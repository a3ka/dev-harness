FAIL
---
status: ready
subject: 131 (poezd-bez-dogonyalok) — реализация scripts/publikaciya_main.sh, ревью перед слиянием
object: a58b219c0c55034f8e02f665465d5586ac2c9140
branch: wip/131/implementer
contract: frozen/contracts/131/1 (tag-object c8c39125dbccf4094e9ab55074f08bc6ffa64495 → commit d21816fc3)
reviewer: Rev131 (reviewer)
date: 2026-10-22
---

# Ревью 131 impl v1 @ a58b219c0 — FAIL: 1 блокирующая находка (Б-1)

Все замеры сняты мной в одноразовых клонах `/tmp/dev-harness-verify/rev131-*` (свой `.git`, push не делался).
Отчёт автора и вердикт адверсария не перепроверялись повтором: цифры получены моими командами.
`.git/*` в отказах детекторов не встречался.

## Блокирующие

- [ ] **Б-1. R читается не из `refs/heads/main`: первая строка вывода `ls-remote` вместо строки ref-а `refs/heads/main`.
  Нарушены И-5 и И-6 на конформном входе; в одном из двух проявлений делается push, который контракт запрещает.**
  - Фрагмент: `scripts/publikaciya_main.sh:33` — `rmain="$(printf '%s\n' "$lr_out" | cut -f1 | head -n1)"`.
  - Механизм: `git ls-remote origin refs/heads/main` сравнивает шаблон с ХВОСТОМ имени ref-а по компонентам.
    Поэтому в вывод попадает и ветка вроде `refs/heads/a/refs/heads/main`. Вывод отсортирован по имени, и такая
    ветка идёт ПЕРВОЙ, если её префикс сортируется раньше `main`. Сам эффект проверен отдельно:
    `ls-remote` вернул обе строки, `cut | head` взял sha ветки `a/…`.
  - Источник в контракте: И-1 определяет «R — вершина main цели». И-5 разрешает «нечего публиковать» только при
    R == main. И-6 требует «R не читается» → rc 1 без push. Демаркация: «конформный вход: репозиторий с локальной
    веткой main, remote origin, …»; имена прочих ref-ов на origin не ограничены.
  - Красное, проявление 1. `bash /tmp/dev-harness-verify/rev131/repro_lsremote.sh /tmp/dev-harness-verify/rev131-clone`
    → rc 1. Origin/main отстаёт от локального main на один учётный коммит (HANDOFF.md). Ветка
    `a/refs/heads/main` равна локальному main. Субъект печатает `ПУБЛИКАЦИЯ: нечего публиковать`, rc=0,
    origin main не тронут (`before=e3680622… after=e3680622… local-main=2e29ee0f…`).
    Ожидалось по И-1/И-5: PUSH.
  - Красное, проявление 2. `bash /tmp/dev-harness-verify/rev131/repro_nomain.sh /tmp/dev-harness-verify/rev131-clone`
    → rc 1. На origin НЕТ `refs/heads/main`, есть только `refs/heads/a/refs/heads/main`. Субъект делает
    `push origin 902d0698…:refs/heads/main` (`* [new branch] … -> main`) и печатает `ПУБЛИКАЦИЯ: 902d0698… H=552f7ae4… остаётся локально 0`, rc=0.
    Ожидалось по И-6: `ОТКАЗ публикация: …не читается`, rc 1, push не зовётся.
    Живой предполёт этот push не остановит [INFERENCE по коду]: `scripts/gitw_preflight_071.sh:291` читает вершину тем же
    `ls-remote … refs/heads/main | cut -f1`. В этом мире строка одна, это sha `a/…`, и чек 5
    судит `vorota` против той же ложной вершины.
  - Более простая форма, которая проходит те же строки приёмки (проверено):
    `rmain="$(printf '%s\n' "$lr_out" | awk -F'\t' '$2 == "refs/heads/main" { print $1; exit }')"`
    (клон `/tmp/dev-harness-verify/rev131-fix`, правка одной строки). Результаты: repro_lsremote rc 0
    (`push origin eaceb3a…:refs/heads/main`, `ПУБЛИКАЦИЯ: eaceb3a… остаётся локально 0`); repro_nomain rc 0
    (`ОТКАЗ публикация: вершина main на origin не читается`, rc=1, без push); батарея `--candidate rev131-fix`
    seed 1/42/99999 → rc 0 «клеток 24, сошлось 24, расхождений 0».
  - Батарея этого не ловит: модель `fixtures/…/poezd_131/model/publikaciya_main.sh` несёт ту же строку, и ни в
    одном мире нет второго ref-а с хвостом `refs/heads/main`. Регресс-клетка — решение architect при v+1
    фикстуры (зона architect). Чинить можно только в зоне implementer, rc батареи от этого не меняется.
    Для красного/зелёного прилагаю два скрипта.
  - Класс: дефект корректности по замороженным инвариантам (И-5, И-6). Проявление 2 — обмен, запрещённый И-6.

