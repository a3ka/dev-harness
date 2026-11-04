FAIL
OBJECT=d32a0612e2bee9b697faec9fbac5f0346b30da57
СУД: repo=dev-harness; предмет=159; фаза=контракт (+красная батарея/спецификация); роль=critic; вызов=3/5; модель-план=openai-codex/gpt-6-sol; сессия=Crit159c; модель-факт=openai-codex/gpt-6-sol; SHA=d32a0612e2bee9b697faec9fbac5f0346b30da57; предыдущий=Crit159b FAIL (a9642253e31b82e416641e406cf524f5373cba63); исключение=нет.

Судится коммит: `git -C /home/harness/dev-harness cat-file -t d32a0612e2bee9b697faec9fbac5f0346b30da57` → rc 0, `commit`; архив OBJECT извлечён отдельно. Автор Arch159c — zai/glm-5.3, модель судьи из runtime — openai-codex/gpt-6-sol; семейства различны. Независимую сверку session-id/model-fact с трейсом до материализации проводит оркестратор. Класс риска «обычный» соответствует предмету. Судились закрытие классов Crit159b и последствия новой семантики rc 2/наблюдателя.

## Блокирующие находки

БЛОКИРУЕТ contracts/159-pustoj-produkt-krasnyj.md:30-31,36,42 — исполнение собственной клетки ПОСЛЕ отказа гейта судится только по лишней строке вывода. Класс причины: наблюдатель заменяет факт исполнения собственных клеток на наличие их stdout/stderr или устойчивого изменения дерева; тихая собственная клетка остаётся невидимой. Это остаток класса Б3 Crit159b, а не требование новой границы риска.
ОБЯЗАТЕЛЬСТВО: «после отказа гейта батарея собственных клеток не запускает»; сценарий 4 объявляет доказательством этого свойства зелёный `W`.
СОСТОЯНИЕ: на каждом из пяти допустимых базовых пустых R действительный `model/gate_tracer.sh` сначала пишет одну трассу и выдаёт правильные причину/rc 1; батарея затем выполняет собственную клетку в памяти без печати и без изменения `baza`, после чего возвращает тот же rc.
НАБЛЮДЕНИЕ: `python3 /tmp/dev-harness-verify/Crit159c/silent_cell_sample.py` → rc 0, все пять вызовов того же `probe.sudit_provodku`, который составляет W-клетки, дают `OK` при исполненном после отказа собственном вычислении. Сырой вывод:
```
a-forma-pusta ('OK', 'PUSTOJ_PRODUKT: FORMA_PUSTA', 1)
b1-pustoj-katalog ('OK', 'PUSTOJ_PRODUKT: KATALOG_PUST', 1)
b2-otsutstvujushchij ('OK', 'PUSTOJ_PRODUKT: KATALOG_OTSUTSTVUET', 1)
v-karta-bez-celej ('OK', 'PUSTOJ_PRODUKT: KARTA_BEZ_CELEJ', 1)
g-koren-bez-soderzhimogo ('OK', 'PUSTOJ_PRODUKT: KOREN_BEZ_SODERZHIMOGO', 1)
```
ОБХОД: реализация с общим гейтом первым, но с тихими собственными проверками после его отказа удовлетворяет всем 20 проводочным клеткам `W` и нарушает прямое обязательство об отсутствии этих проверок. `s8` ловит только вариант, который *печатает* `CASE`.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: при отказе гейта собственная клетка не исполняется, в том числе без вывода/устойчивого изменения дерева; отрицательный контроль именно такого исполнения красен, честный ранний выход зелён. Это свойство, не единственный предписанный способ наблюдения.

