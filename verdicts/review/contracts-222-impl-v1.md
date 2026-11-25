FAIL
OBJECT=26571a3960da5614903d2acc07425f63eb1ba98c
СУД: репо=dev-harness; предмет=222; фаза=реализация; роль=reviewer; вызов=1 (полный); сессия=c907157c/Rev222; модель-факт=anthropic/claude-opus-5-5 (метаданные системного промпта сессии; трассу `models_actual --bind --session Rev222` сверяет оркестратор); автор Impl222/222b — implementer (MiniMax), Architect222b; предыдущие адверсарные: archive/222/adversary-v1-fail-64e736b4dc, archive/222/adversary-v2-fail-eaa6d22acc; правило остановки R-0092 п.2

# Суд реализации 222 — «любая модель любой роли», reviewer вызов 1 (полный)

**БЛОКИРУЕТ: Б-1** — правка `roles/{critic,critic-sol,arbiter,consultant,orchestrator}.md` (коммит `9869c6560`) не несёт адресной строки `РАЗРЕШИЛ-ВЛАДЕЛЕЦ:`. Frozen 222/1 ставит эту строку условием правки ролей: §Зоны «Пересечения с уставными документами», §Предпосылки, §Незаполненные требования. Класс: процедура/норма (reviewer п.6 «Норма не тронута молча»), не код. Содержание правок проверено и верно (§1б). Ремонт — санкция владельца на тех же блобах, затем scoped-повтор.

**СОВЕТ: 6** — файл находок `.review/2026-11-25-2221.md` (`status: ready`):
- С-1, С-2 — дыры батареи К-08 (architect). Среди них остаток К-08 Adv222b. Production на каждом месте честна.
- С-3, С-4 — production (implementer, при следующей правке).
- С-5 — устаревший довод в `roles/consultant.md`.
- С-6 — норма 050, `check_adv222.py`.

Я перепроверил ВСЁ: область правки, сырой вывод, не переписаны ли проверки под код. Свойства И1–И5 проверены своими мирами (`rev222_worlds.py`, 83 входа). Это не клетки батареи. Проверены и 23 своих мутанта production против батареи 222 и соседей 198/173/104.

Production по И1–И5 честна. Единственный блок — отсутствие санкции владельца на правку ролей. Механизм его не ловит: `check_charter` судит только устав по `AGENTS.md:245-246`.

## 1. Область правки

`git merge-base origin/main HEAD` = `880ff787ed8d221e13863afac60208a99843814b`. `git diff --name-status 880ff787e HEAD`:
```
M	.github/workflows/ci.yml
M	.omp/agents/arbiter.md
M	.omp/agents/consultant.md
M	.omp/agents/critic-sol.md
M	.omp/agents/critic.md
M	.omp/agents/orchestrator.md
M	fixtures/check_fork_route/red_marshrut_b_volja_batch.sh
M	fixtures/check_fork_route/red_otvechennaja_dvojnaja_rol.sh
M	fixtures/check_fork_route/red_zapret_dvojnoj_roli.sh
M	fixtures/workshop_project/lyubaja_model_222/SDACHA.md
A	fixtures/workshop_project/lyubaja_model_222/check_adv222.py
M	fixtures/workshop_project/lyubaja_model_222/model/check_sud_model.ts
M	fixtures/workshop_project/lyubaja_model_222/probe.py
M	fixtures/workshop_project/lyubaja_model_222/source.json
A	fixtures/workshop_project/lyubaja_model_222/stabs/st34-denied-per-call-bypass.json
A	fixtures/workshop_project/lyubaja_model_222/stabs/st35-empty-assignment-absent.json
M	fixtures/workshop_project/modeli_tolko_v_reestre_198/probe.py
M	fixtures/workshop_project/sud_model_173/probe.py
M	fixtures/zashchita_main_104/battery_stubs.sh
M	fixtures/zashchita_main_104/red_sud_model_dver_spavna.sh
M	registry/ci-steps.tsv
M	registry/ci-zamery.tsv
M	roles/arbiter.md
M	roles/consultant.md
M	roles/critic-sol.md
M	roles/critic.md
M	roles/orchestrator.md
M	scripts/check_fork_route.sh
M	scripts/check_sud_model.sh
M	scripts/judge_gate.sh
M	scripts/roles.ts
```
`git log --format='%h %an %cn %s' 880ff787e..HEAD`:
```
26571a396 architect architect 222: cover denied per-call and empty assignment regressions
98994a152 implementer implementer 222: явное пустое --assigned-model — именованный отказ rc 2 (присутствие флага отдельно от значения)
465b42261 orchestrator orchestrator orchestrator: 222 CI-шаг check:lyubaja-model-222-family-selftest (вес 45, замер 33 с: --repo 13 + --stabs 19 + --sintaksis 0 при load 1.3), пересчёт JOBS ci.yml; gen_ci_steps --check rc 0
9869c6560 implementer implementer 222: перепин ожиданий соседних семейств и ролевые нормы — «любая модель любой роли»
79a8c6afd implementer implementer 222: дверь сверки модели — объявленность в реестре вместо тира роли; per-call назначение
```

