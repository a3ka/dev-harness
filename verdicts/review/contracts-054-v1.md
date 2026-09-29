FAIL
# Ревью 054 — консолидация кругов 1–3 (профиль два слоя + лаунчер), HEAD 7fbe7c5

Судья: reviewer (семейство, отличное от автора). Контракты: `frozen/contracts/054/1`
(tag-object 53dbc719 = строка реестра `054 → 53dbc719…`) и `frozen/contracts/057/1`
(eba0f818 = строка `057 → eba0f818…`). Судимое круга 3: фикс-Б7 9a5b42f (land 7fbe7c5,
автор `implementer`) + закрытие Б6 реализацией 057 (748f617, land 6fd291b; 057 done по
вердикту f11e43e). Прогоны — одноразовый ssh-клон
`/tmp/dev-harness-verify/rev054k3-1790654510` (HEAD 7fbe7c5) и его копии под мутанты;
основной чекаут только читался.
Сырьё кругов 1–2 (b11h/cto/lit/unk, fd-first 0/200, формы barriers) — в редакции этого
файла на 9cd6bf2; здесь сведено таблицей «Б1–Б9» и строками паразитной сложности.

## Итог одной строкой

Б6 и Б7 закрыты живьём: m1–m6 в батарее, мутант замещения ветви barriers красен на m6
`barriers.optional`; `defaults.git`/`defaults.ci` сливаются с правильным происхождением
(repo задаёт → origin repo; только слой проекта → origin project), silent-drop-мутант красен
на m7. Все приёмки зелёные (батарея rc 0 N=37=C, parsing 4/4, frozen-diff пуст, scoped
9/9 локально и в CI 7fbe7c5). Но фикс-Б7 открыл новый путь выхода НЕВАЛИДНЫХ значений:
**Б8** — `defaults.git.canonicalRemote`/`defaults.ci.workflow` слоя проекта не проходят
проверку И-4 и теперь попадают в merged с rc 0 (число, пустая строка, массив). И малая
**Б9** (050, ACCIDENTAL с тремя частями) — недостижимая ветвь `m7)` во внутреннем
диспетчере.

## Красный вход (Н-165 п.2)

```text
круг 1  до=после: ee1444766dcd4467db3622d64fb78505aacf55ea130e7fa18cacf1e3b6ce0f09  .git/config
круг 2  до=после: ee1444766dcd4467db3622d64fb78505aacf55ea130e7fa18cacf1e3b6ce0f09  .git/config
круг 3  до:       ee1444766dcd4467db3622d64fb78505aacf55ea130e7fa18cacf1e3b6ce0f09  .git/config
круг 3  середина: ee1444766dcd4467db3622d64fb78505aacf55ea130e7fa18cacf1e3b6ce0f09  (HEAD 7fbe7c5, status 0 строк)
круг 3  после:    в сообщении коммита вердикта
```

## (а) Б7 — закрыт по поведению (моя мера `k3.sh`, выброшен; свои JSON, не фикстуры батареи)

Репо — только обязательные поля плюс указанное; слой — обязательные плюс `defaults`.

```text
-- forms against HEAD 7fbe7c5
== REPO_WINS  rc=0 git={"value":{"canonicalRemote":"git@h:REPO.git"},"origin":"repo"} ci={"value":{"workflow":"repo-ci.yml"},"origin":"repo"}
== PROJ_ONLY  rc=0 git={"value":{"canonicalRemote":"git@h:PROJ.git"},"origin":"project"} ci={"value":{"workflow":"proj-ci.yml"},"origin":"project"}
== MIX        rc=0 git={…"git@h:REPO.git"},"origin":"repo"} ci={…"proj-ci.yml"},"origin":"project"}   (репо задал только git)
== NONE       rc=0 git="<absent>" ci="<absent>"
== FORM_P     rc=0 bm=[["check_no_leak"],"repo"] bo=[["d_opt"],"project"]
== BAD_GIT_K  rc=1 profile ОТКАЗ: неизвестный ключ слой-проекта: defaults.git.bogus
```

