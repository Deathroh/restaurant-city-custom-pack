// Copia para o nosso indoor_asset.swf os simbolos da build de julho/2010 (Restaurant Origins) que faltam nele
// (etapa 2 de PLANO_raspagem_julho2010.md). Para cada classe exportada nos .swf deles que o nosso nao tem, leva
// o simbolo e tudo o que ele usa (sprites, shapes, bitmaps, fontes), com ids novos a partir do maior id nosso.
// Uma peca interna que la tem nome exportado que o nosso ja tem (ChefFloor, DoorWayMask, GardenPlot...)
// nao e copiada: aponta para a nossa. A base de fevereiro fica intacta e nenhum simbolo sai duplicado.
// As classes AS3 sao geradas aqui (DoABC) com os scripts de quadro de recriados/julho2010/quadros.json
// (stop / gotoAndPlay). As linhas do tempo internas com script (pacote <swf>_fla) vao para o pacote
// rcr_julho_fla, com o nome do .swf de origem na frente, para nao colidir com as nossas.
// Uso: node copiar_julho2010.cjs <indoor_asset.swf nosso> <saida.swf> <swf deles>... (o primeiro vence)
'use strict';
const fs = require('fs');
const path = require('path');
const zlib = require('zlib');

const [, , entrada, saida, ...fontes] = process.argv;
const quadros = JSON.parse(fs.readFileSync(path.join(__dirname, '..', 'recriados', 'julho2010', 'quadros.json'), 'utf8'));

const u16 = (v) => { const b = Buffer.alloc(2); b.writeUInt16LE(v); return b; };
const u32 = (v) => { const b = Buffer.alloc(4); b.writeUInt32LE(v); return b; };
const cstr = (s) => Buffer.concat([Buffer.from(s, 'utf8'), Buffer.from([0])]);
const tag = (codigo, corpo) => Buffer.concat([u16((codigo << 6) | 0x3f), u32(corpo.length), corpo]);

// ---------- leitura ----------
function lerTags(raw, ini, fim) {
  const tags = []; let p = ini;
  while (p < fim) {
    const cab = raw.readUInt16LE(p); let len = cab & 0x3f, h = 2;
    if (len === 0x3f) { len = raw.readUInt32LE(p + 2); h = 6; }
    tags.push({ codigo: cab >> 6, corpo: raw.subarray(p + h, p + h + len) });
    p += h + len;
    if ((cab >> 6) === 0) break;
  }
  return tags;
}
function abrir(arquivo) {
  const bruto = fs.readFileSync(arquivo);
  const sig = bruto.toString('latin1', 0, 3);
  const raw = sig === 'CWS' ? Buffer.concat([Buffer.from('FWS'), bruto.subarray(3, 8), zlib.inflateSync(bruto.subarray(8))]) : bruto;
  const inicio = 8 + Math.ceil((5 + (raw[8] >> 3) * 4) / 8) + 4;
  return { raw, inicio, comprimido: sig === 'CWS', tags: lerTags(raw, inicio, raw.length) };
}
function simbolos(tags) {   // nome -> id e id -> [nomes]
  const porNome = new Map(), porId = new Map();
  for (const t of tags) if (t.codigo === 76) {
    const c = t.corpo; let q = 2;
    for (let i = 0, n = c.readUInt16LE(0); i < n; i++) {
      const sid = c.readUInt16LE(q); q += 2; let e = q; while (c[e]) e++;
      const nome = c.toString('utf8', q, e); q = e + 1;
      porNome.set(nome, sid); if (!porId.has(sid)) porId.set(sid, []); porId.get(sid).push(nome);
    }
  }
  return { porNome, porId };
}

