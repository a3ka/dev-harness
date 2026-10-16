FAIL — 5742418f1 (.githooks/pre-push, круг 2): Рв-PP-1 и Рв-PP-3 закрыты, Рв-PP-4/5/7 закрыты консультантом. Рв-PP-2 закрыт на всех формах круга 1, но остаток того же класса блокирует: merge опережающего локального main в wip от текущего живого main проходит молча, rc=0 (Рв-PP-9). Регрессий против 9b14bac6f нет. Находки: `.review/2026-10-16-02.md`, отметки круга 1 — `.review/2026-10-16-01.md`.

# Ревью: pre-push fail-open, круг 2 (5742418f1)

- **Предмет:** `5742418f1fa99598a318db13839bc28458b89c60`, единственный файл — `.githooks/pre-push` (+57/−15) к
  `9b14bac6f`. Identity owner, «быстрый путь по слову владельца 2026-10-16». Тело коммита прочитано целиком.
- **Ревьюер:** reviewer (Opus), identity `reviewerprepushv2`. Плоское «reviewer» блокирует worktree-гвард, прецедент
  круга 1 — `reviewerprepushfail`.
- **Клон:** `/tmp/dev-harness-verify/rv-prepush2-VastCrane-1665661-19187`, SSH `git@github.com:a3ka/dev-harness.git`,
  HEAD `5742418f1`. Хук в клоне побайтно равен хуку основного чекаута, sha256 `571f845d…`.
- **Пробы круга 1** (`/tmp/dev-harness-verify/rv-prepush-1665661-19135.probe.sh`) живы. Я перенёс их в свой клон
  с теми же сценариями и теми же именами, без подмены «new». Каждая проба прогнана на трёх версиях: v0 = `0f48780f`,
  r1 = `9b14bac6f`, r2 = `5742418f1`. Дополнительно добавлены P3h–P3o и P5, сделанные под вопросы этого круга.

## Пункты гейта

| # | Пункт | Итог |
|---|-------|------|
| 1 | Область правки | ОК: `git show --stat` — один файл `.githooks/pre-push`. Рв-PP-4/5 сужают допуск механизма, норму они не трогают (ниже) |
| 2 | Сырой вывод | ЧАСТИЧНО: `/tmp/dev-harness-verify/hookround2.out` есть, но в нём одна ложная «rc=1» (Рв-PP-11, совет). Мой вывод ниже |
| 3 | Проверка не подогнана | ОК: фикстуры не тронуты, в диффе нет `fixtures/` |
| 4 | Красное предъявлено | Моими пробами. r1 rc=0 → r2 rc=1 на P3b', P3d, P3e, P3g, P3h', P3j, P3o. Постоянной фикстуры нет (Рв-PP-6) |
| 5 | Атомарность | ОК: один коммит на один предмет |
| 6 | Норма не тронута | ОК: `roles/`, `verdicts/arbitration/` и `AGENTS.md` в диффе отсутствуют |
| 7 | Заявленное = сделанному | ОК по всем перечням тела (сверено своей мерой, ниже). Дыра Рв-PP-9 в теле не заявлялась |

**ПРОВОДКА (038).** Канал тот же, что в круге 1: role-строка `roles/orchestrator.md:195`, хук — guard того же
предмета. Принято.

## Сырой вывод (свой)

### Пробы круга 1 + дополнительные (`…19187.probe.sh`, `…19187.probe2.sh`, `…19187.probe3.sh`)

Устройство пробы:
- O — bare, main=`5742418f1`, плюс все теги и все живые wip-ветки GitHub;
- в W отсутствует 1 живой SHA;
- ghost — для P1b.

Вывод сокращён: SHA заменены на `<sha>`, причина отказа обрезана. Метки `←` мои.

