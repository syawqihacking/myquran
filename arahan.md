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
* `GlassTabBar`, `GlassTab` (Bottom Nav Bar)
* `GlassSwitch` (Toggle switch pengaturan)
* `GlassSegmentedControl`, `GlassSegment` (Segmented control pilihan tema/filter/tab)
* `GlassChip`, `GlassButton`, `GlassIconButton` (Tombol aksi, back button, uji notifikasi)
* `GlassSlider` (Slider ukuran font & audio player)
* `GlassCard`, `GlassContainer` (Kartu hero jadwal sholat, last read, floating audio bar)
* `GlassSearchBar`, `GlassTextField` (Pencarian surah/ayat/doa)
* `GlassModalSheet`, `GlassDialog`, `GlassDialogAction`, `GlassPullDownButton`, `GlassMenu` (Modal tafsir, dialog konfirmasi, menu aksi ayat)
* `GlassBadge`, `GlassProgressIndicator` (Badge status & progress bacaan)
* `AdaptiveLiquidGlassLayer`, `LiquidGlassSettings` (Grouped layer & pengaturan shader)

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

### 5. Title / App Bar & Tombol di Samping Judul (Leading & Action Buttons)

Sesuai filosofi desain Liquid Glass, efek kaca **difokuskan pada tombol-tombol interaktif** (tombol kembali di sisi kiri, dan tombol aksi di samping kanan judul seperti Pencarian, Filter, Bookmark, Audio, atau Pengaturan). Badan App Bar tetap bersih dan transparan/solid agar judul utama tetap tajam dan kontras.

#### A. Tombol Ikon Tunggal (Leading Back & Action Buttons)
Gunakan `GlassIconButton` dengan `useOwnLayer: true`:
```dart
// Tombol Kembali (Leading)
GlassIconButton(
  useOwnLayer: true,
  size: 40,
  icon: const Icon(Icons.arrow_back_rounded),
  onPressed: () => Navigator.of(context).maybePop(),
)

// Tombol Aksi Kanan (Trailing Actions: Search, Bookmark, Filter, dll)
GlassIconButton(
  useOwnLayer: true,
  size: 40,
  icon: Icon(
    Icons.search_rounded,
    color: isDark ? const Color(0xFF67E8B5) : const Color(0xFF064E3B),
  ),
  onPressed: () => openSearch(),
)
```

#### B. Tombol Kapsul / Berlabel di Samping Judul
Bila tombol di samping judul memiliki label teks atau status (misalnya pemutar audio atau pilihan juz/surah), gunakan `GlassChip` atau `GlassButton`:
```dart
GlassChip(
  useOwnLayer: true,
  icon: Icon(Icons.play_arrow_rounded, color: activeGreen, size: 18),
  label: 'Murottal',
  labelStyle: TextStyle(
    color: isDark ? Colors.white : Colors.black87,
    fontWeight: FontWeight.w600,
  ),
  onTap: () => toggleAudioPlayer(),
)
```

#### C. Contoh Susunan Standar di AppBar
```dart
AppBar(
  backgroundColor: Colors.transparent,
  elevation: 0,
  leading: Padding(
    padding: const EdgeInsets.all(8.0),
    child: GlassIconButton(
      useOwnLayer: true,
      size: 40,
      icon: const Icon(Icons.arrow_back_rounded),
      onPressed: () => Navigator.of(context).maybePop(),
    ),
  ),
  title: Text(
    'Al-Baqarah',
    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
  ),
  actions: [
    Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GlassIconButton(
        useOwnLayer: true,
        size: 40,
        icon: const Icon(Icons.search_rounded),
        onPressed: () => openSearch(),
      ),
    ),
    Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: GlassIconButton(
        useOwnLayer: true,
        size: 40,
        icon: const Icon(Icons.bookmark_border_rounded),
        onPressed: () => toggleBookmark(),
      ),
    ),
  ],
)
```

### 6. Slider / Pengatur Nilai (`GlassSlider`)
Gunakan `GlassSlider` untuk kontrol nilai kontinu atau diskrit (seperti ukuran font Arab di Pengaturan, volume suara adzan, atau durasi pemutar audio murottal):
```dart
GlassSlider(
  useOwnLayer: true,
  value: currentFontStep.toDouble(),
  min: 1.0,
  max: 7.0,
  divisions: 6,
  onChanged: (val) => setFontStep(val.round()),
)
```
* **Karakteristik**: Dilengkapi track kaca dengan *jelly thumb* (efek squash & stretch saat digeser) dan *haptic feedback* saat berpindah titik.

### 7. Kartu Kaca & Kontainer Hero (`GlassCard` & `GlassContainer`)
Gunakan `GlassCard` untuk membungkus grup konten penting atau hero banner di atas background bergambar/gradien (misalnya Kartu Jadwal Sholat, Kartu "Terakhir Dibaca", atau Floating Audio Bar):
```dart
GlassCard(
  useOwnLayer: true,
  padding: const EdgeInsets.all(AppLayout.sp4),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Terakhir Dibaca', style: theme.textTheme.titleMedium),
      const SizedBox(height: 4),
      Text('Surah Al-Baqarah : Ayat 255', style: theme.textTheme.bodyMedium),
    ],
  ),
)
```

