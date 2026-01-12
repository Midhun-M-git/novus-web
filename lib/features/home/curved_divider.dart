import 'package:flutter/material.dart';

class CurvedDivider extends StatelessWidget {
  final double height;
  final Color color;

  const CurvedDivider({super.key, this.height = 80, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _CurvePainter(color),
        size: Size.infinite,
      ),
    );
  }
}

class _CurvePainter extends CustomPainter {
  final Color color;

  _CurvePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    var path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0); 
    // Create a smooth quadratic bezier curve
    path.quadraticBezierTo(size.width * 0.5, size.height * 1.5, 0, 0); 
    path.close();

    canvas.drawPath(path, paint); // Inverted curve? No, let's try a standard wave
    
    // Let's do a standard wave top-to-bottom
    Path wavePath = Path();
    wavePath.moveTo(0, 0);
    wavePath.lineTo(0, size.height - 20);
    wavePath.quadraticBezierTo(size.width / 4, size.height, size.width / 2, size.height - 20);
    wavePath.quadraticBezierTo(3 * size.width / 4, size.height - 40, size.width, size.height);
    wavePath.lineTo(size.width, 0);
    wavePath.close();
    
    // Actually, simple arc down is best for "Section End"
    Path simpleArc = Path();
    simpleArc.moveTo(0, 0);
    simpleArc.quadraticBezierTo(size.width / 2, size.height, size.width, 0);
    simpleArc.lineTo(size.width, 0);
    simpleArc.close();
    
    // Let's use the simple inverted arc to "cut" into the next section or fill from previous
    // Actually easier: Just draw the shape of the Next Section rising up?
    // Let's stick to a simple container decoration in the main file for now to be safe.
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
