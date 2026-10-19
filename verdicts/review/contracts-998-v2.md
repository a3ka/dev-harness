FAIL
OBJECT=75eb586db0c929cef9c8eeb8d1c814ca73d9b2c1

# Ревью контракта 998 (pravila-modelei), круг 2 — Rev998r2

Сверка шла по frozen-блобу `git show frozen/contracts/998/1^{commit}:contracts/998-pravila-modelei.md`.
Предмет круга 2:
- architect 27e2ff55 (patch-id совпадает с локальным 935dc8453);
- implementer 951e492e, 665d52e8, a88cbf1c, 6f81a4c3, 1b81b857.

Все они вошли в main merge-коммитом 75eb586d. Находки reslop — `review.md`.

**Итог.** Находки круга 1 Р998-1…Р998-6 закрыты, то есть закрыты чекбоксы блокеров 1–6 в
`.review/2026-10-19-12.md`. Советы с1–с6 остаются открытыми. FAIL держится на НОВОМ блокере Р998-7:
правка Р998-3 сузила fail-closed `--prompt` до одной роли orchestrator, а инвариант 1 требует его для любой роли.

## Блокирующая находка

### Р998-7. `--prompt <роль ≠ orchestrator>` больше не отказывает на сломанном routing (инв. 1) — класс: дефект предмета, регрессия круга 2

Фрагмент: `scripts/gen-harness.ts:161-172`. Барьер `checkRoutingStrict` теперь стоит внутри
`if (r.slug === 'orchestrator')`; коммит 665d52e8 называется «барьер routing только в --check и --prompt orchestrator».

Что нарушено (frozen):
- инв. 1 — «отвергается в ОБЕИХ точках входа генератора (`--check` и `--prompt <роль>`) отказом rc 1»;
- Frontier — «в `--prompt` (fail-closed на каждой сессии)»;
- модель угроз — «в `--prompt` (каждая сессия) — fail-closed обеих точек»;
- честная модель frozen-тега `fixtures/pravila_modelei_998/model_gen.ts:128` — «fail-closed: --prompt
  судит ту же грамматику, что и --check (каждая сессия)», отказ стоит до выбора роли.

Находка Р998-3 просила снять барьер только с `--into`/`--resolve-overlay`/`--agents-rules`.
`--prompt` среди этих трёх режимов не назван.

Потребитель: `workshop:613` и `workshop:873` — `node gen-harness.ts --prompt "$SESSION_ROLE"`, промпт каждой сессии.

**Обход** (rc). Дерево OBJECT, из `config/agent_models.json` удалён `routing`:
- проба 998 зелёная (её клетки зовут только `--prompt orchestrator`);
- `--prompt implementer` даёт rc 0 без диагноза, и сессия implementer стартует молча.

```
$ bash exp.sh 75eb586d obj        # одноразовый worktree exp/obj
obj drop --prompt orchestrator rc=1 err='FAIL routing: routing: секция отсутствует'
obj drop --prompt implementer rc=0 err=''
obj drop --prompt architect rc=0 err=''
obj drop --prompt implementer-glm rc=0 err=''
obj drop --check rc=1 err='FAIL routing: routing: секция отсутствует'
obj badkey --prompt implementer rc=0 err=''
obj badrole --prompt implementer rc=0 err=''
obj badtier --prompt implementer rc=0 err=''
$ bash exp.sh 9aa86e73 r1         # круг 1 — для сравнения
r1 drop --prompt implementer rc=1 err='FAIL routing: routing: секция отсутствует'
r1 badrole --prompt architect rc=1 err='FAIL routing: routing.rules[0]: роль «nosuchrole» отсутствует в roles-таблице config/agent_models.json'
$ bash exp2.sh                    # честная модель архитектора против субъекта, routing снесён
drop --prompt orchestrator: model_gen rc=1 [  FAIL routing: секция отсутствует или не объект] ; subject rc=1 [FAIL routing: routing: секция отсутствует]
drop --prompt implementer: model_gen rc=1 [  FAIL routing: секция отсутствует или не объект] ; subject rc=0 []
drop --prompt architect: model_gen rc=1 [  FAIL routing: секция отсутствует или не объект] ; subject rc=0 []
$ bash fixtures/pravila_modelei_998/probe.sh     # на OBJECT — зелёная, дефекта не видит
census cases: исполнено 50, расхождений 0
census matrix: исполнено 65, расхождений 0
probe_rc=0
```

