const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { spawnSync } = require('node:child_process');

const testDbName = `.own-ingredient-exchange-test-${process.pid}.db`;
const testDbPath = path.join(__dirname, '..', testDbName);
fs.writeFileSync(testDbPath, '');
const pushEnv = { ...process.env }; delete pushEnv.RC_DB_PATH;
const push = spawnSync(
  process.execPath,
  [path.join(__dirname, '..', 'node_modules', 'prisma', 'build', 'index.js'), 'db', 'push', '--url', `file:./${testDbName}`],
  { cwd: path.join(__dirname, '..'), env: pushEnv, encoding: 'utf8' },
);
assert.equal(push.status, 0, push.stderr || push.stdout);
process.env.RC_DB_PATH = testDbPath;

const { prisma } = require('../dist/db/client.js');
const { swapIngredient, ownExchangeAllowed } = require('../dist/db/rpc-store.js');
const { buildResponse } = require('../dist/rpc/index.js');
const { writeBool, writeNetworkUid, writeString, writeU8, writeVarint } = require('../dist/rpc/codec.js');

// Hashes from ingredient-data.ts.
const R1_A = { id: 4000004, hash: 'jn7oj0vkTbuJkKA5QjzGda' }; // rarity 1
const R1_B = { id: 4000014, hash: '_nBStRqcTI8v9m4xr0WKla' }; // rarity 1
const R2 = { id: 4000001, hash: 'zTquXNtn68_n.bQGp7XiVa' }; // rarity 2
const R3 = { id: 4000002, hash: 'DiaUr54yPWANy48rDe5jwa' }; // rarity 3
const R3_B = { id: 4000007, hash: 'q5XhqWJgmBngmjzu.ymSya' }; // rarity 3
const R4 = { id: 4000005, hash: 'hbvbtiywjfbtGr.DGin.uq' }; // rarity 4

function offer(...items) {
  return items.map((item) => item.hash).join(',');
}

let seq = 0;
async function seedProfile(name) {
  seq += 1;
  const networkUid = String(930000000 + seq);
  const account = { username: name, networkUid, playfishUid: Number(networkUid), sessionId: `session-${seq}` };
  await prisma.userProfile.create({
    data: {
      id: `facebook:${networkUid}`,
      networkUid,
      playfishUid: Number(networkUid),
      firstName: name,
      fullName: `${name} Chef`,
      restaurantName: `${name}'s Restaurant`,
      floors: { create: [0, 1].map((floorIndex) => ({ id: `facebook:${networkUid}:floor:${floorIndex}`, floorIndex, tilesJson: JSON.stringify(Array(800).fill(0)) })) },
    },
  });
  return account;
}

async function setIngredient(account, globalItemId, number, isLocked = false) {
  await prisma.ingredientInventory.upsert({
    where: { userProfileId_globalItemId: { userProfileId: `facebook:${account.networkUid}`, globalItemId } },
    update: { number, isLocked },
    create: { id: `facebook:${account.networkUid}:ingredient:${globalItemId}`, userProfileId: `facebook:${account.networkUid}`, globalItemId, number, isLocked },
  });
}

async function ingredientRow(account, globalItemId) {
  return prisma.ingredientInventory.findUnique({
    where: { userProfileId_globalItemId: { userProfileId: `facebook:${account.networkUid}`, globalItemId } },
  });
}

async function count(account, globalItemId) {
  return (await ingredientRow(account, globalItemId))?.number ?? 0;
}

function self(account) {
  return { network: 2, networkUid: account.networkUid, playfishUid: account.playfishUid };
}

test.after(async () => {
  await prisma.$disconnect();
  fs.rmSync(testDbPath, { force: true });
});

test('three picks buy up to their average rarity rounded up', () => {
  assert.equal(ownExchangeAllowed([R1_A.id, R1_A.id, R1_A.id], R1_B.id), true);
  assert.equal(ownExchangeAllowed([R1_A.id, R1_A.id, R1_A.id], R2.id), false);
  assert.equal(ownExchangeAllowed([R3.id, R3.id, R1_A.id], R3_B.id), true);
  assert.equal(ownExchangeAllowed([R3.id, R3.id, R3.id], R4.id), false);
  assert.equal(ownExchangeAllowed([R4.id, R3.id, R3.id], R4.id), false); // asks for one of its own picks
  assert.equal(ownExchangeAllowed([R1_A.id, R1_A.id], R1_B.id), false);
  assert.equal(ownExchangeAllowed([R1_A.id, R1_A.id, R1_A.id, R1_A.id], R1_B.id), false);
});

