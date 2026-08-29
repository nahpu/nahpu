---
title: "Mídia"
sidebar:
  order: 0
---

A mídia armazena as imagens, os áudios e os vídeos associados a um registro do projeto. Use `Add` para importar um arquivo ou, quando o dispositivo permitir, para tirar uma foto, gravar um vídeo ou gravar áudio.

Edite o nome do arquivo, a legenda, a etiqueta e quem fotografou, para que outra pessoa saiba o que o arquivo mostra. A categoria segue o tipo de arquivo, e a data de captura, a câmera e a lente são lidas dos metadados do próprio arquivo quando ele os traz. Confirme que um arquivo gerenciado abre antes de sair do campo e inclua as mídias nos backups ou nas transferências completas de projeto quando elas precisarem ir para outro dispositivo.

A mídia descreve o recurso, não o espécime. Mantenha as observações sobre o organismo no registro do espécime.

## Contexto do Darwin Core

A mídia anexada a um espécime é exportada junto com a ocorrência como um registro `ac:Media` do Audiovisual Core: a legenda ou o nome do arquivo vira o título, a data de captura vira a data de criação e quem fotografou vira a pessoa criadora. Em exportações tabulares, os campos de mídia são mapeados para termos do Dublin Core, como `dcterms:title`, `dcterms:created`, `dcterms:type` e `dcterms:identifier`.
