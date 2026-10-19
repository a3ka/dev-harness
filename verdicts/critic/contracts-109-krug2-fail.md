FAIL
OBJECT=89711b3a21c32e873a9d21340591dba798a99ced

# Критик 109 — круг 2

Предмет: закоммиченный `contracts/109-cmp-bck-004-stend-evidence.md` и названная им батарея `fixtures/workshop_project/stend_109/probe.py`. HEAD клона совпал с OBJECT. Набор полный: предмет, критерий с командами, исполнители и зоны есть. План/контракт/роль не менялись. Complior-back получен по SSH и выставлен на B `9d960a0543eb36696b1d767bf208416e774f0a32`; исходный `back` после checkout использовался только для чтения. Issue #5 получен через `gh issue view`; семь критериев сверены.

Итог: старые конкретные обходы действительно стали красными; однако остаются **три блокирующих обхода**, перечисленные ниже одним пакетом. На каждой новой контрмодели полная батарея возвращает rc 0, `control_green=true`, **все пять фактов true**, 25 `REJECTED_EXACT`, 0 blocked, 0 not_rejected. Это не эксплуатация NEEDS_ENV и не зелёный одиночный `--case` на красной базе.

## Граница доказательства

Модели — одноразовые деревья для суда над приёмкой, НЕ готовый стенд C. За основу взята копия модели архитектора `/tmp/dev-harness-verify/Architect109/modelC`; её исходная батарея независимо исполнена и дала rc 0. В модель вносилась только указанная ниже дельта. PostgreSQL18/TCP suite и полный `docker compose up` этих моделей не запускались; успешное прохождение строк 4–5 целиком НЕ заявляется. Для каждого обхода отдельно объяснено, почему явно перечисленные наблюдения этих строк его не исключают; этот перенос на полноценное C помечен `[INFERENCE]`.

Критик судит недостающие наблюдения в контракте, а не качество незавершённой модели архитектора. Поэтому ошибки/упрощения этой модели вне предъявленных дельт не предъявляются как дефекты будущей реализации.

## Старый пакет БР1–БР4

| Причина круга 1 | Что исполнено в круге 2 | Вывод |
|---|---|---|
| БР1: неиспользуемая internal-сеть, document-worker на default | Точные bytes старого compose перенесены на зелёную контрольную модель; полная батарея rc 1, `COMPOSE_EGRESS_OPEN`, `EGRESS_GUARD=false`, `document-worker→default` | Конкретный старый обход закрыт |
| БР2: `const drill = {rpo: 15, rto: 240, state: 'NOT_RUN'};` | Исходный старый файл исполнен в полном старом дереве; дополнительно те же bytes под именем подключённого `drill-measure.js` на зелёной модели: структурный контроль зелён, `DRILL_EVIDENCE_GUARD=false`, rc 1, сохранённого status нет | Старый мёртвый collector закрыт; разрыв настоящего вызова остаётся — Б2 ниже |
| БР3: старый `module.exports.record` без кортежа | Полное старое дерево и изолированная замена harness точными bytes: rc 1, `HARNESS_TUPLE_GUARD=false`, `recordInteraction is not a function` | Старый файл отвергается, в том числе новым обязательным интерфейсом; сохранённый sink ещё не доказан — Б1 |
| БР4: отказ `check_provodka` | На OBJECT `check_provodka.sh` rc 0; `pre_critic.sh` rc 0; внешние CI-пути и implementer названы | Прежнее нормативное основание снято; будущая проводка продуктового CI не объявляется уже выполненной |

Старый сохранённый marker-tree включал также последующее стирание двух historical-файлов. Исполнены ОБА состояния: точная сохранённая копия (дополнительно красный ROOT_SERVER_PRESENT) и копия с восстановленными bytes B (ROOT_SERVER_PRESENT=true; три новых живых факта всё равно false). Это не подмена первоначального обхода более лёгкой мутацией.

## Блокирующие находки — весь пакет

### Б1. Зелёный возвращённый кортеж не означает сохранённое HTTP/SQL evidence

БЛОКИРУЕТ contracts/109-cmp-bck-004-stend-evidence.md:46 — факт, объявленный доказательством кортежа/manifest (также строки 35, 49–50), проверяет возвращённое значение `recordInteraction`, но не значения осей в сохранённых файлах. Реализация факта: `probe.py:572–587` читает `entries`, а `:588–597` проверяет у файлов только число, сохранение первого и отсутствие трёх sentinel-строк.

ОБХОД: вернуть полностью правильный кортеж и SHA-256 вызывающему, а в каждый новый evidence-файл записать `{}`. Получить все пять зелёных фактов и 25/25, хотя сохранённое evidence не содержит ни HTTP, ни SQL, ни роли, ни provider count, ни manifest.

