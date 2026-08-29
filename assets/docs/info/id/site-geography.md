---
title: "Geografi lokasi"
sidebar:
  order: 0
---

Geografi menjelaskan di mana lokasi berada, dari negara sampai lokalitas yang spesifik, dengan keterangan untuk konteks yang tidak muat pada kolom bernama. Kolom mana saja yang tampil dapat diatur di Settings.

`Find existing locality` mencocokkan yang Anda ketik dengan semua lokalitas yang sudah tersimpan dalam proyek. Memilih satu saran akan mengisi seluruh hierarki sekaligus, dan setiap kolom juga menyarankan nilai yang sudah pernah dicatat untuk kolom itu. Lokalitas disimpan satu kali dan dipakai bersama antarlokasi, sehingga memakai ulang yang sudah tersimpan mencegah munculnya catatan tempat yang nyaris sama.

Isi nilai sesuai konvensi geografis lembaga yang bertanggung jawab. `Precise Locality` sebaiknya menjelaskan tempat bernama yang spesifik di bawah tingkat kota atau kecamatan. Pertahankan bukti apa adanya saat membakukan nama tempat agar kurator berikutnya dapat memahami sumber aslinya.

## Konteks Darwin Core

Kolom geografi diekspor ke `dwc:country`, `dwc:islandGroup`, `dwc:stateProvince`, `dwc:county`, dan `dwc:municipality`. Lokalitas spesifik diekspor sebagai `dwc:verbatimLocality` karena dicatat apa adanya tanpa dibakukan, dan keterangan menjadi `dwc:locationRemarks`.
