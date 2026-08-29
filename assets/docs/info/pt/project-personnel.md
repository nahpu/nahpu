---
title: "Pessoal do projeto"
sidebar:
  order: 0
---

Os registros de pessoal representam as pessoas que participam do projeto. Uma pessoa é armazenada uma única vez no banco de dados e pode ser atribuída a vários projetos. Remover uma pessoa deste painel remove a atribuição ao projeto; a exclusão permanente é gerenciada em Settings.

## Funções no NAHPU

- **Cataloger:** registra os dados do espécime e pode fornecer iniciais e um número de campo pessoal para os Field IDs.
- **Determiner only:** identifica espécimes, mas não os cataloga nem os prepara.
- **Preparator only:** prepara espécimes, mas não os cataloga.
- **None:** participa do trabalho de campo sem uma função de cuidado com o espécime.

Estas são funções de fluxo de trabalho do NAHPU que definem a que cada pessoa pode ser atribuída dentro do aplicativo. Não são as mesmas funções informadas em uma exportação, que seguem as relações reais de cada registro.

## Contexto do Darwin Core

Uma pessoa é exportada como um agente identificado por `dwc:agentID`, obtido do ORCID quando registrado e do identificador do NAHPU caso contrário; as notas do pessoal viram `dwc:agentRemarks`. As relações do espécime preenchem os campos de agente: quem coleta preenche `dwc:recordedBy` e `dwc:recordedByID`, e quem determina preenche `dwc:identifiedBy` e `dwc:identifiedByID`.
