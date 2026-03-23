import 'package:image_picker/image_picker.dart';

class OfferDraft {
  String? title;
  String? description;
  String? state;
  String? location;
  List<int> categories;
  List<XFile> photos;
  double? pricePerDay;
  double? price3Days;
  double? pricePerWeek;
  DateTime? startDate;
  List<int>? availableWeekDays;
  List<DateTime>? unavailableDates;

  OfferDraft({
    this.title,
    this.description,
    this.state,
    this.location,
    this.categories = const [],
    this.photos = const [],
    this.pricePerDay,
    this.price3Days,
    this.startDate,
    this.pricePerWeek,
    this.availableWeekDays,
    this.unavailableDates,
  });
}
