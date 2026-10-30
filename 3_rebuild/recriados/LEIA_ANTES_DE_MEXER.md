# Itens recriados: o caminho único (vale para Claude, Gemini e qualquer agente)

Em 2026-10-26 dois agentes aplicaram manifestos diferentes no servidor, e cada aplicação apagava os itens do outro. O motivo: o aplicador **reconstrói** o servidor a partir dos originais (`base/`) e só põe de volta o que está no manifesto que recebeu. A partir de agora existe um caminho só.

## Regras

1. **Um manifesto só: `recriados/manifesto.json`.**
   - Item novo entra como mais uma linha nele. Não se cria `manifesto_lote2.json` nem outro manifesto paralelo.
   - Os antigos (`manifesto_lote1*.json`, `manifesto_piloto.json`) estão em `historico/` só como registro.
2. **Nunca escrever direto no servidor.** `restaurant-city-server/public/swf/*.swf` e `public/data/*.xml|*.bin` são saída do aplicador. Mudança feita à mão lá some na próxima aplicação.
3. **Aplicar sempre com:**
   ```
   powershell -File "01_PROJECTS/Restaurant City Arquivo/scripts/aplicar_itens.ps1"
   ```
   - Ele não aceita outro manifesto.
   - Se algum arquivo do servidor mudou por fora desde a última aplicação, ele **para e avisa**. Primeiro leve a mudança para o manifesto (ou para `codigo/`), depois rode com `-Forcar`.
   - Depois de aplicar, reinicie o servidor: o catálogo fica em cache.
4. **Ids**: o jogo guarda no inventário da dona o **id** de cada item comprado.
   - Nunca trocar o id de um item que já existe.
   - Nunca reaproveitar id.
   - Item novo pega o próximo livre da tabela abaixo, e a tabela é atualizada aqui.
