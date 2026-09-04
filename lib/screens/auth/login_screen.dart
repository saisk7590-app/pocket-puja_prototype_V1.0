import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/glass.dart';

class LoginScreen extends StatefulWidget {
  final Function(String mobile) onSendOTP;
  final bool isLoading;
  final String? error;
  const LoginScreen({super.key, required this.onSendOTP, this.isLoading = false, this.error});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _mobileController = TextEditingController();
  bool _teluguSelected = true;

  @override
  void dispose() { _mobileController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.auth),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('🪔 Pocket Puja', style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: AppColors.primary, fontSize: 34, shadows: AppTheme.goldGlow)),
                const SizedBox(height: 8),
                Text('Digital sanctuary for your daily rituals', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70)),
                const SizedBox(height: 32),
                GlassPanel(
                  padding: const EdgeInsets.all(24),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Text('SELECT YOUR LANGUAGE', textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white60, letterSpacing: 1.2)),
                    const SizedBox(height: 14),
                    Row(children: [
                      Expanded(child: _LangChip(label: 'తెలుగు', sub: 'TELUGU', selected: _teluguSelected, onTap: () => setState(() => _teluguSelected = true))),
                      const SizedBox(width: 12),
                      Expanded(child: _LangChip(label: 'English', sub: 'ENGLISH', selected: !_teluguSelected, onTap: () => setState(() => _teluguSelected = false))),
                    ]),
                    const SizedBox(height: 28),
                    Text('SIGN IN WITH MOBILE', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white60, letterSpacing: 1.2)),
                    const SizedBox(height: 12),
                    Row(children: [
                      Text('+91', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 12),
                      Expanded(child: TextField(
                        controller: _mobileController, keyboardType: TextInputType.phone, maxLength: 10,
                        style: const TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 1),
                        decoration: const InputDecoration(hintText: 'Enter Mobile Number', hintStyle: TextStyle(color: Colors.white38), counterText: '',
                          border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary))),
                      )),
                    ]),
                    if (widget.error != null) ...[const SizedBox(height: 12), Text(widget.error!, style: const TextStyle(color: Color(0xFFFFB4AB), fontSize: 13))],
                    const SizedBox(height: 28),
                    PrimaryButton(
                      label: 'CONTINUE', icon: Icons.arrow_forward, isLoading: widget.isLoading,
                      onTap: () { final mobile = '+91${_mobileController.text.trim()}'; if (_mobileController.text.trim().length == 10) widget.onSendOTP(mobile); },
                    ),
                  ]),
                ),
                const SizedBox(height: 24),
                Text('By proceeding, you agree to our Terms of Service & Privacy Policy', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white38)),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  final String label, sub;
  final bool selected;
  final VoidCallback onTap;
  const _LangChip({required this.label, required this.sub, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: selected ? AppColors.primary.withValues(alpha: 0.18) : Colors.white.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(16), border: Border.all(color: selected ? AppColors.primary : Colors.white24)),
        child: Column(children: [
          Text(label, style: TextStyle(color: selected ? AppColors.primary : Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(sub, style: TextStyle(color: selected ? AppColors.primary.withValues(alpha: 0.8) : Colors.white54, fontSize: 10, letterSpacing: 1)),
        ]),
      ),
    );
  }
}
