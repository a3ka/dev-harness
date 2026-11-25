FAIL
OBJECT=24d8ca7ece1810a864080f40732762b462363c4c
СУД: репо=dev-harness; предмет=211; фаза=реализация; роль=reviewer; вызов=1 (полный); сессия=Rev211; модель-факт=anthropic/claude-opus-5-5 (`bash scripts/models_actual.sh --tsv --bind --session Rev211 | cut -f1-3` → `reviewer	anthropic/claude-opus-5-5	allowed`, rc 0); автор Impl211* — MiniMax; предыдущий=archive/211/adversary-v4-fail-c187e3c343 (FAIL только К-08; правило остановки R-0074); класс риска=рисковый
КЛАСС=КОДОВЫЙ. Находки: блоков 2 (Б-1, Б-2), советов 4 (С-1…С-4), все с чекбоксами в `.review/2026-11-25-rev211-1.md`.

# Вердикт reviewer — 211, реализация, вызов 1 (полный)

**БЛОКИРУЕТ: Б-1** — инварианты 4 и 8. `scripts/zamok_predmeta.sh:766` читает класс файла предмета через `git cat-file blob "$blob"`, а база и модель-эталон — через `git show "$obj:$kat/$put"`. На ASCII-имени с `^-` (база такое имя видит) путь D42 допускает ревьюера рискового-по-базе предмета без адверсария (rc 0 вместо rc 1), а путь D52 теряет `KLASS_RISKA_NET`.
**БЛОКИРУЕТ: Б-2** — норма 050, ACCIDENTAL. Массивы `sp_*` и повторная печать перед `sort -z` (`:713-715,743-758,788-792`). Названы фрагмент, отсутствующее свойство и более простая форма. Форма прогнана: `--repo` 56/0, 208 35/0.
**СОВЕТ: 4** (С-1 модель берёт вложенный ref как версию; С-2 пины стабов вне истории OBJECT; С-3 `perechen_kontrakta_raven` тяжелее формы модели; С-4 шаг CI 211 не подключён).

Перепроверил ВСЁ: область правки, сырой вывод, не переписаны ли проверки под код.

## 0. Подготовка

```
pwd → /home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/t79a546dca/m
git fetch ssh://git@github.com/a3ka/dev-harness.git refs/heads/wip/211/orchestrator-r6 refs/heads/main refs/heads/archive/211/adversary-v3-fail-8ae264f524 refs/heads/archive/211/adversary-v4-fail-c187e3c343 → rc 0
git fetch … '+refs/tags/*:refs/tags/*' → rc 0; git remote add origin … → rc 0
git switch --detach 24d8ca7ece18…; git rev-parse HEAD → 24d8ca7ece1810a864080f40732762b462363c4c
git merge-base origin/main HEAD → 57631863f314ff7dbae02030de358280f7df656d   (origin/main = dbcce81b7)
sha256 scripts/zamok_predmeta.sh: 57631863f = 1ec472715 = 10ff5df41 = 47de5c0244b5…  (база одна); OBJECT = f9bb49b72f78…
git diff --stat 57631863f origin/main -- scripts/zamok_predmeta.sh fixtures/…/d52_bootstrap_sudej_211 contracts/211-… registry/ci-steps.tsv → пусто (main зону 211 не двигал)
TMPDIR=/tmp/dev-harness-verify/scratch-rev211/<прогон> (удалён перед докладом)
```

## 1. Область правки

```
git diff --name-status 57631863f HEAD → 72 файла:
  M scripts/zamok_predmeta.sh                                        (+222/−21)
  M fixtures/workshop_project/d52_bootstrap_sudej_211/{SDACHA.md,model/zamok_predmeta.sh,probe211.py,source.json}
  M …/stabs/st01…st53/zamok_predmeta.sh (53)   A …/stabs/st54…st67/zamok_predmeta.sh (14)
git log --format='%h %an %cn %s' 57631863f..HEAD:
  24d8ca7ec architect   orchestrator 211 architect-j …  → fixtures/…/d52_bootstrap_sudej_211 (7)
  b5341fbf8 implementer orchestrator 211 implementer-d … → scripts/zamok_predmeta.sh (1)
  1db1a98db architect   orchestrator architect: strengthen 211 battery … → fixtures/… (9)
  3a9b1a961 architect   orchestrator 211: фиксировать порядок диагностики D52 … → fixtures/… (61)
  f5e968504 implementer orchestrator 211 implementer-c … → scripts/zamok_predmeta.sh (1)
  e547931f7 architect   orchestrator 211: cover quoted Git names … → fixtures/… (60)
  be3047e2c implementer orchestrator 211 implementer-b … → scripts/zamok_predmeta.sh (1)
  8a42c06bb implementer orchestrator 211 implementer: D64 … → scripts/zamok_predmeta.sh (1)
```
Каждый коммит лежит в зоне своего автора: implementer — ровно `scripts/zamok_predmeta.sh`, architect — ровно `fixtures/workshop_project/d52_bootstrap_sudej_211/`. Контракт, норма, реестры и CI диффом не тронуты. Атомарность соблюдена: восемь коммитов, у каждого своя ссылка на круг.

