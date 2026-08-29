---
title: "Catatan umum spesimen"
sidebar:
  order: 0
---

Catatan umum menyimpan pengenal kerja spesimen, orang yang bertanggung jawab atasnya, taksonnya, serta konteks preparasi dan kondisinya. Bergantung pada pengaturan proyek, Field ID menggabungkan inisial seorang Cataloger dengan nomor lapangan pribadi, atau menggabungkan awalan dan akhiran proyek dengan nomor katalog proyek.

Pilih takson dari registri proyek. Takson adalah identifikasinya; catatan spesimen adalah kejadian terdokumentasi dari suatu organisme. Catat metode dan tingkat keyakinan identifikasi bila identifikasinya masih sementara, dan tambahkan Museum ID setelah lembaga menetapkannya.

Catat Cataloger, Preparator, dan Determiner sesuai pekerjaan yang benar-benar dilakukan masing-masing. Jelaskan kondisi pada saat preparasi berdasarkan bukti langsung, dan simpan tanggal serta waktu pengumpulan dan preparasi bila diketahui.

## Konteks Darwin Core

Catatan spesimen diekspor sebagai `dwc:Occurrence`: pengenal internalnya menjadi `dwc:occurrenceID` dan Field ID menjadi `dwc:catalogNumber`. NAHPU menulis `dwc:basisOfRecord` sebagai `PreservedSpecimen`, atau sebagai `HumanObservation` bila kondisinya `Released`. Metode identifikasi dipetakan ke `dwc:identificationType` dan tingkat keyakinan identifikasi ke `dwc:identificationVerificationStatus`.
