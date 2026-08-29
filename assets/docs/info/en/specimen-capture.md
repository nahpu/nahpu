---
title: "Specimen capture"
sidebar:
  order: 0
---

Capture information connects the specimen to the collecting event that supplies its site, sampling context, date range, and field team. Record the capture date, time, method, collector, and coordinate when they are specific to this specimen or refine the event.

Changing the collecting event changes the record’s sampling context. NAHPU clears the method, collector, and coordinate so values from the previous event are not silently retained; capture date and time are kept. Review every field after changing the event, and never infer a coordinate that the available evidence does not identify.

Coordinate extent describes how far the specimen could have been from the recorded position. Use it when a trap line, transect, or search area is wider than the coordinate itself.

## Darwin Core context

Capture date and time are exported as `dwc:eventDate` and `dwc:eventTime`, falling back to the event dates when the specimen has none. The chosen coordinate supplies the location terms, and the coordinate extent is combined with the coordinate’s own uncertainty into `dwc:coordinateUncertaintyInMeters`. The collector fills `dwc:recordedBy` and `dwc:recordedByID`.
