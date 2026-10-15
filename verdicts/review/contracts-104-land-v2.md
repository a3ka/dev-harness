FAIL

# Review PR#97 `wip/104/implementer2`, контракт 104 «узкий доверенный гейт судьи» (land-v2, круг 2)

Находки с чекбоксами — в `.review/2026-10-15-07.md` (prev: `.review/2026-10-15-03.md`). Вердикт круга 1:
`verdicts/review/contracts-104-land-v1.md` (FAIL). Вердикт adversary круга 2 на момент записи в main не виден,
поэтому мой написан независимо.

МОДЕЛЬ судьи: `anthropic/claude-opus-5-5` (reviewer, тир audit).

**Субъект.** PR#97, голова `53f27c96ddacee75b851bf66e6e46b63f87c5f77`
(`git ls-remote origin wip/104/implementer2`), OPEN, `mergeable: CONFLICTING`, `mergeStateStatus: DIRTY`.
Ветку переписали принудительно: от головы круга 1 (`6c366f54`) её перебазировали на main `2664189b`. Merge-base с
origin/main (`21f394f4`) = `2664189b`.

```
$ git log --format='%h A:%an C:%cn %s' origin/main..origin/wip/104/implementer2
53f27c96 A:orchestrator C:orchestrator 104: nudge CI — … пустой коммит
b170759e A:architect    C:orchestrator 104 architect: А-917 — РЕШЕНИЕ по Рв97-2 …
12e8c5a6 A:architect    C:orchestrator 104 architect: Рв97-3 / A104-1 — батарея различает дверь, зашитую на critic (17 стабов …)
be0d6d9e A:orchestrator C:orchestrator 104 orchestrator: честная identity для механической регенерации …
0d6b0964 A:implementer  C:orchestrator 104 implementer: потолок персоны orchestrator 52904 → 51084
9e58e5b4 A:implementer  C:orchestrator 104 implementer: узкий доверенный гейт судьи — субъекты ЗОНЫ implementer
f98b3683 A:architect    C:orchestrator 104: fixtures/zashchita_main_104 …
8e6ca35a A:architect    C:orchestrator 104: точечный перенос contracts/104-*.md …
```

Соответствие кругу 1 по `git show <c> | git patch-id --stable` (старые объекты достал `git fetch origin 6c366f54a8…`):

```
452f682b 0a65ac67131a | 8e6ca35a 0a65ac67131a
7f714159 aaffebaefc40 | f98b3683 aaffebaefc40
3ef470c9 d4ac439e2276 | 9e58e5b4 d4ac439e2276
8931df63 0016d3d4aab7 | 0d6b0964 0016d3d4aab7
6c366f54 5b079d719088 | be0d6d9e 5b079d719088
a9a31330 046082d376e9 | 12e8c5a6 046082d376e9   (a9a31330 — клон Architect104Fix3)
fceedc02 b81c172272b0 | b170759e 8f8194d59e2d   (отличие — номер А-915→А-917 и тело коммита, Рв97-16)
```

`git diff 9e58e5b4 53f27c96 -- scripts .omp/extensions fixtures/dokazatelstva_098` пуст, `git diff 0d6b0964 53f27c96 -- roles` пуст:
реализацию после круга 1 не трогали. `git diff 6c366f54 53f27c96` по путям 104 = только 4 файла `fixtures/zashchita_main_104/`
(164+/17−). Blob контракта на голове = blob тега = `e4b1e185`.

**Сборка.** Одноразовый SSH-клон `/tmp/dev-harness-verify/r104v2-1792080035/repo`. Worktree: `../tip` (53f27c96), `../base` (2664189b),
`../w099` (4952f3ff2), `../sim-cur` и `../sim-r1` (симуляция ленда). Мутанты — `../mut/`, скрипты — `../mk_mut.sh`, `../mk_mut2.sh`,
`../probe2.sh`, `../regress.sh`, `../sim_registry.sh`, логи — `../out/`. Основной чекаут я не трогал, push не делал.

