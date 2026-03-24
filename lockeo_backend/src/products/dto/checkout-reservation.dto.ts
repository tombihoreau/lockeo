import { IsIn, IsString } from 'class-validator';

export class CheckoutReservationDto {
  @IsString()
  startDate: string;

  @IsString()
  endDate: string;

  @IsString()
  @IsIn(['visa', 'insufficient_funds', 'three_d_secure'])
  paymentScenario: 'visa' | 'insufficient_funds' | 'three_d_secure';
}
