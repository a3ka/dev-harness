FAIL
OBJECT=4fcd981700e68a7c37b51a0e3865c4b70e66e549
КЛАСС=КОДОВЫЙ (КЛАСС РИСКА: обычный, `contracts/193-svyazka-sdatochnyj-list.md:4`; адверсарий не вызывался)
СУД: repo=dev-harness; предмет=193; фаза=реализация v2 (путевая часть И7; контракт v2, `frozen/contracts/193/2` в удержании `refs/frozen-hold/contracts/193/2`, accept критика Crit193V6 на `e89397d940`); роль=reviewer; вызов=№3 по слову владельца (12:16 UTC 2026-11-18, батч №1 №3; предыдущие — Rev193 FAIL и Rev193b accept по реализации v1, `verdicts/review/contracts-193-impl-v1.md`, `-v2.md`); сессия=Rev193c; модель-факт=anthropic/claude-opus-5-5 (`bash scripts/models_actual.sh --tsv --bind --session Rev193c | cut -f1-3` из `/home/harness/dev-harness` → `reviewer	anthropic/claude-opus-5-5	allowed`); независимость: автор реализации — implementer (MiniMax, Impl193-2), автор контракта и батареи — architect (Sol); судья — другой исполнитель (reviewer)
Находки: `.review/2026-11-18-116.md` (1 блок, 5 советов).

# Вердикт reviewer — 193, реализация v2, вызов №3

## Итог

**FAIL — один блок, Б-1 (И7/И8).** Основное обязательство v2 исполнено на всех перечисленных в задании состояниях. Каждое воспроизведено вручную в своих мирах (§3):

- профильный каталог — зелёный;
- другой законный каталог — зелёный;
- штатный корень без профиля — зелёный;
- корневая приманка при профиле — отказ;
- битый профиль — отказ без fallback;
- `..` и абсолютный путь в профиле — отказ без fallback;
- симлинк-побег — отказ без fallback.

Батарея зелёная во всех трёх режимах (65/65, 65/65, 41/41). Красное-до своей мерой: ровно 10 клеток п.9.

Блок: дверь сравнивает путь вердикта с префиксом лексически, а префикс — ненормализованный вывод резолвера. Значение `workflowPaths.verdicts` с хвостовым `/` резолвер 996 принимает, нога freeze его нормализует (`freeze_contract.sh:107`, `%/`). Дверь же требует `…//critic/*`. Итог: честный accept по такому профилю заморозить нельзя. Исправляется одной строкой. Своя проба этой строки даёт 65/65, и f06 доходит до spec-preflight.

## 1. Объект, область правки, происхождение (повестка 1)

```
pwd: /tmp/dev-harness-verify/Rev193c/repo   (git remote: ssh://git@github.com/a3ka/dev-harness.git; ветка wip/193/implementer)
git rev-parse HEAD origin/wip/193/implementer → 4fcd981700e68a7c37b51a0e3865c4b70e66e549 ×2
git show --format=%P 4fcd9817 → 1f225d3c9781e3a7be506477dd97e20b727eba11 bc5fb6e7f5e02a278c3bc8f1692ad2e549712750
git diff 1f225d3c 4fcd9817 --stat → пусто (merge -s ours: дерево = 1f225d3c)
git diff --stat 82d5cfabb7..4fcd981700 →
 scripts/check_verdict_karta.sh | 47 +++++++++++++++++++++++++++++++++++++-----
 1 file changed, 42 insertions(+), 5 deletions(-)
git diff --stat 82d5cfab 4fcd9817 -- fixtures contracts registry → пусто
1f225d3c: author=implementer <implementer@dev-harness.local>, committer=implementer
```
- Путь `scripts/check_verdict_karta.sh` входит в `ЗОНА implementer` (`contracts/193-svyazka-sdatochnyj-list.md:349`). Вне зоны правок нет.
- Батарея, контракт и реестр implementer не трогал: подгонки проверок под код нет.
- Коммит реализации один, со ссылкой на предмет («193: путь вердикта в двери карты — по эффективному workflowPaths.verdicts (И7)»). Атомарность соблюдена.
- `scripts/check_zones.sh .` — сырой вывод в §6.

