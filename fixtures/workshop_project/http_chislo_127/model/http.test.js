'use strict';

// HTTP-граница по OpenAPI 5.8.x (CMP-BCK-125): настоящий start() на loopback TCP, тестовые обработчики
// реальных операций (вне production app/), матрица версий и ошибок — app/schemas/README.md.

const { test, before, after } = require('node:test');
const assert = require('node:assert/strict');
const crypto = require('node:crypto');
const { execFileSync } = require('node:child_process');
const fs = require('node:fs');
const path = require('node:path');

const { bootContractServer, example } = require('../helpers/contract-server.js');
const { loadContracts } = require('../../app/schemas/index.js');

const V = { 'x-brokeros-contract': '5.8.2' };
const COOKIE = { cookie: '__Host-brokeros_session=valid-test-session' };
const command = () => ({
  'idempotency-key': `key-${crypto.randomUUID()}`,
  'x-command-id': crypto.randomUUID(),
});
// 5.8.4: VERSIONED_TARGET_CAS для acknowledgeDisclosure требует If-Match с сильным ETag
// (источник — GET /disclosures/{disclosure_id}). Тестовое дерево api обработчик getDisclosure не
// реализует, поэтому ETag берётся как фиксированная строка; проверки тела по схеме If-Match не касаются.
const IF_MATCH = { 'if-match': '"test-disclosure-v1"' };

let srv;
before(async () => {
  srv = await bootContractServer();
});
after(async () => {
  await srv.close();
});

const call = async (method, url, { headers = {}, body } = {}) => {
  const res = await fetch(`${srv.base}${url}`, {
    method,
    headers: { ...(body !== undefined ? { 'content-type': 'application/json' } : {}), ...headers },
    body: body === undefined ? undefined : typeof body === 'string' ? body : JSON.stringify(body),
  });
  const text = await res.text();
  return { status: res.status, headers: res.headers, json: text ? JSON.parse(text) : null };
};

const contracts = loadContracts();
// Число операций — из производного контракта app/schemas/openapi.json (gen:contracts), не литерал:
// счёт пар путь×метод с operationId по самому файлу, независимо от загрузчика и реестра сервера.
const DERIVED_DOC = path.join(__dirname, '..', '..', 'app', 'schemas', 'openapi.json');
const countOperations = (doc) => Object.values(doc.paths).reduce((n, item) => n + ['get', 'put', 'post', 'patch', 'delete'].filter((m) => item[m]?.operationId).length, 0);
const DERIVED_OPERATIONS = countOperations(JSON.parse(fs.readFileSync(DERIVED_DOC, 'utf8')));
const assertProblem = (res, status, code) => {
  assert.equal(res.status, status, JSON.stringify(res.json));
  assert.match(res.headers.get('content-type'), /^application\/problem\+json/);
  assert.equal(res.json.code, code);
  assert.ok(
    contracts.validateProblem(res.json),
    `Problem по схеме: ${JSON.stringify(contracts.validateProblem.errors)}`,
  );
  assert.equal(res.headers.get('x-brokeros-contract'), contracts.apiVersion);
};

test('производный контракт совпадает с корневым OpenAPI (gen-contracts --check) и несёт его хэш', () => {
  execFileSync(process.execPath, [
    path.join(__dirname, '..', '..', 'tests', 'tools', 'gen-contracts.js'),
    '--check',
  ]);
  const root = fs.readFileSync(
    path.join(__dirname, '..', '..', 'docs', 'contracts', 'BrokerOS_Unified_OpenAPI_v3.yaml'),
  );
  assert.equal(contracts.sourceSha256, crypto.createHash('sha256').update(root).digest('hex'));
  const rootVersion = /^\s+version:\s*['"]?([0-9.]+)/m.exec(
    root.toString('utf8').split('\ninfo:')[1],
  )[1];
  assert.equal(contracts.apiVersion, rootVersion);
  assert.equal(contracts.operations.size, DERIVED_OPERATIONS);
});

test('матрица версий: 5.8.x принимается и ответ — версия контракта; иное и отсутствие — 400 до обработчика', async () => {
  const ok = await call('GET', '/v1/session', {
    headers: { 'x-brokeros-contract': '5.8.0', ...COOKIE },
  });
  assert.equal(ok.status, 200);
  assert.equal(ok.headers.get('x-brokeros-contract'), contracts.apiVersion);
  // Версия API производного контракта принимается сервером (вместо литерала семейства).
  const own = await call('GET', '/v1/session', { headers: { 'x-brokeros-contract': contracts.apiVersion, ...COOKIE } });
  assert.equal(own.status, 200, JSON.stringify(own.json));
  for (const bad of ['5.7.0', '6.0.0', '5.8', 'latest']) {
    assertProblem(
      await call('GET', '/v1/session', { headers: { 'x-brokeros-contract': bad, ...COOKIE } }),
      400,
      'VALIDATION_ERROR',
    );
  }
  assertProblem(await call('GET', '/v1/session', { headers: COOKIE }), 400, 'VALIDATION_ERROR');
  // Версия проверяется раньше учётных данных: без cookie и с неверной версией — 400, не 401.
  assertProblem(
    await call('GET', '/v1/session', { headers: { 'x-brokeros-contract': '5.7.0' } }),
    400,
    'VALIDATION_ERROR',
  );
});

