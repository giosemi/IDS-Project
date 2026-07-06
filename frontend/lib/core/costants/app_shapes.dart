import 'package:flutter/material.dart';

class AppShapes {
  AppShapes._();

  static const extraSmall = RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4)));
  static const small = RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8)));
  static const medium = RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12)));
  static const large = RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16)));
  static const extraLarge = RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(28)));
  static const full = RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(100)));
}
