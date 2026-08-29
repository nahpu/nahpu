---
title: "Registro general del espécimen"
sidebar:
  order: 0
---

El registro general guarda el identificador de trabajo del espécimen, las personas responsables de él, su taxón y su contexto de preparación y condición. Según la configuración del proyecto, el Field ID combina las iniciales de un Cataloger con un número de campo personal, o el prefijo y el sufijo del proyecto con un número de catálogo del proyecto.

Elija el taxón del registro del proyecto. El taxón es la identificación; el registro del espécimen es la ocurrencia documentada de un organismo. Registre el método y la confianza de la identificación cuando sea provisional, y agregue el Museum ID cuando la institución lo asigne.

Registre Cataloger, Preparator y Determiner según el trabajo que realmente hizo cada persona. Describa la condición en el momento de la preparación a partir de evidencia directa, y conserve las fechas y horas de recolecta y de preparación cuando se conozcan.

## Contexto de Darwin Core

El registro del espécimen se exporta como un `dwc:Occurrence`: su identificador interno se convierte en `dwc:occurrenceID` y el Field ID en `dwc:catalogNumber`. NAHPU escribe `dwc:basisOfRecord` como `PreservedSpecimen`, o como `HumanObservation` cuando la condición es `Released`. El método de identificación se asigna a `dwc:identificationType` y la confianza de la identificación a `dwc:identificationVerificationStatus`.