## 2. Сырой вывод приёмки (повестка 4)

```
$ bash fixtures/workshop_project/sdacha_193/red_sdacha_193.sh --repo .        (клон, OBJECT)
193 v13-profil-996-chestnyj ok rc=0 КАРТА: 17/17 зелёный
193 v14-drugoj-verdiks-katalog ok rc=0 КАРТА: 17/17 зелёный
193 v15-kornevaja-primanka ok rc=1 ОТКАЗ: путь вердикта вне грамматики .harness/verdicts/critic/…: verdicts/critic/contracts-777-v1.md
193 v16-chuzhaja-rol-review ok rc=1 ОТКАЗ: путь вердикта вне грамматики .harness/verdicts/critic/…: .harness/verdicts/review/contracts-777-v1.md
193 v17-bityj-profil ok rc=1 ОТКАЗ: профиль битый или workflowPaths вне репо: файл не JSON: /tmp/batareja-193-azvkzif5/mir-profil_bityj/har
193 v18-simlink-pobeg-verdikts ok rc=1 ОТКАЗ: профиль битый или workflowPaths вне репо: project_paths_resolve: workflowPaths вне репо: verdicts
193 v19-staged-pochinka-plohogo ok rc=1 ОТКАЗ: .harness/verdicts/critic/contracts-777-v1.md: карта 16 строк: нет: К-17
193 v20-rabochee-uhudshenie-chestnogo ok rc=0 КАРТА: 17/17 зелёный
193 v21-net-v-head-staged ok rc=1 ОТКАЗ: вердикт не закоммичен (AGENTS п.9): .harness/verdicts/critic/contracts-777-v1.md нет на HEAD
193 v22-absoljutnyj-put ok rc=1 ОТКАЗ: путь вердикта вне грамматики .harness/verdicts/critic/…: /tmp/batareja-193-azvkzif5/mir-profil_chestnyj
193 v23-tochki-za-koren ok rc=1 ОТКАЗ: путь вердикта вне грамматики (относительный, внутри корня): verdicts/critic/../../evil.md
193 f05-freeze-profil-karta-krasna ok rc=1 …
193 f06-freeze-profil-noga-zelenaja ok rc=1 …
193 f07-freeze-profil-bez-tega ok rc=0 <пусто>
…
ИТОГ 193: rc=0 KLETKI=65 ZELENYE=65 KRASNYE=0
rc=0

$ bash fixtures/workshop_project/sdacha_193/red_sdacha_193.sh --model
ИТОГ 193: rc=0 KLETKI=65 ZELENYE=65 KRASNYE=0
rc=0

$ bash fixtures/workshop_project/sdacha_193/red_sdacha_193.sh --stabs        (одноразовая копия copy-stabs, 162,8 с)
193 PATERN:BEZ-GRAMMATIKI-PUTA POIMAN
193 PATERN:PROFIL-PREFIKS-OTREZAN POIMAN
ИТОГ 193: rc=0 OBMANOK=41 POIMANY=41 ZHIVYH=0
rc=0

$ bash scripts/check_sdacha.sh . contracts/193-svyazka-sdatochnyj-list.md --run
СДАЧА: лист зелёный (двери=5 карта=17/17 дельта=2)
rc=0

$ bash scripts/pre_critic.sh --repo . contracts/193-svyazka-sdatochnyj-list.md
  ok   потолки красны
  ok   проводка красна
КРИТИК: дверь зелёная
  ok   сдаточный лист красен
rc=0

$ bash scripts/check_provodka.sh . contracts/193-svyazka-sdatochnyj-list.md            → rc=0
$ bash scripts/check_provodka.sh --grammar . contracts/193-svyazka-sdatochnyj-list.md  → rc=0
```

