accept

# Ревьюер 057 — консолидация кругов 1–2: батарея 054 честный измеритель + Б3

## Круг 2 — закрытие Б-1 (m1–m6 / п.5 / п.5б)

Мандат круга 2: судится ТОЛЬКО закрытие Б-1 круга 1; прочее круга 1 не
пересуживается (закрыто там же, ниже без изменений). Предмет: `748f617`
(implementer, «клетки m1-m6»), слито `6fd291b`; `09ba1f5` (orchestrator,
перенос ключа ci.yml ap3→ap5). Судился одноразовый SSH-клон `origin/main` =
`09ba1f5` в `/tmp/dev-harness-verify/rev057k2`; мутанты — в отдельных клонах
`r057k2-brr`, `r057k2-brr2`, проба якоря — `r057k2-anc`. Основной checkout —
только чтение. Прогоны батарей последовательные (С-2 круга 1: b11m вероятностна
под нагрузкой).

### Красный вход: `.git/config` основного чекаута

```text
до:        ee1444766dcd4467db3622d64fb78505aacf55ea130e7fa18cacf1e3b6ce0f09
середина:  ee1444766dcd4467db3622d64fb78505aacf55ea130e7fa18cacf1e3b6ce0f09  (HEAD 09ba1f5, porcelain 0)
после:     ee1444766dcd4467db3622d64fb78505aacf55ea130e7fa18cacf1e3b6ce0f09  (перед коммитом вердикта; HEAD 09ba1f5, porcelain 0)
```

### (а) Батарея на честном дереве: rc 0, 36 клеток

```text
$ bash fixtures/_krasnye_054.sh 2>&1 | tee k2-honest.log | grep …; echo RC=${PIPESTATUS[0]}
b11h: ok=72 refused=56 leak=0 (RACE_N=128)
b11m: ok=65 refused=54 leak=9 (RACE_N=128, мутант check-then-open)
СВЕРКА: m1 … СВЕРКА: m6
m6: честный rc=0 листовое слияние; мутант rc=0 barriers.optional потерян (различение работает)
честная часть: проверено предъявлений 36
итог 054: rc=0
RC=0
```

Своя мера (другие команды того же лога): `grep -c '^СВЕРКА: '` = 36,
`sort -u | wc -l` = 36 (дубликатов нет), `grep -cE '^СВЕРКА: m[1-6]$'` = 6;
python-подсчёт `startswith('СВЕРКА: ')` = 36, `стаб пойман:` = 20; литеральный
`HONEST_CELLS` = 7+9+6+1+1+3+3+6 = 36. Печатное N=36 = C=36.

### (а) Мутант замещения ветви: КРАСНЫЙ на m6, ЗЕЛЁНЫЙ на A/G/F/C/M

Два независимых мутанта `scripts/profile_resolver.sh` (оба — семантика
контрмодели критика 057-v1:24–29 «есть объект `barriers` в репо → ветвь
замещена целиком»):

```diff
# brr — мой мутант круга 1 (строка 553), тот, что круг 1 пропускал
-        elif $p.defaults and $p.defaults.barriers and $p.defaults.barriers.optional != null then …
+        elif ($r.barriers|not) and $p.defaults and $p.defaults.barriers and $p.defaults.barriers.optional != null then …
# brr2 — полное замещение ветви (строки 547, 552)
-        if $r.barriers and $r.barriers.mandatory != null then { value: $r.barriers.mandatory, origin: "repo" }
+        if $r.barriers != null then { value: $r.barriers.mandatory, origin: "repo" }
-        if $r.barriers and $r.barriers.optional != null then { value: $r.barriers.optional, origin: "repo" }
+        if $r.barriers != null then { value: $r.barriers.optional, origin: "repo" }
```

Батарея (раннер) против мутантов — m1..m5 исполнены и зелёны (диспетчер валит
на ПЕРВОЙ красной, m6 — последняя в списке), m6 красная с причиной `barriers.optional`:

