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

Estos son roles del flujo de trabajo de NAHPU que controlan a qué se puede asignar cada persona dentro de la aplicación. No son los mismos roles que se informan en una exportación, los cuales siguen las relaciones reales de cada registro.

## Contexto de Darwin Core

Una persona se exporta como un agente identificado por `dwc:agentID`, tomado del ORCID cuando está registrado y del identificador de NAHPU en caso contrario; las notas del personal se convierten en `dwc:agentRemarks`. Las relaciones del espécimen completan los campos de agente: quien recolecta llena `dwc:recordedBy` y `dwc:recordedByID`, y quien determina llena `dwc:identifiedBy` y `dwc:identifiedByID`.