**Красное-до, своя мера.** Копия `before/` на `82d5cfabb7` (дверь до ремонта, батарея OBJECT):
```
193 v13-profil-996-chestnyj KRASNO rc=1 ОТКАЗ: путь вердикта вне грамматики verdicts/critic/…: .harness/verdicts/critic/contracts-777-v1.md
193 v14-drugoj-verdiks-katalog KRASNO rc=1 ОТКАЗ: путь вердикта вне грамматики verdicts/critic/…: workflow/judgements/critic/contracts-777-v1.md
193 v15-kornevaja-primanka KRASNO rc=0 КАРТА: 17/17 зелёный
193 v17-bityj-profil KRASNO rc=0 КАРТА: 17/17 зелёный
193 v18-simlink-pobeg-verdikts KRASNO rc=0 КАРТА: 17/17 зелёный
193 v19-staged-pochinka-plohogo KRASNO …   v20 KRASNO …   v21 KRASNO …   f05 KRASNO …   f06 KRASNO …
ИТОГ 193: rc=1 KLETKI=65 ZELENYE=55 KRASNYE=10
```
Набор совпадает с п.9 контракта: v13 v14 v15 v17 v18 v19 v20 v21 f05 f06.

Счётные утверждения, своя мера (другой командой):
- `grep -vcE '^\s*(#|$)' stabs.tsv` → 41 = OBMANOK;
- census `ls … | wc -l` → 27/7/10/3 = К-15 листа и строки «замер:» контракта;
- `wc -c contracts/193-…md` → 73 856 Б, то есть >64 КиБ.

## 3. Обещание И7 на всех достижимых состояниях — ручное воспроизведение (повестка 2)

Зонд `/tmp/dev-harness-verify/Rev193c/manual.sh`. Дверь берётся из клона, ROOT — свой git-мир под `/tmp/dev-harness-verify/Rev193c/mir.*`. Профиль — настоящие `harness.project.json` и `project-layer.json`, вердикт — честная карта `mir/verdikt_chestnyj.md`, закоммиченная по каждому указанному пути.
```
[m1-bez-profilja] path=verdicts/critic/c-777-v1.md rc=0 | КАРТА: 17/17 зелёный
[m1-bez-profilja] path=.harness/verdicts/critic/c-777-v1.md rc=1 | ОТКАЗ: путь вердикта вне грамматики verdicts/critic/…: .harness/verdicts/critic/c-777-v1.md
[m2-profil] path=.harness/verdicts/critic/c-777-v1.md rc=0 | КАРТА: 17/17 зелёный
[m2-profil] path=verdicts/critic/c-777-v1.md rc=1 | ОТКАЗ: путь вердикта вне грамматики .harness/verdicts/critic/…: verdicts/critic/c-777-v1.md
[m3-drugoj] path=workflow/judgements/critic/c-777-v1.md rc=0 | КАРТА: 17/17 зелёный
[m3-drugoj] path=.harness/verdicts/critic/c-777-v1.md rc=1 | ОТКАЗ: путь вердикта вне грамматики workflow/judgements/critic/…: .harness/verdicts/critic/c-777-v1.md
[m4-bityj] path=verdicts/critic/c-777-v1.md rc=1 | ОТКАЗ: профиль битый или workflowPaths вне репо: файл не JSON: /tmp/dev-harness-verify/Rev193c/mir.TIuy/m4-bityj/harness.project.json
[m5a-dotdot] path=verdicts/critic/c-777-v1.md rc=1 | ОТКАЗ: профиль битый или workflowPaths вне репо: project_paths_resolve: workflowPaths вне репо: verdicts
[m5a-dotdot] path=../out/critic/c-777-v1.md rc=1 | ОТКАЗ: профиль битый или workflowPaths вне репо: project_paths_resolve: workflowPaths вне репо: verdicts
[m5b-abs] path=verdicts/critic/c-777-v1.md rc=1 | ОТКАЗ: профиль битый или workflowPaths вне репо: project_paths_resolve: workflowPaths вне репо: verdicts
[m6-simlink] path=.harness/verdicts/critic/c-777-v1.md rc=1 | ОТКАЗ: профиль битый или workflowPaths вне репо: project_paths_resolve: workflowPaths вне репо: verdicts
[m6-simlink] path=verdicts/critic/c-777-v1.md rc=1 | ОТКАЗ: профиль битый или workflowPaths вне репо: project_paths_resolve: workflowPaths вне репо: verdicts
[m7a-bez-verdicts] path=verdicts/critic/c-777-v1.md rc=1 | ОТКАЗ: профиль битый или workflowPaths вне репо: project_paths_resolve: профиль без workflowPaths.verdicts
[m7b-nowp] path=verdicts/critic/c-777-v1.md rc=0 | КАРТА: 17/17 зелёный
[m8a-slash] path=.harness/verdicts/critic/c-777-v1.md rc=1 | ОТКАЗ: путь вердикта вне грамматики .harness/verdicts//critic/…: .harness/verdicts/critic/c-777-v1.md
[m8a-slash] path=.harness/verdicts//critic/c-777-v1.md rc=1 | ОТКАЗ: вердикт не закоммичен (AGENTS п.9): .harness/verdicts//critic/c-777-v1.md нет на HEAD
[m8b-dot] path=.harness/verdicts/critic/c-777-v1.md rc=1 | ОТКАЗ: путь вердикта вне грамматики ./.harness/verdicts/critic/…: .harness/verdicts/critic/c-777-v1.md
[m8b-dot] path=./.harness/verdicts/critic/c-777-v1.md rc=0 | КАРТА: 17/17 зелёный
[m9-env] path=verdicts/critic/c-777-v1.md rc=0 | КАРТА: 17/17 зелёный      (HARNESS_PROJECT_LAYER_ROOT=/nonexistent, профиля нет)
```
По перечню задания:

