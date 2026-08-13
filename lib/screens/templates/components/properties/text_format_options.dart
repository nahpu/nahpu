import 'package:material_ui/material_ui.dart';

typedef TextFormatOption = ({String value, String label});

const kTextTypeOptions = <TextFormatOption>[
  (value: 'normal', label: 'Normal Text'),
  (value: 'markdown', label: 'Markdown'),
  (value: 'coordinates', label: 'Coordinates'),
  (value: 'list', label: 'List Values'),
  (value: 'nestedList', label: 'Nested List'),
  (value: 'date', label: 'Dates'),
  (value: 'datetime', label: 'Date and Time'),
  (value: 'time', label: 'Time'),
  (value: 'sex', label: 'Sex'),
  (value: 'number', label: 'Number'),
  (value: 'encoded', label: 'Encoded Text'),
];

const kTextFormatOptions = <String, List<TextFormatOption>>{
  'encoded': [
    (value: 'enum', label: 'Default mapping'),
    (value: 'custom', label: 'Custom mapping...'),
  ],
  'coordinates': [
    (value: 'decimal', label: 'Decimal (45.123, -122.543)'),
    (value: 'cardinalDecimal', label: 'Cardinal Dec (45.123° N, 122.543° W)'),
    (value: 'dms', label: 'DMS (45° 7\' 24" N, 122° 32\' 35" W)'),
    (value: 'ddm', label: 'DDM (45° 7.407\' N, 122° 32.592\' W)'),
  ],
  'list': [
    (value: 'pipe', label: 'Pipe separated (A | B | C)'),
    (value: 'comma', label: 'Comma separated (A, B, C)'),
    (value: 'semicolon', label: 'Semicolon separated (A; B; C)'),
    (value: 'slash', label: 'Slash separated (A / B / C)'),
    (value: 'newline', label: 'New line (A\nB\nC)'),
    (value: 'bullet', label: 'Bulleted (• A\n• B)'),
    (value: 'custom', label: 'Custom separator...'),
  ],
  'nestedList': [
    (value: 'table', label: 'Table'),
    (value: 'cardList', label: 'Card list'),
  ],
  'date': [
    (value: 'yyyy-mm-dd', label: 'YYYY-MM-DD (2026-06-28)'),
    (value: 'dd-mm-yyyy', label: 'DD-MM-YYYY (28-06-2026)'),
    (value: 'mm-dd-yyyy', label: 'MM-DD-YYYY (06-28-2026)'),
    (value: 'dd/mm/yyyy', label: 'DD/MM/YYYY (28/06/2026)'),
    (value: 'mm/dd/yyyy', label: 'MM/DD/YYYY (06/28/2026)'),
    (value: 'month-dd-yyyy', label: 'Month DD, YYYY (June 28, 2026)'),
    (value: 'dd-month-yyyy', label: 'DD Month YYYY (28 June 2026)'),
    (value: 'dd-month-abbr-yyyy', label: 'DD Month (Abbr) (28 Jun 2026)'),
  ],
  'datetime': [
    (value: 'yyyy-mm-dd-hm', label: 'YYYY-MM-DD 24h (2026-06-28 14:05)'),
    (
      value: 'yyyy-mm-dd-hms',
      label: 'YYYY-MM-DD seconds (2026-06-28 14:05:09)'
    ),
    (value: 'iso-minutes', label: 'ISO minutes (2026-06-28T14:05)'),
    (value: 'iso-seconds', label: 'ISO seconds (2026-06-28T14:05:09)'),
    (value: 'dd-mm-yyyy-hm', label: 'DD-MM-YYYY 24h (28-06-2026 14:05)'),
    (value: 'mm-dd-yyyy-hm', label: 'MM-DD-YYYY 24h (06-28-2026 14:05)'),
    (value: 'dd/mm/yyyy-hm', label: 'DD/MM/YYYY 24h (28/06/2026 14:05)'),
    (value: 'mm/dd/yyyy-hm', label: 'MM/DD/YYYY 12h (06/28/2026 2:05 PM)'),
    (value: 'yyyy/mm/dd-hm', label: 'YYYY/MM/DD 24h (2026/06/28 14:05)'),
    (
      value: 'dd-month-yyyy-hm',
      label: 'DD Month YYYY 24h (28 June 2026 14:05)'
    ),
    (
      value: 'month-dd-yyyy-hm',
      label: 'Month DD, YYYY 12h (June 28, 2026 2:05 PM)'
    ),
    (
      value: 'dd-month-abbr-yyyy-hm',
      label: 'DD Mon YYYY 24h (28 Jun 2026 14:05)'
    ),
    (
      value: 'month-abbr-dd-yyyy-hm',
      label: 'Mon DD, YYYY 12h (Jun 28, 2026 2:05 PM)'
    ),
    (value: 'time-24', label: 'Time 24h (14:05)'),
    (value: 'time-24-seconds', label: 'Time 24h seconds (14:05:09)'),
    (value: 'time-12', label: 'Time 12h (2:05 PM)'),
    (value: 'time-12-padded', label: 'Time 12h padded (02:05 PM)'),
  ],
  'time': [
    (value: 'time-24', label: 'Time 24h (14:05)'),
    (value: 'time-24-seconds', label: 'Time 24h seconds (14:05:09)'),
    (value: 'time-12', label: 'Time 12h (2:05 PM)'),
    (value: 'time-12-padded', label: 'Time 12h padded (02:05 PM)'),
  ],
  'number': [
    (value: 'original', label: 'Original'),
    (value: '0', label: '0 decimal places (e.g. 12)'),
    (value: '1', label: '1 decimal place (e.g. 12.3)'),
    (value: '2', label: '2 decimal places (e.g. 12.34)'),
    (value: '3', label: '3 decimal places (e.g. 12.345)'),
  ],
  'normal': [
    (value: 'normal', label: 'Normal'),
    (value: 'uppercase', label: 'Uppercase'),
    (value: 'lowercase', label: 'Lowercase'),
    (value: 'capitalize', label: 'Capitalize'),
  ],
  'markdown': [(value: 'normal', label: 'Normal')],
};

const kSexPresentationOptions = <TextFormatOption>[
  (value: 'symbol', label: 'Symbol (♂/♀)'),
  (value: 'letter', label: 'Letter (M/F)'),
  (value: 'text', label: 'Text (Male/Female)'),
];

const kSexMissingOptions = <TextFormatOption>[
  (value: 'unknown', label: 'Unknown'),
  (value: 'na', label: 'N/A'),
  (value: 'none', label: 'None'),
];

List<DropdownMenuItem<String>> textFormatDropdownItems(String textType) {
  final options = kTextFormatOptions[textType] ?? kTextFormatOptions['normal']!;
  return options
      .map(
        (option) => DropdownMenuItem<String>(
          value: option.value,
          child: Text(option.label),
        ),
      )
      .toList(growable: false);
}

List<DropdownMenuItem<String>> textDropdownItems(
  List<TextFormatOption> options,
) {
  return options
      .map(
        (option) => DropdownMenuItem<String>(
          value: option.value,
          child: Text(option.label),
        ),
      )
      .toList(growable: false);
}
