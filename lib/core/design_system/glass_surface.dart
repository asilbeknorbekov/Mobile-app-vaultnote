import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'glass_colors.dart';

// Provider to manage the "Reduce Transparency" accessibility setting
final reduceTransparencyProvider = StateProvider<bool>((ref) => false);

enum GlassTier {
  tier1, // Heaviest blur, nav bar, app bar
  tier2, // Medium blur, cards, modals, sheets
  tier3, // Light blur or flat translucent, chips, tags, list items
}

class GlassSurface extends ConsumerWidget {
  final Widget child;
  final GlassTier tier;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;

  const GlassSurface({
    super.key,
    required this.child,
    this.tier = GlassTier.tier2,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reduceTransparency = ref.watch(reduceTransparencyProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    double blurSigma;
    double opacityMultiplier = 1.0;
    double defaultRadius = 20.0;

    switch (tier) {
      case GlassTier.tier1:
        blurSigma = 24.0;
        opacityMultiplier = 1.2;
        defaultRadius = 28.0;
        break;
      case GlassTier.tier2:
        blurSigma = 16.0;
        opacityMultiplier = 1.0;
        defaultRadius = 20.0;
        break;
      case GlassTier.tier3:
        blurSigma = 8.0;
        opacityMultiplier = 0.8;
        defaultRadius = 12.0;
        break;
    }

    final br = borderRadius ?? BorderRadius.circular(defaultRadius);
    final fillColor = isDark ? GlassColors.darkGlassFill : GlassColors.lightGlassFill;
    final borderColor = isDark ? GlassColors.glassBorderDark : GlassColors.glassBorderLight;

    // Solid fallback for "Reduce Transparency"
    if (reduceTransparency) {
      return Container(
        width: width,
        height: height,
        padding: padding,
        margin: margin,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF),
          borderRadius: br,
          border: Border.all(color: borderColor, width: 1.0),
          boxShadow: const [
            BoxShadow(
              color: GlassColors.glassShadow,
              blurRadius: 10,
              spreadRadius: -2,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: child,
      );
    }

    // Glass implementation
    Widget glassContainer = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: fillColor.withOpacity(fillColor.opacity * opacityMultiplier),
        borderRadius: br,
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: child,
    );

    // Only apply BackdropFilter for Tier 1 and Tier 2 to preserve 60fps
    // Tier 3 is just translucent
    if (tier == GlassTier.tier1 || tier == GlassTier.tier2) {
      glassContainer = ClipRRect(
        borderRadius: br,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: glassContainer,
        ),
      );
    } else {
      glassContainer = ClipRRect(
        borderRadius: br,
        child: glassContainer,
      );
    }

    return RepaintBoundary(
      child: Container(
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: br,
          boxShadow: const [
            BoxShadow(
              color: GlassColors.glassShadow,
              blurRadius: 24,
              spreadRadius: -4,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: glassContainer,
      ),
    );
  }
}
