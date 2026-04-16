import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/page_transitions.dart';
import '../../../../shared/widgets/cards/ventri_card.dart';
import '../../data/jamaah_local_database.dart';
import '../../data/jamaah_member.dart';
import 'jamaah_form_page.dart';

class JamaahDetailPage extends StatefulWidget {
  const JamaahDetailPage({super.key, required this.member});

  final JamaahMember member;

  @override
  State<JamaahDetailPage> createState() => _JamaahDetailPageState();
}

class _JamaahDetailPageState extends State<JamaahDetailPage> {
  late JamaahMember member;

  @override
  void initState() {
    super.initState();
    member = widget.member;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = member.isPresent
        ? AppColors.primary
        : const Color(0xFF92400E);
    final statusBg = member.isPresent
        ? AppColors.primaryBg
        : AppColors.warningLight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Jamaah'),
        actions: <Widget>[
          IconButton(
            onPressed: _editMember,
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Edit',
          ),
          IconButton(
            onPressed: _deleteMember,
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.danger,
            ),
            tooltip: 'Hapus',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          VentriCard(
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 28,
                  backgroundColor: statusBg,
                  child: Text(
                    member.initials,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
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
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          member.status,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
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
          const SizedBox(height: 12),
          const Text(
            'Riwayat Kehadiran',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          VentriCard(
            child: Column(
              children: <Widget>[
                _AttendanceRow(
                  'Pengajian RT 05',
                  member.isPresent ? 'Hadir' : 'Izin',
                  member.isPresent,
                ),
                const Divider(color: AppColors.borderLight),
                const _AttendanceRow('Tahlilan Jasro', 'Izin', false),
                const Divider(color: AppColors.borderLight),
                const _AttendanceRow('Pengajian Akbar', 'Hadir', true),
              ],
            ),
          ),
        ],
      ),
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

  Future<void> _deleteMember() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Jamaah'),
          content: Text('Hapus ${member.name} dari database lokal?'),
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
        );
      },
    );

    if (confirm != true || member.id == null || !mounted) return;

    await JamaahLocalDatabase.instance.deleteMember(member.id!);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }
}

class _AttendanceRow extends StatelessWidget {
  const _AttendanceRow(this.title, this.status, this.present);

  final String title;
  final String status;
  final bool present;

  @override
  Widget build(BuildContext context) {
    final bg = present ? AppColors.primaryBg : AppColors.warningLight;
    final color = present ? AppColors.primary : const Color(0xFF92400E);

    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Mock activity record',
                style: TextStyle(fontSize: 10, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
