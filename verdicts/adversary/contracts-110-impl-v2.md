FAIL
OBJECT=530e8a4a64087ffb44bab909224b466ee1911657

# Adv110r2: атака на реализацию 110 (scripts/done_wave.sh), круг 2

Судья: adversary (Adv110r2). Предмет: `wip/110/implementer@530e8a4a6` (цепочка b4b7e0674 → c60d3f668 →
8ca324644 → 530e8a4a6). Батарея: `wip/110/architect@32e3f3790` (71 клетка, 50 мутантов). Дерево W
собрано по заданию: archive 9bb5beb30, поверх 32e3f3790 (fixtures/…/done_volny_110 и контракт), поверх
4 файла OBJECT, затем `git init`. Все миры одноразовые, лежат в `/tmp/dev-harness-verify/Adv110r2/worlds`.
Сырые логи в `logs/`. Скрипты: `attack.sh` (круг 1, перенесён без изменений), `attack4.sh`,
`attack5.sh`, `attack6.sh` (круг 2), `decoys.py` (13 заглушек круга 1, D7 переведён на `${HEAD_SHA}:`),
`decoys2.py` (новые заглушки E*), `fixctl.py` (позитивный контроль правки), `frozen_check.py`.

## 0. Приёмка судьи и позитивный контроль (дерево W)

```
bash fixtures/workshop_project/done_volny_110/probe.sh                       → rc 0  «случаев 71, зелёных честных 14/14, отказных с именованной причиной 57/57»
bash scripts/verify_antiplacebo.sh --scope verify_ci_parity check_provodka   → rc 0  «барьеров: 2 · фикстур: 54 · предъявлено красным повторным прогоном: 54»
bash scripts/gen_ci_steps.sh --check                                         → rc 0
bash scripts/verify_ci_parity.sh                                             → rc 0  «расхождений: 0»
bash fixtures/workshop_project/done_volny_110/provodka.sh                    → rc 0
bash scripts/check_provodka.sh . contracts/110-done-volny.md                 → rc 0
git -C <main> diff --exit-code frozen/contracts/110/1 32e3f3790 -- contracts/110-done-volny.md  → rc 0
git -C <main> diff --exit-code frozen/contracts/110/1 530e8a4a6 -- contracts/110-done-volny.md  → rc 0
git show frozen/contracts/110/1:contracts/110-done-volny.md | cmp - W/contracts/110-done-volny.md → rc 0
python3 frozen_check.py  → «замороженных клеток 52 | клеток круга 2 71 | изменены/пропали замороженные: [] | добавлено: 19»
                           (AST-сегмент каждой клетки frozen побайтно равен сегменту в 32e3f3790)
```
bash fixtures/workshop_project/done_volny_110/probe.sh --matrix → rc 0, mismatches=0 (319 с; последние строки: ma4_tag_cleanup_strip → a4_tag_owner_line_hash, mb1_tag_on_moved_head → b1_head_pinned_tag)

## 1. Закрыто на деле (replay `attack.sh` круга 1 на новой двери; `logs/attack_impl.log`)

| # | Мир | Круг 1 | Круг 2 (530e8a4a6) |
|---|---|---|---|
| A1 | HEAD:e2e.sh `exit 1`, в рабочем дереве `exit 0` | rc 0 v1 | **rc 1** «рабочее дерево расходится с HEAD: e2e.sh (не HEAD-источник)», refs без изменений |
| A1b | nfr.sh: HEAD 500, в дереве 95 | rc 0 v1 | **rc 1** «… nfr.sh …» |
| A2 | HEAD-профиль → .harness/ledger (112), `rm harness.project.json` в дереве | rc 0 v1 | **rc 1** «профиль проекта расходится с HEAD: harness.project.json» |
| A3 | корень = `sub/` | rc 0, тег в верхнем репо | **rc 1** «корень не корень репозитория» |
| A4 | `повторный…⏎# РАЗРЕШИЛ-ВЛАДЕЛЕЦ: да` | строку владельца срезал cleanup | **rc 0 v2**, аннотация `повторный приём волны 3\|# РАЗРЕШИЛ-ВЛАДЕЛЕЦ: да\|`; `# пусто` → **rc 1** «причина пуста (только комментарные строки)» |
| A5/Б1 | e2e делает коммит | тег на новом коммите | peeled(done/waves/3/1) = HEAD до вызова (a8209d57…); то же для e2e, правящего план (N9) |
| Б2 | шапка | нет классификации | `# НЕ БАРЬЕР:` на :19-21, scoped antiplacebo rc 0 |

