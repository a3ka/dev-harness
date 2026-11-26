FAIL
OBJECT=a62207a3d560f15f34bc28145b49c22e54c1ab9f
СУД: репо=dev-harness; предмет=226; фаза=реализация; роль=reviewer; вызов=1 (полный); сессия=Rev226; модель-факт=anthropic/claude-opus-5-5 (метаданные станции, поле Model); автор Impl226 — implementer (MiniMax); Architect226e/f; предыдущие адверсарные: archive/226/adversary-v3-fail-659a024fd (и 1–2: b4c6d8e2f, 8d1ef6f51); арбитраж: archive/226/arbiter-b2-8bfeab16b; слово владельца R-0156

# Reviewer 226 — профиль включает дверь архитектуры без имени проекта, реализация, вызов 1

**БЛОКИРУЕТ: Б-1** (architect, census `context.py`). На собранном OBJECT красна приёмочная строка «Правило формы перед судом»:

- `python3 fixtures/workshop_project/arch_door_profile_key_226/context.py` → rc 1, `MISSING implementer scripts/done_contract.sh 223`;
- следом `check_sdacha --run` → rc 1 и `pre_critic` → rc 1.

Production тут ни при чём, она честна (ниже).

**СОВЕТ: 3** — файл `.review/2026-11-26-2261.md` (`status: ready`):

- С-1: implementer, устаревшие комментарии селектора в `make_task.sh:32,971`;
- С-2: architect, итог rc 2 вместо rc 1 при уже красном публичном слое;
- С-3: orchestrator, ключа в профиле бэкенда нет и PR нет — cutover только после него.

Перепроверил ВСЁ: область правки, сырой вывод, не переписаны ли проверки под код.

Accept адверсария этим вердиктом не заменяется. Owner-аттестат по R-0156 предусмотрен только при accept ревьюера. Его нет, пока Б-1 не закрыт на новом OBJECT.

## Б-1. Census 226 красен на пересобранном носителе

ОБЯЗАТЕЛЬСТВО. Контракт `contracts/226-arch-door-profile-key.md`, §Приёмочный критерий, «Правило формы перед судом»:

- `pre_critic.sh` → rc 0;
- `check_sdacha.sh . … --run` → rc 0;
- `context.py` → rc 0.

Arb226b §4 добавляет: отказ census по позднему frozen 223 «не объявлять исчезнувшим: закрыть совместимость … не удалением тега и не ослаблением проверки».

СОСТОЯНИЕ. Чистый клон origin на OBJECT, теги подтянуты `git fetch origin '+refs/tags/*:refs/tags/*'`. Это и есть предъявленный носитель.

```
$ python3 -B fixtures/workshop_project/arch_door_profile_key_226/context.py
FROZEN 203 BLOBS 202 OVERLAPS 117 MISSING 1
LATE_FROZEN implementer scripts/done_contract.sh 094 frozen/contracts/094/2 e29e4260… поздний frozen: не предок носителя
… (ещё 6 LATE_FROZEN 094/097/099/100)
MISSING implementer scripts/done_contract.sh 223
CONTEXT_RC=1
$ SDACHA_TIMEOUT_SEK=1200 SDACHA_BUDZHET_SEK=2400 bash scripts/check_sdacha.sh "$PWD" contracts/226-arch-door-profile-key.md --run
ОТКАЗ: строка 21: фактический rc=1 ≠ заявленного 0: fixtures/workshop_project/arch_door_profile_key_226/context.py
@@ SDACHA RC=1 SEC=109
$ SDACHA_TIMEOUT_SEK=1200 SDACHA_BUDZHET_SEK=2400 bash scripts/pre_critic.sh contracts/226-arch-door-profile-key.md
ОТКАЗ: сдаточный лист красен (rc=1): ОТКАЗ: строка 21: фактический rc=1 ≠ заявленного 0: fixtures/workshop_project/arch_door_profile_key_226/context.py
@@ PRE_CRITIC RC=1 SEC=100
```

ПРИЧИНА. `context.py:46-47` проверяет `merge-base --is-ancestor <frozen> HEAD`.

