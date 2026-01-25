import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glass_kit/glass_kit.dart';

class ErrandCard extends StatelessWidget {
  final DocumentSnapshot errand;
  final bool showCancelButton;
  final bool showMarkAsBulkyButton;
  final bool showCompleteButton;
  final bool showReviewButton;
  final bool showReceiptButton;
  final bool showApproveButton;
  final bool showRejectButton;
  final VoidCallback? onCancel;
  final VoidCallback? onMarkAsBulky;
  final VoidCallback? onComplete;
  final VoidCallback? onReview;
  final VoidCallback? onViewReceipt;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const ErrandCard({
    super.key,
    required this.errand,
    this.showCancelButton = false,
    this.showMarkAsBulkyButton = false,
    this.showCompleteButton = false,
    this.showReviewButton = false,
    this.showReceiptButton = false,
    this.showApproveButton = false,
    this.showRejectButton = false,
    this.onCancel,
    this.onMarkAsBulky,
    this.onComplete,
    this.onReview,
    this.onViewReceipt,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final errandData = errand.data() as Map<String, dynamic>;
    final status = errandData['status'] ?? 'N/A';
    final theme = Theme.of(context);

    return GlassContainer(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      blur: 15,
      color: theme.colorScheme.surface.withAlpha(13),
      gradient: LinearGradient(
        colors: [
          theme.colorScheme.surface.withAlpha(26),
          theme.colorScheme.surface.withAlpha(13),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderGradient: LinearGradient(
        colors: [
          theme.primaryColor.withAlpha(153),
          theme.primaryColor.withAlpha(26),
          theme.colorScheme.surface.withAlpha(13),
          theme.colorScheme.surface.withAlpha(153),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: const [0.0, 0.39, 0.40, 1.0],
      ),
      borderRadius: BorderRadius.circular(16.0),
      borderWidth: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              errandData['title'] ?? 'No Title',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errandData['description'] ?? 'No Description',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(204)
              )
            ),
            const SizedBox(height: 12),
            Chip(
              label: Text('Status: $status'),
              backgroundColor: theme.primaryColor.withAlpha(51),
              labelStyle: TextStyle(color: theme.primaryColor),
            ),
            if (errandData['isBulky'] == true)
              const Chip(
                label: Text('Bulky/Heavy Item'),
                backgroundColor: Colors.orangeAccent,
                labelStyle: TextStyle(color: Colors.white),
              ),
            const SizedBox(height: 16),
            if (_shouldShowButtons(status, errandData))
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  alignment: WrapAlignment.end,
                  children: [
                    if (showCancelButton && (status == 'posted' || status == 'accepted'))
                      TextButton(onPressed: onCancel, child: const Text('Cancel')),
                    if (showMarkAsBulkyButton && errandData['isBulky'] != true)
                      TextButton(
                        onPressed: onMarkAsBulky,
                        child: const Text('Mark as Bulky'),
                      ),
                    if (showCompleteButton && status == 'accepted')
                      ElevatedButton(
                        onPressed: onComplete,
                        child: const Text('Complete'),
                      ),
                    if (showReviewButton && status == 'completed' && errandData['reviewed'] != true)
                      ElevatedButton(
                        onPressed: onReview,
                        child: const Text('Review'),
                      ),
                    if (showReceiptButton && status == 'completed')
                      ElevatedButton(
                        onPressed: onViewReceipt,
                        child: const Text('Receipt'),
                      ),
                    if (showApproveButton)
                      ElevatedButton(
                        onPressed: onApprove,
                        child: const Text('Approve'),
                      ),
                    if (showRejectButton)
                      ElevatedButton(
                        onPressed: onReject,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                        child: const Text('Reject'),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _shouldShowButtons(String status, Map<String, dynamic> errandData) {
    return (showCancelButton && (status == 'posted' || status == 'accepted')) ||
           (showMarkAsBulkyButton && errandData['isBulky'] != true) ||
           (showCompleteButton && status == 'accepted') ||
           (showReviewButton && status == 'completed' && errandData['reviewed'] != true) ||
           (showReceiptButton && status == 'completed') ||
           showApproveButton ||
           showRejectButton;
  }
}
