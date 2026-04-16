import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/jamaah_member.dart';

class PrayerRequestFormPage extends StatefulWidget {
  const PrayerRequestFormPage({super.key, this.prayerRequest});

  final PrayerRequest? prayerRequest;

  @override
  State<PrayerRequestFormPage> createState() => _PrayerRequestFormPageState();
}

class _PrayerRequestFormPageState extends State<PrayerRequestFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _relationController;
  bool _isDeceased = false;
  bool _saving = false;

  bool get isEdit => widget.prayerRequest != null;

  @override
  void initState() {
    super.initState();
    final pr = widget.prayerRequest;
    _nameController = TextEditingController(text: pr?.name ?? '');
    _relationController = TextEditingController(text: pr?.relation ?? '');
    _isDeceased = pr?.isDeceased ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _relationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Keluarga' : 'Tambah Keluarga')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            const Text(
              'Nama',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Nama anggota keluarga',
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
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            const Text(
              'Hubungan Keluarga (Opsional)',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _relationController,
              decoration: InputDecoration(
                hintText: 'Contoh: Ayah, Ibu, Kakak',
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
            ),
            const SizedBox(height: 12),
            const Text(
              'Status',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Expanded(
                  child: _StatusOption(
                    label: ' masih hidup',
                    icon: Icons.favorite_rounded,
                    selected: !_isDeceased,
                    color: AppColors.primary,
                    onTap: () => setState(() => _isDeceased = false),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatusOption(
                    label: 'Almarhum',
                    icon: Icons.brightness_7_rounded,
                    selected: _isDeceased,
                    color: AppColors.secondary,
                    onTap: () => setState(() => _isDeceased = true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppColors.radiusMd),
                ),
              ),
              onPressed: _saving ? null : _save,
              child: Text(
                _saving
                    ? 'Menyimpan...'
                    : isEdit
                    ? 'Simpan'
                    : 'Tambah',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
    });

    final prayerRequest = PrayerRequest(
      id: widget.prayerRequest?.id,
      jamaahId: widget.prayerRequest?.jamaahId,
      name: _nameController.text.trim(),
      relation: _relationController.text.trim().isEmpty
          ? null
          : _relationController.text.trim(),
      isDeceased: _isDeceased,
      createdAt: widget.prayerRequest?.createdAt ?? DateTime.now(),
    );

    if (!mounted) return;
    Navigator.of(context).pop(prayerRequest);
  }
}

class _StatusOption extends StatelessWidget {
  const _StatusOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
