

import 'package:flutter/material.dart';

const double _mobileScreenPadding = 25.0;
const double _cardBorderRadius = 10.0;
double get mobileScreenPadding => _mobileScreenPadding;


class UiParameters {
  static BorderRadius get cardBorderRadius => BorderRadius.circular(_cardBorderRadius);
  static EdgeInsets get mobileScreenPadding => const EdgeInsets.all(_mobileScreenPadding);
}