- Носитель i8 пересобран на main `568f0ea63`, а тот уже содержит `frozen/contracts/223/1` = `59719f4043d2…`: `git merge-base --is-ancestor 59719f40 HEAD` → rc 0.
- Пересечение 223×226 по `scripts/done_contract.sh` объявлено поздним контрактом: строка 103 frozen 223/1, «ПЕРЕСЕЧЕНИЕ implementer: scripts/done_contract.sh — 226». Замороженный текст 226 его не несёт и нести не может.
- Ремонт Architect226f (ветвь LATE_FROZEN `context.py:54-57`) проверялся на старой базе. На `archive/226/architect-f-53eaee8f4` тот же census зелёный:

```
53eaee8f448339f89af97765a48d85286776a99d
FROZEN 203 BLOBS 202 OVERLAPS 116 MISSING 0
LATE_FROZEN implementer scripts/done_contract.sh 223 frozen/contracts/223/1 59719f40… поздний frozen: не предок носителя
CONTEXT_AT_ARCHF_RC=0
223_ancestor_rc=1
```

После пересборки на main, где 223/1 уже предок, ремонт перестал закрывать отказ Adv226c. CI зелёный на head `b0295c2be` (16 success, 1 skipped `vorota`). Но `context.py`, `check_sdacha` и `pre_critic` в CI-шаг 226 не входят, поэтому красноту приёмки CI не видит.

ПРОСТАЯ ФОРМА (норма 050: фрагмент, отсутствующее свойство, более простая форма). Предковость судить относительно точки заморозки самого 226: `frozen/contracts/226/1^{commit}` вместо `HEAD`. Замороженный текст обязан объявить только те frozen, что существовали при его заморозке. Позднюю заморозку объявляет сам поздний контракт — 223 это сделал.

Проба в одноразовом клоне OBJECT, правка одной строки `context.py:47`:

```
-                ['git', '-C', str(ROOT), 'merge-base', '--is-ancestor', commit, 'HEAD'],
+                ['git', '-C', str(ROOT), 'merge-base', '--is-ancestor', commit, 'frozen/contracts/226/1^{commit}'],
FROZEN 203 BLOBS 202 OVERLAPS 116 MISSING 0
LATE_FROZEN implementer scripts/done_contract.sh 223 frozen/contracts/223/1 59719f40… поздний frozen: не предок носителя
CONTEXT_FIX_RC=0
```

Тег не удаляется. Предковые пересечения по-прежнему обязательны: выборка 116 непуста. Ремонт — в зоне architect (семья 226). Затем на новом OBJECT нужны `check_sdacha --run` и `pre_critic` rc 0, и вызов 2 (scoped) по этой дельте.

КЛАСС: форма приёмки / census (К-01/К-04 карты SDACHA), не production.

## Область правки

`git diff --name-status $(git merge-base origin/main HEAD) HEAD`. Merge-base = origin/main = `568f0ea63`. Список файлов:

```
M .github/workflows/ci.yml
M fixtures/workshop_project/arch_door_profile_key_226/{SDACHA.md,build.py,context.py,probe.py,source.json}
A fixtures/workshop_project/arch_door_profile_key_226/stabs/st21…st63/scripts/profile_resolver.sh   (43 носителя)
M fixtures/workshop_project/architecture_process_187/probe.py
M fixtures/workshop_project/architecture_steward_186/pin_probe.py
M fixtures/workshop_project/done_dver_soderzhatelnaja_201/dver_probe.py
M registry/ci-steps.tsv
M registry/ci-zamery.tsv
M scripts/{check_architecture_contract,check_architecture_pin,done_contract,freeze_contract,make_task,profile_resolver}.sh
A verdicts/adversary/contracts-226-impl-v1.md
A verdicts/arbitration/contracts-226-impl-b2.md
```

Коммит → автор → файлы (`git diff-tree`):

| Коммит | Автор | Файлы |
|---|---|---|
| `f60b6d53f` | implementer | 6 `scripts/*.sh` + `architecture_process_187/probe.py` + `architecture_steward_186/pin_probe.py` — ровно 8 путей `ЗОНА implementer` frozen 226/1 |
| `e1cb5de5b` | architect | SDACHA 226 + `done_dver_soderzhatelnaja_201/dver_probe.py` |
| `823d87b12`, `0fc601923`, `448e38571`, `56aa9498f` | architect | только семья 226 |
| `05b85a1ff`, `7c9e3ccec`, `814504cdc`, `a62207a3d` | orchestrator | `ci.yml`, `ci-steps.tsv`, `ci-zamery.tsv` |
| `dd57cfb64`, `2749287c2` | adversary | `verdicts/adversary/` |
| `d82a403ce` | arbiter | `verdicts/arbitration/` |