Тринадцать заглушек круга 1 (`python3 decoys.py`, `logs/decoys.log`): усиленная проба краснеет на
**каждой**: D2 → d2_e2e_cache_head; D3 → d3_nfr_first_match_wins; D7 → d7_review_absent_on_head;
D12 → d12_closure_exact_id; D13 → d13_status_trailing_dot; D14 → d14_status_uppercase;
D15 → d15_otkat_field_anchor; D16 → d16_otkat_empty_value; D22 → d22_e2e_rc2 и d29_commands_in_root;
D23 → d23_nfr_rc1; D25 → d25_valve_v3; D29 → b1_head_pinned_tag, d2_e2e_cache_head, d29_commands_in_root;
D31 → d31_nfr_ops_per_row. Везде probe rc 1.

## 2. БЛОКИРУЕТ: новые обходы, при которых проба зелёная (71/71), а тег ставится неверно

### N2. Проверка грязи срабатывает вслепую: упавший `git status` читается как «дерево чисто»
`scripts/done_wave.sh:177-178`: `DIRTY="$(git … status --porcelain --untracked-files=no 2>/dev/null | awk …)"`.
Код возврата git теряется в конвейере внутри `$(…)`, и ни `|| die`, ни `PIPESTATUS` его не проверяют.
**Обход** (`bash attack4.sh <door> corrupt_index`): HEAD:e2e.sh = `exit 1`, в рабочем дереве `exit 0`
(мир A1), плюс `printf garbage > .git/index`. Тогда `git status` → «fatal: .git/index: index file
smaller than expected», rc 128, а дверь → **rc 0 v1**: тег `done/waves/3/1` → HEAD с красным e2e.
cat-file, for-each-ref и tag индекс не читают, поэтому ни одна другая проверка двери не падает.
Эталон здесь закрыт (`git diff --quiet "$HEAD_SHA"` → rc 128 → «рабочее дерево расходится с HEAD»,
rc 1). Слабее модели только дверь.

### N11b. Охрана профиля привязана к зашитому имени `project-layer.json`, а не к файлу слоя, который читает резолвер
`:56` `PROFILE_FILES=("harness.project.json" "project-layer.json")`. Резолвер берёт слой из
`${HARNESS_PROJECT_LAYER_ROOT:-корень}/<projectLayer.profilePath>`. По умолчанию это
`registry/harness-project.json` (scripts/profile_resolver.sh:7,212). Именно этот путь использует
сам харнесс: в `harness.project.json` дерева стоит `registry/harness-project.json`, а файла с именем
`project-layer.json` в git нет. **Обход** (`bash attack6.sh`): репо-слой на HEAD без workflowPaths,
`profilePath: layer/p.json`, файла слоя на HEAD нет. В рабочем дереве лежит неотслеживаемый
`layer/p.json` с registry = корневой деко (волна 3 = {111}). Профильный реестр `.harness/ledger`
содержит 112 без done. Итог: **rc 0 v1, тег поставлен.** На HEAD профиль не разрешается вообще.
Контроль N11a (тот же слой закоммичен) → rc 1 «112 (нет done-тега)». Контроль N11c (слой назван
`project-layer.json`) → rc 1 «профиль проекта не на HEAD: project-layer.json». Это класс A2: профиль
из рабочего дерева подменяет реестр. Закрыт он только для одного имени файла.
Грязная проверка этот обход не ловит: она идёт с `--untracked-files=no`.

**Позитивный контроль правки** (`python3 fixctl.py` → дерево FIX): правок две.
(1) `DIRTY_RAW="$(git status …)" || die "рабочее дерево не читается: git status"`.
(2) Путь слоя берётся из HEAD-блоба `harness.project.json`
(`.projectLayer.profilePath // "registry/harness-project.json"`), и для него проверяется «на HEAD».
Результат: `probe.sh` на FIX → **rc 0, 71/71**. N2 → rc 1 «рабочее дерево не читается: git status».
N11b → rc 1 «профиль проекта не на HEAD: layer/p.json». control → rc 0 v1, A2 → rc 1. Значит, обе
правки в зоне implementer батарею не ломают. При этом проба одинаково зелёная на двери с обходом и
на исправленной: она этих свойств не различает (см. §3).

