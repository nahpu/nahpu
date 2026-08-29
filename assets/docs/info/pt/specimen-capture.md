---
title: "Captura do espécime"
sidebar:
  order: 0
---

As informações de captura conectam o espécime ao evento de coleta que fornece seu local, seu contexto de amostragem, seu intervalo de datas e sua equipe de campo. Registre a data, a hora, o método, quem coletou e a coordenada de captura quando forem específicos deste espécime ou refinarem os do evento.

Alterar o evento de coleta altera o contexto de amostragem do registro. O NAHPU limpa o método, quem coletou e a coordenada para que valores do evento anterior não sejam mantidos silenciosamente; a data e a hora de captura são preservadas. Revise cada campo após alterar o evento e nunca infira uma coordenada que a evidência disponível não identifique.

A extensão da coordenada descreve o quão longe o espécime pode ter estado da posição registrada. Use-a quando uma linha de armadilhas, um transecto ou uma área de busca for maior que a própria coordenada.

## Contexto do Darwin Core

A data e a hora de captura são exportadas como `dwc:eventDate` e `dwc:eventTime`, recorrendo às datas do evento quando o espécime não as tem. A coordenada escolhida fornece os termos de localização, e a extensão da coordenada é somada à incerteza da própria coordenada em `dwc:coordinateUncertaintyInMeters`. Quem coleta preenche `dwc:recordedBy` e `dwc:recordedByID`.
