import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/page_transitions.dart';
import '../../../../shared/widgets/inputs/search_bar_card.dart';
import '../../../jamaah/data/jamaah_local_database.dart';
import '../../../jamaah/data/jamaah_member.dart';
import '../../data/agenda.dart';
import '../../data/agenda_local_database.dart';
import 'agenda_detail_page.dart';
import 'agenda_form_page.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Agenda> _agendas = <Agenda>[];
  List<JamaahMember> _members = <JamaahMember>[];
  bool _loading = true;

  List<Agenda> get filteredAgendas {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _agendas;
    return _agendas.where((Agenda item) {
      return item.title.toLowerCase().contains(query) ||
          item.location.toLowerCase().contains(query) ||
          (item.organizerName?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadData();
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
    });

    final agendas = await AgendaLocalDatabase.instance.getAllAgendas();
    final members = await JamaahLocalDatabase.instance.getAllMembers();

    if (!mounted) return;
    setState(() {
      _agendas = agendas;
      _members = members;
      _loading = false;
    });
  }

  void _onSearchChanged() {
    if (mounted) setState(() {});
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
                    'Manage Agenda',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_agendas.length} agenda',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
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
          placeholder: 'Cari agenda...',
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          trailing: _searchController.text.isEmpty
              ? const SizedBox.shrink()
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
        const SizedBox(height: 12),
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          )
        else if (filteredAgendas.isEmpty)
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
                  Icons.event_busy_rounded,
                  size: 40,
                  color: AppColors.textMuted,
                ),
                SizedBox(height: 10),
                Text(
                  'Belum ada agenda',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 4),
                Text(
                  'Tambah agenda baru untuk memulai.',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          )
        else
          ...filteredAgendas.map(_buildAgendaItem),
      ],
    );
  }

  Widget _buildAgendaItem(Agenda item) {
    final isUpcoming = item.date.isAfter(
      DateTime.now().subtract(const Duration(days: 1)),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => _openDetail(item),
        borderRadius: BorderRadius.circular(AppColors.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppColors.radiusMd),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 50,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isUpcoming
                      ? AppColors.primaryBg
                      : AppColors.borderLight,
                  borderRadius: BorderRadius.circular(AppColors.radiusSm),
                ),
                child: Column(
                  children: <Widget>[
                    Text(
                      item.date.day.toString(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isUpcoming
                            ? AppColors.primary
                            : AppColors.textMuted,
                      ),
                    ),
                    Text(
                      _getMonthAbbr(item.date.month),
                      style: TextStyle(
                        fontSize: 10,
                        color: isUpcoming
                            ? AppColors.primary
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: <Widget>[
                        const Icon(
                          Icons.access_time,
                          size: 10,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.time,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: <Widget>[
                        const Icon(
                          Icons.location_on,
                          size: 10,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.location,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textMuted,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isUpcoming ? AppColors.primary : AppColors.textMuted,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isUpcoming ? 'Akan datang' : 'Selesai',
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMonthAbbr(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return months[month - 1];
  }

  Future<void> _openCreateForm() async {
    final result = await Navigator.of(
      context,
    ).push<Agenda>(buildVentriRoute<Agenda>(AgendaFormPage(members: _members)));
    if (result == null) return;
    await _loadData();
  }

  Future<void> _openDetail(Agenda agenda) async {
    await Navigator.of(context).push<Object?>(
      buildVentriRoute<Object?>(
        AgendaDetailPage(agenda: agenda, members: _members),
      ),
    );
    await _loadData();
  }
}