5. **Código do jogo (`game.swf`)**: só pelos arquivos `.as` em `recriados/codigo/` (ver `PLANO_itens_novos_no_jogo.md`, "Funções novas no game.swf"). Nada de patch binário direto no `game.swf` do servidor.
   - **Antes de copiar um decompilado para `codigo/`, veja se a classe já está lá.** Se estiver, edite o arquivo existente. Em 2026-10-28 uma cópia do original apagou o botão de troca do `WorldRestaurantPlay`.
   - Porta de 2 blocos (2026-10-28): `RoomItem.getEntranceTileX/Y()` devolve o bloco do vão (o 2º bloco) nas portas `RCR_*` de 2 blocos; nas outras, o próprio bloco da porta. Ele é usado em `WorldRestaurantPlay` (`hasValidEntrances`, `getValidDoors`, `walkToEntrance` na chegada do cliente) e em `actors/Customer.as` (abrir a porta na saída). No manifesto, `mascaraPorta` dá à porta uma máscara própria do vão (`<classe>_Mascara`) no lugar da DoorWayMask (914), que só cobre 1 bloco. Os quadros de `animPorta` são **só a abertura**, do fechado ao aberto: o injetor monta o fechamento tocando os quadros de volta.
   - `codigo/com/playfish/games/cooking/WorldRestaurantPlay.as` e `codigo/com/playfish/games/cooking/ui/WorldTradePanel.as` (2026-10-28): **troca de ingredientes no próprio restaurante**. Sem o patch do servidor a troca sempre falha, por isso o `game.swf` padrão do pacote sai sem o botão: `aplicar_itens.ps1 -SemTroca` não recompila o `WorldTradePanel` e tira a chamada `initOwnExchangeButton()` (2026-10-29).
     - O botão fica à direita do Mercado e é só o `TradeIcon` do jogo. Sem o peixinho da Playfish, de propósito: ele lembra fishcash e faria pensar que a troca é por fishcash. O botão é criado em `initOwnExchangeButton`.
     - O painel é o `WorldTradePanel` com o 3º parâmetro `true`. A dona clica em 3 ingredientes seus, um a um (pode repetir); clicar na caixa "Yours" desfaz a última escolha.
     - O pedido sai pela RPC 17 (`swapIngredient`) com `target` = a própria dona e os 3 códigos (hashes) separados por vírgula. A regra vale no servidor, em `restaurant-city-server/src/db/rpc-store.ts` (`ownExchangeAllowed` / `exchangeOwnIngredients`): o pedido pode ter no máximo a média das estrelas dos 3, arredondada para cima; o pedido não pode estar entre os 3; pode gastar tudo; o cadeado não bloqueia; sem limite diário. Teste: `test/own-ingredient-exchange.test.cjs`.
     - As constantes no `.as` só servem para a tela. Se a regra mudar, mude nos dois lugares.
     - O FFDec **não acrescenta classe nova** (`-replace` recusa, `-importScript` ignora sem avisar). Por isso a função entrou numa classe que já existe.
     - Os originais estão em `codigo/original/`.
   - `codigo/com/playfish/games/cooking/itemfunctions/RoomItemFunction.as` e `codigo/com/playfish/games/cooking/actors/MovingVisitActor.as` (2026-10-28): **o Monster Robot anda pelo salão** (função `RobotWalker`).
     - No modo de jogo, `RoomItemFunction` esconde o item parado e põe no lugar um `MovingVisitActor` (o ator das visitas, como o pinguim) com a arte `<classe>Andando`. Ao sair do modo de jogo, o ator sai e o item volta.
     - `MovingVisitActor.startRobot()` liga o modo robô: anda uma casa por vez (2 s por casa, a velocidade original das visitas), nunca dá meia-volta (só em beco sem saída), evita as últimas 6 casas, segue reto de 1 a 3 casas e então vira; para 1 a 3 s a cada 4 a 7 casas. Sem `startRobot()` as visitas continuam como antes.
     - Nasce na casa livre mais perto do item (`placeNear`). Só anda nas casas livres que existiam quando o modo de jogo abriu.
     - Arte do ator (`RCR_MonsterRobotAndando`, `soArte`, campo `filhos` do manifesto): um quadro só com as peças `mc_af`/`mc_ac` (andando de frente/costas) e `mc_pf`/`mc_pc` (parado); `robotShow()` liga a peça certa e espelha pelo `scaleX`. Antes eram 8 quadros trocados com `gotoAndStop`, e no Ruffle o desenho às vezes não trocava (ele andava de lado). A frente olha para baixo e à esquerda, as costas para cima e à esquerda.
     - Começa olhando e andando para onde o item foi girado: `startRobot(giro)`, giro + 1 = direção (frente espelhada = RIGHT, frente = DOWN, costas = LEFT, costas espelhada = UP). Antes todos começavam em DOWN (2026-10-29).
     - O console mostra `[RCR] RobotWalker: item em x,y; robo comeca em x,y` (via `PerfTrace.mark`; `trace` não aparece no Ruffle).
     - `content` é protegido no `BaseObject`: o FFDec recusa usá-lo de fora da classe.
     - O original está em `codigo/original/MovingVisitActor.as`.
   - `codigo/com/playfish/games/cooking/ui/ItemChooser.as` e `recriados/epocas.json` (2026-10-29): **itens de Halloween, Natal e Valentine só aparecem na loja na época.**
     - `epocas.json` lista os ids do catálogo original por época, com a janela `de`/`ate` em MM-DD: Halloween 10-01 a 11-07, Natal 12-01 a 01-06, Valentine 02-01 a 02-21. A lista foi montada pelo bloco de ids de cada lançamento e pelo blog oficial (out/2009, dez/2009, fev/2010). O tema japonês fica sempre na loja.
     - `aplicar_catalogo.cjs` põe `rcrEpoca="de:ate"` nesses itens. Em `getItemConfigsInGroup`, `rcrNaEpoca()` trata o item fora da janela como `invisible`: some da loja, e quem já tem continua vendo no inventário. Vale a data do computador do jogador. O servidor não confere a época na compra.
     - O original está em `codigo/original/ItemChooser.as`.
   - `codigo/com/playfish/games/cooking/RoomItem.as` e `codigo/com/playfish/games/cooking/actors/Waitor.as` (2026-10-29): **mesa de 2+ blocos serve um cliente por bloco.**
     - O jogo guarda um pedido só por mesa (`tableTopOrder`) e `isTableFree` recusa a mesa enquanto ele existe. Numa mesa de 2 blocos isso dava 1 lugar (ou, na 1ª tentativa de correção, 4).
     - `RoomItem`: `tableTopOrder` virou getter/setter e devolve `null` numa mesa de 2+ blocos (`rcrMesaGrande`). O lugar é o bloco: `rcrLugarLivre(cadeira)` olha o bloco em frente à cadeira, `rcrOcupar` e `rcrLiberar` guardam o pedido por bloco na mesa inteira (`rcrRaizMesa`: a fileira de trás é um sub-item). Pedido de cliente que já foi embora não segura o lugar.
     - `Customer` (estados `DECIDING` e `NO_CLEAN_TABLE`) e `WorldRestaurantPlay` (`getEmptyChairs`, saída do cliente e pagamento) chamam essas funções. A mesa de 1 bloco continua como no original.
     - `Waitor` (estado `STATE_SERVING`): na mesa grande o prato vai no bloco em frente à cadeira, na altura do tampo da mesa inteira e com a maior prioridade de desenho entre as peças da mesa (com a da peça de trás, o prato do bloco da frente ficava embaixo da fileira da frente). Antes ia no bloco de origem, e o sub-item devolvia altura errada (o prato ficava no chão).
     - O original está em `codigo/original/Waitor.as`.
   - `codigo/com/playfish/games/cooking/RoomItem.as` (2026-10-28): em `getRowMask`, um item `surface` de 2+ blocos tem a fileira da frente mascarada só até o tampo (`itemHeight`), não `itemHeight + 20`. Sem isso, o que se põe na metade de trás da mesa sai cortado pela metade da frente. O original decompilado está em `codigo/original/RoomItem.as`.
6. **Originais**: `recriados/base/` não se edita. `aplicar_itens.ps1 -Restaurar` volta o servidor a eles.

## Ids em uso (faixa livre 308xxxx)

