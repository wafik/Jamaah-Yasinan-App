import '../../features/jamaah/data/jamaah_local_database.dart';
import '../../features/jamaah/data/jamaah_member.dart';

class CsvExport {
  static Future<String> exportJamaah() async {
    final members = await JamaahLocalDatabase.instance.getAllMembers();
    final buffer = StringBuffer();

    buffer.writeln('Nama,No. HP,Alamat,Wilayah,Peran');
    for (final m in members) {
      buffer.writeln(
        '${_escape(m.name)},${_escape(m.phone)},${_escape(m.address)},${_escape(m.neighborhood)},${_escape(m.role)}',
      );
    }

    return buffer.toString();
  }

  static Future<String> exportJamaahWithPrayerRequests() async {
    final members = await JamaahLocalDatabase.instance.getAllMembers();
    final buffer = StringBuffer();

    buffer.writeln(
      'Nama Jamaah,No. HP,Alamat,Wilayah,Peran,Nama Keluarga,Hubungan,Status',
    );

    for (final m in members) {
      List<PrayerRequest> prayerRequests = [];
      if (m.id != null) {
        prayerRequests = await JamaahLocalDatabase.instance.getPrayerRequests(
          m.id!,
        );
      }

      if (prayerRequests.isEmpty) {
        buffer.writeln(
          '${_escape(m.name)},${_escape(m.phone)},${_escape(m.address)},${_escape(m.neighborhood)},${_escape(m.role)},,,',
        );
      } else {
        for (final pr in prayerRequests) {
          final status = pr.isDeceased ? 'Almarhum' : 'Hidup';
          buffer.writeln(
            '${_escape(m.name)},${_escape(m.phone)},${_escape(m.address)},${_escape(m.neighborhood)},${_escape(m.role)},${_escape(pr.name)},${_escape(pr.relation ?? '')},$status',
          );
        }
      }
    }

    return buffer.toString();
  }

  static Future<String> exportAlmarhum() async {
    final almarhum = await JamaahLocalDatabase.instance.getAllAlmarhum();
    final buffer = StringBuffer();

    buffer.writeln('Nama,Hubungan (Lineage),Tanggal Wafat,Jenis Kelamin');
    for (final a in almarhum) {
      final gender = a.gender == 'L' ? 'Bapak' : 'Ibu';
      buffer.writeln(
        '${_escape(a.jamaahName)},${_escape(a.lineage ?? '')},${a.deathDateFormatted},$gender',
      );
    }

    return buffer.toString();
  }

  static Future<int> importJamaah(
    String csvContent, {
    bool replaceExisting = false,
  }) async {
    final lines = csvContent.split('\n');
    if (lines.isEmpty) return 0;

    int imported = 0;
    final now = DateTime.now();

    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final values = _parseCsvLine(line);
      if (values.length < 5) continue;

      final name = values[0].trim();
      final phone = values[1].trim();
      final address = values[2].trim();
      final neighborhood = values[3].trim();
      final role = values[4].trim();

      if (name.isEmpty) continue;

      if (replaceExisting) {
        final existing = await JamaahLocalDatabase.instance.getAllMembers();
        final existingMember = existing
            .where((m) => m.name == name && m.phone == phone)
            .firstOrNull;
        if (existingMember != null) continue;
      }

      final member = JamaahMember(
        name: name,
        phone: phone,
        address: address,
        neighborhood: neighborhood,
        role: role,
        createdAt: now,
      );

      await JamaahLocalDatabase.instance.insertMember(member);
      imported++;
    }

    return imported;
  }

  static Future<int> importPrayerRequests(
    String csvContent,
    int jamaahId,
  ) async {
    final lines = csvContent.split('\n');
    if (lines.isEmpty) return 0;

    int imported = 0;
    final now = DateTime.now();

    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final values = _parseCsvLine(line);
      if (values.length < 3) continue;

      final name = values[0].trim();
      if (name.isEmpty) continue;

      final relation = values[1].trim();
      final status = values[2].trim().toLowerCase();
      final isDeceased = status == 'almarhum';

      final pr = PrayerRequest(
        jamaahId: jamaahId,
        name: name,
        relation: relation.isEmpty ? null : relation,
        isDeceased: isDeceased,
        createdAt: now,
      );

      await JamaahLocalDatabase.instance.insertPrayerRequest(pr);
      imported++;
    }

    return imported;
  }

  static List<String> _parseCsvLine(String line) {
    final result = <String>[];
    var current = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        result.add(current.toString());
        current = StringBuffer();
      } else {
        current.write(char);
      }
    }
    result.add(current.toString());

    return result;
  }

  static String _escape(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
