import 'package:cupertino_popover/popover_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

enum CupertinoPopoverDirection { top, bottom, left, right }

typedef BoolCallback = bool Function();

class CupertinoPopoverButton extends StatelessWidget {
  CupertinoPopoverButton({
    required this.child,
    required this.popoverBuild,
    this.arrowColor = Colors.white,
    this.popoverBoxShadow,
    this.popoverWidth,
    this.popoverHeight,
    BoxConstraints? popoverConstraints,
    this.direction = CupertinoPopoverDirection.bottom,
    this.onTap,
    this.transitionDuration = const Duration(milliseconds: 200),
    this.barrierColor = Colors.black54,
    this.radius = 8.0,
    this.isShowArrow = true,
    this.isShowSelf = true,
    Key? key,
  })  : popoverConstraints = (popoverWidth != null || popoverHeight != null)
            ? popoverConstraints?.tighten(width: popoverWidth, height: popoverHeight) ??
                BoxConstraints.tightFor(width: popoverWidth, height: popoverHeight)
            : popoverConstraints,
        super(key: key);
  final Widget child;
  final WidgetBuilder? popoverBuild;
  final double? popoverWidth;
  final double? popoverHeight;
  final Color arrowColor;
  final bool isShowArrow;
  final bool isShowSelf;
  final List<BoxShadow>? popoverBoxShadow;
  final double radius;
  final Duration transitionDuration;
  final BoolCallback? onTap;
  final BoxConstraints? popoverConstraints;
  final Color barrierColor;
  final CupertinoPopoverDirection direction;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (onTap != null && onTap!()) {
          return;
        }
        final Offset offset = PopoverUtils.instance.getWidgetLocalToGlobal(context);
        final Rect bounds = PopoverUtils.instance.getWidgetBounds(context);
        Widget? body;
        showGeneralDialog(
          context: context,
          pageBuilder: (BuildContext buildContext, Animation<double> animation, Animation<double> secondaryAnimation) {
            return Builder(builder: (BuildContext context) {
              return Container();
            });
          },
          barrierDismissible: true,
          barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
          barrierColor: barrierColor,
          transitionDuration: transitionDuration,
          transitionBuilder:
              (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget c) {
            body ??= popoverBuild?.call(context);
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
              child: Stack(
                children: <Widget>[
                  if (isShowSelf)
                    PositionedDirectional(
                      start: offset.dx,
                      top: offset.dy,
                      child: IgnorePointer(child: child),
                    ),
                  CupertinoPopover(
                    attachRect: Rect.fromLTWH(offset.dx, offset.dy, bounds.width, bounds.height),
                    constraints: popoverConstraints,
                    color: isShowArrow ? arrowColor : Colors.transparent,
                    isShowArrow: isShowArrow,
                    boxShadow: popoverBoxShadow,
                    radius: radius,
                    doubleAnimation: animation,
                    direction: direction,
                    child: body ?? const SizedBox.shrink(),
                  ),
                ],
              ),
            );
          },
        );
      },
      child: child,
    );
  }
}

// ignore: must_be_immutable
class CupertinoPopover extends StatefulWidget {
  CupertinoPopover({
    required this.attachRect,
    required this.child,
    required this.doubleAnimation,
    BoxConstraints? constraints,
    this.color = Colors.white,
    this.isShowArrow = true,
    this.boxShadow,
    this.direction = CupertinoPopoverDirection.bottom,
    this.radius = 8.0,
    Key? key,
  }) : super(key: key) {
    BoxConstraints temp;
    if (constraints != null) {
      temp = const BoxConstraints(maxHeight: 123, maxWidth: 150).copyWith(
        minWidth: constraints.minWidth.isFinite ? constraints.minWidth : null,
        minHeight: constraints.minHeight.isFinite ? constraints.minHeight : null,
        maxWidth: constraints.maxWidth.isFinite ? constraints.maxWidth : null,
        maxHeight: constraints.maxHeight.isFinite ? constraints.maxHeight : null,
      );
    } else {
      temp = const BoxConstraints(maxHeight: 123, maxWidth: 150);
    }
    this.constraints = temp.copyWith(maxHeight: temp.maxHeight + CupertinoPopoverState._arrowHeight);
  }

