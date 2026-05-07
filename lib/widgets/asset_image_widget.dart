import 'package:flutter/material.dart';

/// Widget لعرض الصور من assets بشكل محسّن
/// مع خلفية شفافة ومحاذاة جيدة
class AssetImageWidget extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? backgroundColor;
  final Widget? errorWidget;
  final AlignmentGeometry alignment;

  const AssetImageWidget({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.backgroundColor,
    this.errorWidget,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: alignment,
      decoration: backgroundColor != null
          ? BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            )
          : null,
      child: Image.asset(
        assetPath,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ??
              Icon(
                Icons.image_not_supported,
                size: width != null ? width! * 0.6 : 30,
                color: Colors.grey,
              );
        },
      ),
    );
  }
}
