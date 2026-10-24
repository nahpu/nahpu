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
  String get projectEditTools => 'Sunting alat';

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
  String projectTissueCellFilled(String cell) {
    return '$cell · terisi';
  }

  @override
  String get projectTissueFilled => 'Terisi';

  @override
  String get projectTissueNext => 'Berikutnya';

  @override
  String get projectTissueTapEmptyCell => 'Ketuk sel kosong untuk melompat';

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
  String get projectTissueWorkListEmpty =>
      'Tidak ada bagian yang belum ditempatkan yang cocok dengan filter jenis jaringan dan pengawetan.';

  @override
  String projectTissueRemaining(int count) {
    return 'Berikutnya · $count tersisa';
  }

  @override
  String get projectTissuePlace => 'Tempatkan';
}
