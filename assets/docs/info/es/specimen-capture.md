---
title: "Captura del espécimen"
sidebar:
  order: 0
---

La información de captura conecta el espécimen con el evento de recolecta que aporta su sitio, su contexto de muestreo, su rango de fechas y su equipo de campo. Registre la fecha, la hora, el método, la persona que recolectó y la coordenada de captura cuando sean propios de este espécimen o precisen los del evento.

Cambiar el evento de recolecta cambia el contexto de muestreo del registro. NAHPU limpia el método, la persona que recolectó y la coordenada para que no se conserven en silencio valores del evento anterior; la fecha y la hora de captura se mantienen. Revise cada campo después de cambiar el evento y nunca infiera una coordenada que la evidencia disponible no identifique.

La extensión de la coordenada describe cuán lejos pudo estar el espécimen de la posición registrada. Úsela cuando una línea de trampas, un transecto o un área de búsqueda sea más amplia que la coordenada misma.

## Contexto de Darwin Core

La fecha y la hora de captura se exportan como `dwc:eventDate` y `dwc:eventTime`, y se toman las del evento cuando el espécimen no las tiene. La coordenada elegida aporta los términos de ubicación, y la extensión de la coordenada se suma a la incertidumbre propia de la coordenada en `dwc:coordinateUncertaintyInMeters`. Quien recolecta llena `dwc:recordedBy` y `dwc:recordedByID`.
