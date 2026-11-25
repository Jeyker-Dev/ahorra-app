import 'package:flutter/material.dart';

/// Semantic colors from `docs/areas/stitch-design.md` beyond standard M3 roles.
@immutable
class AhorraColors extends ThemeExtension<AhorraColors> {
  const AhorraColors({
    required this.surfaceCard,
    required this.surfaceHigh,
    required this.outlineDivider,
    required this.outlineControl,
    required this.tagBcv,
    required this.tagUsdt,
    required this.positive,
    required this.negative,
    required this.warning,
  });

  final Color surfaceCard;
  final Color surfaceHigh;
  final Color outlineDivider;
  final Color outlineControl;
  final Color tagBcv;
  final Color tagUsdt;
  final Color positive;
  final Color negative;
  final Color warning;

  static const dark = AhorraColors(
    surfaceCard: Color(0xFF131A2E),
    surfaceHigh: Color(0xFF1B2440),
    outlineDivider: Color(0xFF2A3350),
    outlineControl: Color(0xFF64748B),
    tagBcv: Color(0xFF60A5FA),
    tagUsdt: Color(0xFF2DD4BF),
    positive: Color(0xFF4ADE80),
    negative: Color(0xFFF87171),
    warning: Color(0xFFFBBF24),
  );

  static const light = AhorraColors(
    surfaceCard: Color(0xFFFFFFFF),
    surfaceHigh: Color(0xFFEEF0F5),
    outlineDivider: Color(0xFFD9DCE5),
    outlineControl: Color(0xFF6B7280),
    tagBcv: Color(0xFF2563EB),
    tagUsdt: Color(0xFF0F766E),
    positive: Color(0xFF166534),
    negative: Color(0xFFB91C1C),
    warning: Color(0xFF92400E),
  );

  @override
  AhorraColors copyWith({
    Color? surfaceCard,
    Color? surfaceHigh,
    Color? outlineDivider,
    Color? outlineControl,
    Color? tagBcv,
    Color? tagUsdt,
    Color? positive,
    Color? negative,
    Color? warning,
  }) {
    return AhorraColors(
      surfaceCard: surfaceCard ?? this.surfaceCard,
      surfaceHigh: surfaceHigh ?? this.surfaceHigh,
      outlineDivider: outlineDivider ?? this.outlineDivider,
      outlineControl: outlineControl ?? this.outlineControl,
      tagBcv: tagBcv ?? this.tagBcv,
      tagUsdt: tagUsdt ?? this.tagUsdt,
      positive: positive ?? this.positive,
      negative: negative ?? this.negative,
      warning: warning ?? this.warning,
    );
  }

  @override
  AhorraColors lerp(ThemeExtension<AhorraColors>? other, double t) {
    if (other is! AhorraColors) return this;
    return AhorraColors(
      surfaceCard: Color.lerp(surfaceCard, other.surfaceCard, t)!,
      surfaceHigh: Color.lerp(surfaceHigh, other.surfaceHigh, t)!,
      outlineDivider: Color.lerp(outlineDivider, other.outlineDivider, t)!,
      outlineControl: Color.lerp(outlineControl, other.outlineControl, t)!,
      tagBcv: Color.lerp(tagBcv, other.tagBcv, t)!,
      tagUsdt: Color.lerp(tagUsdt, other.tagUsdt, t)!,
      positive: Color.lerp(positive, other.positive, t)!,
      negative: Color.lerp(negative, other.negative, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
    );
  }
}

extension AhorraThemeLookup on BuildContext {
  AhorraColors get ahorraColors =>
      Theme.of(this).extension<AhorraColors>() ?? AhorraColors.dark;
}

/// Builds the Ahorra Material 3 light and dark themes from `stitch-design.md`.
abstract final class AhorraTheme {
  static const double cardRadius = 12;
  static const double pillRadius = 999;

  static ThemeData dark() => _buildTheme(
        brightness: Brightness.dark,
        primary: const Color(0xFFA78BFA),
        onPrimary: const Color(0xFF0B1020),
        background: const Color(0xFF0B1020),
        onSurface: const Color(0xFFE6E9F5),
        onSurfaceMuted: const Color(0xFF9AA3BD),
        colors: AhorraColors.dark,
      );

  static ThemeData light() => _buildTheme(
        brightness: Brightness.light,
        primary: const Color(0xFF7C3AED),
        onPrimary: const Color(0xFFFFFFFF),
        background: const Color(0xFFF7F7FA),
        onSurface: const Color(0xFF151826),
        onSurfaceMuted: const Color(0xFF5B6275),
        colors: AhorraColors.light,
      );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color primary,
    required Color onPrimary,
    required Color background,
    required Color onSurface,
    required Color onSurfaceMuted,
    required AhorraColors colors,
  }) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      secondary: primary,
      onSecondary: onPrimary,
      secondaryContainer: colors.surfaceHigh,
      onSecondaryContainer: primary,
      error: colors.negative,
      onError: onPrimary,
      surface: background,
      onSurface: onSurface,
      surfaceContainerLowest: background,
      surfaceContainerLow: colors.surfaceCard,
      surfaceContainer: colors.surfaceCard,
      surfaceContainerHigh: colors.surfaceHigh,
      surfaceContainerHighest: colors.surfaceHigh,
      onSurfaceVariant: onSurfaceMuted,
      outline: colors.outlineControl,
      outlineVariant: colors.outlineDivider,
    );

    final textTheme = TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 32,
        height: 40 / 32,
        fontWeight: FontWeight.w700,
        fontFeatures: const [FontFeature.tabularFigures()],
        color: onSurface,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 24,
        height: 32 / 24,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 20,
        height: 28 / 20,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w400,
        color: onSurface,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w400,
        color: onSurface,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      labelMedium: TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w500,
        color: onSurfaceMuted,
      ),
    );

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(cardRadius),
      borderSide: BorderSide(color: colors.outlineControl),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      fontFamily: 'Inter',
      textTheme: textTheme,
      extensions: [colors],
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: colors.surfaceCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colors.outlineDivider,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceCard,
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          borderSide: BorderSide(color: colors.negative),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          borderSide: BorderSide(color: colors.negative, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cardRadius),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surfaceCard,
        elevation: 0,
        indicatorColor: colors.surfaceHigh,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return textTheme.labelMedium?.copyWith(
            color: isSelected ? primary : onSurfaceMuted,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          );
        }),
      ),
    );
  }
}
