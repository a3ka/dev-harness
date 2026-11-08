accept
OBJECT=4deeb63f5f36bbb46d6dee88a14af5dcec022a06
сессия=Review167Corrective
СУД: repo=dev-harness; предмет=167; фаза=реализация; роль=reviewer; вызов=2 (единственный scoped исправительный после FAIL v2); сессия=Review167Corrective; модель-факт=anthropic/claude-opus-5-5; OBJECT=4deeb63f5f36bbb46d6dee88a14af5dcec022a06
Контракт: frozen/contracts/167/2 (тег → коммит 587b04f7). Кандидат: wip/167/implementer = origin/wip/167/implementer, HEAD = OBJECT, tree a30808cc4dce7e5c39bac32f4477693c524058b6. База: da0ba1fda0a8019f82b1226759bfef25a933a37e (merge-base с main; несёт вердикт v2).
--sud: reviewer <трасса> Review167Corrective; строка трассы (`scripts/models_actual.sh --tsv --bind --all`): `reviewer	anthropic/claude-opus-5-5	allowed	Review167Corrective	4deeb63f5f36bbb46d6dee88a14af5dcec022a06`; `scripts/check_sud_model.sh --verdict reviewer --trace <файл с этой строкой> --object 4deeb63f… --session Review167Corrective --root .` → `СУДЬЯ СВОЕЙ МОДЕЛИ: вердикт reviewer материализуется`, rc=0. Автор исправления — implementer-glm (zai/glm-5.3, сессия Fix167ReviewerFindings), коммит под identity implementer.

# Вердикт reviewer — 167, реализация, scoped-повтор по Р167-Б1/Б2

## Итог

accept. Обе блокирующие находки v2 закрыты:

- **Р167-Б1** закрыта. Rename-атака отказывает при `diff.renames=true`, `false` и `copies`, с переименованием на стороне main и на стороне ветки.
- **Р167-Б2** закрыта. Формулировка владельца «условие возврата» восстановлена байт в байт, генерат совпадает.

Accept привязан к блобам OBJECT:
- `.githooks/pre-push` f3b9a981843347252f6a2bc6e32cde88e9eecd42;
- `roles/orchestrator.md` 87aba615e1b4b80a2cdc249451a98d78ef951d71;
- `.omp/agents/orchestrator.md` 221647b676912a314af34145dac3d17163ff5c5a.

Новая редакция этих блобов accept не наследует.

Область суда — только Р167-Б1/Б2 и пять пунктов задания. Полного CI и нового аудита не было.

Пункты v2 вне зоны implementer остаются открытыми этим вердиктом не судимыми: БЛОК-DONE-1, В-1…В-4, С-1…С-3 (`contracts-167-impl-v2.md`). Блок done по БЛОК-DONE-1 сохраняется.

Прогоны шли в одноразовом клоне `/tmp/dev-harness-verify/r167v3`: `git clone --no-local`, собственный `.git`, detached HEAD = OBJECT, после прогонов `git status --short` = 0 строк. SSH-хостов в станции нет (`ssh://` → «No SSH hosts are configured»), поэтому клон локальный. GIT_DIR на основной репозиторий не направлялся, push не делался.

## 1. Область правки (своя мера, python по ЗОНЕ из frozen-тега)

Зона implementer взята из `frozen/contracts/167/2:contracts/167-…md`:
`['scripts/zamok_predmeta.sh', '.githooks/pre-push', 'roles/orchestrator.md', '.omp/agents/orchestrator.md', 'fixtures/workshop_project/odin_agent_140/probe.py']`.

```
4deeb63f…~1..OBJECT changed=3 ['.githooks/pre-push', '.omp/agents/orchestrator.md', 'roles/orchestrator.md'] outside-zone=[]
da0ba1fda..OBJECT  changed=5 ['.githooks/pre-push', '.omp/agents/orchestrator.md', 'fixtures/workshop_project/odin_agent_140/probe.py', 'roles/orchestrator.md', 'scripts/zamok_predmeta.sh'] outside-zone=[]
```

Исправительный коммит меняет ровно 3 пути, все в замороженной зоне implementer.

`git diff 4deeb63f~1 4deeb63f`: `3 files changed, 6 insertions(+), 6 deletions(-)`. Состав:
- 4 строки `--no-renames` в pre-push:215,216,271,272;
- 1 строка ПАУЗЫ в `roles/orchestrator.md:364`;
- 1 строка ПАУЗЫ в `.omp/agents/orchestrator.md:367`.

Ветвь перебазирована на da0ba1fd. `git range-diff 7dc408e2..56f4b03a da0ba1fd..4deeb63f~1` даёт 7/7 `=`: патчи прежних семи коммитов идентичны осуждённым в v2.

Барьер не тронут:
- `git diff --stat frozen/contracts/167/2 OBJECT -- contracts/167-…md fixtures/workshop_project/obryv_167/` — пусто, rc=0;
- `git log da0ba1fd..OBJECT -- contracts fixtures/workshop_project/obryv_167` — пусто.

