'use strict';
// Общий бутстрап toy-тестов: открыть движок, применить миграции 001–004.
const path = require('node:path');
const ToyPg = require('./toy_pg');

const ROOT = path.resolve(__dirname, '..', '..');

module.exports = { ToyPg, ROOT, openDb };

function openDb(engineKind) {
  const db = new ToyPg(engineKind);
  db.applyMigrationsDir(path.join(ROOT, 'migrations'));
  return db;
}