```text
== brr
b11h: ok=74 refused=54 leak=0 (RACE_N=128)
b11m: ok=59 refused=57 leak=12 (RACE_N=128, мутант check-then-open)
СВЕРКА: m1 … СВЕРКА: m5, СВЕРКА: m6
m6: честный barriers.optional.origin != project
054-батарея ОТКАЗ: ЧЕСТНАЯ ЧАСТЬ: клетка m6 красная
итог 054: rc=1
brr_RUNNER_RC=1
== brr2
b11h: ok=71 refused=57 leak=0 (RACE_N=128)
b11m: ok=55 refused=58 leak=15 (RACE_N=128, мутант check-then-open)
СВЕРКА: m1 … СВЕРКА: m5, СВЕРКА: m6   (grep -c '^СВЕРКА: ' = 36)
m6: честный barriers.optional.origin != project
054-батарея ОТКАЗ: ЧЕСТНАЯ ЧАСТЬ: клетка m6 красная
итог 054: rc=1
brr2_RUNNER_RC=1
```

Независимая мера (моя toy-проба `k2-forms.sh`, НЕ код батареи; те же шесть форм
Ч-1, резолвер вызывается напрямую):

```text
== честный
A rc=0 barriers={mandatory:{check_zones,project},optional:{check_metering,project}} cmd.test.origin=project
G rc=0 barriers={mandatory:{check_zones,project},optional:{check_metering,project}} cmd.test.origin=repo
F rc=0 barriers={mandatory:{check_no_leak,repo},optional:{check_metering,repo}}     cmd.test.origin=project
C rc=0 barriers={mandatory:{check_no_leak,repo},optional:{check_metering,repo}}     cmd.test.origin=repo
M rc=0 barriers={} cmd.test.origin=-
P rc=0 barriers={mandatory:{check_no_leak,repo},optional:{check_metering,project}}  cmd.test.origin=project
== brr   A/G/F/C/M — байт-в-байт как честный; P rc=0 barriers={"mandatory":{"value":["check_no_leak"],"origin":"repo"}}
== brr2  A/G/F/C/M — байт-в-байт как честный; P rc=0 barriers={…mandatory…,"optional":{"origin":"repo"}}
```

То есть мутант на A/G/F/C/M от честного неотличим (п.5б «зелёен на A/G/F/C/M»),
на P теряет `barriers.optional` — и именно клетка m6 это ловит.

Заякоренность самопробы m6 (п.5б «патч не применился → клетка красная
именованно»), изолированный прогон `cell_m6` (функции извлечены из батареи):

```text
честный резолвер                       → m6: честный rc=0 листовое слияние; мутант rc=0 barriers.optional потерян  M6_RC=0
дрейф текста ветви ($r.barriers)→(…)   → ANCHOR MISMATCH: orig_block not found verbatim
  (семантика честная)                    m6: КРАСНАЯ — патч не применился: anchored barriers-блок не найден     M6_RC=1
brr                                    → m6: честный barriers.optional.origin != project                        M6_RC=1
brr2                                   → m6: честный barriers.optional.origin != project                        M6_RC=1
```

### (б) frozen-diff пуст

```text
$ git diff --name-only 939dc64 HEAD -- contracts/ frozen/ AGENTS.md roles/ | wc -l   → 0
$ git diff --quiet frozen/contracts/057/1 HEAD -- contracts/057-…md; echo $?        → 0
$ git diff --name-only 7c7b559 HEAD → .github/workflows/ci.yml, fixtures/workshop_project/red_profil_dva_sloja.sh
```

### (г) scoped profile_resolver 9/9

```text
$ bash scripts/verify_antiplacebo.sh --scope profile_resolver 2>&1 | tee k2-scoped.log; echo AP_RC=${PIPESTATUS[0]}
SCOPED: барьеров 1 из выборки — не для приёмки
  ok   profile_resolver/case_defaults_vne_alfavita.sh … «значение вне алфавита: defaults.barriers.mandatory»
  ok   profile_resolver/case_fail_ne_json.sh … «файл не JSON»
  ok   profile_resolver/case_neizvestnyj_kljuch_repo_sloja.sh … «неизвестный ключ репо-слой: workflowPaths.contrete»
  ok   profile_resolver/case_neizvestnyj_kljuch_sloja_proekta.sh … «неизвестный ключ слой-проекта: boguskey»
  ok   profile_resolver/case_net_fajla_repo_sloja.sh … «нет harness.project.json»
  ok   profile_resolver/case_net_fajla_sloja_proekta.sh … «нет файла слоя проекта»
  ok   profile_resolver/case_rashozhdenie_pina_sloja.sh … «пин слоя проекта расходится»
  ok   profile_resolver/case_vneshnij_symlink_repo_sloja.sh … «не symlink на внешний файл»
  ok   profile_resolver/case_znachenie_vne_alfavita.sh … «значение вне алфавита: language»
барьеров: 1 · фикстур: 9 · предъявлено красным повторным прогоном: 9
AP_RC=0
своя мера: grep -cE '^\s+ok\s' лога = 9; git ls-files fixtures/profile_resolver | wc -l = 9
```