## 2. Р167-Б1 — rename-пересечение (атака своей мерой)

Одноразовый скрипт `/tmp/dev-harness-verify/rename_attack.py` удалён после прогона. Мир:
- toy-репо с `file://` origin;
- `shared.txt` из 20 строк;
- side=main: main делает `git mv shared.txt moved.txt`, ветка `wip/167/architect` правит строку 10;
- side=branch: зеркально;
- чистый полный `git merge --no-ff main`, двухродительский, результат `moved.txt` с правкой;
- настоящий `.githooks/pre-push` OBJECT и, для красного, pre-push родителя `4deeb63f~1` (= осуждённый 56f4b03a).

`diff.renames` задаётся `git config` в toy-репо.

```
RENAME side=main diff.renames=true hook=OBJECT main_delta=['moved.txt'] branch_delta=['shared.txt'] rc=1 stderr=['ОТКАЗ: pre-push: merge main в ветку запрещён (арбитраж merge-wip-protiv-main-konflikt-norm): ref=refs/heads/wip/167/architect коммит=1a5863f3… — родитель 4a935eaa… приносит историю main, которой нет у первого родителя; …']
RENAME side=main diff.renames=true hook=PARENT main_delta=['moved.txt'] branch_delta=['shared.txt'] rc=0 stderr=[]
RENAME side=main diff.renames=false hook=OBJECT main_delta=['moved.txt', 'shared.txt'] branch_delta=['shared.txt'] rc=1 stderr=['ОТКАЗ: pre-push: merge main в ветку запрещён …']
RENAME side=main diff.renames=false hook=PARENT main_delta=['moved.txt', 'shared.txt'] branch_delta=['shared.txt'] rc=1 stderr=['ОТКАЗ: pre-push: merge main в ветку запрещён …']
RENAME side=main diff.renames=copies hook=OBJECT main_delta=['moved.txt'] branch_delta=['shared.txt'] rc=1 stderr=['ОТКАЗ: pre-push: merge main в ветку запрещён …']
RENAME side=main diff.renames=copies hook=PARENT main_delta=['moved.txt'] branch_delta=['shared.txt'] rc=0 stderr=[]
RENAME side=branch diff.renames=true hook=OBJECT main_delta=['shared.txt'] branch_delta=['moved.txt'] rc=1 stderr=['ОТКАЗ: pre-push: merge main в ветку запрещён …']
RENAME side=branch diff.renames=true hook=PARENT main_delta=['shared.txt'] branch_delta=['moved.txt'] rc=0 stderr=[]
RENAME side=branch diff.renames=false hook=OBJECT main_delta=['shared.txt'] branch_delta=['moved.txt', 'shared.txt'] rc=1 stderr=['ОТКАЗ: pre-push: merge main в ветку запрещён …']
RENAME side=branch diff.renames=false hook=PARENT main_delta=['shared.txt'] branch_delta=['moved.txt', 'shared.txt'] rc=1 stderr=['ОТКАЗ: pre-push: merge main в ветку запрещён …']
RENAME side=branch diff.renames=copies hook=OBJECT main_delta=['shared.txt'] branch_delta=['moved.txt'] rc=1 stderr=['ОТКАЗ: pre-push: merge main в ветку запрещён …']
RENAME side=branch diff.renames=copies hook=PARENT main_delta=['shared.txt'] branch_delta=['moved.txt'] rc=0 stderr=[]
RENAME_ATTACK OBJECT_NOT_REJECTED=0
rc=0
```

Красное предъявлено: хук родителя пропускает атаку при `true`/`copies` (rc 0), хук OBJECT отказывает во всех 6 клетках (rc 1).

Исход OBJECT больше не зависит от `diff.renames`. Отказ несёт требуемую контрактом фразу «merge main в ветку запрещён»: исключение возвращает 1 и отдаёт управление прежней логике кольца.

Других `git diff` в `merge_167_razreshen` нет: grep `diff|merge-tree|renames` по pre-push:188–300 → только :215,:216,:271,:272 (все с `--no-renames`) и `merge-tree --write-tree` :226. Детекция переименований `merge-tree` не определяет пересечение путей.

## 3. Р167-Б2 — фраза владельца (своя мера)

python по `git show` блобов:
```
pause lines roles/gen: 1 1 source==generated: True source==owner-base: True
fragment: кто/когда согласовал, условие возврата
```

Строка ПАУЗЫ в OBJECT побайтно равна строке базы da0ba1fd, то есть тексту владельца. sha256 строки (`grep -n | sha256sum`), база и OBJECT:
- roles: c42d171f…8ff41 = c42d171f…8ff41;
- генерат: 67efd079…8bb848 = 67efd079…8bb848.

`grep -c 'условия возврата'` в обоих файлах OBJECT = 0.