  final Rect attachRect;
  final Widget child;
  final Color color;
  final bool isShowArrow;
  final List<BoxShadow>? boxShadow;
  final double radius;
  final CupertinoPopoverDirection direction;
  final Animation<double> doubleAnimation;
  BoxConstraints? constraints;

  @override
  CupertinoPopoverState createState() => CupertinoPopoverState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<BoxConstraints>('constraints', constraints, showName: false));
    properties.add(DiagnosticsProperty<Color>('color', color, showName: false));
    properties.add(DiagnosticsProperty<double>('double', radius, showName: false));
  }
}

class CupertinoPopoverState extends State<CupertinoPopover> with TickerProviderStateMixin {
  static const double _arrowWidth = 12;
  static const double _arrowHeight = 8;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _CupertinoPopoverPosition(
      attachRect: widget.attachRect,
      scale: widget.doubleAnimation,
      constraints: widget.constraints,
      direction: widget.direction,
      child: _CupertinoPopoverContext(
        attachRect: widget.attachRect,
        scale: widget.doubleAnimation,
        radius: widget.radius,
        color: widget.color,
        isShowArrow: widget.isShowArrow,
        boxShadow: widget.boxShadow ?? <BoxShadow>[],
        direction: widget.direction,
        child: Material(type: MaterialType.transparency, child: widget.child),
      ),
    );
  }
}

class _CupertinoPopoverPosition extends SingleChildRenderObjectWidget {
  const _CupertinoPopoverPosition({
    required Widget child,
    required this.attachRect,
    required this.scale,
    required this.direction,
    this.constraints,
  }) : super(child: child);
  final Rect attachRect;
  final Animation<double> scale;
  final BoxConstraints? constraints;
  final CupertinoPopoverDirection direction;

  @override
  RenderObject createRenderObject(BuildContext context) => _CupertinoPopoverPositionRenderObject(
        attachRect: attachRect,
        direction: direction,
        constraints: constraints ?? const BoxConstraints(),
      );

  @override
  void updateRenderObject(BuildContext context, _CupertinoPopoverPositionRenderObject renderObject) {
    renderObject
      ..attachRect = attachRect
      ..direction = direction
      ..additionalConstraints = constraints ?? const BoxConstraints();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<BoxConstraints>('constraints', constraints, showName: false));
  }
}

class _CupertinoPopoverPositionRenderObject extends RenderShiftedBox {
  _CupertinoPopoverPositionRenderObject({
    required Rect attachRect,
    required CupertinoPopoverDirection direction,
    RenderBox? child,
    BoxConstraints constraints = const BoxConstraints(),
  })  : _attachRect = attachRect,
        _additionalConstraints = constraints,
        _direction = direction,
        super(child);

  CupertinoPopoverDirection get direction => _direction;
  CupertinoPopoverDirection _direction;

  set direction(CupertinoPopoverDirection value) {
    if (_direction == value) {
      return;
    }
    _direction = value;
    markNeedsLayout();
  }

  Rect get attachRect => _attachRect;
  Rect _attachRect;

  set attachRect(Rect value) {
    if (_attachRect == value) {
      return;
    }
    _attachRect = value;
    markNeedsLayout();
  }

  BoxConstraints get additionalConstraints => _additionalConstraints;
  BoxConstraints _additionalConstraints;

  set additionalConstraints(BoxConstraints value) {
    if (_additionalConstraints == value) {
      return;
    }
    _additionalConstraints = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    child!.layout(_additionalConstraints.enforce(constraints), parentUsesSize: true);
    size = Size(constraints.maxWidth, constraints.maxHeight);

    final BoxParentData? childParentData = child?.parentData as BoxParentData?;

    childParentData?.offset = calcOffset(child!.size);
  }