```
P1a ROADMAP, no missing live sha (control)                 v0 rc=1 | ОТКАЗ устав-дельта … ROADMAP.md
P1a                                                         r1 rc=1 | ОТКАЗ …            r2 rc=1 | ОТКАЗ …
P1b ROADMAP, live sha missing locally                      v0 rc=0 |                     ← исходный fail-open
P1b                                                         r1 rc=1 | ОТКАЗ …            r2 rc=1 | ОТКАЗ устав-дельта … ROADMAP.md
P2a docs/owner add by architect                            r1 rc=1 | r2 rc=1 ОТКАЗ docs/owner/ пишет только owner
P2b docs/owner add by owner                                r1 rc=0 | r2 rc=0
P2c orchestrator clean merge of owner docs                 r1 rc=0 | r2 rc=0
P2d orchestrator evil merge rewrites owner doc             r1 rc=1 | r2 rc=1 ОТКАЗ docs/owner/ …
P2e non-owner deletes docs/owner file (7ed4a89c form)      r1 rc=1 | r2 rc=1 ОТКАЗ docs/owner/ …
P3a wip without merge                                      r1 rc=0 | r2 rc=0
P3b merge main->wip (wip first parent)                     r1 rc=1 | r2 rc=1 ОТКАЗ … родитель <sha> приносит историю main…
P3b' same, pushed to non-wip ref                           r1 rc=0 | r2 rc=1 ОТКАЗ … ref=refs/heads/tmp-sync   ← Рв-PP-4
P3c int-form to wip/int-999/architect                      r1 rc=0 | r2 rc=0
P3d int-form (main 1st) FF-pushed onto wip/999/architect   r1 rc=0 | r2 rc=1 ОТКАЗ … первый родитель — коммит main (int-форма) вне ветки wip/int-*  ← Рв-PP-5
P3e merge LOCAL main (1 unpushed commit) ->wip             r1 rc=0 | r2 rc=1 ОТКАЗ … приносит историю main…  ← Рв-PP-2
P3h octopus (sib 2nd, main 3rd) ->wip                      r1 rc=1 | r2 rc=1
P3h' octopus (sib 2nd, LOCAL main 3rd) ->wip               r1 rc=0 | r2 rc=1   ← все не-первые родители
P3i merge sibling wip (same base) ->wip (legit)            r1 rc=0 | r2 rc=0
P3j merge sibling-from-newer-main ->wip                    r1 rc=0 | r2 rc=1
P3k merge (local) main into existing int-branch            r1 rc=0 | r2 rc=0   ← класс Рв-PP-9 (p1 уже содержит живой main)
P3o criss-cross: single base in p1, other base not         r1 rc=0 | r2 rc=1   ← --all (single=eaf0aecdc in p1: y, other=b3bd96b88 in p1: n)
P3o' control: p2 history already in p1                     r1 rc=1 | r2 rc=0   (already-contained, намеренно)
P3f M1 already on origin as tmp-sync, now ->wip            r1 rc=0 | r2 rc=0   (диапазон пуст; первый ход теперь P3b')
P3g live main absent locally, merge main->wip              r1 rc=0 | r2 rc=1 ОТКАЗ: проверить слияние на merge main невозможно … живого main origin нет в локальной базе — сделайте git fetch origin main  ← Рв-PP-1
P3g' live main absent, innocent sibling merge ->wip        r1 rc=0 | r2 rc=1 (тот же именованный отказ)
P4  live main absent, innocent wip off local main          r1 rc=0 | r2 rc=0   (range 7)
P4' live main absent, ref deletion                         r1 rc=0 | r2 rc=0
P4m plain wip commit                                       r1 rc=0 | r2 rc=0
P3n fresh wip (from live main) + merge LOCAL main ahead    r1 rc=0 | r2 rc=0 |   ← Рв-PP-9: БЛОК
      p1=435f2228 p2=08110f31 local-main=08110f31 live-main=5742418f1
P5  empty wip (tip=live main) merges sibling wip           r1 rc=0 | r2 rc=1 … int-форма вне ветки wip/int-*   (наблюдение)
```

Проба P3m («у origin нет main») недействительна. Bare O отверг удаление текущей ветки
(`refusing to delete the current branch`), так что прогон повторил P3g. В счёт она не входит.

Сверка с ожиданием задания. Счёт мой, по строкам выше:
- блокирующие P1b, P2d, P2e, P3b, P3b', P3d, P3e, P3g → r2 ОТКАЗ, 8/8;
- законные P2b, P2c, P3a, P3c, P4, P3f → r2 rc=0, 6/6.

Расхождений с заявленным в теле коммита нет.

### Рв-PP-2 остаток и более простая форма (r2x)

r2x — одноразовая правка r2 в `/tmp`, в дерево она не вносилась. В (б) к `LIVE_MAIN` добавлен локальный
`refs/heads/main^{commit}`. Дифф +6/−2: `mains=( "$LIVE_MAIN" [+local main] )`, внутренний `for m in "${mains[@]}"`.

```
P3n  … r2x rc=1 | ОТКАЗ: … ref=refs/heads/wip/999/implementer коммит=<sha> — родитель <sha> приносит историю main…
P1a/P1b/P2a/P2d/P2e/P3b/P3b'/P3d/P3e/P3h/P3h'/P3j/P3o/P3g/P3g'  r2x rc=1 (как r2)
P2b/P2c/P3a/P3c/P3i/P3k/P3f/P4/P4'/P4m/P3o'                     r2x rc=0 (как r2)
```

