// Контракт 145 · тестовый источник состояний знака (пилот; §4 бэкенд-разбора
// «Разговор с агентом», слово владельца 2026-10-29 ~00:55 UTC). Эталон-форма
// батареи (produkt/); в продукте — mobile/src/ui/faden/faden-state-source.ts.
// Чистая функция факт → вход движка; клиентские и серверные состояния РАЗДЕЛЬНЫ;
// «выдуманная фаза» — поимённый отказ; приоритетов источник не изобретает
// (FADEN-1.3 таблицы приоритетов сторон не несёт — арбитраж одновременных
// фактов и шапка дела — редьюсер экрана, контракт 151). Пилот — только
// синтетические данные (G11). Судится клетками i01/i02 батареи 145.
export const FADEN_FACT_SIDES = ['client', 'server'];
export const FADEN_CLIENT_STATES = ['idle', 'listening', 'speaking'];
export const FADEN_SERVER_STATES = ['understanding', 'working', 'waiting', 'needs_action', 'ready', 'done', 'uncertain'];
export const FADEN_ERROR_REASONS = ['microphone', 'transport', 'processing', 'business'];

const SOSTOJANIJA_ZNAKA = [...FADEN_CLIENT_STATES, ...FADEN_SERVER_STATES, 'error'];

export function fadenInput(fact) {
  if (fact === null || typeof fact !== 'object' || Array.isArray(fact)) {
    return { ok: false, refusal: 'VYDUMANNAA_FAZA:nefakt' };
  }
  if (!FADEN_FACT_SIDES.includes(fact.side)) {
    return { ok: false, refusal: 'VYDUMANNAA_FAZA:neizvestnaja_storona' };
  }
  if (!SOSTOJANIJA_ZNAKA.includes(fact.state)) {
    return { ok: false, refusal: 'VYDUMANNAA_FAZA:neizvestnoe_sostojanie' };
  }
  if (FADEN_CLIENT_STATES.includes(fact.state) && fact.side !== 'client') {
    return { ok: false, refusal: 'VYDUMANNAA_FAZA:nevernaja_storona' };
  }
  if (FADEN_SERVER_STATES.includes(fact.state) && fact.side !== 'server') {
    return { ok: false, refusal: 'VYDUMANNAA_FAZA:nevernaja_storona' };
  }
  if (fact.state === 'error') {
    if (fact.reason === undefined || fact.reason === null) {
      return { ok: false, refusal: 'VYDUMANNAA_FAZA:net_prichiny' };
    }
    if (!FADEN_ERROR_REASONS.includes(fact.reason)) {
      return { ok: false, refusal: 'VYDUMANNAA_FAZA:prichina_vne_nabora' };
    }
  }
  return { ok: true, patch: { state: fact.state } };
}
