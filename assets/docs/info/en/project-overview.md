---
title: "Project overview"
sidebar:
  order: 0
---

A project groups the personnel, taxa, sites, collecting events, specimen records, narratives, and media created for one body of work. Use `Edit` to update its descriptive metadata and `Export info` or `Show QR` to share only its identity.

## Project UUID

NAHPU assigns every new project a universally unique identifier (UUID). Importing project information preserves that UUID so collaborating devices can identify copies of the same project. Project information does not include records or media; use project transfer when those must move too.

Keep the project description concise. Record detailed daily context in Narratives.

## Backing up in the field

`Export project` is the daily field backup. It is smaller and faster than a database backup and easier on the battery, and `Merge project` reads it back on another device, so a lost or broken device costs at most one day of work. Choose ZIP or TAR.GZ to carry media, or a `JSON.GZ` light export when the upload must be small.

Reserve `Backup database` for a weekly checkpoint and for the moment before any merge. It copies all projects and every file in NAHPU app data, whether or not a project links to it. In the field, run it occasionally, when battery use is not a concern.

## Darwin Core context

The project UUID identifies the dataset in exports and is written to `dwc:datasetID`.
