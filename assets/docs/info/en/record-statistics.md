---
title: "Record statistics"
authors: ["Caleb Gordon", "Heru Handika"]
sidebar:
  order: 0
---

The Record Statistics panel summarizes the specimens in the active project and updates automatically as the records change. For a more detailed summary of the project's specimen data, select **Explore more stats** at the bottom of the panel.

**Specimens** is the total number of specimen records. **Species** counts distinct identifications that have both a genus and specific epithet, while **Families** counts distinct nonblank family names referenced by those specimens. Differences in capitalization or surrounding spaces do not create additional species or families.

An unidentified specimen or an identification with an incomplete species name still contributes to **Specimens**, but it does not increase **Species**. A missing family does not increase **Families**.


## Exporting statistics

Open **Explore more stats**, then switch to the **Explore** view. Under **Counts**, choose a measure and grouping, then switch the panel to **Table**. Supported formats are CSV, TSV, Excel, and JSON. **Spatial** exports the same way, with one row per site coordinate.

## Learn more

- [Export Statistics](https://nahpu.app/en/usages/export/export-statistics/)
- [Projects](https://nahpu.app/en/usages/projects/)
