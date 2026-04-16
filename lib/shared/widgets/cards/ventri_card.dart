import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class VentriCard extends StatefulWidget {
  const VentriCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.margin,
    this.onTap,
    this.highlight = false,
  });

  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final bool highlight;

  @override
  State<VentriCard> createState() => _VentriCardState();
}

class _VentriCardState extends State<VentriCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final content = AnimatedScale(
      scale: _pressed ? 0.985 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Container(
        padding: widget.padding,
        margin: widget.margin,
        decoration: BoxDecoration(
          color: widget.highlight ? AppColors.primaryBg : AppColors.surface,
          borderRadius: BorderRadius.circular(AppColors.radiusLg),
          border: Border.all(
            color: widget.highlight ? AppColors.primary : AppColors.borderLight,
          ),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: widget.child,
      ),
    );

    if (widget.onTap == null) {
      return content;
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppColors.radiusLg),
        onTap: widget.onTap,
        child: content,
      ),
    );
  }
}
