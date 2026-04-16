Tentu, ini adalah rencana struktur folder modular untuk aplikasi **"Ventri Yasin & Tahlil"**. Struktur ini dirancang agar *scalable*, mendukung *dark mode* dengan mudah, dan menggunakan pola *reusable components* (Atomic Design-ish).

---

## 📂 Project Structure: Ventri Yasin & Tahlil

```text
lib/
├── core/                        # Singleton, Config, & Base Classes
│   ├── constants/               # App strings, image paths, keys
│   ├── theme/                   # Dark/Light mode config (System Design)
│   │   ├── app_colors.dart      # #89E197, #1F2937, etc.
│   │   ├── app_theme.dart       # ThemeData definitions
│   │   └── typography.dart      # TextStyles for Arabic & Latin
│   ├── utils/                   # Extensions, date formatters (Hijri)
│   └── network/                 # API/Firebase base services
│
├── shared/                      # Reusable Components (The UI Kit)
│   ├── widgets/
│   │   ├── buttons/             # Custom buttons (Primary, Outline)
│   │   ├── cards/               # Product-style cards for Jamaah/Arisan
│   │   ├── navigation/          # Floating Bottom Nav Bar implementation
│   │   └── inputs/              # Search bar, custom textfields
│   └── components/              # Complex reusable parts (e.g., ArabicTextRow)
│
├── features/                    # Modular Business Logic
│   ├── dashboard/               # Jam, Tanggal Hijriah, Quick Access
│   │   ├── data/
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   └── widgets/         # Dashboard-specific widgets (e.g., HeaderCard)
│   │   └── logic/               # BLoC/Provider/Riverpod
│   ├── ibadah/                  # Yasin, Tahlil, Asmaul Husna
│   │   ├── presentation/
│   │   │   ├── pages/           # YasinPage, AsmaulHusnaPage
│   │   │   └── widgets/         # AyatCard, TranslationTile
│   ├── arisan/                  # Manage Arisan & Randomizer
│   │   ├── presentation/
│   │   │   ├── pages/           # ArisanListPage, ShufflePage
│   │   │   └── widgets/         # WinnerModal, MemberCard
│   └── jamaah/                  # Manage Jamaah list
│       └── presentation/
│           └── pages/           # JamaahListPage, DetailJamaahPage
│
└── main.dart                    # App Entry Point & Theme Injection
```

---

## 🛠️ Reusable Component Pattern (Contoh Implementasi)

Berikut adalah contoh bagaimana kita membuat komponen yang mendukung *Dark Mode* secara otomatis menggunakan warna sistem yang sudah kita tentukan.

### 1. **Floating Bottom Navigation Bar**
Komponen ini akan diletakkan di `shared/widgets/navigation/ventri_nav_bar.dart`.

```dart
// shared/widgets/navigation/ventri_nav_bar.dart
class VentriNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const VentriNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 30), // Floating effect
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 2,
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(context, icon: Icons.home_rounded, label: "Home", index: 0),
          _navItem(context, icon: Icons.menu_book_rounded, label: "Ibadah", index: 1),
          _navItem(context, icon: Icons.people_alt_rounded, label: "Jamaah", index: 2),
          _navItem(context, icon: Icons.person_rounded, label: "Akun", index: 3),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext context, {required IconData icon, required String label, required int index}) {
    bool isActive = currentIndex == index;
    Color activeColor = const Color(0xFF89E197); // Primary Green
    
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? activeColor : Colors.grey),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? activeColor : Colors.grey,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
```

### 2. **Base Card (Reusable)**
Digunakan untuk List Jamaah, Arisan, maupun List Surat.

```dart
// shared/widgets/cards/ventri_card.dart
class VentriCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const VentriCard({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // Support dark mode surface
        borderRadius: BorderRadius.circular(16), // Rounded 2xl
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }
}
```

---

## 🌑 Dark Mode Support (App Theme)

Definisikan di `core/theme/app_theme.dart`:

```dart
static final lightTheme = ThemeData(
  primaryColor: const Color(0xFF4A7C59),
  scaffoldBackgroundColor: const Color(0xFFFEFCFA),
  cardColor: const Color(0xFFFFFFFF),
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF4A7C59),
    primaryVariant: Color(0xFF6B9B7A),
    secondary: Color(0xFF8B7355),
    surface: Color(0xFFFFFFFF),
    background: Color(0xFFFEFCFA),
    onPrimary: Colors.white,
    onSecondary: Color(0xFF1F2937),
    onSurface: Color(0xFF2D2A26),
    onBackground: Color(0xFF2D2A26),
  ),
);

static final darkTheme = ThemeData(
  primaryColor: const Color(0xFF4A7C59),
  scaffoldBackgroundColor: const Color(0xFF1F2937),
  cardColor: const Color(0xFF1E1E1E), // Soft dark surface
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF4A7C59),
    secondary: Color(0xFF8B7355),
    surface: Color(0xFF1E1E1E),
    background: Color(0xFF121212),
    onPrimary: Colors.white,
    onSecondary: Color(0xFFFEFCFA),
    onSurface: Color(0xFFF8F6F2),
    onBackground: Color(0xFFFEFCFA),
  ),
);
```

### ✨ Keuntungan Struktur Ini:
1.  **Isolation:** Jika kamu ingin mengubah logika Arisan, kamu hanya perlu menyentuh folder `features/arisan`.
2.  **Consistency:** Semua UI Card dan Button terpusat di `shared/`, jadi jika warna primer berubah, kamu cukup ubah satu file.
3.  **Clean Code:** Pemisahan antara data (API), logika (BLoC), dan tampilan (Presentation) membuat debugging jauh lebih mudah.

Ada bagian fitur spesifik (seperti algoritma acak arisan) yang ingin kamu kembangkan kodenya lebih dalam?