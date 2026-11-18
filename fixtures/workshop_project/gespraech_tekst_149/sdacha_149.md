# СДАЧА 149 — закрытие К-04 Crit149V6: точная продуктовая зона

Кандидат поверх `5e87fd56e6efa5481c52828970b7f8611b4ff4b8`.
Источник дельты — вариант А консультанта Cons149Zone, §1–2,
и задание `/tmp/dev-harness-verify/task-149-architect-zone.md`.
Предмет — раздача уже обязательного производного motion-spec по И-12,
не реализация продукта и не изменение батарей геометрии/регистрации.
Привязки негативных образцов к ветвям остаются только в коде
`red_geo_149.py:stabs` и `red_ci_149.py:STABY` (Н-39).
Контракт несёт инварианты и rc-команды, лист — исполненные проверки и границы.

Грамматика машинных таблиц ниже принадлежит `check_sdacha.sh`:
`- К-NN · статус · команда/вход · rc · rc`.
В том же разделе дано представление `К-NN: статус — хвост` для
`lib_karta_sdachi.sh`; это одна карта в двух форматах существующих потребителей,
не две независимые привязки негативных образцов.
ПРЕДЫДУЩИЙ ВЕРДИКТ: verdicts/critic/contracts-149-v5.md

## Двери

- pre_critic · bash scripts/pre_critic.sh contracts/149-gespraech-tekst-chat.md · 0 · 0
- geometry-model · fixtures/workshop_project/gespraech_tekst_149/red_geo_149.py --model · 0 · 0
- geometry-stabs · fixtures/workshop_project/gespraech_tekst_149/red_geo_149.py --stabs · 0 · 0
- geometry-archive · fixtures/workshop_project/gespraech_tekst_149/red_geo_149.py --spec fixtures/workshop_project/gespraech_tekst_149/nositeli/d24/spec.json · 1 · 1
- registration-model · fixtures/workshop_project/gespraech_tekst_149/red_ci_149.py --model · 0 · 0
- registration-stabs · fixtures/workshop_project/gespraech_tekst_149/red_ci_149.py --stabs · 0 · 0
- predposylki · bash scripts/check_predposylki.sh . contracts/149-gespraech-tekst-chat.md · 0 · 0
- zone-allocation · bash fixtures/workshop_project/gespraech_tekst_149/check_zone_149.sh · 0 · 0

## Карта классов

К-01: чисто — bash scripts/pre_critic.sh contracts/149-gespraech-tekst-chat.md; rc 0.
К-02: чисто — вход: геометрический источник Kompakt-1.1 и слово ~14:05; времена/кривые/прерывания/УД/позы и T32/T18/T19 сохранены.
К-03: чисто — вход: адресная замена Final2-геометрии перечислена в «Снятие замороженных норм»; архив/source.json/зонд и набор 158 неизменны.
К-04: чисто — bash fixtures/workshop_project/gespraech_tekst_149/check_zone_149.sh; rc 0: точный файл, границы оригиналов и соседнего -147, исполнение после freeze без повторной раздачи.
К-05: чисто — вход: И-12 и критерий 7 несут --model/--stabs/--repo/--spec с именованным результатом и rc.
К-06: чисто — вход: отказ предпосылки оракула/Chrome — NOT_IMPLEMENTED rc 2; отсутствующий spec субъекта — именованный rc 1.
К-07: чисто — fixtures/workshop_project/gespraech_tekst_149/red_geo_149.py --model; rc 0.
К-08: чисто — fixtures/workshop_project/gespraech_tekst_149/red_ci_149.py --stabs; rc 0, включая RABOTNIK_BEZ_USTANOVKI; геометрические ветви проверены --stabs.
К-09: чисто — вход: обе темы, оба конца прямоугольника, nav, adaptive caps/top/rule; сохранённая часть сцены сравнивается целиком; область — И-12.
К-10: чисто — вход: геометрия — структурные числа resolved, не фраза «Против1.0» и не минимум высоты; это источник, не эффект RN-рендера.
К-11: чисто — вход: геометрия и архив с sha256 снимаются в память до субъекта; MODEL_YML регистрации — в харнессе, не продукте.
К-12: чисто — вход: JSON разбирается стандартным json, YAML — yaml.safe_load; геометрия и сохранённые поля сравниваются с каноном.
К-13: чисто — bash scripts/check_predposylki.sh . contracts/149-gespraech-tekst-chat.md; rc 0, PILOT_DEMO_CODE сохранён.
К-14: чисто — fixtures/workshop_project/gespraech_tekst_149/red_geo_149.py --stabs; rc 0, честный контроль и эквивалентные JSON-ключи/числа зелены.
К-15: чисто — вход: STABY 68 / 68 HONEST_CONTROLS 2; регистрация STAB 50/50; архивный зонд 96/96 и SVJAZI 19; сырые замеры ниже.
К-16: чисто — вход: класс риска обычный, новых полномочий/секретов нет; статическая проверка не доказывает живой рендер, ловец — продуктовый работник/vision-суд.
К-17: н/п — tooling/checks/cli.js и закреплённая модель 188 в этом дереве отсутствуют; продуктовая схема операций не меняется.

