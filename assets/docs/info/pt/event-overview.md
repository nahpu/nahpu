---
title: "Visão geral do evento de coleta"
sidebar:
  order: 0
---

Um evento de coleta registra um esforço de amostragem definido em um site e período. Ele corresponde a um `dwc:Event` ou sampling event do Darwin Core e pode ser vinculado a vários registros de espécimes.

O NAHPU deriva o Event ID do Site ID e da data inicial; adicione um sufixo somente quando outro evento teria o mesmo identificador. Crie outro evento quando site, período, sampling protocol, esforço ou equipe mudar de forma relevante.

Duplicar um evento reutiliza a configuração aplicável, mas avança as datas e deixa os dados meteorológicos vazios. Revise cada valor copiado antes de usar.