## 1. Область правки — PASS по путям и авторам

Живой блоб `contracts/104-…md` (= тег): ЗОНА architect — `contracts/104-…md fixtures/zashchita_main_104/ fixtures/_krasnye_104.sh`.
Задание круга дополнительно разрешает architect `NABLIUDENIA_ARCHITECT.md` и точечно `roles/orchestrator.md`.
`12e8c5a6` — 4 файла `fixtures/zashchita_main_104/` ✓. `b170759e` — `NABLIUDENIA_ARCHITECT.md` ✓. `be0d6d9e` — `.omp/agents/orchestrator.md`
(производная, `orchestrator`) ✓. `53f27c96` — пустой.
`bash scripts/check_zones.sh` на голове → RC=0, `замороженных контрактов: 96 · объявленных авторов: 2 · коммитов в диапазонах: 12093 · проверено по зонам: 2746`.
Единственная FAIL-строка — самотест грамматики 055, к диффу она не относится. `reslop t -- bash fixtures/_krasnye_104.sh` → `ok: true, passed: 39, failed: 0`.

## 2. Сырой вывод своими прогонами — PASS

**Приёмка 3** (голова, `bash fixtures/_krasnye_104.sh`):
```
— t104-m1 … t104-m17 пойман (каждый своей клеткой; m14 dver_spavna, m15/m17 materializatsija, m16 judge_gate)
стаб-пак: 17/17 поймано
ЗЕЛЕНО ×6 (red_huk_alfavit_ustanovki, red_huk_bez_ustanovochnogo_konfiga, red_huk_task_spavna,
           red_judge_gate_svidetelstvo_sudi, red_sud_model_dver_spavna, red_sud_model_materializatsija)
клеток просмотрено: 6
ИТОГ 104: rc=0        RC=0
```
**Приёмка 1** (батарея головы на корне `../base` 2664189b, без субъектов):
```
стаб-пак: 17/17 поймано
КРАСНО: red_huk_alfavit_ustanovki / red_huk_bez_ustanovochnogo_konfiga / red_huk_task_spavna: предмет отсутствует: .omp/extensions/spawn-guard.ts
КРАСНО: red_judge_gate_svidetelstvo_sudi: вход 1: ожидался rc 1 «свидетельство судьи не передано», журнал пуст; факт rc=0, вывод: verdict-строка записа…
КРАСНО: red_sud_model_dver_spavna / red_sud_model_materializatsija: предмет отсутствует: scripts/check_sud_model.sh
ИТОГ 104: rc=1        RC=1
```
**Приёмка 2** (`D104_SUBJECTS_DIR=../w099/scripts Z104_SPAWN_GUARD=../w099/.omp/extensions/spawn-guard.ts`): три клетки хука КРАСНО,
judge_gate КРАСНО на входе 1, `ЗЕЛЕНО: red_sud_model_dver_spavna`, `КРАСНО: red_sud_model_materializatsija: вход 1 … rc=2 … неизвестный аргумент: --object`, `ИТОГ 104: rc=1`.
Совпадает с текстом приёмки 2: входы 7–10 дверь 099 тоже проходит, то есть ноги 099 переносятся.
**5а** поклеточно 098 (`regress.sh`): base 17 строк, голова 17 строк, ненулевых 0, `diff` пуст (rc=0).
**5б** `_krasnye_095.sh` → `ИТОГ 095: rc=0`. **5в** `check_judge_gate.sh` → `check_judge_gate: ветви «all» зелены`, RC=0.
`_krasnye_098.sh` и `--model` → `ИТОГ 098: rc=0`. `node scripts/gen-harness.ts --check` → `харнес соответствует roles/ (9 ролей)`, RC=0.
`check_ceilings.sh .` → `ok персоны: 9 файл(ов), потолок 51200 байт`, RC=0.
**CI** (run 38735211341, headSha 53f27c96): 11/12 pass. `ci (l1, check:charter)` FAIL, единственная причина —
`FAIL уставной документ изменён без разрешения владельца: ROADMAP.md в b0c39a58`, merge-коммит main (Рв97-14). Строка 104 в
том же логе: `ok contracts/104-… — уставной с frozen/contracts/104/1, коммитов в диапазоне 51, изменений без разрешения нет`.