test('каталог: указан не 3.7 → 409 CATALOG_VERSION_UNSUPPORTED', async () => {
  const res = await call('GET', '/v1/session', {
    headers: { ...V, ...COOKIE, 'x-brokeros-catalog': '3.6' },
  });
  assertProblem(res, 409, 'CATALOG_VERSION_UNSUPPORTED');
});

test('учётные данные: без них 401; неверный Authorization не откатывается на cookie', async () => {
  assertProblem(await call('GET', '/v1/session', { headers: V }), 401, 'SCOPE_ACCESS_DENIED');
  const withBadAuth = await call('GET', '/v1/session', {
    headers: { ...V, ...COOKIE, authorization: 'Basic Zm9vOmJhcg==' },
  });
  assertProblem(withBadAuth, 401, 'SCOPE_ACCESS_DENIED');
  const wrongBearer = await call('GET', '/v1/session', {
    headers: { ...V, ...COOKIE, authorization: 'Bearer wrong-token' },
  });
  assertProblem(wrongBearer, 401, 'SCOPE_ACCESS_DENIED');
  const badCookie = await call('GET', '/v1/session', {
    headers: { ...V, cookie: '__Host-brokeros_session=forged' },
  });
  assertProblem(badCookie, 401, 'SCOPE_ACCESS_DENIED');
});

test('ответ обработчика проверяется схемой: верный пример → 200, нарушение схемы → 500 INTERNAL_ERROR', async () => {
  const ok = await call('GET', '/v1/session', {
    headers: { ...V, authorization: 'Bearer valid-test-token' },
  });
  assert.equal(ok.status, 200);
  assert.deepEqual(ok.json, example('getSession', 'response_200'));
  const bad = await call('GET', '/v1/session', {
    headers: { ...V, ...COOKIE, 'x-test-bad-response': '1' },
  });
  assertProblem(bad, 500, 'INTERNAL_ERROR');
});

test('bodyless logoutSession: 204 без тела; заголовки команды обязательны; тело запрещено', async () => {
  const ok = await call('POST', '/v1/session/logout', {
    headers: { ...V, ...COOKIE, ...command() },
  });
  assert.equal(ok.status, 204);
  assert.equal(ok.json, null);
  assert.equal(ok.headers.get('x-brokeros-contract'), contracts.apiVersion);
  const noKey = await call('POST', '/v1/session/logout', {
    headers: { ...V, ...COOKIE, 'x-command-id': crypto.randomUUID() },
  });
  assertProblem(noKey, 400, 'VALIDATION_ERROR');
  assert.ok(noKey.json.field_errors.some((f) => f.field === 'header/idempotency-key'));
  const badId = await call('POST', '/v1/session/logout', {
    headers: { ...V, ...COOKIE, ...command(), 'x-command-id': 'not-a-uuid' },
  });
  assertProblem(badId, 400, 'VALIDATION_ERROR');
  const withBody = await call('POST', '/v1/session/logout', {
    headers: { ...V, ...COOKIE, ...command() },
    body: { a: 1 },
  });
  assertProblem(withBody, 400, 'VALIDATION_ERROR');
});

test('тело по схеме: верный пример проходит, лишнее поле и неверный JSON → 400 с field_errors', async () => {
  const url = `/v1/disclosures/${crypto.randomUUID()}/acknowledgements`;
  const body = example('acknowledgeDisclosure', 'request');
  const ok = await call('POST', url, {
    headers: { ...V, ...COOKIE, ...command(), ...IF_MATCH },
    body,
  });
  assert.equal(ok.status, 200, JSON.stringify(ok.json));
  const extra = await call('POST', url, {
    headers: { ...V, ...COOKIE, ...command(), ...IF_MATCH },
    body: { ...body, unexpected_field: 1 },
  });
  assertProblem(extra, 400, 'VALIDATION_ERROR');
  assert.ok(extra.json.field_errors.length > 0);
  const broken = await call('POST', url, {
    headers: { ...V, ...COOKIE, ...command(), ...IF_MATCH },
    body: '{"digest":',
  });
  assertProblem(broken, 400, 'VALIDATION_ERROR');
  // disclosure_id объявлен на уровне пути (path item): ^[A-Za-z0-9][A-Za-z0-9_-]*$
  const badPath = await call('POST', '/v1/disclosures/-bad/acknowledgements', {
    headers: { ...V, ...COOKIE, ...command(), ...IF_MATCH },
    body,
  });
  assertProblem(badPath, 400, 'VALIDATION_ERROR');
});