// ---------- referencias a outros personagens dentro de cada tag de definicao ----------
// Devolve os offsets (no corpo) de cada u16 que e id de personagem, para o remapeamento.
class Bits {
  constructor(buf, pos) { this.b = buf; this.p = pos * 8; }
  u(n) { let v = 0; for (let i = 0; i < n; i++) { v = (v << 1) | ((this.b[this.p >> 3] >> (7 - (this.p & 7))) & 1); this.p++; } return v >>> 0; }
  s(n) { const v = this.u(n); return n && (v & (1 << (n - 1))) ? v - (1 << n) : v; }
  alinhar() { this.p = (this.p + 7) & ~7; }
  get byte() { return this.p >> 3; }
}
function pularRect(b) { const n = b.u(5); b.u(n * 4); b.alinhar(); }
function pularMatriz(b) {
  if (b.u(1)) { const n = b.u(5); b.u(n * 2); }
  if (b.u(1)) { const n = b.u(5); b.u(n * 2); }
  const n = b.u(5); b.u(n * 2); b.alinhar();
}
function lerEstilos(c, b, versao, refs) {
  // FILLSTYLEARRAY + LINESTYLEARRAY, byte alinhados; versao = 1..4 (DefineShape..DefineShape4)
  const rgb = versao >= 3 ? 4 : 3;
  const preenchimento = () => {
    const tipo = c[b.byte]; b.p += 8;
    if (tipo === 0x00) b.p += rgb * 8;
    else if (tipo === 0x10 || tipo === 0x12 || tipo === 0x13) {
      pularMatriz(b);
      const n = c[b.byte] & 0x0f; b.p += 8 + n * (1 + rgb) * 8;
      if (tipo === 0x13) b.p += 16;
    } else if (tipo >= 0x40 && tipo <= 0x43) {
      refs.push(b.byte); b.p += 16; pularMatriz(b);
    } else throw new Error(`estilo de preenchimento desconhecido 0x${tipo.toString(16)}`);
  };
  let n = c[b.byte]; b.p += 8;
  if (n === 0xff && versao >= 2) { n = c.readUInt16LE(b.byte); b.p += 16; }
  for (let i = 0; i < n; i++) preenchimento();
  n = c[b.byte]; b.p += 8;
  if (n === 0xff && versao >= 2) { n = c.readUInt16LE(b.byte); b.p += 16; }
  for (let i = 0; i < n; i++) {
    if (versao === 4) {
      b.p += 16; const f1 = c[b.byte], f2 = c[b.byte + 1]; b.p += 16;
      if (((f1 >> 4) & 3) === 2) b.p += 16;          // miter
      if (f1 & 0x08) preenchimento(); else b.p += 32;
      void f2;
    } else b.p += 16 + rgb * 8;
  }
}
function refsShape(c, codigo) {
  const versao = { 2: 1, 22: 2, 32: 3, 83: 4 }[codigo];
  const b = new Bits(c, 2); pularRect(b);
  if (versao === 4) { pularRect(b); b.p += 8; }
  const refs = [];
  lerEstilos(c, b, versao, refs);
  let nf = b.u(4), nl = b.u(4);
  for (;;) {
    if (b.u(1) === 0) {
      const f = b.u(5);
      if (!f) break;
      if (f & 1) { const n = b.u(5); b.u(n * 2); }
      if (f & 2) b.u(nf);
      if (f & 4) b.u(nf);
      if (f & 8) b.u(nl);
      if (f & 16) { b.alinhar(); lerEstilos(c, b, versao, refs); nf = b.u(4); nl = b.u(4); }
    } else {
      const reta = b.u(1), n = b.u(4) + 2;
      if (reta) { if (b.u(1)) b.u(n * 2); else { b.u(1); b.u(n); } } else b.u(n * 4);
    }
  }
  return refs;
}
function refsPlace(c, codigo, base) {   // dentro de um sprite; base = offset do corpo da tag no corpo do sprite
  if (codigo === 4 || codigo === 5) return [base];
  if (codigo === 26) return c[0] & 0x02 ? [base + 3] : [];
  if (codigo === 70) {
    let q = 4;
    if (c[1] & 0x08) { while (c[q]) q++; q++; }
    return c[0] & 0x02 ? [base + q] : [];
  }
  return [];
}
const DEFINE = new Set([2, 22, 32, 83, 6, 21, 35, 90, 20, 36, 39, 37, 75, 48, 10, 62, 11, 33, 46, 84, 14, 7, 34]);
const ANEXO = new Set([73, 88, 74, 78]);   // FontAlignZones, FontName, CSMTextSettings, ScalingGrid: u16 alvo no inicio
function refsDe(t) {
  const c = t.corpo;
  if ([2, 22, 32, 83].includes(t.codigo)) return refsShape(c, t.codigo);
  if (t.codigo === 39) {
    const refs = []; let p = 4;
    while (p < c.length) {
      const cab = c.readUInt16LE(p); let len = cab & 0x3f, h = 2;
      if (len === 0x3f) { len = c.readUInt32LE(p + 2); h = 6; }
      const cod = cab >> 6;
      refs.push(...refsPlace(c.subarray(p + h, p + h + len), cod, p + h));
      if ([15, 19, 45, 60, 61].includes(cod)) throw new Error(`sprite ${c.readUInt16LE(0)} com tag ${cod} (som/video) nao suportada`);
      p += h + len; if (cod === 0) break;
    }
    return refs;
  }
  if (t.codigo === 37) {   // DefineEditText: fontId depois do RECT e das flags, se HasFont
    const b = new Bits(c, 2); pularRect(b); const q = b.byte;
    return c[q] & 0x01 ? [q + 2] : [];
  }
  if ([6, 21, 35, 90, 20, 36, 75, 48, 10, 62].includes(t.codigo)) return [];
  throw new Error(`tag de definicao ${t.codigo} nao suportada pelo copiador`);
}

