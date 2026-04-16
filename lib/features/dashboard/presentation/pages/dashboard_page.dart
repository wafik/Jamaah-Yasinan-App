import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/page_transitions.dart';
import '../../../../shared/widgets/cards/ventri_card.dart';
import '../../../../shared/widgets/section_title.dart';
import '../../../agenda/data/agenda.dart';
import '../../../agenda/data/agenda_local_database.dart';
import '../../../ibadah/presentation/pages/asmaul_husna_page.dart';
import '../../../ibadah/presentation/pages/doa_harian_page.dart';
import '../../../ibadah/presentation/pages/kalender_page.dart';
import '../../../ibadah/presentation/pages/kitab_pilihan_page.dart';
import '../../../ibadah/presentation/pages/surat_pilihan_page.dart';
import '../../../ibadah/presentation/pages/tahlil_page.dart';
import '../../../ibadah/presentation/pages/yasin_page.dart';
import '../widgets/dashboard_header.dart';
import '../../../../core/constants/mock_data.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int activeQuickAction = 2;
  List<Agenda> _upcomingAgendas = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAgendas();
  }

  Future<void> _loadAgendas() async {
    final agendas = await AgendaLocalDatabase.instance.getUpcomingAgendas(
      limit: 3,
    );
    if (!mounted) return;
    setState(() {
      _upcomingAgendas = agendas;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        const DashboardHeader(),
        const SizedBox(height: 14),
        const SectionTitle(
          'Akses Cepat',
          padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: quickActions.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (BuildContext context, int index) {
              final item = quickActions[index];
              return VentriCard(
                onTap: () => _openQuickAction(context, index),
                highlight: index == activeQuickAction,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 14,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: index == activeQuickAction
                            ? AppColors.primary
                            : AppColors.card,
                        borderRadius: BorderRadius.circular(AppColors.radiusMd),
                      ),
                      child: Icon(
                        item.icon,
                        color: index == activeQuickAction
                            ? Colors.white
                            : AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        const SectionTitle('Agenda Terdekat'),
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            ),
          )
        else if (_upcomingAgendas.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: VentriCard(
              child: Center(
                child: Column(
                  children: <Widget>[
                    const Icon(
                      Icons.event_busy_rounded,
                      size: 32,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tidak ada agenda terdekat',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...List.generate(_upcomingAgendas.length, (index) {
            final agenda = _upcomingAgendas[index];
            final isLast = index == _upcomingAgendas.length - 1;
            return Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, isLast ? 16 : 8),
              child: _buildAgendaCard(agenda),
            );
          }),
      ],
    );
  }

  Widget _buildAgendaCard(Agenda agenda) {
    final now = DateTime.now();
    final daysUntil = agenda.date.difference(now).inDays;
    String badgeText;
    if (daysUntil == 0) {
      badgeText = 'Hari ini';
    } else if (daysUntil == 1) {
      badgeText = 'Besok';
    } else {
      badgeText = '$daysUntil hari lagi';
    }

    final weekdays = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
    final weekday = weekdays[agenda.date.weekday % 7];

    return VentriCard(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  agenda.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${agenda.date.day} ${_monthName(agenda.date.month)} • ${agenda.time}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: daysUntil <= 1 ? AppColors.warning : AppColors.primary,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Text(
                badgeText,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
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

  Future<void> _openQuickAction(BuildContext context, int index) async {
    setState(() {
      activeQuickAction = index;
    });

    final pages = <Widget>[
      const YasinPage(),
      const TahlilPage(),
      const AsmaulHusnaPage(),
      const SuratPilihanPage(),
      const KalenderPage(),
      const KitabPilihanPage(),
      const DoaHarianPage(),
    ];

    final page = pages[index];
    await Future<void>.delayed(const Duration(milliseconds: 110));
    if (!context.mounted) return;
    Navigator.of(context).push(buildVentriRoute<void>(page));
  }
}
