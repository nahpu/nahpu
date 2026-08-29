---
title: "Geografia do local"
sidebar:
  order: 0
---

A geografia descreve onde o local está, do país até a localidade precisa, com observações para o contexto que não cabe em um campo nomeado. Quais campos aparecem é configurável em Settings.

`Find existing locality` compara o que você digita com todas as localidades já salvas no projeto. Escolher uma sugestão preenche toda a hierarquia de uma vez, e cada campo também sugere valores já registrados para ele. As localidades são armazenadas uma única vez e compartilhadas entre locais, então reaproveitar uma salva evita criar um lugar quase duplicado.

Informe os valores conforme as convenções geográficas da instituição responsável. `Precise Locality` deve descrever o lugar nomeado específico abaixo do nível de município. Preserve a evidência literal ao normalizar nomes de lugares para que quem fizer a curadoria depois entenda a fonte original.

## Contexto do Darwin Core

Os campos geográficos são exportados para `dwc:country`, `dwc:islandGroup`, `dwc:stateProvince`, `dwc:county` e `dwc:municipality`. A localidade precisa é exportada como `dwc:verbatimLocality` porque é registrada como foi escrita, sem normalização, e as observações viram `dwc:locationRemarks`.