И-6 («лист из репо, если ключ там есть, иначе из `defaults`») выполнен на всех четырёх
формах. Барьер — клетка m7 (`red_profil_dva_sloja.sh:1288–1397`), красна против
silent-drop-мутанта (моя правка, не якорь клетки: regex-удаление обеих строк
`elif $p.defaults.{git,ci}`, 2−):

```text
-- forms against mutant SD: PROJ_ONLY rc=0 git="<absent>" ci="<absent>"; MIX ci="<absent>"
### SD RUNNER_RC=1 C=37
m7: честный git.origin != project (silent-drop Б7)
054-батарея ОТКАЗ: ЧЕСТНАЯ ЧАСТЬ: клетка m7 красная
итог 054: rc=1
```

## (б) Б6 — закрыт (m1–m6 в батарее, мутант замещения красен на m6)

Мой мутант замещения (`k3.sh mut_rb`, 1+/1−): ветвь `barriers.optional` —
`if $r.barriers then (лист репо или null) elif $p.defaults…` (объект barriers репо
замещает ветвь целиком, семантика 057 п.5б):

```text
-- forms against mutant RB: FORM_P rc=0 bm=[["check_no_leak"],"repo"] bo=[null,null]   ← barriers.optional потерян
                           REPO_WINS/PROJ_ONLY/MIX/NONE — идентично честному (мутант неотличим вне формы P)
### RB RUNNER_RC=1 C=36
m6: честный barriers.optional.origin != project
054-батарея ОТКАЗ: ЧЕСТНАЯ ЧАСТЬ: клетка m6 красная
итог 054: rc=1
npm run check:antiplacebo -- --scope profile_resolver (RB) → 9/9, rc 0 — ожидаемо: 057 п.5б
    судит батарею, CI-канал case_* этот мутант не обязан ловить
```

## (в) Приёмки живьём (клон 7fbe7c5; батареи — ПОСЛЕДОВАТЕЛЬНО, см. С9)

```text
bash fixtures/_krasnye_054.sh              → RUNNER_RC=0; стаб-пак: просмотрено 20, поймано 20;
    b11h: ok=75 refused=53 leak=0 (RACE_N=128); b11m: … leak=11 (мутант);
    m6: честный rc=0 листовое слияние; мутант rc=0 barriers.optional потерян (различение работает)
    m7: честный rc=0 defaults.git/ci merged origin=project; мутант … (различение работает)
    честная часть: проверено предъявлений 37 ; итог 054: rc=0
    внешняя мера п.1б: C = grep -c '^СВЕРКА: ' = 37 → N=37=C (было 36 до m7; +1 = m7)
bash fixtures/parsing_hygiene_battery/run_battery.sh profile_resolver → итог 4/4 классов закрыто, PARSING_RC=0
npm run check:antiplacebo -- --scope profile_resolver → «предъявлено красным повторным прогоном: 9», AP_RC=0
CI run 36518376504 на 7fbe7c5: ci + ap1..ap5 — 6/6 success; в логе ap5 9 строк `ok profile_resolver/case_*`
    (моя мера: gh run view --log | grep -c 'profile_resolver/case_' → 9)
git diff --stat frozen/contracts/054/1 HEAD -- contracts/054-…md → пусто, rc=0
git diff --stat frozen/contracts/057/1 HEAD -- contracts/057-…md → пусто, rc=0
реестр: 054 → 53dbc719… = rev-parse frozen/contracts/054/1; 057 → eba0f818… = rev-parse frozen/contracts/057/1
bash scripts/check_zones.sh . → ZONES_RC=0; 054 ok, 057 ok; единственный FAIL — предсуществующая
    грамматика ЗОНА контракта 055 (не 054/057)
```

Первый параллельный прогон четырёх батарей дал ложный красный `k8` на ВСЕХ деревьях,
включая честное (C=5, rc 1); одиночный прогон честного — зелёный. Причина: probe
пишет промпт в общий `~/.local/state/dev-harness-projects/p1/home/session-prompt-…md` —
параллельные батареи гоняются за одним файлом. Все числа выше — из последовательных
прогонов. См. С9.