Дельта production к базе, сверена с объявленными инвариантами:

| место | что | объявлено |
|---|---|---|
| `:106-131` | заголовок v211 | да (§Предмет: «заголовок v14») |
| `:697-710` `kontrakt_zapisi` | NUL-перечень `ls-tree -z`, фильтр `<NNN>-*.md` | б3: «тот же перечень имён, что у klass_riska» (полный перечень по глобу); ремонт Adv211 Б-1 |
| `:712` 4-й аргумент `owner` | профиль и legacy у владельца | инв. 1 |
| `:713-715,743-758,788-792` | массивы `sp_*`, повторная печать, `LC_ALL=C sort -z` по ключу «mode\ttip\tsha\tимя» | порядок базы — инв. 4/8; **форма** — Б-2 |
| `:763-765` | mode ∉ {100644,100755} или tip≠blob → `ploh` | D36 (канон — обычный файл), Adv211 Б-2; tip≠blob — как в базе |
| **`:766`** | **`git cat-file blob "$blob"` вместо `git show "$obj:$kat/$put"`** | **нет** — ни контракт, ни комментарий; модель читает по пути → **Б-1** |
| `:779-780` | legacy из `$owner` | инв. 1, 3 |
| `:873-880` `poslednj_frozen_teg` | числовой максимум, только `<NNN>/<digits>` | б1, инв. 7 |
| `:888-915` `perechen_kontrakta_raven` | имя+sha, mode вне сверки, оба — обычные файлы, непустой | б3; форма — С-3 |
| `:917-928` `frozen_udostoveren_objectu` | annotated, предок, перечень | б1–б3 |
| `:1610-1622` ветвь D64 | reviewer/adversary при пустом P_FROZEN | инв. 1/2/4 |

## 2. Сырой вывод (по одной, rc и числа)

`B=bash fixtures/workshop_project/d52_bootstrap_sudej_211/red_d52_bootstrap_sudej_211.sh`, cwd — корень копии, у каждого прогона свой TMPDIR.

```
B --repo .        → SUBJEKT 211: KLETKI 56 KRASNYH 0                                   RC=0
B --model         → MODEL 211: KLETKI 56 KRASNYH 0                                     RC=0
B --stabs         → MODEL 211: KLETKI 56 KRASNYH 0 / STABY 211: SVJAZI 75 ZHIVYH 0      RC=0
B --sintaksis     → SINTAKSIS OK                                                       RC=0
B --sosed-208     → SUBJEKT 208: KLETKI 35 KRASNYH 0                                   RC_sosed=0
B --negativ-208   → NEGATIV 208: KLETKI 35 KRASNYH 2 (r31-review-txt-vperjod, r32-review-vlozhenyj-vperjod) …   RC_negativ=0
bash -n scripts/zamok_predmeta.sh                                                      BASH_N_RC=0
shellcheck 0.11.0 -S warning: OBJECT `grep -c '^In '` = 2, база 1ec472715 = 2 (SC1090 :560, SC2034 :1303 — обе прежние)
red_zamok_object_predok_208.sh --repo .  → SUBJEKT 208: KLETKI 35 KRASNYH 0            RC_208=0
red_obryv_167.sh --repo .  → CHECKED 8 CASES; FAILURES 0 / MERGE separate…other_ref ok RC_167=0
red_pre_judge_leak_185.sh --repo → clean/dirty/local_fake/missing_harness/missing_harness_local_fake ZELENO   RC_185=0
red_architecture_process_187.sh --repo . → CELLS=111 STABS=0 FAILURES=0                RC_187=0
red_odin_agent_140.sh --model → MODEL_KLETKI 244 KRASNYH 0                             RC_140=0
run_battery.sh zamok_predmeta → итог 4/4 классов закрыто                               RC_hyg=0
bash scripts/pre_critic.sh contracts/211-d52-bootstrap-sudej.md → … КРИТИК: дверь зелёная   RC_pre=0
bash scripts/gen_ci_steps.sh --check → RC_gen=0; grep -c d52_bootstrap registry/ci-steps.tsv → 0 (шага 211 нет — С-4)
bash scripts/check_sdacha.sh "$PWD" contracts/211-d52-bootstrap-sudej.md --run → СДАЧА: лист зелёный (двери=17 карта=17/17 дельта=3)   RC_sdacha=0
```

