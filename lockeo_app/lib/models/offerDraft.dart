class OfferDraft {
  String? title;
  String? description;
  String? state;
  String? location;
  List<int> categories;
  List<String> photos;
  double? pricePerDay;
  double? pricePerWeek;
  DateTime? startDate;

  OfferDraft({
    this.title,
    this.description,
    this.state,
    this.location,
    this.categories = const [],
    this.photos = const [],
    this.pricePerDay,
    this.startDate,
    this.pricePerWeek,
  });
}