БЛОКИРУЕТ contracts/159-pustoj-produkt-krasnyj.md:30,38-42 — требуемый проброс rc 2 гейта батареями не доказан и прямо инвертирован судьёй проводки. Класс причины: W-слой охватывает только пять rc-1-входов; на rc-2-входе `sudit_provodku` отвергает честный rc 2 ДО проверки трассы, а ложный rc 1 принимает при совпавшей строке `NECHITAEMO`.
ОБЯЗАТЕЛЬСТВО: «rc 2 гейта передаётся как rc 2 (fail-closed, не зелень)» каждой из четырёх `--repo`-ветвей; критерию нужна команда с различением правильного и ложного проброса. Проверка самого гейта на d-входах не доказывает код батареи.
СОСТОЯНИЕ: ошибку доступа к карте поднимает объявленная симуляция `PUSTOJ_PRODUKT_SIMULIRUJ_DOSTUP=karta`. Честный стенд-гейт возвращает rc 2 `PUSTOJ_PRODUKT: NECHITAEMO`, проводка подменяет только код 2→1 без искажения трассы и причины. Для одноразового свидетеля карта оставлена читаемой наблюдателю-снимальщику: он работает без root, а при chmod 000 сам не может составить снимок (до суда причины). Симуляция моделирует разрешённый root-режим. Базовые rc-1-входы W от подмены не меняются.
НАБЛЮДЕНИЕ: `python3 /tmp/dev-harness-verify/Crit159c/rc2_sample.py` → rc 0; сырой вывод одного и того же `probe.sudit_provodku`:
```
faithful ('SUBEKT_RC2', 'rc=2 (fail-closed — не зелень)', 1)
rc2-to-rc1 ('OK', 'PUSTOJ_PRODUKT: NECHITAEMO', 1)
```
ОБХОД: гейт честен, W-гейт-клетка подтверждает rc 2 на d-входах, а все четыре батареи заменяют только его rc 2 на rc 1: нынешний W проходит базовые 20 клеток, хотя обязательный проброс не сделан.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: проверяемые `--repo`-ветви сохраняют rc 2 гейта как rc 2 на достижимой ошибке доступа; изменённый rc 1 красен, честный rc 2 судится отдельно как ожидаемый fail-closed, без потери красного состояния исходной инфраструктуры 151.

Спора автора с предыдущими находками не предъявлено: второго арбитража из одного лишь FAIL не созываю (§Быстрый-процесс §Остановка). Исправления четырёх прошлых примеров c3/d1–d3/s7–s9 видны в `--model`/`--stabs`; новые блоки — оставшаяся неполнота доказательства, а не повтор числа клеток.

## Команды и наблюдения на OBJECT

