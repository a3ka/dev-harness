РЕШЕНИЕ (контракт 117) связь 117→123: (б) — обязательная статическая клетка проводки в батарее 117, замыкающая связь на эффективный канонический манифест и безусловный шаг 123; текст шага остаётся предметом 123
OBJECT=5cf00bffbc5589cec38db6c3cbbf346a21658e6e
Ветка `wip/117/architect`, worktree read-only, `git rev-parse HEAD` = OBJECT (сверено). Предмет спора: вердикт критика `verdicts/critic/contracts-117-v2-krug2-fail.md` (круг 2 по v2, созыв арбитра по повторной причине «зелёный кодовый критерий при отсутствующем splash») против позиции автора (Architect117e): связь 117→123 достаточна через справочный манифест H + ручного ловца (правило В). Арбитраж не судит 123, не пересматривает сужение владельца, не правит RNTL-закрытие круга 1.

## Первоисточники прочитаны

`contracts/117-cmp-mob-vkhod-splash.md` (OBJECT, целиком: инвариант 9, перечни клеток, приёмка, модель угроз, ПРОВОДКА), `fixtures/workshop_project/vkhod_117/vkhod_static_probe.py:1114–1144` (клетки SPLASH_FRAME_SVERKA_123_*), `source.json` `sverka_123`, `probe_lib.py` MODEL_FILES/installed; оба вердикта критика по v2; `contracts/123-mob-sverka-maketa.md` (frozen v1: инварианты, приёмка п.5–6, зоны, ПЕРЕСЕЧЕНИЯ); `fixtures/workshop_project/mob_sverka_123/kadry_117.json`; `verdicts/review/contracts-123-impl-v2.md` (accept Rev123c, OBJECT 2cc58c22); HANDOFF.md п.3 и `forks/n123-krug3-obem.md` (существование); свидетели критика в `/tmp/dev-harness-verify/Critic117v2b/` (`wrong-effective-workflow.yml`, логи); реальная проводка 123 в продукте — клон `/tmp/dev-harness-verify/Impl123fix/mob` (`cmp-mob-123/sverka` @10cf684, `.github/workflows/mobile.yml:367–378`).

## Замеры (одноразовые клоны `/tmp/dev-harness-verify/Arbiter117b/{h,mob}`, свой `.git`; PYTHONDONTWRITEBYTECODE=1; сети нет)

| № | Что | Наблюдение |
|---|---|---|
| 1 | `vkhod_static_probe.py --repo mob --model` на B 8748a7a (`grep -c sverka mobile.yml` = 0: в workflow НЕТ ни шага 123, ни шага Maestro 117) | rc 0, `static 37/37`, обе `SPLASH_FRAME_SVERKA_123_{DARK,LIGHT}` зелены |
| 2 | Реальная реализация 123 (`git show 2cc58c22:scripts/sverka_maketa.py`, 381 строка) И модель `mob_sverka_123/model/sverka_maketa.py`; кадры: dark = r1423 splash, light = r814 First-Run под именем `vkhod-117-splash`; `--repo mob` (sha макетов Splash.png `4a17e3a4…`, Splash-Hell.png `108167d6…` совпали с пином) | канонические строки Splash: rc 1, `Splash dark 0.783 OK`, `Splash light 0.000 NIZHE_POROGA tagline`; тот же манифест с `tema:"dark"` у `Splash light`: rc 0, `Splash dark 0.783 OK`, `Splash light 0.779 OK`. Оба исполнителя дали одинаковые числа — числа критика воспроизведены дословно |
| 3 | Осуществимость клетки проводки (одноразовый YAML-парсер ~40 строк, литералы из 123 п.5/6): честный `mobile.yml` ветки `cmp-mob-123/sverka`; B; `wrong-effective-workflow.yml` критика; 6 мутантов от честного | честный — все 4 проверки зелены; B — все красны; обход критика — красен ровно `MANIFEST_CANON`; мутанты `continue-on-error`, `if:` → `STEP_UNCONDITIONAL`; `--manifest` локальный, `--kadry` иной → `MANIFEST_CANON`; `ref: main` → `HARNESS_PIN`; шаг удалён → все. Живых нет |
| 4 | Прецедент чтения workflow продукта батареей харнесса | `fixtures/workshop_project/pilot_995/pins_probe.py:42–46` `check_release_mode` читает `.github/workflows/mobile.yml` (995, frozen) — клетка (б) не вводит второй конвенции |
| 5 | Утверждения автора | реализация 123 принята ревьюером (`contracts-123-impl-v2.md` accept, OBJECT 2cc58c22) — верно; форк `n123-krug3-obem` ждёт слова владельца (HANDOFF п.3) — верно; проводка шага в `mobile.yml` уже написана implementer 123 на `cmp-mob-123/sverka` @10cf684 (родитель 1423b86 = `cmp-mob-117/vkhod`) — существует, не влита |

## Решение по спорным пунктам

