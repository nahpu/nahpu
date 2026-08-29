---
title: "Clima del evento"
sidebar:
  order: 0
---

Los campos de clima describen las condiciones observadas durante el evento de recolecta, incluidas la temperatura y la humedad del aire, la nubosidad, la lluvia y, cuando corresponda, la temperatura del agua, el pH, el oxígeno disuelto y la velocidad de flujo. Registre los valores en las unidades mostradas e indique si son mediciones directas, lecturas de instrumento u otra fuente documentada.

Los valores astronómicos se derivan de la ubicación, la fecha y la hora del evento. Trátelos como contexto calculado, no como observaciones directas. Si un resultado es inesperado, verifique las coordenadas del sitio seleccionado, la zona horaria del proyecto y los horarios del evento antes de cambiar otros datos. No copie el clima entre eventos salvo que la medición realmente valga para ambos.

## Contexto de Darwin Core

Los valores de clima, agua y astronomía no tienen un término propio en Darwin Core. Las exportaciones estructuradas llevan cada valor registrado como una medición del evento, conservando su tipo y su unidad, y las notas del ambiente se convierten en `dwc:eventRemarks`.
