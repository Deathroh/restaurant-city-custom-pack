// Acrescenta os itens recriados ao catalogo do jogo (restaurant.xml + restaurant.bin = xml com zlib).
// Parte sempre do XML original guardado em recriados/base/, entao rodar de novo nao duplica linhas.
// Cada item do manifesto precisa de: classe, id (faixa 308xxxx), nome, custo (moedas) ou cash, grupo
// (nome do <group> no XML: "Decoration", "Functional", "Table", "Chair", "Wall Decoration"...),
// e opcionais: tipo (atributo type, ex. "sink", "chairItem, toilet"), sizeX/sizeY, functions.
// Uso: node aplicar_catalogo.cjs <manifesto.json> <restaurant.xml base> <pasta data do servidor>
'use strict';
const fs = require('fs');
const path = require('path');
const zlib = require('zlib');
const crypto = require('crypto');

const [, , arqManifesto, xmlBase, pastaData] = process.argv;
const manifesto = JSON.parse(fs.readFileSync(arqManifesto, 'utf8').replace(/^﻿/, ''));
let xml = fs.readFileSync(xmlBase, 'utf8');

// hash opaco no mesmo formato dos originais (22 caracteres de [A-Za-z0-9._]), estavel por classe
const ALFABETO = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789._';
function hashDe(classe) {
  const d = crypto.createHash('sha256').update(`rcr:${classe}`).digest();
  let s = ''; for (let i = 0; i < 22; i++) s += ALFABETO[d[i] % 64];
  return s;
}
const esc = (v) => String(v).replace(/&/g, '&amp;').replace(/"/g, '&quot;').replace(/</g, '&lt;');

// acrescenta uma linha de item no fim do <group> com esse nome
function noGrupo(grupo, linha, quem) {
  const abre = xml.search(new RegExp(`<group\\b[^>]*\\bname="${grupo.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}"`));
  if (abre < 0) throw new Error(`${quem}: grupo "${grupo}" nao existe no XML`);
  const fecha = xml.indexOf('</group>', abre);
  xml = xml.slice(0, fecha) + linha + '\t' + xml.slice(fecha);
}

// build de julho/2010 (recriados/julho2010/catalogo.json, de preparar_julho2010.cjs): valores novos dos itens
// que ja temos e os itens que so existiam em julho, com o id, o hash e os atributos originais. Os valores
// vem do XML deles ja com as entidades escritas (&amp;), por isso entram sem esc().
const arqJulho = path.join(path.dirname(arqManifesto), 'julho2010', 'catalogo.json');
if (fs.existsSync(arqJulho)) {
  const julho = JSON.parse(fs.readFileSync(arqJulho, 'utf8').replace(/^﻿/, ''));
  for (const v of julho.valores) {
    const m = xml.match(new RegExp(`<item\\b[^>]*\\bid="${v.id}"[^>]*?/?>`));
    if (!m || !m[0].includes(`className="${v.classe}"`)) throw new Error(`julho2010: ${v.classe} (${v.id}) nao encontrado no catalogo`);
    let linha = m[0];
    for (const [k, val] of Object.entries(v.mudar)) {
      const reAttr = new RegExp(`\\s${k}="[^"]*"`);
      if (val === null) linha = linha.replace(reAttr, '');
      else if (reAttr.test(linha)) linha = linha.replace(reAttr, ` ${k}="${val}"`);
      else linha = linha.replace(/\s*\/?>$/, (fim) => ` ${k}="${val}"${fim}`);
    }
    xml = xml.replace(m[0], linha);
  }
  const ids = new Set([...xml.matchAll(/\bid="(\d+)"/g)].map((m) => m[1]));
  const classes = new Set([...xml.matchAll(/\bclassName="([^"]+)"/g)].map((m) => m[1]));
  for (const n of julho.novos) {
    if (ids.has(n.attrs.id) || classes.has(n.attrs.className)) throw new Error(`julho2010: ${n.attrs.className} (${n.attrs.id}) ja existe no catalogo`);
    noGrupo(n.grupo, `\t\t<item ${Object.entries(n.attrs).map(([k, v]) => `${k}="${v}"`).join(' ')}/>\n`, n.attrs.className);
    ids.add(n.attrs.id); classes.add(n.attrs.className);
  }
  console.log(`catalogo: julho/2010 com ${julho.novos.length} item(ns) novo(s) e ${julho.valores.length} com valor de julho`);
}

const idsUsados = new Set([...xml.matchAll(/\bid="(\d+)"/g)].map((m) => Number(m[1])));
let inseridos = 0;
for (const it of manifesto.itens) {
  if (it.soArte) continue;   // so sprite (ex.: particula de efeito), sem linha no catalogo
  if (!it.id || !it.nome || !it.grupo) throw new Error(`${it.classe}: faltam id/nome/grupo no manifesto`);
  if (idsUsados.has(it.id)) throw new Error(`${it.classe}: id ${it.id} ja existe no catalogo`);
  const sub = Math.floor(it.id / 10000);
  if (Math.floor(it.id / 1000000) !== 3 || [360, 390, 391].includes(sub)) throw new Error(`${it.classe}: id fora da faixa de item de restaurante`);
  const attrs = { className: it.classe, hash: hashDe(it.classe), id: it.id, name: it.nome, isNew: 'true' };
  if (it.custo) attrs.cost = it.custo;
  if (it.cash) attrs.cash = it.cash;
  if (it.tipo) attrs.type = it.tipo;
  if (it.sizeX) attrs.sizeX = it.sizeX;
  if (it.sizeY) attrs.sizeY = it.sizeY;
  if (it.functions) attrs.functions = it.functions;
  if (it.operar) attrs.operateTimePercentage = it.operar;   // % do tempo normal: 90 = 10% mais rapido
  if (it.quebra) attrs.breakCount = it.quebra;              // usos ate quebrar (sem isso nunca quebra)
  if (it.functions || it.efeito) attrs.infoText = 'true';   // botao (i): textos de aplicar_textos.cjs
  // fora da loja: o jogo (ItemChooser) so mostra quem ja tem no inventario, e as copias colocadas continuam valendo
  if (it.invisivel) attrs.invisible = 'true';
  noGrupo(it.grupo, `\t\t<item ${Object.entries(attrs).sort(([a], [b]) => a.localeCompare(b)).map(([k, v]) => `${k}="${esc(v)}"`).join(' ')}/>\n`, it.classe);
  idsUsados.add(it.id); inseridos++;
  console.log(`${it.id} ${it.nome} -> grupo ${it.grupo}${it.tipo ? ` (type=${it.tipo})` : ''}`);
}
// itens de epoca do catalogo original (recriados/epocas.json, ao lado do manifesto): rcrEpoca="MM-DD:MM-DD".
// O ItemChooser do game.swf (recriados/codigo) tira da loja fora da janela.
const arqEpocas = path.join(path.dirname(arqManifesto), 'epocas.json');
if (fs.existsSync(arqEpocas)) {
  const { epocas } = JSON.parse(fs.readFileSync(arqEpocas, 'utf8').replace(/^﻿/, ''));
  let marcados = 0;
  for (const ep of epocas) {
    if (!/^\d\d-\d\d$/.test(ep.de) || !/^\d\d-\d\d$/.test(ep.ate)) throw new Error(`epocas.json: ${ep.nome} com data fora do formato MM-DD`);
    for (const id of ep.ids) {
      const re = new RegExp(`(<item\\b[^>]*\\bid="${id}")([^>]*?)(\\s*/?>)`);
      if (!re.test(xml)) throw new Error(`epocas.json: ${ep.nome}: id ${id} nao existe no catalogo`);
      xml = xml.replace(re, (_, a, b, c) => `${a}${b} rcrEpoca="${ep.de}:${ep.ate}"${c}`);
      marcados++;
    }
  }
  console.log(`catalogo: ${marcados} item(ns) de epoca marcados (${epocas.map((e) => `${e.nome} ${e.de} a ${e.ate}`).join(', ')})`);
}
// itens fora da loja (recriados/fora_da_loja.json, ao lado do manifesto; desde 2026-11-04): invisible="true".
// O ItemChooser so mostra quem ja tem no inventario; as copias colocadas continuam valendo.
const arqFora = path.join(path.dirname(arqManifesto), 'fora_da_loja.json');
if (fs.existsSync(arqFora)) {
  const { itens: fora } = JSON.parse(fs.readFileSync(arqFora, 'utf8').replace(/^﻿/, ''));
  for (const f of fora) {
    const re = new RegExp(`<item\\b[^>]*\\bid="${f.id}"[^>]*?/?>`);
    const m = xml.match(re);
    if (!m) throw new Error(`fora_da_loja.json: id ${f.id} nao existe no catalogo`);
    if (/\sinvisible="/.test(m[0])) continue;
    xml = xml.replace(m[0], m[0].replace(/\s*\/?>$/, (fim) => ` invisible="true"${fim}`));
  }
  console.log(`catalogo: ${fora.length} item(ns) fora da loja (${fora.map((f) => f.id).join(', ')})`);
}
fs.writeFileSync(path.join(pastaData, 'restaurant.xml'), xml, 'utf8');
fs.writeFileSync(path.join(pastaData, 'restaurant.bin'), zlib.deflateSync(Buffer.from(xml, 'utf8')));
console.log(`catalogo: ${inseridos} item(ns) acrescentado(s); restaurant.xml e restaurant.bin gravados em ${pastaData}`);
