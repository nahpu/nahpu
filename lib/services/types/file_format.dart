import 'package:file_selector/file_selector.dart';

enum NahpuFileFormat { tabulated, image, audio, video, pdf, database, other }

enum MediaKind { image, audio, video, pdf, other }

const Map<String, NahpuFileFormat> formatByExtension = {
  'csv': NahpuFileFormat.tabulated,
  'tsv': NahpuFileFormat.tabulated,
  'xlsx': NahpuFileFormat.tabulated,
  'jpg': NahpuFileFormat.image,
  'jpeg': NahpuFileFormat.image,
  'png': NahpuFileFormat.image,
  'gif': NahpuFileFormat.image,
  'heic': NahpuFileFormat.image,
  'mp3': NahpuFileFormat.audio,
  'm4a': NahpuFileFormat.audio,
  'wav': NahpuFileFormat.audio,
  'aac': NahpuFileFormat.audio,
  'ogg': NahpuFileFormat.audio,
  'flac': NahpuFileFormat.audio,
  'mp4': NahpuFileFormat.video,
  'mov': NahpuFileFormat.video,
  'm4v': NahpuFileFormat.video,
  'avi': NahpuFileFormat.video,
  'mkv': NahpuFileFormat.video,
  'webm': NahpuFileFormat.video,
  'pdf': NahpuFileFormat.pdf,
  'sqlite3': NahpuFileFormat.database,
  'db': NahpuFileFormat.database,
};

const Set<String> imageExtensions = {'jpg', 'jpeg', 'png', 'gif', 'heic'};
const Set<String> audioExtensions = {'mp3', 'm4a', 'wav', 'aac', 'ogg', 'flac'};
const Set<String> videoExtensions = {'mp4', 'mov', 'm4v', 'avi', 'mkv', 'webm'};
const Set<String> pdfExtensions = {'pdf'};

String normalizeExtension(String value) {
  String ext = value.trim().toLowerCase();
  if (ext.contains('.')) {
    ext = ext.split('.').last;
  }
  return ext;
}

NahpuFileFormat matchNahpuFormatFromPath(String filePath) {
  final ext = normalizeExtension(filePath);
  return formatByExtension[ext] ?? NahpuFileFormat.other;
}

bool isSupportedMediaFormat(NahpuFileFormat format) {
  return format == NahpuFileFormat.image ||
      format == NahpuFileFormat.audio ||
      format == NahpuFileFormat.video ||
      format == NahpuFileFormat.pdf;
}

bool isSupportedMediaPath(String filePath) {
  return isSupportedMediaFormat(matchNahpuFormatFromPath(filePath));
}

MediaKind matchMediaKindFromPath(String filePath) {
  final ext = normalizeExtension(filePath);
  if (imageExtensions.contains(ext)) {
    return MediaKind.image;
  }
  if (audioExtensions.contains(ext)) {
    return MediaKind.audio;
  }
  if (videoExtensions.contains(ext)) {
    return MediaKind.video;
  }
  if (pdfExtensions.contains(ext)) {
    return MediaKind.pdf;
  }
  return MediaKind.other;
}

String matchMediaKindLabel(MediaKind kind) {
  switch (kind) {
    case MediaKind.image:
      return 'Image';
    case MediaKind.audio:
      return 'Audio';
    case MediaKind.video:
      return 'Video';
    case MediaKind.pdf:
      return 'PDF';
    case MediaKind.other:
      return 'Other';
  }
}

const XTypeGroup dbFmt = XTypeGroup(
  label: 'Database (.sqlite3)',
  extensions: ['sqlite3', 'db'],
  uniformTypeIdentifiers: ['public.database'],
  mimeTypes: ['application/vnd.sqlite3'],
);

const XTypeGroup pdfFmt = XTypeGroup(
  label: 'PDF (.pdf)',
  extensions: ['pdf'],
  uniformTypeIdentifiers: ['com.adobe.pdf'],
  mimeTypes: ['application/pdf'],
);

const XTypeGroup audioFmt = XTypeGroup(
  label: 'Audio',
  extensions: ['mp3', 'm4a', 'wav', 'aac', 'ogg', 'flac'],
  uniformTypeIdentifiers: [
    'public.audio',
    'public.mp3',
    'com.microsoft.waveform-audio',
  ],
  mimeTypes: [
    'audio/mpeg',
    'audio/mp4',
    'audio/wav',
    'audio/aac',
    'audio/ogg',
    'audio/flac',
  ],
);

const XTypeGroup videoFmt = XTypeGroup(
  label: 'Video',
  extensions: ['mp4', 'mov', 'm4v', 'avi', 'mkv', 'webm'],
  uniformTypeIdentifiers: [
    'public.movie',
    'public.mpeg-4',
    'com.apple.quicktime-movie',
  ],
  mimeTypes: [
    'video/mp4',
    'video/quicktime',
    'video/x-msvideo',
    'video/x-matroska',
    'video/webm',
  ],
);

const XTypeGroup mediaFmt = XTypeGroup(
  label: 'Media files',
  extensions: [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'heic',
    'mp3',
    'm4a',
    'wav',
    'aac',
    'ogg',
    'flac',
    'mp4',
    'mov',
    'm4v',
    'avi',
    'mkv',
    'webm',
    'pdf',
  ],
  uniformTypeIdentifiers: [
    'public.image',
    'public.audio',
    'public.movie',
    'com.adobe.pdf',
  ],
  mimeTypes: [
    'image/jpeg',
    'image/png',
    'image/gif',
    'image/heic',
    'audio/mpeg',
    'audio/mp4',
    'audio/wav',
    'audio/aac',
    'audio/ogg',
    'audio/flac',
    'video/mp4',
    'video/quicktime',
    'video/x-msvideo',
    'video/x-matroska',
    'video/webm',
    'application/pdf',
  ],
);

const XTypeGroup imageFmt = XTypeGroup(
  label: 'Image files',
  extensions: ['jpg', 'jpeg', 'png', 'gif', 'heic'],
  uniformTypeIdentifiers: ['public.image'],
  mimeTypes: ['image/jpeg', 'image/png', 'image/gif', 'image/heic'],
);

const XTypeGroup jpegFmt = XTypeGroup(
  label: 'JPEG (.jpg)',
  extensions: ['jpg', 'jpeg'],
  uniformTypeIdentifiers: ['public.jpeg'],
  mimeTypes: ['image/jpeg'],
);

const XTypeGroup pngFmt = XTypeGroup(
  label: 'PNG (.png)',
  extensions: ['png'],
  uniformTypeIdentifiers: ['public.png'],
  mimeTypes: ['image/png'],
);

const XTypeGroup gifFmt = XTypeGroup(
  label: 'GIF (.gif)',
  extensions: ['gif'],
  uniformTypeIdentifiers: ['com.compuserve.gif'],
  mimeTypes: ['image/gif'],
);

const XTypeGroup heicFmt = XTypeGroup(
  label: 'HEIC (.heic)',
  extensions: ['heic'],
  uniformTypeIdentifiers: ['public.heic'],
  mimeTypes: ['image/heic'],
);
