accept
OBJECT=c1a83c1ad4acf7b4fb2c69f4a505202232cf8c37
СУД: репо=dev-harness; предмет=223; фаза=реализация; роль=reviewer; вызов=1 (полный); сессия=c907157c/Rev223; модель-факт=anthropic/claude-opus-5-5 (метаданные станции, поле Model); автор Impl223 — implementer (MiniMax); Architect223c; предыдущие адверсарные: archive/223/adversary-v1-fail-3deff003a, archive/223/adversary-v2-accept-437a65794

# Reviewer 223 — ARCH_CI v2: `.review/**` как служебный путь подъёма SHA*, реализация, вызов 1

**БЛОКИРУЕТ: нет.**

**СОВЕТ: 3** — файл `.review/2026-11-26-2231.md` (`status: ready`):

- С-1 (architect после done, К-08). Мутант `.[Hh]arness/*|.[Rr]eview/*` проходит батарею 47/0, а на мире `.Review/x.md` даёт ложный done. Честная production такой мир отвергает (rc 1).
- С-2 (architect после done, К-08). Сужение `.review/[!.]*` проходит батарею 47/0. Направление — ложный отказ (fail-closed), вреда для авторизации нет.
- С-3 (implementer). Комментарий `scripts/done_contract.sh:531–533` всё ещё говорит «только `.harness/**`».

Перепроверил ВСЁ: область правки, сырой вывод, не переписаны ли проверки под код.

Production `scripts/done_contract.sh` честна. Все прогоны ниже шли в чистом клоне с origin на OBJECT. Теги `frozen/contracts/223/1` (`28b91abd6`) и `228/1` (`da59335ba`) подтянуты. Рабочий каталог — `$PWD/tmp/clone-rev223`, `TMPDIR=$PWD/tmp/scratch-rev223`, shellcheck пинован 0.11.0.

## Область правки

Merge-base: `bcd1de3876bbf13fd6612fd1d3b1df1516a2b94c` (origin/main сейчас `568f0ea63`).

```
$ git diff --name-status bcd1de387 c1a83c1ad
M	.github/workflows/ci.yml
M	fixtures/workshop_project/arch_ci_review_223/SDACHA.md
M	fixtures/workshop_project/arch_ci_review_223/context.py
A	fixtures/workshop_project/arch_ci_review_223/context_freeze.py
M	fixtures/workshop_project/arch_ci_review_223/probe.py
M	registry/ci-steps.tsv
M	registry/ci-zamery.tsv
M	scripts/done_contract.sh
A	verdicts/adversary/contracts-223-impl-v1.md
$ git log --format='%h %an %cn %s' bcd1de387..c1a83c1ad
c1a83c1ad orchestrator orchestrator orchestrator: CI-шаг 223 с --sintaksis (curl shellcheck 0.11.0 …; блок Adv223 К-04)
7fd0c01e9 architect orchestrator 223: exclude own frozen subject from overlap census; lock with catalog regression
13ef31882 adversary orchestrator adversary 223: verdict on ARCH_CI and acceptance wiring
e864b784f orchestrator orchestrator orchestrator: CI-шаг батареи 223 (…--repo/--model/--stabs/--catalog…)
880021340 implementer orchestrator implementer 223: ARCH_CI — служебный хвост .harness/** и .review/**
```

ЗОНА frozen 223/1 (`git show frozen/contracts/223/1^{commit}:contracts/223-arch-ci-review.md | grep '^ЗОНА'`): implementer — `scripts/done_contract.sh`; architect — контракт и `arch_ci_review_223/`; orchestrator — `registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml`; adversary — `verdicts/adversary/`.

Сверка по авторам:
- implementer `880021340` → только `scripts/done_contract.sh`;
- architect `7fd0c01e9` → только `arch_ci_review_223/`;
- orchestrator `e864b784f`/`c1a83c1ad` → только три CI-файла; в `ci.yml` правка лежит целиком внутри `# BEGIN/END GENERATED CI JOBS (083)`, `gen_ci_steps.sh --check` rc 0;
- adversary `13ef31882` → только `verdicts/adversary/`.

