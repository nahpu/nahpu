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

Estas são funções de fluxo de trabalho do NAHPU. Os campos de agente exportados, como `dwc:recordedBy` e `dwc:identifiedBy`, são preenchidos de acordo com as relações reais de cada registro.
