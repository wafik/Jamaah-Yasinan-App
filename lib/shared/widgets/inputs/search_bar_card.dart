import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class SearchBarCard extends StatelessWidget {
  const SearchBarCard({
    super.key,
    required this.placeholder,
    this.onTap,
    this.trailing,
    this.controller,
    this.onChanged,
  });

  final String placeholder;
  final VoidCallback? onTap;
  final Widget? trailing;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppColors.radiusMd),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppColors.radiusMd),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: <Widget>[
            const Icon(Icons.search, size: 16, color: AppColors.textMuted),
            const SizedBox(width: 10),
            Expanded(
              child: controller == null && onChanged == null
                  ? Text(
                      placeholder,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    )
                  : TextField(
                      controller: controller,
                      onChanged: onChanged,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: placeholder,
                        hintStyle: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.text,
                      ),
                    ),
            ),
            trailing ?? const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
