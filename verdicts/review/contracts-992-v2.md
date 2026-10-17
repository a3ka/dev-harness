accept

# Вердикт ревьюера, круг 2: контракт 992, пакет implementer

OBJECT: `git rev-parse wip/992/implementer` = `d90e1bfe893ab1c5e40b05b83b8ef844a4082a03`. Сверил дважды, в начале и в конце сессии. Совпадает с тем, что указано в задании. Прогоны шли в одноразовом клоне `/tmp/dev-harness-verify/rv992r2-574569` на d90e1bfe. Рядом стояли два worktree для сравнения: `0339dee3` (последний коммит B до Р-1) и `df3de70f` (база до B). Клон и worktree удалены, вердикт не закоммичен: по заданию коммитит оркестратор.

## Р-1 из v1 — закрыт

**Правка.** `scripts/gitw_preflight_071.sh:420`: `git ls-tree --name-only` заменён на `git ls-tree --full-tree --name-only`. Это ровно та простая форма, которую предлагал v1.

**(а) Моя проба, отдельная от клетки implementer.** Полный CLI `scripts/gitw push ssh://git@github.com/a3ka/dev-harness.git HEAD:main`. Игрушечный репозиторий, push из корня и из подкаталога `a/b` (два уровня). Шим git отвечает за ls-remote и push, шим npm на `run` возвращает exit 7. Три варианта входа:
- `keys` — package.json в корне, четыре ключа check:*;
- `nokeys` — package.json в корне без ключей check:*;
- `subonly` — package.json только в `a/b`.

```
d90e1bfe  keys    cwd=.   rc=1 npm_run=1 pushed=0  ПРЕДПОЛЁТ-ОТКАЗ: чек красный: check:nabludenia
d90e1bfe  keys    cwd=a/b rc=1 npm_run=1 pushed=0  ПРЕДПОЛЁТ-ОТКАЗ: чек красный: check:nabludenia
d90e1bfe  nokeys  cwd=.   rc=0 npm_run=0 pushed=1  чеки неприменимы
d90e1bfe  nokeys  cwd=a/b rc=0 npm_run=0 pushed=1  чеки неприменимы
d90e1bfe  subonly cwd=.   rc=0 npm_run=0 pushed=1  чеки неприменимы
d90e1bfe  subonly cwd=a/b rc=0 npm_run=0 pushed=1  чеки неприменимы
0339dee3  keys    cwd=a/b rc=0 npm_run=0 pushed=1  чеки неприменимы            ← Р-1 воспроизведён
0339dee3  subonly cwd=a/b rc=1 pushed=0  ПРЕДПОЛЁТ-ОТКАЗ: package.json не читается (git show rc=128)  ← второй симптом того же корня
df3de70f  все 6 строк — те же rc/причины, что у d90e1bfe
```

- На d90e1bfe все шесть ячеек совпадают по полярности и причине с базой до B.
- На 0339dee3 пропуск из v1 воспроизводится.
- Попутно моя проба нашла второй симптом того же корня, которого не было в v1: на 0339dee3 при package.json только в подкаталоге push из этого подкаталога получал ложный отказ «не читается». d90e1bfe закрывает и его.
- Законный пропуск сохранён (п.1): дерево без ключей и отсутствующий корневой package.json дают rc0.

**(б) Клетка implementer `fixtures/freeze_contract/red_preflight_podkatalog_992.sh`.** Запущена живьём на трёх версиях предмета:

```
d90e1bfe (без аргумента)  B-preflight-podkatalog: control_rc=0 fault_rc=1 oracle=1 hit=1 accepted=1 / cases=1 observations=2 failures=0  rc=0
0339dee3 (worktree)       control_rc=0 fault_rc=0 oracle=0 hit=0 accepted=0 / failures=2  rc=1   («чеки неприменимы» в обеих ветвях)
df3de70f (worktree)       control_rc=0 fault_rc=1 oracle=1 hit=1 accepted=1 / failures=0  rc=0
d90e1bfe, запуск из scripts/  failures=0 rc=0
```

Клетка красная против реализации с дефектом и зелёная после правки. На базе до B тоже зелёная, то есть клетка ловит именно регрессию B, а не что-то иное. Запуск клетки из подкаталога её результат не меняет.

## Область d90e1bfe

Коммит трогает два файла:
- `scripts/gitw_preflight_071.sh`: +1/−1;
- `fixtures/freeze_contract/red_preflight_podkatalog_992.sh`: новый, 120 строк, mode 100755.

Оба пути в ЗОНЕ implementer. Новый файл в fixtures/freeze_contract/ — это «исправление по находке», как в ПЕРЕСЕЧЕНИИ.

`git diff --quiet 0339dee3d d90e1bfe` по следующим путям дал rc=0, изменений нет:
- `fixtures/freeze_contract/fail_closed_992.py`;
- `red_doc_lifecycle.sh`;
- `fixtures/gitw_predpolet/`;
- `contracts/`, `registry/`, `.github/`, `package.json`, `roles/`, `docs/`.

Оракулы, критерий и нормы не тронуты. CASES я пересчитал по AST: `Dict 24`, из них A — 8, B — 16. Это совпадает с `--list | wc -l` = 24. Число клеток не изменилось.

## Повторные прогоны (на d90e1bfe, с rc)

