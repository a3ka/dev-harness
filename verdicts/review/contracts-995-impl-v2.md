accept
OBJECT=7c74110225d9b63686152e41c088e9fa2f9f2d4c
СУД: repo=dev-harness (+ продукт Complior-mob только для чтения); предмет=995; фаза=реализация frozen/contracts/995/5 — ремонт пробы HTTP_UNAVAILABLE (свидетель URL, регресс env); роль=reviewer; вызов=scoped-исправительный по дельте после `67f7343950`, штатный остаток 1/2 (полный №1 — Rev124a, `verdicts/review/contracts-995-141-impl-124.md`, accept на `67f7343950ece44e2fd53d22c11bb35cf403e07f`); основание=слово владельца 2026-11-19 ~10:07 UTC «…после accept — ревьюер в штатном бюджете»; класс риска=рисковый («безопасность», `contracts/995-cmp-mob-001-android-pilot.md:4`), порядок соблюдён: Adv995c accept (`7c74110225`, OBJECT `e06e3a84cd`) → reviewer; сессия=Rev995S; модель-план=config/agent_models.json reviewer → anthropic/claude-opus-5-5; модель-факт=anthropic/claude-opus-5-5 allowed (`bash scripts/models_actual.sh --tsv --bind --session Rev995S | cut -f1-3` из `/home/harness/dev-harness`, rc 0, две одинаковые строки `reviewer	anthropic/claude-opus-5-5	allowed`); автор дельты=architect (`openai-codex/gpt-6.1-sol` по арбитражу Arb995V1), другое семейство.
СВЕРКА-АРХИТЕКТУРЫ: дифф `662d6a74..7c741102`: четыре файла батареи в `fixtures/workshop_project/pilot_995/` (A `url_witness.py`, A `env_override_regression.py`, A `SDACHA_probe_http_unavailable.md`, M `runtime_probe.py` +15) и два вердикта (adversary, arbitration). Размещение — внутри существующей батареи. Зависимости — только stdlib (`urllib.parse`), новый импорт `url_witness` из соседнего файла. Писателей и операций продукта нет. `bindings.json`/`architecture.lock.json` не тронуты. Долг не расширен. Уровень diff модели — L0 (продуктовой архитектурной модели не касается).
СВЕРКА-СТАНДАРТОВ: AGENTS.md станции не объявляет документ архитектуры и стандарт кода; продукт в дельте не меняется — неприменимо.
НАХОДКИ: `.review/2026-11-19-120.md` (status: ready) — блоков 0, советов 3 (С-1 матрица сверяет константу, а не значение env; С-2 утечка scratch на `--mutation unapplied`; С-3 устаревший комментарий), развилка оркестратору 1 (Р-1 OBJECT adversary ≠ OBJECT этого вердикта, дверь `scripts/done_contract.sh:674`).

# Предмет и метод

Первым действием целиком прочитаны задание `/tmp/dev-harness-verify/task-rev995s.md`, затем
вердикт `Adv995c` (`verdicts/adversary/contracts-995-impl-v1.md`), арбитраж
`verdicts/arbitration/995-proishozhdenie-oracle-url.md`, файлы дельты целиком и нужные места
контракта (`:4`, `:41`, `:94`, `:117–135`, `:208–212`, `:248–251`).

- Клон: `git clone ssh://git@github.com/a3ka/dev-harness.git /tmp/dev-harness-verify/Rev995S/repo`,
  `git fetch --tags origin`, `git checkout wip/995/architect`; `git rev-parse HEAD` →
  `7c74110225d9b63686152e41c088e9fa2f9f2d4c` = OBJECT; `git status -s` пуст.
- Прогоны — в одноразовой копии `cp -a repo run` (тот же HEAD). Продукт — `git -C
  /home/harness/projects/Complior-mob archive 01e081b8dcc95c4f9cba353b656c70301fc4792c` в
  `/tmp/dev-harness-verify/Rev995S/product`, `npm ci --prefix …/product/mobile` rc 0 (1115 пакетов).
  Это то же дерево, что у Adv995c. Основной чекаут продукта не трогался.
