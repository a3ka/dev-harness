#!/usr/bin/env python3
# Обманный стаб батареи 147 (Н-39; цикл 2, вердикт Crit147k2b класс
# ПОРЯДОК AVD): блок ПОДТВЕРЖДЕНИЯ ухода 390 снимается из канона e2e.sh
# — дословный обход критика: после исчерпания цикла ожидания скрипт
# безусловно запускал 393 и завершался rc 0 при «залипшем» 390
# (KILL_390_REQUESTED_BUT_STILL_RUNNING / EXITED_ZERO_WITH_390_STILL_
# LISTED; воспроизведено критиком без Android). e2e.sh И пин source.json
# меняются ВМЕСТЕ — обманный ПЕРЕПИН, а не порча носителя (порчу ловит
# vedro ДО клеток). Дефект наблюдаем на входе клетки
# s-e2e-ostanovka-podtverzhena (исполнение e2e.sh в песочнице двойников:
# залипший 390 — START 393 при живом первом): клетка обязана краснеть
# E2E_ZAPUSK_PRI_ZHIVOM_390; мутант-«пропускник» ловится здесь —
# STAB_ZHIV rc 1.
# argv[1] — корень зеркальной копии зоны.
import hashlib
import sys
from pathlib import Path

z = Path(sys.argv[1])
p = z / 'teksty' / 'e2e.sh'
tekst = p.read_text(encoding='utf-8')

BLOK = (
    'if adb devices | grep -q "$serial"; then\n'
    '  echo "ОТКАЗ: эмулятор $serial не ушёл за 60 с после emu kill — '
    'запуск 393 запрещён (два живых)" >&2\n'
    '  exit 4\n'
    'fi\n'
)
if tekst.count(BLOK) != 1:
    print('MUTACIJA_NE_NAIDENA: блок подтверждения ухода встречен %d раз'
          % tekst.count(BLOK), file=sys.stderr)
    sys.exit(1)
# снятие подтверждения: исчерпание ожидания снова ведёт к безусловному
# запуску 393 (дословное состояние канона до правки по вердикту)
p.write_text(tekst.replace(BLOK, '', 1), encoding='utf-8')
h = hashlib.sha256(p.read_bytes()).hexdigest()

s = z / 'source.json'
import json
src = json.loads(s.read_text(encoding='utf-8'))
if 'teksty/e2e.sh' not in src['piny']['sha']:
    print('MUTACIJA_NE_NAIDENA: пина teksty/e2e.sh нет', file=sys.stderr)
    sys.exit(1)
src['piny']['sha']['teksty/e2e.sh'] = h
s.write_text(json.dumps(src, ensure_ascii=False, indent=1) + '\n',
             encoding='utf-8')
print('mutacija: blok podtverzhdenija uhoda 390 snjat iz e2e.sh')
