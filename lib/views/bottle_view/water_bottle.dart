import 'package:flutter/material.dart';

class WaterBottle extends StatefulWidget {
  const WaterBottle({
    Key? key,
    this.width = 120,
    this.height = 240,
    this.animationDuration = const Duration(milliseconds: 600),
  }) : super(key: key);

  final double width;
  final double height;
  final Duration animationDuration;

  @override
  WaterBottleState createState() => WaterBottleState();
}

class WaterBottleState extends State<WaterBottle> {
  /// 0.0 – 1.0
  double _level = 0.0;

  /// Call this from outside to add water.
  /// [amount] is in 0.0–1.0 range (e.g. 0.1 = +10%)
  void addWater(double amount) {
    setState(() {
      _level = (_level + amount).clamp(0.0, 1.0);
    });
  }

  /// You can also set explicitly if you want
  void setLevel(double level) {
    setState(() {
      _level = level.clamp(0.0, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: TweenAnimationBuilder<double>(
        // TweenAnimationBuilder automatically animates
        // from the old end value to the new end value.
        tween: Tween<double>(begin: 0, end: _level),
        duration: widget.animationDuration,
        curve: Curves.easeInOut,
        builder: (context, animatedLevel, child) {
          return CustomPaint(
            painter: _BottlePainter(fillLevel: animatedLevel),
          );
        },
      ),
    );
  }
}

class _BottlePainter extends CustomPainter {
  final double fillLevel; // 0.0 – 1.0

  _BottlePainter({
    required this.fillLevel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double centerX = w / 2;

    // Bottle proportions
    final double neckWidth = w * 0.3;
    final double bodyWidth = w * 0.7;
    final double neckHeight = h * 0.18;
    final double shoulderHeight = h * 0.08;
    final double baseRadius = w * 0.16;

    final double bodyTopY = neckHeight + shoulderHeight;
    final double bodyBottomY = h;

    // Bottle outline path
    final Path bottlePath = Path()
      // Left neck down
      ..moveTo(centerX - neckWidth / 2, 0)
      ..lineTo(centerX - neckWidth / 2, neckHeight)
      // Left shoulder
      ..lineTo(centerX - bodyWidth / 2, bodyTopY)
      // Left body side
      ..lineTo(centerX - bodyWidth / 2, bodyBottomY - baseRadius)
      // Bottom left curve -> center
      ..quadraticBezierTo(
        centerX - bodyWidth / 2,
        bodyBottomY,
        centerX,
        bodyBottomY,
      )
      // Bottom right curve -> right side
      ..quadraticBezierTo(
        centerX + bodyWidth / 2,
        bodyBottomY,
        centerX + bodyWidth / 2,
        bodyBottomY - baseRadius,
      )
      // Right body side up
      ..lineTo(centerX + bodyWidth / 2, bodyTopY)
      // Right shoulder & neck
      ..lineTo(centerX + neckWidth / 2, neckHeight)
      ..lineTo(centerX + neckWidth / 2, 0)
      // Top edge (cap)
      ..lineTo(centerX - neckWidth / 2, 0)
      ..close();

    final Paint bottlePaint = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.035;

    final Paint waterPaint = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.fill;

    // Compute water rect based on fillLevel (clamped 0–1)
    final double clamped = fillLevel.clamp(0.0, 1.0);
    final double bodyHeight = bodyBottomY - bodyTopY;
    final double waterHeight = bodyHeight * clamped;

    final double waterTop = bodyBottomY - waterHeight;
    final Rect waterRect = Rect.fromLTRB(
      centerX - bodyWidth / 2 + bottlePaint.strokeWidth,
      waterTop,
      centerX + bodyWidth / 2 - bottlePaint.strokeWidth,
      bodyBottomY - bottlePaint.strokeWidth / 2,
    );

    // Clip to bottle shape, then draw water
    canvas.save();
    canvas.clipPath(bottlePath);
    canvas.drawRect(waterRect, waterPaint);
    canvas.restore();

    // Draw outline on top
    canvas.drawPath(bottlePath, bottlePaint);
  }

  @override
  bool shouldRepaint(covariant _BottlePainter oldDelegate) {
    return oldDelegate.fillLevel != fillLevel;
  }
}
