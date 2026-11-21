accept
OBJECT=49943e0f836890f2ecfe84aebf463695edd309e8

# Review 197 — реализация v3 (порт канона 197/3 в a3ka/Complior-mob#213), один полный вызов reviewer

СУД: repo=dev-harness (станционный предмет с внешним runtime продукта, не проектный режим mob); предмет=197; фаза=реализация; роль=reviewer; вызов=1 полный (класс риска обычный → adversary не вызывается); назначения frozen: risk pin реестра — `frozen/contracts/197/2` (`registry/contracts.tsv:193` → `234e912f5556…`, receipt `registry/dostavki/197.json` `frozenTag frozen/contracts/197/2`), текст судимого обязательства — `frozen/contracts/197/3` (тег `858c8c5dc5…` → commit `9380a79dcb…`, блоб контракта `8236d78538…`); оба несут `КЛАСС РИСКА: обычный` (проверено `git show …^{commit}:contracts/197-mob-ci-artefakty-lokalno.md | grep '^КЛАСС РИСКА'`), повышать не за что; модель-план=config/agent_models.json reviewer; сессия=Rev197V4 (задание называет Rev197V3 — `models_actual.sh --session Rev197V3` → `NOT_IMPLEMENTED: сессия не найдена: Rev197V3` rc 2; фактический исполнитель — Rev197V4); модель-факт=anthropic/claude-opus-5-5 (`cd /home/harness/dev-harness && bash scripts/models_actual.sh --tsv --bind --session Rev197V4 | cut -f1-5` → `reviewer	anthropic/claude-opus-5-5	allowed	Rev197V4	49943e0f836890f2ecfe84aebf463695edd309e8`, rc 0; дверь `bash scripts/check_sud_model.sh --verdict reviewer --trace /tmp/dev-harness-verify/rev197v4/trace.tsv --object 49943e0f83… --session Rev197V4 --root .` → «СУДЬЯ СВОЕЙ МОДЕЛИ: вердикт reviewer материализуется», rc 0; trace-файл — первая строка вывода models_actual).

Находки (советы и условия слияния, блоков нет): `.review/2026-11-21-124.md`.

## Деревья

- Станционная копия (вердикт, контракт, батарея): `/home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/ta3ea760d6/m`. HEAD `790cf3d252` = `git fetch ssh://git@github.com/a3ka/dev-harness.git refs/heads/main` → FETCH_HEAD `790cf3d252339ef51ddc71b97e8ddbdfff07d744`. Это main с доставкой a30de35d08.
  - Локальные теги `frozen/contracts/197/{1,2,3}` лёгкие. Они указывают на те же коммиты, что и аннотированные теги origin: `git ls-remote … 'refs/tags/frozen/contracts/197/*'` → `^{}` 7ab3f135 / 34474374 / 9380a79d. Это совпадает с `git rev-parse frozen/contracts/197/N`.
  - Батарея и контракт не менялись после /3: `git diff --stat 'frozen/contracts/197/3^{commit}' FETCH_HEAD -- fixtures/workshop_project/mob_ci_artifacts_local_197/ contracts/197-mob-ci-artefakty-lokalno.md` пуст.
- Продуктовый runtime (только чтение): `/home/harness/.local/state/dev-harness-sessions/c907157c/runtime/197/wip_197_implementer-v3`. `git rev-parse HEAD` = OBJECT. `git status --short | wc -l` = 0 до и после всех прогонов.
- Одноразовые снимки — `git archive` из runtime в `/tmp/dev-harness-verify/rev197v4/`: `base/` = main моба `e40d248bb6` (= base в compare), `pr193/` = голова #193 `70ad24e5b9`.

## 1. Область правки

