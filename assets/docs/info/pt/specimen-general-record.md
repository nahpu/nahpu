---
title: "Registro geral do espécime"
sidebar:
  order: 0
---

O registro geral guarda o identificador de trabalho do espécime, as pessoas responsáveis por ele, seu táxon e seu contexto de preparação e condição. Conforme as configurações do projeto, o Field ID combina as iniciais de um Cataloger com um número de campo pessoal, ou o prefixo e o sufixo do projeto com um número de catálogo do projeto.

Escolha o táxon no registro do projeto. O táxon é a identificação; o registro do espécime é a ocorrência documentada de um organismo. Registre o método e a confiança da identificação quando ela for provisória, e acrescente o Museum ID quando a instituição o atribuir.

Registre Cataloger, Preparator e Determiner conforme o trabalho que cada pessoa realmente fez. Descreva a condição no momento da preparação a partir de evidência direta e preserve as datas e horários de coleta e de preparação quando forem conhecidos.

## Contexto do Darwin Core

O registro do espécime é exportado como um `dwc:Occurrence`: seu identificador interno vira `dwc:occurrenceID` e o Field ID vira `dwc:catalogNumber`. O NAHPU grava `dwc:basisOfRecord` como `PreservedSpecimen`, ou como `HumanObservation` quando a condição é `Released`. O método de identificação é mapeado para `dwc:identificationType` e a confiança da identificação para `dwc:identificationVerificationStatus`.
