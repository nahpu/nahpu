---
title: "Clima do evento"
sidebar:
  order: 0
---

Os campos de clima descrevem as condições observadas durante o evento de coleta, incluindo temperatura e umidade do ar, cobertura de nuvens, chuva e, quando se aplicam, temperatura da água, pH, oxigênio dissolvido e velocidade do fluxo. Registre os valores nas unidades exibidas e indique se são medições diretas, leituras de instrumento ou outra fonte documentada.

Os valores astronômicos são derivados da localização, da data e do horário do evento. Trate-os como contexto calculado, não como observações diretas. Se um resultado for inesperado, verifique as coordenadas do local selecionado, o fuso horário do projeto e os horários do evento antes de alterar outros dados. Não copie o clima entre eventos, a menos que a medição realmente valha para ambos.

## Contexto do Darwin Core

Os valores de clima, água e astronomia não têm termo próprio no Darwin Core. As exportações estruturadas levam cada valor registrado como uma medição do evento, preservando seu tipo e sua unidade, e as notas do ambiente viram `dwc:eventRemarks`.
