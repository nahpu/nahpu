---
title: "Resumen del evento de recolección"
sidebar:
  order: 0
---

Un evento de recolección registra un esfuerzo de muestreo definido en un sitio y período. Corresponde a un `dwc:Event` o sampling event de Darwin Core y puede vincularse con varios registros de especímenes.

NAHPU deriva el Event ID del Site ID y la fecha inicial; añada un sufijo solo cuando otro evento tendría el mismo identificador. Cree otro evento cuando cambien de forma relevante el sitio, el período, el sampling protocol, el esfuerzo o el equipo.

Duplicar un evento reutiliza la configuración aplicable, pero avanza las fechas y deja vacíos los datos meteorológicos. Revise cada valor copiado antes de usarlo.
