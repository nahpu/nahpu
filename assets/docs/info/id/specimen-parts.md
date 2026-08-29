---
title: "Bagian spesimen"
sidebar:
  order: 0
---

Bagian spesimen mendokumentasikan material fisik yang berasal dari atau terkait dengan spesimen, seperti kulit, tengkorak, kerangka, jaringan, organ, atau preparat kaca. Setiap bagian sebaiknya membawa pengenal yang diperlukan agar cocok dengan label atau wadahnya.

Catat tipe preparasi, perlakuan, jumlah, tissue ID, kode QR atau kode batang, Preparator yang bertanggung jawab, serta tanggal dan waktu bagian itu diambil. Tipe dan lokasi penyimpanan, nomor museum permanen dan pinjaman, serta keterangan menjelaskan di mana material disimpan dan apa yang tidak biasa padanya. Atur tipe bagian dan perlakuan terkontrol di Settings, lalu gunakan secara konsisten.

Jaga agar pengenal tetap selaras dengan wadah fisiknya. Tissue ID yang tidak lagi cocok dengan vialnya lebih sulit diperbaiki daripada yang belum diisi.

## Konteks Darwin Core

Setiap bagian diekspor sebagai `dwc:MaterialEntity` yang tertaut pada kejadian spesimen. Tipe preparasi menjadi `dwc:materialEntityType`, tissue ID menjadi nomor katalog material, kode QR atau kode batang yang berbeda menjadi `dwc:otherCatalogNumbers`, dan perlakuan beserta perlakuan tambahan digabung menjadi `dwc:preparations`. Dalam ekspor tabel, tissue ID dipetakan ke `dwc:materialSampleID` dan jumlah ke `dwc:objectQuantity`. Kolom penyimpanan dan museum tidak memiliki padanan Darwin Core dan tetap memakai tajuk NAHPU.
