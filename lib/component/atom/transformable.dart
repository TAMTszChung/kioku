/*
# COMP 4521    #  PANG, Kit        20606678          kpangaa@connect.ust.hk
# COMP 4521    #  TAM, Tsz Chung        20606173          tctam@connect.ust.hk
*/

import 'dart:math' as math;

import 'package:flutter/material.dart';

const _cornerDiameter = 30.0;
const _floatingActionDiameter = 50.0;
const _floatingActionPadding = 100.0;
const _minSize = _cornerDiameter * 1.5;

typedef TransformCallback = void Function(
    Size size, Offset position, double rotation);

class Transformable extends StatefulWidget {
  final Widget child;
  final Size size;
  final Offset position;
  final double rotation;
  final bool isText;
  final TransformCallback? onTransform;

  const Transformable({
    Key? key,
    required this.child,
    required this.size,
    required this.position,
    required this.rotation,
    this.isText = false,
    this.onTransform,
  }) : super(key: key);

  @override
  _TransformableState createState() => _TransformableState();
}

class _TransformableState extends State<Transformable> {
  late Size size;
  late Offset position;
  late Offset initPoint;
  late double rotation;
  late double rotationDelta;
  late double baseRotation;

  @override
  void initState() {
    super.initState();
    size = widget.size;
    position = widget.position;
    initPoint = Offset.zero;
    rotation = widget.rotation;
    baseRotation = 0;
    rotationDelta = 0;
  }

  void setInitPoint() {
    initPoint = Offset(size.width, size.height);
  }