## 3. Проверка не переписана под реализацию — PASS

Семью 104 после реализации меняет только `12e8c5a6`. Это коммит architect, сделанный настоящей сессией `Architect104Fix3`:
в её отчёте `a9a31330`, патч тот же. Он закрывает находку круга 1. Субъекты после круга 1 не менялись (пустые диффы выше).
Новые входы ужесточают батарею: на субъекте 099 и на дереве без субъектов батарея по-прежнему красна (приёмки 1 и 2).

## 4. Красное предъявлено — PASS (Рв97-3 закрыт), остаток — совет Рв97-15

Мутанты РЕАЛЬНЫХ субъектов головы (`mk_mut.sh`: копия `scripts/*.sh` + одна правка, `diff` показан в логе), прогон
`D104_SUBJECTS_DIR=<мутант> Z104_SPAWN_GUARD=<мутант>/spawn-guard.ts bash fixtures/_krasnye_104.sh`:

```
R   стр.159 tier := .roles.critic           → КРАСНО dver_spavna вход 7 (adversary тир apex); materializatsija вход 10   ИТОГ rc=1
H   role=critic после разбора argv           → КРАСНО dver_spavna вход 7; materializatsija вход 10 «трасса без строки роли: critic»  ИТОГ rc=1
A2  break после esac цикла сверки           → КРАСНО materializatsija вход 14 «… вердикт critic материализуется»           ИТОГ rc=1
FB  fallback берётся у тира critic           → КРАСНО materializatsija вход 12 «фолбэк вне списка тира: reviewer … тир audit» ИТОГ rc=1
FM  FM=.omp/agents/critic.md                 → КРАСНО dver_spavna вход 9 «arbiter frontmatter @apex тир plan»             ИТОГ rc=1
JG  judge_gate: --verdict critic             → КРАСНО judge_gate вход 5 «argv двери ≠ «--verdict reviewer …»»            ИТОГ rc=1
S1ST сессия/объект только у первой строки   → 17/17, 6/6 ЗЕЛЕНО, ИТОГ rc=0                                             ← не пойман
```
Все четыре пункта закрытия A104-1 исполнены. (1) Нога spawn/frontmatter: входы 7–10 — честная и чужая модель и тир у adversary,
reviewer, arbiter. (2) Нога verdict: вход 10 (reviewer → rc 0), вход 11 (та же трасса от arbiter → rc 1 «трасса без строки роли: arbiter»).
У reviewer и arbiter одна модель opus, поэтому вход 11 различает именно фильтр роли. (3) judge_gate: вход 5 с литеральным argv.
(4) Стабы m14–m16 «любая роль → critic» умирают на новых не-critic входах, m17 (A2) — на входе 14.
Мутант S1ST (`probe2.sh`): трасса `critic astra allowed S O` + `critic astra allowed S2 O` → реальный субъект `rc=1 ОТКАЗ: чужая трасса`,
мутант `rc=0 СУДЬЯ СВОЕЙ МОДЕЛИ`. С объектом O2 то же самое. Это совет, не блокер, обоснование — Рв97-15.

## 5. Атомарность — PASS с наблюдением

Каждое закрытие — отдельный коммит со ссылкой на находку: Рв97-1 → be0d6d9e, Рв97-3 → 12e8c5a6, Рв97-2 → b170759e.
Пустой коммит `53f27c96` (nudge CI) содержимого не несёт, но попадёт в main (Рв97-18).

