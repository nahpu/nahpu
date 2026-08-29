---
title: "Taksonomi spesimen"
sidebar:
  order: 0
---

Kolom taksonomi diisi dari takson yang dipilih pada catatan spesimen. Kolom-kolom itu menjelaskan identifikasinya, bukan spesimen fisiknya.

Registri takson memuat catatan pada tingkat mana pun, sehingga spesimen yang belum teridentifikasi sampai spesies dapat ditautkan ke famili atau genusnya dan diperinci kemudian. Kelas, ordo, famili, genus, epitet spesifik, dan epitet subspesifik mengikuti takson terdaftar sampai tingkat yang diwakili catatan itu. Kingdom dan filum diambil dari registri bila tercatat, dan disimpulkan dari kelas bila tidak.

Ubah registri takson bila catatan nama bersamanya keliru; ubah takson yang dipilih pada spesimen bila hanya identifikasi itu yang keliru. Pertahankan kepengarangan nama ilmiah dan catatan identifikasi bila tersedia, serta catat Determiner yang bertanggung jawab alih-alih menduganya.

## Konteks Darwin Core

Hasil ekspor menyusun `dwc:scientificName` dari genus dan epitet spesifik takson yang dipilih, serta membawa tingkat di sekitarnya pada `dwc:kingdom` sampai `dwc:infraspecificEpithet` beserta `dwc:scientificNameAuthorship`. Penentu identifikasi mengisi `dwc:identifiedBy` dan `dwc:identifiedByID`.