## Советы (не блок)

- [ ] **С-1. Реализация — побайтовая копия честной модели.**
  `diff scripts/publikaciya_main.sh fixtures/workshop_project/poezd_131/model/publikaciya_main.sh` → rc 0.
  Шапка файла так и говорит: «(контракт 131, честная модель)». Контракт этого не запрещает. Но реализация не
  независима от оракула: все 22 подмены — мутации того же текста, и дефект модели (Б-1) наследуется молча.
  Единственная независимая проверка здесь — ревью кода. Совет: убрать «честная модель» из шапки рабочего сценария.
- [ ] **С-2. Сообщение коммита утверждает «Все инварианты И-1..И-4 соблюдены».** В контракте 7 инвариантов, а Б-1
  нарушает И-5/И-6. Счётное утверждение отчёта не совпадает с контрактом.
- [ ] **С-3 (вне предмета 131, наблюдение владельцу/оркестратору).** У `scripts/gitw_preflight_071.sh:291` тот же
  разбор `ls-remote … refs/heads/main | cut -f1`, только без `head`. При двух совпадениях rmain многострочный,
  при одном чужом — ложный. Это заморожено 071/087/992; правка — отдельным контрактом, не здесь.

## Проверки по пунктам

**1. Область правки.** Diff `frozen/contracts/131/1^{commit}`(d21816fc3)..a58b219c0:
`NABLIUDENIA.md`, `forks/n13x-plan-id.md`, `registry/contracts.tsv` — коммиты orchestrator (eb8cab560, bb41e4c9c,
23df1fb82, 23933834f, 371e0e388), все уже в origin/main. Плюс `scripts/publikaciya_main.sh`.
Коммит implementer один (a58b219c0, автор `implementer <implementer@dev-harness.local>`):
`git diff --name-status HEAD~1 HEAD` → `A scripts/publikaciya_main.sh`, `--stat` 64 вставки. Это ровно ЗОНА implementer.
Замороженные пути: `git diff --stat frozen..HEAD -- contracts/131-poezd-bez-dogonyalok.md fixtures/workshop_project/poezd_131 scripts/gitw scripts/gitw_preflight_071.sh scripts/ci_klass.sh registry/ci-steps.tsv` → пусто, rc 0.
sha256 от `git ls-tree -r` по контракту и фикстуре на заморозке и на HEAD одинаков: `6121ff64…3434`.
`env -i … bash scripts/check_zones.sh` → rc 1, два FAIL; оба не про 131. Первый — грамматика ЗОНА в contracts/055.
Второй — коммит orchestrator 23df1fb8 (REPLACE 122 в registry/contracts.tsv). Оба уже в origin/main
(`merge-base --is-ancestor 23df1fb8 origin/main` → да). Тот же `check_zones.sh` на чистом origin/main 9c8b15be0 (worktree rev131-originmain) даёт те же два FAIL, то есть это базовая линия, а не дельта 131. Коммит implementer среди FAIL не назван.
Атомарность: одна задача — один коммит, предмет назван в subject. Норма не тронута: roles/ и contracts/ в коммите implementer отсутствуют.

**2. Сырой вывод (мои прогоны, клон rev131-clone @ a58b219c0).**
- `--candidate rev131-clone`: seed 1, 42, 99999, 7, 31337, 2026 → каждый rc 0 «ИТОГ 131 (кандидат): клеток 24, сошлось 24, расхождений 0».
  Для seed 1 видны исходы всех 24 клеток: PUSH×17, REFUSE×4 (c05, c08, c11, c12), NOOP (c06), NO_JUDGE (c10), GITW_FAIL (c13).
- `--model`: seed 1, 42, 99999, 7 → rc 0 «клеток 24, сошлось 24, расхождений 0».
- `--stabs`: seed 1, 42, 99999 → rc 0 «стабов 22, поймано 22, непойманных 0».
- Продуктовый режим на HEAD (`--seed 5`) → rc 0 «ИТОГ 131 (продукт): клеток 24, сошлось 24».
- `--cell net-takoj` → rc 2 «НЕЧЕМ СУДИТЬ: нет такой клетки: net-takoj»; с `--candidate` — то же, rc 2.
- Счёт своей мерой: `len(source.json.cells)=24`, `len(stubs)=22`. Совпадает с ИТОГ и с контрактом.