```
git log --format='%H %P | a=%an <%ae> c=%cn <%ce>' -1 49943e0f83
  49943e0f83… e89994cf7a… | a=implementer <implementer@dev-harness.local> c=implementer <implementer@dev-harness.local>
  тема: «197/3: порт канона ci-artefakty.cjs (frozen/contracts/197/3, sha256 6e05c38c…): шаблонный сбор <имя>-<run_id>-<run_attempt>»
git diff --name-status 49943e0f83~1 49943e0f83      M .github/workflows/mobile.yml ; M mobile/scripts/ci-artefakty.cjs   (ровно 2 пути)
git diff --stat 70ad24e5b9 49943e0f83 -- <3 пути зоны>  = тот же дифф (merge e89994cf7a зону не трогает)
git ls-tree 49943e0f83:
  100644 44f4b227543c19228580624f3fec9cb61c431f33 .github/workflows/mobile.yml      == model/.github/workflows/mobile.yml в 197/3
  100755 9a605ce9b4b70b74ad449c49014a7e99f190ef3c mobile/scripts/ci-artefakty.cjs   == model/mobile/scripts/ci-artefakty.cjs в 197/3
  100644 19a4b43583… package.json (не тронут; lanes на строках 9–10 = значения model/package.json 8a551edb36)
sha256sum mobile/scripts/ci-artefakty.cjs  6e05c38cad900b3185dff4716b827ca04ca6d3ec718fb3e14d5c5bdf5f6f69b3 (= source.json:14 в /3)
stat -c %a                                 775 (git-режим 100755)
node --check mobile/scripts/ci-artefakty.cjs   rc 0
```

- Оба пути лежат в `ЗОНА implementer: .github/workflows/mobile.yml package.json mobile/scripts/ci-artefakty.cjs` (/3, совпадает с /2).
- Коммит один, предмет назван в теме. Атомарность соблюдена.
- Комментарии `mobile.yml` исполнения не меняют. Своя мера: из `git diff 70ad24e5b9 49943e0f83 -- .github/workflows/mobile.yml` выбраны изменённые строки, и после отсева строк вида `^[+-]\s*(#.*)?$` не осталось ни одной (grep rc 1).
  - Удалено 5 строк `# 143 (живая приёмка cutover…)` перед `permissions:`.
  - Переписаны комментарии на строках 1450, 1518–1521, 1533–1536 и 1574–1576 (нумерация OBJECT). Это YAML-комментарии или shell-комментарии внутри `run: |`; ключей, шагов и команд среди них нет.
  - Развилка R1 implementer — не нарушение: файл байт-в-байт равен модели канона /3.
  - ПЕРЕСЕЧЕНИЯ 141/148/151 (скриптовые вызовы, управляющие ключи, шаги e2e-vkladki) не задеты: исполняемых строк в диффе нет.
- Проверки не подогнаны под код. Коммит не трогает ни `.harness/`, ни батарею (она живёт в станции). Каталог батареи между заморозкой /3 и main станции не менялся (см. «Деревья»).

## 2. Сырой вывод

```
bash fixtures/workshop_project/mob_ci_artifacts_local_197/red_mob_ci_artifacts_local_197.sh --repo <runtime OBJECT>
  29 строк «CASE … ok» (a01 a02 a03 b01 b02 b03 c01 c02 c03 d01 d02 e01 e02 g01 g02 i01 i02 r01…r11 s01 — пересчитаны поимённо)
  клеток 29, зелёных 29, красных 0                                                       rc 0
… --repo /tmp/dev-harness-verify/rev197v4/pr193   (голова #193 70ad24e5b9, до порта — КРАСНОЕ-ДО)
  CASE e01-skript-pin KRASNO: SKRIPT_PIN_RASHOZHDENIE: f09d7289…5571 != 6e05c38c…69b3
  CASE r07-shablon-sbor KRASNO: SHABLON_NE_SOBRAL: screen-evidence-vhod
  CASE s01-styk-sbor-agregat KRASNO: STYK_AGREGATA_OTKAZ: AGREGAT_OTKAZ: CHILD_EVIDENCE_OTKAZ — PEREPIS_DETEJ
  клеток 29, зелёных 26, красных 3                                                       rc 1   (= «Сценарий v3» §Приёмка п.6: ровно три)
… --model                                       клеток 29, зелёных 29, красных 0         rc 0
… --stabs   честный контроль 29/29; 38 стабов KRASEN своими причинами; «стабов 38, непойманных 0»   rc 0

bash scripts/verify_ci_parity.sh <дерево>   (станционный скрипт)
  OBJECT (runtime)   «workflow-команд: 160 · скриптов в приёмке: 6 · объявленных исключений: 92 · … · расхождений: 29»   rc 1
  main e40d248       «workflow-команд: 147 · скриптов в приёмке: 4 · … · расхождений: 29»                                rc 1
  #193 70ad24e5b9    «workflow-команд: 160 · скриптов в приёмке: 6 · … · расхождений: 29»                                rc 1
  нормализованные множества FAIL (путь до .github/ и номера строк сняты, sort): OBJECT vs main — diff rc 0; OBJECT vs #193 — diff rc 0
bash scripts/ci_preflight.sh --repo <дерево> --workflow .github/workflows/mobile.yml
  OBJECT / main / #193: «preflight ОТКАЗ: vyrazhenie-ne-podderzhano: ${{ github.event_name }}»  rc 1 ×3, выводы попарно идентичны (diff rc 0)

gh pr checks 213 --repo a3ka/Complior-mob                                                rc 0
  android-e2e pass · e2e-erstinformation pass · e2e-first-run pass · e2e-pilot pass · e2e-splash pass · e2e-start pass
  build-apk pass · quality pass · select-screens pass · mobile-regression-signal skipping · e2e-screen skipping   (9 pass, 2 skipping)
gh run view 44506480581 --json headSha,conclusion,event   headSha 49943e0f83…, conclusion success, event pull_request
gh pr view 213 --json …   headRefOid 49943e0f83…, mergeStateStatus BEHIND, state OPEN, commits 5
gh api repos/a3ka/Complior-mob/compare/main...49943e0f83…   status diverged, ahead_by 5, behind_by 11, merge_base 53d1f3a588, base e40d248bb6   rc 0
```

