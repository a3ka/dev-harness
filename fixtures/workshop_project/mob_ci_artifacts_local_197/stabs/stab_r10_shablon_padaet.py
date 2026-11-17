#!/usr/bin/env python3
# Стаб 197-r10 (v+1): скрипт-канон возвращает ОТКАЗ на пустой выбор шаблона
# (поведение замороженного 197/1: SOVPADENIJ_NET rc 2) — ломает честный
# пустой выбор PR без новых экранов (дефект mob#180: required android-e2e
# красна на каждом таком PR). Дефект наблюдаем НА ПОВЕДЕНИИ: клетка
# r10-shablon-pusto (rc 0 + CHTENIE_PUSTO + пустой --kuda); байтовое
# расхождение ловит и e01-skript-pin.
import sys
from pathlib import Path

d = Path(sys.argv[1]) / 'mobile/scripts/ci-artefakty.cjs'
s = d.read_text(encoding='utf-8')
staryj = """  if (sovpadenija.length === 0) {
    // 197 v+1 (слово владельца 2026-11-16 «197 v+1 — да»): пустой выбор
    // шаблона — НЕ отказ: PR без новых экранов даёт пустую matrix, читатель
    // screen-evidence-* честно собирает ноль детей (mob#180: rc 2 краснил
    // required android-e2e на каждом таком PR). Точное имя и каталог run'а
    // остаются fail-closed.
    fs.mkdirSync(kuda, { recursive: true });
    console.log('CHTENIE_PUSTO: ' + shablon);
    return;
  }
"""
novyj = """  if (sovpadenija.length === 0) otkaz('SOVPADENIJ_NET: ' + shablon);
"""
if s.count(staryj) != 1:
    print(f'MUTACIJA_NE_NAIDENA: vstrech {s.count(staryj)}', file=sys.stderr)
    sys.exit(1)
d.write_text(s.replace(staryj, novyj, 1), encoding='utf-8')
