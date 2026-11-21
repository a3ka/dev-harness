accept
OBJECT=e06e3a84cd9b8b5224c86caf8eab29974795abfe
СУД: repo=dev-harness (+ продукт Complior-mob только для чтения); предмет=995; фаза=реализация frozen/contracts/995/5 (проба HTTP_UNAVAILABLE, свидетель URL, регресс env); роль=reviewer; сессия=Rev995T; вызов=один узкий reviewer по слову владельца 14:33/14:35 и фиксации консультанта 18:01 (OBJECT `e06e3a84cd` кодово тождествен общему OBJECT `806d73d624`; вердикты на `e06e3a84cd`/`7c74110225` автоматически не перенесены — всё перепрогнано заново); класс риска=рисковый («безопасность», `contracts/995-cmp-mob-001-android-pilot.md:4`); adversary предшествовал=Adv995c accept на том же OBJECT (`git show 7c74110225:verdicts/adversary/contracts-995-impl-v1.md`, строки 1–2); модель-факт=anthropic/claude-opus-5-5, allowed (`bash scripts/models_actual.sh --tsv --bind --session Rev995T | cut -f1-3` rc 0, две строки `reviewer anthropic/claude-opus-5-5 allowed`).
СВЕРКА-АРХИТЕКТУРЫ: `git diff --stat e06e3a84cd 806d73d624` — три вердиктных файла (`.review/2026-11-19-120.md`, `verdicts/adversary/contracts-995-impl-v1.md`, `verdicts/review/contracts-995-impl-v2.md`), `git diff --exit-code e06e3a84cd 806d73d624 -- fixtures contracts scripts registry` rc 0. Код к frozen (`git diff --name-status frozen/contracts/995/5 e06e3a84cd -- fixtures/workshop_project/pilot_995/ contracts/995-…md`) — те же 4 файла батареи в ЗОНЕ architect (`:119`): A `url_witness.py`, A `env_override_regression.py`, A `SDACHA_probe_http_unavailable.md`, M `runtime_probe.py`. Размещение — внутри существующей батареи; зависимости — stdlib + соседний `url_witness`; писателей и операций продукта нет; `bindings.json`/`architecture.lock.json` не тронуты (`git diff --name-status 806d73d624 e06e3a84cd -- bindings.json architecture.lock.json docs/architecture registry` пуст); долг не расширен; уровень diff модели — L0 (продуктовая архитектурная модель не затронута). Расхождения модели и работы нет — находка 188 не заводилась.
СВЕРКА-СТАНДАРТОВ: AGENTS.md станции не объявляет документ архитектуры и стандарт кода (`ARCHITECTURE.md|CODING-STANDARDS` в `AGENTS.md` — 0 совпадений); продукт в дельте не меняется — неприменимо.
НАХОДКИ: блоков 0. `.review/2026-11-19-120.md` (на `806d73d624`, status: ready) — С-1, С-2, С-3 остаются советами (триаж ниже, файл не изменялся); новых находок нет; развилок 3 (ниже).

# Предмет и метод

Задание `/tmp/dev-harness-verify/task-rev995t.md` прочитано целиком. Прочитаны целиком прошлый суд
`verdicts/review/contracts-995-impl-v2.md` и `.review/2026-11-19-120.md` (через `git show 806d73d624:…`),
accept Adv995c (`git show 806d73d624:verdicts/adversary/contracts-995-impl-v1.md`), арбитраж
`verdicts/arbitration/995-proishozhdenie-oracle-url.md`, файлы батареи `runtime_probe.py`,
`env_override_regression.py`, `url_witness.py`, `runtime.test.tsx`, `SDACHA_probe_http_unavailable.md`,
`restart/red_ci_e2e_restart_995.sh`, места контракта `:4`, `:41`, `:94`, `:119–132`, `:208–251`.

- pwd: `/home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/tfebb3c6ec/m`.
- `git fetch ssh://git@github.com/a3ka/dev-harness.git refs/heads/wip/995/rev-e06` → FETCH_HEAD
  `7c74110225d9b63686152e41c088e9fa2f9f2d4c`; `git merge-base --is-ancestor e06e3a84cd… FETCH_HEAD` rc 0.
  `git switch --detach e06e3a84cd…`; `git rev-parse HEAD` → `e06e3a84cd9b8b5224c86caf8eab29974795abfe` = OBJECT.
  `git fetch --tags …` (три тега отвергнуты «would clobber existing tag» — локальные, к 995 не относятся);
  `git fetch … refs/heads/wip/995/architect` → `806d73d624a935d1dbaf822e32a2b36fdfbc49e0` (только чтение).
