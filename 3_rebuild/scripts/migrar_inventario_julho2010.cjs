// Etapa 4 da raspagem: no dev.db do servidor, troca os ids das recriacoes RCR pelos ids dos originais de
// julho/2010 (recriados/julho2010/migracao_ids.json, de trocar_por_originais_julho2010.cjs). Quem tinha a
// recriacao passa a ter o original, no inventario, no salao, no piso, nas cartas e na garantia de troca.
//   OwnedItem          itens colocados: muda o globalItemId
//   InventoryItem      guardados: muda o id; se a pessoa ja tinha o original, soma as quantidades numa linha so
//   RestaurantFloor    tilesJson (lista de ids por bloco do piso)
//   Mail               itemId e globalItemIdsJson (presentes ainda nao abertos)
//   SocialLinkEscrow   itens retidos em troca entre contas
// O historico (ProfileSnapshot, ProfileSaveFact, CashTransaction) fica como esta.
// Sem --aplicar so conta (dry-run). Com --aplicar: copia o banco para backups/ (API de backup do SQLite) e
// grava tudo numa transacao. Rodar com o servidor PARADO: ele guarda o save em memoria e regravaria os ids antigos.
// Itens retirados do catalogo (REMOVIDOS, desde 2026-11-04): com --aplicar, as copias guardadas e colocadas
// sao apagadas depois da migracao (o jogo nao sabe desenhar um id que nao existe mais no catalogo).
// Uso: node scripts/migrar_inventario_julho2010.cjs [--aplicar] [--servidor <pasta do servidor>] [--banco <copia do dev.db>]
//   --servidor: pasta do restaurant-city-server (padrao: a desta maquina); o banco e <servidor>/dev.db
'use strict';
const fs = require('fs'), path = require('path');
const iServ = process.argv.indexOf('--servidor');
const servidor = iServ > 0 ? path.resolve(process.argv[iServ + 1]) : path.join(__dirname, '..', '..', '..', 'restaurant-city-server');
const Database = require(path.join(servidor, 'node_modules', 'better-sqlite3'));
const migracao = JSON.parse(fs.readFileSync(path.join(__dirname, '..', 'recriados', 'julho2010', 'migracao_ids.json'), 'utf8'));
const para = new Map(Object.entries(migracao).map(([de, m]) => [Number(de), m.para]));
// 3080089 Japanese Divider Corner (recriado por nos, retirado a pedido da dona em 2026-11-04)
const REMOVIDOS = [3080089];
const aplicar = process.argv.includes('--aplicar');
// --banco <arquivo>: outro banco (teste numa copia); o backup vai para a pasta dele
const iBanco = process.argv.indexOf('--banco');
const arqDb = iBanco > 0 ? path.resolve(process.argv[iBanco + 1]) : path.join(servidor, 'dev.db');

