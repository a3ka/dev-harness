'use strict';

// Smoke HTTP-границы (CMP-BCK-125) на настоящем loopback TCP.
//  1. Сервер с тестовыми обработчиками (вне production app/): неверный запрос → 4xx Problem,
//     неизвестный путь → 404, неверный Authorization при верной cookie → 401 (cookie не рассматривается).
//  2. Production-сервер (app/ как есть): ни одной реализованной операции — тестовых обработчиков в
//     production-реестре нет; любой путь → 404 Problem.

const crypto = require('node:crypto');
const fs = require('node:fs');
const path = require('node:path');

const { bootContractServer } = require('../helpers/contract-server.js');

// Число операций — из производного контракта app/schemas/openapi.json (gen:contracts), не литерал.
const DERIVED_DOC = path.join(__dirname, '..', '..', 'app', 'schemas', 'openapi.json');
const countOperations = (doc) => Object.values(doc.paths).reduce((n, item) => n + ['get', 'put', 'post', 'patch', 'delete'].filter((m) => item[m]?.operationId).length, 0);

const check = (condition, message) => {
  if (!condition) throw new Error(message);
  process.stdout.write(`ok  ${message}\n`);
};

const get = async (base, url, headers) => {
  const res = await fetch(`${base}${url}`, { headers });
  const body = await res.json().catch(() => null);
  return { status: res.status, type: res.headers.get('content-type') || '', body };
};

const main = async () => {
  const test = await bootContractServer();
  try {
    const V = { 'x-brokeros-contract': '5.8.2' };
    const cookie = { cookie: '__Host-brokeros_session=valid-test-session' };
    const good = await get(test.base, '/v1/session', { ...V, ...cookie });
    check(good.status === 200, 'тестовый сервер: верный запрос с верной cookie → 200');
    const badVersion = await get(test.base, '/v1/session', {
      'x-brokeros-contract': '4.0.0',
      ...cookie,
    });
    check(
      badVersion.status === 400 &&
        badVersion.type.startsWith('application/problem+json') &&
        badVersion.body.code === 'VALIDATION_ERROR',
      'неверный запрос → 400 Problem VALIDATION_ERROR',
    );
    const unknown = await get(test.base, `/v1/${crypto.randomUUID()}`, V);
    check(
      unknown.status === 404 && unknown.body.code === 'NOT_FOUND',
      'неизвестный путь → 404 Problem',
    );
    const badAuth = await get(test.base, '/v1/session', {
      ...V,
      ...cookie,
      authorization: 'Token abc',
    });
    check(
      badAuth.status === 401 && badAuth.type.startsWith('application/problem+json'),
      'неверный Authorization при верной cookie → 401, cookie не рассматривается',
    );
  } finally {
    await test.close();
  }

  const prod = await bootContractServer({ withTestApi: false, auth: null });
  try {
    const implemented = prod.instance.registry.filter((r) => r.implemented);
    const operations = countOperations(JSON.parse(fs.readFileSync(DERIVED_DOC, 'utf8')));
    check(
      prod.instance.registry.length === operations && implemented.length === 0,
      `production-реестр: ${operations} операций производного контракта, реализовано ${implemented.length} — тестовых обработчиков нет`,
    );
    const session = await get(prod.base, '/v1/session', { 'x-brokeros-contract': '5.8.2' });
    check(
      session.status === 404 && session.body.code === 'NOT_FOUND',
      'production: операция без обработчика → 404 Problem',
    );
  } finally {
    await prod.close();
  }
};

main().then(
  () => process.stdout.write('smoke:http — пройден\n'),
  (error) => {
    process.stderr.write(`smoke:http — отказ: ${error.message}\n`);
    process.exit(1);
  },
);
