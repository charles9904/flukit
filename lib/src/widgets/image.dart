import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum FluImageSource { svg, asset, network, file }

class FluImage extends StatelessWidget {
  const FluImage({
    Key? key,
    this.height,
    this.width,
    this.radius,
    this.source,
    this.boxShadow,
    this.provider,
    this.frameBuilder,
    this.errorBuilder,
    this.placeholder,
    this.progressIndicatorBuilder,
    this.httpHeaders,
    required this.image,
    this.fit = BoxFit.cover,
    this.margin = EdgeInsets.zero,
    this.overlayOpacity = .05,
    this.cache = true,
    this.package,
    this.gradientOverlay = false,
    this.overlayGradientBegin,
    this.overlayGradientEnd,
    this.constraints,
  }) : super(key: key);

  final Widget Function(BuildContext, Widget, int?, bool)? frameBuilder;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;
  final Widget Function(BuildContext, String)? placeholder;
  final Widget Function(BuildContext, String, DownloadProgress)?
      progressIndicatorBuilder;

  final BoxShadow? boxShadow;
  final bool cache;
  final BoxConstraints? constraints;
  final BoxFit? fit;
  final bool gradientOverlay;
  final Map<String, String>? httpHeaders;
  final String image;
  final EdgeInsets? margin;
  final AlignmentGeometry? overlayGradientBegin, overlayGradientEnd;
  final double overlayOpacity;
  final String? package;
  final ImageProvider<Object>? provider;
  final double? height, width, radius;
  final FluImageSource? source;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: height,
        width: width,
        margin: margin,
        clipBehavior: Clip.hardEdge,
        constraints: constraints,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius ?? 0),
            boxShadow: [if (boxShadow != null) boxShadow!]),
        child: Stack(
          children: [
            if (source == FluImageSource.svg)
              SvgPicture.asset(
                image,
                height: height,
                width: width,
                fit: fit ?? BoxFit.cover,
                package: package,
              )
            else if (source == FluImageSource.network)
              CachedNetworkImage(
                imageUrl: image,
                height: height,
                width: width,
                fit: fit ?? BoxFit.cover,
                // TODO make caching optional
                // cacheManager: cache ? BaseCacheManager() : null,
                errorWidget: errorBuilder != null
                    ? (context, url, error) =>
                        errorBuilder!(context, url, error)
                    : null,
                progressIndicatorBuilder: progressIndicatorBuilder,
                placeholder: placeholder,
                httpHeaders: httpHeaders,
              )
            else if (source == FluImageSource.file)
              Image.file(File(image),
                  height: height,
                  width: width,
                  fit: fit ?? BoxFit.cover,
                  errorBuilder: errorBuilder,
                  frameBuilder: frameBuilder)
            else if (source == FluImageSource.asset)
              Image.asset(
                image,
                height: height,
                width: width,
                fit: fit ?? BoxFit.cover,
                errorBuilder: errorBuilder,
                frameBuilder: frameBuilder,
                package: package,
              ),
            Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: gradientOverlay
                        ? null
                        : Colors.black.withOpacity(overlayOpacity),
                    gradient: gradientOverlay
                        ? LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(overlayOpacity),
                            ],
                            begin: overlayGradientBegin ?? Alignment.topCenter,
                            end: overlayGradientEnd ?? Alignment.bottomCenter,
                          )
                        : null,
                  ),
                )),
          ],
        ));
  }
}
