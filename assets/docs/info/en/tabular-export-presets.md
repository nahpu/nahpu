---
title: "Tabular export presets"
sidebar:
  order: 0
---

A tabular export preset saves a repeatable definition: the record type, the specimen taxon group, the selected fields and their order, the generated header format, and how repeated values are written. The output format, file name, and destination are chosen during exports.

`Generated header format` chooses how headers are named: `table::fieldName`, `fieldName`, Darwin Core, or the NAHPU namespace. Repeated values can be written as one column with a separator, or spread into indexed columns such as `field_1`, `field_2`. Test a preset with representative records, including missing and repeated values, before relying on it, and transfer user configurations when collaborators need the same definition.

`Add custom field` writes fields and literal text, or text alone, into one column, such as `[personnel::initial]-[specimen::fieldNumber]` or a constant institution code.

Settings are saved as you change them, but the preset name is not: type a new name and select `Rename` to commit it. Export a single preset from its row, or all presets from the options menu; either file imports through the same action. Exporting opens file settings where you name the file, pick a folder, and `Share` it after export.

`Load defaults` in the options menu, or in an empty list, lets you choose which tabular presets bundled with NAHPU to add. Presets written for one catalog format, such as Non-volant mammals, start unchecked and are also offered in `Setup NAHPU`. Loading never overwrites a preset with the same name, and any preset can be deleted.

A header labeled Darwin Core does not by itself validate the exported data. Review field meaning, units, and repeated values. Tabular exports are for downstream use, not for restoring a NAHPU project.

## Learn more

- [Export Records](https://nahpu.app/en/usages/export/export-records/)
- [Bundle Records](https://nahpu.app/en/usages/export/export-bundles/)
- [Export Expressions](https://nahpu.app/en/usages/export/export-expressions/)