Живой транспорт в логах run 44506480581, прочитанных через `gh api …/actions/jobs/<id>/logs`:
- build-apk: `ZAPIS 44506480581-1/apk-44506480581-f325b6935da4`.
- e2e-pilot: `CHTENIE 44506480581-1/apk-… --run-id 44506480581 --run-attempt 1`, затем `ZAPIS 44506480581-1/maestro`.
- android-e2e: `CHTENIE_PUSTO: screen-evidence-*` → `CHILD_EVIDENCE_OK`.
- Строк `Failed to CreateArtifact` нет: `gh run view --log` пуст, поэтому этот счёт не засчитан. В трёх прочитанных job-логах таких строк тоже нет.

Паритет: OBJECT не добавляет ни одного расхождения ни против main, ни против #193. Вклад 197 в 29 FAIL нулевой: lanes — целевая форма, исключения не нужны (§Приёмка п.9). Предполёт красный одинаково на всех трёх деревьях — это предсуществующий долг, роста нет. Мой замер причины отличается от записанного в задании (`working-directory-otsutstvuet`) — совет С-2.

## 3. Соответствие предмету /3 (не только батарее)

- **И-1.** В `mobile.yml` нет `upload-artifact`, `download-artifact`, `gh run download` и `gh api …/artifacts` в исполняемых строках. Единственное совпадение — комментарий на строке 1326. Совпадения в `.github/` есть только в `mobile-cloud-e2e.yml:95,103` (upload-artifact); он вне предмета («НЕ ЗАЩИЩАЕТ», не тронут диффом).
- **И-2/И-3.** Корень `/var/lib/ci-artifacts/Complior-mob` встречается только в `mobile/scripts/ci-artefakty.cjs:5,35`. В workflow корня нет, `CI_ARTEFAKTY_KOREN` нигде не задаётся (grep по дереву). Писатели `--run-id` не передают.
- **И-4.** У всех 6 APK-читателей (548/737/932/1186/1343/1474) есть пара `--run-id "$RUN_SBORKI" --run-attempt "$POPYTKA_SBORKI"`; ловит c03.
- **И-7, суть v3.** Новые строки скрипта:
  - `const para = \`-${k.id}-${k.popytka}\``, где `k = kontekst_runa(p, false)` (строки 155/199). Пара берётся из собственных env, а если переданы `--run-id/--run-attempt` — из продюсерской пары.
  - Копия кладётся в `kuda/imja+para`. Ровно это имя агрегат 143 ждёт: `screen-evidence-${id}-${build.run_id}-${attempt}` (`ci-aggregate.cjs:82,89`, файл не тронут).
  - Оба шаблонных читателя (1525/1566) пару не передают. Значит, пара — свой run/attempt, и с агрегатом соседнего шага она совпадает.
