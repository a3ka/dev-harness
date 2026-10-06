FAIL

# Reviewer 088, круг 2 (гейт перед слиянием)

- **Предмет:** `frozen/contracts/088/1` (тег на `79f0756`). main @ `419fd2f` = origin/main. Земля реализации:
  `8bc5e68` (land `wip/088/implementer`) и `4b1f3c2` (land `wip/088/implementer-fix2`).
- **Клон:** `/tmp/dev-harness-verify/rev088v2-judges`, `git clone ssh://git@github.com/a3ka/dev-harness.git`. Мутации
  делались только в одноразовых worktree этого клона. Основной чекаут не тронут.
- **Находки:** `.review/2026-10-06-05.md` (reslop, `status: ready`). **Блокирующих 3** (Б-1, Б-2, Б-3), неблокирующих 1
  (Н-1), сведений 2 (С-1, С-2).
- **Вход судьи:** `verdicts/adversary/contracts-088.md`, FAIL, env `PTR_088` + точечный basename. Оба контрпримера
  закрыты, их красное предъявлено мной (§4). Тот же класс обхода остался в новой форме: источник указателя —
  рабочее дерево (Б-1).
- **Нога А (дверь, `scripts/orch_restart.sh`) — находок нет.** FAIL вынесен по ноге Б (`scripts/check_staged.sh`) и батарее.

## 1. Область правки — чисто

```text
$ git log --format='%h %an' + git show --name-only (своя мера)
31f1dcbb implementer  scripts/check_staged.sh scripts/orch_restart.sh
c71af1b6 architect    fixtures/strazh_088/.probe-only
0fe7d70b architect    fixtures/strazh_088/{.probe-only,_toy.sh,red_dver_088.sh,red_stuby_088.sh,red_ukazatel_088.sh}
2ee9651a implementer  scripts/check_staged.sh
```

- Коммиты implementer трогают ровно `ЗОНА implementer: scripts/orch_restart.sh scripts/check_staged.sh`. Коммиты
  architect трогают только `fixtures/strazh_088/`. Прочие пути диапазона `8bc5e68..4b1f3c2` — судейские main-direct:
  `cfb53b9` adversary 088, `ba09ed8` reviewer 086 + `.review/2026-10-06-04.md`.
- Живые заморозки: по строкам `ЗОНА|ПЕРЕСЕЧЕНИЕ` из `frozen/contracts/{082/2,083/3,084/1,085/1,086/1,087/1}` пути
  `check_staged.sh|orch_restart.sh|strazh_088|_krasnye_088` дают **0 совпадений** во всех шести. Обе production-правки
  лежат в объявленных ПЕРЕСЕЧЕНИЯх с done-контрактами (016/018/019/023/031/049/080, 072/080).
- `.githooks/pre-commit` (живая зона 084/1) не тронут: `git diff --exit-code 8bc5e68^1 4b1f3c2 -- … .githooks/pre-commit` → rc 0.
- Норма не тронута: в диапазоне нет `roles/` и нормативных документов (С-2 — сведение о pre-freeze `NABLIUDENIA_ARCHITECT.md`).
- Атомарность: каждый коммит — одна задача со ссылкой на 088. `31f1dcb` несёт обе ноги одного предмета, это одна задача.

## 2. Замороженный текст и И-4 — своя мера

```text
git diff --exit-code frozen/contracts/088/1 -- contracts/088-*.md                       → rc_frozen=0
git diff --exit-code frozen/contracts/088/1 4b1f3c2 -- contracts/088-…-handoff.md      → rc_frozen_vs_4b1f3c2=0
git diff --exit-code 592fc4e -- scripts/lib_session.sh ops/server/root/orch-peak        → rc_I4_592fc4e=0
git diff --exit-code 8bc5e68^1 4b1f3c2 -- scripts/lib_session.sh ops/server/root/orch-peak .githooks/pre-commit → rc_I4_range=0
```

## 3. Батарея вживую (своя мера, не чужой вывод)

```text
$ time bash fixtures/_krasnye_088.sh
ЗЕЛЕНО: L1 (живая среда, omp-мера: Arbiter086 Architect083Timing Judges088Adversary Judges088Reviewer)
ЗЕЛЕНО: D0 … D5          red_dver_088.sh: зелёных 7, красных 0, пропусков 0
ЗЕЛЕНО: B0 … B14         red_ukazatel_088.sh: зелёных 13, красных 0, пропусков 0
стаб-пак 088: 17/17 поймано, диффпроба 17/17
ИТОГ 088 (polnyj): rc=0        real 0m5.502s        rc_full=0
$ time bash fixtures/_krasnye_088.sh fast
ЗЕЛЕНО: D1 / ЗЕЛЕНО: B1 / ИТОГ 088 (fast): rc=0  real 0m0.307s
```

