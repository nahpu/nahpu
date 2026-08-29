---
title: "Parásitos del espécimen"
sidebar:
  order: 0
---

Un registro de parásito documenta material de parásito, o una interacción entre organismos observada, asociada al espécimen hospedador. Registre lo que realmente se observó o recolectó: taxón o categoría, ubicación anatómica, conteo, método de detección, preparación y preservación, quien identifica, estadio de vida y observaciones.

No trate una detección no confirmada como una identificación taxonómica; use el estado de asociación y las observaciones para indicar lo que sigue siendo incierto. Mantenga los identificadores de parásito sincronizados con los recipientes físicos.

## Contexto de Darwin Core

Cada parásito se exporta como su propia ocurrencia, vinculada al hospedador mediante una interacción entre organismos: un Darwin Core Data Package escribe una fila de organism-interaction y un Darwin Core Archive escribe la relación de recursos equivalente. La categoría se convierte en el tipo de interacción y la ubicación anatómica en la parte del organismo relacionado, mientras que el conteo, el método de preparación, el estadio de vida y las observaciones se asignan a `dwc:individualCount`, `dwc:preparations`, `dwc:lifeStage` y `dwc:occurrenceRemarks`.
