accept
# Ревью 054 — консолидация кругов 1–4 (профиль два слоя + лаунчер), HEAD 56f436b

Судья: reviewer (семейство, отличное от автора). Контракты: `frozen/contracts/054/1`
(tag-object 53dbc719 = строка реестра `054 → 53dbc719…`) и `frozen/contracts/057/1`
(eba0f818 = строка `057 → eba0f818…`). Судимое круга 4 — ТОЛЬКО закрытие Б8+Б9:
фикс b9237dc (автор `implementer`, land 56f436b). Прочее кругов 1–3 не пересуживалось.
Прогоны — одноразовый ssh-клон `/tmp/dev-harness-verify/rev054k4-1790657163` (HEAD
56f436b) и его копия `rev054k4-revert` под мутант отката; основной чекаут только читался.
Сырьё кругов 1–2 — в редакции файла на 9cd6bf2, круга 3 — на ac9439a; здесь сведено.

## Итог одной строкой

Б8 закрыт живьём: `defaults.ci.workflow: 7`, `defaults.git.canonicalRemote: ""`,
`defaults.git.canonicalRemote: [1]` → rc 1, P6 с полем и значением; нормальные формы
REPO_WINS/PROJ_ONLY/MIX/NONE → rc 0 с прежним происхождением; мутант отката двух строк
возвращает rc 0 на всех трёх входах (красное предъявлено). Б9 закрыт: исполняемой ветви
`m7)` в `cell_resolver_run` нет. Приёмки: батарея rc 0 N=37=C, parsing 4/4, scoped 9/9,
frozen-diff пуст, CI 36521842789 на 56f436b — 6/6. Блокеров Б1–Б9 открытых нет.
**accept — 054 done; сигнал пилоту владельцу.**

## Красный вход (Н-165 п.2)

```text
круг 1  до=после: ee1444766dcd4467db3622d64fb78505aacf55ea130e7fa18cacf1e3b6ce0f09  .git/config
круг 2  до=после: ee1444766dcd4467db3622d64fb78505aacf55ea130e7fa18cacf1e3b6ce0f09  .git/config
круг 3  до=после: ee1444766dcd4467db3622d64fb78505aacf55ea130e7fa18cacf1e3b6ce0f09  .git/config
круг 4  до:       ee1444766dcd4467db3622d64fb78505aacf55ea130e7fa18cacf1e3b6ce0f09  (HEAD 56f436b, status 0 строк)
круг 4  середина: ee1444766dcd4467db3622d64fb78505aacf55ea130e7fa18cacf1e3b6ce0f09  (HEAD 56f436b, status 0 строк)
круг 4  после:    в сообщении коммита вердикта
```

## Круг 4

### (а) Б8 — закрыт (моя мера `k4.sh`, выброшен; свои JSON, не фикстуры 054)

Репо — только обязательные поля плюс указанное; слой — обязательные плюс `defaults`
(`language` + `workflowPaths` + проверяемая ветвь). Мутант REVERT — копия резолвера
56f436b без двух строк b9237dc (`diff`: `405,406d404`, ровно
`check_object_strings "$PROJECT_JSON_FD" defaults.{git,ci} …`).