### Семь пунктов роли — только дельта круга 2

1. **Область.** `748f617` — один файл `red_profil_dva_sloja.sh` (ЗОНА implementer,
   ПЕРЕСЕЧЕНИЕ «правится ТОЛЬКО файл red_profil_dva_sloja.sh»); резолвер не тронут. PASS.
2. **Сырой вывод.** Коммит приводит приёмку с rc; повторено мной выше. PASS.
3. **Проверка под реализацию.** Автор дописал клетки в своей зоне; клетки
   круга 1 не ослаблены (diff — только вставки + одна строка диспетчера). PASS.
4. **Красное предъявлено.** m6 красна на двух мутантах замещения ветви и на
   дрейфе якоря; m1–m5 — позитивные формы п.5, красная для них п.5б не
   требует (мутант обязан быть на них зелёным — и зелён). PASS.
5. **Атомарность.** Один коммит, одна задача 057, ссылка на предмет. PASS.
6. **Норма.** frozen-diff пуст (б). PASS.
7. **Счётные утверждения.** «36 предъявлений» — своей мерой 36 (grep -c,
   sort -u, python, литеральный список); «9/9» — см. (г). PASS.

### Паразитная сложность (050) — новые артефакты `748f617`

| Артефакт | (1) свойство | (2) состояние | (3) совместная правка | (4) глубина | (5) потребитель / повтор | Класс |
|---|---|---|---|---|---|---|
| `cell_m1`..`cell_m5` (семья) | Ч-1, п.5 | `$WORK/mN-{r,layer}`, явное | JSON слоя с `defaults` повторён дословно в m1/m2/m3/m6, 5 блоков из пяти `jq -r … origin` — правка схемы слоя = 4–6 мест в одном файле | интерфейс 1 арг, работа — 1 прогон + 5 сверок; мелкие копии | п.5 батареи; повторяют друг друга | ACCIDENTAL (совет): проще — одна `cell_form <тег> <repo_json> <layer_json> <путь=origin…>`; отсутствующего свойства нет → не блокирует |
| `cell_m6` (+ встроенный python-патч) | Ч-1, п.5б | `$WORK/m6-*`, копия `m6-mutated.sh`; причина печатается | 1 файл; якорь дублирует 12 строк ветви резолвера — правка ветви = 2 места, но это требование п.5б (анкер, прецедент Ч-5) | ок | п.5б | ESSENTIAL. Совет: `grep -qF` пред-проверка трёх подстрок дублирует `orig_block not in src` (тот же совет, что b11m круга 1); сообщение ветви «совпал … это невозможно; проверь якорь» путано |
| `_setup_form_repo` | фикстуры п.5 | нет | 1 | ок | m1–m6 | ESSENTIAL. Совет: `git config receive.denyCurrentBranch refuse` резолверу не нужна |
| m1–m5 через `cell_resolver_run` | Ч-6 | нет | 3 места на форму (список, `dispatch_honest_cell`, `cell_resolver_run`) против 2 у m6 | двухуровневый диспетчер с `*) return 0` на втором уровне (совет С круга 1) | — | ACCIDENTAL (совет): прямой `m[1-5]) cell_$cell "$PROFILE_RESOLVER"` в `dispatch_honest_cell`, как m6 |
| ключ `profile_resolver` ap3→ap5 (`09ba1f5`) | Ч-10 | нет | 1 | ок | CI | см. «Вопрос владельцу» |

### Вопрос владельцу (не FAIL, вне мандата круга 2)

