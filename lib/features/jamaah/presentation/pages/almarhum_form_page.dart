import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/cards/ventri_card.dart';
import '../../data/jamaah_local_database.dart';
import '../../data/jamaah_member.dart';

class AlmarhumFormPage extends StatefulWidget {
  const AlmarhumFormPage({super.key, required this.member});

  final JamaahMember member;

  @override
  State<AlmarhumFormPage> createState() => _AlmarhumFormPageState();
}

class _AlmarhumFormPageState extends State<AlmarhumFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _lineageController;
  late final TextEditingController _dayController;
  late final TextEditingController _monthController;
  late final TextEditingController _yearController;
  String _gender = 'L';

  @override
  void initState() {
    super.initState();
    _lineageController = TextEditingController();
    final now = DateTime.now();
    _dayController = TextEditingController(text: now.day.toString());
    _monthController = TextEditingController(text: now.month.toString());
    _yearController = TextEditingController(text: now.year.toString());
  }

  @override
  void dispose() {
    _lineageController.dispose();
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tandai Almarhum')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            VentriCard(
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.secondaryBg,
                    child: Text(
                      widget.member.initials,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.member.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          widget.member.detail,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Jenis Kelamin',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Expanded(
                  child: _GenderOption(
                    label: 'Bapak',
                    selected: _gender == 'L',
                    onTap: () => setState(() => _gender = 'L'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _GenderOption(
                    label: 'Ibu',
                    selected: _gender == 'P',
                    onTap: () => setState(() => _gender = 'P'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Garis Keturunan (Opsional)',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _lineageController,
              decoration: InputDecoration(
                hintText: 'Contoh: Bin H. Salim',
                filled: true,
                fillColor: AppColors.surface,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppColors.radiusMd),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppColors.radiusMd),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tanggal Wafat',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: _dayController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      hintText: 'Tgl',
                      filled: true,
                      fillColor: AppColors.surface,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppColors.radiusMd),
                        borderSide: const BorderSide(
                          color: AppColors.borderLight,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppColors.radiusMd),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                    style: const TextStyle(fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _monthController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      hintText: 'Bln',
                      filled: true,
                      fillColor: AppColors.surface,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppColors.radiusMd),
                        borderSide: const BorderSide(
                          color: AppColors.borderLight,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppColors.radiusMd),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                    style: const TextStyle(fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _yearController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      hintText: 'Thn',
                      filled: true,
                      fillColor: AppColors.surface,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppColors.radiusMd),
                        borderSide: const BorderSide(
                          color: AppColors.borderLight,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppColors.radiusMd),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                    style: const TextStyle(fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.danger,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppColors.radiusMd),
                ),
              ),
              onPressed: _save,
              child: const Text('Tandai sebagai Almarhum'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final day = int.tryParse(_dayController.text.trim()) ?? 1;
    final month = int.tryParse(_monthController.text.trim()) ?? 1;
    final year =
        int.tryParse(_yearController.text.trim()) ?? DateTime.now().year;

    if (day < 1 ||
        day > 31 ||
        month < 1 ||
        month > 12 ||
        year < 1900 ||
        year > DateTime.now().year) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan tanggal yang valid'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final almarhum = Almarhum(
      jamaahId: widget.member.id!,
      jamaahName: widget.member.name,
      lineage: _lineageController.text.trim().isEmpty
          ? null
          : _lineageController.text.trim(),
      deathDate: DateTime(year, month, day),
      gender: _gender,
      createdAt: DateTime.now(),
    );

    await JamaahLocalDatabase.instance.insertAlmarhum(almarhum);
    if (!mounted) return;
    Navigator.of(context).pop(almarhum);
  }
}

class _GenderOption extends StatelessWidget {
  const _GenderOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = label == 'Bapak'
        ? const Color(0xFF374151)
        : const Color(0xFFBE185D);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppColors.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color.withAlpha(25) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppColors.radiusMd),
          border: Border.all(
            color: selected ? color : AppColors.borderLight,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              size: 18,
              color: selected ? color : AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? color : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
