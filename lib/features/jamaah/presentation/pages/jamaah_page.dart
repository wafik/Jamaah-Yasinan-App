import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/csv_export.dart';
import '../../../../core/utils/page_transitions.dart';
import '../../../../shared/widgets/inputs/search_bar_card.dart';
import '../../data/jamaah_local_database.dart';
import '../../data/jamaah_member.dart';
import 'jamaah_detail_page.dart';
import 'jamaah_form_page.dart';

class JamaahPage extends StatefulWidget {
  const JamaahPage({super.key});

  @override
  State<JamaahPage> createState() => _JamaahPageState();
}

class _JamaahPageState extends State<JamaahPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _csvController = TextEditingController();
  List<JamaahMember> _members = <JamaahMember>[];
  int _almarhumCount = 0;
  bool _loading = true;

  List<JamaahMember> get filteredMembers {
    final query = _searchController.text.trim().toLowerCase();

    return _members.where((JamaahMember item) {
      if (query.isEmpty) return true;
      return item.name.toLowerCase().contains(query) ||
          item.neighborhood.toLowerCase().contains(query) ||
          item.role.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearchChanged);
    _loadMembers();
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_handleSearchChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Manage Jamaah',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_members.length} anggota + $_almarhumCount almarhum',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.download_rounded,
                color: AppColors.primary,
              ),
              tooltip: 'Export / Import',
              onSelected: (value) {
                if (value == 'export_jamaah') {
                  _exportJamaah();
                } else if (value == 'export_full') {
                  _exportFull();
                } else if (value == 'export_almarhum') {
                  _exportAlmarhum();
                } else if (value == 'import_jamaah') {
                  _showImportDialog();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'export_jamaah',
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.upload_outlined,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 8),
                      Text('Export Jamaah CSV', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'export_full',
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.upload_outlined,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Export Lengkap CSV',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'export_almarhum',
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.upload_outlined,
                        size: 20,
                        color: AppColors.secondary,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Export Almarhum CSV',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'import_jamaah',
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.download_outlined,
                        size: 20,
                        color: AppColors.warning,
                      ),
                      SizedBox(width: 8),
                      Text('Import Jamaah CSV', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: _openCreateForm,
              child: const CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.add, size: 18, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SearchBarCard(
          placeholder: 'Cari nama atau wilayah...',
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          trailing: _searchController.text.isEmpty
              ? const Icon(
                  Icons.tune_rounded,
                  size: 16,
                  color: AppColors.textMuted,
                )
              : InkWell(
                  onTap: () {
                    _searchController.clear();
                    setState(() {});
                  },
                  child: const Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                ),
        ),
        const SizedBox(height: 8),
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          )
        else if (filteredMembers.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppColors.radiusLg),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: const Column(
              children: <Widget>[
                Icon(
                  Icons.group_off_rounded,
                  size: 40,
                  color: AppColors.textMuted,
                ),
                SizedBox(height: 10),
                Text(
                  'Belum ada data yang cocok',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 4),
                Text(
                  'Tambah anggota baru atau ubah filter.',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          )
        else
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: Column(
              key: ValueKey<String>(
                '${_searchController.text}_${filteredMembers.length}',
              ),
              children: filteredMembers.map(_buildMemberItem).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildMemberItem(JamaahMember item) {
    return InkWell(
      onTap: () => _openDetail(item),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.borderLight)),
        ),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primaryBg,
              child: Text(
                item.initials,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.detail,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF25D366),
              child: Icon(Icons.call, size: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadMembers() async {
    setState(() => _loading = true);
    final members = await JamaahLocalDatabase.instance.getAllMembers();
    final almarhumCount = await JamaahLocalDatabase.instance.getAlmarhumCount();
    if (!mounted) return;
    setState(() {
      _members = members;
      _almarhumCount = almarhumCount;
      _loading = false;
    });
  }

  Future<void> _exportJamaah() async {
    try {
      final csv = await CsvExport.exportJamaah();
      await _saveCsvFile('jamaah.csv', csv);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Export Jamaah berhasil')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger),
      );
    }
  }

  Future<void> _exportFull() async {
    try {
      final csv = await CsvExport.exportJamaahWithPrayerRequests();
      await _saveCsvFile('jamaah_lengkap.csv', csv);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Export lengkap berhasil')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger),
      );
    }
  }

  Future<void> _exportAlmarhum() async {
    try {
      final csv = await CsvExport.exportAlmarhum();
      await _saveCsvFile('almarhum.csv', csv);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Export Almarhum berhasil')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger),
      );
    }
  }

  Future<void> _showImportDialog() async {
    _csvController.clear();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Jamaah CSV'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Paste CSV content:',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _csvController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText:
                      'Nama,No. HP,Alamat,Wilayah,Peran\ncontoh: Ahmad,0812...,Jl. Merdeka,RT 01,Anggota',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Import'),
          ),
        ],
      ),
    );

    if (result == true && _csvController.text.isNotEmpty) {
      try {
        final imported = await CsvExport.importJamaah(_csvController.text);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Berhasil import $imported anggota')),
        );
        _loadMembers();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _saveCsvFile(String filename, String content) async {
    final directory = Directory('/storage/emulated/0/Download');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    final file = File('${directory.path}/$filename');
    await file.writeAsString(content);
    await Clipboard.setData(ClipboardData(text: file.path));
  }

  Future<void> _openCreateForm() async {
    final result = await Navigator.of(context).push<JamaahMember>(
      buildVentriRoute<JamaahMember>(const JamaahFormPage()),
    );
    if (result == null) return;
    await _loadMembers();
  }

  Future<void> _openDetail(JamaahMember member) async {
    await Navigator.of(context).push<Object?>(
      buildVentriRoute<Object?>(JamaahDetailPage(member: member)),
    );
    await _loadMembers();
  }

  void _handleSearchChanged() {
    if (mounted) setState(() {});
  }
}