Числа заявлены Impl211d, Arch211j и `SDACHA.md:9,17,94`. Проверил своей мерой, другой командой: `jq` над `source.json` даёт `.kejsy|length` = 56 и `[.stab_vhod[]|length]|add` = 75. `.stab_vhod|length` = 67, и `find stabs -mindepth 1 -maxdepth 1 -type d | wc -l` тоже 67. Ключи клеток идут b01…b56 без пропусков. Связанных клеток 38. Заявленное совпадает с фактом.

## 3. Не подогнаны ли проверки под код

- **Клетки b01–b27 диффом не тронуты.** `git diff 57631863f HEAD -- probe211.py` даёт только добавления: b28–b56, хелперы и параметр `env=None` в `sudit` (умолчание прежнее). По кругам `git diff 3a9b1a961 HEAD` и `1db1a98db HEAD` удалённые строки — только комментарии, сигнатура `sudit`/`d52_zhivaja_baza` и `fn(tekst)` → `fn(tekst_staba(…))`. Ожидания прежних клеток не ослаблены.
- **Implementer батарею не трогал**, architect не трогал production (§1).
- **Ожидания новых клеток идут от поведения, а не от текста скрипта.** b49–b56 запускают живую дверь базы `1ec472715` (`tekst_bazy(BAZA_D52)`) в отдельном мире. Они сверяют её тройку с литералом (`D52_BASE_DRIFT`) и только потом судят субъект. b44–b47 держат литералы базы. b55 запускает обе двери под `LC_ALL=en_US.utf8`, а если локали нет — именованный rc 2 `LOKAL_NEDOSTUPNA`.
- **Модель не подогнана под production.** Модель — независимая форма: сортирует сырые записи `ls-tree -z | LC_ALL=C sort -z`, сравнивает `%q имя blob`, читает класс по пути. На Б-1 она совпала с базой, а не с production (§5).
- **Стабы привязаны к клеткам кодом (Н-39).** `STAB_VHOD` живёт в `probe211.py:1368-1414` и генерируется в `source.json:.stab_vhod`. Проза контракта пар не задаёт.
- **Красное предъявлено своими мутантами production.** Каждый мутант — одна замена (`mut.py`, кратность якоря 1, `bash -n` 0), замены отличаются от замен в `stabs/`. Прогон — штатный `B --repo <корень мутанта>`:

| мутант | замена | rc | красные клетки |
|---|---|---:|---|
| r1-hvost-F | `IFS= read -r -d '' imya_f <&4 && exit 1` → `… && [ -z "$imya_f" ] && exit 1` | 1 | **b48** (T: рисковый хвост удалён из OBJECT → reviewer rc 0 вместо отказа) |
| r2-versija-leksich | `sort -t$'\t' -k1,1n -k2,2` → `sort -t$'\t' -k2,2` | 1 | b20 |
| r3-bez-predka | `merge-base --is-ancestor "$F" "$obj"` → `cat-file -e "$F^{commit}"` | 1 | b06 |
| r4-critic-v-d64 | ветвь D64 `… || [ "$rol" = critic ]` | 1 | b09 |
| r5-mode-755-ploh | `{ mode≠100644 && mode≠100755; }` → `mode≠100644` | 1 | b34 |
| r6-bez-vladelca | `klass_riska … "$obj_fakt" "$risk_repo"` → без 4-го аргумента | 1 | b21, b22, b24 |

Стаб st58 правит ту же строку, что r1, но на пине `f8eaa3bb8`. Замена r1 другая.

## 4. Соответствие контракту (по инвариантам, на OBJECT)

