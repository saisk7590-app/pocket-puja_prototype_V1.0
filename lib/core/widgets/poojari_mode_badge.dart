import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';

/// Small persistent "🪔 Poojari Mode" chip with gold glass styling,
/// shown wherever the Poojari shell or poojari mode is active.
class PoojariModeBadge extends StatelessWidget {
  final bool isPoojari;
  final VoidCallback? onToggle;
  final String? customLabel;

  const PoojariModeBadge({
    super.key,
    this.isPoojari = true,
    this.onToggle,
    this.customLabel,
  });

  @override
  Widget build(BuildContext context) {
    final label = customLabel ?? (isPoojari ? 'Poojari Mode' : 'Customer Mode');

    return GestureDetector(
      onTap: onToggle,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isPoojari
                  ? AppColors.primary.withValues(alpha: 0.22)
                  : Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isPoojari
                    ? AppColors.primary.withValues(alpha: 0.8)
                    : Colors.white24,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isPoojari
                      ? AppColors.primary.withValues(alpha: 0.25)
                      : Colors.black26,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isPoojari ? '🪔' : '👤',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: isPoojari ? AppColors.primary : Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 0.8,
                  ),
                ),
                if (onToggle != null) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.swap_horiz_rounded,
                    size: 15,
                    color: isPoojari ? AppColors.primary : Colors.white70,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