## Область (п.1), атомарность (п.5), норма (п.6), история проверок (п.3)

9a5b42f, автор `implementer`: `scripts/profile_resolver.sh` (+14/−2, только ветви
`git`/`ci` слияния) и `fixtures/workshop_project/red_profil_dva_sloja.sh` (+117/−2:
`cell_m7`, имя в двух списках, С5 — `*) return 1` в двух внутренних диспетчерах). Оба
пути — ЗОНА implementer 054. Один коммит, ссылка «054 фикс-Б7»; С5 — мелкий довесок того
же предмета и того же файла — принимаю. Нормативные документы, контракты, `fixtures/
profile_resolver/`, parsing-профиль не тронуты (`git log 20cf7d4..7fbe7c5 -- fixtures/
profile_resolver fixtures/parsing_hygiene_battery contracts` → пусто). Проверки 054 правит
автор реализации — это новая клетка своего фикса, прежние ожидания не менялись.
Счётное утверждение коммита «37 честных предъявлений» — подтверждено другой мерой (C=37).

## Находки

### Б8 — БЛОКЕР (семантика; И-4 frozen 054 «`canonicalRemote`, `ci.workflow` — непустые строки … Нарушение → rc 1, P6 с полем и значением»; отрицательный вход серии — нарушен ровно И-4)

Фрагмент: `scripts/profile_resolver.sh:357–369` проверяет тип/непустоту `ci.workflow` и
`git.canonicalRemote` ТОЛЬКО репо-слоя; строки 398–399 проверяют `defaults.commands` и
`defaults.workflowPaths` слоя проекта, но `defaults.git`/`defaults.ci` — нет. Фикс-Б7
(`:551`, `:556`) выводит эти непроверенные значения в merged.

```text
## HEAD 7fbe7c5 (val.sh, выброшен)                  ## PRE-FIX 20cf7d4 (тот же вход)
P_ci_num    rc=0 ci={"value":{"workflow":7},"origin":"project"}          rc=0 ci="-"
P_ci_empty  rc=0 ci={"value":{"workflow":""},"origin":"project"}         rc=0 ci="-"
P_git_empty rc=0 git={"value":{"canonicalRemote":""},"origin":"project"} rc=0 git="-"
P_git_num   rc=0 git={"value":{"canonicalRemote":[1]},"origin":"project"} rc=0 git="-"
контроль той же нормы на соседних листьях (HEAD и PRE-FIX одинаково):
P_cmd_num   rc=1 profile ОТКАЗ: значение вне алфавита: defaults.commands.test: <number>
P_wp_empty  rc=1 profile ОТКАЗ: значение вне алфавита: defaults.workflowPaths.contracts: пусто
R_ci_num    rc=1 profile ОТКАЗ: значение вне алфавита: ci.workflow: <number>
R_git_empty rc=1 profile ОТКАЗ: значение вне алфавита: canonicalRemote: пусто
```

Противоречие: одно и то же значение отвергается P6 в репо-слое и в соседних ветвях
`defaults`, но в `defaults.git`/`defaults.ci` принимается rc 0 — и после фикс-Б7 уходит
потребителю (`ci.workflow` = 7 для В5, `canonicalRemote` = "" для gitw). До фикса дыра
в валидации была, но значение молча выпадало; фикс превратил её в выдачу невалидного
значения с происхождением `project`. Ни батарея 054 (37/37), ни parsing-батарея 041 (4/4),
ни case_* (9/9) это не видят. Более простая форма, проверенная мной на копии
резолвера (+2 строки после `:399`):

```text
check_object_strings "$PROJECT_JSON_FD" defaults.git canonicalRemote
check_object_strings "$PROJECT_JSON_FD" defaults.ci workflow
→ P_ci_num    rc=1 profile ОТКАЗ: значение вне алфавита: defaults.ci.workflow: <number>
  P_ci_empty  rc=1 … defaults.ci.workflow: пусто
  P_git_empty rc=1 … defaults.git.canonicalRemote: пусто
  P_git_num   rc=1 … defaults.git.canonicalRemote: <array>
```

