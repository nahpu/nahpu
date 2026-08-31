---
title: "Registro de taxones"
sidebar:
  order: 0
---

El registro contiene los nombres taxonómicos disponibles para este proyecto. Un taxón es un nombre, no un espécimen; los registros de especímenes apuntan a un taxón registrado para su identificación.

Agregue taxones manualmente o importe archivos `.xlsx`, `.csv` o `.tsv`. El registro manual pide primero un `Taxon rank` y luego muestra los campos de nombre hasta ese rango. Las importaciones aceptan clase, orden, familia, género, especie y subespecie. Cada fila requiere los campos de clasificación desde clase hasta el rango seleccionado. Revise cada asignación de columna antes de importar.

El archivo puede omitir `Taxon rank`, `Kingdom`, `Phylum` y `Class`. Si `Class` no está asignada, elija la clase admitida común a todas las filas en `Select a class`. NAHPU completa reino y filo ausentes para clases conocidas y conserva los valores proporcionados. Sin categoría, orden, familia, género y epíteto específico deben estar completos; la categoría será especie, o subespecie cuando haya epíteto subespecífico. Para otras clases, incluya `Taxon rank`, `Kingdom`, `Phylum`, `Class` y todas las columnas de clasificación hasta la categoría seleccionada, con valores en cada celda obligatoria. Los archivos con varias clases necesitan una columna `Class`.

El panel cuenta los órdenes, las familias y los nombres de especie completos distintos que contiene el registro. Un total de taxones aparece cuando el registro también contiene nombres por encima del rango de especie. Estos son conteos del registro; el panel de estadísticas informa los taxones que realmente usan los registros de especímenes.

## Contexto de Darwin Core

Un nombre registrado provee los términos de identificación de una exportación: `dwc:taxonID`, `dwc:kingdom`, `dwc:phylum`, `dwc:class`, `dwc:order`, `dwc:family`, `dwc:genus`, `dwc:specificEpithet`, `dwc:infraspecificEpithet`, `dwc:taxonRank`, `dwc:scientificNameAuthorship`, `dwc:vernacularName` y `dwc:taxonRemarks`.
