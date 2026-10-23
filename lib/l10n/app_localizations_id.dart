// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get commonBeta => 'Beta';

  @override
  String get commonRetry => 'Coba lagi';

  @override
  String get commonUnavailable => 'Tidak tersedia';

  @override
  String get commonError => 'Galat';

  @override
  String get homeDatabaseErrorTitle => 'Tidak dapat membuka basis data NAHPU.';

  @override
  String get homeDatabaseErrorBody =>
      'Data Anda tidak dihapus. Coba lagi migrasi basis data atau mulai ulang NAHPU.';

  @override
  String get homeExistingProjects => 'Proyek yang ada';

  @override
  String get homeNoProjectsTitle => 'Tidak ada proyek.';

  @override
  String get homeNoProjectsBody => 'Buat atau impor proyek untuk memulai.';

  @override
  String get homeSetupHint =>
      'Baru menggunakan NAHPU? Jalankan Siapkan NAHPU untuk memilih format katalog, pengenal, kosakata, dan prasetel ekspor.';

  @override
  String get homeSetupNahpu => 'Siapkan NAHPU';

  @override
  String get homeStatistics => 'Statistik';

  @override
  String get homeSearchRecords => 'Cari catatan';

  @override
  String get drawerCreateProject => 'Buat proyek';

  @override
  String get drawerImportProject => 'Impor proyek';

  @override
  String get drawerDatabaseStatistics => 'Statistik basis data';

  @override
  String get drawerBackupDatabase => 'Cadangkan basis data';

  @override
  String get drawerSettings => 'Pengaturan';

  @override
  String get drawerExportUserConfigs => 'Ekspor konfigurasi pengguna';

  @override
  String get drawerImportUserConfigs => 'Impor konfigurasi pengguna';

  @override
  String get drawerAbout => 'Tentang';

  @override
  String get drawerWebsite => 'Situs web NAHPU';

  @override
  String get drawerCookbook => 'Buku Resep';

  @override
  String get settingsApplications => 'Aplikasi';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeLabel => 'Atur tampilan terang atau gelap';

  @override
  String get settingsThemeDark => 'Gelap';

  @override
  String get settingsThemeLight => 'Terang';

  @override
  String get settingsThemeSystem => 'Sistem';

  @override
  String get settingsTools => 'Alat';

  @override
  String get settingsToolsLabel =>
      'Pilih alat yang ditampilkan di dasbor proyek';

  @override
  String get settingsLanguage => 'Bahasa';

  @override
  String get settingsLanguageSystem => 'Bawaan sistem';

  @override
  String settingsLanguageSystemLabel(String language) {
    return 'Mengikuti bahasa perangkat ($language)';
  }

  @override
  String get settingsLanguageBetaNote =>
      'Dukungan bahasa masih beta. Beberapa layar masih berbahasa Inggris, dan terjemahan mungkin masih berupa draf mesin.';

  @override
  String get settingsRegionalFormat => 'Format regional';

  @override
  String get settingsRegionalFormatMatchLanguage => 'Sesuai bahasa';

  @override
  String get settingsRegionalFormatNote =>
      'Hanya mengubah cara tanggal dan angka ditampilkan. Catatan yang tersimpan dan hasil ekspor tetap memakai format standar.';

  @override
  String settingsRegionalFormatPreview(String date, String number) {
    return 'Contoh: $date · $number';
  }

  @override
  String get docsContents => 'Daftar isi';

  @override
  String docsCollapse(String title) {
    return 'Ciutkan $title';
  }

  @override
  String docsExpand(String title) {
    return 'Bentangkan $title';
  }

  @override
  String get docsLoadError => 'Tidak dapat memuat dokumentasi ini.';

  @override
  String get docsOnlineLinks =>
      'Tautan ini membuka dokumentasi NAHPU dan memerlukan koneksi internet.';

  @override
  String get docsAsideNote => 'Catatan';

  @override
  String get docsAsideCaution => 'Perhatian';

  @override
  String get docsAsideTip => 'Kiat';

  @override
  String get docsAiTranslation => 'Terjemahan dengan bantuan AI.';

  @override
  String get docsAiCheck => 'Periksa ketepatannya';

  @override
  String docsReviewedBy(String reviewers) {
    return 'Diperiksa dan direvisi oleh $reviewers.';
  }

  @override
  String docsReviewerPair(String first, String second) {
    return '$first dan $second';
  }

  @override
  String docsReviewerList(String leading, String last) {
    return '$leading, dan $last';
  }
}
