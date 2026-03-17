import 'package:flutter_test/flutter_test.dart';
import 'package:reels/core/utils/format_utils.dart';

void main() {
  group('FormatUtils.formatCount', () {
    test('formats numbers below 1000 as-is', () {
      expect(FormatUtils.formatCount(0), '0');
      expect(FormatUtils.formatCount(1), '1');
      expect(FormatUtils.formatCount(999), '999');
    });

    test('formats thousands with K suffix', () {
      expect(FormatUtils.formatCount(1000), '1.0K');
      expect(FormatUtils.formatCount(1500), '1.5K');
      expect(FormatUtils.formatCount(10000), '10.0K');
      expect(FormatUtils.formatCount(999999), '1000.0K');
    });

    test('formats millions with M suffix', () {
      expect(FormatUtils.formatCount(1000000), '1.0M');
      expect(FormatUtils.formatCount(2500000), '2.5M');
    });
  });
}
