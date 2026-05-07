import 'package:flutter/material.dart';
import 'package:split_spend/src/theme/theme.dart';

class ExpenseReceiptCard extends StatelessWidget {
  const ExpenseReceiptCard({
    super.key,
    required this.receiptUrl,
  });

  final String receiptUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Attached Receipt',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppPalette.neutral900,
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () async {
            await showDialog<void>(
              context: context,
              builder: (ctx) => Dialog(
                insetPadding: const EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: InteractiveViewer(
                    maxScale: 4,
                    child: Image.network(receiptUrl, fit: BoxFit.contain),
                  ),
                ),
              ),
            );
          },
          child: Container(
            height: 260,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppPalette.neutral200),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              receiptUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  color: AppPalette.neutral400,
                  size: 34,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
