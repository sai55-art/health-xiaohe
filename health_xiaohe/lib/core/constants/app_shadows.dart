import 'package:flutter/material.dart';

/// 暖投影(基于砂/墨色低透明,非纯黑)。
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> soft = [
    BoxShadow(
      color: Color(0x1A8C826E),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x218C826E),
      blurRadius: 22,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> primary = [
    BoxShadow(
      color: Color(0x597FB3A8),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];
}
