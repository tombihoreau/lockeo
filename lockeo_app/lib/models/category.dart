class Category {
  final int categoryId;
  final String label;
  final int? parentId;

  Category({required this.categoryId, required this.label, this.parentId});

  bool get isParent => parentId == null || parentId == 0;
  bool get isChild => parentId != null && parentId != 0;

  static int? _parseNullableInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    final id = json['category_id'] ?? json['categoryId'];
    final parentRaw = json['parent_id'] ?? json['parentId'];
    final parsedParent = _parseNullableInt(parentRaw) ?? 0;

    return Category(
      categoryId: (id is num) ? id.toInt() : int.parse(id.toString()),
      label: (json['label'] ?? '').toString(),
      parentId: parsedParent,
    );
  }

  Map<String, dynamic> toJson() => {
    'category_id': categoryId,
    'label': label,
    'parent_id': parentId ?? 0,
  };

  List<Category> onlyParents(List<Category> all) =>
      all.where((c) => c.isParent).toList();

  List<Category> childrenOf(List<Category> all, int parentId) =>
      all.where((c) => c.parentId == parentId).toList();
}