// ---------- ABC: uma classe por simbolo copiado, com os scripts de quadro ----------
// classes: [{ pacote, nome, base: 'MovieClip'|'BitmapData', quadros: { q: [acao] } }]
function abc(classes) {
  const u30 = (v) => { const o = []; do { let b = v & 0x7f; v >>>= 7; if (v) b |= 0x80; o.push(b); } while (v); return Buffer.from(o); };
  const strings = [''];
  const S = (s) => { let i = strings.indexOf(s); if (i < 0) { strings.push(s); i = strings.length - 1; } return i + 1; };
  const nsLista = [], nsIdx = new Map();
  const NS = (pacote) => { if (!nsIdx.has(pacote)) { nsLista.push(S(pacote)); nsIdx.set(pacote, nsLista.length); } return nsIdx.get(pacote); };
  const mn = [], mnIdx = new Map();
  const Q = (pacote, nome) => { const k = pacote + '|' + nome; if (!mnIdx.has(k)) { mn.push([NS(pacote), S(nome)]); mnIdx.set(k, mn.length); } return mnIdx.get(k); };
  const CADEIA = { MovieClip: [['', 'Object'], ['flash.events', 'EventDispatcher'], ['flash.display', 'DisplayObject'], ['flash.display', 'InteractiveObject'], ['flash.display', 'DisplayObjectContainer'], ['flash.display', 'Sprite'], ['flash.display', 'MovieClip']],
    BitmapData: [['', 'Object'], ['flash.display', 'BitmapData']] };
  const metodos = [], corpos = [];   // metodos: n params; corpos: [metodo, pilha, locais, iniEscopo, maxEscopo, codigo]
  const novoMetodo = (params) => { metodos.push(params); return metodos.length - 1; };
  const inst = [], cls = [];
  for (const c of classes) {
    const cadeia = CADEIA[c.base]; if (!cadeia) throw new Error(`${c.nome}: base ${c.base} nao suportada`);
    const prof = 1 + cadeia.length;   // escopo no newclass: global + cadeia
    const mClasse = Q(c.pacote, c.nome), mBase = Q(...cadeia[cadeia.length - 1]);
    const traits = [];
    const lista = Object.entries(c.quadros).map(([q, acoes]) => [Number(q), acoes]).sort((a, b) => a[0] - b[0]);
    let iinit;
    if (c.base === 'BitmapData') {
      iinit = novoMetodo(2);   // BitmapData(w, h): super(w, h)
      corpos.push([iinit, 3, 3, prof + 1, prof + 2, Buffer.from([0xd0, 0x30, 0xd0, 0xd1, 0xd2, 0x49, 0x02, 0x47])]);
    } else {
      iinit = novoMetodo(0);
      const cod = [0xd0, 0x30, 0xd0, 0x49, 0x00];
      if (lista.length) {
        cod.push(0xd0);
        for (const [q, acoes] of lista) {
          const nomeFn = `frame${q + 1}`, mFn = Q('', nomeFn), met = novoMetodo(0);
          const fc = [0xd0, 0x30];
          for (const a of acoes) {
            if (a[0] === 'stop') fc.push(0xd0, 0x4f, ...u30(Q('', 'stop')), 0x00);
            else if (a[0] === 'gotoAndPlay') fc.push(0xd0, 0x2c, ...u30(S(a[1])), 0x4f, ...u30(Q('', 'gotoAndPlay')), 0x01);
            else throw new Error(`${c.nome}: acao de quadro nao suportada ${JSON.stringify(a)}`);
          }
          fc.push(0x47);
          corpos.push([met, 2, 1, prof + 1, prof + 2, Buffer.from(fc)]);
          traits.push([mFn, met]);
          cod.push(0x25, ...u30(q), 0xd0, 0x66, ...u30(mFn));   // pushshort q; getlocal0; getproperty frameN
        }
        cod.push(0x4f, ...u30(Q('', 'addFrameScript')), ...u30(2 * lista.length));
      }
      cod.push(0x47);
      corpos.push([iinit, 1 + 2 * lista.length, 1, prof + 1, prof + 2, Buffer.from(cod)]);
    }
    const cinit = novoMetodo(0);
    corpos.push([cinit, 1, 1, prof, prof + 1, Buffer.from([0xd0, 0x30, 0x47])]);
    inst.push({ mClasse, mBase, iinit, traits, ns: c.pacote ? NS(c.pacote) : 0 });
    cls.push({ cinit, cadeia: cadeia.map((x) => Q(...x)), mClasse });
  }
  const scriptInit = novoMetodo(0);
  const cod = [0xd0, 0x30];
  cls.forEach((c, k) => {
    cod.push(0x65, 0x00);                                                  // getscopeobject 0
    for (const m of c.cadeia) cod.push(0x60, ...u30(m), 0x30);            // getlex + pushscope
    cod.push(0x60, ...u30(c.cadeia[c.cadeia.length - 1]), 0x58, ...u30(k)); // newclass k
    for (let i = 0; i < c.cadeia.length; i++) cod.push(0x1d);
    cod.push(0x68, ...u30(c.mClasse));                                     // initproperty
  });
  cod.push(0x47);
  corpos.push([scriptInit, 2, 1, 1, 9, Buffer.from(cod)]);

  const partes = [Buffer.from([16, 0, 46, 0]), u30(0), u30(0), u30(0)];
  partes.push(u30(strings.length + 1));
  for (const s of strings) { const b = Buffer.from(s, 'utf8'); partes.push(u30(b.length), b); }
  partes.push(u30(nsLista.length + 1)); for (const n of nsLista) partes.push(Buffer.from([0x16]), u30(n));
  partes.push(u30(0));
  partes.push(u30(mn.length + 1)); for (const [n, s] of mn) partes.push(Buffer.from([0x07]), u30(n), u30(s));
  partes.push(u30(metodos.length)); for (const np of metodos) partes.push(u30(np), u30(0), ...Array.from({ length: np }, () => u30(0)), u30(0), Buffer.from([0]));
  partes.push(u30(0));
  partes.push(u30(classes.length));
  for (const i of inst) {   // instance_info: classe dinamica (flags 0), como as do Flash para simbolos

    partes.push(u30(i.mClasse), u30(i.mBase), Buffer.from([0]), u30(0), u30(i.iinit), u30(i.traits.length));
    for (const [m, met] of i.traits) partes.push(u30(m), Buffer.from([0x01]), u30(0), u30(met));
  }
  for (const c of cls) partes.push(u30(c.cinit), u30(0));
  partes.push(u30(1), u30(scriptInit), u30(classes.length));
  cls.forEach((c, k) => partes.push(u30(c.mClasse), Buffer.from([4]), u30(k + 1), u30(k)));
  partes.push(u30(corpos.length));
  for (const [m, pilha, locais, ini, max, codigo] of corpos) partes.push(u30(m), u30(pilha), u30(locais), u30(ini), u30(max), u30(codigo.length), codigo, u30(0), u30(0));
  return Buffer.concat(partes);
}

