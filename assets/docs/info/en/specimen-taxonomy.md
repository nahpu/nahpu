---
title: "Specimen taxonomy"
sidebar:
  order: 0
---

Taxonomic fields are filled from the taxon selected in the specimen record. They describe the identification, not the physical specimen.

The taxon registry holds records at any rank, so a specimen that is not yet identified to species can be linked to its family or genus and refined later. Class, order, family, genus, specific epithet, and subspecific epithet follow the registered taxon down to the rank that record represents. Kingdom and phylum come from the registry when recorded, and are inferred from class otherwise.

Edit the taxon registry when the shared name record is wrong; change the specimen’s selected taxon when only that identification is wrong. Preserve scientific-name authorship and identification notes when they are available, and record the responsible Determiner rather than inferring one.

## Darwin Core context

Exports build `dwc:scientificName` from the genus and specific epithet of the selected taxon, and carry the surrounding ranks in `dwc:kingdom` through `dwc:infraspecificEpithet` with `dwc:scientificNameAuthorship`. The determiner fills `dwc:identifiedBy` and `dwc:identifiedByID`.
