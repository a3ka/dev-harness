accept

# Reviewer 063: круг 2 (после Р-1/Р-2/Р-3 вердикта 123efc3)

Предмет: `frozen/contracts/063/1`, `contracts/063-ci-proekta-iz-profylja-vorota-slijanija.md`.
Судимый HEAD: `feb414f`. Клон суда: `/tmp/dev-harness-verify/rev063k2c`. Мутанты накладывались
в worktree `rev063k2-m1` и `rev063k2-m2` через `git apply --unidiff-zero`, патчи лежат в
`/tmp/dev-harness-verify/rev063k2-m{1,2}.patch`. В клоне суда правился только этот файл.

Правка круга: `2c0ca7e` (implementer), ленд `9db6cef` (orchestrator, `--no-ff`, родители
`0065a7f` и `2c0ca7e`). Поле 063 после `9db6cef` не менялось:
`git diff --stat 9db6cef HEAD -- <скрипты 063, ci.yml, package.json, fixtures/check_judge_gate/, контракт>`
пуст. `38d9b80`/`feb414f` трогают только `fixtures/check_metering/red_home_raskrytie_064.sh`.

| артефакт | блоб HEAD |
|---|---|
| `scripts/land_project.sh` | `bf07c14` (было `133114c`) |
| `scripts/check_merge_gate.sh` | не менялся с круга 1 |
| `scripts/gen_ci_workflow.sh` | не менялся с круга 1 |
| `fixtures/check_merge_gate/` | удалён целиком (`2c0ca7e`) |
| `.github/workflows/ci.yml` ap3 | ключ `check_merge_gate` снят (`2c0ca7e`) |

## Стенограммы спавна (слово оркестратора)

- Детектор: rc 0. Локальный main впереди origin, батч-режим.
- CI-гейт: последний завершённый прогон 6/6 success.
- Приёмка судьи: Н-48, scoped.

## Закрытие блокирующих находок круга 1

- [x] **Р-1 (И-7): закрыта.** Identity теперь стоит в одной физической строке `land_project.sh:81`:
  `if ! git -C "$REPO" -c user.name=orchestrator -c user.email=orchestrator@dev-harness.local -c commit.gpgsign=false merge --no-ff -m "land: $BRANCH" "$BRANCH" >/dev/null 2>&1; then`.
  Массив `MERGE_CMD` удалён.
- [x] **Р-2 (область правки + 050): закрыта по варианту (а).** Семья `fixtures/check_merge_gate/`
  (4 файла, −260 строк) и ключ ap3 сняты одним коммитом `2c0ca7e`, поэтому промежуточного
  состояния с красным parity нет. Остаток `check_merge_gate` в дереве — только сам барьер
  `scripts/check_merge_gate.sh` (ESSENTIAL по кругу 1) и его упоминания в контракте, батарее
  и вердиктах.
- [x] **Р-3 (050): закрыта.** Флаг `--orchestrator` и переменная `ORCH` удалены. Сверка `:88`
  сравнивает с литералом: `[ "$merge_cn" != orchestrator ]`.

## Сырой вывод: мой прогон на `feb414f`

