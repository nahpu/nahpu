---
title: "Prasetel ekspor tabel"
sidebar:
  order: 0
---

Prasetel ekspor tabel menyimpan definisi yang dapat diulang: jenis catatan, kelompok takson spesimen, kolom yang dipilih beserta urutannya, format tajuk yang dihasilkan, dan cara nilai berulang dituliskan. Format keluaran, nama berkas, dan tujuan penyimpanan dipilih saat ekspor dijalankan.

`Generated header format` menentukan penamaan tajuk: `table::fieldName`, `fieldName`, Darwin Core, atau namespace NAHPU. Nilai berulang dapat ditulis dalam satu kolom dengan pemisah, atau disebar menjadi kolom berindeks seperti `field_1`, `field_2`. Uji sebuah prasetel dengan catatan yang representatif, termasuk nilai yang kosong dan berulang, sebelum mengandalkannya, lalu pindahkan konfigurasi pengguna bila kolaborator memerlukan definisi yang sama.

`Add custom field` menulis field dan teks literal, atau teks saja, ke dalam satu kolom, misalnya `[personnel::initial]-[specimen::fieldNumber]` atau kode institusi yang konstan.

Pengaturan tersimpan otomatis saat Anda mengubahnya, tetapi nama prasetel tidak: ketik nama baru lalu pilih `Rename` untuk menyimpannya. Ekspor satu prasetel dari barisnya, atau semua prasetel dari menu opsi; kedua berkas diimpor dengan tindakan yang sama. Ekspor membuka pengaturan berkas tempat Anda memberi nama berkas, memilih folder, dan membagikannya dengan `Share` setelah ekspor.

`Load defaults` di menu opsi, atau di daftar yang kosong, memungkinkan Anda memilih prasetel tabel bawaan NAHPU yang akan ditambahkan. Prasetel yang ditulis untuk satu format katalog, seperti Non-volant mammals, belum dicentang dan juga ditawarkan di `Setup NAHPU`. Tindakan ini tidak pernah menimpa prasetel bernama sama, dan setiap prasetel dapat dihapus.

Header Darwin Core tidak dengan sendirinya memvalidasi data ekspor. Tinjau makna bidang, satuan, dan nilai berulang. Ekspor tabel digunakan untuk pemrosesan selanjutnya, bukan untuk memulihkan proyek NAHPU.

## Pelajari lebih lanjut

- [Ekspor Catatan](https://nahpu.app/id/usages/export/export-records/)
- [Paket Catatan](https://nahpu.app/id/usages/export/export-bundles/)
- [Ekspresi Ekspor](https://nahpu.app/id/usages/export/export-expressions/)