Барьер нужен по той же мерке, что m7: клетка с `defaults.ci.workflow` не строкой /
пустой → rc 1, P6 назван путь. Причина — не повтор Б7 (И-6, выпадение листа), а И-4
(валидация значения); правило «два отказа по одной причине → арбитр» по моей оценке не
срабатывает. Если оркестратор сочтёт Б8 продолжением Б7 (та же ветвь слияния) — это
вопрос арбитру, не мне.

### Б9 — БЛОКЕР по букве 050 (ACCIDENTAL с тремя частями), тривиальный

Фрагмент: `red_profil_dva_sloja.sh:1755` — `m7) cell_m7 "$PROFILE_RESOLVER" ;;` в
`cell_resolver_run`. Отсутствующее свойство: ветвь недостижима — `dispatch_honest_cell`
шлёт в `cell_resolver_run` только `k2|k3|k3b|k4|k4b|k5|k6|k9|k11|b1|b2|b3|b7|b9|b10|m1..m5`
(`:1555`), `m7` уходит напрямую в `cell_m7` (`:1563`); других вызовов
`cell_resolver_run` нет (grep). Имя клетки теперь в четырёх местах вместо трёх (С5-класс).
Более простая форма: удалить строку 1755 — приёмка (батарея rc 0, m7 зелёная, SD-мутант
красный на m7) не меняется, поскольку путь не исполняется.

### Советы (не блокируют)

- С10. Приоритет repo > project для `git`/`ci` не сверяется семантически ни одной клеткой. Мой мутант
  PS (ветви `git` переставлены: слой проекта раньше репо, 2+/2−):
  ```text
  -- forms against mutant PS: REPO_WINS rc=0 git={…"git@h:PROJ.git"},"origin":"project"}  ← репо проиграл
  ### PS RUNNER_RC=1 C=37
  m7: КРАСНАЯ — патч не применился: anchored git/ci-блок не найден
  итог 054: rc=1
  ```
  Батарея красна, но ТОЛЬКО дрейфом якоря m7 (любая правка текста git/ci-блока), не
  семантической сверкой: мутант, меняющий приоритет вне дословного блока (например,
  пост-обработкой `| .git.origin = …`), якорь не заденет, и ни одна клетка не сверит
  `git.origin` при заданных обоих слоях.
  m2/m4 задают разные `canonicalRemote` в обоих слоях, но `git.origin` не сверяют —
  дописать туда одну строку сверки дешевле новой клетки. Замороженной строки, требующей
  этот барьер, нет (к9 держит приоритет только для `language`) — совет.
- С9. Батарея 054 неизолирована от параллельного прогона: `workshop --probe` пишет в общий
  `~/.local/state/dev-harness-projects/p1/…` (projectId `p1` у всех toy-репо), параллельные
  прогоны дают ложный красный `k8`. Сегодня батарея в CI не гоняется; при подключении —
  `HOME`/state под `$WORK`.
- С8. `defaults.language` слоя проекта вне алфавита (`python`) принимается rc 0
  (HEAD и 20cf7d4 одинаково) — в вывод не попадает, т.к. `language` репо обязателен.
  Тот же класс, что Б8, но без выдачи; вне круга 3 (не вносилось фиксом).
- С5 круга 2 — закрыт (`*) return 1` в обоих внутренних диспетчерах, 9a5b42f).
- С6/С7 круга 2, С1/С3 круга 1 — в силе, вне круга 3.

## Паразитная сложность (контракт 050) — артефакты 9a5b42f

- ветви `elif $p.defaults.{git,ci}` (`:549–558`): (1) И-4/И-6 054; (2) нет; (3) 1 —
  плюс дословный якорь в m7 (2 файла; тот же рецепт Ч-5, что m6); (4) интерфейс не
  меняется; (5) m7. ESSENTIAL — но без валидации значения (Б8).