### 1а. Зоны (frozen/contracts/222/1, `git show 'frozen/contracts/222/1^{commit}:…' | grep '^ЗОНА'`)

- **implementer** (`79a8c6afd`, `9869c6560`, `98994a152`). Все пути лежат в ЗОНЕ implementer: `scripts/{check_sud_model.sh,judge_gate.sh,roles.ts,check_fork_route.sh}`, `fixtures/zashchita_main_104/`, `fixtures/workshop_project/{sud_model_173,modeli_tolko_v_reestre_198}/`, `fixtures/check_fork_route/`, пять `roles/*.md`, `.omp/agents/`.
- **architect** (`26571a396`). Только `fixtures/workshop_project/lyubaja_model_222/**`.
- **orchestrator** (`465b42261`). Ровно три файла: `ci.yml`, `ci-steps.tsv` (+1 строка), `ci-zamery.tsv` (+1 строка).
  - Множество ключей `keys:` в `ci.yml`: база 114, HEAD 115. `comm -3` даёт единственный `check:lyubaja-model-222-family-selftest`; остальное — пересчёт сгенерированного блока JOBS.
  - `bash scripts/gen_ci_steps.sh --check` даёт rc 0.
- **Вне зон ничего нет.**
- **Контракт не менялся.** Блоб `contracts/222-sudja-ljubaja-model.md`: `348c38f8d36b00d278a762c454b2c9a82b23c71a` и на `frozen/contracts/222/1^{commit}` (`244370cb4`), и на HEAD. Тег — предок HEAD.
- **Атомарность.** Пять коммитов. У каждого своя роль, у каждого ссылка на предмет 222.
- **Перепин 198 — ровно четыре клетки И5.** `door_spawn_fallback_refused`, `door_spawn_foreign_refused`, `door_stale_primary`, `repo_door_judges`. Сделан тем же коммитом, что меняет дверь (`79a8c6afd`). Прочие клетки, `repo_seam_*` и `STAB_BIND` не тронуты: `git diff 880ff787e HEAD -- fixtures/workshop_project/modeli_tolko_v_reestre_198/` — только эти четыре функции и константа `UNDECLARED`.
- **104/173/fork_route.** Изменены только ожидания снятого модельного запрета.
  - 104: входы 2, 3, 8 — отказ сменился на rc 0. Добавлен вход 11 «модель не объявлена». Стаб t104-m14 перепривязан на вход 9 (frontmatter). Привязка session/OBJECT и отсутствие `--sud` не тронуты.
  - 173: отказ спавна разведён: у пина frozen 104/2 и у живого предмета свои тексты. Bare/full и чужой полный провайдер в СВЕРКЕ ФАКТА сохранены.
  - fork_route: снята сверка равенства МОДЕЛЬ. Обязательность строки МОДЕЛЬ, грамматика, маршруты и счёт сохранены.

### 1б. Содержание правок ролей (по заданию: только ли модельные пины)