// ---------- copia ----------
const nosso = abrir(entrada);
const nossos = simbolos(nosso.tags);
let proximo = 0;
for (const t of nosso.tags) if (DEFINE.has(t.codigo)) proximo = Math.max(proximo, t.corpo.readUInt16LE(0));
const inicioIds = proximo + 1;
const novas = [], registro = [];   // registro: [id novo, nome publicado, {pacote, nome, base, quadros}]
let jpegTables = null;
const copiadosPorNome = new Set();
for (const fonte of fontes) {
  // fonte filtrada (2026-11-03): "arquivo.swf=Classe1,Classe2" copia so essas classes (e o que elas usam).
  // Ex.: as comidas das receitas de sushi (FoodItem108..114) do game_asset2.swf, para os pratos do Sushi Bar.
  // Classe sem entrada em quadros.json vira MovieClip (ou BitmapData, se for imagem) sem scripts de quadro.
  const [arq, filtroTxt] = fonte.split('=');
  const filtro = filtroTxt ? new Set(filtroTxt.split(',')) : null;
  const swf = abrir(arq);
  const prefixo = path.basename(arq, '.swf');
  const defs = new Map(), anexos = new Map();
  for (const t of swf.tags) {
    if (DEFINE.has(t.codigo)) defs.set(t.corpo.readUInt16LE(0), t);
    else if (ANEXO.has(t.codigo)) { const a = t.corpo.readUInt16LE(0); if (!anexos.has(a)) anexos.set(a, []); anexos.get(a).push(t); }
    else if (t.codigo === 8) jpegTables = jpegTables || t;
  }
  const deles = simbolos(swf.tags);
  const mapa = new Map();   // id deles -> id nosso
  const ehFla = (n) => /_fla\./.test(n);
  // id deles que tem nome exportado que o nosso ja tem (fora as linhas do tempo _fla): aponta para o nosso
  const jaTemos = (id) => (deles.porId.get(id) || []).find((n) => !ehFla(n) && nossos.porNome.has(n));
  const copiar = (id, caminho) => {
    if (mapa.has(id)) return mapa.get(id);
    const nomeNosso = jaTemos(id);
    if (nomeNosso) { mapa.set(id, nossos.porNome.get(nomeNosso)); return mapa.get(id); }
    const t = defs.get(id);
    if (!t) throw new Error(`${prefixo}: personagem ${id} nao definido (${caminho})`);
    mapa.set(id, -1);   // em andamento (ciclo nao acontece em SWF valido)
    const refs = refsDe(t);
    const corpo = Buffer.from(t.corpo);
    for (const off of refs) {
      const alvo = corpo.readUInt16LE(off);
      if (alvo === 0xffff) continue;   // bitmap "nenhum"
      const novo = copiar(alvo, `${caminho} > ${alvo}`);
      if (novo < 0) throw new Error(`${prefixo}: ciclo em ${caminho}`);
      corpo.writeUInt16LE(novo, off);
    }
    const novoId = proximo + 1; proximo = novoId;
    if (novoId > 65535) throw new Error('ids de personagem esgotados');
    corpo.writeUInt16LE(novoId, 0);
    if (t.codigo === 6 && !jpegTables) throw new Error(`${prefixo}: DefineBits ${id} sem JPEGTables`);
    novas.push({ codigo: t.codigo, corpo, jpeg: t.codigo === 6 });
    for (const a of anexos.get(id) || []) { const c = Buffer.from(a.corpo); c.writeUInt16LE(novoId, 0); novas.push({ codigo: a.codigo, corpo: c }); }
    mapa.set(id, novoId);
    // nomes exportados deste simbolo que o nosso nao tem
    for (const nome of deles.porId.get(id) || []) {
      if (!ehFla(nome) && (nossos.porNome.has(nome) || copiadosPorNome.has(nome))) continue;
      let q = quadros[nome];
      if (!q && filtro) q = { base: [6, 20, 21, 35, 36, 90].includes(t.codigo) ? 'BitmapData' : 'MovieClip', quadros: {} };
      if (!q) throw new Error(`${nome}: classe sem entrada em quadros.json (rode julho2010_quadros.cjs)`);
      if (Object.values(q.quadros).flat().some((a) => a[0] === 'naoSuportado')) throw new Error(`${nome}: script de quadro nao suportado`);
      const [pac, cl] = ehFla(nome) ? ['rcr_julho_fla', `${prefixo}_${nome.split('.').pop()}`] : ['', nome];
      registro.push([novoId, pac ? `${pac}.${cl}` : cl, { pacote: pac, nome: cl, base: q.base, quadros: q.quadros }]);
      if (!ehFla(nome)) copiadosPorNome.add(nome);
    }
    return novoId;
  };
  let n = 0;
  for (const [nome, id] of deles.porNome) {
    if (ehFla(nome) || nossos.porNome.has(nome) || copiadosPorNome.has(nome)) continue;
    if (filtro && !filtro.has(nome)) continue;
    copiar(id, nome); n++;
  }
  console.log(`${prefixo}: ${n} classe(s) nova(s)`);
}

