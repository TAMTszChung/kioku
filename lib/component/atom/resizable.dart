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

            // need tp check if draggable is done from corner or sides
            child: FittedBox(child: widget.child, fit: BoxFit.fill),
          ),
        ),
        // top left
        Positioned(
          top: top - ControlPoint.offset,
          left: left - ControlPoint.offset,
          child: ControlPoint(
            onDrag: (dx, dy) {
              var mid = (dx + dy) / 2;
              var newHeight = height - 2 * mid;
              var newWidth = width - 2 * mid;

              setState(() {
                height = newHeight > 0 ? newHeight : 0;
                width = newWidth > 0 ? newWidth : 0;
                top = top + mid;
                left = left + mid;
              });
            },
            handlerWidget: HandlerWidget.VERTICAL,
          ),
        ),
        // top middle
        Positioned(
          top: top - ControlPoint.offset,
          left: left + width / 2 - ControlPoint.offset,
          child: ControlPoint(
            onDrag: (dx, dy) {
              var newHeight = height - dy;

              setState(() {
                height = newHeight > 0 ? newHeight : 0;
                top = top + dy;
              });
            },
            handlerWidget: HandlerWidget.HORIZONTAL,
          ),
        ),
        // top right
        Positioned(
          top: top - ControlPoint.offset,
          left: left + width - ControlPoint.offset,
          child: ControlPoint(
            onDrag: (dx, dy) {
              var mid = (dx + (dy * -1)) / 2;

              var newHeight = height + 2 * mid;
              var newWidth = width + 2 * mid;

              setState(() {
                height = newHeight > 0 ? newHeight : 0;
                width = newWidth > 0 ? newWidth : 0;
                top = top - mid;
                left = left - mid;
              });
            },
            handlerWidget: HandlerWidget.VERTICAL,
          ),
        ),
        // center right
        Positioned(
          top: top + height / 2 - ControlPoint.offset,
          left: left + width - ControlPoint.offset,
          child: ControlPoint(
            onDrag: (dx, dy) {
              var newWidth = width + dx;

              setState(() {
                width = newWidth > 0 ? newWidth : 0;
              });
            },
            handlerWidget: HandlerWidget.HORIZONTAL,
          ),
        ),
        // bottom right
        Positioned(
          top: top + height - ControlPoint.offset,
          left: left + width - ControlPoint.offset,
          child: ControlPoint(
            onDrag: (dx, dy) {
              var mid = (dx + dy) / 2;

              var newHeight = height + 2 * mid;
              var newWidth = width + 2 * mid;

              setState(() {
                height = newHeight > 0 ? newHeight : 0;
                width = newWidth > 0 ? newWidth : 0;
                top = top - mid;
                left = left - mid;
              });
            },
            handlerWidget: HandlerWidget.VERTICAL,
          ),
        ),
        // bottom center
        Positioned(
          top: top + height - ControlPoint.offset,
          left: left + width / 2 - ControlPoint.offset,
          child: ControlPoint(
            onDrag: (dx, dy) {
              var newHeight = height + dy;

              setState(() {
                height = newHeight > 0 ? newHeight : 0;
              });
            },
            handlerWidget: HandlerWidget.HORIZONTAL,
          ),
        ),
        // bottom left
        Positioned(
          top: top + height - ControlPoint.offset,
          left: left - ControlPoint.offset,
          child: ControlPoint(
            onDrag: (dx, dy) {
              var mid = ((dx * -1) + dy) / 2;

              var newHeight = height + 2 * mid;
              var newWidth = width + 2 * mid;

              setState(() {
                height = newHeight > 0 ? newHeight : 0;
                width = newWidth > 0 ? newWidth : 0;
                top = top - mid;
                left = left - mid;
              });
            },
            handlerWidget: HandlerWidget.VERTICAL,
          ),
        ),
        //left center
        Positioned(
          top: top + height / 2 - ControlPoint.offset,
          left: left - ControlPoint.offset,
          child: ControlPoint(
            onDrag: (dx, dy) {
              var newWidth = width - dx;

              setState(() {
                width = newWidth > 0 ? newWidth : 0;
                left = left + dx;
              });
            },
            handlerWidget: HandlerWidget.HORIZONTAL,
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
            handlerWidget: HandlerWidget.VERTICAL,
          ),
        ),
      ],
    );
  }
}

class ControlPoint extends StatefulWidget {
  static const diameter = 15.0;
  static const padding = 20.0;

  static double get offset => diameter / 2 + padding;

  const ControlPoint(
      {required this.onDrag, required this.handlerWidget, Key? key})
      : super(key: key);

  final Function onDrag;
  final HandlerWidget handlerWidget;

  @override
  _ControlPointState createState() => _ControlPointState();
}

// ignore: constant_identifier_names
enum HandlerWidget { HORIZONTAL, VERTICAL }

class _ControlPointState extends State<ControlPoint> {
  late double initX;
  late double initY;

  _handleDrag(details) {
    setState(() {
      initX = details.globalPosition.dx;
      initY = details.globalPosition.dy;
    });
  }

  _handleUpdate(details) {
    var dx = details.globalPosition.dx - initX;
    var dy = details.globalPosition.dy - initY;
    initX = details.globalPosition.dx;
    initY = details.globalPosition.dy;
    widget.onDrag(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handleDrag,
      onPanUpdate: _handleUpdate,
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
            shape: widget.handlerWidget == HandlerWidget.VERTICAL
                ? BoxShape.circle
                : BoxShape.rectangle,
          ),
        ),
      ),
    );
  }
}