1. **Клетки `SPLASH_FRAME_SVERKA_123_{DARK,LIGHT}` не связывают предмет с потребителем — критик прав (замер 1).** Они читают файл H, который субъект изменить не может, и зелены на workflow без единого упоминания сверки. Единственная субъект-зависимая часть — `shot_index(snimok) ≥ 0` — дублирует `MAESTRO_SPLASH_FRAME_WAIT`. Инвариант 9 («видимость кадра на устройстве судит сверка 123») батареей 117 сейчас не обеспечен ничем; строка приёмки «При проведённом шаге сверки 123…» делает единственный механический ловец геометрического/красочного скрытия (модель угроз 117, НЕ ЗАЩИЩАЕТ п.6) условным. Обход критика (opacity 0.001 у light + локальный манифест с `tema:"dark"`) исполним и даёт rc 0 реальному шагу при light-кадре First-Run (замер 2).

2. **Ручной ловец не заменяет клетку — критик прав.** Ревьюер с vision — вторая линия по правилу (В); проект уже платит механическим гейтом за дешёвые статические свойства (995 читает тот же workflow, замер 4). Клетка стоит ~40 строк на уже требуемом pyyaml и закрывает весь класс «шаг есть, но не судит» (замер 3). Условие (а) отклонено.

3. **117 не реализует и не судит 123 — автор прав в границе.** Текст шага, путь скрипта, аргументы, пин `.harness123` — литералы frozen 123 v1 п.5–6; автор шага — implementer 123 (уже написан). 117 ТОЛЬКО наблюдает: клетка статическая, читает `.github/workflows/mobile.yml` субъекта (путь в ЗОНЕ implementer 117 И 123), ни один файл зоны 123 не правится. Мера 123, её числа, порог, манифест — не предмет 117.

4. **Расширение RNTL (запрет opacity<1/transform) не требуется** — критик это сам признал; устройство судит 123 (замер 2: честный манифест даёт 0.000 на скрытом light).

## Что исполняет architect 117 (ЗОНА `contracts/117-cmp-mob-vkhod-splash.md fixtures/workshop_project/vkhod_117/`)

Добавить в статическую семью `vkhod_static_probe.py` три клетки (имена — рекомендация; привязка стаб↔ветвь определяется кодом MUTANTS, Н-39). Все литералы — в `source.json` (новый блок, например `sverka_123.provodka`), сняты с frozen 123 v1 п.5–6 ДО субъекта (Н-351): `script` = `.harness123/scripts/sverka_maketa.py`, `manifest` = `.harness123/fixtures/workshop_project/mob_sverka_123/kadry_117.json`, `kadry` = `mobile/maestro-out-117`, `repo` = `.`, `checkout_path` = `.harness123`, `checkout_repo` = `a3ka/dev-harness`, `job` = `android-e2e`. Разбор — YAML-парсером (как клетки MAESTRO_*), отсутствие pyyaml — rc 2 INFRASTRUCTURE.

- `SVERKA_123_STEP_UNCONDITIONAL`: в `jobs.android-e2e.steps` РОВНО один шаг, чей `run` содержит литерал `script`; у шага НЕТ ключей `if` и `continue-on-error`.
- `SVERKA_123_MANIFEST_CANON`: в строке `run`, содержащей `script` (до первого `|`, разбор shlex), аргумент `--manifest` == литерал `manifest`, `--kadry` == литерал `kadry`, `--repo` == `.`; каталог `kadry` не отслеживается git субъекта (`git ls-files -- mobile/maestro-out-117` пуст — кадры из прогона, не из дерева).
- `SVERKA_123_HARNESS_PIN`: РОВНО один шаг `uses: actions/checkout@*` с `with.path` == `checkout_path`, `with.repository` == `checkout_repo`, `with.ref` ~ `\A[0-9a-f]{40}\Z` (ТОЧНЫЙ SHA не сравнивается — перепин `.harness123` после форка n123 — дело 123), без `if`, стоит в `steps` РАНЬШЕ шага сверки.

Статические обманные стабы (каждый красен именованной клеткой, побочная краснота только в depends): `sverka-step-absent` (workflow B: шага нет) → все три; `sverka-continue-on-error` → STEP_UNCONDITIONAL; `sverka-if-conditional` → STEP_UNCONDITIONAL; `sverka-local-manifest` (`--manifest mobile/.maestro/compare-117.json` — обход критика дословно) → MANIFEST_CANON; `sverka-kadry-other` (`--kadry` на иной каталог) → MANIFEST_CANON; `sverka-ref-branch` (`ref: main`) → HARNESS_PIN. Перечни контракта: статическая 37 → 40, мутантов 25 → 31 (числа — из прогона, как велит контракт).

