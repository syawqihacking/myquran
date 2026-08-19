import 'package:flutter_test/flutter_test.dart';
import 'package:myquran/data/models/zakat_calculator.dart';

void main() {
  group('ZakatCalculator.hitungFitrah', () {
    test('4 jiwa × 2.5 kg × Rp12.000 = Rp120.000, selalu wajib', () {
      final result = ZakatCalculator.hitungFitrah(
        jumlahJiwa: 4,
        hargaBerasPerKg: 12000,
      );
      expect(result.wajib, isTrue);
      expect(result.zakat, closeTo(120000, 0.01));
      expect(result.nisab, closeTo(2.5, 0.01));
      expect(result.catatan, isNull);
    });
  });

  group('ZakatCalculator.hitungMal', () {
    test('harta di bawah nisab (85 gram emas) → belum wajib', () {
      final result = ZakatCalculator.hitungMal(
        totalHarta: 10000000,
        hargaEmasPerGram: 1000000,
      );
      expect(result.nisab, closeTo(85000000, 0.01));
      expect(result.wajib, isFalse);
      expect(result.zakat, 0);
      expect(result.catatan, 'Belum mencapai nisab');
    });

    test('harta di atas nisab → wajib, zakat 2.5%', () {
      final result = ZakatCalculator.hitungMal(
        totalHarta: 100000000,
        hargaEmasPerGram: 1000000,
      );
      expect(result.wajib, isTrue);
      expect(result.zakat, closeTo(2500000, 0.01));
    });
  });

  group('ZakatCalculator.hitungEmasPerak', () {
    test('emas 100 g (>= nisab) wajib, perak 500 g (di bawah nisab) = 0', () {
      final result = ZakatCalculator.hitungEmasPerak(
        gramEmas: 100,
        gramPerak: 500,
        hargaEmasPerGram: 1000000,
        hargaPerakPerGram: 10000,
      );
      expect(result.wajib, isTrue);
      expect(result.zakat, closeTo(2500000, 0.01)); // 100 × 1.000.000 × 0.025
      expect(result.nisab, closeTo(85, 0.01));
      expect(result.catatan, isNull);
    });

    test('emas dan perak di bawah nisab → belum wajib', () {
      final result = ZakatCalculator.hitungEmasPerak(
        gramEmas: 80,
        gramPerak: 500,
        hargaEmasPerGram: 1000000,
        hargaPerakPerGram: 10000,
      );
      expect(result.wajib, isFalse);
      expect(result.zakat, 0);
    });
  });

  group('ZakatCalculator.hitungPenghasilan', () {
    test('penghasilan di atas nisab bulanan → wajib, zakat 2.5%', () {
      final result = ZakatCalculator.hitungPenghasilan(
        penghasilanPerBulan: 8000000,
        hargaEmasPerGram: 1000000,
      );
      expect(result.nisab, closeTo(7083333.33, 0.01));
      expect(result.wajib, isTrue);
      expect(result.zakat, closeTo(200000, 0.01));
    });

    test('penghasilan di bawah nisab bulanan → belum wajib', () {
      final result = ZakatCalculator.hitungPenghasilan(
        penghasilanPerBulan: 5000000,
        hargaEmasPerGram: 1000000,
      );
      expect(result.wajib, isFalse);
      expect(result.zakat, 0);
      expect(result.catatan, 'Belum mencapai nisab');
    });
  });

  group('ZakatCalculator.hitungPertanian', () {
    test('600 kg irigasi alami → zakat 60 kg', () {
      final result = ZakatCalculator.hitungPertanian(
        hasilPanenKg: 600,
        irigasiBerbayar: false,
      );
      expect(result.wajib, isTrue);
      expect(result.zakat, closeTo(60, 0.01));
      expect(result.nisab, closeTo(520, 0.01));
    });

    test('600 kg irigasi berbayar → zakat 30 kg', () {
      final result = ZakatCalculator.hitungPertanian(
        hasilPanenKg: 600,
        irigasiBerbayar: true,
      );
      expect(result.wajib, isTrue);
      expect(result.zakat, closeTo(30, 0.01));
    });

    test('600 kg dengan harga hasil → zakat dalam rupiah', () {
      final result = ZakatCalculator.hitungPertanian(
        hasilPanenKg: 600,
        irigasiBerbayar: false,
        hargaHasilPerKg: 10000,
      );
      expect(result.wajib, isTrue);
      expect(result.zakat, closeTo(600000, 0.01));
    });

    test('400 kg → belum wajib', () {
      final result = ZakatCalculator.hitungPertanian(
        hasilPanenKg: 400,
        irigasiBerbayar: false,
      );
      expect(result.wajib, isFalse);
      expect(result.zakat, 0);
      expect(result.catatan, 'Belum mencapai nisab');
    });
  });
}
