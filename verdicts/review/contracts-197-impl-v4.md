FAIL
OBJECT=3d8fe3e4b48d934cb7a2fdd0b96b8047d27e4980
СУД: репо=dev-harness; предмет=197; роль=reviewer; вызов=1 (полный по v4, SANKCIJA консультанта; обычный класс); фаза=реализация; модель-план=anthropic/claude-opus-5-5; модель-факт=anthropic/claude-opus-5-5 (метаданные среды сессии Rev197b: «Model: anthropic/claude-opus-5-5»); предыдущий=verdicts/review/contracts-197-impl-v3.md (accept на 49943e0f); класс риска=обычный

# Review 197 — реализация v4 (канон `ci-artefakty.cjs` = байты 211 в a3ka/Complior-mob), один полный вызов reviewer

Вердикт FAIL держится на одном блоке — **Б-1, привязка OBJECT**. По существу продукт `f8acbbdf…` соответствует замороженному `frozen/contracts/197/4`: байтовый пин совпал, батарея дала 29/29, стабы — 38 из 38 пойманы, И-1…И-10 сверены по коду, своя поведенческая мера зелёная. Блоков по существу нет.

Блокирует то, что accept обязан называть объект. Назначенный `3d8fe3e4b…` несёт обязательства 197/3, а не v4. На продукте его батарея красна по e01, и дверь `done_contract.sh` отказывает именно по этой привязке (замер ниже). Находки в формате reslop — `.review/2026-11-24-158.md`.

## Область

- **Станционная копия.** `/home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/tca6b50ded/m`, ветка `wip/197/reviewer`. Она перемотана ff на `1ec47271534b8c468611ce26a7769eaeec298644`: это `git fetch ssh://git@github.com/a3ka/dev-harness.git refs/heads/main` → FETCH_HEAD. Контракт и батарея main совпадают с `frozen/contracts/197/4` (`d0ca56b833…`): `git diff --stat frozen/contracts/197/4 HEAD -- contracts/197-… fixtures/workshop_project/mob_ci_artifacts_local_197` пуст.
  - blob контракта — `54be75d1326ec246ea129590070bcb129ea31002`;
  - tree батареи — `28a77757aab3716588bd2f2c7275b0bb642a4ddf`;
  - модель — blob `2016ae8fa6…`, sha256 `f40a5afc…`.
- **Продукт читался на mob `f8acbbdf8ce9529f30628816b14a826b803975fe`**, только чтение.
  - Свежий клон `git clone https://github.com/a3ka/Complior-mob.git` (ssh-URL из задания: `ERROR: Repository not found`, rc 128), затем `git switch --detach f8acbbdf…`; `git rev-parse HEAD` = `f8acbbdf…`. Это head main продукта: `Merge pull request #289 from a3ka/wip/211/ci-wiring`.
  - `git status --short | wc -l` = 0 после всех прогонов. Мутант собирался в отдельной копии.
  - Байт-контроль: `sha256sum mobile/scripts/ci-artefakty.cjs` = `f40a5afc4d8263436714d2f81bb1973209decacbec5942e23db5aaf0e21c47ec`, 238 строк.
    - Это равно пину v4 в контракте (стр. 16, извлечён из `frozen/contracts/197/4` тем же grep).
    - Равно `sha256sum` модели станции на main.
    - Равно `source.json:14` и `:22` (`kanon_211`).
    - `cmp` модели и продукта — rc 0.
    - `git diff --stat 6513a2af f8acbbdf -- mobile/scripts/ci-artefakty.cjs` пуст: байты = принятая голова 211.
