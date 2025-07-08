import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';

class ConnectionStatus extends StatelessWidget {
  const ConnectionStatus({
    required this.isConnected,
    super.key,
    this.serverInfo,
    this.onRetry,
    this.isLoading = false,
  });
  final bool isConnected;
  final String? serverInfo;
  final VoidCallback? onRetry;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getBorderColor(),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: _getBorderColor().withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatusIcon(),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getStatusTitle(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _getTextColor(),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getStatusDescription(),
                        style: TextStyle(
                          fontSize: 14,
                          color: _getTextColor().withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isConnected && !isLoading && onRetry != null)
                  IconButton(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    color: _getTextColor(),
                    tooltip: AppStrings.retry,
                  ),
              ],
            ),
            if (serverInfo != null && isConnected) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: _getTextColor().withOpacity(0.8),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        serverInfo!,
                        style: TextStyle(
                          fontSize: 12,
                          color: _getTextColor().withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (!isConnected) ...[
              const SizedBox(height: 12),
              _buildOfflineFeatures(),
            ],
          ],
        ),
      );

  Widget _buildStatusIcon() {
    if (isLoading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(_getTextColor()),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isConnected ? Icons.cloud_done : Icons.cloud_off,
        color: _getTextColor(),
        size: 24,
      ),
    );
  }

  Widget _buildOfflineFeatures() => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.offline_bolt,
                  size: 16,
                  color: _getTextColor().withOpacity(0.8),
                ),
                const SizedBox(width: 8),
                Text(
                  AppStrings.offlineMode,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _getTextColor(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.offlineFeatures,
              style: TextStyle(
                fontSize: 12,
                color: _getTextColor().withOpacity(0.8),
              ),
            ),
          ],
        ),
      );

  Color _getBackgroundColor() {
    if (isLoading) return AppColors.warning.withOpacity(0.1);
    return isConnected
        ? AppColors.success.withOpacity(0.1)
        : AppColors.error.withOpacity(0.1);
  }

  Color _getBorderColor() {
    if (isLoading) return AppColors.warning;
    return isConnected ? AppColors.success : AppColors.error;
  }

  Color _getTextColor() {
    if (isLoading) return AppColors.warning;
    return isConnected ? AppColors.success : AppColors.error;
  }

  String _getStatusTitle() {
    if (isLoading) return AppStrings.connecting;
    return isConnected ? AppStrings.connected : AppStrings.disconnected;
  }

  String _getStatusDescription() {
    if (isLoading) return AppStrings.connectingToServer;
    return isConnected
        ? AppStrings.serverAvailable
        : AppStrings.serverUnavailable;
  }
}

class MiniConnectionStatus extends StatelessWidget {
  const MiniConnectionStatus({
    required this.isConnected,
    super.key,
    this.isLoading = false,
    this.onTap,
  });
  final bool isConnected;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _getBorderColor(),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    valueColor: AlwaysStoppedAnimation<Color>(_getTextColor()),
                  ),
                )
              else
                Icon(
                  isConnected ? Icons.wifi : Icons.wifi_off,
                  size: 12,
                  color: _getTextColor(),
                ),
              const SizedBox(width: 6),
              Text(
                _getStatusText(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _getTextColor(),
                ),
              ),
            ],
          ),
        ),
      );

  Color _getBackgroundColor() {
    if (isLoading) return AppColors.warning.withOpacity(0.1);
    return isConnected
        ? AppColors.success.withOpacity(0.1)
        : AppColors.error.withOpacity(0.1);
  }

  Color _getBorderColor() {
    if (isLoading) return AppColors.warning;
    return isConnected ? AppColors.success : AppColors.error;
  }

  Color _getTextColor() {
    if (isLoading) return AppColors.warning;
    return isConnected ? AppColors.success : AppColors.error;
  }

  String _getStatusText() {
    if (isLoading) return 'Conectando';
    return isConnected ? 'Online' : 'Offline';
  }
}

class ConnectionIndicator extends StatelessWidget {
  const ConnectionIndicator({
    required this.isConnected,
    super.key,
    this.isLoading = false,
    this.size = 12,
  });
  final bool isConnected;
  final bool isLoading;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _getColor(),
          border: Border.all(
            color: Colors.white,
            width: size * 0.1,
          ),
          boxShadow: [
            BoxShadow(
              color: _getColor().withOpacity(0.3),
              blurRadius: size * 0.3,
              spreadRadius: size * 0.1,
            ),
          ],
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  width: size * 0.6,
                  height: size * 0.6,
                  child: CircularProgressIndicator(
                    strokeWidth: size * 0.1,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              )
            : null,
      );

  Color _getColor() {
    if (isLoading) return AppColors.warning;
    return isConnected ? AppColors.success : AppColors.error;
  }
}
