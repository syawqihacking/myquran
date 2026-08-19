/// Zakat calculator — pure logic, no Flutter UI dependency.
///
/// Standard Indonesian fiqh (BAZNAS-style) rules:
/// - Fitrah: 2.5 kg rice per person.
/// - Mal (wealth): nisab 85 gram gold, rate 2.5%.
/// - Gold & silver: nisab 85 gram gold / 595 gram silver, rate 2.5% each.
/// - Income: nisab = annual gold nisab / 12, rate 2.5%.
/// - Agriculture: nisab 520 kg of staple crops, rate 10% (natural irrigation)
///   or 5% (paid irrigation).
enum ZakatType { fitrah, mal, emasPerak, penghasilan, pertanian }

/// Result of a zakat calculation.
class ZakatResult {
  final bool wajib; // reaches nisab or not
  final double nisab; // nisab value in the relevant unit (kg/gram/rupiah)
  final double zakat; // zakat amount to pay (rupiah, or kg for pertanian)
  final String? catatan; // optional note (e.g. "Belum mencapai nisab")

  const ZakatResult({
    required this.wajib,
    required this.nisab,
    required this.zakat,
    this.catatan,
  });
}

class ZakatCalculator {
  // Nisab constants.
  static const double fitrahBerasPerJiwa = 2.5; // kg of rice per person
  static const double nisabEmasGram = 85; // gram of gold
  static const double nisabPerakGram = 595; // gram of silver
  static const double nisabPertanianKg = 520; // kg of staple crops
  static const double rateMal = 0.025; // 2.5%
  static const double rateIrigasiAlami = 0.10; // 10%
  static const double rateIrigasiBerbayar = 0.05; // 5%
  static const double bulanPerTahun = 12;

  /// Zakat fitrah: 2.5 kg of rice per person × price per kg.
  /// Always obligatory (no nisab). Returns zakat in rupiah.
  static ZakatResult hitungFitrah({
    required int jumlahJiwa,
    required double hargaBerasPerKg,
  }) {
    final zakat = jumlahJiwa * fitrahBerasPerJiwa * hargaBerasPerKg;
    return ZakatResult(
      wajib: true,
      nisab: fitrahBerasPerJiwa, // kg per person
      zakat: zakat,
    );
  }

  /// Zakat mal: nisab = 85 gram gold × gold price/gram; rate 2.5% of total wealth.
  static ZakatResult hitungMal({
    required double totalHarta,
    required double hargaEmasPerGram,
  }) {
    final nisab = nisabEmasGram * hargaEmasPerGram;
    if (totalHarta >= nisab) {
      return ZakatResult(wajib: true, nisab: nisab, zakat: totalHarta * rateMal);
    }
    return ZakatResult(
      wajib: false,
      nisab: nisab,
      zakat: 0,
      catatan: 'Belum mencapai nisab',
    );
  }

  /// Zakat gold & silver: gold nisab 85 gram, silver nisab 595 gram;
  /// rate 2.5% for each. Nisab shown as 85 gram (gold).
  static ZakatResult hitungEmasPerak({
    required double gramEmas,
    required double gramPerak,
    required double hargaEmasPerGram,
    required double hargaPerakPerGram,
  }) {
    final zakatEmas =
        gramEmas >= nisabEmasGram ? gramEmas * hargaEmasPerGram * rateMal : 0.0;
    final zakatPerak =
        gramPerak >= nisabPerakGram ? gramPerak * hargaPerakPerGram * rateMal : 0.0;
    final zakat = zakatEmas + zakatPerak;
    return ZakatResult(
      wajib: zakat > 0,
      nisab: nisabEmasGram, // gram, shown for display
      zakat: zakat,
    );
  }

  /// Zakat income: monthly nisab = (85 gram gold × price/gram) / 12; rate 2.5%.
  static ZakatResult hitungPenghasilan({
    required double penghasilanPerBulan,
    required double hargaEmasPerGram,
  }) {
    final nisab = (nisabEmasGram * hargaEmasPerGram) / bulanPerTahun;
    if (penghasilanPerBulan >= nisab) {
      return ZakatResult(
        wajib: true,
        nisab: nisab,
        zakat: penghasilanPerBulan * rateMal,
      );
    }
    return ZakatResult(
      wajib: false,
      nisab: nisab,
      zakat: 0,
      catatan: 'Belum mencapai nisab',
    );
  }

  /// Zakat agriculture: nisab 520 kg; rate 10% (natural irrigation) or
  /// 5% (paid irrigation). Zakat returned in kg when [hargaHasilPerKg] is 0,
  /// or converted to rupiah (zakatKg × price) when > 0.
  static ZakatResult hitungPertanian({
    required double hasilPanenKg,
    required bool irigasiBerbayar,
    double hargaHasilPerKg = 0,
  }) {
    final rate = irigasiBerbayar ? rateIrigasiBerbayar : rateIrigasiAlami;
    if (hasilPanenKg < nisabPertanianKg) {
      return ZakatResult(
        wajib: false,
        nisab: nisabPertanianKg,
        zakat: 0,
        catatan: 'Belum mencapai nisab',
      );
    }
    final zakatKg = hasilPanenKg * rate;
    final zakat = hargaHasilPerKg > 0 ? zakatKg * hargaHasilPerKg : zakatKg;
    return ZakatResult(
      wajib: true,
      nisab: nisabPertanianKg,
      zakat: zakat,
    );
  }
}