// arteDe (2026-11-03): item do manifesto que usa a arte de um simbolo original copiado acima. Duplica o
// DefineSprite (mesmas pecas internas, id novo) e publica com o nome do item e os mesmos scripts de quadro.
// Ex.: RCR_TeppanyakiGrill (preco e efeito nossos) com a animacao original de JapaneseStove01.
{
  const arqManifesto = path.join(__dirname, '..', 'recriados', 'manifesto.json');
  const man = JSON.parse(fs.readFileSync(arqManifesto, 'utf8').replace(/^﻿/, ''));
  for (const it of man.itens.filter((x) => x.arteDe)) {
    const orig = registro.find((r) => r[1] === it.arteDe);
    if (!orig) throw new Error(`${it.classe}: arteDe ${it.arteDe} nao esta entre os simbolos copiados de julho`);
    const sprite = novas.find((t) => t.codigo === 39 && t.corpo.readUInt16LE(0) === orig[0]);
    if (!sprite) throw new Error(`${it.classe}: ${it.arteDe} nao e um DefineSprite`);
    const corpo = Buffer.from(sprite.corpo);
    const novoId = proximo + 1; proximo = novoId;
    corpo.writeUInt16LE(novoId, 0);
    novas.push({ codigo: 39, corpo });
    registro.push([novoId, it.classe, { ...orig[2], pacote: '', nome: it.classe }]);
    console.log(`arteDe: ${it.classe} = copia de ${it.arteDe} (id ${novoId})`);
  }
}

