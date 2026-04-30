import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_petition_app/core/constants/app_assets.dart';


/// Enum to represent different image types
enum ImageType { svg, svgString, png, network, file, gif, unknown }

/// Extension to determine the type of image based on its path
extension ImageTypeExtension on String {
  ImageType get imageType {
    if (startsWith('<svg')) {
      return ImageType.svgString;
    } else if (startsWith('http') || startsWith('https')) {
      if (toLowerCase().endsWith('.gif')) {
        return ImageType.gif;
      }
      return ImageType.network;
    } else if (endsWith('.svg')) {
      return ImageType.svg;
    } else if (startsWith('file://')) {
      if (toLowerCase().endsWith('.gif')) {
        return ImageType.gif;
      }
      return ImageType.file;
    } else if (endsWith('.png') || endsWith('.jpg') || endsWith('.jpeg')) {
      return ImageType.png;
    } else if (endsWith('.gif')) {
      return ImageType.gif;
    } else {
      return ImageType.unknown;
    }
  }
}

/// A reusable custom image widget
class CustomImageWidget extends StatelessWidget {
  final String? imagePath;
  final double? height;
  final double? width;
  final Color? color;
  final BoxFit? fit;
  final String placeHolder;
  final Alignment? alignment;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? radius;
  final BoxBorder? border;
  final Widget? errorWidget;

  const CustomImageWidget({
    Key? key,
    this.imagePath,
    this.height,
    this.width,
    this.color,
    this.fit,
    this.alignment,
    this.onTap,
    this.radius,
    this.margin,
    this.border,
    this.errorWidget,
    this.placeHolder = AppAssets.logo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(
      alignment: alignment!,
      child: _buildWidget(),
    )
        : _buildWidget();
  }

  Widget _buildWidget() {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: _buildCircleImage(),
      ),
    );
  }

  Widget _buildCircleImage() {
    if (radius != null) {
      return ClipRRect(
        borderRadius: radius!,
        child: _buildImageWithBorder(),
      );
    }
    return _buildImageWithBorder();
  }

  Widget _buildImageWithBorder() {
    if (border != null) {
      return Container(
        decoration: BoxDecoration(
          border: border,
          borderRadius: radius,
        ),
        child: _buildImageView(),
      );
    }
    return _buildImageView();
  }

  Widget _buildImageView() {
    if (imagePath != null) {
      switch (imagePath!.imageType) {
        case ImageType.svg:
          return SvgPicture.asset(
            imagePath!,
            height: height,
            width: width,
            fit: fit ?? BoxFit.contain,
            colorFilter: color != null
                ? ColorFilter.mode(color!, BlendMode.srcIn)
                : null,
          );
        case ImageType.svgString:
          return SvgPicture.string(
            imagePath!,
            height: height,
            width: width,
            fit: fit ?? BoxFit.contain,
            colorFilter: color != null
                ? ColorFilter.mode(color!, BlendMode.srcIn)
                : null,
          );
        case ImageType.file:
          return Image.file(
            File(imagePath!),
            height: height,
            width: width,
            fit: fit ?? BoxFit.cover,
            color: color,
          );
        case ImageType.network:
        // 🔥 FIXED: Direct Image.network instead of CachedNetworkImage
          return Image.network(
            imagePath!,
            height: height,
            width: width,
            fit: fit ?? BoxFit.cover,
            color: color,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;

              return Container(
                height: height,
                width: width,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: radius,
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                        : null,
                    strokeWidth: 2,
                    color: Colors.grey.shade400,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              debugPrint("❌ Network Image Error: $error");
              debugPrint("❌ Failed URL: $imagePath");
              if (errorWidget != null) return errorWidget!;
              return Container(
                height: height,
                width: width,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: radius,
                ),
                child: const Icon(
                  Icons.person,
                  size: 32,
                  color: Colors.grey,
                ),
              );
            },
          );
        case ImageType.png:
          return Image.asset(
            imagePath!,
            height: height,
            width: width,
            fit: fit ?? BoxFit.cover,
            color: color,
          );
        case ImageType.gif:
          if (imagePath!.startsWith('http')) {
            // 🔥 FIXED: Direct Image.network for GIFs too
            return Image.network(
              imagePath!,
              height: height,
              width: width,
              fit: fit ?? BoxFit.cover,
              color: color,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;

                return Center(
                  child: SizedBox(
                    height: 30,
                    width: 30,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.grey.shade200,
                    ),
                  ),
                );
              },
            );
          } else if (imagePath!.startsWith('file://')) {
            return Image.file(
              File(imagePath!),
              height: height,
              width: width,
              fit: fit ?? BoxFit.cover,
              color: color,
            );
          } else {
            return Image.asset(
              imagePath!,
              height: height,
              width: width,
              fit: fit ?? BoxFit.cover,
              color: color,
            );
          }
        case ImageType.unknown:
        default:
          return Image.asset(
            placeHolder,
            height: height,
            width: width,
            fit: fit ?? BoxFit.contain,
            color: Colors.grey,
            colorBlendMode: BlendMode.srcIn,
          );





      }
    }
    return const SizedBox();
  }
}
