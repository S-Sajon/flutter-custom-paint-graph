import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'dart:math' as math;

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
            child: const CustomPaint(
              painter: PaintBarGraph(),
              size: Size(200, 200),
            ),
          ),
        ),
      ),
    );
  }
}

class PaintBarGraph extends CustomPainter {
  const PaintBarGraph();
  @override
  void paint(Canvas canvas, Size size) {
    final widthMidPoint = size.width / 2;
    final heightMidPoint = size.height / 2;
    final backGroundPaint = Paint();
    const double strokeWidth = 2;
    backGroundPaint
      ..color = .fromRGBO(0, 0, 0, 0.05)
      ..strokeWidth = strokeWidth
      ..style = .stroke;
    for (var y in List.generate(
      5,
      (idx) =>
          ((size.height - 5 * strokeWidth) / 4) * idx +
          strokeWidth / 2 +
          strokeWidth * idx,
    )) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), backGroundPaint);
    }

    final groundPainter = Paint();

    canvas.drawLine(
      Offset(widthMidPoint, size.height),
      Offset(size.width, _getAdjacentForOpposite(45, widthMidPoint)),
      groundPainter,
    );
    canvas.drawLine(
      Offset(widthMidPoint, size.height),
      Offset(size.width, _getAdjacentForOpposite(135, widthMidPoint)),
      groundPainter,
    );
    // final rectPainter = Paint();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

double _degToRadian(double degree) {
  return degree * math.pi / 180;
}

double _getAdjacentForOpposite(double angle, double oppositeLength) {
  return oppositeLength * math.tan(_degToRadian(angle));
}
