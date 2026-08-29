---
title: "Specimen attributes"
sidebar:
  order: 0
---

Attributes hold the measurements and biological observations made for the specimen, including sex, life stage, reproductive condition, morphometrics, and fields specific to the taxon group.

Enter only observed or documented values and keep the displayed unit. Use `Unknown` or leave a field empty according to the project protocol rather than guessing. Notes should explain qualifiers, damage, uncertainty, or a method that affects how a value is interpreted.

## Darwin Core context

Sex, life stage, and reproductive condition map to `dwc:sex`, `dwc:lifeStage`, and `dwc:reproductiveCondition`; arthropod caste maps to `dwc:caste` and a recorded host to `dwc:associatedTaxa`. Every other measurement is exported as a measurement rather than a column of its own: a tabular export emits `dwc:measurementType`, `dwc:measurementValue`, and `dwc:measurementUnit` for each selected measurement, and structured packages carry the same triple as one measurement row per value.
