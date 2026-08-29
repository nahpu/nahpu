---
title: "Collecting event overview"
sidebar:
  order: 0
---

A collecting event records a defined sampling effort at a site and time. It corresponds to a Darwin Core `dwc:Event` or sampling event and can be linked to multiple specimen records.

NAHPU derives the Event ID from the Site ID and start date; add a suffix only when another event would otherwise have the same identifier. Create a separate event when the site, time period, sampling protocol, effort, or participating team changes materially.

Duplicating an event reuses applicable setup but advances dates and leaves weather data empty. Review every copied value before use.
