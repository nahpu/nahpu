---
title: "Collecting event overview"
sidebar:
  order: 0
---

A collecting event records one defined sampling effort at a site and time. Specimens link to an event for their site, dates, sampling context, and field team, so many specimen records can share a single event.

NAHPU builds the Event ID from the Site ID and the start date; add a suffix only when another event would otherwise have the same identifier. Create a separate event when the site, time period, sampling protocol, effort, or participating team changes materially.

Duplicating an event reuses applicable setup but advances the dates and leaves weather data empty. Review every copied value before use.

## Darwin Core context

The event is exported as a sampling event: the Event ID becomes `dwc:eventID`, the site becomes `dwc:locationID`, and the dates and times become `dwc:eventDate` and `dwc:eventTime`. A date range is exported as a single ISO 8601 interval.