- К-01 · чисто · bash scripts/pre_critic.sh contracts/149-gespraech-tekst-chat.md · 0 · 0
- К-02 · чисто · вход: Kompakt-1.1, слово ~14:05; времена/кривые/прерывания/УД/позы и T32/T18/T19 сохранены · - · -
- К-03 · чисто · вход: адресная замена Final2-геометрии в «Снятие замороженных норм»; архив/source.json/зонд и набор 158 не меняются · - · -
- К-04 · чисто · bash fixtures/workshop_project/gespraech_tekst_149/check_zone_149.sh · 0 · 0
- К-05 · чисто · вход: критерий 7 — --model/--stabs/--repo/--spec и именованные rc · - · -
- К-06 · чисто · вход: NOT_IMPLEMENTED rc 2 для отказа предпосылки оракула/Chrome; SPEC_NET_ILI_NE_JSON rc 1 для субъекта · - · -
- К-07 · чисто · fixtures/workshop_project/gespraech_tekst_149/red_geo_149.py --model · 0 · 0
- К-08 · чисто · fixtures/workshop_project/gespraech_tekst_149/red_ci_149.py --stabs · 0 · 0
- К-09 · чисто · вход: обе темы, оба конца, nav и adaptive; сохранённая часть сцены сравнивается целиком; область И-12 · - · -
- К-10 · чисто · вход: resolved-прямоугольники — структурные числа, не строка-маркер и не min-height; эффект рендера вне этой проверки · - · -
- К-11 · чисто · вход: геометрия/архив запинены и сняты до субъекта, MODEL_YML встроен в харнесс · - · -
- К-12 · чисто · вход: стандартные json/yaml.safe_load и структурное сравнение с каноном · - · -
- К-13 · чисто · bash scripts/check_predposylki.sh . contracts/149-gespraech-tekst-chat.md · 0 · 0
- К-14 · чисто · fixtures/workshop_project/gespraech_tekst_149/red_geo_149.py --stabs · 0 · 0
- К-15 · чисто · вход: STABY 68/68, HONEST_CONTROLS 2, регистрация STAB 50/50; числа — из сырых прогонов ниже · - · -
- К-16 · чисто · вход: обычный риск; НЕ ЗАЩИЩАЕТ от расхождения живого RN-рендера, ловец — продуктовый работник/vision-суд · - · -
- К-17 · н/п · tooling/checks/cli.js и закреплённая модель 188 отсутствуют; схема операций продукта не меняется · - · -

## Дельта

