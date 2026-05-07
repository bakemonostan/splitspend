import 'package:flutter/material.dart';
import 'package:split_spend/src/theme/theme.dart';

class Skeleton extends StatefulWidget {
  const Skeleton({
    super.key,
    required this.child,
    this.baseColor = AppPalette.neutral100,
    this.highlightColor = AppPalette.neutral50,
  });

  final Widget child;
  final Color baseColor;
  final Color highlightColor;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return ShaderMask(
          shaderCallback: (bounds) {
            final shimmerPosition = _controller.value * 2 - 1;
            return LinearGradient(
              begin: Alignment(-1 + shimmerPosition, -0.3),
              end: Alignment(1 + shimmerPosition, 0.3),
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.2, 0.5, 0.8],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    required this.height,
    this.width,
    this.radius = 10,
  });

  final double height;
  final double? width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppPalette.neutral100,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
