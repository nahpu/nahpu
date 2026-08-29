---
title: "Registro de táxons"
sidebar:
  order: 0
---

O registro contém os nomes taxonômicos disponíveis para este projeto. Um táxon não é o mesmo que um espécime ou um `dwc:Occurrence`; os registros de espécimes se referem a um táxon registrado para a sua identificação.

Adicione táxons manualmente ou importe arquivos `.xlsx`, `.csv` ou `.tsv`. O registro manual pede primeiro uma `Taxon rank` e depois exibe os campos de nome até essa categoria. As importações também podem registrar entradas de classe, ordem, família, gênero, espécie e subespécie quando uma coluna `taxon rank` é incluída. Uma categoria ausente ou vazia é tratada como espécie somente quando classe, ordem, família, gênero e epíteto específico estão completos; caso contrário, adicione uma categoria. Cada linha requer os campos de classificação desde classe até a categoria selecionada. Revise cada mapeamento de coluna detectado antes de importar.

**Registered taxa** conta os nomes atribuídos ao projeto. **Recorded taxa** resume os táxons referenciados por registros de espécime ou de captura e muda conforme os registros são adicionados.
