---
title: "Tabular export presets"
sidebar:
  order: 0
---

A tabular export preset saves a repeatable definition: the record type, the specimen taxon group, the selected fields and their order, the generated header format, and how repeated values are written. The output format, file name, and destination are chosen when the export runs.

Repeated values can be written as one column with a separator, or spread into indexed columns such as `field_1`, `field_2`. Test a preset with representative records, including missing and repeated values, before relying on it, and transfer user configurations when collaborators need the same definition.

## Darwin Core context

`Generated header format` chooses how headers are named: `table::fieldName`, `fieldName`, Darwin Core (`dwc:`/`dcterms:`), or the NAHPU namespace. Darwin Core headers are produced only for CSV, TSV, and Excel output, and only for fields that have a Darwin Core equivalent — a field without one keeps its NAHPU name. Repeated values in a Darwin Core export always use the recommended " | " separator.

Map a custom field to a Darwin Core term only when it means the same thing as that term. Matching labels are not enough: a term that is reused for a different concept makes the export harder to interpret than an unmapped NAHPU column.
