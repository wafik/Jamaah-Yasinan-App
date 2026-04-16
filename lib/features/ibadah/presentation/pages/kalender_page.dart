import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/buttons/circle_icon_button.dart';
import '../../../../shared/widgets/cards/ventri_card.dart';
import '../../../agenda/data/agenda.dart';
import '../../../agenda/data/agenda_local_database.dart';

class KalenderPage extends StatefulWidget {
  const KalenderPage({super.key});

  @override
  State<KalenderPage> createState() => _KalenderPageState();
}

class _KalenderPageState extends State<KalenderPage> {
  late int year;
  late int month;
  List<Agenda> _agendas = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    year = now.year;
    month = now.month;
    _loadAgendas();
  }

  Future<void> _loadAgendas() async {
    final agendas = await AgendaLocalDatabase.instance.getAllAgendas();
    if (!mounted) return;
    setState(() {
      _agendas = agendas;
      _loading = false;
    });
  }

  List<Agenda> get _agendasInMonth => _agendas.where((a) {
    return a.date.year == year && a.date.month == month;
  }).toList();

  bool _hasAgendaOnDay(int day) {
    return _agendasInMonth.any((a) => a.date.day == day);
  }

  Agenda? _getAgendaForDay(int day) {
    try {
      return _agendasInMonth.firstWhere((a) => a.date.day == day);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalDays = DateUtilsX.daysInMonth(year, month);
    final firstWeekday = DateTime(year, month, 1).weekday % 7;

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: CircleIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),
        ),
        leadingWidth: 56,
        title: Text('${DateUtilsX.monthName(month)} $year'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: () => _changeMonth(-1),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: () => _changeMonth(1),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(14),
              children: <Widget>[
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _DayName('Min'),
                    _DayName('Sen'),
                    _DayName('Sel'),
                    _DayName('Rab'),
                    _DayName('Kam'),
                    _DayName('Jum'),
                    _DayName('Sab'),
                  ],
                ),
                const SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: firstWeekday + totalDays + 2,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    final displayDay = index - firstWeekday + 1;
                    final isOtherMonth =
                        displayDay <= 0 || displayDay > totalDays;
                    final resolvedDay = isOtherMonth
                        ? (displayDay <= 0
                              ? 30 + displayDay
                              : displayDay - totalDays)
                        : displayDay;
                    final hasEvent = _hasAgendaOnDay(displayDay);
                    final now = DateTime.now();
                    final isToday =
                        displayDay == now.day &&
                        month == now.month &&
                        year == now.year;

                    return Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isToday ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppColors.radiusSm),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          Text(
                            '$resolvedDay',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isToday
                                  ? Colors.white
                                  : isOtherMonth
                                  ? AppColors.textMuted
                                  : AppColors.text,
                            ),
                          ),
                          if (hasEvent)
                            const Positioned(
                              bottom: 4,
                              child: SizedBox(
                                width: 4,
                                height: 4,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: AppColors.danger,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),
                if (_agendasInMonth.isEmpty)
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
                              'Tidak ada agenda di bulan ini',
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
                  ..._agendasInMonth.map((agenda) => _buildAgendaItem(agenda)),
              ],
            ),
    );
  }

  Widget _buildAgendaItem(Agenda agenda) {
    final weekdays = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
    ];
    final weekday = weekdays[agenda.date.weekday % 7];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '${agenda.date.day} ${_monthName(agenda.date.month)} • $weekday',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          VentriCard(
            onTap: () => _showAgendaDetail(agenda),
            child: Row(
              children: <Widget>[
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('🕌'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        agenda.title,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${agenda.time} • ${agenda.location}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAgendaDetail(Agenda agenda) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              agenda.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              '${agenda.dateFormatted} • ${agenda.time}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              agenda.location,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            if (agenda.description != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryBg,
                  borderRadius: BorderRadius.circular(AppColors.radiusMd),
                ),
                child: Text(
                  agenda.description!,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.7,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _changeMonth(int delta) {
    setState(() {
      month += delta;
      if (month > 12) {
        month = 1;
        year++;
      } else if (month < 1) {
        month = 12;
        year--;
      }
    });
  }

  String _monthName(int month) {
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
    return months[month - 1];
  }
}

class _DayName extends StatelessWidget {
  const _DayName(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}