`git diff 880ff787e HEAD -- roles/`:

- **`arbiter.md:53-56`.** Снято «Штатно arbiter — Fable, architect — GLM». Остались назначение из реестра, ссылка на 166 и сверка факта/fallback. Это пин, как указано в «Существующем».
- **`consultant.md` §2 и §«Запрет двойной роли».**
  - Снят отказ «МОДЕЛЬ свидетеля = АВТОР → самоподтверждение» и пункт 3 из четырёх отказов барьера. Это зеркало `check_fork_route.sh`, контракт 222 разрешает его снять.
  - Запрет «совмещения ОДНИМ АКТОРОМ в одном споре», обязательность `МОДЕЛЬ:` и `ПОДТВЕРЖДЕНО:` сохранены.
  - Устаревший довод `:165` и неявность запрета подписывать собственную запись вынесены в совет С-5. Это не блок: И4 и НЕ ЗАЩИЩАЕТ п.3 оставляют самосуд нормой ролей, и формулировка «вторая РОЛЬ» плюс `critic.md:36` его держат.
- **`critic.md:36`.** «не совмещаются одной моделью» стало «ОДНИМ актором». «Судья не судит собственную работу» сохранено.
- **`critic.md` и `critic-sol.md` §Модель.** Снят «Sol, тир apex-sol» и «Общий advisor … не годится». «Существующее» прямо называет это вторым нормативным пином.
  - Вместе с пином ушла фраза «автоматического повышения до Astra нет». Её смысл держит следующий абзац «Повышения модели по триггеру у тебя нет».
  - Добавлено «подпись одной моделью в нескольких ролях законна». Это §Предмет 222.
- **`orchestrator.md:150-159`.** Добавлены раздел и норма-строка ПРОВОДКИ, совпадающая дословно с `role=roles/orchestrator.md «…»` контракта (сверено), плюс абзац о хвосте `--assigned-model`.
- **Итог.** Других норм эти правки не задевают; семантики сверх объявленной нет. Нарушено только условие санкции (Б-1).

### 1в. Не переписаны ли проверки под код

Батарею 222 после заморозки менял только architect (`26571a396`). Его дельта:
- клетки 77–83;
- st34/st35;
- `check_adv222.py`;
- три строки в эталонной модели `model/check_sud_model.ts` (пустое назначение → rc 2, как велит И1 «selector непустой»).

Прежние 76 клеток и 33 стаба не ослаблены: `git diff` по `probe.py` добавляет `assignment_arg` и семь `Case`, ни одного ожидания не меняет.

Implementer менял чужие семьи 104/173/198/fork_route. Каждая правка снимает ровно отказ, который 222 отменил, и проверена выше по тексту диффа. Ни одно ожидание вне модельного запрета не ослаблено.

## 2. Сырой вывод — регресс (rc и числа)

Чистый клон: `git clone ssh://git@github.com/a3ka/dev-harness.git` → `/tmp/dev-harness-verify/rev222-clean`. Единственный remote — origin. `git checkout --detach 26571a396…` (урок 211). Окружение:
- `TMPDIR=/tmp/dev-harness-verify/scratch-rev222`;
- `VALIDATE_STD_SHELLCHECK=…/shellcheck/0.11.0/shellcheck`.

`W=bash fixtures/workshop_project/lyubaja_model_222/red_lyubaja_model_222.sh`.

