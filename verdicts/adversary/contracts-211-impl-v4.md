FAIL
OBJECT=a6bfd871c729d6e684317dab5edb7350fdf9e3d4
СУД: репо=dev-harness; предмет=211; роль=adversary; вызов=4 (узкий: дельта Impl211d; по SANKCIJA консультанта, ADR 2026-11-24); фаза=реализация; модель-план=anthropic/claude-sonnet-5-5; модель-факт=anthropic/claude-sonnet-5-5 (по метаданным среды); предыдущий=archive/211/adversary-v3-fail-8ae264f524 (FAIL Adv211c, 8ae264f52); класс риска=рисковый

## Область

Узкий вызов 4 на неизменяемом OBJECT `a6bfd871c` (ветка `wip/211/orchestrator-r4`, носитель на main `e767f5132`). Дельта считана ПО КОММИТАМ НОСИТЕЛЯ (`git log e767f5132..HEAD`: Impl211 `229ac707e`, Impl211b `7371af93d`, Architect211 `bbdb5bb1c`, Impl211c `7de6962eb`, Architect211h `df98b2ae8`, Architect211i `28d809e6d`, Impl211d `a6bfd871c`). `git show a6bfd871c --stat`: production — ровно `scripts/zamok_predmeta.sh` (29+/20−); `git show 28d809e6d --stat`: батарея — только `fixtures/workshop_project/d52_bootstrap_sudej_211/**` (SDACHA.md, probe211.py, source.json, стабы st58–st63). Необъявленной семантики вне ключа сортировки `klass_riska` нет (К-01 не задет). Дрейф main (143/217/реестр/вердикты) в дельту не входит.

Исследовано: (1) закрытие Б-1 Adv211c (тай-брейк равных ключей), (2) регресс, (3) соседние входы того же места, (4) мутанты ключа и разбора записей сортировки, (5) двусторонность К-14. Метод атак: один и тот же одноразовый мир (`Mir/nositel/kommit_vse/avtor_sdal` из `probe211.py`, роль critic, ноль frozen-тегов = путь D52) прогоняется через дверь базы (`git show 1ec472715:scripts/zamok_predmeta.sh`) и дверь OBJECT; сравнивается тройка (rc, stdout, stderr) БАЙТАМИ. TMPDIR=`/tmp/dev-harness-verify/scratch-adv211d`.

## Блоки

### БЛОКИРУЕТ Б-1 (К-08; контракт 211 К-08, задание вызова 4 п.3) — живой НЕэквивалентный мутант: `LC_ALL=C` убран из `sort -z` перечня klass_riska; батарея `--repo` зелёная 54/0

**ОБЯЗАТЕЛЬСТВО.** Задание вызова 4 п.3: мутация «`LC_ALL=C` убран» обязана краситься `B --repo` (rc 1 с названными клетками) ИЛИ быть явно эквивалентной; живой неэквивалентный мутант = блок К-08. На вызове 3 тот же мутант (Adv211c, мутант A) не считался блоком только потому, что ключ сортировки был фиксированной ширины (mode/tip/sha/`%08d`) и локаль на него не влияла. Ремонт Impl211d ввёл в ключ ИМЯ целиком (`scripts/zamok_predmeta.sh:790-791`: `printf '%s\t%s\t%s\t%s\0' … "${sp_imya[$sj]}"` | `LC_ALL=C sort -z`): имя — переменной ширины, тай-брейк равных blob разбирается им, и `LC_ALL=C` стал НЕСУЩИМ. Довод эквивалентности вызова 3 больше не работает.

**СОСТОЯНИЕ (достижимое).** Станция/CI/рабочая оболочка с неCлокалью (`LANG=en_US.UTF-8` — `locale -a` на станции: `C C.utf8 POSIX en_US.utf8`), critic/D52, три каталога-близнеца в каталоге контрактов с равным содержимым: `211-a.md/`, `211-a.md.md/`, `211-a.md-x.md/`.

**КОМАНДА** (из корня копии OBJECT; мутант — единственная правка `scripts/zamok_predmeta.sh:791` `done | LC_ALL=C sort -z` → `done | sort -z`):

