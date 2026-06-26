import 'dart:io';

import 'package:exif/exif.dart';
import 'package:file_selector/file_selector.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/media_services.dart';
import 'package:nahpu/services/platform_services.dart';
import 'package:nahpu/services/types/import.dart';
import 'package:nahpu/services/utility_services.dart';
import 'package:nahpu/services/types/file_format.dart';

class ImageServices extends AppServices {
  const ImageServices({required super.ref, required this.category});

  final MediaCategory category;

  Future<File> getMediaPath(String filePath) async {
    return MediaFinder(ref: ref).getPathForMedia(filePath, category);
  }

  Future<File> getPersonnelMediaPath(String filePath) async {
    return await MediaFinder(ref: ref).getPathForPersonnel(filePath, category);
  }

  Future<String> pickImageSingle() async {
    switch (systemPlatform) {
      case PlatformType.mobile:
        return await pickFromGallerySingle();
      case PlatformType.desktop:
        return await pickFromFileSingle();
      case PlatformType.unknown:
        throw Exception('Unsupported platform');
    }
  }

  Future<String?> accessCamera() async {
    final picker = ImagePicker();
    final result = await picker.pickImage(source: ImageSource.camera);
    File? files = result == null ? null : await _copySingleFile(result.path);
    return files?.path;
  }

  Future<String> pickFromGallerySingle() async {
    final picker = ImagePicker();
    final result = await picker.pickImage(source: ImageSource.gallery);
    File? file = result == null ? null : await _copySingleFile(result.path);
    return file?.path ?? '';
  }

  Future<List<String>> pickFromGallery() async {
    final picker = ImagePicker();
    final result = await picker.pickMultiImage();
    List<File> files = await _copyFiles(result.map((e) => e.path).toList());
    return files.map((e) => e.path).toList();
  }

  Future<List<String>> pickFromFiles() async {
    List<XFile> result = await openFiles(
        acceptedTypeGroups: imageFmt, confirmButtonText: 'Import');
    List<File> files = await _copyFiles(result.map((e) => e.path).toList());
    return files.map((e) => e.path).toList();
  }

  Future<List<String>> pickMediaFromFiles() async {
    List<XFile> result = await openFiles(
      acceptedTypeGroups: mediaFmt,
      confirmButtonText: 'Import',
    );
    List<File> files = await _copyFiles(result.map((e) => e.path).toList());
    return files.map((e) => e.path).toList();
  }

  Future<String> pickFromFileSingle() async {
    XFile? result = await openFile(acceptedTypeGroups: imageFmt);
    File? file = result == null ? null : await _copySingleFile(result.path);
    return file?.path ?? '';
  }

  Future<List<File>> _copyFiles(List<String> paths) async {
    List<File> files = [];
    for (String path in paths) {
      File newPath = await _copySingleFile(path);
      files.add(newPath);
    }
    return files;
  }

  Future<File> _copySingleFile(String path) async {
    File file = File(path);
    File newPath = category == MediaCategory.personnel
        ? await FileServices(ref: ref)
            .copyFileToAppDir(file, getMediaDir(category))
        : await FileServices(ref: ref)
            .copyFileToProjectDir(file, getMediaDir(category));
    return newPath;
  }
}

class MediaFileMetadata {
  const MediaFileMetadata({
    required this.taken,
    required this.camera,
    required this.lenses,
    required this.additionalExif,
  });

  final String taken;
  final String camera;
  final String lenses;
  final String additionalExif;
}

class MediaMetadataServices {
  const MediaMetadataServices();

  Future<MediaFileMetadata> extract(File file) async {
    final mediaKind = matchMediaKindFromPath(file.path);
    if (mediaKind == MediaKind.image) {
      final exifData = ExifData.empty();
      await exifData.readExif(file);
      return MediaFileMetadata(
        taken: exifData.dateTaken,
        camera: exifData.camera,
        lenses: exifData.lenseModel,
        additionalExif: exifData.additionalExif,
      );
    }

    final int byteSize = await file.length();
    final DateTime modifiedAt = await file.lastModified();
    final String ext = normalizeExtension(file.path).toUpperCase();
    final List<String> metadata = [
      'Type: ${matchMediaKindLabel(mediaKind)}',
      'Format: $ext',
      'Size: ${_sizeToReadable(byteSize)}',
      'Modified: ${modifiedAt.toLocal()}',
    ];

    return MediaFileMetadata(
      taken: '',
      camera: '',
      lenses: '',
      additionalExif: metadata.join(listTileSeparator),
    );
  }