| команда | rc | вывод / числа |
|---|---|---|
| `W --repo .` | 0 | `SUBJEKT 222: KLETKI 83 KRASNYH 0` |
| `W --model` | 0 | `MODEL 222: KLETKI 83 KRASNYH 0` |
| `W --stabs` | 0 | `MODEL 222: KLETKI 83 KRASNYH 0` … 35 строк `STAB … KRASNYJ` … `STABY 222: STABS 35 ZHIVYH 0` |
| `W --sintaksis` | 0 | — |
| `W --catalog` | 0 | `KLETKI=83 STABS=35 SVJAZI=64` |
| `python3 …/check_adv222.py` | 0 | st34 → `verdict-denied-per-call-wrong-fallback`; st35 → три пустых; два независимых мутанта красят свои клетки |
| `198 --repo .` | 0 | `REPO_CELLS=12 FAILURES=0` |
| `198 --model` | 0 | `CELLS=28 FAILURES=0` |
| `198 --stabs` | 0 | `STABS=17 CAUGHT=17` |
| `fixtures/zashchita_main_104/red_*.sh` (6) | 0 ×6 | каждый `ЗЕЛЕНО: …` |
| `fixtures/zashchita_main_104/battery_stubs.sh` | 0 | 17 различных `t104-mN пойман`, живых 0 |
| `173 --repo` / `--model` / `--stabs` | 0/0/0 | 19 `ZELENO` в `--repo` и в `--model`; `--stabs` — `STAB … caught` |
| `fixtures/check_fork_route/red_*.sh` (11) | 0 ×11 | — |
| `fixtures/check_fork_route/case_*.sh` (5) напрямую | 1 ×5 | `BARRIER: unbound variable`. Это антиплацебо-кейсы, они исполняются только раннером (строка ниже), и на базе так же |
| `bash scripts/verify_antiplacebo.sh --scope check_fork_route` | 0 | `барьеров: 1 · фикстур: 5 · предъявлено красным повторным прогоном: 5` |
| `bash -n` по 8 изменённым `.sh` | 0 ×8 | база тоже 0 ×8 |
| shellcheck 0.11.0 `-s bash -S warning -f gcc` | — | число строк, новое/база: 7 файлов 0/0; `judge_gate.sh` 3/3 (не хуже базы) |
| `node --check scripts/roles.ts` | 0 | — |
| `npm run gen:harness -- --check` | 0 | `харнес соответствует roles/ (13 ролей)` |
| `bash scripts/gen_ci_steps.sh --check` | 0 | — |
| `bash scripts/check_provodka.sh . contracts/222-sudja-ljubaja-model.md` | 0 | — |
| `bash scripts/check_precision_gate.sh . contracts/222-…` | 1 → 0 | Первый прогон: «реестр заморозок не читается: missing-remote», на origin за время работы появились новые теги. После `git fetch origin '+refs/tags/*:refs/tags/*'` — rc 0, `OK` |
| `bash scripts/pre_critic.sh contracts/222-sudja-ljubaja-model.md` | 0 | `КРИТИК: дверь зелёная`; `ok сдаточный лист …`, гейты предпосылок/трека/модели угроз/потолков/проводки ok. Первый прогон до `fetch --tags` дал rc 1 только по строке 61 листа (precision `missing-remote`), см. строку выше |
| `bash scripts/check_sdacha.sh . contracts/222-sudja-ljubaja-model.md --run` | 0 | `СДАЧА: лист зелёный (двери=11 карта=17/17 дельта=7)`, включая строку `check_adv222.py` |

**Своя мера счётных утверждений (B2d).** Число клеток посчитано импортом `probe.py`, а не раннером:
- `len(CASES)=83`, уникальных 83;
- `source.json`: 35 записей, уникальных имён 35, связей 64;
- ссылок на несуществующие клетки 0;
- клеток без стаба 30 — это допустимо, у них честные полюса.

Совпадает с заявленным «83/35/64». 104: 17 различных id пойманы, как в теле `98994a152`. 173: по 19 клеток.

**Чистый клон (урок 211).** Все прогоны выше выполнены в клоне, где кроме origin ничего нет. `--repo`, `--model` и `--stabs` дали rc 0, значит пины-предки достижимы с origin.

## 3. Свои миры и мутанты production (не клетки батареи)

### 3а. Миры

Скрипт `rev222_worlds.py`: 83 входа, временный мир с ПРОБЕЛОМ в пути, фейковый конфиг. В конфиге:
- tier `audit` = `@p`/`@r`;
- tier `lit` = литерал `lv/literal-7` без записи в `models`;
- `models` = `pv/base-1`, `rv/res-2`, `ov/oth-9`, `ov/oth-9:xhigh`.

