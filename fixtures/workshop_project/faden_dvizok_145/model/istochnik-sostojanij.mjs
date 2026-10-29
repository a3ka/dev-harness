// Контракт 145 · РЕФЕРЕНС тестового источника состояний знака (I-ось батареи).
// Основание: §4 бэкенд-разбора «Разговор с агентом» (28.10) + слово владельца
// 2026-10-29 ~00:55 UTC (input145.md, п.1/п.4). ЭТОТ ЖЕ интерфейс, что потом
// даст бэкенд: факт несёт session/turn/generation, mission/operation (когда
// есть), причину (error) и следующего участника (next).
//
// Свойства (судятся клетками i01/i02 probe_runner.mjs):
//  · fadenInput(fact) — ЧИСТАЯ функция факт → вход движка: конформный факт
//    даёт {ok:true, patch:{state}}, патч — валидный аргумент createInstance().set();
//  · клиентские (idle/listening/speaking) и серверные (understanding/working/
//    waiting/needs_action/ready/done/uncertain) состояния РАЗДЕЛЬНЫ: состояние
//    принадлежит ровно одной стороне, error — обеим с причиной из замкнутого
//    набора (microphone/transport/processing/business); принадлежность причин
//    сторонам разбором не установлена — все четыре допустимы с обеих сторон;
//  · «выдуманная фаза» — поимённый ОТКАЗ (сервер не шлёт выдуманных фаз):
//    неизвестное имя состояния, состояние не той стороны, неизвестная сторона,
//    error без причины, причина вне набора, факт-не-объект;
//  · приоритетов источник НЕ изобретает: FADEN-1.3 таблицы приоритетов сторон
//    не несёт (сверено) — один факт → один вход; арбитраж одновременных фактов
//    и состояние дела в шапке — редьюсер экрана (контракт 151 по нарезке);
//  · корреляции факта (session/turn/generation/mission/operation/next) вход
//    движка НЕ меняют;
//  · пилот — только синтетические данные (G11): эталонная таблица фактов
//    батареи синтетическая, живого бэкенда в пилоте нет.
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
