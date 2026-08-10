final RegExp _orcidPattern = RegExp(r'^\d{4}-\d{4}-\d{4}-\d{3}[\dX]$');

bool isValidOrcid(String value) {
  if (!_orcidPattern.hasMatch(value)) return false;
  final characters = value.replaceAll('-', '').split('');
  var total = 0;
  for (final character in characters.take(15)) {
    total = (total + int.parse(character)) * 2;
  }
  final remainder = total % 11;
  final result = (12 - remainder) % 11;
  final checkDigit = result == 10 ? 'X' : result.toString();
  return characters.last == checkDigit;
}

String? canonicalOrcidUrl(String? value) {
  if (value == null || !isValidOrcid(value)) return null;
  return 'https://orcid.org/$value';
}
