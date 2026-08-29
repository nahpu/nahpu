---
title: "Geografía del sitio"
sidebar:
  order: 0
---

La geografía describe dónde está el sitio, desde el país hasta la localidad precisa, con observaciones para el contexto que no cabe en un campo con nombre. Qué campos aparecen se configura en Settings.

`Find existing locality` compara lo que escribe con todas las localidades ya guardadas en el proyecto. Elegir una sugerencia completa toda la jerarquía de una vez, y cada campo también sugiere valores ya registrados para ese campo. Las localidades se almacenan una sola vez y se comparten entre sitios, así que reutilizar una guardada evita crear un lugar casi duplicado.

Ingrese los valores según las convenciones geográficas de la institución responsable. `Precise Locality` debe describir el lugar específico con nombre por debajo del nivel de municipio. Conserve la evidencia literal al normalizar nombres de lugares para que quienes curen después puedan entender la fuente original.

## Contexto de Darwin Core

Los campos geográficos se exportan a `dwc:country`, `dwc:islandGroup`, `dwc:stateProvince`, `dwc:county` y `dwc:municipality`. La localidad precisa se exporta como `dwc:verbatimLocality` porque se registra tal como se escribió, sin normalizar, y las observaciones se convierten en `dwc:locationRemarks`.
