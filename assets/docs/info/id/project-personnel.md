---
title: "Personel proyek"
sidebar:
  order: 0
---

Catatan personel mewakili orang-orang yang terlibat dalam proyek. Seseorang disimpan satu kali di basis data dan dapat ditugaskan ke beberapa proyek. Mengeluarkan seseorang dari panel ini hanya menghapus penugasannya pada proyek; penghapusan permanen dikelola di Settings.

## Peran di NAHPU

- **Cataloger:** mencatat data spesimen dan dapat memberikan inisial serta nomor lapangan pribadi untuk Field ID.
- **Determiner only:** mengidentifikasi spesimen, tetapi tidak mengatalog atau mempreparasinya.
- **Preparator only:** mempreparasi spesimen, tetapi tidak mengatalognya.
- **None:** ikut dalam kerja lapangan tanpa peran perawatan spesimen.

Ini adalah peran alur kerja NAHPU yang menentukan pada apa seseorang dapat ditugaskan di dalam aplikasi. Peran ini berbeda dari peran yang dilaporkan dalam hasil ekspor, yang mengikuti hubungan sebenarnya pada setiap catatan.

## Konteks Darwin Core

Seseorang diekspor sebagai agen dengan pengenal `dwc:agentID`, yang diambil dari ORCID bila tercatat dan dari pengenal NAHPU bila tidak; keterangan personel menjadi `dwc:agentRemarks`. Hubungan pada catatan spesimen mengisi kolom agen: pengumpul mengisi `dwc:recordedBy` dan `dwc:recordedByID`, sedangkan penentu identifikasi mengisi `dwc:identifiedBy` dan `dwc:identifiedByID`.