test('If-Match обязателен у операции → без него 428 PRECONDITION_REQUIRED', async () => {
  const url = `/v1/missions/${crypto.randomUUID()}/answers`;
  const res = await call('POST', url, { headers: { ...V, ...COOKIE, ...command() }, body: {} });
  assertProblem(res, 428, 'PRECONDITION_REQUIRED');
});

test('неизвестный путь и операция без обработчика — 404 NOT_FOUND Problem', async () => {
  assertProblem(await call('GET', '/v1/no-such-route', { headers: V }), 404, 'NOT_FOUND');
  assertProblem(
    await call('GET', '/v1/contexts', { headers: { ...V, ...COOKIE } }),
    404,
    'NOT_FOUND',
  );
});

test('ответ: необъявленный статус → 500; Problem обработчика уходит как application/problem+json', async () => {
  const undeclared = await call('GET', '/v1/session', {
    headers: { ...V, ...COOKIE, 'x-test-status': '201' },
  });
  const viaToJson = await call('GET', '/v1/session', {
    headers: { ...V, ...COOKIE, 'x-test-tojson': '1' },
  });
  assertProblem(viaToJson, 500, 'INTERNAL_ERROR');
  assertProblem(undeclared, 500, 'INTERNAL_ERROR');
  const problem = await call('GET', '/v1/post?limit=5&unread=true', {
    headers: { ...V, ...COOKIE, 'x-scope-id': crypto.randomUUID() },
  });
  assertProblem(problem, 422, 'VALIDATION_ERROR');
  // query приходит строками и приводится к типам схемы до обработчика.
  assert.equal(problem.json.detail, 'number/boolean');
  assertProblem(
    await call('GET', '/v1/post?limit=0', {
      headers: { ...V, ...COOKIE, 'x-scope-id': crypto.randomUUID() },
    }),
    400,
    'VALIDATION_ERROR',
  );
  assertProblem(
    await call('GET', '/v1/post?unread=maybe', {
      headers: { ...V, ...COOKIE, 'x-scope-id': crypto.randomUUID() },
    }),
    400,
    'VALIDATION_ERROR',
  );
});

test('bodyless: любое тело (JSON null, "") → 400; AppError — код из ReasonCode, чужой код → 500', async () => {
  for (const raw of ['null', '""']) {
    const res = await call('POST', '/v1/session/logout', {
      headers: { ...V, ...COOKIE, ...command() },
      body: raw,
    });
    assertProblem(res, 400, 'VALIDATION_ERROR');
  }
  const conflict = await call('POST', '/v1/session/logout', {
    headers: { ...V, ...COOKIE, ...command(), 'x-test-throw': 'conflict' },
  });
  assertProblem(conflict, 409, 'SOURCE_CHANGED');
  const foreign = await call('POST', '/v1/session/logout', {
    headers: { ...V, ...COOKIE, ...command(), 'x-test-throw': 'foreign-code' },
  });
  assertProblem(foreign, 500, 'INTERNAL_ERROR');
  const success = await call('POST', '/v1/session/logout', {
    headers: { ...V, ...COOKIE, ...command(), 'x-test-throw': 'success-status' },
  });
  assertProblem(success, 500, 'INTERNAL_ERROR');
});

test('application/octet-stream из контракта принимается как байты', async () => {
  const res = await fetch(`${srv.base}/webhooks/payment-providers/${crypto.randomUUID()}`, {
    method: 'POST',
    headers: { 'content-type': 'application/octet-stream' },
    body: Buffer.from('signed-bytes'),
  });
  const json = await res.json();
  assert.equal(res.status, 409);
  assert.equal(json.detail, 'bytes:12');
});

test('реестр: тестовые операции реализованы только в тестовом дереве', () => {
  const implemented = srv.instance.registry
    .filter((r) => r.implemented)
    .map((r) => r.operationId)
    .sort();
  assert.deepEqual(implemented, [
    'acknowledgeDisclosure',
    'answerQuestion',
    'getSession',
    'listPostItems',
    'logoutSession',
    'receivePaymentProviderWebhook',
  ]);
  assert.equal(srv.instance.registry.length, DERIVED_OPERATIONS);
});

test('без проверяющего учётных данных (IdP ещё нет) операция с security → 401, а не «успех» или 500', async () => {
  const bare = await bootContractServer({ auth: null });
  try {
    const res = await fetch(`${bare.base}/v1/session`, { headers: { ...V, ...COOKIE } });
    const json = await res.json();
    assert.equal(res.status, 401);
    assert.equal(json.code, 'SCOPE_ACCESS_DENIED');
  } finally {
    await bare.close();
  }
});
