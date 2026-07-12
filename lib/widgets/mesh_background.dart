import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/colors.dart';

class MeshBackground extends StatefulWidget {
  final Widget child;

  const MeshBackground({Key? key, required this.child}) : super(key: key);

  @override
  State<MeshBackground> createState() => _MeshBackgroundState();
}

class _MeshBackgroundState extends State<MeshBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base dark background
        Container(color: AppColors.background),
        // Animated Mesh Gradient Orbs
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _MeshPainter(_controller.value),
              size: Size.infinite,
            );
          },
        ),
        // Content on top
        widget.child,
      ],
    );
  }
}

class _MeshPainter extends CustomPainter {
  final double animationValue;
  _MeshPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..shader = RadialGradient(
        colors: [AppColors.auroraCyan.withOpacity(0.6), Colors.transparent],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.2 + math.sin(animationValue * math.pi * 2) * 50, size.height * 0.2 + math.cos(animationValue * math.pi * 2) * 50),
        radius: size.width * 0.6,
      ))
      ..blendMode = BlendMode.screen;

    final paint2 = Paint()
      ..shader = RadialGradient(
        colors: [AppColors.holographicPurple.withOpacity(0.5), Colors.transparent],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.8 + math.cos(animationValue * math.pi * 2) * 60, size.height * 0.5 + math.sin(animationValue * math.pi * 2) * 60),
        radius: size.width * 0.8,
      ))
      ..blendMode = BlendMode.screen;

    final paint3 = Paint()
      ..shader = RadialGradient(
        colors: [AppColors.sunsetPink.withOpacity(0.4), Colors.transparent],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.5 + math.sin(animationValue * math.pi * 2 + math.pi) * 70, size.height * 0.8 + math.cos(animationValue * math.pi * 2 + math.pi) * 70),
        radius: size.width * 0.7,
      ))
      ..blendMode = BlendMode.screen;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint1);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint2);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint3);
  }

  @override
  bool shouldRepaint(covariant _MeshPainter oldDelegate) => true;
}