```text
$ grep -nE 'user\.(name|email)' scripts/land_project.sh
81:if ! git -C "$REPO" -c user.name=orchestrator -c user.email=orchestrator@dev-harness.local -c commit.gpgsign=false merge --no-ff -m "land: $BRANCH" "$BRANCH" >/dev/null 2>&1; then
                                                                                rc=0
$ grep -nE '\bgit\b[^|<>]*[[:space:]](commit|merge)[[:space:]]' scripts/land_project.sh
81:if ! git -C "$REPO" -c user.name=orchestrator … merge --no-ff …             rc=0   (было rc 1 — слепота круга 1)
$ ! grep -rnE '<канарейка 016 И-5 дословно>' scripts/land_project.sh | … | grep .   rc=0 (мера пуста)
$ sed -E 's/ -c user\.(name|email)=[^ ]+//g' scripts/land_project.sh | <та же канарейка> | grep .
81:if ! git -C "$REPO" -c commit.gpgsign=false merge --no-ff -m "land: $BRANCH" "$BRANCH" >/dev/null 2>&1; then
                                                                                найдено → канарейка КРАСНАЯ на мутанте
$ grep -rn -- '--orchestrator' (всё дерево)
  scripts/land_project.sh:77 — только комментарий; прочее — verdicts/review/contracts-063-v1.md
$ bash scripts/land_project.sh --repo /nonexistent --branch x --orchestrator implementer
land project ОТКАЗ: неизвестный аргумент: --orchestrator                        rc=1
$ ls fixtures/check_merge_gate                    No such file or directory
$ grep -n check_merge_gate .github/workflows/ci.yml package.json                  rc=1 (пусто)
$ git log --diff-filter=D -- fixtures/check_merge_gate/   → 2c0ca7e (один коммит)
$ timeout 120 bash fixtures/check_judge_gate/krasnye_063.sh </dev/null
  ok   к1 … ok   к14            (14 строк ok)
063: честных клеток 14, зелёных 14, красных: нет
063: стабов 7, поймано 7, ускользнуло: нет
063: диффпроб стабов без ручки 7, зелёных 7, провал: нет
итог 063: rc=0                                                                  rc=0
$ bash scripts/verify_ci_parity.sh .
workflow-команд: 51 · скриптов в приёмке: 63 · объявленных исключений: 23 · matrix-ключей: 45 · анти-плацебо-запусков: 2 · расхождений: 0
                                                                                rc=0
$ bash scripts/verify_antiplacebo.sh . --scope check_judge_gate
SCOPED: барьеров 1 из выборки — не для приёмки
барьеров: 1 · фикстур: 3 · предъявлено красным повторным прогоном: 3          rc=0
$ bash scripts/check_provodka.sh . contracts/063-…md                            rc=0 (вывод пуст)
$ bash scripts/check_threat_model.sh . contracts/063-…md
модель угроз: секция валидна (ЗАЩИЩАЕТ 1 буллет(ов), НЕ ЗАЩИЩАЕТ 1 буллет(ов))   rc=0
$ node scripts/gen-harness.ts --check
харнес соответствует roles/ (9 ролей)                                           rc=0
$ git diff --exit-code frozen/contracts/063/1 -- contracts/063-…md               rc=0, пусто
$ git diff --stat frozen/contracts/063/1 HEAD -- fixtures/check_judge_gate/      rc=0, пусто
```

**Своя мера счёта.** Функции `^k[0-9]+() {` в батарее — 14, `^s[0-9]+() {` — 7. Ключи matrix
посчитаны разбором строк `keys:` в ci.yml: 45. Было 46, снят ровно один ключ, это сходится
с parity.

## к8/s7 живы после правки строки merge

| мутант | патч | итог батареи | кто поймал |
|---|---|---|---|
| m1: identity снята со строки `:81` | `rev063k2-m1.patch` | `FAIL к8: … merge-коммит подписан Fixture, ожидался orchestrator`; «зелёных 13, красных: к8-…»; **rc=1** | пост-сверка `land_project.sh:88` |
| m2: самосогласованная чужая identity (`implementer` в `:81` и в `:88`) | `rev063k2-m2.patch` | `ok к8: ленд … rc 0`, затем `FAIL к8: committer merge-коммита «implementer» ≠ «orchestrator» (И-7)`; **rc=1** | независимый предикат батареи `red_iv1b…:359` |

Второй мутант — это и есть форма, которую Р-3 делал возможной через CLI: сверка с собственным
аргументом проходит. Его ловит предикат батареи, а не код реализации, так что второй рубеж
жив. Стаб s7 (`red_iv1b…:841-849`, committer из конфига репо) пойман в живом прогоне:
«стабов 7, поймано 7».

## п.1 Область правки

