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
    // Origin is now at the BOTTOM of the bar (not the top plane)
    const barHeight = 80.0;
    final barBottomOrigin = Offset(widthMidPoint, size.height);
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
      origin: barBottomOrigin,
      xProjectionLength: widthMidPoint,
      angleOfPoint1And2: viewAngle,
      arcPercentage: arcPercentage,
      height: barHeight,
    );

    final leftSidePathPoints = getPointsForLeftSidePolygon(
      origin: barBottomOrigin,
      xProjectionLength: widthMidPoint,
      angleOfPoint1And2: viewAngle,
      height: barHeight,
      arcPercentage: arcPercentage,
    );
    final rightSidePathPoints = getPointsForRightSidePolygon(
      origin: barBottomOrigin,
      xProjectionLength: widthMidPoint,
      angleOfPoint1And2: viewAngle,
      height: barHeight,
      arcPercentage: arcPercentage,
    );
    final frontFacePathPoints = getPointsForFrontFacePolygon(
      origin: barBottomOrigin,
      xProjectionLength: widthMidPoint,
      angleOfPoint1And2: viewAngle,
      height: barHeight,
      arcPercentage: arcPercentage,
    );
    final leftOuterCornerPoints = getPointsForLeftOuterCorner(
      origin: barBottomOrigin,
      xProjectionLength: widthMidPoint,
      angleOfPoint1And2: viewAngle,
      height: barHeight,
      arcPercentage: arcPercentage,
    );
    final rightOuterCornerPoints = getPointsForRightOuterCorner(
      origin: barBottomOrigin,
      xProjectionLength: widthMidPoint,
      angleOfPoint1And2: viewAngle,
      height: barHeight,
      arcPercentage: arcPercentage,
    );

    final topPlanePath = _getPathForPoints(topSidePathPoints);
    final leftSidePath = _getPathForPoints(leftSidePathPoints);
    final rightSidePath = _getPathForPoints(rightSidePathPoints);
    final frontFacePath = _getPathForPoints(frontFacePathPoints);
    final leftOuterCornerPath = _getPathForPoints(leftOuterCornerPoints);
    final rightOuterCornerPath = _getPathForPoints(rightOuterCornerPoints);

    final planePainter = Paint()
      ..shader = ui.Gradient.linear(
        topSidePathPoints[0].$1,
        topSidePathPoints[3].$1,
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
      rightSidePathPoints[0].$1,
      rightSidePathPoints[1].$1,
      [Color(0xFF5844D7), Color(0xFF6580E1)],
    );
    canvas.drawPath(rightSidePath, planePainter);

    planePainter.shader = ui.Gradient.linear(
      frontFacePathPoints[3].$1,
      frontFacePathPoints[0].$1,
      [Color(0xFF5844D7), Color(0xFF6580E1)],
    );
    canvas.drawPath(frontFacePath, planePainter);

    planePainter.shader = ui.Gradient.linear(
      leftOuterCornerPoints[1].$1,
      leftOuterCornerPoints[0].$1,
      [Color(0xFF93E3FC), Color(0xFF93AAFC)],
    );
    canvas.drawPath(leftOuterCornerPath, planePainter);

    planePainter.shader = ui.Gradient.linear(
      rightOuterCornerPoints[0].$1,
      rightOuterCornerPoints[1].$1,
      [Color(0xFF5844D7), Color(0xFF6580E1)],
    );
    canvas.drawPath(rightOuterCornerPath, planePainter);

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

