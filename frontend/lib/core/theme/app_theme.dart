import 'package:artid/core/costants/app_colors.dart';
import 'package:artid/core/costants/app_elevations.dart';
import 'package:artid/core/costants/app_shapes.dart';
import 'package:artid/core/costants/app_spacing.dart';
import 'package:artid/core/costants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  AppTheme._();

  // ── Light ─────────────────────────────────
  static ThemeData get light => _build(Brightness.light);

  // ── Dark ──────────────────────────────────
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = isDark ? _darkColorScheme : _lightColorScheme;
    final textTheme = AppTextStyles.buildTextTheme(dark: isDark);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,

      // ── Scaffold ────────────────────────────
      scaffoldBackgroundColor: colorScheme.surface,

      // ── AppBar ──────────────────────────────
      appBarTheme: AppBarTheme(
        elevation: AppElevations.none,
        scrolledUnderElevation: AppElevations.low,
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: colorScheme.surfaceTint,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: colorScheme.onSurface, size: 24),
        actionsIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant, size: 24),
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),

      // ── Buttons ─────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: AppElevations.low,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          shape: AppShapes.full,
          textStyle: textTheme.labelLarge,
          minimumSize: const Size(64, 48),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          shape: AppShapes.full,
          textStyle: textTheme.labelLarge,
          minimumSize: const Size(64, 48),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          shape: AppShapes.full,
          textStyle: textTheme.labelLarge,
          minimumSize: const Size(64, 48),
          side: BorderSide(color: colorScheme.outline),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          shape: AppShapes.medium,
          textStyle: textTheme.labelLarge,
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(shape: AppShapes.medium, minimumSize: const Size(44, 44)),
      ),

      // ── FAB ─────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(elevation: AppElevations.medium, shape: AppShapes.large, backgroundColor: colorScheme.primaryContainer, foregroundColor: colorScheme.onPrimaryContainer, extendedTextStyle: textTheme.labelLarge),

      // ── Card ────────────────────────────────
      cardTheme: CardThemeData(elevation: AppElevations.low, shape: AppShapes.large, color: colorScheme.surfaceContainerLow, surfaceTintColor: colorScheme.surfaceTint, clipBehavior: Clip.antiAlias, margin: const EdgeInsets.all(AppSpacing.sm)),

      // ── Chip ────────────────────────────────
      chipTheme: ChipThemeData(
        elevation: AppElevations.none,
        pressElevation: AppElevations.low,
        padding: AppSpacing.chipPadding,
        shape: AppShapes.full,
        labelStyle: textTheme.labelMedium,
        side: BorderSide(color: colorScheme.outlineVariant),
        selectedColor: colorScheme.secondaryContainer,
        checkmarkColor: colorScheme.onSecondaryContainer,
        backgroundColor: colorScheme.surfaceContainerHighest,
      ),

      // ── Input / TextField ────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant.withAlpha(153)),
        helperStyle: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        errorStyle: textTheme.bodySmall?.copyWith(color: colorScheme.error),
        prefixIconColor: colorScheme.onSurfaceVariant,
        suffixIconColor: colorScheme.onSurfaceVariant,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),

      // ── Dialog ──────────────────────────────
      dialogTheme: DialogThemeData(elevation: AppElevations.highest, shape: AppShapes.extraLarge, backgroundColor: colorScheme.surfaceContainerHigh, titleTextStyle: textTheme.headlineSmall, contentTextStyle: textTheme.bodyMedium, actionsPadding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg)),

      // ── Bottom Sheet ────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        elevation: AppElevations.highest,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        backgroundColor: colorScheme.surfaceContainerLow,
        showDragHandle: true,
        dragHandleColor: colorScheme.onSurfaceVariant.withAlpha(76),
        dragHandleSize: const Size(32, 4),
        modalElevation: AppElevations.highest,
      ),

      // ── Navigation Bar ──────────────────────
      navigationBarTheme: NavigationBarThemeData(
        elevation: AppElevations.medium,
        height: 72,
        backgroundColor: colorScheme.surfaceContainer,
        indicatorColor: colorScheme.secondaryContainer,
        indicatorShape: AppShapes.full,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelSmall?.copyWith(color: colorScheme.onSecondaryContainer, fontWeight: FontWeight.w700);
          }
          return textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.onSecondaryContainer, size: 24);
          }
          return IconThemeData(color: colorScheme.onSurfaceVariant, size: 24);
        }),
      ),

      // ── Navigation Rail ─────────────────────
      navigationRailTheme: NavigationRailThemeData(
        elevation: AppElevations.none,
        backgroundColor: colorScheme.surfaceContainerLow,
        selectedIconTheme: IconThemeData(color: colorScheme.onSecondaryContainer, size: 24),
        unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant, size: 24),
        selectedLabelTextStyle: textTheme.labelSmall?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w700),
        unselectedLabelTextStyle: textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
        indicatorColor: colorScheme.secondaryContainer,
        indicatorShape: AppShapes.full,
        minWidth: 80,
        minExtendedWidth: 200,
      ),

      // ── Drawer ──────────────────────────────
      drawerTheme: DrawerThemeData(
        elevation: AppElevations.highest,
        backgroundColor: colorScheme.surfaceContainerLow,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(16))),
        width: 280,
      ),

      // ── ListTile ────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        shape: AppShapes.medium,
        titleTextStyle: textTheme.titleSmall,
        subtitleTextStyle: textTheme.bodySmall,
        leadingAndTrailingTextStyle: textTheme.labelSmall,
        iconColor: colorScheme.onSurfaceVariant,
        textColor: colorScheme.onSurface,
        tileColor: Colors.transparent,
        selectedTileColor: colorScheme.secondaryContainer.withAlpha(128),
        selectedColor: colorScheme.onSecondaryContainer,
        minLeadingWidth: 24,
        minVerticalPadding: AppSpacing.sm,
      ),

      // ── Divider ─────────────────────────────
      dividerTheme: DividerThemeData(color: colorScheme.outlineVariant, thickness: 1, space: 1, indent: 0, endIndent: 0),

      // ── Switch ──────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.onPrimary;
          }
          return colorScheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.surfaceContainerHighest;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.transparent;
          }
          return colorScheme.outline;
        }),
      ),

      // ── Checkbox ────────────────────────────
      checkboxTheme: CheckboxThemeData(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(colorScheme.onPrimary),
        side: BorderSide(color: colorScheme.outline, width: 2),
      ),

      // ── Radio ───────────────────────────────
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.onSurfaceVariant;
        }),
      ),

      // ── Slider ──────────────────────────────
      sliderTheme: SliderThemeData(
        activeTrackColor: colorScheme.primary,
        inactiveTrackColor: colorScheme.surfaceContainerHighest,
        thumbColor: colorScheme.primary,
        overlayColor: colorScheme.primary.withAlpha(31),
        valueIndicatorColor: colorScheme.primary,
        valueIndicatorTextStyle: textTheme.labelSmall?.copyWith(color: colorScheme.onPrimary),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
      ),

      // ── Progress Indicator ──────────────────
      progressIndicatorTheme: ProgressIndicatorThemeData(color: colorScheme.primary, linearTrackColor: colorScheme.surfaceContainerHighest, circularTrackColor: colorScheme.surfaceContainerHighest, linearMinHeight: 4, borderRadius: BorderRadius.circular(4)),

      // ── Tooltip ─────────────────────────────
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(color: colorScheme.inverseSurface, borderRadius: BorderRadius.circular(8)),
        textStyle: textTheme.bodySmall?.copyWith(color: colorScheme.onInverseSurface),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        waitDuration: const Duration(milliseconds: 500),
        showDuration: const Duration(seconds: 2),
      ),

      // ── SnackBar ────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: AppShapes.medium,
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onInverseSurface),
        actionTextColor: colorScheme.inversePrimary,
        elevation: AppElevations.high,
      ),

      // ── Tab Bar ─────────────────────────────
      tabBarTheme: TabBarThemeData(
        indicatorColor: colorScheme.primary,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        labelStyle: textTheme.titleSmall,
        unselectedLabelStyle: textTheme.titleSmall,
        dividerColor: colorScheme.outlineVariant,
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return colorScheme.primary.withAlpha(31);
          }
          if (states.contains(WidgetState.hovered)) {
            return colorScheme.primary.withAlpha(15);
          }
          return null;
        }),
      ),

      // ── Popup Menu ──────────────────────────
      popupMenuTheme: PopupMenuThemeData(elevation: AppElevations.high, shape: AppShapes.large, color: colorScheme.surfaceContainerHigh, textStyle: textTheme.bodyMedium, enableFeedback: true, position: PopupMenuPosition.under, shadowColor: Colors.black.withAlpha(40)),

      // ── Icon ────────────────────────────────
      iconTheme: IconThemeData(color: colorScheme.onSurface, size: 24),

      // ── Badge ───────────────────────────────
      badgeTheme: BadgeThemeData(backgroundColor: colorScheme.error, textColor: colorScheme.onError, textStyle: textTheme.labelSmall, padding: const EdgeInsets.symmetric(horizontal: 6), smallSize: 8, largeSize: 16),
    );
  }

  // ── Light ColorScheme ────────────────────────
  static const _lightColorScheme = ColorScheme(brightness: Brightness.light, primary: AppColors.primary, onPrimary: Colors.white, primaryContainer: Color(0xFFE8E6FF), onPrimaryContainer: Color(0xFF21005D), secondary: AppColors.secondary, onSecondary: Colors.white, secondaryContainer: Color(0xFFFFD9E2), onSecondaryContainer: Color(0xFF3E001E), tertiary: AppColors.tertiary, onTertiary: Colors.white, tertiaryContainer: Color(0xFFBEF2E4), onTertiaryContainer: Color(0xFF00201A), error: AppColors.error, onError: Colors.white, errorContainer: Color(0xFFFFDAD6), onErrorContainer: Color(0xFF410002), surface: AppColors.lightBackground, onSurface: AppColors.lightOnSurface, surfaceContainerHighest: AppColors.lightSurfaceVariant, onSurfaceVariant: AppColors.lightOnSurfaceVariant, surfaceContainerLowest: Colors.white, surfaceContainerLow: Color(0xFFF3F2FF), surfaceContainer: Color(0xFFEDECFF), surfaceContainerHigh: Color(0xFFE7E6FF), outline: AppColors.lightOutline, outlineVariant: AppColors.lightOutlineVariant, inverseSurface: Color(0xFF302F4E), onInverseSurface: Color(0xFFF3F0FF), inversePrimary: AppColors.primaryLight, surfaceTint: AppColors.primary, shadow: Color(0xFF000000), scrim: Color(0xFF000000));

  // ── Dark ColorScheme ─────────────────────────
  static const _darkColorScheme = ColorScheme(brightness: Brightness.dark, primary: AppColors.primaryLight, onPrimary: Color(0xFF20006E), primaryContainer: AppColors.primaryDark, onPrimaryContainer: Color(0xFFE8E6FF), secondary: Color(0xFFFFB1C8), onSecondary: Color(0xFF5C1133), secondaryContainer: Color(0xFF7B294A), onSecondaryContainer: Color(0xFFFFD9E2), tertiary: Color(0xFFA2D6C8), onTertiary: Color(0xFF00382F), tertiaryContainer: Color(0xFF1F5046), onTertiaryContainer: Color(0xFFBEF2E4), error: Color(0xFFFFB4AB), onError: Color(0xFF690005), errorContainer: Color(0xFF93000A), onErrorContainer: Color(0xFFFFDAD6), surface: AppColors.darkBackground, onSurface: AppColors.darkOnSurface, onSurfaceVariant: AppColors.darkOnSurfaceVariant, surfaceContainerLowest: Color(0xFF090818), surfaceContainerLow: AppColors.darkSurface, surfaceContainer: Color(0xFF1E1D30), surfaceContainerHigh: AppColors.darkSurfaceVariant, surfaceContainerHighest: Color(0xFF302E4C), outline: AppColors.darkOutline, outlineVariant: AppColors.darkOutlineVariant, inverseSurface: Color(0xFFE6E1FF), onInverseSurface: Color(0xFF302F4E), inversePrimary: AppColors.primary, surfaceTint: AppColors.primaryLight, shadow: Color(0xFF000000), scrim: Color(0xFF000000));
}
