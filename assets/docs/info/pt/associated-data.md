---
title: "Dados associados"
sidebar:
  order: 0
---

Os dados associados conectam um registro a links e arquivos não multimídia de apoio, como referências de tombamento, conjuntos de dados, licenças, protocolos, registros de sequências ou documentos.

Escolha o tipo de dado que descreve a relação, acrescente um nome, uma descrição e uma data, e forneça um URI estável ou um arquivo gerenciado. Use Media para imagens, áudio e vídeo, para que os metadados audiovisuais sejam registrados de forma consistente. Verifique cada link ou arquivo depois de adicioná-lo e não anexe material sensível sem que seu acesso e compartilhamento estejam autorizados.

## Contexto do Darwin Core

Os dados associados não têm uma classe própria no Darwin Core. As exportações tabulares mapeiam esses registros para termos do Dublin Core: o nome para `dcterms:title`, o tipo de dado para `dcterms:type`, a descrição para `dcterms:description`, a data para `dcterms:created` e o URI para `dcterms:identifier`.
