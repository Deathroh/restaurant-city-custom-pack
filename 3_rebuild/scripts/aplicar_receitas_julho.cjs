// Receitas e ingredientes da build de julho/2010 que o nosso jogo nao tem (pedido da dona, 2026-11-04):
// as 7 receitas da cadeia do Sushi Bar (o Yakibuta Ramen ja existia) e os ingredientes Salmon e Seaweed.
// Linhas copiadas sem mudar do recipe.xml / ingredient.xml do Restaurant Origins (mesmo id, hash, preco e
// ingredientes; a Salmon Sashimi mantem level10Reward="3500117", o Sushi Bar como premio do nivel 10).
// Cada receita entra no mesmo grupo do cardapio de julho (Starter / Main / Dessert).
// Parte sempre dos originais guardados em recriados/base/ (na primeira vez, copia os do servidor) e grava
// recipe.xml/.bin e ingredient.xml/.bin (o .bin e o xml com zlib) em <pasta data do servidor>.
// O servidor le esses xml (recipe-catalog.ts, cash-catalog.ts) e guarda em cache: reiniciar depois.
// A arte: comidas FoodItem108..114 (game_asset2.swf de julho) e o ingrediente Salmon (ingredient_asset.swf de
// julho) entram no indoor_asset.swf pelo copiar_julho2010.cjs (fontes filtradas). O Seaweed ja tem arte.
// Uso: node aplicar_receitas_julho.cjs <pasta data do servidor>
'use strict';
const fs = require('fs'), path = require('path'), zlib = require('zlib');
const [, , pastaData] = process.argv;
if (!pastaData) throw new Error('uso: node aplicar_receitas_julho.cjs <pasta data do servidor>');
const proj = path.join(__dirname, '..');
const base = path.join(proj, 'recriados', 'base');
const ro = path.join(proj, 'recuperado', 'restaurant_origins');

const RECEITAS = ['5100044', '5000031', '5000032', '5000033', '5100043', '5100045', '5200033'];
const INGREDIENTES = ['4000103', '4000104'];

function original(nome) {
  const arq = path.join(base, nome);
  if (!fs.existsSync(arq)) {
    const doServidor = fs.readFileSync(path.join(pastaData, nome), 'utf8');
    for (const id of [...RECEITAS, ...INGREDIENTES]) if (doServidor.includes(`id="${id}"`)) throw new Error(`${nome} do servidor ja tem ${id}: nao e o original`);
    fs.writeFileSync(arq, doServidor);
  }
  return fs.readFileSync(arq, 'utf8');
}

// linha <item ... id="X" .../> do xml de julho e o nome do grupo onde ela esta
function linhaDeJulho(xml, id) {
  for (const g of xml.matchAll(/<group name="([^"]*)"[^>]*>([\s\S]*?)<\/group>/g)) {
    const m = g[2].match(new RegExp(`<item [^>]*\\bid="${id}"[^>]*/>`));
    if (m) return { grupo: g[1], linha: m[0] };
  }
  throw new Error(`id ${id} nao achado no xml de julho`);
}

function acrescentar(nome, ids) {
  let xml = original(nome);
  const julho = fs.readFileSync(path.join(ro, nome), 'utf8');
  let n = 0;
  for (const id of ids) {
    if (xml.includes(`id="${id}"`)) throw new Error(`${nome}: ${id} ja existe no original`);
    const { grupo, linha } = linhaDeJulho(julho, id);
    const abre = xml.match(new RegExp(`<group name="${grupo}"[^>]*>`));
    if (!abre) throw new Error(`${nome}: grupo ${grupo} nao existe no nosso`);
    const fim = xml.indexOf('</group>', abre.index);
    xml = xml.slice(0, fim) + `\t${linha}\r\n\t` + xml.slice(fim);
    n++;
  }
  fs.writeFileSync(path.join(pastaData, nome), xml);
  fs.writeFileSync(path.join(pastaData, nome.replace('.xml', '.bin')), zlib.deflateSync(Buffer.from(xml, 'utf8')));
  console.log(`${nome}: ${n} linha(s) de julho acrescentada(s)`);
}

acrescentar('ingredient.xml', INGREDIENTES);
acrescentar('recipe.xml', RECEITAS);
