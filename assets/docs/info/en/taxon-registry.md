---
title: "Taxon registry"
sidebar:
  order: 0
---

The registry contains the taxonomic names available to this project. A taxon is a name, not a specimen; specimen records point to a registered taxon for their identification.

Add taxa manually or import `.xlsx`, `.csv`, or `.tsv` files. Manual registration asks for a `Taxon rank` first and then shows the name fields down to that rank. Imports can register class, order, family, genus, species, and subspecies records when a `taxon rank` column is included. A missing or blank rank defaults to species only when class, order, family, genus, and specific epithet are complete; otherwise add a rank. Each row requires the classification fields from class through its selected rank. Review every detected column mapping before import.

The panel counts the distinct orders, families, and full species names held in the registry. A total taxa count appears when the registry also holds names above species rank. These are registry counts; the statistics panel reports the taxa that specimen records actually use.

## Darwin Core context

A registered name supplies the identification terms of an export: `dwc:taxonID`, `dwc:kingdom`, `dwc:phylum`, `dwc:class`, `dwc:order`, `dwc:family`, `dwc:genus`, `dwc:specificEpithet`, `dwc:infraspecificEpithet`, `dwc:taxonRank`, `dwc:scientificNameAuthorship`, `dwc:vernacularName`, and `dwc:taxonRemarks`.
