# Briefing para o Gemini: itens recriados do Restaurant City (estado em 2026-10-26)

Leia isto e depois `recriados/LEIA_ANTES_DE_MEXER.md` antes de qualquer mudança. Pasta do projeto: `C:\Users\Nashira\OneDrive\Documentos\Antigravity\01_PROJECTS\Restaurant City Arquivo\`.

## O que deu errado antes

Você aplicava `manifesto_lote1_final.json` e o Claude aplicava `manifesto.json`. `aplicar_itens.ps1` reconstrói o servidor a partir dos originais com **um** manifesto, então cada aplicação apagava os itens do outro. Além disso, os ids colidiam: 3080010 era o seu Bonsai e a Stone Lantern do Claude, e Daruma, Gong e Stone Lantern existiam com dois ids.

## Como está agora

1. **Manifesto único**: `recriados/manifesto.json`.
   - Os seus 14 itens e as 2 sobreposições de cadeira entraram **idênticos** à sua última versão, com os seus ids, porque a dona já os tinha comprado.
   - Os seus manifestos antigos estão em `recriados/historico/`. Não os aplique.
2. **`scripts/aplicar_itens.ps1` não aceita mais `-Manifesto`.**
   - Ele aplica só o `manifesto.json`.
   - Se algum arquivo do servidor mudou por fora desde a última aplicação, ele para e avisa.
   - Não escreva direto em `restaurant-city-server/public/`. Não faça patch binário no `game.swf`: código do jogo vai em `recriados/codigo/*.as`, e o aplicador recompila com o FFDec.
3. **Ids**: tabela em `LEIA_ANTES_DE_MEXER.md`. Próximo livre: **3080052**. Nunca mude o id de item existente nem reaproveite id.

## Mudanças de 2026-10-26 que afetam o seu trabalho

**Itens seus que mudaram**
- `RCR_ZenTable` (3080020): agora é `Decoration` com `type="surface"` (decoração que aceita peça em cima), por decisão da dona.
- `RCR_KatanaDecor` (3080017): agora é `Decoration` (é um suporte de chão), com o nome "Katana Decor".
- Os outros seus continuam iguais.

**Removido**
- `RCR_DarkwoodSink` (3080005), que estava com defeito. O id fica aposentado.

**Campos novos no manifesto** (todos em `LEIA_ANTES_DE_MEXER.md`)
- `operar`: vira `operateTimePercentage`.
- `quebra`: vira `breakCount`.
- `efeito`/`descricao`: textos da janela (i), gravados em `lang_en.bin` pelo `aplicar_textos.cjs`.
- `deslocX`: ajuste horizontal para itens 2×1/1×2.
- `soArte`: só o sprite, sem linha no catálogo.
- `estados`: **obrigatório para fogão**.
  - O `game.swf` faz `isStoveAvailable` = `item.content.mc_content.currentLabel == "idle"`. Sem uma peça interna `mc_content` com os rótulos `idle/cooking/done`, o jogo dá erro quando o cozinheiro usa o fogão.
  - Com `"estados": ["idle","cooking","done"]`, o injetor gera essa peça e uma classe com `addFrameScript` + `stop()` em cada estado. Decompilado e conferido no FFDec.
  - Bebidas (`drink`) e fliperamas (`interactive`) não precisam: o jogo só troca o estado se `mc_content` existir.

**Imagens mais nítidas**
- `scripts/preparar_nitido.ps1`: tira o fundo, apara e amplia 4× com `Nitidez.cs` (cores achatadas na paleta, contorno definido).
- No manifesto use `"altura"` (px no jogo) na vista, não `"escala"`: o injetor calcula a escala e o item mantém o tamanho.

**Itens acrescentados (28)**
- Ids 3080022–3080029 e 3080032–3080051.
- Faltam de propósito, com motivo em `LEIA_ANTES_DE_MEXER.md`: papéis de parede, porta de correr, privada High Tech, Stone Chair/Table, Dance Arcade e itens de fachada.

**Cherry Blossom Tree**
- `functions="PetalGenerator"`: pétalas pelo salão, com código novo em `recriados/codigo/`.
- Grupo Functional, 12 fishcash.

## Se você for continuar

**Cadeiras e privadas**
- Precisam de 4 vistas e de `<Classe>Overlay` (`soArte`). As suas Zen Chair e White Zen Chair são o modelo.
- Stone Chair e High Tech Smart Toilet estão pendentes.
- Privada: `type="chairItem, toilet"`; o blog diz "4× mais tempo sem quebrar, 40% mais rápido" (`operar: 60`, `quebra` alto).

**Fluxo de cada mudança**
1. Edite o `manifesto.json`.
2. Rode `scripts/aplicar_itens.ps1`.
3. Confira os sprites no JPEXS: `ferramentas/ffdec/ffdec-cli.jar -selectid <ids> -format sprite:png -export sprite <pasta> <swf>`.
4. Peça à dona para reiniciar o servidor. Ela pode estar jogando; não reinicie por conta própria.
5. Atualize a tabela de ids e o `Wiki/_Log.md`.
