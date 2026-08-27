import 'package:flutter/material.dart';

import '../../core/app_layout.dart';
import '../../l10n/app_localizations.dart';
import '../../data/models/zakat_calculator.dart';

/// Kalkulator Zakat — M3 form per jenis zakat (fitrah, mal, emas & perak,
/// penghasilan, pertanian) yang menghitung lewat [ZakatCalculator].
///
/// Pilihan jenis memakai TabBar scrollable (5 tab melebihi lebar layar kecil
/// untuk SegmentedButton), form input angka per jenis, tombol hitung penuh,
/// dan kartu hasil: status wajib/belum, nisab, dan jumlah zakat. Format
/// rupiah memakai pemisah ribuan manual ('Rp 1.234.567') tanpa dependency
/// tambahan.
class ZakatCalculatorScreen extends StatefulWidget {
  const ZakatCalculatorScreen({super.key});

  @override
  State<ZakatCalculatorScreen> createState() => _ZakatCalculatorScreenState();
}

class _ZakatCalculatorScreenState extends State<ZakatCalculatorScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController =
      TabController(length: ZakatType.values.length, vsync: this);

  final TextEditingController _jumlahJiwa = TextEditingController();
  final TextEditingController _hargaBeras = TextEditingController();
  final TextEditingController _totalHarta = TextEditingController();
  final TextEditingController _hargaEmas = TextEditingController();
  final TextEditingController _gramEmas = TextEditingController();
  final TextEditingController _gramPerak = TextEditingController();
  final TextEditingController _hargaPerak = TextEditingController();
  final TextEditingController _penghasilan = TextEditingController();
  final TextEditingController _hasilPanen = TextEditingController();
  final TextEditingController _hargaHasil = TextEditingController();

  bool _irigasiBerbayar = false;
  ZakatResult? _result;

  @override
  void dispose() {
    _tabController.dispose();
    for (final c in <TextEditingController>[
      _jumlahJiwa,
      _hargaBeras,
      _totalHarta,
      _hargaEmas,
      _gramEmas,
      _gramPerak,
      _hargaPerak,
      _penghasilan,
      _hasilPanen,
      _hargaHasil,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  ZakatType get _type => ZakatType.values[_tabController.index];

  // ── Parsing & validasi ──────────────────────────────────────────────

  /// Parse angka gaya Indonesia: titik ribuan ('.') dan koma desimal (',')
  /// keduanya diterima. '1.500.000' → 1500000, '1,5' → 1.5.
  double? _num(String raw) {
    final cleaned = raw.trim().replaceAll('.', '').replaceAll(',', '.');
    if (cleaned.isEmpty) return null;
    return double.tryParse(cleaned);
  }

  int? _int(String raw) {
    final cleaned = raw.trim().replaceAll('.', '');
    if (cleaned.isEmpty) return null;
    return int.tryParse(cleaned);
  }

  bool _priceFilled(TextEditingController c) {
    final v = _num(c.text);
    return v != null && v > 0;
  }

  bool get _fieldsValid {
    switch (_type) {
      case ZakatType.fitrah:
        final jiwa = _int(_jumlahJiwa.text);
        return jiwa != null && jiwa >= 1 && _priceFilled(_hargaBeras);
      case ZakatType.mal:
        return _num(_totalHarta.text) != null && _priceFilled(_hargaEmas);
      case ZakatType.emasPerak:
        return _num(_gramEmas.text) != null &&
            _num(_gramPerak.text) != null &&
            _priceFilled(_hargaEmas) &&
            _priceFilled(_hargaPerak);
      case ZakatType.penghasilan:
        return _num(_penghasilan.text) != null && _priceFilled(_hargaEmas);
      case ZakatType.pertanian:
        // Harga hasil panen opsional — kosong berarti hasil dalam kg.
        final hasPanen = _num(_hasilPanen.text) != null;
        final hargaOk = _hargaHasil.text.trim().isEmpty ||
            _priceFilled(_hargaHasil);
        return hasPanen && hargaOk;
    }
  }

  void _hitung() {
    final l10n = AppLocalizations.of(context)!;
    if (!_fieldsValid) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.zakatFieldRequired)));
      return;
    }
    final result = switch (_type) {
      ZakatType.fitrah => ZakatCalculator.hitungFitrah(
          jumlahJiwa: _int(_jumlahJiwa.text)!,
          hargaBerasPerKg: _num(_hargaBeras.text)!,
        ),
      ZakatType.mal => ZakatCalculator.hitungMal(
          totalHarta: _num(_totalHarta.text)!,
          hargaEmasPerGram: _num(_hargaEmas.text)!,
        ),
      ZakatType.emasPerak => ZakatCalculator.hitungEmasPerak(
          gramEmas: _num(_gramEmas.text)!,
          gramPerak: _num(_gramPerak.text)!,
          hargaEmasPerGram: _num(_hargaEmas.text)!,
          hargaPerakPerGram: _num(_hargaPerak.text)!,
        ),
      ZakatType.penghasilan => ZakatCalculator.hitungPenghasilan(
          penghasilanPerBulan: _num(_penghasilan.text)!,
          hargaEmasPerGram: _num(_hargaEmas.text)!,
        ),
      ZakatType.pertanian => ZakatCalculator.hitungPertanian(
          hasilPanenKg: _num(_hasilPanen.text)!,
          irigasiBerbayar: _irigasiBerbayar,
          hargaHasilPerKg: _hargaHasil.text.trim().isEmpty
              ? 0
              : _num(_hargaHasil.text)!,
        ),
    };
    setState(() => _result = result);
  }

  // ── Format (manual, tanpa intl) ─────────────────────────────────────

  /// 1234567 → '1.234.567'
  String _formatThousands(num value) {
    final s = value.round().toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      buf.write(s[i]);
      final remaining = s.length - 1 - i;
      if (remaining > 0 && remaining % 3 == 0) buf.write('.');
    }
    return buf.toString();
  }

  String _formatRupiah(num value) {
    final l10n = AppLocalizations.of(context)!;
    return '${l10n.zakatRupiah} ${_formatThousands(value)}';
  }

  String _nisabText(ZakatResult r) => switch (_type) {
        ZakatType.fitrah =>
          '${r.nisab.toStringAsFixed(1).replaceAll('.', ',')} kg/jiwa',
        ZakatType.emasPerak => '${r.nisab.round()} gram emas',
        ZakatType.pertanian => '${r.nisab.round()} kg',
        ZakatType.mal || ZakatType.penghasilan => _formatRupiah(r.nisab),
      };

  String _zakatText(ZakatResult r) {
    if (r.zakat == 0) return '—';
    // Pertanian tanpa harga: hasil zakat dalam kg.
    if (_type == ZakatType.pertanian && _hargaHasil.text.trim().isEmpty) {
      return '${_formatThousands(r.zakat)} kg';
    }
    return _formatRupiah(r.zakat);
  }

  // ── Build ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.zakatTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppLayout.sp4,
            AppLayout.sp3,
            AppLayout.sp4,
            AppLayout.sp8,
          ),
          children: [
            Text(
              l10n.zakatSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppLayout.sp3),
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              onTap: (_) => setState(() => _result = null),
              tabs: [
                Tab(text: l10n.zakatTabFitrah),
                Tab(text: l10n.zakatTabMal),
                Tab(text: l10n.zakatTabEmasPerak),
                Tab(text: l10n.zakatTabPenghasilan),
                Tab(text: l10n.zakatTabPertanian),
              ],
            ),
            const SizedBox(height: AppLayout.sp4),
            _buildForm(),
            const SizedBox(height: AppLayout.sp4),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _hitung,
                icon: const Icon(Icons.calculate_rounded),
                label: Text(l10n.zakatHitung),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppLayout.sp3),
                ),
              ),
            ),
            if (_result != null) ...[
              const SizedBox(height: AppLayout.sp4),
              _ResultCard(
                wajib: _result!.wajib,
                nisabText: _nisabText(_result!),
                zakatText: _zakatText(_result!),
                catatan: _result!.catatan,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    switch (_type) {
      case ZakatType.fitrah:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _field(
              controller: _jumlahJiwa,
              label: l10n.zakatJumlahJiwa,
              allowDecimal: false,
            ),
            const SizedBox(height: AppLayout.sp3),
            _field(
              controller: _hargaBeras,
              label: l10n.zakatHargaBeras,
              rupiah: true,
            ),
          ],
        );
      case ZakatType.mal:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _field(
              controller: _totalHarta,
              label: l10n.zakatTotalHarta,
              rupiah: true,
            ),
            const SizedBox(height: AppLayout.sp3),
            _field(controller: _hargaEmas, label: l10n.zakatHargaEmas, rupiah: true),
          ],
        );
      case ZakatType.emasPerak:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _field(
                    controller: _gramEmas,
                    label: l10n.zakatGramEmas,
                  ),
                ),
                const SizedBox(width: AppLayout.sp3),
                Expanded(
                  child: _field(
                    controller: _gramPerak,
                    label: l10n.zakatGramPerak,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppLayout.sp3),
            _field(controller: _hargaEmas, label: l10n.zakatHargaEmas, rupiah: true),
            const SizedBox(height: AppLayout.sp3),
            _field(controller: _hargaPerak, label: l10n.zakatHargaPerak, rupiah: true),
          ],
        );
      case ZakatType.penghasilan:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _field(
              controller: _penghasilan,
              label: l10n.zakatPenghasilanBulanan,
              rupiah: true,
            ),
            const SizedBox(height: AppLayout.sp3),
            _field(controller: _hargaEmas, label: l10n.zakatHargaEmas, rupiah: true),
          ],
        );
      case ZakatType.pertanian:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _field(controller: _hasilPanen, label: l10n.zakatHasilPanen),
            const SizedBox(height: AppLayout.sp3),
            _field(
              controller: _hargaHasil,
              label: l10n.zakatHargaHasil,
              rupiah: true,
              helperText: l10n.zakatHargaHasilHint,
            ),
            const SizedBox(height: AppLayout.sp4),
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(
                  value: false,
                  icon: Icon(Icons.water_drop_outlined, size: 16),
                  label: Text(l10n.zakatIrigasiAlami),
                ),
                ButtonSegment(
                  value: true,
                  icon: Icon(Icons.water_drop_rounded, size: 16),
                  label: Text(l10n.zakatIrigasiBerbayar),
                ),
              ],
              selected: {_irigasiBerbayar},
              onSelectionChanged: (s) => setState(() {
                _irigasiBerbayar = s.first;
                _result = null;
              }),
              showSelectedIcon: false,
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return scheme.primary.withValues(alpha: 0.28);
                  }
                  return Colors.transparent;
                }),
                side: const WidgetStatePropertyAll(BorderSide.none),
              ),
            ),
          ],
        );
    }
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    bool rupiah = false,
    bool allowDecimal = true,
    String? helperText,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        prefixText: rupiah ? '${l10n.zakatRupiah} ' : null,
        filled: true,
        fillColor: scheme.surfaceContainerLow.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppLayout.radiusMd),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppLayout.radiusMd),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppLayout.radiusMd),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
    );
  }
}

