---
title: "Identidad del sitio"
sidebar:
  order: 0
---

Un sitio es el registro de lugar reutilizable de NAHPU. Los eventos de recolecta toman su ubicación de un sitio, así que dé a cada sitio un Site ID estable y único en el proyecto, y use una sola convención de nombres entre los dispositivos que colaboran.

Registre a la persona responsable y el tipo de sitio cuando sea útil. Use `Duplicate site` para copiar la información descriptiva dejando vacíos el nuevo Site ID y las coordenadas. Use `Copy from project ...` solo cuando un sitio de otro proyecto describa un lugar que deba reutilizarse; verifique cada valor copiado antes de comenzar la recolecta.

## Contexto de Darwin Core

El Site ID identifica la ubicación en las exportaciones y se escribe en `dwc:locationID`; las observaciones del sitio se convierten en `dwc:locationRemarks`.
