---
title: "Taxonomia do espécime"
sidebar:
  order: 0
---

Os campos taxonômicos são preenchidos a partir do táxon selecionado no registro do espécime. Eles descrevem a identificação, não o espécime físico.

O registro de táxons aceita registros em qualquer nível, então um espécime ainda não identificado até espécie pode ser vinculado à sua família ou ao seu gênero e refinado depois. Classe, ordem, família, gênero, epíteto específico e epíteto subespecífico seguem o táxon registrado até o nível que aquele registro representa. Reino e filo vêm do registro quando anotados e são inferidos da classe caso contrário.

Edite o registro de táxons quando o registro de nome compartilhado estiver errado; altere o táxon selecionado do espécime quando apenas aquela identificação estiver errada. Preserve a autoria do nome científico e as notas de identificação quando disponíveis, e registre o Determiner responsável em vez de inferi-lo.

## Contexto do Darwin Core

As exportações montam `dwc:scientificName` a partir do gênero e do epíteto específico do táxon selecionado, e levam os níveis ao redor em `dwc:kingdom` até `dwc:infraspecificEpithet`, com `dwc:scientificNameAuthorship`. Quem determina preenche `dwc:identifiedBy` e `dwc:identifiedByID`.
