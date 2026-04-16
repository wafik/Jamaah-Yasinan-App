import 'package:flutter/material.dart';

class QuickActionItem {
  const QuickActionItem(this.label, this.icon);

  final String label;
  final IconData icon;
}

class CalendarEventItem {
  const CalendarEventItem(
    this.day,
    this.title,
    this.time,
    this.badge,
    this.icon,
  );

  final int day;
  final String title;
  final String time;
  final String badge;
  final String icon;
}

class ArisanGroupItem {
  const ArisanGroupItem({
    required this.name,
    required this.round,
    required this.totalRounds,
    required this.amount,
    required this.members,
    required this.paid,
  });

  final String name;
  final int round;
  final int totalRounds;
  final String amount;
  final List<String> members;
  final int paid;
}

class JamaahMemberItem {
  const JamaahMemberItem({
    required this.initials,
    required this.name,
    required this.detail,
    required this.status,
    required this.isPresent,
  });

  final String initials;
  final String name;
  final String detail;
  final String status;
  final bool isPresent;
}

class AlmarhumItem {
  const AlmarhumItem(this.initials, this.name, this.lineage, this.date);

  final String initials;
  final String name;
  final String lineage;
  final String date;
}

class DoaItem {
  const DoaItem({
    required this.title,
    required this.arabic,
    required this.latin,
    required this.translation,
    required this.category,
  });

  final String title;
  final String arabic;
  final String latin;
  final String translation;
  final String category;
}

const List<QuickActionItem> quickActions = <QuickActionItem>[
  QuickActionItem('Surat Yasin', Icons.menu_book_rounded),
  QuickActionItem('Tahlil', Icons.schedule_rounded),
  QuickActionItem('Asmaul Husna', Icons.auto_awesome_rounded),
  QuickActionItem('Surat Pilihan', Icons.grid_view_rounded),
  QuickActionItem('Kalender', Icons.calendar_month_rounded),
  QuickActionItem('Kitab Pilihan', Icons.book_rounded),
  QuickActionItem('Doa Harian', Icons.chrome_reader_mode_rounded),
];

const List<CalendarEventItem> calendarEvents = <CalendarEventItem>[
  CalendarEventItem(
    5,
    'Pengajian RT 05',
    'Ba\'da Isya • Masjid Al-Hidayah',
    'Umum',
    '🕌',
  ),
  CalendarEventItem(
    12,
    'Tahlilan Jasro',
    'Pukul 10.00 • Masjid Al-Hidayah',
    'Umum',
    '🕌',
  ),
  CalendarEventItem(
    19,
    'Pengajian Akbar',
    'Ba\'da Isya • Masjid Al-Hidayah',
    'Umum',
    '🕌',
  ),
  CalendarEventItem(
    26,
    'Tahlilan Kenaikan',
    'Pukul 10.00 • Masjid Al-Hidayah',
    'Umum',
    '🕌',
  ),
];

const List<ArisanGroupItem> arisanGroups = <ArisanGroupItem>[
  ArisanGroupItem(
    name: 'Arisan RT 05',
    round: 7,
    totalRounds: 12,
    amount: 'Rp 150.000',
    members: <String>['BU', 'SR', 'AN', 'WT'],
    paid: 7,
  ),
  ArisanGroupItem(
    name: 'Arisan Ibu PKK',
    round: 3,
    totalRounds: 20,
    amount: 'Rp 50.000',
    members: <String>['SW', 'RM', 'DK'],
    paid: 3,
  ),
];

const List<JamaahMemberItem> jamaahMembers = <JamaahMemberItem>[
  JamaahMemberItem(
    initials: 'BU',
    name: 'Bapak Usman',
    detail: 'RT 05 • Ketua Jamaah',
    status: 'Hadir',
    isPresent: true,
  ),
  JamaahMemberItem(
    initials: 'SR',
    name: 'Ibu Sari Rahayu',
    detail: 'RT 06 • Anggota',
    status: 'Izin',
    isPresent: false,
  ),
  JamaahMemberItem(
    initials: 'AN',
    name: 'Ahmad Nurdin',
    detail: 'RT 05 • Anggota',
    status: 'Hadir',
    isPresent: true,
  ),
  JamaahMemberItem(
    initials: 'WT',
    name: 'Wati Susanti',
    detail: 'RT 07 • Bendahara',
    status: 'Hadir',
    isPresent: true,
  ),
];

const List<AlmarhumItem> almarhumBapak = <AlmarhumItem>[
  AlmarhumItem('A', 'H. Ahmad Wijaya', 'Bin H. Salim', '10 Mar 2024'),
  AlmarhumItem('B', 'H. Budi Santoso', 'Bin H. Suparman', '22 Jan 2024'),
  AlmarhumItem('C', 'H. Cokro Aminoto', 'Bin M. Joyo', '05 Des 2023'),
];

const List<AlmarhumItem> almarhumIbu = <AlmarhumItem>[
  AlmarhumItem('S', 'Hj. Siti Rahayu', 'Binti H. Mahmud', '18 Feb 2024'),
  AlmarhumItem('M', 'Hj. Mariyam', 'Binti H. Basri', '30 Nov 2023'),
];

const List<String> tahlilLines = <String>[
  'لَا إِلٰهَ إِلَّا ٱللَّٰهُ',
  'اَللّٰهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ',
  'سُبْحَانَ اللّٰهِ وَالْحَمْدُ لِلّٰهِ وَلاَ إِلٰهَ إِلاَّ اللّٰهُ وَاللّٰهُ أَكْبَرُ',
  'رَبِّ اغْفِرْ لِي وَلِوَالِدَيَّ وَلِلْمُؤْمِنِينَ',
];

const List<DoaItem> doaHarianItems = <DoaItem>[
  DoaItem(
    title: 'Doa Sebelum Tidur',
    arabic: 'بِاسْمِكَ اللّٰهُمَّ اَحْيَا وَاَمُوْتُ',
    latin: 'Bismikallahumma ahya wa amut.',
    translation: 'Dengan nama-Mu ya Allah aku hidup dan aku mati.',
    category: 'Pagi & Malam',
  ),
  DoaItem(
    title: 'Doa Bangun Tidur',
    arabic: 'اَلْحَمْدُ لِلّٰهِ الَّذِيْ اَحْيَانَا بَعْدَ مَا اَمَاتَنَا',
    latin: 'Alhamdulillahil ladzi ahyana ba\'da ma amatana.',
    translation:
        'Segala puji bagi Allah yang menghidupkan kami kembali setelah mematikan kami.',
    category: 'Pagi & Malam',
  ),
  DoaItem(
    title: 'Doa Masuk Rumah',
    arabic:
        'اَللّٰهُمَّ اِنِّيْ اَسْأَلُكَ خَيْرَ الْمَوْلِجِ وَخَيْرَ الْمَخْرَجِ',
    latin: 'Allahumma inni as\'aluka khairal mauliji wa khairal makhraji.',
    translation:
        'Ya Allah, aku memohon kepada-Mu kebaikan ketika masuk dan keluar rumah.',
    category: 'Aktivitas Harian',
  ),
  DoaItem(
    title: 'Doa Keluar Rumah',
    arabic: 'بِسْمِ اللّٰهِ تَوَكَّلْتُ عَلَى اللّٰهِ',
    latin: 'Bismillahi tawakkaltu \u2018alallah.',
    translation: 'Dengan nama Allah, aku bertawakal kepada Allah.',
    category: 'Aktivitas Harian',
  ),
];
