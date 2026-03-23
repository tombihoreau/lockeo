import '../models/product.dart';

class RentalPriceBreakdown {
  final int days;
  final double dailyRate;
  final double rentalPrice;

  const RentalPriceBreakdown({
    required this.days,
    required this.dailyRate,
    required this.rentalPrice,
  });
}

class RentalPricing {
  static RentalPriceBreakdown breakdownForProduct(Product product, int days) {
    final safeDays = days < 1 ? 1 : days;
    final dayPrice = product.price ?? 0;

    double dailyRate = dayPrice;

    if (safeDays >= 7 && (product.price7Days ?? 0) > 0) {
      dailyRate = (product.price7Days ?? 0) / 7;
    } else if (safeDays >= 3 && (product.price3Days ?? 0) > 0) {
      dailyRate = (product.price3Days ?? 0) / 3;
    }

    final rentalPrice = _roundCurrency(dailyRate * safeDays);

    return RentalPriceBreakdown(
      days: safeDays,
      dailyRate: _roundCurrency(dailyRate),
      rentalPrice: rentalPrice,
    );
  }

  static double _roundCurrency(double value) =>
      (value * 100).roundToDouble() / 100;
}