### N1. A1 закрыт только для ОТСЛЕЖИВАЕМОЙ правки: исполняемый код, которого нет на HEAD, проходит
**Обход** (`bash attack4.sh <door> untracked_e2e`): манифест `e2e bash e2e.sh`, файла e2e.sh на HEAD нет
(«exists on disk, but not in 'HEAD'»), в дереве он неотслеживаемый с `exit 0`. `status --porcelain
--untracked-files=no` пуст, дверь → **rc 0 v1**. Тот же e2e на экспорте HEAD (`git archive HEAD`) даёт
`bash: e2e.sh: No such file or directory`, rc 127. Варианты дают тот же исход: N1c (nfr.sh в
`.gitignore`, rc 0 v1) и N1d (закоммиченный чистый e2e.sh делает `. ./helper.sh`, helper.sh снят с HEAD
коммитом, а в дереве лежит неотслеживаемым; rc 0 v1). Это ровно предикат клетки a1 «e2e-код зелёный
только в рабочем дереве (на HEAD красный)». Отличие одно: файл забыли `git add`, а не правили.
Эталон слеп так же: на N1 он даёт rc 0 v1.
**Адресат — architect, не только implementer.** Клетка d2_e2e_cache_head (ok-клетка, probe.py:507-513)
кладёт неотслеживаемый `flag` в корень как законный вход e2e. Заглушка E7 (`--untracked-files=all`)
краснеет именно на ней (`logs/decoys2.log`). Поэтому «отказ на любом неотслеживаемом» батарею ломает,
а «исполнять команды на экспорте HEAD» ломает d2. Норма-строка 996/1 (sourceCanon): тег волны
утверждает «HEAD прошёл сквозной запуск», и правило H ради этого распространено на код (A1). Карта
пропускает канал «неотслеживаемый код». Наблюдаемый контрпример — N1. В моём D2 круга 1 флаг лежал
ВНЕ корня (`$r.flag`). Перенос флага клетки d2 за пределы корня снял бы конфликт.

## 3. Дыры батареи (адресат architect): заглушки новых поверхностей, против которых проба зелёная

Каждая заглушка — мутант двери 530e8a4a6, установленный как scripts/done_wave.sh (`python3 decoys2.py`,
`logs/decoys2.log`). На своём мире каждая ошибается, честная дверь отвечает верно (`bash attack5.sh`,
`logs/attack5.log`).

| Заглушка | probe | Мир | честная | заглушка |
|---|---|---|---|---|
| E1 грязь только worktree-vs-index (`git diff --name-only`) | **rc 0, 71/71** | HEAD:e2e.sh exit 1, зелёная версия `git add`, не закоммичена | rc 1 «расходится с HEAD: e2e.sh» | **rc 0 v1** |
| E3 охрана профиля только `harness.project.json` | **rc 0** | слой project-layer.json не на HEAD, в дереве неотслеживаемый → деко-реестр | rc 1 «не на HEAD: project-layer.json» | **rc 0 v1** |
| E4 нет отказа «причина из одних комментариев» | **rc 0** | причина `# пусто` | rc 1 «причина пуста (только комментарные строки)» | **rc 0 v1**, аннотация `# пусто` |
| E5 топлевел против логического `pwd -L` | **rc 0** | честный мир, корень передан через симлинк | rc 0 v1 | **rc 1** «корень не корень репозитория» |
| E6 «корень» = есть каталог `.git` | **rc 0** | честный мир в linked worktree (`.git`-файл) | rc 0 v1 | **rc 1** «корень не корень репозитория» |
| E10 исключение грязи по префиксу `$REG_REL/` | **rc 0** | `e2e bash registry/e2e.sh`, HEAD exit 1, дерево exit 0 | rc 1 «расходится с HEAD: registry/e2e.sh» | **rc 0 v1** |
| E11 проверка грязи ПОСЛЕ NFR/e2e (порядок до 8ca324644) | **rc 0** | e2e.sh в дереве `git checkout -- e2e.sh; exit 0`, на HEAD exit 1 | rc 1 «расходится с HEAD: e2e.sh» | **rc 0 v1** |
| E7 неотслеживаемое = грязь | rc 1 (d2_e2e_cache_head) | — | — | — |
| E8 `--cleanup=strip` | rc 1 (a4_tag_owner_line_hash) | — | — | — |
| E9 тег на живой HEAD | rc 1 (b1_head_pinned_tag) | — | — | — |