### История (`…19187.hist.sh`)

Origin пробы — refs на каждого родителя плюс main. Диапазон в каждом случае равен 1.

```
== W tree: 5742418f; pair32 in tree: 2
868d386f   refs/heads/main                  r1 rc=1 | r2 rc=1 ОТКАЗ docs/owner автор=orchestrator
7ed4a89c   refs/heads/main                  r1 rc=1 | r2 rc=1 ОТКАЗ docs/owner автор=orchestrator
b0c39a58   refs/heads/main                  r1 rc=0 | r2 rc=0
f3452af5 / e1109e76 / 678c64db / 3c2962c7   r1 rc=0 | r2 rc=0
b2a0573a9  refs/heads/wip/104/implementer2  r1 rc=0 | r2 rc=0
f926 (P=b2a0573a ea39bec9)                  r1 rc=1 | r2 rc=1 ОТКАЗ ROADMAP + ОТКАЗ merge main в ветку запрещён
== W tree: b0c39a58 (own tree); pair32 in tree: 0
b0c39a58   refs/heads/main                  r1 rc=1 | r2 rc=1 ОТКАЗ устав-дельта … ROADMAP.md
== W tree: af4e33f4 (pair-32 commit); pair32 in tree: 2
b0c39a58   refs/heads/main                  r1 rc=0 | r2 rc=0
```

Это прямо проверяет поправку Рв-PP-3 в теле 5742418f1 («“b0c39a58 — ОТКАЗ” верно для дерева b0c39a58 (до
grandfather-пары 32 af4e33f4); на текущем дереве пара 32 его законно пропускает»): она верна. На текущем дереве
нового FAIL нет. Предок проверен тоже: `git merge-base --is-ancestor b0c39a58 af4e33f49` → rc=0.

### Фикстуры контракта 022 (`…19187.run.sh`)

Хук версии подставлялся в дерево клона, после прогона восстанавливался. Итоговый `sha256` дерева = `571f845d…`,
`status` чист. Перечень — 9 `red_push_*`, 2 `probe_*` и `red_check_hooks_bez_push_faz`. Счёт 12 мой, из
вывода `fixtures run: 12`.

```
                                             v0    r1    r2    r2x
red_push_dobavlenie_ustavnogo_svobodno.sh    rc=0  rc=0  rc=0  rc=0
red_push_istoricheskij_legit_prohodit.sh     rc=0  rc=0  rc=0  rc=0
red_push_lechenie_ne_blokiruetsja.sh         rc=0  rc=0  rc=0  rc=0
red_push_merge_gran_bez_stroki.sh            rc=0  rc=0  rc=0  rc=0
red_push_nulevoj_ref_scoped.sh               rc=0  rc=0  rc=0  rc=0
red_push_stale_zerkalo_iskljuchaet.sh        rc=0  rc=0  rc=0  rc=0
red_push_teg_annotirovannyj_suditsja.sh      rc=0  rc=0  rc=0  rc=0
red_push_vetochnaja_gran_bez_merge.sh        rc=0  rc=0  rc=0  rc=0
red_push_vtoroj_remote_sushhij_ref.sh        rc=0  rc=0  rc=0  rc=0
probe_check_hooks_krasnyj.sh                 rc=0  rc=0  rc=0  rc=0
probe_push_svezhij_sverh_origin_umiraet.sh   rc=0  rc=0  rc=0  rc=0
red_check_hooks_bez_push_faz.sh              rc=0  rc=0  rc=0  rc=0
```

Прогон r1 завершился ошибкой bash уже после 12 строк rc: я переписал `run.sh`, пока он исполнялся. На сами rc
это не повлияло, они напечатаны до сбоя. Восстановление хука выполнено следующим прогоном.

## Суд по блокерам круга 1

- **Рв-PP-1 — ЗАКРЫТ.** `merge_main_verdict` различает три исхода. Когда `LIVE_MAIN` пуст или его объекта нет
  локально, возвращается 2, и вызывающий печатает именованный ОТКАЗ с подсказкой `git fetch origin main`.
  Проверено на P3g и P3g'. Ограничение верное: исход 2 возникает только для merge-коммитов, поэтому строка
  `[ "${#parents[@]}" -ge 3 ] || return 1` стоит ДО проверки main. Без merge в диапазоне ложного отказа нет:
  P4, P4', P4m. Разрешающего stale-fallback нет, как и рекомендовал консультант.