`09ba1f5` (orchestrator) перенёс `profile_resolver` из `keys` шарда ap3 в ap5
по таймауту ap3. Замороженные Ч-10 (строка 188) и ПЕРЕСЕЧЕНИЕ ci.yml (строки
256–257) называют буквально «шард ap3». Свойство Ч-10 «CI исполняет клетки»
сохранено (ключ один, в ap5; ci.yml:69), но буква контракта разошлась с деревом, и правку
внёс не implementer. Мандат круга 2 — закрытие m1–m6, поэтому не судится;
владельцу — принять как операционную правку матрицы или оформить.

Наблюдение: m6 исполняется только батареей 054 (судейская, Граница-3), не CI —
`krasnye_054|red_profil` по `.github/`, `package.json`, `fixtures/profile_resolver/`
ноль попаданий. П.5б требует клетку батареи, не CI-ключ — не FAIL.

### Итог круга 2

accept — Б-1 закрыт: клетки m1–m6 существуют и исполняются (36 предъявлений,
N=C), мутант замещения ветви `barriers` (два варианта) красен на m6 с
причиной `barriers.optional` и зелен на A/G/F/C/M, дрейф якоря красен
именованно; frozen-diff пуст; scoped profile_resolver 9/9; `.git/config`
основного без изменений. Блокеров нет; советы выше не блокируют.

---

## Круг 1 (сохранён; блокер Б-1 закрыт кругом 2)

Вердикт круга 1 (блоб 7c7b559): FAIL

#### Ревьюер 057 — круг 1: батарея 054 честный измеритель + Б3

Судился одноразовый SSH-клон `origin/main` = `9cd6bf2` в
`/tmp/dev-harness-verify/rev057`; мутанты — в отдельных свежих SSH-клонах
`/tmp/dev-harness-verify/r057-{cto,lit,unk,brr}`. Основной checkout не правился
(только чтение); вердикт — единственная запись. Предмет: `34d0c06` (M1+M3) +
`8430ce1` (M2+M4), слито `252b4f7`/`bebea3c`. Оракул — замороженный блоб
`frozen/contracts/057/1` (tag-object `eba0f818…` → commit `939dc64`,
блоб контракта `8b934a4c…` = HEAD-блоб).

### Красный вход: `.git/config`

```text
до:    ee1444766dcd4467db3622d64fb78505aacf55ea130e7fa18cacf1e3b6ce0f09  (основной)
после: ee1444766dcd4467db3622d64fb78505aacf55ea130e7fa18cacf1e3b6ce0f09  (основной, перед коммитом вердикта)
```

### Блокеры

#### Б-1 (FAIL, класс: заявленное ≠ сделанному / зелёное без красного) — клеток m1–m6 нет, мутант замещения ветви `barriers` зелёный в батарее И в CI

Обязательства frozen 057: Ч-1 («мутант … на P теряет `barriers.optional` —
краснеет клеткой m6 (п.5/п.5б)»), приёмка п.5 («фикстуры m1–m6 честной
части»), п.5б («клетка m6 (форма P) против мутанта; тогда rc 1»), Модель угроз
(«замещение ветви вместо слияния краснеет (Ч-1/п.5б)»).

Фрагмент результата: `HONEST_CELLS` в `red_profil_dva_sloja.sh` (строки
~1151–1168) — `k1 … b10 b11h b11m b5 b6 b8 b4 k10 k10b`, ни одной клетки m*;
`grep -E '\bm[1-6]\b|форм[аы] P|cell_m'` по `fixtures/` — ноль попаданий в
батарее 054 и в `fixtures/profile_resolver/`. Зелёные контроли case-семьи —
формы M/A/G/F/C/«полный», формы P нет; раннер case-канала судит только rc.

Мутант (одна строка, `scripts/profile_resolver.sh:553`, свежий клон
`r057-brr`):

```diff
-        elif $p.defaults and $p.defaults.barriers and $p.defaults.barriers.optional != null then …
+        elif ($r.barriers|not) and $p.defaults and $p.defaults.barriers and $p.defaults.barriers.optional != null then …
```

Мутант живой — независимая toy-проба (`r057-forms.sh`) различает его на форме P:

