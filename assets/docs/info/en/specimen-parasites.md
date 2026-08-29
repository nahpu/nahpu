---
title: "Parasite records"
sidebar:
  order: 0
---

A parasite record documents parasite material, or an observed organism interaction, associated with the host specimen. Record what was actually observed or collected: taxon or category, anatomical location, count, detection method, preparation and preservation, identifier, life stage, and remarks.

Do not treat an unconfirmed detection as a taxonomic identification; use the association status and remarks to state what is still uncertain. Keep parasite identifiers synchronized with the physical containers.

## Darwin Core context

Each parasite is exported as its own occurrence, linked to the host through an organism interaction — a Darwin Core Data Package writes an organism-interaction row, and a Darwin Core Archive writes the equivalent resource relationship. The category becomes the interaction type and the anatomical location the related organism part, while count, preparation method, life stage, and remarks map to `dwc:individualCount`, `dwc:preparations`, `dwc:lifeStage`, and `dwc:occurrenceRemarks`.
