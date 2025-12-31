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
            child: CustomPaint(
              painter: PaintBarGraph(income: 0, expense: 0),
              size: Size(200, 200),
            ),
          ),
        ),
      ),
    );
  }
}

class PaintBarGraph extends CustomPainter {
  PaintBarGraph({required this.income, required this.expense});

  double expense;
  double income;

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
    final topPlaneOriginPoint = Offset(widthMidPoint, size.height - 80);
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

    const arcPercentage = 10.0;
    final topSidePathPoints = getPointsForPlanePolygon(
      origin: topPlaneOriginPoint,
      xProjectionLength: widthMidPoint,
      angleOfPoint1And2: viewAngle,
      arcPercentage: arcPercentage,
    );

    final leftSidePathPoints = getPointsForLeftSidePolygon(
      origin: topPlaneOriginPoint,
      xProjectionLength: widthMidPoint,
      angleOfPoint1And2: viewAngle,
      height: 40,
      arcPercentage: arcPercentage,
    );
    final rightSidePathPoints = getPointsForRightSidePolygon(
      origin: topPlaneOriginPoint,
      xProjectionLength: widthMidPoint,
      angleOfPoint1And2: viewAngle,
      height: 40,
      arcPercentage: arcPercentage,
    );

    final topPlanePath = _getPathForPoints(topSidePathPoints);
    final leftSidePath = _getPathForPoints(leftSidePathPoints);
    final rightSidePath = _getPathForPoints(rightSidePathPoints);

    final planePainter = Paint()
      ..shader = ui.Gradient.linear(
        topSidePathPoints[3].$1,
        topSidePathPoints[1].$1,
        [Color(0xFFE5D5FF), Color(0xFFBDCBFD)],
      )
      ..style = .fill;
    canvas.drawPath(topPlanePath, planePainter);
    planePainter.shader = ui.Gradient.linear(
      leftSidePathPoints[1].$1,
      leftSidePathPoints[0].$1,
      [Color(0xFF93E3FC), Color(0xFF93AAFC)],
    );
    canvas.drawPath(leftSidePath, planePainter);
    planePainter.shader = ui.Gradient.linear(
      leftSidePathPoints[1].$1,
      leftSidePathPoints[0].$1,
      [Color(0xFF5844D7), Color(0xFF6580E1)],
    );
    canvas.drawPath(rightSidePath, planePainter);

    // canvas.drawRRect(RRect.fromRectAndCorners(Rect.fromPoints(a, b)), paint)
    // final rectPainter = Paint();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum _PathType { arc, line }

Path _getPathForPoints(List<(Offset, _PathType, Offset?)> points) {
  final path = Path();
  if (points.isNotEmpty) {
    final (firstPoint, _, _) = points.first; //Ignore the type for first point
    path.moveTo(firstPoint.dx, firstPoint.dy);
    for (int i = 1; i < points.length; i++) {
      final (point, type, controlPoint) = points[i];
      switch (type) {
        case _PathType.arc:
          if (controlPoint != null) {
            path.quadraticBezierTo(
              controlPoint.dx,
              controlPoint.dy,
              point.dx,
              point.dy,
            );
          } else {
            path.lineTo(point.dx, point.dy);
          }
          break;
        case _PathType.line:
          path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
  }
  return path;
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

List<(Offset, _PathType, Offset?)> getPointsForPlanePolygon({
  required Offset origin,
  required double xProjectionLength,
  required double angleOfPoint1And2,
  required double arcPercentage,
}) {
  final arcDiameter = xProjectionLength * (arcPercentage / 100);
  final radianAngle = _degToRadian(angleOfPoint1And2);

  // Original sharp corners (used as control points for rounded arcs)
  final rightCorner = _getAngledOffset(
    origin,
    xProjectionLength,
    angleOfPoint1And2,
  );
  final leftCorner = _getAngledOffset(
    origin,
    xProjectionLength,
    180 - angleOfPoint1And2,
  );
  final topCorner = Offset(
    origin.dx,
    origin.dy - 2 * math.tan(radianAngle) * xProjectionLength,
  );
  final bottomCorner = origin;

  // Points shifted inward from corners for the rounded shape
  final shiftedOrigin = _getAngledOffset(
    origin,
    arcDiameter,
    angleOfPoint1And2,
  );
  final secondPoint = _getAngledOffset(
    origin,
    xProjectionLength - arcDiameter,
    angleOfPoint1And2,
  );
  final thirdPoint =
      secondPoint - Offset(0, 2 * math.tan(radianAngle) * arcDiameter);
  final fourthPoint =
      shiftedOrigin -
      Offset(0, 2 * math.tan(radianAngle) * (xProjectionLength - arcDiameter));
  final eigthPoint = _getAngledOffset(
    origin,
    arcDiameter,
    180 - angleOfPoint1And2,
  );
  final seventhPoint = _getAngledOffset(
    origin,
    xProjectionLength - arcDiameter,
    180 - angleOfPoint1And2,
  );
  final fifthPoint =
      eigthPoint -
      Offset(0, 2 * math.tan(radianAngle) * (xProjectionLength - arcDiameter));
  final sixthPoint =
      seventhPoint - Offset(0, 2 * math.tan(radianAngle) * arcDiameter);
  return [
    (shiftedOrigin, .line, null),
    (secondPoint, .line, null),
    (thirdPoint, .arc, rightCorner), // Arc around right corner
    (fourthPoint, .line, null),
    (fifthPoint, .arc, topCorner), // Arc around top corner
    (sixthPoint, .line, null),
    (seventhPoint, .arc, leftCorner), // Arc around left corner
    (eigthPoint, .line, null),
    (shiftedOrigin, .arc, bottomCorner), // Arc around bottom corner
  ];
}

List<(Offset, _PathType, Offset?)> getPointsForLeftSidePolygon({
  required Offset origin,
  required double xProjectionLength,
  required double angleOfPoint1And2,
  required double height,
  required double arcPercentage,
}) {
  final arcDiameter = xProjectionLength * (arcPercentage / 100);

  final shiftedOrigin = _getAngledOffset(
    origin,
    arcDiameter,
    180 - angleOfPoint1And2,
  );
  final secondPoint = _getAngledOffset(
    origin,
    xProjectionLength - arcDiameter,
    180 - angleOfPoint1And2,
  );
  final thirdPoint = secondPoint + Offset(0, height);
  final fourthPoint = shiftedOrigin + Offset(0, height);
  return [
    (shiftedOrigin, .line, null),
    (secondPoint, .line, null),
    (thirdPoint, .line, null),
    (fourthPoint, .line, null),
    (shiftedOrigin, .line, null),
  ];
}

List<(Offset, _PathType, Offset?)> getPointsForRightSidePolygon({
  required Offset origin,
  required double xProjectionLength,
  required double angleOfPoint1And2,
  required double height,
  required double arcPercentage,
}) {
  final arcDiameter = xProjectionLength * (arcPercentage / 100);
  final shiftedOrigin = _getAngledOffset(
    origin,
    arcDiameter,
    angleOfPoint1And2,
  );
  final secondPoint = _getAngledOffset(
    origin,
    xProjectionLength - arcDiameter,
    angleOfPoint1And2,
  );
  final thirdPoint = secondPoint + Offset(0, height);
  final fourthPoint = shiftedOrigin + Offset(0, height);
  return [
    (shiftedOrigin, .line, null),
    (secondPoint, .line, null),
    (thirdPoint, .line, null),
    (fourthPoint, .line, null),
    (shiftedOrigin, .line, null),
  ];
}
