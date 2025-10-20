class Category {
  final int categoryId;
  final String label;
  final String iconName;

  Category({
    required this.categoryId,
    required this.label,
    required this.iconName,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryId: json['category_id'],
      label: json['label'],
      iconName: json['iconName'],
    );
  }
}
