# Jamaah Yasinan

Aplikasi management untuk kegiatan ibadah dan arisan warga.

## Fitur

### Dashboard
- Akses cepat ke berbagai fitur (Yasin, Tahlil, Asmaul Husna, dll)
- Agenda terdekat dari database

### Ibadah
- **Yasin** - bacaan Surat Yasin
- **Tahlil** - bacaan tahlil
- **Asmaul Husna** - 99 nama Allah
- **Surat Pilihan** - kumpulan surat pilihan
- **Kalender** - kalender dengan agenda dari database
- **Kitab Pilihan** - kumpulan kitab pilihan
- **Doa Harian** - doa-doa harian

### Agenda
- List agenda dari database
- Tambah, edit, hapus agenda
- Filter berdasarkan tanggal

### Arisan
- Manajemen arisan dengan peserta dari Jamaah
- multi-select anggota dengan dropdown search
- Validasi nominal iuran (min Rp 1.000, max Rp 100.000.000)
- Validasi total iuran (max Rp 1.000.000.000)
- Riwayat peserta dengan status pembayaran
- info pemenang perputaran

### Jamaah
- Manajemen data Jamaah
- Tambah, edit, hapus anggota
- detail Jamaah dengan:
  - **Profil** - informasi kontak
  - **Keluarga Di-doakan** - list anggota keluarga yang di-doakan (bisa ditambahkan saat meninggal/ masih hidup)

## Cara Install

### Debug Build
```bash
flutter install
```

### Release Build
```bash
flutter build apk --release
```

### Split APK per ABI
Untuk membatasi ukuran APK per arsitektur:

```bash
flutter build apk --release --split-per-abi
```

Ini akan menghasilkan:
- `app-armeabi-v7a-release.apk`
- `app-arm64-v8a-release.apk`
- `app-x86_64-release.apk`

Atau untuk semua ABI dalam satu perintah:
```bash
flutter build apk --release
```

### Build Specific ABI
```bash
flutter build apk --release --target-platform android-arm64
flutter build apk --release --target-platform android-arm
flutter build apk --release --target-platform android-x64
```

## Struktur Project

```
lib/
├── core/
│   ├── constants/     # Mock data
│   ├── theme/         # Colors, Theme
│   └── utils/         # Helpers
├── features/
│   ├── agenda/        # Fitur agenda
│   ├── arisan/       # Fitur arisan
│   ├── dashboard/    # Halaman utama
│   ├── Ibadah/       # Fitur Ibadah
│   └── Jamaah/       # Fitur Jamaah
└── shared/
    └── widgets/       # Widget reusable
```

## Tech Stack
- Flutter
- SQLite (sqflite)
- Material Design 3