История фразы: `git log -S 'согласовал, условие возврата' -- roles/orchestrator.md` →
- `88500cac owner 2026-10-28` (внесена);
- `ac7daf16 implementer` (удалена, Р167-Б2);
- `4deeb63f implementer` (возвращена).

`git diff --numstat da0ba1fd OBJECT` → `roles/orchestrator.md 10 0`, `.omp/agents/orchestrator.md 10 0`. Удалённых строк в роли и генерате нет, чужие нормы не тронуты.

Генерат: `npm run -s gen:harness -- --check` (клон, OBJECT) → `харнес соответствует roles/ (12 ролей)`, rc=0. Своя мера — построчное равенство строки ПАУЗЫ источника и генерата: True (выше).

## 4. Приёмка 167 на OBJECT (клон)

`bash fixtures/workshop_project/obryv_167/red_obryv_167.sh --repo`:
```
CASE interrupted ok
CASE verdict ok
CASE verdict_no_receipt ok
CASE reviewer_verdict ok
CASE remote_unavailable ok
CASE verdict_wrong_author ok
CASE verdict_wrong_path ok
CASE verdict_wrong_object ok
CASE verdict_wrong_session ok
CHECKED 9 CASES; FAILURES 0
MERGE separate ok
MERGE registry ok
MERGE overlap ok
MERGE registry_drop ok
MERGE partial ok
MERGE other_ref ok
rc=0
```

`--model`: те же 15 строк ok, `CHECKED 9 CASES; FAILURES 0`, rc=0.

`--stabs`: 15 строк ok, rc=0. Пойманы:
- `ignore_all_starts` (verdict, interrupted), `yield_is_verdict`, `always_block`, `no_retry_limit`;
- `skip_remote_check`;
- `no_author_check`/`broader_path`/`no_object_check`/`no_session_check`;
- `forbid_all` (separate, registry), `allow_all` (overlap, registry_drop, partial);
- `no_ref` (other_ref).

Своя мера повторным прогоном с подсчётом python: `caught 16 zhiv 0 ok 15`, rc=0.

## 5. Паразитная сложность (050)

| артефакт | (1) свойство | (2) состояние | (3) файлов вместе | (4) глубина | (5) потребитель / повтор | класс |
|---|---|---|---|---|---|---|
| флаг `--no-renames` ×4 в `merge_167_razreshen` | §Предмет п.1 «не пересекаются по путям», детерминированно | нового нет; снимает неявную зависимость от пользовательского `diff.renames` | 1 (без роста) | интерфейс функции не изменён | `red_obryv_167.sh --repo`; грамматику не повторяет | ESSENTIAL |
| строка ПАУЗЫ (роль + генерат) | возврат чужой нормы | нет | 2, как у всех ролей | — | `gen:harness --check` | ESSENTIAL (откат) |

Новых скриптов, флагов CLI, env и состояния дифф не вводит.

## 6. ПРОВОДКА / стандарты

ПРОВОДКА: исправление не трогает ни норма-строк 167, ни guard-путей. В роли и генерате изменена только строка ПАУЗЫ. Прежняя сверка v2 §3/§8 в остальном не пересматривается.

СВЕРКА-СТАНДАРТОВ: не применимо. `AGENTS.md` dev-harness не объявляет ни документа архитектуры, ни стандарта кода: grep `ARCHITECTURE|CODING-STANDARDS|стандарт кода` по AGENTS.md — 0 совпадений. Режим проекта 996 не объявлен, sourceCanon нет.

Детектор основного чекаута перед материализацией: `bash scripts/check_no_leak.sh --check /home/harness/dev-harness` → `основной чекаут чист`, rc=0.

## Находки

status: ready

- [x] **Р167-Б1 (БЛОК v2, implementer) — закрыта.** `--no-renames` в pre-push:215,216,271,272. Атака §2: OBJECT 6/6 rc 1, родитель 4/6 rc 0 (красное).
- [x] **Р167-Б2 (БЛОК v2, implementer) — закрыта.** Строка ПАУЗЫ равна тексту владельца 88500cac, генерат совпадает, `gen:harness --check` rc 0.
- [ ] **С-4 (совет, implementer/architect).** Rename-клетки нет в замороженном барьере. Регрессия `--no-renames` поймается только ревью.
  - Барьер — зона architect: клетку `MERGE rename` (обе стороны, `diff.renames=true`) можно добавить в v+1.
  - Готовая форма мира — §2.
- [ ] **С-5 (совет, атомарность).** Обе находки закрыты одним коммитом 4deeb63f.
  - Это одна исправительная задача одного предмета, со ссылкой на 167 и ID обеих находок. Откату по частям не мешает: правки в разных файлах.
  - Не блок. Раздельные коммиты на находку читались бы чище.
- Открыты из v2, этим вызовом не судимы: БЛОК-DONE-1 (orchestrator/контракт — блок done), В-1, В-2, В-3, В-4, С-1, С-2, С-3.
