import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/inputs/multi_select_dropdown.dart';
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
  List<JamaahMember> _selectedMembers = [];
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
    if (isEdit) {
      _loadExistingParticipants();
    }
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

  Future<void> _loadExistingParticipants() async {
    if (widget.arisan?.id == null) return;
    final participants = await ArisanLocalDatabase.instance.getParticipants(
      widget.arisan!.id!,
    );
    if (!mounted) return;
    final memberIds = participants.map((p) => p.memberId).toSet();
    final selected = widget.members
        .where((m) => m.id != null && memberIds.contains(m.id))
        .toList();
    setState(() {
      _selectedMembers = selected;
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
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: _validateAmount,
            ),
            const SizedBox(height: 12),
            _FieldLabel('Jumlah Putaran'),
            _AppTextField(
              controller: _totalRoundsController,
              hint: 'Contoh: 12',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: _validateRounds,
            ),
            const SizedBox(height: 12),
            _FieldLabel('Anggota'),
            MultiSelectDropdown<JamaahMember>(
              selectedItems: _selectedMembers,
              items: widget.members,
              hint: 'Pilih anggota arisan',
              displayText: (m) => m.name,
              itemLabel: (m) => '${m.name} (${m.neighborhood})',
              onChanged: (selected) {
                setState(() {
                  _selectedMembers = selected;
                });
              },
            ),
            if (_selectedMembers.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _selectedMembers.map((member) {
                  return Chip(
                    label: Text(
                      member.name,
                      style: const TextStyle(fontSize: 11),
                    ),
                    deleteIcon: const Icon(Icons.close, size: 14),
                    onDeleted: () {
                      setState(() {
                        _selectedMembers.remove(member);
                      });
                    },
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  );
                }).toList(),
              ),
            ],
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
                : _buildAgendaDropdown(),
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

  Widget _buildAgendaDropdown() {
    final agendaItems = [null, ..._agendas];
    return DropdownButtonFormField<Agenda?>(
      value: _selectedAgenda,
      decoration: InputDecoration(
        hintText: 'Pilih agenda terkait',
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
      items: [
        const DropdownMenuItem<Agenda?>(
          value: null,
          child: Text('Tidak ada', style: TextStyle(fontSize: 12)),
        ),
        ...agendaItems.whereType<Agenda>().map(
          (a) => DropdownMenuItem<Agenda?>(
            value: a,
            child: Text(
              '${a.title} - ${a.dateFormatted}',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _selectedAgenda = value;
        });
      },
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
    if (amount < 1000) {
      return 'Minimal Rp 1.000';
    }
    if (amount > 100000000) {
      return 'Maksimal Rp 100.000.000';
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
    if (rounds > 100) {
      return 'Maksimal 100 putaran';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal 1 anggota'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final amount = int.parse(_amountController.text.trim());
    final totalRounds = int.parse(_totalRoundsController.text.trim());
    if (amount * totalRounds > 1000000000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Total iuran tidak boleh melebihi Rp 1.000.000.000'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    final arisan = Arisan(
      id: widget.arisan?.id,
      name: _nameController.text.trim(),
      amount: amount,
      currentRound: widget.arisan?.currentRound ?? 0,
      totalRounds: totalRounds,
      agendaId: _selectedAgenda?.id,
      agendaTitle: _selectedAgenda?.title,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      createdAt: widget.arisan?.createdAt ?? DateTime.now(),
    );

    int arisanId;
    if (isEdit) {
      await ArisanLocalDatabase.instance.updateArisan(arisan);
      arisanId = widget.arisan!.id!;
      await _saveParticipants(arisanId);
      if (!mounted) return;
      Navigator.of(context).pop(arisan);
      return;
    }

    arisanId = await ArisanLocalDatabase.instance.insertArisan(arisan);
    await _saveParticipants(arisanId);
    if (!mounted) return;
    Navigator.of(context).pop(arisan.copyWith(id: arisanId));
  }

  Future<void> _saveParticipants(int arisanId) async {
    final existing = await ArisanLocalDatabase.instance.getParticipants(
      arisanId,
    );
    for (final p in existing) {
      await ArisanLocalDatabase.instance.removeParticipant(p.id!);
    }
    for (final member in _selectedMembers) {
      if (member.id == null) continue;
      await ArisanLocalDatabase.instance.addParticipant(
        ArisanParticipant(
          arisanId: arisanId,
          memberId: member.id!,
          memberName: member.name,
          hasPaid: false,
          wonRound: 0,
        ),
      );
    }
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
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String hint;
  final String? Function(String?)? validator;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
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
