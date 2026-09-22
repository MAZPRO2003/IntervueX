import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum AppButtonVariant { primary, secondary, outline, danger }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final AppButtonVariant variant;
  final double? width;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BorderSide? border;

    final primaryColor = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (variant) {
      case AppButtonVariant.primary:
        bg = primaryColor;
        fg = Colors.white;
        border = null;
        break;
      case AppButtonVariant.secondary:
        bg = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
        fg = isDark ? Colors.white : AppColors.textLightPrimary;
        border = BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1));
        break;
      case AppButtonVariant.outline:
        bg = Colors.transparent;
        fg = primaryColor;
        border = BorderSide(color: primaryColor, width: 1.5);
        break;
      case AppButtonVariant.danger:
        bg = AppColors.danger.withOpacity(0.15);
        fg = AppColors.danger;
        border = const BorderSide(color: AppColors.danger);
        break;
    }

    final btnContent = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );

    return SizedBox(
      width: width,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          side: border,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        onPressed: isLoading ? null : onPressed,
        child: btnContent,
      ),
    );
  }
}
