import 'dart:io';

const _locales = ['en', 'pt', 'es', 'id'];
const _dayOneFile = 'day-one.mdoc';
const _websiteOrigin = 'https://nahpu.app';

void main(List<String> arguments) {
  final docsRoot = _optionValue(arguments, '--docs-root');
  final write = arguments.contains('--write');
  final check = arguments.contains('--check');
  if (docsRoot == null || write == check) {
    stderr.writeln(
      'Usage: dart run tool/sync_cookbook.dart '
      '--docs-root PATH (--check | --write)',
    );
    exitCode = 64;
    return;
  }

  final canonicalRoot = Directory(
    '${Directory(docsRoot).absolute.path}/src/content/docs',
  );
  if (!canonicalRoot.existsSync()) {
    stderr.writeln('Documentation root not found: ${canonicalRoot.path}');
    exitCode = 66;
    return;
  }

  final appRoot = Directory.current.absolute.path;
  final differences = <String>[];
  for (final locale in _locales) {
    final source = Directory('${canonicalRoot.path}/$locale/how-to-recipes');
    final destination = Directory('$appRoot/assets/docs/cookbook/$locale');
    if (!source.existsSync()) {
      differences.add('Missing canonical directory: ${source.path}');
      continue;
    }
    final sourceFiles = _documentationFiles(source);
    final destinationFiles = destination.existsSync()
        ? _documentationFiles(destination)
        : <String, File>{};

    for (final entry in sourceFiles.entries) {
      final destinationFile = File('${destination.path}/${entry.key}');
      final sourceBytes = entry.value.readAsBytesSync();
      final matches =
          destinationFile.existsSync() &&
          _bytesEqual(sourceBytes, destinationFile.readAsBytesSync());
      if (matches) continue;
      differences.add('$locale/${entry.key}');
      if (write) {
        destinationFile.parent.createSync(recursive: true);
        destinationFile.writeAsBytesSync(sourceBytes);
      }
    }
    for (final relativePath in destinationFiles.keys) {
      if (relativePath == _dayOneFile) continue;
      if (!sourceFiles.containsKey(relativePath)) {
        differences.add('Extra app file: $locale/$relativePath');
      }
    }

    final dayOneDifference = _syncDayOne(
      canonicalRoot: canonicalRoot,
      destination: destination,
      locale: locale,
      write: write,
    );
    if (dayOneDifference != null) differences.add(dayOneDifference);
  }

  if (differences.isEmpty) {
    stdout.writeln('Cookbook files match nahpu-docs.');
    return;
  }
  if (write) {
    stdout.writeln('Copied ${differences.length} changed Cookbook paths.');
    for (final difference in differences.where(
      (value) => value.startsWith('Extra app file:'),
    )) {
      stdout.writeln(difference);
    }
    return;
  }
  stderr.writeln('Cookbook files differ:');
  for (final difference in differences) {
    stderr.writeln('- $difference');
  }
  exitCode = 1;
}

/// Copies Day One into the Cookbook, rewriting its site-relative links.
///
/// The app has no router for documentation pages, so a link only works when it
/// carries a scheme. Recipes already use absolute website URLs; Day One is
/// authored for the website and is converted on the way in.
String? _syncDayOne({
  required Directory canonicalRoot,
  required Directory destination,
  required String locale,
  required bool write,
}) {
  final source = File('${canonicalRoot.path}/$locale/$_dayOneFile');
  if (!source.existsSync()) {
    return 'Missing canonical Day One: ${source.path}';
  }
  final expected = absoluteWebsiteLinks(source.readAsStringSync());
  final destinationFile = File('${destination.path}/$_dayOneFile');
  if (destinationFile.existsSync() &&
      destinationFile.readAsStringSync() == expected) {
    return null;
  }
  if (write) {
    destinationFile.parent.createSync(recursive: true);
    destinationFile.writeAsStringSync(expected);
  }
  return '$locale/$_dayOneFile';
}

/// Turns `](/en/usages/settings/#tab)` into a full `https://nahpu.app` URL.
///
/// Day One links to the website with root-absolute paths, which resolve only
/// inside a browser on that site.
String absoluteWebsiteLinks(String source) {
  return source.replaceAllMapped(RegExp(r'\]\(/([^)\s]+)\)'), (match) {
    return ']($_websiteOrigin/${match.group(1)})';
  });
}

String? _optionValue(List<String> arguments, String option) {
  final index = arguments.indexOf(option);
  if (index == -1 || index + 1 >= arguments.length) return null;
  return arguments[index + 1];
}

Map<String, File> _documentationFiles(Directory root) {
  final result = <String, File>{};
  for (final entity in root.listSync(recursive: true)) {
    if (entity is! File ||
        (!entity.path.endsWith('.md') && !entity.path.endsWith('.mdoc'))) {
      continue;
    }
    final relativePath = entity.path.substring(root.path.length + 1);
    result[relativePath] = entity;
  }
  return result;
}

bool _bytesEqual(List<int> left, List<int> right) {
  if (left.length != right.length) return false;
  for (var index = 0; index < left.length; index++) {
    if (left[index] != right[index]) return false;
  }
  return true;
}
