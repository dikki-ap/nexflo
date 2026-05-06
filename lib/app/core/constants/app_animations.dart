import 'package:flutter/material.dart';

class AppAnimations {
  AppAnimations._();

  // ── Durations ────────────────────────────────────────────
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration page = Duration(milliseconds: 300);
  static const Duration splash = Duration(milliseconds: 900);
  static const Duration counter = Duration(milliseconds: 600);
  static const Duration staggerOffset = Duration(milliseconds: 50);

  // ── Curves ───────────────────────────────────────────────
  static const Curve easeOutCubic = Cubic(0.215, 0.610, 0.355, 1.000);
  static const Curve easeInOutCubic = Cubic(0.645, 0.045, 0.355, 1.000);
  static const Curve spring = ElasticOutCurve(0.6);
  static const Curve decelerate = Curves.decelerate;
  static const Curve standard = Curves.easeInOut;

  // ── Press scale ──────────────────────────────────────────
  static const double pressScale = 0.97;
  static const double pressScaleSmall = 0.95;

  // ── Shimmer colors ───────────────────────────────────────
  static const Color shimmerBase = Color(0xFF1C2433);
  static const Color shimmerHighlight = Color(0xFF2A3547);
  static const Color shimmerBaseLight = Color(0xFFE2E8F0);
  static const Color shimmerHighlightLight = Color(0xFFF8FAFC);
}