**Обход:** возвращаемый объект подменяет проверку фактического sink.

**Конкретное дерево:** `sink-decoy/` — копия зелёной модели, единственная дельта в `backend/tests/helpers/harness.js`: `fs.writeSync(fd, text);` → `fs.writeSync(fd, '{}');`. Сериализация/scrubber, эксклюзивное открытие, правильный return и все маркеры сохранены. Полная батарея rc 0; `--matrix` rc 0; каждый из 25 `--case` rc 0; `--case nonexistent` rc 2. Независимая команда `node observe_sink.cjs` → rc 0: возвращены шесть разных значений осей и SHA-256 `5ac4ae11f60260b146ac77d6a004d8cf68737a4cf5fe1be4f56ad67c0fa9b092`, сохранённый файл — буквально `{}` (`sink-observed.json`).

`[INFERENCE]` В полноценном C та же дельта не меняет TCP, SQL role/context isolation, отсутствие DDL-учёток, DB-down или compose. Пустые JSON-файлы append-only и не содержат sentinel, то есть дополнительные наблюдения строки 49 также не исключают обход. Именно доказательство содержимого sink в критерии отсутствует.

**Простейшая форма фикса:** проверять кортеж и manifest из фактически сохранённого JSON, связанного с тем же наблюдённым взаимодействием, а не из return. В живой TCP/SQL строке нужен путь «наблюдённый запрос/SQL/роль/provider → сохранённая запись», иначе правильный сериализатор произвольного входного объекта ещё не доказывает происхождение evidence. Красный свидетель: правильный return + пустой/чужой sink. Привязку свидетеля к исполняемой ветви делает architect по коду, не проза контракта.

### Б2. Живой collector можно оставить не подключённым ни к одному запуску стенда

БЛОКИРУЕТ contracts/109-cmp-bck-004-stend-evidence.md:50 — критерий #5 замкнут на standalone `DRILL_EVIDENCE_GUARD`, но не на появление drill-evidence в результате запуска стенда/harness. Инвариант строки 38 требует именно исполняемый провод. В `probe.py:326–330` проводка = basename где-либо в package.json/harness/тесте; `:463–473` затем отдельно запускает первый найденный collector в disposable-каталоге самого проверяющего.

ОБХОД: сохранить честный работающий collector, удалить его вызывающий npm-script и вызов из integration-теста, оставить basename только в поле `description` package.json. Standalone факт сам запустит collector и станет зелёным; evidence обычного запуска стенда останется без drill-результата и даже без NOT_RUN.

**Обход:** факт существования исполняемого CLI принимается за его подключение к поставляемому пути evidence.

**Конкретное дерево:** `drill-unwired/`: удалён `scripts["drill:evidence"]`, из integration-файла удалён `require('../../scripts/drill-measure.js')`, `description="drill-measure.js"`. Сам collector не изменён, других ссылок-вызовов в модели нет; integration-файл сохраняет подключение harness. Полная батарея rc 0, пять фактов true, 25/25. Известные CLI-входы действительно исполняются и создают корректные временные файлы — но только по инициативе батареи, не по пути стенда.

`[INFERENCE]` На полноценном C можно сохранить все TCP/SQL/DB-down/scrubber проверки строки 49 и compose строки 48, удалив лишь invocation collector. Ни одна названная живая строка не требует найти drill-evidence в каталоге этого же запуска: строка 49 снова ссылается на standalone факт. Критерий зелён, а требуемый исполняемый провод отсутствует.

**Простейшая форма фикса:** проверять появление drill-evidence через реальную точку входа поставки и в её каталоге evidence: без входа — сохранённый NOT_RUN, с входом — точные измерения. Проверка только наличия basename не должна заменять этот вызов. Красный свидетель — полностью рабочий collector без вызывающего пути, с названием в метаданных.

### Б3. FIXTURE и SYNTHETIC можно сохранять как RUNTIME

БЛОКИРУЕТ contracts/109-cmp-bck-004-stend-evidence.md:46 — критерий должен доказывать различение режимов из предмета строки 27 и инварианта строки 37, но обе живые записи `HARNESS_OBS` имеют только `mode='RUNTIME'` (`probe.py:507–521`), а `mode` вообще не входит в сравниваемые поля `:578–579`. `harness_no_mode_label` проверяет исчезновение литерала, не значение сохранённого режима.

ОБХОД: оставить все три литерала в MODES, но всегда устанавливать `entry.mode='RUNTIME'` независимо от входа. Все 25 мутантов и пять фактов остаются зелёными; fixture/historical evidence маркируется runtime.

**Обход:** словарь имён режимов подменяет наблюдаемое различение режимов.

