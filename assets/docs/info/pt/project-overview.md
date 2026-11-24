---
title: "Visão geral do projeto"
authors: []
sidebar:
  order: 0
---

Um projeto agrupa os locais, eventos de coleta, espécimes, pessoal, táxons, narrativas e arquivos de apoio de um mesmo trabalho de campo ou baseado em espécimes. Use `Edit` na parte inferior do painel Visão geral do projeto para atualizar as informações do projeto.

Defina o fuso horário do projeto para descrever os horários locais registrados. Alterar o fuso horário do projeto não converte os valores de data e hora existentes. O fuso horário é armazenado com o projeto e incluído nas exportações, para que aplicativos de terceiros possam interpretar os horários registrados. Os fusos horários são indicados em relação ao Tempo Universal Coordenado (UTC), o principal padrão de tempo usado no mundo, de UTC−12:00 a UTC+14:00, cada um com um nome Continente/Cidade. Por exemplo, o horário de Brasília aparece como `(UTC-03:00) America/Sao_Paulo`.

O UUID do projeto é um identificador único do projeto entre dispositivos. Para compartilhar o projeto com colaboradores, selecione o código QR no painel Visão geral do projeto para ampliá-lo ou salvá-lo, ou selecione `Export info` na parte inferior do painel. Os colaboradores escaneiam o código QR ao criar um novo projeto. As duas opções compartilham o UUID e os metadados do projeto, sem registros ou mídia.

Para um backup diário em campo, abra o menu e selecione `Export project`. ZIP e TAR.GZ incluem todos os registros e a mídia anexada disponível; o formato leve JSON.GZ contém registros sem mídia.

## Saiba mais

- [Projetos](https://nahpu.app/pt/usages/projects/)
- [Exportar](https://nahpu.app/pt/usages/export/#backup-strategy)
