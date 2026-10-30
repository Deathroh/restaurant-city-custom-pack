// Injeta itens novos (arte recriada) num SWF de assets do Restaurant City (indoor_asset.swf).
// Para cada item gera: DefineBitsLossless2 (bitmap), DefineShape (retangulo com o bitmap, na escala e
// com a base no lugar certo em relacao a origem do item), DefineSprite (um quadro por angulo:
// 1 = frente, 2 = espelho da frente, 3 = costas, 4 = espelho das costas), uma classe AS3 vazia
// "extends flash.display.MovieClip" (DoABC gerado aqui) e o SymbolClass ligando sprite e classe.
// O jogo acha a arte com getDefinitionByName(className) e usa totalFrames como numero de rotacoes.
//
// Uso: node injetar_itens.cjs <manifesto.json>
// Manifesto: { "entrada": "...swf", "saida": "...swf", "itens": [
//   { "classe": "RCR_X", "frente": "a.png", "costas": "b.png"?, "quadros": 1|2|4,
//     "escala": 0.75, "base": 31 } ] }
//   escala = pixels do jogo por pixel da imagem; base = px da base da arte abaixo da origem.
'use strict';
const fs = require('fs');
const path = require('path');
const zlib = require('zlib');

// ---------- PNG (RGBA 8 bits, como o System.Drawing salva) ----------
function lerPng(arquivo) {
  const buf = fs.readFileSync(arquivo);
  if (buf.readUInt32BE(0) !== 0x89504e47) throw new Error(`nao e PNG: ${arquivo}`);
  let p = 8, largura, altura, prof, tipo, entrelace;
  const idat = [];
  while (p < buf.length) {
    const len = buf.readUInt32BE(p), nome = buf.toString('latin1', p + 4, p + 8), dados = buf.subarray(p + 8, p + 8 + len);
    if (nome === 'IHDR') { largura = dados.readUInt32BE(0); altura = dados.readUInt32BE(4); prof = dados[8]; tipo = dados[9]; entrelace = dados[12]; }
    else if (nome === 'IDAT') idat.push(dados);
    else if (nome === 'IEND') break;
    p += 12 + len;
  }
  if (prof !== 8 || (tipo !== 6 && tipo !== 2) || entrelace) throw new Error(`PNG nao suportado (prof ${prof}, tipo ${tipo}): rode preparar_imagem.ps1 antes`);
  const bpp = tipo === 6 ? 4 : 3, linha = largura * bpp;
  const cru = zlib.inflateSync(Buffer.concat(idat));
  const out = Buffer.alloc(altura * linha);
  for (let y = 0; y < altura; y++) {
    const f = cru[y * (linha + 1)], src = y * (linha + 1) + 1, dst = y * linha;
    for (let x = 0; x < linha; x++) {
      const a = x >= bpp ? out[dst + x - bpp] : 0, b = y > 0 ? out[dst - linha + x] : 0, c = x >= bpp && y > 0 ? out[dst - linha + x - bpp] : 0;
      let v = cru[src + x];
      if (f === 1) v += a; else if (f === 2) v += b; else if (f === 3) v += (a + b) >> 1;
      else if (f === 4) { const pa = Math.abs(b - c), pb = Math.abs(a - c), pc = Math.abs(a + b - 2 * c); v += pa <= pb && pa <= pc ? a : pb <= pc ? b : c; }
      out[dst + x] = v & 0xff;
    }
  }
  // RGBA -> ARGB pre-multiplicado (formato do DefineBitsLossless2)
  const argb = Buffer.alloc(largura * altura * 4);
  for (let i = 0, j = 0; i < out.length; i += bpp, j += 4) {
    const al = bpp === 4 ? out[i + 3] : 255;
    argb[j] = al; argb[j + 1] = (out[i] * al + 127) / 255 | 0; argb[j + 2] = (out[i + 1] * al + 127) / 255 | 0; argb[j + 3] = (out[i + 2] * al + 127) / 255 | 0;
  }
  return { largura, altura, argb };
}

// ---------- escrita de bits (RECT, MATRIX, registros de forma) ----------
class Bits {
  constructor() { this.bytes = []; this.atual = 0; this.n = 0; }
  u(valor, nbits) { for (let i = nbits - 1; i >= 0; i--) { this.atual = (this.atual << 1) | ((valor >>> i) & 1); if (++this.n === 8) { this.bytes.push(this.atual); this.atual = 0; this.n = 0; } } }
  s(valor, nbits) { this.u(valor < 0 ? (valor + 2 ** nbits) : valor, nbits); }
  alinhar() { if (this.n) { this.u(0, 8 - this.n); } }
  buffer() { this.alinhar(); return Buffer.from(this.bytes); }
}
const bitsS = (...v) => Math.max(1, ...v.map((x) => (x === 0 ? 1 : Math.floor(Math.log2(Math.abs(x))) + 2)));
function rect(b, x0, x1, y0, y1) { const n = bitsS(x0, x1, y0, y1); b.u(n, 5); b.s(x0, n); b.s(x1, n); b.s(y0, n); b.s(y1, n); }
function matriz(b, sx, sy, tx, ty) {
  if (sx !== 1 || sy !== 1) { const fx = Math.round(sx * 65536), fy = Math.round(sy * 65536), n = bitsS(fx, fy); b.u(1, 1); b.u(n, 5); b.s(fx, n); b.s(fy, n); } else b.u(0, 1);
  b.u(0, 1);
  const n = bitsS(tx, ty); b.u(n, 5); b.s(tx, n); b.s(ty, n);
}

