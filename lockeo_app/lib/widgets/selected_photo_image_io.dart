import 'dart:io';

import 'package:flutter/material.dart';

Widget buildSelectedPhotoImage({
  required String path,
  required BoxFit fit,
  double? width,
  double? height,
  ImageErrorWidgetBuilder? errorBuilder,
}) {
  if (path.startsWith('assets/')) {
    return Image.asset(
      path,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: errorBuilder,
    );
  }

  if (path.startsWith('http://') || path.startsWith('https://')) {
    return Image.network(
      path,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: errorBuilder,
    );
  }

  return Image.file(
    File(path),
    fit: fit,
    width: width,
    height: height,
    errorBuilder: errorBuilder,
  );
}