Каждый коммит — одна задача со ссылкой на 226. Committer у всех `orchestrator` (пересборка носителя), авторы сохранены.

Правка 201 сводится к двум строкам: `if kind == 'back': profile['hooks'] = {'archBrief': 'a3ka/Complior-back'}`. Других изменений в `done_dver_soderzhatelnaja_201/` нет, ожидания не ослаблены. Правки 187/186 меняют только входной профиль мира (+6 и +22 строки), ожидания и предикаты не тронуты.

Контракт и нормы:

- `git diff frozen/contracts/226/1 HEAD -- contracts/226-arch-door-profile-key.md` пуст;
- `roles/`, `AGENTS.md` и frozen-тексты не тронуты.

Вне зон изменений нет.

## Проверки не переписаны под код

- Implementer батарею не трогал: `f60b6d53f` содержит только production и входы 187/186.
- После реализации семья 226 менялась только добавлениями. `git diff --numstat f60b6d53f HEAD`: probe.py +338/−0; build.py +124/−1; source.json +1222/−1; context.py +17/−1. Каждое удаление — замена строки на расширенную: `'bindings': bindings` → `+ 'public': public`, запятая в json, `found, checked` → `found, late, checked`. Ни одно ожидание, клетка или связь не удалены.
- Оракул `grammar_accepts` (`probe.py:118-126`) независим от production-регекса. Он работает посимвольно на frozenset A/B, проверяет `value is False` и `type(value) is not str`. Его ожидания вычисляются в `CASES.update` до субъекта.
- `git diff frozen/contracts/226/1 HEAD -- contracts/` для 226 пуст.

## Полный diff production — построчно

`scripts/profile_resolver.sh`:

- `:221-222` SCHEMA_LEVELS `repo:hooks:optional`, `repo:hooks:archBrief:optional`.
- `:485` `hooks` в known_branches: неизвестные имена внутри hooks — предупреждение М-0.
- `:952-955` defaults-лист даёт `die_p "ARCH_PROFILE_LAYER: …"` независимо от значения.
- `:956-965` вход в валидацию: `has("hooks")` → `type == "object"` иначе `die_p … hooks не объект` → `has("archBrief")` → значение `. == false` | `type == "string" and test("^[A-Za-z0-9][A-Za-z0-9_.-]*/[A-Za-z0-9][A-Za-z0-9_.-]*\\z")` | `else false` → `|| die_p "значение вне алфавита: hooks.archBrief: ожидается false или owner/repo"`.
- `die_p` (`:228`) печатает в stderr и выходит с rc 1.
- `:1096-1099` merged `hooks` берётся только из repo и только с ключом `archBrief`.

Каждое управляющее условие проверено мутацией (ниже). Значение `-0` даёт отказ.

`scripts/check_architecture_contract.sh`:

- `arch187_profile` (`:129-158`):
  - файла нет при lock → rc 2 `ARCH_PROFILE_MISSING`; без lock → rc 0, пусто;
  - resolver до `profile_get` (прецедент 193); отказ resolver → rc 2 `ARCH_PROFILE`, причина resolver остаётся в stderr;
  - `false` → выключено; строка → `ARCH187_PRODUCT_REPO`.
- `arch187_scope` (`:165-174`): rc 0/1/2. Публичная дверь (`:1079-1088`) на rc>1 печатает отказ в stderr и выходит с rc 1. «Неизвестно» нигде не превращается в «выключено».

Потребители:

- `make_task.sh:1015-1018`, `freeze_contract.sh:311-314`, `done_contract.sh:440-443` — `[ "$_scope_rc" -le 1 ] || die "$ARCH187_REFUSAL"`;
- `check_architecture_pin.sh:46-62` — профиль через тот же `arch187_profile`. Отсутствие или false дают `ARCH_PROFILE_REQUIRED` до gh. `PRODUCT_REPO` из окружения больше не читается.

