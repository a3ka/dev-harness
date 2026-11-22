accept
OBJECT=099150d29e5eab5b204705e5cb20f4963b2980c4
СУД: repo=dev-harness; предмет=206; роль=critic; вызов=2/2 (scoped); фаза=v1; модель-план=openai-codex/gpt-6.1-terra; сессия=Crit206V2; модель-факт=openai-codex/gpt-6.1-terra; предыдущий=verdicts/critic/contracts-206-v1.md FAIL 1167f53a2b; исключение=нет; класс риска=рисковый

Предмет — только закрытие четырёх блоков предыдущего суда и последствия дельты. Коммит кандидата — architect, судья — critic. Фактическая модель указана средой сеанса; доступная история `history://Crit206V2` не содержит независимого трейса модели, а HANDOFF на OBJECT не содержит строки этого вызова. Оркестратор обязан сверить фактический трейс и дополнить счёт в своём HANDOFF до материализации вердикта; эта запись не подменяет учёт.

## Закрытие блоков

`python3 "$PWD/.scratch-crit206v2/attacks.py"` rc 0: одноразовые модели по `155cb90732` и OBJECT и реальные Node/git/pre_judge, журнал только синтетический. В скобках — сырые rc/выходы в сокращённых путях; ни production, ни исходный журнал не менялись.

- К-09, `contracts/206-sreda-sudji.md:36-37`: при cwd вне своей копии `cp -- /etc/hosts ---`, `mkdir -p -- ---`, `cp -x -- /etc/hosts --`, `mkdir -- --` до правки каждый дал `(0, '{"decision":"pass"}', '')`; на OBJECT каждый дал rc 0 и `decision=block` с Н-85 и HINT. Положительные `cp -p -- /etc/hosts -inside` и `mkdir -p -- -inside` в своей копии дали `(0, '{"decision":"pass"}', '')` на обеих моделях. Варианты `-t` и `--target-directory` не оценивались как обязательные: за объявленной грамматикой.
- К-08, `contracts/206-sreda-sudji.md:40`: свои `./../outside.md`, `a/../../../outside.md`, `a/../../../../outside.md`, `linkout/outside.md`, `linkout//outside.md` до правки `(0, 'VERDICT_BRANCH=wip/206/critic', '')`, на OBJECT rc 1, пустой stdout и `ОТКАЗ: VERDIKT_VNE_REPO` с формой. Абсолютный внутренний файл и `./a/../inside.md` на обеих моделях `(0, 'VERDICT_BRANCH=wip/206/critic', '')`.
- К-10, `contracts/206-sreda-sudji.md:41`: при назначенном `a`×40 свой START с другим object `b`×40, отсутствующим object, `a`×39, `a`×41 либо `A`×40 до правки каждый дал `(0, 'SUDA=3 OBRYVOV=0 VERDIKTOV=3', '')`, на OBJECT каждый `(1, 'OBJECT_NE_SOVPADAET', '')`. Перемена порядка START дала `(1, 'TRI_SUDA_NE_PREDJAVLENY', '')`. Честная тройка и перекрытие RELEASE дополнительно проверены live_control.
- К-06, `contracts/206-sreda-sudji.md:60`: `NaN`, `true`, `[[{}]]` до правки дали rc 1 с traceback `AttributeError`; на OBJECT каждый `(2, '', 'NOT_IMPLEMENTED: NEVALIDNYJ_ZHURNAL')`. Не-UTF8, NUL и строка пробелов на OBJECT также rc 2 с каноническим stderr; пустой файл и `{}\r\n` дают `(1, 'TRI_SUDA_NE_PREDJAVLENY', '')`; отсутствующий файл rc 2 `NOT_IMPLEMENTED`. CRLF здесь JSON-объект, а не свидетельство состоявшегося суда.