```sh
export TMPDIR=/tmp/dev-harness-verify/scratch-adv211d SUBJ_ROOT="$PWD"
python3 $TMPDIR/mut.py m4-LC_ALL-ubran     # -> $TMPDIR/mut-m4-LC_ALL-ubran/scripts/zamok_predmeta.sh
bash fixtures/workshop_project/d52_bootstrap_sudej_211/red_d52_bootstrap_sudej_211.sh --repo "$TMPDIR/mut-m4-LC_ALL-ubran"   # (A) батарея на мутанте
DOOR=$TMPDIR/mut-m4-LC_ALL-ubran/scripts/zamok_predmeta.sh python3 $TMPDIR/atk.py one 'B three' en_US.utf8   # (B) мир мутанта в en_US
```

**РЕЗУЛЬТАТ.**

```
(A) B --repo <мутант m4>:  rc=0  SUBJEKT 211: KLETKI 54 KRASNYH 0         # ЖИВ: ни одна клетка не красна
(B) base loc=en_US.utf8 rc 0 211-a.md 211-a.md-x.md 211-a.md.md
    obj  loc=en_US.utf8 rc 0 211-a.md 211-a.md.md 211-a.md-x.md           # порядок диагностики D52 ≠ базы
(B2, мир «пунктуация»; обе строки — весь список файлов)
    base en_US.utf8: 211-A.md 211-a-b.md 211-a.1.md 211-a.md 211-a.md-.md 211-a.md.md 211-a.md_.md 211-a0.md 211-a_b.md
    obj  en_US.utf8: 211-a0.md 211-a.1.md 211-a-b.md 211-a_b.md 211-a.md 211-A.md 211-a.md-.md 211-a.md.md 211-a.md_.md
```

Мутант НЕ эквивалентен: достижимое состояние (неCлокаль + равные blob с именами, различающимися пунктуацией/регистром/длиной) даёт другие байты stderr D52, чем база; production-вариант с `LC_ALL=C` на тех же мирах SAME с базой во всех пяти локалях (C, C.utf8, en_US.utf8, пустой LANG, по умолчанию).

**Почему батарея слепа.** `probe211.py:95-101` — `GIT_ENV['LC_ALL']='C'` задаётся ГЛОБАЛЬНО для всех клеток (дверь и git), поэтому ни одна из 54 клеток не исполняет дверь под не-C локалью; `grep -n 'en_US\|LC_ALL\|LANG' probe211.py` — единственное совпадение строка 100. Стабы на PINNED production — только st58–st63 (`PRODUCTION_STABY`, `probe211.py:1337-1339`: T/P/Q/R/L/M Adv211c); ни один не правит строку сортировки 791, st57 — мутация `ls-tree -z | sort -z` в `kontrakt_zapisi` модели/стаба, не `klass_riska` production.

**Тот же дефект охвата (достижим и при LC_ALL=C — батарея слепа даже в своей среде).** Одиночные правки флагов той же строки `sort -z`: каждая обязана быть красной или эквивалентной.

| ID | правка | `B --repo` | поведение на мире (LC_ALL=C) |
|---|---|---|---|
| m8d | `sort -z -V` | rc 0, 54/0 ЖИВ | 3 каталога `211-a.md`,`211-a.md.md`,`211-a.md-x.md`: база `211-a.md 211-a.md-x.md 211-a.md.md`, мутант `211-a.md 211-a.md.md 211-a.md-x.md`; 9 из 18 моих миров расходятся |
| m8e | `sort -z -f` | rc 0, 54/0 ЖИВ | мир «пунктуация»: база `211-A.md 211-a-b.md …`, мутант `211-a-b.md 211-a.1.md 211-A.md 211-a.md …` |
| m8f | `sort -z -d` | rc 0, 54/0 ЖИВ | расходится на 6 мирах из 18 |

(Воспроизведение: `python3 $TMPDIR/mut.py m8d-V m8e-f m8f-d`; `B --repo "$TMPDIR/mut-<ID>"`; `DOOR=$TMPDIR/mut-<ID>/scripts/zamok_predmeta.sh python3 $TMPDIR/atk.py one 'B three' C`.) Причина общая: батарея держит тай-брейк только двумя близнецами `211-a.md`/`211-a.md.md` (b54) и 12 нулёнными равными (b53) — на них `-V/-f/-d` совпадают с байтовым порядком; клеток «три и более равных близнецов» и «равные blob с именами, различающимися регистром/пунктуацией/числом после точки» нет.