### 8. Kolom Pencarian & Input Teks (`GlassSearchBar` & `GlassTextField`)
Gunakan `GlassSearchBar` untuk pencarian ayat, surah, atau doa dengan animasi tombol clear & cancel bawaan:
```dart
GlassSearchBar(
  useOwnLayer: true,
  placeholder: 'Cari surah, ayat, atau terjemahan...',
  onChanged: (query) => searchController.search(query),
)
```

### 9. Modal Sheet, Dialog & Popover Aksi
Gunakan modal dan dialog kaca untuk interaksi sekunder yang elegan:
* **Modal Sheet (Tafsir / Pilihan Qari)**:
  ```dart
  GlassModalSheet.show(
    context: context,
    builder: (context) => TafsirContentWidget(ayah: ayah),
  );
  ```
* **Dialog Konfirmasi (Reset / Hapus Data)**:
  ```dart
  GlassDialog.show(
    context: context,
    title: 'Konfirmasi Reset',
    message: 'Apakah Anda yakin ingin menghapus data bacaan?',
    actions: [
      GlassDialogAction(
        label: 'Batal',
        onPressed: () => Navigator.pop(context),
      ),
      GlassDialogAction(
        label: 'Reset',
        isDestructive: true,
        onPressed: () => executeReset(),
      ),
    ],
  );
  ```
* **Menu Popover / Pull Down Button (Opsi Ayat: Salin, Tandai, Bagikan)**:
  ```dart
  GlassPullDownButton(
    useOwnLayer: true,
    items: [
      GlassMenuItem(title: 'Salin Ayat', icon: Icons.copy_rounded, onTap: copyAyah),
      GlassMenuItem(title: 'Simpan Penanda', icon: Icons.bookmark_add_rounded, onTap: bookmarkAyah),
      GlassMenuItem(title: 'Buka Tafsir', icon: Icons.menu_book_rounded, onTap: openTafsir),
    ],
  );
  ```

---

## 5. Pedoman Performa & Skalabilitas Rendering

1. **Aturan `useOwnLayer: true` vs `AdaptiveLiquidGlassLayer`**:
   * Gunakan `useOwnLayer: true` untuk widget mandiri yang terisolasi (Bottom Nav, Switch di baris, Tombol AppBar, Segmented Control).
   * **JANGAN** memasang `useOwnLayer: true` pada ratusan item di dalam `ListView.builder` panjang (misal 286 ayat sekaligus) karena akan membuat ratusan shader pass terpisah di GPU.
   * Untuk daftar panjang, bungkus parent list dengan satu `AdaptiveLiquidGlassLayer` (Grouped Mode) agar seluruh anak berbagi satu pass rendering shader yang sangat efisien.
2. **Auto Adaptive Dark/Light Mode**:
   * Root app sudah dibungkus `LiquidGlassWidgets.wrap(brightnessResolver: Theme.maybeBrightnessOf)`. Shader kaca akan otomatis menyesuaikan reflektivitas cahaya secara real-time saat pengguna mengganti tema.
3. **Kompatibilitas Mesin Grafis (Impeller & Skia)**:
   * Pada Android/iOS dengan backend **Impeller**, widget akan memanfaatkan full compute shader GPU untuk distorsi refraksi cairan 60-120 FPS.
   * Pada perangkat dengan backend **Skia/Web**, library otomatis beralih ke rendering fallback yang ringan dan aman tanpa crash.

---

## 6. Anti-Patterns (Hal yang DILARANG)

1. ❌ **Menumpuk Kaca di dalam Kaca**: Jangan membungkus `GlassSegmentedControl`, `GlassSwitch`, atau `GlassTabBar` di dalam `GlassContainer` / `GlassCard` lain karena akan memicu `avoidsRefraction` dan mematikan animasi jelly.
2. ❌ **Memberi Tint Hijau pada Kaca**: Jangan memberikan warna hijau pekat pada body kaca. Kaca harus tetap transparan/bening dengan blur; hanya teks/ikon yang berwarna hijau.
3. ❌ **Mengubah Struktur UI Dasar**: Jangan merombak struktur layout atau arsitektur screen yang sudah ada saat menambahkan efek glass.
4. ❌ **Over-usage di List View Item**: Jangan membungkus setiap kartu ayat dengan `useOwnLayer: true` secara individual tanpa Grouped Layer.

---

## 7. Verifikasi & Build

Setelah mengubah atau menambahkan komponen Liquid Glass:
1. Jalankan unit test:
   ```bash
   flutter test
   ```
2. Build dan uji coba di perangkat:
   ```bash
   flutter build apk --release && adb install -r build/app/outputs/flutter-apk/app-release.apk
   ```