Исполняемых литералов `Complior-back` в `check_architecture_*.sh` нет. `ARCH_REPO` по умолчанию `a3ka/CompliorOS-architecture` — так было и раньше, инв. 4 это разрешает. R-0102 соблюдён.

Пограничные профили на честной production: свой мир, публичный resolver и `arch187_scope` (`tmp/edge_rev226.py`, удалён):

```
bom-valid: resolver rc=0 hooks={"value": {"archBrief": "own/repo"}, "origin": "repo"}  scope=0 repo=[own/repo]
crlf-ws-valid: resolver rc=0 …  scope=0 repo=[own/repo]
dup-leaf-last-false: resolver rc=0 hooks={"value": {"archBrief": false}, …}  scope=1 repo=[]
dup-hooks-last-empty: resolver rc=0 hooks={"value": {}, …}  scope=1 repo=[]
escaped-slash (own\u002frepo): resolver rc=0 …  scope=0 repo=[own/repo]
neg-zero (-0): resolver rc=1 stdout_bytes=0 'profile ОТКАЗ: значение вне алфавита: hooks.archBrief: ожидается false или owner/repo'  scope=2
string-false: resolver rc=1 stdout_bytes=0 …  scope=2 refusal=[ARCH_PROFILE: …]
hooks-null: resolver rc=1 stdout_bytes=0 '… hooks не объект'  scope=2
layer-top-level-hooks: resolver rc=0 hooks=null stderr='профиль ПРЕДУПРЕЖДЕНИЕ: неизвестный ключ слой-проекта: hooks …'  scope=1
layer-defaults-hooks-string: resolver rc=0 hooks=null 'ПРЕДУПРЕЖДЕНИЕ … defaults.hooks'  scope=1
layer-defaults-array: resolver rc=1 '… defaults.workflowPaths: проверка типа ветви не выполнилась (jq rc=5)'  scope=2
layer-defaults-false: resolver rc=1 'ARCH_PROFILE_LAYER: hooks.archBrief: …'  scope=2
eacces-with-lock: resolver rc=1  scope=2 refusal=[ARCH_PROFILE: …]
symlink-inside: resolver rc=0  scope=0 repo=[own/repo]
symlink-outside: resolver rc=1 'нет файла репо-слоя в корне репо …'  scope=2
dangling-symlink-with-lock: scope=2 refusal=[ARCH_PROFILE_MISSING: harness.project.json]
directory-profile-with-lock: scope=2 refusal=[ARCH_PROFILE_MISSING: harness.project.json]
```

Дубли ключей решаются по правилу last-key-wins одинаково в resolver и в `profile_get`: оба читают через jq. BOM и CRLF jq принимает одинаково в обоих чтениях. EACCES и симлинки ведут к отказу, а не к «выключено».

Лист в корне слоя проекта, а не в `defaults`, даёт только предупреждение М-0. Контракт называет ошибкой размещения именно «project defaults», и выключенная политика здесь вытекает из отсутствия листа в repo-профиле, а это санкционированное состояние Frontier. Нарушения нет. На самой станции `arch187_scope "$PWD"` → `scope_rc=1`, resolver зелёный.

shellcheck 0.11.0 `-S warning -f gcc` по 6 production-файлам: множества сообщений на base `568f0ea63` и OBJECT совпадают поштучно (md5 без номеров строк). Счёт: profile_resolver 2/2, check_architecture_contract 2/2, pin 0/0, make_task 8/8, freeze 2/2, done 5/5. `bash -n` проходит у всех.

## Публичные guard-свидетели (R-0156, Arb226b §3)

Порядок: одна мутация на одноразовый клон OBJECT, честная батарея из чистого клона, полный `W --repo <клон>` (`tmp/mut_rev226.py`, удалён). Свои формы записи; где можно, отличные от `build.py`.

