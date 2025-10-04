class Category {
  final int categoryId;
  final String label;

  Category({
    required this.categoryId,
    required this.label,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryId: json['category_id'],
      label: json['label'],
    );
  }
}
