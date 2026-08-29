---
title: "Registri takson"
sidebar:
  order: 0
---

Registri berisi nama takson yang tersedia untuk proyek ini. Takson adalah sebuah nama, bukan spesimen; catatan spesimen menunjuk ke takson terdaftar untuk identifikasinya.

Tambahkan takson secara manual atau impor berkas `.xlsx`, `.csv`, atau `.tsv`. Pendaftaran manual meminta `Taxon rank` terlebih dahulu, lalu menampilkan kolom nama sampai tingkat tersebut. Impor dapat mendaftarkan kelas, ordo, famili, genus, spesies, dan subspesies bila kolom `taxon rank` disertakan. Tingkat yang kosong dianggap spesies hanya bila kelas, ordo, famili, genus, dan epitet spesifik lengkap; selain itu, tambahkan tingkat takson. Setiap baris memerlukan kolom klasifikasi dari kelas sampai tingkat yang dipilih. Periksa setiap pemetaan kolom yang terdeteksi sebelum mengimpor.

Panel menghitung ordo, famili, dan nama spesies lengkap yang berbeda di dalam registri. Jumlah total takson muncul bila registri juga memuat nama di atas tingkat spesies. Ini adalah hitungan registri; panel statistik melaporkan takson yang benar-benar dipakai catatan spesimen.

## Konteks Darwin Core

Nama terdaftar mengisi istilah identifikasi pada hasil ekspor: `dwc:taxonID`, `dwc:kingdom`, `dwc:phylum`, `dwc:class`, `dwc:order`, `dwc:family`, `dwc:genus`, `dwc:specificEpithet`, `dwc:infraspecificEpithet`, `dwc:taxonRank`, `dwc:scientificNameAuthorship`, `dwc:vernacularName`, dan `dwc:taxonRemarks`.