```text
честный: P rc=0 OK  | barriers={"mandatory":{"value":["check_no_leak"],"origin":"repo"},"optional":{"value":["check_metering"],"origin":"project"}}
мутант:  P rc=0 BAD | barriers={"mandatory":{"value":["check_no_leak"],"origin":"repo"}}
```

Батарея и CI-канал этого мутанта НЕ ловят:

```text
== brr: bash fixtures/_krasnye_054.sh; bash scripts/verify_antiplacebo.sh --scope profile_resolver
b11h: ok=71 refused=57 leak=0 (RACE_N=128)
b11m: ok=64 refused=55 leak=9 (RACE_N=128, мутант check-then-open)
честная часть: проверено предъявлений 30
итог 054: rc=0
BRR_RUNNER_RC=0
барьеров: 1 · фикстур: 9 · предъявлено красным повторным прогоном: 9
BRR_AP_RC=0
```

Вывод: блокер критика 057-v1:16–33, ради которого форма P введена во второй
круг и за который критик принял контракт (`939dc64`), в реализации не закрыт —
механизм, который его различает, отсутствует. Отдельная реализация m1–m6 в
семье не отражена и в отчёте коммита `8430ce1` (перечислены M2/M4, п.5/п.5б
не упомянуты).

**Оговорка (m1–m6 — предмет или совет).** Предмет. §Зоны frozen 057/1 отдаёт
implementer'у `fixtures/workshop_project/red_profil_dva_sloja.sh`; Ч-1 (М1) и
п.5/п.5б §Зелёное ПОСЛЕ («исполняет implementer») называют клетки m1–m6/m6
буквально; §Покрытие: «Б3→п.5/п.5б/п.6». Ни РАБОТА НЕ РАЗДАЁТСЯ, ни Граница-3
(вынос гонки из case-канала) m-клетки не исключают. Это не новая мера судьи —
обязательство заморожено.

Более простая проходящая форма: `cell_m1..m6` (или одна параметризованная
`cell_forms` с шестью СВЕРКА-событиями) в `HONEST_CELLS` + дифф-проба п.5б по
прецеденту `cell_b11m` (заякоренная правка строки `optional` ветви слияния;
якорь не найден → красная именованно).

### Что закрыто (прогнано мной)

| Предмет | Команда (клон `rev057`) | Наблюдение |
|---|---|---|
| п.1 Б2 позитив | `bash fixtures/_krasnye_054.sh > log; echo RC=$?` | `RC=0`, `итог 054: rc=0`, `стаб-пак: просмотрено 20, поймано 20` |
| п.1б внешняя мера | `sed …проверено предъявлений…` vs `grep -c '^СВЕРКА: '` | `N=30 C=30`, `P1B_RC=0`; своей мерой: `grep -c '^стаб пойман: '` = 20, дубликатов СВЕРКА 0 |
| п.3 честная гонка | тот же лог | `b11h: ok=64 refused=64 leak=0 (RACE_N=128)` |
| Ч-5 дифф-проба | тот же лог | `b11m: ok=70 refused=46 leak=12 (RACE_N=128, мутант check-then-open)` |
| п.5 формы A/G/F/C/M/P | `r057-forms.sh scripts/profile_resolver.sh` | все rc=0; A/G barriers origin project; F origin repo, commands project; P mandatory repo + optional project со значениями; C все ветвевые листы repo (projectId/workspaceId/schemaVersion/packs — project: поля слоя проекта, не ветви репо); M `barriers={}`, `commands={}` — листьев нет, не null |
| п.6 Ч-2 | toy: `defaults.barriers.mandatory=["BAD KEY!"]` | rc=1 `profile ОТКАЗ: значение вне алфавита: defaults.barriers.mandatory: BAD KEY!` |
| п.7 Ч-3 P4 | toy к4/к4б | rc=1 `…неизвестный ключ репо-слой: workflowPaths.contrete`; rc=1 `…неизвестный ключ слой-проекта: boguskey`; frozen 054 строка 211 `P4 = profile ОТКАЗ: неизвестный ключ <репо-слой|слой-проекта>: …` — совпадает |
| п.8 Б4 | `bash scripts/verify_antiplacebo.sh --scope profile_resolver` | `AP_RC=0`, 9 строк `ok`, `предъявлено красным повторным прогоном: 9`; glob `fixtures/profile_resolver/*` = 9 файлов (другая мера) |
| Ч-10 CI | `git show 8430ce1 -- .github/workflows/ci.yml` | одно слово `profile_resolver` в `keys` ap3, новой джобы нет |
| п.9 регресс 041 | `run_battery.sh profile_resolver` | `PH_RC=0`, `итог 4/4 классов закрыто` |

