import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/offerDraft.dart';
import '../../widgets/button.dart';
import 'create_offer_step3_screen.dart';
import 'package:lockeo_app/theme/app_colors.dart';
import 'package:lockeo_app/theme/app_text_styles.dart';

class CreateOfferStep2Screen extends StatefulWidget {
  final OfferDraft draft;

  const CreateOfferStep2Screen({super.key, required this.draft});

  @override
  State<CreateOfferStep2Screen> createState() => _CreateOfferStep2ScreenState();
}

class _CreateOfferStep2ScreenState extends State<CreateOfferStep2Screen> {
  // ---------- Variables de test (tu changes ici) ----------
  final double discount3Days = 0.05; // -5%
  final double discount7Days = 0.10; // -10%
  final int stepEuro = 1; // incrément +/- en €

  final pricePerDayController = TextEditingController();

  double? _dayPrice;

  int _price3Days = 0; // total pour 3 jours
  int _price7Days = 0; // total pour 7 jours

  @override
  void initState() {
    super.initState();

    // Si tu veux pré-remplir depuis le draft :
    if (widget.draft.pricePerDay != null && widget.draft.pricePerDay! > 0) {
      final initial = widget.draft.pricePerDay!.round();
      pricePerDayController.text = initial.toString();
      _applyDayPrice(initial.toDouble());
    }

    pricePerDayController.addListener(_onDayPriceChanged);
  }

  @override
  void dispose() {
    pricePerDayController.removeListener(_onDayPriceChanged);
    pricePerDayController.dispose();
    super.dispose();
  }

  void _onDayPriceChanged() {
    final raw = pricePerDayController.text.trim();
    if (raw.isEmpty) {
      setState(() {
        _dayPrice = null;
        _price3Days = 0;
        _price7Days = 0;
      });
      return;
    }

    final parsed = double.tryParse(raw);
    if (parsed == null || parsed <= 0) return;

    _applyDayPrice(parsed);
  }

  int _roundEuro(double v) => v.round();

  int get _minTotal => (_dayPrice ?? 0).round(); // min = prix/jour
  int get _max3 => _roundEuro((_dayPrice ?? 0) * 3);
  int get _max7 => _roundEuro((_dayPrice ?? 0) * 7);

  int get _recommended3 => _roundEuro(_max3 * (1 - discount3Days));
  int get _recommended7 => _roundEuro(_max7 * (1 - discount7Days));

  void _applyDayPrice(double newDayPrice) {
    setState(() {
      _dayPrice = newDayPrice;

      // Initialise les totaux sur le prix conseillé (borné min/max)
      _price3Days = _clampInt(_recommended3, _minTotal, _max3);
      _price7Days = _clampInt(_recommended7, _minTotal, _max7);
    });
  }

  int _clampInt(int value, int min, int max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  void _inc3() => setState(
    () => _price3Days = _clampInt(_price3Days + stepEuro, _minTotal, _max3),
  );
  void _dec3() => setState(
    () => _price3Days = _clampInt(_price3Days - stepEuro, _minTotal, _max3),
  );

  void _inc7() => setState(
    () => _price7Days = _clampInt(_price7Days + stepEuro, _minTotal, _max7),
  );
  void _dec7() => setState(
    () => _price7Days = _clampInt(_price7Days - stepEuro, _minTotal, _max7),
  );

  bool get _showDurations => _dayPrice != null && _dayPrice! > 0;

  void goToStep3() {
    if (!_showDurations) return;

    widget.draft.pricePerDay = _dayPrice;
    widget.draft.pricePerWeek = _price7Days
        .toDouble(); // total 7 jours (comme ton ancien champ "semaine")
    widget.draft.price3Days = _price3Days.toDouble();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateOfferStep3Screen(draft: widget.draft),
      ),
    );
  }

  Widget _pillRecommended(int value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.blue50,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.primaryBlue, width: 1),
      ),
      child: Text(
        "Prix conseillé : $value€",
        style: AppTextStyles.caption.copyWith(color: AppColors.primaryBlue),
      ),
    );
  }

  Widget _minusButton({required bool enabled, required VoidCallback onTap}) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(
          Icons.remove,
          size: 18,
          color: enabled ? Colors.black : Colors.grey,
        ),
      ),
    );
  }

  Widget _plusButton({required bool enabled, required VoidCallback onTap}) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(
          Icons.add,
          size: 18,
          color: enabled ? Colors.black : Colors.grey,
        ),
      ),
    );
  }

  Widget _durationRow({
    required String title,
    required int current,
    required int recommended,
    required int min,
    required int max,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    final bool canMinus = current > min;
    final bool canPlus = current < max;

    final Color amountColor = (current <= recommended)
        ? AppColors.green
        : AppColors.primaryRed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
              ),
            ),
            _pillRecommended(recommended),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _minusButton(enabled: canMinus, onTap: onMinus),
            const SizedBox(width: 24),
            Text(
              "$current €",
              style: AppTextStyles.h1.copyWith(color: amountColor),
            ),
            const SizedBox(width: 24),
            _plusButton(enabled: canPlus, onTap: onPlus),
          ],
        ),
      ],
    );
  }

  Widget _dayPriceInput() {
    return Center(
      child: Container(
        width: 160,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: pricePerDayController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              "€",
              style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final minTotal = _minTotal;
    final max3 = _max3;
    final max7 = _max7;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Icon(Icons.chevron_left, color: Colors.black),
            ),
          ),
        ),
        centerTitle: false,
        title: Text(
          "Fixez votre prix",
          style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(
              "2/3",
              style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Pour une journée", style: AppTextStyles.h3),
            const SizedBox(height: 16),
            _dayPriceInput(),

            if (_showDurations) ...[
              const SizedBox(height: 24),

              Text(
                "Fixez des tarifs par durée de location.\n"
                "Un prix dégressif incite les locataires à réserver sur\n"
                "plusieurs jours.",
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 24),

              _durationRow(
                title: "Pour 3 jours",
                current: _price3Days,
                recommended: _recommended3,
                min: minTotal,
                max: max3,
                onMinus: _dec3,
                onPlus: _inc3,
              ),

              const SizedBox(height: 24),

              _durationRow(
                title: "Pour 7 jours",
                current: _price7Days,
                recommended: _recommended7,
                min: minTotal,
                max: max7,
                onMinus: _dec7,
                onPlus: _inc7,
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 54,
            child: CustomButton(
              text: "Suivant",
              onPressed: _showDurations ? goToStep3 : null,
            ),
          ),
        ),
      ),
    );
  }
}