  @override
  Widget build(BuildContext context) {
    final aspectRatio = widget.size.width / widget.size.height;
    return LayoutBuilder(
      builder: (context, constraints) {
        final normalizedWidth = size.width;
        final normalizedHeight = normalizedWidth / aspectRatio;
        size = Size(normalizedWidth, normalizedHeight);

        final normalizedLeft =
            position.dx - (_floatingActionPadding / 2) - (_cornerDiameter / 2);
        final normalizedTop =
            position.dy - (_floatingActionPadding / 2) - (_cornerDiameter / 2);

        void onTransform() {
          final normalizedPosition = Offset(
            normalizedLeft +
                (_floatingActionPadding / 2) +
                (_cornerDiameter / 2),
            normalizedTop +
                (_floatingActionPadding / 2) +
                (_cornerDiameter / 2),
          );
          widget.onTransform?.call(size, normalizedPosition, rotation);
        }

        void onDragTopCenter(Offset details) {
          double newHeight = size.height - details.dy;
          if (newHeight < _minSize) return;

          final updatedSize = Size(size.width, newHeight);

          final nCos = math.cos(-rotation);
          final nSin = math.sin(-rotation);
          final resizedCenter = Offset(0, (newHeight - size.height) / 2);
          final rotatedCenter = Offset(
              nCos * (resizedCenter.dx) - nSin * (resizedCenter.dy),
              nSin * (resizedCenter.dx) + nCos * (resizedCenter.dy));
          final updatedPosition = Offset(
              position.dx + (rotatedCenter.dx - resizedCenter.dx),
              position.dy - (rotatedCenter.dy - resizedCenter.dy) + details.dy);

          setState(() {
            size = updatedSize;
            position = updatedPosition;
          });

          onTransform();
        }

        void onDragBottomCenter(Offset details) {
          double newHeight = size.height + details.dy;
          if (newHeight < _minSize) return;

          final updatedSize = Size(size.width, newHeight);

          final nCos = math.cos(-rotation);
          final nSin = math.sin(-rotation);
          final resizedCenter = Offset(0, (-newHeight + size.height) / 2);
          final rotatedCenter = Offset(
              nCos * (resizedCenter.dx) - nSin * (resizedCenter.dy),
              nSin * (resizedCenter.dx) + nCos * (resizedCenter.dy));
          final updatedPosition = Offset(
              position.dx + (rotatedCenter.dx - resizedCenter.dx),
              position.dy - (rotatedCenter.dy - resizedCenter.dy));

          setState(() {
            size = updatedSize;
            position = updatedPosition;
          });

          onTransform();
        }

        void onDragLeftCenter(Offset details) {
          double newWidth = size.width - details.dx;
          if (newWidth < _minSize) return;

          final updatedSize = Size(newWidth, size.height);

          final nCos = math.cos(-rotation);
          final nSin = math.sin(-rotation);
          final resizedCenter = Offset((-newWidth + size.width) / 2, 0);
          final rotatedCenter = Offset(
              nCos * (resizedCenter.dx) - nSin * (resizedCenter.dy),
              nSin * (resizedCenter.dx) + nCos * (resizedCenter.dy));
          final updatedPosition = Offset(
              position.dx + (rotatedCenter.dx - resizedCenter.dx) + details.dx,
              position.dy - (rotatedCenter.dy - resizedCenter.dy));

          setState(() {
            size = updatedSize;
            position = updatedPosition;
          });

          onTransform();
        }

        void onDragRightCenter(Offset details) {
          double newWidth = size.width + details.dx;
          if (newWidth < _minSize) return;

          final updatedSize = Size(newWidth, size.height);

          final nCos = math.cos(-rotation);
          final nSin = math.sin(-rotation);
          final resizedCenter = Offset((newWidth - size.width) / 2, 0);
          final rotatedCenter = Offset(
              nCos * (resizedCenter.dx) - nSin * (resizedCenter.dy),
              nSin * (resizedCenter.dx) + nCos * (resizedCenter.dy));
          final updatedPosition = Offset(
              position.dx + (rotatedCenter.dx - resizedCenter.dx),
              position.dy - (rotatedCenter.dy - resizedCenter.dy));

          setState(() {
            size = updatedSize;
            position = updatedPosition;
          });

          onTransform();
        }

        void onDragTopLeft(Offset details) {
          initPoint =
              Offset(initPoint.dx - details.dx, initPoint.dy - details.dy);
          double newWidth = initPoint.dx;
          double newHeight = initPoint.dy;
          final itemRatio = size.width / size.height;
          final pointerRatio = initPoint.dx / initPoint.dy;
          if (pointerRatio > itemRatio) {
            newHeight = newWidth / itemRatio;
          } else if (pointerRatio < itemRatio) {
            newWidth = newHeight * itemRatio;
          }
          if (newHeight < _minSize || newWidth < _minSize) return;

          final updatedSize = Size(newWidth, newHeight);

          final nCos = math.cos(-rotation);
          final nSin = math.sin(-rotation);
          final resizedCenter = Offset(
              (-newWidth + size.width) / 2, (newHeight - size.height) / 2);
          final rotatedCenter = Offset(
              nCos * (resizedCenter.dx) - nSin * (resizedCenter.dy),
              nSin * (resizedCenter.dx) + nCos * (resizedCenter.dy));
          final updatedPosition = Offset(
              position.dx +
                  (rotatedCenter.dx - resizedCenter.dx) -
                  (newWidth - size.width),
              position.dy -
                  (rotatedCenter.dy - resizedCenter.dy) -
                  (newHeight - size.height));

          setState(() {
            size = updatedSize;
            position = updatedPosition;
          });

          onTransform();
        }

        void onDragTopRight(Offset details) {
          initPoint =
              Offset(initPoint.dx + details.dx, initPoint.dy - details.dy);
          double newWidth = initPoint.dx;
          double newHeight = initPoint.dy;
          final itemRatio = size.width / size.height;
          final pointerRatio = initPoint.dx / initPoint.dy;
          if (pointerRatio > itemRatio) {
            newHeight = newWidth / itemRatio;
          } else if (pointerRatio < itemRatio) {
            newWidth = newHeight * itemRatio;
          }
          if (newHeight < _minSize || newWidth < _minSize) return;

          final updatedSize = Size(newWidth, newHeight);

          final nCos = math.cos(-rotation);
          final nSin = math.sin(-rotation);
          final resizedCenter = Offset(
              (newWidth - size.width) / 2, (newHeight - size.height) / 2);
          final rotatedCenter = Offset(
              nCos * (resizedCenter.dx) - nSin * (resizedCenter.dy),
              nSin * (resizedCenter.dx) + nCos * (resizedCenter.dy));
          final updatedPosition = Offset(
              position.dx + (rotatedCenter.dx - resizedCenter.dx),
              position.dy -
                  (rotatedCenter.dy - resizedCenter.dy) -
                  (newHeight - size.height));

          setState(() {
            size = updatedSize;
            position = updatedPosition;
          });

          onTransform();
        }

        void onDragBottomLeft(Offset details) {
          initPoint =
              Offset(initPoint.dx - details.dx, initPoint.dy + details.dy);
          double newWidth = initPoint.dx;
          double newHeight = initPoint.dy;
          final itemRatio = size.width / size.height;
          final pointerRatio = initPoint.dx / initPoint.dy;
          if (pointerRatio > itemRatio) {
            newHeight = newWidth / itemRatio;
          } else if (pointerRatio < itemRatio) {
            newWidth = newHeight * itemRatio;
          }
          if (newHeight < _minSize || newWidth < _minSize) return;
          final updatedSize = Size(newWidth, newHeight);

          final nCos = math.cos(-rotation);
          final nSin = math.sin(-rotation);
          final resizedCenter = Offset(
              (-newWidth + size.width) / 2, (-newHeight + size.height) / 2);
          final rotatedCenter = Offset(
              nCos * (resizedCenter.dx) - nSin * (resizedCenter.dy),
              nSin * (resizedCenter.dx) + nCos * (resizedCenter.dy));
          final updatedPosition = Offset(
              position.dx +
                  (rotatedCenter.dx - resizedCenter.dx) -
                  (newWidth - size.width),
              position.dy - (rotatedCenter.dy - resizedCenter.dy));

          setState(() {
            size = updatedSize;
            position = updatedPosition;
          });

          onTransform();
        }

        void onDragBottomRight(Offset details) {
          initPoint =
              Offset(initPoint.dx + details.dx, initPoint.dy + details.dy);
          double newWidth = initPoint.dx;
          double newHeight = initPoint.dy;
          final itemRatio = size.width / size.height;
          final pointerRatio = newWidth / newHeight;
          if (pointerRatio > itemRatio) {
            newHeight = newWidth / itemRatio;
          } else if (pointerRatio < itemRatio) {
            newWidth = newHeight * itemRatio;
          }
          if (newHeight < _minSize || newWidth < _minSize) return;
          final updatedSize = Size(newWidth, newHeight);

          final nCos = math.cos(-rotation);
          final nSin = math.sin(-rotation);
          final resizedCenter = Offset(
              (newWidth - size.width) / 2, (-newHeight + size.height) / 2);
          final rotatedCenter = Offset(
              nCos * (resizedCenter.dx) - nSin * (resizedCenter.dy),
              nSin * (resizedCenter.dx) + nCos * (resizedCenter.dy));
          final updatedPosition = Offset(
              position.dx + (rotatedCenter.dx - resizedCenter.dx),
              position.dy - (rotatedCenter.dy - resizedCenter.dy));

          setState(() {
            size = updatedSize;
            position = updatedPosition;
          });

          onTransform();
        }

        final decoratedChild = Container(
          key: const Key('transformable_child_container'),
          alignment: Alignment.center,
          height: normalizedHeight + _cornerDiameter + _floatingActionPadding,
          width: normalizedWidth + _cornerDiameter + _floatingActionPadding,
          child: Container(
            height: normalizedHeight,
            width: normalizedWidth,
            decoration: BoxDecoration(
              border: Border.all(
                width: 2,
                color: Colors.blue,
              ),
            ),
            child: widget.isText
                ? widget.child
                : FittedBox(
                    child: widget.child,
                    fit: BoxFit.fill,
                  ),
          ),
        );

        final topCenterPoint = _ResizePoint(
          key: const Key('transformable_topCenter_resizePoint'),
          type: _ResizePointType.axis,
          onDrag: onDragTopCenter,
        );

        final bottomCenterPoint = _ResizePoint(
          key: const Key('transformable_bottomCenter_resizePoint'),
          type: _ResizePointType.axis,
          onDrag: onDragBottomCenter,
        );

        final leftCenterPoint = _ResizePoint(
          key: const Key('transformable_leftCenter_resizePoint'),
          type: _ResizePointType.axis,
          onDrag: onDragLeftCenter,
        );

        final rightCenterPoint = _ResizePoint(
          key: const Key('transformable_rightCenter_resizePoint'),
          type: _ResizePointType.axis,
          onDrag: onDragRightCenter,
        );

        final topLeftPoint = _ResizePoint(
          key: const Key('transformable_topLeft_resizePoint'),
          type: _ResizePointType.diagonal,
          onDragStart: setInitPoint,
          onDrag: onDragTopLeft,
        );

        final topRightPoint = _ResizePoint(
          key: const Key('transformable_topRight_resizePoint'),
          type: _ResizePointType.diagonal,
          onDragStart: setInitPoint,
          onDrag: onDragTopRight,
        );

        final bottomLeftPoint = _ResizePoint(
          key: const Key('transformable_bottomLeft_resizePoint'),
          type: _ResizePointType.diagonal,
          onDragStart: setInitPoint,
          onDrag: onDragBottomLeft,
        );

        final bottomRightPoint = _ResizePoint(
          key: const Key('transformable_bottomRight_resizePoint'),
          type: _ResizePointType.diagonal,
          onDragStart: setInitPoint,
          onDrag: onDragBottomRight,
        );

        final center = Offset(
          (_floatingActionDiameter + _cornerDiameter) / 2,
          (normalizedHeight / 2) +
              (_floatingActionDiameter / 2) +
              (_cornerDiameter / 2) +
              (_floatingActionPadding / 2),
        );

        final rotateAnchor = GestureDetector(
          key: const Key('transformable_rotate_gestureDetector'),
          onScaleStart: (details) {
            final offsetFromCenter = details.localFocalPoint - center;
            setState(() {
              rotationDelta = baseRotation - offsetFromCenter.direction;
            });
          },
          onScaleUpdate: (details) {
            final offsetFromCenter = details.localFocalPoint - center;
            setState(() {
              rotation = offsetFromCenter.direction + rotationDelta;
            });
            onTransform();
          },
          onScaleEnd: (_) => setState(() => baseRotation = rotation),
          child: _FloatingActionIcon(
            key: const Key('transformable_rotate_floatingActionIcon'),
            iconData: Icons.rotate_left,
            onTap: () {},
          ),
        );

        return Stack(
          children: <Widget>[
            Positioned(
              top: normalizedTop,
              left: normalizedLeft,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..scale(1.0)
                  ..rotateZ(rotation),
                child: _DraggablePoint(
                  key: const Key('transformable_child_draggablePoint'),
                  onTap: onTransform,
                  onDrag: (d) {
                    setState(() {
                      position = Offset(position.dx + d.dx, position.dy + d.dy);
                    });
                    onTransform();
                  },
                  onScale: (s) {
                    final updatedSize = Size(
                      widget.size.width * s,
                      widget.size.height * s,
                    );
                    final midX = position.dx + (size.width / 2);
                    final midY = position.dy + (size.height / 2);
                    final updatedPosition = Offset(
                      midX - (updatedSize.width / 2),
                      midY - (updatedSize.height / 2),
                    );

                    setState(() {
                      size = updatedSize;
                      position = updatedPosition;
                    });
                    onTransform();
                  },
                  onRotate: (a) {
                    setState(() => rotation = a);
                    onTransform();
                  },
                  child: Stack(
                    children: [
                      decoratedChild,
                      Positioned(
                        top: _floatingActionPadding / 2,
                        left: normalizedWidth / 2 + _floatingActionPadding / 2,
                        child: topCenterPoint,
                      ),
                      Positioned(
                        top: normalizedHeight + _floatingActionPadding / 2,
                        left: normalizedWidth / 2 + _floatingActionPadding / 2,
                        child: bottomCenterPoint,
                      ),
                      Positioned(
                        top: normalizedHeight / 2 + _floatingActionPadding / 2,
                        left: _floatingActionPadding / 2,
                        child: leftCenterPoint,
                      ),
                      Positioned(
                        top: normalizedHeight / 2 + _floatingActionPadding / 2,
                        left: normalizedWidth + _floatingActionPadding / 2,
                        child: rightCenterPoint,
                      ),
                      Positioned(
                        top: _floatingActionPadding / 2,
                        left: _floatingActionPadding / 2,
                        child: topLeftPoint,
                      ),
                      Positioned(
                        top: _floatingActionPadding / 2,
                        left: normalizedWidth + _floatingActionPadding / 2,
                        child: topRightPoint,
                      ),
                      Positioned(
                        top: normalizedHeight + _floatingActionPadding / 2,
                        left: _floatingActionPadding / 2,
                        child: bottomLeftPoint,
                      ),
                      Positioned(
                        top: normalizedHeight + _floatingActionPadding / 2,
                        left: normalizedWidth + _floatingActionPadding / 2,
                        child: bottomRightPoint,
                      ),
                      Positioned(
                        top: 0,
                        left: (normalizedWidth / 2) -
                            (_floatingActionDiameter / 2) +
                            (_cornerDiameter / 2) +
                            (_floatingActionPadding / 2),
                        child: rotateAnchor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

enum _ResizePointType {
  diagonal,
  axis,
}

class _ResizePoint extends StatelessWidget {
  final Function? onDragStart;
  final ValueSetter<Offset> onDrag;
  final ValueSetter<double>? onScale;
  final _ResizePointType type;

  const _ResizePoint({
    Key? key,
    this.onDragStart,
    required this.onDrag,
    required this.type,
    this.onScale,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _DraggablePoint(
      mode: _PositionMode.local,
      onDragStart: onDragStart,
      onDrag: onDrag,
      onScale: onScale,
      child: Container(
        width: _cornerDiameter,
        height: _cornerDiameter,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue, width: 2),
          shape: type == _ResizePointType.axis
              ? BoxShape.rectangle
              : BoxShape.circle,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: type == _ResizePointType.axis
                ? BoxShape.rectangle
                : BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

enum _PositionMode { local, global }

class _DraggablePoint extends StatefulWidget {
  final Widget child;
  final _PositionMode mode;
  final Function? onDragStart;
  final ValueSetter<Offset>? onDrag;
  final ValueSetter<double>? onScale;
  final ValueSetter<double>? onRotate;
  final VoidCallback? onTap;

  const _DraggablePoint({
    Key? key,
    required this.child,
    this.onDragStart,
    this.onDrag,
    this.onScale,
    this.onRotate,
    this.onTap,
    this.mode = _PositionMode.global,
  }) : super(key: key);

  @override
  _DraggablePointState createState() => _DraggablePointState();
}

class _DraggablePointState extends State<_DraggablePoint> {
  late Offset initPoint;
  var baseScaleFactor = 1.0;
  var scaleFactor = 1.0;
  var baseAngle = 0.0;
  var angle = 0.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onScaleStart: (details) {
        switch (widget.mode) {
          case _PositionMode.global:
            initPoint = details.focalPoint;
            break;
          case _PositionMode.local:
            initPoint = details.localFocalPoint;
            break;
        }
        widget.onDragStart?.call();
      },
      onScaleUpdate: (details) {
        switch (widget.mode) {
          case _PositionMode.global:
            final dx = details.focalPoint.dx - initPoint.dx;
            final dy = details.focalPoint.dy - initPoint.dy;
            initPoint = details.focalPoint;
            widget.onDrag?.call(Offset(dx, dy));
            break;
          case _PositionMode.local:
            final dx = details.localFocalPoint.dx - initPoint.dx;
            final dy = details.localFocalPoint.dy - initPoint.dy;
            initPoint = details.localFocalPoint;
            widget.onDrag?.call(Offset(dx, dy));
            break;
        }
      },
      child: widget.child,
    );
  }
}

class _FloatingActionIcon extends StatelessWidget {
  final IconData iconData;
  final VoidCallback? onTap;

  const _FloatingActionIcon({
    Key? key,
    required this.iconData,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      clipBehavior: Clip.hardEdge,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: _floatingActionDiameter,
          width: _floatingActionDiameter,
          child: Center(
            child: Icon(
              iconData,
              color: Colors.blue,
            ),
          ),
        ),
      ),
    );
  }
}