`2c0ca7e` трогает `scripts/land_project.sh`, `.github/workflows/ci.yml` (−1 ключ) и удаляет
`fixtures/check_merge_gate/`. Всё это — поле 063, лишнего нет. Дельта ПЕРЕСЕЧЕНИЯ ci.yml от тега
`frozen/contracts/063/1` теперь для 063 — ровно один прямой шаг `bash fixtures/check_judge_gate/krasnye_063.sh`,
как объявлено. Шаг 062 в том же диффе принадлежит 062 (`82b40d8`). Шард-ключа 063 нет.

## п.3 Проверка не подогнана

Батарея и раннер не менялись с тега: `git diff --stat` пуст. Implementer в круге 2 их не трогал.

## п.5 Атомарность

Один коммит закрывает три находки одного вердикта `123efc3` по одному предмету и ссылается на
вердикт. Р-1 и Р-3 физически лежат в одной строке, это и предсказывал круг 1. Р-2 снят целиком
в том же коммите: семья и ключ обязаны уйти вместе, иначе parity красный (замер круга 1,
`rev063-m3`). Разнести их по отдельным коммитам значило бы оставить красный промежуток.
Принимаю.

## п.6 Норма

`2c0ca7e` не трогает `roles/`, `contracts/`, `frozen/`. `gen --check` rc 0.

## Советы круга 1: статус

`check_merge_gate.sh` и `gen_ci_workflow.sh` в круге 2 не менялись. Хвост `land_project.sh`
после merge перечитан.

- [ ] **С-1 (И-2).** `find` по рабочей копии вместо `git ls-tree HEAD`. Остаётся, не блокирует
  (отказ в безопасную сторону).
- [ ] **С-2 (И-3).** Symlink-`.review` / symlink-файл пропускается `find -type f`. Остаётся,
  не блокирует: вход вне положительной области, [INFERENCE].
- [ ] **С-3 (И-8).** `2>&1` при захвате JSON резолвера. Остаётся, не блокирует: живого дефекта нет.
- [ ] **С-4 (И-7).** После отказа пост-сверки merge-коммит остаётся в HEAD, `:86-92` отката
  не имеет. Остаётся, не блокирует: контракт откат не требует.
- [ ] **С-5 (остаток контракта, адресат architect).** `run: |` без индикатора отступа. Остаётся,
  не блокирует: форма заморожена литералом И-4/И-10.
- [ ] **С-6 (новое, стиль).** Комментарии `land_project.sh:9-10,76-78` пересказывают историю ревью
  («Р-3 вердикта 123efc3: НИКАКОГО CLI-флага»). Историю уже несёт git log; такие комментарии
  устаревают при следующей правке. Не блокирует.

## Замечания вне поля 063

- **О-2 (круг 1) держится.** Канарейка 016 И-5 на всём `scripts/` по-прежнему красная, rc 1:
  `check_hooks.sh:329,342,368`, `git -C "$T_DIR" commit` без identity. `land_project.sh` в её
  выводе больше нет. Адресат — оркестратор.

## Паразитная сложность (050)

Круг 2 только удаляет, новых артефактов нет:

- **`scripts/land_project.sh`.** (1) И-7. (2) Состояние — merge-коммит, явно. (3) Сопряжённых
  файлов стало меньше: identity живёт в одной строке и в одной сверке. (4) Интерфейс сузился
  до `--repo`/`--branch`, работа та же, модуль стал глубже. (5) Потребители — к8/к9. **ESSENTIAL.**
- **Семья `fixtures/check_merge_gate/` и ключ ap3.** Удалены, ACCIDENTAL Р-2 снят.

## ПРОВОДКА (038)

Как в круге 1: guard `fixtures/check_judge_gate/krasnye_063.sh` — прямой шаг ci.yml и ключ
`check:merge-gate-family-selftest`, `check_provodka` rc 0. Круг 2 проводку не трогал.

## Итог

accept. Р-1, Р-2, Р-3 закрыты, у каждой есть своя мера и мутант. Блокирующих находок нет.
Советы С-1..С-6 не блокируют.
