---
title: "Predefinições de exportação tabular"
sidebar:
  order: 0
---

Uma predefinição de exportação tabular salva uma definição repetível: o tipo de registro, o grupo taxonômico do espécime, os campos selecionados e sua ordem, o formato de cabeçalho gerado e como os valores repetidos são escritos. O formato de saída, o nome do arquivo e o destino são escolhidos no momento da exportação.

`Generated header format` escolhe como os cabeçalhos são nomeados: `table::fieldName`, `fieldName`, Darwin Core ou o namespace do NAHPU. Valores repetidos podem ser escritos em uma única coluna com um separador ou distribuídos em colunas indexadas como `field_1`, `field_2`. Teste uma predefinição com registros representativos, incluindo valores ausentes e repetidos, antes de depender dela, e transfira as configurações de usuário quando colaboradores precisarem da mesma definição.

`Add custom field` escreve campos e texto literal, ou apenas texto, em uma coluna, como `[personnel::initial]-[specimen::fieldNumber]` ou um código de instituição constante.

As configurações são salvas conforme você as altera, mas o nome da predefinição não: digite um nome novo e selecione `Rename` para confirmá-lo. Exporte uma única predefinição a partir de sua linha, ou todas pelo menu de opções; qualquer um dos arquivos é importado pela mesma ação. Ao exportar, abrem-se as configurações do arquivo, onde você define o nome, escolhe uma pasta e compartilha com `Share` depois da exportação.

`Load defaults` no menu de opções, ou em uma lista vazia, permite escolher quais predefinições tabulares incluídas no NAHPU adicionar. As escritas para um formato de catálogo, como Non-volant mammals, aparecem desmarcadas e também são oferecidas em `Setup NAHPU`. Ele nunca sobrescreve uma predefinição com o mesmo nome, e qualquer predefinição pode ser excluída.

Um cabeçalho Darwin Core não valida, por si só, os dados exportados. Revise o significado dos campos, unidades e valores repetidos. Exportações tabulares são destinadas ao uso posterior, não à restauração de um projeto NAHPU.

## Saiba mais

- [Exportar Registros](https://nahpu.app/pt/usages/export/export-records/)
- [Empacotar Registros](https://nahpu.app/pt/usages/export/export-bundles/)
- [Expressões de Exportação](https://nahpu.app/pt/usages/export/export-expressions/)
