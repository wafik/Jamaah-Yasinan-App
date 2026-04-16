import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/inputs/search_dropdown.dart';
import '../../../jamaah/data/jamaah_member.dart';
import '../../data/agenda.dart';
import '../../data/agenda_local_database.dart';

class AgendaFormPage extends StatefulWidget {
  const AgendaFormPage({super.key, this.agenda, required this.members});

  final Agenda? agenda;
  final List<JamaahMember> members;

  @override
  State<AgendaFormPage> createState() => _AgendaFormPageState();
}

class _AgendaFormPageState extends State<AgendaFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _timeController;
  late final TextEditingController _locationController;
  late final TextEditingController _descriptionController;
  late DateTime _selectedDate;
  JamaahMember? _selectedOrganizer;
  bool _saving = false;

  bool get isEdit => widget.agenda != null;

  @override
  void initState() {
    super.initState();
    final agenda = widget.agenda;
    _titleController = TextEditingController(text: agenda?.title ?? '');
    _timeController = TextEditingController(text: agenda?.time ?? '');
    _locationController = TextEditingController(text: agenda?.location ?? '');
    _descriptionController = TextEditingController(
      text: agenda?.description ?? '',
    );
    _selectedDate = agenda?.date ?? DateTime.now();

    if (agenda?.organizerId != null) {
      _selectedOrganizer = widget.members.cast<JamaahMember?>().firstWhere(
        (m) => m?.id == agenda?.organizerId,
        orElse: () => null,
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Agenda' : 'Tambah Agenda'),
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
            _FieldLabel('Judul Agenda'),
            _AppTextField(
              controller: _titleController,
              hint: 'Contoh: Pengajian RT 05',
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _FieldLabel('Tanggal'),
            InkWell(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppColors.radiusMd),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _formatDate(_selectedDate),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _FieldLabel('Waktu'),
            _AppTextField(
              controller: _timeController,
              hint: "Contoh: Ba'da Isya",
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _FieldLabel('Lokasi'),
            _AppTextField(
              controller: _locationController,
              hint: 'Contoh: Masjid Al-Hidayah',
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),
            _FieldLabel('Penanggung Jawab'),
            SearchDropdown<JamaahMember>(
              value: _selectedOrganizer,
              items: widget.members,
              hint: 'Pilih penanggung jawab',
              displayText: (m) => m.name,
              onChanged: (value) {
                setState(() {
                  _selectedOrganizer = value;
                });
              },
            ),
            const SizedBox(height: 12),
            _FieldLabel('Deskripsi (Opsional)'),
            _AppTextField(
              controller: _descriptionController,
              hint: 'Deskripsi agenda...',
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
                    : 'Tambah Agenda',
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
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

    final agenda = Agenda(
      id: widget.agenda?.id,
      title: _titleController.text.trim(),
      date: _selectedDate,
      time: _timeController.text.trim(),
      location: _locationController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      organizerId: _selectedOrganizer?.id,
      organizerName: _selectedOrganizer?.name,
      createdAt: widget.agenda?.createdAt ?? DateTime.now(),
    );

    if (isEdit) {
      await AgendaLocalDatabase.instance.updateAgenda(agenda);
      if (!mounted) return;
      Navigator.of(context).pop(agenda);
      return;
    }

    final id = await AgendaLocalDatabase.instance.insertAgenda(agenda);
    if (!mounted) return;
    Navigator.of(context).pop(agenda.copyWith(id: id));
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusXl),
        ),
        title: const Text('Hapus Agenda'),
        content: const Text('Apakah Anda yakin ingin menghapus agenda ini?'),
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

    if (confirmed == true && widget.agenda?.id != null) {
      await AgendaLocalDatabase.instance.deleteAgenda(widget.agenda!.id!);
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
  });

  final TextEditingController controller;
  final String hint;
  final String? Function(String?)? validator;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
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