// ---------- tags SWF ----------
const u16 = (v) => { const b = Buffer.alloc(2); b.writeUInt16LE(v); return b; };
const u32 = (v) => { const b = Buffer.alloc(4); b.writeUInt32LE(v); return b; };
const cstr = (s) => Buffer.concat([Buffer.from(s, 'utf8'), Buffer.from([0])]);
function tag(codigo, corpo) { return Buffer.concat([u16((codigo << 6) | 0x3f), u32(corpo.length), corpo]); }

function defineBitmap(id, img) {
  return tag(36, Buffer.concat([u16(id), Buffer.from([5]), u16(img.largura), u16(img.altura), zlib.deflateSync(img.argb)]));
}
// retangulo (em twips) preenchido com o bitmap recortado e suavizado; escala em twips por pixel da imagem
function defineShape(id, bitmapId, img, escalaTwips, x0, y0) {
  const w = Math.round(img.largura * escalaTwips), h = Math.round(img.altura * escalaTwips);
  const b = new Bits();
  rect(b, x0, x0 + w, y0, y0 + h);
  b.alinhar();
  b.u(1, 8);                       // 1 estilo de preenchimento
  b.u(0x41, 8); b.u(bitmapId & 0xff, 8); b.u(bitmapId >> 8, 8);   // clipped bitmap, suavizado
  matriz(b, escalaTwips, escalaTwips, x0, y0); b.alinhar();
  b.u(0, 8);                       // 0 estilos de linha
  b.u(1, 4); b.u(0, 4);            // NumFillBits=1, NumLineBits=0
  // StyleChange: moveTo(x0,y0) + FillStyle1 = 1 (contorno no sentido horario, interior a direita)
  b.u(0, 1); b.u(0, 1); b.u(0, 1); b.u(1, 1); b.u(0, 1); b.u(1, 1);
  const nm = bitsS(x0, y0); b.u(nm, 5); b.s(x0, nm); b.s(y0, nm);
  b.u(1, 1);
  for (const [dx, dy] of [[w, 0], [0, h], [-w, 0], [0, -h]]) {
    const n = bitsS(dx, dy); b.u(1, 1); b.u(1, 1); b.u(n - 2, 4); b.u(1, 1); b.s(dx, n); b.s(dy, n);
  }
  b.u(0, 6);                       // EndShapeRecord
  return tag(2, Buffer.concat([u16(id), b.buffer()]));
}
function placeObject(charId, espelhar, nome) {
  const b = new Bits(); matriz(b, espelhar ? -1 : 1, 1, 0, 0);
  if (nome) return tag(26, Buffer.concat([Buffer.from([0x26]), u16(1), u16(charId), b.buffer(), cstr(nome)]));   // + nome da instancia
  return tag(26, Buffer.concat([Buffer.from([0x06]), u16(1), u16(charId), b.buffer()]));
}
function placeComProfundidade(charId, espelhar, nome, prof, update) {
  const b = new Bits(); matriz(b, espelhar ? -1 : 1, 1, 0, 0);
  if (update) {
    return tag(26, Buffer.concat([Buffer.from([0x05]), u16(prof), b.buffer()]));
  }
  if (nome) {
    return tag(26, Buffer.concat([Buffer.from([0x26]), u16(prof), u16(charId), b.buffer(), cstr(nome)]));
  }
  return tag(26, Buffer.concat([Buffer.from([0x06]), u16(prof), u16(charId), b.buffer()]));
}
function definePortaAnimada(id, listaImagens, escalaTwips, x0, y0, novoId, novas) {
  const shapes = listaImagens.map((img) => {
    const bmp = novoId(), shp = novoId();
    novas.push(defineBitmap(bmp, img), defineShape(shp, bmp, img, escalaTwips, x0, y0));
    return shp;
  });
  // linha do tempo como a da porta original (Door): closed (para) -> opening (imagens 2..n) -> open (ultima
  // imagem, para) -> closing (imagens de volta) -> volta ao quadro 1 closed (para). O jogo da gotoAndPlay
  // "opening" quando um cliente chega e "closing" depois do tempo; sem as paradas a porta abria sem parar.
  const n = shapes.length;
  const seq = [[0, 'closed']];
  for (let i = 1; i < n - 1; i++) seq.push([i, i === 1 ? 'opening' : null]);
  seq.push([n - 1, 'open']);
  for (let i = n - 2; i >= 1; i--) seq.push([i, i === n - 2 ? 'closing' : null]);
  const partes = [];
  seq.forEach(([img, rotulo], f) => {
    if (rotulo) partes.push(tag(43, cstr(rotulo)));
    if (f > 0) partes.push(tag(28, u16(1))); // RemoveObject2 depth 1
    partes.push(placeComProfundidade(shapes[img], false, null, 1, false));
    partes.push(tag(1, Buffer.alloc(0))); // ShowFrame
  });
  partes.push(Buffer.from([0, 0])); // End
  definePortaAnimada.paradas = [0, n - 1];   // quadros (base 0) closed e open
  return tag(39, Buffer.concat([u16(id), u16(seq.length), ...partes]));
}
function defineSpritePorta(id, doorAnimId, maskId) {
  const partes = [];
  // Frame 1
  partes.push(placeComProfundidade(maskId, false, 'mc_mask', 1, false));
  partes.push(placeComProfundidade(doorAnimId, false, 'mc_content', 3, false));
  partes.push(tag(1, Buffer.alloc(0)));
  // Frame 2
  partes.push(placeComProfundidade(maskId, true, null, 1, true));
  partes.push(placeComProfundidade(doorAnimId, true, null, 3, true));
  partes.push(tag(1, Buffer.alloc(0)));
  partes.push(Buffer.from([0, 0]));
  return tag(39, Buffer.concat([u16(id), u16(2), ...partes]));
}
// coloca um personagem numa profundidade com translacao (twips)
function placeEm(profundidade, charId, tx, ty) {
  const b = new Bits(); matriz(b, 1, 1, Math.round(tx), Math.round(ty));
  return tag(26, Buffer.concat([Buffer.from([0x06]), u16(profundidade), u16(charId), b.buffer()]));
}
// defineEstados: cria linha do tempo de estados (idle, cooking, done)
function defineEstados(id, conteudoId, rotulos, it, animOverride) {
  const ehFogao = (it && (it.tipo === 'kitchen' || it.grupo === 'Kitchen Appliance')) || rotulos.includes('done');
  const partes = conteudoId == null ? [] : [placeObject(conteudoId, false)];
  for (let i = 0; i < rotulos.length; i++) {
    const r = rotulos[i];
    partes.push(tag(43, cstr(r)));
    if (ehFogao) {
      if (r === 'idle') {
        if (i > 0) partes.push(tag(28, u16(2)));
      } else if (r === 'cooking') {
        if (i > 0) partes.push(tag(28, u16(2)));
        const animId = animOverride || ((it && it.panelaId) ? it.panelaId : ((it && (it.panela || it.classe === 'RCR_TeppanyakiGrill' || it.animCooking === 'panela')) ? 1679 : 1585));
        const txCook = (it && it.txCooking !== undefined) ? it.txCooking : 0;
        const tyCook = (it && it.tyCooking !== undefined) ? it.tyCooking : ((animOverride || it.panela || it.classe === 'RCR_TeppanyakiGrill') ? -240 : -200);
        partes.push(placeEm(2, animId, txCook, tyCook));
      } else if (r === 'done') {
        if (i > 0) partes.push(tag(28, u16(2)));
        partes.push(placeEm(2, 1587, 0, -200));
      }
    }
    partes.push(tag(1, Buffer.alloc(0)));
  }
  partes.push(Buffer.from([0, 0]));
  return tag(39, Buffer.concat([u16(id), u16(rotulos.length), ...partes]));
}

