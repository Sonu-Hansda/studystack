import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum SnackBarType {
  success,
  error,
  info,
}

class CustomSnackBar extends SnackBar {
  CustomSnackBar({
    super.key,
    required String message,
    required SnackBarType type,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) : super(
          content: Row(
            children: [
              Icon(
                _getIcon(type),
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.poppins(),
                ),
              ),
            ],
          ),
          backgroundColor: _getBackgroundColor(type),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: duration ?? const Duration(seconds: 3),
          animation: CurvedAnimation(
            parent: const AlwaysStoppedAnimation(1),
            curve: Curves.easeInOut,
          ),
          action: actionLabel != null
              ? SnackBarAction(
                  label: actionLabel,
                  textColor: Colors.white,
                  onPressed: onActionPressed ?? () {},
                )
              : null,
        );

  static IconData _getIcon(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Icons.check_circle;
      case SnackBarType.error:
        return Icons.error_outline;
      case SnackBarType.info:
        return Icons.info_outline;
    }
  }

  static Color _getBackgroundColor(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Colors.green;
      case SnackBarType.error:
        return Colors.red;
      case SnackBarType.info:
        return Colors.blue;
    }
  }

  // Convenience constructors
  factory CustomSnackBar.success({
    required String message,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    return CustomSnackBar(
      message: message,
      type: SnackBarType.success,
      duration: duration,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }

  factory CustomSnackBar.error({
    required String message,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    return CustomSnackBar(
      message: message,
      type: SnackBarType.error,
      duration: duration,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }

  factory CustomSnackBar.info({
    required String message,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    return CustomSnackBar(
      message: message,
      type: SnackBarType.info,
      duration: duration,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }
}
