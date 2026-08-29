---
title: "Associated data"
sidebar:
  order: 0
---

Associated data connects a record to supporting links and non-media files, such as accession references, datasets, permits, protocols, sequence records, or documents.

Choose the data type that describes the relationship, add a name, description, and date, and provide a stable URI or a managed file. Use Media instead for images, audio, and video so audiovisual metadata is recorded consistently. Verify every link or file after adding it, and do not attach sensitive material unless its access and sharing are authorized.

## Darwin Core context

Associated data has no Darwin Core class of its own. Tabular exports map these records to Dublin Core terms: the name to `dcterms:title`, the data type to `dcterms:type`, the description to `dcterms:description`, the date to `dcterms:created`, and the URI to `dcterms:identifier`.
