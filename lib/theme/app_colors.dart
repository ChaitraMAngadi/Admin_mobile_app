import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFE23744);
  static const Color primaryDark = Color(0xFFB22433);
  static const Color secondary = Color(0xFFFF7A85);
  static const Color accent = Color(0xFFFFB3B8);
  static const Color bgStart = Color(0xFFFFF8F9);
  static const Color bgEnd = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color mutedBg = Color(0xFFFFF1F2);
  static const Color badgeBg = Color(0xFFFFEDEE);
  static const Color badgeText = Color(0xFFB22433);
  static const Color softPinkish = Color(0xFFFFF5F7);
  
  static LinearGradient primaryGradient = const LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  
  static LinearGradient secondaryGradient = const LinearGradient(
    colors: [secondary, accent],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  
  static LinearGradient bgGradient = const LinearGradient(
    colors: [bgStart, bgEnd],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}