**3. Проверки не переписаны под код.** Коммит implementer не трогает fixtures/ и contracts/ (п.1). Приёмка §4,
негативные пары — на моих мутантах реализации (`/tmp/dev-harness-verify/rev131/mk_mutants.py`), seed 1 и 99999 оба:
- без файла (`rev131-m0-net-fajla`) → rc 1, «клеток 24, сошлось 0, расхождений 24; предмет отсутствует».
  Продуктовый режим этого же дерева, `--seed 7` → rc 1 «ИТОГ 131 (продукт): …; предмет отсутствует» (приёмка §1).
- `--diff-filter=AM` решает служебность (`m5`) → rc 1, «сошлось 20, расхождений 4»: c14, c15, c16, c18;
  `c14-udalenie-koda: РАСХОЖДЕНИЕ GITW,ORIGIN,VYVOD`.
- `rev-list` без `--first-parent` (`m1`) → rc 1, c20 и c21: GITW,ORIGIN,VYVOD.
- `--first-parent --no-merges` (`m2`) → rc 1: c22 (RC,GITW,ORIGIN,VYVOD) и c24.
- сортировка по `%ct` (`m3`) → rc 1 ровно на c23 (GITW,ORIGIN,VYVOD).
- `--max-parents=2` (`m4`) → rc 1 ровно на c24 (GITW,ORIGIN,VYVOD).
- Дополнительно: push вершины вместо P (`m6`) → rc 1 (c02, c03, c04, c09, c14–c17 …: GITW,ORIGIN).
  Проглоченный отказ gitw (`m7`) → rc 1 на c13 (RC).
- Приёмка §6: `pre_critic.sh contracts/131-…` → rc 0 («КРИТИК: дверь зелёная»).
  `check_threat_model.sh . contracts/131-…` → rc 0 (ЗАЩИЩАЕТ 6, НЕ ЗАЩИЩАЕТ 4).

**4. Код против инвариантов (чтение кода + прогоны).**
- Обмен только через соседа `$SELF_DIR/gitw`: ls-remote и единственный `push origin ${P}:refs/heads/main`.
  Прямого `git push`/`fetch` нет. Решение о доказанности — только `ci_klass.sh vorota` (И-3, И-4).
  Путей и subject скрипт не судит.
- Перечисление — `git rev-list --first-parent R..main`, первый rc 0 (И-1). Merge-коммиты линии — кандидаты.
  Боковые родители не перечисляются (c20–c24 и мутанты m1–m4 это подтверждают).
- Локальный main не двигается: ни одной записи ref-ов в скрипте нет. Батарея сверяет LOCAL во всех клетках (И-2).
- rc gitw проносится `exit "$gw_rc"` со строкой `ОТКАЗ публикация: gitw rc=<n> на <P>` (И-3, m7 красный).
- vorota rc ∉ {0,1} на любом кандидате → `НЕЧЕМ СУДИТЬ`, rc 2, без push (И-7).
- Отказы И-6 названы. Но «R не читается» и И-5 нарушаются при неоднозначном выводе ls-remote — **Б-1**.
- `k` = `rev-list --count P..main` (не first-parent) совпадает с оракулом (`poezd_131.py:311`).

**ПРОВОДКА.** `bash scripts/check_provodka.sh . contracts/131-poezd-bez-dogonyalok.md` → rc 1
«guard не подключён: …red_poezd_131.sh не вызывается…». Контракт (§ПРОВОДКА-ЭНФОРСМЕНТ) прямо разрешает это до
интеграционного коммита оркестратора, поэтому это не блок. Guard — батарея именно этого предмета.

**Паразитная сложность (050).** Артефакт `scripts/publikaciya_main.sh`:
(1) свойство — весь предмет 131 (И-1…И-7);
(2) состояния на диске не вводит; входы — вершина origin и локальный main, выход — stdout/stderr и rc 0/1/2/n;
единственный побочный эффект — push через gitw, он виден в выводе;
(3) правка того же свойства меняет вместе 2 файла (сценарий + модель-копия; число задано конструкцией контракта);
(4) интерфейс — ноль аргументов, ноль читаемых env, 4 класса rc, вся работа скрыта внутри: модуль глубокий;
(5) потребитель — приёмка §4 и guard ПРОВОДКИ; грамматику дерева он не дублирует сверх модели, которую
обязывает контракт. ESSENTIAL.

## Вердикт

FAIL по Б-1: дефект корректности И-5/И-6, воспроизведён двумя скриптами, во втором проявлении — запрещённый push.
Исправление — одна строка в зоне implementer (проверенная форма выше). После неё батарея 24/24 на seed 1/42/99999,
оба repro зелёные. Остальное принимается: область правки, сырые прогоны, негативные пары приёмки, прочие инварианты.
С-1…С-3 — советы и наблюдение, не блок.

Артефакты ревью: `/tmp/dev-harness-verify/rev131/{mk_mutants.py,repro_lsremote.sh,repro_nomain.sh}`,
клоны `/tmp/dev-harness-verify/rev131-{clone,fix,m0…m7}`.