## 6. Норма не тронута молча — FAIL (Рв97-12)

`contracts/*`: blob = тег. `roles/orchestrator.md` после 0d6b0964 не менялся. Сжатие чужих фрагментов принято решением architect
А-917 (Рв97-2 закрыт). Зато отступление от слова владельца произошло молча. По forks/n287 (ОТВЕЧЕНО, слово 2026-10-15 ~09:15 UTC)
ветка должна идти «ОТ КОММИТА САМОГО ТЕГА»: «тег /1 уже основа новой ветки». Голова круга 1 этому следовала, а ребейз
12:29:27 это отменил:

```
$ git merge-base --is-ancestor frozen/contracts/104/1^{commit} 6c366f54   → rc=0
$ git merge-base --is-ancestor frozen/contracts/104/1^{commit} 53f27c96   → rc=1
$ git merge-base --is-ancestor 452f682b origin/main                         → rc=1
$ git branch -r --contains 452f682b                                         → origin/wip/104/architect2
```
HANDOFF называет это «ребейзом на свежий main» и не упоминает, что ветка потеряла происхождение от тега. Заголовок PR
по-прежнему «ветка от коммита тега, Н-287». Цена проверена симуляцией (`sim_registry.sh`: merge головы в origin/main,
затем реестровая замена `104 → 73a85203…` в форме `orchestrator freeze: registry NNN → …`, затем полный `check_zones.sh`):

```
голова 53f27c96: предикат check_zones:1167 (тег-коммит предок C) rc=1
  FAIL коммит вне зоны: orchestrator 001cce85 registry/contracts.tsv — дверь минта 031: дельта манифеста не только-добавление (нет frozen-тегов для замены)
  check_zones RC=1
голова 6c366f54 (топология круга 1, от тега): предикат rc=0
  замороженных контрактов: 96 · … · проверено по зонам: 2752
  check_zones RC=0
```
На текущей топологии после ленда реестровую строку 104 можно будет заменить только через новую грандфазер-пару со словом
владельца (класс `8f1c25f0`/`8c734d93`, check_zones.sh:1036-1046). Маршрут n287 был выбран как раз для того, чтобы такой цены не платить.

## 7. Заявленное равно сделанному — PASS по счёту, два расхождения провенанса

- Рв97-1. Тело `be0d6d9e` («байт-в-байт тот же контент») подтверждено: patch-id `5b079d71` = 6c366f54. Создатель — сессия Main
  `2026-10-15T11-51-23…jsonl` (`[detached HEAD 6ebd24a4b] 104 orchestrator: честная identity …`). Identity честная.
- 12e8c5a6 («17 стабов, клеток 6»): `grep -c '^progon t104-m'` = 17, `grep -oE 't104-m[0-9]+' | sort -u | wc -l` = 17,
  `ls red_*.sh | wc -l` = 6. Счёт верен. Frozen-текст говорит «13», расхождение раскрыто (Рв97-17).
- А-917 («потерь нормы/числа/ссылки нет»; 51154/52904/51084): байты подтверждены `git cat-file -s`. Мой разбор 12 фрагментов
  в круге 1 тоже не нашёл потерь предписаний. Снятые атрибуции и замеры architect оценил как не нормативные, и это его решение.
- Тело `b170759e` ≠ тело `fceedc02` настоящей architect-сессии: оркестратор удалил два места, раскрыв только перенумерацию.
  Номер А-917 уже выдан диагнозу 085 (`17cfc5d2`, на main). Это Рв97-16.
- HANDOFF: «11/12 green … единственный красный — l1 (та же b0c39a58-причина)». Это подтверждено логом job 116422645465.

## ПРОВОДКА (038)

