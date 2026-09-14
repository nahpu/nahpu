import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/templates/template_model.dart';

void main() {
  test('formats every date in a line', () {
    expect(
      formatTemplateText(
        'Collected 2024-05-03, prepared 2024-06-10',
        'date',
        'dd-month-abbr-yyyy',
      ),
      'Collected 3 May 2024, prepared 10 Jun 2024',
    );
  });

  test('formats every date and time in a line', () {
    expect(
      formatTemplateText(
        'Set 2024-05-03T08:15, checked 2024-05-04 17:45',
        'datetime',
        'dd-month-abbr-yyyy-hm',
      ),
      'Set 3 May 2024 08:15, checked 4 May 2024 17:45',
    );
  });

  test('formats every time in a line', () {
    expect(
      formatTemplateText('Open 08:15, close 17:45', 'time', 'time-12'),
      'Open 8:15 AM, close 5:45 PM',
    );
  });

  test('a single date still formats and text without one is unchanged', () {
    expect(formatDateText('2024-05-03', 'dd/mm/yyyy'), '03/05/2024');
    expect(
      formatDateText('No date recorded', 'dd/mm/yyyy'),
      'No date recorded',
    );
  });
}