- **Профильный каталог** (m2) и **другой законный каталог** (m3) — rc 0. Каталог не захардкожен: путь `.harness/…` при профиле `workflow/judgements` отвергнут.
- **Корень без профиля** (m1) — rc 0, путь `.harness/…` отвергнут.
- **Корневая приманка при профиле** (m2) — закоммиченная честная карта 17/17 по `verdicts/critic/…` получает отказ: запасного корня нет.
- **Отказ резолвера без fallback**:
  - битый JSON (m4);
  - `..` и абсолютное значение (m5a, m5b);
  - симлинк-побег (m6);
  - профиль без `workflowPaths.verdicts` (m7a).

  Во всех пяти мирах честная корневая карта лежит рядом, и дверь её не берёт.
- **Профиль без `workflowPaths`** (m7b) — 996 FALLBACK-NO-WORKFLOW, штатный корень. Это семантика резолвера, дверь его не переизобретает.
- **m8a** — дефект Б-1, **m8b** — совет С-1.

## 4. Блоки

### Б-1 (implementer, `scripts/check_verdict_karta.sh:67-76`; обязательства И7, И8)

Цитата:
```
67 case "$_k193_verdicts_abs" in
68     "$ROOT"/*) _k193_verdicts_rel="${_k193_verdicts_abs#"$ROOT"/}" ;;
…
73 case "$VERDICT" in
74     "$_k193_verdicts_rel"/critic/*) : ;;
75     *) otkaz "путь вердикта вне грамматики ${_k193_verdicts_rel}/critic/…: $VERDICT" ;;
```
и второй читатель того же вывода резолвера — `scripts/freeze_contract.sh:107`:
```
_PROFILE_VERDICTS_DIR="${_PROFILE_VERDICTS_REL%/}/critic"
```
- **Обязательство И7** (`contracts/193-svyazka-sdatochnyj-list.md:141-145`): «путь — непустой относительный путь вердикта внутри critic-каталога эффективного `workflowPaths.verdicts`, полученного единым `project_paths_resolve(ROOT)`».
- **Обязательство И8** (`:159-162`): «замораживается только при rc 0 двери карты на accept-вердикте этой версии».
- **Состояние достижимо.** Профиль `"verdicts": ".harness/verdicts/"` проходит `project_paths_resolve`: гард `_dotdot_segment` пропускает, `readlink -f` даёт путь внутри ROOT. Резолвер возвращает `$ROOT/.harness/verdicts/`, а freeze_contract.sh:107 сам снимает этот `/`.
- **Наблюдение, прямой вызов** (m8a выше): rc 1 на законном `.harness/verdicts/critic/…`.
- **Наблюдение, заморозка** (`f06slash.py`: мир `freeze_profil_zelenyj` строится самой батареей, freeze запускается напрямую):
```
== repo       profile verdicts = .harness/verdicts
freeze rc=1 | ОТКАЗ: spec-preflight 036 красен (rc=127): … check_spec_ready.sh: No such file or directory | теги: <нет>
== slash      profile verdicts = .harness/verdicts/
freeze rc=1 | ОТКАЗ: карта классов вердикта .harness/verdicts/critic/contracts-777-v1.md красна (rc=1): ОТКАЗ: путь вердикта вне грамматики .harness/verdicts//critic/…: .harness/verdicts/critic/contracts-777-v1.md | теги: <нет>
== slashfix   profile verdicts = .harness/verdicts/   (+ `_k193_verdicts_rel="${_k193_verdicts_rel%/}"` после строки 71)
freeze rc=1 | ОТКАЗ: spec-preflight 036 красен (rc=127): … | теги: <нет>
```
- **Батарея копии `slash`** (только значение verdicts в `PROFIL_STANDART` с `/`):
```
193 v13-profil-996-chestnyj KRASNO rc=1 ОТКАЗ: путь вердикта вне грамматики .harness/verdicts//critic/…: .harness/verdicts/critic/contracts-777-v1.md
193 v19… KRASNO   v20… KRASNO   v21… KRASNO   f05… KRASNO   f06-freeze-profil-noga-zelenaja KRASNO
ИТОГ 193: rc=1 KLETKI=65 ZELENYE=59 KRASNYE=6
== slashfix
193 v13-profil-996-chestnyj ok rc=0 КАРТА: 17/17 зелёный
193 f06-freeze-profil-noga-zelenaja ok …
ИТОГ 193: rc=0 KLETKI=65 ZELENYE=65 KRASNYE=0
```
- **Закрывающее свойство.** Каждое значение `workflowPaths.verdicts`, которое принимает `project_paths_resolve`, двери и ноге freeze даёт один и тот же critic-каталог. Честный путь `<каталог>/critic/…` зелёный и при прямом вызове, и через freeze (И8). Простейшая форма — нормализация `%/`, та же, что у freeze:107.
- **Клетка на это состояние** — зона architect (Н-39). Ни одна из 65 клеток и 41 привязки его не ловит.

