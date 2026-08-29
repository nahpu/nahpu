---
title: "Partes do espécime"
sidebar:
  order: 0
---

As partes do espécime documentam o material físico derivado do espécime ou associado a ele, como pele, crânio, esqueleto, tecido, órgão ou lâmina. Cada parte deve levar os identificadores necessários para corresponder à sua etiqueta ou ao seu recipiente.

Registre o tipo de preparação, o tratamento, a contagem, o tissue ID, o código QR ou de barras, o Preparator responsável e a data e hora em que a parte foi retirada. O tipo e o local de armazenamento, os números de museu permanente e de empréstimo, e as observações descrevem onde o material está guardado e o que ele tem de incomum. Configure em Settings os tipos de parte e os tratamentos controlados e use-os de forma consistente.

Mantenha os identificadores sincronizados com os recipientes físicos. Um tissue ID que já não corresponde ao seu frasco é mais difícil de corrigir do que um ausente.

## Contexto do Darwin Core

Cada parte é exportada como um `dwc:MaterialEntity` vinculado à ocorrência do espécime. O tipo de preparação vira `dwc:materialEntityType`, o tissue ID vira o número de catálogo do material, um código QR ou de barras diferente vira `dwc:otherCatalogNumbers`, e o tratamento e o tratamento adicional são unidos em `dwc:preparations`. Em exportações tabulares, o tissue ID é mapeado para `dwc:materialSampleID` e a contagem para `dwc:objectQuantity`. Os campos de armazenamento e de museu não têm equivalente no Darwin Core e mantêm seus cabeçalhos do NAHPU.
