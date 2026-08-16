---
title: "Pessoal do projeto"
sidebar:
  order: 0
---

Os registros de pessoal representam pessoas que participam do projeto. Cada pessoa é armazenada uma vez no banco de dados e pode ser atribuída a vários projetos. Remover alguém deste painel remove a atribuição ao projeto; a exclusão permanente é gerenciada em Settings.

## Funções do NAHPU

- **Cataloger:** registra dados de espécimes e pode fornecer iniciais e número de campo pessoal para Field IDs.
- **Determiner only:** identifica espécimes, mas não os cataloga nem prepara.
- **Preparator only:** prepara espécimes, mas não os cataloga.
- **None:** participa do campo sem função de cuidado de espécimes.

Essas são funções de fluxo do NAHPU. Campos de agentes exportados, como `dwc:recordedBy` e `dwc:identifiedBy`, são preenchidos conforme as relações reais de cada registro.
