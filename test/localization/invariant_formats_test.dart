import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:nahpu/services/common/utility_services.dart';
import 'package:nahpu/services/database/migration_utilities.dart';

void main() {
  setUpAll(initializeDateFormatting);

  for (final region in ['de_DE', 'id_ID', 'pt_BR', 'fr_CA']) {
    group('with the regional format $region', () {
      late String? previous;

      setUp(() {
        previous = Intl.defaultLocale;
        Intl.defaultLocale = region;
      });

      tearDown(() => Intl.defaultLocale = previous);

      test('stored dates and times stay ISO', () {
        final date = DateTime(2024, 3, 18, 14, 5);
        expect(dateTimeToDateStd(date), '2024-03-18');
        expect(dateStdToDateTime('2024-03-18'), DateTime(2024, 3, 18));
        expect(timeStdToTimeOfDay('14:05:00')?.hour, 14);
        expect(
          getSystemDateTime(),
          matches(RegExp(r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$')),
        );
      });

      test('legacy migration still reads English dates', () {
        expect(convertDateString('Mar 18, 2024'), '2024-03-18');
        expect(convertTimeString('2:05 PM'), '14:05:00');
      });

      test('display dates follow the region', () {
        expect(
          dateStdToDateDisplay('2024-03-18'),
          DateFormat.yMMMd(region).format(DateTime(2024, 3, 18)),
        );
      });
    });
  }
}