## 5. Класс Н-446 и мутации вне привязок (повестка 3)

**Н-446 в новом коде.** `grep -nE 'grep -q|bash -c|timeout|\| *(head|tail|grep)' scripts/check_verdict_karta.sh`:
```
64:  || otkaz "профиль битый или workflowPaths вне репо: $(printf '%s' "$_k193_paths" | tail -n 1)"
88:grep -q '^## Карта классов$' <<<"$telo" \
```
- Новые конвейеры — `printf | tail -n 1` (стр. 64) и `printf | jq` (стр. 65). Оба потребителя читают вход до конца, раннего выхода нет. Вход — JSON резолвера или его строка отказа, это сотни байт, а не контракт или вердикт.
- `grep -q` в двери — here-string (стр. 88, без изменений).
- `bash -c` и `timeout` в новом коде нет.
- Класс не введён.

**Мутации новых строк** (`/tmp/dev-harness-verify/Rev193c/mut.sh`). Каждая — в своей одноразовой копии клона, якорь ровно один; судит `--repo .`:
```
MU1-fallback-na-koren rc=1 krasnye: v17-bityj-profil v18-simlink-pobeg-verdikts  | ИТОГ 193: rc=1 KLETKI=65 ZELENYE=63 KRASNYE=2
MU2-dva-globalnyh rc=0 krasnye:  | ИТОГ 193: rc=0 KLETKI=65 ZELENYE=65 KRASNYE=0
MU3-hardkod-kornja rc=1 krasnye: v13 v14 v15 v19 v20 v21 f05 f06  | ИТОГ 193: rc=1 KLETKI=65 ZELENYE=57 KRASNYE=8
MU4-shablon-zvezda rc=1 krasnye: v15-kornevaja-primanka  | ИТОГ 193: rc=1 KLETKI=65 ZELENYE=64 KRASNYE=1
MU5-bez-proverki-kornja rc=0 krasnye:  | ИТОГ 193: rc=0 KLETKI=65 ZELENYE=65 KRASNYE=0
MU6-stderr-poterjan rc=0 krasnye:  | ИТОГ 193: rc=0 KLETKI=65 ZELENYE=65 KRASNYE=0
```
| Мутант | Что сделано | Итог |
|---|---|---|
| MU1 | при отказе резолвера — fallback на `$ROOT/verdicts` | пойман |
| MU2 | второе глобальное разрешение `.harness/verdicts/critic/*` | живой — С-2 |
| MU3 | хардкод корня | пойман |
| MU4 | шаблон `*/critic/*` | пойман |
| MU5 | ветвь «вне корня» снята | эквивалентен: резолвер гарантирует путь внутри ROOT, при пустом выводе отказ даёт шаблон `/critic/*` |
| MU6 | stderr резолвера отброшен | живой — С-3 |

