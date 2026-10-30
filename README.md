# Restaurant City Reborn: Installation Guide for Recreated Items

> 🇧🇷 **Para o guia de instalação em Português, [clique aqui (LEIA_INSTALACAO.md)](LEIA_INSTALACAO.md).**

Compatible with the [Dippys/Restaurant-City-Server](https://github.com/Dippys/Restaurant-City-Server) server (tested on commit `cdef695`).

---

## ⚠️ SAFETY WARNINGS & PRECAUTIONS (READ FIRST)

> [!CAUTION]
> **1. ID Conflict (3080001 to 3080146)**  
> The new items strictly use this range of IDs. If your server already has custom items registered in this range, **DO NOT INSTALL**: they will clash and corrupt the shop catalog.

> [!WARNING]
> **2. Required Backup of the 5 Files**  
> Installation overwrites 5 core server files. Before copying any files, save a backup copy in a separate folder (you need them to restore):
> - `public/swf/indoor_asset.swf`
> - `public/swf/game.swf`
> - `public/data/restaurant.xml`
> - `public/data/restaurant.bin`
> - `public/data/lang_en.bin`

> [!IMPORTANT]
> **3. Server Restart is Required**  
> The server caches the catalog and pricing in RAM. After copying files, **restarting the server is mandatory** (`npm run start:built` or `start.bat`). Without a restart, new items will not show up or will be charged at outdated prices.

> [!NOTE]
> **4. Player Cache Refresh (Ctrl + F5)**  
> Flash Player / Ruffle caches the SWF file in the player's browser. All players must reload the game page with **Ctrl + F5** to load the new graphics and behaviors.

---

## 🛍️ Item Catalog by Tabs (In Game Shop Order)

### 1. Chairs (2 items)

* **Zen Chair** (ID `3080030`) — 700 coins
* **White Zen Chair** (ID `3080031`) — 700 coins

### 2. Tables (4 items)

* **Zen Table** (ID `3080020`) — 8 Playfish Cash — *★ Costs Cash, 2-tile table (serves 2 customers)*
* **Small Zen Table** (ID `3080021`) — 1,200 coins
* **Sushi Table** (ID `3080026`) — 1,200 coins
* **Long Sushi Table** (ID `3080027`) — 8 Playfish Cash — *★ Costs Cash, 2-tile table (serves 2 customers)*

### 3. Kitchen Appliances (2 items)

* **Ceremonial Drink Set** (ID `3080023`) — 6 Playfish Cash — *★ Costs Cash, Speed bonus (+10% drink preparation speed)*
* **Teppanyaki Grill** (ID `3080048`) — 10 Playfish Cash — *★ Costs Cash*

### 4. Floor Tiles (53 items)

* **Tatami Mat** (ID `3080016`) — 20 coins
* **Zen Circle Tile** (ID `3080049`) — 40 coins
* **Zen Stripe Tile** (ID `3080050`) — 40 coins
* **Zen Tile** (ID `3080051`) — 40 coins
* **Magic Floor Tile** (ID `3080094`) — 40 coins
* **Cloud Flooring** (ID `3080095`) — 40 coins
* **Clubs Tile** (ID `3080096`) — 40 coins
* **Diamond Tile** (ID `3080097`) — 40 coins
* **Multi Tile** (ID `3080098`) — 40 coins
* **Spades Tile** (ID `3080099`) — 40 coins
* **Dark Blue Floor** (ID `3080100`) — 40 coins
* **Bamboo Flooring** (ID `3080101`) — 40 coins
* **Terracotta Tile** (ID `3080102`) — 40 coins
* **Wonderland Tile - Red** (ID `3080103`) — 40 coins
* **Grass Tile** (ID `3080104`) — 40 coins
* **Garden Path Tile 1** (ID `3080105`) — 40 coins
* **Garden Path Tile 2** (ID `3080106`) — 40 coins
* **Garden Path Tile 3** (ID `3080107`) — 40 coins
* **Garden Path Tile 4** (ID `3080108`) — 40 coins
* **Garden Path Tile 5** (ID `3080109`) — 40 coins
* **Garden Path Tile 6** (ID `3080110`) — 40 coins
* **Turkish Stone Tile** (ID `3080111`) — 40 coins
* **Sand Tile** (ID `3080112`) — 40 coins
* **Sand Tile 2** (ID `3080113`) — 40 coins
* **Sand Tile 3** (ID `3080114`) — 40 coins
* **Sports Court Tile 1** (ID `3080115`) — 40 coins
* **Sports Court Tile 2** (ID `3080116`) — 40 coins
* **Sports Court Tile 3** (ID `3080117`) — 40 coins
* **Sports Court Tile 4** (ID `3080118`) — 40 coins
* **Sports Court Tile 5** (ID `3080119`) — 40 coins
* **Oktoberfest Tile** (ID `3080120`) — 40 coins
* **Sun God Tile** (ID `3080121`) — 40 coins
* **Magic Chocolate Tile** (ID `3080122`) — 40 coins
* **Sports Court Tile 6** (ID `3080125`) — 40 coins
* **Sports Court Tile 7** (ID `3080126`) — 40 coins
* **Magic Water Corner 1** (ID `3080127`) — 60 coins
* **Magic Water Corner 2** (ID `3080128`) — 60 coins
* **Magic Water Corner 3** (ID `3080129`) — 60 coins
* **Magic Water Corner 4** (ID `3080130`) — 60 coins
* **Magic Water (Plain)** (ID `3080131`) — 60 coins
* **Magic Water Edge 1** (ID `3080137`) — 60 coins
* **Magic Water Edge 2** (ID `3080138`) — 60 coins
* **Magic Water Edge 3** (ID `3080139`) — 60 coins
* **Magic Water Edge 4** (ID `3080140`) — 60 coins
* **Dark Magic Water Corner 1** (ID `3080132`) — 60 coins
* **Dark Magic Water Corner 2** (ID `3080134`) — 60 coins
* **Dark Magic Water Corner 3** (ID `3080135`) — 60 coins
* **Dark Magic Water Corner 4** (ID `3080136`) — 60 coins
* **Dark Magic Water (Plain)** (ID `3080133`) — 60 coins
* **Dark Magic Water Edge 1** (ID `3080141`) — 60 coins
* **Dark Magic Water Edge 2** (ID `3080142`) — 60 coins
* **Dark Magic Water Edge 3** (ID `3080143`) — 60 coins
* **Dark Magic Water Edge 4** (ID `3080144`) — 60 coins

### 5. Wallpapers (2 items)

* **Sakura Wallpaper** (ID `3080084`) — 1,200 coins
* **Shoji Screen Wallpaper** (ID `3080085`) — 1,000 coins

### 6. Doors (1 items)

* **Japanese Sliding Door** (ID `3080086`) — 1,200 coins — *Animated (opens and closes when customers pass)*

### 7. Interior Decorations (49 items)

* **Fish Tank (Taste of Asia)** (ID `3080004`) — 2,500 coins
* **Japanese Pond** (ID `3080009`) — 10,000 coins — *Animated (continuous waterfall and ripple effect)*
* **Bonsai Tree** (ID `3080010`) — 1,600 coins
* **Stone Lantern** (ID `3080011`) — 2,000 coins
* **Daruma** (ID `3080012`) — 1,800 coins
* **Gong** (ID `3080013`) — 2,000 coins
* **Bamboo Water Feature** (ID `3080014`) — 2,000 coins
* **Samurai Armor** (ID `3080015`) — 4,000 coins
* **Katana Decor** (ID `3080017`) — 1,200 coins
* **Samurai Sword Decor** (ID `3080022`) — 1,200 coins
* **Zen Garden** (ID `3080028`) — 3,000 coins
* **Zen Rock** (ID `3080029`) — 2,200 coins
* **Zen Stone** (ID `3080032`) — 900 coins
* **Zen Pebble** (ID `3080033`) — 500 coins
* **Garden Fireplace** (ID `3080034`) — 1,500 coins
* **Garden Lamp** (ID `3080035`) — 1,200 coins
* **Japanese Fishpond** (ID `3080036`) — 8,000 coins
* **Japanese Garden Pond** (ID `3080037`) — 10,000 coins — *Animated (floating lotus drifting on water, 3x3)*
* **Octopus Statue** (ID `3080039`) — 3,000 coins
* **Prawn Sushi Decor** (ID `3080040`) — 600 coins
* **Salmon Sushi Decor** (ID `3080041`) — 600 coins
* **Yellow Maki Decor** (ID `3080042`) — 500 coins
* **Green Maki Decor** (ID `3080043`) — 500 coins
* **Red Maki Decor** (ID `3080044`) — 700 coins
* **Sakura Mochi Decor** (ID `3080045`) — 700 coins
* **Ad Divider** (ID `3080046`) — 2,000 coins
* **Ad Post** (ID `3080047`) — 1,800 coins
* **Melon Rug** (ID `3080053`) — 1,500 coins
* **Strawberry Rug** (ID `3080054`) — 1,500 coins
* **Kiwi Rug** (ID `3080055`) — 1,500 coins
* **Potted Melon Divider** (ID `3080056`) — 1,200 coins
* **Nosy Squirrel** (ID `3080057`) — 2,500 coins
* **Camouflage Bear** (ID `3080058`) — 4,000 coins
* **Ghost Story Arcade** (ID `3080060`) — 9,000 coins
* **Louis Biltong** (ID `3080067`) — 3,000 coins
* **New Orleans Jazzy Duo** (ID `3080068`) — 4,000 coins
* **New Orleans Jukebox** (ID `3080069`) — 5,000 coins
* **Alessandra Clapper** (ID `3080071`) — 2,500 coins
* **The Watering Hole** (ID `3080073`) — 6,000 coins
* **Failed Knight Figurine** (ID `3080074`) — 3,500 coins
* **Evil Tree** (ID `3080075`) — 6,000 coins
* **Cheesey Varities** (ID `3080081`) — 2,500 coins
* **Liberty Bell** (ID `3080083`) — 3,000 coins
* **Japanese Divider** (ID `3080088`) — 600 coins
* **Japanese Divider Corner** (ID `3080089`) — 600 coins
* **Spring Divider** (ID `3080090`) — 400 coins
* **Spring Divider Block** (ID `3080091`) — 800 coins
* **White Sofa Corner** (ID `3080145`) — 800 coins — *V-shaped corner sofa (connects modern sofas)*
* **Black Sofa Corner** (ID `3080146`) — 800 coins — *V-shaped corner sofa (connects modern sofas)*

### 8. Wall Decorations (7 items)

* **Shuriken Wall Decor** (ID `3080018`) — 800 coins
* **Sushi Sign** (ID `3080019`) — 1,500 coins
* **Delicious Sign Decor** (ID `3080024`) — 900 coins
* **Japanese Garden Picture** (ID `3080025`) — 2,500 coins — *Wide 4-tile wall picture*
* **Pixel Decal - Fruit Punch** (ID `3080061`) — 800 coins
* **Pixel Decal - Gooey Monster** (ID `3080062`) — 800 coins
* **Pixel Decal - Potato <3** (ID `3080063`) — 800 coins

### 9. Functional Items (2 items)

* **Monster Robot** (ID `3080001`) — 25 Playfish Cash — *★ Costs Cash, Animated (walks around restaurant)*
* **Cherry Blossom Tree** (ID `3080007`) — 15 Playfish Cash — *★ Costs Cash, Animated (drops cherry blossom petals)*

### ⭐ Special Tab: Items That Cost Playfish Cash (6 items)

> *These items are also listed in their respective categories above.*

* **Monster Robot** (ID `3080001`) — **25 Playfish Cash** (Tab: Functional) — *★ Costs Cash, Animated (walks around restaurant)*
* **Cherry Blossom Tree** (ID `3080007`) — **15 Playfish Cash** (Tab: Functional) — *★ Costs Cash, Animated (drops cherry blossom petals)*
* **Zen Table** (ID `3080020`) — **8 Playfish Cash** (Tab: Table) — *★ Costs Cash, 2-tile table (serves 2 customers)*
* **Ceremonial Drink Set** (ID `3080023`) — **6 Playfish Cash** (Tab: Kitchen Appliance) — *★ Costs Cash, Speed bonus (+10% drink preparation speed)*
* **Long Sushi Table** (ID `3080027`) — **8 Playfish Cash** (Tab: Table) — *★ Costs Cash, 2-tile table (serves 2 customers)*
* **Teppanyaki Grill** (ID `3080048`) — **10 Playfish Cash** (Tab: Kitchen Appliance) — *★ Costs Cash*

### ✨ Special Tab: Items with Animation / Visual Effects (5 items)

> *These items are also listed in their respective categories above.*

* **Monster Robot** (ID `3080001`) — 25 Playfish Cash (Tab: Functional) — *★ Costs Cash, Animated (walks around restaurant)*
* **Cherry Blossom Tree** (ID `3080007`) — 15 Playfish Cash (Tab: Functional) — *★ Costs Cash, Animated (drops cherry blossom petals)*
* **Japanese Pond** (ID `3080009`) — 10,000 coins (Tab: Decoration) — *Animated (continuous waterfall and ripple effect)*
* **Japanese Garden Pond** (ID `3080037`) — 10,000 coins (Tab: Decoration) — *Animated (floating lotus drifting on water, 3x3)*
* **Japanese Sliding Door** (ID `3080086`) — 1,200 coins (Tab: Door) — *Animated (opens and closes when customers pass)*

---

## 🚀 Which Installation Path to Follow?

| Your Current Situation | Recommended Path | Estimated Time |
|---|---|---|
| **Never edited** the server's `game.swf`, `restaurant.xml` or texts | **Path A: Copy & Paste** | ~3 minutes |
| **Already modified** `game.swf`, added custom items or changed `lang_en.bin` | **Path B: Rebuild** (Merges without losing your changes) | ~5 minutes |

---

## Path A: Direct Installation (Copy & Paste)

### 1. Stop the server and make a backup
Stop your running server and copy the 5 original files listed in the warnings above to a backup folder.

### 2. Copy the ready-made files
Copy the files from the `1_ready_files` folder and paste them into your server's root folder, **overwriting** existing files:

| Source in Package | Destination on Server |
|---|---|
| `1_ready_files/public/swf/indoor_asset.swf` | `public/swf/indoor_asset.swf` |
| `1_ready_files/public/swf/game.swf` | `public/swf/game.swf` |
| `1_ready_files/public/data/restaurant.xml` | `public/data/restaurant.xml` |
| `1_ready_files/public/data/restaurant.bin` | `public/data/restaurant.bin` |
| `1_ready_files/public/data/lang_en.bin` | `public/data/lang_en.bin` |

### 3. Restart the server
Start the server again (`npm run start:built`, background service, or `start.bat`). Ask all players to refresh their browser with **Ctrl + F5**.

---

## Path B: Rebuild on Top of Your Own Files

*Requirements: Windows with PowerShell, **Java 17+**, and **Node 20+** installed.*

1. Stop the server and back up the 5 files as in Step 1.
2. Copy the entire `3_rebuild` folder to a folder on your computer (e.g., `C:\rc_items\`).
3. Open PowerShell inside that folder and run the command below (adjusting the path to your server's `public` folder):
   ```powershell
   powershell -ExecutionPolicy Bypass -File scripts\aplicar_itens.ps1 -Servidor "C:\path\to\server\public" -SemTroca
   ```
   *(Only omit `-SemTroca` if you intend to enable the optional ingredient exchange).*
4. Wait for the final message: `Pronto. Reinicie o servidor` ("Done. Restart the server"). If you encounter an FFDec compilation error, check your Java version with `java -version`.
5. Restart the server and ask players to press **Ctrl + F5**.

> 💡 **Note on base folder:** The script maintains `3_rebuild\recriados\base\` with your server's original files. Do not delete it, as future builds start from this base.

---

## 🧩 Optional Features

### 1. Ingredient Exchange Inside Your Own Restaurant (3-for-1)
Adds an exchange button next to the Market: players select 3 of their own ingredients and receive 1 chosen ingredient without needing neighbors.

Client and server patch must be installed **together**:
1. **Client:** Copy `2_optional/ingredient_exchange/game.swf` to `public/swf/game.swf` *(replaces default game.swf)*.
2. **Server:** Open a terminal in your server's folder and execute:
   ```bash
   git apply --ignore-whitespace path\to\package\2_optional\ingredient_exchange\ingredient_exchange.patch
   copy path\to\package\2_optional\ingredient_exchange\own-ingredient-exchange.test.cjs test\
   npm run build
   ```
   *(Back up `src/db/rpc-store.ts` first)*.

> ⚠️ **Warning:** Installing the `game.swf` with the button without applying the server patch will cause exchanges to always fail with a network error.

### 2. Resolution / Performance Selector (Ruffle)
Adds a dropdown to `public/game.html` with three presets (Ultra-fast, Balanced, and High Definition) to reduce lag on low-end machines and HiDPI screens.
- In your server folder, apply:
  ```bash
  git apply --ignore-whitespace path\to\package\2_optional\launcher_desempenho.patch
  npm run build
  ```

---

## ↩️ How to Undo

- **If you used Path A:** Copy the 5 backed-up files back into `public/` and restart the server.
- **If you used Path B:** In PowerShell inside `3_rebuild`, run:
  ```powershell
  powershell -ExecutionPolicy Bypass -File scripts\aplicar_itens.ps1 -Servidor "C:\path\to\server\public" -Restaurar
  ```
  and restart the server.
- **If you applied Patches:** Revert them using `git apply -R <patch>` and run `npm run build`.

---

## ✅ How to Verify in Game

Open the restaurant in-game and confirm:
1. **Functional Tab:** *Monster Robot* (25 Playfish Cash) appears in the shop and wanders freely between tables when placed.
2. **Functional Tab:** *Cherry Blossom Tree* (15 Playfish Cash) releases cherry blossom petals continuously.
3. **Table Tab:** *Zen Table* and *Long Sushi Table* (8 Playfish Cash, 2 tiles) accommodate 2 chairs and serve 2 customers at once.
4. **Kitchen Appliance Tab:** Hovering over the *Ceremonial Drink Set* shows the tooltip *"Serves drinks 10% faster"*.
5. **Floor Tile Tab:** Assembled *Magic Water* tiles connect into a seamless pool without grid gaps.
6. **Decoration Tab:** *White Sofa Corner* or *Black Sofa Corner* connects two modern sofas into an L-shape.
