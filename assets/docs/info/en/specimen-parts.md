---
title: "Specimen parts"
sidebar:
  order: 0
---

Specimen parts document the physical material derived from or associated with the specimen, such as a skin, skull, skeleton, tissue, organ, or slide. Each part should carry the identifiers needed to match it to its label or container.

Record the preparation type, treatment, count, tissue ID, QR or barcode ID, responsible Preparator, and the date and time the part was taken. Storage type and location, museum permanent and loan numbers, and remarks describe where the material is held and anything unusual about it. Configure the controlled part types and treatments in Settings and use them consistently.

Keep identifiers synchronized with the physical containers. A tissue ID that no longer matches its vial is harder to correct than a missing one.

## Darwin Core context

Each part is exported as a `dwc:MaterialEntity` linked to the specimen occurrence. The preparation type becomes `dwc:materialEntityType`, the tissue ID becomes the material catalog number, a differing QR or barcode ID becomes `dwc:otherCatalogNumbers`, and treatment and additional treatment are joined into `dwc:preparations`. In tabular exports the tissue ID maps to `dwc:materialSampleID` and the count to `dwc:objectQuantity`. Storage and museum fields have no Darwin Core equivalent and keep their NAHPU headers.