  Offset calcOffset(Size size) {
    final CupertinoPopoverDirection calcDirection = _calcDirection(attachRect, size, direction);

    if (calcDirection == CupertinoPopoverDirection.top || calcDirection == CupertinoPopoverDirection.bottom) {
      double bodyLeft = 0;
      // 上下
      if (attachRect.left > size.width / 2 && PopoverUtils.instance.screenWidth - attachRect.right > size.width / 2) {
        //判断是否可以在中间
        bodyLeft = attachRect.left + attachRect.width / 2 - size.width / 2;
      } else if (attachRect.left < size.width / 2) {
        //靠左
        bodyLeft = 10.0;
      } else {
        //靠右
        bodyLeft = PopoverUtils.instance.getInstance().screenWidth - 10.0 - size.width;
      }

      if (calcDirection == CupertinoPopoverDirection.bottom) {
        return Offset(bodyLeft, attachRect.bottom);
      } else {
        return Offset(bodyLeft, attachRect.top - size.height);
      }
    } else {
      double bodyTop = 0;
      if (attachRect.top > size.height / 2 &&
          PopoverUtils.instance.getInstance().screenHeight - attachRect.bottom > size.height / 2) {
        //判断是否可以在中间
        bodyTop = attachRect.top + attachRect.height / 2 - size.height / 2;
      } else if (attachRect.top < size.height / 2) {
        //靠左
        bodyTop = 10.0;
      } else {
        //靠右
        bodyTop = PopoverUtils.instance.getInstance().screenHeight - 10.0 - size.height;
      }

      if (calcDirection == CupertinoPopoverDirection.right) {
        return Offset(attachRect.right, bodyTop);
      } else {
        return Offset(attachRect.left - size.width, bodyTop);
      }
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<BoxConstraints>('additionalConstraints', additionalConstraints));
  }
}

class _CupertinoPopoverContext extends SingleChildRenderObjectWidget {
  const _CupertinoPopoverContext({
    required Widget child,
    required this.attachRect,
    required this.color,
    required this.isShowArrow,
    required this.scale,
    required this.radius,
    required this.direction,
    this.boxShadow = const <BoxShadow>[],
  }) : super(child: child);
  final Rect attachRect;
  final Color color;
  final bool isShowArrow;
  final List<BoxShadow> boxShadow;
  final Animation<double> scale;
  final double radius;
  final CupertinoPopoverDirection direction;

  @override
  RenderObject createRenderObject(BuildContext context) => _CupertinoPopoverContextRenderObject(
        attachRect: attachRect,
        color: color,
        boxShadow: boxShadow,
        scale: scale.value,
        direction: direction,
        radius: radius,
        isShowArrow: isShowArrow,
      );

  @override
  void updateRenderObject(BuildContext context, _CupertinoPopoverContextRenderObject renderObject) {
    renderObject
      ..attachRect = attachRect
      ..color = color
      ..boxShadow = boxShadow
      ..scale = scale.value
      ..direction = direction
      ..radius = radius;
  }
}

class _CupertinoPopoverContextRenderObject extends RenderShiftedBox {
  _CupertinoPopoverContextRenderObject({
    required Rect attachRect,
    required Color color,
    required this.isShowArrow,
    required double scale,
    required double radius,
    required CupertinoPopoverDirection direction,
    RenderBox? child,
    List<BoxShadow> boxShadow = const <BoxShadow>[],
  })  : _attachRect = attachRect,
        _color = color,
        _boxShadow = boxShadow,
        _scale = scale,
        _radius = radius,
        _direction = direction,
        super(child);

  bool isShowArrow;

  CupertinoPopoverDirection get direction => _direction;
  CupertinoPopoverDirection _direction;

  set direction(CupertinoPopoverDirection value) {
    if (_direction == value) {
      return;
    }
    _direction = value;
    markNeedsLayout();
  }

  Rect get attachRect => _attachRect;
  Rect _attachRect;

  set attachRect(Rect value) {
    if (_attachRect == value) {
      return;
    }
    _attachRect = value;
    markNeedsLayout();
  }

  Color get color => _color;
  Color _color;

