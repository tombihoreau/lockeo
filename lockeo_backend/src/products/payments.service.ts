import {
  BadRequestException,
  Injectable,
  InternalServerErrorException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

export type DemoPaymentScenario =
  | 'visa'
  | 'insufficient_funds'
  | 'three_d_secure';

export interface DemoPaymentResult {
  provider: 'mock_demo' | 'stripe_test';
  status: 'succeeded';
  reference: string;
  cardLabel: string;
  cardNumberPreview: string;
}

interface ScenarioDefinition {
  cardLabel: string;
  cardNumberPreview: string;
  stripePaymentMethod: string;
}

@Injectable()
export class PaymentsService {
  constructor(private readonly configService: ConfigService) {}

  async chargeDemoPayment(
    amount: number,
    reservationId: number,
    scenario: DemoPaymentScenario,
  ): Promise<DemoPaymentResult> {
    const scenarioDefinition = this.getScenarioDefinition(scenario);
    const stripeSecretKey = this.configService
      .get<string>('STRIPE_SECRET_KEY', '')
      .trim();

    if (!stripeSecretKey) {
      return this.chargeWithMock(reservationId, scenario, scenarioDefinition);
    }

    return this.chargeWithStripe(
      stripeSecretKey,
      amount,
      reservationId,
      scenario,
      scenarioDefinition,
    );
  }

  private async chargeWithStripe(
    stripeSecretKey: string,
    amount: number,
    reservationId: number,
    scenario: DemoPaymentScenario,
    definition: ScenarioDefinition,
  ): Promise<DemoPaymentResult> {
    const amountInCents = Math.max(50, Math.round(amount * 100));
    const body = new URLSearchParams();
    body.set('amount', amountInCents.toString());
    body.set('currency', 'eur');
    body.set('confirm', 'true');
    body.set('payment_method', definition.stripePaymentMethod);
    body.set('payment_method_types[]', 'card');
    body.set('description', `Reservation Lockeo #${reservationId}`);
    body.set('metadata[reservation_id]', reservationId.toString());
    body.set('metadata[payment_scenario]', scenario);

    const response = await fetch('https://api.stripe.com/v1/payment_intents', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${stripeSecretKey}`,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: body.toString(),
    });

    const payload = (await response.json()) as Record<string, unknown>;

    if (!response.ok) {
      const error = this.extractStripeError(payload);
      throw new BadRequestException(
        error ?? 'Le paiement de test Stripe a echoue',
      );
    }

    const status = (payload.status as string | undefined)?.trim();
    if (status !== 'succeeded') {
      if (status === 'requires_action') {
        throw new BadRequestException(
          "Cette carte de test demande une authentification 3D Secure. La suite du parcours n'est pas activee dans cette demo.",
        );
      }

      if (status === 'requires_payment_method') {
        throw new BadRequestException(
          this.extractStripeError(payload) ??
            'Le paiement de test a ete refuse par Stripe',
        );
      }

      throw new BadRequestException(
        `Le paiement de test Stripe est revenu avec le statut ${status ?? 'inconnu'}`,
      );
    }

    return {
      provider: 'stripe_test',
      status: 'succeeded',
      reference:
        (payload.id as string | undefined) ?? `pi_demo_${reservationId}`,
      cardLabel: definition.cardLabel,
      cardNumberPreview: definition.cardNumberPreview,
    };
  }

  private chargeWithMock(
    reservationId: number,
    scenario: DemoPaymentScenario,
    definition: ScenarioDefinition,
  ): DemoPaymentResult {
    if (scenario === 'insufficient_funds') {
      throw new BadRequestException(
        'Paiement de demonstration refuse: fonds insuffisants',
      );
    }

    if (scenario === 'three_d_secure') {
      throw new BadRequestException(
        'Paiement de demonstration interrompu: authentification 3D Secure requise',
      );
    }

    return {
      provider: 'mock_demo',
      status: 'succeeded',
      reference: `mock_pi_${reservationId}_${Date.now().toString(36)}`,
      cardLabel: definition.cardLabel,
      cardNumberPreview: definition.cardNumberPreview,
    };
  }

  private getScenarioDefinition(
    scenario: DemoPaymentScenario,
  ): ScenarioDefinition {
    switch (scenario) {
      case 'visa':
        return {
          cardLabel: 'Visa de test',
          cardNumberPreview: '4242 4242 4242 4242',
          stripePaymentMethod: 'pm_card_visa',
        };
      case 'insufficient_funds':
        return {
          cardLabel: 'Carte test refusee',
          cardNumberPreview: '4000 0000 0000 9995',
          stripePaymentMethod: 'pm_card_visa_chargeDeclinedInsufficientFunds',
        };
      case 'three_d_secure':
        return {
          cardLabel: 'Carte test 3D Secure',
          cardNumberPreview: '4000 0000 0000 3220',
          stripePaymentMethod: 'pm_card_threeDSecure2Required',
        };
    }
  }

  private extractStripeError(
    payload: Record<string, unknown>,
  ): string | undefined {
    const error = payload.error;
    if (
      error != null &&
      typeof error === 'object' &&
      'message' in error &&
      typeof error.message === 'string'
    ) {
      return error.message;
    }

    return undefined;
  }

  failUnexpectedPaymentError(error: unknown): never {
    if (error instanceof BadRequestException) {
      throw error;
    }

    throw new InternalServerErrorException(
      "Impossible d'initialiser le paiement de demonstration",
    );
  }
}
