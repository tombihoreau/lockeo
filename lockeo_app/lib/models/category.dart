class Category {
  final int categoryId;
  final String label;
  final String iconUrl;

  Category({
    required this.categoryId,
    required this.label,
    required this.iconUrl,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryId: json['category_id'],
      label: json['label'],
      iconUrl: json['iconUrl'],
    );
  }
}
