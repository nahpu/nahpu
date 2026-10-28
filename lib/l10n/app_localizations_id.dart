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
  String get homeMoreActions => 'Lainnya';

  @override
  String get homeGallery => 'Galeri';

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
  String get drawerMediaGallery => 'Galeri media';

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
  String get settingsLanguageHelpTranslate => 'Bantu terjemahkan NAHPU';

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

  @override
  String get commonDelete => 'Hapus';

  @override
  String get commonDone => 'Selesai';

  @override
  String get commonExport => 'Ekspor';

  @override
  String get commonRemove => 'Hapus';

  @override
  String get commonReset => 'Atur ulang';

  @override
  String get settingsNavCatalogs => 'Katalog';

  @override
  String get settingsNavCatalogFormat => 'Format';

  @override
  String get settingsNavCatalogFormatLabel => 'Atur format katalog';

  @override
  String settingsNavCatalogFormatLoadError(String error) {
    return 'Tidak dapat memuat format katalog: $error';
  }

  @override
  String get settingsNavSites => 'Lokasi';

  @override
  String get settingsNavSitesLabel =>
      'Kelola jenis lokasi, jenis habitat, dan datum koordinat';

  @override
  String get settingsNavEvents => 'Kegiatan';

  @override
  String get settingsNavEventsLabel =>
      'Kelola aktivitas, metode koleksi, peran personel, dan kolom lingkungan';

  @override
  String get settingsNavSpecimens => 'Spesimen';

  @override
  String get settingsNavSpecimensLabel =>
      'Kelola pengaturan kolom dan ID jaringan, serta kosakata terkendali untuk formulir spesimen';

  @override
  String get settingsNavCustomFields => 'Kolom khusus';

  @override
  String get settingsNavCustomFieldsLabel =>
      'Kelola kolom untuk lokasi, data lingkungan, spesimen, bagian, dan parasit';

  @override
  String get settingsNavDatabase => 'Basis data';

  @override
  String get settingsNavTaxa => 'Takson';

  @override
  String get settingsNavTaxaLabel => 'Kelola catatan taksonomi';

  @override
  String get settingsNavPersonnel => 'Personel';

  @override
  String get settingsNavPersonnelLabel => 'Kelola catatan personel';

  @override
  String get settingsNavBackupDatabaseLabel =>
      'Cadangan basis data lengkap untuk semua catatan dan pengaturan';

  @override
  String get settingsNavReplaceDatabase => 'Ganti basis data';

  @override
  String get settingsNavReplaceDatabaseLabel =>
      'Ganti basis data saat ini dengan berkas basis data lain';

  @override
  String get settingsNavExports => 'Ekspor';

  @override
  String get settingsNavTabularData => 'Data tabular';

  @override
  String get settingsNavTabularDataLabel =>
      'Kelola preset untuk ekspor dalam format tabular';

  @override
  String get settingsNavDocuments => 'Dokumen';

  @override
  String get settingsNavDocumentsLabel => 'Kelola preset untuk ekspor dokumen';

  @override
  String get settingsNavTemplateEditor => 'Penyunting templat';

  @override
  String get settingsNavTemplateEditorLabel =>
      'Buat dan sunting templat dokumen';

  @override
  String get settingsCommonSetCaseFormat => 'Atur format huruf';

  @override
  String get settingsFileTreeEmpty => 'Folder aplikasi kosong.';

  @override
  String settingsFileTreeUnlinkedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tidak tertaut',
    );
    return '$_temp0';
  }

  @override
  String get settingsFileTreeRemoveEmptyFolder => 'Hapus folder kosong ini';

  @override
  String get settingsFileTreeSelectFolder => 'Pilih folder ini';

  @override
  String settingsFileTreeSelectRemovable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Pilih $count berkas yang dapat dihapus di sini',
    );
    return '$_temp0';
  }

  @override
  String get settingsFileTreeSaveCopy => 'Simpan salinan';

  @override
  String get settingsFileTreeRemoveFile => 'Hapus berkas ini';

  @override
  String get settingsFileTreeKept => 'Disimpan';

  @override
  String get settingsSelectionApplicationFolder => 'Folder aplikasi';

  @override
  String settingsSelectionTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count berkas dipilih',
    );
    return '$_temp0';
  }

  @override
  String get settingsSelectionArchiveFormat => 'Format arsip';

  @override
  String get settingsSelectionNoFolder =>
      'Mengekspor pilihan memerlukan folder tujuan, yang tidak tersedia di perangkat ini. Anda tetap dapat menghapus berkas yang dipilih setelah meninjaunya.';

  @override
  String get settingsSelectionExportNote =>
      'Ekspor menulis berkas ini ke satu arsip terkompresi, lalu menawarkan untuk menghapus berkas aslinya. Menghapus akan langsung menghilangkannya dan tidak dapat dibatalkan.';

  @override
  String get settingsSelectionDeleteNote =>
      'Menghapus akan langsung menghilangkan berkas yang dipilih dan tidak dapat dibatalkan.';

  @override
  String get settingsSelectionDeletePermanently => 'Hapus permanen';

  @override
  String get settingsMapLayers => 'Lapisan peta';

  @override
  String get settingsMapPmtilesType => 'Jenis lapisan PMTiles';

  @override
  String settingsMapImportError(String error) {
    return 'Tidak dapat mengimpor lapisan peta: $error';
  }

  @override
  String get settingsMapBaseLayer => 'Lapisan dasar';

  @override
  String get settingsMapCustomLayers => 'Lapisan khusus';

  @override
  String settingsMapLoadError(String error) {
    return 'Tidak dapat memuat lapisan peta khusus: $error';
  }

  @override
  String get settingsMapNoCustomLayers =>
      'Belum ada lapisan khusus yang diimpor.';

  @override
  String get settingsMapImportCustomLayer => 'Impor lapisan khusus';

  @override
  String settingsMapKindUnavailableOnDesktop(String kind) {
    return '$kind · tidak tersedia di desktop';
  }

  @override
  String get settingsMapConfigureLayer => 'Atur lapisan';

  @override
  String get settingsMapShowLayer => 'Tampilkan lapisan';

  @override
  String get settingsMapLayerUnavailableOnDesktop =>
      'Lapisan ini tidak tersedia di desktop';

  @override
  String get settingsMapLayerTypeUnavailableOnDesktop =>
      'Jenis lapisan ini tidak tersedia di desktop.';

  @override
  String get settingsMapOpacity => 'Opasitas';

  @override
  String get settingsMapUseTerrain => 'Gunakan untuk medan 3D';

  @override
  String get settingsMapHillshadeNote =>
      'Bayangan relief tetap terlihat saat medan dimatikan.';

  @override
  String get settingsMapLayerOrder => 'Urutan lapisan';

  @override
  String get settingsMapMoveEarlier => 'Pindahkan ke atas';

  @override
  String get settingsMapMoveLater => 'Pindahkan ke bawah';

  @override
  String get settingsMapDeleteLayer => 'Hapus lapisan';

  @override
  String get settingsMapDeleteLayerTitle => 'Hapus lapisan peta?';

  @override
  String settingsMapDeleteLayerBody(String name) {
    return 'Hapus $name beserta data peta yang tersimpan?';
  }

  @override
  String get settingsMapSupportedFormatsDesktop =>
      'Di desktop mendukung GeoJSON, Shapefile WGS84 dalam ZIP, dan PMTiles raster.';

  @override
  String get settingsMapSupportedFormats =>
      'Mendukung GeoJSON, Shapefile WGS84 dalam ZIP, dan PMTiles.';

  @override
  String get settingsDataUsage => 'Penggunaan data';

  @override
  String get settingsDataUsageLabel => 'Telusuri dan bersihkan folder aplikasi';

  @override
  String get settingsDataUsageRescan => 'Pindai ulang';

  @override
  String get settingsDataUsageFiles => 'Berkas';

  @override
  String get settingsDataUsageFilesLabel => 'Termasuk gambar dan berkas lain';

  @override
  String get settingsDataUsageMediaFiles => 'Berkas media';

  @override
  String get settingsDataUsageMediaFilesLabel => 'Gambar, audio, video';

  @override
  String get settingsDataUsageTotal => 'Total penggunaan';

  @override
  String get settingsDataUsageReclaimable => 'Dapat dikosongkan';

  @override
  String get settingsDataUsageReclaimableLabel =>
      'Berkas tidak tertaut yang dapat dihapus';

  @override
  String get settingsDataUsageNone => 'Tidak ada';

  @override
  String get settingsDataUsageRemoveOriginalsTitle => 'Hapus berkas asli?';

  @override
  String settingsDataUsageArchiveWritten(
    int count,
    String archive,
    String size,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count berkas ditulis ke $archive ($size).',
    );
    return '$_temp0';
  }

  @override
  String get settingsDataUsageRemoveOriginalsBody =>
      'Menghapusnya dari NAHPU akan mengosongkan ruang. Arsip tetap menyimpan salinan Anda, dan tindakan ini tidak dapat dibatalkan.';

  @override
  String settingsDataUsageExportedTo(String path) {
    return 'Diekspor ke $path';
  }

  @override
  String settingsDataUsageExportFailed(String error) {
    return 'Ekspor gagal: $error';
  }

  @override
  String settingsDataUsageSaveCopyFailed(String name, String error) {
    return 'Tidak dapat menyimpan $name: $error';
  }

  @override
  String get settingsDataUsageRemoveFileTitle => 'Hapus berkas ini?';

  @override
  String settingsDataUsageRemoveFileBody(String name, String size) {
    return '$name ($size) tidak tertaut ke catatan mana pun. Tindakan ini tidak dapat dibatalkan.';
  }

  @override
  String get settingsDataUsageRemoveFolderTitle => 'Hapus folder kosong ini?';

  @override
  String settingsDataUsageRemoveFolderBody(String name) {
    return '$name tidak berisi berkas. Menghapusnya tidak memengaruhi catatan mana pun.';
  }

  @override
  String settingsDataUsageRemovedFolder(String name) {
    return '$name dihapus.';
  }

  @override
  String settingsDataUsageRemoveFolderFailed(String name) {
    return 'Tidak dapat menghapus $name.';
  }

  @override
  String settingsDataUsageDeleteSelectionTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hapus $count berkas yang dipilih?',
    );
    return '$_temp0';
  }

  @override
  String get settingsDataUsageDeleteSelectionBody =>
      'Berkas ini tidak tertaut ke catatan mana pun. Tindakan ini tidak dapat dibatalkan.';

  @override
  String get settingsDataUsageCollapseAll => 'Ciutkan semua';

  @override
  String get settingsDataUsageExpandAll => 'Bentangkan semua';

  @override
  String get settingsDataUsageSelectAll => 'Pilih semua';

  @override
  String get settingsDataUsageSelect => 'Pilih';

  @override
  String get settingsDataUsageClear => 'Hapus pilihan';

  @override
  String settingsDataUsageReview(int count) {
    return 'Tinjau $count';
  }

  @override
  String get settingsDataUsageScanError =>
      'Tidak dapat membaca folder aplikasi';

  @override
  String get settingsDataUsagePruneTitle => 'Hapus berkas tidak tertaut';

  @override
  String get settingsDataUsagePruneDescription =>
      'Berkas yang tidak lagi dipakai oleh catatan mana pun, misalnya sisa media yang dihapus atau impor yang dibatalkan. Berkas tertaut, basis data dan cadangannya, fon khusus, lapisan peta, serta berkas di luar folder yang dikelola NAHPU tidak terpengaruh.';

  @override
  String get settingsDataUsageNothingToReclaim =>
      'Tidak ada yang perlu dikosongkan.';

  @override
  String settingsDataUsagePruneButton(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hapus $count berkas tidak tertaut ($size)',
    );
    return '$_temp0';
  }

  @override
  String settingsDataUsagePruneConfirmTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hapus $count berkas tidak tertaut?',
    );
    return '$_temp0';
  }

  @override
  String settingsDataUsagePruneConfirmBody(String size) {
    return 'Ini akan mengosongkan $size. Berkas yang masih tertaut ke catatan Anda, basis data beserta cadangannya, serta fon khusus dan lapisan peta Anda tidak terpengaruh.\n\nTindakan ini tidak dapat dibatalkan.';
  }

  @override
  String settingsDataUsageRemovedSummary(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count berkas dihapus ($size).',
    );
    return '$_temp0';
  }

  @override
  String settingsDataUsageKeptChanged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count berkas dipertahankan karena berubah selama pemindaian.',
    );
    return '$_temp0';
  }

  @override
  String get commonOk => 'OK';

  @override
  String get recordsCatalogFormat => 'Format katalog';

  @override
  String get recordsCatalogMeasurementRecords => 'Catatan pengukuran';

  @override
  String get recordsCatalogAlwaysShowBatFields =>
      'Selalu tampilkan bidang kelelawar';

  @override
  String get recordsCatalogBatFieldsNote =>
      'Jika diaktifkan, bidang khusus kelelawar selalu ditampilkan di bidang pengukuran mamalia. Anda juga dapat menampilkan atau menyembunyikan bidang khusus kelelawar untuk setiap catatan spesimen di layar catatan spesimen.';

  @override
  String get recordsVocabularyCaseFormat => 'Format huruf';

  @override
  String recordsVocabularyCaseFormatLoadError(String error) {
    return 'Tidak dapat memuat format huruf: $error';
  }

  @override
  String get recordsVocabularyCaseAny => 'Bebas';

  @override
  String get recordsVocabularyCaseSentence => 'Huruf kalimat';

  @override
  String get recordsVocabularyCaseTitle => 'Huruf judul';

  @override
  String get recordsVocabularyCaseUpper => 'Huruf kapital';

  @override
  String get recordsVocabularyCaseLower => 'Huruf kecil';

  @override
  String get recordsSiteSettings => 'Pengaturan lokasi';

  @override
  String get recordsSiteTypes => 'Jenis lokasi';

  @override
  String get recordsSiteHabitatTypes => 'Jenis habitat';

  @override
  String get recordsSiteDatums => 'Datum';

  @override
  String get recordsSiteGeographyFields => 'Bidang geografi';

  @override
  String recordsSiteGeographyFieldsLoadError(String error) {
    return 'Tidak dapat memuat bidang geografi: $error';
  }

  @override
  String get recordsSiteMaps => 'Peta';

  @override
  String get recordsSiteMapLayers => 'Lapisan peta';

  @override
  String get recordsSiteMapLayersLabel =>
      'Pilih lapisan dasar atau impor dan kelola lapisan khusus';

  @override
  String get recordsCollEventSettings => 'Pengaturan kegiatan koleksi';

  @override
  String get recordsCollEventPrimaryActivities => 'Kegiatan utama';

  @override
  String get recordsCollEventCollectionMethods => 'Metode koleksi';

  @override
  String get recordsCollEventPersonnelRoles => 'Peran personel';

  @override
  String get recordsCollEventEnvironmentalDataFields =>
      'Bidang data lingkungan';

  @override
  String recordsCollEventEnvironmentalDataFieldsLoadError(String error) {
    return 'Tidak dapat memuat bidang data lingkungan: $error';
  }

  @override
  String get recordsCollEventTemperature => 'Suhu';

  @override
  String get recordsCollEventHumidity => 'Kelembapan';

  @override
  String get recordsCollEventEnvironmentalMeasurements =>
      'Pengukuran lingkungan';

  @override
  String get recordsCollEventAquaticData => 'Data perairan';

  @override
  String get recordsCollEventAstronomy => 'Astronomi';

  @override
  String get recordsSpecimenSettings => 'Pengaturan spesimen';

  @override
  String get recordsSpecimenCaptureRecords => 'Catatan penangkapan';

  @override
  String get recordsSpecimenAlwaysShowCollector =>
      'Selalu tampilkan bidang kolektor';

  @override
  String get recordsSpecimenIdentificationMethods => 'Metode identifikasi';

  @override
  String get recordsSpecimenLifeStages => 'Tahap hidup';

  @override
  String get recordsSpecimenTypes => 'Jenis spesimen';

  @override
  String get recordsSpecimenTreatments => 'Perlakuan';

  @override
  String get recordsSpecimenConditions => 'Kondisi';

  @override
  String get recordsSpecimenSex => 'Jenis kelamin';

  @override
  String recordsSpecimenSexNote(String male, String female, String unknown) {
    return '$male, $female, dan $unknown selalu tersedia. Tambahkan istilah opsional dengan +. Tanda tanya mencatat ketidakpastian pemeriksa.';
  }

  @override
  String recordsSpecimenSexLoadError(String error) {
    return 'Tidak dapat memuat opsi jenis kelamin: $error';
  }

  @override
  String get recordsSpecimenSexSelected => 'Dipilih';

  @override
  String get recordsSpecimenSexAdditional => 'Opsi tambahan';

  @override
  String get recordsSpecimenSexRemoveBlockedTitle =>
      'Tidak dapat menghapus jenis kelamin';

  @override
  String recordsSpecimenSexRemoveBlockedBody(String sex) {
    return '$sex digunakan oleh satu atau lebih catatan spesimen. Ubah catatan tersebut sebelum menghapus opsi ini.';
  }

  @override
  String get recordsSpecimenParasites => 'Parasit';

  @override
  String get recordsSpecimenParasiteIdentification => 'Identifikasi';

  @override
  String get recordsSpecimenParasiteCategories => 'Kategori';

  @override
  String get recordsSpecimenParasiteDetectionMethods => 'Metode deteksi';

  @override
  String get recordsSpecimenParasitePreparationMethods => 'Metode preparasi';

  @override
  String get recordsSpecimenParasiteAnatomicalLocations => 'Lokasi anatomi';

  @override
  String get recordsSpecimenParasiteStorage => 'Penyimpanan';

  @override
  String get recordsSpecimenParasiteIdPrefix => 'Prefiks ID parasit';

  @override
  String recordsSpecimenParasiteIdPrefixHint(String example) {
    return 'Masukkan prefiks, mis. $example';
  }

  @override
  String get recordsSpecimenParasiteIdNumber => 'Nomor ID parasit';

  @override
  String get recordsSpecimenNextNumberHint => 'Masukkan nomor berikutnya';

  @override
  String get recordsSpecimenFieldId => 'ID lapangan';

  @override
  String recordsSpecimenFieldIdModeLoadError(String error) {
    return 'Tidak dapat memuat mode ID lapangan: $error';
  }

  @override
  String get recordsSpecimenPersonnelId => 'ID personel';

  @override
  String get recordsSpecimenPersonnelIdDescription =>
      'ID berupa inisial seseorang dan nomor urut. Anda akan mengaturnya saat membuat personel dengan peran katalogis.';

  @override
  String get recordsSpecimenProjectId => 'ID proyek';

  @override
  String get recordsSpecimenProjectIdDescription =>
      'Proyek menyimpan satu nomor urut dengan prefiks dan sufiks bersama.';

  @override
  String get recordsSpecimenPersonnelFieldIdNoteTitle =>
      'ID lapangan personel memerlukan katalogis';

  @override
  String get recordsSpecimenPersonnelFieldIdNoteBody =>
      'Tambahkan orang dengan peran Katalogis di proyek dan tetapkan nomor lapangan saat ini untuk peran tersebut.';

  @override
  String get recordsSpecimenAddPersonnel => 'Tambah personel';

  @override
  String get recordsSpecimenPrefix => 'Prefiks';

  @override
  String get recordsSpecimenSuffix => 'Sufiks';

  @override
  String recordsSpecimenExampleHint(String example) {
    return 'mis. $example';
  }

  @override
  String get recordsSpecimenCurrentCatalogNumber => 'Nomor katalog saat ini';

  @override
  String recordsSpecimenFieldIdPreview(String id) {
    return 'Pratinjau: $id';
  }

  @override
  String get recordsSpecimenAutoIncrement =>
      'Tambah nomor katalog secara otomatis';

  @override
  String get recordsSpecimenSaveFieldIdSettings =>
      'Simpan pengaturan ID lapangan';

  @override
  String get recordsSpecimenFieldIdSettingsSaved =>
      'Pengaturan ID lapangan disimpan.';

  @override
  String get recordsSpecimenNoProjectFieldIdTitle =>
      'Buka proyek untuk mengatur ID lapangan proyek';

  @override
  String get recordsSpecimenNoProjectFieldIdBody =>
      'Prefiks, nomor saat ini, dan sufiks disimpan per proyek.';

  @override
  String get recordsSpecimenFieldIdChangeTitle =>
      'Ubah format ID lapangan proyek?';

  @override
  String get recordsSpecimenFieldIdChangeBody =>
      'Mengubah prefiks atau sufiks ID lapangan proyek akan mengubah ID proyek yang sudah ada. Pengenal ini mungkin sudah digunakan dalam ekspor atau ditulis pada label spesimen. Periksa kembali nilai baru sebelum mengubahnya.';

  @override
  String get recordsSpecimenIUnderstand => 'Saya mengerti';

  @override
  String get recordsSpecimenTissueId => 'ID jaringan';

  @override
  String get recordsSpecimenNextTissueId => 'ID jaringan berikutnya';

  @override
  String get recordsSpecimenIndividualTagId => 'ID tag individu';

  @override
  String get recordsSpecimenNextTag => 'Tag berikutnya';

  @override
  String get recordsCustomFieldTitle => 'Bidang khusus';

  @override
  String get recordsCustomFieldFieldsTab => 'Bidang';

  @override
  String get recordsCustomFieldEditField => 'Sunting bidang';

  @override
  String recordsCustomFieldLoadError(String error) {
    return 'Tidak dapat memuat bidang: $error';
  }

  @override
  String recordsCustomFieldSaved(String name) {
    return '“$name” disimpan.';
  }

  @override
  String recordsCustomFieldImportQrError(String error) {
    return 'Tidak dapat mengimpor kode QR: $error';
  }

  @override
  String recordsCustomFieldImportError(String error) {
    return 'Tidak dapat mengimpor bidang khusus: $error';
  }

  @override
  String get recordsCustomFieldImportEmpty =>
      'Konfigurasi pengguna ini tidak berisi templat bidang khusus.';

  @override
  String recordsCustomFieldImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count definisi bidang khusus diimpor.',
    );
    return '$_temp0';
  }

  @override
  String recordsCustomFieldExportError(String error) {
    return 'Tidak dapat mengekspor bidang khusus: $error';
  }

  @override
  String recordsCustomFieldExportedTo(String path) {
    return 'Bidang khusus diekspor ke $path';
  }

  @override
  String get recordsCustomFieldExported => 'Bidang khusus diekspor';

  @override
  String get recordsCustomFieldQrTooLargeTitle => 'Kode QR terlalu besar';

  @override
  String get recordsCustomFieldQrTooLargeBody =>
      'Bidang khusus yang dipilih berisi terlalu banyak data untuk satu kode QR. Ekspor sebagai berkas.';

  @override
  String get recordsCustomFieldExportFile => 'Ekspor berkas';

  @override
  String get recordsCustomFieldDiscardLegacyTitle => 'Buang nilai lama?';

  @override
  String recordsCustomFieldDiscardLegacyBody(String name) {
    return 'Nilai lama untuk “$name” tidak dapat dipulihkan setelah dibuang.';
  }

  @override
  String get recordsCustomFieldDiscardValues => 'Buang nilai';

  @override
  String get recordsCustomFieldDeleteTitle => 'Hapus bidang khusus?';

  @override
  String recordsCustomFieldDeleteBody(String name) {
    return 'Hapus “$name” secara permanen? Tindakan ini tidak dapat dibatalkan.';
  }

  @override
  String get recordsCustomFieldSelectFields => 'Pilih bidang';

  @override
  String get recordsCustomFieldShowArchived =>
      'Tampilkan bidang yang diarsipkan';

  @override
  String recordsCustomFieldAllArchived(String location) {
    return 'Semua bidang khusus di $location diarsipkan.';
  }

  @override
  String recordsCustomFieldEmpty(String location) {
    return 'Belum ada bidang khusus di $location.';
  }

  @override
  String get recordsCustomFieldAdd => 'Tambah bidang khusus';

  @override
  String get recordsCustomFieldArchived => 'Diarsipkan';

  @override
  String get recordsCustomFieldActive => 'Aktif';

  @override
  String get recordsCustomFieldDefinitionActions => 'Tindakan definisi';

  @override
  String get recordsCustomFieldMoveUp => 'Pindah ke atas';

  @override
  String get recordsCustomFieldMoveDown => 'Pindah ke bawah';

  @override
  String get recordsCustomFieldRestore => 'Pulihkan';

  @override
  String get recordsCustomFieldArchive => 'Arsipkan';

  @override
  String get recordsCustomFieldDiscardLegacy => 'Buang nilai lama';

  @override
  String get recordsCustomFieldDeleteInUse => 'Hapus (nilai sedang digunakan)';

  @override
  String get recordsCustomFieldSelectPrompt =>
      'Pilih bidang khusus untuk disunting, atau tambahkan yang baru.';

  @override
  String get recordsCustomFieldNew => 'Bidang khusus baru';

  @override
  String recordsCustomFieldEditName(String name) {
    return 'Sunting $name';
  }

  @override
  String recordsCustomFieldShownIn(String location) {
    return 'Ditampilkan di $location';
  }

  @override
  String get recordsCustomFieldDetails => 'Detail';

  @override
  String get recordsCustomFieldStatus => 'Status';

  @override
  String get recordsCustomFieldScope => 'Cakupan';

  @override
  String get recordsCustomFieldStoredValues => 'Nilai tersimpan';

  @override
  String get recordsCustomFieldLegacyValues => 'Nilai lama';

  @override
  String get recordsCustomFieldDeletion => 'Penghapusan';

  @override
  String get recordsCustomFieldDeletionAvailable => 'Tersedia';

  @override
  String get recordsCustomFieldDeletionUnavailable =>
      'Tidak tersedia sampai semua nilai tersimpan dihapus';

  @override
  String recordsCustomFieldUsageLoadError(String error) {
    return 'Tidak dapat memuat penggunaan: $error';
  }

  @override
  String get recordsCustomFieldProjectUuid => 'UUID proyek';

  @override
  String get recordsCustomFieldDefinitionUuid => 'UUID definisi';

  @override
  String get recordsCustomFieldSourceTemplateUuid => 'UUID templat sumber';

  @override
  String get recordsCustomFieldNotFromTemplate => 'Tidak diimpor dari templat';

  @override
  String get recordsCustomFieldTypeText => 'Teks';

  @override
  String get recordsCustomFieldTypeNumber => 'Angka';

  @override
  String get recordsCustomFieldTypeBoolean => 'Ya / Tidak';

  @override
  String get recordsCustomFieldTypeDropdown => 'Daftar pilihan';

  @override
  String get recordsCustomFieldScopeGlobal => 'Global';

  @override
  String get recordsCustomFieldScopeProject => 'Proyek saat ini';

  @override
  String get recordsCustomFieldAllCatalogs => 'Semua format katalog';

  @override
  String recordsCustomFieldCatalogOnly(String catalog) {
    return 'Hanya $catalog';
  }

  @override
  String get commonSelectAll => 'Pilih semua';

  @override
  String get commonClear => 'Hapus pilihan';

  @override
  String get commonImport => 'Impor';

  @override
  String get databaseSelectFileFailed => 'Gagal memilih berkas!';

  @override
  String get databaseReplaceConfirmTitle => 'Ganti basis data?';

  @override
  String get databaseReplace => 'Ganti';

  @override
  String get databaseRestoreCancelled =>
      'Pemulihan dibatalkan. Basis data tidak diganti.';

  @override
  String get databaseRestoreCannotStop =>
      'Pemulihan sedang mengganti data Anda dan tidak dapat dihentikan sekarang.';

  @override
  String get databaseCancelRestoreTitle => 'Batalkan pemulihan?';

  @override
  String get databaseCancelRestoreBody =>
      'Arsip masih dibaca. Keluar sekarang akan membatalkan pemulihan dan data Anda saat ini tidak diubah.';

  @override
  String get databaseKeepRestoring => 'Lanjutkan pemulihan';

  @override
  String get databaseCancelRestore => 'Batalkan pemulihan';

  @override
  String databaseReplaceFailed(String error) {
    return 'Gagal mengganti basis data: $error';
  }

  @override
  String get databaseReplaceDatabase => 'Ganti basis data';

  @override
  String get databaseReplaceWith => 'Ganti dengan';

  @override
  String get databaseSourceDescription =>
      'Arsip cadangan NAHPU atau berkas basis data SQLite.';

  @override
  String get databaseNoFileSelected => 'Belum ada berkas yang dipilih';

  @override
  String get databaseBrowse => 'Telusuri';

  @override
  String get databaseChangeFile => 'Ubah';

  @override
  String get databaseClearFile => 'Hapus pilihan berkas';

  @override
  String get databaseSupportedFormats => 'ZIP, TAR.GZ, atau SQLITE3';

  @override
  String get databaseCannotRestore => 'Tidak dapat dipulihkan';

  @override
  String get databaseSqliteDatabase => 'Basis data SQLite';

  @override
  String get databaseBackupArchive => 'Arsip cadangan NAHPU';

  @override
  String databaseBackupArchiveRestores(String database) {
    return 'Arsip cadangan NAHPU · memulihkan $database';
  }

  @override
  String get databaseBeforeReplacing => 'Sebelum mengganti';

  @override
  String get databaseReplaceWarning =>
      'Tindakan ini akan mengganti setiap catatan di NAHPU. Berkas media atau konfigurasi yang cocok dengan arsip akan ditimpa. Tindakan ini tidak dapat dibatalkan.';

  @override
  String get databaseBackupFirst => 'Cadangkan data saat ini terlebih dahulu';

  @override
  String get databaseBackupFirstSubtitle =>
      'Menyimpan arsip lengkap, termasuk media, ke folder cadangan NAHPU';

  @override
  String get databaseNoSafetyBackup =>
      'Tanpa cadangan pengaman. Catatan dan media Anda saat ini tidak disimpan sebelum diganti.';

  @override
  String get databaseComparisonTitle => 'Saat ini dan pengganti';

  @override
  String get databaseChooseFileToCompare => 'Pilih berkas untuk dibandingkan.';

  @override
  String get databaseArchiveIncludesConfigs =>
      'Arsip ini juga berisi konfigurasi pengguna, yang akan diimpor saat pemulihan.';

  @override
  String get databaseSchemaVersion => 'Versi skema';

  @override
  String get databaseAssociatedFiles => 'Berkas terkait';

  @override
  String get databaseSize => 'Ukuran';

  @override
  String databaseSchemaUpgraded(int version, int current) {
    return 'Skema pengganti v$version akan ditingkatkan ke v$current setelah pemulihan.';
  }

  @override
  String databaseSchemaNewer(int version) {
    return 'Skema pengganti v$version lebih baru dari aplikasi ini.';
  }

  @override
  String get databaseTableProjects => 'Proyek';

  @override
  String get databaseTablePersonnel => 'Personel';

  @override
  String get databaseTableTaxa => 'Takson';

  @override
  String get databaseTableSites => 'Lokasi';

  @override
  String get databaseTableCollectionEvents => 'Kegiatan koleksi';

  @override
  String get databaseTableSpecimens => 'Spesimen';

  @override
  String get databaseTableNarratives => 'Narasi';

  @override
  String get databaseTableMediaRecords => 'Catatan media';

  @override
  String get databaseIssueNotNahpu =>
      'Berkas ini bukan basis data NAHPU. Pilih arsip cadangan atau berkas basis data NAHPU.';

  @override
  String get databaseIssueNewerSchema =>
      'Basis data ini dibuat oleh versi NAHPU yang lebih baru. Perbarui NAHPU, lalu pulihkan.';

  @override
  String get databaseIssueUnreadable =>
      'Basis data ini tidak dapat dibaca. Berkas mungkin rusak.';

  @override
  String get databaseColumnCurrent => 'Saat ini';

  @override
  String get databaseColumnReplacement => 'Pengganti';

  @override
  String get databaseColumnChange => 'Perubahan';

  @override
  String get databaseRestoring => 'Memulihkan basis data';

  @override
  String get databaseRestoreHint =>
      'Memulihkan cadangan dengan banyak foto dapat memakan waktu beberapa menit. Biarkan NAHPU tetap terbuka hingga selesai.';

  @override
  String get databaseChooseDatabase => 'Pilih basis data';

  @override
  String get databaseChooseDatabaseBody =>
      'Arsip ini berisi beberapa berkas basis data di akarnya. Pilih basis data yang akan dipulihkan.';

  @override
  String get databaseConfirmWithBackup =>
      'Cadangan lengkap data Anda saat ini akan disimpan terlebih dahulu. Lanjutkan?';

  @override
  String get databaseConfirmWithoutBackup =>
      'Tidak ada cadangan yang dibuat, sehingga data Anda saat ini tidak dapat dipulihkan. Lanjutkan?';

  @override
  String get databaseReplaceSuccess => 'Berhasil 🎉';

  @override
  String get databaseReplaced => 'Basis data telah diganti!';

  @override
  String get databaseBackupFilePath => 'Jalur berkas cadangan:';

  @override
  String get databaseBackToHome => 'Kembali ke Beranda';

  @override
  String databaseIosBackupPath(
    String appDir,
    String backupDir,
    String fileName,
  ) {
    return 'Aplikasi File/Di Perangkat Saya/$appDir/$backupDir/$fileName';
  }

  @override
  String get transferCustomFieldsQrTitle => 'Kode QR kolom kustom';

  @override
  String transferCustomFieldsQrDescription(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Pindai kode ini dari perangkat NAHPU lain untuk mengimpor $count definisi kolom kustom.',
    );
    return '$_temp0';
  }

  @override
  String get transferExportCustomFields => 'Ekspor kolom kustom';

  @override
  String get transferShowQr => 'Tampilkan QR';

  @override
  String get transferExportFile => 'Ekspor berkas';

  @override
  String get transferNoCustomFields =>
      'Tidak ada kolom kustom yang dapat diekspor.';

  @override
  String transferSelectedCount(int selected, int total) {
    return '$selected dari $total dipilih';
  }

  @override
  String get transferScopeGlobal => 'Global';

  @override
  String get transferScopeCurrentProject => 'Proyek saat ini';

  @override
  String get transferArchived => 'Diarsipkan';

  @override
  String get transferImportCustomFields => 'Impor kolom kustom';

  @override
  String transferReusableDefinitions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count definisi yang dapat digunakan ulang',
    );
    return '$_temp0';
  }

  @override
  String get transferDestination => 'Tujuan';

  @override
  String get transferCustomFieldImportNote =>
      'Definisi diperiksa terlebih dahulu sebelum diimpor. ID templat yang cocok diperbarui dengan aman; kolom lain tetap tidak berubah.';

  @override
  String get transferImportSelectedConfigs => 'Impor konfigurasi yang dipilih';

  @override
  String get transferWillImport => 'Akan diimpor';

  @override
  String get transferImportSelectedConfigsConfirm =>
      'Impor konfigurasi yang dipilih?';

  @override
  String get transferConfigsImported =>
      'Konfigurasi pengguna yang dipilih telah diimpor.';

  @override
  String get transferImportConfirmationBody =>
      'Grup yang dipilih akan diganti. Kolom kustom dicocokkan berdasarkan ID templat lalu digabungkan, sehingga definisi yang ada tetap disimpan. Grup yang tidak dipilih tetap tidak berubah.';

  @override
  String get transferCustomFieldDestination => 'Tujuan kolom kustom';

  @override
  String get transferSectionUserConfigs => 'Kosakata terkontrol dan pengaturan';

  @override
  String get transferSectionRecordExportPresets => 'Preset ekspor tabel';

  @override
  String get transferSectionTemplatePresets => 'Templat dokumen';

  @override
  String get transferSectionDocumentLayouts => 'Preset tata letak dokumen';

  @override
  String get transferSectionTemplateTablePreview =>
      'Kolom pratinjau tabel templat';

  @override
  String get transferSectionCustomFields => 'Kolom kustom';

  @override
  String get transferConfigSections => 'Bagian konfigurasi';

  @override
  String get transferChooseFileToPreview =>
      'Pilih berkas konfigurasi pengguna untuk melihat pratinjau isinya.';

  @override
  String get transferSelectAtLeastOneSection =>
      'Pilih setidaknya satu bagian konfigurasi.';

  @override
  String transferEntryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entri',
    );
    return '$_temp0';
  }

  @override
  String get transferNoSavedEntries => 'Tidak ada entri tersimpan';

  @override
  String get transferOtherSettings => 'Pengaturan lain';

  @override
  String get transferNoItems => 'Tidak ada item';

  @override
  String transferMappingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pemetaan',
    );
    return '$_temp0';
  }

  @override
  String get transferIncompatiblePreset => 'Preset tidak kompatibel';

  @override
  String transferBlockCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count blok',
    );
    return '$_temp0';
  }

  @override
  String get setupReviewSetup => 'Tinjau penyiapan';

  @override
  String get setupSkipSetup => 'Lewati penyiapan';

  @override
  String get setupStepWelcome => 'Selamat datang';

  @override
  String get setupCatalogFormat => 'Format katalog';

  @override
  String get setupIdentifiers => 'Pengenal';

  @override
  String get setupStepSites => 'Lokasi';

  @override
  String get setupStepEvents => 'Peristiwa';

  @override
  String get setupStepSpecimens => 'Spesimen';

  @override
  String get setupParasites => 'Parasit';

  @override
  String get setupExportPresets => 'Prasetel ekspor';

  @override
  String get setupStepFinish => 'Selesai';

  @override
  String get setupWelcomeTitle => 'Siapkan NAHPU';

  @override
  String get setupWelcomeMessage =>
      'NAHPU mencatat spesimen menggunakan konvensi Anda sendiri. Bagian ini mengatur format nomor katalog serta kosakata terkendali untuk lokasi, peristiwa, dan spesimen.';

  @override
  String get setupWelcomeCatalogFormat =>
      'Kelompok takson yang Anda katalogkan.';

  @override
  String get setupWelcomeIdentifiers =>
      'Cara nomor lapangan dan nomor jaringan dibentuk.';

  @override
  String get setupControlledVocabularies => 'Kosakata terkendali';

  @override
  String get setupWelcomeVocabularies =>
      'Kosakata untuk lokasi, peristiwa, dan spesimen.';

  @override
  String get setupWelcomeExportPresets =>
      'Tata letak cetak dan prasetel tabel bawaan untuk ekspor.';

  @override
  String get setupWelcomeNotPermanent =>
      'Ini hanya butuh beberapa menit dan tidak ada yang permanen. Setiap jawaban dapat diubah nanti di Pengaturan, atau dengan menjalankan wizard ini lagi.';

  @override
  String get setupImportTitle => 'Sudah punya pengaturan dari tim Anda?';

  @override
  String get setupImportMessage =>
      'Sebuah tim cukup menyiapkan ini sekali. Jika tim Anda sudah mengonfigurasi NAHPU, impor berkas konfigurasi pengguna mereka dan Anda dapat melewati sisa wizard ini. Anda dapat mengekspor konfigurasi Anda untuk anggota lain di akhir.';

  @override
  String get setupCatalogFormatMessage =>
      'Format menentukan kolom pengukuran yang muncul pada catatan spesimen.';

  @override
  String get setupCatalogFormatNote =>
      'Anda dapat mengubah format katalog kapan saja, dan satu proyek dapat memuat catatan dalam lebih dari satu format. Pilih format yang paling sering Anda gunakan.';

  @override
  String setupCatalogFormatLoadError(String error) {
    return 'Tidak dapat memuat format katalog: $error';
  }

  @override
  String get setupFieldIdsTitle => 'ID lapangan spesimen';

  @override
  String get setupFieldIdsMessage =>
      'Pilih strategi ID lapangan Anda. Penyiapan ID akan diselesaikan saat membuat proyek baru.';

  @override
  String get setupIdentifiersNote =>
      'Pengaturan pengenal ini dapat diubah untuk proyek lain. Anda dapat mengaturnya di Pengaturan > Katalog.';

  @override
  String get setupTissueIdsTitle => 'ID jaringan';

  @override
  String get setupTissueIdsMessage =>
      'Beberapa koleksi memberi nomor jaringan terpisah dari spesimen. Atur di sini jika koleksi Anda menggunakannya. Jika ID jaringan tidak diatur, NAHPU otomatis menggunakan ID lapangan spesimen.';

  @override
  String get setupUseSeparateTissueId => 'Gunakan ID jaringan terpisah';

  @override
  String get setupNextTissueId => 'ID jaringan berikutnya';

  @override
  String get setupSitesTitle => 'Kosakata lokasi';

  @override
  String get setupSitesMessage =>
      'Kosakata terkendali untuk formulir lokasi dan koordinat. Tambahkan istilah Anda sendiri, hapus yang tidak akan dipakai, atau biarkan nilai bawaan. Anda dapat memperbarui daftar ini nanti di Pengaturan > Lokasi.';

  @override
  String get setupSiteTypes => 'Jenis lokasi';

  @override
  String get setupHabitatTypes => 'Jenis habitat';

  @override
  String get setupDatums => 'Datum';

  @override
  String get setupEventsTitle => 'Kosakata peristiwa koleksi';

  @override
  String get setupEventsMessage =>
      'Kosakata terkendali untuk peristiwa koleksi. Anda dapat memperbarui daftar ini nanti di Pengaturan > Peristiwa.';

  @override
  String get setupPrimaryActivities => 'Aktivitas utama';

  @override
  String get setupCollectionMethods => 'Metode koleksi';

  @override
  String get setupPersonnelRoles => 'Peran personel';

  @override
  String get setupSpecimensTitle => 'Kosakata spesimen';

  @override
  String get setupSpecimensMessage =>
      'Kosakata terkendali untuk catatan spesimen. Anda dapat memperbarui daftar ini nanti di Pengaturan > Spesimen.';

  @override
  String get setupIdentificationMethods => 'Metode identifikasi';

  @override
  String get setupLifeStages => 'Tahap hidup';

  @override
  String get setupSpecimenTypes => 'Jenis spesimen';

  @override
  String get setupTreatments => 'Perlakuan';

  @override
  String get setupConditions => 'Kondisi';

  @override
  String get setupParasitesMessage =>
      'NAHPU menyediakan formulir parasit terpisah untuk mengaitkan catatan parasit dengan spesimen. Sakelar di bawah memungkinkan Anda menyiapkan kosakata terkendali untuk catatan parasit.';

  @override
  String get setupCollectsParasites => 'Saya akan mengoleksi parasit';

  @override
  String get setupParasiteCategories => 'Kategori';

  @override
  String get setupDetectionMethods => 'Metode deteksi';

  @override
  String get setupPreparationMethods => 'Metode preparasi';

  @override
  String get setupAnatomicalLocations => 'Lokasi anatomi';

  @override
  String get setupStorage => 'Penyimpanan';

  @override
  String get setupFinishTitle => 'Penyiapan selesai';

  @override
  String get setupFinishMessage =>
      'NAHPU akan menggunakan konvensi ini untuk catatan baru.';

  @override
  String get setupNotSet => 'Belum diatur';

  @override
  String get setupFieldId => 'ID lapangan';

  @override
  String get setupProjectId => 'ID proyek';

  @override
  String get setupPersonnelId => 'ID personel';

  @override
  String get setupTissueId => 'ID jaringan';

  @override
  String get setupTissueNumberedSeparately => 'Dinomori terpisah';

  @override
  String get setupTissueFollowsSpecimen => 'Mengikuti spesimen';

  @override
  String get setupParasitesCollected => 'Dikoleksi';

  @override
  String get setupParasitesNotCollected => 'Tidak dikoleksi';

  @override
  String get setupShareTitle => 'Bagikan penyiapan ini dengan tim Anda';

  @override
  String get setupShareMessage =>
      'Tim Anda cukup melakukan ini sekali. Ekspor konfigurasi pengguna ini dan bagikan kepada anggota tim atau kolaborator agar semua orang bekerja dengan kosakata dan pengaturan yang sama.';

  @override
  String get setupFinishNote =>
      'Tidak ada yang terkunci di sini. Ubah pengaturan mana pun di Pengaturan, atau jalankan Siapkan NAHPU lagi dari menu.';

  @override
  String get setupExportPresetsMessage =>
      'Ini adalah prasetel bawaan untuk mengekspor catatan. Tata letak cetak digunakan untuk label, tag, dan buku lapangan. Prasetel tabel digunakan untuk lembar kerja. Anda dapat mengelola atau membuat prasetel sendiri di menu Pengaturan.';

  @override
  String get setupPresetDefaults => 'Bawaan';

  @override
  String get setupPresetDefaultsMessage =>
      'Prasetel yang cocok untuk format katalog apa pun.';

  @override
  String setupPresetsForFormat(String catalogFormat) {
    return 'Untuk $catalogFormat';
  }

  @override
  String get setupPresetsForFormatMessage =>
      'Prasetel opsional yang dibuat untuk format katalog ini.';

  @override
  String get setupAddSelectedPresets => 'Tambahkan prasetel terpilih';

  @override
  String setupBundledPresetsLoadError(String error) {
    return 'Tidak dapat memuat prasetel bawaan: $error';
  }

  @override
  String setupAddPresetsError(String error) {
    return 'Gagal menambahkan prasetel: $error';
  }

  @override
  String setupExportPresetCounts(int documentCount, int tabularCount) {
    return '$documentCount dokumen, $tabularCount tabel';
  }

  @override
  String get commonClose => 'Tutup';

  @override
  String get commonCreate => 'Buat';

  @override
  String get commonSelect => 'Pilih';

  @override
  String get presetsTemplateDeleteTitle => 'Hapus templat';

  @override
  String presetsDeleteNamePrompt(String name) {
    return 'Hapus \"$name\"?';
  }

  @override
  String get presetsTemplateUnusedDelete =>
      'Templat ini tidak digunakan dan akan dihapus secara permanen.';

  @override
  String presetsTemplateInUse(int blockCount, int layoutCount) {
    String _temp0 = intl.Intl.pluralLogic(
      blockCount,
      locale: localeName,
      other: '$blockCount blok',
    );
    String _temp1 = intl.Intl.pluralLogic(
      layoutCount,
      locale: localeName,
      other: '$layoutCount tata letak cetak',
    );
    return 'Templat ini digunakan oleh $_temp0 dalam $_temp1. Pilih pengganti sebelum menghapusnya.';
  }

  @override
  String presetsTemplateUsageBlocks(
    String layoutName,
    int count,
    String blocks,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'blok',
    );
    return '$layoutName: $_temp0 $blocks';
  }

  @override
  String get presetsTemplateNoReplacement =>
      'Buat templat lain dengan jenis catatan yang sama, atau ubah blok tata letak yang terdampak sebelum menghapus templat ini.';

  @override
  String get presetsTemplateReplacement => 'Templat pengganti';

  @override
  String get presetsTemplateReplacementNote =>
      'Ukuran halaman, margin, kisi, dan padding tidak akan berubah. Tinjau tata letak cetak yang terdampak setelah penggantian.';

  @override
  String get presetsTemplateEmpty =>
      'Belum ada templat. Templat menentukan konten yang ditempatkan di blok tata letak cetak.';

  @override
  String get presetsTemplateNoMatch =>
      'Tidak ada templat yang cocok dengan pencarian Anda.';

  @override
  String get presetsTemplateNoneToExport => 'Tidak ada templat untuk diekspor';

  @override
  String get presetsTemplateExportTitle => 'Ekspor templat';

  @override
  String presetsTemplateCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count templat',
    );
    return '$_temp0';
  }

  @override
  String presetsTemplateInvalidFile(String error) {
    return 'Berkas templat tidak valid: $error';
  }

  @override
  String presetsTemplateImportFailed(String error) {
    return 'Gagal mengimpor templat: $error';
  }

  @override
  String presetsTemplateImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count templat diimpor',
    );
    return '$_temp0';
  }

  @override
  String presetsTemplateImportedPartial(int imported, int offered, int limit) {
    return '$imported dari $offered templat diimpor (batas $limit)';
  }

  @override
  String presetsTemplateLoadError(String error) {
    return 'Tidak dapat memuat templat: $error';
  }

  @override
  String presetsTemplateDeleted(String name) {
    return '\"$name\" dihapus';
  }

  @override
  String presetsTemplateDeletedUpdated(String name, int count) {
    return '\"$name\" dihapus dan $count blok diperbarui';
  }

  @override
  String presetsTemplateDeleteError(String error) {
    return 'Tidak dapat menghapus templat: $error';
  }

  @override
  String get presetsTemplateSearchHint => 'Cari templat';

  @override
  String get presetsUnused => 'Tidak digunakan';

  @override
  String presetsTemplateLayoutCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tata letak',
    );
    return '$_temp0';
  }

  @override
  String get presetsTemplateOptions => 'Opsi templat';

  @override
  String get presetsRecordTypeSpecimen => 'Spesimen';

  @override
  String get presetsRecordTypeSite => 'Lokasi';

  @override
  String get presetsRecordTypeCollEvent => 'Peristiwa koleksi';

  @override
  String get presetsRecordTypeNarrative => 'Narasi';

  @override
  String get presetsRecordTypeSpecimenParts => 'Bagian spesimen';

  @override
  String get presetsRecordTypeParasites => 'Parasit';

  @override
  String get presetsRecordTypeNone => 'Tanpa catatan';

  @override
  String presetsFontReadError(String error) {
    return 'Tidak dapat membaca fon: $error';
  }

  @override
  String get presetsFonts => 'Fon';

  @override
  String presetsFontInstalled(String family) {
    return '$family terpasang';
  }

  @override
  String presetsFontInstallError(String error) {
    return 'Tidak dapat memasang fon: $error';
  }

  @override
  String presetsFontInUseTitle(String family) {
    return '$family sedang digunakan';
  }

  @override
  String presetsFontInUseBody(int count, String templates) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'templat berikut',
    );
    return 'Hapus atau ganti fon ini di $_temp0 sebelum menghapusnya:\n\n$templates';
  }

  @override
  String presetsFontDeleteTitle(String family) {
    return 'Hapus $family?';
  }

  @override
  String get presetsFontDeleteBody =>
      'Berkas fon dihapus dari instalasi ini. Templat yang menggunakannya di tempat lain tidak berubah.';

  @override
  String get presetsFontSearch => 'Cari fon';

  @override
  String get presetsFontInstall => 'Pasang fon';

  @override
  String get presetsFontFind => 'Cari fon daring';

  @override
  String get presetsFontLicenseNote =>
      'Unduh fon di peramban Anda, lalu pasang berkas .ttf atau .otf di sini. Anda bertanggung jawab atas lisensi setiap fon yang Anda pasang.';

  @override
  String get presetsFontNoMatch =>
      'Tidak ada fon yang cocok dengan pencarian Anda';

  @override
  String get presetsFontInstalledByYou => 'Dipasang oleh Anda';

  @override
  String get presetsFontBundledWithNahpu => 'Disertakan dengan NAHPU';

  @override
  String presetsFontFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count berkas',
    );
    return '$_temp0';
  }

  @override
  String presetsFontUsedByCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Digunakan oleh $count templat',
    );
    return '$_temp0';
  }

  @override
  String get presetsFontDelete => 'Hapus fon';

  @override
  String get presetsFontSelectToPreview =>
      'Pilih fon untuk melihat pratinjaunya';

  @override
  String get presetsFontBundled => 'Bawaan';

  @override
  String get presetsFontInstalledLabel => 'Terpasang';

  @override
  String presetsFontUsedBy(String templates) {
    return 'Digunakan oleh $templates';
  }

  @override
  String get presetsFontSize => 'Ukuran';

  @override
  String presetsMaxReached(int max) {
    return 'Batas maksimum $max prasetel tercapai.';
  }

  @override
  String presetsImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count prasetel diimpor',
    );
    return '$_temp0';
  }

  @override
  String presetsImportFailed(String error) {
    return 'Gagal mengimpor prasetel: $error';
  }

  @override
  String get presetsNoneToExport => 'Tidak ada prasetel untuk diekspor';

  @override
  String get presetsExportTabularTitle => 'Ekspor prasetel tabel';

  @override
  String presetsTabularCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count prasetel tabel',
    );
    return '$_temp0';
  }

  @override
  String presetsExportFailed(String error) {
    return 'Gagal mengekspor prasetel: $error';
  }

  @override
  String get presetsTabularTitle => 'Prasetel Ekspor Tabel';

  @override
  String get presetsTabPresets => 'Prasetel';

  @override
  String get presetsTabEditPreset => 'Sunting Prasetel';

  @override
  String get presetsSelectPresets => 'Pilih Prasetel';

  @override
  String get presetsTabularEmpty =>
      'Belum ada prasetel tabel. Buat atau impor satu, atau tambahkan prasetel untuk format katalog Anda di Siapkan NAHPU.';

  @override
  String presetsMappingSummary(int count, String recordType) {
    return '$count pemetaan · $recordType';
  }

  @override
  String get presetsExportThisPreset => 'Ekspor prasetel ini';

  @override
  String presetsErrorDetail(String error) {
    return 'Galat: $error';
  }

  @override
  String get presetsDeletePresetTitle => 'Hapus Prasetel';

  @override
  String presetsDeletePresetConfirm(String name) {
    return 'Apakah Anda yakin ingin menghapus prasetel \"$name\"?';
  }

  @override
  String get presetsSelectToEdit => 'Pilih prasetel untuk disunting';

  @override
  String get presetsNotFound => 'Prasetel tidak ditemukan';

  @override
  String get presetsLoadError => 'Galat saat memuat prasetel';

  @override
  String get presetsNewPreset => 'Prasetel Baru';

  @override
  String get presetsName => 'Nama Prasetel';

  @override
  String get presetsNameExists => 'Prasetel dengan nama ini sudah ada';

  @override
  String get presetsNameEmpty => 'Nama tidak boleh kosong';

  @override
  String get presetsNameInvalidChars =>
      'Hanya huruf, angka, garis bawah, dan tanda hubung yang diizinkan';

  @override
  String get presetsPreviewEmptyTitle => 'Tidak Ada Data Pratinjau';

  @override
  String get presetsPreviewEmptyBody =>
      'Tidak ada catatan yang cocok dengan filter yang dipilih, atau pemetaan masih kosong.';

  @override
  String presetsPreviewFailed(String error) {
    return 'Gagal membuat pratinjau: $error';
  }

  @override
  String presetsSaveError(String error) {
    return 'Tidak dapat menyimpan: $error';
  }

  @override
  String get presetsNameRequired => 'Nama prasetel tidak boleh kosong.';

  @override
  String presetsNameTaken(String name) {
    return 'Prasetel bernama \"$name\" sudah ada.';
  }

  @override
  String presetsUpdateError(String error) {
    return 'Tidak dapat memperbarui: $error';
  }

  @override
  String get presetsDuplicateTitle => 'Duplikasi prasetel';

  @override
  String presetsDuplicateError(String error) {
    return 'Tidak dapat menduplikasi: $error';
  }

  @override
  String presetsEditTitle(String name) {
    return 'Sunting $name';
  }

  @override
  String get presetsEditFields => 'Sunting Kolom';

  @override
  String get presetsPreviewExportTable => 'Pratinjau Tabel Ekspor';

  @override
  String get presetsSaving => 'Menyimpan…';

  @override
  String get presetsSavedAutomatically => 'Disimpan otomatis';

  @override
  String get presetsRecordType => 'Jenis catatan';

  @override
  String get presetsSpecimenTaxonGroup => 'Kelompok takson spesimen';

  @override
  String get presetsHeaderFormat => 'Format tajuk yang dihasilkan';

  @override
  String get presetsHeaderNahpuNamespace =>
      'Ruang nama NAHPU (nahpu:table.field)';

  @override
  String presetsPreviewSites(int count) {
    return 'Pratinjau Lokasi ($count dipilih)';
  }

  @override
  String presetsPreviewEvents(int count) {
    return 'Pratinjau Peristiwa ($count dipilih)';
  }

  @override
  String presetsPreviewNarratives(int count) {
    return 'Pratinjau Narasi ($count dipilih)';
  }

  @override
  String presetsPreviewSpecimenParts(int count) {
    return 'Pratinjau Bagian Spesimen ($count dipilih)';
  }

  @override
  String presetsPreviewParasites(int count) {
    return 'Pratinjau Parasit ($count dipilih)';
  }

  @override
  String presetsPreviewSpecimens(int count) {
    return 'Pratinjau Spesimen ($count dipilih)';
  }

  @override
  String get presetsPreviewCurrentProject => 'Proyek Saat Ini (Tidak Ada)';

  @override
  String get presetsDocumentTitle => 'Prasetel Dokumen';

  @override
  String get presetsPrintLayouts => 'Tata letak cetak';

  @override
  String get presetsTemplates => 'Templat';

  @override
  String get presetsDocumentNew => 'Prasetel dokumen baru';

  @override
  String presetsRenamed(String name) {
    return 'Nama diubah menjadi $name';
  }

  @override
  String presetsRenameFailed(String error) {
    return 'Gagal mengubah nama: $error';
  }

  @override
  String get presetsExportPrintLayoutsTitle => 'Ekspor tata letak cetak';

  @override
  String presetsPrintLayoutCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tata letak cetak',
    );
    return '$_temp0';
  }

  @override
  String presetsDocumentInvalidFile(String error) {
    return 'Berkas tata letak dokumen tidak valid: $error';
  }

  @override
  String get presetsDocumentEmpty =>
      'Belum ada tata letak cetak. Buat atau impor satu, atau muat tata letak bawaan.';

  @override
  String get presetsIncompatible => 'Prasetel tidak kompatibel';

  @override
  String get presetsIncompatibleBody =>
      'Prasetel ini tidak kompatibel dengan versi saat ini.';

  @override
  String get presetsPreviewNoRecords =>
      'Tidak ada catatan pratinjau untuk jenis ini';

  @override
  String get presetsPreviewSelectSpecimenParts =>
      'Pilih bagian spesimen untuk pratinjau';

  @override
  String get presetsPreviewSelectParasites => 'Pilih parasit untuk pratinjau';

  @override
  String get presetsPreviewSelectSpecimens => 'Pilih spesimen untuk pratinjau';

  @override
  String get presetsTableColumns => 'Kolom tabel';

  @override
  String get commonApply => 'Terapkan';

  @override
  String get exportFieldsTitle => 'Sunting pemetaan prasetel';

  @override
  String get exportFieldsAvailableFields => 'Bidang tersedia';

  @override
  String get exportFieldsSelectedMappings => 'Pemetaan terpilih';

  @override
  String get exportFieldsNoPreviewTitle => 'Tidak ada data pratinjau';

  @override
  String get exportFieldsNoPreviewBody =>
      'Tidak ada catatan yang cocok dengan filter terpilih, atau pemetaan masih kosong.';

  @override
  String exportFieldsPreviewFailed(String error) {
    return 'Gagal membuat pratinjau: $error';
  }

  @override
  String get exportFieldsInsertSourceField => 'Sisipkan bidang sumber';

  @override
  String get exportFieldsDisplayTableField => 'Tabel::Bidang';

  @override
  String get exportFieldsDisplayFieldOnly => 'Bidang saja';

  @override
  String get exportFieldsOtherFields => 'Bidang lainnya';

  @override
  String get exportFieldsSelectField => 'Pilih bidang';

  @override
  String get exportFieldsChooseField => 'Pilih bidang';

  @override
  String get exportFieldsCloseFieldPicker => 'Tutup pemilih bidang';

  @override
  String get exportFieldsSearchFields => 'Cari bidang atau tabel';

  @override
  String get exportFieldsNoMatchingFields => 'Tidak ada bidang yang cocok.';

  @override
  String get exportFieldsAddCustomField => 'Tambah bidang kustom';

  @override
  String get exportFieldsAddNested => 'Tambah bersarang';

  @override
  String get exportFieldsUnnamed => 'Tanpa nama';

  @override
  String exportFieldsCardNested(String name) {
    return 'Bersarang: $name';
  }

  @override
  String exportFieldsCardList(String name) {
    return 'Daftar: $name';
  }

  @override
  String exportFieldsCardField(String name) {
    return 'Bidang: $name';
  }

  @override
  String exportFieldsCardCustom(String name) {
    return 'Kustom: $name';
  }

  @override
  String exportFieldsCardIndexedColumns(String style) {
    return 'Kolom berindeks · $style';
  }

  @override
  String get exportFieldsCardDarwinCoreSeparator =>
      'Satu kolom · pemisah \" | \" Darwin Core';

  @override
  String exportFieldsCardSeparator(String separator) {
    return 'Satu kolom · pemisah $separator';
  }

  @override
  String exportFieldsCardFormat(String format, String options) {
    return 'Format: $format · Opsi: $options';
  }

  @override
  String get exportFieldsCustomize => 'Sesuaikan';

  @override
  String get exportFieldsOneColumn => 'Satu kolom';

  @override
  String get exportFieldsIndexedColumns => 'Kolom berindeks';

  @override
  String get exportFieldsRepeatedRows => 'Baris berulang';

  @override
  String get exportFieldsFormatConditionalBrackets => 'kurung bersyarat';

  @override
  String get exportFieldsFormatConditionalField => 'bidang bersyarat';

  @override
  String get exportFieldsFormatConditionalValue => 'nilai bersyarat';

  @override
  String get exportFieldsMappingType => 'Jenis pemetaan';

  @override
  String get exportFieldsKindSingle => 'Bidang tunggal';

  @override
  String get exportFieldsKindCustom => 'Bidang kustom';

  @override
  String get exportFieldsKindList => 'Bidang daftar';

  @override
  String get exportFieldsKindNested => 'Catatan bersarang';

  @override
  String get exportFieldsSourceField => 'Bidang sumber';

  @override
  String get exportFieldsSourceFieldHelper =>
      'Pilih bidang NAHPU yang mengisi kolom ini.';

  @override
  String get exportFieldsColumnNameOptional => 'Nama kolom (opsional)';

  @override
  String get exportFieldsColumnNameOptionalHelper =>
      'Biarkan kosong untuk memakai nama bidang sumber.';

  @override
  String get exportFieldsListOutput => 'Keluaran daftar';

  @override
  String exportFieldsExample(String example) {
    return 'Contoh: $example';
  }

  @override
  String get exportFieldsDarwinCoreListSeparator =>
      'Nilai daftar Darwin Core dipisahkan dengan \" | \".';

  @override
  String get exportFieldsSeparator => 'Pemisah';

  @override
  String get exportFieldsSeparatorPipe => 'Garis tegak (A | B)';

  @override
  String get exportFieldsSeparatorComma => 'Koma (A, B)';

  @override
  String get exportFieldsSeparatorSemicolon => 'Titik koma (A; B)';

  @override
  String get exportFieldsSeparatorSlash => 'Garis miring (A / B)';

  @override
  String get exportFieldsSeparatorNewLine => 'Baris baru';

  @override
  String get exportFieldsSeparatorBulleted => 'Berpoin';

  @override
  String get exportFieldsSeparatorCustom => 'Kustom';

  @override
  String get exportFieldsCustomSeparator => 'Pemisah kustom';

  @override
  String get exportFieldsValueFormat => 'Format nilai';

  @override
  String get exportFieldsValueNormal => 'Teks biasa';

  @override
  String get exportFieldsValueEncoded => 'Teks terkode';

  @override
  String get exportFieldsValueCoordinates => 'Koordinat';

  @override
  String get exportFieldsValueConditionalBrackets => 'Kurung bersyarat';

  @override
  String get exportFieldsValueConditionalField => 'Bidang bersyarat';

  @override
  String get exportFieldsValueConditionalValue => 'Nilai bersyarat';

  @override
  String get exportFieldsReplacementText => 'Teks pengganti';

  @override
  String get exportFieldsReplacementTextHelper =>
      'Ditulis jika kondisi terpenuhi; jika tidak, nilai asli dipertahankan.';

  @override
  String get exportFieldsColumnName => 'Nama kolom';

  @override
  String get exportFieldsColumnNameHelper =>
      'Beri nama kolom keluaran yang berisi nilai kustom.';

  @override
  String get exportFieldsRelatedRecords => 'Catatan terkait';

  @override
  String get exportFieldsRelatedRecordsHelper =>
      'Pilih kelompok catatan berulang yang akan diekspor.';

  @override
  String get exportFieldsSelectedChildFields => 'Bidang anak terpilih';

  @override
  String get exportFieldsSelectChildFieldHint =>
      'Pilih setidaknya satu bidang anak di bawah.';

  @override
  String get exportFieldsMoveUp => 'Pindah ke atas';

  @override
  String get exportFieldsMoveDown => 'Pindah ke bawah';

  @override
  String get exportFieldsRemoveField => 'Hapus bidang';

  @override
  String get exportFieldsChooseChildFields => 'Pilih bidang anak';

  @override
  String get exportFieldsColumnPrefixOptional => 'Awalan kolom (opsional)';

  @override
  String get exportFieldsNestedOutput => 'Keluaran bersarang';

  @override
  String get exportFieldsNestedOneColumnHint =>
      'Gabungkan semua catatan anak ke dalam satu sel.';

  @override
  String get exportFieldsNestedIndexedHint =>
      'Buat satu kelompok kolom untuk setiap catatan.';

  @override
  String get exportFieldsNestedRepeatedHint =>
      'Buat satu baris ekspor untuk setiap catatan anak.';

  @override
  String get exportFieldsNestedRepeatedTaken =>
      'Pemetaan lain sudah memperluas baris ekspor.';

  @override
  String get exportFieldsFieldSeparator => 'Pemisah bidang';

  @override
  String get exportFieldsRecordSeparator => 'Pemisah catatan';

  @override
  String get exportFieldsAdvanced => 'Lanjutan';

  @override
  String get exportFieldsRawExpression => 'Ekspresi sumber mentah';

  @override
  String get exportFieldsRawFormatOption => 'Opsi format mentah';

  @override
  String get exportFieldsRawFormatOptionHelper =>
      'Contoh: enum, dms, atau custom_map:0=No.';

  @override
  String get exportFieldsEmptyValue => 'Nilai kosong';

  @override
  String get exportFieldsEmptyBlank => 'Kosong';

  @override
  String get exportFieldsEmptyCustomText => 'Teks kustom';

  @override
  String get exportFieldsCustomEmptyText => 'Teks kustom untuk nilai kosong';

  @override
  String get exportFieldsRawNamespace => 'Namespace mentah catatan terkait';

  @override
  String exportFieldsErrorReplacement(int number, String error) {
    return 'Penggantian $number: $error';
  }

  @override
  String get exportFieldsErrorChooseGroup => 'Pilih kelompok catatan terkait.';

  @override
  String get exportFieldsErrorChooseChild =>
      'Pilih setidaknya satu bidang anak.';

  @override
  String get exportFieldsErrorSeparatorsEmpty =>
      'Pemisah bidang dan catatan tidak boleh kosong.';

  @override
  String get exportFieldsErrorMultiFieldHeader =>
      'Tetapkan judul kolom kustom untuk pemetaan gabungan beberapa bidang.';

  @override
  String get exportFieldsErrorAddSegment =>
      'Tambahkan setidaknya satu bidang atau segmen teks.';

  @override
  String get exportFieldsErrorChooseSource => 'Pilih bidang sumber.';

  @override
  String get exportFieldsErrorCompositeHeader =>
      'Tetapkan judul kolom kustom untuk pemetaan komposit.';

  @override
  String get exportFieldsErrorIndexedSingleSource =>
      'Daftar berindeks memerlukan tepat satu bidang sumber.';

  @override
  String get exportFieldsErrorConditionalSingleSource =>
      'Keluaran bersyarat memerlukan tepat satu bidang sumber.';

  @override
  String get exportFieldsErrorAddCondition =>
      'Tambahkan setidaknya satu kondisi.';

  @override
  String get exportFieldsErrorReplacementText => 'Masukkan teks pengganti.';

  @override
  String get exportFieldsErrorControllingField =>
      'Pilih bidang pengendali untuk setiap kondisi kurung.';

  @override
  String get exportFieldsErrorComparisonValue =>
      'Masukkan nilai pembanding untuk setiap kondisi kurung.';

  @override
  String get exportFieldsErrorSelfDependency =>
      'Bidang bersyarat tidak boleh bergantung pada dirinya sendiri.';

  @override
  String get exportFieldsCustomValue => 'Nilai kustom';

  @override
  String get exportFieldsCustomValueHelp =>
      'Bidang dan teks ditulis dari kiri ke kanan. Tambahkan segmen sebanyak yang diperlukan.';

  @override
  String get exportFieldsCustomValueEmpty =>
      'Tambahkan bidang atau teks untuk memulai.';

  @override
  String get exportFieldsTextOrSeparator => 'Teks atau pemisah';

  @override
  String get exportFieldsShowLabel => 'Tampilkan label';

  @override
  String get exportFieldsEditConditionalText => 'Sunting teks bersyarat';

  @override
  String get exportFieldsMoveSegmentUp => 'Pindahkan segmen ke atas';

  @override
  String get exportFieldsMoveSegmentDown => 'Pindahkan segmen ke bawah';

  @override
  String get exportFieldsRemoveSegment => 'Hapus segmen';

  @override
  String get exportFieldsAddField => 'Tambah bidang';

  @override
  String get exportFieldsAddText => 'Tambah teks';

  @override
  String get exportFieldsAddConditionalText => 'Tambah teks bersyarat';

  @override
  String exportFieldsExpression(String expression) {
    return 'Ekspresi: $expression';
  }

  @override
  String get exportFieldsAddSourceField => 'Tambah bidang sumber';

  @override
  String get exportFieldsConditionalText => 'Teks bersyarat';

  @override
  String get exportFieldsTextWhenMatched => 'Teks jika cocok';

  @override
  String exportFieldsTextWhenMatchedHelper(String example) {
    return 'Bidang seperti $example akan diisi.';
  }

  @override
  String get exportFieldsTextOtherwise => 'Teks jika tidak (opsional)';

  @override
  String get exportFieldsTextOtherwiseHelper =>
      'Biarkan kosong agar tidak menulis apa pun.';

  @override
  String get exportFieldsSummaryOr => 'atau';

  @override
  String get exportFieldsSummaryAnd => 'dan';

  @override
  String exportFieldsSummaryIf(String conditions, String text) {
    return 'Jika $conditions → \"$text\"';
  }

  @override
  String exportFieldsSummaryIfOtherwise(
    String conditions,
    String text,
    String otherwise,
  ) {
    return 'Jika $conditions → \"$text\", jika tidak \"$otherwise\"';
  }

  @override
  String exportFieldsSummaryEquals(String field, String value) {
    return '$field sama dengan \"$value\"';
  }

  @override
  String exportFieldsSummaryNotEquals(String field, String value) {
    return '$field tidak sama dengan \"$value\"';
  }

  @override
  String exportFieldsSummaryContains(String field, String value) {
    return '$field mengandung \"$value\"';
  }

  @override
  String exportFieldsSummaryIsNotEmpty(String field) {
    return '$field tidak kosong';
  }

  @override
  String exportFieldsSummaryIsEmpty(String field) {
    return '$field kosong';
  }

  @override
  String get exportFieldsValueConditions => 'Kondisi nilai';

  @override
  String get exportFieldsFieldConditions => 'Kondisi bidang';

  @override
  String get exportFieldsConditionsHelp =>
      'Membandingkan nilai mentah yang tersimpan. Nilai pengendali yang kosong tidak pernah cocok.';

  @override
  String get exportFieldsMatchLogic => 'Logika pencocokan';

  @override
  String get exportFieldsMatchAny => 'Salah satu kondisi (ATAU)';

  @override
  String get exportFieldsMatchAll => 'Semua kondisi (DAN)';

  @override
  String get exportFieldsAddCondition => 'Tambah kondisi';

  @override
  String get exportFieldsControllingField => 'Bidang pengendali';

  @override
  String get exportFieldsOperatorEquals => 'Sama dengan';

  @override
  String get exportFieldsOperatorNotEquals => 'Tidak sama dengan';

  @override
  String get exportFieldsOperatorContains => 'Mengandung';

  @override
  String get exportFieldsOperatorIsNotEmpty => 'Tidak kosong';

  @override
  String get exportFieldsOperatorIsEmpty => 'Kosong';

  @override
  String get exportFieldsValue => 'Nilai';

  @override
  String get exportFieldsRemoveCondition => 'Hapus kondisi';

  @override
  String get exportFieldsIndexedColumnNames => 'Nama kolom berindeks';

  @override
  String exportFieldsIndexedUnderscore(String example) {
    return 'Garis bawah: $example';
  }

  @override
  String exportFieldsIndexedCompact(String example) {
    return 'Ringkas: $example';
  }

  @override
  String exportFieldsIndexedBrackets(String example) {
    return 'Kurung siku: $example';
  }

  @override
  String get exportFieldsOutputExample => 'Contoh keluaran';

  @override
  String get exportFieldsOutputExampleEmpty =>
      'Lengkapi pemetaan untuk melihat bentuk keluarannya.';

  @override
  String get exportFieldsOutputExampleRows =>
      'Setiap catatan anak membuat baris ekspor baru.';

  @override
  String get exportFieldsCustomizeNested => 'Sesuaikan pemetaan bersarang';

  @override
  String get exportFieldsCustomizeField => 'Sesuaikan pemetaan bidang';

  @override
  String get exportFieldsPreviewTitle => 'Pratinjau ekspor';

  @override
  String exportFieldsPreviewShowing(int shown, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: 'Menampilkan $shown dari $total catatan',
    );
    return '$_temp0';
  }

  @override
  String get commonSave => 'Simpan';

  @override
  String get commonYes => 'Ya';

  @override
  String get commonNo => 'Tidak';

  @override
  String get formsChooseOne => 'Pilih salah satu';

  @override
  String formsErrorDetail(String error) {
    return 'Galat: $error';
  }

  @override
  String formsAddValue(String type) {
    return 'Tambah $type';
  }

  @override
  String formsEnterValue(String type) {
    return 'Masukkan $type';
  }

  @override
  String get formsMatchDatabase => 'Cocokkan dengan basis data';

  @override
  String formsMatchDatabaseTitle(String plural) {
    return 'Cocokkan $plural dengan basis data?';
  }

  @override
  String get formsMatchAppendMissing => 'Tambahkan yang belum ada';

  @override
  String get formsMatchOverrideAll => 'Timpa semua';

  @override
  String get formsMatchHelp =>
      'Gunakan ini saat menerima catatan dari seseorang yang kosakata terkendalinya tidak Anda miliki.';

  @override
  String formsMatchAppendDescription(String plural) {
    return 'Tambahkan nilai yang ditemukan di basis data tanpa mengubah $plural yang sudah ada.';
  }

  @override
  String formsMatchOverrideDescription(String plural) {
    return 'Ganti semua $plural yang dikonfigurasi dengan nilai yang saat ini ada di basis data.';
  }

  @override
  String get formsVocabSiteType => 'jenis lokasi';

  @override
  String get formsVocabSiteTypePlural => 'jenis lokasi';

  @override
  String get formsVocabHabitatType => 'jenis habitat';

  @override
  String get formsVocabHabitatTypePlural => 'jenis habitat';

  @override
  String get formsVocabDatum => 'datum';

  @override
  String get formsVocabDatumPlural => 'datum';

  @override
  String get formsVocabPrimaryActivity => 'kegiatan utama';

  @override
  String get formsVocabPrimaryActivityPlural => 'kegiatan utama';

  @override
  String get formsVocabCollectionMethod => 'metode koleksi';

  @override
  String get formsVocabCollectionMethodPlural => 'metode koleksi';

  @override
  String get formsVocabPersonnelRole => 'peran personel';

  @override
  String get formsVocabPersonnelRolePlural => 'peran personel';

  @override
  String get formsVocabIdentificationMethod => 'metode identifikasi';

  @override
  String get formsVocabIdentificationMethodPlural => 'metode identifikasi';

  @override
  String get formsVocabLifeStage => 'tahap hidup';

  @override
  String get formsVocabLifeStagePlural => 'tahap hidup';

  @override
  String get formsVocabSpecimenType => 'jenis spesimen';

  @override
  String get formsVocabSpecimenTypePlural => 'jenis spesimen';

  @override
  String get formsVocabTreatment => 'perlakuan';

  @override
  String get formsVocabTreatmentPlural => 'perlakuan';

  @override
  String get formsVocabCondition => 'kondisi';

  @override
  String get formsVocabConditionPlural => 'kondisi';

  @override
  String get formsVocabParasiteCategory => 'kategori';

  @override
  String get formsVocabParasiteCategoryPlural => 'kategori';

  @override
  String get formsVocabDetectionMethod => 'metode deteksi';

  @override
  String get formsVocabDetectionMethodPlural => 'metode deteksi';

  @override
  String get formsVocabPreparationMethod => 'metode preparasi';

  @override
  String get formsVocabPreparationMethodPlural => 'metode preparasi';

  @override
  String get formsVocabAnatomicalLocation => 'lokasi anatomi';

  @override
  String get formsVocabAnatomicalLocationPlural => 'lokasi anatomi';

  @override
  String get formsVocabStorageValue => 'nilai penyimpanan';

  @override
  String get formsVocabStorageValuePlural => 'nilai penyimpanan';

  @override
  String get formsNextId => 'ID berikutnya';

  @override
  String get formsNextNumber => 'Nomor berikutnya';

  @override
  String get formsNumberedIdNoPreview =>
      'Atur nomor berikutnya untuk penomoran otomatis · Nol di depan dipertahankan';

  @override
  String formsNumberedIdPreview(String label, String preview) {
    return '$label: $preview · Nol di depan dipertahankan';
  }

  @override
  String get formsBundledDocuments => 'Dokumen';

  @override
  String get formsBundledTabularRecords => 'Catatan tabel';

  @override
  String get formsBundledTemplates => 'Templat';

  @override
  String formsBundledAdded(String description) {
    return 'Sudah ditambahkan · $description';
  }

  @override
  String get formsDescriptionOptional => 'Deskripsi (opsional)';

  @override
  String formsDescriptionTooLong(int max) {
    return 'Gunakan $max karakter atau kurang.';
  }

  @override
  String get formsShowInfo => 'Tampilkan informasi';

  @override
  String get formsInfo => 'Info';

  @override
  String formsDeleteConfirmPrompt(String text) {
    return 'Ketik `$text` untuk mengaktifkan penghapusan';
  }

  @override
  String get formsDeleteConfirmHint => 'Masukkan teks konfirmasi';

  @override
  String get formsSearchAll => 'Semua';

  @override
  String get formsSearchFieldNumber => 'Nomor lapangan';

  @override
  String get formsSearchCataloger => 'Katalogator';

  @override
  String get formsSearchPreparator => 'Preparator';

  @override
  String get formsSearchCollector => 'Kolektor';

  @override
  String get formsSearchCondition => 'Kondisi';

  @override
  String get formsSearchPrepDate => 'Tanggal preparasi';

  @override
  String get formsSearchPrepTime => 'Waktu preparasi';

  @override
  String get formsSearchTaxa => 'Takson';

  @override
  String get formsSearchPrepType => 'Jenis preparasi';

  @override
  String get formsSiteId => 'ID lokasi';

  @override
  String get formsSiteIdHint => 'Masukkan lokasi';

  @override
  String get formsSiteName => 'Nama lokasi';

  @override
  String get formsPresetDuplicate => 'Duplikat';

  @override
  String get formsPresetName => 'Nama prasetel';

  @override
  String get formsPresetUpdateHelper =>
      'Pilih Perbarui untuk menyimpan nama dan deskripsi';

  @override
  String get formsPresetUpdate => 'Perbarui';

  @override
  String formsCustomFieldLoadError(String error) {
    return 'Tidak dapat memuat bidang khusus: $error';
  }

  @override
  String get formsCustomFieldManage => 'Kelola bidang khusus';

  @override
  String get formsEnterNumber => 'Masukkan angka';

  @override
  String get formsCustomFieldUnset => 'Belum diatur';

  @override
  String formsCustomFieldArchivedOption(String label) {
    return '$label (diarsipkan)';
  }

  @override
  String sharedPresetCreateTooltip(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'template': 'Buat templat baru',
      'customField': 'Buat bidang khusus baru',
      'other': 'Buat prasetel baru',
    });
    return '$_temp0';
  }

  @override
  String sharedPresetOptions(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'template': 'Opsi templat',
      'customField': 'Opsi bidang khusus',
      'other': 'Opsi prasetel',
    });
    return '$_temp0';
  }

  @override
  String get sharedPresetCreateNew => 'Buat baru';

  @override
  String get sharedPresetScanQr => 'Pindai QR';

  @override
  String sharedPresetExportSelected(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'template': 'Ekspor templat ini',
      'customField': 'Ekspor bidang khusus ini',
      'other': 'Ekspor prasetel ini',
    });
    return '$_temp0';
  }

  @override
  String sharedPresetExportAll(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'template': 'Ekspor semua templat',
      'customField': 'Ekspor semua bidang khusus',
      'other': 'Ekspor semua prasetel',
    });
    return '$_temp0';
  }

  @override
  String get sharedLoadDefaults => 'Muat bawaan';

  @override
  String get sharedShowMore => 'Tampilkan lebih banyak';

  @override
  String get sharedShowLess => 'Tampilkan lebih sedikit';

  @override
  String get sharedShare => 'Bagikan';

  @override
  String get sharedUpdate => 'Perbarui';

  @override
  String get sharedAdd => 'Tambah';

  @override
  String get sharedExportAs => 'Ekspor sebagai…';

  @override
  String get sharedFind => 'Cari';

  @override
  String sharedDeleteSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hapus $count item',
    );
    return '$_temp0';
  }

  @override
  String get sharedDeleteSelectedTitle => 'Hapus item terpilih';

  @override
  String get sharedDeleteSelectedBody =>
      'Apakah Anda yakin ingin menghapus item yang dipilih?';

  @override
  String get sharedTryAgain => 'Coba lagi';

  @override
  String sharedExportTimeLeft(String duration) {
    return 'sekitar $duration lagi';
  }

  @override
  String get sharedExportCancelling => 'Membatalkan…';

  @override
  String sharedExportFilesOfTotal(int completed, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total berkas',
    );
    return '$completed dari $_temp0';
  }

  @override
  String sharedExportFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count berkas',
    );
    return '$_temp0';
  }

  @override
  String sharedExportBytesOfTotal(String processed, String total) {
    return '$processed dari $total';
  }

  @override
  String sharedExportElapsed(String duration) {
    return '$duration berlalu';
  }

  @override
  String sharedExportUnitsOfTotal(int completed, int total) {
    return '$completed dari $total';
  }

  @override
  String get sharedExportCancelledBody =>
      'Tidak ada berkas yang disimpan. Tidak ada yang diubah di perangkat ini.';

  @override
  String sharedExportStoppedAt(String step) {
    return 'Berhenti saat mengerjakan: $step';
  }

  @override
  String get sharedExportDidNotFinish => 'Ekspor tidak selesai.';

  @override
  String get sharedExportCancelled => 'Ekspor dibatalkan';

  @override
  String get sharedExportFailed => 'Ekspor gagal';

  @override
  String get sharedExportComplete => 'Ekspor selesai';

  @override
  String get sharedSaved => 'Tersimpan';

  @override
  String get sharedHideSaveLocation => 'Sembunyikan lokasi simpan';

  @override
  String get sharedExportTemporaryNote =>
      'Bagikan berkas ini sekarang untuk menyimpannya. NAHPU menghapusnya saat Anda mengekspor lagi.';

  @override
  String get sharedExportAppStorageNote =>
      'Disimpan di penyimpanan aplikasi NAHPU. Pilih folder lain kali untuk menyimpan langsung ke sana.';

  @override
  String sharedExportFinishedIn(String duration) {
    return 'Selesai dalam $duration';
  }

  @override
  String sharedExportSizeIn(String size, String duration) {
    return '$size dalam $duration';
  }

  @override
  String get sharedOpenDirectory => 'Buka direktori';

  @override
  String get sharedSaveToDevice => 'Simpan ke perangkat';

  @override
  String sharedSaveCopyTooLarge(String limit) {
    return 'Terlalu besar untuk disimpan melalui aplikasi Files, yang dibatasi hingga $limit. Pilih folder sebelum mengekspor untuk menulis berkas sebesar ini langsung ke perangkat Anda.';
  }

  @override
  String get sharedQrExportImage => 'Ekspor kode QR sebagai gambar';

  @override
  String get sharedQrImageTooLarge =>
      'Data ini terlalu besar untuk gambar kode QR.';

  @override
  String get sharedLoadDefaultsDescription =>
      'Pilih prasetel bawaan yang akan ditambahkan. Prasetel yang sudah Anda miliki tidak diubah.';

  @override
  String get sharedLoadDefaultsNone =>
      'Tidak ada prasetel bawaan untuk jenis ini.';

  @override
  String get sharedLoadDefaultsGenericTitle => 'Bawaan';

  @override
  String get sharedLoadDefaultsGenericMessage =>
      'Prasetel yang sesuai untuk format katalog apa pun.';

  @override
  String sharedLoadDefaultsForFormat(String format) {
    return 'Untuk $format';
  }

  @override
  String get sharedLoadDefaultsForFormatMessage =>
      'Prasetel opsional yang dibuat untuk format katalog ini.';

  @override
  String get sharedLoadDefaultsLayoutsNote =>
      'Tata letak menyertakan templat yang digunakan untuk mencetak.';

  @override
  String get sharedLoadSelected => 'Muat yang dipilih';

  @override
  String sharedLoadDefaultsLoadError(String error) {
    return 'Tidak dapat memuat prasetel bawaan: $error';
  }

  @override
  String sharedLoadDefaultsFailed(String error) {
    return 'Gagal memuat prasetel bawaan: $error';
  }

  @override
  String get sharedIncludeLinkedTemplates => 'Sertakan templat tertaut';

  @override
  String sharedLinkedTemplateList(int count, String names) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count templat: $names',
    );
    return '$_temp0';
  }

  @override
  String sharedExportedTo(String path) {
    return 'Diekspor ke $path';
  }

  @override
  String sharedExportFailedError(String error) {
    return 'Ekspor gagal: $error';
  }

  @override
  String get sharedExportProjectInfo => 'Ekspor info proyek';

  @override
  String get sharedExportProjectInfoDescription =>
      'Ekspor informasi proyek ini sebagai JSON.';

  @override
  String get sharedSortOrder => 'Urutan';

  @override
  String get sharedSortAscending => 'Naik';

  @override
  String get sharedSortDescending => 'Turun';

  @override
  String get sharedSortId => 'ID';

  @override
  String get sharedSortRecordOrder => 'Urutan catatan';

  @override
  String get sharedSortSiteId => 'ID lokasi';

  @override
  String get sharedSortStateProvince => 'Negara bagian/provinsi';

  @override
  String get sharedSortPreciseLocality => 'Lokalitas tepat';

  @override
  String get sharedSortEventId => 'ID kegiatan';

  @override
  String get sharedSortStartDate => 'Tanggal mulai';

  @override
  String get sharedSortFieldId => 'ID lapangan';

  @override
  String get sharedSortCataloger => 'Pengatalog';

  @override
  String get sharedSortSpecies => 'Spesies';

  @override
  String get sharedSortDate => 'Tanggal';

  @override
  String get sharedSortWriter => 'Penulis';

  @override
  String sharedImportRecordType(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'site': 'Impor lokasi',
      'event': 'Impor kegiatan',
      'other': 'Impor spesimen',
    });
    return '$_temp0';
  }

  @override
  String sharedCreateNewRecordType(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'site': 'Buat lokasi baru',
      'event': 'Buat kegiatan baru',
      'other': 'Buat spesimen baru',
    });
    return '$_temp0';
  }

  @override
  String sharedUpdateExistingRecordType(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'site': 'Perbarui lokasi yang ada',
      'event': 'Perbarui kegiatan yang ada',
      'other': 'Perbarui spesimen yang ada',
    });
    return '$_temp0';
  }

  @override
  String sharedExportRecordType(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'site': 'Ekspor lokasi',
      'event': 'Ekspor kegiatan',
      'other': 'Ekspor spesimen',
    });
    return '$_temp0';
  }

  @override
  String sharedExportRecordJson(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'site': 'Ekspor catatan lokasi ini sebagai JSON.',
      'event': 'Ekspor catatan kegiatan ini sebagai JSON.',
      'other': 'Ekspor catatan spesimen ini sebagai JSON.',
    });
    return '$_temp0';
  }

  @override
  String sharedExportRecordMedia(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Catatan ini memiliki $count berkas media tertaut yang akan disertakan dalam arsip.',
    );
    return '$_temp0';
  }

  @override
  String sharedReusesSavedLocality(String locality) {
    return 'Menggunakan kembali lokalitas tersimpan: $locality';
  }

  @override
  String get sharedContinue => 'Lanjutkan';

  @override
  String get sharedBack => 'Kembali';

  @override
  String get sharedChooseEventSite => 'Pilih lokasi kegiatan';

  @override
  String get sharedChooseEventSiteDescription =>
      'Kegiatan ini memiliki lokasi tertaut. Pilih lokasi yang ada atau buat lokasi yang disertakan sebagai lokasi baru.';

  @override
  String get sharedCreateEmbeddedSite => 'Buat lokasi yang disertakan';

  @override
  String get sharedCreateEmbeddedEvent => 'Buat kegiatan yang disertakan';

  @override
  String get sharedCreateEmbeddedTaxonomy => 'Buat taksonomi yang disertakan';

  @override
  String get sharedChooseSpecimenEvent => 'Pilih kegiatan spesimen';

  @override
  String get sharedChooseSpecimenTaxonomy => 'Pilih taksonomi spesimen';

  @override
  String sharedCoordinateCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count koordinat',
    );
    return '$_temp0';
  }

  @override
  String sharedPersonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count orang',
    );
    return '$_temp0';
  }

  @override
  String sharedCollMethodCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count metode koleksi',
    );
    return '$_temp0';
  }

  @override
  String sharedPersonnelAssignmentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count penugasan personel',
    );
    return '$_temp0';
  }

  @override
  String get sharedEnvironmentalData => 'data lingkungan';

  @override
  String sharedMediaFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count berkas media',
    );
    return '$_temp0';
  }

  @override
  String get sharedNoAssociatedRecords => 'Tidak ada catatan terkait';

  @override
  String sharedSiteLabel(String id) {
    return 'Lokasi $id';
  }

  @override
  String sharedEventLabel(String id) {
    return 'Kegiatan $id';
  }

  @override
  String sharedSpecimenLabel(String id) {
    return 'Spesimen $id';
  }

  @override
  String sharedTaxonLabel(String id) {
    return 'Takson $id';
  }

  @override
  String get sharedRecordLabel => 'Catatan';

  @override
  String sharedSpecimenImportSummary(
    int partCount,
    int associatedCount,
    int mediaCount,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      partCount,
      locale: localeName,
      other: '$partCount bagian',
    );
    String _temp1 = intl.Intl.pluralLogic(
      associatedCount,
      locale: localeName,
      other: '$associatedCount catatan terkait',
    );
    String _temp2 = intl.Intl.pluralLogic(
      mediaCount,
      locale: localeName,
      other: '$mediaCount berkas media',
    );
    return 'Mencakup $_temp0, $_temp1, dan $_temp2.';
  }

  @override
  String get sharedSiteQrCode => 'Kode QR lokasi';

  @override
  String get sharedEventQrCode => 'Kode QR kegiatan';

  @override
  String get sharedSpecimenImported => 'Spesimen berhasil diimpor.';

  @override
  String get sharedSiteImported => 'Lokasi berhasil diimpor.';

  @override
  String get sharedEventImported => 'Kegiatan berhasil diimpor.';

  @override
  String get sharedQrNoData => 'Kode QR tidak berisi data.';

  @override
  String get sharedRecordQrTooLargeBody =>
      'Catatan ini berisi terlalu banyak data untuk kode QR. Ekspor sebagai JSON untuk memindahkan catatan lengkap.';

  @override
  String get sharedRecordQrDescription =>
      'Pindai kode ini dari perangkat NAHPU lain untuk mengimpor catatan.';

  @override
  String sharedRecordExchangeFailed(String error) {
    return 'Impor/ekspor catatan gagal: $error';
  }

  @override
  String get sharedFileName => 'Nama berkas';

  @override
  String sharedSomethingWentWrong(String error) {
    return 'Terjadi kesalahan: $error';
  }

  @override
  String get sharedSelectFile => 'Pilih berkas';

  @override
  String get sharedSupportedFormats => 'Format yang didukung';

  @override
  String sharedSupportedFormatsList(String label, String formats) {
    return '$label:\n$formats';
  }

  @override
  String get sharedAppendDate => 'Tambahkan tanggal saat ini';

  @override
  String get sharedAppendDateDescription =>
      'Menambahkan -yyyy-mm-dd ke nama berkas';

  @override
  String get sharedSaveTo => 'Simpan ke';

  @override
  String get sharedSelectDirectory => 'Pilih direktori';

  @override
  String get sharedClearDirectory => 'Hapus pilihan direktori';

  @override
  String get sharedNoFolderChosen =>
      'Belum ada folder yang dipilih. Ekspor masuk ke penyimpanan aplikasi NAHPU — telusuri folder untuk menyimpannya di tempat pilihan Anda.';

  @override
  String get sharedShareAfterExport => 'Bagikan setelah ekspor';

  @override
  String get sharedTemporaryExportNote =>
      'NAHPU menyimpan berkas hanya sampai ekspor berikutnya. Bagikan untuk menyimpan salinan di Files, mengirimnya ke aplikasi lain, atau menaruhnya di folder cloud.';

  @override
  String get sharedEntireDatabaseContents => 'Seluruh isi basis data';

  @override
  String get sharedBackupSizeBeforeCompression =>
      'Ukuran cadangan sebelum kompresi';

  @override
  String sharedWizardStepChip(int number, String label) {
    return '$number. $label';
  }

  @override
  String get sharedNavDashboard => 'Dasbor';

  @override
  String get sharedNavSites => 'Lokasi';

  @override
  String get sharedNavEvents => 'Kegiatan';

  @override
  String get sharedNavSpecimens => 'Spesimen';

  @override
  String get sharedNavNarrative => 'Narasi';

  @override
  String get sharedNavCollapse => 'Ciutkan';

  @override
  String get sharedNavExpand => 'Bentangkan';

  @override
  String get sharedNavCollapseNavigation => 'Ciutkan navigasi';

  @override
  String get sharedNavExpandNavigation => 'Bentangkan navigasi';

  @override
  String get sharedNavCollapseRail => 'Ciutkan panel navigasi';

  @override
  String get sharedNavExpandRail => 'Bentangkan panel navigasi';

  @override
  String get sharedNavMenu => 'Menu';

  @override
  String get sharedNavCloseMenu => 'Tutup menu';

  @override
  String get sharedNavCloseProjectMenu => 'Tutup menu proyek';

  @override
  String get sharedNavOpenProjectMenu => 'Buka menu proyek';

  @override
  String get sharedNavCloseProject => 'Tutup proyek';

  @override
  String get sharedGoToPage => 'Ke halaman';

  @override
  String get sharedGoToPageOrSearch => 'Ke halaman atau cari';

  @override
  String sharedPageOf(int current, int total) {
    return 'Halaman $current dari $total';
  }

  @override
  String get sharedSearch => 'Cari';

  @override
  String get sharedPageNumber => 'Nomor halaman';

  @override
  String get sharedGo => 'Buka';

  @override
  String get sharedOr => 'atau';

  @override
  String get sharedSearchRecords => 'Cari catatan';

  @override
  String sharedPageOutOfRange(int total) {
    return 'Masukkan halaman 1 sampai $total';
  }

  @override
  String get textReplaceErrorEmptyPattern =>
      'Teks yang dicari tidak boleh kosong.';

  @override
  String textReplaceErrorInvalidRegex(String detail) {
    return 'Ekspresi reguler tidak valid: $detail';
  }

  @override
  String get textReplaceAdd => 'Tambah penggantian';

  @override
  String get textReplaceTitle => 'Ganti teks';

  @override
  String get textReplaceSubtitle =>
      'Diterapkan berurutan setelah pemformatan nilai.';

  @override
  String get textReplaceDialogTitle => 'Cari dan ganti';

  @override
  String get textReplaceMatch => 'Pencocokan';

  @override
  String get textReplaceMatchExact => 'Persis';

  @override
  String get textReplaceMatchRegex => 'Regex';

  @override
  String get textReplaceFind => 'Cari';

  @override
  String get textReplaceWith => 'Ganti dengan';

  @override
  String get textReplaceIgnoreCase => 'Abaikan huruf besar/kecil';

  @override
  String get textReplaceMoveUp => 'Pindahkan penggantian ke atas';

  @override
  String get textReplaceMoveDown => 'Pindahkan penggantian ke bawah';

  @override
  String get textReplaceRemove => 'Hapus penggantian';

  @override
  String get textReplaceRegexHelp =>
      'Gunakan \$0 untuk seluruh kecocokan, \$1…\$n untuk grup, dan \$\$ untuk \$.';

  @override
  String get documentFontSampleA =>
      'Durian adalah raja buah, dan manggis adalah ratunya. Ternyata, memakan keduanya sekaligus bukanlah ide yang baik. Seharusnya saya tidak makan 12 durian dan selusin manggis dalam sekali duduk di lapangan.';

  @override
  String get documentFontSampleB =>
      'Hanya ada satu tempat di Sumatra bagian utara tempat orang utan, badak, gajah, dan harimau berbagi habitat alami yang sama. Tebak nama taman nasionalnya?';

  @override
  String get documentFontSampleC =>
      'Sedang kreatif atau terinspirasi? Kirimkan kepada pengelola gagasan Anda, fakta keanekaragaman hayati yang menarik, lelucon lapangan, atau cerita pendek yang layak dibaca, atau unggah di github.com/nahpu/nahpu/issues, dan mungkin akan muncul di sini. Pilihan fon tidak semestinya ditentukan oleh rubah cokelat yang melompati anjing malas.';

  @override
  String get documentFontBold => 'Tebal';

  @override
  String get documentFontItalic => 'Miring';

  @override
  String get fieldEditorLabel => 'Label';

  @override
  String get fieldEditorType => 'Jenis';

  @override
  String get fieldEditorCatalogApplicability => 'Penerapan katalog';

  @override
  String fieldEditorCurrentCatalogOnly(String catalog) {
    return 'Hanya katalog saat ini ($catalog)';
  }

  @override
  String get fieldEditorOptions => 'Opsi';

  @override
  String get fieldEditorOptionsHelper => 'Masukkan satu opsi per baris.';

  @override
  String get fieldEditorMapToDwc => 'Petakan ke Darwin Core';

  @override
  String fieldEditorDwcOfficialTerms(String version) {
    return 'Istilah resmi $version';
  }

  @override
  String get fieldEditorDwcTarget => 'Target DWC';

  @override
  String get fieldEditorDwcMappingMode => 'Mode pemetaan';

  @override
  String get fieldEditorDwcDirect => 'Bidang langsung';

  @override
  String get fieldEditorDwcAssertion => 'Pengukuran / fakta berulang';

  @override
  String get fieldEditorDwcField => 'Bidang DWC';

  @override
  String get fieldEditorDwcAllowConflict => 'Saya memahami nilai duplikat';

  @override
  String get fieldEditorDwcAllowConflictNote =>
      'Nilai skalar yang bertentangan akan digabungkan dengan “ | ”.';

  @override
  String get fieldEditorEditTitle => 'Sunting bidang khusus';

  @override
  String fieldEditorAddTitle(String section) {
    return 'Tambah bidang khusus ke $section';
  }

  @override
  String get documentFileSettings => 'Pengaturan Berkas';

  @override
  String get documentFileFormat => 'Format berkas';

  @override
  String get documentFileBundleFormat => 'Format paket';

  @override
  String get documentFileDwcDpZipNote =>
      'ZIP disediakan untuk kompatibilitas. TAR.GZ adalah opsi DwC-DP yang sesuai standar.';

  @override
  String get documentFileFormatCsv => 'Dipisahkan koma (.csv)';

  @override
  String get documentFileFormatTsv => 'Dipisahkan tab (.tsv)';

  @override
  String get documentFileFormatExcel => 'Excel (.xlsx)';

  @override
  String get documentFileFormatJson => 'JSON (.json)';

  @override
  String documentPreviewPdfError(String error) {
    return 'Galat saat membuat PDF:\n$error';
  }

  @override
  String get documentPreviewUnavailable => 'Pratinjau tidak tersedia.';

  @override
  String get documentPreviewNotGenerated => 'Pratinjau belum dibuat.';

  @override
  String get documentPreviewNoLayout => 'Tidak ada tata letak yang dimuat.';

  @override
  String get documentPreviewUpdate => 'Perbarui pratinjau';

  @override
  String get documentPreviewGenerate => 'Buat pratinjau';

  @override
  String get documentPreviewOptionsChanged => 'Opsi pratinjau berubah';

  @override
  String documentPreviewPageOf(int current, int total) {
    return 'Halaman $current dari $total';
  }

  @override
  String get documentColumnsDefaults => 'Bawaan';

  @override
  String documentColumnsSelectedCount(int selected, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$selected dari $total kolom dipilih',
    );
    return '$_temp0';
  }

  @override
  String get documentPartFilterTitle => 'Saring bagian spesimen';

  @override
  String get documentPartFilterNote =>
      'Filter hanya mengubah daftar. Bagian yang dipilih tetap disertakan dalam ekspor sampai Anda mengubah pilihan.';

  @override
  String get documentPartFilterTypes => 'Jenis bagian';

  @override
  String get documentPartFilterTypesHint =>
      'Biarkan semua tidak dicentang untuk menyertakan semua jenis.';

  @override
  String get documentPartFilterNumberRange => 'Rentang nomor';

  @override
  String get documentPartFilterFieldNumber => 'Nomor lapangan';

  @override
  String get documentPartFilterProjectNumber => 'Nomor proyek';

  @override
  String get documentPartFilterFrom => 'Dari';

  @override
  String get documentPartFilterTo => 'Sampai';

  @override
  String get documentPartFilterRangeHint =>
      'Termasuk kedua batas. Kosongkan salah satu batas agar tidak ada batasan.';

  @override
  String get documentPartFilterReset => 'Atur ulang filter';

  @override
  String get documentPartFilterInvalidNumber =>
      'Masukkan bilangan bulat non-negatif.';

  @override
  String get documentPartFilterFromAfterTo =>
      '“Dari” harus lebih kecil dari atau sama dengan “Sampai”.';

  @override
  String documentPartsLoadError(String error) {
    return 'Tidak dapat memuat bagian: $error';
  }

  @override
  String get documentPartsSearch => 'Cari bagian atau nomor spesimen';

  @override
  String get documentPartFilterActive => 'Saring bagian spesimen (aktif)';

  @override
  String documentPartsSummary(int shown, int total, int selected) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total bagian',
    );
    return 'Menampilkan $shown dari $_temp0 · Dipilih $selected';
  }

  @override
  String documentPartsSummaryHidden(
    int shown,
    int total,
    int selected,
    int hidden,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total bagian',
    );
    return 'Menampilkan $shown dari $_temp0 · Dipilih $selected ($hidden tersembunyi)';
  }

  @override
  String get documentPartsEmpty => 'Tidak ada bagian spesimen yang ditemukan';

  @override
  String documentPartFallbackTitle(String id) {
    return 'Bagian $id';
  }

  @override
  String documentParasitesLoadError(String error) {
    return 'Tidak dapat memuat parasit: $error';
  }

  @override
  String get documentParasitesSearch => 'Cari parasit atau nomor spesimen';

  @override
  String documentParasitesSummary(int shown, int total, int selected) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total parasit',
    );
    return 'Menampilkan $shown dari $_temp0 · Dipilih $selected';
  }

  @override
  String documentParasitesSummaryHidden(
    int shown,
    int total,
    int selected,
    int hidden,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total parasit',
    );
    return 'Menampilkan $shown dari $_temp0 · Dipilih $selected ($hidden tersembunyi)';
  }

  @override
  String get documentParasitesEmpty => 'Tidak ada parasit';

  @override
  String documentParasiteFallbackTitle(String id) {
    return 'Parasit $id';
  }

  @override
  String documentPartFieldNumber(String number) {
    return 'No. lapangan $number';
  }

  @override
  String documentPartProjectNumber(String number) {
    return 'No. proyek $number';
  }

  @override
  String documentPartCatalog(String number) {
    return 'Katalog $number';
  }

  @override
  String documentPartSpecimenFallback(String uuid) {
    return 'Spesimen $uuid';
  }

  @override
  String get documentSelectionClearAll => 'Hapus semua';

  @override
  String get documentSpecimenSearch =>
      'Cari no. lapangan, kolektor, spesies...';

  @override
  String documentSpecimenCollectedRange(String start, String end) {
    return 'Koleksi: $start - $end';
  }

  @override
  String get documentSpecimenCollectionDate => 'Tanggal Koleksi';

  @override
  String documentSpecimenPreparedRange(String start, String end) {
    return 'Prep.: $start - $end';
  }

  @override
  String get documentSpecimenPrepDate => 'Tanggal Preparasi';

  @override
  String documentSelectionSelectedOf(int selected, int total) {
    return 'Dipilih $selected dari $total';
  }

  @override
  String get documentSpecimenSelectTitle => 'Pilih spesimen';

  @override
  String get documentSelectSitePreview => 'Pilih Lokasi untuk Pratinjau';

  @override
  String get documentSelectSitesPreview => 'Pilih Lokasi untuk Pratinjau';

  @override
  String get documentSelectSites => 'Pilih lokasi';

  @override
  String get documentSelectEventPreview => 'Pilih Kegiatan untuk Pratinjau';

  @override
  String get documentSelectEventsPreview => 'Pilih Kegiatan untuk Pratinjau';

  @override
  String get documentSelectEvents => 'Pilih kegiatan';

  @override
  String get documentSelectNarrativePreview => 'Pilih Narasi untuk Pratinjau';

  @override
  String get documentSelectNarrativesPreview => 'Pilih Narasi untuk Pratinjau';

  @override
  String get documentSelectNarratives => 'Pilih narasi';

  @override
  String get documentSiteSearch => 'Cari ID lokasi, lokalitas...';

  @override
  String get documentSelectionClearSearch => 'Hapus pencarian';

  @override
  String get documentSitesEmpty => 'Tidak ada lokasi yang ditemukan';

  @override
  String get documentSiteUnnamed => 'Lokasi Tanpa Nama';

  @override
  String get documentSiteNoLocality => 'Tidak ada detail lokalitas';

  @override
  String documentSelectionLoadError(String error) {
    return 'Galat: $error';
  }

  @override
  String get documentEventSearch => 'Cari ID kegiatan, metode...';

  @override
  String get documentEventsEmpty => 'Tidak ada kegiatan yang ditemukan';

  @override
  String documentEventFallbackTitle(String id) {
    return 'ID kegiatan: $id';
  }

  @override
  String get documentEventNoMethod => 'Tanpa metode';

  @override
  String get documentSelectionNoDate => 'Tanpa tanggal';

  @override
  String get documentNarrativeSearch => 'Cari tanggal, isi...';

  @override
  String get documentNarrativesEmpty => 'Tidak ada narasi yang ditemukan';

  @override
  String get documentNarrativeNoText => 'Tanpa teks';

  @override
  String get documentRecordsSpecimens => 'Spesimen';

  @override
  String get documentRecordsSites => 'Lokasi';

  @override
  String get documentRecordsEvents => 'Kegiatan Koleksi';

  @override
  String get documentRecordsNarratives => 'Narasi';

  @override
  String get documentRecordsGeneric => 'Catatan';

  @override
  String documentSelectedCount(int selected, int total) {
    return '$selected dari $total dipilih';
  }

  @override
  String get documentPageSizeLetter => 'US Letter (8,5 x 11 in)';

  @override
  String get documentPageSizeLegal => 'US Legal';

  @override
  String get documentPageSizeCustom => 'Kustom';

  @override
  String get documentOrientationPortrait => 'Potret';

  @override
  String get documentOrientationLandscape => 'Lanskap';

  @override
  String get documentOverrideBlocks => 'Timpa blok templat';

  @override
  String get documentTemplateBlocks => 'Blok templat';

  @override
  String get documentAddBlock => 'Tambah Blok';

  @override
  String get documentMultiBlockMode => 'Mode beberapa blok';

  @override
  String get documentMultiBlockContinuous => 'Berurutan (Blok demi blok)';

  @override
  String get documentMultiBlockAlternate => 'Bergantian (Catatan demi catatan)';

  @override
  String documentBlockNumber(int number) {
    return 'Blok #$number';
  }

  @override
  String get documentShowLess => 'Tampilkan lebih sedikit';

  @override
  String get documentShowMore => 'Tampilkan lebih banyak';

  @override
  String get documentDeleteBlock => 'Hapus Blok';

  @override
  String get documentBlockTemplate => 'Templat';

  @override
  String get documentTemplateMissing => 'Templat ini sudah tidak ada';

  @override
  String documentMissingItem(String name) {
    return 'Hilang: $name';
  }

  @override
  String get documentEditTemplate => 'Sunting templat';

  @override
  String get documentBlockCopies => 'Salinan';

  @override
  String get documentBlockRows => 'Baris';

  @override
  String get documentBlockCols => 'Kol.';

  @override
  String get documentAutoFillPage => 'Isi halaman otomatis';

  @override
  String get documentTemplatePadding => 'Bantalan templat (mm)';

  @override
  String get documentPaddingTop => 'Atas';

  @override
  String get documentPaddingLeft => 'Kiri';

  @override
  String get documentPaddingRight => 'Kanan';

  @override
  String get documentPaddingBottom => 'Bawah';

  @override
  String get documentPageBreakAfter => 'Pemisah halaman setelahnya';

  @override
  String get documentPageBreakAfterHint =>
      'Sisipkan pemisah halaman setelah blok ini';

  @override
  String get documentCurrentProjectSelection => 'Pilihan Proyek Saat Ini';

  @override
  String get documentActiveProjectDocument => '1 dokumen (proyek aktif)';

  @override
  String get documentSelectionSpecimens => 'Pilihan Spesimen';

  @override
  String get documentSelectionSpecimenParts => 'Pilihan Bagian Spesimen';

  @override
  String get documentSelectionParasites => 'Pilihan Parasit';

  @override
  String get documentSelectionSites => 'Pilihan Lokasi';

  @override
  String get documentSelectionEvents => 'Pilihan Kegiatan Koleksi';

  @override
  String get documentSelectionNarratives => 'Pilihan Narasi';

  @override
  String get documentSortDirection => 'Arah';

  @override
  String get documentSortAscending => 'Naik';

  @override
  String get documentSortDescending => 'Turun';

  @override
  String get documentSortFieldsLoadError =>
      'Tidak dapat memuat bidang pengurutan';

  @override
  String get documentSortOriginalOrder => 'Urutan asli';

  @override
  String get documentSortOrderBy => 'Urutkan berdasarkan';

  @override
  String get documentSortOrderRecordsBy => 'Urutkan catatan berdasarkan';

  @override
  String get documentSortClosePicker => 'Tutup pemilih bidang urutan';

  @override
  String documentSortFieldUnavailable(String table) {
    return '$table · Tidak tersedia untuk templat ini';
  }

  @override
  String documentFieldCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bidang',
    );
    return '$_temp0';
  }

  @override
  String get documentLayoutTitle => 'Tata Letak Dokumen';

  @override
  String get documentLayoutProfile => 'Profil tata letak';

  @override
  String get documentLayoutProfileHelper =>
      'Pengaturan halaman dan blok templat ditentukan oleh profil.';

  @override
  String get documentManagePresets => 'Kelola prasetel';

  @override
  String get documentPageSetup => 'Pengaturan Halaman';

  @override
  String get documentPageSize => 'Ukuran halaman';

  @override
  String get documentPageWidthMm => 'Lebar mm';

  @override
  String get documentPageHeightMm => 'Tinggi mm';

  @override
  String get documentOrientation => 'Orientasi';

  @override
  String get documentPagePadding => 'Bantalan halaman (mm)';

  @override
  String get documentSelectSpecimenParts => 'Pilih bagian spesimen';

  @override
  String get documentSelectParasites => 'Pilih parasit';

  @override
  String get labelCatalogFormatOrnithology => 'Ornitologi';

  @override
  String get labelCatalogFormatMammalogy => 'Mamalogi';

  @override
  String get labelCatalogFormatHerpetology => 'Herpetologi';

  @override
  String get labelCatalogFormatInvertebrateZoology => 'Zoologi invertebrata';

  @override
  String get labelCatalogFormatIchthyology => 'Iktiologi';

  @override
  String get labelSpecimenRecordTypeAllTaxa => 'Semua takson';

  @override
  String get labelSpecimenRecordTypeBirds => 'Burung';

  @override
  String get labelSpecimenRecordTypeMammals => 'Mamalia';

  @override
  String get labelSpecimenRecordTypeHerpetofauna => 'Herpetofauna';

  @override
  String get labelSpecimenRecordTypeInvertebrates => 'Invertebrata';

  @override
  String get labelSpecimenRecordTypeFishes => 'Ikan';

  @override
  String get labelProjectToolCategoryUtilities => 'Utilitas';

  @override
  String get labelProjectToolCategoryProject => 'Proyek';

  @override
  String get labelProjectToolCategoryRecords => 'Catatan';

  @override
  String get labelProjectToolCategoryDatabase => 'Basis data';

  @override
  String get labelProjectToolCategoryConfiguration => 'Konfigurasi';

  @override
  String get labelProjectToolDataTable => 'Tabel data';

  @override
  String get labelProjectToolDataTableDescription =>
      'Telusuri, urutkan, dan cari catatan proyek';

  @override
  String get labelProjectToolTemplates => 'Templat';

  @override
  String get labelProjectToolTemplatesDescription =>
      'Buat dan edit templat dokumen';

  @override
  String get labelProjectToolMergeProject => 'Gabungkan proyek';

  @override
  String get labelProjectToolMergeProjectDescription =>
      'Gabungkan proyek lain ke proyek ini';

  @override
  String get labelProjectToolExportProject => 'Ekspor proyek';

  @override
  String get labelProjectToolExportProjectDescription =>
      'Ekspor proyek ini untuk dipindahkan';

  @override
  String get labelProjectToolBatchImport => 'Impor massal';

  @override
  String get labelProjectToolBatchImportDescription =>
      'Impor atau perbarui catatan dari lembar kerja';

  @override
  String get labelProjectToolCuration => 'Kurasi';

  @override
  String get labelProjectToolCurationDescription =>
      'Kurasi spesimen: pindai jaringan ke dalam kotak penyimpanan';

  @override
  String get labelProjectToolBundleRecords => 'Bundel catatan';

  @override
  String get labelProjectToolBundleRecordsDescription =>
      'Bundel catatan beserta medianya';

  @override
  String get labelProjectToolExportRecords => 'Ekspor catatan';

  @override
  String get labelProjectToolExportRecordsDescription =>
      'Ekspor catatan sebagai data tabular';

  @override
  String get labelProjectToolExportDocuments => 'Ekspor dokumen';

  @override
  String get labelProjectToolExportDocumentsDescription =>
      'Ekspor catatan sebagai dokumen';

  @override
  String get labelProjectToolBackupDatabaseDescription =>
      'Cadangkan basis data aplikasi';

  @override
  String get labelProjectToolSettingsDescription => 'Buka pengaturan aplikasi';

  @override
  String get labelProjectToolExportConfigs => 'Ekspor konfigurasi';

  @override
  String get labelProjectToolImportConfigs => 'Impor konfigurasi';

  @override
  String get labelBasemapNone => 'Tidak ada';

  @override
  String get labelBasemapNoneDescription => 'Tanpa lapisan dasar geografis';

  @override
  String get labelBasemapAutomatic => 'Otomatis';

  @override
  String get labelBasemapAutomaticDescription =>
      'Positron dalam mode terang dan Gelap dalam mode gelap';

  @override
  String get labelBasemapNaturalEarthOffline => 'Natural Earth (luring)';

  @override
  String get labelBasemapNaturalEarthOfflineDescription =>
      'Batas negara bawaan yang berfungsi tanpa akses internet';

  @override
  String get labelBasemapPositronDescription =>
      'Peta terang minimalis dengan kontras rendah';

  @override
  String get labelBasemapBrightDescription =>
      'Peta terperinci dengan warna cerah';

  @override
  String get labelBasemapLibertyDescription =>
      'Peta terperinci dengan warna seimbang';

  @override
  String get labelBasemapDark => 'Gelap';

  @override
  String get labelBasemapDarkDescription =>
      'Peta gelap untuk kondisi minim cahaya';

  @override
  String get labelMapLayerKindRasterTiles => 'Ubin raster';

  @override
  String get labelMapLayerKindVectorTiles => 'Ubin vektor';

  @override
  String get labelMapLayerKindElevationModel => 'Model elevasi';

  @override
  String get labelFieldSectionSpecimenAttributes => 'Atribut spesimen';

  @override
  String get labelFieldSectionSiteAttributes => 'Atribut lokasi';

  @override
  String get labelFieldSectionEnvironmentalData => 'Data lingkungan';

  @override
  String get labelFieldSectionSpecimenPart => 'Bagian spesimen';

  @override
  String get labelFieldSectionParasite => 'Parasit';

  @override
  String get labelSiteGeographyCountry => 'Negara';

  @override
  String get labelSiteGeographyIslandGroup => 'Gugus pulau';

  @override
  String get labelSiteGeographyStateProvince => 'Provinsi/Negara bagian';

  @override
  String get labelSiteGeographyCounty => 'Kabupaten/Distrik';

  @override
  String get labelSiteGeographyMunicipality => 'Kotamadya/Kota/Desa';

  @override
  String get labelEnvironmentalLowestDayTemp => 'Suhu terendah siang hari';

  @override
  String get labelEnvironmentalHighestDayTemp => 'Suhu tertinggi siang hari';

  @override
  String get labelEnvironmentalLowestNightTemp => 'Suhu terendah malam hari';

  @override
  String get labelEnvironmentalHighestNightTemp => 'Suhu tertinggi malam hari';

  @override
  String get labelEnvironmentalAverageHumidity => 'Kelembapan rata-rata';

  @override
  String get labelEnvironmentalDewPoint => 'Titik embun';

  @override
  String get labelEnvironmentalCloudCover => 'Tutupan awan';

  @override
  String get labelEnvironmentalRainfall => 'Curah hujan';

  @override
  String get labelEnvironmentalAmbientTemperature => 'Suhu lingkungan';

  @override
  String get labelEnvironmentalAmbientHumidity => 'Kelembapan lingkungan';

  @override
  String get labelEnvironmentalWaterTemperature => 'Suhu air';

  @override
  String get labelEnvironmentalDissolvedOxygen => 'Oksigen terlarut';

  @override
  String get labelEnvironmentalDissolvedOxygenSaturation =>
      'Saturasi oksigen terlarut';

  @override
  String get labelEnvironmentalConductivity => 'Konduktivitas';

  @override
  String get labelEnvironmentalFlowVelocity => 'Kecepatan arus';

  @override
  String get labelEnvironmentalSunrise => 'Matahari terbit';

  @override
  String get labelEnvironmentalSunset => 'Matahari terbenam';

  @override
  String get labelEnvironmentalMoonPhase => 'Fase bulan';

  @override
  String get labelEnvironmentalNotes => 'Catatan';

  @override
  String labelEnvironmentalWithUnit(String label, String unit) {
    return '$label ($unit)';
  }

  @override
  String get labelTableProject => 'Proyek';

  @override
  String get labelTableGeography => 'Geografi';

  @override
  String get labelTableSite => 'Lokasi';

  @override
  String get labelTableSiteAttribute => 'Atribut lokasi';

  @override
  String get labelTableFossilSite => 'Lokasi fosil';

  @override
  String get labelTableCoordinate => 'Koordinat';

  @override
  String get labelTableCollEvent => 'Kegiatan koleksi';

  @override
  String get labelTableEnvironment => 'Lingkungan';

  @override
  String get labelTableCollPersonnel => 'Personel koleksi';

  @override
  String get labelTableCollMethod => 'Metode koleksi';

  @override
  String get labelTableNarrative => 'Narasi';

  @override
  String get labelTableMedia => 'Media';

  @override
  String get labelTableNarrativeMedia => 'Media narasi';

  @override
  String get labelTableSiteMedia => 'Media lokasi';

  @override
  String get labelTableEventMedia => 'Media kegiatan';

  @override
  String get labelTableSpecimenMedia => 'Media spesimen';

  @override
  String get labelTableAssociatedData => 'Data terkait';

  @override
  String get labelTableSpecimenAssociatedData => 'Data terkait spesimen';

  @override
  String get labelTableSiteAssociatedData => 'Data terkait lokasi';

  @override
  String get labelTableEventAssociatedData => 'Data terkait kegiatan';

  @override
  String get labelTablePersonnelList => 'Daftar personel';

  @override
  String get labelTablePersonnel => 'Personel';

  @override
  String get labelTableTaxonomy => 'Taksonomi';

  @override
  String get labelTableSpecimen => 'Spesimen';

  @override
  String get labelTableMammalAttribute => 'Atribut mamalia';

  @override
  String get labelTableBirdAttribute => 'Atribut burung';

  @override
  String get labelTableHerpAttribute => 'Atribut herpetofauna';

  @override
  String get labelTableInvertebrateAttribute => 'Atribut invertebrata';

  @override
  String get labelTableFishAttribute => 'Atribut ikan';

  @override
  String get labelTableFossilAttribute => 'Atribut fosil';

  @override
  String get labelTableParasiteDetection => 'Deteksi parasit';

  @override
  String get labelTableParasite => 'Parasit';

  @override
  String get labelTableSpecimenPart => 'Bagian spesimen';

  @override
  String get labelTableSpecimenIndividual => 'Individu spesimen';

  @override
  String get labelTableSpecimenPartIndividual => 'Individu bagian spesimen';

  @override
  String get labelTableParasiteIndividual => 'Individu parasit';

  @override
  String get labelTableCustomFieldDefinition => 'Definisi kolom khusus';

  @override
  String get labelTableCustomFieldValue => 'Nilai kolom khusus';

  @override
  String fileExplorerFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count berkas',
    );
    return '$_temp0';
  }

  @override
  String fileExplorerImageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gambar',
    );
    return '$_temp0';
  }

  @override
  String fileExplorerAudioCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count berkas audio',
    );
    return '$_temp0';
  }

  @override
  String fileExplorerVideoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count video',
    );
    return '$_temp0';
  }

  @override
  String fileExplorerOtherCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count berkas lain',
    );
    return '$_temp0';
  }

  @override
  String get fileExplorerLockDatabase => 'Basis data aplikasi';

  @override
  String get fileExplorerLockDatabaseSidecar => 'Berkas kerja basis data';

  @override
  String get fileExplorerLockBackup => 'Cadangan basis data';

  @override
  String get fileExplorerLockUserConfig => 'Fon dan lapisan peta khusus';

  @override
  String get fileExplorerLockTemplateMedia => 'Media templat global';

  @override
  String get fileExplorerLockMediaRecord => 'Tertaut ke catatan media';

  @override
  String get fileExplorerLockPersonnelPhoto => 'Tertaut ke foto personel';

  @override
  String get fileExplorerLockAssociatedData => 'Tertaut ke data terkait';

  @override
  String get fileExplorerLockUnresolvedReference =>
      'Sebuah catatan merujuk ke sini tetapi tidak dapat dibaca';

  @override
  String get fileExplorerLockRecentlyModified =>
      'Baru saja diubah, mungkin masih disalin';

  @override
  String get fileExplorerLockUnmanagedLocation =>
      'Tidak berada di folder yang dikelola NAHPU';

  @override
  String get fileExplorerLockUnknownProject =>
      'Folder proyek yang tidak ada di basis data';

  @override
  String fileExplorerPruneBlockedUnresolved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count catatan data terkait tidak dapat dibaca, sehingga beberapa berkas tidak dapat diperiksa. Penghapusan berkas dinonaktifkan sampai masalah ini teratasi.',
    );
    return '$_temp0';
  }

  @override
  String get fileExplorerPruneBlockedEmptyIndex =>
      'Basis data tidak melaporkan berkas tertaut sama sekali, yang biasanya berarti basis data masih dibuka. Buka kembali layar ini sebelum menghapus apa pun.';

  @override
  String get progressPrepareBackup => 'Siapkan cadangan';

  @override
  String get progressCopyMediaAndFiles => 'Salin media dan berkas';

  @override
  String get progressCompressArchive => 'Kompres arsip';

  @override
  String get progressExtractArchive => 'Ekstrak arsip';

  @override
  String get progressRestoreMediaAndFiles => 'Pulihkan media dan berkas';

  @override
  String get progressBackUpCurrentData => 'Cadangkan data saat ini';

  @override
  String get progressReplaceDatabase => 'Ganti basis data';

  @override
  String get progressWriteRecords => 'Tulis catatan';

  @override
  String get progressCopyMedia => 'Salin media';

  @override
  String get progressCheckContents => 'Periksa isi';

  @override
  String get progressCollectRecords => 'Kumpulkan catatan';

  @override
  String get progressCheckRecords => 'Periksa catatan';

  @override
  String get progressWriteAndCompressPackage => 'Tulis dan kompres paket';

  @override
  String get progressProcessMedia => 'Proses media';

  @override
  String serviceMessagePresetsAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count prasetel ditambahkan',
    );
    return '$_temp0';
  }

  @override
  String get serviceMessageNoDefaultPresets =>
      'Tidak ada prasetel bawaan untuk jenis ini';

  @override
  String get serviceMessageDefaultPresetsLoaded =>
      'Prasetel bawaan sudah dimuat';

  @override
  String serviceMessagePresetsAndTemplatesImported(
    int count,
    int templateCount,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count prasetel',
    );
    String _temp1 = intl.Intl.pluralLogic(
      templateCount,
      locale: localeName,
      other: '$templateCount templat',
    );
    return '$_temp0 dan $_temp1 diimpor';
  }

  @override
  String serviceMessagePresetImageNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count templat menggunakan gambar, yang dirujuk berdasarkan nama dan tidak disimpan di dalam berkas. Pada instalasi lain, gambar tersebut harus ditambahkan lagi.',
    );
    return '$_temp0';
  }

  @override
  String deletePersonnelCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hapus $count personel',
    );
    return '$_temp0';
  }

  @override
  String deletePersonnelTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hapus personel',
    );
    return '$_temp0';
  }

  @override
  String deletePersonnelBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Yakin ingin menghapus personel yang dipilih?',
    );
    return '$_temp0';
  }

  @override
  String deleteTaxaCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hapus $count takson',
    );
    return '$_temp0';
  }

  @override
  String deleteTaxaTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hapus takson',
    );
    return '$_temp0';
  }

  @override
  String deleteTaxaBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Yakin ingin menghapus takson yang dipilih?',
    );
    return '$_temp0';
  }

  @override
  String deleteCoordinatesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hapus $count koordinat',
    );
    return '$_temp0';
  }

  @override
  String deleteCoordinatesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hapus koordinat',
    );
    return '$_temp0';
  }

  @override
  String deleteCoordinatesBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Yakin ingin menghapus koordinat yang dipilih?',
    );
    return '$_temp0';
  }

  @override
  String deleteCollMethodsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hapus $count metode koleksi',
    );
    return '$_temp0';
  }

  @override
  String deleteCollMethodsTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hapus metode koleksi',
    );
    return '$_temp0';
  }

  @override
  String deleteCollMethodsBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Yakin ingin menghapus metode koleksi yang dipilih?',
    );
    return '$_temp0';
  }

  @override
  String deleteParasitesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hapus $count parasit',
    );
    return '$_temp0';
  }

  @override
  String deleteParasitesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hapus parasit',
    );
    return '$_temp0';
  }

  @override
  String deleteParasitesBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Yakin ingin menghapus parasit yang dipilih?',
    );
    return '$_temp0';
  }

  @override
  String deleteSpecimenPartsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hapus $count bagian spesimen',
    );
    return '$_temp0';
  }

  @override
  String deleteSpecimenPartsTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hapus bagian spesimen',
    );
    return '$_temp0';
  }

  @override
  String deleteSpecimenPartsBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Yakin ingin menghapus bagian spesimen yang dipilih?',
    );
    return '$_temp0';
  }

  @override
  String deleteAssociatedDataCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hapus $count entri data terkait',
    );
    return '$_temp0';
  }

  @override
  String get deleteAssociatedDataTitle => 'Hapus data terkait';

  @override
  String get deleteAssociatedDataBody =>
      'Hapus data terkait yang dipilih dari catatan ini? Data yang dibagikan dengan catatan lain akan tetap disimpan.';

  @override
  String removeProjectPersonnelCount(int count) {
    return 'Hapus $count personel dari proyek';
  }

  @override
  String get removeProjectPersonnelTitle => 'Hapus personel';

  @override
  String get removeProjectPersonnelBody =>
      'Yakin ingin menghapus personel yang dipilih dari proyek?';

  @override
  String removeEventPersonnelCount(int count) {
    return 'Hapus $count personel dari peristiwa';
  }

  @override
  String get removeEventPersonnelTitle => 'Hapus personel peristiwa';

  @override
  String get removeEventPersonnelBody =>
      'Yakin ingin menghapus personel yang dipilih dari peristiwa ini?';

  @override
  String get projectDeleteProject => 'Hapus proyek';

  @override
  String get projectDeleteProjectTitle => 'Hapus proyek?';

  @override
  String get projectDeleteProjectPrompt =>
      'Anda akan menghapus proyek ini beserta datanya. Tindakan ini tidak dapat dibatalkan.';

  @override
  String get projectNoProject => 'Tidak ada proyek';

  @override
  String get projectOverview => 'Ringkasan proyek';

  @override
  String projectOverviewLoadError(Object error) {
    return 'Gagal mengambil data dari basis data. Periksa apakah nama proyek ada. $error';
  }

  @override
  String projectSaveFailed(String error) {
    return 'Tidak dapat menyimpan proyek: $error';
  }

  @override
  String get projectDetails => 'Detail proyek';

  @override
  String get projectNameLabel => 'Nama proyek*';

  @override
  String get projectNameHint => 'Masukkan nama proyek (wajib)';

  @override
  String get projectDescriptionLabel => 'Deskripsi proyek';

  @override
  String get projectDescriptionHint => 'Masukkan deskripsi singkat proyek';

  @override
  String get projectPrincipalInvestigator => 'Peneliti utama';

  @override
  String get projectPrincipalInvestigatorHint => 'Masukkan peneliti utama';

  @override
  String get projectAccession => 'Aksesi';

  @override
  String get projectAccessionHint => 'Masukkan aksesi institusi';

  @override
  String get projectPlaceAndTime => 'Tempat dan waktu';

  @override
  String get projectLocation => 'Lokasi';

  @override
  String get projectLocationHint => 'Masukkan lokasi umum proyek';

  @override
  String get projectTimeZoneNote =>
      'NAHPU menyimpan tanggal dan waktu koleksi sesuai yang dimasukkan dalam waktu lokal lapangan. Zona waktu proyek mencatat konteks tersebut agar data yang dipertukarkan dapat ditafsirkan secara konsisten oleh sistem manajemen koleksi pihak ketiga dan alat lainnya.';

  @override
  String get projectDates => 'Tanggal proyek';

  @override
  String get projectStartDate => 'Tanggal mulai';

  @override
  String get projectEndDate => 'Tanggal selesai';

  @override
  String get projectChooseDate => 'Pilih tanggal';

  @override
  String projectClearField(String label) {
    return 'Hapus $label';
  }

  @override
  String get projectTimeZone => 'Zona waktu';

  @override
  String get projectChooseTimeZone => 'Pilih zona waktu';

  @override
  String get projectTimeZoneUtc => '(UTC) Waktu Universal Terkoordinasi';

  @override
  String get projectMainTaxonGroup => 'Kelompok takson utama';

  @override
  String get projectChooseTaxonGroup => 'Pilih kelompok takson';

  @override
  String projectTaxonSettingLoadError(String error) {
    return 'Tidak dapat memuat pengaturan takson: $error';
  }

  @override
  String get projectIdentity => 'Identitas';

  @override
  String get projectDescription => 'Deskripsi';

  @override
  String get projectSchedule => 'Jadwal';

  @override
  String get projectRecordMetadata => 'Metadata catatan';

  @override
  String get projectCreated => 'Dibuat';

  @override
  String get projectLastAccessed => 'Terakhir diakses';

  @override
  String get projectNotProvided => 'Tidak diisi';

  @override
  String get projectUuid => 'UUID';

  @override
  String get projectQrTooltip => 'Kode QR proyek. Ketuk untuk melihat penuh.';

  @override
  String get projectEditTools => 'Sunting daftar';

  @override
  String get projectEditToolsTooltip => 'Pilih alat yang ditampilkan di sini';

  @override
  String get projectUtilities => 'Utilitas proyek';

  @override
  String get projectDashboard => 'Dasbor proyek';

  @override
  String get projectEditProject => 'Sunting proyek';

  @override
  String get projectPersonnelRoleCataloger => 'Katalogis';

  @override
  String get projectPersonnelRoleDeterminer => 'Hanya identifikator';

  @override
  String get projectPersonnelRolePreparator => 'Hanya preparator';

  @override
  String get projectPersonnelRoleNone => 'Tidak ada';

  @override
  String get projectPersonnelSelectExisting => 'Pilih yang ada';

  @override
  String get projectPersonnelSelectFromDatabase => 'Pilih dari basis data';

  @override
  String get projectPersonnelAddNew => 'Tambah baru';

  @override
  String get projectPersonnelAddNewPersonnel => 'Tambah personel baru';

  @override
  String get projectPersonnelImageNotFound => 'Gambar tidak ditemukan';

  @override
  String get projectPersonnelTakePhoto => 'Ambil foto';

  @override
  String get projectPersonnelSelectPhoto => 'Pilih foto';

  @override
  String get projectPersonnelEdit => 'Sunting personel';

  @override
  String get projectPersonnelManage => 'Kelola personel';

  @override
  String get projectPersonnelManageButton => 'Kelola';

  @override
  String get projectPersonnelNoneFound => 'Tidak ada personel.';

  @override
  String get projectPersonnelSelectToView =>
      'Pilih personel untuk melihat detail';

  @override
  String get projectPersonnelSearch => 'Cari personel';

  @override
  String get projectPersonnelUnnamed => 'Personel tanpa nama';

  @override
  String get projectPersonnelAssigned =>
      'Personel sedang ditugaskan ke sebuah proyek';

  @override
  String projectPersonnelDeleted(int deleted) {
    String _temp0 = intl.Intl.pluralLogic(
      deleted,
      locale: localeName,
      other: '$deleted personel dihapus.',
    );
    return '$_temp0';
  }

  @override
  String projectPersonnelDeletedPartly(int deleted, int protected) {
    return '$deleted personel dihapus. $protected personel tidak dapat dihapus karena ditugaskan ke sebuah proyek.';
  }

  @override
  String projectPersonnelNoMatch(String query) {
    return 'Tidak ada personel yang cocok dengan “$query”.';
  }

  @override
  String projectSelectedCount(int count) {
    return '$count dipilih';
  }

  @override
  String get projectPersonnelAdded => 'Ditambahkan';

  @override
  String projectPersonnelAddCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tambah $count personel',
    );
    return '$_temp0';
  }

  @override
  String projectPersonnelRemoveBlocked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count personel tidak dapat dihapus karena digunakan oleh catatan proyek.',
    );
    return '$_temp0';
  }

  @override
  String get projectPersonnelRole => 'Peran';

  @override
  String get projectPersonnelRoleHint => 'Masukkan peran';

  @override
  String get projectPersonnelAffiliation => 'Afiliasi';

  @override
  String get projectPersonnelAffiliationHint => 'Masukkan afiliasi';

  @override
  String get projectPersonnelOrcid => 'ORCID iD';

  @override
  String get projectPersonnelOrcidInvalid =>
      'Masukkan ORCID iD yang valid dengan tanda hubung';

  @override
  String get projectPersonnelCurrentFieldNumber => 'Nomor lapangan saat ini';

  @override
  String get projectPersonnelInitials => 'Inisial';

  @override
  String get projectPersonnelInitialsLabel => 'Inisial*';

  @override
  String get projectPersonnelInitialsHint => 'mis. HH atau H-H';

  @override
  String get projectPersonnelEmail => 'Email';

  @override
  String get projectPersonnelEmailHint => 'Masukkan email';

  @override
  String get projectPersonnelPhone => 'Telepon';

  @override
  String get projectPersonnelPhoneHint => 'Masukkan telepon';

  @override
  String get projectPersonnelSpecimenCare => 'Penanganan spesimen';

  @override
  String get projectPersonnelSpecimenCareRole => 'Peran penanganan spesimen';

  @override
  String get projectPersonnelRegisterFieldNumber => 'Daftarkan nomor lapangan';

  @override
  String get projectPersonnelRegisterPersonalFieldNumber =>
      'Daftarkan nomor lapangan pribadi';

  @override
  String get projectPersonnelRegisterFieldNumberNote =>
      'Inisial dan nomor katalogis akan digunakan untuk membuat ID lapangan spesimen.';

  @override
  String get projectEnabled => 'Aktif';

  @override
  String get projectDisabled => 'Nonaktif';

  @override
  String get projectPersonnelProfile => 'Profil';

  @override
  String get projectPersonnelContact => 'Kontak';

  @override
  String get projectPersonnelNotes => 'Catatan';

  @override
  String get projectPersonnelNotesHint => 'Tulis catatan';

  @override
  String get projectPersonnelNameLabel => 'Nama*';

  @override
  String get projectPersonnelNameHint => 'Masukkan nama (wajib)';

  @override
  String get projectPersonnelCatalogerNumberLabel => 'Nomor katalogis*';

  @override
  String projectErrorDetail(String error) {
    return 'Galat: $error';
  }

  @override
  String get projectLoading => 'Memuat…';

  @override
  String get projectTaxonNew => 'Takson baru';

  @override
  String get projectTaxonEdit => 'Sunting takson';

  @override
  String get projectTaxonAdd => 'Tambah takson';

  @override
  String get projectTaxonClassification => 'Klasifikasi';

  @override
  String get projectTaxonRank => 'Peringkat';

  @override
  String get projectTaxonRankLabel => 'Peringkat takson';

  @override
  String get projectTaxonRankHint =>
      'Pilih peringkat yang diwakili catatan ini';

  @override
  String get projectTaxonRankRequired =>
      'Pilih peringkat dan masukkan namanya.';

  @override
  String projectTaxonEnterValue(String field) {
    return 'Masukkan $field';
  }

  @override
  String get projectTaxonKingdom => 'Kerajaan';

  @override
  String get projectTaxonPhylum => 'Filum';

  @override
  String get projectTaxonClass => 'Kelas';

  @override
  String get projectTaxonOrder => 'Ordo';

  @override
  String get projectTaxonFamily => 'Famili';

  @override
  String get projectTaxonGenus => 'Genus';

  @override
  String get projectTaxonSpecies => 'Spesies';

  @override
  String get projectTaxonSubspecies => 'Subspesies';

  @override
  String get projectTaxonSpecificEpithet => 'Epitet spesifik';

  @override
  String get projectTaxonSubspecificEpithet => 'Epitet subspesifik';

  @override
  String get projectTaxonAdditionalDetails => 'Detail tambahan';

  @override
  String get projectTaxonAuthors => 'Penulis';

  @override
  String get projectTaxonAuthorsHint => 'Masukkan penulis';

  @override
  String get projectTaxonCommonName => 'Nama umum';

  @override
  String get projectTaxonCommonNameHint => 'Masukkan nama umum';

  @override
  String get projectTaxonRedListLabel => 'Kategori Daftar Merah IUCN';

  @override
  String get projectTaxonRedListHint => 'mis. Genting, Rentan, dll.';

  @override
  String get projectTaxonRedListCategory => 'Kategori Daftar Merah';

  @override
  String get projectTaxonCitesStatus => 'Status CITES';

  @override
  String get projectTaxonCitesHint =>
      'mis. Apendiks I, Apendiks II, Non-CITES, dll.';

  @override
  String get projectTaxonCountryStatusLabel => 'Status konservasi negara';

  @override
  String get projectTaxonCountryStatusHint => 'mis. Dilindungi, umum, dll.';

  @override
  String get projectTaxonCountryStatus => 'Status negara';

  @override
  String get projectTaxonSortingOrder => 'Urutan penyortiran';

  @override
  String get projectTaxonSortingOrderHint => 'mis. 1, 2, 3';

  @override
  String get projectTaxonNotesHint => 'Masukkan catatan';

  @override
  String get projectTaxonAllFields => 'Semua bidang';

  @override
  String get projectTaxonConservation => 'Konservasi';

  @override
  String get projectTaxonTotalRecords => 'Total catatan';

  @override
  String get projectTaxonCurrentProject => 'Proyek saat ini';

  @override
  String get projectTaxonAllProjects => 'Semua proyek';

  @override
  String projectTaxonRecordTotalsError(String error) {
    return 'Tidak dapat memuat total catatan: $error';
  }

  @override
  String get projectTaxonQrTooltip =>
      'Kode QR takson. Ketuk untuk melihat penuh.';

  @override
  String get projectTaxonQrCode => 'Kode QR takson';

  @override
  String get projectTaxonQrDescription =>
      'Pindai kode ini di NAHPU untuk mengimpor takson ini.';

  @override
  String get projectTaxonRegistry => 'Registri takson';

  @override
  String projectTaxonImported(int taxa, int families) {
    return '$taxa takson diimpor dari $families famili.';
  }

  @override
  String get projectTaxonEmpty =>
      'Tidak ada takson.\nTambah atau impor takson untuk mulai mencatat tangkapan.';

  @override
  String get projectTaxonMetricOrders => 'ordo';

  @override
  String get projectTaxonMetricFamilies => 'famili';

  @override
  String get projectTaxonMetricSpecies => 'spesies terdaftar';

  @override
  String get projectTaxonMetricTaxa => 'takson';

  @override
  String get projectTaxonSpecimenRecords => 'Catatan spesimen';

  @override
  String get projectTaxonSearchSpecimens => 'Cari spesimen';

  @override
  String get projectTaxonNoSpecimens => 'Tidak ada spesimen';

  @override
  String projectTaxonSpecimensFound(int found, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total spesimen',
    );
    String _temp1 = intl.Intl.pluralLogic(
      found,
      locale: localeName,
      other: 'Ditemukan: $found dari $_temp0',
    );
    return '$_temp1';
  }

  @override
  String projectTaxonSpecimenCount(int count) {
    return 'Jumlah spesimen: $count';
  }

  @override
  String get projectTaxonImportFromQr => 'Impor dari QR';

  @override
  String get projectTaxonSingle => 'Takson tunggal';

  @override
  String get projectTaxonMultiple => 'Banyak takson';

  @override
  String get projectTaxonScanQr => 'Pindai QR takson';

  @override
  String get projectTaxonScanMultiple => 'Pindai banyak takson';

  @override
  String get projectCameraDenied =>
      'Akses kamera ditolak. Izinkan akses kamera di pengaturan perangkat, lalu coba lagi.';

  @override
  String get projectTaxonCameraUnavailable =>
      'Pemindaian kamera tidak tersedia. Coba lagi atau gunakan impor berkas.';

  @override
  String get projectTaxonCameraError =>
      'Tidak dapat menggunakan kamera. Coba lagi atau gunakan impor berkas.';

  @override
  String projectTaxonReadyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count takson siap',
    );
    return '$_temp0';
  }

  @override
  String get projectTaxonScanPrompt => 'Pindai kode QR takson NAHPU.';

  @override
  String get projectRetryCamera => 'Coba kamera lagi';

  @override
  String get projectTaxonManage => 'Kelola takson';

  @override
  String get projectTaxonNoneFound => 'Tidak ada takson';

  @override
  String get projectTaxonSelectToView => 'Pilih takson untuk melihat detail';

  @override
  String projectTaxonSearchIn(String category) {
    return 'Cari $category';
  }

  @override
  String projectTaxonSearchCategoryTooltip(String category) {
    return 'Kategori pencarian: $category';
  }

  @override
  String get projectTaxonSearchCategory => 'Kategori pencarian';

  @override
  String get projectTaxonInUse => 'Takson sedang digunakan oleh spesimen';

  @override
  String projectTaxonDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count takson dihapus.',
    );
    return '$_temp0';
  }

  @override
  String projectTaxonDeletedPartly(int deleted, int protected) {
    return '$deleted takson dihapus. $protected takson tidak dapat dihapus karena digunakan oleh spesimen.';
  }

  @override
  String projectTaxonNoMatch(String query) {
    return 'Tidak ada takson yang cocok dengan “$query”.';
  }

  @override
  String projectTaxonNoMatchIn(String query, String category) {
    return 'Tidak ada takson yang cocok dengan “$query” di $category.';
  }

  @override
  String get projectTaxonManual => 'Manual';

  @override
  String get projectImportSetupTab => 'Penyiapan';

  @override
  String get projectTaxonQrSource => 'QR takson NAHPU';

  @override
  String get projectMapColumns => 'Petakan kolom';

  @override
  String get projectParsingError => 'Galat penguraian';

  @override
  String get projectCheckColumns => 'Periksa kolom';

  @override
  String get projectHideAdvancedOptions => 'Sembunyikan opsi lanjutan';

  @override
  String get projectAdvancedOptions => 'Opsi lanjutan';

  @override
  String get projectTaxonReview => 'Tinjau takson';

  @override
  String get projectTaxonPreviewEmpty =>
      'Pilih berkas atau pindai QR takson untuk pratinjau impor.';

  @override
  String projectTaxonReviewSummary(int registered, int duplicates) {
    return '$registered sudah terdaftar · $duplicates duplikat';
  }

  @override
  String get projectTaxonAlreadyRegistered => 'Sudah terdaftar';

  @override
  String get projectTaxonDuplicate => 'Duplikat';

  @override
  String projectImportSelectedCount(int count) {
    return 'Impor $count yang dipilih';
  }

  @override
  String get projectTaxonSelectSharedClass =>
      'Pilih kelas yang sama untuk semua baris';

  @override
  String get projectTaxonClassForAllRows => 'Kelas untuk semua baris';

  @override
  String projectTaxonKingdomPhylum(String kingdom, String phylum) {
    return 'Kerajaan: $kingdom · Filum: $phylum';
  }

  @override
  String get projectParserExcel => 'Pengurai Excel';

  @override
  String get projectParserDelimited => 'Pengurai teks berpembatas';

  @override
  String get projectDelimiterNotApplicable => 'Tidak berlaku (berkas Excel)';

  @override
  String get projectDelimiterTab => 'Tab (\"\\t\")';

  @override
  String get projectDelimiterComma => 'Koma (\",\")';

  @override
  String get projectDelimiterSemicolon => 'Titik koma (\";\")';

  @override
  String get projectDelimiterCustomRaw => 'Kustom (teks mentah)';

  @override
  String get projectParsingDetails => 'Detail penguraian';

  @override
  String projectParserValue(String parser) {
    return 'Pengurai: $parser';
  }

  @override
  String projectDelimiterValue(String delimiter) {
    return 'Pembatas: $delimiter';
  }

  @override
  String get projectCustomDelimiterRequired =>
      'Masukkan pembatas kustom untuk melanjutkan.';

  @override
  String get projectParser => 'Pengurai';

  @override
  String get projectParserAutoDetect => 'Deteksi otomatis';

  @override
  String get projectCustomDelimiter => 'Pembatas kustom';

  @override
  String get projectCustomDelimiterHint =>
      'Masukkan teks mentah (contoh: | atau \\t)';

  @override
  String get projectRetryParse => 'Urai ulang';

  @override
  String get projectTaxonSupportedInputs => 'Masukan yang didukung:';

  @override
  String get projectTaxonSupportedFormats =>
      'CSV (.csv), TSV (.tsv), Excel (.xlsx), QR takson NAHPU';

  @override
  String get projectReadingFile => 'Membaca berkas…';

  @override
  String get projectQrUnavailable =>
      'Pemindaian QR tidak tersedia di platform ini.';

  @override
  String get projectClearImport => 'Hapus impor';

  @override
  String get projectWizardWelcome => 'Selamat datang';

  @override
  String get projectWizardMainTaxon => 'Takson utama';

  @override
  String get projectWizardReview => 'Tinjauan';

  @override
  String get projectWizardCreateOnce => 'Buat sekali untuk semua perangkat';

  @override
  String get projectWizardCreateOnceBody =>
      'Buat proyek baru hanya di perangkat pertama. Gunakan QR/Impor JSON untuk memindahkan info proyek beserta identitasnya.';

  @override
  String get projectWizardCreateNew => 'Buat proyek baru';

  @override
  String get projectScanQr => 'Pindai QR proyek';

  @override
  String get projectWizardMainTaxonBody =>
      'Pilih takson utama untuk menyesuaikan formulir spesimen dan bawaan NAHPU di perangkat ini. Sebuah proyek dapat berisi beberapa kelompok takson, dan Anda dapat mengubah takson utama nanti di Pengaturan.';

  @override
  String get projectWizardFieldIdsTitle => 'Siapkan ID lapangan';

  @override
  String projectWizardFieldIdsLoadError(String error) {
    return 'Tidak dapat memuat pengaturan ID lapangan: $error';
  }

  @override
  String get projectWizardFieldIdsBody =>
      'Pilih cara ID lapangan spesimen dibuat. Anda dapat mengubahnya nanti di Pengaturan > Katalog > Spesimen.';

  @override
  String get projectWizardCatalogerRequired => 'Diperlukan katalogis terdaftar';

  @override
  String get projectWizardCatalogerRequiredBody =>
      'Selanjutnya, pilih katalogis yang memenuhi syarat atau buat dengan inisial dan nomor lapangan pribadi saat ini.';

  @override
  String projectWizardPrefixHint(String example) {
    return 'mis. $example';
  }

  @override
  String get projectCurrentCatalogNumber => 'Nomor katalog saat ini';

  @override
  String get projectWizardNextNumberHint => 'Masukkan nomor berikutnya';

  @override
  String get projectWizardCurrentNumberRequired => 'Masukkan nomor saat ini';

  @override
  String get projectWizardAutoIncrementCatalog =>
      'Tambah nomor katalog otomatis';

  @override
  String projectWizardPersonnelLoadError(String error) {
    return 'Tidak dapat memuat personel: $error';
  }

  @override
  String get projectWizardCreateCataloger => 'Buat katalogis';

  @override
  String get projectWizardChooseCataloger => 'Pilih katalogis';

  @override
  String get projectWizardNoCatalogerBody =>
      'Tidak ada katalogis terdaftar. Buat sekarang; peran dan pendaftaran nomor lapangan pribadi diisi otomatis.';

  @override
  String get projectWizardCreateAnotherCatalogerBody =>
      'Buat katalogis lain. Peran dan pendaftaran nomor lapangan pribadi diisi otomatis.';

  @override
  String get projectWizardChooseCatalogerBody =>
      'Pilih katalogis yang inisial dan nomor lapangan saat ininya akan digunakan untuk ID lapangan personel.';

  @override
  String get projectWizardCatalogerLabel => 'Katalogis*';

  @override
  String get projectWizardCatalogerNameHint => 'Masukkan nama katalogis';

  @override
  String get projectWizardCurrentFieldNumberLabel => 'Nomor lapangan saat ini*';

  @override
  String get projectWizardCurrentFieldNumberHint =>
      'Masukkan nomor lapangan pribadi berikutnya';

  @override
  String get projectWizardCatalogerRoleSet =>
      'Peran penanganan spesimen: Katalogis';

  @override
  String get projectWizardFieldNumberEnabled =>
      'Pendaftaran nomor lapangan pribadi aktif';

  @override
  String get projectWizardReviewImported => 'Tinjau proyek yang diimpor';

  @override
  String get projectWizardReviewProject => 'Tinjau proyek';

  @override
  String get projectWizardImportNote =>
      'Pemindahan info proyek ini mempertahankan UUID sumber. Catatan, personel, takson, dan pengaturan perangkat tidak disertakan.';

  @override
  String get projectName => 'Nama proyek';

  @override
  String get projectFieldIdPrefix => 'Prefiks ID lapangan';

  @override
  String get projectFieldIdSuffix => 'Sufiks ID lapangan';

  @override
  String get projectWizardExistingCataloger => 'Katalogis yang ada dipilih';

  @override
  String get projectWizardNotConfigured => 'Belum diatur';

  @override
  String get projectWizardDeviceSetup => 'Penyiapan perangkat';

  @override
  String get projectWizardKeepCurrent => 'Pertahankan pengaturan saat ini';

  @override
  String get projectWizardFieldIdMode => 'Mode ID lapangan';

  @override
  String get projectWizardAutoIncrement => 'Tambah otomatis';

  @override
  String get projectOn => 'Aktif';

  @override
  String get projectOff => 'Nonaktif';

  @override
  String get projectWizardTaxonomyReadiness => 'Kesiapan taksonomi';

  @override
  String get projectWizardTaxaCountUnavailable =>
      'Jumlah takson yang tersedia tidak dapat ditampilkan.';

  @override
  String projectWizardAvailableTaxa(int count) {
    return 'Takson tersedia: $count';
  }

  @override
  String get projectWizardNoTaxa => 'Tidak ada takson tersedia';

  @override
  String get projectWizardNoTaxaBody =>
      'Tambah atau impor takson di Registri takson sebelum membuat catatan spesimen baru.';

  @override
  String get projectWizardSkip => 'Lewati';

  @override
  String get projectWizardCreating => 'Membuat…';

  @override
  String get projectWizardCatalogerNameRequired => 'Nama katalogis wajib diisi';

  @override
  String get projectWizardNameTooShort => 'Nama terlalu pendek';

  @override
  String get projectWizardInvalidCharacters => 'Karakter tidak valid';

  @override
  String get projectWizardInitialsRequired => 'Inisial wajib diisi';

  @override
  String get projectWizardInitialsTooShort => 'Inisial terlalu pendek';

  @override
  String get projectWizardFieldNumberRequired =>
      'Nomor lapangan saat ini wajib diisi';

  @override
  String get projectWizardInvalidFieldNumber => 'Nomor lapangan tidak valid';

  @override
  String get projectInvalidQr => 'Kode QR proyek tidak valid.';

  @override
  String get projectNameRequired => 'Nama proyek wajib diisi';

  @override
  String get projectNameTooShort => 'Nama proyek terlalu pendek';

  @override
  String get projectNameTooLong => 'Nama proyek terlalu panjang';

  @override
  String get projectNameInvalid => 'Nama proyek tidak valid';

  @override
  String get projectNameExists => 'Nama proyek sudah ada';

  @override
  String get projectUuidExists =>
      'Proyek dengan UUID ini sudah ada di perangkat ini.';

  @override
  String projectCreateFailed(String error) {
    return 'Tidak dapat membuat proyek: $error';
  }

  @override
  String get projectWizardChooseExisting => 'Pilih yang ada';

  @override
  String get projectWizardCreateNewCataloger => 'Buat baru';

  @override
  String projectUuidValue(String uuid) {
    return 'UUID proyek: $uuid';
  }

  @override
  String get projectImportInfoJson => 'Impor JSON info proyek';

  @override
  String get projectTransferProjectInfo => 'Info proyek';

  @override
  String get projectTransferTaxonomy => 'Taksonomi';

  @override
  String get projectTransferSites => 'Lokasi';

  @override
  String get projectTransferEvents => 'Kegiatan';

  @override
  String get projectTransferSpecimens => 'Spesimen';

  @override
  String get projectTransferNarratives => 'Narasi';

  @override
  String get projectTransferCustomFields => 'Bidang kustom';

  @override
  String get projectTransferMedia => 'Media';

  @override
  String get projectTransferKeepCurrent => 'Pertahankan yang ada';

  @override
  String get projectTransferUseImported => 'Gunakan yang diimpor';

  @override
  String get projectTransferImportAsNew => 'Impor sebagai baru';

  @override
  String get projectExporting => 'Mengekspor proyek';

  @override
  String get projectExportingHint =>
      'Proyek dengan banyak foto dapat memakan waktu beberapa menit. Biarkan NAHPU tetap terbuka sampai selesai.';

  @override
  String get projectExportAnother => 'Ekspor lagi';

  @override
  String get projectExportCancelTitle => 'Batalkan ekspor?';

  @override
  String get projectExportCancelBody =>
      'Ekspor masih berjalan. Keluar sekarang akan membatalkannya dan tidak ada berkas yang disimpan.';

  @override
  String get projectExportKeepExporting => 'Lanjutkan ekspor';

  @override
  String get projectExportCancel => 'Batalkan ekspor';

  @override
  String projectOpenFolderFailed(String error) {
    return 'Tidak dapat membuka folder: $error';
  }

  @override
  String projectSaveCopyFailed(String error) {
    return 'Tidak dapat menyimpan salinan: $error';
  }

  @override
  String get projectExportArchiveTitle => 'Arsip cadangan dan pemindahan';

  @override
  String get projectExportArchiveBody =>
      'Gunakan arsip ini sebagai cadangan proyek, atau untuk memindahkan proyek ini ke perangkat lain dan menggabungkannya di sana.';

  @override
  String get projectExportLight => 'Ekspor ringan';

  @override
  String get projectExportLightBody =>
      'Ekspor proyek tanpa berkas media untuk unggahan dengan internet terbatas. Gunakan TAR.GZ atau ZIP untuk cadangan proyek lengkap.';

  @override
  String get projectExportArchiveContents => 'Isi arsip';

  @override
  String get projectExportExcluded => 'Tidak disertakan';

  @override
  String get projectExportMediaSize => 'Ukuran media';

  @override
  String projectWarningCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count peringatan',
    );
    return '$_temp0';
  }

  @override
  String get projectTransferFileAndSafety => 'Berkas dan keamanan';

  @override
  String get projectTransferReviewImport => 'Tinjau dan impor';

  @override
  String get projectTransferReviewMerge => 'Tinjau dan gabungkan';

  @override
  String get projectTransferResult => 'Hasil';

  @override
  String get projectTransferChooseFirst =>
      'Pilih pemindahan proyek terlebih dahulu';

  @override
  String get projectTransferChooseFirstBody =>
      'Kembali ke Berkas dan keamanan untuk memilih arsip.';

  @override
  String get projectTransferChooseTitle => 'Pilih pemindahan proyek NAHPU';

  @override
  String get projectTransferChooseBody =>
      'Pemindahan proyek dapat berupa JSON.GZ, ZIP, atau TAR.GZ. JSON.GZ hanya berisi catatan. ZIP dan TAR.GZ menyertakan media.';

  @override
  String get projectTransferReadingArchive => 'Membaca arsip';

  @override
  String get projectTransferReadingArchiveHint =>
      'Pemindahan yang menyertakan media dapat memakan waktu beberapa menit untuk dibongkar. Biarkan NAHPU tetap terbuka.';

  @override
  String get projectTransferChooseArchive => 'Pilih arsip';

  @override
  String get projectTransferChooseAnotherArchive => 'Pilih arsip lain';

  @override
  String get projectTransferBackupBeforeImport => 'Cadangkan sebelum mengimpor';

  @override
  String get projectTransferBackupBeforeMerge =>
      'Cadangkan sebelum menggabungkan';

  @override
  String get projectTransferBackupBody =>
      'Cadangan basis data memberi Anda titik pemulihan jika perubahan yang diimpor tidak sesuai harapan.';

  @override
  String get projectTransferBackupNow => 'Cadangkan sekarang';

  @override
  String get projectTransferBackupAckImport =>
      'Saya mengerti bahwa saya perlu menyimpan cadangan sebelum mengimpor.';

  @override
  String get projectTransferBackupAckMerge =>
      'Saya mengerti bahwa saya perlu menyimpan cadangan sebelum menggabungkan.';

  @override
  String get projectTransferNewIdentity => 'Identitas proyek baru';

  @override
  String projectTransferArchiveUuid(String uuid) {
    return 'UUID arsip: $uuid';
  }

  @override
  String get projectTransferDestinationName => 'Nama proyek tujuan';

  @override
  String get projectTransferDestinationNameHelper =>
      'Menamai proyek baru di perangkat ini. Arsip tidak diubah.';

  @override
  String projectTransferNameConflict(String name) {
    return 'Proyek bernama “$name” sudah ada. Pilih nama lain. Jika keduanya salinan proyek yang sama, batalkan dan gunakan Gabungkan proyek.';
  }

  @override
  String get projectTransferAlreadyExists => 'Proyek ini sudah ada';

  @override
  String get projectTransferAlreadyExistsBody =>
      'UUID yang sama menandakan proyek yang sama. Impor diblokir. Gabungkan arsip ini ke proyek yang ada.';

  @override
  String get projectTransferOpenMerge => 'Buka Gabungkan proyek';

  @override
  String get projectTransferUuidMismatch => 'UUID proyek tidak cocok';

  @override
  String projectTransferUuidMismatchBody(String archive, String active) {
    return 'Arsip: $archive\nProyek aktif: $active';
  }

  @override
  String get projectTransferForceMerge => 'Paksa gabung ke proyek aktif';

  @override
  String get projectTransferForceMergeBody =>
      'Catatan proyek yang diimpor akan menggunakan UUID proyek aktif. Konflik tetap memerlukan pilihan yang ditampilkan nanti.';

  @override
  String projectTransferTypeToConfirm(String name) {
    return 'Ketik “$name” untuk mengonfirmasi';
  }

  @override
  String get projectCatalogNumberPrefix => 'Prefiks nomor katalog';

  @override
  String get projectCatalogNumberSuffix => 'Sufiks nomor katalog';

  @override
  String get projectTransferProjectInfoBody =>
      'Nilai saat ini dipertahankan secara bawaan. Pilih nilai impor satu per satu jika ingin menggantinya.';

  @override
  String get projectTransferKeepAllCurrent => 'Pertahankan semua yang ada';

  @override
  String get projectTransferUseAllImported => 'Gunakan semua yang diimpor';

  @override
  String get projectTransferReviewMatches =>
      'Tinjau kecocokan sebelum melanjutkan. “Pertahankan yang ada” memetakan dependensi yang diimpor ke catatan yang ada tanpa menggantinya.';

  @override
  String get projectTransferBulkTooltip =>
      'Terapkan satu pilihan ke semua catatan yang cocok';

  @override
  String projectTransferActionForAll(String action) {
    return '$action untuk semua';
  }

  @override
  String get projectTransferBulkAction => 'Tindakan massal';

  @override
  String get projectTransferStatusNew => 'Baru';

  @override
  String get projectTransferStatusMatched => 'Cocok';

  @override
  String get projectTransferNeedsAttention => 'Perlu perhatian';

  @override
  String get projectTransferSkipped => 'Dilewati';

  @override
  String get projectTransferNoConflicts => 'Tidak ada konflik';

  @override
  String get projectTransferNoConflictsBody =>
      'Semua catatan di bagian ini dapat diimpor sebagai baru.';

  @override
  String get projectTransferReviewBody =>
      'Belum ada yang ditulis. Perubahan basis data akan disimpan bersamaan; satu kegagalan membatalkan semuanya.';

  @override
  String get projectTransferSourceProject => 'Proyek sumber';

  @override
  String get projectTransferDestination => 'Tujuan';

  @override
  String get projectTransferUuidHandling => 'Penanganan UUID';

  @override
  String projectTransferNewUuid(String uuid) {
    return 'UUID proyek baru: $uuid';
  }

  @override
  String get projectTransferForceMergeUuid => 'Paksa gabung ke UUID aktif';

  @override
  String get projectTransferMatchingUuid => 'UUID proyek cocok';

  @override
  String get projectTransferConflicts => 'Konflik';

  @override
  String get projectTransferMediaFiles => 'Berkas media';

  @override
  String get projectTransferResolveConflicts =>
      'Selesaikan konflik sebelum menggabungkan';

  @override
  String projectTransferDuplicateIdentifiers(String sections) {
    return 'Pengenal duplikat masih memerlukan tindakan di $sections.';
  }

  @override
  String get projectTransferArchiveWarnings => 'Peringatan arsip';

  @override
  String get projectTransferImportUnfinished => 'Impor tidak selesai';

  @override
  String get projectTransferMergeUnfinished => 'Penggabungan tidak selesai';

  @override
  String get projectTransferImportRetry =>
      'Kembali ke Tinjau dan impor lalu coba lagi.';

  @override
  String get projectTransferMergeRetry =>
      'Kembali ke Tinjau dan gabungkan lalu coba lagi.';

  @override
  String get projectTransferImported => 'Proyek diimpor';

  @override
  String get projectTransferMerged => 'Data proyek digabungkan';

  @override
  String get projectTransferCountImported => 'Diimpor';

  @override
  String get projectTransferCountMerged => 'Digabungkan';

  @override
  String get projectTransferCountUpdated => 'Diperbarui';

  @override
  String get projectTransferSkippedOnConflict => 'Dilewati karena konflik';

  @override
  String get projectTransferMediaCopied => 'Media disalin';

  @override
  String get projectTransferWarnings => 'Peringatan';

  @override
  String get projectTransferConflict => 'Konflik';

  @override
  String get projectTransferCurrent => 'Saat ini';

  @override
  String get projectTransferConflictAction => 'Tindakan konflik';

  @override
  String get projectTransferChooseAction => 'Pilih tindakan';

  @override
  String get projectTransferChooseActionToContinue =>
      'Pilih tindakan untuk melanjutkan';

  @override
  String get projectTransferNotSet => 'Belum diatur';

  @override
  String get projectTransferNoDetails => 'Tidak ada detail';

  @override
  String get projectBatchSpecimenParts => 'Bagian spesimen';

  @override
  String get projectBatchParasites => 'Parasit';

  @override
  String get projectBatchNarrative => 'Narasi';

  @override
  String get projectBatchModeUpdate => 'Perbarui catatan yang ada';

  @override
  String get projectBatchModeCreate => 'Impor catatan baru';

  @override
  String get projectBatchHeaderAuto => 'Otomatis';

  @override
  String get projectBatchDarwinCore => 'Darwin Core';

  @override
  String get projectBatchHeaderNames => 'Nama kolom';

  @override
  String get projectBatchKeySpecimenUuid => 'UUID spesimen';

  @override
  String get projectBatchKeyCatalogNumber => 'Nomor katalog';

  @override
  String get projectBatchKeyCatalogerFieldNumber =>
      'Katalogis dan nomor lapangan';

  @override
  String get projectBatchKeyTissueId => 'ID jaringan';

  @override
  String get projectBatchKeyBarcodeId => 'ID kode batang';

  @override
  String get projectBatchKeyParasiteId => 'ID parasit';

  @override
  String get projectBatchKeyParasiteUuid => 'UUID parasit';

  @override
  String get projectBatchKeySiteId => 'ID lokasi';

  @override
  String get projectBatchKeyEventId => 'ID kegiatan';

  @override
  String get projectBatchKeyNarrativeDate => 'Tanggal narasi';

  @override
  String get projectBatchStatusReady => 'Siap';

  @override
  String get projectBatchStatusMissingLink => 'Tautan hilang';

  @override
  String get projectBatchStatusNoMatch => 'Tidak cocok';

  @override
  String get projectBatchStatusAmbiguous => 'Beberapa kecocokan';

  @override
  String get projectBatchStatusExists => 'Sudah ada di proyek';

  @override
  String get projectBatchStatusDuplicateInFile => 'Berulang di berkas';

  @override
  String get projectBatchStatusInvalid => 'Nilai tidak valid';

  @override
  String get projectBatchUpdateRecords => 'Perbarui catatan';

  @override
  String get projectBatchImportRecords => 'Impor catatan';

  @override
  String get projectBatchStepMode => 'Mode';

  @override
  String get projectBatchStepFile => 'Berkas';

  @override
  String get projectBatchStepColumns => 'Kolom';

  @override
  String get projectBatchStepGroups => 'Grup';

  @override
  String get projectBatchUnsupportedFile =>
      'Pilih berkas CSV, TSV, atau Excel.';

  @override
  String get projectBatchModeTitle => 'Apa yang ingin Anda lakukan?';

  @override
  String get projectBatchModeBody =>
      'Masukkan catatan dari berkas CSV, TSV, atau Excel. Kolom dapat memakai istilah Darwin Core atau nama Anda sendiri.';

  @override
  String get projectBatchModeCreateBody =>
      'Tambahkan satu catatan per baris. Takson, personel, lokasi, dan kegiatan ditautkan jika sudah ada di proyek.';

  @override
  String get projectBatchModeUpdateBody =>
      'Cocokkan setiap baris dengan catatan melalui kolom kunci, seperti nomor katalog, lalu tulis kolom lainnya. Sel kosong tidak diubah.';

  @override
  String get projectBatchRecords => 'Catatan';

  @override
  String get projectBatchLinkedRecords => 'Catatan tertaut';

  @override
  String get projectBatchLinkedRecordsBody =>
      'Setiap baris dapat menjelaskan lokasi, kegiatan koleksinya, spesimen, dan bagiannya. Baris dikelompokkan ke dalam lokasi dan kegiatan yang dapat Anda periksa sebelum mengimpor.';

  @override
  String get projectBatchChooseFile => 'Pilih berkas';

  @override
  String get projectBatchChooseFileBody =>
      'Baris pertama harus berisi nama kolom. Setiap baris setelahnya adalah satu catatan.';

  @override
  String get projectBatchSheet => 'Lembar';

  @override
  String projectBatchTableSize(int rows, int columns) {
    String _temp0 = intl.Intl.pluralLogic(
      rows,
      locale: localeName,
      other: '$rows baris',
    );
    String _temp1 = intl.Intl.pluralLogic(
      columns,
      locale: localeName,
      other: '$columns kolom',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get projectBatchMatchColumns => 'Cocokkan kolom';

  @override
  String projectBatchMatchColumnsBody(int mapped, int total) {
    return '$mapped dari $total kolom cocok dengan bidang. Ubah kecocokan apa pun, atau lewati kolom. Perubahan Anda diingat untuk berkas dengan kolom yang sama.';
  }

  @override
  String get projectBatchKeyColumn => 'Kolom kunci';

  @override
  String projectBatchKeyColumnMissing(String keys) {
    return 'Petakan kolom ke salah satu dari: $keys.';
  }

  @override
  String get projectBatchKeyColumnBody =>
      'Baris memperbarui catatan dengan nilai yang sama.';

  @override
  String get projectBatchMatchRecordsBy => 'Cocokkan catatan berdasarkan';

  @override
  String get projectBatchNoValues => 'Tidak ada nilai';

  @override
  String get projectBatchNahpuField => 'Bidang NAHPU';

  @override
  String get projectBatchSkipColumn => 'Lewati kolom';

  @override
  String projectBatchFieldInUse(String field) {
    return '$field (sedang dipakai)';
  }

  @override
  String get projectBatchNameMatch => 'Nama cocok';

  @override
  String projectBatchCloseMatch(int percent) {
    return 'Hampir cocok $percent%';
  }

  @override
  String get projectBatchSkippedByYou => 'Dilewati oleh Anda';

  @override
  String get projectBatchYourChoice => 'Pilihan Anda';

  @override
  String get projectBatchSearch => 'Cari';

  @override
  String projectBatchLoadRecordsFailed(String error) {
    return 'Tidak dapat memuat catatan: $error';
  }

  @override
  String get projectBatchNoMatchingRecords => 'Tidak ada catatan yang cocok.';

  @override
  String get projectBatchNoOtherGroup =>
      'Tidak ada grup lain untuk digabungkan.';

  @override
  String get projectBatchMoveToNewGroup => 'Pindahkan ke grup baru';

  @override
  String get projectBatchCheckGroups => 'Periksa grup';

  @override
  String get projectBatchCheckGroupsBody =>
      'Baris yang menjelaskan lokasi atau kegiatan yang sama dikelompokkan. Tautkan grup ke catatan yang ada di proyek, gabungkan grup yang merupakan tempat atau kunjungan yang sama, atau pisahkan baris.';

  @override
  String projectBatchSitesCount(int count) {
    return 'Lokasi ($count)';
  }

  @override
  String projectBatchEventsCount(int count) {
    return 'Kegiatan ($count)';
  }

  @override
  String projectBatchSpecimensCount(int count) {
    return 'Spesimen ($count)';
  }

  @override
  String get projectBatchNoSiteColumns =>
      'Tidak ada kolom yang menjelaskan lokasi.';

  @override
  String get projectBatchNoEventColumns =>
      'Tidak ada kolom yang menjelaskan kegiatan.';

  @override
  String get projectBatchNoSpecimenColumns =>
      'Tidak ada kolom yang menjelaskan spesimen.';

  @override
  String get projectBatchNewSite => 'Lokasi baru';

  @override
  String projectBatchEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kegiatan',
    );
    return '$_temp0';
  }

  @override
  String projectBatchSpecimenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spesimen',
    );
    return '$_temp0';
  }

  @override
  String projectBatchPartCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bagian',
    );
    return '$_temp0';
  }

  @override
  String projectBatchParasiteCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parasit',
    );
    return '$_temp0';
  }

  @override
  String get projectBatchSetSiteId => 'Atur ID lokasi';

  @override
  String get projectBatchLinkSite => 'Tautkan ke lokasi yang ada';

  @override
  String get projectBatchMergeIntoSite => 'Gabungkan ke lokasi';

  @override
  String get projectBatchMoveRowsToSite => 'Pindahkan baris ke lokasi baru';

  @override
  String projectBatchRow(String row) {
    return 'Baris $row';
  }

  @override
  String projectBatchRows(String rows) {
    return 'Baris $rows';
  }

  @override
  String projectBatchRowsMore(int count, String rows) {
    return 'Baris $rows dan $count lainnya';
  }

  @override
  String get projectBatchNoSite => 'Tanpa lokasi';

  @override
  String get projectBatchNoEvent => 'Tanpa kegiatan';

  @override
  String projectBatchEventLabel(String event) {
    return 'Kegiatan: $event';
  }

  @override
  String get projectBatchSetIdSuffix => 'Atur sufiks ID';

  @override
  String get projectBatchLinkEvent => 'Tautkan ke kegiatan yang ada';

  @override
  String get projectBatchSetEventIdSuffix => 'Atur sufiks ID kegiatan';

  @override
  String get projectBatchMergeIntoEvent => 'Gabungkan ke kegiatan';

  @override
  String get projectBatchMoveRowsToEvent => 'Pindahkan baris ke kegiatan baru';

  @override
  String get projectBatchExcluded => 'Dikecualikan';

  @override
  String get projectBatchCheck => 'Periksa';

  @override
  String get projectBatchLinksToExisting => 'Tertaut ke yang ada';

  @override
  String get projectBatchChangeGroup => 'Ubah grup';

  @override
  String get projectBatchLinkExisting => 'Tautkan ke yang ada…';

  @override
  String get projectBatchCreateNew => 'Buat baru saja';

  @override
  String get projectBatchMergeInto => 'Gabungkan ke…';

  @override
  String get projectBatchSplitRows => 'Pisahkan baris…';

  @override
  String get projectBatchLinkedReviewBody =>
      'Lokasi ditulis terlebih dahulu, lalu kegiatan di lokasi tersebut, kemudian spesimen dan bagiannya.';

  @override
  String projectBatchSitesSummary(int created, int linked) {
    return 'Lokasi: $created baru, $linked tertaut';
  }

  @override
  String projectBatchEventsSummary(int created, int linked) {
    return 'Kegiatan: $created baru, $linked tertaut';
  }

  @override
  String projectBatchSpecimensSummary(int count) {
    return 'Spesimen: $count';
  }

  @override
  String projectBatchPartsSummary(int count) {
    return 'Bagian: $count';
  }

  @override
  String projectBatchParasitesSummary(int count) {
    return 'Parasit: $count';
  }

  @override
  String projectBatchRowsSkipped(int count) {
    return 'Baris dilewati: $count';
  }

  @override
  String get projectBatchImportSpecimensMissingLinks =>
      'Impor spesimen dengan tautan hilang';

  @override
  String get projectBatchImportSpecimensMissingLinksBody =>
      'Takson atau orang dibiarkan kosong. Tambahkan ke proyek terlebih dahulu untuk menautkannya.';

  @override
  String projectBatchWritingRecords(int done, int total) {
    return 'Menulis $done dari $total catatan';
  }

  @override
  String projectBatchWritingRows(int done, int total) {
    return 'Menulis $done dari $total baris';
  }

  @override
  String get projectBatchNoProblems => 'Tidak ada masalah.';

  @override
  String projectBatchMoreRows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dan $count baris lainnya.',
    );
    return '$_temp0';
  }

  @override
  String projectBatchSiteProblem(String site, String message) {
    return 'Lokasi $site: $message';
  }

  @override
  String projectBatchSpecimenSkipped(String status) {
    return 'Spesimen dilewati: $status.';
  }

  @override
  String get projectBatchExcludedRow => 'Dikecualikan.';

  @override
  String get projectBatchDoneWithErrors => 'Selesai, dengan galat';

  @override
  String projectBatchAddedSpecimensParts(int specimens, int parts) {
    String _temp0 = intl.Intl.pluralLogic(
      specimens,
      locale: localeName,
      other: '$specimens spesimen',
    );
    String _temp1 = intl.Intl.pluralLogic(
      parts,
      locale: localeName,
      other: '$parts bagian',
    );
    return 'Menambahkan $_temp0 dan $_temp1.';
  }

  @override
  String projectBatchRowsWithErrors(int count) {
    return 'Baris dengan galat: $count';
  }

  @override
  String get projectBatchOpenSpecimenTable => 'Buka tabel catatan spesimen';

  @override
  String projectBatchUpdatedRecords(int count, String records) {
    return '$count $records diperbarui.';
  }

  @override
  String projectBatchAddedRecords(int count, String records) {
    return '$count $records ditambahkan.';
  }

  @override
  String projectBatchUpdatedCount(int count) {
    return 'Diperbarui: $count';
  }

  @override
  String projectBatchAddedCount(int count) {
    return 'Ditambahkan: $count';
  }

  @override
  String projectBatchSkippedInReview(int count) {
    return 'Dilewati saat tinjauan: $count';
  }

  @override
  String projectBatchFailedCount(int count) {
    return 'Gagal: $count';
  }

  @override
  String projectBatchOpenTable(String records) {
    return 'Buka tabel $records';
  }

  @override
  String projectBatchReviewUpdate(int count, int total, String records) {
    return 'Ini akan memperbarui $count dari $total $records. Baris bermasalah dilewati.';
  }

  @override
  String projectBatchReviewAdd(int count, int total, String records) {
    return 'Ini akan menambahkan $count dari $total $records. Baris bermasalah dilewati.';
  }

  @override
  String get projectBatchImportRowsMissingLinks =>
      'Impor baris dengan tautan hilang';

  @override
  String get projectBatchImportRowsMissingLinksBody =>
      'Takson, orang, lokasi, atau kegiatan dibiarkan kosong. Tambahkan ke proyek terlebih dahulu untuk menautkannya.';

  @override
  String get projectStatsPartQuantity => 'Jumlah bagian';

  @override
  String get projectStatsQuantity => 'Jumlah';

  @override
  String get projectStatsSite => 'Lokasi';

  @override
  String get projectStatsDate => 'Tanggal';

  @override
  String get projectStatsMethod => 'Metode';

  @override
  String get projectStatsSex => 'Jenis kelamin';

  @override
  String get projectStatsLifeStage => 'Tahap hidup';

  @override
  String get projectStatsPartType => 'Jenis bagian';

  @override
  String get projectStatsTreatment => 'Perlakuan';

  @override
  String get projectStatsParasiteTaxon => 'Takson parasit';

  @override
  String get projectStatsParasiteCategory => 'Kategori';

  @override
  String get projectStatsAnatomicalLocation => 'Lokasi anatomi';

  @override
  String get projectStatsHostSpecies => 'Spesies inang';

  @override
  String projectStatsTitle(String measure, String category) {
    return '$measure menurut $category';
  }

  @override
  String projectStatsTitleWithBreakdown(
    String measure,
    String category,
    String breakdown,
  ) {
    return '$measure menurut $category dan $breakdown';
  }

  @override
  String projectStatsTitleAtSite(String title, String site) {
    return '$title di $site';
  }

  @override
  String projectStatsTitleForSpecies(String title, String species) {
    return '$title untuk $species';
  }

  @override
  String get projectStatsCoordinatesBySpecies => 'Koordinat menurut spesies';

  @override
  String get projectStatsSpatialSpecimensTitle =>
      'Jumlah spesimen menurut koordinat lokasi';

  @override
  String get projectStatsSpatialSpeciesTitle =>
      'Jumlah spesies menurut koordinat lokasi';

  @override
  String get projectStatsSpatialFamiliesTitle =>
      'Jumlah famili menurut koordinat lokasi';

  @override
  String get projectStatsSpatialSelectedSpeciesTitle =>
      'Jumlah spesies terpilih menurut koordinat';

  @override
  String get projectStatsCountSpecimens => 'spesimen';

  @override
  String get projectStatsCountSpecies => 'spesies';

  @override
  String get projectStatsCountFamilies => 'famili';

  @override
  String get projectStatsClasses => 'Kelas';

  @override
  String get projectStatsOrders => 'Ordo';

  @override
  String get projectStatsFamilies => 'Famili';

  @override
  String get projectStatsGenera => 'Genus';

  @override
  String get projectStatsSpecimenMedia => 'Media spesimen';

  @override
  String get projectStatsSiteMedia => 'Media lokasi';

  @override
  String get projectStatsEventMedia => 'Media kegiatan';

  @override
  String get projectStatsNarrativeMedia => 'Media narasi';

  @override
  String get projectStatsRecordedSites => 'Lokasi tercatat';

  @override
  String get projectStatsSampledSites => 'Lokasi tersampel';

  @override
  String get projectStatsCaptureDays => 'Hari penangkapan';

  @override
  String get projectStatsProjectDays => 'Hari proyek';

  @override
  String get projectStatsRecordedElevation => 'Ketinggian tercatat';

  @override
  String get projectStatsSampledElevation => 'Ketinggian tersampel';

  @override
  String get projectStatsNotRecorded => 'Tidak tercatat';

  @override
  String get projectStatsRecordStatistics => 'Statistik catatan';

  @override
  String get projectStatsTopSpecies => 'Spesies paling banyak tercatat';

  @override
  String get projectStatsRecordCounts => 'Jumlah catatan';

  @override
  String get projectStatsShowRecordCounts => 'Tampilkan jumlah catatan';

  @override
  String get projectStatsShowTopSpecies =>
      'Tampilkan spesies paling banyak tercatat';

  @override
  String get projectStatsExploreMore => 'Jelajahi statistik lainnya';

  @override
  String projectStatsRecordLoadError(String error) {
    return 'Tidak dapat memuat statistik catatan: $error';
  }

  @override
  String get projectStatsSummary => 'Ringkasan';

  @override
  String get projectStatsExplore => 'Jelajahi';

  @override
  String get projectStatsTotalAllProjects => 'Total semua proyek';

  @override
  String get projectStatsGroupBy => 'Kelompokkan menurut';

  @override
  String get projectStatsSelectSite => 'Pilih lokasi';

  @override
  String get projectStatsAllSites => 'Semua lokasi';

  @override
  String get projectStatsSelectSpecies => 'Pilih spesies';

  @override
  String get projectStatsAllSpecies => 'Semua spesies';

  @override
  String get projectStatsChart => 'Grafik';

  @override
  String get projectStatsTable => 'Tabel';

  @override
  String get projectStatsRecordSummary => 'Ringkasan catatan';

  @override
  String get projectStatsTaxonomicBreakdown => 'Rincian taksonomi';

  @override
  String get projectStatsMediaBreakdown => 'Rincian media';

  @override
  String get projectStatsPerProject => 'Per proyek';

  @override
  String get projectStatsNoProjects => 'Belum ada proyek.';

  @override
  String projectStatsProjectLoadError(String error) {
    return 'Tidak dapat memuat statistik proyek: $error';
  }

  @override
  String get projectStatsViewDetails => 'Lihat detail';

  @override
  String get projectStatsBreakDownBy => 'Rinci menurut';

  @override
  String projectStatsLoadError(String error) {
    return 'Tidak dapat memuat statistik: $error';
  }

  @override
  String get projectStatsSpecimensBySpecies => 'Spesimen menurut spesies';

  @override
  String get projectStatsSpecimensByFamily => 'Spesimen menurut famili';

  @override
  String get projectStatsSpecimensBySite => 'Spesimen menurut lokasi';

  @override
  String get projectStatsSpecimensByDate => 'Spesimen menurut tanggal';

  @override
  String get projectStatsSpecimensByMethod => 'Spesimen menurut metode';

  @override
  String get projectStatsSpecimensBySex => 'Spesimen menurut jenis kelamin';

  @override
  String get projectStatsPartQuantityByType => 'Jumlah bagian menurut jenis';

  @override
  String get projectStatsPartQuantityByTreatment =>
      'Jumlah bagian menurut perlakuan';

  @override
  String get projectStatsCounts => 'Jumlah';

  @override
  String get projectStatsSpatial => 'Spasial';

  @override
  String get projectStatsNetwork => 'Graf';

  @override
  String get projectStatsNetworkTitle =>
      'Catatan yang terhubung melalui spesimen';

  @override
  String get projectStatsNetworkHint =>
      'Ketuk catatan untuk melihat apa yang terhubung dengannya.';

  @override
  String get projectStatsNetworkRadial => 'Radial';

  @override
  String get projectStatsNetworkLayered => 'Berlapis';

  @override
  String get projectStatsNetworkStartFrom => 'Mulai dari';

  @override
  String get projectStatsNetworkColumns => 'Kolom';

  @override
  String get projectStatsNetworkFields => 'Bidang';

  @override
  String projectStatsNetworkMaxColumns(int count) {
    return 'Maksimal $count kolom';
  }

  @override
  String get projectStatsNetworkYear => 'Tahun';

  @override
  String get projectStatsNetworkLinked => 'Catatan terhubung';

  @override
  String get projectStatsNetworkFit => 'Sesuaikan tampilan';

  @override
  String get projectStatsNetworkReset => 'Atur ulang';

  @override
  String get projectStatsNetworkFullScreen => 'Lihat graf layar penuh';

  @override
  String projectStatsNetworkLoadError(String error) {
    return 'Tidak dapat memuat graf: $error';
  }

  @override
  String get projectStatsNetworkEmpty =>
      'Belum ada spesimen untuk dihubungkan.';

  @override
  String projectStatsNetworkMore(int count) {
    return '+$count lainnya';
  }

  @override
  String projectStatsNetworkSpecimens(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spesimen',
    );
    return '$_temp0';
  }

  @override
  String projectStatsNetworkShared(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spesimen bersama',
    );
    return '$_temp0';
  }

  @override
  String projectStatsNetworkRecords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count catatan',
    );
    return '$_temp0';
  }

  @override
  String get projectStatsNetworkShowLinks => 'Tampilkan tautan';

  @override
  String get projectStatsNetworkHideLinks => 'Sembunyikan tautan';

  @override
  String get projectStatsNetworkShowMore => 'Tampilkan lebih banyak';

  @override
  String get projectStatsNetworkSites => 'Lokasi';

  @override
  String get projectStatsNetworkEvents => 'Peristiwa';

  @override
  String get projectStatsNetworkSpecimenType => 'Spesimen';

  @override
  String get projectStatsNetworkTaxa => 'Spesies';

  @override
  String get projectStatsNetworkMedia => 'Media';

  @override
  String get projectStatsNetworkParts => 'Bagian';

  @override
  String get projectStatsNetworkParasites => 'Parasit';

  @override
  String get projectStatsNetworkLegend => 'Jenis catatan';

  @override
  String get projectStatsNetworkAllProjects => 'Semua proyek';

  @override
  String get projectStatsNetworkOptions => 'Opsi';

  @override
  String get projectStatsNetworkShowOptions => 'Tampilkan opsi';

  @override
  String get projectStatsNetworkHideOptions => 'Sembunyikan opsi';

  @override
  String get projectStatsNetworkDetails => 'Detail';

  @override
  String get projectStatsNetworkExitFullScreen => 'Keluar dari layar penuh';

  @override
  String projectStatsNetworkSummaryRadial(String layout, String type) {
    return '$layout · dari $type';
  }

  @override
  String projectStatsNetworkSummaryLayered(String layout, int count) {
    return '$layout · $count kolom';
  }

  @override
  String get projectStatsNoData => 'Tidak ada data untuk ditampilkan';

  @override
  String projectStatsTapToView(String label) {
    return '$label\nKetuk untuk melihat catatan';
  }

  @override
  String get projectStatsShowBarChart => 'Tampilkan diagram batang';

  @override
  String get projectStatsShowPieChart => 'Tampilkan diagram lingkaran';

  @override
  String get projectStatsClearSelection => 'Hapus pilihan';

  @override
  String projectStatsChoicesLoadError(String error) {
    return 'Tidak dapat memuat pilihan: $error';
  }

  @override
  String get projectStatsNoMatchingChoices => 'Tidak ada pilihan yang cocok';

  @override
  String get projectStatsNoRecordsInGroup => 'Tidak ada catatan di grup ini.';

  @override
  String get projectStatsShow => 'Tampilkan';

  @override
  String projectStatsSpeciesCountsByCoordinates(String species) {
    return 'Jumlah $species menurut koordinat';
  }

  @override
  String get projectStatsMap => 'Peta';

  @override
  String projectStatsSpatialLoadError(String error) {
    return 'Tidak dapat memuat statistik spasial: $error';
  }

  @override
  String get projectStatsNoSpecimenCoords =>
      'Tidak ada spesimen yang ditetapkan ke koordinat proyek.';

  @override
  String get projectStatsNoSpeciesCoords =>
      'Tidak ada spesies yang terkait dengan koordinat proyek.';

  @override
  String get projectStatsNoFamilyCoords =>
      'Tidak ada famili yang terkait dengan koordinat proyek.';

  @override
  String get projectStatsNoSelectedSpeciesCoords =>
      'Tidak ada spesimen dari spesies terpilih yang ditetapkan ke koordinat proyek.';

  @override
  String projectStatsNoSpeciesCoordsFor(String species) {
    return 'Tidak ada spesimen $species yang ditetapkan ke koordinat proyek.';
  }

  @override
  String projectStatsCoordinateLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Koordinat',
    );
    return '$_temp0';
  }

  @override
  String projectStatsMeanPerCoordinate(String counted) {
    return 'Rata-rata $counted per koordinat';
  }

  @override
  String get projectStatsTopCoordinate => 'Koordinat teratas';

  @override
  String projectStatsTopValue(String name) {
    return 'Teratas: $name';
  }

  @override
  String projectStatsCategoryCount(int count, String category) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kategori ($category)',
    );
    return '$_temp0';
  }

  @override
  String projectStatsMeanPerCategory(String counted) {
    return 'Rata-rata $counted per kategori';
  }

  @override
  String get projectStatsTopCategory => 'Kategori teratas';

  @override
  String get projectStatsTopCategoryShare => 'Porsi kategori teratas';

  @override
  String projectStatsTotalCount(String value) {
    return 'Jumlah total: $value';
  }

  @override
  String get projectStatsElevation => 'Ketinggian';

  @override
  String get projectStatsSelectSpeciesPrompt =>
      'Pilih spesies untuk melihat kelimpahan per koordinat.';

  @override
  String get projectStatsCollapseLegend => 'Ciutkan legenda peta';

  @override
  String get projectStatsExpandLegend => 'Bentangkan legenda peta';

  @override
  String get projectStatsLegend => 'Legenda';

  @override
  String get projectStatsLegendCircle =>
      'Setiap lingkaran mewakili\nsatu koordinat';

  @override
  String get projectStatsLegendGrouped =>
      'Lokasi dikelompokkan,\nperbesar untuk memisahkan';

  @override
  String projectStatsUnmappedRecords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count catatan tercantum di tabel tetapi tidak dapat dipetakan karena lintang atau bujur kosong atau tidak valid.',
    );
    return '$_temp0';
  }

  @override
  String get projectStatsSpatialMap => 'Peta statistik spasial';

  @override
  String get projectStatsMapLayers => 'Lapisan peta';

  @override
  String get projectStatsViewFullScreen => 'Lihat peta layar penuh';

  @override
  String get projectStatsNaturalEarthError =>
      'Tidak dapat memuat peta luring Natural Earth.';

  @override
  String get projectStatsNoValidCoordinates =>
      'Tidak ada koordinat valid untuk dipetakan.';

  @override
  String projectStatsMapPrepareError(String error) {
    return 'Tidak dapat menyiapkan peta: $error';
  }

  @override
  String get projectStatsZoomIn => 'Perbesar';

  @override
  String get projectStatsZoomOut => 'Perkecil';

  @override
  String get projectStatsCenterMap => 'Pusatkan peta pada statistik';

  @override
  String projectStatsSiteCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lokasi',
    );
    return '$_temp0';
  }

  @override
  String get projectStatsExportTable => 'Ekspor tabel';

  @override
  String get projectStatsColumnName => 'Nama';

  @override
  String get projectStatsColumnLocality => 'Lokalitas';

  @override
  String get projectStatsColumnDecimalLatitude => 'Lintang desimal';

  @override
  String get projectStatsColumnDecimalLongitude => 'Bujur desimal';

  @override
  String get projectStatsColumnElevation => 'Ketinggian (m)';

  @override
  String get projectStatsColumnDatum => 'Datum';

  @override
  String get projectStatsColumnUncertainty => 'Ketidakpastian (m)';

  @override
  String get projectStatsColumnGpsUnit => 'Unit GPS';

  @override
  String get projectStatsColumnLatitude => 'Lintang';

  @override
  String get projectStatsColumnLongitude => 'Bujur';

  @override
  String get projectStatsColumnCount => 'Jumlah';

  @override
  String get projectStatsColumnPercent => 'Persen';

  @override
  String get projectStatsColumnCategory => 'Kategori';

  @override
  String get projectStatsViewRecords => 'Lihat catatan';

  @override
  String get projectStatsExportStatisticsTable => 'Ekspor tabel statistik';

  @override
  String get projectStatsExportSpatialTable => 'Ekspor tabel statistik spasial';

  @override
  String projectStatsExportError(String error) {
    return 'Tidak dapat mengekspor statistik: $error';
  }

  @override
  String get projectStatsExportComplete => 'Ekspor selesai';

  @override
  String projectStatsShareError(String error) {
    return 'Tidak dapat membagikan statistik: $error';
  }

  @override
  String get projectTissueMuseumPermanent => 'Koleksi tetap museum';

  @override
  String get projectTissueMuseumLoan => 'Pinjaman museum';

  @override
  String get projectTissueIdOrBarcode => 'ID jaringan atau kode batang';

  @override
  String get projectTissueFillRows => 'Baris, kiri ke kanan';

  @override
  String get projectTissueFillColumns => 'Kolom, atas ke bawah';

  @override
  String get projectTissueFillSerpentine => 'Baris berliku';

  @override
  String get projectTissueEntryScan => 'Pindai';

  @override
  String get projectTissueEntryWorkList => 'Daftar kerja';

  @override
  String get projectTissueTitle => 'Kurasi spesimen';

  @override
  String projectTissueFilledCount(int filled, int capacity) {
    return '$filled / $capacity terisi';
  }

  @override
  String get projectTissueNextCell => 'Sel berikutnya';

  @override
  String get projectTissueFull => 'Penuh';

  @override
  String get projectTissueNextBox => 'Kotak berikutnya';

  @override
  String get projectTissueFilled => 'Terisi';

  @override
  String get projectTissueNext => 'Berikutnya';

  @override
  String get projectTissueScanTubes => 'Pindai tabung';

  @override
  String get projectTissueCameraUnavailable =>
      'Pemindaian kamera tidak tersedia. Gunakan kolom pindai.';

  @override
  String get projectTissueCameraError =>
      'Tidak dapat menggunakan kamera. Coba lagi atau gunakan kolom pindai.';

  @override
  String get projectTissueSessionLog => 'Log sesi';

  @override
  String projectTissueSessionLogCount(int count) {
    return 'Log sesi ($count)';
  }

  @override
  String get projectTissueSessionLogEmpty =>
      'Tabung yang diperiksa muncul di sini.';

  @override
  String projectTissueSeveralMatches(String code) {
    return 'Beberapa bagian cocok dengan $code';
  }

  @override
  String projectTissueCount(String count) {
    return 'Jumlah $count';
  }

  @override
  String projectTissueAt(String location) {
    return 'Di $location';
  }

  @override
  String get projectTissueFindTubes => 'Cari tabung';

  @override
  String get projectTissueType => 'Jenis jaringan';

  @override
  String get projectTissuePreservation => 'Pengawetan';

  @override
  String get projectTissueUpdateField => 'Bidang yang diperbarui';

  @override
  String get projectTissueField => 'Bidang';

  @override
  String get projectTissueValue => 'Nilai';

  @override
  String get projectTissueMuseumCode => 'Kode museum';

  @override
  String get projectTissueBoxSize => 'Ukuran kotak';

  @override
  String get projectTissueNumbering => 'Penomoran';

  @override
  String get projectTissueFillOrder => 'Urutan pengisian';

  @override
  String get projectTissueBoxLabel => 'Label kotak';

  @override
  String get projectTissueBoxHint => 'Kotak';

  @override
  String get projectTissueBoxNumber => 'Nomor kotak';

  @override
  String get projectTissueOverwrite => 'Timpa nilai yang ada';

  @override
  String get projectTissueOverwriteBody =>
      'Ganti lokasi tersimpan atau nilai bidang yang berbeda';

  @override
  String get projectTissueTabBox => 'Kotak';

  @override
  String get projectTissueTabSetup => 'Pengaturan';

  @override
  String projectTissueTabLog(int count) {
    return 'Log ($count)';
  }

  @override
  String get projectTissueFindTubesBody =>
      'Tabung yang dicocokkan oleh pemindaian dan daftar kerja.';

  @override
  String get projectTissueUpdateFieldBody =>
      'Ditulis ke setiap tabung yang ditempatkan.';

  @override
  String get projectTissueBoxSectionBody =>
      'Ukuran, urutan pengisian, dan kotak yang sedang diisi.';

  @override
  String get projectTissueAdvanced => 'Label dan penimpaan';

  @override
  String get projectTissueAdvancedBody =>
      'Format label sel dan penanganan nilai yang tersimpan.';

  @override
  String get projectTissueExportLog => 'Ekspor log';

  @override
  String get projectTissueExportLogTitle => 'Ekspor log sesi';

  @override
  String projectTissueExportSummary(int checked, int skipped) {
    return '$checked diperiksa, $skipped dilewati';
  }

  @override
  String get projectTissueLogStatusChecked => 'Diperiksa';

  @override
  String get projectTissueLogStatusSkipped => 'Dilewati';

  @override
  String get projectTissuePart => 'Bagian';

  @override
  String get projectTissueColStatus => 'Status';

  @override
  String get projectTissueColOrder => 'Urutan';

  @override
  String get projectTissueColFieldId => 'ID lapangan';

  @override
  String get projectTissueColTubeId => 'ID tabung';

  @override
  String get projectTissueColKind => 'Jenis';

  @override
  String get projectTissueColType => 'Tipe';

  @override
  String get projectTissueColTreatment => 'Perlakuan';

  @override
  String get projectTissueColField => 'Kolom diperbarui';

  @override
  String get projectTissueColValue => 'Nilai';

  @override
  String get projectTissueColLocation => 'Lokasi';

  @override
  String get projectTissueColBox => 'Kotak';

  @override
  String get projectTissueColCell => 'Sel';

  @override
  String get projectTissueColPreviousValue => 'Nilai sebelumnya';

  @override
  String get projectTissueColPreviousLocation => 'Lokasi sebelumnya';

  @override
  String get projectTissueLogColumns => 'Kolom';

  @override
  String get projectTissueLogColumnsBody =>
      'Kolom kurasi selalu di depan. Tambahkan kolom bagian, spesimen, dan rekaman terkait setelahnya.';

  @override
  String get projectTissueLogAddColumns => 'Tambah kolom';

  @override
  String get projectTissueLogAddedColumns => 'Kolom tambahan';

  @override
  String get projectTissueLogNoAddedColumns =>
      'Tidak ada kolom tambahan. Ekspor hanya berisi kolom kurasi.';

  @override
  String get projectTissueLogHeaderStyle => 'Judul kolom tambahan';

  @override
  String get projectTissueLogHeaderFieldName => 'Nama kolom';

  @override
  String get projectTissueLogHeaderKey => 'Kunci NAHPU';

  @override
  String get projectTissueLogChooseColumns => 'Pilih kolom';

  @override
  String projectTissueLogRemoveColumn(String name) {
    return 'Hapus $name';
  }

  @override
  String projectTissueLogSelectedCount(int count) {
    return '$count dipilih';
  }

  @override
  String get projectTissueReplace => 'Ganti';

  @override
  String projectTissueReplaceTitle(String cell) {
    return 'Ganti $cell?';
  }

  @override
  String projectTissueReplaceMessage(int count, String cell, String labels) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Tabung berikutnya yang dipindai atau ditempatkan masuk ke $cell. $labels kehilangan lokasinya dan kembali ke daftar kerja. Urungkan untuk mengembalikannya.',
    );
    return '$_temp0';
  }

  @override
  String projectTissueReplacing(String labels) {
    return 'Mengganti $labels';
  }

  @override
  String projectTissueReplacedLog(String labels) {
    return 'Mengganti $labels';
  }

  @override
  String get projectTissueColReplaced => 'Diganti';

  @override
  String get projectTissueAny => 'Apa saja';

  @override
  String get projectTissueScanTube => 'Pindai tabung';

  @override
  String get projectTissueScanHint => 'Pindai atau ketik, lalu tekan Enter';

  @override
  String get projectTissueScanWithCamera => 'Pindai dengan kamera';

  @override
  String get projectTissueUndo => 'Urungkan';

  @override
  String get projectTissueReady => 'Siap. Pindai tabung pertama.';

  @override
  String get projectTissueSuggestionsLabel => 'Apakah maksud Anda';

  @override
  String get projectTissueWorkListEmpty =>
      'Tidak ada bagian yang belum ditempatkan yang cocok dengan filter jenis jaringan dan pengawetan.';

  @override
  String projectTissueRemaining(int count) {
    return 'Berikutnya · $count tersisa';
  }

  @override
  String get projectTissuePlace => 'Tempatkan';

  @override
  String get projectTissueIncludeParasites => 'Sertakan parasit';

  @override
  String get projectTissueWorkListSearch => 'Cari daftar kerja';

  @override
  String get projectTissueNoMatches => 'Tidak ada tabung yang cocok';

  @override
  String get projectTissueParasite => 'Parasit';

  @override
  String get projectTissueParasiteCategory => 'Kategori parasit';

  @override
  String get projectTissueIdParasiteIdOrBarcode =>
      'ID jaringan, ID parasit, atau kode batang';

  @override
  String get projectTissueFieldIdOrParasiteId => 'ID lapangan atau ID parasit';

  @override
  String get projectTissueSearchByFieldId => 'Cari berdasarkan ID lapangan';

  @override
  String projectTissueLogChecked(int count) {
    return 'Tercatat ($count)';
  }

  @override
  String projectTissueLogSkipped(int count) {
    return 'Dilewati ($count)';
  }

  @override
  String get projectTissueLogSkippedEmpty =>
      'Tabung yang dilewati muncul di sini sampai ditempatkan.';

  @override
  String get projectTissuePreviousBox => 'Kotak sebelumnya';

  @override
  String get projectTissueDetails => 'Detail';

  @override
  String get projectTissueOpenRecord => 'Buka catatan';

  @override
  String projectTissueSharedCell(int count) {
    return '$count tabung berbagi sel ini';
  }

  @override
  String get projectTissueBarcode => 'Kode batang';

  @override
  String get projectTissueStorageLocation => 'Lokasi penyimpanan';

  @override
  String get projectTissueCountLabel => 'Jumlah';

  @override
  String get projectTissueTapCellHint =>
      'Ketuk sel kosong untuk melompat, atau sel terisi untuk melihat tabungnya';

  @override
  String get parasiteRecords => 'Catatan parasit';

  @override
  String get parasiteUnidentified => 'Parasit tak teridentifikasi';

  @override
  String parasiteIndividuals(String ids) {
    return 'Ind: $ids';
  }

  @override
  String parasiteCount(String count) {
    return 'Jumlah: $count';
  }

  @override
  String get parasiteNoneAdded => 'Belum ada parasit';

  @override
  String get parasiteAdd => 'Tambah parasit';

  @override
  String get parasiteEdit => 'Sunting parasit';

  @override
  String get parasiteDetails => 'Detail parasit';

  @override
  String get parasiteCountLabel => 'Jumlah';

  @override
  String get parasiteCountHint => 'Masukkan jumlah parasit';

  @override
  String get parasiteCategory => 'Kategori';

  @override
  String get parasiteAnatomicalLocation => 'Lokasi anatomi';

  @override
  String get parasiteCollectionIdentification => 'Koleksi & identifikasi';

  @override
  String get parasiteCollector => 'Kolektor';

  @override
  String get parasiteCollectorHint => 'Pilih siapa yang mengoleksi parasit';

  @override
  String get parasiteDetectionMethod => 'Metode deteksi';

  @override
  String get parasiteDateCollected => 'Tanggal koleksi';

  @override
  String get parasiteDateCollectedHint => 'Masukkan tanggal koleksi';

  @override
  String get parasiteTimeCollected => 'Waktu koleksi';

  @override
  String get parasiteTimeCollectedHint => 'Masukkan waktu koleksi';

  @override
  String get parasiteDeterminer => 'Pengidentifikasi';

  @override
  String get parasiteDeterminerHint =>
      'Pilih siapa yang mengidentifikasi parasit';

  @override
  String get parasiteDateDetermined => 'Tanggal identifikasi';

  @override
  String get parasiteDateDeterminedHint => 'Masukkan tanggal identifikasi';

  @override
  String get parasiteDeterminationMethod => 'Metode identifikasi';

  @override
  String parasiteSaveError(String error) {
    return 'Tidak dapat menyimpan parasit: $error';
  }

  @override
  String get parasiteTaxon => 'Takson parasit';

  @override
  String get parasiteTaxonHint => 'Pilih takson terdaftar';

  @override
  String get parasiteNotIdentified => 'Belum diidentifikasi';

  @override
  String parasiteTaxaLoadError(String error) {
    return 'Tidak dapat memuat takson: $error';
  }

  @override
  String get parasiteAddTaxon => 'Tambah takson';

  @override
  String get parasiteNotAssigned => 'Belum ditetapkan';

  @override
  String get parasitePreparationPreservation => 'Preparasi & pengawetan';

  @override
  String get parasitePreparationMethod => 'Metode preparasi';

  @override
  String get parasiteTreatment => 'Perlakuan';

  @override
  String get parasiteDatePreserved => 'Tanggal pengawetan';

  @override
  String get parasiteDatePreservedHint => 'Masukkan tanggal pengawetan';

  @override
  String get parasiteTimePreserved => 'Waktu pengawetan';

  @override
  String get parasiteTimePreservedHint => 'Masukkan waktu pengawetan';

  @override
  String get parasiteCuration => 'Kurasi';

  @override
  String get parasiteStorage => 'Penyimpanan';

  @override
  String get parasiteStorageLocation => 'Lokasi penyimpanan';

  @override
  String get parasiteStorageLocationHint =>
      'Masukkan freezer, lemari, rak, atau wadah';

  @override
  String get parasiteMuseumPermanent => 'Koleksi tetap museum';

  @override
  String get parasiteMuseumHint => 'Masukkan nama atau singkatan museum';

  @override
  String get parasiteMuseumLoan => 'Pinjaman museum';

  @override
  String get parasiteRemarks => 'Catatan';

  @override
  String get parasiteRemarksHint => 'Masukkan catatan parasit';

  @override
  String get parasiteLifeStage => 'Tahap hidup';

  @override
  String get parasiteLifeStageHint => 'Pilih tahap hidup parasit';

  @override
  String get parasiteAssociationStatus => 'Status asosiasi';

  @override
  String get parasiteAssociationStatusHint => 'Pilih status asosiasi';

  @override
  String parasiteFieldLoadError(String field, String error) {
    return 'Tidak dapat memuat $field: $error';
  }

  @override
  String get parasiteSetOptionsInSettings => 'Atur opsi di pengaturan spesimen';

  @override
  String parasiteSelectField(String field) {
    return 'Pilih $field';
  }

  @override
  String get parasiteIds => 'ID';

  @override
  String parasiteUuid(String uuid) {
    return 'UUID: $uuid';
  }

  @override
  String get parasiteId => 'ID parasit';

  @override
  String get parasiteIdHint => 'Masukkan ID parasit buatan pengguna';

  @override
  String get parasiteIdOptions => 'Opsi ID parasit';

  @override
  String get parasiteScanCode => 'Pindai QR/kode batang';

  @override
  String get parasiteNewNumber => 'Nomor baru';

  @override
  String get parasiteSettings => 'Pengaturan';

  @override
  String get parasiteIdSettings => 'Pengaturan ID parasit';

  @override
  String get parasitePrefix => 'Prefiks';

  @override
  String get parasitePrefixHint => 'Masukkan prefiks ID parasit';

  @override
  String get parasiteNumber => 'Nomor';

  @override
  String get parasiteNumberHint => 'Masukkan nomor ID parasit berikutnya';

  @override
  String get specimenShowOutlierWarnings => 'Tampilkan peringatan pencilan';

  @override
  String get mammalTotalLength => 'Panjang total (mm)';

  @override
  String get mammalTotalLengthHint => 'Masukkan PT';

  @override
  String get mammalTailLength => 'Panjang ekor (mm)';

  @override
  String get mammalTailLengthHint => 'Masukkan PE';

  @override
  String get specimenAutoCalculated => 'Dihitung otomatis';

  @override
  String get mammalHeadBodyLength => 'Panjang kepala dan badan (mm)';

  @override
  String get mammalHeadBodyLengthHint => 'Masukkan PKB';

  @override
  String get mammalTailHeadBodyRatio => 'Panjang ekor/KB';

  @override
  String get mammalTailHeadBodyRatioHint => 'Masukkan PE/PKB';

  @override
  String get mammalHindFootLength => 'Panjang kaki belakang (mm)';

  @override
  String get mammalHindFootLengthHint => 'Masukkan panjang KB';

  @override
  String get mammalEarLength => 'Panjang telinga (mm)';

  @override
  String get mammalEarLengthHint => 'Masukkan panjang telinga';

  @override
  String get mammalShowBatFields => 'Tampilkan bidang kelelawar';

  @override
  String get specimenRemarks => 'Catatan';

  @override
  String get specimenMeasurementRemarksHint =>
      'Tulis catatan tentang pengukuran (opsional)';

  @override
  String get specimenUnusualMeasurement => 'Pengukuran tidak biasa';

  @override
  String get mammalChangeSexTitle => 'Ubah jenis kelamin?';

  @override
  String get mammalChangeSexBody =>
      'Mengubah jenis kelamin akan menghapus data reproduksi yang tidak berlaku untuk pilihan baru.';

  @override
  String get specimenAccuracy => 'Akurasi';

  @override
  String get specimenAccuracyHint => 'Pilih akurasi pengukuran';

  @override
  String get specimenNoInaccurateSelected =>
      'Tidak ada pengukuran tidak akurat yang dipilih';

  @override
  String specimenInaccurateList(String labels) {
    return '*Tidak akurat: $labels';
  }

  @override
  String specimenAccuracyRemarkValue(String remark) {
    return 'Catatan:\n$remark';
  }

  @override
  String get specimenSelectInaccurate => 'Pilih pengukuran tidak akurat';

  @override
  String get specimenInaccurateMeasurements => 'Pengukuran tidak akurat';

  @override
  String get specimenSelectEveryInaccurate =>
      'Pilih setiap pengukuran yang tidak akurat.';

  @override
  String get specimenSelectAtLeastOneInaccurate =>
      'Pilih setidaknya satu pengukuran tidak akurat.';

  @override
  String get specimenAccuracyRemark => 'Catatan akurasi';

  @override
  String get specimenAccuracyRemarkHint =>
      'Jelaskan mengapa pengukuran tidak akurat';

  @override
  String get mammalTestes => 'Testis';

  @override
  String get mammalTestisPosition => 'Posisi';

  @override
  String get mammalTestisPositionHint => 'Pilih posisi testis';

  @override
  String get specimenLengthMm => 'Panjang (mm)';

  @override
  String get mammalTestisLengthHint => 'Masukkan panjang testis kanan';

  @override
  String get specimenWidthMm => 'Lebar (mm)';

  @override
  String get mammalTestisWidthHint => 'Masukkan lebar testis kanan';

  @override
  String get mammalEpididymis => 'Epididimis';

  @override
  String get mammalEpididymisHint => 'Pilih tampilan epididimis';

  @override
  String get mammalVaginaOpening => 'Bukaan vagina';

  @override
  String get mammalVaginaOpeningHint => 'Pilih bukaan vagina';

  @override
  String get mammalPubicSymphysis => 'Simfisis pubis';

  @override
  String get mammalPubicSymphysisHint => 'Pilih kondisi simfisis pubis';

  @override
  String get mammalFemaleReproductive => 'Atribut reproduksi betina';

  @override
  String get mammalReproductiveStage => 'Tahap reproduksi';

  @override
  String get mammalReproductiveStageHint => 'Pilih tahap reproduksi';

  @override
  String get mammalMammaeCounts => 'Jumlah mamae (pasang)';

  @override
  String get mammalMammaeCondition => 'Kondisi mamae';

  @override
  String get mammalMammaeConditionHint => 'Pilih kondisi mamae';

  @override
  String get mammalEmbryo => 'Embrio';

  @override
  String get mammalCrownRumpLength => 'Panjang CR (mm)';

  @override
  String get mammalCrownRumpLengthHint => 'Masukkan panjang mahkota-pantat';

  @override
  String get mammalPlacentalScars => 'Bekas luka plasenta';

  @override
  String get mammalAxillary => 'Aksila';

  @override
  String get mammalAxillaryHint => 'Masukkan jumlah pasang aksila';

  @override
  String get mammalAbdominal => 'Abdomen';

  @override
  String get mammalAbdominalHint => 'Masukkan jumlah pasang abdomen';

  @override
  String get mammalInguinal => 'Inguinal';

  @override
  String get mammalInguinalHint => 'Masukkan jumlah pasang inguinal';

  @override
  String get specimenLeft => 'Kiri';

  @override
  String get specimenRight => 'Kanan';

  @override
  String get mammalForearmLength => 'Panjang lengan bawah (mm)';

  @override
  String get mammalForearmLengthHint => 'Masukkan panjang LB';

  @override
  String get mammalTibiaLength => 'Panjang tibia (mm)';

  @override
  String get mammalTibiaLengthHint => 'Masukkan panjang tibia';

  @override
  String get mammalEcholocate => 'Berekolokasi?';

  @override
  String get mammalEcholocation => 'Ekolokasi';

  @override
  String get mammalEcholocationHint => 'Pilih jenis ekolokasi';

  @override
  String get mammalFrequencyMax => 'Frekuensi maksimum (kHz)';

  @override
  String get mammalFrequencyMaxHint => 'Masukkan frekuensi ekolokasi maksimum';

  @override
  String get mammalFrequencyMin => 'Frekuensi minimum (kHz)';

  @override
  String get mammalFrequencyMinHint => 'Masukkan frekuensi ekolokasi minimum';

  @override
  String get mammalFrequencyMaxEnergy => 'Frekuensi pada energi maksimum (kHz)';

  @override
  String get mammalFrequencyMaxEnergyHint =>
      'Masukkan frekuensi ekolokasi pada energi maksimum';

  @override
  String get mammalEcholocationDuration => 'Durasi (detik)';

  @override
  String get mammalEcholocationDurationHint => 'Masukkan durasi ekolokasi';

  @override
  String get birdWingspan => 'Rentang sayap (mm)';

  @override
  String get birdWingspanHint => 'Masukkan rentang sayap';

  @override
  String get birdBillColor => 'Warna paruh';

  @override
  String get birdBillColorHint => 'Masukkan warna paruh';

  @override
  String get birdMaxillaColor => 'Warna maksila';

  @override
  String get birdMaxillaColorHint => 'Masukkan warna maksila';

  @override
  String get birdMandibleColor => 'Warna mandibula';

  @override
  String get birdMandibleColorHint => 'Masukkan warna mandibula';

  @override
  String get birdIrisColor => 'Warna iris';

  @override
  String get birdIrisColorHint => 'Masukkan warna iris';

  @override
  String get birdTarsusColor => 'Warna tarsus';

  @override
  String get birdTarsusColorHint => 'Masukkan warna tarsus';

  @override
  String get birdToeColor => 'Warna jari kaki';

  @override
  String get birdToeColorHint => 'Masukkan warna jari kaki';

  @override
  String get birdBroodPatch => 'Bercak eram';

  @override
  String get birdBursaPresent => 'Bursa ada';

  @override
  String get birdStomachContents => 'Isi lambung';

  @override
  String get birdStomachContentsHint => 'Masukkan isi lambung';

  @override
  String get birdBursaLength => 'Panjang bursa (mm)';

  @override
  String get birdBursaLengthHint => 'Masukkan panjang bursa';

  @override
  String get birdBursaWidth => 'Lebar bursa (mm)';

  @override
  String get birdBursaWidthHint => 'Masukkan lebar bursa';

  @override
  String get birdMaleGonads => 'Gonad jantan';

  @override
  String get birdLeftTestisSize => 'Ukuran testis kiri (mm)';

  @override
  String get birdSize => 'Ukuran';

  @override
  String get birdMinute => 'sangat kecil';

  @override
  String get birdOneMmOrGreater => '1 mm atau lebih';

  @override
  String get birdLength => 'Panjang';

  @override
  String get specimenEnterLength => 'Masukkan panjang';

  @override
  String get birdWidth => 'Lebar';

  @override
  String get specimenEnterWidth => 'Masukkan lebar';

  @override
  String get birdTestisRemarksHint =>
      'Masukkan catatan, mis. ukuran testis kanan';

  @override
  String get birdFemaleGonads => 'Gonad betina';

  @override
  String get birdOvarySize => 'Ukuran ovarium';

  @override
  String get birdAppearance => 'Tampilan';

  @override
  String get birdOviduct => 'Oviduk';

  @override
  String get birdGonadRemarksHint =>
      'Tambahkan informasi tambahan tentang gonad';

  @override
  String get birdSkullOssification => 'Osifikasi tengkorak (%)';

  @override
  String get birdSkullOssificationHint => 'Masukkan persentase';

  @override
  String get birdFat => 'Lemak';

  @override
  String get birdLargestOva => 'Diameter tiga ovum terbesar (mm)';

  @override
  String get birdFirst => 'Pertama';

  @override
  String get birdEnterSize => 'Masukkan ukuran';

  @override
  String get birdSecond => 'Kedua';

  @override
  String get birdThird => 'Ketiga';

  @override
  String get birdMolt => 'Molting';

  @override
  String get birdWingMolt => 'Molting sayap';

  @override
  String get birdTailMolt => 'Molting ekor';

  @override
  String get birdMoltRemarksHint => 'Tambahkan informasi molting tambahan';

  @override
  String get birdWingMoltHint => 'Masukkan molting sayap';

  @override
  String get birdTailMoltHint => 'Masukkan molting ekor';

  @override
  String get birdBodyMolt => 'Molting tubuh';

  @override
  String get specimenNotes => 'Catatan';

  @override
  String get birdHabitat => 'Habitat';

  @override
  String get birdHabitatHint => 'Tambahkan informasi tambahan tentang habitat';

  @override
  String get specimenSpecimen => 'Spesimen';

  @override
  String get specimenRemarksHint =>
      'Tambahkan informasi tambahan tentang spesimen';

  @override
  String get fishStandardLength => 'Panjang standar (mm)';

  @override
  String get fishStandardLengthHint => 'Masukkan panjang standar';

  @override
  String get fishTotalLengthHint => 'Masukkan panjang total';

  @override
  String get fishTotalIndividuals => 'Total individu';

  @override
  String get fishTotalIndividualsHint => 'Masukkan jumlah individu dalam lot';

  @override
  String get fishAutoUpdateRanges => 'Perbarui min dan maks otomatis';

  @override
  String get fishAutoUpdateRangesBody =>
      'Isi rentang dari individu yang diukur di bawah';

  @override
  String get fishMinStandardLength => 'Panjang standar min. (mm)';

  @override
  String get fishMinStandardLengthHint => 'Masukkan panjang standar minimum';

  @override
  String get fishMaxStandardLength => 'Panjang standar maks. (mm)';

  @override
  String get fishMaxStandardLengthHint => 'Masukkan panjang standar maksimum';

  @override
  String get fishMinTotalLength => 'Panjang total min. (mm)';

  @override
  String get fishMinTotalLengthHint => 'Masukkan panjang total minimum';

  @override
  String get fishMaxTotalLength => 'Panjang total maks. (mm)';

  @override
  String get fishMaxTotalLengthHint => 'Masukkan panjang total maksimum';

  @override
  String get fishMinWeight => 'Berat min.';

  @override
  String get fishMinWeightHint => 'Masukkan berat minimum';

  @override
  String get fishMaxWeight => 'Berat maks.';

  @override
  String get fishMaxWeightHint => 'Masukkan berat maksimum';

  @override
  String get fishSpecimenType => 'Jenis spesimen';

  @override
  String get fishTypeIndividual => 'Individu';

  @override
  String get fishTypeLot => 'Lot';

  @override
  String get fishTypeIndividualDescription =>
      'Satu ikan dengan pengukurannya sendiri';

  @override
  String get fishTypeLotDescription => 'Banyak individu disimpan bersama';

  @override
  String get invertCaste => 'Kasta';

  @override
  String get invertCasteHint => 'Pilih kasta';

  @override
  String get invertEcologicalInteractions => 'Interaksi ekologis';

  @override
  String get invertShowMorphometrics => 'Tampilkan morfometri spesimen';

  @override
  String get invertMorphometrics => 'Morfometri spesimen';

  @override
  String get invertHostOrganism => 'Organisme inang';

  @override
  String get invertHostOrganismHint => 'Masukkan takson inang terkait';

  @override
  String get invertHostPart => 'Bagian inang';

  @override
  String get invertHostPartHint => 'Masukkan bagian inang yang ditempati';

  @override
  String get invertHeadWidth => 'Lebar kepala (mm)';

  @override
  String get invertHeadWidthHint => 'Masukkan lebar kepala';

  @override
  String get invertBodyLength => 'Panjang tubuh (mm)';

  @override
  String get invertBodyLengthHint => 'Masukkan panjang tubuh';

  @override
  String get invertUpperWingspan => 'Rentang sayap atas (mm)';

  @override
  String get invertUpperWingspanHint => 'Masukkan rentang sayap atas';

  @override
  String get invertLowerWingspan => 'Rentang sayap bawah (mm)';

  @override
  String get invertLowerWingspanHint => 'Masukkan rentang sayap bawah';

  @override
  String get herpSnoutVentLength => 'PMK (cm)';

  @override
  String get herpSnoutVentLengthHint => 'Masukkan panjang moncong-kloaka';

  @override
  String get partSpecimenParts => 'Bagian spesimen';

  @override
  String get partAdd => 'Tambah bagian spesimen';

  @override
  String get partNoneAdded => 'Belum ada bagian';

  @override
  String get partUnknown => 'Bagian tidak diketahui';

  @override
  String get partNoCount => 'Tanpa jumlah';

  @override
  String get partNoTreatment => 'Tidak ada';

  @override
  String get partHasRemark => 'ada catatan';

  @override
  String partPmi(String pmi) {
    return 'PMI $pmi';
  }

  @override
  String get partAddParts => 'Tambah bagian spesimen';

  @override
  String get partEditParts => 'Sunting bagian spesimen';

  @override
  String get partPreparation => 'Preparasi';

  @override
  String get partSampling => 'Pengambilan sampel';

  @override
  String partSaveError(String error) {
    return 'Tidak dapat menyimpan bagian spesimen: $error';
  }

  @override
  String get partCounts => 'Jumlah';

  @override
  String get partCountsHint => 'Masukkan jumlah bagian';

  @override
  String get partPreparationType => 'Jenis preparasi';

  @override
  String get partPreparationTypeHint => 'Masukkan jenis preparasi';

  @override
  String get partTreatmentHint => 'Masukkan perlakuan';

  @override
  String get partAdditionalTreatment => 'Perlakuan tambahan';

  @override
  String get partAdditionalTreatmentHint => 'Masukkan perlakuan tambahan';

  @override
  String get partPreparatorHint => 'Jika berbeda dari preparator voucer';

  @override
  String get partDateTaken => 'Tanggal pengambilan';

  @override
  String get partTimeTaken => 'Waktu pengambilan';

  @override
  String get partRecommendedFresh => 'Disarankan untuk jaringan segar';

  @override
  String get partStorageType => 'Jenis penyimpanan';

  @override
  String get partStorageTypeHint => 'Masukkan jenis penyimpanan';

  @override
  String get partStorageLocationHint =>
      'Dapat berupa ID sel atau toples, sesuai konvensi museum Anda';

  @override
  String get partMuseumHint => 'Masukkan nama atau singkatan museum';

  @override
  String get partRemarksHint => 'Masukkan catatan khusus untuk bagian ini';

  @override
  String get partBarcodeId => 'ID QR/kode batang';

  @override
  String get partBarcodeIdHint => 'Masukkan ID kode batang (jika ada)';

  @override
  String get partBarcodeIdOptions => 'Opsi ID QR/kode batang';

  @override
  String get partGenerateUuid => 'Buat UUID';

  @override
  String get partInvalidBarcode => 'QR/kode batang tidak valid';

  @override
  String get partBarcodeIdExists =>
      'ID QR/kode batang sudah ada. Kosongkan kolom untuk membuat UUID baru';

  @override
  String get partTissueIdHint => 'Masukkan ID jaringan';

  @override
  String get partRepeatTissueFailed => 'Gagal mengulang nomor jaringan';

  @override
  String get partTissueIdOptions => 'Opsi ID jaringan';

  @override
  String get partTissueIdSettings => 'Pengaturan ID jaringan';

  @override
  String get specimenCollectionIdentification => 'Koleksi & identifikasi';

  @override
  String get specimenTaxaLoadError => 'Galat saat memuat takson';

  @override
  String get specimenIdConfidence => 'Keyakinan identifikasi';

  @override
  String get specimenIdConfidenceHint => 'Pilih tingkat keyakinan';

  @override
  String get specimenDeterminerHint =>
      'Pilih pengidentifikasi (bawaan: katalogis)';

  @override
  String get specimenIdMethod => 'Metode identifikasi';

  @override
  String get specimenIdMethodHint => 'Pilih metode identifikasi';

  @override
  String get specimenCollectionDate => 'Tanggal koleksi';

  @override
  String get specimenCollectionTime => 'Waktu koleksi';

  @override
  String get specimenConditionHint => 'Pilih kondisi';

  @override
  String get specimenPrepDate => 'Tanggal prep.';

  @override
  String get specimenPrepTime => 'Waktu prep.';

  @override
  String get specimenPreparatorHint => 'Pilih preparator (bawaan: katalogis)';

  @override
  String specimenUuid(String uuid) {
    return 'UUID spesimen: $uuid';
  }

  @override
  String get specimenMuseumId => 'ID museum';

  @override
  String get specimenMuseumIdHint => 'Masukkan ID museum (jika ada)';

  @override
  String specimenFieldIdValue(String id) {
    return 'ID lapangan: $id';
  }

  @override
  String get specimenFieldIdLoading => 'ID lapangan: memuat…';

  @override
  String get specimenFieldIdUnavailable => 'ID lapangan: tidak tersedia';

  @override
  String get specimenFieldIdSelectCataloger => 'ID lapangan: pilih katalogis';

  @override
  String get specimenFieldIdCatalogerNotSetUp =>
      'ID lapangan: katalogis belum diatur untuk nomor lapangan';

  @override
  String get specimenEditFieldId => 'Sunting ID lapangan';

  @override
  String get specimenFieldIdPersonnel => 'Personel';

  @override
  String get specimenFieldIdProject => 'Proyek';

  @override
  String get specimenFieldIdPersonnelUnavailable =>
      'Pilih katalogis dengan pendaftaran nomor lapangan pribadi aktif sebelum menetapkan ID lapangan personel.';

  @override
  String get specimenPersonnelFieldNumber => 'Nomor lapangan personel';

  @override
  String get specimenProjectCatalogNumber => 'Nomor katalog proyek';

  @override
  String get specimenFieldIdTypeChangeAck =>
      'Saya memahami bahwa mengubah jenis pengenal akan menghapus ID lapangan spesimen sebelumnya dan ID tersebut mungkin sudah muncul di ekspor atau label spesimen.';

  @override
  String get specimenSaving => 'Menyimpan…';

  @override
  String get fishStandardLengthShort => 'Panjang standar';

  @override
  String get fishTotalLengthShort => 'Panjang total';

  @override
  String get fishWeight => 'Berat';

  @override
  String get fishLotSummary => 'Ringkasan lot';

  @override
  String fishMeasuredCount(int count) {
    return '$count diukur';
  }

  @override
  String fishMeasuredOfTotal(int count, int total) {
    return '$count dari $total individu diukur';
  }

  @override
  String get fishNotMeasured => 'Belum diukur';

  @override
  String fishStandardDeviation(String value) {
    return '± $value SD';
  }

  @override
  String fishRange(String min, String max, String unit) {
    return 'Rentang $min–$max $unit';
  }

  @override
  String get fishIndividuals => 'Individu';

  @override
  String fishIndividualsLoadError(String error) {
    return 'Tidak dapat memuat individu: $error';
  }

  @override
  String get fishAddIndividual => 'Tambah individu';

  @override
  String get fishDeleteIndividual => 'Hapus individu';

  @override
  String fishStandardLengthValue(String value) {
    return 'PS $value mm';
  }

  @override
  String fishTotalLengthValue(String value) {
    return 'PT $value mm';
  }

  @override
  String get fishNoMeasurements => 'Tidak ada pengukuran';

  @override
  String fishDeleteIndividualTitle(String name) {
    return 'Hapus $name?';
  }

  @override
  String get fishDeleteIndividualBody =>
      'Ini menghapus individu dan melepaskan tautannya dari semua bagian spesimen dan parasit.';

  @override
  String get fishStandardLengthMm => 'PS (mm)';

  @override
  String get fishTotalLengthMm => 'PT (mm)';

  @override
  String fishWeightWithUnit(String unit) {
    return 'Berat ($unit)';
  }

  @override
  String get fishEnterWeight => 'Masukkan berat';

  @override
  String get fishIndividualRemarksHint =>
      'Tambahkan catatan tentang individu ini';

  @override
  String get fishEditIndividual => 'Sunting individu';

  @override
  String fishEnteredCount(int count) {
    return '$count dimasukkan';
  }

  @override
  String fishEnteredOfTotal(int count, int total) {
    return '$count dari $total dimasukkan';
  }

  @override
  String get fishSaveAndAddAnother => 'Simpan dan tambah lagi';

  @override
  String get fishMeasurements => 'Pengukuran';

  @override
  String get fishTagId => 'ID tag';

  @override
  String get fishTagIdHint => 'Masukkan ID individu atau tag';

  @override
  String get fishAutoNumbered => 'Bernomor otomatis. Sunting untuk mengganti.';

  @override
  String get fishTagIdOptions => 'Opsi ID tag';

  @override
  String get fishTagIdSettings => 'Pengaturan ID tag';

  @override
  String get specimenCaptureRecords => 'Catatan penangkapan';

  @override
  String get specimenChooseSite => 'Pilih situs';

  @override
  String get specimenChangeSiteTitle => 'Ubah situs?';

  @override
  String get specimenChangeSiteBody =>
      'Kecuali tanggal dan waktu penangkapan, semua kolom di bagian catatan koleksi akan kosong kembali.';

  @override
  String get specimenChooseEvent => 'Pilih ID kegiatan koleksi';

  @override
  String get specimenChangeEventTitle => 'Ubah ID kegiatan koleksi?';

  @override
  String get specimenChangeEventBody =>
      'Kecuali tanggal dan waktu penangkapan, semua kolom di bagian catatan koleksi akan kosong kembali. Koordinat tetap disimpan jika berada di situs yang sama.';

  @override
  String get specimenChooseMethod => 'Pilih jenis metode';

  @override
  String get specimenRelativeTime => 'Waktu relatif';

  @override
  String get specimenMethodId => 'ID metode';

  @override
  String get specimenMethodIdHint =>
      'Masukkan ID, mis. nomor perangkap/jaring, dll.';

  @override
  String get specimenCaptureDate => 'Tanggal penangkapan';

  @override
  String get specimenCoordinateId => 'ID koordinat';

  @override
  String get specimenChooseCoordinate => 'Pilih koordinat';

  @override
  String get specimenCoordinateExtent => 'Cakupan koordinat (m)';

  @override
  String get specimenCoordinateExtentHint => 'Tambahkan cakupan koordinat';

  @override
  String get specimenExtentInvalid =>
      'Cakupan harus berupa angka lebih dari nol';

  @override
  String get specimenCaptureTime => 'Waktu penangkapan';

  @override
  String get specimenChoosePerson => 'Pilih orang';

  @override
  String get specimenSexHint => 'Pilih jenis kelamin spesimen';

  @override
  String get specimenLifeStageHint => 'Pilih tahap hidup';

  @override
  String specimenLifeStagesLoadError(String error) {
    return 'Tidak dapat memuat tahap hidup: $error';
  }

  @override
  String specimenParasiteDetectionLoadError(String error) {
    return 'Tidak dapat memuat deteksi parasit: $error';
  }

  @override
  String get specimenParasitesExamined => 'Parasit diperiksa';

  @override
  String get specimenParasitesDetected => 'Parasit terdeteksi';

  @override
  String get specimenDetectionRemarks => 'Catatan deteksi';

  @override
  String get specimenDetectionRemarksHint =>
      'Masukkan catatan pemeriksaan atau deteksi parasit';

  @override
  String get specimenCreate => 'Buat spesimen';

  @override
  String get specimenActions => 'Tindakan spesimen';

  @override
  String get specimenDuplicatePart => 'Duplikat bagian';

  @override
  String get specimenExport => 'Ekspor spesimen';

  @override
  String get specimenImport => 'Impor spesimen';

  @override
  String specimenDuplicatePartError(String error) {
    return 'Galat saat menduplikasi bagian: $error';
  }

  @override
  String get specimenDeleteTitle => 'Hapus spesimen?';

  @override
  String get specimenDeleteBody =>
      'Anda akan menghapus catatan spesimen ini, semua pengukuran, dan bagian spesimen.\nAnda perlu memperbarui nomor lapangan secara manual.';

  @override
  String specimenDeleteError(String error) {
    return 'Galat saat menghapus spesimen: $error';
  }

  @override
  String get specimenDeleteAllTitle => 'Hapus semua spesimen?';

  @override
  String get specimenDeleteAllBody =>
      'Ini akan menghapus semua catatan spesimen, pengukuran, dan bagian spesimen';

  @override
  String specimenDeleteAllError(String error) {
    return 'Galat saat menghapus semua spesimen: $error';
  }

  @override
  String get specimenTaxonInfo => 'Info takson';

  @override
  String get specimenNoSpeciesSelected => 'Belum ada spesies yang dipilih';

  @override
  String get specimenTaxonTooltip => 'Ketik nama takson dan pilih dari daftar';

  @override
  String get specimenTaxon => 'Takson';

  @override
  String get specimenTaxonHint => 'Ketik nama takson';

  @override
  String get specimenEnterTaxon => 'Masukkan takson';

  @override
  String get specimenNoneSelected => 'Tidak ada yang dipilih';

  @override
  String specimenRemoveIndividualTooltip(String name) {
    return 'Hapus $name';
  }

  @override
  String get specimenAllIndividualsAdded => 'Semua individu telah ditambahkan';

  @override
  String get specimenSelectIndividual => 'Pilih individu';

  @override
  String specimenRemoveIndividualTitle(String name) {
    return 'Hapus $name?';
  }

  @override
  String specimenRemoveIndividualBody(String name) {
    return 'Catatan ini tidak akan lagi ditautkan ke individu $name. Individunya tetap disimpan.';
  }

  @override
  String get specimenRecordsTitle => 'Catatan spesimen';

  @override
  String get specimenSearchOptions => 'Opsi pencarian';

  @override
  String get specimenRecordTitle => 'Catatan spesimen';

  @override
  String get specimenNoneFound => 'Spesimen tidak ditemukan';

  @override
  String get specimenWeightHint => 'Masukkan berat spesimen';

  @override
  String get specimenChangeWeightUnit => 'Ubah satuan berat';

  @override
  String get templateDeleteTextBox => 'Hapus kotak teks';

  @override
  String get templateHeightMm => 'Tinggi (mm)';

  @override
  String get templatePictureTypeOptions => 'Opsi jenis gambar';

  @override
  String get templateRotation => 'Rotasi';

  @override
  String get templateQrCode => 'Kode QR';

  @override
  String get templateQrSize => 'Ukuran QR (mm)';

  @override
  String get templateContentFormattingOptions => 'Opsi format konten';

  @override
  String get templateShape => 'Bentuk';

  @override
  String get templateSquare => 'Persegi';

  @override
  String get templateCircle => 'Lingkaran';

  @override
  String get templateDynamic => 'Dinamis';

  @override
  String get templateSizePt => 'Ukuran (pt)';

  @override
  String get templateDecreaseFontSize => 'Perkecil ukuran huruf';

  @override
  String get templateIncreaseFontSize => 'Perbesar ukuran huruf';

  @override
  String get templateTextFormattingOptions => 'Opsi format teks';

  @override
  String get templateTextStylingOptions => 'Opsi gaya teks';

  @override
  String get templateMaxWidth => 'Lebar maksimum (mm)';

  @override
  String get templateMaxHeight => 'Tinggi maksimum (mm)';

  @override
  String get templateFont => 'Huruf';

  @override
  String templateFontNotInstalled(String font) {
    return '$font (tidak terpasang)';
  }

  @override
  String get templateUnderline => 'Garis bawah';

  @override
  String get templateStrikethrough => 'Coret';

  @override
  String get templateForeground => 'Latar depan';

  @override
  String get templateQrForegroundColor => 'Pilih warna latar depan QR';

  @override
  String get templateBackground => 'Latar belakang';

  @override
  String get templateQrBackgroundColor => 'Pilih warna latar belakang QR';

  @override
  String get templateConditionalOutput => 'Keluaran bersyarat';

  @override
  String get templateFormat => 'Format';

  @override
  String get templateMapEncodedValues => 'Petakan nilai terkode';

  @override
  String get templateHeaderCase => 'Kapitalisasi judul';

  @override
  String get templateUppercase => 'Huruf besar';

  @override
  String get templateLowercase => 'Huruf kecil';

  @override
  String get templateMissing => 'Kosong';

  @override
  String get templateTextColor => 'Pilih warna teks';

  @override
  String get templateTextBackgroundColor => 'Pilih warna latar belakang teks';

  @override
  String get templateStroke => 'Garis tepi';

  @override
  String get templateTextStrokeColor => 'Pilih warna garis tepi teks';

  @override
  String get templateStyle => 'Gaya';

  @override
  String get templateRadius => 'Radius';

  @override
  String get templatePadding => 'Bantalan';

  @override
  String get templateAlignLeft => 'Rata kiri';

  @override
  String get templateAlignCenter => 'Rata tengah';

  @override
  String get templateAlignRight => 'Rata kanan';

  @override
  String templateClearColor(String label) {
    return 'Hapus $label';
  }

  @override
  String get templateNoContentPlaceholder => 'Pengganti tanpa konten';

  @override
  String get templateCustomText => 'Teks khusus';

  @override
  String get templateCustomTextHint => 'Masukkan teks pengganti khusus';

  @override
  String get templateConditionalType => 'Jenis bersyarat';

  @override
  String get templateTargetField => 'Bidang target';

  @override
  String get templateConditionalTextHelper =>
      'Bidang seperti [mammalAttribute::testisWidth] akan diisi.';

  @override
  String get templateReplacementHelper =>
      'Ditulis jika cocok; jika tidak, nilai target asli dipertahankan. Biarkan kosong untuk menyembunyikan nilai.';

  @override
  String get templateTypeNormalText => 'Teks biasa';

  @override
  String get templateTypePicture => 'Gambar';

  @override
  String get templateTypeMarkdown => 'Markdown';

  @override
  String get templateTypeCoordinates => 'Koordinat';

  @override
  String get templateTypeList => 'Nilai daftar';

  @override
  String get templateTypeNestedList => 'Daftar bertingkat';

  @override
  String get templateTypeDates => 'Tanggal';

  @override
  String get templateTypeDateTime => 'Tanggal dan waktu';

  @override
  String get templateTypeTime => 'Waktu';

  @override
  String get templateTypeSex => 'Jenis kelamin';

  @override
  String get templateTypeNumber => 'Angka';

  @override
  String get templateTypeEncoded => 'Teks terkode';

  @override
  String get templateFormatDefaultMapping => 'Pemetaan bawaan';

  @override
  String get templateFormatCustomMapping => 'Pemetaan khusus…';

  @override
  String get templateFormatDecimal => 'Desimal (45.123, -122.543)';

  @override
  String get templateFormatCardinalDecimal =>
      'Desimal arah mata angin (45.123° LU, 122.543° BB)';

  @override
  String get templateFormatPipe => 'Dipisahkan garis tegak (A | B | C)';

  @override
  String get templateFormatComma => 'Dipisahkan koma (A, B, C)';

  @override
  String get templateFormatSemicolon => 'Dipisahkan titik koma (A; B; C)';

  @override
  String get templateFormatSlash => 'Dipisahkan garis miring (A / B / C)';

  @override
  String get templateFormatNewline => 'Baris baru (A\nB\nC)';

  @override
  String get templateFormatBullet => 'Berpoin (• A\n• B)';

  @override
  String get templateFormatCustomSeparator => 'Pemisah khusus…';

  @override
  String get templateFormatTable => 'Tabel';

  @override
  String get templateFormatCardList => 'Daftar kartu';

  @override
  String get templateFormatMonthDdYyyy => 'Bulan DD, YYYY (Juni 28, 2026)';

  @override
  String get templateFormatDdMonthYyyy => 'DD Bulan YYYY (28 Juni 2026)';

  @override
  String get templateFormatDdMonthAbbr => 'DD Bulan (singkat) (28 Jun 2026)';

  @override
  String get templateFormatYmdSeconds =>
      'YYYY-MM-DD detik (2026-06-28 14:05:09)';

  @override
  String get templateFormatIsoMinutes => 'ISO menit (2026-06-28T14:05)';

  @override
  String get templateFormatIsoSeconds => 'ISO detik (2026-06-28T14:05:09)';

  @override
  String get templateFormatDdMonthYyyyTime =>
      'DD Bulan YYYY 24j (28 Juni 2026 14:05)';

  @override
  String get templateFormatMonthDdYyyyTime =>
      'Bulan DD, YYYY 12j (Juni 28, 2026 2:05 PM)';

  @override
  String get templateFormatDdMonYyyyTime =>
      'DD Bln YYYY 24j (28 Jun 2026 14:05)';

  @override
  String get templateFormatMonDdYyyyTime =>
      'Bln DD, YYYY 12j (Jun 28, 2026 2:05 PM)';

  @override
  String get templateFormatTime24 => 'Waktu 24j (14:05)';

  @override
  String get templateFormatTime24Seconds => 'Waktu 24j dengan detik (14:05:09)';

  @override
  String get templateFormatTime12 => 'Waktu 12j (2:05 PM)';

  @override
  String get templateFormatTime12Padded =>
      'Waktu 12j dengan nol di depan (02:05 PM)';

  @override
  String get templateFormatOriginal => 'Asli';

  @override
  String get templateFormatDecimals0 => '0 tempat desimal (mis. 12)';

  @override
  String get templateFormatDecimals1 => '1 tempat desimal (mis. 12.3)';

  @override
  String get templateFormatDecimals2 => '2 tempat desimal (mis. 12.34)';

  @override
  String get templateFormatDecimals3 => '3 tempat desimal (mis. 12.345)';

  @override
  String get templateFormatNormal => 'Biasa';

  @override
  String get templateFormatCapitalize => 'Kapitalisasi';

  @override
  String get templateSexSymbol => 'Simbol (♂/♀)';

  @override
  String get templateSexLetter => 'Huruf (J/B)';

  @override
  String get templateSexText => 'Teks (Jantan/Betina)';

  @override
  String get templateSexUnknown => 'Tidak diketahui';

  @override
  String get templateSexNa => 'T/A';

  @override
  String get templateSexNone => 'Tidak ada';

  @override
  String get templateSizeLabel => 'Ukuran templat:';

  @override
  String get templateAddImage => 'Tambah gambar';

  @override
  String get templateAddLine => 'Tambah garis';

  @override
  String get templateAddShape => 'Tambah bentuk';

  @override
  String get templateFront => 'Depan';

  @override
  String get templateBack => 'Belakang';

  @override
  String get templateSave => 'Simpan templat';

  @override
  String get templateRedo => 'Ulangi';

  @override
  String get templateBorder => 'Batas templat';

  @override
  String get templateElements => 'Elemen';

  @override
  String get templateHideGrid => 'Sembunyikan kisi';

  @override
  String get templateShowGrid => 'Tampilkan kisi';

  @override
  String get templateDisableSnap => 'Nonaktifkan jepret';

  @override
  String get templateEnableSnap => 'Aktifkan jepret';

  @override
  String get templateUnlockCanvas => 'Buka kunci gerakan kanvas';

  @override
  String get templateLockCanvas => 'Kunci gerakan kanvas';

  @override
  String get templateSelectPreviewRecord =>
      'Pilih spesimen untuk pratinjau teks';

  @override
  String get templateSettings => 'Pengaturan templat';

  @override
  String get templateToolPage => 'Halaman';

  @override
  String get templateToolView => 'Tampilan';

  @override
  String get templatePresetTemplate => 'Templat prasetel';

  @override
  String templateMirrorOn(String side) {
    return '$side: diputar 180° untuk dicetak (ketuk untuk menonaktifkan)';
  }

  @override
  String templateMirrorOff(String side) {
    return '$side: ketuk untuk memutar templat 180° saat dicetak';
  }

  @override
  String get templateOneSided => '1 sisi';

  @override
  String templateEditSide(String side) {
    return 'Sunting sisi $side';
  }

  @override
  String templateElementsForSide(String side) {
    return 'Elemen · $side';
  }

  @override
  String get templateNoElements =>
      'Belum ada elemen di sisi ini. Tambahkan dari alat Tambah.';

  @override
  String get templateHidden => 'Tersembunyi';

  @override
  String get templateLocked => 'Terkunci';

  @override
  String get templateNoSaved => 'Belum ada templat tersimpan.';

  @override
  String get templateFitToScreen => 'Sesuaikan dengan layar';

  @override
  String get templateRemoveImage => 'Hapus gambar';

  @override
  String get templateDragToRotate => 'Seret untuk memutar';

  @override
  String get templateRemoveLine => 'Hapus garis';

  @override
  String get templateDragToMove => 'Seret untuk memindahkan';

  @override
  String get templateRemoveShape => 'Hapus bentuk';

  @override
  String get templateDeleteImage => 'Hapus gambar';

  @override
  String get templateLineStrokeOptions => 'Opsi garis';

  @override
  String get templateThickness => 'Ketebalan';

  @override
  String get templateColor => 'Warna';

  @override
  String get templateSelectColor => 'Pilih warna';

  @override
  String get templateDeleteLine => 'Hapus garis';

  @override
  String get templateDismissToolbar => 'Tutup bilah alat';

  @override
  String get templateBorderFillOptions => 'Opsi batas dan isian';

  @override
  String get templateSelectStrokeColor => 'Pilih warna garis tepi';

  @override
  String get templateFill => 'Isian';

  @override
  String get templateClearFill => 'Hapus isian';

  @override
  String get templateDeleteShape => 'Hapus bentuk';

  @override
  String get templateRectangle => 'Persegi panjang';

  @override
  String get templateEllipse => 'Elips';

  @override
  String get templateTriangle => 'Segitiga';

  @override
  String get templatePolygon => 'Poligon';

  @override
  String get templateCorners => 'Sudut';

  @override
  String get templateSelectFillColor => 'Pilih warna isian';

  @override
  String get templateBorderTitle => 'Batas';

  @override
  String get templateSelectBorderColor => 'Pilih warna batas';

  @override
  String get templateSelectColorShade => 'Pilih corak warna';

  @override
  String get templateSelectedColorShades => 'Warna terpilih dan coraknya';

  @override
  String get templateSendToBack => 'Kirim ke paling belakang';

  @override
  String get templateSendBackward => 'Mundurkan';

  @override
  String get templateBringForward => 'Majukan';

  @override
  String get templateBringToFront => 'Bawa ke paling depan';

  @override
  String get templateUnlockPosition => 'Buka kunci posisi';

  @override
  String get templateLockPosition => 'Kunci posisi';

  @override
  String get templateHideElement => 'Sembunyikan elemen';

  @override
  String get templateShowElement => 'Tampilkan elemen';

  @override
  String get templateDuplicateElement => 'Duplikat elemen';

  @override
  String get templateCopyElement => 'Salin elemen';

  @override
  String get templatePasteElement => 'Tempel elemen';

  @override
  String templateMapEncodedValuesBody(String field) {
    return 'Tentukan label khusus untuk nilai [$field]:';
  }

  @override
  String get templateFontsNotInstalled => 'Huruf tidak terpasang';

  @override
  String templateMissingFontOne(int templates) {
    String _temp0 = intl.Intl.pluralLogic(
      templates,
      locale: localeName,
      other:
          'Instalasi ini tidak memiliki 1 huruf yang digunakan oleh templat yang diimpor. Pilih penggantinya.',
    );
    return '$_temp0';
  }

  @override
  String templateMissingFontMany(int templates, int fonts) {
    String _temp0 = intl.Intl.pluralLogic(
      templates,
      locale: localeName,
      other:
          'Instalasi ini tidak memiliki $fonts huruf yang digunakan oleh templat yang diimpor. Pilih pengganti untuk masing-masing.',
    );
    return '$_temp0';
  }

  @override
  String get templateInstallOriginalFonts =>
      'Pasang huruf asli di Dokumen > Huruf jika Anda memerlukan kecocokan persis.';

  @override
  String templateFontPreview(String font) {
    return 'Pratinjau: $font';
  }

  @override
  String get templateCancelImport => 'Batalkan impor';

  @override
  String get templateReplaceAndImport => 'Ganti dan impor';

  @override
  String get templateExistsTitle => 'Templat sudah ada';

  @override
  String templateExistsBody(String name) {
    return 'Templat bernama \"$name\" sudah ada. Ganti salinan yang tersimpan?';
  }

  @override
  String get templateNewName => 'Nama baru';

  @override
  String get templateUploadFromDevice => 'Unggah dari perangkat';

  @override
  String get templateUploadFromDeviceBody =>
      'Menyalin berkas ke folder gambar templat Anda';

  @override
  String get templateSavedImages => 'Gambar tersimpan';

  @override
  String get templateNoSavedImages =>
      'Belum ada gambar tersimpan - unggah satu terlebih dahulu.';

  @override
  String get templateName => 'Nama templat';

  @override
  String get templateEnterName => 'Masukkan nama';

  @override
  String get templateSaveImportedAs => 'Simpan templat yang diimpor sebagai';

  @override
  String templateMustDiffer(String name) {
    return 'Harus berbeda dari \"$name\"';
  }

  @override
  String get templateNameExists => 'Templat dengan nama ini sudah ada';

  @override
  String templateRecordTypeValue(String type) {
    return 'Jenis catatan: $type';
  }

  @override
  String get templateSides => 'Sisi';

  @override
  String get templateOneSidedBody => 'Buat templat hanya dengan sisi depan.';

  @override
  String get templateTwoSided => '2 sisi';

  @override
  String get templateTwoSidedBody => 'Buat desain depan dan belakang terpisah.';

  @override
  String get templateCreateNew => 'Buat templat baru';

  @override
  String get templateOptions => 'Opsi templat';

  @override
  String get templateSaveAs => 'Simpan sebagai…';

  @override
  String get templateChoose => 'Pilih templat';

  @override
  String get templateUntitled => 'Templat tanpa judul';

  @override
  String get templateInsertField => 'Sisipkan bidang';

  @override
  String get templateAllTaxa => 'Semua takson';

  @override
  String get templateEditCustomText => 'Sunting teks khusus';

  @override
  String get templateTextInput => 'Masukan teks';

  @override
  String get templateTextInputHint => 'Masukkan teks atau sisipkan bidang…';

  @override
  String get templateAvailableSymbols => 'Simbol yang tersedia';

  @override
  String get templateEnterText => 'Masukkan teks…';

  @override
  String templateRenamedTo(String name) {
    return 'Diganti nama menjadi $name';
  }

  @override
  String templateRenameFailed(String error) {
    return 'Gagal mengganti nama: $error';
  }

  @override
  String templateSavedName(String name) {
    return 'Templat \"$name\" disimpan';
  }

  @override
  String templateSavedFile(String file) {
    return '$file disimpan';
  }

  @override
  String templateReplacementInvalid(int index, String text, String message) {
    return 'Penggantian teks $index di \"$text\" tidak valid: $message';
  }

  @override
  String templateImportedAndSaved(String name) {
    return '\"$name\" diimpor dan disimpan';
  }

  @override
  String get templateImportFailed => 'Impor gagal atau berkas tidak valid';

  @override
  String get templateUnsavedChanges => 'Perubahan belum disimpan';

  @override
  String get templateUnsavedChangesBody =>
      'Apakah Anda ingin menyimpan perubahan templat sebelum keluar?';

  @override
  String get templateDiscard => 'Buang';

  @override
  String get templatePreviewPartSelection =>
      'Pemilihan bagian spesimen untuk pratinjau';

  @override
  String get templatePreviewParasiteSelection =>
      'Pemilihan parasit untuk pratinjau';

  @override
  String get templatePreviewSpecimenSelection =>
      'Pemilihan spesimen untuk pratinjau';

  @override
  String get templateSizePreset => 'Prasetel ukuran templat';

  @override
  String get templateSizePaper => 'Kertas';

  @override
  String get templateSizeCryotubes => 'Kriotabung';

  @override
  String get templateSizeRangeHelper => 'Masukkan nilai antara 10 dan 500 mm';

  @override
  String get templateSizeEnterWidth => 'Masukkan lebar';

  @override
  String get templateSizeInvalidNumber => 'Masukkan angka yang valid';

  @override
  String get templateSizeOutOfRange => 'Harus antara 10 dan 500';

  @override
  String get templateSizeEnterHeight => 'Masukkan tinggi';

  @override
  String get templateSizeApplyCustom => 'Terapkan ukuran khusus';

  @override
  String get templatePresetLetter => 'Letter';

  @override
  String get templatePresetLegal => 'Legal';

  @override
  String get templatePresetVialSideLarge => 'Sisi vial 1.5 - 2.0 mL';

  @override
  String get templatePresetVialSideSmall => 'Sisi vial 0.5 - 1.0 mL';

  @override
  String get templatePresetCapDotSmall => 'Titik tutup vial kecil';

  @override
  String get templatePresetCapDotLarge => 'Titik tutup vial besar';

  @override
  String get templatePresetSelfLaminating => 'Pembungkus laminasi mandiri';

  @override
  String get templatePresetPinnedLocality =>
      'Invertebrata berjarum (lokalitas)';

  @override
  String get templatePresetPinnedTaxon => 'Invertebrata berjarum (ID takson)';

  @override
  String get templatePresetJarInsert => 'Koleksi basah (sisipan toples)';

  @override
  String get templatePresetVertebrateTag => 'Tag spesimen vertebrata (sedang)';

  @override
  String get templatePresetSkullBox => 'Kotak tengkorak / mikrovial';

  @override
  String get templatePresetA4Description =>
      'Standar internasional bawaan untuk katalog, laporan, dan lembar label.';

  @override
  String get templatePresetLetterDescription =>
      'Standar Amerika Utara bawaan untuk dokumentasi dan pencetakan matriks.';

  @override
  String get templatePresetLegalDescription =>
      'Kanvas panjang untuk catatan lapangan panjang, lembar riwayat, atau tabel besar.';

  @override
  String get templatePresetA5Description =>
      'Ukuran ringkas, ideal untuk buku lapangan saku dan sisipan catatan kecil.';

  @override
  String get templatePresetA3Description =>
      'Lembar besar untuk pembuatan peta, tata letak laci koleksi, dan kisi sistem.';

  @override
  String get templatePresetVialSideLargeDescription =>
      'Label sisi standar. Muat 3-4 baris teks dan kode batang.';

  @override
  String get templatePresetVialSideSmallDescription =>
      'Profil sisi ringkas untuk alikuot jaringan atau DNA yang lebih kecil.';

  @override
  String get templatePresetCapDotSmallDescription =>
      'Titik bundar atas untuk tutup tabung 0.5–1.5 mL agar dapat dipindai dari atas.';

  @override
  String get templatePresetCapDotLargeDescription =>
      'Titik bundar atas untuk tutup ulir krivial 2.0 mL atau lebih besar.';

  @override
  String get templatePresetSelfLaminatingDescription =>
      'Teks dicetak di area 25.4x12.7 mm; ekor bening membungkus untuk melindungi dari nitrogen cair.';

  @override
  String get templatePresetPinnedLocalityDescription =>
      'Batas kaku untuk serangga berjarum; muat 5-6 baris metadata sangat ringkas.';

  @override
  String get templatePresetPinnedTaxonDescription =>
      'Ukuran terkecil; memuat genus spesies, author, dan info pengidentifikasi.';

  @override
  String get templatePresetJarInsertDescription =>
      'Diletakkan di dalam toples basah (alkohol/formalin). Mudah dibaca melalui kaca lengkung.';

  @override
  String get templatePresetVertebrateTagDescription =>
      'Tag gantung standar berukuran sedang untuk kurasi vertebrata.';

  @override
  String get templatePresetSkullBoxDescription =>
      'Dioptimalkan untuk vial kaca 1–2 dram atau kotak osteologi karton kecil.';

  @override
  String get templateElementImage => 'Gambar';

  @override
  String templateElementImageDetail(String width, String height) {
    return 'Gambar · $width × $height mm';
  }

  @override
  String get templateElementLine => 'Garis';

  @override
  String get templateElementEmptyText => 'Teks kosong';

  @override
  String get mediaGallery => 'Galeri';

  @override
  String get mediaActions => 'Tindakan';

  @override
  String get mediaDeleteSelectedTitle => 'Hapus media yang dipilih?';

  @override
  String get mediaDeleteSelectedBody =>
      'Hapus media yang dipilih dari semua catatan NAHPU dan dari disk? Tindakan ini tidak dapat dibatalkan.';

  @override
  String mediaSelectedCount(int count) {
    return '$count dipilih';
  }

  @override
  String get mediaNoneAdded => 'Belum ada media';

  @override
  String get mediaAdd => 'Tambah media';

  @override
  String get mediaTakePhotosVideos => 'Ambil foto/video';

  @override
  String get mediaRecordAudio => 'Rekam audio';

  @override
  String get mediaAddFromGallery => 'Tambah dari galeri';

  @override
  String get mediaAddFromFile => 'Tambah dari berkas';

  @override
  String get mediaUnavailable => 'Media tidak tersedia';

  @override
  String get mediaFileMissing => 'Berkas tidak ada';

  @override
  String get mediaImageUnavailable => 'Gambar tidak tersedia';

  @override
  String get mediaNone => 'Tidak ada media';

  @override
  String get mediaMenuActions => 'Tindakan media';

  @override
  String get mediaShowInfo => 'Tampilkan info';

  @override
  String get mediaEdit => 'Sunting media';

  @override
  String get mediaInfo => 'Info media';

  @override
  String get mediaDeleteFileTitle => 'Hapus berkas media?';

  @override
  String mediaDeleteFileBody(String name) {
    return 'Hapus $name dari semua catatan NAHPU dan dari disk? Tindakan ini tidak dapat dibatalkan.';
  }

  @override
  String get mediaDeleteThisFileBody =>
      'Hapus berkas media ini dari semua catatan NAHPU dan dari disk? Tindakan ini tidak dapat dibatalkan.';

  @override
  String get mediaFileAlreadyExists => 'Berkas sudah ada';

  @override
  String get mediaFileName => 'Nama berkas';

  @override
  String get mediaFileNameHint => 'Masukkan nama berkas';

  @override
  String get mediaCaption => 'Keterangan';

  @override
  String get mediaCaptionHint => 'Masukkan keterangan';

  @override
  String get mediaTag => 'Tag';

  @override
  String get mediaTagHint => 'Masukkan tag';

  @override
  String get mediaPhotographer => 'Fotografer';

  @override
  String get mediaSelectPersonnel => 'Pilih personel';

  @override
  String get mediaClearPhotographer => 'Hapus fotografer';

  @override
  String get mediaExportSelected => 'Ekspor media yang dipilih';

  @override
  String get mediaExporting => 'Mengekspor media';

  @override
  String get mediaExportingHint =>
      'Pilihan media yang besar dapat memakan waktu beberapa menit. Biarkan NAHPU tetap terbuka hingga selesai.';

  @override
  String get mediaExport => 'Ekspor media';

  @override
  String get mediaExportLeaveBody =>
      'Ekspor masih berjalan. Keluar sekarang akan membatalkannya dan tidak ada berkas yang disimpan.';

  @override
  String get mediaArchive => 'Arsip media';

  @override
  String get mediaImageFormat => 'Format gambar';

  @override
  String get mediaLimitDimensions => 'Batasi dimensi gambar';

  @override
  String get mediaLimitDimensionsBody =>
      'Batasi sisi terpanjang tanpa memperbesar';

  @override
  String get mediaMaxDimension => 'Lebar atau tinggi maksimum (px)';

  @override
  String get mediaMaxDimensionHelper =>
      'Berlaku untuk sisi yang lebih panjang.';

  @override
  String get mediaJpegQuality => 'Kualitas JPEG';

  @override
  String get mediaImages => 'Gambar';

  @override
  String get mediaAudio => 'Audio';

  @override
  String get mediaVideo => 'Video';

  @override
  String get mediaOther => 'Lainnya';

  @override
  String get mediaSourceSize => 'Ukuran sumber';

  @override
  String get mediaExported => 'Diekspor';

  @override
  String mediaWarningCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count peringatan',
    );
    return '$_temp0';
  }

  @override
  String mediaCannotConvert(String format) {
    return '$format tidak dapat dikonversi dan akan tetap dalam format aslinya.';
  }

  @override
  String get mediaPause => 'Jeda';

  @override
  String get mediaPlay => 'Putar';

  @override
  String mediaPlaybackUnavailable(String error) {
    return 'Pratinjau pemutaran tidak tersedia: $error';
  }

  @override
  String get mediaCameraAccessRequired =>
      'Akses kamera diperlukan untuk mengambil foto dan video.';

  @override
  String get mediaMicrophoneAccessRequired =>
      'Akses mikrofon diperlukan untuk merekam video.';

  @override
  String get mediaCameraError => 'Tidak dapat menggunakan kamera.';

  @override
  String get mediaPhoto => 'Foto';

  @override
  String get mediaSwitchCamera => 'Ganti kamera';

  @override
  String get mediaStopRecording => 'Hentikan perekaman';

  @override
  String get mediaRecordVideo => 'Rekam video';

  @override
  String get mediaRetake => 'Ambil ulang';

  @override
  String get mediaUse => 'Gunakan';

  @override
  String get mediaDetailFile => 'Berkas';

  @override
  String get mediaCategory => 'Kategori';

  @override
  String get mediaCaptureEquipment => 'Pengambilan dan peralatan';

  @override
  String get mediaTaken => 'Diambil';

  @override
  String get mediaCamera => 'Kamera';

  @override
  String get mediaLenses => 'Lensa';

  @override
  String get mediaAdditionalExif => 'EXIF tambahan';

  @override
  String get mediaId => 'ID media';

  @override
  String get mediaSecondaryId => 'ID sekunder';

  @override
  String get mediaPhotographerId => 'ID fotografer';

  @override
  String get mediaLinkedInformation => 'Informasi tertaut';

  @override
  String mediaLinkedInformationError(String error) {
    return 'Informasi tertaut tidak tersedia: $error';
  }

  @override
  String get mediaResume => 'Lanjutkan';

  @override
  String get mediaPausePlayback => 'Jeda pemutaran';

  @override
  String get mediaPlayRecording => 'Putar rekaman';

  @override
  String get mediaRecordingNotSaved => 'Rekaman audio tidak disimpan.';

  @override
  String get mediaImageSettings => 'Pengaturan gambar';

  @override
  String mediaOriginalSize(int width, int height) {
    return 'Asli: $width × $height px';
  }

  @override
  String get mediaResizeImage => 'Ubah ukuran gambar';

  @override
  String get mediaAspectLocked => 'Rasio aspek terkunci';

  @override
  String get mediaWidthPx => 'Lebar (px)';

  @override
  String mediaMaxValue(int value) {
    return 'Maks. $value';
  }

  @override
  String get mediaHeightPx => 'Tinggi (px)';

  @override
  String get mediaSearchMetadata => 'Cari metadata media';

  @override
  String get mediaGalleryTitle => 'Galeri media';

  @override
  String get mediaGalleryAllProjectsTitle => 'Semua media';

  @override
  String get mediaFilterProject => 'Saring berdasarkan proyek';

  @override
  String get mediaAllProjects => 'Semua proyek';

  @override
  String get mediaSearch => 'Cari media';

  @override
  String get mediaDeleteSelected => 'Hapus media yang dipilih';

  @override
  String get mediaCategoryEvent => 'Kegiatan';

  @override
  String get mediaSort => 'Urutkan media';

  @override
  String get mediaNoMatching => 'Tidak ada media yang cocok';

  @override
  String get mediaSortAddedNewest => 'Terbaru ditambahkan';

  @override
  String get mediaSortAddedOldest => 'Terlama ditambahkan';

  @override
  String get mediaSortFileNameAsc => 'Nama berkas A–Z';

  @override
  String get mediaSortFileNameDesc => 'Nama berkas Z–A';

  @override
  String get mediaSortTakenNewest => 'Tanggal diambil, terbaru';

  @override
  String get mediaSortTakenOldest => 'Tanggal diambil, terlama';

  @override
  String get mediaHideDetails => 'Sembunyikan detail';

  @override
  String get mediaShowDetails => 'Tampilkan detail';

  @override
  String get mediaPrevious => 'Sebelumnya';

  @override
  String get mediaMute => 'Bisukan';

  @override
  String get mediaUnmute => 'Bunyikan';

  @override
  String get mediaPlaybackSpeed => 'Kecepatan pemutaran';

  @override
  String get mediaExitFullscreen => 'Keluar dari layar penuh';

  @override
  String get mediaFullscreen => 'Layar penuh';

  @override
  String mediaCannotDisplay(String kind) {
    return 'Tidak dapat menampilkan berkas $kind ini';
  }

  @override
  String get mediaBarcode => 'Kode batang';

  @override
  String get mediaScanQrCode => 'Pindai kode QR';

  @override
  String get mediaScanBarcode => 'Pindai kode batang';

  @override
  String get mediaAlignQrCode => 'Sejajarkan kode QR di dalam bingkai';

  @override
  String get mediaAlignBarcode => 'Sejajarkan kode batang di dalam bingkai';

  @override
  String get mediaQrTooLarge =>
      'Data terlalu besar untuk kode QR.\nEkspor sebagai berkas.';

  @override
  String get associatedUnnamed => 'Data terkait tanpa nama';

  @override
  String get associatedFileUnavailable => 'Berkas tidak tersedia';

  @override
  String get associatedTypeLink => 'Tautan';

  @override
  String get associatedUnknownType => 'Jenis tidak diketahui';

  @override
  String get associatedNoResource => 'Tidak ada sumber daya';

  @override
  String get associatedActions => 'Tindakan data terkait';

  @override
  String get associatedOpenInDefaultApp => 'Buka di aplikasi bawaan';

  @override
  String get associatedOpenLink => 'Buka tautan';

  @override
  String get associatedNoUriToShare => 'Tidak ada URI untuk dibagikan.';

  @override
  String get associatedFileNotFound => 'Berkas tidak ditemukan';

  @override
  String get associatedInvalidUri => 'URI tidak valid.';

  @override
  String associatedCouldNotOpen(String uri) {
    return 'Tidak dapat membuka $uri';
  }

  @override
  String get associatedAdd => 'Tambah data terkait';

  @override
  String get associatedNoneAdded => 'Belum ada data terkait';

  @override
  String get associatedEdit => 'Sunting data terkait';

  @override
  String get associatedDataType => 'Jenis data';

  @override
  String get associatedDataTypeHint => 'Pilih jenis data';

  @override
  String get associatedNameHint => 'mis. GenBank atau MorphoSource';

  @override
  String get associatedDescriptionHint => 'Jelaskan data terkait';

  @override
  String get associatedResource => 'Sumber daya';

  @override
  String get associatedNonMediaFiles => 'Berkas non-media';

  @override
  String get associatedCopyToProject => 'Salin ke proyek';

  @override
  String get associatedLinkOriginal => 'Tautkan asli';

  @override
  String get associatedLinkOriginalWarning =>
      'Tautan akan berhenti berfungsi jika berkas asli dipindahkan atau dihapus.';

  @override
  String get associatedSelectDataType => 'Pilih jenis data.';

  @override
  String get associatedEnterValidUri => 'Masukkan URI yang valid.';

  @override
  String get associatedSelectFile => 'Pilih berkas.';

  @override
  String get associatedNoIdentifier => 'Data terkait tidak memiliki pengenal.';

  @override
  String get associatedInfo => 'Info data terkait';

  @override
  String get associatedOriginStoragePath => 'Jalur penyimpanan asal';

  @override
  String get associatedLinkedOriginal => 'Asli tertaut';

  @override
  String get associatedProjectCopy => 'Salinan proyek';

  @override
  String get associatedAvailability => 'Ketersediaan';

  @override
  String get associatedChecking => 'Memeriksa…';

  @override
  String get legalReadThe => 'Harap baca ';

  @override
  String get legalTermsAndConditions => 'Syarat dan Ketentuan';

  @override
  String get legalAndThe => ' dan ';

  @override
  String get legalPrivacyPolicy => 'Kebijakan Privasi';

  @override
  String get legalBeforeYouStart =>
      ' sebelum memulai. Dengan menggunakan NAHPU, Anda menyetujuinya.';

  @override
  String get legalTermsTile => 'Syarat dan ketentuan';

  @override
  String get legalPrivacyTile => 'Kebijakan privasi';

  @override
  String get mapCenterOnCoordinates => 'Pusatkan peta pada koordinat';

  @override
  String mapMoreCount(int count) {
    return '+$count lainnya';
  }

  @override
  String get mapTapToZoomIn => 'Ketuk untuk memperbesar';

  @override
  String get mapNaturalEarthOffline => 'Natural Earth · luring';

  @override
  String get mapRetryDetailed => 'Coba lagi peta terperinci';

  @override
  String get siteAddCoordinates => 'Tambah koordinat';

  @override
  String get siteViewMap => 'Lihat peta';

  @override
  String siteAddSelected(int count) {
    return 'Tambah $count yang dipilih';
  }

  @override
  String get siteNewCoordinate => 'Koordinat baru';

  @override
  String get siteSupportedFiles => 'Berkas yang didukung:';

  @override
  String get siteSupportedFileTypes =>
      'CSV, TSV, Excel, GeoJSON/JSON, KML, Shapefile terkompresi, dan GPX.';

  @override
  String get siteSelectCoordinateFile => 'Pilih berkas koordinat';

  @override
  String siteRowsSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count baris dilewati',
    );
    return '$_temp0';
  }

  @override
  String get siteEditColumnMapping => 'Sunting pemetaan kolom';

  @override
  String get siteChooseAnotherFile => 'Pilih berkas lain';

  @override
  String get siteCoordinateChanged =>
      'Koordinat berubah. Muat ulang peta untuk memperbarui pratinjau.';

  @override
  String get siteEnterValidCoordinate =>
      'Masukkan lintang dan bujur WGS84 yang valid, lalu muat ulang peta.';

  @override
  String get siteRefreshMap => 'Muat ulang peta';

  @override
  String get siteEditCoordinates => 'Sunting koordinat';

  @override
  String get siteAddName => 'Tambahkan nama';

  @override
  String get siteDeviceGps => 'GPS perangkat';

  @override
  String get siteDeviceGpsBody =>
      'Gunakan sensor perangkat untuk mengisi koordinat otomatis';

  @override
  String get siteGetLocation => 'Dapatkan lokasi';

  @override
  String get siteCoordinateFormat => 'Format koordinat';

  @override
  String get siteDecimalDegrees => 'Derajat desimal';

  @override
  String get siteDdm => 'Derajat menit desimal (DDM)';

  @override
  String get siteDms => 'Derajat menit detik (DMS)';

  @override
  String get siteUtm => 'UTM (WGS84)';

  @override
  String get siteUtmCoordinate => 'Koordinat UTM';

  @override
  String get siteDecimalLatitude => 'Lintang desimal';

  @override
  String get siteAddLatitude => 'Tambahkan lintang';

  @override
  String get siteDecimalLongitude => 'Bujur desimal';

  @override
  String get siteAddLongitude => 'Tambahkan bujur';

  @override
  String get siteAddElevation => 'Tambahkan elevasi';

  @override
  String get siteSpecifyDatum => 'Tentukan datum';

  @override
  String get siteAddUncertainty => 'Tambahkan ketidakpastian';

  @override
  String get siteGpsUnit => 'Unit GPS';

  @override
  String get siteSpecifyGpsUnit => 'Tentukan unit GPS';

  @override
  String get siteAddNotes => 'Tambahkan catatan (opsional)';

  @override
  String get siteChangeFormatTitle => 'Ubah format koordinat?';

  @override
  String get siteChangeFormatBody =>
      'Mengubah format akan menghapus nilai koordinat yang dimasukkan. Nama, elevasi, datum, ketidakpastian, unit GPS, dan catatan tetap disimpan.';

  @override
  String get siteClearAndSwitch => 'Hapus dan ganti';

  @override
  String siteInvalidVerbatim(String axis, String value) {
    return '$axis verbatim ini tidak dapat dibaca dan mungkin telah diubah di luar NAHPU. Masukkan ulang sebelum menyimpan.\nAsli: $value';
  }

  @override
  String get siteMissingValue => '(kosong)';

  @override
  String get siteDegree => 'Derajat';

  @override
  String get siteMinute => 'Menit';

  @override
  String get siteSecond => 'Detik';

  @override
  String get siteManageCoordinates => 'Kelola koordinat';

  @override
  String get siteCoordinateMap => 'Peta koordinat';

  @override
  String siteExportCoordinatesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ekspor $count koordinat',
    );
    return '$_temp0';
  }

  @override
  String get siteFormatGeoJson => 'GeoJSON (.geojson)';

  @override
  String get siteFormatShapefile => 'Bundel Shapefile (.zip)';

  @override
  String get siteShowCoordinates => 'Tampilkan koordinat';

  @override
  String get siteAllCoordinates => 'Semua koordinat';

  @override
  String siteLoadSitesError(String error) {
    return 'Tidak dapat memuat situs: $error';
  }

  @override
  String siteLoadCoordinatesError(String error) {
    return 'Tidak dapat memuat koordinat: $error';
  }

  @override
  String siteExportSelectedCoordinates(int count) {
    return 'Ekspor koordinat ($count)';
  }

  @override
  String get siteNoCoordinates => 'Belum ada koordinat';

  @override
  String siteSelectedOfCoordinates(int count, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total koordinat',
    );
    return '$count dari $_temp0';
  }

  @override
  String siteUnnamedCoordinateId(String id) {
    return 'Koordinat tanpa nama ($id)';
  }

  @override
  String siteCoordinatesNotShown(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count koordinat tidak ditampilkan karena lintang atau bujur kosong atau tidak valid.',
    );
    return '$_temp0';
  }

  @override
  String get siteCoordinateActions => 'Tindakan koordinat';

  @override
  String get siteCopy => 'Salin';

  @override
  String get siteOpenInMap => 'Buka di peta';

  @override
  String get siteCoordinateDetails => 'Detail koordinat';

  @override
  String get siteCopiedToClipboard => 'Lintang dan bujur disalin ke papan klip';

  @override
  String get siteNoName => 'Tanpa nama';

  @override
  String get siteOriginalCoordinate => 'Koordinat asli';

  @override
  String get siteOriginalFormat => 'Format asli';

  @override
  String get siteUncertainty => 'Ketidakpastian';

  @override
  String get siteUnnamedCoordinate => 'Koordinat tanpa nama';

  @override
  String get siteAddCoordinate => 'Tambah koordinat';

  @override
  String get siteNoId => 'Tanpa ID';

  @override
  String siteColumnsDetected(int columns, int rows) {
    return 'Terdeteksi $columns kolom dan $rows baris data. NAHPU menyimpulkan kecocokan di bawah. Lintang dan bujur wajib diisi; bidang lainnya opsional.';
  }

  @override
  String siteColumnsDetectedInWorksheet(
    int columns,
    int rows,
    String worksheet,
  ) {
    return 'Terdeteksi $columns kolom dan $rows baris data di lembar kerja \"$worksheet\". NAHPU menyimpulkan kecocokan di bawah. Lintang dan bujur wajib diisi; bidang lainnya opsional.';
  }

  @override
  String get siteNotIncluded => 'Tidak disertakan';

  @override
  String siteHeaderColumn(String header, int index) {
    return '$header (kolom $index)';
  }

  @override
  String get siteReviewCoordinates => 'Tinjau koordinat';

  @override
  String get siteImportFieldNameId => 'Nama / ID';

  @override
  String get siteCopyFromProject => 'Salin dari proyek';

  @override
  String get siteChooseDataToCopy => 'Pilih data untuk disalin';

  @override
  String get siteSelectSourceProject =>
      'Pilih proyek yang berisi situs yang akan disalin.';

  @override
  String siteSelectFromProject(String project) {
    return 'Pilih situs dari $project.';
  }

  @override
  String get siteNoSitesInProject => 'Tidak ada situs di proyek ini.';

  @override
  String get siteSelectDataToCopy =>
      'Pilih data yang akan disalin ke situs kosong.';

  @override
  String get siteNoCopyableData =>
      'Situs yang dipilih tidak memiliki data yang dapat disalin.';

  @override
  String get siteNoDataInSource => 'Tidak ada data di sumber';

  @override
  String get siteMustBeEmptyBody =>
      'Situs saat ini harus kosong sebelum menyalin data. Hapus informasi situs, koordinat, media, dan data tertautnya terlebih dahulu.';

  @override
  String get siteMustBeEmpty => 'Situs harus kosong';

  @override
  String get siteNeedAnotherProject =>
      'Buat atau impor proyek lain sebelum menyalin data situs.';

  @override
  String get siteMultipleProjectsRequired => 'Diperlukan beberapa proyek';

  @override
  String siteUnnamedSite(String id) {
    return 'Situs tanpa nama #$id';
  }

  @override
  String siteGeographySettingsError(String error) {
    return 'Tidak dapat memuat pengaturan geografi: $error';
  }

  @override
  String get siteFindLocalityTooltip =>
      'Ketik lokalitas dan pilih yang tersimpan untuk mengisi semua bidang geografi';

  @override
  String get siteFindLocality => 'Cari lokalitas yang ada';

  @override
  String get siteFindLocalityHint => 'Ketik untuk memakai lokalitas tersimpan';

  @override
  String get siteEnterCountry => 'Masukkan negara';

  @override
  String get siteEnterIslandGroup => 'Masukkan kelompok pulau';

  @override
  String get siteEnterStateProvince => 'Masukkan negara bagian/provinsi';

  @override
  String get siteEnterCounty => 'Masukkan kabupaten/paroki/distrik';

  @override
  String get siteEnterMunicipality => 'Masukkan kotamadya/kota/desa';

  @override
  String get sitePreciseLocality => 'Lokalitas tepat';

  @override
  String get sitePreciseLocalityHint =>
      'Masukkan lokalitas tepat di bawah tingkat kotamadya';

  @override
  String get siteRemarksHint =>
      'Masukkan info lebih lanjut tentang situs (opsional)';

  @override
  String get siteHabitatType => 'Jenis habitat';

  @override
  String get siteHabitatTypeHint => 'Pilih jenis habitat';

  @override
  String get siteHabitatCondition => 'Kondisi habitat';

  @override
  String get siteHabitatConditionHint => 'Mis. \"Asli\", \"Terganggu\", dll.';

  @override
  String get siteHabitatDescription => 'Deskripsi habitat';

  @override
  String get siteHabitatDescriptionHint =>
      'Jelaskan situs, mis. \"Lokasi kemah di tengah hutan.\"';

  @override
  String get siteCanopyCover => 'Tutupan kanopi';

  @override
  String get siteCanopyCoverHint => 'Masukkan tutupan kanopi';

  @override
  String get siteCreate => 'Buat situs';

  @override
  String get siteActions => 'Tindakan situs';

  @override
  String get siteDuplicate => 'Duplikat situs';

  @override
  String get siteCopyFromProjectMenu => 'Salin dari proyek…';

  @override
  String get siteExport => 'Ekspor situs';

  @override
  String get siteImport => 'Impor situs';

  @override
  String siteCopiedSummary(
    String fields,
    String coordinates,
    String site,
    String project,
  ) {
    return 'Disalin $fields dan $coordinates dari $site di $project.';
  }

  @override
  String siteFieldCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bidang',
    );
    return '$_temp0';
  }

  @override
  String get siteDeleteTitle => 'Hapus situs?';

  @override
  String get siteDeleteBody =>
      'Anda akan menghapus semua catatan di formulir situs ini';

  @override
  String get siteDeleteAllTitle => 'Hapus semua situs?';

  @override
  String get siteDeleteAllBody => 'Anda akan menghapus semua catatan situs';

  @override
  String get siteDeleteInUse =>
      'Tidak dapat menghapus situs. Sedang digunakan oleh catatan lain.';

  @override
  String get siteIdentity => 'Identitas situs';

  @override
  String get siteIdHint =>
      'Masukkan ID situs (maks. 40 karakter), mis. \"CAMP-01\", \"LINE-1\"';

  @override
  String get siteLeader => 'Pemimpin situs';

  @override
  String get siteType => 'Jenis situs';

  @override
  String get siteTypeHint => 'Pilih jenis situs';

  @override
  String get siteSearch => 'Cari situs';

  @override
  String get siteRecordTitle => 'Catatan situs';

  @override
  String get siteNoneFound => 'Situs tidak ditemukan';

  @override
  String get siteCopyFieldSiteLeader => 'Pemimpin situs';

  @override
  String get siteCopyFieldSiteType => 'Jenis situs';

  @override
  String get siteCopyFieldPreciseLocality => 'Lokalitas tepat';

  @override
  String get siteCopyFieldHabitatType => 'Jenis habitat';

  @override
  String get siteCopyFieldHabitatCondition => 'Kondisi habitat';

  @override
  String get siteCopyFieldHabitatDescription => 'Deskripsi habitat';

  @override
  String get siteCopyFieldCanopyCover => 'Tutupan kanopi';

  @override
  String eventEnvironmentLoadError(String error) {
    return 'Tidak dapat memuat data lingkungan: $error';
  }

  @override
  String get eventDayLowest => 'Terendah siang';

  @override
  String get eventDayHighest => 'Tertinggi siang';

  @override
  String get eventNightLowest => 'Terendah malam';

  @override
  String get eventNightHighest => 'Tertinggi malam';

  @override
  String get eventAverage => 'Rata-rata';

  @override
  String get eventDewPoint => 'Titik embun';

  @override
  String get eventEnterLowestTemp => 'Masukkan suhu terendah';

  @override
  String get eventEnterHighestTemp => 'Masukkan suhu tertinggi';

  @override
  String get eventEnterAverageHumidity => 'Masukkan kelembapan rata-rata';

  @override
  String get eventEnterDewPoint => 'Masukkan titik embun';

  @override
  String get eventCloudCover => 'Tutupan awan (okta)';

  @override
  String get eventCloudCoverHint => 'Pilih tutupan awan';

  @override
  String get eventCloudCoverHelper =>
      'Satu okta mewakili seperdelapan langit yang terlihat.';

  @override
  String eventInvalidStoredValue(String value) {
    return '$value — Nilai tersimpan tidak valid';
  }

  @override
  String get eventEnterRainfall => 'Masukkan curah hujan';

  @override
  String get eventEnterAmbientTemp => 'Masukkan suhu lingkungan';

  @override
  String get eventEnterRelativeHumidity => 'Masukkan kelembapan relatif';

  @override
  String get eventEnterWaterTemp => 'Masukkan suhu air';

  @override
  String get eventEnterPh => 'Masukkan pH';

  @override
  String get eventEnterDissolvedOxygen => 'Masukkan oksigen terlarut';

  @override
  String get eventEnterOxygenSaturation => 'Masukkan saturasi oksigen terlarut';

  @override
  String get eventEnterConductivity => 'Masukkan konduktivitas';

  @override
  String get eventEnterFlowVelocity => 'Masukkan kecepatan aliran';

  @override
  String get eventEnterSunrise => 'Masukkan waktu matahari terbit';

  @override
  String get eventEnterSunset => 'Masukkan waktu matahari terbenam';

  @override
  String get eventMoonPhaseHint => 'Pilih fase bulan';

  @override
  String eventRecoveryTitle(int count) {
    return 'Beberapa nilai lingkungan tersimpan perlu diperhatikan ($count)';
  }

  @override
  String get eventRecoveryBody =>
      'Perbaiki atau kosongkan bidang yang disorot. Nilai lain tidak akan diubah.';

  @override
  String eventSaveValueError(String error) {
    return 'Tidak dapat menyimpan nilai ini: $error';
  }

  @override
  String get eventEnterValidNumber => 'Masukkan angka yang valid.';

  @override
  String eventValueRange(String minimum, String maximum) {
    return 'Masukkan nilai dari $minimum hingga $maximum';
  }

  @override
  String eventValueMinimum(String minimum) {
    return 'Masukkan nilai $minimum atau lebih';
  }

  @override
  String get eventOkta0 => '0 — Langit cerah';

  @override
  String get eventOkta1 => '1 — Hingga 1/8 tertutup';

  @override
  String get eventOkta2 => '2 — 2/8 tertutup';

  @override
  String get eventOkta3 => '3 — 3/8 tertutup';

  @override
  String get eventOkta4 => '4 — Setengah tertutup';

  @override
  String get eventOkta5 => '5 — 5/8 tertutup';

  @override
  String get eventOkta6 => '6 — 6/8 tertutup';

  @override
  String get eventOkta7 => '7 — Setidaknya 7/8, tidak mendung total';

  @override
  String get eventOkta8 => '8 — Mendung total';

  @override
  String get eventOkta9 => '9 — Langit tertutup';

  @override
  String get eventMoonNew => 'Bulan baru';

  @override
  String get eventMoonWaxingCrescent => 'Bulan sabit awal';

  @override
  String get eventMoonFirstQuarter => 'Kuartal pertama';

  @override
  String get eventMoonWaxingGibbous => 'Cembung awal';

  @override
  String get eventMoonFull => 'Bulan purnama';

  @override
  String get eventMoonWaningGibbous => 'Cembung akhir';

  @override
  String get eventMoonLastQuarter => 'Kuartal terakhir';

  @override
  String get eventMoonWaningCrescent => 'Bulan sabit akhir';

  @override
  String get eventActivity => 'Aktivitas';

  @override
  String get eventPrimaryActivity => 'Aktivitas utama';

  @override
  String get eventSelectActivity => 'Pilih aktivitas';

  @override
  String eventActivitiesLoadError(String error) {
    return 'Tidak dapat memuat aktivitas utama: $error';
  }

  @override
  String get eventActivityNotesHint => 'Masukkan catatan tentang aktivitas';

  @override
  String get eventAddCollMethod => 'Tambah metode koleksi';

  @override
  String get eventNoCollMethods => 'Belum ada metode koleksi';

  @override
  String get eventAddCollMethodTitle => 'Tambah metode koleksi';

  @override
  String get eventEditCollMethod => 'Sunting metode koleksi';

  @override
  String get eventCollMethod => 'Metode koleksi';

  @override
  String get eventCountHint =>
      'Berapa banyak alat ini yang digunakan (jika ada)?';

  @override
  String get eventMethodDetails => 'Detail metode';

  @override
  String get eventBrandModel => 'Merek dan model';

  @override
  String get eventBrandModelHint => 'Masukkan merek dan model alat (jika ada)';

  @override
  String get eventSizeHint => 'Masukkan ukuran alat (jika ada)';

  @override
  String get eventToolNotesHint => 'Masukkan catatan tentang alat (jika ada)';

  @override
  String get eventSelectMethod => 'Pilih metode';

  @override
  String get eventIdentity => 'Identitas kegiatan';

  @override
  String get eventStartDate => 'Tanggal mulai';

  @override
  String get eventEndDate => 'Tanggal selesai';

  @override
  String get eventEditId => 'Sunting ID kegiatan';

  @override
  String get eventIdSuffix => 'Akhiran ID';

  @override
  String get eventIdSuffixHint => 'Masukkan akhiran ID';

  @override
  String get eventIdLabel => 'ID kegiatan: ';

  @override
  String get eventStartTime => 'Waktu mulai';

  @override
  String get eventEndTime => 'Waktu selesai';

  @override
  String get eventCreate => 'Buat kegiatan';

  @override
  String get eventDeleteInUse =>
      'Gagal menghapus kegiatan. Kegiatan sedang digunakan oleh catatan lain.';

  @override
  String get eventActions => 'Tindakan kegiatan';

  @override
  String get eventDuplicate => 'Duplikat kegiatan';

  @override
  String get eventExport => 'Ekspor kegiatan';

  @override
  String get eventImport => 'Impor kegiatan';

  @override
  String get eventDeleteTitle => 'Hapus kegiatan koleksi?';

  @override
  String get eventDeleteBody =>
      'Anda juga akan menghapus metode koleksi, personel koleksi, data lingkungan, dan media dalam kegiatan ini.';

  @override
  String get eventDeleteAllTitle => 'Hapus semua kegiatan koleksi?';

  @override
  String get eventDeleteAllBody =>
      'Menghapus semua kegiatan koleksi juga akan menghapus semua metode koleksi, personel koleksi, data lingkungan, dan media terkait dari basis data.';

  @override
  String get eventPersonnel => 'Personel kegiatan';

  @override
  String get eventNoPersonnel => 'Belum ada personel';

  @override
  String get eventUnknownPersonnel => 'Personel tidak dikenal';

  @override
  String get eventEnterRole => 'Masukkan peran';

  @override
  String get eventSearch => 'Cari kegiatan';

  @override
  String get eventRecordTitle => 'Catatan kegiatan koleksi';

  @override
  String get eventNoneFound => 'Kegiatan koleksi tidak ditemukan';

  @override
  String exportPresetsLoadError(String error) {
    return 'Tidak dapat memuat prasetel ekspor: $error';
  }

  @override
  String get exportPreset => 'Prasetel ekspor';

  @override
  String get exportNoPresets =>
      'Tidak ada prasetel ekspor. Kelola prasetel di pengaturan untuk membuatnya.';

  @override
  String get exportManagePresetsButton => 'Kelola prasetel';

  @override
  String get exportPresetHelper =>
      'Jenis catatan, header, dan pemetaan bidang ditentukan oleh prasetel.';

  @override
  String get exportPresetDetails => 'Detail prasetel';

  @override
  String get exportSelectPresetPrompt =>
      'Pilih prasetel ekspor untuk melihat detail dan pratinjau.';

  @override
  String exportPresetName(String name) {
    return 'Prasetel: $name';
  }

  @override
  String exportPresetRecord(String type) {
    return 'Catatan: $type';
  }

  @override
  String exportPresetTaxon(String taxon) {
    return 'Takson: $taxon';
  }

  @override
  String exportPresetHeader(String format) {
    return 'Header: $format';
  }

  @override
  String exportSelectedColumns(int count) {
    return 'Kolom terpilih ($count):';
  }

  @override
  String get exportPreviewTable => 'Pratinjau tabel';

  @override
  String get exportNoFieldsMapped =>
      'Tidak ada bidang yang dipetakan di prasetel ini.';

  @override
  String exportNestedFields(String namespace, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bidang',
    );
    return '$namespace ($_temp0)';
  }

  @override
  String get exportTablePreview => 'Pratinjau tabel';

  @override
  String get exportNoRecordsForPreset =>
      'Tidak ada catatan untuk prasetel ini.';

  @override
  String exportShowingRecords(int start, int end, int total) {
    return 'Menampilkan $start-$end dari $total catatan';
  }

  @override
  String exportPageOf(int page, int total) {
    return 'Halaman $page dari $total';
  }

  @override
  String get exportBundling => 'Membundel catatan';

  @override
  String get exportBundlingHint =>
      'Pengemasan menulis catatan, menyalin media, mengompresi bundel, lalu memeriksanya. Biarkan NAHPU tetap terbuka.';

  @override
  String get exportCreateBundle => 'Buat bundel';

  @override
  String get exportBundleAnother => 'Bundel lainnya';

  @override
  String get exportCancelBundleTitle => 'Batalkan bundel?';

  @override
  String get exportCancelBundleBody =>
      'Bundel masih ditulis. Keluar sekarang akan membatalkannya dan tidak ada paket yang disimpan.';

  @override
  String get exportKeepBundling => 'Lanjutkan membundel';

  @override
  String get exportCancelBundle => 'Batalkan bundel';

  @override
  String exportCreatedFile(String file) {
    return '$file dibuat';
  }

  @override
  String get exportBundleComplete => 'Bundel selesai!';

  @override
  String get exportCompleteData => 'Data NAHPU lengkap';

  @override
  String get exportCompleteDataBody =>
      'Bundel ini mencakup semua tabel basis data NAHPU, snapshot proyek yang dapat dipulihkan, konfigurasi pengguna, media yang tersedia, dan huruf khusus.';

  @override
  String get exportFrictionless =>
      'Ekspor menggunakan format Frictionless Data.';

  @override
  String get exportRecordedTaxa => 'Takson tercatat';

  @override
  String get exportSelectedTaxa => 'Takson terpilih';

  @override
  String get exportNoTaxaRecorded => 'Belum ada takson spesimen yang dicatat.';

  @override
  String exportTaxonGroupsIncluded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kelompok takson tercatat akan disertakan.',
    );
    return '$_temp0';
  }

  @override
  String get exportPackageContents => 'Isi paket';

  @override
  String get exportSelectTaxonPrompt =>
      'Pilih setidaknya satu takson tercatat untuk menampilkan isi paket.';

  @override
  String get exportPackageContentsBody =>
      'Daftar ini mencerminkan persis apa yang akan dibundel. Bidang dan tabel opsional yang kosong dihilangkan.';

  @override
  String exportRecordsAndFields(int records, int fields) {
    String _temp0 = intl.Intl.pluralLogic(
      records,
      locale: localeName,
      other: '$records catatan',
    );
    String _temp1 = intl.Intl.pluralLogic(
      fields,
      locale: localeName,
      other: '$fields bidang',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get exportBackingUp => 'Mencadangkan basis data';

  @override
  String get exportBackingUpHint =>
      'Pustaka media yang besar dapat memakan waktu beberapa menit. Biarkan NAHPU tetap terbuka hingga selesai.';

  @override
  String get exportSaveBackup => 'Simpan cadangan';

  @override
  String get exportSaveAnother => 'Simpan lainnya';

  @override
  String get exportCancelBackupTitle => 'Batalkan pencadangan?';

  @override
  String get exportCancelBackupBody =>
      'Pencadangan masih berjalan. Keluar sekarang akan membatalkannya dan tidak ada berkas yang disimpan.';

  @override
  String get exportKeepBackingUp => 'Lanjutkan mencadangkan';

  @override
  String get exportCancelBackup => 'Batalkan pencadangan';

  @override
  String get exportBackupArchive => 'Arsip cadangan';

  @override
  String get exportBackupBody =>
      'Ini membuat cadangan lengkap basis data NAHPU. Untuk cadangan proyek saja, gunakan Ekspor proyek.';

  @override
  String get exportBackupDetail =>
      'Ini menyalin semua proyek dan setiap berkas di data aplikasi NAHPU, baik ditautkan ke proyek maupun tidak. Jalankan sesekali di lapangan saat penggunaan baterai tidak menjadi masalah.';

  @override
  String get exportWillExport => 'Akan diekspor';

  @override
  String exportUserConfigsExportedTo(String path) {
    return 'Konfigurasi pengguna diekspor ke $path';
  }

  @override
  String get exportCustomFieldTemplates => 'Templat bidang khusus';

  @override
  String get exportNoCustomFields => 'Tidak ada bidang khusus';

  @override
  String get exportNoPrintLayouts =>
      'Belum ada tata letak cetak. Muat tata letak bawaan, atau buat di Prasetel Dokumen.';

  @override
  String get exportEnterFileNameFirst =>
      'Masukkan nama berkas terlebih dahulu.';

  @override
  String exportShareFailed(String error) {
    return 'Tidak dapat membagikan ekspor: $error';
  }

  @override
  String get exportFormatOptionsTitle => 'Opsi format';

  @override
  String get exportFormatOptions => 'Opsi format';

  @override
  String get exportConcatenateMultiEntry => 'Gabungkan catatan multientri';

  @override
  String get exportFieldNamesOnly => 'Hanya nama bidang untuk header';

  @override
  String get exportSelectFieldsTitle => 'Pilih bidang';

  @override
  String get exportClearAll => 'Hapus semua';

  @override
  String get exportRequired => 'Wajib';

  @override
  String get dataTableMoreActions => 'Tindakan lainnya';

  @override
  String dataTableNoMatches(String records) {
    return 'Tidak ada $records yang cocok dengan pencarian dan filter.';
  }

  @override
  String dataTableNoRecordsYet(String records) {
    return 'Belum ada $records.';
  }

  @override
  String dataTableNoRecordsForTaxaYet(String records, String taxa) {
    return 'Belum ada $records untuk $taxa.';
  }

  @override
  String dataTableProjectNoRecordsForTaxa(String records, String taxa) {
    return 'Proyek ini tidak memiliki $records untuk $taxa.';
  }

  @override
  String dataTableProjectNoRecordsYet(String records) {
    return 'Proyek ini belum memiliki $records.';
  }

  @override
  String get dataTableSaved => 'Tersimpan.';

  @override
  String dataTableLoadError(String records) {
    return 'Tidak dapat memuat $records.';
  }

  @override
  String get dataTableSomeChangesFailed =>
      'Beberapa perubahan tidak dapat disimpan. Periksa sel yang ditandai.';

  @override
  String get dataTableNoMoreMatches => 'Tidak ada kecocokan lagi.';

  @override
  String get dataTableNoEarlierMatches => 'Tidak ada kecocokan sebelumnya.';

  @override
  String get dataTableCellCannotBeReplaced => 'Sel ini tidak dapat diganti.';

  @override
  String dataTableReadForReplaceError(String error) {
    return 'Tidak dapat membaca catatan untuk diganti: $error';
  }

  @override
  String get dataTableNothingToReplace => 'Tidak ada yang perlu diganti.';

  @override
  String get dataTableReplaceAllTitle => 'Ganti semua?';

  @override
  String dataTableReplaceAllBody(String values, String records) {
    return 'Ganti $values di $records?';
  }

  @override
  String dataTableValueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nilai',
    );
    return '$_temp0';
  }

  @override
  String dataTableRecordCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count catatan',
    );
    return '$_temp0';
  }

  @override
  String get dataTableAutoSaveWrites =>
      'Simpan otomatis langsung menuliskannya.';

  @override
  String get dataTableWaitForSave => 'Perubahan menunggu Simpan.';

  @override
  String dataTableReplaced(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nilai diganti.',
    );
    return '$_temp0';
  }

  @override
  String dataTableSkippedChoices(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nilai tarik-turun dilewati; pilih dari daftarnya.',
    );
    return '$_temp0';
  }

  @override
  String dataTableInvalidValues(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nilai tidak sesuai dengan bidangnya.',
    );
    return '$_temp0';
  }

  @override
  String get dataTablePickDate => 'Pilih tanggal';

  @override
  String get dataTablePickTime => 'Pilih waktu';

  @override
  String get dataTableSaveChangesTitle => 'Simpan perubahan Anda?';

  @override
  String dataTableUnsavedChanges(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ada $count perubahan yang belum disimpan di tabel ini.',
    );
    return '$_temp0';
  }

  @override
  String get dataTableFindField => 'Cari bidang';

  @override
  String dataTableFieldsShown(int count, int total) {
    return '$count dari $total bidang ditampilkan';
  }

  @override
  String get dataTableComputedNotSearchable =>
      'Dihitung saat ekspor: tidak dapat dicari atau diurutkan';

  @override
  String get dataTableShowAll => 'Tampilkan semua';

  @override
  String get dataTableAutoSaveTooltip =>
      'Simpan setiap perubahan saat Anda menerapkannya. Batalkan dengan Ctrl+Z atau ⌘Z selama tabel ini terbuka.';

  @override
  String get dataTableAutoSave => 'Simpan otomatis';

  @override
  String get dataTableDiscardChanges => 'Buang perubahan';

  @override
  String get dataTableRetrySave => 'Coba simpan lagi';

  @override
  String get dataTableEditModeOn => 'Mode sunting aktif (Ctrl+E atau ⌘E)';

  @override
  String get dataTableEditModeOff => 'Mode sunting nonaktif (Ctrl+E atau ⌘E)';

  @override
  String dataTableCellsNeedAttention(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sel perlu diperhatikan',
    );
    return '$_temp0';
  }

  @override
  String dataTableUnsavedChangeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count perubahan belum disimpan',
    );
    return '$_temp0';
  }

  @override
  String get dataTableAllChangesSaved => 'Semua perubahan tersimpan';

  @override
  String dataTableColumnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kolom',
    );
    return '$_temp0';
  }

  @override
  String dataTableExportSummary(String records, String columns) {
    return '$records × $columns, dengan pencarian, filter, urutan, dan kolom yang terlihat saat ini.';
  }

  @override
  String get dataTableColumnHeaders => 'Header kolom';

  @override
  String get dataTableDwcOnly => 'Hanya kolom yang dipetakan ke Darwin Core';

  @override
  String get dataTableDwcOnlyBody =>
      'Abaikan kolom tanpa istilah Darwin Core. Jika tidak, kolom tetap memakai kunci NAHPU.';

  @override
  String dataTableReadProgress(int count, int total) {
    return 'Membaca $count dari $total catatan';
  }

  @override
  String dataTableScopeChip(String label, int count) {
    return '$label ($count)';
  }

  @override
  String get dataTableClearFilters => 'Hapus filter';

  @override
  String dataTableBetweenValues(String low, String high) {
    return '$low dan $high';
  }

  @override
  String get dataTableFilterRules => 'Aturan filter';

  @override
  String get dataTableFilterRulesBody =>
      'Tampilkan catatan yang cocok dengan semua aturan.';

  @override
  String get dataTableAddRule => 'Tambah aturan';

  @override
  String get dataTableEnterValueEveryRule =>
      'Masukkan nilai untuk setiap aturan.';

  @override
  String get dataTableEnterDates => 'Masukkan tanggal sebagai YYYY-MM-DD.';

  @override
  String get dataTableEnterTimes => 'Masukkan waktu sebagai HH:MM.';

  @override
  String get dataTableChooseListed => 'Pilih salah satu nilai yang tercantum.';

  @override
  String get dataTableEnterNumber => 'Masukkan angka.';

  @override
  String get dataTableComputedNotFilterable =>
      'Dihitung saat ekspor; tidak dapat difilter';

  @override
  String get dataTableRemoveRule => 'Hapus aturan';

  @override
  String get dataTableReplacingNeedsEditMode =>
      'Penggantian memerlukan mode sunting.';

  @override
  String get dataTableMatchCase => 'Cocokkan huruf besar/kecil';

  @override
  String get dataTableWholeCell => 'Seluruh sel';

  @override
  String get dataTablePreviousMatch => 'Kecocokan sebelumnya';

  @override
  String get dataTableNextMatch => 'Kecocokan berikutnya';

  @override
  String get dataTableTurnOnEditMode => 'Aktifkan mode sunting';

  @override
  String get dataTableReplaceAll => 'Ganti semua';

  @override
  String get dataTableNoMatchesShort => 'Tidak ada kecocokan';

  @override
  String dataTableFoundCount(int count) {
    return '$count ditemukan';
  }

  @override
  String dataTableMatchOf(int current, int total) {
    return '$current dari $total';
  }

  @override
  String get dataTableAllVisibleColumns => 'Semua kolom yang terlihat';

  @override
  String dataTableColumnReadOnly(String column) {
    return '$column hanya-baca di sini.';
  }

  @override
  String dataTableSkippedOffList(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nilai yang tidak ada di daftarnya dilewati.',
    );
    return '$_temp0';
  }

  @override
  String get dataTableChangeFishTypeTitle => 'Ubah jenis catatan ikan?';

  @override
  String dataTableSexClears(String fields) {
    return 'Ini menghapus $fields yang tidak lagi berlaku untuk jenis kelamin baru.';
  }

  @override
  String get dataTableFishTypeChangeBody =>
      'Beralih antara individu dan lot mengubah pengukuran yang berlaku.';

  @override
  String dataTableSkippedReadOnly(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sel hanya-baca atau tertaut dilewati.',
    );
    return '$_temp0';
  }

  @override
  String dataTableCopiedCells(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sel disalin.',
    );
    return '$_temp0';
  }

  @override
  String get dataTableSwitchToEditToPaste =>
      'Beralih ke mode sunting untuk menempel.';

  @override
  String dataTablePastedSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ditempel; $count sel hanya-baca atau tertaut dilewati.',
    );
    return '$_temp0';
  }

  @override
  String get dataTablePastedCutOff => 'Ditempel; terpotong di tepi halaman.';

  @override
  String dataTablePastedSkippedAndCutOff(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Ditempel; $count sel hanya-baca atau tertaut dilewati dan terpotong di tepi halaman.',
    );
    return '$_temp0';
  }

  @override
  String get dataTableComputedField =>
      'Dihitung saat ekspor: tidak dapat dicari, diurutkan, atau difilter.';

  @override
  String get dataTableLinkedDataHint =>
      'Data tertaut: klik dua kali atau tekan F2 untuk menyunting.';

  @override
  String get dataTableReadOnlyHere => 'Hanya-baca di sini.';

  @override
  String get dataTableOpenForm => 'Buka formulir';

  @override
  String dataTableLinkCurrent(String value) {
    return 'Saat ini: $value.';
  }

  @override
  String get dataTableLoadChoicesError => 'Tidak dapat memuat pilihan.';

  @override
  String get dataTableLinkCatalogerNote =>
      'Nomor lapangan mengikuti katalogis baru. Pengidentifikasi dan preparator juga berubah jika sebelumnya adalah katalogis lama.';

  @override
  String get dataTableLinkEventNote =>
      'Metode koleksi dan personel dihapus, dan koordinat mengikuti situs kegiatan baru.';

  @override
  String get dataTableLinkTaxonNote =>
      'Ordo, famili, genus, dan epitet semuanya berasal dari takson yang dipilih.';

  @override
  String dataTableSaveError(String error) {
    return 'Tidak dapat menyimpan: $error';
  }

  @override
  String get dataTableNothingMatches => 'Tidak ada yang cocok.';

  @override
  String dataTableNotLinked(String noun) {
    String _temp0 = intl.Intl.selectLogic(noun, {
      'site': 'Catatan ini belum ditautkan ke situs.',
      'other': 'Catatan ini belum ditautkan ke kegiatan.',
    });
    return '$_temp0';
  }

  @override
  String dataTableLinkedLoadError(String noun) {
    String _temp0 = intl.Intl.selectLogic(noun, {
      'site': 'Tidak dapat memuat situs.',
      'other': 'Tidak dapat memuat kegiatan.',
    });
    return '$_temp0';
  }

  @override
  String dataTableLinkShared(String noun, int count) {
    String _temp0 = intl.Intl.selectLogic(noun, {
      'site':
          'Perubahan berlaku untuk semua catatan yang ditautkan ke situs ini ($count).',
      'other':
          'Perubahan berlaku untuk semua catatan yang ditautkan ke kegiatan ini ($count).',
    });
    return '$_temp0';
  }

  @override
  String get dataTableSomeChangesNotSaved =>
      'Beberapa perubahan tidak dapat disimpan.';

  @override
  String get dataTablePageRangeEmpty => '0 dari 0';

  @override
  String dataTablePageRange(String first, String last, String total) {
    return '$first–$last dari $total';
  }

  @override
  String get dataTableRowsPerPage => 'Baris per halaman';

  @override
  String get dataTableFirstPage => 'Halaman pertama';

  @override
  String get dataTablePreviousPage => 'Halaman sebelumnya';

  @override
  String get dataTableNextPage => 'Halaman berikutnya';

  @override
  String get dataTableLastPage => 'Halaman terakhir';

  @override
  String dataTableSearchIn(String target) {
    return 'Cari $target';
  }

  @override
  String get dataTableRefresh => 'Muat ulang';

  @override
  String get dataTableAddFieldRules => 'Tambah aturan bidang';

  @override
  String get dataTableEditFieldRules => 'Sunting aturan bidang';

  @override
  String get dataTableFilters => 'Filter';

  @override
  String get dataTableAllVisibleFields => 'Semua bidang yang terlihat';

  @override
  String get dataTableSearchingAllFields =>
      'Mencari di semua bidang yang terlihat';

  @override
  String dataTableSearchingField(String field) {
    return 'Mencari di $field';
  }

  @override
  String get dataTableFilterOpIs => 'adalah';

  @override
  String get dataTableFilterOpContains => 'berisi';

  @override
  String get dataTableFilterOpStartsWith => 'diawali';

  @override
  String get dataTableFilterOpGreaterThan => 'lebih dari';

  @override
  String get dataTableFilterOpLessThan => 'kurang dari';

  @override
  String get dataTableFilterOpBetween => 'antara';

  @override
  String get dataTableFilterOpIsEmpty => 'kosong';

  @override
  String get dataTableFilterOpIsNotEmpty => 'tidak kosong';

  @override
  String get dataTableQuickMissingTaxon => 'Tanpa takson';

  @override
  String get dataTableQuickNoFieldNumber => 'Tanpa nomor lapangan';

  @override
  String get dataTableQuickNoEvent => 'Tanpa kegiatan';

  @override
  String get dataTableQuickHasParts => 'Ada bagian';

  @override
  String get dataTableQuickHasMedia => 'Ada media';

  @override
  String get dataTableQuickNoTissueId => 'Tanpa ID jaringan';

  @override
  String get dataTableQuickNoParasiteId => 'Tanpa ID parasit';

  @override
  String get dataTableQuickNoCoordinates => 'Tanpa koordinat';

  @override
  String get dataTableQuickNoLocality => 'Tanpa lokalitas';

  @override
  String get dataTableQuickNoSpecimens => 'Tanpa spesimen';

  @override
  String get dataTableQuickNoEndDate => 'Tanpa tanggal selesai';

  @override
  String get dataTableQuickNoSite => 'Tanpa situs';

  @override
  String dataTableProjectScopeOne(String name) {
    return 'Proyek: $name';
  }

  @override
  String dataTableProjectScopeTwo(String first, String second) {
    return 'Proyek: $first, $second';
  }

  @override
  String dataTableProjectScopeMany(int count) {
    return '$count proyek';
  }

  @override
  String get siteImportFieldGpsUnit => 'Unit GPS';

  @override
  String get projectTissueCustomLabels => 'Sesuaikan label sel';

  @override
  String get projectTissueBoxSeparator => 'Pemisah kotak';

  @override
  String get projectTissueRowColumnSeparator => 'Pemisah baris–kolom';

  @override
  String get projectTissueZeroPad => 'Isi angka dengan nol';

  @override
  String projectTissueLabelExample(String example) {
    return 'Contoh: $example';
  }
}