Плюс две двери из §2 (N2 и N11b): проба зелёная и на исправленной FIX, и на OBJECT. Клеток
«git status падает» и «слой профиля не на HEAD по фактическому profilePath» нет. Нейтрализующий
контроль: E8, E9 и все 13 заглушек круга 1 пробу роняют. Значит, проба гоняет именно подложенную дверь.

## 4. Советы (не блокируют)

- N3 (`awk '{print $2}'` по porcelain v1). git выводит в кавычках пути с не-ASCII (core.quotePath=true,
  а глобальный конфиг дверь обнуляет) и с пробелами. Отсюда две беды. (а) HEAD-источник с кириллическим
  именем (`docs/откат.md`) или с пробелом (`.review/volna 2.md`), правленный в дереве, отклоняется:
  «рабочее дерево расходится с HEAD: \"docs/\320\276…\" (не HEAD-источник)». Тот же мир с ASCII-именем
  (`docs/otkat.md`) даёт rc 0 v1 (N3a/N3b/N3c). Поведение зависит от алфавита имени, а в причине
  отказа путь искажён. (б) Пути разбиваются по пробелам. Обхода это не даёт (N3d: «docs/otkat.md x/e2e.sh»
  → rc 1), но держится на случайности. Лечение: `status --porcelain=v1 -z --no-renames`, путь = `${ln:3}`.
  Позитивный контроль (дерево FIXZ = FIX + `-z`): probe → rc 0, 71/71; N3b → rc 0 v1, N3c → rc 0 v1;
  N3d → rc 1 с неискажённым путём «docs/otkat.md x/e2e.sh»; N2 → rc 1.
- N4: дверь (в отличие от модели) освобождает HEAD-источники от проверки грязи. e2e, который читает
  источник (`! grep -q BROKEN registry/closed-without-done.tsv`), видит версию дерева: на HEAD там BROKEN,
  дерево исправлено → rc 0 v1. Модель на таком мире отказывает: у неё `git diff --quiet HEAD_SHA` по
  всему дереву, на N3a она тоже даёт rc 1. Эталон и предмет расходятся, клетки на это нет.
- N2b: `git update-index --skip-worktree e2e.sh` прячет правку → rc 0 v1. Нужно действие оператора.
- N12: `HARNESS_PROJECT_LAYER_ROOT=<внешний каталог>` в среде вызывающего подменяет слой. HEAD-слой
  указывает на `.harness/ledger` (112), внешний слой — на корневой деко → rc 0 v1, без env → rc 1.
  По 996 это законный канал (odelix-stack), но тег волны от него зависит, а в аннотации это не отражено.
- N10: NFR-команда может переписать отслеживаемый e2e.sh после проверки грязи → rc 0 v1. Это злонамеренный
  манифест, вне модели угроз.
- Без изменений с круга 1: A6 (status из тела находки), A7 (закрытие без причины), A8 (`#review`
  молча пропускается), A12 (захват `.` → rc 0). A9 (тег `done/waves/3/08`) по-прежнему роняет bash:
  `:243: 08: value too great for base`, `v: unbound variable`, rc 1 вместо именованного отказа.
- Шапка `:20` говорит «52 случая + 31 мутант», а батарея уже 71/50.

## Итог

FAIL. A1–A4, Б1 и Б2 на мирах круга 1 закрыты на деле, все 13 заглушек круга 1 проба ловит. Блокеры:
(1) N2 — проверка грязи срабатывает вслепую при падении `git status`. Обход наблюдаем, эталон тут
строже двери, правка в зоне implementer, позитивный контроль 71/71.
(2) N11b — охрана A2 стоит на зашитом имени, а не на фактическом файле слоя. Обход наблюдаем, правка в
зоне implementer, позитивный контроль 71/71.
(3) N1 — канал «неотслеживаемый исполняемый код» A1 оставляет открытым. Чтобы его закрыть, нужно
решение architect по клетке d2.
Батарея (architect): 7 заглушек новых поверхностей (E1, E3, E4, E5, E6, E10, E11) и обе двери N2/N11b
проходят пробу зелёными.