| # | Мутация (место) | `W --repo` | Публичный свидетель (первые RED) |
|---|---|---|---|
| A1 | дословный CR-мутант Adv226c, `:959` | rc 1, `KRASNYH 7` | `grid-boundary-before/after/owner/repo-cr`, `public-duplicate-leaf/hooks-last-cr`, `public-control-cr` — `PUBLIC_RC,PUBLIC_DIAGNOSIS,PUBLIC_PARTIAL_OUTPUT ('PUBLIC_CLI', 0, b'{…merged…', b'')` |
| A2a | `has("hooks") and false`, `:956` | rc 2* | `bad-null…bad-repo-internal-space`, `bad-hooks` `PUBLIC_RC…`, `bad-door/freeze/done` |
| A2b | `has("hooks") \| not`, `:956` | rc 2* | `other-absent`, `backend-absent`, `legacy-local`, весь `bad-*` `PUBLIC_RC`, `pin-absent`, `unknown-layer-sibling` |
| A3 | `\|\| die_p … hooks не объект` → `\|\| true`, `:958` | rc 1, `KRASNYH 7` | `bad-hooks`, `public-hooks-null` `PUBLIC_RC…`; `public-hooks-false/true/zero/string` `PUBLIC_DIAGNOSIS`; `public-hooks-array` |
| A4a | `has("archBrief")` → `.archBrief != null`, `:959` | rc 1, `KRASNYH 6` | `bad-null`, `grid-type-null`, `public-control-null` |
| A4b | только строки, `:959` | rc 1, `KRASNYH 20` | `bad-null/zero/one/true/array/object` … |
| A4c | `has("archBrief") and false`, `:959` | rc 2* | весь `bad-*` `PUBLIC_RC`, `bad-door/freeze/done` |
| A5a | `. == false or . == true`, `:960` | rc 1, `KRASNYH 3` | `bad-true`, `grid-type-true`, `public-control-true` |
| A5b | `. == (0)` вместо `== false`, `:960` | rc 1, `KRASNYH 9` | `bad-zero`, `public-control-zero`, `public-control-false` … |
| A5c | `else false` → `else true`, `:962` | rc 1, `KRASNYH 20` | `bad-null/zero/…`, `public-control-*` |
| A5d | `elif 1 == 1`, `:961` | rc 2* | `bad-null/zero/one/true/array/object` `PUBLIC_DIAGNOSIS` (в stderr лишняя строка `jq: error … cannot be matched`) |
| A5e | `elif (type == "string" \| not)`, `:961` | rc 2* | `other-enabled`, `backend-enabled`, `grammar-plain` `PUBLIC_RC,PUBLIC_JSON`, `pin-*`, `key-toggle` |
| A6a | `\|\| die_p …` → `\|\| true`, `:963` | rc 1, `KRASNYH 109` | весь отрицательный публичный слой |
| A6b | локально `exit 0` с той же причиной, `:963` | rc 1, `KRASNYH 109` | то же |
| A6c | локально `exit 2`, `:963` | rc 1, `KRASNYH 106` | то же (`PUBLIC_RC`) |
| A6d | причина → `die_p "hooks.archBrief: отказ"` (токен сохранён), `:963` | rc 1, `KRASNYH 106` | `PUBLIC_DIAGNOSIS` на всём отрицательном слое |
| A6e | причина в stdout, rc 1, `:963` | rc 1, `KRASNYH 110` | `PUBLIC_DIAGNOSIS,PUBLIC_PARTIAL_OUTPUT` |
| O1 | `has("hooks")` → `.hooks != null`, `:956` | rc 1, `KRASNYH 2` | `bad-hooks`, `public-hooks-null` |
| O2 | `has("archBrief") and .archBrief != "false"` («false»-строка = выключено), `:959` | rc 1, `KRASNYH 2` | `bad-string-false`, `grid-false-case-00` `PUBLIC_RC` |
| O3 | `. == false or . == null`, `:960` | rc 1, `KRASNYH 6` | `bad-null`, `bad-door` (rc 0 `ARCH_187A_SKIP`), `bad-freeze` (тег!), `bad-done`, `grid-type-null`, `public-control-null` |
| O4 | дверь гасит stderr resolver, `check_architecture_contract.sh:147` | rc 1, `KRASNYH 3` | `bad-door`, `pin-invalid`, `layer-door` `DIAGNOSIS` |
| O5 | отказ двери в stdout, `:1082` | rc 1, `KRASNYH 6` | `bad-door`, `missing-profile-door`, `missing-layer-door`, `malformed-*-door`, `layer-door` `PARTIAL_OUTPUT` |
| O6 | defaults-страж только для строк, `:952` | rc 1, `KRASNYH 1` | `layer-false` (rc 0 — make_task прошёл) |
| O7 | `arch187_profile … \|\| return 1` (неизвестно = выключено), `:169` | rc 1, `KRASNYH 6` | `bad-door`, `missing-profile-door`, `missing-layer-door`, `malformed-*-door`, `layer-door` `RC` (rc 0 `ARCH_187A_SKIP`) |
| E1 | эквивалент `test(re; "x")` | **rc 0**, `KRASNYH 0` | — |
| E2 | эквивалент `(type == "boolean" and . == false)` | **rc 0**, `KRASNYH 0` | — |

