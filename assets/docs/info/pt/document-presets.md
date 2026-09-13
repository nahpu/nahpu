---
title: "Predefinições de documento"
sidebar:
  order: 0
---

As configurações de documento separam os modelos reutilizáveis dos layouts de impressão. Um modelo define uma etiqueta, uma plaqueta, uma folha ou um bloco de documento. Um layout de impressão define o tamanho e a orientação da página, as margens, os blocos de modelo colocados na página, as cópias, a ordenação dos registros e as configurações de arquivo usadas ao gerar o documento.

Crie um layout separado para cada fluxo de trabalho distinto e duplique com outro nome uma predefinição que já funciona antes de experimentar com ela. Visualize com registros representativos, incluindo textos longos, valores ausentes e ambos os lados de um modelo em frente e verso.

`Load defaults` no menu de opções, ou em uma lista vazia, permite escolher quais layouts de impressão e modelos incluídos no NAHPU adicionar. Os que servem para qualquer formato de catálogo aparecem marcados; os escritos para um formato de catálogo, como o caderno de campo, as plaquetas de crânio e as etiquetas de espécime de mamíferos, aparecem desmarcados e também são oferecidos em `Setup NAHPU`. Ele nunca sobrescreve uma predefinição com o mesmo nome, e qualquer predefinição pode ser excluída.

Ao exportar, abrem-se as configurações do arquivo, onde você define o nome, escolhe uma pasta e compartilha com `Share` depois da exportação. Exportar um layout inclui os modelos usados pelos seus blocos, a menos que você desative `Include linked templates`, e importar esse arquivo também adiciona os modelos.

Os modelos e seus layouts são transferidos juntos por meio das configurações de usuário, então mova os dois quando uma pessoa colaboradora precisar da mesma saída.

Ao desenhar um modelo, você pode usar as fontes incluídas ou importar suas próprias fontes. As fontes são gerenciadas em `Documents` > `Fonts`.

As definições transferidas não incluem fontes personalizadas nem imagens dos modelos. Instale as fontes e adicione as imagens no dispositivo de destino; depois compare o PDF gerado com a saída desejada.

## Saiba mais

- [Exportar Documentos](https://nahpu.app/pt/usages/export/export-documents/)
- [Expressões de Exportação](https://nahpu.app/pt/usages/export/export-expressions/)
