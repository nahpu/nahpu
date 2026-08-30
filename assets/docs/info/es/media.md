---
title: "Multimedia"
sidebar:
  order: 0
---

Multimedia almacena las imágenes, el audio y el video asociados a un registro del proyecto. Use `Add` para importar un archivo o, cuando el dispositivo lo permita, para tomar una foto o un video o grabar audio.

Edite el nombre de archivo, el pie, la etiqueta y quien fotografió para que otra persona sepa qué muestra el archivo. La categoría sigue al tipo de archivo, y la fecha de captura, la cámara y el lente se leen de los metadatos del propio archivo cuando los tiene. Confirme que un archivo gestionado se abre antes de salir del campo, e incluya la multimedia en las copias de seguridad o en las transferencias completas de proyecto cuando deba moverse a otro dispositivo.

La multimedia describe el recurso, no el espécimen. Mantenga las observaciones sobre el organismo en el registro del espécimen.

## Exportar multimedia

Use `Export` en un elemento multimedia para guardar un archivo, con opciones para convertirlo a JPEG, PNG o WebP y para redimensionarlo. Para guardar varios archivos a la vez, abra la galería de medios, active la selección y elija `Export`. Eso escribe un solo paquete TAR.GZ o ZIP, con las imágenes convertidas y redimensionadas en conjunto, y el audio y el video copiados sin cambios.

## Contexto de Darwin Core

La multimedia adjunta a un espécimen se exporta junto a la ocurrencia como un registro `ac:Media` de Audiovisual Core: el pie o el nombre de archivo se convierte en el título, la fecha de captura en la fecha de creación y quien fotografió en la persona creadora. En las exportaciones tabulares, los campos de multimedia se asignan a términos de Dublin Core como `dcterms:title`, `dcterms:created`, `dcterms:type` y `dcterms:identifier`.