- **Повтор попытки, не регресс** [INFERENCE по коду, не измерено живьём]. При re-run failed jobs ребёнок, не перезапущенный во 2-й попытке, лежит в `<run>-1/`, и шаблонный читатель попытки 2 его не соберёт. Но и до 197 `pattern: screen-evidence-*-<run>-<attempt>` его не матчил, а агрегат ждёт `-<attempt текущий>`. Семантика сохранена — та, которую требует И-7 («раскладка merge-multiple: false до 197»).
- **package.json.** `ci:artefakt-zapis` = `node mobile/scripts/ci-artefakty.cjs zapis`, `ci:artefakt-chtenie` = `… chtenie` — значения канона (e02). Других ссылок на канон в дереве нет (grep `ci-artefakty|ci:artefakt|ci-artifacts`, кроме `.harness/fixtures/gespraech-host-seams/` — строк зон 197/2, не исполнения).

## Остатки (контракт 192; «НЕ ЗАЩИЩАЕТ» с ловцом reviewer, по порядку пунктов списка /3)

ОСТАТОК: К-08 (произвольный shell вне обнаруженных носителей: косвенный вызов lane через переменную, eval, функцию, составное имя) — не укусил.
- `grep -nE 'ci:artefakt-|ci-artefakty|\beval\b|npm run "?\$' .github/workflows/mobile.yml` даёт ровно 17 прямых литеральных носителей: строки 105, 511, 548, 699, 737, 891, 932, 1143, 1186, 1301, 1343, 1435, 1474, 1498, 1525, 1566, 1583. Ни `eval`, ни `npm run "$…"` нет.
- Других вызывающих скрипт файлов в дереве нет.
- Дифф OBJECT исполняемых строк в `mobile.yml` не меняет (§1).

ОСТАТОК: К-09 (поштучная сохранность каждого maestro-писателя) — не укусил. Исходный инвентарь — `git show fda1fc8:.github/workflows/mobile.yml`: 9 upload + 3 download + 5 gh run download = 17 операций. Поштучное соответствие:
- **upload → zapis**, совпадают имя-основа и источник:
  - selection.json → 105;
  - APK → 511;
  - maestro-out-117 → 699;
  - maestro-out-first-run → 891;
  - maestro-out-erstinformation → 1143;
  - maestro-out-start → 1301;
  - maestro-out → 1435;
  - screen-evidence/<id>/ → 1498;
  - needs.json (regression-marker) → 1583.
- **gh run download APK → chtenie --imja** с парой: 556→548, 753→737, 956→932, 1218→1186, 1378→1343.
- **download-artifact APK (e2e-screen) → 1474**; download child evidence ×2 → 1525, 1566.
- Пропусков нет, все 5 maestro-писателей на месте. Живой CI исполнил писателя `maestro` в e2e-pilot: `ZAPIS 44506480581-1/maestro`.

Пункты К-01…К-07 и К-10 ловят живой CI, 196, 143/141/148 и паритет — это не reviewer. Из них К-07 (канал вне mobile.yml): паритет на OBJECT нового не сообщает, `mobile-cloud-e2e.yml` не тронут.

## Паразитная сложность (050)

Единственный новый артефакт — ветвь `para` в `chtenie --shablon` (`ci-artefakty.cjs:192–203`, плюс 4 строки шапки):
1. Свойство — И-7 v3: шаблонный сбор кладёт ребёнка каталогом `<имя>-<run_id>-<run_attempt>`.
2. Состояние явное: пара видна в аргументах и env, имя каждого ребёнка — в выводе `CHTENIE_PO_SHABLONU`.
3. Файлов, меняющихся вместе, по-прежнему один: грамматика живёт только в каноне.
4. Интерфейс не вырос: ни флагов, ни env, ни кодов возврата не добавилось.
5. Потребители — клетки r07/s01 и агрегат 143. Более простая форма — сбор без пары, то есть голова #193 — измерена красной на r07/s01.

Вывод: ESSENTIAL. Правка `mobile.yml` новых артефактов не вводит, только комментарии.

## ПРОВОДКА (038)

