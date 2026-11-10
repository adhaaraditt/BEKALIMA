import 'package:flutter_test/flutter_test.dart';
import 'package:bekalima/utils/currency.dart';

void main() {
  test('formatRupiah adds thousand separators', () {
    expect(formatRupiah(0), 'Rp 0');
    expect(formatRupiah(28000), 'Rp 28.000');
    expect(formatRupiah(1234567), 'Rp 1.234.567');
  });
}
