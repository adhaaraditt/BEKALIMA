import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Pop-up ulasan yang tampil di tengah layar.
class ReviewDialog extends StatefulWidget {
  const ReviewDialog({super.key});

  /// Mengembalikan rating & komentar, atau null bila dialog dibatalkan.
  static Future<({double rating, String comment})?> show(
    BuildContext context,
  ) {
    return showDialog<({double rating, String comment})>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const ReviewDialog(),
    );
  }

  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  final TextEditingController _commentController = TextEditingController();
  double _rating = 5.0;
  String? _error;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submit() {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) {
      setState(() => _error = 'Tuliskan ulasan Anda terlebih dahulu.');
      return;
    }
    Navigator.pop(context, (rating: _rating, comment: comment));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Beri Ulasan & Rating',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Bagaimana cita rasa dan layanan katering BEKALIMA?',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starIndex = index + 1;
                  return IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      starIndex <= _rating
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: AppColors.sunshine,
                      size: 34,
                    ),
                    onPressed: () => setState(() => _rating = starIndex.toDouble()),
                  );
                }),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _commentController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
                decoration: InputDecoration(
                  hintText:
                      'Tuliskan ulasan Anda mengenai rasa lauk, ketepatan waktu, dan kemasan...',
                  errorText: _error,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Kirim Ulasan'),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.onSurfaceVariant,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