- `cell_m7` (~110 стр.): (1) И-6 + демаркация 054 «стаб/мутант расходится с честным на
  своей клетке» в форме Ч-5 057 (прецедент m6); (2) копия резолвера
  `$WORK/m7-mutated.sh`, итог печатается строкой `m7: …` — явно; (3) якорь
  git/ci-блока — 2 файла меняются вместе, выросло на 1 (осознанно: дрейф якоря → красная
  именованно); (4) интерфейс — путь субъекта; (5) батарея `_krasnye_054.sh` (не CI —
  как и m1–m6). ESSENTIAL. Встроенная половина-мутант дублирует то, что уже даёт
  честная половина против внешнего мутанта (SD красен на честной половине m7), —
  но это принятая 057 форма, не второй рецепт.
- имя `m7` в HONEST_CELLS + `dispatch_honest_cell`: ESSENTIAL; в `cell_resolver_run` —
  ACCIDENTAL, Б9.
- `*) return 1` ×2: (1) fail-closed диспетчера Ч-6 057; (2)–(5) без нового состояния и
  интерфейса. ESSENTIAL (закрывает С5).

Артефакты кругов 1–2 — строки кругов 1–2 в силе (сводка: резолвер, `workshop --probe`,
`gen-harness --agents-rules`, parsing-профиль, `cell_b11h`, `cell_b11m`, case_*-семья,
ключ `profile_resolver` в ci.yml, `BATTERY_RC` — ESSENTIAL; дубль предиката стаб/честная
сторона — совет С5-класса).

## Б1–Б7 — сводка кругов 1–3

| Блокер | Круг открытия | Закрыт | Доказательство закрытия |
|---|---|---|---|
| Б1 честная b11 против стаба | 1 | 057 (к2) | b11h leak=0/128 честный; мутант cto leak=13 → rc 1 |
| Б2 раннер глотает rc | 1 | 057 (к2) | honest 0, cto 1; SD/RB к3 → RUNNER_RC=1 |
| Б3 конформный вход отвергнут | 1 | 057 (к2) | формы A/G/F/C/M/P rc 0 |
| Б4 нет guard-канала | 1 | 057 (к2) | 9/9 case_* локально и в CI 7fbe7c5 |
| Б5 фразы не дословны | 1 | 057 (к2) | P4 дословно; N=C |
| Б6 нет m1–m6 / мутант замещения зелёный | 2 | 057 (к3) | RB → m6 красна `barriers.optional` |
| Б7 defaults.git/ci молча выпадают | 2 | 9a5b42f (к3) | формы REPO_WINS/PROJ_ONLY/MIX; SD → m7 красна |
| Б8 defaults.git/ci без И-4 | 3 | — | P_ci_num rc 0 `workflow:7` |
| Б9 мёртвая ветвь m7 | 3 | — | `:1755` недостижима |

## (г) Развилка

ЗАКРЫТА словом владельца (HANDOFF.md:112): «Развилка «где наши артефакты» ЗАКРЫТА словом
владельца: .harness/ в самом репо. Консультанта НЕ собирать.»; HANDOFF.md:136 — «в
вердикте ревьюера 054 отмечаем решение владельца» — отмечено. Механизм 054 инвариантен
(пути — значения `workflowPaths.*`); каталога `.harness/` в дереве dev-harness нет и не
требуется — решение касается репо проекта. Строка HANDOFF.md:335 («ЧЕРЕЗ КОНСУЛЬТАНТА 029»)
устарела относительно п.2 — к сведению оркестратора.

## (д) Красный вход — см. блок выше; основной чекаут не менялся (HEAD 7fbe7c5, status пуст).

## Вердикт

**FAIL.** Б6 и Б7 — закрыты живьём своей мерой (RB красен на m6 `barriers.optional`, SD
красен на m7; формы git/ci с верным происхождением); все приёмки 054/057 зелёные, CI 6/6.
Блокирует **Б8**: фикс-Б7 выпустил в merged значения `defaults.git.canonicalRemote`/
`defaults.ci.workflow`, не прошедшие И-4 (`workflow: 7`, `""`, `[1]` → rc 0); исправление —
две строки `check_object_strings` плюс клетка, доказано на копии. **Б9** — одна мёртвая
строка по букве 050. Это не повтор причин кругов 1–2. Сигнал пилоту — НЕТ до закрытия
Б8/Б9; остальное принимается как есть.
