---
title: "Taxon registry"
sidebar:
  order: 0
---

The registry contains taxonomic names available to this project. A taxon is not the same as a specimen or `dwc:Occurrence`; specimen records refer to a registered taxon for their identification.

Add taxa manually or import `.xlsx`, `.csv`, or `.tsv` files. Manual registration asks for a `Taxon rank` first and then shows the name fields down to that rank. Imports can also register class, order, family, genus, species, and subspecies records when a `taxon rank` column is included. A missing or blank rank defaults to species only when class, order, family, genus, and specific epithet are complete; otherwise add a rank. Each row requires the classification fields from class through its selected rank. Review every detected column mapping before import.

**Registered taxa** counts names assigned to the project. **Recorded taxa** summarizes taxa referenced by specimen or capture records and changes as records are added.