Реальные двери копируются из дерева. Сырой вывод — `имя rc журнал stderr`:

```
S02-spawn-tier-fallback 0 | S03-spawn-other-declared 0 | S04-spawn-tier-literal-other-role 0 | S09-spawn-bare-173 0 | S10-spawn-declared-effort 0
S05-spawn-substring     1 ОТКАЗ: модель не объявлена: ov/oth (тир роли audit; в реестре назначений такой модели нет)
S06-spawn-suffix        1 ОТКАЗ: модель не объявлена: v/oth-9 …
S07-spawn-case          1 ОТКАЗ: модель не объявлена: PV/base-1 …
S08-spawn-foreign-provider-same-bare 1 ОТКАЗ: модель не объявлена: xx/base-1 …
S11-spawn-undeclared-effort 1 … pv/base-1:xhigh …   S12-spawn-undeclared-route 1 … pv/base-1@route …
S13-spawn-no-model      1 ОТКАЗ: спавн судьи без явного agent: critic
S14-spawn-space 2 / S15-spawn-nfkc-fullwidth 2 / S18-spawn-cmdsubst 2 (вне алфавита; файла PWNED нет) / S16-spawn-role-task 2
S19 no-config 2 / S20 broken 2 / S21 array 2 / S22 empty-object 2 (резолвер назначений отказал)
V01-primary 0 | V02-bare-primary-173 0 | V21-arbiter-literal-tier 0 | V16-denied-fallback 0
V03-foreign-provider-full 1 вердикт не материализуется | V04-other-no-assigned 1 | V05-fallback-as-allowed-no-assigned 1
V06-object-dash 1 ОТКАЗ: трасса не об объекте суда: -, суд aaaa…   V07 other-object 1 | V08 other-session 1 ОТКАЗ: чужая трасса
V09-missing-trace 2 ОТКАЗ: трасса не читается | V13 three-fields 2 | V14 crlf 2 | V22 status-other 2 | V15 no-role-row 1
V10-good-then-bad-model 1 | V11-good-then-bad-session 1 | V12-good-then-bad-object 1
V17-denied-fallback-effort-K08 1 ОТКАЗ: фолбэк вне списка тира: critic на rv/res-2:xhigh, тир audit (Н-270)
V18-denied-fallback-prefix-K08 1 ОТКАЗ: фолбэк вне списка тира: critic на rv/res-20, тир audit (Н-270)
V19-denied-other-declared 1 | V20-arbiter-denied-no-fallback 1
A01-assigned-other-fact-other 0 | A13-assigned-denied-fact-fallback 0 | A24-assigned-tier-literal 0
A02-assigned-other-fact-primary 1 вердикт не материализуется | A03 plain→fact-effort 1 | A04 effort→fact-plain 1 | A12 full-fact-foreign-provider 1
A05-assigned-substring 2 ОТКАЗ: назначенная модель не объявлена в конфиге: ov/oth | A09-assigned-case 2 | A10-assigned-undeclared 2
A06-assigned-empty 2 ОТКАЗ: назначенная модель пуста … | A17-assigned-flag-last 2 (не зависает) | A07 space 2 | A08 trailing-space 2 | A21 cmdsubst 2
A14-assigned-denied-fact-assigned 1 ОТКАЗ: фолбэк вне списка тира | A18 assigned+object-dash 1 | A19 assigned good-then-bad 1 | A20 «--root» как значение 2
A11-assigned-bare-fact-foreign-provider 0   ← С-3 (буква 173)
S23-spawn-models-string 0                   ← С-4 (битая форма models)
G01-gate-honest 0  журнал: verdict\tcontracts/222\tcccc…\taccept\t1\n
G04-gate-assigned-honest 0 журнал: verdict\tcontracts/222\tcccc…\taccept\t1\n
G02 wrong-fact 1 / G05 assigned-wrong-fact 1 / G09 assigned-undeclared 2 / G10 object-dash 1 / G11 denied-wrong 1 — журнал пуст (append после двери)
G03-gate-no-sud 1 свидетельство судьи не передано | G06 assigned '' 1 | G07 флаг без значения 1 «аргументов 10, нужно 5, 9 или 11» | G08 хвост не --assigned-model 1 | G12 12 аргументов 1
```

