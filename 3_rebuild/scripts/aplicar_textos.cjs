// Acrescenta ao lang_en.bin (XML comprimido com zlib) os textos da janela de informacao dos itens
// recriados que tem "descricao" e/ou "efeito" no manifesto: ItemDescription<classe> e ItemFunction<classe>
// (lidos por WorldItemInfoPopUp no game.swf). "dica" vira ItemToolTip<classe>: a linha azul que aparece ao
// passar o mouse no item da loja (ex.: Valentine Stove, ItemToolTipStove14 = "Cooks 8% faster").
// Uso: node aplicar_textos.cjs <manifesto.json> <lang_en.bin original> <lang_en.bin de saida>
const fs = require('fs');
const zlib = require('zlib');
const [, , arqManifesto, entrada, saida] = process.argv;
const manifesto = JSON.parse(fs.readFileSync(arqManifesto, 'utf8').replace(/^﻿/, ''));
let xml = zlib.inflateSync(fs.readFileSync(entrada)).toString('utf8');
const esc = (v) => String(v).replace(/&/g, '&amp;').replace(/</g, '&lt;');

const linhas = [];
for (const it of manifesto.itens) {
  for (const [campo, prefixo] of [['descricao', 'ItemDescription'], ['efeito', 'ItemFunction'], ['dica', 'ItemToolTip']]) {
    if (!it[campo]) continue;
    const id = prefixo + it.classe;
    if (xml.includes(`<text id="${id}">`)) throw new Error(`${id} ja existe no lang_en`);
    linhas.push(`\t\t<text id="${id}">\r\n\t\t\t${esc(it[campo])}\r\n\t\t</text>\r\n`);
  }
}
// entra logo depois do bloco da Snow Machine, dentro do mesmo <content>
const ancora = xml.indexOf('<text id="ItemFunctionSnowMachine">');
if (ancora < 0) throw new Error('ancora ItemFunctionSnowMachine nao encontrada');
const fim = xml.indexOf('</text>', ancora) + '</text>'.length;
xml = xml.slice(0, fim) + '\r\n' + linhas.join('') + xml.slice(fim);
fs.writeFileSync(saida, zlib.deflateSync(Buffer.from(xml, 'utf8')));
console.log(`lang_en: ${linhas.length} texto(s) acrescentado(s)`);
