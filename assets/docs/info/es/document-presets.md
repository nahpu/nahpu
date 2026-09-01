---
title: "Preajustes de documento"
sidebar:
  order: 0
---

La configuración de documentos separa las plantillas reutilizables de los diseños de impresión. Una plantilla define una etiqueta, un marbete, una hoja o un bloque de documento. Un diseño de impresión define el tamaño y la orientación de la página, los márgenes, los bloques de plantilla colocados en la página, las copias, el orden de los registros y la configuración de archivo que se usa al generar el documento.

Cree un diseño separado para cada flujo de trabajo distinto y duplique con otro nombre un preajuste que ya funciona antes de experimentar con él. Previsualice con registros representativos, incluidos textos largos, valores faltantes y ambas caras de una plantilla a doble faz.

Un PDF generado sirve para imprimir o presentar. No es una exportación de datos estructurados ni una copia de seguridad restaurable; use una exportación tabular o de Darwin Core para los datos, y una transferencia de proyecto o una copia de la base de datos para la recuperación. Las plantillas y sus diseños se transfieren juntos mediante las configuraciones de usuario, así que mueva ambos cuando alguien necesite la misma salida.

Las fuentes se gestionan por separado en `Documents` > `Fonts`. Las fuentes incluidas siempre están disponibles; una fuente que instale desde un archivo `.ttf` u `.otf` existe solo en esa instalación, por lo que una plantilla que la use pedirá un reemplazo al importarse en otro lugar. Una plantilla se puede renombrar en la configuración del editor de plantillas, y un diseño de impresión desde el campo de nombre en la parte superior de `Edit Preset`. Exporte una sola plantilla o un solo diseño desde su fila, o todos desde el menú de opciones; ambos archivos se importan con la misma acción.