  String formatAdditionalMetadataForExport(String? metadata) {
    if (metadata == null || metadata.isEmpty) {
      return '';
    }
    return metadata
        .replaceAll(listTileSeparator, ' ')
        .replaceAll('\n', ' ')
        .trim();
  }

  String _sizeToReadable(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
    }
    return '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(1)} GB';
  }
}

class ExifData {
  ExifData({
    required this.dateTaken,
    required this.camera,
    required this.lenseModel,
    required this.additionalExif,
  });

  String dateTaken;
  String camera;
  String lenseModel;
  String additionalExif;

  factory ExifData.empty() {
    return ExifData(
      dateTaken: '',
      camera: '',
      lenseModel: '',
      additionalExif: '',
    );
  }

  Future<void> readExif(File file) async {
    try {
      final Map<String, IfdTag> exif =
          await readExifFromBytes(await file.readAsBytes());
      _getExifDate(exif);
      _getExifCameraModel(exif);
      _getExifLenseModel(exif);
      String focalLength = _getExifFocalLength(exif);
      String aperture = _getExifAperture(exif);
      String exposure = _getExifExposureTime(exif);
      String iso = _getExifIso(exif);
      List<String> exifList = [focalLength, aperture, exposure, iso];
      additionalExif = exifList.join(listTileSeparator);
    } catch (e) {
      return;
    }
  }

  void _getExifDate(Map<String, IfdTag> exif) {
    final IfdTag? dateTag = exif['Image DateTime'];
    if (dateTag != null) {
      dateTaken = dateTag.toString();
    }
  }

  void _getExifCameraModel(Map<String, IfdTag> exif) {
    final IfdTag? cameraMakerTag = exif['Image Make'];
    final IfdTag? cameraModelTag = exif['Image Model'];
    String cameraMaker = cameraMakerTag?.toString() ?? 'Unknown maker';
    String cameraModel = cameraModelTag?.toString() ?? 'Unknown model';

    camera = '$cameraMaker $cameraModel';
  }

  void _getExifLenseModel(Map<String, IfdTag> exif) {
    final IfdTag? lenseModelTag = exif['EXIF LensModel'];
    lenseModel = lenseModelTag?.toString() ?? 'Unknown lenses';
  }

  String _getExifFocalLength(Map<String, IfdTag> exif) {
    final IfdTag? focalLengthTag = exif['EXIF FocalLength'];
    return '${focalLengthTag?.toString() ?? '?'} mm';
  }

  String _getExifExposureTime(Map<String, IfdTag> exif) {
    final IfdTag? exposureTimeTag = exif['EXIF ExposureTime'];
    return '${exposureTimeTag?.toString() ?? '?'}s';
  }

  String _getExifAperture(Map<String, IfdTag> exif) {
    final IfdTag? apertureTag = exif['EXIF FNumber'];
    if (apertureTag == null) {
      return 'F?';
    }

    return 'F${_calculateAperture(apertureTag.toString())}';
  }

  double _calculateAperture(String aperture) {
    if (aperture.contains('/')) {
      List<String> apertureList = aperture.split('/');
      double numerator = double.parse(apertureList[0]);
      double denominator = double.parse(apertureList[1]);
      return numerator / denominator;
    }
    return double.tryParse(aperture) ?? 0.0;
  }

  String _getExifIso(Map<String, IfdTag> exif) {
    final IfdTag? isoTag = exif['EXIF ISOSpeedRatings'];
    return 'ISO${isoTag?.toString() ?? '?'}';
  }
}

({String date, String time}) parseMediaDateTime(String value) {
  if (value.isEmpty || !value.contains(' ')) {
    return (date: '', time: '');
  }
  List<String> dateTime = value.split(' ');
  if (dateTime.length != 2) {
    return (date: '', time: '');
  }
  String cleanedDate = dateTime[0].replaceAll(':', '-');
  String cleanDateTime = '$cleanedDate ${dateTime[1]}';
  return parseDate(cleanDateTime);
}
