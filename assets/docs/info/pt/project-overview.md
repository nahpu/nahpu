---
title: "Visão geral do projeto"
sidebar:
  order: 0
---

Um projeto agrupa o pessoal, os táxons, os locais, os eventos de coleta, os registros de espécimes, as narrativas e as mídias criados para um mesmo trabalho. Use `Edit` para atualizar seus metadados descritivos e `Export info` ou `Show QR` para compartilhar apenas sua identidade.

## UUID do projeto

O NAHPU atribui a cada projeto novo um identificador único universal (UUID). Importar as informações do projeto preserva esse UUID para que os dispositivos que colaboram reconheçam cópias do mesmo projeto. As informações do projeto não incluem registros nem mídias; use a transferência de projeto quando eles também precisarem ser movidos.

Mantenha a descrição do projeto concisa. Registre o contexto diário detalhado em Narratives.

## Fazendo backup em campo

O `Export project` é o backup diário de campo. Ele é menor e mais rápido que um backup do banco de dados e consome menos bateria, e o `Merge project` o lê de volta em outro dispositivo, então um aparelho perdido ou quebrado custa no máximo um dia de trabalho. Escolha ZIP ou TAR.GZ para levar a mídia, ou uma exportação leve `JSON.GZ` quando o envio precisar ser pequeno.

Reserve o `Backup database` para um checkpoint semanal e para o momento anterior a qualquer mesclagem. Ele copia a instalação inteira, e não um único projeto.

## Contexto do Darwin Core

O UUID do projeto identifica o conjunto de dados nas exportações e é gravado em `dwc:datasetID`.
