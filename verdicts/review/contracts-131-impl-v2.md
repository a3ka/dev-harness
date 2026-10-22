accept
---
status: ready
subject: 131 (poezd-bez-dogonyalok) — реализация scripts/publikaciya_main.sh, scoped-ревью круг 2 (фикс Б-1)
object: d0ac745197c04d12d5e8a40ea6bf55e295c9ea69
parent: a58b219c0c55034f8e02f665465d5586ac2c9140
branch: wip/131/implementer
contract: frozen/contracts/131/1 (→ commit d21816fc3)
round1: verdicts/review/contracts-131-impl-v1.md (main 3c32dbb81) — FAIL по Б-1
reviewer: Rev131b (reviewer)
date: 2026-10-22
---

# Ревью 131 impl, круг 2 @ d0ac74519 — accept

Суд ограничен дельтой круга 2 (a58b219c0..d0ac74519). Всё остальное принято в круге 1.
Все замеры сделаны моими командами. Клоны со своим `.git`, remote origin в них удалён, push в origin не делался:
- `/tmp/dev-harness-verify/rev131b-clone` — кандидат d0ac74519;
- `/tmp/dev-harness-verify/rev131b-parent` — родитель a58b219c0, контроль красного.

`.git/*` в отказах не встречался.

## Находки круга 1

- [x] **Б-1 закрыта.** Было `scripts/publikaciya_main.sh:33` `cut -f1 | head -n1`, стало
  `awk -F'\t' '$2 == "refs/heads/main" { print $1; exit }'`. Это та самая простая форма из вердикта круга 1.
  `rmain` пустой → `otkaz 'вершина main на origin не читается'` (строка 34 не менялась).
  - Репро — копии скриптов круга 1 в `/tmp/dev-harness-verify/rev131b/`. Изменены префикс tmp и одно место:
    `repro_nomain.sh` теперь берёт `ci_klass.sh`/`gitw` из того же клона `<C>`, а не из rev131-clone.
    В `repro_lsremote.sh` зелёный дополнительно требует rc=0.
  - (а) `bash repro_lsremote.sh /tmp/dev-harness-verify/rev131b-clone` → EXIT=0:
    `push origin 3dd81ca8…:refs/heads/main`, `ПУБЛИКАЦИЯ: 3dd81ca8… H=6431c7c0… остаётся локально 0`,
    `rc=0 origin-main before=83050bc5… after=3dd81ca8… local-main=3dd81ca8…`, `REPRO: GREEN (published)`.
  - (б) `bash repro_nomain.sh /tmp/dev-harness-verify/rev131b-clone` → EXIT=0:
    `ОТКАЗ публикация: вершина main на origin не читается`, `rc=1`.
    Журнал gitw — одна строка `ls-remote origin refs/heads/main`, push нет.
    На origin только `refs/heads/a/refs/heads/main`. `REPRO: GREEN (refused, no push)`.
  - Красное на родителе a58b219c0 (те же скрипты, клон rev131b-parent):
    - (а) EXIT=1: `ПУБЛИКАЦИЯ: нечего публиковать`, `before=after=c705c6f3…`, `local-main=40de44f9…`, `REPRO: RED`;
    - (б) EXIT=1: `push origin c59cdee2…:refs/heads/main` (`* [new branch] … -> main`), `rc=0`, `REPRO: RED (I-6 violated)`.

    То есть репро различают реализации, и зелёное на кандидате — результат фикса.

## Проверки по пунктам

**1. Репро.** Оба зелёные на кандидате и оба красные на родителе (см. выше).

**2. Батарея** (`fixtures/workshop_project/poezd_131/red_poezd_131.sh`, cwd rev131b-clone):

| seed | --candidate rev131b-clone | --model | --stabs |
|---|---|---|---|
| 1 | rc 0, клеток 24, сошлось 24, расхождений 0 | rc 0, 24/24/0 | rc 0, стабов 22, поймано 22, непойманных 0 |
| 42 | rc 0, 24/24/0 | rc 0, 24/24/0 | rc 0, 22/22/0 |
| 99999 | rc 0, 24/24/0 | rc 0, 24/24/0 | rc 0, 22/22/0 |