Эталон `--model`: `probe_lib.MODEL_FILES` получает `.github/workflows/mobile.yml` → `model/github.workflows.mobile.yml`; содержимое — workflow B с job `android-e2e`, дополненным шагом Maestro 117 (как на `cmp-mob-117/vkhod` 1423b86) и двумя шагами 123 ДОСЛОВНО по `cmp-mob-123/sverka` @10cf684 (`mobile.yml:367–378`). Модель — фикстура architect, не проводка: сами шаги в продукт кладёт implementer (ниже).

Контракт: инвариант 9 дополнить словами «шаг сверки 123 в job android-e2e присутствует безусловно и исполняет канонический манифест пина `.harness123` (клетки SVERKA_123_*)»; в приёмке заменить «При проведённом шаге сверки 123 (зона 123)…» на безусловное «Шаг сверки 123 (текст — frozen 123 п.5, автор — implementer 123) стоит в job android-e2e; клетки SVERKA_123_* зелены; его вывод несёт строки `KADR<TAB>Splash dark/light…OK`; негатив…»; клетки `SPLASH_FRAME_SVERKA_123_{DARK,LIGHT}` ОСТАВИТЬ, но описать честно — «согласованность справочного манифеста H с пинами 117 (sha макетов, id, имя снимка); потребление судят SVERKA_123_*»; в модели угроз «НЕ ЗАЩИЩАЕТ п.6 …проводка — зона 123, до её ленда ловец — ревьюер» переписать: проводка наблюдается клетками, остаток — ниже. ПРОВОДКА: фраза «117 судит лишь, что снимок объявлен и снят» заменяется на «…и что шаг 123 стоит безусловно с каноническим манифестом».

## Что исполняет implementer 117 (ЗОНА включает `.github/workflows/mobile.yml`)

Ничего не сочиняет по 123: PR 117 v2 (`cmp-mob-117/vkhod`) обязан нести коммит проводки 123 implementer'а 123 (`cmp-mob-123/sverka` @10cf684 или его перепин) — rebase/merge/cherry-pick с СОХРАНЕНИЕМ авторства, текст шагов 123 не меняется (`check_zones.sh` различает по `user.name`; ПЕРЕСЕЧЕНИЕ 123: «123 добавляет checkout `.harness123` и шаг сверки, не меняет шаги 117» — зеркально, 117 не меняет шаги 123). Шаг Maestro 117 пишет в `mobile/maestro-out-117` (как на 1423b86). Любая правка текста шага 123 — вторжение в предмет 123, отказ ревьюера 117 по строке ПЕРЕСЕЧЕНИЕ.

## Граница остатка (принято cognitive-only; кандидаты в предмет 123-б)

- Содержимое `kadry_117.json` по SHA пина `.harness123` против копии в H батареи 117: клетка сравнивает форму пина (40-hex), не байты файла на другом SHA; гарантия — иммутабельность frozen-файла 123 и 40-hex; ловец — ревьюер 123 при перепине.
- Связь каталога `--kadry` с `--test-output-dir` шага Maestro 117 (bash внутри `run`): не парсится; защита — fail-closed (пустой каталог → `KADR_OTSUTSTVUET` rc 1) + «каталог не в git»; ловец — ревьюер по логу android-e2e.
- Job-уровень (`if:` на job, required-checks ветки): `gh pr checks --required → rc0` в приёмке 117, настройка — владельца.
- Opacity 0.001 / transform / сосед поверх в рендере: RNTL не судит, судит шаг 123 на устройстве — теперь безусловно.
- Последовательность ленда: 117 done требует присутствия шага 123 в PR 117 — зависимость уже заявлена 123 п.5 («положительная половина судится на первом прогоне PR 117 v2»), новой воли не вводится; если слово владельца по форку n123 задержит ленд 123, 117 ждёт — сообщить владельцу через оркестратора, не решать здесь.

## Вне арбитража

СОВЕТ критика о мёртвом `model/features.auth.auth-screen.tsx` — остаётся советом (не блокер, не предмет созыва). Сужение 117 до splash+иконка — слово владельца, не пересматривается.

## Финальный проход критика — ТОЛЬКО по названному закрытию

(1) три клетки SVERKA_123_* в коде `vkhod_static_probe.py` с литералами source.json; (2) шесть стабов красны именованными ветвями, обход круга 2 (`sverka-local-manifest`) среди них дословно; (3) `--model` 40/40, `--matrix` rc 0, B — красна по ветви SVERKA_123_STEP_UNCONDITIONAL среди прочих; (4) текст контракта: инвариант 9, приёмка, модель угроз, ПРОВОДКА — без условного «при проведённом». Кругов сверх регламента нет.

Счёт решений: пункт 1–2 — критику целиком, пункт 3 — автору (граница зоны), пункт 4 — ничья (обе стороны согласны). Файл вердикта — ЗОНА arbiter `verdicts/arbitration/`; доставка — одноразовая копия `/tmp/dev-harness-verify/Arbiter117b/` и коммит под `user.name=arbiter` в клоне `h` (bundle `verdict.bundle`); в основной чекаут не коммичено (ограничение задания), push не выполнялся.
