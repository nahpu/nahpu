---
title: "Record statistics"
sidebar:
  order: 0
---

Record statistics summarize the active project and update as its records or referenced taxonomy change.

**Specimens** is the total number of specimen records. **Species** counts distinct identifications that have both a genus and specific epithet, while **Families** counts distinct nonblank family names referenced by those specimens. Differences in capitalization or surrounding spaces do not create additional species or families.

An unidentified specimen or an identification with an incomplete species name still contributes to **Specimens**, but it does not increase **Species**. A missing family does not increase **Families**. These counts describe the names used by specimen records, not every name available in the taxon registry.

The panel opens on **Top recorded species**, the five species with the most specimen records, each with a bar scaled to the highest count. Use the toggle in the upper right to switch between that chart and **Record counts**, the numeric summary described above.

Select **Explore more stats** for detailed charts, tables, filters, and exports. The screen opens on **Summary**; switch to **Detailed** and choose **Counts** or **Spatial**.

## Exporting statistics

Select **Explore more stats**, then **Detailed**. Under **Counts**, choose a measure and grouping, then switch the panel to **Table**. The `Export table` button writes the rows currently shown to CSV, TSV, Excel, or JSON. **Spatial** exports the same way, one row per site coordinate.

Counts help identify unexpected changes but do not establish that records are complete or correctly identified. Check the underlying records before using a summary in a report.

## Learn more

- [Export Statistics](https://nahpu.app/en/usages/export/export-statistics/)
- [Projects](https://nahpu.app/en/usages/projects/)
