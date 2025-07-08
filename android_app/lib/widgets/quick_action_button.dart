import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class QuickActionButton extends StatelessWidget {

  const QuickActionButton({
    required this.icon, required this.label, required this.color, required this.onTap, super.key,
    this.isEnabled = true,
    this.badge,
    this.isLoading = false,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isEnabled;
  final String? badge;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => Material(
      elevation: isEnabled ? 4 : 2,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: isEnabled && !isLoading ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: isEnabled
                ? LinearGradient(
                    colors: [
                      color.withOpacity(0.8),
                      color,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : LinearGradient(
                    colors: [
                      Colors.grey.shade300,
                      Colors.grey.shade400,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
          ),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isLoading)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  else
                    Icon(
                      icon,
                      color: Colors.white,
                      size: 24,
                    ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              if (badge != null && !isLoading)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white),
                    ),
                    child: Text(
                      badge!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
}

class CircularActionButton extends StatelessWidget {

  const CircularActionButton({
    required this.icon, required this.label, required this.color, required this.onTap, super.key,
    this.isEnabled = true,
    this.size = 60,
    this.showLabel = true,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isEnabled;
  final double size;
  final bool showLabel;

  @override
  Widget build(BuildContext context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          elevation: isEnabled ? 6 : 2,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: isEnabled ? onTap : null,
            customBorder: const CircleBorder(),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isEnabled
                    ? LinearGradient(
                        colors: [
                          color.withOpacity(0.8),
                          color,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                    : LinearGradient(
                        colors: [
                          Colors.grey.shade300,
                          Colors.grey.shade400,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: size * 0.4,
              ),
            ),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isEnabled
                  ? AppColors.textPrimary
                  : AppColors.textDisabled,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
}

class EmergencyActionButton extends StatelessWidget {

  const EmergencyActionButton({
    required this.label, required this.onTap, super.key,
    this.isEnabled = true,
    this.isPulsing = false,
  });
  final String label;
  final VoidCallback onTap;
  final bool isEnabled;
  final bool isPulsing;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: isEnabled ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: isEnabled
                  ? const LinearGradient(
                      colors: [
                        Color(0xFFE53935),
                        Color(0xFFB71C1C),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )
                  : LinearGradient(
                      colors: [
                        Colors.grey.shade300,
                        Colors.grey.shade400,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
              border: isPulsing
                  ? Border.all(color: Colors.red.shade200, width: 3)
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.emergency,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
}

class FloatingQuickAction extends StatelessWidget {

  const FloatingQuickAction({
    required this.icon, required this.tooltip, required this.color, required this.onTap, super.key,
    this.isEnabled = true,
  });
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) => FloatingActionButton(
      onPressed: isEnabled ? onTap : null,
      backgroundColor: isEnabled ? color : Colors.grey,
      tooltip: tooltip,
      elevation: 6,
      child: Icon(
        icon,
        color: Colors.white,
        size: 28,
      ),
    );
}

