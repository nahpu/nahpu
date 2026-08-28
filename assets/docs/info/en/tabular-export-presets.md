---
title: "Tabular export presets"
sidebar:
  order: 0
---

A tabular export preset saves a repeatable record type, taxon scope, field selection, ordering, header style, and repeated-value behavior. The output format, filename, and destination are chosen when the export runs.

Use standard mappings only where the NAHPU field has the same meaning as the target term. Darwin Core headers such as `dwc:scientificName` or `dwc:samplingProtocol` must not be assigned merely because labels look similar. Test a preset with representative records, including missing and repeated values, and transfer user configurations when collaborators need the same export definition.