| Id | Classe | Item | Grupo / preço / comportamento |
|---|---|---|---|
| 3080001 | RCR_MonsterRobot (+ RCR_MonsterRobotAndando, so arte) | Monster Robot | Functional, **25 fishcash** (desde 2026-10-29; era 17); functions=RobotWalker (anda pelo salao, sem vai-e-volta); 30% maior desde 2026-10-28; `angulosIsolados` (giro volta para a frente, 2026-10-29) |
| 3080002 | — | (aposentado: Daruma duplicado, use 3080012) | — |
| 3080003 | — | (aposentado: Gong duplicado, use 3080013) | — |
| 3080004 | RCR_AsianFishTank | Fish Tank (Taste of Asia) | Decoration, 2.500 |
| 3080005 | — | (aposentado 2026-10-26: Darkwood Sink removida a pedido da dona, estava com defeito) | — |
| 3080006 | RCR_SushiBar | Sushi Bar | **Removido em 2026-10-29** (fora do manifesto e do pacote; arte em `itens_removidos/`; ninguém no dev.db tinha cópia) |
| 3080007 | RCR_CherryBlossomTree | Cherry Blossom Tree | Functional, **15 fishcash** (desde 2026-10-29; era 12); functions=PetalGenerator, 2x2 |
| 3080008 | RCR_JapaneseDivider | Japanese Divider | **Removido em 2026-10-29** (fora do manifesto e do pacote; arte em `itens_removidos/`; ninguém no dev.db tinha cópia) |
| 3080009 | RCR_JapanesePond | Japanese Pond | Decoration, 10.000; 2x2; agua das cascatas correndo, espuma e ondas (12 quadros em `anim/`, 2026-10-29) |
| 3080010 | RCR_Bonsai | Bonsai Tree | Decoration, 1.600; type=stackable |
| 3080011 | RCR_StoneLantern | Stone Lantern | Decoration, 2.000 |
| 3080012 | RCR_Daruma | Daruma | Decoration, 1.800; type=stackable |
| 3080013 | RCR_Gong | Gong | Decoration, 2.000; type=stackable |
| 3080014 | RCR_BambooWaterFeature | Bamboo Water Feature | Decoration, 2.000 |
| 3080015 | RCR_SamuraiArmor | Samurai Armor | Decoration, 4.000 |
| 3080016 | RCR_TatamiMat | Tatami Mat | Floor Tile, 20; type=floorTileItem |
| 3080017 | RCR_KatanaDecor | Katana Decor | Decoration, 1.200 |
| 3080018 | RCR_ShurikenDecor | Shuriken Wall Decor | Wall Decoration, 800; type=wallDecorationItem |
| 3080019 | RCR_SushiSignDecor | Sushi Sign | Wall Decoration, 1.500; type=wallDecorationItem |
| 3080020 | RCR_ZenTable | Zen Table | Table, **8 fishcash**; type=tableItem, surface, 1x2 (mesa de verdade desde 2026-10-28); um lugar por cadeira e escala 0.272 (mesma altura de perna e tampo 1,5x a Small Zen Table) desde 2026-10-29 |
| 3080021 | RCR_SmallZenTable | Small Zen Table | Table, 1.200; type=tableItem, surface |
| 3080022 | RCR_SamuraiSwordDecor | Samurai Sword Decor | Decoration, 1.200 |
| 3080023 | RCR_CeremonialDrinkSet | Ceremonial Drink Set | Kitchen Appliance, **6 fishcash**; type=drink, operateTime 90%; dica "Serves drinks 10% faster" |
| 3080024 | RCR_DeliciousSignDecor | Delicious Sign Decor | Wall Decoration, 900; type=wallDecorationItem |
| 3080025 | RCR_JapaneseGardenPicture | Japanese Garden Picture | Wall Decoration, 2.500; type=wallDecorationItem; 4 blocos. Desde 2026-10-29 as portas são o próprio Shoji Screen Wallpaper e o jardim do meio tem um realce leve (`scripts/picture_com_shoji_da_parede.ps1` -> `frente_shoji_parede.png`) |
| 3080026 | RCR_SushiTable | Sushi Table | Table, 1.200; type=tableItem, surface |
| 3080027 | RCR_LongSushiTable | Long Sushi Table | Table, **8 fishcash**; type=tableItem, surface, 1x2; um lugar por cadeira e mesma escala da Sushi Table (62/228) desde 2026-10-29 |
| 3080028 | RCR_ZenGarden | Zen Garden | Decoration, 3.000; 1x2 |
| 3080029 | RCR_ZenRock | Zen Rock | Decoration, 2.200; 2x2 |
| 3080030 | RCR_ZenChair (+ RCR_ZenChairOverlay) | Zen Chair | Chair, 700; type=chairItem |
| 3080031 | RCR_WhiteZenChair (+ RCR_WhiteZenChairOverlay) | White Zen Chair | Chair, 700; type=chairItem |
| 3080032 | RCR_ZenStone | Zen Stone | Decoration, 900 |
| 3080033 | RCR_ZenPebble | Zen Pebble | Decoration, 500; type=stackable |
| 3080034 | RCR_GardenFireplace | Garden Fireplace | Decoration, 1.500 |
| 3080035 | RCR_GardenLamp | Garden Lamp | Decoration, 1.200 |
| 3080036 | RCR_JapaneseFishpond | Japanese Fishpond | Decoration, 8.000; 2x2 |
| 3080037 | RCR_JapaneseGardenPond | Japanese Garden Pond | Decoration, 10.000; **3x3 desde 2026-10-29** (era 2x2; arte 1,5x). Nenhuma fonte guardada diz o tamanho original; indícios de 3x3: o Koi Pond do original é 3x3 e a arte tem ponte, lanterna e árvore. Animado desde 2026-10-29, como no blog: composição em `comp/` (fundo sem a lótus + a lótus numa camada que anda), de `scripts/animar_japanese_garden_pond.ps1`. A lótus se move em todos os quadros do jogo (25 fps): balanço de 3,2 s de ~0,5 px e pausas paradas de 2, 3 e 2,5 s (ciclo de ~17 s). As versões em quadros inteiros (12 e depois 16) pulavam e pareciam glitch; estão em `itens_removidos/` |
| 3080038 | RCR_ToyEggMachine | Toy Egg Machine | **Removido em 2026-10-29** (fora do manifesto e do pacote; arte em `itens_removidos/`; ninguém no dev.db tinha cópia) |
| 3080039 | RCR_OctopusStatue | Octopus Statue | Decoration, 3.000 |
| 3080040 | RCR_PrawnSushiDecor | Prawn Sushi Decor | Decoration, 600; type=stackable |
| 3080041 | RCR_SalmonSushiDecor | Salmon Sushi Decor | Decoration, 600; type=stackable |
| 3080042 | RCR_YellowMakiDecor | Yellow Maki Decor | Decoration, 500; type=stackable |
| 3080043 | RCR_GreenMakiDecor | Green Maki Decor | Decoration, 500; type=stackable |
| 3080044 | RCR_RedMakiDecor | Red Maki Decor | Decoration, 700; type=stackable |
| 3080045 | RCR_SakuraMochiDecor | Sakura Mochi Decor | Decoration, 700; type=stackable |
| 3080046 | RCR_AdDivider | Ad Divider | Decoration, 2.000 |
| 3080047 | RCR_AdPost | Ad Post | Decoration, 1.800 |
| 3080048 | RCR_TeppanyakiGrill | Teppanyaki Grill | Kitchen Appliance, **10 fishcash**; dica "Cooks 10% faster"; type=kitchen, operateTime 90%, estados idle/cooking/done |
| 3080049 | RCR_ZenCircleTile | Zen Circle Tile | Floor Tile, 40; type=floorTileItem |
| 3080050 | RCR_ZenStripeTile | Zen Stripe Tile | Floor Tile, 40; type=floorTileItem |
| 3080051 | RCR_ZenTile | Zen Tile | Floor Tile, 40; type=floorTileItem |
| 3080052 | RCR_SingingFruit | Singing Fruit | **Removido em 2026-10-29** (fora do manifesto e do pacote; arte em `itens_removidos/`; ninguém no dev.db tinha cópia) |
| 3080053 | RCR_MelonRug | Melon Rug | Decoration, 1.500; 2x2; arte do Behance |
| 3080054 | RCR_StrawberryRug | Strawberry Rug | Decoration, 1.500; 2x2; arte do Behance |
| 3080055 | RCR_KiwiRug | Kiwi Rug | Decoration, 1.500; 2x2; arte do Behance |
| 3080056 | RCR_PottedMelonDivider | Potted Melon Divider | Decoration, 1.200; 1x2; arte do Behance |
| 3080057 | RCR_NosySquirrel | Nosy Squirrel | Decoration, 2.500; arte do Behance |
| 3080058 | RCR_CamouflageBear | Camouflage Bear | Decoration, 4.000; arte do Behance |
| 3080059 | RCR_PlatypusPond | Platypus Pond | **Removido em 2026-10-29** (fora do manifesto e do pacote; arte em `itens_removidos/`; ninguém no dev.db tinha cópia) |
| 3080060 | RCR_GhostStoryArcade | Ghost Story Arcade | Functional, 9.000; type=interactive; 2x2; arte do Behance |
| 3080061 | RCR_PixelDecalFruitPunch | Pixel Decal - Fruit Punch | Wall Decoration, 800; type=wallDecorationItem; arte do Behance |
| 3080062 | RCR_PixelDecalGooeyMonster | Pixel Decal - Gooey Monster | Wall Decoration, 800; type=wallDecorationItem; arte do Behance |
| 3080063 | RCR_PixelDecalPotato | Pixel Decal - Potato <3 | Wall Decoration, 800; type=wallDecorationItem; arte do Behance |
| 3080064 | RCR_PixelDecalHorizon | Pixel Decal - Horizon | **Removido em 2026-10-29** (fora do manifesto e do pacote; arte em `itens_removidos/`; ninguém no dev.db tinha cópia) |
| 3080065 | RCR_PixelDecalSkyline | Pixel Decal - Skyline | **Removido em 2026-10-29** (fora do manifesto e do pacote; arte em `itens_removidos/`; ninguém no dev.db tinha cópia) |
| 3080066 | RCR_ArcheoMosaic | Archeo Mosaic | **Removido em 2026-10-29** (fora do manifesto e do pacote; arte em `itens_removidos/`; ninguém no dev.db tinha cópia) |
| 3080067 | RCR_LouisBiltong | Louis Biltong | Decoration, 3.000; arte do Behance |
| 3080068 | RCR_NewOrleansJazzyDuo | New Orleans Jazzy Duo | Decoration, 4.000; arte do Behance |
| 3080069 | RCR_NewOrleansJukebox | New Orleans Jukebox | Decoration, 5.000; arte do Behance |
| 3080070 | RCR_DirectorGourmetKing | Director Gourmet King and Assistant | **Removido em 2026-10-29** (fora do manifesto e do pacote; arte em `itens_removidos/`; ninguém no dev.db tinha cópia) |
| 3080071 | RCR_AlessandraClapper | Alessandra Clapper | Decoration, 2.500; arte do Behance |
| 3080072 | RCR_FunInACupDispenser | Fun in a Cup Drink Dispenser | **Removido em 2026-10-29** (fora do manifesto e do pacote; arte em `itens_removidos/`; ninguém no dev.db tinha cópia) |
| 3080073 | RCR_TheWateringHole | The Watering Hole | Decoration, 6.000; 2x2; arte do Behance |
| 3080074 | RCR_FailedKnightFigurine | Failed Knight Figurine | Decoration, 3.500; arte do Behance |
| 3080075 | RCR_EvilTree | Evil Tree | Decoration, 6.000; 2x2; arte do Behance |
| 3080076 | RCR_JungleRuinSink | Jungle Ruin Fountain | **Removido em 2026-10-29** (fora do manifesto e do pacote; arte em `itens_removidos/`; ninguém no dev.db tinha cópia) |
| 3080077 | RCR_JungleRuinTorch | Jungle Ruin Torch | **Removido em 2026-10-29** (fora do manifesto e do pacote; arte em `itens_removidos/`; ninguém no dev.db tinha cópia) |
| 3080078 | RCR_JungleRuinDivider | Jungle Ruin Divider | **Removido em 2026-10-29** (fora do manifesto e do pacote; arte em `itens_removidos/`; ninguém no dev.db tinha cópia) |
| 3080079 | RCR_JungleRuinDividerCorner | Jungle Ruin Divider Corner | **Removido em 2026-10-29** (fora do manifesto e do pacote; arte em `itens_removidos/`; ninguém no dev.db tinha cópia) |
| 3080080 | RCR_ExplorerGourmetKing | Explorer Gourmet King | **Removido em 2026-10-29** (fora do manifesto e do pacote; arte em `itens_removidos/`; ninguém no dev.db tinha cópia) |
| 3080081 | RCR_CheeseyVarities | Cheesey Varities | Decoration, 2.500; arte do Behance |
| 3080082 | RCR_MarbyLotusPool | Marby Lotus Pool | **Removido em 2026-10-29** (fora do manifesto e do pacote; arte em `itens_removidos/`; ninguém no dev.db tinha cópia) |
| 3080083 | RCR_LibertyBell | Liberty Bell | Decoration, 3.000; arte do Behance |
| 3080084 | RCR_SakuraWallpaper | Sakura Wallpaper | Wallpaper, 1.200 |
| 3080085 | RCR_ShojiScreenWallpaper | Shoji Screen Wallpaper | Wallpaper, 1.000 |
| 3080086 | RCR_JapaneseSlidingDoor | Japanese Sliding Door | Door, 1.200; 2 blocos |
| 3080087 | RCR_JapaneseDividerCorner | Japanese Divider Corner | **Removido em 2026-10-29** (fora do manifesto e do pacote; arte em `itens_removidos/`; ninguém no dev.db tinha cópia) |
| 3080088 | RCR_SmallJapaneseDivider | Japanese Divider (era Small Japanese Divider) | Decoration, 600; mesma arte da Japanese Divider em escala 40/161: os corpos dos postes vizinhos se tocam (colunas 10..170 do frente.png = um passo de bloco); a normal compartilha o poste; desde 2026-10-29 na escala 40/154 (postes um pouco mais juntos) |
| 3080089 | RCR_SmallJapaneseDividerCorner | Japanese Divider Corner (era Small Japanese Divider Corner) | Decoration, 600; o V na escala da Small |
| 3080090 | RCR_SpringDivider | Spring Divider | Decoration, 400; tamanho e base do Oak Room Divider (49,2 px, base 32,4) |
| 3080091 | RCR_SpringDividerBlock | Spring Divider Block | Decoration, 800; type=surface; tamanho e base do Oak Room Divider Block (80 px, base 39,65) |
| 3080092 | RCR_AutumnFloor | Autumn Floor | **Removido em 2026-10-29** (fora do manifesto e do pacote; arte em `itens_removidos/`; ninguém no dev.db tinha cópia) |
| 3080093 | RCR_IcyFloorTile | Icy Floor Tile | **Removido em 2026-10-29** (fora do manifesto e do pacote; arte em `itens_removidos/`; ninguém no dev.db tinha cópia) |
| 3080094 | RCR_MagicFloorTile | Magic Floor Tile | Floor Tile, 40; type=floorTileItem |
| 3080095 | RCR_CloudFlooring | Cloud Flooring | Floor Tile, 40; type=floorTileItem |
| 3080096 | RCR_ClubsTile | Clubs Tile | Floor Tile, 40; type=floorTileItem |
| 3080097 | RCR_DiamondTile | Diamond Tile | Floor Tile, 40; type=floorTileItem |
| 3080098 | RCR_MultiTile | Multi Tile | Floor Tile, 40; type=floorTileItem |
| 3080099 | RCR_SpadesTile | Spades Tile | Floor Tile, 40; type=floorTileItem |
| 3080100 | RCR_DarkBlueFloor | Dark Blue Floor | Floor Tile, 40; type=floorTileItem |
| 3080101 | RCR_BambooFlooring | Bamboo Flooring | Floor Tile, 40; type=floorTileItem |
| 3080102 | RCR_TerracottaTile | Terracotta Tile | Floor Tile, 40; type=floorTileItem |
| 3080103 | RCR_WonderlandTileRed | Wonderland Tile - Red | Floor Tile, 40; type=floorTileItem |
| 3080104 | RCR_GrassTile | Grass Tile | Floor Tile, 40; type=floorTileItem |
| 3080105 | RCR_GardenPathTile1 | Garden Path Tile 1 | Floor Tile, 40; type=floorTileItem |
| 3080106 | RCR_GardenPathTile2 | Garden Path Tile 2 | Floor Tile, 40; type=floorTileItem |
| 3080107 | RCR_GardenPathTile3 | Garden Path Tile 3 | Floor Tile, 40; type=floorTileItem |
| 3080108 | RCR_GardenPathTile4 | Garden Path Tile 4 | Floor Tile, 40; type=floorTileItem |
| 3080109 | RCR_GardenPathTile5 | Garden Path Tile 5 | Floor Tile, 40; type=floorTileItem |
| 3080110 | RCR_GardenPathTile6 | Garden Path Tile 6 | Floor Tile, 40; type=floorTileItem |
| 3080111 | RCR_TurkishStoneTile | Turkish Stone Tile | Floor Tile, 40; type=floorTileItem |
| 3080112 | RCR_SandTile | Sand Tile | Floor Tile, 40; type=floorTileItem |
| 3080113 | RCR_SandTile2 | Sand Tile 2 | Floor Tile, 40; type=floorTileItem |
| 3080114 | RCR_SandTile3 | Sand Tile 3 | Floor Tile, 40; type=floorTileItem |
| 3080115 | RCR_SportsCourtTile1 | Sports Court Tile 1 | Floor Tile, 40; type=floorTileItem |
| 3080116 | RCR_SportsCourtTile2 | Sports Court Tile 2 | Floor Tile, 40; type=floorTileItem |
| 3080117 | RCR_SportsCourtTile3 | Sports Court Tile 3 | Floor Tile, 40; type=floorTileItem |
| 3080118 | RCR_SportsCourtTile4 | Sports Court Tile 4 | Floor Tile, 40; type=floorTileItem |
| 3080119 | RCR_SportsCourtTile5 | Sports Court Tile 5 | Floor Tile, 40; type=floorTileItem |
| 3080120 | RCR_OktoberfestTile | Oktoberfest Tile | Floor Tile, 40; type=floorTileItem |
| 3080121 | RCR_SunGodTile | Sun God Tile | Floor Tile, 40; type=floorTileItem |
| 3080122 | RCR_MagicChocolateTile | Magic Chocolate Tile | Floor Tile, 40; type=floorTileItem |
| 3080123 | RCR_MagicWaterTile | Magic Water Tile | **Removido em 2026-10-29** (fora do manifesto e do pacote; arte em `itens_removidos/`; ninguém no dev.db tinha cópia) |
| 3080124 | RCR_DarkMagicWaterTile | Dark Magic Water Tile | **Removido em 2026-10-29** (fora do manifesto e do pacote; arte em `itens_removidos/`; ninguém no dev.db tinha cópia) |
| 3080125 | RCR_SportsCourtTile6 | Sports Court Tile 6 | Floor Tile, 40; type=floorTileItem; canto que faltava (espelho horizontal do 3) |
| 3080126 | RCR_SportsCourtTile7 | Sports Court Tile 7 | Floor Tile, 40; type=floorTileItem; canto que faltava (espelho vertical do 4) |
| 3080127 | RCR_MagicWaterCorner1 | Magic Water Corner 1 | Floor Tile, 60 (desde 2026-10-29; era 900); type=floorTileItem; canto de cima (borda clara nos 2 lados de cima). Arte de `scripts/gerar_agua_magica.ps1` (2026-10-29) |
| 3080128 | RCR_MagicWaterCorner2 | Magic Water Corner 2 | Floor Tile, 60 (desde 2026-10-29; era 900); type=floorTileItem; canto da direita. Arte de `scripts/gerar_agua_magica.ps1` (2026-10-29) |
| 3080129 | RCR_MagicWaterCorner3 | Magic Water Corner 3 | Floor Tile, 60 (desde 2026-10-29; era 900); type=floorTileItem; canto de baixo. Arte de `scripts/gerar_agua_magica.ps1` (2026-10-29) |
| 3080130 | RCR_MagicWaterCorner4 | Magic Water Corner 4 | Floor Tile, 60 (desde 2026-10-29; era 900); type=floorTileItem; canto da esquerda. Arte de `scripts/gerar_agua_magica.ps1` (2026-10-29) |
| 3080131 | RCR_MagicWaterPlain | Magic Water (Plain) | Floor Tile, 60 (desde 2026-10-29; era 900); type=floorTileItem; lisa, para o meio (cor 144,207,230). Arte de `scripts/gerar_agua_magica.ps1` (2026-10-29) |
| 3080132 | RCR_DarkMagicWaterCorner1 | Dark Magic Water Corner 1 | Floor Tile, 60 (desde 2026-10-29; era 900); type=floorTileItem; canto de cima. Arte de `scripts/gerar_agua_magica.ps1` (2026-10-29) |
| 3080133 | RCR_DarkMagicWaterPlain | Dark Magic Water (Plain) | Floor Tile, 60 (desde 2026-10-29; era 900); type=floorTileItem; lisa (cor 10,64,104). Arte de `scripts/gerar_agua_magica.ps1` (2026-10-29) |
| 3080134 | RCR_DarkMagicWaterCorner2 | Dark Magic Water Corner 2 | Floor Tile, 60 (desde 2026-10-29; era 900); type=floorTileItem; canto da direita. Arte de `scripts/gerar_agua_magica.ps1` (2026-10-29) |
| 3080135 | RCR_DarkMagicWaterCorner3 | Dark Magic Water Corner 3 | Floor Tile, 60 (desde 2026-10-29; era 900); type=floorTileItem; canto de baixo. Arte de `scripts/gerar_agua_magica.ps1` (2026-10-29) |
| 3080136 | RCR_DarkMagicWaterCorner4 | Dark Magic Water Corner 4 | Floor Tile, 60 (desde 2026-10-29; era 900); type=floorTileItem; canto da esquerda. Arte de `scripts/gerar_agua_magica.ps1` (2026-10-29) |
| 3080137 | RCR_MagicWaterEdge1 | Magic Water Edge 1 | Floor Tile, 60 (desde 2026-10-29; era 900); type=floorTileItem; lado de cima-esquerda. Arte de `scripts/gerar_agua_magica.ps1` (2026-10-29) |
| 3080138 | RCR_MagicWaterEdge2 | Magic Water Edge 2 | Floor Tile, 60 (desde 2026-10-29; era 900); type=floorTileItem; lado de cima-direita. Arte de `scripts/gerar_agua_magica.ps1` (2026-10-29) |
| 3080139 | RCR_MagicWaterEdge3 | Magic Water Edge 3 | Floor Tile, 60 (desde 2026-10-29; era 900); type=floorTileItem; lado de baixo-direita. Arte de `scripts/gerar_agua_magica.ps1` (2026-10-29) |
| 3080140 | RCR_MagicWaterEdge4 | Magic Water Edge 4 | Floor Tile, 60 (desde 2026-10-29; era 900); type=floorTileItem; lado de baixo-esquerda. Arte de `scripts/gerar_agua_magica.ps1` (2026-10-29) |
| 3080141 | RCR_DarkMagicWaterEdge1 | Dark Magic Water Edge 1 | Floor Tile, 60 (desde 2026-10-29; era 900); type=floorTileItem; lado de cima-esquerda. Arte de `scripts/gerar_agua_magica.ps1` (2026-10-29) |
| 3080142 | RCR_DarkMagicWaterEdge2 | Dark Magic Water Edge 2 | Floor Tile, 60 (desde 2026-10-29; era 900); type=floorTileItem; lado de cima-direita. Arte de `scripts/gerar_agua_magica.ps1` (2026-10-29) |
| 3080143 | RCR_DarkMagicWaterEdge3 | Dark Magic Water Edge 3 | Floor Tile, 60 (desde 2026-10-29; era 900); type=floorTileItem; lado de baixo-direita. Arte de `scripts/gerar_agua_magica.ps1` (2026-10-29) |
| 3080144 | RCR_DarkMagicWaterEdge4 | Dark Magic Water Edge 4 | Floor Tile, 60 (desde 2026-10-29; era 900); type=floorTileItem; lado de baixo-esquerda. Arte de `scripts/gerar_agua_magica.ps1` (2026-10-29) |
| 3080145 | RCR_WhiteSofaCorner | White Sofa Corner | Decoration, 800; 1x1; o canto em V do White Modern Sofa (blog 2010-06-14, "beige-corner-chair"). 4 ângulos no sentido horário montados com o próprio sofá original (`scripts/montar_sofa_corner.ps1`, quadros do Chair19 em `sofa_original/`); base 39,5 = a do sofá. Os lados "<" e ">" (ângulos 4 e 2) foram corrigidos à mão pela dona em `Edições/V Sofa.png` e encaixados por `scripts/sofa_corner_lados_da_dona.ps1` (rodar depois do montar) |
| 3080146 | RCR_BlackSofaCorner | Black Sofa Corner | Decoration, 800; idem com o Black Modern Sofa (Chair20, "smoke-corner-chair") |
| 3080147+ | — | **livres** (próximo: 3080147) | — |