Три мутации из первого вердикта присутствуют в `probe.py` и `stabs.tsv`: `hint-refuse → guard-pin-mismatch`, `boundary-no-inside → verdict-outside`, `observer-no-sequence → observer-overlapping-judges`. Самостоятельный подсчёт в материализованной модели: `anchor_count=1` для каждой; `--stabs` реально поймал все три. Привязки к клеткам — код `MUTATIONS`, не проза (Н-39).

## Исполненные команды

- `red_sreda_sudji_206.sh --repo .`: rc 1, `KLETKI=82 ZELENYE=50 KRASNYE=32` — ожидаемый red-before.
- `red_sreda_sudji_206.sh --model`: rc 0, `KLETKI=82 ZELENYE=82 KRASNYE=0`.
- `red_sreda_sudji_206.sh --stabs`: rc 0, `OBMANOK=34 POIMANY=34 ZHIVYH=0`; отдельно напечатаны `hint-refuse: guard-pin-mismatch: POIMAN`, `boundary-no-inside: verdict-outside: POIMAN`, `observer-no-sequence: observer-overlapping-judges: POIMAN`.
- `live_control.py`: rc 0, `OBSERVER_CONTROLS=21 KRASNYE=0; LIVE_JUDGES_NOT_RUN`; `catalog.py --check`: rc 0, `STABS=34 NORM_CONSUMERS=3`.
- `check_sdacha.sh "$PWD" contracts/206-sreda-sudji.md --run`: rc 0, `СДАЧА: лист зелёный (двери=12 карта=17/17 дельта=5)`; `pre_critic.sh`: rc 0, `КРИТИК: дверь зелёная`.
- `check_spec_ready`, `check_ids`, `check_ceilings`, `check_provodka --grammar`, `check_precision_gate`, `check_threat_model`, `check_predposylki`: каждый rc 0.
- `validate_std.sh bash .../red_sreda_sudji_206.sh` с `VALIDATE_STD_SHELLCHECK=/home/harness/.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck`: rc 0; `shellcheck --version` этого файла = 0.11.0. Первый запуск без пути: rc 2 `VALIDATOR_MISSING: shellcheck`.
- Две первоначальные ошибочные команды `--model .` и `--stabs .` дали rc 2 `unrecognized arguments: .`; выше указаны корректные отдельные прогоны.
- `bash scripts/scope_select.sh "$PWD" --changed 155cb90732`: rc 2, `SCOPED: 0 задетых ...`, `MODE: needs-full`. Изменённых ключей анти-плацебо нет, полный прогон здесь не запускался. Настоящие суды и рестарт не проводились: это приёмка после реализации.

## Карта классов

К-01: чисто — `check_sdacha --run`, rc 0, дельта 5.
К-02: без изменений с вызова 1.
К-03: чисто — нормализация пути и сохранённые обязательства, `--model` rc 0.
К-04: чисто — `git diff --name-only 155cb90732 099150d29e`, контракт и семья 206; precision rc 0.
К-05: чисто — `contracts/206-sreda-sudji.md:54-62`, rc-команды модели и live.
К-06: чисто — собственные JSON/non-UTF8/NUL/пустой файл, rc 2/1 как выше.
К-07: чисто — реальный Node/git и `--model` rc 0.
К-08: чисто — пять самостоятельных относительных выходов и два внутренних входа выше.
К-09: чисто — четыре операнда после `--` и положительные контроли выше.
К-10: чисто — пять соседних object и порядок START выше; live_control rc 0.
К-11: без изменений с вызова 1.
К-12: чисто — дельта использует GNU realpath и Python JSON; вход `model/build.py:87-99`, `live.py`.
К-13: без изменений с вызова 1; секреты не в предмете.
К-14: чисто — внутренние относительные/абсолютные пути и dash-операнды в своей копии, как выше.
К-15: чисто — выполненные 82/82, 34/34, 21/21 и каталог 34, rc 0.
К-16: чисто — риск путей и ограниченная грамматика `contracts/206-sreda-sudji.md:4,37,73-84`.
К-17: без изменений с вызова 1; pinned проектный архитектурный бриф неприменим.
