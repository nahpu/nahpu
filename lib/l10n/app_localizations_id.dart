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
  String get commonCancel => 'Batal';

  @override
  String get commonEdit => 'Sunting';

  @override
  String get commonPreview => 'Pratinjau';

  @override
  String get commonSortRecords => 'Urutkan catatan';

  @override
  String get commonDeleteRecord => 'Hapus catatan';

  @override
  String get commonDeleteAllRecords => 'Hapus semua catatan';

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
  String get homeSearchReset => 'Atur ulang';

  @override
  String get homeSearchShowResults => 'Tampilkan hasil';

  @override
  String get homeSearchHint =>
      'Nomor lapangan, takson, lokasi, atau nilai apa pun';

  @override
  String get homeSearchRecordType => 'Jenis catatan';

  @override
  String get homeSearchIn => 'Cari di';

  @override
  String get homeSearchAllFields => 'Semua bidang';

  @override
  String get homeSearchProjects => 'Proyek';

  @override
  String get homeSearchAllProjects => 'Semua proyek';

  @override
  String get homeSearchTaxa => 'Takson';

  @override
  String get homeSearchQuickFilters => 'Filter cepat';

  @override
  String homeProjectAccessed(String date) {
    return 'Diakses: $date';
  }

  @override
  String homeProjectCreated(String date) {
    return 'Dibuat: $date';
  }

  @override
  String get homeProjectActions => 'Tindakan proyek';

  @override
  String get homeProjectEditInfo => 'Sunting info';

  @override
  String get homeProjectShowQr => 'Tampilkan QR';

  @override
  String get homeProjectExportInfo => 'Ekspor info';

  @override
  String get homeProjectDetails => 'Detail';

  @override
  String get homeProjectInformation => 'Informasi proyek';

  @override
  String get homeProjectQrCode => 'Kode QR proyek';

  @override
  String get homeProjectQrDescription =>
      'Pindai kode ini saat membuat proyek baru untuk mentransfer informasi proyek.';

  @override
  String aboutTitle(String appName) {
    return 'Tentang $appName';
  }

  @override
  String get aboutTagline =>
      'Memikirkan ulang inventarisasi keanekaragaman hayati di era digital';

  @override
  String get aboutLicenses => 'Lisensi';

  @override
  String get aboutAppVersion => 'Versi aplikasi';

  @override
  String aboutVersionBuild(String version, String build) {
    return 'v$version (build $build)';
  }

  @override
  String get aboutCodename => 'Nama kode';

  @override
  String get aboutCodenameNote =>
      'Dari uji lapangan nyata pertama NAHPU di Gunung Gede, Jawa Barat, Indonesia.';

  @override
  String get aboutDatabaseSchema => 'Skema basis data';

  @override
  String aboutSchemaSupported(String version) {
    return 'Aplikasi mendukung v$version';
  }

  @override
  String aboutDescription(String appName) {
    return '$appName adalah aplikasi katalog digital lintas platform yang dirancang untuk pengumpulan dan pengelolaan data spesimen sejarah alam, yang memberikan wawasan saat pengumpulan.';
  }

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

  @override
  String get narrativeTitle => 'Narasi';

  @override
  String get narrativeRecordTitle => 'Catatan narasi';

  @override
  String get narrativeSearchHint => 'Cari narasi';

  @override
  String get narrativeEmpty => 'Narasi tidak ditemukan';

  @override
  String get narrativeCreate => 'Buat narasi';

  @override
  String get narrativeActions => 'Tindakan narasi';

  @override
  String get narrativeDeleteTitle => 'Hapus narasi?';

  @override
  String get narrativeDeletePrompt => 'Anda akan menghapus narasi ini';

  @override
  String get narrativeDeleteAllTitle => 'Hapus semua narasi?';

  @override
  String get narrativeDeleteAllPrompt =>
      'Anda akan menghapus semua narasi dalam proyek ini';

  @override
  String narrativeDeleteError(String error) {
    return 'Gagal menghapus narasi: $error';
  }

  @override
  String get narrativeDeleted => 'Narasi dihapus';

  @override
  String get narrativeTextLabel => 'Narasi';

  @override
  String get narrativeTextHint => 'Tulis narasi (mendukung Markdown)';

  @override
  String get narrativeTextEmpty =>
      'Belum ada narasi. Gunakan tombol Sunting di atas untuk mulai menulis.';

  @override
  String get narrativeDate => 'Tanggal';

  @override
  String get narrativeDateHint => 'Masukkan tanggal';

  @override
  String get narrativeTime => 'Waktu';

  @override
  String get narrativeTimeHint => 'Masukkan waktu';

  @override
  String get narrativeWriter => 'Penulis';

  @override
  String get narrativeWriterHint => 'Pilih nama orang';
}
