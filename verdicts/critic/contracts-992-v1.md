accept

# Критик — контракт 992, круг 2

Предмет: `contracts/992-oshibka-eto-otkaz.md` на `wip/992/architect`, HEAD `7a3a97c8`
(«992: declare existing CI dispatcher as enforcement channel»).
Клон: `/tmp/dev-harness-verify/2757517287/repo` (одноразовый SSH-клон origin).
Круг 1: `verdicts/critic/contracts-992-krug1-fail.md` (origin/main, `4dc30df7`) — FAIL, один блокер (ПРОВОДКА
не подключена), пять советов.

Набор артефактов полон: предмет, критерий с командами, исполнители, `ЗОНА`-строки, модель угроз — есть и
закоммичены.

## Дифф круга 2

`git diff --stat e763ec4b..7a3a97c8` — `contracts/992-oshibka-eto-otkaz.md | 6 +++---`, 1 файл, 3+/3−.
Фикстуры (`fail_closed_992.py`, `model_992.py`, `red_doc_lifecycle.sh`) не менялись. Правленные строки:
`:12` (§Существующее — цепочка потребителя), `:62` (`guard=scripts/run_ci_lane.sh`), `:64` (ПРОВОДКА-ЭНФОРСМЕНТ).

## Живые прогоны (cwd = корень клона, HEAD 7a3a97c8)

|команда|rc|итог|
|---|---|---|
|`bash scripts/pre_critic.sh --repo . contracts/992-oshibka-eto-otkaz.md`|0|`КРИТИК: дверь зелёная`|
|**`bash scripts/check_provodka.sh . contracts/992-oshibka-eto-otkaz.md`**|**0**|молча (круг 1: rc1 `guard не подключён`)|
|`bash scripts/check_precision_gate.sh . contracts/992-oshibka-eto-otkaz.md`|0|`OK`|
|`bash scripts/check_threat_model.sh . contracts/992-oshibka-eto-otkaz.md`|0|`секция валидна (ЗАЩИЩАЕТ 3, НЕ ЗАЩИЩАЕТ 2)`|
|`bash scripts/check_spec_ready.sh . contracts/992-oshibka-eto-otkaz.md`|0|`OK`|
|`python3 fixtures/freeze_contract/fail_closed_992.py --matrix`|0|`cases=24 observations=72 failures=0`|
|`python3 fixtures/freeze_contract/fail_closed_992.py --model`|0|`cases=24 observations=24 failures=0`|
|`python3 fixtures/freeze_contract/fail_closed_992.py`|1|`cases=24 observations=24 failures=16`: 8 A `accepted=1`, 16 B `accepted=0`|
|`python3 fixtures/freeze_contract/fail_closed_992.py --list \| wc -l`|0|`24`|
|`bash scripts/gen_ci_steps.sh --check`|0|сгенерированный блок ci.yml совпадает с реестром|
|**`bash scripts/run_ci_lane.sh check:document`**|**1**|`+ npm run check:document` → … → `cases=24 observations=24 failures=16` → `lane: отказ ключа check:document (rc=1)`|

## Закрытие блокера круга 1

Блокер круга 1 (`contracts/992-oshibka-eto-otkaz.md:62`, норма AGENTS.md:174-175 «каждый канал нормы существует
и подключён») **ЗАКРЫТ**. Это закрытие по согласию с правкой, арбитраж не нужен. Круг 1 сам называл этот путь:
«переназначить `guard=` на уже литерально подключённый файл, который вызывает батарею».

Цепочка `:64` сверена звено за звеном по коду, прозе я не доверял:

1. `.github/workflows/ci.yml:223` — `run: bash scripts/run_ci_lane.sh ${{ matrix.keys }}`, у шага нет `if:`;
   `check:document` стоит в lane `l5` (`ci.yml:112`), блок сверен `gen_ci_steps.sh --check` rc0.