```text
                     == HEAD 56f436b                                                          == REVERT
P_ci_num    rc=1 profile ОТКАЗ: значение вне алфавита: defaults.ci.workflow: <number>        rc=0 ci={"value":{"workflow":7},"origin":"project"}
P_git_empty rc=1 profile ОТКАЗ: значение вне алфавита: defaults.git.canonicalRemote: пусто   rc=0 git={"value":{"canonicalRemote":""},"origin":"project"}
P_git_arr   rc=1 profile ОТКАЗ: значение вне алфавита: defaults.git.canonicalRemote: <array> rc=0 git={"value":{"canonicalRemote":[1]},"origin":"project"}
P_ci_empty  rc=1 profile ОТКАЗ: значение вне алфавита: defaults.ci.workflow: пусто           rc=0 ci={"value":{"workflow":""},"origin":"project"}
P_git_num_repo_set (репо задал git, слой — 7)
            rc=1 … defaults.git.canonicalRemote: <number>                                     rc=0 git={…"git@h:REPO.git"},"origin":"repo"}
-- нормальные (HEAD = REVERT, побайтово одинаково)
REPO_WINS   rc=0 git={"value":{"canonicalRemote":"git@h:REPO.git"},"origin":"repo"} ci={"value":{"workflow":"repo-ci.yml"},"origin":"repo"}
PROJ_ONLY   rc=0 git={"value":{"canonicalRemote":"git@h:PROJ.git"},"origin":"project"} ci={"value":{"workflow":"proj-ci.yml"},"origin":"project"}
MIX         rc=0 git={…"git@h:REPO.git"},"origin":"repo"} ci={…"proj-ci.yml"},"origin":"project"}
NONE        rc=0 git="<absent>" ci="<absent>"          (defaults без git/ci)
NODEF       rc=0 git="<absent>" ci="<absent>"          (слой без defaults)
-- контроль той же нормы в репо-слое (не изменился)
R_ci_num    rc=1 profile ОТКАЗ: значение вне алфавита: ci.workflow: <number>
R_git_empty rc=1 profile ОТКАЗ: значение вне алфавита: canonicalRemote: пусто
```

Форма отказа — ровно P6 (`profile ОТКАЗ: значение вне алфавита: <поле>: <значение>`,
контракт 054 :213), поле названо полным путём. Проверка стоит и тогда, когда репо
перекрывает ветвь (`P_git_num_repo_set`): невалидный слой отвергается независимо от
слияния — та же политика, что у соседних `defaults.commands`/`defaults.workflowPaths`.
И-4 («`canonicalRemote`, `ci.workflow` — непустые строки … Нарушение → rc 1, P6 с полем и
значением») выполнен для обоих слоёв. Фикс переиспользует существующую
`check_object_strings` — второй реализации классов И-4 нет (контракт 054 :227).

### (б) Б9 — закрыт

`grep '^\s*m7\)'` по `red_profil_dva_sloja.sh:1666-1770` (тело `cell_resolver_run`) →
совпадений нет. Единственное `m7)` в теле — в комментарии `:1759`. Исполняемая `m7) cell_m7`
осталась одна — `dispatch_honest_cell:1563`; `cell_resolver_run` завершается
`*) return 1` (fail-closed, С5 к2).

### (в) Приёмки живьём (клон 56f436b; батареи ПОСЛЕДОВАТЕЛЬНО, С9)

```text
bash fixtures/_krasnye_054.sh              → RUNNER_RC=0; стаб-пак: просмотрено 20, поймано 20;
    b11h: ok=60 refused=68 leak=0 (RACE_N=128); m6/m7 — различение работает;
    честная часть: проверено предъявлений 37; итог 054: rc=0
    внешняя мера п.1б: grep -c '^СВЕРКА: ' лога = 37 → N=37=C
bash fixtures/parsing_hygiene_battery/run_battery.sh profile_resolver → итог 4/4 классов закрыто, PARSING_RC=0
npm run check:antiplacebo -- --scope profile_resolver (последовательно) → «предъявлено красным повторным прогоном: 9», AP_RC=0
CI run 36521842789 на 56f436b (headSha 56f436b5…): моя мера — gh run view --json jobs:
    ci, ap1, ap2, ap3, ap4, ap5 — 6/6 success
git diff --stat frozen/contracts/054/1 HEAD -- contracts/054-profil-dva-sloja-launcher-proekta.md → пусто, rc=0
git diff --stat frozen/contracts/057/1 HEAD -- contracts/057-batareja-054-chestnyj-izmeritel.md → пусто, rc=0
registry/contracts.tsv:56 054 → 53dbc719… = rev-parse frozen/contracts/054/1
registry/contracts.tsv:59 057 → eba0f818… = rev-parse frozen/contracts/057/1
```

Мутант REVERT против тех же приёмок: `_krasnye_054.sh` → RUNNER_RC=0, N=37=C — батарея
откат Б8 не видит (см. С12).

