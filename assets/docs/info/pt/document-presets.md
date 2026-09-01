---
title: "Predefinições de documento"
sidebar:
  order: 0
---

As configurações de documento separam os modelos reutilizáveis dos layouts de impressão. Um modelo define uma etiqueta, uma plaqueta, uma folha ou um bloco de documento. Um layout de impressão define o tamanho e a orientação da página, as margens, os blocos de modelo colocados na página, as cópias, a ordenação dos registros e as configurações de arquivo usadas ao gerar o documento.

Crie um layout separado para cada fluxo de trabalho distinto e duplique com outro nome uma predefinição que já funciona antes de experimentar com ela. Visualize com registros representativos, incluindo textos longos, valores ausentes e ambos os lados de um modelo em frente e verso.

Um PDF gerado serve para imprimir ou apresentar. Não é uma exportação de dados estruturados nem um backup restaurável; use uma exportação tabular ou do Darwin Core para os dados, e uma transferência de projeto ou um backup do banco de dados para a recuperação. Os modelos e seus layouts são transferidos juntos por meio das configurações de usuário, então mova os dois quando alguém precisar da mesma saída.

As fontes são gerenciadas separadamente em `Documents` > `Fonts`. As fontes incluídas estão sempre disponíveis; uma fonte que você instala a partir de um arquivo `.ttf` ou `.otf` existe apenas naquela instalação, então um modelo que a use pedirá uma substituição ao ser importado em outro lugar. Um modelo pode ser renomeado nas configurações do editor de modelos, e um layout de impressão pelo campo de nome no topo de `Edit Preset`. Exporte um único modelo ou layout a partir de sua linha, ou todos pelo menu de opções; qualquer um dos arquivos é importado pela mesma ação.
