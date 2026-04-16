import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/cards/ventri_card.dart';
import '../../data/jamaah_local_database.dart';
import '../../data/jamaah_member.dart';

class AlmarhumPage extends StatefulWidget {
  const AlmarhumPage({super.key});

  @override
  State<AlmarhumPage> createState() => _AlmarhumPageState();
}

class _AlmarhumPageState extends State<AlmarhumPage> {
  String selectedSection = 'L';
  List<Almarhum> _almarhumList = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAlmarhum();
  }

  Future<void> _loadAlmarhum() async {
    setState(() {
      _loading = true;
    });
    final almarhum = await JamaahLocalDatabase.instance.getAlmarhumByGender(
      selectedSection,
    );
    if (!mounted) return;
    setState(() {
      _almarhumList = almarhum;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = selectedSection == 'L'
        ? const Color(0xFF374151)
        : const Color(0xFFBE185D);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Almarhum')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: <Widget>[
          Row(
            children: <Widget>[
              _SectionChip(
                label: 'Bapak',
                active: selectedSection == 'L',
                onTap: () {
                  setState(() => selectedSection = 'L');
                  _loadAlmarhum();
                },
              ),
              const SizedBox(width: 8),
              _SectionChip(
                label: 'Ibu',
                active: selectedSection == 'P',
                onTap: () {
                  setState(() => selectedSection = 'P');
                  _loadAlmarhum();
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              ),
            )
          else if (_almarhumList.isEmpty)
            VentriCard(
              child: Center(
                child: Column(
                  children: <Widget>[
                    const Icon(
                      Icons.person_off_rounded,
                      size: 40,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      selectedSection == 'L'
                          ? 'Belum ada almarhum Bapak'
                          : 'Belum ada almarhum Ibu',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tandai anggota sebagai almarhum dari detail Jamaah',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            VentriCard(
              child: Column(
                children: _almarhumList.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      border: index == _almarhumList.length - 1
                          ? null
                          : const Border(
                              bottom: BorderSide(color: AppColors.borderLight),
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
                                item.jamaahName,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (item.lineage != null)
                                Text(
                                  item.lineage!,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              item.deathDateFormatted,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 4),
                            InkWell(
                              onTap: () => _confirmDelete(item),
                              child: const Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: AppColors.danger,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(Almarhum almarhum) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusXl),
        ),
        title: const Text('Hapus Almarhum'),
        content: Text('Hapus ${almarhum.jamaahName} dari data almarhum?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && almarhum.id != null) {
      await JamaahLocalDatabase.instance.deleteAlmarhum(almarhum.id!);
      _loadAlmarhum();
    }
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
