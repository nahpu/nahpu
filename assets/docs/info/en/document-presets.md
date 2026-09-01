---
title: "Document presets"
sidebar:
  order: 0
---

Document settings separate reusable templates from print layouts. A template defines one label, tag, sheet, or document block. A print layout defines the page size and orientation, margins, the template blocks placed on the page, copies, record ordering, and the file settings used when the document is generated.

Create a separate layout for each distinct workflow, and duplicate a known-good preset under a new name before experimenting with it. Preview with representative records, including long text, missing values, and both sides of a duplex template.

A generated PDF is for printing or presentation. It is not a structured data export and not a restorable backup; use a tabular or Darwin Core export for data, and a project transfer or database backup for recovery. Templates and their layouts are transferred together through user configurations, so move both when a collaborator needs the same output.

Fonts are managed separately under `Documents` > `Fonts`. Bundled fonts are always available; a font you install from a `.ttf` or `.otf` file lives on that installation only, so a template that uses one asks for a replacement when it is imported elsewhere. A template can be renamed in the template editor settings, and a print layout from the name field at the top of `Edit Preset`. Export a single template or layout from its row, or all of them from the options menu; either file imports through the same action.