Мутанты (свежие клоны, прогон последовательный):

```text
== cto (check-then-open по рецепту r-Б1: readlink -f "$REPO_JSON" ДО exec {REPO_FD}<; п.2/п.3)
b11h: ok=65 refused=55 leak=8 (RACE_N=128)
054-батарея ОТКАЗ: ЧЕСТНАЯ ЧАСТЬ: клетка b11h красная
итог 054: rc=1
CTO_RUNNER_RC=1
== unk (zz_nosuch вписана в HONEST_CELLS после b11m; п.4)
СВЕРКА: zz_nosuch
054-батарея ОТКАЗ: ЧЕСТНАЯ ЧАСТЬ: клетка zz_nosuch красная
итог 054: rc=1
UNK_RUNNER_RC=1
== lit (в печати Ч-7 "$sverka_count" → литерал 1; п.1в)
LIT_RUNNER_RC=0
LIT_P1B_RC=1 N=1 C=30
```

### Семь пунктов роли

1. **Область.** `34d0c06`/`8430ce1` трогают только `scripts/profile_resolver.sh`,
   `fixtures/_krasnye_054.sh`, `red_profil_dva_sloja.sh`, `fixtures/profile_resolver/`
   (9 case), `.github/workflows/ci.yml` — все в ЗОНА implementer 057. `.probe-only`,
   `red_izoljacija_projectid.sh`, `_verify_055_r3.sh`, `_krasnye_055.sh`,
   `verify_antiplacebo.sh` не тронуты. Дельта резолвера — `level_label` (P4),
   гейт `getpath == null` в `check_barrier_array`, `else null` двух листьев
   `barriers` — внутри ПЕРЕСЕЧЕНИЯ (fd-first/алфавиты/packs не правлены). PASS.
2. **Сырой вывод.** Коммит `8430ce1` приводит команды приёмки с rc; повторено мной — выше. PASS.
3. **Проверка под реализацию.** Автор правил батарею — это его зона по §Зонам;
   правка grep-литералов `project:`→`слой-проекта:` (b1 стаб/честная) требуется
   Ч-3 и совпадает с блобом 054. Ослабления клеток не найдено. PASS.
4. **Красное предъявлено.** Для b11h/b11m, fail-closed диспетчера, литерал-счётчика,
   раннера — да (адверсарий + мои мутанты). Для п.5б — НЕТ (Б-1). FAIL.
5. **Атомарность.** Два коммита одной задачи 057 со ссылкой на предмет. PASS.
6. **Норма.** `git diff 939dc64 HEAD -- contracts/ frozen/ AGENTS.md roles/` пуст;
   `registry/contracts.tsv` — только строка заморозки `43282f4`; HEAD-блоб контракта
   `8b934a4c` = блоб в `939dc64`. frozen-diff пуст. PASS.
7. **Счётные утверждения.** «30/30» — `N=30 C=30` (grep -c событий); «9/9» — 9 ok-строк и
   9 файлов glob; «4/4» — вывод батареи; «20/20» стабов — `grep -c '^стаб пойман: '`=20. PASS.

### ПРОВОДКА (038)

Канал один — `guard=scripts/verify_antiplacebo.sh`; существует и подключён
ключом `profile_resolver` в ap3; барьер именно этого предмета (семья
`fixtures/profile_resolver/` адресует `scripts/profile_resolver.sh` по ключу).
ПРОВОДКА-ЭНФОРСМЕНТ обоснован честно: поведенческих норм ролей нет. PASS.

### Граница-2: `.probe-only`

`fixtures/workshop_project/` = `.probe-only`, `red_profil_dva_sloja.sh`,
`red_izoljacija_projectid.sh`, `_verify_055_r3.sh`; `case_*` — ноль. Форма 034
инв.1 (маркер ∧ red_* ∧ нет case_*) соблюдена; Б4 закрыт исполнением новой семьи
в CI, не снятием маркера. Легитимно. PASS.