| Команда | rc | Итог |
|---|---|---|
| `python3 fixtures/freeze_contract/fail_closed_992.py` | 0 | `cases=24 observations=24 failures=0`, 24 строки `accepted=1` |
| то же `--model` | 0 | `cases=24 observations=24 failures=0` |
| `bash fixtures/freeze_contract/red_doc_lifecycle.sh` | 0 | батарея 24/24/0 |
| `bash fixtures/gitw_predpolet/red_predpolet_071.sh` | 0 | `честные клетки: 41/41 зелёные; стаб-пак 21/21 + дифф 21/21` (418 с) |
| `bash scripts/run_ci_lane.sh check:document` | 0 | батарея 24/24/0 |
| `bash scripts/check_provodka.sh . contracts/992-oshibka-eto-otkaz.md` | 0 | без вывода |

## Зелёные пункты v1 после d90e1bfe

1. **Область.** Зелёный, см. выше.
2. **Сырой вывод.** Зелёный, вся таблица прогнана мной.
3. **Проверки не подогнаны под код.** Зелёный. Старые фикстуры и оракулы побайтно прежние. Новая клетка только добавлена, и на базе до B она зелёная.
4. **Красное предъявлено.** Зелёный: красное у клетки на 0339dee3 rc1, у моей пробы на 0339dee3 rc0-пропуск.
5. **Атомарность.** Зелёный. Один коммит `992(gitw_preflight_071): Р-1 …`, автор `implementer <implementer@dev-harness.local>`, в нём правка и её регрессионная клетка.
6. **Норма.** Зелёный, нормативные пути не тронуты.
7. **Счётные утверждения своей мерой.** Зелёный:
   - 24 клетки (AST и `--list`);
   - 41 клетка 071 (живой прогон);
   - заявление коммита «4 ключа check:*» сверено с телом фикстуры: четыре ключа `check:nabludenia/ci-parity/ceilings/ids`.

**ПРОВОДКА (038).** Зелёный. Цепочка ci.yml → `run_ci_lane.sh check:document` → `red_doc_lifecycle.sh` → `fail_closed_992.py` жива, rc0. `check_provodka` rc0.

**Тот же класс (cwd-относительный pathspec) в остальных правках B.** Не найден:
- `check_charter.sh:446` идёт через `g() { git -C "$ROOT" …; }` на :410;
- `done_contract.sh:73` идёт через `cd "$ROOT"`;
- `freeze_contract.sh:398` идёт через `g`.

## Паразитная сложность (050) по новому артефакту

**red_preflight_podkatalog_992.sh:**
1. Свойство: §Предмет и п.1 — «сбой проверки не превращается в пропуск проверки». Отказ при существующем package.json с ключами не должен зависеть от cwd вызова.
2. Состояние: временный `$WORK` под `trap rm -rf`. Предмет передаётся явным аргументом, итог виден в выводе `control_rc/fault_rc/oracle/hit` и в rc.
3. При правке того же свойства меняются 2 файла: предполёт и клетка.
4. Интерфейс: один необязательный позиционный аргумент (путь к предмету), rc 0 или 1. Новых флагов и читаемых env нет.
5. Потребителя в строке приёмки или в шаге CI нет. Клетка запускается только напрямую: `red_*` вне глоба `case_*` у `verify_antiplacebo.sh:603`, и её не вызывает `red_doc_lifecycle.sh`.

По букве правила 050 это ACCIDENTAL: без файла все строки приёмки проходят так же. Но находка НЕ блокирует. Подключить клетку в CI implementer мог бы только двумя путями, и оба ему недоступны:
- через CASES (24 → 25) — это смена замороженного критерия;
- через `red_doc_lifecycle.sh` — это файл architect по ПЕРЕСЕЧЕНИЮ.

У блокирующей находки должна быть более простая форма, которая проходит те же строки приёмки в зоне исполнителя, а её нет. Сама клетка — ровно то, что попросил v1.

## Находки круга 2

- [x] **Р-1 (v1, БЛОКИРОВАЛА) — ЗАКРЫТА** в d90e1bfe. Свидетельства выше: (а) и (б).
- [ ] **Р-5. СОВЕТ / вопрос владельцу.** Регрессия Р-1 в CI не подключена. Клетка `red_preflight_podkatalog_992.sh` запускается только вручную. Подключить её (вызов из `red_doc_lifecycle.sh` или пересмотр CASES) может architect в рамках существующего ПЕРЕСЕЧЕНИЯ, либо это делается отдельной Н-записью. Слияние не блокирует.
- [ ] **Р-2, Р-3, Р-4 (v1)** — без изменений и с прежними классами. Р-2 — Н-запись или вопрос владельцу, Р-3 — совет, Р-4 — замечание к заданию. d90e1bfe их не трогает.

## Итог

`accept`. Блокирующая Р-1 закрыта правкой ровно той формы, что предлагал v1. Это подтверждено моей независимой CLI-пробой и клеткой implementer: красная до правки, зелёная после. Все зелёные пункты v1 остались зелёными, включая полные прогоны 24/24/0, `--model`, red_doc_lifecycle, run_ci_lane и 41/41 предполёта. Принятие относится к блобу `d90e1bfe` (`scripts/gitw_preflight_071.sh` @ d90e1bfe). Новая редакция этот вердикт не наследует.