**Более простая форма проходит те же строки приёмки.** Барьер вызывается один раз в `--prompt`
до ветки orchestrator (`exp3.sh`, `gen-harness.ts` +2/−5):
```
patched drop --prompt orchestrator rc=1 [FAIL routing: routing: секция отсутствует]
patched drop --prompt implementer rc=1 [FAIL routing: routing: секция отсутствует]
patched drop --into rc=0
patched drop --resolve-overlay rc=0
patched drop --agents-rules rc=0
patched probe rc=0
census cases: исполнено 50, расхождений 0
census matrix: исполнено 65, расхождений 0
```

Порядок починки по Н-39:
1. architect добавляет клетку: `--prompt <роль≠orchestrator>` на сломанном routing ⇒ rc 1 с именованием routing.
   К ней — обманку «барьер только для orchestrator». На OBJECT клетка обязана быть красной.
2. Затем правит implementer.

Пробел батареи, через который дефект прошёл, вынесен в совет Р998-с7.

## Закрытие Р998-1…Р998-6 — своей мерой, на входах, отличных от входов автора

| Находка | Коммит | Моя мера | Результат |
|---|---|---|---|
| Р998-1 | 951e492e | `exp2.sh`: правило 9 `role: consultant`→`tier: consultant`, правило 11 `role: steward`→`tier: steward` (в клетке архитектора только правило 9) | `consultant_tier: --check rc=0 --prompt rc=0 identical=False` (`→ role: consultant` / `→ tier: consultant`); `steward_tier: … identical=False` (`→ role: steward` / `→ tier: steward`). **Закрыта** |
| Р998-2 | 6f81a4c3 | `registry/ci-steps.tsv:136` = `step check:pravila-modelei-998 6 bash fixtures/pravila_modelei_998/probe.sh`. Lane на OBJECT печатает `+ bash fixtures/pravila_modelei_998/probe.sh`, `census cases: 50/0`, `census matrix: 65/0`, rc 0. Вариация: `decoy_form_blind.ts` заменён честной моделью (в круге 1 менялся `decoy_hardcoded`) | `lane rc=1`, `census matrix: исполнено 65, расхождений 1`. **Закрыта.** Вес 6 ≠ 10 — совет с10 |
| Р998-3 | 665d52e8 | `exp.sh` на OBJECT / дереве до 998 (22be79c0^), мутации drop/badkey/badrole/badtier | OBJECT: `--resolve-overlay`/`--agents-rules`/`--into` rc 0 на всех четырёх; до 998 — то же. **Закрыта для трёх названных режимов**, сверх этого сузила `--prompt` (Р998-7) |
| Р998-4 | 1b81b857 | `git diff 22be79c0^ OBJECT -- roles/orchestrator.md` | Только `+## Выбор роли субагента по routing`, пустая строка, норма-строка, пустая строка — ПОСЛЕ тела 016 («Не обходи `--no-verify`»). Производная `.omp/agents/orchestrator.md` такая же (diff 1b81b857). **Закрыта** |
| Р998-5 | 1b81b857 | `grep -n 'opus\|Opus\|НЕ \`@fable\`' roles/consultant.md` | 0 строк; §Модель: `tiers.consultant.fallback = @fable` — так же, как в конфиге. **Закрыта** (совет с12) |
| Р998-6 | a88cbf1c | grep `checkRouting\b(?!Strict)` по `scripts;fixtures;workshop` | `No matches found`. **Закрыта** |

Чекбоксы `.review/2026-10-19-12.md`:
- закрыты блокеры **1, 2, 3, 4, 5, 6** (Р998-1…Р998-6);
- советы **с1–с6** открыты: с1 — частично, 1b81b857 по-прежнему несёт Р998-4 и Р998-5; с3 — в выводе нет пустой строки
  перед заголовком (строки 449→450); с6 — пустой строки после `## Модель` нет, файл кончается `\n\n`;
  с2, с4, с5 не тронуты.