### Паразитная сложность (050)

| Артефакт | (1) свойство | (2) состояние | (3) совместная правка | (4) глубина | (5) потребитель / повтор | Класс |
|---|---|---|---|---|---|---|
| `cell_b11h` | Ч-4 | `$WORK/b11h-*`, фоновый swap-pid; счёт напечатан | 1 файл | интерфейс 1 арг → гонка 128 | п.3; — | ESSENTIAL |
| `cell_b11m` (+ встроенный python-патч) | Ч-5 | `$WORK/b11m-*`; счёт напечатан | 1 файл, но ~50 строк гонки (фикстуры, swap-цикл, классификация, уборка) дублируют `cell_b11h` дословно — правка гонки = 2 места | мелкий из-за копии | п.3/Ч-5; повторяет логику b11h | ACCIDENTAL (совет): фрагмент — копия гонки; отсутствующего свойства нет; проще — общий `race_leaks <субъект> <тег>`. Также двойной якорь: `grep -qF` пред-проверка дублирует `orig_block not in src` python — одна проверка достаточна |
| `HONEST_CELLS` + `dispatch_honest_cell` | Ч-6 | явное, в выводе через СВЕРКА | 2 места на новую клетку (список + case) — было 2 и раньше | ок | п.4 | ESSENTIAL. Совет: вложенные `cell_workshop_run`/`cell_resolver_run` сохраняют `*) return 0` (строки 1294, 1381) — сейчас недостижимы (все 25 имён имеют ветвь, сверено), но это тот же класс Б1 на втором уровне |
| счётчик `sverka_count` + СВЕРКА | Ч-7 | явное (stdout) | 1 | ок | п.1б | ESSENTIAL (ветвь `==0` при литеральном непустом списке недостижима, но требуется Ч-7 буквально) |
| 9 `case_*.sh` (семья) | Ч-9 | `$WORK`, симлинк слоя | 9 файлов несут JSON-литералы слоя; при правке схемы — 9 мест | ок | п.8, CI ap3 | ESSENTIAL (протокол раннера — файл на кейс) |
| `BATTERY_RC` в раннере | Ч-8 | явное | 1 | ок | п.1/п.2 | ESSENTIAL |
| `level_label` | Ч-3 | нет | 1 | ок | п.7 | ESSENTIAL |
| `getpath == null` гейт | Ч-2 | нет | 1 | ок | п.5/п.6 | ESSENTIAL |
| ключ ci.yml | Ч-10 | нет | 1 | ок | CI | ESSENTIAL |

### Советы (не блокируют)

- С-1. b11h/b11m считают `refused` любой rc≠0 и rc=0 с чужим repoId; Ч-4 говорит
  «rc 1 ∧ именованный отказ → refused». Крах резолвера (rc 2, без фразы) сейчас
  неотличим от отказа.
- С-2. b11m вероятностна под нагрузкой: при параллельном прогоне трёх батарей
  на этой машине честное дерево (`r057-unk` первой попытки, cp -a) дало
  `ОТКАЗ: ЧЕСТНАЯ ЧАСТЬ: клетка b11m красная` (leak=0 у мутанта), а соседние
  прогоны — красное k8. Одиночный прогон зелёный. Для судейской батареи
  (Граница-3) допустимо, но стоит печатать счёт b11m перед отказом.
- С-3. Б7 ревьюера 054 к2 (`defaults.git/ci` не наследуются, `resolver:543–544`)
  — вне 057: ПЕРЕСЕЧЕНИЕ ограничивает дельту резолвера ветвью `barriers`; это
  предмет 054/нового контракта, не блокер 057.
- С-4. Форма M оставляет пустые контейнеры `barriers:{}`/`commands:{}` в выводе;
  Ч-1 требует отсутствия листьев — соблюдено; пустые объекты — на усмотрение.

### Итог

FAIL — одна находка-блокер Б-1 (m1–m6 / п.5б: мутант замещения ветви `barriers`
проходит батарею и CI). Б1/Б2/Б4/Б5 закрыты и воспроизведены; Б3 закрыт по
поведению резолвера (формы A/G/F/C/M/P, Ч-2), но не по барьеру, который обязан
держать его от регресса формы P.
