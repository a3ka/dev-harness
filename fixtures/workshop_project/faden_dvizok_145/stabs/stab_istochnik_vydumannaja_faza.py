#!/usr/bin/env python3
"""Стаб 145 (produkt-форма): источник состояний «пропускает выдуманные фазы» —
§4 бэкенд-разбора + слово владельца 2026-10-29 ~00:55 UTC (input145.md п.1:
сервер не шлёт выдуманных фаз; «выдуманная фаза» — отказ).

«Честно выглядящий» источник: конформные факты отображает верно (клетка
i01 зелёна), но неизвестное имя состояния молча отображает на 'working',
состояние не той стороны пропускает, error без причины даёт как валидный.
Ловится клеткой i02-istochnik-vydumannaja-faza: выход на входах-отказах
расходится с эталонными поимёнными отказами VYDUMANNAA_FAZA (ожидания
вычисляет пиннованный эталон model/istochnik-sostojanij.mjs ДО субъекта).
Привязка Н-39: дефект наблюдаем на входах-отказах — привязка только к i02."""
import pathlib
import shutil
import sys

cel = pathlib.Path(sys.argv[1])
bat = pathlib.Path(__file__).resolve().parents[1]
cel = cel / 'produkt'
shutil.copytree(bat / 'produkt', cel)
modul = '''// мутант стаба 145: источник БЕЗ отказов выдуманных фаз (i02)
export const FADEN_FACT_SIDES = ['client', 'server'];
export const FADEN_CLIENT_STATES = ['idle', 'listening', 'speaking'];
export const FADEN_SERVER_STATES = ['understanding', 'working', 'waiting', 'needs_action', 'ready', 'done', 'uncertain'];
export const FADEN_ERROR_REASONS = ['microphone', 'transport', 'processing', 'business'];

const ZNACHENIE = [...FADEN_CLIENT_STATES, ...FADEN_SERVER_STATES, 'error'];

export function fadenInput(fact) {
  if (fact === null || typeof fact !== 'object' || Array.isArray(fact)) {
    return { ok: true, patch: { state: 'working' } };
  }
  let sostojanie = fact.state;
  if (!ZNACHENIE.includes(sostojanie)) sostojanie = 'working';
  return { ok: true, patch: { state: sostojanie } };
}
'''
(cel / 'mobile/src/ui/faden/faden-state-source.ts').write_text(modul, encoding='utf-8')
