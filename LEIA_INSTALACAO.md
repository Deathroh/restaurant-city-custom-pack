---
tags: [restaurant-city, instalacao, itens-recriados, julho-2010]
fontes:
  - "recriados/manifesto.json, recriados/julho2010/ e scripts/aplicar_itens.ps1 (Restaurant City Arquivo)"
  - "restaurant-city-server (fork de Dippys/Restaurant-City-Server, commit cdef695)"
criado: 2026-10-28
atualizado: 2026-11-04
---

# Restaurant City Reborn: Guia de Instalação (itens recriados + build de julho/2010)

> 🇺🇸 **English guide: [README.md](README.md).**

Compatível com o servidor [Dippys/Restaurant-City-Server](https://github.com/Dippys/Restaurant-City-Server) (testado no commit `cdef695`).

Versão do pacote: **2026-11-04**. A anterior era a de 2026-10-29.

---

## 🆕 O que mudou desde o pacote de 29/10

- **Build oficial de julho de 2010.** Entram **494 itens oficiais** que a build 0.9.143a do servidor não tinha: Lounge Bar, Wedding, Underwater, Alice no País das Maravilhas, tema japonês, Primavera, México, Espaço, os bichinhos e o Sushi Bar. A arte e os dados vêm dos arquivos de julho/2010 que o projeto Restaurant Origins preservou. Os itens usam o **id original da Playfish**. Também foram atualizados os valores de 53 itens que já existiam.
- **As recriações viraram os originais.** 77 itens que tínhamos recriado (Monster Robot, Cherry Blossom Tree, Zen Table, Magic Water, Sofa Corner...) agora são os itens oficiais de julho. **Quem instalou o pacote de 29/10 precisa migrar o banco** (veja o aviso 1 abaixo).
- **50 receitas e 11 ingredientes de 2010.** Entram as 7 receitas da cadeia do Sushi Bar (Miso Soup, Yaki Gyoza, Seaweed Salad, Salmon Sashimi, Sushi Selection, Salmon Handrolls, Sakura Mochi) e mais **43 receitas de fevereiro a julho de 2010** (Rainbow Soup, Monster Burger, Chocolate Dream, as bebidas do Lounge Bar e outras), com o desenho original de cada prato. Também entram 11 ingredientes: Salmon, Seaweed, Pineapple, Coconut, Crab, Cherry, Mint, Easter Egg, Easter Spices, Chick Figurine e Chocolate Bunny. As 21 receitas que eram de tempo limitado em 2010 ficam **sempre disponíveis**. Por isso o pacote agora substitui **9 arquivos**, não mais 5.
- **Sushi Bar:** cada um dos 8 pratos da esteira é de uma receita de sushi e só aparece cheio quando a receita foi **dominada** (nível 10), esteja ela no cardápio ou não. No começo, só o Salmon Sashimi aparece; os outros pratos giram vazios.
- **Prêmios de domínio de receita:** ao dominar (nível 10) uma das 6 receitas especiais, o item de prêmio exclusivo é desbloqueado e adicionado direto ao inventário (Salmon Sashimi dá o Sushi Bar, Coco Colada dá o Lounge Bar, Eat Me dá o Pet Cheshire Cat, Boston Cooler dá a Night Sculpture, Chili Crabs dá o Sunken Ship Prow e Zero Gravity Salad dá o Blue Alien Pet).
- **Correções no `game.swf`:**
  - **Garçons:** o cálculo de rotas do garçom ficou rápido. Antes, um salão com muitas mesas longe da cozinha travava o jogo ao abrir ("A script in this movie has taken too long").
  - **Arcos de passar por baixo:** o Sunken Ruins Arch e o Wedding Trellis agora aparecem montados certo, e o cliente passa pelo bloco do meio.
  - **Itens de época:** os de Halloween, Natal e Valentine só aparecem na loja na época deles.
  - **Itens de julho com efeito:** os bichinhos andam, o Magic Water liga as bordas, a Rain Cloud faz chover, o Pet Cheshire Cat aparece e some, os enfeites que soltam pétalas, borboletas ou notas funcionam, e há os bônus de demanda.
- **Loja sem repetidos.** Saíram da loja o Teppanyaki Grill de julho (fica o `3080048`, com a animação original, 10 fishcash e 10% mais rápido), o Bonsai Tree, o Bamboo Flooring e o Multi Tile recriados, porque repetiam itens originais. Quem já tem um deles continua com ele.
- **Retirado:** o Japanese Divider Corner (`3080089`), que tínhamos feito nós mesmos. A migração apaga as cópias que estiverem no banco.
- **Novo patch opcional do servidor:** `block_stacks.patch`. Ele impede que o servidor apague as pilhas de blocos iguais no mesmo bloco, um truque clássico de decoração.

---

## ⚠️ AVISOS (LEIA ANTES DE TUDO)

> [!CAUTION]
> **1. Instalou o pacote de 29/10? Migre o banco ANTES de abrir o jogo.**  
> Os ids das 77 recriações que viraram originais deixaram de existir no catálogo. Sem a migração, os itens guardados e colocados com esses ids somem ou travam o restaurante. Com o servidor **parado**, dentro da pasta `3_rebuild`:
> ```powershell
> node scripts\migrar_inventario_julho2010.cjs --servidor "C:\caminho\do\servidor"
> node scripts\migrar_inventario_julho2010.cjs --servidor "C:\caminho\do\servidor" --aplicar
> ```
> O primeiro comando só conta o que vai mudar. O segundo faz um backup do `dev.db` em `backups\` e troca os ids no inventário, no salão, nos pisos, nas cartas e nas trocas pendentes, conferindo no fim se o total de itens continuou o mesmo. Ele também apaga as cópias do Japanese Divider Corner. Precisa do Node 20+ e do servidor com `npm install` já feito (o script usa o `better-sqlite3` dele). Quem nunca instalou o pacote de 29/10 pode pular este passo.

> [!CAUTION]
> **2. Conflito de ids.**  
> Os itens recriados usam a faixa `3080001` a `3080146`. Os itens de julho usam os ids originais da Playfish que não existem na build 0.9.143a: decoração e móveis entre `3000066` e `3500130`, as receitas `5000026`–`5000037`, `5100037`–`5100049`, `5200029`–`5200038` e `5300020`–`5300034`, e os ingredientes `4000101`–`4000111`. Se o seu servidor já cadastrou itens próprios nesses ids (ou já trouxe os itens de julho de outro jeito), **não instale**: as linhas vão se misturar no catálogo.

> [!WARNING]
> **3. Faça backup dos 9 arquivos.**  
> A instalação substitui estes arquivos. Guarde uma cópia deles numa pasta separada; é o seu ponto de volta:
> - `public/swf/indoor_asset.swf`
> - `public/swf/game.swf`
> - `public/data/restaurant.xml` e `public/data/restaurant.bin`
> - `public/data/lang_en.bin`
> - `public/data/recipe.xml` e `public/data/recipe.bin`
> - `public/data/ingredient.xml` e `public/data/ingredient.bin`

> [!IMPORTANT]
> **4. Reinicie o servidor.**  
> O servidor guarda o catálogo, as receitas e os preços em cache na memória. Depois de copiar os arquivos, **reinicie** (`npm run start:built` ou `start.bat`). Sem isso, os itens novos não aparecem ou saem com preço antigo.

> [!NOTE]
> **5. Ctrl + F5 nos navegadores.**  
> O Flash Player / Ruffle guarda o SWF no navegador. Todo jogador precisa recarregar a página do jogo com **Ctrl + F5**.

---

## 🛍️ O que vem no pacote

| | Quantidade |
|---|---|
| Itens recriados por nós (ids `3080xxx`) | 44 no catálogo, 41 à venda |
| Itens oficiais de julho/2010 | 494 (106 custam fishcash) |
| Receitas novas | 50 (7 da cadeia do Sushi Bar + 43 de fev–jul/2010) |
| Ingredientes novos | 11 |

A lista completa, aba por aba, com id, preço, efeito e tamanho de cada item, está em **[ITENS.md](ITENS.md)**.

### Itens recriados à venda (41)

- **Cozinha:** Teppanyaki Grill (`3080048`, 10 fishcash, 10% mais rápido, animação original de julho).
- **Pisos (19):** Garden Path Tile 1–6, Turkish Stone Tile, Sand Tile 2 e 3, Sports Court Tile 1–7, Oktoberfest Tile, Sun God Tile, Magic Chocolate Tile.
- **Decoração (18):** Fish Tank (Taste of Asia), Japanese Fishpond, Melon/Strawberry/Kiwi Rug, Potted Melon Divider, Nosy Squirrel, Camouflage Bear, Ghost Story Arcade, Louis Biltong, New Orleans Jazzy Duo, New Orleans Jukebox, Alessandra Clapper, The Watering Hole, Failed Knight Figurine, Evil Tree, Cheesey Varities, Liberty Bell.
- **Decoração de parede (3):** Pixel Decal - Fruit Punch, Gooey Monster e Potato <3.

### Fora da loja (quem tem continua usando)

| Id | Item | Por quê |
|---|---|---|
| `3070020` | Teppanyaki Grill (julho) | repetido: fica o `3080048` |
| `3080010` | Bonsai Tree (recriado) | repetia o Bonsai original `3020288` |
| `3080101` | Bamboo Flooring (recriado) | repetia o Bamboo Floor original `3050063` |
| `3080098` | Multi Tile (recriado) | repetia o Cards Tile original `3050061` |

### Itens de julho que ainda não têm efeito

Aparecem, decoram e podem ser comprados, mas a função especial ainda não foi escrita:
- **Tiny Door** (`ShrinkCustomerDoor`): os clientes deveriam encolher ao passar.
- **Night Sculpture** (`NightTimeRoad`): a rua deveria ficar de noite.
- **Tiki Statue, Hotel City Sign, Alien Monolith e Football Wall TV:** atraem clientes fantasiados, mas as roupas de julho não existem no jogo.

### Melhorias de receitas que ainda não têm efeito
Dá para aprender e servir, mas os efeitos extras abaixo ainda não foram escritos:
- **Melhorias do Lounge Bar:** Tropical Sunrise, Strawberry Heaven, Russian Cappuccino, Mint Breeze, Pink Lemonade, Mango Tango e Kiwi Twist (petiscos, segundo barman, banco extra, torneiras, misturador).
- **Drink Me:** deveria encolher o cliente (ShrinkCustomer).

---

## 🚀 Qual caminho seguir?

| A sua situação | Caminho | Tempo |
|---|---|---|
| **Nunca mexeu** no `game.swf`, no catálogo ou nos textos do servidor (ou só instalou o pacote de 29/10) | **Caminho A: copiar e colar** | ~3 minutos |
| **Já modificou** o `game.swf`, cadastrou itens próprios ou mudou o `lang_en.bin` | **Caminho B: reconstruir** por cima dos seus arquivos | ~5 minutos |

Nos dois caminhos, quem instalou o pacote de 29/10 roda antes a migração do aviso 1.

---

## Caminho A: copiar e colar

1. **Pare o servidor e faça o backup** dos 9 arquivos do aviso 3.
2. **Se instalou o pacote de 29/10**, rode a migração (aviso 1).
3. **Copie** o conteúdo de `1_ready_files` para a pasta do servidor, **substituindo** os arquivos:

   | No pacote | No servidor |
   |---|---|
   | `1_ready_files/public/swf/indoor_asset.swf` | `public/swf/indoor_asset.swf` |
   | `1_ready_files/public/swf/game.swf` | `public/swf/game.swf` |
   | `1_ready_files/public/data/restaurant.xml` e `.bin` | `public/data/restaurant.xml` e `.bin` |
   | `1_ready_files/public/data/lang_en.bin` | `public/data/lang_en.bin` |
   | `1_ready_files/public/data/recipe.xml` e `.bin` | `public/data/recipe.xml` e `.bin` |
   | `1_ready_files/public/data/ingredient.xml` e `.bin` | `public/data/ingredient.xml` e `.bin` |

4. **Reinicie o servidor** e peça **Ctrl + F5** a todos os jogadores.

O `game.swf` desta pasta vem **sem** o botão de troca de ingredientes no próprio restaurante (ele precisa de um patch no servidor; veja os opcionais).

---

## Caminho B: reconstruir por cima dos seus arquivos

*Precisa de: Windows com PowerShell, **Java 17+** e **Node 20+**.*

1. Pare o servidor, faça o backup dos 9 arquivos e, se for o caso, rode a migração.
2. Copie a pasta `3_rebuild` inteira para uma pasta no computador (ex.: `C:\rc_itens\`).
3. Abra o PowerShell dentro dela e rode, com o caminho da pasta `public` do seu servidor:
   ```powershell
   powershell -ExecutionPolicy Bypass -File scripts\aplicar_itens.ps1 -Servidor "C:\caminho\do\servidor\public" -SemTroca
   ```
   Tire o `-SemTroca` só se for instalar também a troca de ingredientes (cliente e patch do servidor).
4. Espere a mensagem `Pronto. Reinicie o servidor`. Se aparecer erro de compilação do FFDec, confira o Java com `java -version`.
5. Reinicie o servidor e peça **Ctrl + F5** aos jogadores.

O que o script faz:
- **Primeira execução:** guarda os originais do seu servidor em `3_rebuild\recriados\base\`. As execuções seguintes sempre partem desses originais, então **não apague essa pasta**.
- **Arte de julho:** copia para o `indoor_asset.swf` a arte de julho/2010, que vem de `3_rebuild\recuperado\restaurant_origins\`.
- **Itens recriados:** injeta a arte e as linhas de catálogo dos itens recriados (`recriados\manifesto.json`).
- **Catálogo:** aplica os valores de julho, as épocas (`recriados\epocas.json`) e os itens fora da loja (`recriados\fora_da_loja.json`).
- **Receitas:** grava as 50 receitas e os 11 ingredientes de 2010.
- **Jogo:** recompila no `game.swf` as classes de `recriados\codigo\`.

Para tirar outro item da loja, acrescente uma linha em `recriados\fora_da_loja.json` e rode de novo.

---

## 🧩 Opcionais

### 1. Troca de ingredientes no próprio restaurante (3 por 1)
Um botão ao lado do Mercado: o jogador escolhe 3 ingredientes seus e recebe 1 à escolha, sem precisar de vizinho. Cliente e servidor vão **juntos**:
1. **Cliente:** copie `2_optional/ingredient_exchange/game.swf` para `public/swf/game.swf` (no lugar do `game.swf` padrão).
2. **Servidor:** na pasta do servidor (faça backup de `src/db/rpc-store.ts` antes):
   ```bash
   git apply --ignore-whitespace caminho\do\pacote\2_optional/ingredient_exchange\ingredient_exchange.patch
   copy caminho\do\pacote\2_optional/ingredient_exchange\own-ingredient-exchange.test.cjs test\
   npm run build
   ```

> ⚠️ Com o `game.swf` com botão e sem o patch do servidor, a troca sempre falha com erro de rede.

### 2. Pilhas de blocos (servidor)
O truque clássico de empilhar blocos iguais (por exemplo, 3 White Room Divider Block num bloco só, para fazer pilares) funciona no jogo, mas o servidor do Dippy trata as cópias iguais no mesmo bloco como duplicatas e as apaga na próxima vez que o restaurante carrega. O patch faz o servidor ignorar os itens do tipo `surface` nessa limpeza. Na pasta do servidor (backup de `src/db/item-catalog.ts` e `src/db/profile-store.ts` antes):
```bash
git apply --ignore-whitespace caminho\do\pacote\2_optional\block_stacks.patch
npm run build
```

### 3. Seletor de desempenho (Ruffle)
Um menu em `public/game.html` com três ajustes (Ultrarrápido, Equilibrado e Alta Definição), para reduzir o travamento em máquinas fracas e telas HiDPI:
```bash
git apply --ignore-whitespace caminho\do\pacote\2_optional\performance_launcher.patch
npm run build
```

---

## ↩️ Como desfazer

- **Caminho A:** devolva os 9 arquivos do backup para `public/` e reinicie o servidor.
- **Caminho B:** no PowerShell, dentro de `3_rebuild`:
  ```powershell
  powershell -ExecutionPolicy Bypass -File scripts\aplicar_itens.ps1 -Servidor "C:\caminho\do\servidor\public" -Restaurar
  ```
  e reinicie o servidor.
- **Migração:** o backup do banco está em `backups\` do servidor, com o nome `dev.db.<data>_antes_julho2010_<número>`. Para voltar, pare o servidor e copie esse arquivo por cima do `dev.db`.
- **Patches:** `git apply -R <patch>` e `npm run build`.

---

## ✅ Como conferir no jogo

1. **Loja, aba Cozinha:** aparece um Teppanyaki Grill só (10 fishcash).
2. **Loja, aba Funcionais:** o Monster Robot anda pelo salão e a Cherry Blossom Tree solta pétalas.
3. **Loja, aba Decoração:** o Sunken Ruins Arch e o Wedding Trellis aparecem inteiros; o cliente passa por baixo.
4. **Cardápio:** as receitas novas aparecem no fim de cada aba (entradas, pratos, sobremesas e bebidas), com desenho e sem contador de tempo limitado.
5. **Sushi Bar:** só os pratos das receitas de sushi dominadas aparecem cheios na esteira.
6. **Salão grande:** um layout com 50+ cadeiras abre sem travar (no teste, 59 cadeiras abriram em 0,7 s).
7. **Quem migrou:** os itens recriados que você tinha aparecem como os originais de julho, nos mesmos lugares.
