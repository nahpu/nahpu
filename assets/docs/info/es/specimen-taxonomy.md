---
title: "Taxonomía del espécimen"
sidebar:
  order: 0
---

Los campos taxonómicos se completan a partir del taxón seleccionado en el registro del espécimen. Describen la identificación, no el espécimen físico.

El registro de taxones admite registros de cualquier rango, así que un espécimen aún no identificado hasta especie puede vincularse a su familia o género y precisarse después. Clase, orden, familia, género, epíteto específico y epíteto subespecífico siguen al taxón registrado hasta el rango que representa ese registro. Reino y filo provienen del registro cuando están anotados, y se infieren de la clase en caso contrario.

Edite el registro de taxones cuando el registro de nombre compartido esté mal; cambie el taxón seleccionado del espécimen cuando solo esa identificación esté mal. Conserve la autoría del nombre científico y las notas de identificación cuando estén disponibles, y registre al Determiner responsable en lugar de inferirlo.

## Contexto de Darwin Core

Las exportaciones construyen `dwc:scientificName` con el género y el epíteto específico del taxón seleccionado, y llevan los rangos circundantes en `dwc:kingdom` hasta `dwc:infraspecificEpithet` junto con `dwc:scientificNameAuthorship`. Quien determina llena `dwc:identifiedBy` y `dwc:identifiedByID`.