/// Kartu hasil: status wajib/belum (hijau/abu), nisab, dan jumlah zakat.
class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.wajib,
    required this.nisabText,
    required this.zakatText,
    this.catatan,
  });

  final bool wajib;
  final String nisabText;
  final String zakatText;
  final String? catatan;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final statusColor = wajib ? scheme.primary : scheme.onSurfaceVariant;
    final statusBg =
        wajib ? scheme.primaryContainer : scheme.surfaceContainerHighest;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppLayout.sp4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppLayout.radiusLg),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppLayout.sp3,
              vertical: AppLayout.sp1 + 2,
            ),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(AppLayout.radiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  wajib
                      ? Icons.check_circle_rounded
                      : Icons.info_outline_rounded,
                  size: 18,
                  color: statusColor,
                ),
                const SizedBox(width: AppLayout.sp1 + 2),
                Text(
                  wajib ? l10n.zakatWajib : l10n.zakatBelumWajib,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppLayout.sp4),
          _ResultRow(label: l10n.zakatNisab, value: nisabText),
          const SizedBox(height: AppLayout.sp2),
          _ResultRow(
            label: l10n.zakatJumlahZakat,
            value: zakatText,
            valueStyle: theme.textTheme.titleLarge?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (catatan != null) ...[
            const SizedBox(height: AppLayout.sp3),
            Text(
              catatan!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: AppLayout.sp3),
        Text(
          value,
          textAlign: TextAlign.end,
          style: valueStyle ??
              theme.textTheme.titleMedium?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
