import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

/// 毛玻璃容器组件
/// 提供毛玻璃效果的容器
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final double blurAmount;
  final Color? backgroundColor;
  final Border? border;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blurAmount = 10.0,
    this.backgroundColor,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: borderRadius ??
            BorderRadius.circular(AppDimensions.radiusMd),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blurAmount,
            sigmaY: blurAmount,
          ),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: backgroundColor ?? AppColors.glass,
              borderRadius: borderRadius ??
                  BorderRadius.circular(AppDimensions.radiusMd),
              border: border ??
                  Border.all(
                    color: AppColors.glassBorder,
                    width: 0.5,
                  ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// 毛玻璃对话框
/// 提供毛玻璃效果的对话框背景
class GlassDialog extends StatelessWidget {
  final Widget child;
  final double blurAmount;

  const GlassDialog({
    super.key,
    required this.child,
    this.blurAmount = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: blurAmount,
        sigmaY: blurAmount,
      ),
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: GlassContainer(
          padding: const EdgeInsets.all(AppDimensions.paddingXl),
          child: child,
        ),
      ),
    );
  }
}
