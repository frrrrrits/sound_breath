import 'package:flutter/material.dart';
import 'package:sound_breath/utils/palette.dart';

class CardItemView extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;

  const CardItemView({
    super.key,
    required this.label,
    this.onTap,
  });

  @override
  State<CardItemView> createState() => _CardItemViewState();
}

class _CardItemViewState extends State<CardItemView> {
  late final Palette palette; // persistent, never recreated
  double _scale = 1.0;
  double _blur = 28.0;

  void _press() {
    setState(() {
      _scale = 0.24;
      _blur = 40;
    });
  }

  void _release() async {
    setState(() {
      _scale = 1.0;
      _blur = 28;
    });

    await Future.delayed(const Duration(milliseconds: 90));
    widget.onTap?.call();
  }

  @override
  void initState() {
    super.initState();
    palette = Palette.random(); // generate once ONLY
  }

  @override
  Widget build(BuildContext context) {
    final primary = palette.primary;
    final light = palette.light;
    final dark = palette.dark;

    return GestureDetector(
      onTapDown: (_) => _press(),
      onTapUp: (_) => _release(),
      onTapCancel: () => _release(),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
        tween: Tween(begin: 1.0, end: _scale),
        builder: (context, scale, child) => Transform.scale(
          scale: scale,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 360),
            curve: Curves.easeOutCubic,
            tween: Tween(begin: 28, end: _blur),
            builder: (context, blur, _) => Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [light, primary],
                ),
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.6),
                    blurRadius: blur,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: dark.withValues(alpha: .25),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    radius: 0.9,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: .18),
                      Colors.black.withValues(alpha: .28),
                    ],
                    stops: const [0.0, 0.75, 1.0],
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                widget.label,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: palette.textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
