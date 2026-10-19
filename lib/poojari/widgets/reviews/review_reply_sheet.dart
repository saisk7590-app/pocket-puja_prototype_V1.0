import 'package:flutter/material.dart';
import 'package:pocket_puja/core/models/review.dart';
import 'package:pocket_puja/core/services/poojari_controller.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/core/widgets/glass.dart';

/// Bottom sheet dialog for composing or editing a Poojari's single response to a devotee review.
/// Reuses the bottom-sheet pattern established in Block 11.
class ReviewReplySheet extends StatefulWidget {
  final Review review;
  final ValueChanged<String> onSubmit;

  const ReviewReplySheet({
    super.key,
    required this.review,
    required this.onSubmit,
  });

  static Future<void> show(
    BuildContext context, {
    required Review review,
    required PoojariController controller,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => ReviewReplySheet(
        review: review,
        onSubmit: (text) => controller.replyToReview(review.id, text),
      ),
    );
  }

  @override
  State<ReviewReplySheet> createState() => _ReviewReplySheetState();
}

class _ReviewReplySheetState extends State<ReviewReplySheet> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.review.poojariReply ?? '');
    _textController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  bool get _canSubmit => _textController.text.trim().isNotEmpty;

  void _handleSubmit() {
    if (!_canSubmit) return;
    widget.onSubmit(_textController.text.trim());
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.review.hasReply
              ? 'Your reply to ${widget.review.customerFirstName} has been updated.'
              : 'Your reply has been sent to ${widget.review.customerFirstName}.',
        ),
        backgroundColor: const Color(0xFF1E1C16),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isEditing = widget.review.hasReply;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: Colors.white12, width: 1),
          left: BorderSide(color: Colors.white12, width: 1),
          right: BorderSide(color: Colors.white12, width: 1),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        bottomInset + MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.reply_rounded, color: AppColors.primary, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    isEditing ? 'Edit Reply' : 'Reply to ${widget.review.customerFirstName}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white60, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Responding to ${widget.review.stars}★ review for ${widget.review.poojaName}',
            style: const TextStyle(color: Colors.white60, fontSize: 13),
          ),
          const SizedBox(height: 16),

          // Multiline text input
          TextField(
            controller: _textController,
            maxLines: 4,
            maxLength: 300,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Write a courteous Vedic response (e.g. Subhamastu, Dhanyavadagalu)...',
              hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Colors.white12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              counterStyle: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ),
          const SizedBox(height: 20),

          // Buttons: Cancel & Submit
          Row(
            children: [
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: PrimaryButton(
                  label: isEditing ? 'Update Reply' : 'Send Reply',
                  enabled: _canSubmit,
                  onTap: _handleSubmit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