Первый scoped-прогон antiplacebo, запущенный ПАРАЛЛЕЛЬНО с батареей 054, дал одно
расхождение (`case_znachenie_vne_alfavita`: rerun.out `profile ОТКАЗ: неизвестный ключ
слой-проекта: defaults.barriers.mandatory`, AP_RC=1), хотя сам вызов 2 назвал
`language: python`; последовательный повтор — 9/9, AP_RC=0; копия барьера в рабочем
каталоге прогона побайтово равна HEAD (`cmp` 0). Фикстура и путь `language` диффом
b9237dc не затронуты; причину не установил — С13.

### Область (п.1), атомарность (п.5), норма (п.6), история проверок (п.3), заявленное (п.7)

`git diff --stat ac9439a 56f436b` → 2 файла: `scripts/profile_resolver.sh` (+7: две строки
`check_object_strings` + 5 строк комментария) и `fixtures/workshop_project/
red_profil_dva_sloja.sh` (+6/−2: удалена ветвь `m7)`, комментарий). Оба — ЗОНА implementer
054. Один коммит на один предмет, ссылка «054 фикс-Б8+Б9»: две находки одного вердикта
одного предмета — принимаю. `git log ac9439a..HEAD -- contracts fixtures/profile_resolver
fixtures/parsing_hygiene_battery registry roles docs` → пусто: нормы, контракты, case_*,
parsing-профиль не тронуты; прежние ожидания проверок не менялись.

Заявленное: «Батарея rc=0, N=37=C, parsing 4/4, frozen-diff пуст» — подтверждено своей
мерой (C по `^СВЕРКА:`, gh jobs, rev-parse тегов). Цитаты отказов в сообщении коммита
неточны: заявлено `значение вне алфавита: ci.workflow: <number>` / `canonicalRemote: пусто` /
`canonicalRemote: <array>`, фактически резолвер печатает `defaults.ci.workflow: <number>` /
`defaults.git.canonicalRemote: …` (заявленные строки — отказы РЕПО-слоя, `grep -F` по ним
на выводе фикса не совпал бы). Поведение лучше заявленного (путь назван полностью, как
требует P6) — С11, не блокирует.

## Находки круга 4

Блокеров нет.

- С11 (п.7, совет). Сообщение b9237dc цитирует тексты отказов репо-слоя вместо фактических
  `defaults.…` — см. выше. Историю не переписывать; на будущее — цитировать вывод, а не
  ожидание.
- С12 (совет; снимаю «плюс клетка» к3 как требование). Постоянного барьера на Б8 нет:
  мутант REVERT проходит батарею 054 (rc 0, N=37=C), а case_* сверяют P6 только для
  `language` и `defaults.barriers.mandatory`. Замороженное покрытие соблюдено (054 :428
  «И-4→к5»), строки, требующей клетку на каждый лист И-4, на freeze нет — по 027 мера,
  которой не было на freeze, не FAIL. Дешёвая форма — второй красный вызов в
  `case_defaults_vne_alfavita.sh` (`defaults.ci.workflow: 7`) или строка в m7.
- С13 (совет, вне предмета Б8/Б9). Одиночное расхождение scoped antiplacebo при
  параллельном прогоне с батареей 054 (см. (в)); последовательно 9/9, CI 6/6. Тот же класс
  неизоляции, что С9; если повторится в CI — разбирать `rerun` antiplacebo.
- С14 (050, совет). Новый комментарий `:1759–1763` дословно копирует routing-список
  `dispatch_honest_cell:1555` — вторая копия, которая устареет при следующей клетке.
  Хватит ссылки «см. dispatch_honest_cell».
- С5 к2 — закрыт (к3). С6/С7 к2, С1/С3 к1, С8/С9/С10 к3 — в силе, вне круга 4.

## Паразитная сложность (контракт 050) — артефакты b9237dc