### 3б. Дифференциал база/OBJECT

На 50 входах без `--assigned-model` те же миры прогнаны на `scripts/*` базы `880ff787e`. 34 из 50 совпали байт-в-байт (rc, stdout, stderr, журнал). Совпали все входы привязки session/OBJECT, пятиколонной трассы, `-` в пятом поле, отсутствия трассы, второй строки, denied, отказов gate, frontmatter, алфавита ролей и битого/пустого конфига.

16 расхождений, все только там, где их объявил контракт:
- спавн объявленной модели: rc 1 → 0 (S02, S03, S04);
- текст отказа спавна «модель не тира роли» → «модель не объявлена» при том же rc 1 (S05–S08);
- алфавит selector `-._/` → `-._/@:`:
  - S10: rc 2 → 0 (объявленный effort);
  - S11/S12: rc 2 → 1 «модель не объявлена»;
  - S14/S15/S18: только текст алфавита в отказе;
  - V17: rc 2 «вне алфавита» → rc 1 «фолбэк вне списка тира»;
- S17 (`--x` на спавне): rc 1 → rc 2 (fail-closed резолвера);
- S23: С-4.

### 3в. Мутанты production

Свои мутанты (`rev222_mutants.py`, рабочее дерево — git worktree одноразового клона). У каждого: эффект в моих мирах, затем `W --repo .`.

| мутант (место) | эффект в мирах | батарея 222 |
|---|---|---|
| m01 спавн = primary тира (`check_sud_model.sh:304`) | S02/S03/S04/S10 0→1 | rc 1, 6 красных |
| m02 `includes` в объявленности (`roles.ts:445`) | S05/S06 1→0 | rc 1, 4 |
| m03 `endsWith` | S06 1→0 | rc 1, 2 |
| **m04 `toLowerCase`** | S07 1→0, A09 2→0 | **rc 0, 0 — С-2** |
| m05 `split('/').pop()` | S06/S07/S08 1→0 | rc 1, 2 |
| **m06 отрезать `:effort` в объявленности** | S11 1→0 | **rc 0 — С-2** |
| m07 `normalize('NFKC').trim()` | эффекта 0: недостижимо, bash-алфавит отсекает раньше (S14/S15 rc 2) | rc 0, не контрпример |
| m08 назначение без `:effort` (`:274`) | A04 1→0 | rc 1, 3 |
| m09 allowed = любая объявленная (`:418`) | 10 входов | rc 1, 7 |
| m10 `-` в пятом поле принят (`:408`) | V06/A18/G10 1→0 | rc 1, 2 |
| m11 нет трассы = rc 0 (`:362`) | V09 2→0 | rc 1, 1 |
| m12 судится первая строка (`:367 \| head -1`) | V10/V11/V12/A19 1→0 | rc 1, 1 |
| m13 gate игнорирует rc двери (append до сверки; `judge_gate.sh:135`) | G02/G05/G09/G10/G11 → 0 + журнал | rc 1, 6 |
| m14 denied = любая объявленная (`:429`) | 4 входа | rc 1, 2 |
| **m15 префиксная сверка denied (Adv222b)** | V17/V18 1→0 | **rc 0 — С-1 (остаток К-08)** |
| m16 allowed без сверки | 11 входов | rc 1, 9 |
| m17 gate теряет `--assigned-model` (`judge_gate.sh:128`) | G04 0→1, G05 1→0 | rc 1, 4 |
| **m18 объявленность без tiers (`roles.ts:396-408`)** | S04 0→1, A24 0→2 | **rc 0 — С-2** |
| m19 объявленность без models | 18 входов | rc 1, 21 |
| m20 назначение без проверки объявленности (`:272`) | 7 входов | rc 1, 3 |
| m21 спавн принимает всё (`:304`) | 7 входов | rc 1, 3 |
| m22 сессия не сверяется (`:404`) | V08/V11 1→0 | rc 1, 2 |
| m23 (ремонт С-3) канон из `--resolve-selector` | A11 0→1 | rc 0, 83/0 |

