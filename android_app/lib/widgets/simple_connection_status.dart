import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Widget simplificado para mostrar status de conexão
class SimpleConnectionStatus extends StatelessWidget {

  const SimpleConnectionStatus({
    required this.isConnected, super.key,
    this.isLoading = false,
    this.title = 'Status',
    this.description = '',
  });
  final bool isConnected;
  final bool isLoading;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Container(
      constraints: const BoxConstraints(maxWidth: 280),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getBorderColor(),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatusIcon(),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getTextColor(),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (description.isNotEmpty)
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 10,
                      color: _getTextColor().withValues(alpha: 0.7),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );

  Widget _buildStatusIcon() {
    if (isLoading) {
      return SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(_getIconColor()),
        ),
      );
    }

    return Icon(
      isConnected ? Icons.cloud_done : Icons.cloud_off,
      size: 16,
      color: _getIconColor(),
    );
  }

  Color _getBackgroundColor() {
    if (isLoading) return AppColors.warning.withValues(alpha: 0.1);
    return isConnected
        ? AppColors.success.withValues(alpha: 0.1)
        : AppColors.error.withValues(alpha: 0.1);
  }

  Color _getBorderColor() {
    if (isLoading) return AppColors.warning;
    return isConnected ? AppColors.success : AppColors.error;
  }

  Color _getTextColor() {
    if (isLoading) return AppColors.warning;
    return isConnected ? AppColors.success : AppColors.error;
  }

  Color _getIconColor() {
    if (isLoading) return AppColors.warning;
    return isConnected ? AppColors.success : AppColors.error;
  }
}