- две строки `check_object_strings "$PROJECT_JSON_FD" defaults.{git,ci} …` (`:405–406`):
  (1) И-4 054 — непустые строки `canonicalRemote`/`ci.workflow`, P6; (2) нового состояния
  нет, отказ явный — rc 1 и P6 на stderr; (3) 1 файл, число не выросло (переиспользована
  существующая функция, алфавит `SCHEMA_LEVELS` не тронут, якорь m7 не задет — батарея
  зелёна); (4) интерфейс резолвера не изменился; (5) потребитель — строка И-4 и Б8;
  постоянного CI-потребителя нет (С12). ESSENTIAL: более простой формы нет — без строк
  входы Б8 проходят rc 0 (REVERT).
- удалённая `m7)` в `cell_resolver_run`: сокращение, имя клетки снова в трёх местах
  (Б9 закрыт).
- комментарий `:1759–1763`: не артефакт по перечню 050; копия грамматики — С14.

Артефакты кругов 1–3 — строки кругов 1–3 в силе (резолвер, `workshop --probe`,
`gen-harness --agents-rules`, parsing-профиль, `cell_b11h`, `cell_b11m`, case_*-семья,
ключ `profile_resolver` в ci.yml, `BATTERY_RC`, ветви `defaults.{git,ci}` слияния,
`cell_m7`, `*) return 1` ×2 — ESSENTIAL; дубль предиката стаб/честная сторона — совет).

## Круг 3 — сводка (сырьё — редакция на ac9439a)

- Б7 закрыт 9a5b42f: формы REPO_WINS/PROJ_ONLY/MIX/NONE с верным origin; silent-drop-мутант
  SD (удаление `elif $p.defaults.{git,ci}`) → m7 красна, RUNNER_RC=1.
- Б6 закрыт 057: мутант замещения RB (barriers репо замещает ветвь целиком) → m6 красна
  `barriers.optional`, RUNNER_RC=1.
- Открыты Б8 (И-4 для `defaults.git/ci`), Б9 (мёртвая `m7)`); советы С8–С10.

## Б1–Б9 — сводка кругов 1–4

| Блокер | Круг открытия | Закрыт | Доказательство закрытия |
|---|---|---|---|
| Б1 честная b11 против стаба | 1 | 057 (к2) | b11h leak=0/128 честный; мутант cto leak=13 → rc 1 |
| Б2 раннер глотает rc | 1 | 057 (к2) | honest 0, cto 1; SD/RB к3 → RUNNER_RC=1 |
| Б3 конформный вход отвергнут | 1 | 057 (к2) | формы A/G/F/C/M/P rc 0 |
| Б4 нет guard-канала | 1 | 057 (к2) | 9/9 case_* локально и в CI 56f436b |
| Б5 фразы не дословны | 1 | 057 (к2) | P4 дословно; N=C |
| Б6 нет m1–m6 / мутант замещения зелёный | 2 | 057 (к3) | RB → m6 красна `barriers.optional` |
| Б7 defaults.git/ci молча выпадают | 2 | 9a5b42f (к3) | формы REPO_WINS/PROJ_ONLY/MIX; SD → m7 красна |
| Б8 defaults.git/ci без И-4 | 3 | b9237dc (к4) | `workflow:7`/`""`/`[1]` → rc 1 P6; REVERT → rc 0 |
| Б9 мёртвая ветвь m7 | 3 | b9237dc (к4) | исполняемой `m7)` в `cell_resolver_run` нет |

## Развилка

ЗАКРЫТА словом владельца (HANDOFF.md:112): «.harness/ в самом репо. Консультанта НЕ
собирать.» — отмечено в к3; механизм 054 инвариантен (пути — значения `workflowPaths.*`).

## Вердикт

**accept.** Б8 и Б9 закрыты своей мерой: три мутантных входа Б8 → rc 1, P6 с полным путём
поля; нормальные → rc 0 без изменения слияния; откат фикса возвращает rc 0 (красное
предъявлено); мёртвой ветви нет. Все приёмки 054/057 зелёные (батарея N=37=C, parsing
4/4, scoped 9/9, CI 6/6 на 56f436b), frozen-diff пуст, реестр совпадает с тегами. Советы
С11–С14 не блокируют. **054 — done; сигнал пилота владельцу.**