Живые m04, m06, m15 и m18 предъявлены соседям на реальной двери. Каждый мутант даёт rc 0 по всем: `198 --repo`, `173 --repo`, `104 dver_spavna`, `104 materializatsija`, `104 judge_gate`.

После прогонов `git status` чистый.

**Различие двух списков `roles.ts` ↔ `check_sud_model.sh`.**
- Список объявленных один — `declaredModels` в `roles.ts`. Дверь своего списка не ведёт, только `sud_declared` → `--resolve-selector`.
- Эквивалентность 173 реализована дважды: `sud_same_model` (bash, `check_sud_model.sh:148`) и `sameModelName` (TS, `roles.ts:384`). Я сверил ветви: обе снимают префикс до первого `/` и только при одном bare. На всех 83 входах расхождений между объявленностью и сверкой факта нет. Двойная реализация учтена в строке 050 ниже.

## 4. Дефекты честной production

Доказанных достижимых дефектов на конформных входах нет.

- **Injection/expansion.** В аргументах (selector, session, OBJECT, пути с пробелом) нет: `$(touch PWNED)` как модель и как назначение даёт rc 2 «вне алфавита», файла нет. `--root`/`--x` как значение дают rc 2: резолвер отвергает ведущие `--`.
- **`set -e` / `pipefail`.** rc не теряется: `rc=$?` у двери и `|| rc=$?` в gate, append после `[ "$rc" -eq 0 ] || exit "$rc"`; мутант m13 краснит батарею.
- **Fail-open.** На пустом, битом, массиве или без файла конфига fail-open нет: везде rc 2. Fail-open есть только на битой ФОРМЕ `models` — С-4, вне конформных входов.
- **Тексты ролей.** Самосуд они не ослабили (§1б); совет С-5.
- **Наблюдение, не 222.** `check_sud_model.sh --verdict critic … --trace` без значения в конце аргументов зависает (`timeout 5` → rc 124) и на базе `880ff787e`, и на OBJECT. Это `shift 2` при одном аргументе у `--trace/--object/--session/--root/--spawn`. `judge_gate` передаёт аргументы полной тройкой, так что через неё это недостижимо. Impl222b починил ровно `--assigned-model`. Кандидат в NABLIUDENIA, вне зоны 222.

## 5. Остатки

- ОСТАТОК: К-08 (Adv222b, префиксная/effort-сверка denied) — не укусил.
  - В диффе: `scripts/check_sud_model.sh:429` — буквальная `sud_same_model "$m" "$fbexpected"`. V17 (`rv/res-2:xhigh`), V18 (`rv/res-20`) и вход Adv222b с `--assigned-model` дают rc 1 «фолбэк вне списка тира».
  - Честной production на контрпримере достаточно.
  - Батарею закрывает простая клетка, проверено (С-1): 3 клетки зелёные на production и reference, все красные на мутанте; без них батарея на мутанте `KRASNYH 0`.
- ОСТАТОК: НЕ ЗАЩИЩАЕТ п.1 (текстовый `--assigned-model` не аутентифицирует себя; ловцы — суд и trace-протокол) — не укусил. Норма переноса из запроса, а не из трассы, внесена в `roles/orchestrator.md:150-159`. Дверь значение не выводит из трассы: m17/G04 показывают перенос хвоста.
- ОСТАТОК: НЕ ЗАЩИЩАЕТ п.3 (самосуд одного актора; ловец — независимый reviewer) — не укусил. Остаются `critic.md:36` «Судья не судит собственную работу», `critic.md:200` / `critic-sol.md:166` «судья не судит собственную работу» и `consultant.md` «СОВМЕЩЕНИЕ ОДНИМ АКТОРОМ». Неявность §2 consultant — С-5.
- ОСТАТОК: НЕ ЗАЩИЩАЕТ п.4 (конечная батарея) — укусил в батарее, не в production. Живые мутанты m04/m06/m15/m18 — С-1/С-2.

