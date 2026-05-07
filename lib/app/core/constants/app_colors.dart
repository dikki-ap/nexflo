import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Accent palette ──────────────────────────────────────
  static const teal = Color(0xFF00BCD4);
  static const blue = Color(0xFF2196F3);
  static const purple = Color(0xFF9C27B0);
  static const green = Color(0xFF4CAF50);
  static const orange = Color(0xFFFF9800);
  static const pink = Color(0xFFE91E63);

  // ── Teal gradient stops (Electric Teal) ─────────────────
  static const tealLight = Color(0xFF00E5FF);
  static const tealMid = Color(0xFF00BCD4);
  static const tealDark = Color(0xFF0097A7);
  static const tealDeep = Color(0xFF006064);

  static const LinearGradient tealGradient = LinearGradient(
    colors: [tealLight, tealMid, tealDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tealGradientVertical = LinearGradient(
    colors: [tealLight, tealMid, tealDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient primaryGradient(Color c) {
    final hsl = HSLColor.fromColor(c);
    final lighter = hsl
        .withLightness((hsl.lightness + 0.12).clamp(0.0, 1.0))
        .toColor();
    final darker = hsl
        .withLightness((hsl.lightness - 0.08).clamp(0.0, 1.0))
        .toColor();
    return LinearGradient(
      colors: [lighter, c, darker],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // ── Glow / shadow for accent elements ───────────────────
  static const tealGlow = Color(0x4D00BCD4); // 30% opacity
  static const tealGlowSoft = Color(0x1A00BCD4); // 10% opacity

  // ── Dark mode background system ─────────────────────────
  static const darkBg = Color(0xFF0A0E1A);       // deep space
  static const darkSurface = Color(0xFF111827);   // surface
  static const darkCard = Color(0xFF1C2433);      // card base
  static const darkCardAlt = Color(0xFF1A2235);   // alternate card

  // ── Glass overlay colors ────────────────────────────────
  static const glassLight = Color(0x14FFFFFF);    // white 8%
  static const glassMid = Color(0x1FFFFFFF);      // white 12%
  static const glassDark = Color(0x0AFFFFFF);     // white 4%
  static const glassBorder = Color(0x33FFFFFF);   // white 20%
  static const glassBorderLight = Color(0x1AFFFFFF); // white 10%

  // ── Light mode background system ────────────────────────
  static const lightBg = Color(0xFFF8FAFC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFF1F5F9);

  // ── Semantic colors ──────────────────────────────────────
  static const income = Color(0xFF22C55E);      // modern green
  static const expense = Color(0xFFEF4444);     // modern red
  static const transfer = Color(0xFF00BCD4);
  static const incomeGlow = Color(0x3322C55E);
  static const expenseGlow = Color(0x33EF4444);

  // ── Budget progress states ───────────────────────────────
  static const budgetSafe = Color(0xFF22C55E);
  static const budgetWarning = Color(0xFFF59E0B);
  static const budgetAlert = Color(0xFFF97316);
  static const budgetOver = Color(0xFFEF4444);

  // ── Neutral grays ────────────────────────────────────────
  static const grey50 = Color(0xFFF8FAFC);
  static const grey100 = Color(0xFFF1F5F9);
  static const grey200 = Color(0xFFE2E8F0);
  static const grey300 = Color(0xFFCBD5E1);
  static const grey400 = Color(0xFF94A3B8);
  static const grey500 = Color(0xFF64748B);
  static const grey600 = Color(0xFF475569);
  static const grey700 = Color(0xFF334155);
  static const grey800 = Color(0xFF1E293B);
  static const grey900 = Color(0xFF0F172A);

  // ── Wallet type gradient presets ─────────────────────────
  static const LinearGradient walletCash = LinearGradient(
    colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient walletBank = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient walletEwallet = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient walletCreditCard = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient walletInvestment = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFB45309)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient walletSavings = LinearGradient(
    colors: [tealLight, tealDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