\* rc 2 = `NOT_IMPLEMENTED: GRID_JQ_SEAM (0, 1)` (A2a/A2b/A4c), `GRID_JQ_INFRA` (A5d), `GRID_RESOLVER_CONTROL` (A5e). Это отказ шва пакетной сетки после того, как публичный слой уже напечатал RED-клетки. CI красен (≠0), а в `--stabs` соответствующие st51/st52/st55/st57/st58 дают CAUGHT. Итоговый rc 2 вместо 1 — С-2.

Сырой вывод A1 (дословный CR-мутант), честный против мутанта, одна и та же клетка:

```
honest W --repo .:   GREEN grid-boundary-after-cr  ('PUBLIC_CLI', 1, b'', b'profile ОТКАЗ: значение вне алфавита: hooks.archBrief: ожидается false или owner/repo\n')
mutant:
-  if jq -e '.hooks | has("archBrief")' "$REPO_JSON_FD" >/dev/null; then
+  if jq -e '.hooks | has("archBrief") and ((.archBrief | type != "string") or (.archBrief | contains("\r") | not))' "$REPO_JSON_FD" >/dev/null; then
W --repo <clone> rc=1 seconds=129.2
RED grid-boundary-before-cr PUBLIC_RC,PUBLIC_DIAGNOSIS,PUBLIC_PARTIAL_OUTPUT ('PUBLIC_CLI', 0, b'{\n  "language": {…', b'')
RED grid-boundary-after-cr PUBLIC_RC,PUBLIC_DIAGNOSIS,PUBLIC_PARTIAL_OUTPUT ('PUBLIC_CLI', 0, b'{\n  "language": {…', b'')
RED grid-boundary-owner-cr …
RED grid-boundary-repo-cr …
RED public-duplicate-leaf-last-cr …
RED public-duplicate-hooks-last-cr …
RED public-control-cr …
KLETKI 954 KRASNYH 7 SVJAZI 0 ZHIVYH 0
```

Итог: все 17 управляющих мутаций Arb226b §3 и 7 своих (O1–O7, не из `build.py`) красятся публичным свидетелем. Обе эквивалентные записи зелёные. Живых мутаций нет. Вреда, достижимого на честной production, нет.

## Регресс

Чистый клон origin (`git clone ssh://git@github.com/a3ka/dev-harness.git`, свой `.git`), detached на OBJECT, теги подтянуты. `TMPDIR` внутри копии, `VALIDATE_STD_SHELLCHECK` — пин 0.11.0. `W=bash fixtures/workshop_project/arch_door_profile_key_226/red_arch_door_profile_key_226.sh`.

