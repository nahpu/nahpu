---
title: "Atributos do espécime"
sidebar:
  order: 0
---

Os atributos guardam as medições e observações biológicas feitas para o espécime, incluindo sexo, estágio de vida, condição reprodutiva, morfometria e campos específicos do grupo taxonômico.

Informe apenas valores observados ou documentados e mantenha a unidade exibida. Use `Unknown` ou deixe um campo vazio conforme o protocolo do projeto, em vez de supor. As notas devem explicar ressalvas, danos, incerteza ou um método que afete a interpretação de um valor.

## Contexto do Darwin Core

Sexo, estágio de vida e condição reprodutiva são mapeados para `dwc:sex`, `dwc:lifeStage` e `dwc:reproductiveCondition`; a casta de artrópodes é mapeada para `dwc:caste` e um hospedeiro registrado para `dwc:associatedTaxa`. Toda outra medição é exportada como medição, e não como coluna própria: uma exportação tabular emite `dwc:measurementType`, `dwc:measurementValue` e `dwc:measurementUnit` para cada medição selecionada, e os pacotes estruturados levam o mesmo trio como uma linha de medição por valor.