// JPEGTables (so pode haver uma) antes dos DefineBits; o nosso nao tem
const tagsNovas = [];
if (novas.some((t) => t.jpeg)) {
  if (nosso.tags.some((t) => t.codigo === 8)) throw new Error('o nosso SWF ja tem JPEGTables: DefineBits copiado ficaria com a tabela errada');
  tagsNovas.push(tag(8, jpegTables.corpo));
}
for (const t of novas) tagsNovas.push(tag(t.codigo, t.corpo));
tagsNovas.push(tag(82, Buffer.concat([u32(1), cstr(''), abc(registro.map((r) => r[2]))])));
tagsNovas.push(tag(76, Buffer.concat([u16(registro.length), ...registro.map(([id, nome]) => Buffer.concat([u16(id), cstr(nome)]))])));

// insere antes do ultimo ShowFrame da linha do tempo principal (como o injetor)
let p = nosso.inicio, corte = -1;
while (p < nosso.raw.length) {
  const cab = nosso.raw.readUInt16LE(p); let len = cab & 0x3f, h = 2;
  if (len === 0x3f) { len = nosso.raw.readUInt32LE(p + 2); h = 6; }
  if ((cab >> 6) === 1) corte = p;
  if ((cab >> 6) === 0) { if (corte < 0) corte = p; break; }
  p += h + len;
}
const corpo = Buffer.concat([nosso.raw.subarray(8, corte), ...tagsNovas, nosso.raw.subarray(corte)]);
const cab = Buffer.from(nosso.raw.subarray(0, 8)); cab.writeUInt32LE(8 + corpo.length, 4);
const final = nosso.comprimido ? Buffer.concat([Buffer.from('CWS'), cab.subarray(3, 8), zlib.deflateSync(corpo)]) : Buffer.concat([cab, corpo]);
fs.mkdirSync(path.dirname(saida), { recursive: true });
fs.writeFileSync(saida, final);
console.log(`copiados ${novas.length} personagem(ns) (ids ${inicioIds}..${proximo}), ${registro.length} classe(s); ${saida}: ${final.length} bytes (antes ${fs.statSync(entrada).size})`);
