import 'package:flutter/material.dart';

/// Tajwid coloring palette (design system §1.5 companion).
///
/// Colors for the tajwid recitation rules, resolved by brightness. All values
/// are AA-safe on the warm paper background in both modes. Mirrors how
/// [QuranPalette] is structured as a `ThemeExtension`.
@immutable
class TajwidPalette extends ThemeExtension<TajwidPalette> {
  const TajwidPalette({
    required this.mad,
    required this.ghunnah,
    required this.qalqalah,
    this.nunSukun,
    this.madSila,
  });

  final Color mad;
  final Color ghunnah;
  final Color qalqalah;

  /// Reserved for future rules (not yet decoded).
  final Color? nunSukun;
  final Color? madSila;

  static const TajwidPalette light = TajwidPalette(
    mad: Color(0xFFC62828),
    ghunnah: Color(0xFF2E7D32),
    qalqalah: Color(0xFF1565C0),
  );

  static const TajwidPalette dark = TajwidPalette(
    mad: Color(0xFFEF9A9A),
    ghunnah: Color(0xFF81C784),
    qalqalah: Color(0xFF64B5F6),
  );

  /// Resolves the tajwid palette for a brightness.
  static TajwidPalette of(bool dark) => dark ? TajwidPalette.dark : TajwidPalette.light;

  @override
  TajwidPalette copyWith({
    Color? mad,
    Color? ghunnah,
    Color? qalqalah,
    Color? nunSukun,
    Color? madSila,
  }) {
    return TajwidPalette(
      mad: mad ?? this.mad,
      ghunnah: ghunnah ?? this.ghunnah,
      qalqalah: qalqalah ?? this.qalqalah,
      nunSukun: nunSukun ?? this.nunSukun,
      madSila: madSila ?? this.madSila,
    );
  }

  @override
  TajwidPalette lerp(TajwidPalette? other, double t) {
    if (other == null) return this;
    return TajwidPalette(
      mad: Color.lerp(mad, other.mad, t)!,
      ghunnah: Color.lerp(ghunnah, other.ghunnah, t)!,
      qalqalah: Color.lerp(qalqalah, other.qalqalah, t)!,
      nunSukun: Color.lerp(nunSukun, other.nunSukun, t),
      madSila: Color.lerp(madSila, other.madSila, t),
    );
  }
}