- `bash fixtures/workshop_project/pustoj_produkt_159/red_pustoj_produkt_159.sh --model` → rc 0: `CASE m-c3-vneshnij-src-simlink ok`, `CASE m-c4-karta-simlink ok`, `CASE m-c5-forma-simlink ok`, `CASE m-d1-karta-nechitaema ok`, `CASE m-d2-src-nechitaem ok`, `CASE m-d3-forma-nechitaema ok`, `CASE m-konformnyj ok`; итог `клеток 21, зелёных 21, красных 0; режим model`.
- `bash fixtures/workshop_project/pustoj_produkt_159/red_pustoj_produkt_159.sh --stabs` → rc 0: `STAB s6_sleduet_simlinku_src.py POJMAN vetka=BATAREJA_ZELENA_NA_PUSTOM na c3-vneshnij-src-simlink`; `STAB s7_pobochnyj_effekt_do_gejta.py POJMAN vetka=POBOCHNYJ_EFFEKT na a-forma-pusta`; `STAB s8_kletki_posle_otkaza.py POJMAN vetka=KLETKI_POSLE_OTKAZA na a-forma-pusta`; `STAB s9_ne_takoj_rc.py POJMAN vetka=RC_NE_1 na a-forma-pusta`; `SVJAZI 9`; итог `клеток 21, зелёных 21, красных 0; режим stabs`. Все девять вариантов пойманы своими заявленными ветвями; сами s8/s9 не покрывают два контрпримера выше.
- `bash fixtures/workshop_project/pustoj_produkt_159/red_pustoj_produkt_159.sh` → rc 1: `CASE s-gate-v-dereve KRASNO SUBJECT_ABSENT scripts/check_pustoj_produkt.sh`; `CASE W-gespraech_otdacha_151/a-forma-pusta KRASNO SUBEKT_RC2 rc=2 (fail-closed — не зелень)`; `CASE W-gespraech_tekst_149/a-forma-pusta KRASNO GATE_NE_VYZVAN записей трассы 0 (ожидалась одна с этим R)`; `CASE W-gespraech_vhod_147/a-forma-pusta KRASNO VREMJA_ISTEKLO субъект завис`; итог `клеток 23, зелёных 0, красных 23; режим derevo`. При параллельных прогонах фактическое распределение: 3 SUBJECT_ABSENT, 7 GATE_NE_VYZVAN, 8 VREMJA_ISTEKLO, 5 SUBEKT_RC2 (в отчёте автора без этой нагрузки — 3/15/0/5). Не выдаю таймаут за подтверждение отсутствия вызова гейта и не блокирую самоописанные числа.
- `bash scripts/check_precision_gate.sh . contracts/159-pustoj-produkt-krasnyj.md` → rc 0, `OK` (после добавления git-метаданных и frozen-тегов в архив; первый вызов на голом архиве → rc 2 `NOT_IMPLEMENTED: ... не репозиторий git`). `bash scripts/check_threat_model.sh . contracts/159-pustoj-produkt-krasnyj.md` → rc 0: `модель угроз: секция валидна (ЗАЩИЩАЕТ 12 буллет(ов), НЕ ЗАЩИЩАЕТ 8 буллет(ов))`. `bash scripts/check_spec_ready.sh . contracts/159-pustoj-produkt-krasnyj.md` → rc 0 `OK`. `bash scripts/pre_critic.sh --repo . contracts/159-pustoj-produkt-krasnyj.md` → rc 0 `КРИТИК: дверь зелёная` (+ `PREDPOSYLKI_OK`).
- `bash scripts/check_ceilings.sh .` → rc 1: единственный отказ `FAIL контракт ./contracts/158-ekrannyj-nabor.md (82 байт): нет раздела «Незаполненные требования:»`; о 159 отказа нет. `bash scripts/check_provodka.sh . contracts/159-pustoj-produkt-krasnyj.md` → rc 1, `проводка: guard не подключён: fixtures/workshop_project/pustoj_produkt_159/red_pustoj_produkt_159.sh не вызывается в .githooks/ или .github/workflows/` — до реализации ожидаемо.
- `bash scripts/check_zones.sh --incr /tmp/dev-harness-verify/Crit159c/zones-cache-159` → за 360 с полного исторического прохода (кеш отсутствует) не завершился, `Command timed out after 360 seconds`; зелёным НЕ объявляю. `bash scripts/check_precision_gate.sh` проверил текущие пересечения rc 0; из frozen `140/1` прочитаны ЗОНА architect/implementer/critic/orchestrator, из frozen `147/1`, `148/1`, `149/1`, `151/1` — `ЗОНА architect` для четырёх fixture-семей; все четыре `ПЕРЕСЕЧЕНИЕ implementer` в 159 объявлены. Полная историческая проверка зон не подтверждена.
- Регрессии: `bash fixtures/workshop_project/gespraech_vhod_147/red_gespraech_vhod_147.sh --model` и `--stabs` → rc 0, `клеток 71, зелёных 71, красных 0`; `bash fixtures/workshop_project/vkladki_tabov_148/red_vkladki_tabov_148.sh --model` → rc 0, `клеток 44, зелёных 44, красных 0`; `bash fixtures/workshop_project/gespraech_tekst_149/red_gespraech_tekst_149.sh --model` и `--stabs` → rc 0, `клеток 85, зелёных 85, красных 0`. `W148 --stabs` в параллельном окне не завершился за timeout 240 с после `клеток 44, зелёных 44, красных 0` и нескольких `STAB ... KRASEN`: итог SVJAZI/rc не получен.

## Не проверено

- Полный исторический `check_zones.sh`: timeout 360 с; локальные точные пересечения подтверждены precision-гейтом и чтением frozen-текстов, но не заменяют полного барьера.
- Результат `W148 --stabs` целиком: timeout 240 с на фоне параллельной работы; зелёный исход этого режима не утверждается.
- Зелёный полный `W` на настоящих четырёх ленднутых `--repo`-ветвях, живой продукт/A-дерево и CI-проводка: их нет на исходном OBJECT; проверки стенд-гейта не выдаются за продуктовый результат.
- Фактический trace session-id/fallback недоступен изолированному судье: указан agent-id `Crit159c` и модель исполнения, сообщённая runtime; перед материализацией требуется независимая сверка трейсом, иначе вердикт не материализуется.
