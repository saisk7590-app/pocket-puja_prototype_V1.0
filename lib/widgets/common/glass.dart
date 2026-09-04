import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// The frosted "glass-panel" surface used everywhere in the Liquid Glass
/// design system: translucent white fill + backdrop blur + hairline
/// border + soft shadow.
class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color tint;
  final Color borderColor;
  final VoidCallback? onTap;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 24,
    this.tint = Colors.white,
    this.borderColor = Colors.white,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    Widget content = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: tint.withValues(alpha: tint == Colors.white ? 0.08 : 0.12),
            borderRadius: radius,
            border: Border.all(color: borderColor.withValues(alpha: 0.18)),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 32, offset: Offset(0, 8)),
            ],
          ),
          child: child,
        ),
      ),
    );
    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(borderRadius: radius, onTap: onTap, child: content),
      );
    }
    return content;
  }
}

/// Thin gold-tinted glass variant, used for highlighted / accent panels.
class GlassPanelGold extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final VoidCallback? onTap;

  const GlassPanelGold({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 24,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    Widget content = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.06),
            borderRadius: radius,
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
          ),
          child: child,
        ),
      ),
    );
    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(borderRadius: radius, onTap: onTap, child: content),
      );
    }
    return content;
  }
}

/// Amber "attention" glass variant — reused everywhere a warning state
/// needs the exact same visual weight (Audio usage banner, Profile
/// subscription row, etc).
class GlassPanelAmber extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final VoidCallback? onTap;

  const GlassPanelAmber({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 18,
    this.onTap,
  });

  static const amber = Color(0xFFFFB84D);

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    Widget content = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: amber.withValues(alpha: 0.1),
            borderRadius: radius,
            border: Border.all(color: amber.withValues(alpha: 0.35)),
          ),
          child: child,
        ),
      ),
    );
    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(borderRadius: radius, onTap: onTap, child: content),
      );
    }
    return content;
  }
}

/// Fixed glass top app bar.
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onProfile;
  final Widget? trailing;
  final bool showBack;

  const GlassAppBar({
    super.key,
    this.title = 'Pocket Puja',
    this.onBack,
    this.onProfile,
    this.trailing,
    this.showBack = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: const BoxDecoration(
            color: Color(0x99141311),
            border: Border(bottom: BorderSide(color: Colors.white12)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 44,
                child: showBack
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                        color: AppColors.primary,
                        onPressed: onBack ?? () => Navigator.maybePop(context),
                      )
                    : null,
              ),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.primary,
                        shadows: AppTheme.goldGlow,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              SizedBox(
                width: 44,
                child: trailing ??
                    IconButton(
                      icon: const Icon(Icons.account_circle_outlined),
                      color: AppColors.primary,
                      onPressed: onProfile,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Floating pill-shaped glass bottom navigation bar.
class GlassBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<IconData> icons;

  const GlassBottomNav({super.key, required this.currentIndex, required this.onTap, required this.icons});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.15), blurRadius: 32)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(icons.length, (i) {
                final selected = i == currentIndex;
                return GestureDetector(
                  onTap: () => onTap(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      icons[i],
                      color: selected ? AppColors.primary : AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                      size: selected ? 26 : 24,
                      shadows: selected ? [Shadow(color: AppColors.primary.withValues(alpha: 0.8), blurRadius: 8)] : null,
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

/// Scaffold shell shared by every screen.
class GlassScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Gradient gradient;
  final Widget? bottomNav;
  final Widget? floatingActionButton;
  final bool showAppBar;
  final VoidCallback? onBack;
  final Widget? trailing;
  final bool showBack;

  const GlassScaffold({
    super.key,
    this.title = 'Pocket Puja',
    required this.body,
    this.gradient = AppGradients.sacred,
    this.bottomNav,
    this.floatingActionButton,
    this.showAppBar = true,
    this.onBack,
    this.trailing,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      appBar: showAppBar ? GlassAppBar(title: title, onBack: onBack, trailing: trailing, showBack: showBack) : null,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNav,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: gradient),
        child: SafeArea(top: false, child: body),
      ),
    );
  }
}

/// Primary gold gradient button — the one CTA style used across every
/// module (Login, Checkout, Booking confirm, Subscription upgrade...).
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool enabled;
  final IconData? icon;
  final double height;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.enabled = true,
    this.icon,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    final active = enabled && !isLoading;
    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: active ? AppGradients.goldButton : null,
          color: active ? null : AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: active ? null : Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
          boxShadow: active ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 6))] : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: active ? onTap : null,
            child: Center(
              child: isLoading
                  ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: active ? AppColors.onPrimary : AppColors.primary.withValues(alpha: 0.5)))
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(label, style: TextStyle(color: active ? AppColors.onPrimary : AppColors.primary.withValues(alpha: 0.4), fontWeight: FontWeight.w800, fontSize: 15)),
                        if (icon != null) ...[const SizedBox(width: 8), Icon(icon, color: active ? AppColors.onPrimary : AppColors.primary.withValues(alpha: 0.4), size: 18)],
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Ghost/outline button — used for Cancel and other non-destructive
/// secondary actions. Never red (red is reserved for destructive-only).
class GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final double height;

  const GhostButton({super.key, required this.label, this.onTap, this.height = 52});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white70,
          side: const BorderSide(color: Colors.white24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

/// Destructive button — reserved ONLY for actually destructive actions
/// (Sign Out, Cancel Booking, Delete Address). Red is meaningful, not
/// reused for routine "cancel editing."
class DestructiveButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;

  const DestructiveButton({super.key, required this.label, this.onTap, this.icon});

  static const _red = Color(0xFFE8A0A0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: _red.withValues(alpha: 0.4))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[Icon(icon, color: _red, size: 18), const SizedBox(width: 10)],
            Text(label, style: const TextStyle(color: _red, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

/// A settings-style tappable row: icon + title + subtitle + chevron.
/// Reused across Profile, Preferences, Support, etc.
class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const SettingsTile({super.key, required this.icon, required this.title, required this.subtitle, this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassPanel(
        padding: const EdgeInsets.all(14),
        borderRadius: 18,
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                  Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                ],
              ),
            ),
            trailing ?? const Icon(Icons.chevron_right, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}

/// Section header used across list screens ("PAYMENT METHOD", "UPCOMING
/// FESTIVALS", etc).
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.labelLarge?.copyWith(letterSpacing: 1.2));
  }
}
