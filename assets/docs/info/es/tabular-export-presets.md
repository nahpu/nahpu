---
title: "Preajustes de exportación tabular"
sidebar:
  order: 0
---

Un preajuste de exportación tabular guarda una definición repetible: el tipo de registro, el grupo taxonómico del espécimen, los campos seleccionados y su orden, el formato de encabezado generado y cómo se escriben los valores repetidos. El formato de salida, el nombre del archivo y el destino se eligen al ejecutar la exportación.

Los valores repetidos pueden escribirse en una sola columna con un separador, o repartirse en columnas indexadas como `field_1`, `field_2`. Pruebe un preajuste con registros representativos, incluidos valores faltantes y repetidos, antes de depender de él, y transfiera las configuraciones de usuario cuando quienes colaboran necesiten la misma definición.

## Contexto de Darwin Core

`Generated header format` elige cómo se nombran los encabezados: `table::fieldName`, `fieldName`, Darwin Core (`dwc:`/`dcterms:`) o el espacio de nombres de NAHPU. Los encabezados de Darwin Core solo se producen para salidas CSV, TSV y Excel, y solo para campos que tienen un equivalente en Darwin Core; un campo sin equivalente conserva su nombre de NAHPU. Los valores repetidos en una exportación de Darwin Core siempre usan el separador recomendado " | ".

Asigne un campo personalizado a un término de Darwin Core solo cuando signifique lo mismo que ese término. Que las etiquetas coincidan no basta: un término reutilizado para otro concepto vuelve la exportación más difícil de interpretar que una columna de NAHPU sin asignar.
