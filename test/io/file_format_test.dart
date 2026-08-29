import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/types/file_format.dart';

void main() {
  test('normalize extension from paths and suffixes', () {
    expect(normalizeExtension('photo.JPG'), 'jpg');
    expect(normalizeExtension('.PDF'), 'pdf');
    expect(normalizeExtension('/tmp/clip.Mp4'), 'mp4');
  });

  test('match nahpu file format for supported media', () {
    expect(matchNahpuFormatFromPath('recording.mp3'), NahpuFileFormat.audio);
    expect(matchNahpuFormatFromPath('video.webm'), NahpuFileFormat.video);
    expect(matchNahpuFormatFromPath('document.pdf'), NahpuFileFormat.pdf);
    expect(matchNahpuFormatFromPath('image.heic'), NahpuFileFormat.image);
    expect(
      matchNahpuFormatFromPath('database.sqlite3'),
      NahpuFileFormat.database,
    );
    expect(matchNahpuFormatFromPath('notes.unknown'), NahpuFileFormat.other);
  });

  test('match media kind from path', () {
    expect(matchMediaKindFromPath('photo.jpeg'), MediaKind.image);
    expect(matchMediaKindFromPath('voice.m4a'), MediaKind.audio);
    expect(matchMediaKindFromPath('movie.mov'), MediaKind.video);
    expect(matchMediaKindFromPath('report.pdf'), MediaKind.other);
    expect(matchMediaKindFromPath('archive.zip'), MediaKind.other);
  });

  test('match supported media path and format helpers', () {
    expect(isSupportedMediaPath('photo.jpeg'), isTrue);
    expect(isSupportedMediaPath('PHOTO.JPG'), isTrue);
    expect(isSupportedMediaPath('voice.m4a'), isTrue);
    expect(isSupportedMediaPath('VOICE.MP3'), isTrue);
    expect(isSupportedMediaPath('movie.mov'), isTrue);
    expect(isSupportedMediaPath('MOVIE.MP4'), isTrue);
    expect(isSupportedMediaPath('report.pdf'), isFalse);
    expect(isSupportedMediaPath('REPORT.PDF'), isFalse);
    expect(isSupportedMediaPath('table.csv'), isFalse);

    expect(isSupportedMediaFormat(NahpuFileFormat.image), isTrue);
    expect(isSupportedMediaFormat(NahpuFileFormat.audio), isTrue);
    expect(isSupportedMediaFormat(NahpuFileFormat.video), isTrue);
    expect(isSupportedMediaFormat(NahpuFileFormat.pdf), isFalse);
    expect(isSupportedMediaFormat(NahpuFileFormat.tabulated), isFalse);
    expect(isSupportedMediaFormat(NahpuFileFormat.database), isFalse);
  });

  test('media picker group combines supported media extensions', () {
    expect(mediaFmt.label, 'Media files');
    expect(
      mediaFmt.extensions,
      containsAll([...imageExtensions, ...audioExtensions, ...videoExtensions]),
    );
    expect(
      mediaFmt.extensions,
      hasLength(
        imageExtensions.length +
            audioExtensions.length +
            videoExtensions.length,
      ),
    );
    expect(
      mediaFmt.uniformTypeIdentifiers,
      containsAll(['public.image', 'public.audio', 'public.movie']),
    );
    expect(
      mediaFmt.mimeTypes,
      containsAll(['image/jpeg', 'audio/mpeg', 'video/mp4']),
    );
  });

  test('media and image picker groups are iOS-safe', () {
    expect(
      mediaFmt.allowsAny ||
          ((mediaFmt.uniformTypeIdentifiers?.isNotEmpty ?? false) == true),
      isTrue,
    );
    expect(
      imageFmt.allowsAny ||
          ((imageFmt.uniformTypeIdentifiers?.isNotEmpty ?? false) == true),
      isTrue,
    );
  });
}
