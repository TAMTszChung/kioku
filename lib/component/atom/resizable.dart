import 'package:flutter/material.dart';

typedef ResizeReleaseCallback = void Function(Rect bound);

class Resizable extends StatefulWidget {
  final double initialTop;
  final double initialLeft;
  final double initialHeight;
  final double initialWidth;
  final ResizeReleaseCallback? onRelease;
  final bool isText;

  const Resizable(
      {required this.child,
      this.initialTop = 0,
      this.initialLeft = 0,
      required this.initialHeight,
      required this.initialWidth,
      this.onRelease,
      this.isText = false,
      Key? key})
      : super(key: key);

  final Widget child;
  @override
  _ResizableState createState() => _ResizableState();
}

class _ResizableState extends State<Resizable> {
  static const minSize = ControlPoint.diameter * 2;

  late double height;
  late double width;

  late double top;
  late double left;

  late double initX;
  late double initY;

  @override
  initState() {
    super.initState();
    top = widget.initialTop;
    left = widget.initialLeft;
    initX = left;
    initY = top;
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
          child: SizedBox(
            height: height,
            width: width,
            child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: (details) {
                  setState(() {
                    initX = details.localPosition.dx;
                    initY = details.localPosition.dy;
                  });
                },
                onPanUpdate: (details) {
                  final double dx = details.localPosition.dx - initX;
                  final double dy = details.localPosition.dy - initY;
                  setState(() {
                    initX = details.localPosition.dx;
                    initY = details.localPosition.dy;
                    top = top + dy;
                    left = left + dx;
                  });
                },
                onPanEnd: (details) {
                  widget.onRelease
                      ?.call(Rect.fromLTWH(left, top, width, height));
                },
                child: widget.isText
                    ? widget.child
                    : FittedBox(child: widget.child, fit: BoxFit.fill)),
          ),
        ),
        // top left
        Positioned(
          top: top - (ControlPoint.diameter + ControlPoint.offset),
          left: left - (ControlPoint.diameter + ControlPoint.offset),
          child: ControlPoint(
            onDrag: (dx, dy) {
              double offset = dx + dy;
              double newHeight = height - offset;
              double newWidth = width - offset;
              if (newHeight <= minSize || newWidth <= minSize) return;
              final mid = dx + dy / 2;

              setState(() {
                height = newHeight;
                width = newWidth;
                top = top + mid;
                left = left + mid;
              });
            },
            onDragEnd: (details) {
              widget.onRelease?.call(Rect.fromLTWH(left, top, width, height));
            },
            handlerWidget: HandlerWidget.DIAGONAL,
            padding: const EdgeInsets.only(
                top: ControlPoint.offset, left: ControlPoint.offset),
          ),
        ),
        // top center
        Positioned(
          top: top - (ControlPoint.diameter + ControlPoint.offset),
          left:
              left + (width - ControlPoint.diameter - ControlPoint.offset) / 2,
          child: ControlPoint(
            onDrag: (dx, dy) {
              double newHeight = height - dy;
              if (newHeight <= minSize) return;

              setState(() {
                height = newHeight;
                top = top + dy;
              });
            },
            onDragEnd: (details) {
              widget.onRelease?.call(Rect.fromLTWH(left, top, width, height));
            },
            handlerWidget: HandlerWidget.AXIS,
            padding: const EdgeInsets.only(
                top: ControlPoint.offset,
                left: ControlPoint.offset / 2,
                right: ControlPoint.offset / 2),
          ),
        ),
        // top right
        Positioned(
          top: top - (ControlPoint.diameter + ControlPoint.offset),
          left: left + width,
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
            onDragEnd: (details) {
              widget.onRelease?.call(Rect.fromLTWH(left, top, width, height));
            },
            handlerWidget: HandlerWidget.DIAGONAL,
            padding: const EdgeInsets.only(
                top: ControlPoint.offset, right: ControlPoint.offset),
          ),
        ),
        // center right
        Positioned(
          top: top + (height - ControlPoint.diameter - ControlPoint.offset) / 2,
          left: left + width,
          child: ControlPoint(
            onDrag: (dx, dy) {
              double newWidth = width + dx;
              if (newWidth <= minSize) return;

              setState(() {
                width = newWidth;
              });
            },
            onDragEnd: (details) {
              widget.onRelease?.call(Rect.fromLTWH(left, top, width, height));
            },
            handlerWidget: HandlerWidget.AXIS,
            padding: const EdgeInsets.only(
                right: ControlPoint.offset,
                top: ControlPoint.offset / 2,
                bottom: ControlPoint.offset / 2),
          ),
        ),
        // bottom right
        Positioned(
          top: top + height,
          left: left + width,
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
            onDragEnd: (details) {
              widget.onRelease?.call(Rect.fromLTWH(left, top, width, height));
            },
            handlerWidget: HandlerWidget.DIAGONAL,
            padding: const EdgeInsets.only(
                bottom: ControlPoint.offset, right: ControlPoint.offset),
          ),
        ),
        // bottom center
        Positioned(
          top: top + height,
          left:
              left + (width - ControlPoint.diameter - ControlPoint.offset) / 2,
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
            onDragEnd: (details) {
              widget.onRelease?.call(Rect.fromLTWH(left, top, width, height));
            },
            handlerWidget: HandlerWidget.AXIS,
            padding: const EdgeInsets.only(
                bottom: ControlPoint.offset,
                left: ControlPoint.offset / 2,
                right: ControlPoint.offset / 2),
          ),
        ),
        // bottom left
        Positioned(
          top: top + height,
          left: left - (ControlPoint.diameter + ControlPoint.offset),
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
            onDragEnd: (details) {
              widget.onRelease?.call(Rect.fromLTWH(left, top, width, height));
            },
            handlerWidget: HandlerWidget.DIAGONAL,
            padding: const EdgeInsets.only(
                bottom: ControlPoint.offset, left: ControlPoint.offset),
          ),
        ),
        // left center
        Positioned(
          top: top + (height - ControlPoint.diameter - ControlPoint.offset) / 2,
          left: left - ControlPoint.diameter - ControlPoint.offset,
          child: ControlPoint(
            onDrag: (dx, dy) {
              double newWidth = width - dx;
              if (newWidth <= minSize) return;

              setState(() {
                width = newWidth;
                left = left + dx;
              });
            },
            onDragEnd: (details) {
              widget.onRelease?.call(Rect.fromLTWH(left, top, width, height));
            },
            handlerWidget: HandlerWidget.AXIS,
            padding: const EdgeInsets.only(
                left: ControlPoint.offset,
                top: ControlPoint.offset / 2,
                bottom: ControlPoint.offset / 2),
          ),
        ),
      ],
    );
  }
}

typedef ControlPointDragCallback = void Function(double dx, double dy);

class ControlPoint extends StatefulWidget {
  static const diameter = 15.0;
  static const offset = 20.0;

  final ControlPointDragCallback onDrag;
  final GestureDragEndCallback? onDragEnd;
  final HandlerWidget handlerWidget;
  final EdgeInsetsGeometry padding;

  const ControlPoint(
      {required this.onDrag,
      this.onDragEnd,
      required this.handlerWidget,
      this.padding = EdgeInsetsDirectional.zero,
      Key? key})
      : super(key: key);

  @override
  _ControlPointState createState() => _ControlPointState();
}

// ignore: constant_identifier_names
enum HandlerWidget { AXIS, DIAGONAL }

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
      onPanEnd: widget.onDragEnd,
      behavior: HitTestBehavior.translucent,
      child: Padding(
        padding: widget.padding,
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