Sem id (só arte, `"soArte": true`): `RCR_Petal01..03` (pétalas da cerejeira), `RCR_ZenChairOverlay`, `RCR_WhiteZenChairOverlay`.

Atenção: no `manifesto_lote1.json` antigo, 3080017 era Zen Circle Tile e 3080019 era Sakura Wallpaper. A dona tem um 3080017 e um 3080019 guardados no inventário, comprados quando esse lote estava no ar. Hoje esses ids são Katana Decor e Sushi Sign. Zen Circle/Stripe/Tile voltaram com ids novos (3080049–3080051).

Ficaram de fora, de propósito (2026-10-26):
- **Sakura Wallpaper e Shoji Screen Wallpaper**: papel de parede tem formato próprio de sprite, que o injetor ainda não gera.
- **Japanese Sliding Door**: porta substitui a parede; o formato também é próprio.
- **High Tech Smart Toilet e Stone Chair**: precisam de 4 vistas diferentes (não há imagem das costas) e da sobreposição `Overlay`.
- **Stone Table**: a imagem do blog não foi baixada.
- **Dance Arcade**: só há uma captura de tela com fundo.
- **Itens de fachada** (Japanese Roof/Wall/Doorway/Window, Sakura Tree externa, Mount Fuji...): vão no `outdoor_asset.swf` + `front.xml`, que o aplicador ainda não trata.