// Item em camadas (comp.json): camadas fixas ({imagem,x,y}) e moveis ({imagem,trajeto:[[x,y]...]})
// em pixels da imagem composta. A cada quadro as camadas moveis sao reordenadas pela base na tela
// (quem esta mais embaixo e desenhado por cima). Devolve o id do sprite animado.
function defineComposicao(novoId, comp, dirComp, escala, base, novas) {
  const twips = escala * 20;
  const cache = {};
  const shapeDe = (arq) => {
    if (cache[arq]) return cache[arq];
    const img = lerPng(path.join(dirComp, arq));
    const bmp = novoId(), shp = novoId();
    novas.push(defineBitmap(bmp, img), defineShape(shp, bmp, img, twips, 0, 0));
    return (cache[arq] = { shp, img });
  };
  const pos = (x, y) => [(x - comp.largura / 2) * twips, (y - comp.altura) * twips + base * 20];
  const fixas = [], moveis = [];
  comp.camadas.forEach((c, i) => (c.trajeto ? moveis : fixas).push({ ...c, ordem: i, s: shapeDe(c.imagem) }));
  const ultimaFixaAntes = Math.max(...fixas.filter((f) => f.ordem < Math.min(...moveis.map((m) => m.ordem))).map((f) => f.ordem), -1);
  const partes = [];
  for (let q = 0; q < comp.quadros; q++) {
    if (q === 0) {
      for (const f of fixas) {
        const prof = f.ordem <= ultimaFixaAntes ? 1 + f.ordem : 500 + f.ordem;   // fundo embaixo, frente por cima dos moveis
        const [tx, ty] = pos(f.x, f.y);
        partes.push(placeEm(prof, f.s.shp, tx, ty));
      }
    } else {
      for (let k = 0; k < moveis.length; k++) partes.push(tag(28, u16(100 + k)));   // tira os moveis do quadro anterior
    }
    const ord = moveis.map((m) => { const [x, y] = m.trajeto[q % m.trajeto.length]; return { m, x, y, chao: y + m.s.img.altura }; })
      .sort((a, b) => a.chao - b.chao);
    ord.forEach((o, k) => { const [tx, ty] = pos(o.x, o.y); partes.push(placeEm(100 + k, o.m.s.shp, tx, ty)); });
    partes.push(tag(1, Buffer.alloc(0)));
  }
  partes.push(Buffer.from([0, 0]));
  const id = novoId();
  novas.push(tag(39, Buffer.concat([u16(id), u16(comp.quadros), ...partes])));
  return id;
}
// quadros: [{ shape, espelhar, manter, fixoAtivo, espelharFixo, fixoReverseAtivo, espelharReverse }]
// fixo (mc_content) no depth 2 e fixoReverse (mc_contentReverse) no depth 3
function defineSprite(id, quadros, fixo, fixoReverse) {
  const partes = [];
  quadros.forEach((q, i) => {
    if (!q.manter) {
      if (i > 0) partes.push(tag(28, u16(1)));            // RemoveObject2 profundidade 1
      partes.push(placeObject(q.shape, q.espelhar, q.nome));
    }
    if (fixo) {
      const b = new Bits();
      if (q.fixoAtivo !== undefined) {
        if (q.fixoAtivo) matriz(b, q.espelharFixo ? -1 : 1, 1, 0, 0);
        else matriz(b, 1, 1, 0, 60000);   // move para fora da tela
      } else {
        const esp = !!q.espelharFixo;
        matriz(b, esp ? -1 : 1, 1, 0, 0);
      }
      if (i === 0) partes.push(tag(26, Buffer.concat([Buffer.from([0x26]), u16(2), u16(fixo.charId), b.buffer(), cstr(fixo.nome)])));
      else partes.push(tag(26, Buffer.concat([Buffer.from([0x05]), u16(2), b.buffer()])));
    }
    if (fixoReverse) {
      const b = new Bits();
      if (q.fixoReverseAtivo) matriz(b, q.espelharReverse ? -1 : 1, 1, 0, 0);
      else matriz(b, 1, 1, 0, 60000);     // move para fora da tela
      if (i === 0) partes.push(tag(26, Buffer.concat([Buffer.from([0x26]), u16(3), u16(fixoReverse.charId), b.buffer(), cstr(fixoReverse.nome)])));
      else partes.push(tag(26, Buffer.concat([Buffer.from([0x05]), u16(3), b.buffer()])));
    }
    partes.push(tag(1, Buffer.alloc(0)));                 // ShowFrame
  });
  partes.push(Buffer.from([0, 0]));                       // End
  return tag(39, Buffer.concat([u16(id), u16(quadros.length), ...partes]));
}