| инв. | команда / клетки | rc | вывод |
|---|---|---:|---|
| 1 (D64, б1–б3, корни) | `B --repo .` b01 b02 b08 b10 b16; б1 b10 b11 b18 b20 b25; б2 b06 b17; б3 b05 b19 b28–b43 b48; корни b21–b24 b26 | 0 | соответствует; мутанты r2/r3/r6/r1 красны |
| 2 (промах — прежнее поведение) | b06 b11 b15 b18 b19 b20 b48 | 0 | соответствует |
| 3 (не занижается, не выдумывается) | b05 b14 b21–b24 b26 **b48** (T: удаление рискового контракта из OBJECT при reviewer → `KLASS_RISKA_NET`+`ADVERSARIJ_DO_REVJUERA`, rc 1) | 0 | соответствует на D64; **на пути D42 — нет, Б-1** |
| 4 (critic/D52 как в базе) | b09 b37 b44–b47 b49–b56 + живая база | 0 | порядок и сообщения D52 байт-в-байт с базой на всех клетках (b55 в en_US.utf8); **имя с `^-` — расхождение, Б-1** |
| 5 (порядок судей) | b03 b04 b13 | 0 | соответствует; `ADVERSARIJ_DO_REVJUERA` fail-closed сохранён |
| 6 (закреплённый frozen приоритетен) | b08 b12 b27 | 0 | соответствует |
| 7 (версии) | b10 b11 b18 b20 b25 | 0 | соответствует |
| 8 (регресс A2/208) | `--sosed-208` 35/0, `--negativ-208` 35/2 r31/r32, 208 `--repo` 35/0, 167, 140 `--model` 244/0, гигиена 4/4 | 0 | механический якорь зелёный; **вход D42 с `^-` в имени — нарушение, Б-1** |
| приёмка | все строки §«После реализации», кроме `gen_ci_steps --check` (С-4) | 0 | см. §2 |

`KLASS_RISKA_NET` и `ADVERSARIJ_DO_REVJUERA` fail-closed сохранены на всех промахах D64. Класс через bootstrap не занижается (b05, b48). Нарушение Б-1 лежит не в D64, а в общей для D42/D52/D64 функции `klass_riska`.

## 5. Б-1 — сырой вывод

Мир строится строителями `probe211.py` (`repro_caret.py`): файл предмета переименован в `contracts/211-fixture^-.md` с `КЛАСС РИСКА: обычный`. Предъявлен трём дверям.
```
critic   base   rc=0 stdout='PUSCHEM Crit211 dev-harness/211 (sudja/critic)\n' stderr='ПРЕДУПРЕЖДЕНИЕ: KLASS_RISKA_NET: предмет 211: класс риска неоднозначно определён (neodnoznachno); файлы: 211-fixture^-.md — класс не определён, предмет считается рисковым\n'
critic   model  rc=0 (тот же stdout и тот же stderr, что у base)
critic   object rc=0 stdout='PUSCHEM Crit211 dev-harness/211 (sudja/critic)\n' stderr=''
reviewer base   rc=1 stdout='' stderr='ПРЕДУПРЕЖДЕНИЕ: KLASS_RISKA_NET: … файлы: 211-fixture^-.md — …\nОТКАЗ: ADVERSARIJ_DO_REVJUERA: предмет 211 рисковый, завершённого адверсария в учёте нет — ревьюер раньше адверсария запрещён\n'
reviewer model  rc=1 (тот же stdout и тот же stderr, что у base)
reviewer object rc=0 stdout='PUSCHEM Rev211 dev-harness/211 (sudja/reviewer)\n' stderr=''
контроль 211-fixture.md: base/model/object — critic rc 0 stderr '' ; reviewer rc 0 PUSCHEM — совпадают
```
Мир reviewer — путь D42: frozen-тег и строка REPLACE на HEAD станции (`stancija_teg` + `stancija_stroka`). Это вход вне дельты D64.

Причина (`repro_show.sh`, git 2.43.0): `git show <c>:contracts/211-a^-.md` → rc 128. Для `..`, `...`, `^!`, `^@`, `@{1}`, `~1`, `^`, `:`, `^{}` в имени rc 0 и класс читается. Ломает только `^-`.

Своя мера по всему классу входов (`diff_klass.py`). Функция `klass_riska` базы против OBJECT, stdout байтами, локали C и en_US.utf8, имена из ASCII без цитирования `ls-tree`, режимы 644/755/040000/160000/120000, legacy-строки:
```
seed=20261125 мирoв 300  → PROGONOV 600  RASHOZHDENIJ 2
seed=7        мирoв 1500 → PROGONOV 3000 RASHOZHDENIJ 4
seed=11       мирoв 1500 → PROGONOV 3000 RASHOZHDENIJ 4
расхождений без имени с «^-» (NE_CARET): 0
```

