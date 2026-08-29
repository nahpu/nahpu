---
title: "Resumen del evento"
sidebar:
  order: 0
---

Un evento de recolecta registra un esfuerzo de muestreo definido en un sitio y en un momento. Los especímenes se vinculan a un evento para tomar su sitio, sus fechas, su contexto de muestreo y su equipo de campo, de modo que muchos registros de especímenes pueden compartir un mismo evento.

NAHPU construye el Event ID a partir del Site ID y de la fecha de inicio; agregue un sufijo solo cuando otro evento tendría el mismo identificador. Cree un evento separado cuando el sitio, el período, el protocolo de muestreo, el esfuerzo o el equipo participante cambien de forma significativa.

Duplicar un evento reutiliza la configuración aplicable, pero adelanta las fechas y deja vacíos los datos meteorológicos. Revise cada valor copiado antes de usarlo.

## Contexto de Darwin Core

El evento se exporta como un evento de muestreo: el Event ID se convierte en `dwc:eventID`, el sitio en `dwc:locationID`, y las fechas y horas en `dwc:eventDate` y `dwc:eventTime`. Un rango de fechas se exporta como un único intervalo ISO 8601.
