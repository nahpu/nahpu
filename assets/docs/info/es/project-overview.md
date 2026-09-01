---
title: "Resumen del proyecto"
sidebar:
  order: 0
---

Un proyecto agrupa el personal, los taxones, los sitios, los eventos de recolecta, los registros de especímenes, las narrativas y la multimedia creados para un mismo trabajo. Use `Edit` para actualizar sus metadatos descriptivos y `Export info` o `Show QR` para compartir solo su identidad.

## UUID del proyecto

NAHPU asigna a cada proyecto nuevo un identificador único universal (UUID). Importar la información del proyecto conserva ese UUID para que los dispositivos que colaboran puedan reconocer copias del mismo proyecto. La información del proyecto no incluye registros ni multimedia; use la transferencia de proyecto cuando también deban moverse.

Mantenga breve la descripción del proyecto. Registre el contexto diario detallado en Narratives.

## Copias de seguridad en el campo

`Export project` es la copia de campo diaria. Es más pequeña y rápida que una copia de la base de datos y consume menos batería, y `Merge project` la vuelve a leer en otro dispositivo, así que un dispositivo perdido o roto cuesta como máximo un día de trabajo. Elija ZIP o TAR.GZ para llevar los medios, o una exportación ligera `JSON.GZ` cuando la carga deba ser pequeña.

Reserve `Backup database` para un punto de control semanal y para el momento previo a cualquier fusión. Copia todos los proyectos y todos los archivos de los datos de la aplicación NAHPU, estén o no vinculados a un proyecto. En el campo, ejecútela de forma ocasional, cuando el consumo de batería no sea una preocupación.

## Contexto de Darwin Core

El UUID del proyecto identifica al conjunto de datos en las exportaciones y se escribe en `dwc:datasetID`.
