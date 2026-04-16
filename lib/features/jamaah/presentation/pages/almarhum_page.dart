import 'package:flutter/material.dart';

import '../../../../core/constants/mock_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/cards/ventri_card.dart';

class AlmarhumPage extends StatefulWidget {
  const AlmarhumPage({super.key});

  @override
  State<AlmarhumPage> createState() => _AlmarhumPageState();
}

class _AlmarhumPageState extends State<AlmarhumPage> {
  String selectedSection = 'Bapak';

  @override
  Widget build(BuildContext context) {
    final items = selectedSection == 'Bapak' ? almarhumBapak : almarhumIbu;
    final color = selectedSection == 'Bapak'
        ? const Color(0xFF374151)
        : const Color(0xFFBE185D);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Almarhum'),
        actions: const <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.secondary,
              child: Icon(Icons.add, size: 18, color: Colors.white),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: <Widget>[
          VentriCard(
            child: Row(
              children: <Widget>[
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryBg,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Text('👤', style: TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Bapak H. Ahmad Wijaya',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Jl. Peta No. 45, Purbalingga',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'No. HP: 0812-3456-7890',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 6),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.dangerLight,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          child: Text(
                            'Status: Jamaah Aktif',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.danger,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              _SectionChip(
                label: 'Bapak',
                active: selectedSection == 'Bapak',
                onTap: () => setState(() => selectedSection = 'Bapak'),
              ),
              const SizedBox(width: 8),
              _SectionChip(
                label: 'Ibu',
                active: selectedSection == 'Ibu',
                onTap: () => setState(() => selectedSection = 'Ibu'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: VentriCard(
              key: ValueKey<String>(selectedSection),
              child: Column(
                children: items
                    .map(
                      (AlmarhumItem item) => Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          border: item == items.last
                              ? null
                              : const Border(
                                  bottom: BorderSide(
                                    color: AppColors.borderLight,
                                  ),
                                ),
                        ),
                        child: Row(
                          children: <Widget>[
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: color,
                              child: Text(
                                item.initials,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    item.lineage,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              item.date,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionChip extends StatelessWidget {
  const _SectionChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? AppColors.secondaryBg : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: active
              ? Border.all(color: AppColors.secondary)
              : Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: active ? AppColors.secondary : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
