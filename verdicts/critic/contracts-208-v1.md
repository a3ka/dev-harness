accept
OBJECT=061bb707cd52e65907eeae2c9681b7b9c5a7a2cf
СУД: репо=dev-harness; предмет=208; роль=critic; вызов=3/3 (узкий, санкция консультанта); фаза=v1; модель-план=openai-codex/gpt-6.1-terra; модель-факт=openai-codex/gpt-6.1-terra; предыдущий=archive/208/critic-v2-fail-c8aef370e3; класс риска=рисковый

Сессия Crit208V3. Факт модели — из контекста запуска; отдельная сверка трейса fallback и записи счёта оркестратора не наблюдалась, её оркестратор выполняет до материализации. Автор OBJECT — architect. Основание узкого суда: санкция консультанта и решение арбитра 14c8ef20940654aa95e607deb80140e0fcd04018; исследована байтовая дельта, её зависимый регресс и тексты варианта А, а не заново весь контракт.

## Карта классов
К-01: чисто — check_sdacha --run rc 0 и pre_critic rc 0
К-02: чисто — вход contracts/208-zamok-object-predok.md раздел Пересечение 140↔208 и слово владельца 22.11 вариант А
К-03: чисто — merge-base --is-ancestor 378e45782e HEAD rc 0 и diff двери с A2 пуст
К-04: чисто — check_precision_gate . contracts/208-zamok-object-predok.md rc 0
К-05: чисто — вход раздела Приёмка содержит команды model stabs repo и sintaksis с rc
К-06: чисто — вход probe208.py zashita_zavisimostej и nositeli_sverka задаёт rc 2
К-07: чисто — --repo . rc 1 23/18 и честная модель через --repo rc 0 23/0
К-08: чисто — --stabs rc 0 64 связи 0 живых включая st13–st19
К-09: чисто — st16 связан с r22 и --stabs rc 0
К-10: чисто — st20–st29 лично на r04 r06 r07 красны и честная модель 23/0
К-11: чисто — вход probe208.py sudit и k_vyvod сравнивает захваченные bytes с независимыми ожиданиями
К-12: чисто — вход probe208.py run использует subprocess без text-режима
К-13: н/п — вход предмета не содержит секретов
К-14: чисто — --model rc 0 23/0 и честная модель через --repo rc 0 23/0
К-15: чисто — --stabs 64/0 и check_threat_model 6/8 rc 0
К-16: чисто — вход contracts/208-zamok-object-predok.md разделы риска и Модель угроз с решением владельца вариант А
К-17: н/п — sourceCanon и режим архитектурной модели для предмета не объявлены

## Исполнение решения арбитра

`probe208.py:73-78,230-233,267-294`: общий запуск получает stdout/stderr как bytes, обе трубы сравниваются через `k_vyvod` полным равенством; `k_rc` отдельно судит код возврата. Поиск `text=True`, `decode`, `strip`, `splitlines`, `universal_newlines`, `readlines`, `.stdout` и `.stderr` в пробе и носителях не выявил преобразования вывода двери перед сравнением. `plumbing` используется для git-данных мира, `diag` и декодирование в `k_vyvod` — только для диагностики после выявления различия, JSON и исходник модели не являются выводом двери.

Слово владельца в `contracts/208-zamok-object-predok.md`, раздел «Пересечение 140↔208», дословно фиксирует вариант А: судейские несовпадение объекта и повтор роли — отказы по 208, прочие — предупреждения по слову 21.11. Первый буллет НЕ ЗАЩИЩАЕТ указывает на полученное согласие, а не на неразрешённый вопрос. `check_threat_model` rc 0: ЗАЩИЩАЕТ 6, НЕ ЗАЩИЩАЕТ 8.

## Адресные мутации и сырой результат

Команда: `export TMPDIR="$PWD/.scratch-crit208v3"; python3 "$PWD/.scratch-crit208v3/replay.py"`. Одноразовый драйвер в своей копии импортировал существующую пробу, применял по одной мутации модели и вызывал реальные `prognot_kletku` на отдельных мирах r04/r06/r07. Для st20 дополнительно запускал реальную оболочку `--repo <scratch>/subject`, затем туда же помещал честную модель. Сырой результат отдельных проверок ниже: `True` — клетка красная, указана труба.

