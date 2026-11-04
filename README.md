# Restaurant City Reborn: Installation Guide (recreated items + July 2010 build)

> 🇧🇷 **Guia em português: [LEIA_INSTALACAO.md](LEIA_INSTALACAO.md).**

Compatible with the [Dippys/Restaurant-City-Server](https://github.com/Dippys/Restaurant-City-Server) server (tested on commit `cdef695`).

Package version: **2026-11-04**. The previous one was 2026-10-29.

---

## 🆕 What changed since the 2026-10-29 package

- **Official July 2010 build.** The package adds **494 official items** that the server's 0.9.143a build did not have: Lounge Bar, Wedding, Underwater, Alice in Wonderland, the Japanese theme, Spring, Mexico, Space, the pets and the Sushi Bar. Art and data come from the July 2010 files preserved by the Restaurant Origins project. Items keep their **original Playfish ids**, and 53 existing items got their July 2010 values.
- **Recreations replaced by the originals.** 77 items we had recreated (Monster Robot, Cherry Blossom Tree, Zen Table, Magic Water, Sofa Corner...) are now the official July items. **If you installed the 2026-10-29 package, you must migrate your database** (see warning 1 below).
- **50 recipes and 11 ingredients from 2010.** The 7 recipes of the Sushi Bar chain (Miso Soup, Yaki Gyoza, Seaweed Salad, Salmon Sashimi, Sushi Selection, Salmon Handrolls, Sakura Mochi) plus **43 recipes from February to July 2010** (Rainbow Soup, Monster Burger, Chocolate Dream, the Lounge Bar drinks and more), each with its original dish art. Also 11 ingredients: Salmon, Seaweed, Pineapple, Coconut, Crab, Cherry, Mint, Easter Egg, Easter Spices, Chick Figurine and Chocolate Bunny. The 21 recipes that were limited-time in 2010 are **always available**. Because of them the package now replaces **9 files** instead of 5.
- **Sushi Bar:** each of the 8 plates on the belt belongs to one sushi recipe and only shows food once that recipe is **mastered** (level 10), whether or not it is on the menu. At first only the Salmon Sashimi shows; the other plates go round empty.
- **Recipe mastery rewards:** mastering (level 10) one of the 6 special recipes unlocks its exclusive prize item and adds it directly to your inventory (Salmon Sashimi unlocks the Sushi Bar, Coco Colada unlocks the Lounge Bar, Eat Me unlocks Pet Cheshire Cat, Boston Cooler unlocks Night Sculpture, Chili Crabs unlocks Sunken Ship Prow, and Zero Gravity Salad unlocks Blue Alien Pet).
- **`game.swf` fixes:**
  - **Waiters:** the waiter route calculation is now fast. Before, a dining room with many tables far from the kitchen froze the game on load ("A script in this movie has taken too long").
  - **Walk-through arches:** the Sunken Ruins Arch and the Wedding Trellis now render assembled correctly, and customers walk through the middle tile.
  - **Seasonal items:** Halloween, Christmas and Valentine's items only show up in the shop during their season.
  - **July items with effects:** the pets walk around, Magic Water joins its edges, the Rain Cloud makes rain, the Pet Cheshire Cat vanishes and comes back, the petal, butterfly and music-note decorations work, and the demand bonuses apply.
- **No duplicates in the shop.** These left the shop because they repeated original items: the July Teppanyaki Grill (the `3080048` one stays, with the original animation, 10 Playfish Cash and 10% faster cooking), and the recreated Bonsai Tree, Bamboo Flooring and Multi Tile. Anyone who already owns one keeps it.
- **Removed:** the Japanese Divider Corner (`3080089`), which we had made ourselves. The migration deletes any copies in the database.
- **New optional server patch:** `block_stacks.patch`. It stops the server from deleting stacks of identical blocks on one tile, a classic decorating trick.

---

## ⚠️ WARNINGS (READ FIRST)

> [!CAUTION]
> **1. Installed the 2026-10-29 package? Migrate the database BEFORE opening the game.**  
> The ids of the 77 recreations that became originals no longer exist in the catalog. Without the migration, stored and placed items with those ids disappear or break the restaurant. With the server **stopped**, inside the `3_rebuild` folder:
> ```powershell
> node scripts\migrar_inventario_julho2010.cjs --servidor "C:\path\to\server"
> node scripts\migrar_inventario_julho2010.cjs --servidor "C:\path\to\server" --aplicar
> ```
> The first command only counts what will change (dry run). The second backs up `dev.db` into `backups\` and swaps the ids in inventories, placed items, floors, mail and pending trades. At the end it checks that the item totals did not change. It also deletes the Japanese Divider Corner copies. It needs Node 20+ and the server with `npm install` already done, since it uses the server's `better-sqlite3`. If you never installed the 2026-10-29 package, skip this step.

> [!CAUTION]
> **2. Id conflicts.**  
> Recreated items use the range `3080001` to `3080146`. July items use the original Playfish ids that do not exist in the 0.9.143a build: decorations and furniture between `3000066` and `3500130`, recipes `5000026`–`5000037`, `5100037`–`5100049`, `5200029`–`5200038` and `5300020`–`5300034`, and ingredients `4000101`–`4000111`. If your server already registered its own items under those ids (or added the July items some other way), **do not install**: the rows would clash in the catalog.

> [!WARNING]
> **3. Back up the 9 files.**  
> The installation overwrites these files. Keep a copy of them in a separate folder so you can restore them:
> - `public/swf/indoor_asset.swf`
> - `public/swf/game.swf`
> - `public/data/restaurant.xml` and `public/data/restaurant.bin`
> - `public/data/lang_en.bin`
> - `public/data/recipe.xml` and `public/data/recipe.bin`
> - `public/data/ingredient.xml` and `public/data/ingredient.bin`

> [!IMPORTANT]
> **4. Restart the server.**  
> The server caches the catalog, recipes and prices in memory. After copying the files, **restart it** (`npm run start:built` or `start.bat`). Otherwise new items will not show up or will keep old prices.

> [!NOTE]
> **5. Ctrl + F5 in the browsers.**  
> Flash Player / Ruffle caches the SWF in the browser. Every player must reload the game page with **Ctrl + F5**.

---

## 🛍️ What the package contains

| | Count |
|---|---|
| Items recreated by us (ids `3080xxx`) | 44 in the catalog, 41 for sale |
| Official July 2010 items | 494 (106 cost Playfish Cash) |
| New recipes | 50 (7 from the Sushi Bar chain + 43 from Feb–Jul 2010) |
| New ingredients | 11 |

The complete list, tab by tab, with the id, price, effect and size of every item, is in **[ITEMS.md](ITEMS.md)**.

### Recreated items for sale (41)

- **Kitchen:** Teppanyaki Grill (`3080048`, 10 Playfish Cash, cooks 10% faster, original July animation).
- **Floor tiles (19):** Garden Path Tile 1–6, Turkish Stone Tile, Sand Tile 2 and 3, Sports Court Tile 1–7, Oktoberfest Tile, Sun God Tile, Magic Chocolate Tile.
- **Decorations (18):** Fish Tank (Taste of Asia), Japanese Fishpond, Melon/Strawberry/Kiwi Rug, Potted Melon Divider, Nosy Squirrel, Camouflage Bear, Ghost Story Arcade, Louis Biltong, New Orleans Jazzy Duo, New Orleans Jukebox, Alessandra Clapper, The Watering Hole, Failed Knight Figurine, Evil Tree, Cheesey Varities, Liberty Bell.
- **Wall decorations (3):** Pixel Decal - Fruit Punch, Gooey Monster and Potato <3.

### Not in the shop (owners keep using them)

| Id | Item | Why |
|---|---|---|
| `3070020` | Teppanyaki Grill (July) | duplicate: `3080048` stays |
| `3080010` | Bonsai Tree (recreated) | repeated the original Bonsai `3020288` |
| `3080101` | Bamboo Flooring (recreated) | repeated the original Bamboo Floor `3050063` |
| `3080098` | Multi Tile (recreated) | repeated the original Cards Tile `3050061` |

### July items without their effect yet

They show up, decorate and can be bought, but their special function is not written yet:
- **Tiny Door** (`ShrinkCustomerDoor`): customers should shrink when walking through.
- **Night Sculpture** (`NightTimeRoad`): the street should turn to night.
- **Tiki Statue, Hotel City Sign, Alien Monolith and Football Wall TV:** they attract costumed customers, but the July costumes do not exist in the game.

### Recipe upgrades that do not take effect yet
You can learn and serve them, but the extra visual/functional perks below have not been written yet:
- **Lounge Bar upgrades:** Tropical Sunrise, Strawberry Heaven, Russian Cappuccino, Mint Breeze, Pink Lemonade, Mango Tango and Kiwi Twist (bar snacks, second bartender, extra stool, taps, mixer).
- **Drink Me:** should shrink the customer (ShrinkCustomer).

---

## 🚀 Which path to follow?

| Your situation | Path | Time |
|---|---|---|
| **Never edited** the server's `game.swf`, catalog or texts (or only installed the 2026-10-29 package) | **Path A: copy & paste** | ~3 minutes |
| **Already modified** `game.swf`, added your own items or changed `lang_en.bin` | **Path B: rebuild** on top of your files | ~5 minutes |

On both paths, users of the 2026-10-29 package run the migration from warning 1 first.

---

## Path A: copy & paste

1. **Stop the server and back up** the 9 files from warning 3.
2. **If you installed the 2026-10-29 package**, run the migration (warning 1).
3. **Copy** the contents of `1_ready_files` into the server folder, **overwriting** the files:

   | In the package | On the server |
   |---|---|
   | `1_ready_files/public/swf/indoor_asset.swf` | `public/swf/indoor_asset.swf` |
   | `1_ready_files/public/swf/game.swf` | `public/swf/game.swf` |
   | `1_ready_files/public/data/restaurant.xml` and `.bin` | `public/data/restaurant.xml` and `.bin` |
   | `1_ready_files/public/data/lang_en.bin` | `public/data/lang_en.bin` |
   | `1_ready_files/public/data/recipe.xml` and `.bin` | `public/data/recipe.xml` and `.bin` |
   | `1_ready_files/public/data/ingredient.xml` and `.bin` | `public/data/ingredient.xml` and `.bin` |

4. **Restart the server** and ask every player for **Ctrl + F5**.

The `game.swf` in this folder comes **without** the in-restaurant ingredient exchange button (it needs a server patch; see the optional features).

---

## Path B: rebuild on top of your own files

*Requirements: Windows with PowerShell, **Java 17+** and **Node 20+**.*

1. Stop the server, back up the 9 files and, if needed, run the migration.
2. Copy the whole `3_rebuild` folder somewhere on your computer (e.g. `C:\rc_items\`).
3. Open PowerShell inside it and run, with the path of your server's `public` folder:
   ```powershell
   powershell -ExecutionPolicy Bypass -File scripts\aplicar_itens.ps1 -Servidor "C:\path\to\server\public" -SemTroca
   ```
   Drop `-SemTroca` only if you are also installing the ingredient exchange (client and server patch).
4. Wait for the final message `Pronto. Reinicie o servidor` ("Done. Restart the server"). If FFDec reports a compilation error, check your Java version with `java -version`.
5. Restart the server and ask players for **Ctrl + F5**.

What the script does:
- **First run:** stores your server's original files in `3_rebuild\recriados\base\`. Later runs always start from them, so **do not delete that folder**.
- **July art:** copies the July 2010 art from `3_rebuild\recuperado\restaurant_origins\` into `indoor_asset.swf`.
- **Recreated items:** injects the art and catalog rows of the recreated items (`recriados\manifesto.json`).
- **Catalog:** applies the July values, the seasons (`recriados\epocas.json`) and the items taken out of the shop (`recriados\fora_da_loja.json`).
- **Recipes:** writes the 50 recipes and 11 ingredients from 2010.
- **Game:** recompiles the classes in `recriados\codigo\` into `game.swf`.

To take another item out of the shop, add a line to `recriados\fora_da_loja.json` and run the script again.

---

## 🧩 Optional features

### 1. Ingredient exchange inside your own restaurant (3-for-1)
A button next to the Market: players pick 3 of their own ingredients and get 1 of their choice, without needing a neighbor. Client and server go **together**:
1. **Client:** copy `2_optional/ingredient_exchange/game.swf` to `public/swf/game.swf` (instead of the default `game.swf`).
2. **Server:** in the server folder (back up `src/db/rpc-store.ts` first):
   ```bash
   git apply --ignore-whitespace path\to\package\2_optional/ingredient_exchange\ingredient_exchange.patch
   copy path\to\package\2_optional/ingredient_exchange\own-ingredient-exchange.test.cjs test\
   npm run build
   ```

> ⚠️ With the button `game.swf` but without the server patch, exchanges always fail with a network error.

### 2. Block stacks (server)
The classic trick of stacking identical blocks (for example, 3 White Room Divider Blocks on one tile to build a pillar) works in the game. Dippy's server, however, treats identical copies on the same tile as duplicates and deletes them the next time the restaurant loads. This patch makes the server skip `surface` items in that cleanup. In the server folder (back up `src/db/item-catalog.ts` and `src/db/profile-store.ts` first):
```bash
git apply --ignore-whitespace path\to\package\2_optional\block_stacks.patch
npm run build
```

### 3. Performance selector (Ruffle)
A dropdown in `public/game.html` with three presets (Ultra-fast, Balanced and High Definition) to reduce lag on low-end machines and HiDPI screens:
```bash
git apply --ignore-whitespace path\to\package\2_optional\performance_launcher.patch
npm run build
```

---

## ↩️ How to undo

- **Path A:** copy the 9 backed-up files back into `public/` and restart the server.
- **Path B:** in PowerShell, inside `3_rebuild`:
  ```powershell
  powershell -ExecutionPolicy Bypass -File scripts\aplicar_itens.ps1 -Servidor "C:\path\to\server\public" -Restaurar
  ```
  then restart the server.
- **Migration:** the database backup is in the server's `backups\` folder, named `dev.db.<date>_antes_julho2010_<number>`. To roll back, stop the server and copy it over `dev.db`.
- **Patches:** `git apply -R <patch>` and `npm run build`.

---

## ✅ How to check in game

1. **Shop, Kitchen tab:** a single Teppanyaki Grill shows up (10 Playfish Cash).
2. **Shop, Functional tab:** the Monster Robot walks around the room and the Cherry Blossom Tree drops petals.
3. **Shop, Decoration tab:** the Sunken Ruins Arch and the Wedding Trellis show up whole; customers walk through them.
4. **Menu:** the new recipes appear at the end of each tab (starters, mains, desserts and drinks), with their art and no limited-time countdown.
5. **Sushi Bar:** only the plates of mastered sushi recipes show food on the belt.
6. **Big dining room:** a layout with 50+ chairs loads without freezing (in testing, 59 chairs loaded in 0.7 s).
7. **If you migrated:** the recreated items you owned now show up as the July originals, in the same places.