  set color(Color value) {
    if (_color == value) {
      return;
    }
    _color = value;
    markNeedsLayout();
  }

  List<BoxShadow> get boxShadow => _boxShadow;
  List<BoxShadow> _boxShadow;

  set boxShadow(List<BoxShadow> value) {
    if (_boxShadow == value) {
      return;
    }
    _boxShadow = value;
    markNeedsLayout();
  }

  double get scale => _scale;
  double _scale;

  set scale(double value) {
    // print('scale:${_scale.value}');
    // if (_scale == value)
    //   return;
    _scale = value;
    markNeedsLayout();
  }

  double get radius => _radius;
  double _radius;

  set radius(double value) {
    if (_radius == value) {
      return;
    }
    _radius = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    assert(constraints.maxHeight.isFinite, 'constraints.maxHeight.isFinite');
    BoxConstraints childConstraints;

    if (direction == CupertinoPopoverDirection.top || direction == CupertinoPopoverDirection.bottom) {
      childConstraints =
          BoxConstraints(maxHeight: constraints.maxHeight - CupertinoPopoverState._arrowHeight).enforce(constraints);
    } else {
      childConstraints =
          BoxConstraints(maxWidth: constraints.maxWidth - CupertinoPopoverState._arrowHeight).enforce(constraints);
    }

    child!.layout(childConstraints, parentUsesSize: true);

    if (direction == CupertinoPopoverDirection.top || direction == CupertinoPopoverDirection.bottom) {
      size = Size(child!.size.width, child!.size.height + CupertinoPopoverState._arrowHeight);
    } else {
      size = Size(child!.size.width + CupertinoPopoverState._arrowHeight, child!.size.height);
    }
    final CupertinoPopoverDirection calcDirection = _calcDirection(attachRect, size, direction);

    final BoxParentData? childParentData = child?.parentData as BoxParentData?;
    if (calcDirection == CupertinoPopoverDirection.bottom) {
      childParentData?.offset = const Offset(0, CupertinoPopoverState._arrowHeight);
    } else if (calcDirection == CupertinoPopoverDirection.right) {
      childParentData?.offset = const Offset(CupertinoPopoverState._arrowHeight, 0);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Matrix4 transform = Matrix4.identity();

    final CupertinoPopoverDirection calcDirection = _calcDirection(attachRect, size, direction);

    Rect arrowRect = Rect.zero;
    Offset translation = Offset.zero;
    Rect bodyRect = Rect.zero;

    final BoxParentData? childParentData = child?.parentData as BoxParentData?;
    if (childParentData != null) {
      bodyRect = childParentData.offset & child!.size;
    }

    final double arrowLeft = attachRect.left + // 用于 Top和Bottom
        attachRect.width / 2 -
        CupertinoPopoverState._arrowWidth / 2 -
        offset.dx;

    final double arrowTop = attachRect.top + // 用于 Left和Right
        attachRect.height / 2 -
        CupertinoPopoverState._arrowWidth / 2 -
        offset.dy;

    switch (calcDirection) {
      case CupertinoPopoverDirection.top:
        arrowRect = Rect.fromLTWH(
            arrowLeft, child!.size.height, CupertinoPopoverState._arrowWidth, CupertinoPopoverState._arrowHeight);
        translation = Offset(arrowLeft + CupertinoPopoverState._arrowWidth / 2, size.height);

        break;
      case CupertinoPopoverDirection.left:
        arrowRect = Rect.fromLTWH(
            child!.size.width, arrowTop, CupertinoPopoverState._arrowHeight, CupertinoPopoverState._arrowWidth);
        translation = Offset(size.width, arrowTop + CupertinoPopoverState._arrowWidth / 2);
        break;
      case CupertinoPopoverDirection.bottom:
        arrowRect = Rect.fromLTWH(arrowLeft, 0, CupertinoPopoverState._arrowWidth, CupertinoPopoverState._arrowHeight);
        translation = Offset(arrowLeft + CupertinoPopoverState._arrowWidth / 2, 0);
        break;
      case CupertinoPopoverDirection.right:
        arrowRect = Rect.fromLTWH(0, arrowTop, CupertinoPopoverState._arrowHeight, CupertinoPopoverState._arrowWidth);
        translation = Offset(0, arrowTop + CupertinoPopoverState._arrowWidth / 2);
        break;
      default:
    }

    transform.translate(translation.dx, translation.dy);
    transform.scale(scale, scale, 1);
    transform.translate(-translation.dx, -translation.dy);

    _paintShadows(context, transform, offset, calcDirection, arrowRect, bodyRect);

    final Path clipPath = _getClip(calcDirection, arrowRect, bodyRect);
    context.pushClipPath(needsCompositing, offset, offset & size, clipPath, (PaintingContext context, Offset offset) {
      context.pushTransform(needsCompositing, offset, transform, (PaintingContext context, Offset offset) {
        final Paint backgroundPaint = Paint();
        backgroundPaint.color = color;
        context.canvas.drawRect(offset & size, backgroundPaint);
        super.paint(context, offset);
      });
    });
  }

  void _paintShadows(PaintingContext context, Matrix4 transform, Offset offset, CupertinoPopoverDirection direction,
      Rect arrow, Rect body) {
    for (final BoxShadow boxShadow in boxShadow) {
      final Paint paint = boxShadow.toPaint();
      final Rect arrowRect = arrow.shift(offset).shift(boxShadow.offset).inflate(boxShadow.spreadRadius);
      final Rect bodyRect = body.shift(offset).shift(boxShadow.offset).inflate(boxShadow.spreadRadius);
      final Path path = _getClip(direction, arrowRect, bodyRect);

      context.pushTransform(needsCompositing, offset, transform, (PaintingContext context, Offset offset) {
        context.canvas.drawPath(path, paint);
      });
    }
  }

  Path _getClip(CupertinoPopoverDirection direction, Rect arrowRect, Rect bodyRect) {
    final Path path = Path();
    if (direction == CupertinoPopoverDirection.top) {
      if (isShowArrow) {
        path.moveTo(arrowRect.left, arrowRect.top); //箭头
        path.lineTo(arrowRect.left + arrowRect.width / 2, arrowRect.bottom);
        path.lineTo(arrowRect.right, arrowRect.top);
      } else {
        path.moveTo(bodyRect.right - radius, bodyRect.bottom);
      }

      path.lineTo(bodyRect.right - radius, bodyRect.bottom); //右下角
      path.conicTo(bodyRect.right, bodyRect.bottom, bodyRect.right, bodyRect.bottom - radius, 1);

      path.lineTo(bodyRect.right, bodyRect.top + radius); //右上角
      path.conicTo(bodyRect.right, bodyRect.top, bodyRect.right - radius, bodyRect.top, 1);

      path.lineTo(bodyRect.left + radius, bodyRect.top); //左上角
      path.conicTo(bodyRect.left, bodyRect.top, bodyRect.left, bodyRect.top + radius, 1);

      path.lineTo(bodyRect.left, bodyRect.bottom - radius); //左下角
      path.conicTo(bodyRect.left, bodyRect.bottom, bodyRect.left + radius, bodyRect.bottom, 1);
    } else if (direction == CupertinoPopoverDirection.right) {
      if (isShowArrow) {
        path.moveTo(arrowRect.right, arrowRect.top); //箭头
        path.lineTo(arrowRect.left, arrowRect.top + arrowRect.height / 2);
        path.lineTo(arrowRect.right, arrowRect.bottom);
      } else {
        path.moveTo(bodyRect.left, bodyRect.bottom - radius);
      }
      path.lineTo(bodyRect.left, bodyRect.bottom - radius); //左下角
      path.conicTo(bodyRect.left, bodyRect.bottom, bodyRect.left + radius, bodyRect.bottom, 1);

      path.lineTo(bodyRect.right - radius, bodyRect.bottom); //右下角
      path.conicTo(bodyRect.right, bodyRect.bottom, bodyRect.right, bodyRect.bottom - radius, 1);

      path.lineTo(bodyRect.right, bodyRect.top + radius); //右上角
      path.conicTo(bodyRect.right, bodyRect.top, bodyRect.right - radius, bodyRect.top, 1);

      path.lineTo(bodyRect.left + radius, bodyRect.top); //左上角
      path.conicTo(bodyRect.left, bodyRect.top, bodyRect.left, bodyRect.top + radius, 1);
    } else if (direction == CupertinoPopoverDirection.left) {
      if (isShowArrow) {
        path.moveTo(arrowRect.left, arrowRect.top); //箭头
        path.lineTo(arrowRect.right, arrowRect.top + arrowRect.height / 2);
        path.lineTo(arrowRect.left, arrowRect.bottom);
      } else {
        path.moveTo(bodyRect.right, bodyRect.bottom - radius);
      }

      path.lineTo(bodyRect.right, bodyRect.bottom - radius); //右下角
      path.conicTo(bodyRect.right, bodyRect.bottom, bodyRect.right - radius, bodyRect.bottom, 1);

      path.lineTo(bodyRect.left + radius, bodyRect.bottom); //左下角
      path.conicTo(bodyRect.left, bodyRect.bottom, bodyRect.left, bodyRect.bottom - radius, 1);

      path.lineTo(bodyRect.left, bodyRect.top + radius); //左上角
      path.conicTo(bodyRect.left, bodyRect.top, bodyRect.left + radius, bodyRect.top, 1);

      path.lineTo(bodyRect.right - radius, bodyRect.top); //右上角
      path.conicTo(bodyRect.right, bodyRect.top, bodyRect.right, bodyRect.top + radius, 1);
    } else {
      if (isShowArrow) {
        path.moveTo(arrowRect.left, arrowRect.bottom); //箭头
        path.lineTo(arrowRect.left + arrowRect.width / 2, arrowRect.top);
        path.lineTo(arrowRect.right, arrowRect.bottom);
      } else {
        path.moveTo(bodyRect.right - radius, bodyRect.top);
      }

      path.lineTo(bodyRect.right - radius, bodyRect.top); //右上角
      path.conicTo(bodyRect.right, bodyRect.top, bodyRect.right, bodyRect.top + radius, 1);

      path.lineTo(bodyRect.right, bodyRect.bottom - radius); //右下角
      path.conicTo(bodyRect.right, bodyRect.bottom, bodyRect.right - radius, bodyRect.bottom, 1);

      path.lineTo(bodyRect.left + radius, bodyRect.bottom); //左下角
      path.conicTo(bodyRect.left, bodyRect.bottom, bodyRect.left, bodyRect.bottom - radius, 1);

      path.lineTo(bodyRect.left, bodyRect.top + radius); //左上角
      path.conicTo(bodyRect.left, bodyRect.top, bodyRect.left + radius, bodyRect.top, 1);
    }
    path.close();
    return path;
  }
}

CupertinoPopoverDirection _calcDirection(Rect attachRect, Size size, CupertinoPopoverDirection direction) {
  switch (direction) {
    case CupertinoPopoverDirection.top:
      return (attachRect.top < size.height + CupertinoPopoverState._arrowHeight)
          ? CupertinoPopoverDirection.bottom
          : CupertinoPopoverDirection.top; // 判断顶部位置够不够
    case CupertinoPopoverDirection.bottom:
      return PopoverUtils.instance.getInstance().screenHeight >
              attachRect.bottom + size.height + CupertinoPopoverState._arrowHeight
          ? CupertinoPopoverDirection.bottom
          : CupertinoPopoverDirection.top;
    case CupertinoPopoverDirection.left:
      return (attachRect.left < size.width + CupertinoPopoverState._arrowHeight)
          ? CupertinoPopoverDirection.right
          : CupertinoPopoverDirection.left; // 判断顶部位置够不够
    case CupertinoPopoverDirection.right:
      return PopoverUtils.instance.getInstance().screenWidth >
              attachRect.right + size.width + CupertinoPopoverState._arrowHeight
          ? CupertinoPopoverDirection.right
          : CupertinoPopoverDirection.left;
  }
}
