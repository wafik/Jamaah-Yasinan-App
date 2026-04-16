class DateUtilsX {
  static const List<String> _days = <String>[
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Ahad',
  ];

  static const List<String> _months = <String>[
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

  static String formatClock(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static String formatFullDate(DateTime value) {
    return '${_days[value.weekday - 1]}, ${value.day} ${_months[value.month - 1]} ${value.year}';
  }

  static String monthName(int month) => _months[month - 1];

  static int daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }
}