П6 и П8 на `4b1f3c2`: `_krasnye_072.sh` rc_072=0 («стабы 16/16 + дифф 16/16 + честные 20/20»; «6/6+6/6+6/6»);
`red_dver_bugfiks_080.sh` rc_080=0 («честные 31/31»); `_krasnye_074.sh` rc 1 (`КРАСНО: cell_k5b` станционная, стабы 7/7) —
на `592fc4e` тот же rc 1 и тот же k5b; `verify_antiplacebo --scope check_staged` rc 0 (33/33), `--scope orch_restart`
rc 0 (1/1) — на `592fc4e` тоже rc 0 (С-1: ДО-числа контракта средозависимы, ПОСЛЕ = ДО соблюдено);
`pre_critic` rc 0, `check_threat_model` rc 0, `check_ceilings` rc 0.

## 4. Красное предъявлено — своя мера

```text
worktree 4b1f3c2 + scripts/check_staged.sh из 8bc5e68 (env-указатель круга 1):
  КРАСНО: B14: … получено rc=0 HEAD сдвинут: не судится: автор «orchestrator» …   rc=1
worktree 4b1f3c2 + check_staged.sh/orch_restart.sh из 592fc4e (ДО):
  fast: КРАСНО: D1, КРАСНО: B1, ИТОГ 088 (fast): rc=1
  red_dver: КРАСНО L1 D1 D2 D3 D5, ЗЕЛЕНО D0 D4, rc=1
```

У новых клеток D5 и B14 есть красный прогон против сломанной реализации. **У обхода Б-1 красной клетки нет.**
Против `4b1f3c2` вся семья зелёная, см. Б-3.

## 5. L1 — честная симуляция живой omp-среды

Контракт объявляет эту ветку остаточным риском. §Остаточный риск п.1: «L1 судима только из живого субагента omp:
вне omp и без субагента моложе 60 с — пропуск; D-клетки держат логику детерминированно, L1 — дрейф раскладки omp».
П2: «вне omp (CI) — ПРОПУСК, не зелёное».

- Изнутри omp-субагента (этот прогон): `ЗЕЛЕНО: L1 (… omp-мера: Arbiter086 Architect083Timing Judges088Adversary
  Judges088Reviewer)`. Против двери `592fc4e`: `КРАСНО: L1: … дверь rc=1, не названы: … ОТКАЗ: HEAD расходится с origin/main`.
  Значит, нога (1) реально слепа ДО и видит ПОСЛЕ, в живой раскладке omp.
- Вне omp: `env -u PI_CODING_AGENT_DIR bash fixtures/strazh_088/red_dver_088.sh . L1` →
  `ПРОПУСК (не зелёное): L1: вне сессии omp …`, `NOT_IMPLEMENTED: ни одной судимой клетки`, rc 2. Пропуск не выдаётся
  за зелёное, как и объявлено.

## 6. Находки (полностью — `.review/2026-10-06-05.md`)

- **Б-1 — блокирует** (И-5/И-6; ЗАЩИЩАЕТ п.3; Frontier п.5 (i) и п.6; правило 8). Источник строки-указателя —
  рабочее дерево `fixtures/ops_server/red_server_obvjazka_074.sh` (`check_staged.sh:275-285`). Если файла нет, проверка
  молча пропускается. Своя мера: staged `HANDOFF.md` без k7, коммит оркестратора.
  - Не staged правка 074 на `HANDOFF_PTR='attacker'`: `rc_A=0 HEAD 4b1f3c2f -> 386ae006`.
  - 074 отсутствует: `rc_B=0`.
  - В 074 два присваивания: `rc_C=0`.
  - Контроль на честном дереве: `rc_control=1`, HEAD не сдвинут.
  - Дрейф k7 B0/B1 больше не краснит (`rc_prod=0`). Контракт обещает обратное.
- **Б-2 — блокирует** (050 ACCIDENTAL, И-7). `${OTKAZ_088:-…}` (`check_staged.sh:295,303`) — читаемая env без
  потребителя: `_toy.sh:26` её снимает. `OTKAZ_088='всё хорошо'` → stderr `всё хорошо`, rc 1. Названы фрагмент,
  отсутствующее свойство и более простая форма (литерал). Литерал проходит 13/13 текущих и 12/12 замороженных
  B-клеток.
- **Б-3 — блокирует** (пункты 3 и 4). У Б-1 нет красной клетки. `0fe7d70` перевёл тоу-мир на закоммиченную копию
  074, которая нужна только субъекту, читающему фикстуру. Мини-судьи читают 074 из индекса, production — из
  рабочего дерева. Замороженная батарея против `4b1f3c2`: `КРАСНО: B1 B2 B3 B4 B6 B7 B11`, rc 1. Против литерала:
  12/12, rc 0.
