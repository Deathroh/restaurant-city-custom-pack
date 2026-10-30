# 3_rebuild: what is in here

The scripts were written in Portuguese and look for these exact folder names, so **do not rename anything here**.

| Path | What it is |
|---|---|
| `scripts/aplicar_itens.ps1` | "Apply items". The only script you run (see `INSTALL.md`, Path B). It runs the three below, recompiles `game.swf` with FFDec and keeps a lock (`recriados/.estado_servidor*.json`) so changes made by hand on the server are not silently overwritten. |
| `scripts/injetar_itens.cjs` | Injects the item art into `indoor_asset.swf`. |
| `scripts/aplicar_catalogo.cjs` | Adds the items to `restaurant.xml` / `restaurant.bin` and marks the seasonal items from `recriados/epocas.json`. |
| `scripts/aplicar_textos.cjs` | Adds item descriptions and shop tooltips to `lang_en.bin`. |
| `recriados/` | "Recreated": all items and code. |
| `recriados/manifesto.json` | One entry per item: `classe` (class name), `nome` (name), `grupo` (shop group), `custo` (coins) or `cash` (fishcash), `vistas` (art per view), `angulos` (rotations), `descricao` / `efeito` / `dica` (texts). |
| `recriados/RCR_<Item>/` | The PNG art of each item. |
| `recriados/epocas.json` | Seasonal items: `epocas` (seasons) with `de` (from) / `ate` (until) in MM-DD and the ids. Halloween, Natal (Christmas), Valentine. |
| `recriados/codigo/` | "Code": modified game classes recompiled into `game.swf`; `codigo/original/` keeps the decompiled originals for comparison. |
| `recriados/base/` | Created on the first run: your server's original files. Do not delete. |
| `recriados/LEIA_ANTES_DE_MEXER.md` | "Read before editing": the full technical notes (every item, every code change and why). Portuguese only. |
| `ferramentas/ffdec/` | "Tools": FFDec, the compiler used for `game.swf` (needs Java 17+). |

Script options (`aplicar_itens.ps1`):
- `-Servidor <path>`: your server's `public` folder.
- `-SemTroca`: build `game.swf` without the ingredient-exchange button.
- `-Restaurar`: put your server's originals back.
- `-Forcar`: apply even if the server files changed since the last run. Only use it after moving those changes into `manifesto.json` or `recriados/codigo/`.
