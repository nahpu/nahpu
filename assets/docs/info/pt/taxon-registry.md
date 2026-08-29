---
title: "Registro de táxons"
sidebar:
  order: 0
---

O registro contém os nomes taxonômicos disponíveis para este projeto. Um táxon é um nome, não um espécime; os registros de espécimes apontam para um táxon registrado para sua identificação.

Adicione táxons manualmente ou importe arquivos `.xlsx`, `.csv` ou `.tsv`. O registro manual pede primeiro um `Taxon rank` e depois mostra os campos de nome até esse nível. As importações podem registrar classe, ordem, família, gênero, espécie e subespécie quando há uma coluna `taxon rank`. Um nível ausente ou vazio é tratado como espécie somente se classe, ordem, família, gênero e epíteto específico estiverem completos; caso contrário, informe um nível. Cada linha exige os campos de classificação de classe até o nível selecionado. Revise cada mapeamento de coluna detectado antes de importar.

O painel conta as ordens, as famílias e os nomes de espécie completos distintos existentes no registro. Um total de táxons aparece quando o registro também contém nomes acima do nível de espécie. Essas são contagens do registro; o painel de estatísticas informa os táxons que os registros de espécimes de fato usam.

## Contexto do Darwin Core

Um nome registrado fornece os termos de identificação de uma exportação: `dwc:taxonID`, `dwc:kingdom`, `dwc:phylum`, `dwc:class`, `dwc:order`, `dwc:family`, `dwc:genus`, `dwc:specificEpithet`, `dwc:infraspecificEpithet`, `dwc:taxonRank`, `dwc:scientificNameAuthorship`, `dwc:vernacularName` e `dwc:taxonRemarks`.
