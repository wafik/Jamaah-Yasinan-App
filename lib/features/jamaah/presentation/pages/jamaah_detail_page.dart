import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/page_transitions.dart';
import '../../../../shared/widgets/cards/ventri_card.dart';
import '../../data/jamaah_local_database.dart';
import '../../data/jamaah_member.dart';
import 'jamaah_form_page.dart';
import 'prayer_request_form_page.dart';

class JamaahDetailPage extends StatefulWidget {
  const JamaahDetailPage({super.key, required this.member});

  final JamaahMember member;

  @override
  State<JamaahDetailPage> createState() => _JamaahDetailPageState();
}

class _JamaahDetailPageState extends State<JamaahDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late JamaahMember member;
  List<PrayerRequest> _prayerRequests = [];

  @override
  void initState() {
    super.initState();
    member = widget.member;
    _tabController = TabController(length: 2, vsync: this);
    _loadPrayerRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPrayerRequests() async {
    if (member.id == null) return;
    final requests = await JamaahLocalDatabase.instance.getPrayerRequests(
      member.id!,
    );
    if (!mounted) return;
    setState(() {
      _prayerRequests = requests;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Jamaah'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Profil'),
            Tab(text: 'Keluarga Di-doakan'),
          ],
        ),
        actions: <Widget>[
          IconButton(
            onPressed: _editMember,
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Edit',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildProfileTab(), _buildPrayerRequestsTab()],
      ),
    );
  }

  Widget _buildProfileTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        VentriCard(
          child: Row(
            children: <Widget>[
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primaryBg,
                child: Text(
                  member.initials,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      member.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      member.detail,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Informasi Kontak',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        VentriCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'No. HP',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
              const SizedBox(height: 2),
              Text(
                member.phone,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Alamat',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
              const SizedBox(height: 2),
              Text(
                member.address,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Wilayah',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
              const SizedBox(height: 2),
              Text(
                member.neighborhood,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrayerRequestsTab() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '${_prayerRequests.length} anggota keluarga',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              IconButton(
                onPressed: _addPrayerRequest,
                icon: const Icon(
                  Icons.add_circle_rounded,
                  color: AppColors.primary,
                ),
                tooltip: 'Tambah',
              ),
            ],
          ),
        ),
        Expanded(
          child: _prayerRequests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Icon(
                        Icons.family_restroom_rounded,
                        size: 48,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Belum ada keluarga yang di-doakan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tambahkan anggota keluarga untuk didoakan',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _prayerRequests.length,
                  itemBuilder: (context, index) {
                    final pr = _prayerRequests[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: VentriCard(
                        child: Row(
                          children: <Widget>[
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: pr.isDeceased
                                  ? AppColors.secondaryBg
                                  : AppColors.primaryBg,
                              child: Text(
                                pr.initials,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: pr.isDeceased
                                      ? AppColors.secondary
                                      : AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    pr.name,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (pr.relation != null)
                                    Text(
                                      pr.relation!,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (pr.isDeceased)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Almarhum',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ),
                            PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.more_vert,
                                size: 18,
                                color: AppColors.textMuted,
                              ),
                              onSelected: (value) {
                                if (value == 'delete') {
                                  _deletePrayerRequest(pr);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.delete_outline,
                                        size: 18,
                                        color: AppColors.danger,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Hapus',
                                        style: TextStyle(fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _editMember() async {
    final result = await Navigator.of(context).push<JamaahMember>(
      buildVentriRoute<JamaahMember>(JamaahFormPage(member: member)),
    );

    if (result == null || !mounted) return;

    setState(() {
      member = result;
    });
  }

  Future<void> _addPrayerRequest() async {
    final pr = PrayerRequest(
      jamaahId: member.id,
      name: '',
      isDeceased: false,
      createdAt: DateTime.now(),
    );
    final result = await Navigator.of(context).push<PrayerRequest>(
      buildVentriRoute<PrayerRequest>(PrayerRequestFormPage(prayerRequest: pr)),
    );

    if (result != null && mounted) {
      await JamaahLocalDatabase.instance.insertPrayerRequest(result);
      _loadPrayerRequests();
    }
  }

  Future<void> _deletePrayerRequest(PrayerRequest pr) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusXl),
        ),
        title: const Text('Hapus'),
        content: Text('Hapus ${pr.name} dari daftar?'),
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

    if (confirm == true && pr.id != null) {
      await JamaahLocalDatabase.instance.deletePrayerRequest(pr.id!);
      _loadPrayerRequests();
    }
  }
}
