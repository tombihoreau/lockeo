class Category {
  final int categoryId;
  final String label;
  final int? parentId; // null = parent (ou parent_id absent/0)

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

    final parsedParent = _parseNullableInt(parentRaw);
    final normalizedParent = (parsedParent == 0) ? null : parsedParent;

    return Category(
      categoryId: (id is num) ? id.toInt() : int.parse(id.toString()),
      label: (json['label'] ?? '').toString(),
      parentId: normalizedParent,
    );
  }

  Map<String, dynamic> toJson() => {
    'category_id': categoryId,
    'label': label,
    if (parentId != null) 'parent_id': parentId,
  };

  List<Category> onlyParents(List<Category> all) =>
      all.where((c) => c.isParent).toList();

  List<Category> childrenOf(List<Category> all, int parentId) =>
      all.where((c) => c.parentId == parentId).toList();
}
