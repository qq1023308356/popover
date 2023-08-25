import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class PopoverUtils {
  static late final PopoverUtils _singleton = PopoverUtils();

  static PopoverUtils get instance => _singleton;

  PopoverUtils getInstance() {
    _singleton._init();
    return _singleton;
  }

  double screenWidth = 0;
  double screenHeight = 0;
  double screenDensity = 0;
  double statusBarHeight = 0;
  double bottomBarHeight = 0;
  double appBarHeight = 0;
  double textScaleFactor = 0;
  MediaQueryData? _mediaQueryData;

  ///get Widget Bounds (width, height, left, top, right, bottom and so on).Widgets must be rendered completely.
  ///获取widget Rect
  Rect getWidgetBounds(BuildContext context) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    return (box != null) ? box.semanticBounds : Rect.zero;
  }

  ///Get the coordinates of the widget on the screen.Widgets must be rendered completely.
  ///获取widget在屏幕上的坐标,widget必须渲染完成
  Offset getWidgetLocalToGlobal(BuildContext context) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    return box == null ? Offset.zero : box.localToGlobal(Offset.zero);
  }

  void _init() {
    final MediaQueryData mediaQuery = MediaQueryData.fromWindow(ui.window);
    if (_mediaQueryData != mediaQuery) {
      _mediaQueryData = mediaQuery;
      screenWidth = mediaQuery.size.width;
      screenHeight = mediaQuery.size.height;
      screenDensity = mediaQuery.devicePixelRatio;
      statusBarHeight = mediaQuery.padding.top;
      bottomBarHeight = mediaQuery.padding.bottom;
      textScaleFactor = mediaQuery.textScaleFactor;
      appBarHeight = kToolbarHeight;
    }
  }
}
