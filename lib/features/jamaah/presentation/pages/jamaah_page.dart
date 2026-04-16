import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/page_transitions.dart';
import '../../../../shared/widgets/inputs/search_bar_card.dart';
import '../../data/jamaah_local_database.dart';
import '../../data/jamaah_member.dart';
import 'almarhum_page.dart';
import 'jamaah_detail_page.dart';
import 'jamaah_form_page.dart';

class JamaahPage extends StatefulWidget {
  const JamaahPage({super.key});

  @override
  State<JamaahPage> createState() => _JamaahPageState();
}

class _JamaahPageState extends State<JamaahPage> {
  final TextEditingController _searchController = TextEditingController();
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
            IconButton(
              onPressed: () => Navigator.of(
                context,
              ).push(buildVentriRoute<void>(const AlmarhumPage())),
              icon: const Icon(
                Icons.download_rounded,
                color: AppColors.primary,
              ),
              tooltip: 'Export CSV',
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
                  'Tambah anggota baru atau ubah filter pencarian.',
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
    setState(() {
      _loading = true;
    });

    final members = await JamaahLocalDatabase.instance.getAllMembers();
    final almarhumCount = await JamaahLocalDatabase.instance.getAlmarhumCount();

    if (!mounted) return;
    setState(() {
      _members = members;
      _almarhumCount = almarhumCount;
      _loading = false;
    });
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
