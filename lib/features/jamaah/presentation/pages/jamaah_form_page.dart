import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/jamaah_local_database.dart';
import '../../data/jamaah_member.dart';

class JamaahFormPage extends StatefulWidget {
  const JamaahFormPage({super.key, this.member});

  final JamaahMember? member;

  @override
  State<JamaahFormPage> createState() => _JamaahFormPageState();
}

class _JamaahFormPageState extends State<JamaahFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _neighborhoodController;
  late final TextEditingController _roleController;
  late bool _isPresent;
  bool _saving = false;

  bool get isEdit => widget.member != null;

  @override
  void initState() {
    super.initState();
    final member = widget.member;
    _nameController = TextEditingController(text: member?.name ?? '');
    _phoneController = TextEditingController(text: member?.phone ?? '');
    _addressController = TextEditingController(text: member?.address ?? '');
    _neighborhoodController = TextEditingController(
      text: member?.neighborhood ?? '',
    );
    _roleController = TextEditingController(text: member?.role ?? '');
    _isPresent = member?.isPresent ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _neighborhoodController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Jamaah' : 'Tambah Jamaah')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            _FieldLabel('Nama Lengkap'),
            _AppTextField(
              controller: _nameController,
              hint: 'Masukkan nama',
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _FieldLabel('No. HP'),
            _AppTextField(
              controller: _phoneController,
              hint: '0812xxxxxxx',
              keyboardType: TextInputType.phone,
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _FieldLabel('Alamat'),
            _AppTextField(
              controller: _addressController,
              hint: 'Alamat lengkap',
              maxLines: 2,
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _FieldLabel('Wilayah / RT'),
            _AppTextField(
              controller: _neighborhoodController,
              hint: 'Contoh: RT 05',
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _FieldLabel('Peran'),
            _AppTextField(
              controller: _roleController,
              hint: 'Contoh: Ketua Jamaah',
              validator: _requiredValidator,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppColors.radiusMd),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: <Widget>[
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Status Kehadiran',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Tandai hadir atau izin',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: _isPresent,
                    activeThumbColor: AppColors.primary,
                    onChanged: (bool value) {
                      setState(() {
                        _isPresent = value;
                      });
                    },
                  ),
                ],
              ),
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
                    ? 'Simpan Perubahan'
                    : 'Tambah Jamaah',
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Wajib diisi';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
    });

    final baseMember = JamaahMember(
      id: widget.member?.id,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      neighborhood: _neighborhoodController.text.trim(),
      role: _roleController.text.trim(),
      isPresent: _isPresent,
      createdAt: widget.member?.createdAt ?? DateTime.now(),
    );

    if (isEdit) {
      await JamaahLocalDatabase.instance.updateMember(baseMember);
      if (!mounted) return;
      Navigator.of(context).pop(baseMember);
      return;
    }

    final id = await JamaahLocalDatabase.instance.insertMember(baseMember);
    if (!mounted) return;
    Navigator.of(context).pop(baseMember.copyWith(id: id));
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.text,
        ),
      ),
    );
  }
}

class _AppTextField extends StatelessWidget {
  const _AppTextField({
    required this.controller,
    required this.hint,
    required this.validator,
    this.keyboardType,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hint;
  final String? Function(String?) validator;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusMd),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusMd),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
      ),
    );
  }
}
