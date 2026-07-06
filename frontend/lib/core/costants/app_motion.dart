import 'package:flutter/material.dart';

class AppMotion {
  AppMotion._();

  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration slower = Duration(milliseconds: 700);

  static const Curve standard = Curves.easeInOut;
  static const Curve emphasized = Curves.easeOutCubic;
  static const Curve decelerate = Curves.decelerate;
  static const Curve spring = Curves.elasticOut;
}
