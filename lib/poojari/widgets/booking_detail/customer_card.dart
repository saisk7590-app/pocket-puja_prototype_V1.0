import 'package:flutter/material.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/core/widgets/glass.dart';
import 'package:pocket_puja/core/widgets/network_image_placeholder.dart';

/// Customer Card for Poojari's View of a Booking (BLOCK 8).
/// Built by copying PanditCard's exact structure and swapping data fields:
/// - Customer Name
/// - Photo / avatar
/// - Service address (full address for confirmed bookings)
/// - Phone number & Gotram
/// - Call & Message action buttons
class CustomerCard extends StatelessWidget {
  final String customerName;
  final String fullAddress;
  final String phone;
  final String gotram;
  final String badgeLabel;
  final String avatarSeed;
  final bool showActions;
  final VoidCallback? onCall;
  final VoidCallback? onMessage;

  const CustomerCard({
    super.key,
    required this.customerName,
    required this.fullAddress,
    required this.phone,
    this.gotram = 'Kashyapa',
    this.badgeLabel = 'Devotee / Host',
    this.avatarSeed = 'devotee1',
    this.showActions = true,
    this.onCall,
    this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: NetworkImageWithPlaceholder(
                  imageUrl: 'https://picsum.photos/seed/$avatarSeed/200',
                  width: 64,
                  height: 64,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        badgeLabel,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      customerName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.people_outline, color: AppColors.primary, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Gotram: $gotram',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_outlined, color: AppColors.primaryFixed, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            fullAddress,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white60, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (showActions) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ActionBtn(
                    icon: Icons.call,
                    label: 'Call ($phone)',
                    onTap: onCall ??
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Calling $customerName at $phone...'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionBtn(
                    icon: Icons.message_outlined,
                    label: 'Message',
                    onTap: onMessage ??
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Messaging $customerName...'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white70, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
