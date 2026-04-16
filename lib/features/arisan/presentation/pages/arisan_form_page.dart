import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/inputs/search_dropdown.dart';
import '../../../agenda/data/agenda.dart';
import '../../../agenda/data/agenda_local_database.dart';
import '../../../jamaah/data/jamaah_member.dart';
import '../../data/arisan.dart';
import '../../data/arisan_local_database.dart';

class ArisanFormPage extends StatefulWidget {
  const ArisanFormPage({super.key, this.arisan, required this.members});

  final Arisan? arisan;
  final List<JamaahMember> members;

  @override
  State<ArisanFormPage> createState() => _ArisanFormPageState();
}

class _ArisanFormPageState extends State<ArisanFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final TextEditingController _totalRoundsController;
  late final TextEditingController _descriptionController;
  Agenda? _selectedAgenda;
  List<Agenda> _agendas = [];
  bool _saving = false;
  bool _loadingAgendas = true;

  bool get isEdit => widget.arisan != null;

  @override
  void initState() {
    super.initState();
    final arisan = widget.arisan;
    _nameController = TextEditingController(text: arisan?.name ?? '');
    _amountController = TextEditingController(
      text: arisan != null ? arisan.amount.toString() : '',
    );
    _totalRoundsController = TextEditingController(
      text: arisan != null ? arisan.totalRounds.toString() : '12',
    );
    _descriptionController = TextEditingController(
      text: arisan?.description ?? '',
    );
    _loadAgendas();
  }

  Future<void> _loadAgendas() async {
    final agendas = await AgendaLocalDatabase.instance.getAllAgendas();
    if (!mounted) return;
    setState(() {
      _agendas = agendas;
      _loadingAgendas = false;
      if (widget.arisan?.agendaId != null) {
        _selectedAgenda = agendas.cast<Agenda?>().firstWhere(
          (a) => a?.id == widget.arisan?.agendaId,
          orElse: () => null,
        );
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _totalRoundsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Arisan' : 'Tambah Arisan'),
        actions: isEdit
            ? [
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _confirmDelete,
                ),
              ]
            : null,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            _FieldLabel('Nama Arisan'),
            _AppTextField(
              controller: _nameController,
              hint: 'Contoh: Arisan RT 05',
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _FieldLabel('Jumlah Iuran per Putaran'),
            _AppTextField(
              controller: _amountController,
              hint: 'Contoh: 150000',
              keyboardType: TextInputType.number,
              validator: _validateAmount,
            ),
            const SizedBox(height: 12),
            _FieldLabel('Jumlah Putaran'),
            _AppTextField(
              controller: _totalRoundsController,
              hint: 'Contoh: 12',
              keyboardType: TextInputType.number,
              validator: _validateRounds,
            ),
            const SizedBox(height: 12),
            _FieldLabel('Agenda (Opsional)'),
            _loadingAgendas
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : SearchDropdown<Agenda>(
                    value: _selectedAgenda,
                    items: _agendas,
                    hint: 'Pilih agenda terkait',
                    displayText: (a) => '${a.title} - ${a.dateFormatted}',
                    onChanged: (value) {
                      setState(() {
                        _selectedAgenda = value;
                      });
                    },
                  ),
            const SizedBox(height: 12),
            _FieldLabel('Deskripsi (Opsional)'),
            _AppTextField(
              controller: _descriptionController,
              hint: 'Deskripsi arisan...',
              maxLines: 3,
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
                    : 'Tambah Arisan',
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

  String? _validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Wajib diisi';
    }
    final amount = int.tryParse(value.trim());
    if (amount == null || amount <= 0) {
      return 'Masukkan jumlah yang valid';
    }
    return null;
  }

  String? _validateRounds(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Wajib diisi';
    }
    final rounds = int.tryParse(value.trim());
    if (rounds == null || rounds <= 0) {
      return 'Masukkan jumlah putaran yang valid';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
    });

    final arisan = Arisan(
      id: widget.arisan?.id,
      name: _nameController.text.trim(),
      amount: int.parse(_amountController.text.trim()),
      currentRound: widget.arisan?.currentRound ?? 0,
      totalRounds: int.parse(_totalRoundsController.text.trim()),
      agendaId: _selectedAgenda?.id,
      agendaTitle: _selectedAgenda?.title,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      createdAt: widget.arisan?.createdAt ?? DateTime.now(),
    );

    if (isEdit) {
      await ArisanLocalDatabase.instance.updateArisan(arisan);
      if (!mounted) return;
      Navigator.of(context).pop(arisan);
      return;
    }

    final id = await ArisanLocalDatabase.instance.insertArisan(arisan);
    if (!mounted) return;
    Navigator.of(context).pop(arisan.copyWith(id: id));
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusXl),
        ),
        title: const Text('Hapus Arisan'),
        content: const Text('Apakah Anda yakin ingin menghapus arisan ini?'),
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

    if (confirmed == true && widget.arisan?.id != null) {
      await ArisanLocalDatabase.instance.deleteArisan(widget.arisan!.id!);
      if (!mounted) return;
      Navigator.of(context).pop();
    }
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
    this.validator,
    this.maxLines = 1,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hint;
  final String? Function(String?)? validator;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
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
