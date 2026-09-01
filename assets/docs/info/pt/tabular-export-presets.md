---
title: "Predefinições de exportação tabular"
sidebar:
  order: 0
---

Uma predefinição de exportação tabular salva uma definição repetível: o tipo de registro, o grupo taxonômico do espécime, os campos selecionados e sua ordem, o formato de cabeçalho gerado e como os valores repetidos são escritos. O formato de saída, o nome do arquivo e o destino são escolhidos no momento da exportação.

Valores repetidos podem ser escritos em uma única coluna com um separador ou distribuídos em colunas indexadas como `field_1`, `field_2`. Teste uma predefinição com registros representativos, incluindo valores ausentes e repetidos, antes de depender dela, e transfira as configurações de usuário quando colaboradores precisarem da mesma definição.

As configurações são salvas conforme você as altera, mas o nome da predefinição não: digite um nome novo e selecione `Rename` para confirmá-lo. Exporte uma única predefinição a partir de sua linha, ou todas pelo menu de opções; qualquer um dos arquivos é importado pela mesma ação.

## Contexto do Darwin Core

`Generated header format` escolhe como os cabeçalhos são nomeados: `table::fieldName`, `fieldName`, Darwin Core (`dwc:`/`dcterms:`) ou o namespace do NAHPU. Cabeçalhos do Darwin Core são produzidos apenas para saídas CSV, TSV e Excel, e apenas para campos que tenham equivalente no Darwin Core; um campo sem equivalente mantém seu nome do NAHPU. Valores repetidos em uma exportação do Darwin Core sempre usam o separador recomendado " | ".

Mapeie um campo personalizado para um termo do Darwin Core apenas quando ele significar a mesma coisa que aquele termo. Rótulos parecidos não bastam: um termo reaproveitado para outro conceito torna a exportação mais difícil de interpretar do que uma coluna do NAHPU sem mapeamento.
