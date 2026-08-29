---
title: "Visão geral do evento"
sidebar:
  order: 0
---

Um evento de coleta registra um esforço de amostragem definido em um local e em um momento. Os espécimes se vinculam a um evento para obter seu local, suas datas, seu contexto de amostragem e sua equipe de campo, de modo que muitos registros de espécimes podem compartilhar um mesmo evento.

O NAHPU monta o Event ID a partir do Site ID e da data de início; acrescente um sufixo apenas quando outro evento teria o mesmo identificador. Crie um evento separado quando o local, o período, o protocolo de amostragem, o esforço ou a equipe participante mudarem de forma significativa.

Duplicar um evento reaproveita a configuração aplicável, mas avança as datas e deixa os dados meteorológicos vazios. Revise cada valor copiado antes de usar.

## Contexto do Darwin Core

O evento é exportado como um evento de amostragem: o Event ID vira `dwc:eventID`, o local vira `dwc:locationID`, e as datas e horas viram `dwc:eventDate` e `dwc:eventTime`. Um intervalo de datas é exportado como um único intervalo ISO 8601.