| Команда | rc | Числа |
|---|---|---|
| `W --repo .` | 0 | `KLETKI 954 KRASNYH 0 SVJAZI 0 ZHIVYH 0` (110 с) |
| `W --model` | 0 | `KLETKI 954 KRASNYH 0` (135 с) |
| `W --stabs` | 0 | `KLETKI 954 KRASNYH 0 SVJAZI 79 ZHIVYH 0` (354 с) |
| `W --sintaksis` | 0 | `SINTAKSIS 68 SHELLCHECK_DIFFERENTIAL 6 BASELINE_DIAGNOSTICS 30` (19 с) |
| `W --catalog` | 0 | `KLETKI 954 STABY 61 SVJAZI 79`, `PUBLIC_UNIQUE_INPUTS 131` |
| `python3 …/context.py` | **1** | `MISSING implementer scripts/done_contract.sh 223` — Б-1 |
| `check_sdacha.sh "$PWD" contracts/226-… --run` | **1** | строка 21 (context.py) — Б-1 |
| `pre_critic.sh contracts/226-…` | **1** | «сдаточный лист красен» — Б-1 |
| `check_precision_gate.sh . contracts/226-…` | 0 | `OK` |
| `check_spec_ready` / `check_threat_model` / `check_predposylki` | 0/0/0 | `ЗАЩИЩАЕТ 3, НЕ ЗАЩИЩАЕТ 3`; `PREDPOSYLKI_OK … settings=2` |
| `check_provodka.sh . contracts/226-…` | 0 | — |
| `gen_ci_steps.sh --check` | 0 | — |
| `red_dver_brifa_203.sh --repo .` | 0 | `CELLS=21 STABS=0 FAILURES=0 ZHIVYH=0` |
| `architecture_steward_186/pin_probe.py --repo .` | 0 | pin_merged, lock_missing, pin_missing, pin_wrong, pin_arch_head ok (5/5) |
| `red_architecture_process_187.sh --repo .` | 0 | `CELLS=111 STABS=0 FAILURES=0` |
| `red_done_dver_201.sh --repo .` | 0 | `CELLS=62 STABS=0 FAILURES=0` |
| `red_sdacha_193.sh --repo .` | 0 | `KLETKI=152 ZELENYE=152 KRASNYE=0` |
| `red_svezhest_verdikta_done_224.sh --repo .` | 0 | `KLETKI 100 KRASNYH 0` |
| `W --regression` | 0 | `REGRESSION 203 PIN186 rc=0` (203 `CELLS=21 FAILURES=0`, pin186 5/5) |

Счёт своей мерой (другой командой):

- `grep -c '^GREEN '` по выводу `W --repo .` = 954, `'^RED '` = 0;
- `grep -c '^CAUGHT '` по `--stabs` = 79, уникальных стабов 61;
- `ls -d stabs/*/ | wc -l` = 61;
- `jq '[.bindings[]|.cells|length]|add'` по source.json = 79 связей, `jq '.bindings|length'` = 61 стаб;
- `jq '.public.unique_inputs'` = 131;
- `jq '.carriers|length'` = 69.

Внутренняя сетка по `GRID_AXIS`: 9+34+11+768+20+17+3 = 862.

CI: PR #1439, head `b0295c2be` = OBJECT + пустой коммит. `git diff --stat OBJECT b0295c2be` пуст. Check-runs: 16 success, 1 skipped (`vorota`); lane l2 с `check:arch-door-profile-key-226-family-selftest` — success. Строка шага (`registry/ci-steps.tsv:341`, вес 700): `--repo . && --model && --stabs && --catalog && curl shellcheck v0.11.0 && --sintaksis`. Моя сумма режимов под нагрузкой (≈620 с плюс catalog) с весом согласуется.

## Предпосылки и доставка

Отдельный PR бэкенда объявлен в контракте: Frontier, ПРЕДПОСЫЛКИ «setting Профиль backend меняется отдельным PR проекта ДО установки…» и последняя строка приёмки. SDACHA тоже его называет («Backend-ключ доставляет orchestrator отдельным PR проекта до установки 226»).

Живое состояние бэкенда: `gh api repos/a3ka/Complior-back/contents/harness.project.json` → `{"repoId":"Complior-back","hooks":null}`, последний коммит профиля `7b0375bf8dd6`. PR и кода с `archBrief` нет. Установка 226 до этого PR молча выключит pinned-дверь бэкенда, потому что лист отсутствует. Это обязательство orchestrator до cutover; живая проба `make_task` без `--arch-component` → `ARCH_COMPONENT_NET` ещё не выполнялась — С-3.

R-0102: литералов проекта в исполняемых строках `check_architecture_*.sh` нет.

## Остатки (контракт 192)