- **Н-1 — не блокирует.** Счёт сценариев П2/П3/П4 (6/6, 12/12, 15/15) расходится с выводом батареи (7/7, 13/13, 17/17).
  Рост аддитивен. Нужна отметка оркестратора, текст заморозки не трогать.
- **С-1, С-2 — сведения** (П6 ДО-числа средозависимы; pre-freeze `NABLIUDENIA_ARCHITECT.md`).

Простая форма закрытия Б-1+Б-2 проверена своей мерой: литерал k7 и литерал отказа в `check_staged.sh`.
- атаки A/B/C/D → `rc_A=1 rc_B=1 rc_C=1 rc_D=1`, HEAD не сдвинут;
- текущая батарея 13/13;
- замороженная 12/12;
- дрейф k7 → `КРАСНО: B0`.

Это измерение, а не проект. Форму выбирает implementer, клетку Б-3 — architect.

## 7. ПРОВОДКА (контракт 038)

`ПРОВОДКА: guard=fixtures/_krasnye_088.sh`. Канал существует, исполнен (§3) и является барьером именно этого предмета:
он вызывает только `strazh_088/*`. CI-шага нет, это объявлено: живые зоны 083/084/087 + РАБОТА НЕ РАЗДАЁТСЯ.
Потребители до подключения — строки П1–П8. Обоснование `ПРОВОДКА-ЭНФОРСМЕНТ` честное: норм-строк ролей нет,
механизм дан норме `roles/orchestrator.md:427` без правки текста.

## 8. Паразитная сложность (контракт 050) — по артефакту

| Артефакт | (1) свойство | (2) состояние | (3) файлов на правку свойства | (4) глубина | (5) потребитель / дубль | Класс |
|---|---|---|---|---|---|---|
| `orch_restart.sh` ветка `getent passwd` + `HOME="$uh" . lib_session.sh` | И-1, И-3 | явное: дом из passwd, швы 080 приоритетнее; rc 2 при пустом getent | 1 (было 1) | интерфейс не вырос, работа — резолв дома | D1 D3 D4 L1, sa3 sa4 | ESSENTIAL |
| `orch_restart.sh` `$(set +o pipefail; current_session_dir)` | И-2 | нет нового | 1 | интерфейс 0 | D2, sa2 | ESSENTIAL |
| `check_staged.sh` суд `:HANDOFF.md` (граница k7, `grep -Fxq`, B11 пустой блоб) | И-5…И-8 | явное: rc 1 + строка И-7 | 1 | интерфейс 0 (хук прежний) | B0–B13, sb1–sb10 | ESSENTIAL |
| `check_staged.sh:275-284` чтение 074 из рабочего дерева | нет (контракт требует производственную строку, Frontier п.5/6) | **скрытое**: файл чужой живой зоны 085/1, пустое → суд выключен | 2 (выросло: правка k7 теперь меняет production) | — | потребителя нет; дублирует грамматику `^HANDOFF_PTR=` из `_toy.sh` | **ACCIDENTAL, блокирует (Б-1)** |
| `check_staged.sh:295,303` `${OTKAZ_088:-…}` | нет | **скрытое**: читаемая env | 1 | интерфейс +1 env без работы | потребителя нет (`_toy.sh:26` снимает) | **ACCIDENTAL, блокирует (Б-2)** |
| семья `fixtures/strazh_088/` + `_krasnye_088.sh` (одним артефактом) | П1–П5, ПРОВОДКА guard | явное: rc 0/1/2, ПРОПУСК L1 | 4 файла семьи (D5/B14: +1 клетка на файл) | оракул в памяти, `--dver/--sudja` швы стаб-пака | строки приёмки П1–П5; копия 074 в тоу-мире нужна только ACCIDENTAL-источнику (Б-3) | ESSENTIAL (кроме копии 074 — Б-3) |
| `fixtures/strazh_088/.probe-only` | легализация probe-only каталога (CI `verify_antiplacebo`) | нет | 1 | — | CI ap-шаги PR#42 | ESSENTIAL |

## 9. Связь с блобами

Вердикт относится к `scripts/check_staged.sh` @ `4b1f3c2` (`git rev-parse 4b1f3c2:scripts/check_staged.sh`),
`scripts/orch_restart.sh` @ `4b1f3c2` и `fixtures/strazh_088/` @ `4b1f3c2`. Новая редакция принятие или отказ этого
блоба не наследует. Это второй отказ по классу «источник строки-указателя вне коммита» (адверсарий круга 1 → Б-1 здесь).
Если следующий круг снова упрётся в тот же класс, созывается арбитр.