**Конкретное дерево:** `mode-collapse/`, единственная дельта harness: `mode: rec.mode || 'RUNTIME',` → `mode: 'RUNTIME',`. Полная батарея rc 0, пять фактов true, 25/25. `python3 observe_modes.py` → rc 0; независимые node-вызовы для FIXTURE_5_8_2, SYNTHETIC, RUNTIME прочитали из трёх сохранённых файлов соответственно RUNTIME, RUNTIME, RUNTIME (`mode-observed.json`).

`[INFERENCE]` На полноценном C дельта не меняет все перечисленные native-RUNTIME проверки строки 49 и compose строки 48: RUNTIME остаётся RUNTIME. Старые исторические bytes тоже неизменны. Но новый harness не различает режимы, прямо входящие в предмет.

**Простейшая форма фикса:** исполнить запись каждого объявленного режима и сверить режим в сохранённом evidence вместе с соответствующими осями; проверить отсутствие их склейки. Это конечная ось заявленного предмета, не требование перебрать произвольные входы или создать полную реализацию исторического backend.

## Замыкание осей и пять вопросов гейта

1. **Предмет сильнее критерия:** да — Б1 (return × sink), Б2 (standalone CLI × поставочный вызов), Б3 (режим × сохранённая запись). Наличие двух различных RUNTIME-входов закрывает константные значения в return, но не эти произведения.
2. **Доказуемость командами:** команды существуют и исполнены. Фактические ограничения stdout/return не доказывают перечисленные выше свойства. Остальные живые условия строк 48–49 не объявляю выполненными без стенда.
3. **Решения исполнителя:** точка сохранения drill и связь реального TCP/SQL capture с persisted tuple остаются свободными в приёмке; это существенно именно через названные обходы, не из-за стиля формулировок.
4. **Границы:** architect/implementer/судьи названы; целевые файлы и внешние CI-пути в зонах, пересечения объявлены. Precision gate rc 0. Отдельного наблюдаемого обхода зон не предъявлено.
5. **Нормы AGENTS:** прежнее нормативное нарушение проводки снято. Полнота секции угроз механически подтверждена. sourceCanon не объявлен; карта семи критериев issue есть, но клетки #1/#5 неполны по Б1/Б2. Остальную прозу вне предмета/приёмки/раздачи не использую как основание FAIL.

## Советы — не дополнительные блокеры

СОВЕТ contracts/109-cmp-bck-004-stend-evidence.md:49 — живой scrubber-факт сам по себе вакуумен: sentinel лежат в отдельном `observation.secrets`, а не в сохраняемых HTTP/SQL полях. На `scrubber-identity/` замена `scrubSecrets` на identity сохраняет полную батарею rc 0. Но строка 49 отдельно требует sentinel-пробу на живом evidence: поэтому это совет усилить факт, а не ещё один обход всего критерия. Для пробы секрет должен реально попасть в сериализуемое поле.

СОВЕТ contracts/109-cmp-bck-004-stend-evidence.md:48 — отрицательный rc `wget` стоит различать с отсутствием wget/ошибкой образа и дополнять положительным контролем инструмента/маршрута. Старый реальный default-egress обход закрыт; нового зелёного дерева с доступным запрещённым маршрутом в этом круге не предъявлено.

СОВЕТ contracts/109-cmp-bck-004-stend-evidence.md:46 — код допускает None у факта для общего rc/control_green, тогда как текст требует все пять true. Здесь обходом это не названо: все три предъявленные контрмодели имеют именно true, а проверка полных условий текста исключает None. Полезно сделать rc согласованным с объявленным fail-closed C.

СОВЕТ contracts/109-cmp-bck-004-stend-evidence.md:43 — перенос одного harness.js/collector.js в пустой disposable-каталог запрещает обычные относительные зависимости честной реализации. Это риск ложного красного и молча выбранное ограничение интерфейса, не зелёный обход; приёмку лучше исполнять с нужным checkout-контекстом.

СОВЕТ contracts/109-cmp-bck-004-stend-evidence.md:29 — в работах issue также названы private object-storage profile, TLS verify-full ingress и шесть identities; в карте семи критериев это отдельно не разложено. Не выдаю это за доказанный обход текущего ограниченного предмета; границу этих source-требований стоит назвать явно.

## Сырые команды и rc

Рабочий каталог H: `/tmp/dev-harness-verify/Critic109r2/h`; корень доказательств D: `/tmp/dev-harness-verify/Critic109r2`.