// ---------- ABC: uma classe dinamica "extends MovieClip" por item ----------
// classes: nomes (string) ou { nome, paradas: N } -- com paradas, o construtor registra
// addFrameScript(0..N-1, frameParar) e frameParar() da stop(): cada estado rotulado fica parado
// no proprio quadro (como as linhas do tempo internas dos fogoes originais, que o game.swf
// le com currentLabel == "idle").
function abc(classes) {
  classes = classes.map((c) => (typeof c === 'string' ? { nome: c, paradas: 0 } : c));
  const nomes = classes.map((c) => c.nome);
  const u30 = (v) => { const o = []; do { let b = v & 0x7f; v >>>= 7; if (v) b |= 0x80; o.push(b); } while (v); return Buffer.from(o); };
  const strings = ['', 'flash.display', 'flash.events', 'Object', 'EventDispatcher', 'DisplayObject', 'InteractiveObject', 'DisplayObjectContainer', 'Sprite', 'MovieClip', 'addFrameScript', 'stop', 'frameParar', ...nomes];
  const S = (s) => strings.indexOf(s) + 1;
  // namespaces: 1 = pacote "", 2 = flash.display, 3 = flash.events
  const ns = [[0x16, S('')], [0x16, S('flash.display')], [0x16, S('flash.events')]];
  const mn = [];
  const Q = (nsi, nome) => { mn.push([nsi, S(nome)]); return mn.length; };
  const mObject = Q(1, 'Object'), mED = Q(3, 'EventDispatcher'), mDO = Q(2, 'DisplayObject'), mIO = Q(2, 'InteractiveObject');
  const mDOC = Q(2, 'DisplayObjectContainer'), mSprite = Q(2, 'Sprite'), mMC = Q(2, 'MovieClip');
  const mAdd = Q(1, 'addFrameScript'), mStop = Q(1, 'stop'), mParar = Q(1, 'frameParar');
  const mClasses = nomes.map((c) => Q(1, c));
  // metodos: por classe iinit, cinit e (se tiver paradas) frameParar; por ultimo o init do script
  const met = classes.map(() => ({}));
  let nMetodos = 0;
  classes.forEach((c, k) => { met[k].iinit = nMetodos++; met[k].cinit = nMetodos++; if (c.paradas) met[k].parar = nMetodos++; });
  const scriptInit = nMetodos++;
  const partes = [Buffer.from([16, 0, 46, 0])];                         // minor 16, major 46
  partes.push(u30(0), u30(0), u30(0));                                 // int, uint, double
  partes.push(u30(strings.length + 1));
  for (const s of strings) { const b = Buffer.from(s, 'utf8'); partes.push(u30(b.length), b); }
  partes.push(u30(ns.length + 1)); for (const [k, n] of ns) partes.push(Buffer.from([k]), u30(n));
  partes.push(u30(0));                                                 // ns_set
  partes.push(u30(mn.length + 1)); for (const [n, s] of mn) partes.push(Buffer.from([0x07]), u30(n), u30(s));
  const nClasses = classes.length;
  partes.push(u30(nMetodos)); for (let i = 0; i < nMetodos; i++) partes.push(u30(0), u30(0), u30(0), Buffer.from([0]));
  partes.push(u30(0));                                                 // metadata
  partes.push(u30(nClasses));
  classes.forEach((c, k) => {                                          // instance_info (dinamica)
    partes.push(u30(mClasses[k]), u30(mMC), Buffer.from([0]), u30(0), u30(met[k].iinit));
    if (c.paradas) partes.push(u30(1), u30(mParar), Buffer.from([0x01]), u30(0), u30(met[k].parar));   // Trait_Method frameParar
    else partes.push(u30(0));
  });
  classes.forEach((c, k) => partes.push(u30(met[k].cinit), u30(0)));                                   // class_info
  partes.push(u30(1), u30(scriptInit), u30(nClasses));                                                 // script: init + traits
  classes.forEach((c, k) => partes.push(u30(mClasses[k]), Buffer.from([4]), u30(k + 1), u30(k)));     // Trait_Class
  // corpos
  const corpo = (metodo, maxPilha, locais, ini, max, codigo) => Buffer.concat([u30(metodo), u30(maxPilha), u30(locais), u30(ini), u30(max), u30(codigo.length), codigo, u30(0), u30(0)]);
  partes.push(u30(nMetodos));
  classes.forEach((c, k) => {
    if (c.paradas) {
      // super(); this.addFrameScript(0, this.frameParar, 1, this.frameParar, ...)
      // paradas: N (para em todos os quadros 0..N-1) ou lista de quadros (base 0) onde parar
      const lista = Array.isArray(c.paradas) ? c.paradas : Array.from({ length: c.paradas }, (_, q) => q);
      const cod = [0xd0, 0x30, 0xd0, 0x49, 0x00, 0xd0];
      for (const q of lista) cod.push(0x25, ...u30(q), 0xd0, 0x66, ...u30(mParar));          // pushshort q; getlocal0; getproperty
      cod.push(0x4f, ...u30(mAdd), ...u30(2 * lista.length), 0x47);                          // callpropvoid addFrameScript; returnvoid
      partes.push(corpo(met[k].iinit, 1 + 2 * lista.length, 1, 9, 10, Buffer.from(cod)));
      partes.push(corpo(met[k].parar, 1, 1, 9, 10, Buffer.from([0xd0, 0x30, 0xd0, 0x4f, ...u30(mStop), 0x00, 0x47])));   // stop()
    } else {
      partes.push(corpo(met[k].iinit, 1, 1, 9, 10, Buffer.from([0xd0, 0x30, 0xd0, 0x49, 0x00, 0x47])));   // iinit: super()
    }
    partes.push(corpo(met[k].cinit, 1, 1, 8, 9, Buffer.from([0xd0, 0x30, 0x47])));                  // cinit
  });
  // script init: mesma cadeia de escopo que o Flash gera para classes de simbolo MovieClip
  const cod = [0xd0, 0x30];
  const getlex = (m) => [0x60, ...u30(m)];
  classes.forEach((c, k) => {
    cod.push(0x65, 0x00);                                                    // getscopeobject 0
    for (const m of [mObject, mED, mDO, mIO, mDOC, mSprite, mMC]) cod.push(...getlex(m), 0x30);
    cod.push(...getlex(mMC), 0x58, ...u30(k));                              // newclass k
    for (let i = 0; i < 7; i++) cod.push(0x1d);                             // popscope x7
    cod.push(0x68, ...u30(mClasses[k]));                                    // initproperty
  });
  cod.push(0x47);
  partes.push(corpo(scriptInit, 2, 1, 1, 9, Buffer.from(cod)));
  return Buffer.concat(partes);
}

