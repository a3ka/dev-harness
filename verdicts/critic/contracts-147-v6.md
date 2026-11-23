accept
OBJECT=13a2de20926dbfc1564d34aaab4f553e7473ab1c

СУД: репо=dev-harness; предмет=147; роль=critic; вызов=2 (scoped); фаза=v6; модель-план=openai-codex/gpt-6.1-terra; модель-факт=openai-codex/gpt-6.1-terra (источник: контекст сессии); предыдущий=archive/147/critic-v6-fail-309e8d84b0; класс риска=обычный

## Закрытие блока вызова 1

Проверена дельта К-05/К-08/К-09/К-10: значение lane приёмки сравнивается с каноном, а не только проверяется на наличие. Источник входа — package.json из зоны 147, исходная операция — `bash mobile/scripts/ci-ekran-gespraech-vhod.sh`. Замена на `echo skipped` на старой батарее OBJECT `dde53fe039b7947b42a715b12f8ad6855a7c4306` дала `REGISTRACIJA_OK`, rc 0; на новой — `PRICHINA LANE_NE_KANON`, rc 1. Честная модель — `REGISTRACIJA_OK`, rc 0. Адресный стаб этой мутации — STAB 11/46, хвоста `|| true` — STAB 12/46; `--stabs` rc 0, 46/46 именованных отказов.

Соседняя мутация на той же модели: значение lane `bash mobile/scripts/ci-ekran-gespraech-vhod.sh; true` → rc 1, `PRICHINA LANE_NE_KANON`. Честная эквивалентная JSON-запись с `\u002e` вместо точки в имени скрипта → `REGISTRACIJA_OK`, rc 0. Дополнительная мутация относится к тому же предикату и отклонена, обхода не обнаружено.

Команда эксперимента: импорт `red_ci_147.py`, `postroj_model` в одноразовый каталог, замена `scripts[LANE_VALIDATORA]` через Python json и запуск `python3 fixtures/workshop_project/gespraech_vhod_147/red_ci_147.py --repo <модель>` для каждого значения. Старая батарея извлечена `git show dde53fe039:fixtures/workshop_project/gespraech_vhod_147/red_ci_147.py` и вызвана `python3 <старый-файл> --repo <та же модель с echo skipped>`.

Сырой вывод:
```
HONEST rc 0 REGISTRACIJA_OK
ECHO rc 1 PRICHINA LANE_NE_KANON: lane ci:ekran-gespraech-vhod: значение 'echo skipped' != канону 'bash mobile/scripts/ci-ekran-gespraech-vhod.sh' — lane обязана побайтово исполнять скрипт приёмки
SEMICOLON rc 1 PRICHINA LANE_NE_KANON: lane ci:ekran-gespraech-vhod: значение 'bash mobile/scripts/ci-ekran-gespraech-vhod.sh; true' != канону 'bash mobile/scripts/ci-ekran-gespraech-vhod.sh' — lane обязана побайтово исполнять скрипт приёмки
REGISTRACIJA_OK
OLD_RC=0
REGISTRACIJA_OK
EQUIV_RC=0
```

Регресс: `red_ci_147.py --model` rc 0 MODEL_OK, `--stabs` rc 0; legacy `red_gespraech_vhod_147.sh --model` rc 0 (геометрия 8/8, legacy 76/76) и `--stabs` rc 0 (геометрия 5/5, legacy 18/18). `check_zone_147.sh`, `check_spec_ready.sh`, `check_ids.sh`, `check_ceilings.sh`, `check_provodka.sh --grammar`, `check_precision_gate.sh`, `check_threat_model.sh`, `check_predposylki.sh`, `check_trek_ekrana.sh` — каждый rc 0. `pre_critic.sh` и `check_sdacha.sh --run` rc 1: единственная причина `последний FAIL 2: карта 0 строк` относится к v5b, закрытой accept; разовое разрешение владельца 23.11, ловец 213. Полная `check_provodka.sh` rc 1 `guard не подключён`; на старом контракте та же причина и rc 1, скрипт и проводка не менялись.

`verify_ci_parity.sh` на копии модели `postroj_model` rc 2 `NOT_IMPLEMENTED: нет .../model/config/ci_parity_exceptions.txt`: эта модель не содержит нужной конфигурации паритета, зелёный результат на ней не заявляется. На собственном дереве харнесса rc 0, расхождений 0. На архиве продукта PR #248 d3a17dd247a2c876890a823686b47304d65370ef rc 1, расхождений 172 — равно базовому замеру, указанному в листе. Продукт и исключения не менялись.

## Карта классов

К-01: чисто — pre_critic и check_sdacha rc 1 только по разрешённой причине прошлого FAIL
К-02: чисто — вход слово владельца 22.11 и дельта листа 147
К-03: чисто — вход frozen 147/5 не изменён дельтой
К-04: чисто — check_zone_147.sh rc 0
К-05: чисто — критерий 4 и red_ci_147.py --stabs rc 0
К-06: чисто — вход red_ci_147.py явно различает NOT_IMPLEMENTED rc 2
К-07: чисто — red_ci_147.py --model и --repo честной модели rc 0
К-08: чисто — echo skipped новая батарея rc 1 LANE_NE_KANON
К-09: чисто — подмена lane через JSON и отказ LANE_NE_KANON rc 1
К-10: чисто — semicolon true rc 1 и стаб подавления 12/46 красен
К-11: чисто — вход MODEL_PKG загружается до чтения продукта
К-12: чисто — вход json и PyYAML используют штатные разборщики
К-13: н/п — секреты не входят в изменённый предикат
К-14: чисто — эквивалентный JSON escape даёт REGISTRACIJA_OK rc 0
К-15: чисто — red_ci_147.py --stabs rc 0 и вывод 46/46
К-16: чисто — check_threat_model.sh rc 0 и риск обычный
К-17: н/п — дельта не вводит схем и операций архитектуры 188

## Блоки

Блокирующих находок в scoped-области нет. Побайтовая форма значения lane — прямо названное обязательство, поэтому произвольная shell-эквивалентность значения вне объявленной формы не является честным входом этого предиката.

## НЕ ЗАЩИЩАЕТ

Значения `ci:artefakt-*` проверяются здесь только на существование; ловец — семья 197. Само тело продуктового скрипта приёмки, эмулятор, Maestro и визуальную сверку эта модель не исполняет: ловцы — приёмочный валидатор и ревьюер продукта. Красную дверь прошлого FAIL исправляет предмет 213; разовое разрешение владельца не заменяет её ремонта. Паритет неполного модельного мира не доказан, rc 2 указан выше.
