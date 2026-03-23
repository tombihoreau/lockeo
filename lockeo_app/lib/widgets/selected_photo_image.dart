import 'package:flutter/material.dart';

import 'selected_photo_image_impl.dart'
    if (dart.library.html) 'selected_photo_image_web.dart'
    if (dart.library.io) 'selected_photo_image_io.dart'
    as impl;

class SelectedPhotoImage extends StatelessWidget {
  final String path;
  final BoxFit fit;
  final double? width;
  final double? height;
  final ImageErrorWidgetBuilder? errorBuilder;

  const SelectedPhotoImage({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return impl.buildSelectedPhotoImage(
      path: path,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: errorBuilder,
    );
  }
}
