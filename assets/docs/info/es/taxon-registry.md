---
title: "Registro de taxones"
sidebar:
  order: 0
---

El registro contiene los nombres taxonómicos disponibles para este proyecto. Un taxón es un nombre, no un espécimen; los registros de especímenes apuntan a un taxón registrado para su identificación.

Agregue taxones manualmente o importe archivos `.xlsx`, `.csv` o `.tsv`. El registro manual pide primero un `Taxon rank` y luego muestra los campos de nombre hasta ese rango. Las importaciones pueden registrar clase, orden, familia, género, especie y subespecie cuando se incluye una columna `taxon rank`. Un rango ausente o vacío se toma como especie solo si clase, orden, familia, género y epíteto específico están completos; de lo contrario, agregue un rango. Cada fila requiere los campos de clasificación desde clase hasta el rango seleccionado. Revise cada asignación de columna detectada antes de importar.

El panel cuenta los órdenes, las familias y los nombres de especie completos distintos que contiene el registro. Un total de taxones aparece cuando el registro también contiene nombres por encima del rango de especie. Estos son conteos del registro; el panel de estadísticas informa los taxones que realmente usan los registros de especímenes.

## Contexto de Darwin Core

Un nombre registrado provee los términos de identificación de una exportación: `dwc:taxonID`, `dwc:kingdom`, `dwc:phylum`, `dwc:class`, `dwc:order`, `dwc:family`, `dwc:genus`, `dwc:specificEpithet`, `dwc:infraspecificEpithet`, `dwc:taxonRank`, `dwc:scientificNameAuthorship`, `dwc:vernacularName` y `dwc:taxonRemarks`.