- `--cell net-takoj` → rc 2, «НЕЧЕМ СУДИТЬ: нет такой клетки: net-takoj».
  С `--candidate rev131b-clone` — то же, rc 2.
- `--candidate … --cell c01-uchet-hvost --seed 42` → rc 0, «c01-uchet-hvost: СОШЛОСЬ PUSH; клеток 1, сошлось 1».
- Продуктовый режим на HEAD, `--seed 5` → rc 0, «ИТОГ 131 (продукт): клеток 24, сошлось 24, расхождений 0».
- Счёт своей мерой: `len(source.json.cells)=24`, `len(stubs)=22`. Совпадает с ИТОГ.

**3. Зона.**
- `git log a58b219c0..d0ac74519` — один коммит d0ac74519, автор `implementer <implementer@dev-harness.local>`,
  родитель a58b219c0. В subject есть ссылка на предмет (Б-1 ревью 131). Атомарно.
- `git diff --name-status a58b219c0 d0ac74519` → только `M scripts/publikaciya_main.sh`, одна строка (33).
- `git diff --stat a58b219c0 d0ac74519 -- contracts/131-poezd-bez-dogonyalok.md fixtures/workshop_project/poezd_131 scripts/gitw scripts/gitw_preflight_071.sh scripts/ci_klass.sh registry/ci-steps.tsv roles contracts frozen` → пусто, rc 0.
- `git diff --stat frozen/contracts/131/1^{commit} d0ac74519 -- contracts/131-… fixtures/workshop_project/poezd_131` → пусто.
  sha256 от `git ls-tree -r` по этим путям на HEAD равен `6121ff64…3434`. Это то же значение, что на заморозке в круге 1.
- Норма не тронута: в коммите нет roles/ и contracts/. Фикстура и модель не менялись, проверки под код не переписаны.
- `bash -n scripts/publikaciya_main.sh` → rc 0.

**Паразитная сложность (050).** Новых артефактов нет. Изменена одна строка существующего сценария.
- (1) Свойство: И-1 «R — вершина main цели», И-5 и И-6.
- (2) Нового состояния нет.
- (3) Число файлов, которые меняются вместе, не выросло.
- (4) Интерфейс не изменился.
- (5) Потребитель — приёмка §4 и guard ПРОВОДКИ.

ESSENTIAL: прежняя форма не выполняла И-5/И-6.

## Советы (не блок)

- [ ] **С-4. Реализация и модель разошлись.** `diff scripts/publikaciya_main.sh fixtures/…/poezd_131/model/publikaciya_main.sh`
  → rc 1, отличается только строка 33. В модели остался `cut -f1 | head -n1`, то есть дефект Б-1 остался в оракуле.
  Батарея этого не ловит, потому что ни в одном мире нет второго ref-а с хвостом `refs/heads/main`.
  Решение — регресс-клетка и правка модели при v+1 фикстуры (зона architect). Это развитие С-1 круга 1.
- [ ] **С-5. Счётное утверждение в сообщении коммита неточно.** Там написано: «батарея 131 --model/--stabs/--candidate/--cell
  сиды 1/42/99999 — rc 0». Но `--cell net-takoj` даёт rc 2 по замыслу; rc 0 даёт `--cell` только с существующей клеткой.
  «repro_nomain rc 1» — это rc субъекта, а сам репро-скрипт выходит с 0.
  По существу сообщение верно, формулировка неточна.
- С-3 круга 1 (`scripts/gitw_preflight_071.sh:291`, тот же разбор `ls-remote | cut -f1`) остаётся наблюдением
  вне предмета 131.

## Вердикт

accept. Б-1 закрыта. Оба репро круга 1 зелёные на d0ac74519 и красные на a58b219c0.
Батарея на seed 1/42/99999: 24/24 и 22/22, rc 0; `--cell net-takoj` → rc 2.
Дельта — одна строка в зоне implementer, замороженные пути не тронуты.
С-4 и С-5 — советы.

Артефакты: `/tmp/dev-harness-verify/rev131b/{repro_lsremote.sh,repro_nomain.sh,verdict.md}`,
клоны `/tmp/dev-harness-verify/rev131b-{clone,parent}`.