Реализация на ветвях MU2 и MU6 честна: m1/m3 показывают отказ, m4/m5/m6 — названную причину.

## 6. Зоны

`scripts/check_zones.sh .` (полный режим, клон):
```
(первый запуск — rc 1 «реестр заморозок (refs/tags/frozen/*) недоступен: missing-remote»: origin получил новый тег
 frozen/contracts/147/5 после моего fetch; после повторного `git fetch --tags origin`:)
  ok   контракт 043: коммит 9c372335 (implementer) — СПАСЕНО, из суда зон выведен
  ok   контракт 043: коммит fc7c536a (implementer) — СПАСЕНО, из суда зон выведен
  ok   контракт 045: коммит 9c372335 (implementer) — СПАСЕНО, из суда зон выведен
  ok   контракт 045: коммит fc7c536a (implementer) — СПАСЕНО, из суда зон выведен

процессных вне суда:

замороженных контрактов: 181 · объявленных авторов: 5 · коммитов в диапазонах: 64692 · проверено по зонам: 20764
rc=0                                                     (944 с)
```

## 7. Паразитная сложность (050) — новые артефакты диффа

| Артефакт | (1) свойство | (2) состояние | (3) сопряжённые файлы | (4) глубина | (5) потребитель | класс |
|---|---|---|---|---|---|---|
| `. next_id.sh` (NEXT_ID_LIB=1) + вызов `project_paths_resolve "$ROOT"` | И7 «единым project_paths_resolve(ROOT) по 996» | нет нового; читает профиль ROOT; env резолвера (HARNESS_PROJECT_LAYER_ROOT) — семантика 996 | дверь + model + PATERN-якоря v15/v16/v23 = 3 (не выросло: якоря на тот же case) | интерфейс двери не вырос (те же 2 аргумента, rc 0/1/2) | v13–v23, f05–f07 | ESSENTIAL; тот же приём, что в freeze_contract.sh:90 — грамматика не дублируется |
| `command -v jq … ni` | разбор JSON резолвера | нет | 1 | +1 причина rc 2 | — (нет клетки) | ESSENTIAL по факту, безусловность — С-4 |
| ветвь `case "$ROOT"/*` + `otkaz «вне корня»` | И7 «отказ резолвера — именованный отказ» | нет | 1 | — | MU5 эквивалентен | ESSENTIAL как именованная причина пустого вывода, совет не нужен |
| шаблон `"$_k193_verdicts_rel"/critic/*` | И7 путевая часть | `_k193_verdicts_rel` — производная вывода резолвера | 1 (+model) | — | v13–v16 | ESSENTIAL; нормализация — Б-1/С-1 |
| блок шапки «ГРАММАТИКА ПУТИ» (15 строк) | документация двери | нет | 1 | — | — | ESSENTIAL (повтор И7, без новой логики) |

## 8. Строки сверок

СВЕРКА-СТАНДАРТОВ: н/п. `AGENTS.md` харнесса не объявляет `docs/ARCHITECTURE.md` и `docs/CODING-STANDARDS.md` (`grep` пуст), обоих файлов в дереве нет.

СВЕРКА-АРХИТЕКТУРЫ: н/п по инструменту — `tooling/checks/cli.js` и `bindings.json` в дереве отсутствуют, поэтому `finding new` недоступен, и находки записаны в `.review/2026-11-18-116.md`. По существу:

- **Размещение.** Правка — один файл в зоне implementer, новых файлов нет.
- **Зависимости.** Новая — `scripts/next_id.sh` (резолвер 996) из `SELF_DIR`. Её же использует freeze_contract.sh. Код барьера берётся не из судимого дерева.
- **Писатели и операции** не менялись. Дверь только читает (HEAD-блоб, профиль).
- **Долг модели.** Модель-эталон `model/scripts/check_verdict_karta.sh` несёт ту же форму, расхождения нет. Долг не расширен; уровень diff модели — L1 (только путь).

