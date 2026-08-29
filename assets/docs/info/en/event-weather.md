---
title: "Weather and astronomy"
sidebar:
  order: 0
---

Weather fields describe the conditions observed during the collecting event, including air temperature and humidity, cloud cover, rainfall, and — where they apply — water temperature, pH, dissolved oxygen, and flow velocity. Record values in the displayed units and note whether they are direct measurements, instrument readings, or another documented source.

Astronomy values are derived from the event’s location, date, and time. Treat them as calculated context, not direct observations. If a result is unexpected, verify the selected site coordinates, project time zone, and event times before changing other data. Do not copy weather between events unless the measurement truly applies to both.

## Darwin Core context

Weather, water, and astronomy values have no Darwin Core term of their own. Structured exports carry each recorded value as a measurement of the event, keeping its type and unit, and the environment notes become `dwc:eventRemarks`.