Относительно `5e87fd56e6`: добавлена точная продуктовая ЗОНА implementer
одного производного файла -149.json и граница неизменности оригиналов/-147.
Незаполненное требование ссылается на уже объявленную зону:
исполнение остаётся после freeze в том же продуктовом PR, раздача не отложена.
И-1…И-12, критерии, батареи и продукт не меняются.

- К-04 · канон/инструмент · bash fixtures/workshop_project/gespraech_tekst_149/check_zone_149.sh · 0 · 0

Доказательство — стандартный `grep -Fxq` по точной строке зоны, полной границе
и строке оставшегося исполнения; текст сверки взят из задания/решения А.
Отдельный короткий файл команды необходим по грамматике check_sdacha.sh:
она исполняет argv файла, а не shell-выражение в поле таблицы.
До правки контракт не проходит эту же команду (сырой rc 1); после правки — rc 0.
Новых предикатов батарей, клеток и обязательств нет.

## Замеры v+6 (2026-11-18)

Исторические замеры геометрического кандидата ниже сохранены как происхождение,
а не выданы за повторные измерения этой дельты.

Все команды проверки исполнены из изолированной копии architect.
`R=/tmp/dev-harness-verify/Impl149Fix/mob`, HEAD
`4205358b45eb9f0bc6d0779ca76db3071cc9e9ff` (git rev-parse HEAD, rc 0).
Временные миры проверок создавались в TMPDIR внутри этой копии, не в продукте.

| Команда (путь относительно gespraech_tekst_149) | Фактический rc | Сырой результат |
|---|---:|---|
| red_geo_149.py --model | 0 | GEOMETRIJA_KOMPAKT_11 |
| red_geo_149.py --stabs | 0 | STABY 68 / 68 HONEST_CONTROLS 2; каждый observed == EXPECTED |
| red_geo_149.py --spec nositeli/d24/spec.json | 1 | PRICHINA PRJAMOUGOLNIK_T30 |
| red_geo_149.py --repo R | 1 | PRICHINA SPEC_NET_ILI_NE_JSON |
| red_ci_149.py --model | 0 | MODEL_OK |
| red_ci_149.py --stabs | 0 | MODEL_OK; STAB 1/50 … 50/50, собственные PRICHINA |
| red_ci_149.py --repo R | 0 | REGISTRACIJA_OK |
| probe.py --model | 0 | клеток 96, зелёных 96, красных 0; режим model seed 149 |
| probe.py --stabs | 0 | SVJAZI 19; клеток 96, зелёных 96, красных 0; режим stabs seed 149 |
| probe.py --repo R | 1 | s-ekran-ispolnim KRASNO ISPOLNIMYJ_KONTROL_KRASEN; упавших ассертов 53; клеток 96, зелёных 95, красных 1 |
| check_predposylki.sh <копия> contracts/149-gespraech-tekst-chat.md | 0 | PREDPOSYLKI_OK secrets=1 variables=0 environments=0 settings=6 |
| measure_geo_149.py R/docs/ux/05_Kompakt_D24 | 2 | NOT_IMPLEMENTED: Chrome не открыл CDP |

Зонд `probe.py` прогнан только как запрошенная диагностическая регрессия;
он не включён в машинные двери и приёмкой лёгкого трека не объявлен.
Его красный живой контроль не чинится переобучением source.json/зонда:
устаревшие имена наблюдателей — отдельный вопрос оракула, сохраняющееся
поведение продукта — зона implementer по действующим инвариантам.
Красный --repo новой геометрии означает отсутствие нового источника в R,
а не дефект регистрации: на том же R регистрация даёт REGISTRACIJA_OK.

`sha256sum` геометрического носителя →
`ec4b8607e73995533d1bf36e0c71f4703daff5880d6e0d607ca2934e03acd94a`,
архивного spec → `064d7821428f425d431fbd1efd65cbec37263bb62ef974924746a07e769cd318` (rc 0).
Оба совпадают с пинами кандидата.

