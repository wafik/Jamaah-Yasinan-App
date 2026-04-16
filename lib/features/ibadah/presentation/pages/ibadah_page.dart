import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/page_transitions.dart';
import '../../../../shared/widgets/cards/ventri_card.dart';
import 'asmaul_husna_page.dart';
import 'doa_harian_page.dart';
import 'kalender_page.dart';
import 'kitab_pilihan_page.dart';
import 'surat_pilihan_page.dart';
import 'tahlil_page.dart';
import 'yasin_page.dart';

class IbadahPage extends StatelessWidget {
  const IbadahPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_MenuItem>[
      const _MenuItem(
        'Surat Yasin',
        'Pembaca Yasin dengan terjemahan',
        Icons.menu_book_rounded,
        YasinPage(),
      ),
      const _MenuItem(
        'Tahlil',
        'Bacaan tahlil dengan panduan',
        Icons.schedule_rounded,
        TahlilPage(),
      ),
      const _MenuItem(
        'Asmaul Husna',
        '99 Nama Indah Allah SWT',
        Icons.auto_awesome_rounded,
        AsmaulHusnaPage(),
      ),
      const _MenuItem(
        'Surat Pilihan',
        'Surat-surat untuk murojaah',
        Icons.grid_view_rounded,
        SuratPilihanPage(),
      ),
      const _MenuItem(
        'Kitab Pilihan',
        'Daftar kitab rujukan',
        Icons.book_rounded,
        KitabPilihanPage(),
      ),
      const _MenuItem(
        'Kalender',
        'Agenda jamaah bulanan',
        Icons.calendar_month_rounded,
        KalenderPage(),
      ),
      const _MenuItem(
        'Doa Harian',
        'Doa-doa harian pilihan',
        Icons.chrome_reader_mode_rounded,
        DoaHarianPage(),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Text(
            'Ibadah',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Text(
            'Pilih bacaan dan amalan harian dari modul berikut',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) {
              final item = items[index];
              return VentriCard(
                margin: const EdgeInsets.only(bottom: 10),
                onTap: () => Navigator.of(
                  context,
                ).push(buildVentriRoute<void>(item.page)),
                highlight: item.title == 'Asmaul Husna',
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: item.title == 'Asmaul Husna'
                            ? AppColors.surface
                            : AppColors.card,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        item.icon,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.subtitle,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MenuItem {
  const _MenuItem(this.title, this.subtitle, this.icon, this.page);

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget page;
}