## 6. ПРОВОДКА (контракт 038)

- `guard=fixtures/workshop_project/lyubaja_model_222/red_lyubaja_model_222.sh` существует и подключён шагом `check:lyubaja-model-222-family-selftest` (`registry/ci-steps.tsv`: `--repo .`, `--stabs`, `--sintaksis`). Это барьер именно этого предмета.
- `role=roles/orchestrator.md`: норма-строка дословно, `:154`.
- ПРОВОДКА-ЭНФОРСМЕНТ («после ленда … переключает на --repo .») уже исполнено шагом.
- `check_provodka.sh` даёт rc 0.

## 7. Паразитная сложность (050)

- **`roles.ts --resolve-selector`** (`sameModelName`, `declaredModels`, `resolveSelectorCli`, диспетчер).
  - (1) И5: «получает назначения и объявленность только от roles.ts».
  - (2) Состояния нет, rc 0/1/2, stdout — канон, но дверь его отбрасывает (С-3).
  - (3) Эквивалентность 173 теперь живёт в двух файлах (bash + TS): число совместно меняемых мест выросло с 1 до 2.
  - (4) Один режим и `--root` против разбора реестра, алиасов и сравнения — модуль глубокий.
  - (5) Потребитель — `sud_declared`.
  - ESSENTIAL: дверь читать реестр сама не вправе (И5).
- **`check_sud_model.sh --assigned-model` + `assigned_given`.**
  - (1) §Предмет, И2.
  - (2) Флаг в argv явный; `assigned_given` — внутренний признак разбора.
  - (3) Совместно меняются дверь, gate и норма оркестратора, три места — новое свойство.
  - (4) +1 флаг, +3 причины rc 2.
  - (5) Потребители — gate и клетки.
  - ESSENTIAL.
- **`judge_gate.sh`, форма из 11 аргументов.** (1) §Предмет. (2) argv. (3) Меняется вместе с дверью. (4) +1 форма. (5) Норма оркестратора и клетки `gate-*`. ESSENTIAL.
- **`check_fork_route.sh`.** Чистое удаление ветвей: сложность уменьшена.
- **`stabs/st34`, `st35` (одна семья).** (1) И2 (denied/per-call, пустое назначение). (5) `--stabs` в CI. ESSENTIAL.
- **CI-шаг.** (1) ПРОВОДКА guard. ESSENTIAL.
- **`check_adv222.py`.**
  - (1) Свойства контракта нет.
  - (2) Состояния нет.
  - (3) Мутации живут в двух местах (`source.json` и строки скрипта).
  - (4) Аргументов нет.
  - (5) Потребитель — только SDACHA / `check_sdacha --run`, логику `--stabs` повторяет.
  - ACCIDENTAL. Фрагмент, отсутствующее свойство и более простая форма названы — С-6. Оставлен советом: фикстура без состояния, production не задевает.

СВЕРКА-СТАНДАРТОВ: неприменимо. `AGENTS.md` dev-harness не объявляет `docs/ARCHITECTURE.md` / `docs/CODING-STANDARDS.md`: `grep` пуст, файлов нет.

СВЕРКА-АРХИТЕКТУРЫ: неприменимо. Модели архитектуры 188 в dev-harness нет (`tooling/checks/cli.js` отсутствует, `bindings.json` предмета нет). Размещение не меняется: дверь остаётся в `scripts/check_sud_model.sh`, резолвер — в `scripts/roles.ts`. Зависимости: дверь → `node roles.ts`, как в 198; jq не добавлен. Писатель журнала один — `judge_gate.sh`, append после двери. Новых операций, ресурсов и долга нет. Уровень diff модели: нет модели, L-уровня нет.

Режим проекта (996): sourceCanon не объявлен — неприменимо. Мобильного экрана нет — неприменимо.
