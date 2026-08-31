---
title: "Registri takson"
sidebar:
  order: 0
---

Registri berisi nama takson yang tersedia untuk proyek ini. Takson adalah sebuah nama, bukan spesimen; catatan spesimen menunjuk ke takson terdaftar untuk identifikasinya.

Tambahkan takson secara manual atau impor berkas `.xlsx`, `.csv`, atau `.tsv`. Pendaftaran manual meminta `Taxon rank` terlebih dahulu, lalu menampilkan kolom nama sampai tingkat tersebut. Impor menerima kelas, ordo, famili, genus, spesies, dan subspesies. Setiap baris memerlukan kolom klasifikasi dari kelas sampai tingkat yang dipilih. Periksa setiap pemetaan kolom sebelum mengimpor.

Berkas boleh tidak menyertakan `Taxon rank`, `Kingdom`, `Phylum`, dan `Class`. Jika `Class` belum dipetakan, pilih kelas yang didukung dan sama untuk semua baris melalui `Select the class shared by all rows`. NAHPU mengisi kerajaan dan filum yang kosong untuk kelas yang dikenali serta mempertahankan nilai yang disediakan. Tanpa tingkat takson, ordo, famili, genus, dan epitet spesifik harus lengkap; tingkatnya spesies, atau subspesies jika epitet subspesifik tersedia. Untuk kelas lain, sertakan `Taxon rank`, `Kingdom`, `Phylum`, `Class`, dan semua kolom klasifikasi sampai tingkat yang dipilih, dengan nilai pada setiap sel wajib. Berkas yang berisi beberapa kelas memerlukan kolom `Class`.

Panel menghitung ordo, famili, dan nama spesies lengkap yang berbeda di dalam registri. Jumlah total takson muncul bila registri juga memuat nama di atas tingkat spesies. Ini adalah hitungan registri; panel statistik melaporkan takson yang benar-benar dipakai catatan spesimen.

Untuk impor QR, pilih `Scan QR`, lalu `Single taxon` atau `Multiple taxa`. Satu pemindaian valid membuka pratinjau pada mode tunggal; mode beberapa takson membiarkan kamera terbuka sampai `Done` dipilih. Tinjau dan impor takson yang dipilih untuk menyimpannya. Takson yang sudah ada dinonaktifkan dan tidak pernah ditimpa. Pembatalan mempertahankan impor sebelumnya; sesi yang selesai menggantikannya. Rekaman QR hanya memerlukan tingkat takson yang didukung dan namanya; kode lama menyimpulkan tingkat dari nama paling spesifik. Pemilihan kelas tidak diperlukan. Gunakan kamera; gambar QR dan teks yang ditempel tidak didukung.

## Konteks Darwin Core

Nama terdaftar mengisi istilah identifikasi pada hasil ekspor: `dwc:taxonID`, `dwc:kingdom`, `dwc:phylum`, `dwc:class`, `dwc:order`, `dwc:family`, `dwc:genus`, `dwc:specificEpithet`, `dwc:infraspecificEpithet`, `dwc:taxonRank`, `dwc:scientificNameAuthorship`, `dwc:vernacularName`, dan `dwc:taxonRemarks`.