## Campos do manifesto (resumo)

- `classe`, `id`, `nome`, `grupo`: o grupo é o nome exato do `<group>` no `restaurant.xml` (Decoration, Functional, Table, Chair, Floor Tile, Wall Decoration, Kitchen Appliance, Drink...).
- `custo` (moedas) **ou** `cash` (fishcash).
- `tipo`: atributo `type`. Exemplos:
  - `stackable`: vai em cima de outra peça;
  - `surface`: aceita peça `stackable` em cima;
  - `tableItem, surface`: mesa de refeição;
  - `chairItem`: cadeira;
  - `kitchen`: fogão;
  - `drink`: bebidas;
  - `interactive`: tipo fliperama, o cliente usa e paga.
- `sizeX`/`sizeY`: quantos pisos o item ocupa.
- `functions`: efeito especial que precisa de código no `game.swf` (ex. `PetalGenerator`).
- `operar`: vira `operateTimePercentage`. 90 = 10% mais rápido; serve para fogão, bebida, privada, cama.
- `quebra`: vira `breakCount`, o número de usos até quebrar. Sem ele, o item nunca quebra.
- `pisoChef: true` (fogão): monta o item como os fogões oficiais. A raiz recebe `sub0`, que é o próprio fogão, exportado como `<classe>Rotations`, e `sub1`, que é o `ChefFloor` oficial (o tapete cinza com o prato onde o chef fica) em (40,20). O `createRoomItems` do jogo transforma o tapete num item filho no bloco da frente e o gira junto. O fogão passa a ocupar 2 blocos, igual aos oficiais. Em uso no Teppanyaki Grill desde 2026-10-28.
- `estados`: obrigatório em fogão. Gera a peça interna `mc_content` com rótulos e `stop()`. Sem isso o jogo dá erro quando o cozinheiro usa o fogão (`isStoveAvailable` lê `mc_content.currentLabel`). Fogão: `["idle","cooking","done"]`.
- `descricao`/`efeito`: textos da janela (i). O botão (i) aparece sozinho quando há `efeito` ou `functions`.
- Arte: `frente`+`quadros`+`escala` ou `vistas`+`angulos`. Detalhes:
  - na vista, prefira `"altura"` (px no jogo) a `"escala"`: assim a imagem pode ser 4× maior (mais nítida) sem mudar o tamanho no jogo;
  - `base` = px da base da arte abaixo da origem (canto de cima do losango do piso);
  - `deslocX` = ajuste horizontal para itens 2×1 (+20) ou 1×2 (−20).
