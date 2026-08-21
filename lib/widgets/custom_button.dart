import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isSecondary;
  final IconData? icon;
  final bool fullWidth;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isSecondary = false,
    this.icon,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final style = isSecondary ? _secondaryStyle() : _primaryStyle();
    
    Widget buttonContent = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isSecondary ? AppTheme.primary : Colors.white,
          ),
        ),
      ],
    );

    final button = isSecondary
        ? OutlinedButton(
            onPressed: onPressed,
            style: style,
            child: buttonContent,
          )
        : ElevatedButton(
            onPressed: onPressed,
            style: style,
            child: buttonContent,
          );

    return fullWidth
        ? SizedBox(
            width: double.infinity,
            height: 52,
            child: button,
          )
        : SizedBox(
            height: 52,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: button,
            ),
          );
  }

  ButtonStyle _primaryStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppTheme.primary,
      foregroundColor: Colors.white,
      disabledBackgroundColor: AppTheme.border,
      disabledForegroundColor: AppTheme.textLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
    );
  }

  ButtonStyle _secondaryStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: AppTheme.primary,
      backgroundColor: Colors.transparent,
      disabledForegroundColor: AppTheme.textLight,
      side: const BorderSide(color: AppTheme.primary, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
    );
  }
}