2. `scripts/run_ci_lane.sh:53-64` — команда ключа берётся из реестра и исполняется через `bash -c`, при ненулевом rc
   печатается `lane: отказ ключа … (rc=…)` и делается `exit "$rc"`. Пропусков или инкрементального обхода
   внутри диспетчера нет.
3. `registry/ci-steps.tsv:34` — `step check:document 20 npm run check:document`.
4. `package.json:23` — цикл `… fixtures/freeze_contract/red_doc_lifecycle.sh; do bash "$f" || exit 1; done`.
5. `fixtures/freeze_contract/red_doc_lifecycle.sh:5` — `python3 "$HERE/fail_closed_992.py"` без флагов.

Живой прогон диспетчера даёт rc1 с `failures=16` батареи, то есть состояние батареи доходит до кода возврата
CI-шага. `check_provodka.sh` rc0. done-шаг объявленного порядка (`:3`) больше не заблокирован ПРОВОДКОЙ.

## Находки

СОВЕТ contracts/992-oshibka-eto-otkaz.md:62 — `guard=scripts/run_ci_lane.sh` — это общий диспетчер.
`check_provodka.sh` (`guard_is_wired`, :356; вызов :478-482) проверяет только литеральный вызов
`run_ci_lane.sh` в workflow. Значит, rc0 этого гейта не зависит от звеньев 3–5 цепочки 992 и был бы зелёным
у любого контракта. Звено «lifecycle вызывает батарею» после B не держит ни одна команда с кодом возврата:
`run_ci_lane.sh check:document` rc0 и `red_doc_lifecycle.sh` rc0 (`:43`, `:64`) получаются и тогда, когда
строка `:5` удалена. Почему это не блокер: предмет (fail-closed семи скриптов) всё равно вынуждает
`fail_closed_992.py` rc0 (`:41`), а правку implementer'ом `red_doc_lifecycle.sh` в его зоне
`fixtures/freeze_contract/` уже покрывает совет 5 круга 1 (держит ревьюер, AGENTS.md шаг 7). Дёшево сделать
звено механическим: добавить в `:43` команду
`grep -Fqx 'python3 "$HERE/fail_closed_992.py"' fixtures/freeze_contract/red_doc_lifecycle.sh` → rc0.

Советы 1–5 круга 1 (`:21` ветвь в регексе profile, `:20` ошибка чтения журнала, `:31` безусловный импорт
`model_992`, `:45` пересчёт без команды, `:50-53` fixtures-зона implementer'а) остаются советами в прежней
формулировке. Формулировки этих строк в круге 2 не менялись, и в блокеры я их не перевожу.

## Пять вопросов роли (по тексту целиком)

1. **Критерий слабее предмета?** Нет. Правка не тронула `:39-45` и CASES. Каждая клетка по-прежнему исполняет
   полный скрипт и требует rc1, предметный регекс, неизменность побочных эффектов и отсутствие
   success-баннера. Различимость (`--matrix` 72/0) и правильное красное (16 B) получены живьём.
2. **«Готово», недоказуемое командой?** Все пункты имеют команду с rc. Исключения — `:45` (совет круга 1) и
   звено lifecycle→батарея после B (совет выше).
3. **Решение, молча оставленное исполнителю?** Вопрос круга 1 «кто и где подключает guard» закрыт `:64`:
   architect подключает до заморозки (уже сделано, `red_doc_lifecycle.sh:5`), а после landing подключать нечего.
4. **Границы исполнения?** Новых файлов к правке не добавилось. Цепочка не требует трогать workflow,
   package.json или registry, и это согласовано с `:12`, `:43`, `:57`. Противоречия круга 1 (запрещённые места
   подключения) больше нет.
5. **Противоречие AGENTS.md?** Нет. ПРОВОДКА зелёная, `ПРОВОДКА-ЭНФОРСМЕНТ:` с обоснованием присутствует
   (guard-only разрешён нормой :175), печати `PASS` нет, у порога есть область (24 клетки, `--list`).

Precision-гейт 043: rc0. Модель угроз 041: rc0. Spec-ready 036: rc0.