- `soArte: true`: só o sprite, sem linha no catálogo (partículas, `Overlay` de cadeira).
- `invisivel: true` (não usado desde 2026-10-29; os ocultos saíram do manifesto): vira `invisible="true"` no catálogo. O item sai da loja, mas quem já tem continua vendo no inventário e usando (o `ItemChooser` só mostra item invisível com estoque). É o jeito de "remover" sem quebrar restaurantes que já têm o item.
- `dica`: a linha azul que aparece ao passar o mouse no item da loja (`ItemToolTip<classe>` no `lang_en`), como o "Cooks 8% faster" do Valentine Stove.
- `angulosIsolados: true`: cada ângulo num sprite próprio e numa profundidade própria. Usar quando o giro trava num ângulo no Ruffle (Monster Robot, 2026-10-29: do 4º para o 1º ele não voltava para a frente, porque os 4 quadros reusavam as mesmas duas peças na mesma profundidade). Não combina com `estados`.
- `filhos: [{ vista, nome }]`: em vez de um quadro por ângulo, um quadro só com cada vista como peça nomeada (o código liga a certa). Usado no ator do Monster Robot.

Imagem nova: `scripts/preparar_nitido.ps1 -Entrada <png do blog> -Saida recriados\RCR_X\frente.png` (tira o fundo, apara e amplia 4× com contorno definido).

## Lotes prontos sem id (2026-10-26)

Para juntar vários itens de uma vez sem pisar no trabalho de outro agente, prepare um arquivo de lote no formato do manifesto, mas **sem `id`** (ex. `recriados/lote_behance.json`, gerado por `scripts/preparar_behance.ps1`). Depois:
```
node scripts/juntar_lote.cjs recriados/lote_behance.json
powershell -File scripts/aplicar_itens.ps1
```
`juntar_lote.cjs` relê o `manifesto.json` do disco na hora, dá os próximos ids livres (pulando os em uso e os aposentados), ignora classe que já existe e grava de uma vez. Rodar de novo não duplica nada.
