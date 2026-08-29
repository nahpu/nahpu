---
title: "Media"
sidebar:
  order: 0
---

Media stores the images, audio, and video associated with a project record. Use `Add` to import a file or, where the device supports it, to take a photo or video or record audio.

Edit the file name, caption, tag, and photographer so another person can tell what the file shows. The category follows the file type, and capture date, camera, and lens details are read from the file’s own metadata when it carries any. Confirm that a managed file opens before leaving the field, and include media in backups or full project transfers when it must move to another device.

Media describes the resource, not the specimen. Keep observations about the organism in the specimen record.

## Darwin Core context

Media attached to a specimen is exported alongside the occurrence as an Audiovisual Core `ac:Media` record: the caption or file name becomes the title, the capture date the creation date, and the photographer the creator. In tabular exports the media fields map to Dublin Core terms such as `dcterms:title`, `dcterms:created`, `dcterms:type`, and `dcterms:identifier`.