Замеры исходного патча Arch149Geo (не новый успешный рендер этой копии):
Chrome, fonts.ready + 2 rAF, обе темы, 390:
T30 [35,575,320,52]→[68,452,250,48]; T34 [16,322,173,44]→[16,768,358,60];
T08 [217.3125,673,156.6875,44]→[16,768,358,60];
T37 [16,768,358,60]→[68,735,250,48]; T17 [68,438,250,62]→[16,768,358,60].
Шапки — 52 и 111 (393). Повторный замер здесь дал rc 2 выше;
это не выдаётся за подтверждённый повтор Chrome-измерения.

## Развилки

Статический источник и пин в продукте отсутствуют до работы implementer;
--repo новой геометрии остаётся будущей продуктовой приёмкой.
Точная зона для доставки уже раздана контрактом; оригиналы и -147 не затрагиваются.
Строку владельца, freeze и CI-проводку выполняет orchestrator; push не делается.
Журнал NABLIUDENIA_ARCHITECT.md не правится в wip-ветке и вне зоны.
Процессное наблюдение для main: таблица check_sdacha исполняет только argv файла;
для доказательства текстовой дельты требуется адресный файл команды, не shell в листе.
РЕШЕНО (знак 20 — слово владельца 2026-11-18 ~19:35 UTC, решено с дизайнером): размер знака в Kompakt = 20 px по `motion-delta.md:22` (40→32 над вопросом); расхождения `manifest.json:106` (28→24) и `tokens.json` presence-mini/presence.figure (28, s28→24px) — несогласованность пакета, исправляется в предмете моба №14 (единая машинная motion-spec Kompakt), не альтернатива; батарея и замеры (20↔32) держат 20; движок 145 этой пачкой не меняется.

## Фактические двери формы

Копия текущего прогона:
`/home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/tcdacd044e/m`,
ветка `wip/149/architect`, база `5e87fd56e6efa5481c52828970b7f8611b4ff4b8`.
`TMPDIR` равен корню этой копии; временные миры остаются внутри неё.

| Команда | Сырой rc | Вывод |
|---|---:|---|
| bash fixtures/workshop_project/gespraech_tekst_149/check_zone_149.sh (до правки контракта) | 1 | пустой stdout |
| bash fixtures/workshop_project/gespraech_tekst_149/check_zone_149.sh (после правки) | 0 | ZONA_149_VYDANA |
| bash /home/harness/dev-harness/scripts/check_sdacha.sh <копия> contracts/149-gespraech-tekst-chat.md --run | 0 | СДАЧА: лист зелёный (двери=8 карта=17/17 дельта=1) |
| bash /home/harness/dev-harness/scripts/pre_critic.sh --repo <копия> contracts/149-gespraech-tekst-chat.md | 0 | КРИТИК: дверь зелёная |
| fixtures/workshop_project/gespraech_tekst_149/red_geo_149.py --model | 0 | GEOMETRIJA_KOMPAKT_11 |
| fixtures/workshop_project/gespraech_tekst_149/red_geo_149.py --stabs | 0 | STABY 68 / 68 HONEST_CONTROLS 2 |
| fixtures/workshop_project/gespraech_tekst_149/red_ci_149.py --model | 0 | MODEL_OK |
| fixtures/workshop_project/gespraech_tekst_149/red_ci_149.py --stabs | 0 | MODEL_OK; STAB 1/50 … 50/50 |

Последние четыре команды дополнительно исполнены последовательной цепочкой `&&`;
общий сырой rc 0, каждая команда достигнута. Машинные двери листа также
перепрогнали неизменённые geometry-archive (ожидаемый rc 1) и predposylki (rc 0).
Продуктовый --repo, Chrome и архивная батарея цикла 2 в этой дельте не запускались.
Исторический done-отказ проводки не пересматривается этой пачкой:
CI-подключение guard остаётся объявленной зоной orchestrator в freeze..done,
вне зоны данной пачки; изменение CI и ослабление проверки не выполняются.
