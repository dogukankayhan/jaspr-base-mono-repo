import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Responsive, cached network image widget.
///
/// Features:
/// - Disk + memory caching via [CachedNetworkImage]
/// - Shimmer placeholder while loading
/// - Configurable error widget
/// - Responsive sizing (fills parent by default)
/// - Shape support: rectangle, rounded, circle
/// - Fade-in animation
/// - Optional overlay gradient (useful for text on image)
/// - Asset / icon fallback when URL is null
class AppImage extends StatelessWidget {
  /// Image URL. If null, [fallbackIcon] is shown.
  final String? imageUrl;

  /// How to inscribe the image into the available space.
  final BoxFit fit;

  /// Fixed width. If null, expands to parent.
  final double? width;

  /// Fixed height. If null, expands to parent.
  final double? height;

  /// Border radius. Ignored when [shape] is [BoxShape.circle].
  final BorderRadius? borderRadius;

  /// Shape of the image container.
  final BoxShape shape;

  /// Gradient overlay drawn on top of the image.
  final Gradient? overlayGradient;

  /// Icon shown when [imageUrl] is null.
  final IconData fallbackIcon;

  /// Size of the fallback icon.
  final double fallbackIconSize;

  /// Color of the fallback icon.
  final Color? fallbackIconColor;

  /// Background color for placeholder and error states.
  final Color? backgroundColor;

  /// Fade-in duration.
  final Duration fadeInDuration;

  /// Custom placeholder builder. Overrides default shimmer.
  final Widget Function(BuildContext context)? placeholderBuilder;

  /// Custom error builder. Overrides default error widget.
  final Widget Function(BuildContext context, String url, Object error)?
  errorBuilder;

  /// Optional color filter applied over the image (e.g. tint).
  final Color? colorFilter;

  /// Optional color blend mode for [colorFilter].
  final BlendMode colorBlendMode;

  const AppImage({
    super.key,
    this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.overlayGradient,
    this.fallbackIcon = Icons.image_outlined,
    this.fallbackIconSize = 40,
    this.fallbackIconColor,
    this.backgroundColor,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.placeholderBuilder,
    this.errorBuilder,
    this.colorFilter,
    this.colorBlendMode = BlendMode.srcATop,
  });

  // ─── Named constructors ──────────────────────────────────

  /// Square avatar with circle shape.
  const AppImage.avatar({
    super.key,
    this.imageUrl,
    double size = 48,
    this.fallbackIcon = Icons.person,
    this.fallbackIconSize = 24,
    this.fallbackIconColor,
    this.backgroundColor,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.placeholderBuilder,
    this.errorBuilder,
    this.colorFilter,
    this.colorBlendMode = BlendMode.srcATop,
  }) : fit = BoxFit.cover,
       width = size,
       height = size,
       borderRadius = null,
       shape = BoxShape.circle,
       overlayGradient = null;

  /// Rounded rectangle thumbnail.
  AppImage.rounded({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    double radius = 12,
    this.fit = BoxFit.cover,
    this.overlayGradient,
    this.fallbackIcon = Icons.image_outlined,
    this.fallbackIconSize = 40,
    this.fallbackIconColor,
    this.backgroundColor,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.placeholderBuilder,
    this.errorBuilder,
    this.colorFilter,
    this.colorBlendMode = BlendMode.srcATop,
  }) : borderRadius = BorderRadius.all(Radius.circular(radius)),
       shape = BoxShape.rectangle;

  @override
  Widget build(BuildContext context) {
    final bg =
        backgroundColor ??
        Theme.of(context).colorScheme.surfaceContainerHighest;

    Widget content;

    if (imageUrl == null || imageUrl!.isEmpty) {
      content = _buildFallback(bg);
    } else {
      content = CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: fit,
        width: width,
        height: height,
        fadeInDuration: fadeInDuration,
        color: colorFilter,
        colorBlendMode: colorBlendMode,
        placeholder: (ctx, url) =>
            placeholderBuilder?.call(ctx) ?? _buildPlaceholder(ctx, bg),
        errorWidget: (ctx, url, error) =>
            errorBuilder?.call(ctx, url, error) ?? _buildError(bg),
      );
    }

    // Clip shape – always clip to prevent overflow
    if (shape == BoxShape.circle) {
      content = ClipOval(child: content);
    } else if (borderRadius != null) {
      content = ClipRRect(borderRadius: borderRadius!, child: content);
    } else {
      content = ClipRect(child: content);
    }

    // Overlay gradient
    if (overlayGradient != null && imageUrl != null && imageUrl!.isNotEmpty) {
      content = Stack(
        fit: StackFit.passthrough,
        children: [
          content,
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: overlayGradient),
            ),
          ),
        ],
      );
    }

    // Fixed size container
    if (width != null || height != null) {
      return SizedBox(width: width, height: height, child: content);
    }

    return content;
  }

  // ─── Private builders ─────────────────────────────────────

  Widget _buildPlaceholder(BuildContext context, Color bg) {
    return Container(
      width: width,
      height: height,
      color: bg,
      child: Center(
        child: _ShimmerBlock(width: width, height: height),
      ),
    );
  }

  Widget _buildError(Color bg) {
    return Container(
      width: width,
      height: height,
      color: bg,
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: fallbackIconSize,
          color: fallbackIconColor ?? Colors.grey,
        ),
      ),
    );
  }

  Widget _buildFallback(Color bg) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: bg, shape: shape),
      child: Center(
        child: Icon(
          fallbackIcon,
          size: fallbackIconSize,
          color: fallbackIconColor ?? Colors.grey,
        ),
      ),
    );
  }
}

/// Simple shimmer animation block used as a loading placeholder.
class _ShimmerBlock extends StatefulWidget {
  final double? width;
  final double? height;
  const _ShimmerBlock({this.width, this.height});

  @override
  State<_ShimmerBlock> createState() => _ShimmerBlockState();
}

class _ShimmerBlockState extends State<_ShimmerBlock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    final highlightColor = Theme.of(
      context,
    ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          color: Color.lerp(baseColor, highlightColor, _animation.value),
        );
      },
    );
  }
}
