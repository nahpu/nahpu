/// The escape character [escapeLikePattern] uses, for `LIKE ... ESCAPE`.
const String likeEscapeChar = r'\';

/// Makes `%`, `_`, and `\` match literally in a LIKE pattern.
String escapeLikePattern(String value) =>
    value.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_');
