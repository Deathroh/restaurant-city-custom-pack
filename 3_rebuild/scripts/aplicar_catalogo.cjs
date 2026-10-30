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
  const linha = `\t\t<item ${Object.entries(attrs).sort(([a], [b]) => a.localeCompare(b)).map(([k, v]) => `${k}="${esc(v)}"`).join(' ')}/>\n`;
  const abre = xml.search(new RegExp(`<group\\b[^>]*\\bname="${it.grupo.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}"`));
  if (abre < 0) throw new Error(`${it.classe}: grupo "${it.grupo}" nao existe no XML`);
  const fecha = xml.indexOf('</group>', abre);
  xml = xml.slice(0, fecha) + linha + '\t' + xml.slice(fecha);
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
fs.writeFileSync(path.join(pastaData, 'restaurant.xml'), xml, 'utf8');
fs.writeFileSync(path.join(pastaData, 'restaurant.bin'), zlib.deflateSync(Buffer.from(xml, 'utf8')));
console.log(`catalogo: ${inseridos} item(ns) acrescentado(s); restaurant.xml e restaurant.bin gravados em ${pastaData}`);
