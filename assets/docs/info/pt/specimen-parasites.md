---
title: "Parasitas do espécime"
sidebar:
  order: 0
---

Um registro de parasita documenta material de parasita, ou uma interação entre organismos observada, associada ao espécime hospedeiro. Registre o que foi de fato observado ou coletado: táxon ou categoria, localização anatômica, contagem, método de detecção, preparação e preservação, quem identificou, estágio de vida e observações.

Não trate uma detecção não confirmada como identificação taxonômica; use o status de associação e as observações para declarar o que ainda é incerto. Mantenha os identificadores de parasita sincronizados com os recipientes físicos.

## Contexto do Darwin Core

Cada parasita é exportado como sua própria ocorrência, ligada ao hospedeiro por uma interação entre organismos: um Darwin Core Data Package grava uma linha de organism-interaction e um Darwin Core Archive grava a relação de recursos equivalente. A categoria vira o tipo de interação e a localização anatômica vira a parte do organismo relacionado, enquanto contagem, método de preparação, estágio de vida e observações são mapeados para `dwc:individualCount`, `dwc:preparations`, `dwc:lifeStage` e `dwc:occurrenceRemarks`.