Проводка (038/1): guard — `fixtures/workshop_project/sdacha_193/red_sdacha_193.sh`, барьер именно этого предмета. Подключение — `registry/ci-steps.tsv:318` `check:sdacha-193-family-selftest` (`--repo . && --model && --stabs`), замер — `registry/ci-zamery.tsv:120`. ПРОВОДКА-ЭНФОРСМЕНТ обоснован: поведенческих норм ролей контракт не вводит. Канал не менялся.

Режим проекта (996/1): у харнесса `harness.project.json` без `sourceCanon` (`jq -r '.sourceCanon // "нет"'` → нет) — неприменимо.

Норма не тронута: `roles/`, `AGENTS.md`, `docs/owner/` в диффе отсутствуют.

## 9. Остаток контракта (НЕ ЗАЩИЩАЕТ с ловцом reviewer)

- ОСТАТОК: НЗ-1 (смысловая достаточность доказательств, честность «чисто») — не укусил. Лист 193 перепрогнан дверью целиком: rc 0, «двери=5 карта=17/17 дельта=2». К-08 (41 привязка) и К-15 (census 27/7/10/3) сверены своим счётом (§2).
- ОСТАТОК: К-04 (полнота охвата дверей формы, расположение листа в зоне автора) — не укусил. `fixtures/workshop_project/sdacha_193/SDACHA.md` лежит в `ЗОНА architect` (`:348`).
- ОСТАТОК: НЗ-4 (механическая карта исторических FAIL-вердиктов) — не укусил: дифф этой ветви не касается.
- ОСТАТОК: НЗ-5 (универсальная полнота набора мутаций; сговор субъекта с батареей) — **укусил**, место в диффе — `scripts/check_verdict_karta.sh:67-76`:
  - состояние Б-1 не ловится ни одной клеткой;
  - мутанты MU2 и MU6 живые (С-2, С-3).

  Сговора нет: implementer батарею не правил (`git diff 82d5cfab 4fcd9817 -- fixtures` пуст), architect не трогал `scripts/`.
- ОСТАТОК: НЗ-6 (профильная раскладка контрактов в тегах заморозок) — граница названа контрактом, этим диффом не затронута.

## 10. Что не проверено

- Регресс п.7 (103/191/192/189/190) сам не гонял. По заданию общий регресс берётся из CI (PR #1099 зелёный); там же доклад implementer.
- Полный `verify_antiplacebo` не запускался (по заданию).
- Влияние env `HARNESS_PROJECT_LAYER_ROOT` при НАЛИЧИИ профиля (слой проекта из другого каталога) не исследовал. Это семантика резолвера 996, дверь её только наследует. Без профиля env не влияет (m9).
- Значение `workflowPaths.verdicts`, указывающее на симлинк ВНУТРИ репо, не исследовал. Freeze и дверь читают один и тот же лексический путь из HEAD.

## Развилки

1. **Б-1 — блок, а не совет.** Ни одного живого профиля с хвостовым `/` нет: у харнесса `"verdicts": "verdicts"`. Довод за блок: значение принимает единый резолвер 996, а нормализацию `%/` для него уже пишет второй читатель той же двери — freeze:107. Состояние законно и предусмотрено соседним кодом. На нём И8 ломается полностью: честный accept не заморозить. Это отличается от прецедента Rev193b С-1 (rc 137), где состояние вне алфавита живых листов.
2. **Клетка Б-1 — architect, исправление — implementer** (Н-39). Implementer-у хватает одной строки `${…%/}`. Возможно, вместе со снятием ведущего `./` (С-1).
3. **Развилка implementer (check_provodka без `--grammar` → rc 0) — не дефект.** Контракт п.6 различает «до подключения CI-строки — rc 1» и «после строки и замера оркестратора — rc 0». Строка и замер уже в дереве (`registry/ci-steps.tsv:318`, `registry/ci-zamery.tsv:120`), так что rc 0 — заявленное «после».
