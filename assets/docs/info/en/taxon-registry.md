---
title: "Taxon registry"
sidebar:
  order: 0
---

The registry contains the taxonomic names available to this project. A taxon is a name, not a specimen; specimen records point to a registered taxon for their identification.

Add taxa manually or import `.xlsx`, `.csv`, or `.tsv` files. Manual registration asks for a `Taxon rank` first and then shows the name fields down to that rank. Imports accept class, order, family, genus, species, and subspecies records. Each row requires the classification fields from class through its selected rank. Review every detected column mapping before import.

A file may omit `Taxon rank`, `Kingdom`, `Phylum`, and `Class`. If `Class` is not mapped, select the supported class shared by all rows in `Select a class`. NAHPU fills missing kingdom and phylum values for known classes and preserves supplied values. Without a rank, order, family, genus, and specific epithet must be complete; the rank is species, or subspecies when a subspecific epithet is present. For other classes, include `Taxon rank`, `Kingdom`, `Phylum`, `Class`, and every classification column through the selected rank, with values in every required cell. Files containing multiple classes need a `Class` column.

The panel counts the distinct orders, families, and full species names held in the registry. A total taxa count appears when the registry also holds names above species rank. These are registry counts; the statistics panel reports the taxa that specimen records actually use.

## Darwin Core context

A registered name supplies the identification terms of an export: `dwc:taxonID`, `dwc:kingdom`, `dwc:phylum`, `dwc:class`, `dwc:order`, `dwc:family`, `dwc:genus`, `dwc:specificEpithet`, `dwc:infraspecificEpithet`, `dwc:taxonRank`, `dwc:scientificNameAuthorship`, `dwc:vernacularName`, and `dwc:taxonRemarks`.