- Guard `fixtures/workshop_project/mob_ci_artifacts_local_197/red_mob_ci_artifacts_local_197.sh` существует и подключён: `registry/ci-steps.tsv:315` `check:mob-ci-artifacts-local-197-family-selftest … --stabs`.
- Это барьер именно предмета 197: e01 пинует байты канона, a01–a03 закрывают канал. На OBJECT он зелёный, на голове до порта — красный тремя клетками.
- `--repo <дерево продукта>` в CI станции не подключается: продукта в дереве станции нет. Это ПРОВОДКА-ЭНФОРСМЕНТ контракта, решение оркестратора, не реализации.

СВЕРКА-СТАНДАРТОВ:
- `AGENTS.md` продукта документ архитектуры и стандарт кода не объявляет (grep `CODING|ARCHITECT` по нему пуст; `docs/ARCHITECTURE.md` отсутствует).
- `docs/CODING-STANDARDS.md` §1 — «Правила для кода в `mobile/`… соглашения кода `mobile/src`; стандарт не дублирует… CI-job'ы». CI-скрипт и workflow под §2–§13 не попадают — соответствует.
- §14 «Ветки, коммиты, PR» — соответствует: ветка `wip/NNN/<слог>`, тема `197/3: …` в форме `NNN: …`, один PR в main, merge — владелец.

СВЕРКА-АРХИТЕКТУРЫ: не применимо — модели архитектуры 188 в продукте нет (`tooling/checks/cli.js`, `bindings.json` отсутствуют).
- Размещение: канон в `mobile/scripts/`, рядом с `ci-aggregate.cjs`, файл уже существовал.
- Новых зависимостей нет: только `path`/`fs` Node, как раньше.
- Писатели и операции: прежние 17. Диффа модели нет, долг паритета не вырос.

Мобильный экран (сверка с макетом): не применимо — предмет не экранный, кадров нет.
Режим проекта / sourceCanon (996): не применимо — станционный предмет с внешним runtime.

## Блоки

Нет.

## Условия слияния и советы

Полный текст — `.review/2026-11-21-124.md`:
- Л-1 — синхронизация с main перед слиянием.
- Л-2 — назначение реестра /2 против судимого /3.
- С-1 — живой ловец непустого шаблонного сбора.
- С-2 — измеренная причина предполёта.

## Рекомендации по слиянию

1. PR #213 `BEHIND`: `behind_by 11`, merge_base `53d1f3a588`, main `e40d248bb6`. Одиннадцать коммитов main зону implementer не трогают: `git diff --stat 53d1f3a588b4 e40d248bb680 -- .github/ package.json mobile/scripts/ mobile/package.json` пуст.
2. Перед слиянием нужна синхронизация: merge main по 167. Получится новый OBJECT, и этот accept к нему не применяется — нужна отдельная доставка (140) и scoped-суд по норме переноса: дифф зоны против `49943e0f83` пуст, батарея 197 `--repo` 29/29, CI зелёный на новом head.
3. Назначение реестра `registry/contracts.tsv:193` (197/2, пин скрипта `f09d7289…`) стоит привести к /3 (пин `6e05c38c…`) до done-двери.
4. Merge продуктового PR нажимает владелец (CODING-STANDARDS §14), это не шаг reviewer.

## Развилки

- Д-1: сессия в задании — `Rev197V3`, в реестре моделей её нет (rc 2). Суд исполнен сессией `Rev197V4`, привязка модели к OBJECT подтверждена дверью. Запись СУД в state-HANDOFF дописывает оркестратор.
- Д-2: назначение frozen — /2 в реестре и receipt против /3 по тексту. Вердикт судит текст /3, как велит задание v2 п.3; расхождение вынесено в Л-2.

## Не проверено

- `gh run view 44506480581 --log` вернул пустой вывод (0 строк). Отсутствие `Failed to CreateArtifact` подтверждено только по трём job-логам: build-apk, e2e-pilot, android-e2e.
- `sverka_inventarja_143.sh` (§Приёмка п.8) и `pre_critic.sh`/`check_provodka.sh` (п.11) не запускались: это приёмка контракта, на реализации она не судится.
- Живой повтор попытки (re-run failed jobs) не воспроизводился. Суждение о семантике дано по коду.
