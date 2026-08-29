---
title: "Personal del proyecto"
sidebar:
  order: 0
---

Los registros de personal representan a las personas que participan en el proyecto. Una persona se almacena una sola vez en la base de datos y puede asignarse a varios proyectos. Quitar a una persona de este panel elimina la asignación al proyecto; la eliminación permanente se gestiona en Settings.

## Roles en NAHPU

- **Cataloger:** registra los datos del espécimen y puede aportar iniciales y un número de campo personal para los Field IDs.
- **Determiner only:** identifica especímenes, pero no los cataloga ni los prepara.
- **Preparator only:** prepara especímenes, pero no los cataloga.
- **None:** participa en el trabajo de campo sin un rol de cuidado del espécimen.

Estos son roles del flujo de trabajo de NAHPU. Los campos de agente exportados, como `dwc:recordedBy` y `dwc:identifiedBy`, se completan según las relaciones reales de cada registro.
