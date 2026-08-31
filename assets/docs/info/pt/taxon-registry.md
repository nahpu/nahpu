---
title: "Registro de táxons"
sidebar:
  order: 0
---

O registro contém os nomes taxonômicos disponíveis para este projeto. Um táxon é um nome, não um espécime; os registros de espécimes apontam para um táxon registrado para sua identificação.

Adicione táxons manualmente ou importe arquivos `.xlsx`, `.csv` ou `.tsv`. O registro manual pede primeiro um `Taxon rank` e depois mostra os campos de nome até esse nível. As importações aceitam classe, ordem, família, gênero, espécie e subespécie. Cada linha exige os campos de classificação de classe até o nível selecionado. Revise cada mapeamento de coluna antes de importar.

O arquivo pode omitir `Taxon rank`, `Kingdom`, `Phylum` e `Class`. Se `Class` não estiver mapeada, escolha a classe compatível comum a todas as linhas em `Select the class shared by all rows`. O NAHPU preenche reino e filo ausentes para classes conhecidas e preserva os valores fornecidos. Sem categoria, ordem, família, gênero e epíteto específico devem estar completos; a categoria será espécie, ou subespécie quando houver epíteto subespecífico. Para outras classes, inclua `Taxon rank`, `Kingdom`, `Phylum`, `Class` e todas as colunas de classificação até a categoria selecionada, com valores em cada célula obrigatória. Arquivos com várias classes precisam de uma coluna `Class`.

O painel conta as ordens, as famílias e os nomes de espécie completos distintos existentes no registro. Um total de táxons aparece quando o registro também contém nomes acima do nível de espécie. Essas são contagens do registro; o painel de estatísticas informa os táxons que os registros de espécimes de fato usam.

Para importar de QR, selecione `Scan QR` e depois `Single taxon` ou `Multiple taxa`. No modo individual, um escaneamento válido abre a prévia; o modo múltiplo mantém a câmera aberta até selecionar `Done`. Revise e importe os táxons selecionados para salvá-los. Os existentes ficam desabilitados e nunca são sobrescritos. Cancelar preserva a importação anterior; concluir a sessão a substitui. Um registro QR precisa apenas de uma categoria compatível e seu nome; códigos antigos inferem a categoria pelo nome mais específico. Não é necessário selecionar uma classe. Use a câmera; imagens QR e texto colado não são aceitos.

## Contexto do Darwin Core

Um nome registrado fornece os termos de identificação de uma exportação: `dwc:taxonID`, `dwc:kingdom`, `dwc:phylum`, `dwc:class`, `dwc:order`, `dwc:family`, `dwc:genus`, `dwc:specificEpithet`, `dwc:infraspecificEpithet`, `dwc:taxonRank`, `dwc:scientificNameAuthorship`, `dwc:vernacularName` e `dwc:taxonRemarks`.
