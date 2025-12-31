import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Scaffold(
        body: Center(
          child: Container(
            clipBehavior: .antiAlias,
            decoration: BoxDecoration(),
            child: CustomPaint(painter: PaintBarGraph(), size: Size(200, 200)),
          ),
        ),
      ),
    );
  }
}

class PaintBarGraph extends CustomPainter {
  PaintBarGraph();

  final backGroundPaint = Paint()
    ..color = .fromRGBO(0, 0, 0, 0.05)
    ..strokeWidth = 2
    ..style = .stroke;

  @override
  void paint(Canvas canvas, Size size) {
    const double viewAngle = 15;
    final widthMidPoint = size.width / 2;

    for (var y in List.generate(
      5,
      (idx) =>
          ((size.height - 5 * backGroundPaint.strokeWidth) / 4) * idx +
          backGroundPaint.strokeWidth / 2 +
          backGroundPaint.strokeWidth * idx,
    )) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), backGroundPaint);
    }

    // final groundPainter = Paint();
    // final groundPlaneY =
    //     size.height - _getAdjacentForOpposite(viewAngle, widthMidPoint);
    final groundOriginPoint = Offset(widthMidPoint, size.height - 40);
    // canvas.drawLine(
    //   groundOriginPoint,
    //   _getAngledOffset(groundOriginPoint, widthMidPoint, -viewAngle),
    //   groundPainter,
    // );
    // canvas.drawLine(
    //   groundOriginPoint,
    //   _getAngledOffset(groundOriginPoint, widthMidPoint, (180 + viewAngle)),
    //   groundPainter,
    // );
    List<Offset> points = getPointsForPolygon(
      groundOriginPoint,
      widthMidPoint,
      viewAngle,
    );

    final planePath = Path();
    if (points.isNotEmpty) {
      planePath.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        planePath.lineTo(points[i].dx, points[i].dy);
      }
      planePath.close();
    }

    final planePainter = Paint()
      ..shader = ui.Gradient.linear(points[3], points[1], [
        Color(0xFFE5D5FF),
        Color(0xFFBDCBFD),
      ])
      ..style = .fill;
    canvas.drawPath(planePath, planePainter);

    // canvas.drawRRect(RRect.fromRectAndCorners(Rect.fromPoints(a, b)), paint)
    // final rectPainter = Paint();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

double _degToRadian(double degree) {
  return degree * math.pi / 180;
}

Offset _getAngledOffset(Offset origin, double oppositeLength, double angle) {
  final radiansAngle = _degToRadian(angle);
  final distance = (oppositeLength / math.cos(radiansAngle)).abs();
  return Offset(
    origin.dx + distance * math.cos(radiansAngle),
    origin.dy - distance * math.sin(radiansAngle),
  );
}

List<Offset> getPointsForPolygon(
  Offset origin,
  double xProjectionLength,
  double angleOfPoint1And2,
) {
  return [
    origin,
    _getAngledOffset(origin, xProjectionLength, angleOfPoint1And2),
    origin -
        Offset(
          0,
          2 * math.tan(_degToRadian(angleOfPoint1And2)) * xProjectionLength,
        ),
    _getAngledOffset(origin, xProjectionLength, 180 - angleOfPoint1And2),
    origin,
  ];
}