`bash scripts/check_provodka.sh . contracts/104-…md` → RC=1 `проводка: guard не подключён: fixtures/_krasnye_104.sh …`.
Так и объявлено: подключение после ленда (Рв97-7 открыт до done). Guard `fixtures/_krasnye_104.sh` остаётся барьером именно
этого предмета. Role-канал (раздел «Свидетельство судьи» в roles/orchestrator.md) не менялся с круга 1.

## Паразитная сложность (050) — артефакты диффа круга 2

| артефакт | (1) свойство | (2) состояние | (3) файлов на правку | (4) глубина | (5) потребитель | класс |
|---|---|---|---|---|---|---|
| входы 7–10 / 10–14 / 5 в трёх клетках семьи 104 (одна семья) | Решение 3 «роль вызова и её тир», «КАЖДАЯ строка»; Решение 4 argv | миры в `$Z104_BASE`, явные | 1 семья | без нового интерфейса | приёмка 3, guard ПРОВОДКИ | ESSENTIAL |
| `SPAWN_TPL` + маркеры `__TIER__`/`__LOOP_TAIL__` в battery_stubs.sh | приёмка 6 (каждый стаб — одна порча честного каркаса) | нет | грамматика ног `--spawn/--frontmatter` теперь в 2 местах (субъект + SPAWN_TPL), `--verdict` — в 3 (субъект + VERDICT_TPL + model 098); выросло на 1 | малая, без env | стабы m14 | ESSENTIAL: стаб от реального субъекта связал бы стаб-пак с реализацией, по образцу круга 1 |
| стабы m14–m17 | A104-1 п.4, Рв97-3 | нет | 1 | — | стаб-пак | ESSENTIAL |
| запись А-917 | Рв97-2 (решение) | — | 1 | — | вердикт | ESSENTIAL (номер — Рв97-16) |
| пустой коммит 53f27c96 | никакое | — | — | — | нет | наблюдение Рв97-18 (это не артефакт кода) |

ACCIDENTAL с полной тройкой (фрагмент, отсутствующее свойство, более простая форма) не найдено.

## Итог

| находка | класс | блок |
|---|---|---|
| Рв97-1 | авторство регенерации → `be0d6d9e` orchestrator, контент = 6c366f54 | закрыт [x] |
| Рв97-2 | сжатие роли → решение architect А-917 (настоящая сессия Architect104Fix3) | закрыт [x] |
| Рв97-3 (+A104-1 п.1–4) | 17 стабов, не-critic входы, мутанты R/H/A2/FB/FM/JG пойманы | закрыт [x] |
| Рв97-12 | топология: ветка больше не от коммита тега (n287), реестровая замена 104 после ленда — check_zones RC=1 | **да** |
| Рв97-13 | PR CONFLICTING (NABLIUDENIA_ARCHITECT.md, А-918 на main) | **да** (механика ленда) |
| Рв97-14 | l1 check:charter красен от main (b0c39a58), не от 104 | нет (внешний) |
| Рв97-15 | session/object не первой строки не пришпилены (мутант S1ST) | нет (совет) |
| Рв97-16 | тело b170759e правлено оркестратором под author architect; номер А-917 уже выдан 085 | нет |
| Рв97-17 | frozen «13 стабов» против живых 17 (раскрыто) | нет |
| Рв97-18 | пустой nudge-коммит в ленте | нет |
| Рв97-7 | ПРОВОДКА после ленда | нет (до done) |

По содержанию 104 готов: код субъектов не менялся и верен на всех пробах, батарея теперь различает дверь, зашитую на critic,
авторство честное. FAIL ставлю из-за доставки. Ветка ушла с маршрута владельца n287, и это даёт измеримый отказ двери
реестра после ленда. Плюс PR не сливаем. Оба пункта закрываются одним перестроением ветки на коммите тега, которое разрешит
конфликт NABLIUDENIA_ARCHITECT.md (лучше со свободным номером вместо А-917), либо словом владельца, принимающим отход от n287
и цену грандфазера. После этого нужны свежий CI и сверка patch-id содержательных коммитов против этой головы.