- Продукт: `git -C /home/harness/projects/Complior-mob archive 01e081b8dcc95c4f9cba353b656c70301fc4792c`
  → `<копия>/.scratch-rev995t/product`, `npm ci --prefix …/product/mobile --no-audit --no-fund` rc 0.
  Свежий main продукта: `git -C … rev-parse main` = `e0f3c754…` (ушёл дальше `7c7e333b67`;
  `merge-base --is-ancestor 7c7e333b67 main` rc 0). Дополнительный прогон — на названном
  `7c7e333b675f6a3ffdd6990ace04358d756fa7d8` (mob#213 влит): archive → `.scratch-rev995t/main7c7`, `npm ci` rc 0.
  Основной чекаут продукта не трогался.
- sha256 на OBJECT = SDACHA = Adv995c: runtime.test `c9aa30fa…94f6`, runtime_probe `268e4513…e5a5`,
  env_override_regression `49156ade…78b4`, url_witness `a2842f16…2c79`.

## Изоляция: единственное отступление от буквы команд (см. Р-1)

Авторские команды из моей копии дают **rc 2**: `env_override_regression.py --repo <копия>/product` →
`995 env ORACLE_TAMPERED: DISPOSABLE_REQUIRED: продукт обязан быть одноразовым клоном под /tmp/dev-harness-verify`;
`runtime_probe.py --repo <копия>/product --case HTTP_UNAVAILABLE` → `995 INFRASTRUCTURE: DISPOSABLE_REQUIRED`.
Корень одноразовой зоны зашит (`runtime_probe.py:64`, `env_override_regression.py:72`), а задание запрещает
писать в `/tmp/dev-harness-verify`. `unshare --user --mount` → `write failed /proc/self/uid_map: Operation not
permitted`. Поэтому прогоны идут из копии батареи `.scratch-rev995t/battery`, где заменён ровно этот литерал
(скрипт `.scratch-rev995t/mk_battery.py`, якорь `count == 1`, иначе rc 2). `diff -r` копии с деревом OBJECT —
ровно две строки: `:72 SCRATCH_ROOT` и `:64 is_relative_to(...)` → путь `.scratch-rev995t`. Логика, CASES, MUTANTS,
якоря мутаций, свидетель — байт-те же. Restart-батарея запущена прямо из дерева OBJECT (`tempfile` уважает
`TMPDIR=<копия>/.scratch-rev995t`).

# 1. Тождество кода OBJECT и общего OBJECT

`git diff --stat e06e3a84cd 806d73d624` → `.review/2026-11-19-120.md | 52 +`, `verdicts/adversary/contracts-995-impl-v1.md
| 113 +-`, `verdicts/review/contracts-995-impl-v2.md | 167 +`; `3 files changed`. Код/батарея/контракт/скрипты/registry
(`git diff --exit-code e06e3a84cd 806d73d624 -- fixtures contracts scripts registry`) rc 0. `git diff --stat e6555cacd7
e06e3a84cd` → один файл `verdicts/arbitration/995-proishozhdenie-oracle-url.md | 137 +`. Авторы дельты `e06e3a84cd..806d73d624`
(`git log --format='%an <%ae> | %cn <%ce>'`): `7c74110225 adversary | adversary`, `806d73d624 reviewer | reviewer`.
Фиксация консультанта 18:01 подтверждена своей мерой: кодово тождественны.

# 2. Сырой вывод (мои прогоны)

B = `.scratch-rev995t/battery` (см. «Изоляция»), P = `.scratch-rev995t/product` (01e081b8), M = `.scratch-rev995t/main7c7` (7c7e333b).
Все с `TMPDIR=<копия>/.scratch-rev995t PYTHONDONTWRITEBYTECODE=1`.

| команда | rc | ключевой вывод (дословно) |
|---|---:|---|
| `python3 B/env_override_regression.py --repo P --stabs` (прогон 1) | 1 | `control parent=EXPO_PUBLIC_API_URL:absent: rc=1`; stderr `Exceeded timeout of 5000 ms for a test` (`runtime.test.tsx:37`); `foreign-parent…: rc=0`; дальше не пошёл (`if control(repo): return 1`). См. Р-2 |
| `python3 B/env_override_regression.py --repo P --stabs` (прогон 2) | 0 | `control …absent: rc=0`, `control …https://foreign-parent.example.com: rc=0`; `STAB no-override parent=no-url KRASEN (… Expected: "https://api.example.invalid" \| Received: undefined)`; `STAB no-override parent=foreign-url KRASEN (… Received: "https://foreign-parent.example.com")`; `STAB real-host parent=no-url KRASEN (URL_TAMPERED)` ×2 входа; `STAB setdefault parent=foreign-url KRASEN (… Received: "https://foreign-parent.example.com")`; `995 env-regress SVJAZI 5 zhivykh 0`; 15 строк `url-regress STAB {real,test,local,localhost,empty} door={matrix,regression,regression-stabs} rc=1 URL_TAMPERED`; `995 url-regress SVJAZI 15 zhivykh 0` |
| `python3 B/runtime_probe.py --repo P --matrix` | 0 | 6 `runtime/honest/*: rc=0`; `copied-model, any-code, env-code /SHIPPED_INVALID`, `http-demo/HTTP_UNAVAILABLE`, `ignore-mode/UNKNOWN_MODE`, `bypass-ports, wrong-session, wrong-disclosure /RUNTIME_RESPONSES`: `rc=1`; `995 runtime runs=9 mismatches=0`; stderr 0 строк |
| `bash fixtures/…/restart/red_ci_e2e_restart_995.sh --stabs` (дерево OBJECT) | 0 | своей мерой: `grep -c '^CASE '` 63, `grep -c '^CASE .* ok$'` 63; `SVIP itog: N=20, krasnykh 0`; красные свипы `krasnykh 1 (k=1)` ×2, `(k=7)` ×1 (внутри стабов, ожидаемы); `SVJAZI 69`; `zhivykh 0` |
| `python3 B/env_override_regression.py --repo P` (общий прогон, без флага) | 0 | оба `control …: rc=0` |
| `python3 B/runtime_probe.py --repo P` (общий прогон = quality-шаг продукта, `:94`) прогон 1 | 1 | `actual/SHIPPED_INVALID: rc=1` (stderr `Exceeded timeout of 5000 ms`, `runtime.test.tsx:21`), остальные 5 `rc=0`. См. Р-2 |
| `python3 B/runtime_probe.py --repo P` прогон 2 | 0 | 6 `actual/*: rc=0`; stderr 0 строк |
| `python3 B/env_override_regression.py --repo P --mutation unapplied` | 2 | `995 env ORACLE_TAMPERED: якорь unapplied не единственен (вхождений 0)` |
| `bash scripts/check_threat_model.sh . contracts/995-cmp-mob-001-android-pilot.md` | 0 | `секция валидна (ЗАЩИЩАЕТ 4 буллет(ов), НЕ ЗАЩИЩАЕТ 4 буллет(ов))` |

Дополнительно на main продукта (M = `7c7e333b67`):

| команда | rc | ключевой вывод |
|---|---:|---|
| `python3 B/env_override_regression.py --repo M --stabs` | 0 | оба `control: rc=0`; `995 env-regress SVJAZI 5 zhivykh 0`; `995 url-regress SVJAZI 15 zhivykh 0` |
| `python3 B/runtime_probe.py --repo M --matrix` | 0 | тот же поимённый набор, `995 runtime runs=9 mismatches=0` |
| `python3 B/runtime_probe.py --repo M` прогон 1 / прогон 2 | 1 / 0 | прогон 1 — `actual/SHIPPED_INVALID: rc=1` с тем же `Exceeded timeout of 5000 ms`; прогон 2 — 6 `actual/*: rc=0` |

Различий в результатах между 01e081b8 и 7c7e333b нет; таймаут первого холодного Jest — на обоих деревьях одинаково (Р-2).

Сверка с Adv995c: `url-regress SVJAZI 15 zhivykh 0`, `env-regress SVJAZI 5 zhivykh 0`, `runs=9 mismatches=0`,
restart `--stabs` 63 ok / SVJAZI 69 / zhivykh 0 — **совпадает** (счёт — `grep -c` по моим сырым логам,
не сводка автора). Прежний accept `Rev995S` остаётся в силе на этом OBJECT по своей мере.

# 3. Триаж `.review/2026-11-19-120.md` (блок или совет)

Правило: блок — только при доказанном нарушении обязательства контракта на достижимом состоянии.

- **С-1 — совет.** Своя мера: `.scratch-rev995t/mk_c1.py` (копия B, якорь `:115` `count == 1`, присваивание
  → `'https://example.com'`, константа цела). `python3 battery-c1/runtime_probe.py --repo P --matrix` → **rc 0**
  `runs=9 mismatches=0`; `python3 battery-c1/env_override_regression.py --repo P` → **rc 2** `ORACLE_TAMPERED: якорь
  no-override не единственен (вхождений 0)`. Состояние достижимо только правкой батареи; на поставленных байтах
  `:115` присваивает константу, проверенную свидетелем (`:60`, `:145`). Регресс (арбитраж, свойство 4 — правда env)
  не зеленеет; throw-fetch (`runtime.test.tsx:39`) исключает сетевой вызов. Нарушения `:41`/`:94` на достижимом
  состоянии нет.
- **С-2 — совет.** Своя мера: до `--mutation unapplied` в SCRATCH_ROOT копий `env995-*` 0, после — 1
  (`env995-ioiscgbw`; удалена мной). `prepare` `:135` → `replace_once` `:140` бросает до `return`, `main` `:263`
  не убирает. Утечка — копия батареи без секрета и без продукта; rc 2 верен. Обязательство контракта не нарушено.
- **С-3 — совет.** `env_override_regression.py:75` — комментарий «Independent witness…» над `REAL_HOST_URL`
  (`:76`), свидетель живёт в `url_witness.py:4`. Поведения не меняет.

Файл `.review/2026-11-19-120.md` остаётся `status: ready` (на `806d73d624`; на OBJECT его нет), этим судом не изменялся.

# 4. Обязательство безопасности (класс рисковый)

- Адрес API в `.invalid` (`:41`): `url_witness.py:4,7–18` — литерал вне пробы, правило класса; `runtime_probe.py:60,145`
  — сверка до Jest; честный `https://api.example.invalid` зелён (control/matrix выше); 15/15 подмен → rc 1 `URL_TAMPERED`.
- `HTTP_UNAVAILABLE` (`:94`): `runtime/actual/HTTP_UNAVAILABLE: rc=0` (auth-unavailable, без F02.01/protected-start,
  `runtime.test.tsx:37–47`) на обоих родительских входах; `http-demo/HTTP_UNAVAILABLE: rc=1` (мутант пойман).
- `PILOT_DEMO_CODE` (`:4`): `env.pop('PILOT_DEMO_CODE')` `runtime_probe.py:113`, редакция `failureMessages` `:128`.
  Своя мера: `env PILOT_DEMO_CODE=synthetic-verification-value python3 B/runtime_probe.py --repo P --matrix` → rc 0
  `runs=9 mismatches=0`; `env PILOT_DEMO_CODE=… python3 B/env_override_regression.py --repo P --mutation no-override` →
  rc 0 `SVJAZI 2 zhivykh 0`. `grep -c synthetic-verification-value` по всем 22 моим логам (`log-*`, `logm-*`, включая
  красные прогоны с таймаутом) → **0** в каждом. Это известный mock-литерал, не CI-секрет [INFERENCE: совпадение с
  секретом CI не проверяемо].

# Паразитная сложность (050)

Дельта `e06e3a84cd..806d73d624` новых артефактов кода не вводит (три вердикта). Кодовые артефакты к frozen те же,
что судил Rev995S, байт-неизменны (sha256 выше); ответы на пять вопросов повторены своей мерой:

| артефакт | (1) свойство | (2) состояние | (3) связанные правки | (4) глубина | (5) потребитель | вывод |
|---|---|---|---|---|---|---|
| `url_witness.py` | `:41` `.invalid`; К-11 (арбитраж, свойства 1–2) | нет | 2 файла (свидетель + константа) — минимум независимости | 2 функции, без флагов/env | три двери и `run` | ESSENTIAL |
| `env_override_regression.py` | предусловие HTTP_UNAVAILABLE (арбитраж, свойства 3–4) | копии в SCRATCH_ROOT побочным эффектом; на `unapplied` не убираются (С-2) | якоря повторяют строки `runtime_probe.py:26,115` | 3 флага при 3 режимах + 5+15 связок | SDACHA, Adv995c, этот суд | ESSENTIAL (С-2 — совет) |
| `runtime_probe.py` +15 | `:115` — предусловие `:94`; `:60–62`, `:145–147` — свойство 3 | нет | см. выше | CLI не вырос | quality-шаг продукта, матрица | ESSENTIAL |
| `SDACHA_probe_http_unavailable.md` | сдаточный лист | нет | 1 | — | судьи | ESSENTIAL |

Н-39: привязки стабов — в коде architect (`STAB_INPUTS` `:130`, `URL_INPUTS`/`URL_DOORS` `:116–124`), не в прозе контракта.

# ОСТАТОК (192): строки НЕ ЗАЩИЩАЕТ с ловцом reviewer — проверены первыми

- ОСТАТОК: К-995:211 (пропуск cognitive-only сверок) — не укусил: в дельте к frozen 0 путей продукта.
- ОСТАТОК: К-995:212 (ApiClient/AuthProvider, П4) — не укусил: слои продукта дельтой не тронуты.
- ОСТАТОК: К-995:238 (субъект, подогнанный под форму свипа restart) — не укусил: `restart/` байт-неизменен
  (`git diff --exit-code e06e3a84cd 806d73d624 -- fixtures` rc 0; к frozen `restart/` не в списке изменённых); свип `SVIP itog: N=20, krasnykh 0`.
- ОСТАТОК: К-995:250 (содержимое кадров) — не укусил: кадров/Maestro в дельте нет.
- ОСТАТОК: арбитраж «свидетель не sandbox против согласованной подмены проверяющего» — не укусил: `url_witness.py`
  не импортирует пробу, не читает env и вывод продукта; литералы свидетеля и пробы в разных файлах.
- ОСТАТОК: арбитраж «HTTP_UNAVAILABLE с синтетическим URL не доказывает доставку / IdP / поведение 165 без URL» — не
  укусил: заявлений о доставке нет (SDACHA §Развилки), этот вердикт их тоже не делает.

# ПРОВОДКА (038)

guard `restart/red_ci_e2e_restart_995.sh` существует, подключён (`registry/ci-steps.tsv:144`, строка
`check:ci-e2e-restart-995-family-selftest … --stabs`), мой прогон rc 0. Дельта guard и проводку не меняла.

# Блоки

Нет. Доказанного нарушения обязательства контракта на достижимом состоянии не найдено.

# Развилки

- **Р-1 (изоляция ↔ зашитый корень).** Задание требует писать только в копии, батарея принимает продукт только под
  `/tmp/dev-harness-verify` (`runtime_probe.py:64`, `env_override_regression.py:72`; так же у соседних проб батареи).
  Буквальные команды из копии → rc 2 `DISPOSABLE_REQUIRED` (fail-closed, верно по замыслу). Прогоны выполнены на копии
  с одной заменой литерала (diff — 2 строки). Не находка к 995: корень одноразовой зоны — осознанный страж.
- **Р-2 (наблюдение к architect, не блок).** Под нагрузкой хоста (`load average: 23.61` на 16 CPU) первый холодный
  Jest-процесс трижды упал по дефолтному таймауту 5000 ms (`runtime.test.tsx:21` и `:37`): env-регресс `--stabs`
  rc 1 (control absent), `runtime_probe.py --repo P` и `--repo M` rc 1 (SHIPPED_INVALID); повтор каждый раз rc 0.
  Отказ красный (fail-closed), не ложный зелёный; секрета в выводе 0. Обязательство не нарушено; устойчивость CI
  этим не измерялась [INFERENCE].
- **Р-3 (пункт 5 задания, наблюдение к 995).** Чья проба/ожидание: ожидание `auth-unavailable` для режима H — 995
  (`runtime_probe.py` CASES `'HTTP_UNAVAILABLE': 'http'`, `runtime.test.tsx:43`; ЗОНА architect `:119`). Продукт
  (01e081b8 = локальная `wip/165/implementer`; `origin/wip/165/implementer` = `23fadc8`) читает `EXPO_PUBLIC_API_URL`
  (`mobile/src/api/http/config.ts:13`, `mobile/src/bootstrap/http-runtime.ts:37`); `EXPO_PUBLIC_API_BASE_URL` в
  `23fadc8:mobile .github` — 0 совпадений (`git grep`). На OBJECT проба сама присваивает синтетический URL (`:115`) →
  `actual/HTTP_UNAVAILABLE: rc=0` на 01e081b8 и 7c7e333b; без присваивания (стаб no-override, parent=no-url)
  дочерний процесс видит `Received: undefined` и краснеет. CI моба на `23fadc8` берёт H по пину
  `b9b4c66f3d84dc8aa7eb7c8e83b466e807817416` (`.github/workflows/mobile.yml:177`, шаг `runtime_probe.py --repo .` `:243`);
  в `b9b4c66f3d:fixtures/workshop_project/pilot_995/runtime_probe.py` нет ни `EXPO_PUBLIC_API_URL`, ни `SYNTHETIC`
  (grep rc 1). Значит расхождение «проба ждёт auth-unavailable, 165 без URL даёт auth-unconfigured» — от старого пина
  H (до ремонта 995), а не от 165; закрывается перепином quality на H с ремонтом, которого SDACHA не объявляет
  выполненным. [INFERENCE: CI моба не запускался; что 165 без URL показывает именно auth-unconfigured — по
  комментарию `runtime_probe.py:21–25` и SDACHA, не моим прогоном.] Суд на дефекты 165 не расширялся.
- Push, тег `done/…`, записи в `docs/owner/` и `/tmp/dev-harness-verify` не выполнялись; scratch `.scratch-rev995t`
  в коммит не включён.