- **OBJECT `3d8fe3e4b…` против `088cc14ab…`.**
  - `git diff --stat 3d8fe3e4b 088cc14ab`: 343 files changed, 2772(+), 88038(−). По dirstat это `.review/`, `fixtures/workshop_project/odin_agent_140/stabs/`, `fixtures/`, `verdicts/critic/`, `verdicts/review/` и прочее — чужие предметы на двух линиях истории.
  - По 197 различий нет: `git diff --stat 3d8fe3e4b 088cc14ab -- contracts/197-… fixtures/workshop_project/mob_ci_artifacts_local_197 frozen` пуст.
  - На обоих — blob контракта `8236d78538…` (= `frozen/contracts/197/3`) и модель `6e05c38c…` (канон v3, 206 строк).
  - `3d8fe3e4b` — это `land: wip/int-095/orch-b4v` (orchestrator, 2026-11-22 05:16, коммит main). Он не tip `wip/197/architect` (origin tip `8a6ff2082`; `--is-ancestor 3d8fe3e4b 8a6ff2082` → rc 1) и не потомок заморозки 197/4 (`--is-ancestor d0ca56b83 3d8fe3e4b` → rc 1).
  - Отличие OBJECT от main по 197: `git diff --stat 3d8fe3e4b HEAD -- …197…` → 4 файла (контракт, модель cjs, `sdacha_197.md`, `source.json`), +86/−11. Это ровно коммит architect `9c90ecd45` «197 v4: канон и пин … по реализации 211». `probe.py`, `red_…sh` и стабы не менялись.