```text
st20-otkaz-crlf: r04=True stderr, r06=True stderr, r07=True stderr
st21-otkaz-odinochnyj-cr: r04=True stderr, r06=True stderr, r07=True stderr
st22-otkaz-probel-v-konce: r04=True stderr, r06=True stderr, r07=True stderr
st23-otkaz-dvojnoj-lf: r04=True stderr, r06=True stderr, r07=True stderr
st24-otkaz-bom: r04=True stderr, r06=True stderr, r07=True stderr
st25-otkaz-nul: r04=True stderr, r06=True stderr, r07=True stderr
st26-otkaz-ne-utf8: r04=True stderr, r06=True stderr, r07=True stderr
st27-otkaz-lishnij-vyvod: r04=True stderr, r06=True stderr, r07=True stderr
st28-otkaz-perenos: r04=True stdout+stderr, r06=True stdout+stderr, r07=True stdout+stderr
st29-otkaz-lishnij-v-stdout: r04=True stdout, r06=True stdout, r07=True stdout
CRLF --repo rc=1: SUBJEKT 208: KLETKI 23 KRASNYH 12
HONEST --repo rc=0 stdout= b'SUBJEKT 208: KLETKI 23 KRASNYH 0\n'
rc-mutant r04-predok-ne-opublikovan: rc 2 ≠ 1
rc-mutant r06-vperjod-verdikt-hvost: rc 2 ≠ 1
rc-mutant r07-vperjod-ne-opublikovan: rc 2 ≠ 1
REPLAY_RC=0
```

Строки st20–st29 выше сокращают единообразный сырой Python-вывод списков до клетки, логического результата и трубы; исходные длинные результаты с фактическими байтами CRLF сохранены в выводе команды сессии. CRLF-мутант — та же замена существующего `otp` из вызова 2 и адресный st20. Прежние мутации критика CRLF, пробел и двойной LF внесены как st20/st22/st23; их привязки к r04/r06/r07 находятся в source.json и коде. st26 печатает FF, он же не-UTF8 байт. Изменение `exit 1` на `exit 2` в той же `otp` — отдельная адресная проба трёх отказных клеток по rc, не утверждение о наличии для неё зарегистрированного стаба. Его фактический результат — красный, а не обход. `--stabs` дополнительно проверил зарегистрированные st30–st39 на r01 для stdout и st13–st19 для предыдущих исправлений.

## Прогоны

```text
check_sdacha.sh "$PWD" contracts/208-zamok-object-predok.md --run
СДАЧА: лист зелёный (двери=14 карта=17/17 дельта=5)
rc=0
red_zamok_object_predok_208.sh --repo .
SUBJEKT 208: KLETKI 23 KRASNYH 18
rc=1 (ожидается на двери A2 до реализации)
red_zamok_object_predok_208.sh --model
MODEL 208: KLETKI 23 KRASNYH 0
rc=0
red_zamok_object_predok_208.sh --stabs
MODEL 208: KLETKI 23 KRASNYH 0
STABY 208: SVJAZI 64 ZHIVYH 0
rc=0
red_zamok_object_predok_208.sh --sintaksis
SINTAKSIS OK
rc=0
pre_critic.sh contracts/208-zamok-object-predok.md: КРИТИК: дверь зелёная, rc=0
odin_agent_140/red_odin_agent_140.sh --model: MODEL_KLETKI 244 KRASNYH 0, rc=0
parsing_hygiene_battery/run_battery.sh zamok_predmeta: итог 4/4 классов закрыто, rc=0
check_spec_ready rc=0
check_ids rc=0
check_ceilings rc=0
check_provodka --grammar rc=0
check_precision_gate rc=0
check_threat_model rc=0
check_predposylki rc=0
```

## НЕ ЗАЩИЩАЕТ

Отдельные конечные stdout/stderr не сохраняют общей временной хронологии записей между трубами, границы write/read и задержки. Это граница решения арбитра, а не исключение для байтов внутри трубы. Конечная батарея не доказывает эквивалентности произвольной двери на всех входах; ловцы — adversary и reviewer реализации.