## Проверки не переписаны под код; красное предъявлено

```
$ git show 27e2ff55 | git patch-id --stable          # в клоне
22250ed3898d3c6cfd70da25b198a136b0d33122 27e2ff55…
$ git show 935dc8453 | git patch-id --stable         # в основном чекауте, read-only
22250ed3898d3c6cfd70da25b198a136b0d33122 935dc8453…
$ git show --stat 27e2ff55     → 4 files changed, 722 insertions(+)   (0 удалений: прежние клетки не тронуты)
$ git diff --stat 27e2ff55 75eb586d -- fixtures/pravila_modelei_998 contracts/998-pravila-modelei.md   → пусто, rc=0
$ git diff --stat frozen/contracts/998/1 27e2ff55 -- contracts/998-pravila-modelei.md               → пусто, rc=0
$ bash exp4.sh      # дерево круга 1 (9aa86e73) + проба OBJECT
r1-tree + OBJECT-probe --cases rc=1
census cases: исполнено 50, расхождений 4
CASE cases gen_render_target_form_distinct: РАСХОЖДЕНИЕ — рендер не различает форму цели …
CASE cases gen_modes_isolated_from_routing: РАСХОЖДЕНИЕ — routing отсутствует/--resolve-overlay: rc=1 (до предмета 0 …
CASE cases ci_step_full_probe: РАСХОЖДЕНИЕ — команда шага «bash fixtures/pravila_modelei_998/probe.sh --cases» урезает пробу …
CASE cases orchestrator_role_016_body_intact: РАСХОЖДЕНИЕ — секция «## Страж staged-коммитов активен (016)» разрезана …
--matrix rc=0
census matrix: исполнено 65, расхождений 0
```

Заявка архитектора «OBJECT 50/4 (ровно новые красные)» подтверждена своей мерой. Р998-5 и Р998-6
клеток не имеют (cognitive-only и 050), их закрытие проверено напрямую — см. таблицу.

## Scoped-регресс на OBJECT

| Команда | rc | Вывод |
|---|---|---|
| `bash fixtures/pravila_modelei_998/probe.sh` | 0 | `census cases: исполнено 50, расхождений 0` / `census matrix: исполнено 65, расхождений 0`; подсчёт своей мерой `grep -c '^CASE cases .*: ok'` = 50, `grep -c '^CASE matrix .*: ok'` = 65 |
| `bash scripts/run_ci_lane.sh check:pravila-modelei-998` | 0 | `+ bash fixtures/pravila_modelei_998/probe.sh`, census 50/0 и 65/0, real 9.95 с |
| `npm run --silent gen:harness -- --check` | 0 | `харнес соответствует roles/ (10 ролей)` |
| `bash scripts/run_ci_lane.sh check:gen` (`registry/ci-steps.tsv:103`) | 0 | `+ npm run check:gen` |
| `bash scripts/gen_ci_steps.sh --check` и lane `check:gen-ci-steps-coherence` | 0 / 0 | — |
| `bash scripts/check_provodka.sh "$PWD" contracts/998-pravila-modelei.md` | 0 | — |
| `npm run --silent check:antiplacebo -- --scope check_provodka` | 0 | `барьеров: 1 · фикстур: 28 · предъявлено красным повторным прогоном: 28` |
| `bash scripts/check_zones.sh` | 0 | 6f81a4c3 (ci.yml) не отмечен — union-зоны |

Через `reslop t -- <команда>` то же самое: все шесть команд дали `exit: 0`.

Неизменность frozen-барьеров. `git diff --stat 27e2ff55 1b81b857` даёт 8 файлов:
`.github/workflows/ci.yml`, `.omp/agents/{consultant,orchestrator}.md`, `registry/ci-steps.tsv`,
`roles/{consultant,orchestrator}.md`, `scripts/{gen-harness,roles}.ts`. Коммит architect 27e2ff55 трогает
только `fixtures/pravila_modelei_998/`. `scripts/check_*`, `scripts/verify_*`, `fixtures/gen-harness/`
диффом не тронуты.

