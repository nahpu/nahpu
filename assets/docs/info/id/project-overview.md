---
title: "Ikhtisar proyek"
sidebar:
  order: 0
---

Proyek mengelompokkan personel, takson, lokasi, kegiatan pengumpulan, catatan spesimen, narasi, dan media yang dibuat untuk satu pekerjaan. Gunakan `Edit` untuk memperbarui metadata deskriptifnya, dan `Export info` atau `Show QR` untuk membagikan identitasnya saja.

## UUID proyek

NAHPU memberikan pengenal unik universal (UUID) kepada setiap proyek baru. Mengimpor informasi proyek mempertahankan UUID tersebut sehingga perangkat yang berkolaborasi dapat mengenali salinan proyek yang sama. Informasi proyek tidak mencakup catatan atau media; gunakan transfer proyek bila keduanya juga perlu dipindahkan.

Jaga agar deskripsi proyek tetap ringkas. Catat konteks harian yang rinci di Narratives.

## Mencadangkan di lapangan

`Export project` adalah cadangan lapangan harian. Ukurannya lebih kecil dan prosesnya lebih cepat daripada cadangan basis data serta lebih hemat baterai, dan `Merge project` membacanya kembali di perangkat lain, sehingga perangkat yang hilang atau rusak paling banyak menghabiskan satu hari kerja. Pilih ZIP atau TAR.GZ agar media ikut terbawa, atau ekspor ringan `JSON.GZ` bila unggahannya harus kecil.

Simpan `Backup database` untuk pemeriksaan mingguan dan untuk saat sebelum penggabungan apa pun. Cadangan itu menyalin seluruh instalasi, bukan satu proyek saja.

## Konteks Darwin Core

UUID proyek menjadi pengenal kumpulan data dalam hasil ekspor dan ditulis ke `dwc:datasetID`.
