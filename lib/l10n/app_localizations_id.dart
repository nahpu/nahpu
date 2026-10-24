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
  String settingsMapKindUnavailableOnLinux(String kind) {
    return '$kind · tidak tersedia di Linux';
  }

  @override
  String get settingsMapConfigureLayer => 'Atur lapisan';

  @override
  String get settingsMapShowLayer => 'Tampilkan lapisan';

  @override
  String get settingsMapLayerUnavailableOnLinux =>
      'Lapisan ini tidak tersedia di Linux';

  @override
  String get settingsMapLayerTypeUnavailableOnLinux =>
      'Jenis lapisan ini tidak tersedia di Linux.';

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
  String get settingsMapSupportedFormatsLinux =>
      'Di Linux mendukung GeoJSON, Shapefile WGS84 dalam ZIP, dan PMTiles raster.';

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
}
