import 'package:flutter/material.dart';

class Resizable extends StatefulWidget {
  final double initialHeight;
  final double initialWidth;
  final double containerHeight;
  final double containerWidth;

  const Resizable(
      {required this.child,
      required this.initialHeight,
      required this.initialWidth,
      required this.containerHeight,
      required this.containerWidth,
      Key? key})
      : super(key: key);

  final Widget child;
  @override
  _ResizableState createState() => _ResizableState();
}

class _ResizableState extends State<Resizable> {
  static const minSize = ControlPoint.diameter * 3;

  late double height;
  late double width;

  double top = 0;
  double left = 0;

  @override
  initState() {
    super.initState();
    height = widget.initialHeight;
    width = widget.initialWidth;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Positioned(
          top: top,
          left: left,
          child: Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              color: Colors.blueGrey,
              border: Border.all(
                width: 2,
                color: Colors.white70,
              ),
              borderRadius: BorderRadius.circular(0.0),
            ),
            child: FittedBox(child: widget.child, fit: BoxFit.fill),
          ),
        ),
        // top left
        Positioned(
          top: top - ControlPoint.offset,
          left: left - ControlPoint.offset,
          child: ControlPoint(
            onDrag: (dx, dy) {
              double offset = dx + dy;
              double newHeight = height - offset;
              double newWidth = width - offset;
              if (newHeight <= minSize || newWidth <= minSize) return;
              final mid = offset / 2;

              setState(() {
                height = newHeight;
                width = newWidth;
                top = top + mid;
                left = left + mid;
              });
            },
            handlerWidget: HandlerWidget.DIAGONAL,
          ),
        ),
        // top middle
        Positioned(
          top: top - ControlPoint.offset,
          left: left + width / 2 - ControlPoint.offset,
          child: ControlPoint(
            onDrag: (dx, dy) {
              double newHeight = height - dy;
              if (newHeight <= minSize) return;

              setState(() {
                height = newHeight;
                top = top + dy;
              });
            },
            handlerWidget: HandlerWidget.AXIS,
          ),
        ),
        // top right
        Positioned(
          top: top - ControlPoint.offset,
          left: left + width - ControlPoint.offset,
          child: ControlPoint(
            onDrag: (dx, dy) {
              double offset = dx + -dy;
              double newHeight = height + offset;
              double newWidth = width + offset;
              if (newHeight <= minSize || newWidth <= minSize) return;
              final mid = offset / 2;

              setState(() {
                height = newHeight;
                width = newWidth;
                top = top - mid;
                left = left - mid;
              });
            },
            handlerWidget: HandlerWidget.DIAGONAL,
          ),
        ),
        // center right
        Positioned(
          top: top + height / 2 - ControlPoint.offset,
          left: left + width - ControlPoint.offset,
          child: ControlPoint(
            onDrag: (dx, dy) {
              double newWidth = width + dx;
              if (newWidth <= minSize) return;

              setState(() {
                width = newWidth;
              });
            },
            handlerWidget: HandlerWidget.AXIS,
          ),
        ),
        // bottom right
        Positioned(
          top: top + height - ControlPoint.offset,
          left: left + width - ControlPoint.offset,
          child: ControlPoint(
            onDrag: (dx, dy) {
              double offset = dx + dy;
              double newHeight = height + offset;
              double newWidth = width + offset;
              if (newHeight <= minSize || newWidth <= minSize) return;
              final mid = offset / 2;

              setState(() {
                height = newHeight;
                width = newWidth;
                top = top - mid;
                left = left - mid;
              });
            },
            handlerWidget: HandlerWidget.DIAGONAL,
          ),
        ),
        // bottom center
        Positioned(
          top: top + height - ControlPoint.offset,
          left: left + width / 2 - ControlPoint.offset,
          child: ControlPoint(
            onDrag: (dx, dy) {
              double newHeight = height + dy;
              if (newHeight <= minSize) {
                newHeight = height;
                dy = 0;
              }

              setState(() {
                height = newHeight;
              });
            },
            handlerWidget: HandlerWidget.AXIS,
          ),
        ),
        // bottom left
        Positioned(
          top: top + height - ControlPoint.offset,
          left: left - ControlPoint.offset,
          child: ControlPoint(
            onDrag: (dx, dy) {
              double offset = -dx + dy;
              double newHeight = height + offset;
              double newWidth = width + offset;
              if (newHeight <= minSize || newWidth <= minSize) return;
              final mid = offset / 2;

              setState(() {
                height = newHeight;
                width = newWidth;
                top = top - mid;
                left = left - mid;
              });
            },
            handlerWidget: HandlerWidget.DIAGONAL,
          ),
        ),
        // left center
        Positioned(
          top: top + height / 2 - ControlPoint.offset,
          left: left - ControlPoint.offset,
          child: ControlPoint(
            onDrag: (dx, dy) {
              double newWidth = width - dx;
              if (newWidth <= minSize) return;

              setState(() {
                width = newWidth;
                left = left + dx;
              });
            },
            handlerWidget: HandlerWidget.AXIS,
          ),
        ),
        // center center
        Positioned(
          top: top + height / 2 - ControlPoint.offset,
          left: left + width / 2 - ControlPoint.offset,
          child: ControlPoint(
            onDrag: (dx, dy) {
              setState(() {
                top = top + dy;
                left = left + dx;
              });
            },
            handlerWidget: HandlerWidget.FREE,
          ),
        ),
      ],
    );
  }
}

typedef ControlPointDragCallback = void Function(double dx, double dy);

class ControlPoint extends StatefulWidget {
  static const diameter = 15.0;
  static const padding = 20.0;
  static double get offset => diameter / 2 + padding;

  final ControlPointDragCallback onDrag;
  final HandlerWidget handlerWidget;

  const ControlPoint(
      {required this.onDrag, required this.handlerWidget, Key? key})
      : super(key: key);

  @override
  _ControlPointState createState() => _ControlPointState();
}

// ignore: constant_identifier_names
enum HandlerWidget { FREE, AXIS, DIAGONAL }

class _ControlPointState extends State<ControlPoint> {
  late double initX;
  late double initY;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        setState(() {
          initX = details.localPosition.dx;
          initY = details.localPosition.dy;
        });
      },
      onPanUpdate: (details) {
        final double dx = details.localPosition.dx - initX;
        final double dy = details.localPosition.dy - initY;
        initX = details.localPosition.dx;
        initY = details.localPosition.dy;
        widget.onDrag(dx, dy);
      },
      behavior: HitTestBehavior.translucent,
      child: Padding(
        padding: const EdgeInsets.all(ControlPoint.padding),
        child: Container(
          width: ControlPoint.diameter,
          height: ControlPoint.diameter,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                spreadRadius: 2,
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
            shape: widget.handlerWidget == HandlerWidget.AXIS
                ? BoxShape.rectangle
                : BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
