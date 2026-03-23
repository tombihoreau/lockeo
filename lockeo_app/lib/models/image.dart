import '../services/backend_config.dart';

class ImageModel {
  final int imageId;
  final int productId;
  final String url;
  final int positionImage;
  final String createdAt;

  ImageModel({
    required this.imageId,
    required this.productId,
    required this.url,
    required this.positionImage,
    required this.createdAt,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    String normalizePath(dynamic raw) {
      final value = (raw ?? '').toString().trim();
      if (value.isEmpty) return 'assets/images/default.jpg';
      if (value.startsWith('assets/') ||
          value.startsWith('http://') ||
          value.startsWith('https://') ||
          value.startsWith('file://')) {
        return value;
      }
      if (value.startsWith('uploads/') ||
          value.startsWith('/uploads/') ||
          value.startsWith('api/uploads/') ||
          value.startsWith('/api/uploads/')) {
        return BackendConfig.resolveApiUrl(value);
      }
      if (value.startsWith('/')) return value;
      return 'assets/images/$value';
    }

    return ImageModel(
      imageId: json['image_id'],
      productId: json['product_id'],
      url: normalizePath(json['url'] ?? json['uri']),
      positionImage: json['position_image'],
      createdAt: json['created_at'],
    );
  }
}
