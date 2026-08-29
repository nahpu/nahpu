---
title: "Identidade do local"
sidebar:
  order: 0
---

Um local é o registro de lugar reutilizável do NAHPU. Os eventos de coleta obtêm sua localização de um local, então dê a cada local um Site ID estável e único no projeto, e use uma única convenção de nomes entre os dispositivos que colaboram.

Registre a pessoa responsável e o tipo de local quando for útil. Use `Duplicate site` para copiar as informações descritivas deixando vazios o novo Site ID e as coordenadas. Use `Copy from project ...` apenas quando um local de outro projeto descrever um lugar que deva ser reaproveitado; verifique cada valor copiado antes de iniciar a coleta.

## Contexto do Darwin Core

O Site ID identifica a localização nas exportações e é gravado em `dwc:locationID`; as observações do local viram `dwc:locationRemarks`.
