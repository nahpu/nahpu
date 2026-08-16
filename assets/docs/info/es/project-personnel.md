---
title: "Personal del proyecto"
sidebar:
  order: 0
---

Los registros de personal representan a quienes participan en el proyecto. Cada persona se almacena una vez en la base de datos y puede asignarse a varios proyectos. Quitar a alguien de este panel elimina su asignación al proyecto; la eliminación permanente se administra en Settings.

## Funciones de NAHPU

- **Cataloger:** registra datos de especímenes y puede aportar iniciales y número de campo personal para los Field IDs.
- **Determiner only:** identifica especímenes, pero no los cataloga ni prepara.
- **Preparator only:** prepara especímenes, pero no los cataloga.
- **None:** participa en el campo sin función de cuidado de especímenes.

Estas son funciones del flujo de NAHPU. Los campos de agentes exportados, como `dwc:recordedBy` y `dwc:identifiedBy`, se completan según las relaciones reales de cada registro.
