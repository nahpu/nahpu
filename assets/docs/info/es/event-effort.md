---
title: "Esfuerzo del evento"
sidebar:
  order: 0
---

Los registros de esfuerzo describen cómo se realizó el muestreo. Agregue cada método por separado y registre el número de unidades, la marca y el modelo del equipo, su tamaño o dimensiones y las notas.

Use las mismas unidades y nombres de método controlados en todo el proyecto para poder comparar los esfuerzos. La duración, el área y cualquier otra magnitud sin campo propio van en las notas. Indique suficiente contexto para que otra persona entienda el esfuerzo sin inferir datos faltantes.

## Contexto de Darwin Core

En una exportación tabular, el método se asigna a `dwc:samplingProtocol` y las notas a `dwc:samplingEffort`; el conteo, la marca y el tamaño no tienen equivalente en Darwin Core y conservan sus encabezados de NAHPU. Los Darwin Core Archives y los Data Packages llevan en su lugar la actividad y las notas del propio evento, así que registre también en el evento aquello que un archivo deba informar.