- `git clone --branch wip/109/architect ssh://git@github.com/a3ka/dev-harness.git /tmp/dev-harness-verify/Critic109r2/h` → rc 0.
- `git log -1 --format='%H %an %s'` → rc 0, `89711b3a21c32e873a9d21340591dba798a99ced architect ...`.
- `git show origin/main:verdicts/critic/contracts-109-krug1-fail.md` → rc 0, предыдущие Б1–Б4 прочитаны.
- `git clone ssh://git@github.com/a3ka/Complior-back.git /tmp/dev-harness-verify/Critic109r2/back` → rc 0; `git checkout 9d960a0543eb36696b1d767bf208416e774f0a32` в back → rc 0.
- `gh issue view 5 --repo a3ka/Complior-back --json body --jq .body` → rc 0.
- `python3 fixtures/workshop_project/stend_109/probe.py` → rc 2, `the following arguments are required: --repo`.
- `python3 fixtures/workshop_project/stend_109/probe.py --repo /tmp/dev-harness-verify/Critic109r2/back --out /tmp/dev-harness-verify/Critic109r2/base-report` → rc 1: четыре ожидаемые причины, 1 rejected/24 blocked; runner NEEDS_ENV (в read-only снимок зависимости не устанавливались).
- `python3 /tmp/dev-harness-verify/Critic109r2/reproduce.py` → rc 0. Скрипт выполняет точные команды `python3 H/fixtures/workshop_project/stend_109/probe.py --repo D/<дерево> --out D/<имя>-report`; полные команды/stdout/stderr/rc сохранены в соответствующих `.log`. На отдельной копии B с уже установленными dependencies — rc 1, ROOT_SERVER_PRESENT/RUNNER_DAMAGE_GUARD true, три новых факта None, ровно 1 rejected/24 blocked. На control-model, sink-decoy, drill-unwired, scrubber-identity — rc 0, все пять фактов true, 25/25. На точном старом дереве и варианте с восстановленным historical — rc 1.
- `python3 H/fixtures/workshop_project/stend_109/probe.py --repo D/sink-decoy --matrix` → rc 0, 25 строк REJECTED_EXACT; команда развёрнута в `sink-matrix.log`.
- `python3 H/fixtures/workshop_project/stend_109/probe.py --repo D/sink-decoy --case <имя>` для каждого из 25 имён CASES → все rc 0; отдельный сырой лог `sink-case-<имя>.log`. `--case nonexistent` → rc 2, `109 UNMEASURABLE: EMPTY_SELECTION`.
- `python3 /tmp/dev-harness-verify/Critic109r2/old_cases.py` → rc 0; три вложенных полных прогона br1-same/br2-same/br3-same → каждый rc 1, причины приведены выше, логи сохранены.
- `node /tmp/dev-harness-verify/Critic109r2/observe_sink.cjs` → rc 0; сохранён `{}` при правильном return.
- `python3 /tmp/dev-harness-verify/Critic109r2/observe_modes.py` → rc 0; вложенная полная батарея rc 0; node-наблюдение трёх сохранённых режимов rc 0, все RUNTIME.
- `bash scripts/check_provodka.sh /tmp/dev-harness-verify/Critic109r2/h contracts/109-cmp-bck-004-stend-evidence.md` → rc 0, пустой вывод.
- `bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Critic109r2/h contracts/109-cmp-bck-004-stend-evidence.md` → rc 0, `OK`.
- `bash scripts/pre_critic.sh contracts/109-cmp-bck-004-stend-evidence.md` → rc 0, `КРИТИК: дверь зелёная`.
- `bash scripts/check_threat_model.sh /tmp/dev-harness-verify/Critic109r2/h contracts/109-cmp-bck-004-stend-evidence.md` → rc 0, 8/4 буллета.
- `docker compose version` → rc 0, v2.39.1. Фактический `docker compose config` исполнялся внутри каждой полной батареи; контейнеры судом не создавались.

Project-wide suites/линтеры/форматтеры не запускались. Перепроверка заявленных pre_critic/check_provodka была явно затребована заданием; новые поведенческие выводы получены собственными прогонами.

## Арбитраж и доставка

АРБИТР: роль arbiter. Предмет повторной причины БР3 — достаточно ли проверки возвращённого кортежа для утверждения о сохранённом HTTP/SQL evidence; БР2 — достаточно ли standalone-исполнения collector без наблюдения его вызова поставкой. Созыв записан критиком сейчас, а не отложен до третьего FAIL. Согласие/несогласие автора с настоящими находками ещё не получено; это не эскалация воли владельцу.

Вердикт для передачи: `/tmp/dev-harness-verify/Critic109r2/verdict.md`; закоммиченная копия — `verdicts/critic/contracts-109-v2.md` на ветке предмета, автор critic. Из-за прямого запрета писать в `/home/harness/dev-harness` доставка коммита выполняется через сохраняемый `verdict.bundle`, без push; основной репозиторий критик не меняет. Клоны h/back удаляются после сохранения и проверки bundle; модели/закреплённая батарея сохраняются упакованными в `evidence.tar.gz`, сырые логи/JSON и воспроизводители — рядом с вердиктом.