- **Дельта продукта от v3-accept** (`git diff --stat 49943e0f83 f8acbbdf -- mobile/scripts .github package.json`, 10 файлов, +1010/−237). Принадлежность измерена `git log --first-parent` по каждому пути:
  - **197/211 (зона 197):** `mobile/scripts/ci-artefakty.cjs` +40/−… — коммит 211 `6a8872904b` «211: запрет повторной записи…» (implementer), PR #252. Это и есть канон v4.
  - **211 ci-wiring (#289):** `package.json` lane `ci:ci-artefakty.cjs` и шаг `mobile.yml` «211 батарея --candidate» (стр. 143–149). Сверх семантики v4 по 197 он не вводит ничего: это прогон батареи 211 на кандидате, артефактов не пишет и не читает. Принят под предметом 211 — отмечено, не блок.
  - **212 (#276), 207 (#286, #241):** lanes `ci:red_mob_harness_events_212`, `ci:check-context-sources.py` и их шаги; `check-context-sources.py`.
  - **141 (#222):** `ci-erstinformation-118.sh`, `ci-first-run-135.sh`, `ci-pilot-995.sh`, перенос adb/APK-диагностики из `mobile.yml`.
  - **205 (#283):** правки `mobile.yml`.
  - **164 (#183):** `check-api-snapshot.py`, `gen-api-types.sh`, `coding-standards-claims.tsv`.
  - **197 v3 (#213):** уже судим v3-accept.
- **Атомарность.** Изменение канона — один коммит `6a8872904b` с предметом в теме. Автор — `implementer <implementer@dev-harness.local>`.
- **Норма не тронута.** Текст контракта после заморозки 197/4 не менялся (diff выше пуст). Вердикт не правит ничего, кроме своего файла и `.review/`.

## Регресс

- **Инвентарь операций.** Он не изменился против v3-accept: `diff` списков `ci:artefakt-(zapis|chtenie) -- …` в `mobile.yml` на `49943e0f83` и на `f8acbbdf` → rc 0, 9 zapis + 8 chtenie = 17.
- **Канал GitHub в `mobile.yml`.** Исполняемых вхождений нет. Единственное совпадение — комментарий, стр. 1184. `upload-artifact` остался только в `mobile-cloud-e2e.yml:95,103`, а он в «НЕ ЗАЩИЩАЕТ».
- **Корень.** Литерал `/var/lib/ci-artifacts/Complior-mob` и `CI_ARTEFAKTY_KOREN` вне `.harness/` встречаются только в `mobile/scripts/ci-artefakty.cjs` (grep по `*.yml *.json *.cjs *.sh`).
- **Паритет `verify_ci_parity.sh`.**
  - `7c7e333` (ленд 197 v3): rc 1, «workflow-команд: 160 · скриптов в приёмке: 6 · объявленных исключений: 92 · … · расхождений: 29».
  - `f8acbbdf`: rc 1, «workflow-команд: 152 · скриптов в приёмке: 9 · объявленных исключений: 92 · … · расхождений: 43».
  - Все 14 новых FAIL — 141 (#222, `git log -S`). Lanes 197/211 в FAIL не входят. Приёмка п.9 по 197 выполняется; прирост вынесен в С-1.

## Проверки

**1. Байт-равенство канона** — `sha256sum`, своя мера.

```
f40a5afc4d8263436714d2f81bb1973209decacbec5942e23db5aaf0e21c47ec  <mob f8acbbdf>/mobile/scripts/ci-artefakty.cjs          (238 строк)
f40a5afc4d8263436714d2f81bb1973209decacbec5942e23db5aaf0e21c47ec  fixtures/…/model/mobile/scripts/ci-artefakty.cjs (main = 197/4)
f40a5afc4d8263436714d2f81bb1973209decacbec5942e23db5aaf0e21c47ec  пин стр.16 frozen/contracts/197/4
cmp model product → rc 0
6e05c38cad900b3185dff4716b827ca04ca6d3ec718fb3e14d5c5bdf5f6f69b3  модель на OBJECT 3d8fe3e4b (206 строк)  ≠ продукт → Б-1
```

**2. Батарея 197 (main = 197/4).** Корень станционной копии, `TMPDIR=/tmp/dev-harness-verify/scratch-rev197b`.

```
bash fixtures/workshop_project/mob_ci_artifacts_local_197/red_mob_ci_artifacts_local_197.sh --repo <mob f8acbbdf>
CASE a01-upload-artefakt-ostalsja ok
CASE a02-download-artefakt-ostalsja ok
CASE a03-gh-kanal-v-run ok
CASE b01-forma-pisatelja ok
CASE b02-imja-pisatelja-razreshimo ok
CASE b03-pisatel-s-run-argumentom ok
CASE c01-forma-chitatelja ok
CASE c02-imja-bez-pisatelja ok
CASE c03-run-para-iz-sborki ok
CASE d01-koren-vne-skripta ok
CASE d02-vyhod-za-koren ok
CASE e01-skript-pin ok
CASE e02-linei-npm ok
CASE g01-forma-nositelja ok
CASE g02-rabochij-katalog-nositelja ok
CASE i01-nositel-ispolnim ok
CASE i02-zamknutyj-inventar ok
CASE r01-krug-zapisi-chtenija ok
CASE r02-popytka-prodjusera ok
CASE r03-imja-pobeg ok
CASE r04-imja-razdelitel ok
CASE r05-run-nechislovoj ok
CASE r06-nepolnaja-identifikacija ok
CASE r07-shablon-sbor ok
CASE r08-istochnik-otsutstvuet ok
CASE r09-izoljacija-popytok ok
CASE r10-shablon-pusto ok
CASE r11-tochnoe-imja-otsutstvuet ok
CASE s01-styk-sbor-agregat ok
клеток 29, зелёных 29, красных 0
RC_REPO=0
… --model   → 29 строк «CASE … ok», «клеток 29, зелёных 29, красных 0», RC_MODEL=0
… --stabs   → честный контроль 29/29; 38 строк «STAB <имя> KRASEN: <клетка>: rc=…: <причина>»; восемь s01-snimok-стабов
              дают «ORACLE_TAMPERED» rc 2 в четырёх режимах ([], --model, --stabs, --repo); «стабов 38, непойманных 0», RC_STABS=0
```

Число стабов пересчитано своей мерой: в `stabs/` 38 файлов `stab_*.py` (`git ls-tree`), строк KRASEN — 38.

**3. Батарея дерева OBJECT на продукте** — `git worktree add --detach <scratch>/objtree 3d8fe3e4b`; `… --repo <mob f8acbbdf> | grep -v ' ok$'`.

```
CASE e01-skript-pin KRASNO: SKRIPT_PIN_RASHOZHDENIE: f40a5afc4d8263436714d2f81bb1973209decacbec5942e23db5aaf0e21c47ec != 6e05c38cad900b3185dff4716b827ca04ca6d3ec718fb3e14d5c5bdf5f6f69b3
клеток 29, зелёных 28, красных 1
RC_OBJ_REPO=1
```

**4. Дверь** — одноразовый клон main `1ec472715` в scratch, пробный accept-файл, никуда не пушился; удалён вместе со scratch.

```
OBJECT=3d8fe3e4b…  → done: OBJECT 3d8fe3e4b… не связан с последней заморозкой frozen/contracts/197/4 — вердикт судит объект старой версии   DOOR_RC=1
OBJECT=f8acbbdf…   → done: место реализации предмета 197 не установлено — нет объявления ПРОДУКТ: и нет применимой записи registry/mesto-legacy.tsv   DOOR_RC=1
OBJECT=f8acbbdf… + строка mesto-legacy (197, blob 54be75d…, a3ka/Complior-mob) → done: v>1 требует строку РАЗРЕШИЛ-ВЛАДЕЛЕЦ: в причине   DOOR_RC=1 (шаг 7 — после всей 6б)
git tag -l 'done/contracts/197/*' → done/contracts/197/1 (прежний, новых не создано)
```

**5. И-1…И-10 по коду** (`mobile/scripts/ci-artefakty.cjs` на f8acbbdf; номера строк — этого файла).

- **И-1.** Канала GitHub в `mobile.yml` нет (§Регресс). Клетки a01–a03 зелёные.
- **И-2.** Путь `<koren>/<run_id>-<run_attempt>/<imja>` строит только `katalog_artefakta` (стр. 101–108: `path.resolve(koren(), k.id + '-' + k.popytka, imja)`). Каталог run'а для чтения — стр. 189. Корень по умолчанию — стр. 44; абсолютность — стр. 97.
  - В workflow корня нет, имя пары workflow не строит.
  - Носители однострочные: 9 `ci:artefakt-zapis` (стр. 107, 538, 728, 830, 997, 1157, 1270, 1335, 1424) и 8 `ci:artefakt-chtenie` (577, 768, 873, 1042, 1201, 1311, 1364, 1407).
  - Lanes в `package.json:9-10` = канон (e02).
- **И-3.** Писатель с `--run-id/--run-attempt` → `PISATEL_S_RUN_ARGUMENTOM` (стр. 76). Контекст берётся из `GITHUB_RUN_ID/ATTEMPT` (стр. 78). Числовость — `RUN_KONTSEKST_NECHISLOVYJ` (стр. 89–92).
- **И-4.** Все 6 APK-читателей (577, 768, 873, 1042, 1201, 1311) передают `--run-id "$RUN_SBORKI" --run-attempt "$POPYTKA_SBORKI"`. Неполная пара → `NEPOLNAJA_IDENTIFIKACIJA_RUNA` (стр. 82). Происхождение пары судит c03 — зелёная.
- **И-5.** Отсутствующий каталог run'а → `KATALOG_RUNA_OTSTUTSTVUET` (стр. 190–192). Отсутствующее точное имя → `CHTENIE_OTSTUTSTVUET` (стр. 199–201). Оба отказа rc 2 через `otkaz` (стр. 49–52).
- **И-6.**
  - Алфавиты — стр. 45–46.
  - Проверки имени — стр. 154, 197; шаблона — стр. 209.
  - Страж префикса корня `VYHOD_ZA_KOREN` — стр. 104–107.
  - `--kuda` абсолютный или с `..` → `NAZNACHENIE_VNE_RABOCHEGO_KATALOGA` (стр. 186).
- **И-7.**
  - Файл кладётся внутрь `<imja>/` под своим именем (стр. 177), каталог — содержимым (стр. 175).
  - Пустой шаблон: `mkdirSync(kuda)` + `CHTENIE_PUSTO`, rc 0 (стр. 214–222).
  - Шаблонный сбор пишет в `<имя>-<run_id>-<run_attempt>` (стр. 231–233).
- **И-8 / И-9.** Это свойства носителей в workflow. Клетки g01/g02/i01/i02 зелёные. Каждый носитель несёт `working-directory: ${{ github.workspace }}`: g02 зелёная, выборочно сверено на стр. 105–107, 147–149.
- **И-10.**
  - `zapis_zanyat` — `lstatSync` (стр. 126–138).
  - Вызов — до копирования (стр. 171–173): `ARTEFAKT_UZHE_ZAPISAN`, rc 2.
  - `ISTOCHNIK_NE_FAIJ_NI_KATALOG` проверяется до копирования (стр. 163–166).
  - Механизм гарантии — пин e01; вне батареи его подтверждает п.6.

**6. Своя поведенческая мера** — `/tmp/dev-harness-verify/scratch-rev197b/i10.sh`, продуктовый скрипт, временный корень; RC_REPLAY=0.

```
z1-pervaja rc=0 ZAPIS 111-1/art
z2-povtor-fajl rc=2 ARTEFAKT_OTKAZ: ARTEFAKT_UZHE_ZAPISAN: 111-1/art
z2-bajty-ne-izmeneny OK
z3-pustoj-katalog rc=2 ARTEFAKT_OTKAZ: ARTEFAKT_UZHE_ZAPISAN: 111-1/pustoj
z3-pusto-ostalos OK
z4-bityj-symlink rc=2 ARTEFAKT_OTKAZ: ARTEFAKT_UZHE_ZAPISAN: 111-1/bityj
z4-cel-symlink-ne-izmenena OK
z5-fifo rc=2 ARTEFAKT_OTKAZ: ISTOCHNIK_NE_FAIJ_NI_KATALOG: src/fifo
z5-nichego-ne-sozdano OK
z6-drugaja-popytka rc=0 ZAPIS 111-2/art
z7-pisatel-run rc=2 ARTEFAKT_OTKAZ: PISATEL_S_RUN_ARGUMENTOM
z8-nechislovoj rc=2 ARTEFAKT_OTKAZ: RUN_KONTSEKST_NECHISLOVYJ: {"id":"abc","popytka":"1"}
z9-imja-pobeg rc=2 ARTEFAKT_OTKAZ: IMJA_VNE_ALFAVITA: ..
c1-tochnoe-net rc=2 ARTEFAKT_OTKAZ: CHTENIE_OTSTUTSTVUET: 111-1/netu
c2-run-net rc=2 ARTEFAKT_OTKAZ: KATALOG_RUNA_OTSTUTSTVUET: 999-1
c3-nepolnaja rc=2 ARTEFAKT_OTKAZ: NEPOLNAJA_IDENTIFIKACIJA_RUNA
c4-shablon-pusto rc=0 CHTENIE_PUSTO: zzz-*
c4-kuda-pust OK
c5-kuda-pobeg rc=2 ARTEFAKT_OTKAZ: NAZNACHENIE_VNE_RABOCHEGO_KATALOGA: ../o5
c6-tochnoe rc=0 CHTENIE 111-1/art
c6-bajty-pervoj-zapisi OK
z10-ev-a rc=0 ZAPIS 111-1/screen-evidence-a
c7-shablon rc=0 CHTENIE_PO_SHABLONU 1: screen-evidence-a-111-1
```

**7. Неподгонка и красное.**

- После заморозки 197/4 батарея не менялась. Дельта v4 к батарее (`9c90ecd45`, architect) — только пин, байты модели, `sdacha` и текст. `probe.py`, `red_…sh` и `stabs/` не тронуты: `git diff --stat 3d8fe3e4b HEAD -- fixtures/…197` → 3 файла, ни один не логика.
- Красное своей мерой: копия продукта с `if (zapis_zanyat(naznachenie)) {` → `if (false) {` (scratch `mut.py`, одно вхождение) даёт
  ```
  CASE e01-skript-pin KRASNO: SKRIPT_PIN_RASHOZHDENIE: fcf17b3f4a586ef532afecfb0ea629bb755a66385105945629374ed39627efc5 != f40a5afc…
  клеток 29, зелёных 28, красных 1
  RC_MUT=1
  ```
- 38 стабов красны каждый своей именованной причиной (п.2). Клетки различают поведение: например, `stab_r10_shablon_padaet` → `SHABLON_PUSTO_OTKAZ`, `stab_r11_imja_ticho` → `TOCHNOE_IMJA_TICHO_PROSHLO`. Это не повтор текста скрипта.

**ОСТАТОК** (контракт 192; «НЕ ЗАЩИЩАЕТ» с ловцом reviewer, номера — позиции списка, как в v3).

ОСТАТОК: К-08 — не укусил. Произвольный shell вне носителей проверен по `mobile.yml`/`package.json` на f8acbbdf:
- `grep -nE 'npm run +["$]|npm run +\$\{|eval|bash -c|sh -c|node +-e|xargs'` даёт одно вхождение — `node -e` на стр. 95, это выходы выбора из `selection.json`, к артефактам отношения не имеет.
- Вызовы канона — только 17 прямых носителей и lane 211 `ci:ci-artefakty.cjs` (батарея 211, шаг стр. 149).
- `git grep 'ci-artefakty|CI_ARTEFAKTY|ci-artifacts'` по `mobile/scripts .github` за пределами канона: только комментарий стр. 144 и шаг 149.

ОСТАТОК: К-09 — не укусил. Поштучная сохранность 17 операций исходного инвентаря:
- Тексты носителей на f8acbbdf байт-в-байт равны v3-accept `49943e0f83`, где v3-вердикт сверил их поштучно с `fda1fc8` (diff rc 0).
- Все 5 maestro-писателей на месте: `maestro-117` 728, `maestro-first-run` 830, `maestro-erstinformation` 997, `maestro-start` 1157, `maestro` 1270.

**Паразитная сложность (050)** — артефакты дельты v4 в зоне 197.

- `zapis_zanyat` (стр. 126–138) и вызов на стр. 171–173:
  1. Свойство — И-10, отказ повторной записи для любой записи ФС.
  2. Состояние явное: rc 2 и строка `ARTEFAKT_UZHE_ZAPISAN: <пара>/<имя>`.
  3. Файл один — канон.
  4. Интерфейс не вырос: ни флагов, ни env; новая причина отказа идёт тем же rc 2.
  5. Потребители — e01 (пин) и шаг «211 батарея --candidate». Более простая форма (`existsSync`) не держит битый symlink: И-10 его явно называет.

  Вывод: ESSENTIAL.
- Перенос `ISTOCHNIK_NE_FAIJ_NI_KATALOG` до копирования (стр. 163–166) — тот же вывод (И-10, «до копирования»). Ветвь в `skopirovat` (стр. 121–122) осталась для вложенных не-файлов при рекурсии — ESSENTIAL.
- Lane и шаг 211 `ci:ci-artefakty.cjs` — артефакт 211, судится там.

**ПРОВОДКА (038).**
- Guard `red_mob_ci_artifacts_local_197.sh` существует и подключён: `registry/ci-steps.tsv:315` `check:mob-ci-artifacts-local-197-family-selftest … --stabs`.
- Это барьер именно 197: e01 — пин канона, a01–a03 — канал. `--repo <продукт>` в CI станции не подключается, потому что продукта нет в дереве (как в v3).

СВЕРКА-СТАНДАРТОВ: продуктовый `docs/CODING-STANDARDS.md` §1 (область — код `mobile/src`; CI-скрипты и workflow под §2–§13 не попадают) — соответствует. §14 (ветки/коммиты: `wip/211/implementer`, тема «211: …», один PR #252, merge владельцем) — соответствует. `docs/ARCHITECTURE.md` в продукте нет — не применимо.

СВЕРКА-АРХИТЕКТУРЫ: модели архитектуры 188 у предмета нет (`tooling/checks/cli.js` в станции отсутствует, `bindings.json` в продукте нет) — уровень diff модели не применим.
- Размещение: канон остался в `mobile/scripts/`.
- Зависимости: только `fs`/`path` Node.
- Писатели и операции: прежние 17.
- Долг паритета вкладом 197/211 не расширен (С-1 — 141).
- Находок L1/L2/L3 нет. `finding new` не заводился: расхождения модели и работы не обнаружено, а Б-1 — привязка процесса, не архитектура.

Мобильный экран: не применимо — предмет не экранный.
Режим проекта / sourceCanon (996): не применимо — `harness.project.json` станции: `repoId` = `dev-harness`, `sourceCanon` не объявлен (jq → null; grep sourceCanon → 0); гейт сверки источников двери в пробе п.4 пройден.

## Блоки

- **Б-1 (оркестратор → консультант).** OBJECT `3d8fe3e4b…` — объект 197/3, а не 197 v4: blob контракта `8236d78…`, модель `6e05c38c…`.
  - На продукте его батарея красна по e01 (§Проверки п.3).
  - Заморозка 197/4 — не его предок, поэтому дверь отказывает: «OBJECT … не связан с последней заморозкой» (п.4).
  - Посылка задания «tip `wip/197/architect`; модель/батарея 197 v4» измерена ложной (§Область).
  - **Исправление, проходящее дверь до клапана владельца (п.4).** Accept с `OBJECT=f8acbbdf8ce9529f30628816b14a826b803975fe` плюс строка `registry/mesto-legacy.tsv` для blob 197/4 `54be75d1326ec246ea129590070bcb129ea31002` → `a3ka/Complior-mob`. Строку пишет оркестратор, зона реестра. Подробно — `.review/2026-11-24-158.md`.
  - **Повторный суд** — scoped, только на перепривязку. Замеры этого вердикта переносятся при неизменных sha256 канона `f40a5afc…` и tree батареи `28a77757aa…`.

## НЕ ЗАЩИЩАЕТ

- **К-01 (корень и очистка — 196), К-02 (DAG — 143/141/148), К-03 (выражения вне списка), К-05 (`actions: read`), К-06 (ретенция).** Ловцы — живой CI или станция, не reviewer.
- **К-04.** `mobile-cloud-e2e.yml` по-прежнему несёт 2 upload-шага (стр. 95, 103) — вне предмета.
- **К-07.** Канал вне `mobile.yml`: `.github/actions/**` в продукте нет (`git grep` пуст). Ловец — паритет.
- **К-10.** Совместимость агрегата: `ci-aggregate.cjs` в дельте не тронут (не входит в diff `--stat`), s01 зелёная.
- **Чего этот вызов не проверял.**
  - Живой мобильный CI на f8acbbdf — пп.10 приёмки; ловец — оркестратор и продуктовый CI.
  - `sverka_inventarja_143.sh`, `pre_critic.sh`, `check_provodka.sh` (пп.8, 11): это приёмка контракта на станции, у критика v4 они rc 0.

## Советы

Полный текст — `.review/2026-11-24-158.md`.
- **С-1.** Долг паритета продукта 29 → 43 — вклад 141 (#222), не 197/211.
- **С-2.** И-10 держится только пином e01. Поведенческая r-клетка повторного `zapis` — при следующей версии 197.
