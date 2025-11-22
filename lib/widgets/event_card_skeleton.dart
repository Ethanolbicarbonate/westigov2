import 'package:flutter/material.dart';
import 'package:westigov2/utils/constants.dart';

class EventCardSkeleton extends StatefulWidget {
  const EventCardSkeleton({super.key});

  @override
  State<EventCardSkeleton> createState() => _EventCardSkeletonState();
}

class _EventCardSkeletonState extends State<EventCardSkeleton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Placeholder
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.radiusM)),
              ),
            ),
            // Details Placeholder
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 12, width: 80, color: Colors.grey[300]), // Date
                  const SizedBox(height: 8),
                  Container(height: 20, width: double.infinity, color: Colors.grey[300]), // Title
                  const SizedBox(height: 8),
                  Container(height: 12, width: 200, color: Colors.grey[300]), // Desc
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(height: 20, width: 60, color: Colors.grey[300]),
                      const SizedBox(width: 8),
                      Container(height: 20, width: 60, color: Colors.grey[300]),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}