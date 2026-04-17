import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class AutoScrollController extends StatefulWidget {
  const AutoScrollController({
    super.key,
    required this.scrollController,
    required this.child,
    this.speed = 1.0,
  });

  final ScrollController scrollController;
  final Widget child;
  final double speed;

  @override
  State<AutoScrollController> createState() => _AutoScrollControllerState();
}

class _AutoScrollControllerState extends State<AutoScrollController> {
  Timer? _timer;
  bool _isScrolling = false;

  bool get isScrolling => _isScrolling;

  void startScrolling() {
    if (_isScrolling) return;
    setState(() => _isScrolling = true);
    _timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (!widget.scrollController.hasClients) return;
      final maxScroll = widget.scrollController.position.maxScrollExtent;
      final currentScroll = widget.scrollController.offset;
      if (currentScroll >= maxScroll) {
        stopScrolling();
        return;
      }
      widget.scrollController.jumpTo(currentScroll + widget.speed);
    });
  }

  void stopScrolling() {
    _timer?.cancel();
    _timer = null;
    if (mounted) setState(() => _isScrolling = false);
  }

  void toggleScrolling() {
    if (_isScrolling) {
      stopScrolling();
    } else {
      startScrolling();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class AutoScrollButton extends StatelessWidget {
  const AutoScrollButton({
    super.key,
    required this.isActive,
    required this.onTap,
  });

  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.danger : AppColors.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              isActive ? Icons.stop_rounded : Icons.play_arrow_rounded,
              size: 14,
              color: Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              isActive ? 'Stop' : 'Auto Scroll',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
