---
title: "Partes del espécimen"
sidebar:
  order: 0
---

Las partes del espécimen documentan el material físico derivado del espécimen o asociado a él, como piel, cráneo, esqueleto, tejido, órgano o portaobjetos. Cada parte debe llevar los identificadores necesarios para corresponder con su etiqueta o su recipiente.

Registre el tipo de preparación, el tratamiento, el conteo, el tissue ID, el código QR o de barras, el Preparator responsable y la fecha y hora en que se tomó la parte. El tipo y la ubicación de almacenamiento, los números de museo permanente y de préstamo, y las observaciones describen dónde se conserva el material y qué tiene de inusual. Configure en Settings los tipos de parte y los tratamientos controlados y úselos de forma consistente.

Mantenga los identificadores sincronizados con los recipientes físicos. Un tissue ID que ya no corresponde con su vial es más difícil de corregir que uno faltante.

## Contexto de Darwin Core

Cada parte se exporta como un `dwc:MaterialEntity` vinculado a la ocurrencia del espécimen. El tipo de preparación se convierte en `dwc:materialEntityType`, el tissue ID en el número de catálogo del material, un código QR o de barras distinto en `dwc:otherCatalogNumbers`, y el tratamiento y el tratamiento adicional se unen en `dwc:preparations`. En las exportaciones tabulares, el tissue ID se asigna a `dwc:materialSampleID` y el conteo a `dwc:objectQuantity`. Los campos de almacenamiento y museo no tienen equivalente en Darwin Core y conservan sus encabezados de NAHPU.
