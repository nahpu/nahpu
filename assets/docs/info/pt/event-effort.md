---
title: "Esforço do evento"
sidebar:
  order: 0
---

Os registros de esforço descrevem como a amostragem foi realizada. Adicione cada método separadamente e registre o número de unidades, a marca e o modelo do equipamento, seu tamanho ou dimensões e as notas.

Use as mesmas unidades e nomes de método controlados em todo o projeto para que os esforços possam ser comparados. Duração, área e qualquer outra magnitude sem campo próprio ficam nas notas. Informe contexto suficiente para que outra pessoa entenda o esforço sem inferir dados ausentes.

## Contexto do Darwin Core

Em uma exportação tabular, o método é mapeado para `dwc:samplingProtocol` e as notas para `dwc:samplingEffort`; contagem, marca e tamanho não têm equivalente no Darwin Core e mantêm seus cabeçalhos do NAHPU. Os Darwin Core Archives e os Data Packages levam, em vez disso, a atividade e as notas do próprio evento, então registre também no evento aquilo que um arquivo precise informar.