/// Calculate the midpoint of a quadratic bezier curve at t=0.5
/// Returns (midpoint, controlForFirstHalf, controlForSecondHalf)
({Offset midpoint, Offset controlFirst, Offset controlSecond})
_splitQuadraticBezier(Offset start, Offset control, Offset end) {
  // Midpoint at t=0.5: P = 0.25*start + 0.5*control + 0.25*end
  final midpoint = Offset(
    0.25 * start.dx + 0.5 * control.dx + 0.25 * end.dx,
    0.25 * start.dy + 0.5 * control.dy + 0.25 * end.dy,
  );
  // Control point for first half (start to midpoint)
  final controlFirst = Offset(
    (start.dx + control.dx) / 2,
    (start.dy + control.dy) / 2,
  );
  // Control point for second half (midpoint to end)
  final controlSecond = Offset(
    (control.dx + end.dx) / 2,
    (control.dy + end.dy) / 2,
  );
  return (
    midpoint: midpoint,
    controlFirst: controlFirst,
    controlSecond: controlSecond,
  );
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
  required double height,
}) {
  // Origin is now at bottom of bar, so top plane origin is origin - height
  final topPlaneOrigin = origin - Offset(0, height);

  final arcDiameter = xProjectionLength * (arcPercentage / 100);
  final radianAngle = _degToRadian(angleOfPoint1And2);

  // Original sharp corners (used as control points for rounded arcs)
  final rightCorner = _getAngledOffset(
    topPlaneOrigin,
    xProjectionLength,
    angleOfPoint1And2,
  );
  final leftCorner = _getAngledOffset(
    topPlaneOrigin,
    xProjectionLength,
    180 - angleOfPoint1And2,
  );
  final topCorner = Offset(
    topPlaneOrigin.dx,
    topPlaneOrigin.dy - 2 * math.tan(radianAngle) * xProjectionLength,
  );
  final bottomCorner = topPlaneOrigin;

  // Points shifted inward from corners for the rounded shape
  final shiftedOrigin = _getAngledOffset(
    topPlaneOrigin,
    arcDiameter,
    angleOfPoint1And2,
  );
  final secondPoint = _getAngledOffset(
    topPlaneOrigin,
    xProjectionLength - arcDiameter,
    angleOfPoint1And2,
  );
  final thirdPoint =
      secondPoint - Offset(0, 2 * math.tan(radianAngle) * arcDiameter);
  final fourthPoint =
      shiftedOrigin -
      Offset(0, 2 * math.tan(radianAngle) * (xProjectionLength - arcDiameter));
  final eigthPoint = _getAngledOffset(
    topPlaneOrigin,
    arcDiameter,
    180 - angleOfPoint1And2,
  );
  final seventhPoint = _getAngledOffset(
    topPlaneOrigin,
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
  // Origin is now at bottom of bar, top plane origin is origin - height
  final topPlaneOrigin = origin - Offset(0, height);
  final arcDiameter = xProjectionLength * (arcPercentage / 100);

  // Top edge points (at top plane level)
  final topInner = _getAngledOffset(
    topPlaneOrigin,
    arcDiameter,
    180 - angleOfPoint1And2,
  );
  final topOuter = _getAngledOffset(
    topPlaneOrigin,
    xProjectionLength - arcDiameter,
    180 - angleOfPoint1And2,
  );
  // Bottom edge points (at origin level)
  final bottomOuter = topOuter + Offset(0, height);
  final bottomInner = topInner + Offset(0, height);
  return [
    (topInner, .line, null),
    (topOuter, .line, null),
    (bottomOuter, .line, null),
    (bottomInner, .line, null),
  ];
}

List<(Offset, _PathType, Offset?)> getPointsForRightSidePolygon({
  required Offset origin,
  required double xProjectionLength,
  required double angleOfPoint1And2,
  required double height,
  required double arcPercentage,
}) {
  // Origin is now at bottom of bar, top plane origin is origin - height
  final topPlaneOrigin = origin - Offset(0, height);
  final arcDiameter = xProjectionLength * (arcPercentage / 100);

  // Top edge points (at top plane level)
  final topInner = _getAngledOffset(
    topPlaneOrigin,
    arcDiameter,
    angleOfPoint1And2,
  );
  final topOuter = _getAngledOffset(
    topPlaneOrigin,
    xProjectionLength - arcDiameter,
    angleOfPoint1And2,
  );
  // Bottom edge points (at origin level)
  final bottomOuter = topOuter + Offset(0, height);
  final bottomInner = topInner + Offset(0, height);
  return [
    (topInner, .line, null),
    (topOuter, .line, null),
    (bottomOuter, .line, null),
    (bottomInner, .line, null),
  ];
}

/// Front face that connects the inner edges of left and right side faces
List<(Offset, _PathType, Offset?)> getPointsForFrontFacePolygon({
  required Offset origin,
  required double xProjectionLength,
  required double angleOfPoint1And2,
  required double height,
  required double arcPercentage,
}) {
  // Origin is now at bottom of bar, top plane origin is origin - height
  final topPlaneOrigin = origin - Offset(0, height);
  final arcDiameter = xProjectionLength * (arcPercentage / 100);

  // Top corners (at top plane level)
  final topRight = _getAngledOffset(
    topPlaneOrigin,
    arcDiameter,
    angleOfPoint1And2,
  );
  final topLeft = _getAngledOffset(
    topPlaneOrigin,
    arcDiameter,
    180 - angleOfPoint1And2,
  );

  // Bottom corners (at origin level)
  final bottomRight = topRight + Offset(0, height);
  final bottomLeft = topLeft + Offset(0, height);

  // Control points for arcs
  final topCorner = topPlaneOrigin; // Top arc control point
  final bottomCorner = origin; // Bottom arc control point

  return [
    (topRight, .line, null),
    (bottomRight, .line, null),
    (bottomLeft, .arc, bottomCorner), // Arc around bottom corner
    (topLeft, .line, null),
    (
      topRight,
      .arc,
      topCorner,
    ), // Arc around top corner (matches top plane's bottom arc)
  ];
}

/// Left outer corner - extends the left corner arc down (inner half only)
List<(Offset, _PathType, Offset?)> getPointsForLeftOuterCorner({
  required Offset origin,
  required double xProjectionLength,
  required double angleOfPoint1And2,
  required double height,
  required double arcPercentage,
}) {
  // Origin is now at bottom of bar, top plane origin is origin - height
  final topPlaneOrigin = origin - Offset(0, height);
  final arcDiameter = xProjectionLength * (arcPercentage / 100);
  final radianAngle = _degToRadian(angleOfPoint1And2);

  // Left corner (control point for arcs) - at top plane level
  final leftCorner = _getAngledOffset(
    topPlaneOrigin,
    xProjectionLength,
    180 - angleOfPoint1And2,
  );

  // Top arc points (at top plane level)
  final seventhPoint = _getAngledOffset(
    topPlaneOrigin,
    xProjectionLength - arcDiameter,
    180 - angleOfPoint1And2,
  );
  final sixthPoint =
      seventhPoint - Offset(0, 2 * math.tan(radianAngle) * arcDiameter);

  // Split the top arc
  final topArcSplit = _splitQuadraticBezier(
    seventhPoint,
    leftCorner,
    sixthPoint,
  );

  // Bottom arc points (at origin level)
  final bottomCorner = leftCorner + Offset(0, height);
  final bottomMidpoint = topArcSplit.midpoint + Offset(0, height);
  final bottomInner = seventhPoint + Offset(0, height);

  // Split the bottom arc
  final bottomArcSplit = _splitQuadraticBezier(
    bottomInner,
    bottomCorner,
    sixthPoint + Offset(0, height),
  );

  return [
    (seventhPoint, .line, null), // Start at inner edge of top arc
    (
      topArcSplit.midpoint,
      .arc,
      topArcSplit.controlFirst,
    ), // Inner half of top arc (to midpoint)
    (bottomMidpoint, .line, null), // Line down
    (
      bottomInner,
      .arc,
      bottomArcSplit.controlFirst,
    ), // Inner half of bottom arc
    // path.close() handles closing
  ];
}

/// Right outer corner - extends the right corner arc down (inner half only)
List<(Offset, _PathType, Offset?)> getPointsForRightOuterCorner({
  required Offset origin,
  required double xProjectionLength,
  required double angleOfPoint1And2,
  required double height,
  required double arcPercentage,
}) {
  // Origin is now at bottom of bar, top plane origin is origin - height
  final topPlaneOrigin = origin - Offset(0, height);
  final arcDiameter = xProjectionLength * (arcPercentage / 100);
  final radianAngle = _degToRadian(angleOfPoint1And2);

  // Right corner (control point for arcs) - at top plane level
  final rightCorner = _getAngledOffset(
    topPlaneOrigin,
    xProjectionLength,
    angleOfPoint1And2,
  );

  // Top arc points (at top plane level)
  final secondPoint = _getAngledOffset(
    topPlaneOrigin,
    xProjectionLength - arcDiameter,
    angleOfPoint1And2,
  );
  final thirdPoint =
      secondPoint - Offset(0, 2 * math.tan(radianAngle) * arcDiameter);

  // Split the top arc
  final topArcSplit = _splitQuadraticBezier(
    secondPoint,
    rightCorner,
    thirdPoint,
  );

  // Bottom arc points (at origin level)
  final bottomCorner = rightCorner + Offset(0, height);
  final bottomMidpoint = topArcSplit.midpoint + Offset(0, height);
  final bottomInner = secondPoint + Offset(0, height);

  // Split the bottom arc
  final bottomArcSplit = _splitQuadraticBezier(
    bottomInner,
    bottomCorner,
    thirdPoint + Offset(0, height),
  );

  return [
    (secondPoint, .line, null), // Start at inner edge of top arc
    (
      topArcSplit.midpoint,
      .arc,
      topArcSplit.controlFirst,
    ), // Inner half of top arc (to midpoint)
    (bottomMidpoint, .line, null), // Line down
    (
      bottomInner,
      .arc,
      bottomArcSplit.controlFirst,
    ), // Inner half of bottom arc
    // path.close() handles closing
  ];
}