## Область правки и атомарность

- Implementer в круге 2 правил 7 путей из своей ЗОНЫ 998, плюс `.github/workflows/ci.yml`. По frozen 998 ci.yml —
  ЗОНА orchestrator, но union-зоны (002/003/…/059 implementer) его покрывают, поэтому `check_zones.sh`
  rc 0. Содержимое производное: `gen_ci_steps --check` rc 0. Совет с9.
- Норма не тронута молча: в roles/* правки только в оговорённых местах (норма-строка инв. 7, §Модель консультанта).
- Каждой находке — свой коммит со ссылкой на номер, кроме 1b81b857 (Р998-4 + Р998-5) — совет с1.
- Коммиты 998 вошли в main под маркером `land: wip/996/implementer` (75eb586d^2 = 1b81b857) — совет с8.

## ПРОВОДКА-каналы

- role-канал: норма-строка инв. 7 в `roles/orchestrator.md` стоит дословно, под своим заголовком,
  секцию 016 больше не режет. `check_provodka` rc 0.
- guard: `fixtures/pravila_modelei_998/probe.sh` — барьер именно этого предмета. Шаг реестра исполняет его
  ЦЕЛИКОМ: `cases` + `matrix`; ключ `check:pravila-modelei-998` есть в shard l7 ci.yml.
- ПРОВОДКА-ЭНФОРСМЕНТ обоснован честно. Его пункт «fail-closed обеих точек входа» на OBJECT выполнен
  только для одной роли — это Р998-7.

## Паразитная сложность (контракт 050) — артефакты круга 2

| Артефакт | (1) свойство | (2) состояние | (3) файлы при следующей правке | (4) глубина | (5) потребитель | Класс |
|---|---|---|---|---|---|---|
| `renderRoutingSection`: цель как `role: X` / `tier: X` | инв. 3 (смена формы цели) | нет | 1, не выросло | интерфейс прежний | `--prompt orchestrator`, клетка `gen_render_target_form_distinct` | ESSENTIAL |
| перенос барьера: блок gate в `--prompt orchestrator` (:168-172) и в `--check` (:411-415) | инв. 1 + ПЕРЕСЕЧЕНИЕ 054 | нет | 2 места вместо 1 — выросло | общая логика уже в `checkRoutingStrict`, повторяется печать+exit | `--check`, `--prompt` | ESSENTIAL по свойству; удвоение — совет с11; сужение до orchestrator — Р998-7 |
| удаление `checkRouting` | — (минус артефакт) | — | −1 | — | — | закрывает Р998-6 |
| step-строка: аргументы сняты, вес 6, 5 строк комментария | ПРОВОДКА guard | нет | 2 (tsv + ci.yml генератором), не выросло | — | CI l7 | ESSENTIAL; вес — совет с10 |
| `decoy_form_blind.ts`, `decoy_module_barrier.ts` (семья обманок) | различимость инв. 3 и ПЕРЕСЕЧЕНИЯ 054 в матрице | нет | 1 семья | — | `probe.sh --matrix`, CI | ESSENTIAL |
| `probe.py` +304 (4 клетки cases, 8 matrix), `model_gen.ts` +31 (режимы 054) | Р998-1…4 как красные клетки | нет | 1 | — | `probe.sh`, CI | ESSENTIAL; пробел `--prompt <не orchestrator>` — совет с7 |

ACCIDENTAL-блокеров в круге 2 нет.

## Новые советы (не блокируют) — подробно в review.md

- с7 — пробел батареи: клетки не зовут `--prompt <роль≠orchestrator>` на сломанном routing.
- с8 — коммиты 998 вошли в main под чужим маркером `land: wip/996/implementer`.
- с9 — ci.yml правил implementer, а по 998 это ЗОНА orchestrator; законно по union.
- с10 — вес 6 «по замеру 5.57 с» моей мерой не подтверждён: 9.89 / 11.76 / 13.81 с; замороженный вес 10.
- с11 — блок gate существует в двух копиях.
- с12 — consultant §Модель дословно повторяет значения конфига (класс Н-51).
