# Panduan & Standar Implementasi Liquid Glass (MyQuran)

Dokumen ini berisi panduan teknis, arsitektur, dan aturan konsistensi desain untuk implementasi **Liquid Glass** di aplikasi MyQuran. Gunakan panduan ini sebagai acuan setiap kali membuat komponen baru atau melakukan revisi UI agar visual dan interaksi tetap konsisten.

---

## 1. Fondasi & Dependensi

Proyek menggunakan package resmi:
```yaml
# pubspec.yaml
dependencies:
  liquid_glass_widgets: ^0.29.8
```

### Inisialisasi Aplikasi (`lib/main.dart`)
1. Di dalam `main()`, panggil `initialize()` sebelum menjalankan app:
   ```dart
   WidgetsFlutterBinding.ensureInitialized();
   await LiquidGlassWidgets.initialize();
   ```
2. Bungkus root widget aplikasi menggunakan `LiquidGlassWidgets.wrap`:
   ```dart
   runApp(
     ProviderScope(
       child: LiquidGlassWidgets.wrap(
         brightnessResolver: Theme.maybeBrightnessOf,
         child: const MyQuranApp(),
       ),
     ),
   );
   ```

---

## 2. Sentralisasi Ekspor (`lib/features/widgets/liquid_glass.dart`)

Semua komponen Liquid Glass diekspor melalui satu pintu:
```dart
import '../widgets/liquid_glass.dart';
```
Ekspor mencakup:
* `GlassTabBar`, `GlassTab`
* `GlassSwitch`
* `GlassSegmentedControl`, `GlassSegment`
* `GlassChip`, `GlassButton`, `GlassIconButton`
* `GlassCard`, `GlassContainer`

---

## 3. Prinsip Desain & Aturan Visual

### A. Kaca Bening & Netral (Pure Frosted Glass)
* **Kaca Tidak Boleh Diwarnai Pekat**: Jangan menambahkan `glowColor` atau warna latar belakang pekat pada wadah kapsul kaca (*capsule/track*).
* Material Liquid Glass harus **tetap bening, transparan, dan memantulkan/merefraksi latar belakang** menggunakan shader asli.

### B. Palet Warna Aksen (Hijau Emerald MyQuran)
Hanya **ikon**, **label teks**, dan **indikator seleksi** yang diberi warna aksen:
```dart
final isDark = Theme.of(context).brightness == Brightness.dark;

// Warna elemen saat aktif / terpilih
final activeGreen = isDark ? const Color(0xFF67E8B5) : const Color(0xFF064E3B);

// Warna elemen saat tidak aktif
final inactiveColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
```

### C. Layering Standalone (`useOwnLayer: true`)
* Bila komponen digunakan secara mandiri di dalam `Column`, `ListView`, atau `Scaffold` biasa (tanpa pembungkus `AdaptiveLiquidGlassLayer`), **wajib** sertakan:
  ```dart
  useOwnLayer: true
  ```
  Hal ini memastikan shader refraksi bekerja optimal pada elemen tersebut.

---

## 4. Pola Implementasi Komponen

### 1. Bottom Navigation Bar (`lib/app.dart`)
Gunakan `GlassTabBar.bottom` dengan padding minimal agar presisi di atas bar navigasi sistem:
```dart
GlassTabBar.bottom(
  horizontalPadding: 16,
  verticalPadding: 6,
  barHeight: 64,
  selectedIndex: selectedIndex,
  selectedIconColor: activeGreen,
  selectedLabelColor: activeGreen,
  unselectedIconColor: inactiveColor,
  unselectedLabelColor: inactiveColor,
  onTabSelected: (idx) => onSelect(views[idx]),
  tabs: const [
    GlassTab(
      label: 'Beranda',
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home_rounded),
    ),
    // Tab lainnya...
  ],
)
```

### 2. Sakelar / Toggle Switch
Gunakan `GlassSwitch` untuk semua switch di pengaturan atau modul lain:
```dart
GlassSwitch(
  value: isEnabled,
  onChanged: (val) => controller.toggle(val),
  useOwnLayer: true,
)
```

### 3. Pemilihan Segmen / Segmented Control (Mode Tema, Filter, Perataan)
Gunakan `GlassSegmentedControl` dengan indikator kapsul kaca geser (*jelly physics*):
```dart
GlassSegmentedControl(
  useOwnLayer: true,
  selectedIndex: currentIndex,
  onSegmentSelected: (idx) => onSelect(idx),
  selectedIconColor: activeGreen,
  selectedTextStyle: TextStyle(
    color: activeGreen,
    fontWeight: FontWeight.w700,
    fontSize: 13,
  ),
  unselectedTextStyle: TextStyle(
    color: inactiveColor,
    fontWeight: FontWeight.w500,
    fontSize: 13,
  ),
  segments: const [
    GlassSegment(
      label: 'Sistem',
      icon: Icon(Icons.brightness_auto_rounded, size: 18),
    ),
    GlassSegment(
      label: 'Terang',
      icon: Icon(Icons.light_mode_rounded, size: 18),
    ),
    GlassSegment(
      label: 'Gelap',
      icon: Icon(Icons.dark_mode_rounded, size: 18),
    ),
  ],
)
```

### 4. Tombol Aksi / Chips / Uji Notifikasi
Gunakan `GlassChip` untuk tombol aksi kompak atau filter chip:
```dart
GlassChip(
  useOwnLayer: true,
  icon: Icon(
    Icons.volume_up_rounded,
    size: 18,
    color: activeGreen,
  ),
  label: 'Uji Adzan Sholat',
  labelStyle: TextStyle(
    color: isDark ? Colors.white : Colors.black87,
    fontSize: 13,
    fontWeight: FontWeight.w600,
  ),
  onTap: () => testNotification(),
)
```

---

## 5. Anti-Patterns (Hal yang DILARANG)

1. ❌ **Menumpuk Kaca di dalam Kaca**: Jangan membungkus `GlassSegmentedControl`, `GlassSwitch`, atau `GlassTabBar` di dalam `GlassContainer` / `GlassCard` lain karena akan memicu `avoidsRefraction` dan mematikan animasi jelly.
2. ❌ **Memberi Tint Hijau pada Kaca**: Jangan memberikan warna hijau pekat pada body kaca. Kaca harus tetap transparan/bening dengan blur; hanya teks/ikon yang berwarna hijau.
3. ❌ **Mengubah Struktur UI Dasar**: Jangan merombak struktur layout atau arsitektur screen yang sudah ada saat menambahkan efek glass.

---

## 6. Verifikasi & Build

Setelah mengubah atau menambahkan komponen Liquid Glass:
1. Jalankan unit test:
   ```bash
   flutter test
   ```
2. Build dan uji coba di perangkat:
   ```bash
   flutter build apk --release && adb install -r build/app/outputs/flutter-apk/app-release.apk
   ```