test('all three copies can be spent, with no reserve', async () => {
  const owner = await seedProfile('noreserve');
  await setIngredient(owner, R1_A.id, 3);
  assert.equal(await swapIngredient(owner, self(owner), offer(R1_A, R1_A, R1_A), R1_B.hash, false, 0), 0);
  assert.equal(await ingredientRow(owner, R1_A.id), null);
  assert.equal(await count(owner, R1_B.id), 1);
});

test('mixed picks are debited one by one and padlocked copies can be spent', async () => {
  const owner = await seedProfile('mixed');
  await setIngredient(owner, R3.id, 2, true);
  await setIngredient(owner, R1_A.id, 1, true);
  assert.equal(await swapIngredient(owner, self(owner), offer(R3, R1_A, R3), R3_B.hash, false, 0), 0);
  assert.equal(await count(owner, R3.id), 0);
  assert.equal(await count(owner, R1_A.id), 0);
  const received = await ingredientRow(owner, R3_B.id);
  assert.equal(received.number, 1);
  assert.equal(received.isLocked, false);
});

test('a pick without stock rolls back the whole exchange', async () => {
  const owner = await seedProfile('rollback');
  await setIngredient(owner, R1_B.id, 1);
  await setIngredient(owner, R1_A.id, 1);
  assert.equal(await swapIngredient(owner, self(owner), offer(R1_B, R1_A, R1_A), R2.hash, false, 0), 4);
  assert.equal(await count(owner, R1_B.id), 1);
  assert.equal(await count(owner, R1_A.id), 1);
  assert.equal(await count(owner, R2.id), 0);
});

test('invalid requests change nothing', async () => {
  const owner = await seedProfile('invalid');
  await setIngredient(owner, R1_A.id, 10);
  assert.equal(await swapIngredient(owner, self(owner), offer(R1_A, R1_A, R1_A), R1_A.hash, false, 0), 4);
  assert.equal(await swapIngredient(owner, self(owner), offer(R1_A, R1_A, R1_A), R2.hash, false, 0), 4);
  assert.equal(await swapIngredient(owner, self(owner), R1_A.hash, R1_B.hash, false, 0), 4);
  assert.equal(await swapIngredient(owner, self(owner), `${offer(R1_A, R1_A)},not-a-hash`, R1_B.hash, false, 0), 4);
  assert.equal(await swapIngredient(owner, self(owner), offer(R1_A, R1_A, R1_A), 'not-a-hash', false, 0), 4);
  assert.equal(await count(owner, R1_A.id), 10);
  assert.equal(await count(owner, R1_B.id), 0);
});

test('a comma list is never accepted as a friend trade offer', async () => {
  const owner = await seedProfile('friendlist');
  const other = await seedProfile('friendlisttarget');
  await setIngredient(owner, R1_A.id, 3);
  await setIngredient(other, R1_B.id, 1);
  assert.equal(await swapIngredient(owner, self(other), offer(R1_A, R1_A, R1_A), R1_B.hash, false, 0), 4);
  assert.equal(await count(owner, R1_A.id), 3);
});

test('concurrent exchanges cannot spend the same copies twice', async () => {
  const owner = await seedProfile('concurrent');
  await setIngredient(owner, R1_A.id, 3);
  const results = await Promise.allSettled([
    swapIngredient(owner, self(owner), offer(R1_A, R1_A, R1_A), R1_B.hash, false, 0),
    swapIngredient(owner, self(owner), offer(R1_A, R1_A, R1_A), R1_B.hash, false, 0),
  ]);
  const ok = results.filter((r) => r.status === 'fulfilled' && r.value === 0).length;
  assert.equal(ok, 1);
  assert.equal(await count(owner, R1_A.id), 0);
  assert.equal(await count(owner, R1_B.id), 1);
});

test('RPC 17 aimed at the caller runs the exchange with the shipped wire layout', async () => {
  const owner = await seedProfile('wireself');
  await setIngredient(owner, R1_A.id, 3);
  const request = Buffer.concat([
    writeU8(0),
    writeU8(17),
    writeString('flash-session'),
    writeNetworkUid(2, owner.networkUid, owner.playfishUid),
    writeString(offer(R1_A, R1_A, R1_A)),
    writeString(R1_B.hash),
    writeBool(false),
    writeVarint(0),
    writeBool(true),
  ]);
  const result = await buildResponse(request, owner);
  assert.equal(result.response.toString('hex'), '001100');
  assert.equal(await count(owner, R1_A.id), 0);
  assert.equal(await count(owner, R1_B.id), 1);
});
