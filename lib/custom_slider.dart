import 'package:flutter/material.dart';

class CustomSlider extends SliderComponentShape {
  final double thumbRadius;

  const CustomSlider({required this.thumbRadius});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(PaintingContext context, Offset center,
      {required Animation<double> activationAnimation,
      required Animation<double> enableAnimation,
      required bool isDiscrete,
      required TextPainter labelPainter,
      required RenderBox parentBox,
      required SliderThemeData sliderTheme,
      required TextDirection textDirection,
      required double value,
      required double textScaleFactor,
      required Size sizeWithOverflow}) {
    final Canvas canvas = context.canvas;
    Paint paint1 = Paint()
      ..color = Color(0xff63aa65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    final rect = Rect.fromCircle(center: center, radius: thumbRadius);
    final rrect = RRect.fromRectAndRadius(
      Rect.fromPoints(
        Offset(rect.left - 5, rect.top),
        Offset(rect.right + 5, rect.bottom),
      ),
      Radius.circular(thumbRadius + 2),
    );

    final fillPaint = Paint()
      ..color = sliderTheme.activeTrackColor!
      ..style = PaintingStyle.fill;

    canvas.drawRRect(rrect, fillPaint);
  }
}