**Что даёт исправление (за architect, production корректен).** Клетки в `probe211.py`: (а) D52, равные blob, `211-a.md`/`211-a.md-x.md`/`211-a.md.md` как каталоги (убивает m8d), (б) `211-A.md`/`211-a.md`/`211-a_b.md`/`211-a-b.md` с равным blob (убивает m8e, m8f и в en_US — m4), (в) запуск ТАКОЙ клетки с `LC_ALL=en_US.utf8` в env двери (убивает m4; локаль присутствует на станции — иначе клетка обязана явно сообщить о пропуске, а не зеленеть), (г) стаб st64 = m4 на PINNED production. Production-правок не нужно.

Оценка тяжести: диагностика fail-closed (предмет остаётся рисковым), класс не занижается; блок держится на критерии К-08 «живой неэквивалентный мутант = блок» и прецеденте Adv211c Б-2, а не на дефекте production.

## Остатки

- ОСТАТОК: «D52/critic на OBJECT видит имена, которые база молча пропускала» (кириллица, `"`, `\`, TAB, LF; симлинк с текстом класса в цели — `neodnoznachno` вместо молчаливой декларации): строже базы, следствие ремонта Б-1 вызова 1 (NUL-перечень). Подтверждено мирами (`atk.py exotic`): база не видит `211-a"q.md`, `211-a\s.md`, `211-риск.md`, TAB/LF-имён; OBJECT видит и сортирует байтами (`211-a\tb.md 211-a\nb.md 211-a b.md 211-a"q.md 211-a.md 211-a\\s.md 211-риск.md`). НЕ блок (задание п.5). Ловец — architect (оговорить в контракте как намеренную дельту) / reviewer.
- ОСТАТОК: имя файла с LF/TAB попадает в stderr предупреждения `KLASS_RISKA_NET` сырым (`файлы: … 211-a<LF>b.md …`): строка диагностики разрывается. Автор носителя контролирует имена, предупреждение fail-closed — класс не занижается. Ловец — reviewer.
- ОСТАТОК: К-16 (граница владельца через носитель без/с иным origin) — не затронут дельтой, граница принята владельцем (слово 23.11). Ловцы — adversary/reviewer.
- ОСТАТОК: `fixtures/.../model/zamok_predmeta.sh` (модель-оракул) строит порядок D52 иначе (`ls-tree -z | LC_ALL=C sort -z` целой записи) — независимый оракул; `--model` 54/0 совпадает с production на всех клетках. Не дефект.

## Регресс

`B` = `bash fixtures/workshop_project/d52_bootstrap_sudej_211/red_d52_bootstrap_sudej_211.sh`.

| Команда | rc | результат |
|---|---:|---|
| `B --repo .` | 0 | `SUBJEKT 211: KLETKI 54 KRASNYH 0` |
| `B --model` | 0 | `MODEL 211: KLETKI 54 KRASNYH 0` |
| `B --stabs` | 0 | `MODEL 211: KLETKI 54 KRASNYH 0`, `STABY 211: SVJAZI 71 ZHIVYH 0` (63 каталога стабов st01–st63) |
| `B --sintaksis` | 0 | `SINTAKSIS OK` |
| `B --sosed-208` | 0 | `SUBJEKT 208: KLETKI 35 KRASNYH 0` |
| `B --negativ-208` | 0 | `NEGATIV 208: KLETKI 35 KRASNYH 2 (r31-review-txt-vperjod, r32-review-vlozhenyj-vperjod)` |
| `bash scripts/pre_critic.sh contracts/211-d52-bootstrap-sudej.md` | 0 | `КРИТИК: дверь зелёная` |
| `bash scripts/check_sdacha.sh "$PWD" contracts/211-d52-bootstrap-sudej.md --run` | 0 | `СДАЧА: лист зелёный (двери=17 карта=17/17 дельта=2)` |
| `red_zamok_object_predok_208.sh --repo .` | 0 | `SUBJEKT 208: KLETKI 35 KRASNYH 0` |
| `red_obryv_167.sh --repo .` | 0 | `MERGE registry_drop ok / partial ok / other_ref ok` |
| `red_pre_judge_leak_185.sh --repo` (без `.`: с `.` — usage rc 1, это CLI батареи) | 0 | `185 local_fake ZELENO rc=1 … missing_harness ZELENO rc=2 …` — как в прежних вызовах |
| `red_architecture_process_187.sh --repo .` | 0 | `CELLS=111 STABS=0 FAILURES=0` |
| `red_odin_agent_140.sh --model` | 0 | `MODEL_KLETKI 244 KRASNYH 0` |
| `run_battery.sh zamok_predmeta` | 0 | `итог 4/4 классов закрыто` |
| `bash -n scripts/zamok_predmeta.sh` | 0 | — |
| shellcheck 0.11.0 `-S warning scripts/zamok_predmeta.sh` | — | 2 находки на OBJECT и 2 на базе `1ec472715` (`grep -c '^In '`) — новых нет |

## Закрытие Б-1 Adv211c и атаки (D52/critic против базы `1ec472715`, байты (rc, stdout, stderr))

Б-1 Adv211c ЗАКРЫТ. 18 именованных миров (`atk.py spec`) — все SAME с базой, в т.ч.: два каталога `211-a.md/` + `211-a.md.md/` (stderr `файлы: 211-a.md 211-a.md.md` — БАЙТ-В-БАЙТ базы, в обоих порядках создания); три близнеца `211-a.md 211-a.md-x.md 211-a.md.md`; четыре близнеца (+`211-a.md.0.md`); близнецы с `-`, `.`, `_`, цифрами после точки (`211-a-b.md 211-a_b.md 211-a.1.md 211-1.0.md 211-1.5.md 211-1_a.md 211-1-a.md`), регистр (`211-A.md`), `.MD` (не входит в перечень, как на базе); 12 и 14 равных файлов без декларации (и каталогов); 14 файлов с чередованием R/O; пробел в имени (`211-a  b.md`); смесь классов и режимов 755/644; файл в подкаталоге. Локали `LC_ALL` ∈ {не задан, C, C.utf8, en_US.utf8, пусто} (`atk.py loc`): production OBJECT SAME с базой во всех 18 мирах × 5 локалей. Fuzz 250 миров (2–9 файлов из пула 19 ASCII-имён, файл/каталог, R/O/без декларации/без класса с равным blob, 644/755): `fuzz done n=250 seed=20261124 diffs=0`.

Двусторонность К-14 (честные входы зелёные): один файл предмета (R / O), файл только в подкаталоге — rc 0, stderr пуст (SAME с базой); смена только exec-бита, не-ASCII имя в обоих деревьях с одним blob — клетки b34, b38–b43 зелёные в `--repo` 54/0; D52/critic на входах вне D64 — SAME с базой во всех мирах выше, кроме заведомо более строгих (раздел «Остатки»).

## Мутации

Одноразовые каталоги `$TMPDIR/mut-<ID>/scripts/zamok_predmeta.sh` (`python3 $TMPDIR/mut.py <ID>`, якорь кратности 1, `bash -n` ok), штатный `B --repo <каталог>`.

| ID | правка единственного места | rc | красные клетки |
|---|---|---:|---|
| m1 | `sort -z` → `sort` (без -z) | 1 | b44, b45, b47, b49, b54 |
| m2 | в ключ — номер записи вместо имени (как до Impl211d) | 1 | b54 |
| m3 | имя в ключе между mode и tip/sha | 1 | b42, b44, b45, b47 |
| m3b | имя в ключе ПЕРЕД mode | 1 | b42, b44, b45, b47, b49 |
| **m4** | **`LC_ALL=C sort -z` → `sort -z`** | **0** | **ЖИВ, неэквивалентен (Б-1)** |
| m5a | `sort -z -u` | 0 | ЖИВ, ЭКВИВАЛЕНТЕН: имя входит в ключ целиком, имена в дереве уникальны ⇒ полностью равных записей нет, `-u` ничего не удаляет (`atk.py spec`: 0 расхождений из 18 миров) |
| m5b | `sort -z -u -t<TAB> -k1,3` (равные blob теряются) | 1 | b45, b52, b53, b54 |
| m6 | разделитель ключа TAB → пробел (с согласованным разбором) | 0 | ЖИВ, ЭКВИВАЛЕНТЕН: mode — 6 знаков, sha — фиксированной длины, tip ∈ {blob, commit, tree} — ни одно не префикс другого, разделитель после поля переменной длины никогда не сравнивается с символом; 0 расхождений из 18 миров |
| m7a | `read -r` без `-d ''` после сортировки | 1 | 33 клетки (b01…b04, b08, b10, b12–b14, …) |
| m7b | `sort -z \| tr '\0' '\n'` + `read -r` (построчно) | 1 | b43 |
| m8a | `sort -z -s -t<TAB> -k1,3` (тай-брейк = порядок дерева, форма дефекта Б-1 Adv211c) | 1 | b54 |
| m8b | `sort -z -t<TAB> -k4` (только имя) | 1 | b44, b45, b47, b49 |
| m8c | `sort -z -r` | 1 | b44, b45, b46, b47, b49, b52, b53, b54 |
| **m8d** | **`sort -z -V`** | **0** | **ЖИВ, неэквивалентен (см. Б-1)** |
| **m8e** | **`sort -z -f`** | **0** | **ЖИВ, неэквивалентен (см. Б-1)** |
| **m8f** | **`sort -z -d`** | **0** | **ЖИВ, неэквивалентен (см. Б-1)** |
| m8g | `sort -z -i` | 0 | ЖИВ, эквивалентен на 18 мирах (непечатаемых символов в именах каталога контрактов нет, кроме TAB/LF — они вне ASCII-имён моих миров; не блок) |
| m8h | `sort -z -n` | 0 | ЖИВ, эквивалентен: ключ начинается с 6-значного mode (число = строковый порядок), далее последнее сравнение — байты |
| m8i | `sort -z -s` | 0 | ЖИВ, эквивалентен: без `-k` ключ — вся запись, `-s` не меняет порядок |

## НЕ ЗАЩИЩАЕТ

- ОСТАТОК: порядок D52 при неC-локали окружения двери и при ≥3 равных blob с именами, различающимися пунктуацией/регистром/числом, батареей не защищён: `LC_ALL=C` в `scripts/zamok_predmeta.sh:791`, опции `sort -z` в этой строке (m4, m8d, m8e, m8f) — укус вызова 4, см. Б-1. Ловец — architect (клетки (а)–(г)) до принятия.
- ОСТАТОК: поведение на строках-именах с управляющими символами в диагностике (stderr) — ловец reviewer.
- ОСТАТОК: нестандартный mode 100664 (старые деревья с удалённого репозитория): `klass_riska` отнесёт запись к `neodnoznachno` (база читала бы файл); `git mktree` его канонизирует, не воспроизводилось. Ловец — reviewer.
- ОСТАТОК: К-16 — см. «Остатки».

## Советы

- Клетки в `probe211.py`: (1) D52, три равных blob-каталога `211-a.md/`, `211-a.md-x.md/`, `211-a.md.md/` (убивает `-V`); (2) D52, равные blob `211-A.md`, `211-a.md`, `211-a_b.md`, `211-a-b.md` (убивает `-f`, `-d` и при `LC_ALL=en_US.utf8` в env двери — `LC_ALL`-мутант); (3) отдельная локаль-клетка: `sudit` с env `LC_ALL=en_US.utf8` (если локаль отсутствует — явный пропуск, не зелёный); (4) стабы st64–st67 по m4/m8d/m8e/m8f на PINNED production.
- Альтернатива без локаль-клеток: убрать зависимость от окружения принципиально — задавать `LC_ALL=C` для всей двери одной строкой в начале скрипта (но тогда вызов `git`/`grep -E -o 'КЛАСС РИСКА…'` по кириллице получит другой контекст — проверить) либо сортировать в самом bash/awk байтами. Решение за architect/implementer.
- Контракт: оговорить дельту «D52/critic видит имена, цитируемые `ls-tree`» как намеренную.

## Сырой вывод ключевых прогонов

```
B --repo .      rc=0  SUBJEKT 211: KLETKI 54 KRASNYH 0
B --model       rc=0  MODEL 211: KLETKI 54 KRASNYH 0
B --stabs       rc=0  MODEL 211: KLETKI 54 KRASNYH 0 / STABY 211: SVJAZI 71 ZHIVYH 0
B --sintaksis   rc=0  SINTAKSIS OK
B --sosed-208   rc=0  SUBJEKT 208: KLETKI 35 KRASNYH 0
B --negativ-208 rc=0  NEGATIV 208: KLETKI 35 KRASNYH 2 (r31-review-txt-vperjod, r32-review-vlozhenyj-vperjod)
pre_critic      rc=0  КРИТИК: дверь зелёная
check_sdacha    rc=0  СДАЧА: лист зелёный (двери=17 карта=17/17 дельта=2)
atk.py spec     18 миров, расхождений с базой 0 | atk.py loc 18×5 локалей, 0 | atk.py fuzz 250 seed=20261124, diffs=0
мутанты: m1/m2/m3/m3b/m5b/m7a/m7b/m8a/m8b/m8c красны; m5a/m6/m8g/m8h/m8i эквивалентны; m4/m8d/m8e/m8f ЖИВЫ, неэквивалентны
В env батареи: probe211.py:100  'LC_ALL': 'C'  (глобально для всех клеток)
```