Вне зоны правок нет.

Контракт не менялся: `git diff --stat frozen/contracts/223/1 HEAD -- contracts/223-arch-ci-review.md` пуст, `git diff bcd1de387 HEAD -- contracts/ | wc -l` = 0.

Production после implementer не трогали: `diff <(git show 880021340:scripts/done_contract.sh) scripts/done_contract.sh` пуст.

**Проверки не подогнаны под код.** После freeze architect менял в батарее только четыре места:
- `context.py`: исключение SUBJECT из census;
- `context_freeze.py`: новый;
- `probe.py`: +1 строка, вызов context_freeze в `--catalog`;
- `SDACHA.md`.

CASES, оракул, stabs.tsv, source.json и MUTATIONS не тронуты: `git diff frozen/contracts/223/1 HEAD -- …/probe.py` показывает одну строку в ветке `--catalog`. Implementer фикстуры не трогал.

Модель отличается от production только комментариями: `diff model/done_contract.sh scripts/done_contract.sh` даёт 25 строк, после отбрасывания строк `#` не остаётся ни одной.

## Полный diff production (+25/−11; код +7/−4)

```
+_arch_ci_service_path() {          # :295–300, вызывается один раз (:547)
+  case "$1" in
+    .harness/*|.review/*) return 0 ;;
+    *) return 1 ;;
+  esac
+}
-            case "$_a187_path" in
-              .harness/*) : ;;
-              *) _a187_only=0 ;;
-            esac
+            _arch_ci_service_path "$_a187_path" || _a187_only=0
```

Остальная дельта — комментарии.

- **Граница каталога.** `case` сравнивает литеральный префикс `.harness/` или `.review/` и не складывает регистр: `nocasematch`/`shopt` в файле нет, grep пуст. Префикс без `/` (`.review`, `.review.md`, `.reviewx/`), `.REVIEW/`, `.Review/`, `docs/.review/`, `other/.review/` попадают в `*) return 1`.
  - `./`- и `..`-компоненты git не выдаёт; инв. 4 проверяет это клетка `normalized-escape`.
  - Невалидный UTF-8 под `.review/` при `LC_ALL=C.UTF-8` и `LC_ALL=C` даёт service, `.r\xc3\xa9view/x` — product (собственный прогон `bash -c 'case …'`).
