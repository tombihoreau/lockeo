import 'dart:io';

import 'package:flutter/material.dart';

import '../services/backend_config.dart';

Widget buildSelectedPhotoImage({
  required String path,
  required BoxFit fit,
  double? width,
  double? height,
  ImageErrorWidgetBuilder? errorBuilder,
}) {
  final normalizedPath = path.trim();

  if (normalizedPath.isEmpty) {
    return Image.asset(
      'assets/images/default.jpg',
      fit: fit,
      width: width,
      height: height,
      errorBuilder: errorBuilder,
    );
  }

  if (normalizedPath.startsWith('assets/')) {
    return Image.asset(
      normalizedPath,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: errorBuilder,
    );
  }

  if (normalizedPath.startsWith('http://') ||
      normalizedPath.startsWith('https://')) {
    return Image.network(
      normalizedPath,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: errorBuilder,
    );
  }

  if (normalizedPath.startsWith('uploads/') ||
      normalizedPath.startsWith('/uploads/') ||
      normalizedPath.startsWith('api/uploads/') ||
      normalizedPath.startsWith('/api/uploads/')) {
    return Image.network(
      BackendConfig.resolveApiUrl(normalizedPath),
      fit: fit,
      width: width,
      height: height,
      errorBuilder: errorBuilder,
    );
  }

  return Image.file(
    File(normalizedPath),
    fit: fit,
    width: width,
    height: height,
    errorBuilder: errorBuilder,
  );
}
