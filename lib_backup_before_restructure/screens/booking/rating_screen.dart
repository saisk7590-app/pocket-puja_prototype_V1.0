import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/glass.dart';

class RatingScreen extends StatefulWidget {
  final String bookingRef, poojaName;
  const RatingScreen({super.key, required this.bookingRef, required this.poojaName});
  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _rating = 0;
  final _reviewController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thank you for your feedback!')));
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      title: 'Rate & Review',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        children: [
          GlassPanel(
            child: Column(children: [
              Text(widget.poojaName, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text(widget.bookingRef, style: const TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 20),
              const Text('How was your experience?', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) => GestureDetector(
                onTap: () => setState(() => _rating = i + 1),
                child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: Icon(i < _rating ? Icons.star : Icons.star_border, color: AppColors.primary, size: 36)),
              ))),
              const SizedBox(height: 20),
              TextField(
                controller: _reviewController, maxLines: 4, style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Share your thoughts about the pandit and service...', hintStyle: const TextStyle(color: Colors.white38),
                  filled: true, fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(label: 'Submit Review', isLoading: _isSubmitting, enabled: _rating > 0, onTap: _submit),
            ]),
          ),
        ],
      ),
    );
  }
}