// ---------- SWF ----------
const DEFINE = new Set([2, 22, 32, 83, 39, 6, 21, 35, 36, 20, 90, 10, 48, 75, 91, 11, 33, 37, 7, 34, 46, 84, 14, 60, 87]);
function abrirSwf(arquivo) {
  const bruto = fs.readFileSync(arquivo);
  const sig = bruto.toString('latin1', 0, 3);
  const raw = sig === 'CWS' ? Buffer.concat([Buffer.from('FWS'), bruto.subarray(3, 8), zlib.inflateSync(bruto.subarray(8))]) : bruto;
  const nbits = raw[8] >> 3, inicio = 8 + Math.ceil((5 + nbits * 4) / 8) + 4;
  const tags = []; let p = inicio, maxId = 0;
  while (p < raw.length) {
    const cab = raw.readUInt16LE(p); let len = cab & 0x3f, h = 2;
    if (len === 0x3f) { len = raw.readUInt32LE(p + 2); h = 6; }
    const codigo = cab >> 6;
    tags.push({ codigo, ini: p, fim: p + h + len });
    if (DEFINE.has(codigo)) maxId = Math.max(maxId, raw.readUInt16LE(p + h));
    p += h + len;
    if (codigo === 0) break;
  }
  return { raw, inicio, tags, maxId, comprimido: sig === 'CWS' };
}

