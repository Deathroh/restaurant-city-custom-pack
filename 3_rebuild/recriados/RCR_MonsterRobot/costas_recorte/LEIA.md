---
tags: [restaurant-city, itens-recriados, monster-robot]
fontes:
  - "RCR_MonsterRobot/costas_ia.png (imagem de costas gerada por IA, 848×1264)"
  - "Sprite da loja de 2010 (blog oficial, 2010-04-21), usado como referência de cor"
criado: 2026-10-28
atualizado: 2026-10-28
---

# Monster Robot de costas: quadros por recorte

Ainda não entraram no `manifesto.json` nem no jogo. São insumo para quando o robô ganhar a vista de costas com rugido.

| Arquivo | O que é |
|---|---|
| `costas_base_112x167.png` | A imagem de costas da IA tratada: fundo branco removido, reduzida para a altura do sprite original e com os cinzas e azuis trocados pelos do sprite de 2010 (casamento de distribuição de luminância). |
| `costas_neutro.png` | Pose parada. |
| `costas_bracos.png` | Braço para frente na altura do peito, cabeça um pouco erguida, visor aceso. Corresponde a `frente/2.png`. |
| `costas_rugido.png` | Cabeça erguida e boca aberta com dentes. Corresponde a `frente/4.png`. |

- Os três quadros têm 160×190 px, fundo transparente, e o ponto no chão entre os pés fica em **(80, 172)**. No `costas_base`, esse ponto fica em (36, 152).
- **Não são do mesmo tamanho que `frente/*.png` (138×170).** Para o injetor, alinhe pelo ponto no chão, não pelo canto.
- Olham para cima e à esquerda; o lado direito é o espelho. Os `costas/1-4.png` antigos olham para o outro lado.
- Foram feitos em 2026-10-28, na sessão do artifact "Monster Robot" (claude.ai/artifact/C4GtztQRxfBmsQGsMCJPcF). Lá também estão o passo de 8 quadros (frente e costas) e o ciclo do rugido: neutro → braços (0,43 s) → neutro → rugido (0,9 s) → neutro, a cada 7 s.