- Предыдущий OBJECT `67f7343950` — коммит продукта (PR #124), не харнесса. Поэтому дельта
  харнесса после того суда — коммиты ветки поверх `662d6a74` (база main): `b182b339`,
  `6b22cb4f` (merge `-s ours`; `git diff b182b339 6b22cb4f` пуст, дерево не изменилось),
  `63f3b4c6`, `d532f364`, `10cc58c3`, `e6555cac`, `e06e3a84`, `7c741102`.

# 1. Область правки

- `git diff --name-status 662d6a74 HEAD` → 6 путей: 4 в `fixtures/workshop_project/pilot_995/`
  (ЗОНА architect, `:119`), `verdicts/adversary/contracts-995-impl-v1.md` (ЗОНА adversary, `:121`),
  `verdicts/arbitration/995-proishozhdenie-oracle-url.md` (роль арбитра). Других путей нет.
- Авторы по своей мере (`git log --format='%an <%ae> | %cn <%ce>' 662d6a74..HEAD --no-merges`):
  файлы батареи — только `architect`, вердикты — `adversary`/`arbiter`; author=committer везде.
- Контракт и замороженные байты: `git diff --name-status frozen/contracts/995/5 HEAD --
  fixtures/workshop_project/pilot_995/ contracts/995-cmp-mob-001-android-pilot.md` → только те же
  4 файла батареи. Контракт и `runtime.test.tsx` не изменились. `restart/` не изменился.
  `git diff frozen/contracts/995/5 HEAD -- runtime_probe.py`: CASES и MUTANTS байт-неизменны.
  Добавлены импорт свидетеля, `SYNTHETIC_API_URL`, предзапускные проверки `:60–62`, `:145–147`
  и присваивание `:115`.
- Продукт: в дельте харнесса нет ни одного пути продукта. Пины H в продукте этой дельтой не
  менялись (SDACHA говорит то же самое).
- Подгонки под тестовые имена нет: новые проверки сравнивают значение со свидетелем и не
  ветвятся по имени клетки или мутанта.
- `bash scripts/check_zones.sh .` (копия клона) не дошёл до итога за 600 с (таймаут инструмента,
  весь репозиторий). Машинного вывода зон НЕТ. Зоны сверены вручную по `ЗОНА`-строкам
  замороженного текста `:119–122` (выше): вне зон 0 путей.

# 2. Сырой вывод (мои прогоны, `/tmp/dev-harness-verify/Rev995S/run`)

sha256 четырёх файлов до прогонов = SDACHA/Adv995c: runtime.test `c9aa30fa…94f6`, runtime_probe
`268e4513…e5a5`, env_override_regression `49156ade…78b4`, url_witness `a2842f16…2c79`.

| команда | rc | ключевой вывод (дословно) |
|---|---:|---|
| `reslop t -- python3 fixtures/workshop_project/pilot_995/env_override_regression.py --repo …/Rev995S/product --stabs` | 0 | `control parent=…:absent: rc=0`, `control parent=…:https://foreign-parent.example.com: rc=0`; `995 env-regress SVJAZI 5 zhivykh 0`; `995 url-regress SVJAZI 15 zhivykh 0` |
| `reslop t -- python3 fixtures/workshop_project/pilot_995/runtime_probe.py --repo …/Rev995S/product --matrix` | 0 | 6 honest rc=0, 8 мутантов rc=1 поимённо; `995 runtime runs=9 mismatches=0` |
| `reslop t -- bash fixtures/workshop_project/pilot_995/restart/red_ci_e2e_restart_995.sh --stabs` (guard ПРОВОДКИ `:280`) | 0 | своей мерой по сырому логу: `^CASE ` 63, `^CASE .* ok$` 63; `SVIP itog: N=20, krasnykh 0` (контроль); `SVJAZI 69`; `zhivykh 0`. Красные свипы `krasnykh 1 (k=1)`×2 и `(k=7)`×1 — внутри стабов, ожидаемы |
| `python3 …/env_override_regression.py --repo …/product --mutation unapplied` | 2 | `995 env ORACLE_TAMPERED: якорь unapplied не единственен (вхождений 0)` |
| `bash scripts/check_threat_model.sh . contracts/995-cmp-mob-001-android-pilot.md` | 0 | `секция валидна (ЗАЩИЩАЕТ 4 …, НЕ ЗАЩИЩАЕТ 4 …)` |

Посвязно (stdout `--stabs`): no-override × {no-url: `Received: undefined`; foreign-url:
`Received: "https://foreign-parent.example.com"`}, real-host × {no-url, foreign-url}:
`KRASEN (URL_TAMPERED)`, setdefault × foreign-url: `Received: "https://foreign-parent…"`.
URL — 5 входов (real, test, local, localhost, empty) × 3 двери (matrix, regression,
regression-stabs): каждая строка `rc=1 URL_TAMPERED`.

Сверка с Adv995c: `url-regress SVJAZI 15 zhivykh 0`, `env-regress SVJAZI 5 zhivykh 0`,
`runs=9 mismatches=0`, restart `--stabs` 63 ok / SVJAZI 69 / zhivykh 0 — **совпадает**.
Счёт я брал своей мерой (`grep -c` по сырому логу), а не из сводки автора.

# 3. Неподгонка: красное и зелёное своей мерой (вне авторских входов)

Скрипт `/tmp/dev-harness-verify/Rev995S/own_measure.sh` работает только в одноразовых копиях
файлов батареи; подмена — ровно одного якоря с проверкой `count == 1`.

- Пять URL, которых нет в `URL_INPUTS`, × три двери (`--matrix`, регресс без флага,
  `--case HTTP_UNAVAILABLE`): `https://evil.invalid` (допустимый класс, но не свидетель),
  `https://api.example.invalid/`, `https://u:p@api.example.invalid`,
  `https://api.example.invalid.example.com`, `HTTPS://api.example.invalid`. Результат —
  **15/15 rc=1** `995 runtime URL_TAMPERED` / `995 env URL_TAMPERED`; продукт не запускался.
- Честная копия: `--case HTTP_UNAVAILABLE` rc 0; регресс без флага rc 0, оба родительских входа
  rc=0.
- Подмена присваивания при целой константе (`:115` → `'https://example.com'`): `--matrix` **rc 0**,
  регресс rc 2 ORACLE_TAMPERED. Регресс не зеленеет, а арбитраж (свойство 4) отдаёт правду env
  регрессу. Поэтому это совет С-1, не блок.
- Привязки стабов — в коде architect (`STAB_INPUTS` `:130`, `URL_INPUTS`/`URL_DOORS` `:116–124`),
  не в прозе контракта (Н-39). Ветви различающие: real-host краснеет предзапускным свидетелем,
  no-override/setdefault — наблюдением `process.env` внутри Jest (`Expected/Received` выше).
  setdefault осознанно привязан только к foreign-url: на no-url мутант честно зелёный.
- Происхождение свидетеля: `url_witness.py` не импортирует пробу, не читает env и вывод
  продукта. Сам свидетель проверяется на класс `.invalid` (`synthetic_origin`, rc 2
  `WITNESS_NOT_SYNTHETIC`). Взаимную подмену свидетеля и правила класса Adv995c показал как
  предел; это НЕ ЗАЩИЩАЕТ `:209` («злонамеренный код с общим uid»).

Лист `SDACHA_probe_http_unavailable.md` соответствует факту: таблица rc (регресс 0/0, матрица 0
`runs=9`, unapplied 2, restart 0 SVJAZI 69), матрица 5×3 rc 1, sha256 и «runtime.test/restart/
контракт не менялись» — всё сверено выше своей мерой. Расхождений нет. Фраза «Копии удаляются
после проверки» верна для `url_stabs`/`drive`, но не для пути `--mutation unapplied` (С-2).

# 4. Безопасность (класс рисковый): секрет PILOT_DEMO_CODE

Дельта не трогает пути секрета: `env.pop('PILOT_DEMO_CODE')` и редакция `failureMessages` в
`run` — прежние. Своя мера на путях дельты: `env PILOT_DEMO_CODE=synthetic-verification-value
reslop t -- python3 …/env_override_regression.py --repo …/product --mutation no-override` →
rc 0 (`SVJAZI 2 zhivykh 0`); то же для `runtime_probe.py --matrix` → rc 0 (`runs=9
mismatches=0`). `grep -c synthetic-verification-value` по сырым логам всех пяти моих прогонов
(python3-01…04, bash-01) → **0** во всех. Совпадает ли секрет CI с этим литералом, не известно
(как и у Rev124a); это проверка известного mock-литерала, а не CI-секрета.

# 5. Атомарность и норма

Каждый ремонт — отдельный коммит со ссылкой на предмет и блок: `b182b339` (предусловие
HTTP_UNAVAILABLE), `d532f364` (Adv995), `e6555cac` (Adv995b). Нормативные документы и контракт
не правились. Merge `6b22cb4f` нетто-пустой по дереву; он приносит в историю ветки прежние
коммиты architect `33d84c5f…40a93f1d` (все `architect`) без изменения дерева.

# Паразитная сложность (050) — по артефактам дельты

| артефакт | (1) свойство | (2) состояние | (3) связанные правки | (4) глубина | (5) потребитель | вывод |
|---|---|---|---|---|---|---|
| `url_witness.py` (18 стр.) | 995:41 `.invalid`; К-11 «оракул не из субъекта» (арбитраж, свойства 1–2) | нет; литерал в исходнике | 2 файла (свидетель + константа пробы) — минимум для независимости | 2 функции, без флагов и env | три двери и `run` | ESSENTIAL |
| `env_override_regression.py` (279 стр.; флаги `--repo`, `--stabs`, `--mutation`) | предусловие HTTP_UNAVAILABLE: env внутри процесса при absent/foreign (арбитраж, свойство 4) и URL-двери (свойство 3) | одноразовые копии в `SCRATCH_ROOT`, видны лишь как побочный эффект; путь unapplied их не убирает (С-2) | якоря мутаций повторяют строки `runtime_probe.py:26,115` — правка присваивания обязана менять оба файла (рост: было 1) | глубокий: 3 флага при 3 режимах и матрице 5+15 связок | приёмка SDACHA, Adv995c, арбитраж; в `registry/ci-steps.tsv` шага нет | ESSENTIAL (более простая форма свойства 4 без наблюдения env внутри Jest не проходит строки арбитража). Шов якорей — совет С-1 |
| `runtime_probe.py` +15 | `:115` — предусловие сетевой клетки `:94`; `:60–62`, `:145–147` — свойство 3 | нет | см. выше | интерфейс CLI не вырос | quality-шаг продукта (после перепина H), матрица | ESSENTIAL |
| `SDACHA_probe_http_unavailable.md` | сдаточный лист (правило сдачи) | нет | 1 | — | судьи | ESSENTIAL |

# ОСТАТОК (192): строки НЕ ЗАЩИЩАЕТ с ловцом reviewer, проверены первыми

- ОСТАТОК: 995:211 (пропуск cognitive-only сверок) — не укусил. Дельта не касается
  root/bootstrap/auth/api/mocks/PNG продукта: 0 путей продукта в `git diff --name-status`.
- ОСТАТОК: 995:212 (ApiClient/AuthProvider, чек-лист П4) — не укусил. Слои продукта дельтой не
  тронуты; П4 судил полный вызов Rev124a.
- ОСТАТОК: 995:250 (содержимое кадров) — не укусил. Кадров и Maestro в дельте нет; `restart/`
  байт-неизменен.
- ОСТАТОК: арбитраж «свидетель не sandbox против согласованной подмены проверяющего и его правила
  класса; ловец — reviewer по происхождению и diff проверяющего» — не укусил. `url_witness.py`
  создан одним коммитом architect `e6555cac`. Импортов пробы, env и вывода продукта в нём нет.
  Литерал свидетеля и литерал пробы живут в разных файлах, а подмена одного из них краснеет
  (§3).
- ОСТАТОК: арбитраж «HTTP_UNAVAILABLE с синтетическим URL и throw-fetch не доказывает доставку /
  внешний IdP / поведение 165 без URL; ловец недостоверного заявления — reviewer» — не укусил.
  В SDACHA §Развилки сказано прямо: «поведение 165 “без URL → auth-unconfigured” не
  доказывается… CI/Android и перепин quality не исполнялись и не объявляются проверенными».
  Заявления о доставке нет.

# ПРОВОДКА (038)

guard `fixtures/workshop_project/pilot_995/restart/red_ci_e2e_restart_995.sh` существует и
подключён: `registry/ci-steps.tsv:144` `check:ci-e2e-restart-995-family-selftest … --stabs`. Мой
прогон rc 0 (§2). Дельта guard и строку проводки не меняла. Новые
`env_override_regression.py`/`url_witness.py` строкой CI не проведены. Контракт этого не требует
(они вне ПРОВОДКА `:278–282`), поэтому это факт, а не находка.

# Блоки

Нет. Доказанного нарушения на достижимом состоянии не найдено: подмена URL краснеет во всех трёх
обещанных дверях (свои 15/15 и авторские 15/15), честный мир зелёный, секрет не утекает,
контракт/runtime.test/restart не тронуты, область правки — в зонах.

# Развилки

- Р-1 (оркестратор): OBJECT accept Adv995c — `e06e3a84cd…`, а этого вердикта — `7c74110225…`
  (дельта между ними — только файл вердикта adversary). Дверь `scripts/done_contract.sh:674`
  требует тот же объект; подробности — `.review/2026-11-19-120.md` Р-1. Вердикт написан по
  заданию.
- Остаток `env995-vcj9csh9` в `/tmp/dev-harness-verify` (mtime 10:16:57 UTC, до моей сессии) я
  не удалял: он не мой. Свою копию от проверки С-2 удалил.
- Push, тег `done/…`, записи в `docs/owner/` не выполнялись.