## Регресс

См. §2: все соседи зелёные с теми же числами, что у Adv211d. shellcheck не хуже базы (2 = 2). Без флага 140 не гонялся (вариант А, вне 211).

## Остатки

- **ОСТАТОК (Adv211d): «D52/critic строже базы» — не блок.** NUL-перечень показывает critic имена, которые база молча пропускала (кириллица, `"`, `\`, TAB, LF, симлинк с текстом класса в цели). Это прямое следствие б3: «тот же перечень имён, что у klass_riska», а глоб `<NNN>-*.md` эти имена включает. Направление только fail-closed: лишний файл даёт тот же класс либо `neodnoznachno`, то есть рисковый. Если единственный файл предмета назван не-ASCII, база дала бы `net_stroki` (рисковый), а OBJECT читает декларацию. На D52 автор и так контролирует текст OBJECT, на D42 текст заморожен. Нового рычага занижения нет. Инвариант 4 «байт-в-байт базы» для входов, которые база видела, не нарушен: на ASCII-именах без цитирования моя мера даёт 0 расхождений, кроме `^-` (Б-1). Почему это не блок, а `^-` — блок: мерило — модель-эталон (§Предмет: «эталон семантики — model»). Единственный файл `211-риск.md` (`repro_caret.py … 211-риск.md`): база на D42 даёт reviewer rc 1 (`net_stroki`), модель rc 0 и OBJECT rc 0. Значит, эталон эту дельту объявляет, и она закреплена клетками b38–b43. На `^-` модель совпадает с базой (rc 1), а production — нет.
- **ОСТАТОК (Adv211d): имя с LF/TAB попадает в stderr сырым — не блок.** Учёт пишется через `jq --arg` (`:277`) и экранируется. Строка stderr рвётся, но rc и класс fail-closed. База таких имён не видела, поэтому сравнивать не с чем. Ловец — следующий предмет диагностики, если владелец захочет.
- **Эквивалентные мутанты Adv211d — принимаю.** m5a `-u`: имя входит в ключ, имена в дереве уникальны, удалять нечего. m6 TAB→пробел: mode фиксированной ширины, tip ∈ {blob, commit, tree} (первые буквы различны), sha фиксированной длины, так что разделитель никогда не сравнивается с символом. m8h `-n`: ключ начинается с шестизначного mode, дальше байтовое сравнение. m8i `-s`: без `-k` ключ — вся запись. m8g `-i`: в ASCII-именах нет непечатаемых. TAB/LF возможны только в именах, которых база не видела. Это доказательства по устройству ключа, независимые от мира. Моя мера на 6600 прогонов их не опровергает.
- **ОСТАТОК «граница risk_repo = носитель» (принята владельцем 23.11, арбитраж 2353d9e0b8 §4) — не укусил.** Дельта выбор `risk_repo` не меняет: в ветви D64 `:1618-1619` передаётся тот же `$risk_repo`, что у D42 `:1606,1609`. Фактический источник в мирах батареи — станция мира (b21–b24, b26 красны на r6). Класс предмета 211 — рисковый. Порядок adversary → reviewer соблюдён: R-0074 — четыре FAIL адверсария, пятого нет, его accept заменяет owner-аттестат. Автоматический допуск доверенности источника не доказывает.
- **ОСТАТОК «батарея — конечный набор; остаток — судьи» (ловец adversary → reviewer) — укусил.** Место — `scripts/zamok_predmeta.sh:766` (Б-1): класса входов «имя с синтаксисом ревизии git» в батарее нет.
- **ОСТАТОК «D52 читает профиль и legacy носителя» и «незакоммиченные профиль/legacy владельца» — не укусил.** b37 зелёна (умолчание владельца на D52 — `$wt`, как в базе), r6 различим.

## СВЕРКА-СТАНДАРТОВ

н/п: `AGENTS.md` станции не объявляет документа архитектуры и стандарта кода (`grep -n 'ARCHITECTURE\|CODING-STANDARDS' AGENTS.md` → пусто). Дифф затрагивает дверь и фикстуру.

## СВЕРКА-АРХИТЕКТУРЫ

Размещение — дверь в `scripts/`, батарея в своей фикстуре, соответствует. Новых зависимостей нет: git/jq/awk/sort как в базе. Писатель учёта прежний (`predupr`/`zapis_dodat`). Новых операций нет, ветвь внутри `--sudit`. `bindings.json` и sourceCanon не объявлены (`tooling/checks/cli.js` в дереве нет), diff модели архитектуры пуст, уровень L не применим. Долг расширен на Б-2 (лишний слой в `klass_riska`). Находку `finding new` не заводил: модели архитектуры нет. Расхождение «эталон-модель против production» (Б-1) — нарушение контракта, а не модели архитектуры.

## Паразитная сложность (050)

Ответы на (1) свойство / (2) состояние / (3) число файлов при правке свойства / (4) глубина / (5) потребитель:

- `kontrakt_zapisi` — (1) б3 (полный перечень по глобу), Adv211 Б-1; (2) нет, поток NUL; (3) 2 файла (дверь и модель), как до диффа; (4) 3 аргумента, работа — разбор `ls-tree -z`; (5) `klass_riska`, `perechen_kontrakta_raven`. **ESSENTIAL.**
- 4-й аргумент `klass_riska` — (1) инв. 1, корни; (2) явный аргумент, умолчание `$wt`; (3) 2; (4) +1 необязательный аргумент; (5) ветвь D64, b21–b26. **ESSENTIAL.**
- массивы `sp_*` + повторная печать (`:713-715,743-758,788-792`) — (1) свойства нет: порядок базы даёт сортировка потока; (2) скрытое состояние в 4 массивах и 4 лишних локальных; (3) 2; (4) мелко: 20 строк без новой функции; (5) повторяет разбор ключа, который в сырой записи `ls-tree -z` уже есть (модель `:682`). **ACCIDENTAL → Б-2** (простая форма прогнана: 56/0, 208 35/0).
- `poslednj_frozen_teg` — (1) б1/инв. 7; (2) нет; (3) 2; (4) 2 аргумента, работа — числовой максимум любой длины; (5) `frozen_udostoveren_objectu`. **ESSENTIAL.**
- `perechen_kontrakta_raven` — (1) б3; (2) подоболочка с fd 3/4, явное; (3) 2; (4) 30 строк против 12 в модели; (5) `frozen_udostoveren_objectu`. Свойство ESSENTIAL, форма тяжелее нужной → С-3 (на production не прогнано, поэтому совет).
- `frozen_udostoveren_objectu` + ветвь D64 — (1) инв. 1/2/4; (2) нет; (3) 2; (4) 4 аргумента, rc 0/1; (5) `--sudit`. **ESSENTIAL.**
- фильтр mode в `klass_riska` — (1) D36, Adv211 Б-2; (2) нет; (3) 2; (4) одна ветвь; (5) b34–b36, r5 красен. **ESSENTIAL.**
- батарея: клетки b28–b56, хелперы `d52_spisok`/`d52_zhivaja_baza`/`d52_lokal_ne_c`/`lokal_env`/`tekst_bazy`/`tekst_staba`, семья стабов st54–st67 — (1) инв. 1б3/3/4/8 и К-08 Adv211c/d; (2) env локали двери — явный аргумент `sudit(…, env=)`; пины `f8eaa3bb8`/`a6bfd871c` — внешние git-объекты, неявное состояние → С-2; поля `source.json:baza_*` — пишутся, но не читаются (справочные); (3) 2–3 (`probe211.py`, `source.json`, `stabs/`) — генератор их связывает; (4) приемлемо; (5) `--repo`/`--stabs` в строках приёмки. **ESSENTIAL** с советом С-2.

## Что чинить (порядок)

1. Implementer: Б-1 (`:766` → чтение по пути, как в базе и модели) и Б-2 (сортировка потока в `kontrakt_zapisi`, без массивов) — одна правка `klass_riska`/`kontrakt_zapisi`.
2. Architect: клетка с `^-` в имени (D42 reviewer и D52 critic против живой базы) плюс стаб на неё; С-1 и С-2 — по усмотрению.
3. Повтор: узкий вызов reviewer на дельту. Адверсария по R-0074 нет. Owner-аттестат консультанта — после accept.

## НЕ ЗАЩИЩАЕТ (этот вердикт)

- Мутационный поиск адверсариев не повторялся (п.3 задания). Мутанты r1–r6 нужны только для красного своей мерой.
- `check_zones.sh` целиком не гонялся (п.6 задания): зона сверена по автору и путям каждого коммита.
- Живую станцию и настоящее состояние замка не трогал: все прогоны — в одноразовых мирах под `TMPDIR`.
- Мобильного экрана в предмете нет.
- Запись СУД в HANDOFF дописывает оркестратор.
