---
title: "Atributos del espécimen"
sidebar:
  order: 0
---

Los atributos contienen las mediciones y observaciones biológicas hechas para el espécimen, incluidos el sexo, el estadio de vida, la condición reproductiva, la morfometría y los campos propios del grupo taxonómico.

Ingrese solo valores observados o documentados y conserve la unidad mostrada. Use `Unknown` o deje un campo vacío según el protocolo del proyecto en lugar de suponer. Las notas deben explicar salvedades, daños, incertidumbre o un método que afecte cómo se interpreta un valor.

## Contexto de Darwin Core

El sexo, el estadio de vida y la condición reproductiva se asignan a `dwc:sex`, `dwc:lifeStage` y `dwc:reproductiveCondition`; la casta de artrópodos se asigna a `dwc:caste` y un hospedador registrado a `dwc:associatedTaxa`. Toda otra medición se exporta como medición y no como columna propia: una exportación tabular emite `dwc:measurementType`, `dwc:measurementValue` y `dwc:measurementUnit` por cada medición seleccionada, y los paquetes estructurados llevan ese mismo trío como una fila de medición por valor.
