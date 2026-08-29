---
title: "Sampling effort"
sidebar:
  order: 0
---

Effort records describe how sampling was carried out. Add each method separately and record the number of units, the brand and model of the equipment, its size or dimensions, and notes.

Use the same units and controlled method names throughout the project so efforts can be compared. Duration, area, and any other magnitude without a dedicated field belong in the notes. State enough context for another person to understand the effort without inferring missing details.

## Darwin Core context

In a tabular export, the method maps to `dwc:samplingProtocol` and the notes to `dwc:samplingEffort`; count, brand, and size have no Darwin Core equivalent and keep their NAHPU headers. Darwin Core Archives and Data Packages carry the event’s own activity and notes instead, so record anything an archive must report at the event level as well.