- ОСТАТОК: НЕ ЗАЩИЩАЕТ-2 (TOCTOU/PATH, ловец reviewer) — не укусил. `arch187_profile` проверяет профиль resolver-ом, затем перечитывает его по имени через `profile_get` (`check_architecture_contract.sh:146-153`). Окно между ними — санкционированная граница single-uid 996. Без одновременной записи — согласованность при симлинке внутрь, отказ при симлинке наружу, EACCES и висячем симлинке (вывод выше).
- ОСТАТОК: НЕ ЗАЩИЩАЕТ-3 (inherited shellcheck, ловцы CI/reviewer) — не укусил. Множества диагностик base и OBJECT совпадают поштучно по всем 6 файлам.
- ОСТАТОК: SDACHA Arb226b «конечная пакетная сетка и публичные представители разделений не доказывают отсутствие произвольной ошибки на непредставленном значении…» (ловцы reviewer и CI) — не укусил. Полный diff прочитан построчно. Валидатор достижим при любом `has("hooks")`. Оракул независим. Все отказные каналы (rc 1, пустой stdout, причина в stderr) судятся публично. 24 мутации управления красны, 2 эквивалента зелёные. Непредставленные значения проверены отдельно: `-0`, `own\u002frepo`, BOM, CRLF, дубли. Остаток по-прежнему конечен — это предел метода, а не дыра.
- ОСТАТОК: НЕ ЗАЩИЩАЕТ-1 (санкционированный false/удаление листа; ловцы — code review профиля проекта и его CI) — в станционном диффе не применим. Применим при доставке в бэкенд — С-3.
- Наблюдение Adv226c (совет вызовов 1–3): мутации `-le 1 → -le 2` в make_task/freeze/done батарея не ловит. Честная production отказывает (die на rc 2). В make_task и freeze резолвер стоит раньше, поэтому rc 2 там достижим только через окно TOCTOU. Новой достижимости не нашёл; оценка остаётся прежней — совет Adv226c.

## Норма 050 (паразитная сложность)

- `arch187_profile` (`check_architecture_contract.sh:129-158`):
  - (1) инв. 2 и 4 — трёхзначное чтение политики для двери и пина;
  - (2) глобальные `ARCH187_PRODUCT_REPO`/`ARCH187_REFUSAL` в принятой конвенции `ARCH187_*`, видны в отказах;
  - (3) один шов на дверь и пин — меньше мест, чем было (литерал repoId и `PRODUCT_REPO` env);
  - (4) 1 аргумент и rc 0/2 против resolver + profile_get — модуль глубокий;
  - (5) потребители — `arch187_scope`, pin.
  - ESSENTIAL.
- Блок 226 resolver (`profile_resolver.sh:941-965`, SCHEMA_LEVELS, merged `hooks`):
  - (1) инв. 1, единый источник грамматики;
  - (2) состояния нет;
  - (3) 1 файл;
  - (5) все двери.
  - ESSENTIAL.
- Трёхзначный `_scope_rc` в 4 потребителях:
  - (1) инв. 2 «все потребители сохраняют различение»;
  - (3) число мест прежнее — 4 вызова `arch187_scope` были и до этого.
  - ESSENTIAL.
- Публичный слой и st21–st63 батареи:
  - (1) Arb226b §2–3;
  - (2) производное от `source.json`;
  - (5) `--repo/--stabs/--catalog`, CI.
  - ESSENTIAL.
- `context.py` LATE_FROZEN: ESSENTIAL по свойству, но форма дефектна — Б-1.
- CI-шаг и замер: ПРОВОДКА, ESSENTIAL.

## Сверки

- СВЕРКА-АРХИТЕКТУРЫ: н/п. Контракт объявляет «АРХИТЕКТУРА: н/п — станционные двери, продуктовую модель не меняем». В диффе нет `bindings.json` и модели. Писатели не добавлены, двери прежние. Долг не расширен.
- СВЕРКА-СТАНДАРТОВ: н/п. `AGENTS.md` станции не объявляет `docs/ARCHITECTURE.md`/`docs/CODING-STANDARDS.md` (grep пуст).
- Режим проекта 996: sourceCanon не объявлен (строка КОНТЕКСТ), сверка карты н/п. Мобильного экрана нет.
- ПРОВОДКА (038): `guard=scripts/check_architecture_contract.sh`, `guard=scripts/check_architecture_pin.sh` существуют. `check_provodka` → rc 0. CI-шаг 226 исполняет семью, которая судит именно эти стражи. ПРОВОДКА-ЭНФОРСМЕНТ обоснована как конфигурация существующих стражей без новой поведенческой нормы.
