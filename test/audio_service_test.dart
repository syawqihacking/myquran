import 'package:flutter_test/flutter_test.dart';
import 'package:myquran/data/services/just_audio_service.dart';

void main() {
  group('audioUrlFor', () {
    test('zero-pads surah and ayah to 3 digits', () {
      expect(
        audioUrlFor(
          2,
          255,
          'https://everyayah.com/data/Alafasy_128kbps/{SSS}{AAA}.mp3',
        ),
        'https://everyayah.com/data/Alafasy_128kbps/002255.mp3',
      );
    });

    test('handles 3-digit surah and ayah numbers', () {
      expect(
        audioUrlFor(
          114,
          6,
          'https://audio.qurancdn.com/Alafasy/mp3/{SSS}{AAA}.mp3',
        ),
        'https://audio.qurancdn.com/Alafasy/mp3/114006.mp3',
      );
    });

    test('handles single-digit values', () {
      expect(audioUrlFor(1, 1, 'https://x/{SSS}{AAA}.mp3'),
          'https://x/001001.mp3');
    });

    test('cache filename derives from the same padding', () {
      expect(audioUrlFor(2, 255, '{SSS}{AAA}.mp3'), '002255.mp3');
    });
  });
}