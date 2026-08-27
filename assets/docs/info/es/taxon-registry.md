---
title: "Registro de taxones"
sidebar:
  order: 0
---

El registro contiene los nombres taxonómicos disponibles para este proyecto. Un taxón no es lo mismo que un espécimen o un `dwc:Occurrence`; los registros de especímenes se refieren a un taxón registrado para su identificación.

Agregue taxones manualmente o importe archivos `.xlsx`, `.csv` o `.tsv`. El registro manual pide primero una `Taxon rank` y luego muestra los campos de nombre hasta esa categoría. Las importaciones también pueden registrar entradas de clase, orden, familia, género, especie y subespecie cuando se incluye una columna `taxon rank`. Una categoría ausente o vacía se interpreta como especie solo si la clase, el orden, la familia, el género y el epíteto específico están completos; de lo contrario, agregue una categoría. Cada fila requiere los campos de clasificación desde clase hasta la categoría seleccionada. Revise cada asignación de columna detectada antes de importar.

**Registered taxa** cuenta los nombres asignados al proyecto. **Recorded taxa** resume los taxones referenciados por registros de espécimen o de captura y cambia a medida que se agregan registros.