function main() {
  // o PowerShell 5.1 grava UTF-8 com BOM
  const manifesto = JSON.parse(fs.readFileSync(process.argv[2], 'utf8').replace(/^﻿/, ''));
  const dirBase = path.dirname(path.resolve(process.argv[2]));
  const R = (f) => path.resolve(dirBase, f);
  const entrada = R(manifesto.entrada), saida = R(manifesto.saida);
  const swf = abrirSwf(entrada);
  const existentes = new Map();
  // nomes ja exportados -> id (nao duplicar classe; achar simbolos oficiais como ChefFloor)
  for (const t of swf.tags) if (t.codigo === 76) {
    const h = (swf.raw.readUInt16LE(t.ini) & 0x3f) === 0x3f ? 6 : 2;
    let q = t.ini + h; const n = swf.raw.readUInt16LE(q); q += 2;
    for (let i = 0; i < n; i++) { const sid = swf.raw.readUInt16LE(q); q += 2; let e = q; while (swf.raw[e]) e++; existentes.set(swf.raw.toString('utf8', q, e), sid); q = e + 1; }
  }
  let id = swf.maxId;
  const novas = [], simbolos = [];
  for (const it of manifesto.itens) {
    if (existentes.has(it.classe)) throw new Error(`classe ja existe no SWF: ${it.classe}`);
    const base = it.base ?? 31, repetir = it.repetir ?? 5;
    if (it.animPorta || it.porta) {
      const dirAnim = R(it.animPorta || `${it.classe}/anim`);
      const arquivosAnim = fs.readdirSync(dirAnim).filter((f) => f.endsWith('.png')).sort();
      const listaAnim = arquivosAnim.map((f) => lerPng(path.join(dirAnim, f)));
      const alturaAlvo = it.altura ?? 135;
      const escala = alturaAlvo / listaAnim[0].altura;
      const twips = escala * 20;
      const x0 = Math.round((it.deslocX ?? 0) * 20);
      const y0 = Math.round((it.base ?? base) * 20 - listaAnim[0].altura * twips);

      const doorAnimId = ++id;
      novas.push(definePortaAnimada(doorAnimId, listaAnim, twips, x0, y0, () => ++id, novas));
      simbolos.push([doorAnimId, `${it.classe}_Anim`, definePortaAnimada.paradas]);

      // mascaraPorta (png do tamanho dos quadros): mascara propria do vao, exportada como <classe>_Mascara
      // (o jogo cria uma copia dela pelo nome da classe para apagar a parede). Sem ela, a DoorWayMask (914) de 1 bloco.
      let mascaraId = 914;
      if (it.mascaraPorta) {
        const img = lerPng(R(it.mascaraPorta));
        const bmp = ++id, shp = ++id;
        mascaraId = ++id;
        novas.push(defineBitmap(bmp, img), defineShape(shp, bmp, img, twips, x0, y0), defineSprite(mascaraId, [{ shape: shp, espelhar: false }]));
        simbolos.push([mascaraId, `${it.classe}_Mascara`, 0]);
      }
      const spr = ++id;
      novas.push(defineSpritePorta(spr, doorAnimId, mascaraId));
      simbolos.push([spr, it.classe, 0]);
      console.log(`${it.classe}: porta animada criada com sucesso (anim ${doorAnimId}, sprite ${spr}, altura ${alturaAlvo})`);
      continue;
    }
    // Vistas: { nome: { imagens: [png...], altura?: px do jogo, escala?: px do jogo por px da imagem } }.
    // Formato antigo (frente/costas/quadros) continua aceito.
    const vistas = it.vistas ?? Object.fromEntries([['frente', it.frente], ['costas', it.costas]].filter(([, v]) => v).map(([k, v]) => [k, { imagens: [v] }]));
    const angulos = it.angulos ?? (() => {
      const nq = it.quadros ?? 2, costas = vistas.costas ? 'costas' : 'frente';
      return [{ vista: 'frente' }, { vista: 'frente', espelhar: true }, { vista: costas }, { vista: costas, espelhar: true }].slice(0, nq);
    })();
    // cada vista vira um shape (imagem unica) ou um sprite interno animado em loop (varias imagens)
    const conteudo = {};
    for (const [nome, v] of Object.entries(vistas)) {
      if (v.composicao) {
        const arqComp = R(v.composicao);
        const comp = JSON.parse(fs.readFileSync(arqComp, 'utf8').replace(/^﻿/, ''));
        const escala = v.altura ? v.altura / comp.altura : (v.escala ?? it.escala ?? 0.7);
        conteudo[nome] = defineComposicao(() => ++id, comp, path.dirname(arqComp), escala, base, novas);
        continue;
      }
      const isParede = it.grupo === 'Wall Decoration' || it.grupo === 'Wallpaper' || (typeof it.tipo === 'string' && (it.tipo.includes('wallDecorationItem') || it.tipo.includes('wallpaperItem'))) || !!it.parede;
      const lista = (Array.isArray(v) ? v : v.imagens).map((f) => lerPng(R(f)));
      const shapes = lista.map((img) => {
        const alturaAlvo = v.altura ?? it.altura;
        const escala = alturaAlvo ? alturaAlvo / img.altura : (v.escala ?? it.escala ?? 0.7);
        const bmp = ++id, shp = ++id, twips = escala * 20;
        // deslocX (px do jogo): itens 2x1/1x2 tem o losango do piso fora do centro da origem (+20 ou -20)
        // itens de parede (Wall Decoration): origem x fica no canto de apoio (x0 = 0), para nao invadir a outra parede nem sumir
        const x0 = isParede
          ? Math.round((v.deslocX ?? it.deslocX ?? 0) * 20)
          : -Math.round(img.largura * twips / 2) + Math.round((v.deslocX ?? it.deslocX ?? 0) * 20);
        // base por vista (ex. as costas de uma folha desenhada um pouco maiores que a frente)
        const y0 = Math.round((v.base ?? base) * 20 - img.altura * twips);
        novas.push(defineBitmap(bmp, img), defineShape(shp, bmp, img, twips, x0, y0));
        return shp;
      });
      if (shapes.length === 1) { conteudo[nome] = shapes[0]; continue; }
      const anim = ++id;
      const quadrosAnim = shapes.flatMap((s) => Array.from({ length: repetir }, (_, k) => ({ shape: s, espelhar: false, manter: k > 0 })));
      novas.push(defineSprite(anim, quadrosAnim));
      conteudo[nome] = anim;
    }
    // "filhos": [{ vista, nome }] -> um quadro so, com cada vista como peca nomeada numa profundidade propria.
    // O codigo do jogo liga a peca certa (visible) e espelha pelo scaleX, sem trocar de quadro. Usado no ator do
    // Monster Robot (2026-10-28): no Ruffle, gotoAndStop entre quadros de angulo as vezes nao trocava o desenho.
    if (it.filhos) {
      const spr = ++id;
      const partes = it.filhos.map((f, i) => {
        if (!(f.vista in conteudo)) throw new Error(`${it.classe}: vista "${f.vista}" nao definida`);
        return placeComProfundidade(conteudo[f.vista], false, f.nome, i + 1, false);
      });
      novas.push(tag(39, Buffer.concat([u16(spr), u16(1), ...partes, tag(1, Buffer.alloc(0)), Buffer.from([0, 0])])));
      simbolos.push([spr, it.classe, 0]);
      console.log(`${it.classe}: sprite ${spr}, 1 quadro com pecas [${it.filhos.map((f) => f.nome).join(', ')}], base ${base}`);
      continue;
    }
    // "estados": ["idle","cooking","done"] -> uma linha do tempo rotulada (com os efeitos de cozimento),
    // colocada UMA vez no quadro 1 com o nome de instancia mc_content (o game.swf troca o estado com
    // gotoAndPlay(rotulo)). Ela fica fixa enquanto o desenho de cada angulo troca por baixo: se fosse
    // recriada a cada angulo, o giro travava ao voltar do ultimo quadro para o 1 (2026-10-27).
    let fixo = null, fixoReverse = null;
    if (it.estados) {
      if (it.classe === 'RCR_TeppanyakiGrill' || it.quatroLadosPanela) {
        const estUp = ++id;
        novas.push(defineEstados(estUp, null, it.estados, it, 1679));
        simbolos.push([estUp, `${it.classe}_Estados`, it.estados.length]);
        fixo = { charId: estUp, nome: 'mc_content' };

        const estDown = ++id;
        novas.push(defineEstados(estDown, null, it.estados, it, 1329));
        simbolos.push([estDown, `${it.classe}_EstadosReverse`, it.estados.length]);
        fixoReverse = { charId: estDown, nome: 'mc_contentReverse' };
      } else {
        const est = ++id;
        novas.push(defineEstados(est, null, it.estados, it));
        simbolos.push([est, `${it.classe}_Estados`, it.estados.length]);
        fixo = { charId: est, nome: 'mc_content' };
      }
    }
    const seq = angulos.map((a) => {
      if (!(a.vista in conteudo)) throw new Error(`${it.classe}: vista "${a.vista}" nao definida`);
      return {
        shape: conteudo[a.vista],
        espelhar: !!a.espelhar,
        fixoAtivo: a.fixoAtivo,
        espelharFixo: a.espelharFixo ?? a.espelharEstados ?? !!a.espelhar,
        fixoReverseAtivo: a.fixoReverseAtivo,
        espelharReverse: a.espelharReverse ?? false
      };
    });
    const spr = ++id;
    if (it.angulosIsolados) {
      // Cada angulo numa peca propria (sprite embrulho) e numa profundidade propria (10, 11, ...). Ao girar, o jogo
      // troca de quadro com nextFrame/gotoAndStop(1); no Ruffle, a troca entre quadros que reusam a mesma peca na
      // mesma profundidade as vezes nao acontecia (2026-10-29: o Monster Robot ficava de costas ao voltar do 4o
      // para o 1o angulo). Nao combina com "estados" (fixo).
      if (fixo) throw new Error(`${it.classe}: angulosIsolados nao funciona junto com estados`);
      const partes = [];
      seq.forEach((q, i) => {
        const emb = ++id;
        novas.push(defineSprite(emb, [{ shape: q.shape, espelhar: q.espelhar }]));
        if (i > 0) partes.push(tag(28, u16(10 + i - 1)));          // RemoveObject2 do angulo anterior
        partes.push(placeComProfundidade(emb, false, null, 10 + i, false));
        partes.push(tag(1, Buffer.alloc(0)));                       // ShowFrame
      });
      partes.push(Buffer.from([0, 0]));
      novas.push(tag(39, Buffer.concat([u16(spr), u16(seq.length), ...partes])));
    } else novas.push(defineSprite(spr, seq, fixo, fixoReverse));
    if (it.pisoChef) {
      // como os fogoes oficiais (Stove01 etc.): raiz com sub0 = o fogao (classe <classe>Rotations) e
      // sub1 = ChefFloor (tapete cinza com o prato, onde o chef fica) em (40,20), o bloco da frente.
      // O createRoomItems do jogo transforma cada subN num item filho e gira o tapete junto.
      const chefFloor = existentes.get('ChefFloor');
      if (chefFloor === undefined) throw new Error('ChefFloor nao encontrado no SWF de entrada');
      simbolos.push([spr, `${it.classe}Rotations`, 0]);
      const raiz = ++id, b = new Bits(); matriz(b, 1, 1, 40 * 20, 20 * 20);
      novas.push(tag(39, Buffer.concat([u16(raiz), u16(1), placeComProfundidade(spr, false, 'sub0', 1, false),
        tag(26, Buffer.concat([Buffer.from([0x26]), u16(2), u16(chefFloor), b.buffer(), cstr('sub1')])),
        tag(1, Buffer.alloc(0)), Buffer.from([0, 0])])));
      simbolos.push([raiz, it.classe, 0]);
    } else simbolos.push([spr, it.classe, 0]);
    const desc = Object.entries(vistas).map(([n, v]) => `${n}:${v.composicao ? 'camadas' : (Array.isArray(v) ? v : v.imagens).length}`).join(' ');
    console.log(`${it.classe}: sprite ${spr}, ${seq.length} angulo(s) [${angulos.map((a) => a.vista + (a.espelhar ? '*' : '')).join(', ')}], vistas ${desc}, base ${base}`);
  }
  if (id > 65535) throw new Error('ids de personagem esgotados');
  novas.push(tag(82, Buffer.concat([u32(1), cstr(''), abc(simbolos.map(([, nome, paradas]) => ({ nome, paradas })))])));
  novas.push(tag(76, Buffer.concat([u16(simbolos.length), ...simbolos.map(([sid, nome]) => Buffer.concat([u16(sid), cstr(nome)]))])));
  // insere antes do ultimo ShowFrame da linha do tempo principal
  const ultimoShow = [...swf.tags].reverse().find((t) => t.codigo === 1);
  const corte = ultimoShow ? ultimoShow.ini : swf.tags[swf.tags.length - 1].ini;
  const corpo = Buffer.concat([swf.raw.subarray(8, corte), ...novas, swf.raw.subarray(corte)]);
  const total = 8 + corpo.length;
  const cab = Buffer.from(swf.raw.subarray(0, 8)); cab.writeUInt32LE(total, 4);
  const final = swf.comprimido ? Buffer.concat([Buffer.from('CWS'), cab.subarray(3, 8), zlib.deflateSync(corpo)]) : Buffer.concat([cab, corpo]);
  fs.writeFileSync(saida, final);
  console.log(`gravado ${saida}: ${simbolos.length} item(ns), ${final.length} bytes (antes ${fs.statSync(entrada).size})`);
}
main();
