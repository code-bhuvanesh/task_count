import 'package:flutter/material.dart';

class GraphWidget extends StatefulWidget {
  final double topValue;
  final List<double> plots;
  final List<String> horizontalValues;
  final int barSize;
  final double spacing;
  final double barRadius;
  const GraphWidget({
    super.key,
    required this.topValue,
    required this.horizontalValues,
    required this.plots,
    this.barRadius = 15.0,
    this.barSize = 20,
    this.spacing = 20.0,
  });

  @override
  State<GraphWidget> createState() => _GraphWidgetState();
}

class _GraphWidgetState extends State<GraphWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 30.0),
      child: Stack(
        children: [
          CustomPaint(
            size: Size(
              MediaQuery.of(context).size.width,
              300.0,
            ),
            painter: GraphPainter(
              topValue: widget.topValue,
              horizontalValues: widget.horizontalValues,
              plots: widget.plots,
              barRadius: widget.barRadius,
              barSize: widget.barSize,
              spacing: widget.spacing,
            ),
          ),
        ],
      ),
    );
  }
}

class GraphPainter extends CustomPainter {
  final double topValue;
  final List<String> horizontalValues;
  final List<double> plots;
  var barSize = 20;
  var spacing = 20.0;
  var barRadius = 15.0;

  GraphPainter({
    super.repaint,
    required this.topValue,
    required this.horizontalValues,
    required this.plots,
    required this.barRadius,
    required this.barSize,
    required this.spacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var smallLine = Paint()
      ..color = Colors.green // Line color
      ..style = PaintingStyle.stroke // Stroke style
      ..strokeWidth = .3; // Stroke width

    var bigLine = Paint()
      ..color = Colors.green // Line color
      ..style = PaintingStyle.stroke // Stroke style
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5; // Stroke width

    // var bigLines = 4;
    // var smallLines = 2 + 1;

    var splittings = 5;
    // var pad = 30.0;

    for (int i = 0; i < splittings + 1; i++) {
      canvas.drawLine(
        Offset(0, size.height),
        Offset(size.width, size.height),
        bigLine,
      );
      canvas.drawLine(
        const Offset(0, 0),
        Offset(0, size.height),
        bigLine,
      );
      canvas.drawLine(
        Offset(0, size.height * (i / splittings)),
        Offset(size.width, size.height * (i / splittings)),
        smallLine,
      );
      canvas.drawLine(
        Offset(size.width * (i / splittings), 0),
        Offset(size.width * (i / splittings), size.height),
        smallLine,
      );

      const textStyle = TextStyle(
          color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold);
      var textSpan = TextSpan(
        text: ((topValue / (splittings)) * (splittings - i)).toInt().toString(),
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.start,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(
        minWidth: 0,
        maxWidth: size.width,
      );

      final offset = Offset(0 - 20.0, (size.height - 10) * (i / splittings));
      textPainter.paint(canvas, offset);
    }
    var count = 0;

    for (var i in plots) {
      var interval = size.width * (count / splittings) + spacing;
      var barHeight = size.height * (1 - (i / topValue).abs());

      canvas.drawDRRect(
        // RRect.fromRectXY(
        //   Rect.fromPoints(
        //     Offset(interval, size.height),
        //     Offset(interval + barSize, barHeight),
        //   ),
        //   barRadius,
        //   barRadius,
        // ),
        RRect.fromRectAndCorners(
          Rect.fromPoints(
            Offset(interval, size.height),
            Offset(interval + barSize, barHeight),
          ),
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
        ),
        RRect.fromRectXY(
          Rect.fromPoints(
            const Offset(0, 0),
            const Offset(0, 00),
          ),
          barRadius,
          barRadius,
        ),
        Paint()
          ..color = Colors.green // Line color
          ..style = PaintingStyle.fill // Stroke style
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 5,
      );

      const textStyle = TextStyle(
          color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold);
      var textSpan = TextSpan(
        text: horizontalValues[count],
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.start,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(
        minWidth: 0,
        maxWidth: size.width,
      );

      final offset = Offset(interval - 3, size.height + 5);
      textPainter.paint(canvas, offset);
      count++;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
