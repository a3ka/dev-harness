#!/usr/bin/env python3
# Обманный стаб батареи 149 (Н-39, v+1 цикл 2, вердикт Crit149k2a класс
# ПОРЯДОК_AVD_393): ПАРАЛЛЕЛЬНЫЙ job — второй эмулятор 393 стартует ДО
# остановки первого (дословная атака критика: boot 5580, сохранение
# серийника, boot 5582 — без остановки; решение владельца 31.10: второй
# запускется ПОСЛЕ остановки первого, не одновременно — Astra
# mob-ci-razdelenie п.342). Мутирует e2e.sh КОПИИ A-дерева: блок запуска
# 393 вставляется ПЕРЕД остановкой первого. Дефект наблюдаем на входе
# клетки s-emuljatory-posledovatelno: исполняющий суд (песочница с
# двойниками SDK) обязан краснеть AVD393_ZAPUSCHEN_DO_OSTANOVKI по
# журналу START при живом emulator-5580; мутант-«пропускник» (клетка
# зелена без исполнения) ловится здесь — STAB_ZHIV rc 1.
# argv[1] — каталог копии A-дерева.
import sys
from pathlib import Path

d = Path(sys.argv[1])
p = d / 'mobile' / 'e2e-gespraech-tekst' / 'e2e.sh'
tekst = p.read_text(encoding='utf-8')

JAKOR = 'adb -s "$SERIAL_390" emu kill\n'
VSTAVKA = (
    '"$ANDROID_HOME/emulator/emulator" -avd "$AVD_393" '
    '-port "$PORT_393" -no-window -no-audio -no-boot-anim -no-snapshot '
    '-gpu swiftshader_indirect >"emulator-149-393.log" 2>&1 &\n'
)
if tekst.count(JAKOR) != 1:
    print('MUTACIJA_NE_NAIDENA: якорь остановки встречен %d раз'
          % tekst.count(JAKOR), file=sys.stderr)
    sys.exit(1)
# параллельный старт ДО остановки первого (атака: одновременно)
p.write_text(tekst.replace(JAKOR, VSTAVKA + JAKOR, 1), encoding='utf-8')
print('mutacija: parallel-start-393 vstavlen do ostanovki 390')
