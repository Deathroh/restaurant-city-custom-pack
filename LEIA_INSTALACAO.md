---
tags: [restaurant-city, instalacao, itens-recriados]
fontes:
  - "recriados/manifesto.json e scripts/aplicar_itens.ps1 (Restaurant City Arquivo)"
  - "restaurant-city-server (fork de Dippys/Restaurant-City-Server, commit cdef695)"
criado: 2026-10-28
atualizado: 2026-10-29
---

# Restaurant City Reborn: Guia de Instalação dos Itens Recriados

> 🇺🇸 **For the installation guide in English, [click here (README.md)](README.md).**

Compatível com o servidor [Dippys/Restaurant-City-Server](https://github.com/Dippys/Restaurant-City-Server) (testado no commit `cdef695`).

---

## ⚠️ AVISOS DE SEGURANÇA E CUIDADOS (LEIA ANTES DE TUDO)

> [!CAUTION]
> **1. Conflito de IDs (3080001 a 3080146)**  
> Os itens deste pacote utilizam estritamente esta faixa de identificadores. Se o seu servidor já possui itens próprios cadastrados nesses IDs, **NÃO INSTALE**, pois haverá colisão e os itens se misturarão no catálogo.

> [!WARNING]
> **2. Backup Obrigatório dos 5 Arquivos**  
> A instalação substitui 5 arquivos centrais do servidor. Antes de copiar qualquer arquivo, faça uma cópia de segurança deles em uma pasta separada (eles são o seu ponto de restauração para desfazer):
> - `public/swf/indoor_asset.swf`
> - `public/swf/game.swf`
> - `public/data/restaurant.xml`
> - `public/data/restaurant.bin`
> - `public/data/lang_en.bin`

> [!IMPORTANT]
> **3. Reinício Obrigatório do Servidor**  
> O servidor mantém o catálogo e os preços em cache na memória RAM. Após copiar os arquivos, **reiniciar o servidor é obrigatório** (`npm run start:built` ou `start.bat`). Sem reiniciar, os itens novos não aparecerão ou serão cobrados com valores desatualizados.

> [!NOTE]
> **4. Limpeza de Cache dos Jogadores (Ctrl + F5)**  
> O Flash Player / Ruffle grava o arquivo SWF no navegador dos usuários. Todo jogador precisa recarregar a página do jogo com **Ctrl + F5** para carregar os novos gráficos e comportamentos.

---

## 🛍️ Catálogo de Itens por Abas (Na Ordem da Loja do Jogo)

### 1. Cadeiras (Chairs) (2 itens)

* **Zen Chair** (ID `3080030`) — 700 moedas
* **White Zen Chair** (ID `3080031`) — 700 moedas

### 2. Mesas (Tables) (4 itens)

* **Zen Table** (ID `3080020`) — 8 Playfish Cash — *★ Custa Cash, Mesa de 2 blocos (atende 2 clientes)*
* **Small Zen Table** (ID `3080021`) — 1.200 moedas
* **Sushi Table** (ID `3080026`) — 1.200 moedas
* **Long Sushi Table** (ID `3080027`) — 8 Playfish Cash — *★ Custa Cash, Mesa de 2 blocos (atende 2 clientes)*

### 3. Eletrodomésticos de Cozinha (Kitchen Appliances) (2 itens)

* **Ceremonial Drink Set** (ID `3080023`) — 6 Playfish Cash — *★ Custa Cash, Bônus de velocidade (+10% rapidez nas bebidas)*
* **Teppanyaki Grill** (ID `3080048`) — 10 Playfish Cash — *★ Custa Cash*

### 4. Pisos (Floor Tiles) (53 itens)

* **Tatami Mat** (ID `3080016`) — 20 moedas
* **Zen Circle Tile** (ID `3080049`) — 40 moedas
* **Zen Stripe Tile** (ID `3080050`) — 40 moedas
* **Zen Tile** (ID `3080051`) — 40 moedas
* **Magic Floor Tile** (ID `3080094`) — 40 moedas
* **Cloud Flooring** (ID `3080095`) — 40 moedas
* **Clubs Tile** (ID `3080096`) — 40 moedas
* **Diamond Tile** (ID `3080097`) — 40 moedas
* **Multi Tile** (ID `3080098`) — 40 moedas
* **Spades Tile** (ID `3080099`) — 40 moedas
* **Dark Blue Floor** (ID `3080100`) — 40 moedas
* **Bamboo Flooring** (ID `3080101`) — 40 moedas
* **Terracotta Tile** (ID `3080102`) — 40 moedas
* **Wonderland Tile - Red** (ID `3080103`) — 40 moedas
* **Grass Tile** (ID `3080104`) — 40 moedas
* **Garden Path Tile 1** (ID `3080105`) — 40 moedas
* **Garden Path Tile 2** (ID `3080106`) — 40 moedas
* **Garden Path Tile 3** (ID `3080107`) — 40 moedas
* **Garden Path Tile 4** (ID `3080108`) — 40 moedas
* **Garden Path Tile 5** (ID `3080109`) — 40 moedas
* **Garden Path Tile 6** (ID `3080110`) — 40 moedas
* **Turkish Stone Tile** (ID `3080111`) — 40 moedas
* **Sand Tile** (ID `3080112`) — 40 moedas
* **Sand Tile 2** (ID `3080113`) — 40 moedas
* **Sand Tile 3** (ID `3080114`) — 40 moedas
* **Sports Court Tile 1** (ID `3080115`) — 40 moedas
* **Sports Court Tile 2** (ID `3080116`) — 40 moedas
* **Sports Court Tile 3** (ID `3080117`) — 40 moedas
* **Sports Court Tile 4** (ID `3080118`) — 40 moedas
* **Sports Court Tile 5** (ID `3080119`) — 40 moedas
* **Oktoberfest Tile** (ID `3080120`) — 40 moedas
* **Sun God Tile** (ID `3080121`) — 40 moedas
* **Magic Chocolate Tile** (ID `3080122`) — 40 moedas
* **Sports Court Tile 6** (ID `3080125`) — 40 moedas
* **Sports Court Tile 7** (ID `3080126`) — 40 moedas
* **Magic Water Corner 1** (ID `3080127`) — 60 moedas
* **Magic Water Corner 2** (ID `3080128`) — 60 moedas
* **Magic Water Corner 3** (ID `3080129`) — 60 moedas
* **Magic Water Corner 4** (ID `3080130`) — 60 moedas
* **Magic Water (Plain)** (ID `3080131`) — 60 moedas
* **Magic Water Edge 1** (ID `3080137`) — 60 moedas
* **Magic Water Edge 2** (ID `3080138`) — 60 moedas
* **Magic Water Edge 3** (ID `3080139`) — 60 moedas
* **Magic Water Edge 4** (ID `3080140`) — 60 moedas
* **Dark Magic Water Corner 1** (ID `3080132`) — 60 moedas
* **Dark Magic Water Corner 2** (ID `3080134`) — 60 moedas
* **Dark Magic Water Corner 3** (ID `3080135`) — 60 moedas
* **Dark Magic Water Corner 4** (ID `3080136`) — 60 moedas
* **Dark Magic Water (Plain)** (ID `3080133`) — 60 moedas
* **Dark Magic Water Edge 1** (ID `3080141`) — 60 moedas
* **Dark Magic Water Edge 2** (ID `3080142`) — 60 moedas
* **Dark Magic Water Edge 3** (ID `3080143`) — 60 moedas
* **Dark Magic Water Edge 4** (ID `3080144`) — 60 moedas

### 5. Papel de Parede (Wallpapers) (2 itens)

* **Sakura Wallpaper** (ID `3080084`) — 1.200 moedas
* **Shoji Screen Wallpaper** (ID `3080085`) — 1.000 moedas

### 6. Portas (Doors) (1 itens)

* **Japanese Sliding Door** (ID `3080086`) — 1.200 moedas — *Animado (abre e fecha ao passar clientes)*

### 7. Decoração Interior (Decorations) (49 itens)

* **Fish Tank (Taste of Asia)** (ID `3080004`) — 2.500 moedas
* **Japanese Pond** (ID `3080009`) — 10.000 moedas — *Animado (efeito contínuo de cascata e água)*
* **Bonsai Tree** (ID `3080010`) — 1.600 moedas
* **Stone Lantern** (ID `3080011`) — 2.000 moedas
* **Daruma** (ID `3080012`) — 1.800 moedas
* **Gong** (ID `3080013`) — 2.000 moedas
* **Bamboo Water Feature** (ID `3080014`) — 2.000 moedas
* **Samurai Armor** (ID `3080015`) — 4.000 moedas
* **Katana Decor** (ID `3080017`) — 1.200 moedas
* **Samurai Sword Decor** (ID `3080022`) — 1.200 moedas
* **Zen Garden** (ID `3080028`) — 3.000 moedas
* **Zen Rock** (ID `3080029`) — 2.200 moedas
* **Zen Stone** (ID `3080032`) — 900 moedas
* **Zen Pebble** (ID `3080033`) — 500 moedas
* **Garden Fireplace** (ID `3080034`) — 1.500 moedas
* **Garden Lamp** (ID `3080035`) — 1.200 moedas
* **Japanese Fishpond** (ID `3080036`) — 8.000 moedas
* **Japanese Garden Pond** (ID `3080037`) — 10.000 moedas — *Animado (lótus flutuando na água, 3x3)*
* **Octopus Statue** (ID `3080039`) — 3.000 moedas
* **Prawn Sushi Decor** (ID `3080040`) — 600 moedas
* **Salmon Sushi Decor** (ID `3080041`) — 600 moedas
* **Yellow Maki Decor** (ID `3080042`) — 500 moedas
* **Green Maki Decor** (ID `3080043`) — 500 moedas
* **Red Maki Decor** (ID `3080044`) — 700 moedas
* **Sakura Mochi Decor** (ID `3080045`) — 700 moedas
* **Ad Divider** (ID `3080046`) — 2.000 moedas
* **Ad Post** (ID `3080047`) — 1.800 moedas
* **Melon Rug** (ID `3080053`) — 1.500 moedas
* **Strawberry Rug** (ID `3080054`) — 1.500 moedas
* **Kiwi Rug** (ID `3080055`) — 1.500 moedas
* **Potted Melon Divider** (ID `3080056`) — 1.200 moedas
* **Nosy Squirrel** (ID `3080057`) — 2.500 moedas
* **Camouflage Bear** (ID `3080058`) — 4.000 moedas
* **Ghost Story Arcade** (ID `3080060`) — 9.000 moedas
* **Louis Biltong** (ID `3080067`) — 3.000 moedas
* **New Orleans Jazzy Duo** (ID `3080068`) — 4.000 moedas
* **New Orleans Jukebox** (ID `3080069`) — 5.000 moedas
* **Alessandra Clapper** (ID `3080071`) — 2.500 moedas
* **The Watering Hole** (ID `3080073`) — 6.000 moedas
* **Failed Knight Figurine** (ID `3080074`) — 3.500 moedas
* **Evil Tree** (ID `3080075`) — 6.000 moedas
* **Cheesey Varities** (ID `3080081`) — 2.500 moedas
* **Liberty Bell** (ID `3080083`) — 3.000 moedas
* **Japanese Divider** (ID `3080088`) — 600 moedas
* **Japanese Divider Corner** (ID `3080089`) — 600 moedas
* **Spring Divider** (ID `3080090`) — 400 moedas
* **Spring Divider Block** (ID `3080091`) — 800 moedas
* **White Sofa Corner** (ID `3080145`) — 800 moedas — *Sofá de canto em V (conecta sofás modernos)*
* **Black Sofa Corner** (ID `3080146`) — 800 moedas — *Sofá de canto em V (conecta sofás modernos)*

### 8. Decoração de Parede (Wall Decorations) (7 itens)

* **Shuriken Wall Decor** (ID `3080018`) — 800 moedas
* **Sushi Sign** (ID `3080019`) — 1.500 moedas
* **Delicious Sign Decor** (ID `3080024`) — 900 moedas
* **Japanese Garden Picture** (ID `3080025`) — 2.500 moedas — *Painel largo de 4 blocos*
* **Pixel Decal - Fruit Punch** (ID `3080061`) — 800 moedas
* **Pixel Decal - Gooey Monster** (ID `3080062`) — 800 moedas
* **Pixel Decal - Potato <3** (ID `3080063`) — 800 moedas

### 9. Itens Funcionais (Functional) (2 itens)

* **Monster Robot** (ID `3080001`) — 25 Playfish Cash — *★ Custa Cash, Animado (anda pelo restaurante)*
* **Cherry Blossom Tree** (ID `3080007`) — 15 Playfish Cash — *★ Custa Cash, Animado (solta pétalas de cerejeira)*

### ⭐ Aba Especial: Itens que Custam Playfish Cash (6 itens)

> *Estes itens também estão listados em suas respectivas categorias acima.*

* **Monster Robot** (ID `3080001`) — **25 Playfish Cash** (Aba: Functional) — *★ Custa Cash, Animado (anda pelo restaurante)*
* **Cherry Blossom Tree** (ID `3080007`) — **15 Playfish Cash** (Aba: Functional) — *★ Custa Cash, Animado (solta pétalas de cerejeira)*
* **Zen Table** (ID `3080020`) — **8 Playfish Cash** (Aba: Table) — *★ Custa Cash, Mesa de 2 blocos (atende 2 clientes)*
* **Ceremonial Drink Set** (ID `3080023`) — **6 Playfish Cash** (Aba: Kitchen Appliance) — *★ Custa Cash, Bônus de velocidade (+10% rapidez nas bebidas)*
* **Long Sushi Table** (ID `3080027`) — **8 Playfish Cash** (Aba: Table) — *★ Custa Cash, Mesa de 2 blocos (atende 2 clientes)*
* **Teppanyaki Grill** (ID `3080048`) — **10 Playfish Cash** (Aba: Kitchen Appliance) — *★ Custa Cash*

### ✨ Aba Especial: Itens com Animação / Efeitos Visuais (5 itens)

> *Estes itens também estão listados em suas respectivas categorias acima.*

* **Monster Robot** (ID `3080001`) — 25 Playfish Cash (Aba: Functional) — *★ Custa Cash, Animado (anda pelo restaurante)*
* **Cherry Blossom Tree** (ID `3080007`) — 15 Playfish Cash (Aba: Functional) — *★ Custa Cash, Animado (solta pétalas de cerejeira)*
* **Japanese Pond** (ID `3080009`) — 10.000 moedas (Aba: Decoration) — *Animado (efeito contínuo de cascata e água)*
* **Japanese Garden Pond** (ID `3080037`) — 10.000 moedas (Aba: Decoration) — *Animado (lótus flutuando na água, 3x3)*
* **Japanese Sliding Door** (ID `3080086`) — 1.200 moedas (Aba: Door) — *Animado (abre e fecha ao passar clientes)*

---

## 🚀 Qual Caminho de Instalação Seguir?

| Sua Situação Atual | Caminho Recomendado | Tempo Estimado |
|---|---|---|
| **Nunca alterou** o `game.swf`, `restaurant.xml` ou textos do servidor | **Caminho A: Copiar e Colar** | ~3 minutos |
| **Já modificou** o `game.swf`, adicionou itens próprios ou editou textos (`lang_en.bin`) | **Caminho B: Reconstruir** (Mescla sem perder suas alterações) | ~5 minutos |

---

## Caminho A: Instalação Direta (Copiar e Colar)

### 1. Pare o servidor e faça o backup
Finalize a execução do seu servidor e copie os 5 arquivos originais citados no aviso do topo para uma pasta de backup.

### 2. Copie os arquivos prontos
Copie os arquivos da pasta `1_arquivos_prontos` e cole-os na pasta raiz do seu servidor, **substituindo** os arquivos existentes:

| Origem no Pacote | Destino no Servidor |
|---|---|
| `1_arquivos_prontos/public/swf/indoor_asset.swf` | `public/swf/indoor_asset.swf` |
| `1_arquivos_prontos/public/swf/game.swf` | `public/swf/game.swf` |
| `1_arquivos_prontos/public/data/restaurant.xml` | `public/data/restaurant.xml` |
| `1_arquivos_prontos/public/data/restaurant.bin` | `public/data/restaurant.bin` |
| `1_arquivos_prontos/public/data/lang_en.bin` | `public/data/lang_en.bin` |

### 3. Reinicie o servidor
Inicie novamente o servidor (`npm run start:built`, serviço em segundo plano ou `start.bat`). Peça a todos os jogadores para recarregarem a página com **Ctrl + F5**.

---

## Caminho B: Reconstruir Sobre os Seus Arquivos

*Requisitos: Windows com PowerShell, **Java 17+** e **Node 20+** instalados.*

1. Pare o servidor e faça o backup dos 5 arquivos do Passo 1.
2. Copie a pasta `3_reconstruir` inteira para uma pasta no seu computador (ex.: `C:\rc_itens\`).
3. Abra o terminal PowerShell dentro dessa pasta e execute o comando abaixo (ajustando o caminho para a pasta `public` do seu servidor):
   ```powershell
   powershell -ExecutionPolicy Bypass -File scripts\aplicar_itens.ps1 -Servidor "C:\caminho\do\servidor\public" -SemTroca
   ```
   *(Remova o `-SemTroca` somente se você for habilitar o opcional de troca de ingredientes).*
4. Aguarde a mensagem final: `Pronto. Reinicie o servidor`. Se houver erro de compilação no FFDec, verifique sua versão do Java com `java -version`.
5. Reinicie o servidor e solicite **Ctrl + F5** aos jogadores.

> 💡 **Nota sobre a pasta base:** O script cria e mantém a pasta `3_reconstruir\recriados\base\` com os arquivos originais do seu servidor. Não a delete, pois aplicações futuras partem dessa base.

---

## 🧩 Recursos Opcionais

### 1. Troca de Ingredientes no Próprio Restaurante (3 por 1)
Adiciona um botão de troca ao lado do Mercado: o jogador seleciona 3 ingredientes próprios e recebe 1 novo ingrediente à escolha, sem depender de vizinhos.

Para funcionar, é **obrigatório** instalar o cliente e o patch do servidor juntos:
1. **No cliente:** Copie `2_opcionais/troca_de_ingredientes/game.swf` para `public/swf/game.swf` *(substitui o game.swf padrão)*.
2. **No servidor:** Abra o terminal na pasta do servidor e execute:
   ```bash
   git apply --ignore-whitespace caminho\do\pacote\2_opcionais\troca_de_ingredientes\troca_de_ingredientes.patch
   copy caminho\do\pacote\2_opcionais\troca_de_ingredientes\own-ingredient-exchange.test.cjs test\
   npm run build
   ```
   *(Faça backup prévio de `src/db/rpc-store.ts`)*.

> ⚠️ **Atenção:** Instalar o `game.swf` com o botão sem aplicar o patch do servidor fará a troca sempre falhar com erro de rede.

### 2. Seletor de Resolução / Desempenho (Ruffle)
Adiciona um menu na página `public/game.html` com três perfis (Ultrarrápido, Equilibrado e Alta Definição) para reduzir travamentos em computadores modestos e telas de alta densidade (HiDPI).
- Na pasta do servidor, aplique:
  ```bash
  git apply --ignore-whitespace caminho\do\pacote\2_opcionais\launcher_desempenho.patch
  npm run build
  ```

---

## ↩️ Como Desfazer a Instalação

- **Se usou o Caminho A:** Copie os 5 arquivos do seu backup de volta para a pasta `public/` e reinicie o servidor.
- **Se usou o Caminho B:** No PowerShell de `3_reconstruir`, execute:
  ```powershell
  powershell -ExecutionPolicy Bypass -File scripts\aplicar_itens.ps1 -Servidor "C:\caminho\do\servidor\public" -Restaurar
  ```
  e reinicie o servidor.
- **Se aplicou Patches:** Reverta via terminal com `git apply -R <patch>` e execute `npm run build`.

---

## ✅ Como Conferir se a Instalação Deu Certo

Abra o restaurante no jogo e verifique:
1. **Aba Functional:** O *Monster Robot* (25 Playfish Cash) deve estar na loja e, quando colocado no salão com o jogo rodando, caminha livremente entre as mesas.
2. **Aba Functional:** A *Cherry Blossom Tree* (15 Playfish Cash) solta pétalas de cerejeira no ar continuamente.
3. **Aba Table:** A *Zen Table* e a *Long Sushi Table* (8 Playfish Cash, 2 blocos) devem acomodar 2 cadeiras e 2 clientes ao mesmo tempo.
4. **Aba Kitchen Appliance:** Ao passar o mouse sobre o *Ceremonial Drink Set*, aparece a legenda *"Serves drinks 10% faster"*.
5. **Aba Floor Tile:** As peças de *Magic Water* encaixadas formam uma piscina contínua sem linhas de grade.
6. **Aba Decoration:** O *White Sofa Corner* ou *Black Sofa Corner* unem dois sofás modernos em formato de L.