- **Рв-PP-2 — ЗАКРЫТ на заявленных формах, остаток блокирует (Рв-PP-9).** `merge-base --all` прогоняется по
  `"${parents[@]:2}"`, то есть по каждому не-первому родителю. Это видно из P3h' (octopus, локальный main третьим:
  r1 rc=0, r2 rc=1) и P3o (criss-cross, две лучшие базы, одиночный `merge-base` выбрал бы базу из p1: r1 rc=0,
  r2 rc=1). Остаток — P3n, rc=0: класс «wip уже содержит живой main». Форма проверки — та, которую я рекомендовал
  в круге 1, и ошибка в ней моя.
- **Рв-PP-3 — ЗАКРЫТ.** Поправка вынесена append-only в тело 5742418f1, а не в NABLIUDENIA. Тело неизменяемо,
  ссылается на 9b14bac6 и находится через `git log --grep`, поэтому форму принимаю. По сути поправка верна,
  см. историю выше.

## Рв-PP-4/5 — строже рекомендации: расширение или нет

Расширением без санкции не считаю: оба закрыты.
- Решение пришло каналом владельца: коммит identity owner, «по слову владельца 2026-10-16». В круге 1 я сам
  поставил это вопросом владельцу и не объявлял границей.
- Рв-PP-5 совпадает с буквой нормы. Арбитраж `merge-wip-protiv-main-konflikt-norm.md` §(б) называет
  int-класс `wip/int-<NNN>/<автор>`, «ОТДЕЛЬНЫЙ … сама wip не переписывается».
- Рв-PP-4 — guard строже role-строки. Мерой проверено, что он не задевает санкционированные потоки:
  - ленды идут в main, а main исключён;
  - int — в `wip/int-*`;
  - ветки без merge проходят: P3a, P4, b2a0573a9.
- На origin сейчас 17 голов вне `main` и `wip/*` (`git ls-remote origin 'refs/heads/*'`, мой подсчёт). Уже
  опубликованные коммиты в них не судятся повторно, потому что диапазон исключает их.

Цена Рв-PP-5 зафиксирована наблюдением P5: merge соседней wip в пустую wip отклоняется как int-форма.

## Паразитная сложность (050)

Свойства взяты из арбитража `merge-wip-protiv-main-konflikt-norm` и слова владельца. Замороженного контракта
у быстрого пути нет.

- **`merge_main_verdict` (три исхода, глобальная `MM_REASON`).**
  1. Свойство: запрет merge main и fail-closed при неизвестности (Рв-PP-1/2).
  2. Состояние: глобальная переменная, но её значение печатается в причине отказа, то есть явно в выводе.
  3. Меняется 1 файл, число не выросло.
  4. Интерфейс: 2 аргумента и код 0/1/2. Работа под ним: (а) и (б), octopus, `--all`. Модуль глубокий.
  5. Потребитель — P3b/P3e/P3g, в CI нет. Чужую грамматику не повторяет.

  Итог: ESSENTIAL.
- **`range_err` (mktemp на каждую пуш-строку).**
  1. Свойство: Рв-PP-7, stderr отделён от списка.
  2. Состояние: временный файл, удаляется на обоих путях.
  3. Меняется 1 файл.
  4. Интерфейс не вырос.
  5. Потребитель — P1b.

  Итог: ESSENTIAL. Перенаправление в переменную через группировку дало бы то же, но проще не стало бы.
- **Ветвь `refs/heads/main) ;;` + `refs/heads/*)`.**
  1. Свойство: Рв-PP-4.
  2. Состояния нет.
  3. Меняется 1 файл.
  4. Интерфейс не вырос.
  5. Потребитель — P3b'.

  Итог: ESSENTIAL.
- **`r=$?` после `mapfile` (строка 220).**
  1. Свойство: никакое, значение не читается.
  2. Состояния нет.
  3. Меняется 1 файл.
  4. Мёртвое присваивание.
  5. Потребителя нет.

  Итог: ACCIDENTAL, совет в составе Рв-PP-10, без блока: строки приёмки не задеты.

## Итог

Код остаётся в main. Он строго лучше 9b14bac6f: ни одна проба не перешла из ОТКАЗ в проход, кроме намеренной
P3o' (already-contained), а 9 проб перешли из прохода в ОТКАЗ (P3b', P3d, P3e, P3h', P3j, P3o, P3g, P3g', P5). Блок — Рв-PP-9, адресат — консультант. Форма r2x
приведена как доказательство того, что более простая форма проходит те же строки приёмки; дизайн она не
навязывает. Советы — Рв-PP-6, Рв-PP-10, Рв-PP-11. Следующий круг узкий: P3n плюс перепрогон этой матрицы.
