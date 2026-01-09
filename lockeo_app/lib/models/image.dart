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
    return ImageModel(
      imageId: json['image_id'],
      productId: json['product_id'],
      url: json['url'],
      positionImage: json['position_image'],
      createdAt: json['created_at'],
    );
  }
}
