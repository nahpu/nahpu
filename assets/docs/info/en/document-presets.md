---
title: "Document presets"
sidebar:
  order: 0
---

Document settings separate reusable templates from print layouts. A template defines one label, tag, sheet, or document block. A print layout defines the page size and orientation, margins, the template blocks placed on the page, copies, record ordering, and the file settings used when the document is generated.

Create a separate layout for each distinct workflow, and duplicate a known-good preset under a new name before experimenting with it. Preview with representative records, including long text, missing values, and both sides of a duplex template.

`Load defaults` in the options menu, or in an empty list, lets you choose which print layouts and templates bundled with NAHPU to add. Presets that suit any catalog format start checked; presets written for one catalog format, such as the mammal field booklet, skull tags, and voucher labels, start unchecked and are also offered in `Setup NAHPU`. Loading never overwrites a preset with the same name, and any preset can be deleted.

Exporting opens file settings where you name the file, pick a folder, and `Share` it after export. A layout export includes the templates its blocks use unless you turn off `Include linked templates`, and importing that file adds the templates too.

Templates and their layouts are transferred together through user configurations, so move both when a collaborator needs the same output.

When designing a template, you can use bundled fonts or import your own fonts. Fonts are managed in `Documents` > `Fonts`.

Transferred definitions do not include custom fonts or template images. Install the required fonts and add the images on the receiving device, then compare a generated PDF with the intended output.

## Learn more

- [Export Documents](https://nahpu.app/en/usages/export/export-documents/)
- [Export Expressions](https://nahpu.app/en/usages/export/export-expressions/)