- **Сбор путей.** Строка `:542` не изменилась: `git diff --no-renames --ignore-submodules=none --name-only -z p1 SHA*`, чтение `read -r -d ''`. Список NUL-разделён и полон: rename даёт обе стороны, gitlink виден даже при `diff.ignoreSubmodules=all` и `diff.renames=copies` в конфиге репо (собственная клетка `gitlink-src-userconfig-ignore` GREEN rc=1).
- **Пустая дельта и octopus.** Предикат `[ "$_a187_npaths" -eq 0 ] || [ "$_a187_only" -ne 1 ]` сохранён на `:550`. Ветвь octopus `-gt 2` (`:523`), root и предел 50 не тронуты.
- **Порядок ARCH_CI (187а/201(г)).** Запрос check-run, имена `arch`/`arch …`/`arch (…)` и `head_sha ∈ {SHA*, HEAD}` не изменились.
- **R-0102.** Литералов проектов нет: в коде только два корневых каталога.
- **Ветвь `.harness/**`.** Не сломана: клетки `harness-merge`, `empty-second-harness` и собственные `delete-harness-only`/`delete-harness-add-review` GREEN rc=0.
- **Реальный мир done 177/6 (09f8ba63).** Клетка `backend177-chain` (`.review/` PR #1031, затем `.harness`/`.review`/`.harness` merge) GREEN rc=0: запрос к продуктовому SHA*, тег на HEAD.
- **Shellcheck и синтаксис.** `bash -n` rc 0. Shellcheck 0.11.0 `-S warning` на HEAD и на базе выдаёт одни и те же 5 предупреждений (SC2034×4, SC1010) со сдвигом строк на 13. Новых находок нет; rc 1 у обоих — пред-существующий.

## Собственные мутанты production (НЕ из stabs.tsv), `probe.py --repo <мутант>`

| мутант | правка | батарея | итог |
|---|---|---|---|
| m01 | `.review*/*` | 47/1 (`reviewx` RED rc=0) | убит |
| m02 | `+*/.review/*` | 47/1 (`review-not-root` RED rc=0) | убит |
| m03 | `.[Hh]arness/*\|.[Rr]eview/*` | **47/0** | жив → С-1 |
| m04 | без `-z`, `read` по LF | 47/2 (`review-unicode`, `review-newline`) | убит |
| m05 | `.review/[!.]*` | **47/0** | жив → С-2 (только ложный отказ) |
| m06 | `+*.md` | 47/10 | убит |
| m07 | `+.review` (файл) | 47/1 (`review-file`) | убит |
| m08 | `--diff-filter=d` | 47/2 (`review-delete`, `product-rename-in`) | убит |
| m09 | `.review/*.md` | 47/1 (`review-symlink`) | убит |
| m10 | `case "${1#./}"` | 47/0 | эквивалент: git не выдаёт `./` |

Сырой вывод живых мутантов:
```
m03-partial-fold: KLETKI 47 KRASNYH 0
m03-partial-fold RC=0
EXTRA review-titlecase RED RC,QUERY,TAG rc=0 q=302c0cdca | ARCH_CI: HEAD=b44eab69…; SHA*=302c0cdc…; успешный check-run arch засчитан   # m03
EXTRA review-titlecase GREEN rc=1 q=4f1164d8a | … SHA*=4f1164d8…(=HEAD); успешного check-run arch нет                               # честная
m05-review-no-dotfiles: KLETKI 47 KRASNYH 0
EXTRA review-dotfile RED RC,QUERY,TAG rc=1 …        # m05
EXTRA review-dotfile GREEN rc=0 q=96799e6d3 …       # честная
```

## Собственные Git-миры на честной production (настоящий CLI двери, API-шлюз как в probe.py)

Конструктор — `world201.build` и помощники `probe.py`. Ожидания заданы литералами до запуска двери. Скрипт был scratch, после суда удалён.

```
EXTRA delete-harness-plus-scripts GREEN rc=1   (SHA*=HEAD)
EXTRA delete-harness-only GREEN rc=0           (SHA*=продукт)
EXTRA delete-harness-add-review GREEN rc=0
EXTRA rename-review-to-scripts GREEN rc=1      (.review/old.md → scripts/a.md)
EXTRA review-bak-dir GREEN rc=1                (.review.bak/x)
EXTRA harnessx-dir GREEN rc=1
EXTRA harness-prefix-file GREEN rc=1           (.harness.md)
EXTRA review-prefix-file GREEN rc=1            (.review.md)
EXTRA review-dir-to-file GREEN rc=1            (каталог .review → файл .review)
EXTRA gitlink-review GREEN rc=0                (gitlink .review/sub)
EXTRA gitlink-src GREEN rc=1
EXTRA gitlink-src-userconfig-ignore GREEN rc=1 (diff.ignoreSubmodules=all, diff.renames=copies)
EXTRA status-editing GREEN rc=0                (.review/… status: editing — служебен по пути, НЕ ЗАЩИЩАЕТ)
EXTRA mid-product-stops GREEN rc=1             (review-merge → продуктовый коммит → review-merge: SHA* = продуктовый коммит)
EXTRA depth-50 GREEN rc=0
EXTRA depth-51 GREEN rc=1                      (лимит глубины подъёма (50) исчерпан, API не вызван)
EXTRA review-titlecase GREEN rc=1 / other-nested-review GREEN rc=1 / review-dotfile GREEN rc=0
EXTRA quote-name GREEN rc=0 / leading-dash GREEN rc=0
EXTRA KLETKI 18 KRASNYH 0  (+3 отдельным прогоном, все GREEN)
```

Список задания п.4 проверен целиком, ложного done на честной production нет:
- продуктовая дельта, смесь: `mixed-*`, `delete-harness-plus-scripts`;
- `.review` как префикс строки;
- регистр;
- rename `.review/a` → `scripts/a`;
- удаление `.harness/x` вместе со `scripts/y`;
- merge без check-run на предке: клетка `review-missing-run` rc 1;
- `status: editing`: служебен по пути, контракт этого и не обещает.

## «Три искусственных расширения классификатора» (совет Adv223/Adv223b)

Расширения `.review.bak/*`, `.Review/*`, `other/.review/*` на честной production недостижимы.
- Её шаблон — литерал `.harness/*|.review/*` (`:297`). Все три пути попадают в `*) return 1`.
- Миры `review-bak-dir`, `review-titlecase`, `other-nested-review` дают GREEN rc=1: SHA* = HEAD, тега нет.
- Ложного done нет, поэтому это совет, а не блок. Класс «частичное складывание регистра» — С-1. Два других расширения — произвольные литеральные добавки; конечная батарея их не исключает. Обобщённые формы m01 и m02 батарея убивает.

## Регресс (чистый клон, OBJECT)

```
W --repo .      : KLETKI 47 KRASNYH 0, RC=0 (1m44s)
W --model       : KLETKI 47 KRASNYH 0, RC=0
W --stabs       : 24 красные связи RED, ZHIVYH 0 SVJAZI 43, RC=0
W --catalog     : CONTEXT KLETKI 3 STABY 2 EKVIVALENTY 1 ZHIVYH 0; KLETKI 47 STABY 12 EKVIVALENTY 4 SVJAZI 43, RC=0
W --sintaksis   : SINTAKSIS 17 SHELLCHECK 2, RC=0 (VALIDATE_STD_SHELLCHECK=пин 0.11.0; без пина — rc 2 VALIDATOR_MISSING, среда)
context.py      : ДЕКЛАРАЦИИ 75, RC=0
check_sdacha --run (1200/2400): СДАЧА: лист зелёный (двери=10 карта=17/17 дельта=2), RC=0
pre_critic      : КРИТИК: дверь зелёная, RC=0 (с пином shellcheck; первый прогон без пина rc 1 на --sintaksis — моя среда)
check_precision_gate: OK RC=0
check_provodka  : RC=0
check_spec_ready: OK RC=0
gen_ci_steps --check: RC=0
224 --repo .    : KLETKI 100 KRASNYH 0, RC=0
187 --repo .    : CELLS=111 STABS=0 FAILURES=0, RC=0
201 --repo .    : CELLS=62 STABS=0 FAILURES=0, RC=0
205 --repo .    : KLETKI=24 ZELENYE=24 KRASNYE=0, RC=0
992 fail_closed : cases=25 observations=25 failures=0, RC=0
038 consumers   : RC=0
116/195         : RC=1 — 195: честных клеток 14, зелёных 13, красных: k187a-okno-187-s-probami-r0
                  БАЗА bcd1de387 (отдельный клон): RC=1 — та же клетка k187a и та же причина
                  «потребители 116: замер маппинга отсутствует (контракт правит писателя scripts/done_contract.sh)»
                  (писатель-коммитов 8 на базе / 9 на OBJECT) — пред-существующее, не хуже базы
verify_antiplacebo --scope done_contract: барьеров 1, фикстур 1, предъявлено красным 1, RC=0
CI на OBJECT (gh api check-runs c1a83c1ad): все ci (l1…l7), antiplacebo ap1…ap5, klass/legkij/obshchij/tyazhelyj-itog — success; vorota — skipped
```

CI-шаг: строка 223 в `registry/ci-steps.tsv` содержит `--repo . && --model && --stabs && --catalog && curl shellcheck-v0.11.0 … VALIDATE_STD_SHELLCHECK=… --sintaksis`. Замер `ci-zamery.tsv` — `450 320 0`. Ключ стоит в lane l4 сгенерированной секции.

## Модель угроз и ПРОВОДКА

Модель угроз и НЕ ЗАЩИЩАЕТ в контракте записаны, у каждого остатка назван ловец.

ПРОВОДКА: guard `fixtures/workshop_project/arch_ci_review_223/red_arch_ci_review_223.sh` — барьер именно этого предмета. Он подключён шагом `check:arch-ci-review-223-family-selftest` (l4), `check_provodka.sh . contracts/223-arch-ci-review.md` rc 0.

Строка `ПРОВОДКА-ЭНФОРСМЕНТ` обоснована честно: меняется только классификатор существующей двери, новой поведенческой нормы роли нет.

ОСТАТОК: К-16 — не укусил: `git diff --name-only bcd1de387 c1a83c1ad | grep -cE '^\.(harness|review)/'` = 0. Продуктового содержимого в служебных каталогах дифф не несёт. Мир `status-editing` подтверждает: классификация идёт только по пути, как и записано.
ОСТАТОК: К-03 — не укусил: кодовая дельта production — только функция `:295–300` и строка `:547`. Остальные ноги done (вердикты, freeze/OBJECT, риск, профиль, consumers, проводка, 996) не тронуты. Регресс 224/187/201/205/992/038 зелёный, 116/195 — как на базе.
ОСТАТОК: К-13 — не укусил: подмена Git/PATH/API исключена моделью угроз. Новой аутентификации дифф не вводит.

## Сверки

СВЕРКА-СТАНДАРТОВ: н/п — `AGENTS.md` станции не объявляет `docs/ARCHITECTURE.md`/`docs/CODING-STANDARDS.md` (`grep -nE 'ARCHITECTURE.md|CODING-STANDARDS' AGENTS.md` пуст).

СВЕРКА-АРХИТЕКТУРЫ: н/п по модели 188 — контракт пишет «АРХИТЕКТУРА: н/п — станционный механизм». По существу:
- размещение: функция лежит в единственном файле-потребителе;
- новых зависимостей и писателей нет;
- операции: только чтение `git diff`;
- `bindings.json` дифф не трогает;
- долг не расширен: классификатор задан одной функцией вместо inline-`case`;
- уровень diff модели — L0, решения владельца не требуется.

ПАРАЗИТНАЯ СЛОЖНОСТЬ (050), по пять вопросов на артефакт:
- **`_arch_ci_service_path`** — ESSENTIAL.
  1. Предмет требует «одной функцией/константой», инв. 1.
  2. Состояния нет: аргумент на входе, rc на выходе.
  3. При смене набора служебных путей меняется 1 место плюс комментарии; дифф это число не увеличил.
  4. Интерфейс — 1 аргумент и rc, мелким не стал.
  5. Потребитель — цикл `:547`, мерит его `B --repo`.
- **`context_freeze.py`** — ESSENTIAL.
  1. Приёмка «context.py → rc 0, реальные frozen-источники» и закрытие К-01 Adv223.
  2. Состояние — временные Git-миры в TMPDIR, результат явно в выводе.
  3. Меняется вместе с `context.py`: 2 файла.
  4. Флагов нет.
  5. Потребитель — `B --catalog` в CI-шаге.
- **`SUBJECT` в `context.py`** — ESSENTIAL: одно место исключения собственного предмета; без него rc 1 `CONTRACT_OVERLAPS_INCOMPLETE`.
- **CI-строка и замер** — ESSENTIAL: ПРОВОДКА guard. Грамматика curl-shellcheck взята из 215/226, своей не заводит.