async function main() {
  const db = new Database(arqDb, { fileMustExist: true });
  const ids = [...para.keys()], ph = ids.map(() => '?').join(',');
  const contar = () => ({
    salao: db.prepare(`select count(*) n from OwnedItem where globalItemId in (${ph})`).get(...ids).n,
    guardados: db.prepare(`select coalesce(sum(number),0) n from InventoryItem where globalItemId in (${ph})`).get(...ids).n,
    pisos: db.prepare('select tilesJson from RestaurantFloor').all().reduce((s, f) => s + JSON.parse(f.tilesJson).filter((t) => para.has(t)).length, 0),
    cartas: db.prepare(`select count(*) n from Mail where itemId in (${ph})`).get(...ids).n
      + db.prepare("select globalItemIdsJson j from Mail where globalItemIdsJson != '[]'").all().reduce((s, m) => s + JSON.parse(m.j).filter((x) => para.has(Number(x))).length, 0),
    garantia: db.prepare(`select count(*) n from SocialLinkEscrow where globalItemId in (${ph})`).get(...ids).n,
  });
  const antes = contar();
  const totalGuardado = () => db.prepare('select coalesce(sum(number),0) n from InventoryItem').get().n;
  const totalSalao = () => db.prepare('select count(*) n from OwnedItem').get().n;
  const totais = [totalGuardado(), totalSalao()];
  console.log(`com id de recriacao: ${antes.salao} no salao, ${antes.guardados} guardado(s), ${antes.pisos} bloco(s) de piso, ${antes.cartas} em carta(s), ${antes.garantia} em garantia`);
  const phR = REMOVIDOS.map(() => '?').join(',');
  const contarRemovidos = () => ({
    salao: db.prepare(`select count(*) n from OwnedItem where globalItemId in (${phR})`).get(...REMOVIDOS).n,
    guardados: db.prepare(`select coalesce(sum(number),0) n from InventoryItem where globalItemId in (${phR})`).get(...REMOVIDOS).n,
  });
  const rem = contarRemovidos();
  console.log(`retirados do catalogo (${REMOVIDOS.join(', ')}): ${rem.salao} no salao, ${rem.guardados} guardado(s)`);
  if (!aplicar) { console.log('dry-run: nada gravado (use --aplicar com o servidor parado)'); db.close(); return; }

  const copia = path.join(iBanco > 0 ? path.dirname(arqDb) : path.join(servidor, 'backups'), `dev.db.${new Date().toISOString().slice(0, 10)}_antes_julho2010_${Date.now()}`);
  fs.mkdirSync(path.dirname(copia), { recursive: true });
  await db.backup(copia);
  console.log(`backup: ${copia}`);
  const tx = db.transaction(() => {
    const upOwned = db.prepare('update OwnedItem set globalItemId = ? where globalItemId = ?');
    for (const [de, novo] of para) upOwned.run(novo, de);
    const linhas = db.prepare(`select id, userProfileId, globalItemId, number from InventoryItem where globalItemId in (${ph})`).all(...ids);
    for (const l of linhas) {
      const novo = para.get(l.globalItemId);
      const ja = db.prepare('select id from InventoryItem where userProfileId = ? and globalItemId = ?').get(l.userProfileId, novo);
      if (ja) {
        db.prepare('update InventoryItem set number = number + ?, updatedAt = ? where id = ?').run(l.number, Date.now(), ja.id);
        db.prepare('delete from InventoryItem where id = ?').run(l.id);
      } else db.prepare('update InventoryItem set globalItemId = ?, updatedAt = ? where id = ?').run(novo, Date.now(), l.id);
    }
    for (const f of db.prepare('select id, tilesJson from RestaurantFloor').all()) {
      const t = JSON.parse(f.tilesJson);
      if (t.some((x) => para.has(x))) db.prepare('update RestaurantFloor set tilesJson = ? where id = ?').run(JSON.stringify(t.map((x) => para.get(x) ?? x)), f.id);
    }
    const upMail = db.prepare('update Mail set itemId = ? where itemId = ?');
    for (const [de, novo] of para) upMail.run(novo, de);
    for (const m of db.prepare("select id, globalItemIdsJson j from Mail where globalItemIdsJson != '[]'").all()) {
      const l = JSON.parse(m.j);
      if (l.some((x) => para.has(Number(x)))) db.prepare('update Mail set globalItemIdsJson = ? where id = ?').run(JSON.stringify(l.map((x) => para.get(Number(x)) ?? x)), m.id);
    }
    const upEsc = db.prepare('update SocialLinkEscrow set globalItemId = ? where globalItemId = ?');
    for (const [de, novo] of para) upEsc.run(novo, de);
  });
  tx();
  const depois = contar();
  if (Object.values(depois).some((n) => n)) throw new Error(`sobrou id de recriacao: ${JSON.stringify(depois)}`);
  if (totalGuardado() !== totais[0] || totalSalao() !== totais[1]) throw new Error('o total de itens mudou na migracao');
  console.log(`migrado. Totais conferidos: ${totais[0]} guardado(s) e ${totais[1]} no salao, iguais a antes`);
  if (rem.salao || rem.guardados) {
    db.transaction(() => {
      db.prepare(`delete from OwnedItem where globalItemId in (${phR})`).run(...REMOVIDOS);
      db.prepare(`delete from InventoryItem where globalItemId in (${phR})`).run(...REMOVIDOS);
    })();
    console.log(`apagados os retirados do catalogo: ${rem.salao} no salao, ${rem.guardados} guardado(s) (estao no backup)`);
  }
  db.close();
}
main().catch((e) => { console.error(e); process.exit(1); });
