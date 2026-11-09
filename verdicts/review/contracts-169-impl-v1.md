accept
OBJECT=ab3cf479cdcdf1d7ce741a760c25fc528ad7b790
сессия=Review169Canonical
СУД: repo=dev-harness; предмет=169; фаза=реализация; роль=reviewer; вызов=1/2 (полный); модель-план=anthropic/claude-opus-5-5; сессия=Review169Canonical; модель-факт=anthropic/claude-opus-5-5; SHA=ab3cf479cdcdf1d7ce741a760c25fc528ad7b790; предыдущий=нет (суд реализации 169 первый); исключение=нет
Контракт: frozen/contracts/169/1 (tag-object 3b686197… → коммит 5d48155f). Кандидат: PR #626, head `wip/int-169/implementer` = OBJECT; локальный канонический `wip/169/implementer` → OBJECT; tree 804c6aca43e14818a9311f8e213f0cf998d4b0f8. База: main 41218f7cf85959752f638465d4d5d33d8a712552 (родитель OBJECT, предок — проверено `merge-base --is-ancestor`).
--sud: reviewer <трасса> Review169Canonical; строка трассы (`scripts/models_actual.sh --tsv --bind --all`, сама команда rc 2 по чужой сессии `Arbiter079Б1` — известный NOT_IMPLEMENTED из HANDOFF, строка моей сессии выдана до отказа): `reviewer	anthropic/claude-opus-5-5	allowed	Review169Canonical	ab3cf479cdcdf1d7ce741a760c25fc528ad7b790`; `scripts/check_sud_model.sh --verdict reviewer --trace <файл с этой строкой> --object ab3cf479… --session Review169Canonical --root .` → `СУДЬЯ СВОЕЙ МОДЕЛИ: вердикт reviewer материализуется`, rc=0. Автор реализации — identity implementer (author implementer, committer orchestrator); ревьюер её не писал.

# Вердикт reviewer — 169, реализация, вызов 1 (полный)

## Итог

accept. Все четыре обязательства задания выполнены на OBJECT:

- явный не-файловый `--model-trace` (строка модели, несуществующий путь, путь без «/», каталог) → rc 1, stdout пуст, stderr ровно новая строка контракта; подложенный `<registry>/trace.tsv` его не маскирует;
- проектный fallback работает только без аргумента: brief rc 0 с TRACE-строкой из `<registry>/trace.tsv`;
- при полном отсутствии трассы — прежний `ОТКАЗ: нет свидетельства модели: orchestrator`, rc 1;
- шаг 0 роли (и генерат) называет оба способа; строка байт-в-байт равна ПРОВОДКА-строке контракта.

Блокирующих находок нет. Советы и наблюдения — `.review/2026-11-09-93.md`. Блок done по CI-проводке (обязанность оркестратора по контракту) остаётся — см. Н-1.

Accept привязан к блобам OBJECT:
- `scripts/make_task.sh` 93e0f771692bc6ff0d5f8df85cc624bf3beed694;
- `roles/orchestrator.md` f0274b4f85c7e6d52590f1d1ac22e31a3166f969;
- `.omp/agents/orchestrator.md` 0e69dd7cad2642d5c3f3a3dfa3b8dc869f938d68.

Новая редакция этих блобов accept не наследует.

Область суда — scoped: семья 169 (`--repo/--model/--stabs`/без флага), мои мутации, frozen-diff, старые контроли 095/136, гейты pre_critic/check_provodka/check_project_sources/gen. Полного CI не гонял; CI PR #626 на OBJECT: 16 SUCCESS, 1 SKIPPED (`vorota`), 0 failure (`gh pr view 626 --json statusCheckRollup`).

Прогоны шли в одноразовом SSH-клоне `/tmp/dev-harness-verify/r169-1794227637`: `git clone ssh://git@github.com/a3ka/dev-harness.git`, `git fetch origin ab3cf479…`, detached HEAD = OBJECT, `git status --short` = 0 строк. SSH-хостов харнесса нет (`ssh://` → «No SSH hosts are configured»), клон — через git по ssh-URL origin. Push не делался, wip-веток не создавалось.

## 1. Область правки (своя мера: python по ЗОНЕ из frozen-блоба)

ЗОНА implementer из `frozen/contracts/169/1:contracts/169-…md`: `['scripts/make_task.sh', 'roles/orchestrator.md', '.omp/agents/orchestrator.md']`.

```
changed 3 ['.omp/agents/orchestrator.md', 'roles/orchestrator.md', 'scripts/make_task.sh'] outside-zone []
provodka-line-in-role True count 1
```

`git diff --numstat 41218f7cf ab3cf479c`:
```
1	1	.omp/agents/orchestrator.md
1	1	roles/orchestrator.md
22	7	scripts/make_task.sh
```

ПЕРЕСЕЧЕНИЯ:
- роль и генерат: изменена одна строка, шаг 0; чужие нормы не тронуты;
- `make_task.sh` 136: блок fallback перенесён в `else` без изменения логики, только отступ;
- 095: при незаданном аргументе `TRACE` непуст только при `-f <registry>/trace.tsv`, поэтому `[ -n "$TRACE" ] || die "нет свидетельства модели: $ROLE"` эквивалентен прежнему `[ -z ] || [ ! -f ]`; грамматика TSV, выбор модели, allowed|denied, резолвер 103/996 не тронуты (вне hunk'ов диффа).

## 2. Барьер не переписан под реализацию (frozen-diff)

```
git diff --quiet frozen/contracts/169/1 OBJECT -- contracts/169-model-trace-put-i-project-brief.md fixtures/workshop_project/model_trace_169/   → rc=0
git log 41218f7cf..OBJECT -- contracts fixtures   → пусто
```

Семья — коммит architect `a73637c0`, принят критиком (`verdicts/critic/contracts-169-v1.md`). Автор реализации файлов проверки не трогал.

## 3. Приёмка 169 на OBJECT (клон)

`bash fixtures/workshop_project/model_trace_169/red_model_trace_169.sh --repo`:
```
169 project_no_arg ok rc=0 stderr=''
169 explicit_model_string ok rc=1 stderr='ОТКАЗ: --model-trace ожидает путь к TSV-файлу трассы (роль<TAB>модель<TAB>allowed); в проектном корне аргумент можно опустить — берётся <registry>/trace.tsv'
169 explicit_missing_path ok rc=1 stderr='ОТКАЗ: --model-trace ожидает путь к TSV-файлу трассы (роль<TAB>модель<TAB>allowed); в проектном корне аргумент можно опустить — берётся <registry>/trace.tsv'
169 no_trace_anywhere ok rc=1 stderr='ОТКАЗ: нет свидетельства модели: orchestrator'
169 orchestrator_step_0 ok
rc=0
```

`--model`: те же 5 строк ok, rc=0.

`--stabs` (контроль 5 ok, затем):
```
169 STAB old_missing_error caught @ explicit_model_string
169 STAB explicit_falls_back caught @ explicit_model_string
169 STAB no_default caught @ project_no_arg
169 STAB missing_is_new caught @ no_trace_anywhere
169 STAB old_step caught @ orchestrator_step_0
rc=0
```
5 caught, 0 ZHIV. Адреса мутант→вход — только в коде `probe.py` (`stubs = [...]`), в прозе контракта пар нет (Н-39).

Без флага (CI-форма): `--repo` + `--model` + `--stabs` подряд, все ok/caught, rc=0.

### Красное предъявлено (своя мера: дерево родителя)

`python3 probe.py --repo <worktree 41218f7cf>` (дерево до реализации):
```
169 project_no_arg ok rc=0 stderr=''
169 explicit_model_string KRASNO rc=1 stderr='ОТКАЗ: нет свидетельства модели: orchestrator'
169 explicit_missing_path KRASNO rc=1 stderr='ОТКАЗ: нет свидетельства модели: orchestrator'
169 no_trace_anywhere ok rc=1 stderr='ОТКАЗ: нет свидетельства модели: orchestrator'
169 orchestrator_step_0 KRASNO
rc=1
```
Ровно три клетки, названные критерием, красны до правки и зелены на OBJECT.

### Старые контроли (без переписывания фикстур)

```
bash fixtures/context_pack_095/red_svidetelstvo_modeli.sh          → rc095=0
bash fixtures/workshop_project/sessii_136/red_sessii_136.sh --model → sessii_136: клеток 87, зелёных 87, красных 0; rc136=0
```

## 4. Мои мутации против OBJECT `make_task.sh` (одноразовый `/tmp/dev-harness-verify/r169_mut.py`)

Мир — toy 095 с `ci.yml` (проектный профиль), второй мир без `ci.yml` (вне проекта). Клетки — `probe.cases` замороженной семьи плюс мои пограничные входы.

OBJECT:
```
OBJECT_ALL_OK True
EDGE explicit_dir (1, 'ОТКАЗ: --model-trace ожидает путь к TSV-файлу трассы …', True)
EDGE explicit_other_model (1, 'ОТКАЗ: --model-trace ожидает путь к TSV-файлу трассы …', True)
EDGE explicit_good_overrides (0, ['TRACE: role=orchestrator model=x/other-model fallback=denied'], '')
EDGE explicit_model_no_fallback (1, 'ОТКАЗ: --model-trace ожидает путь к TSV-файлу трассы …', True)
OUTSIDE explicit_model 1 True True
OUTSIDE no_arg 1 True
```
Пояснения:
- явный валидный файл переопределяет проектную трассу;
- явная строка модели отказывает новым диагнозом и без трассы в реестре;
- вне проекта: явный не-файл → новый диагноз, без аргумента → старый.

Отдельный прогон (`/tmp/dev-harness-verify/r169_ns.py`, проектный мир с подложенной трассой; закрывает класс критика mutC — вход без «/»):
```
arg=net-fayla.tsv rc=1 stdout_bytes=0 trace=[] stderr='ОТКАЗ: --model-trace ожидает путь к TSV-файлу трассы …'
arg=gpt-6-sol rc=1 stdout_bytes=0 trace=[] stderr='ОТКАЗ: --model-trace ожидает путь к TSV-файлу трассы …'
arg=registry rc=1 stdout_bytes=0 trace=[] stderr='ОТКАЗ: --model-trace ожидает путь к TSV-файлу трассы …'
arg=<none> rc=0 stdout_bytes=808 trace=['TRACE: role=orchestrator model=openai-codex/gpt-6-sol fallback=allowed'] stderr=''
```

Мутации:
```
MUT MA_no_explicit_flag family_red=['explicit_model_string', 'explicit_missing_path'] edge_dir=(1, '…read error: 0: Is a directory\nОТКАЗ: свидетельство не той роли: orchestrator') outside_explicit_ok=False
MUT MB_exists_not_regular family_red=[] edge_dir=(1, '…read error: 0: Is a directory\nОТКАЗ: свидетельство не той роли: orchestrator') outside_explicit_ok=True
MUT MC_explicit_then_fallback family_red=['explicit_model_string', 'explicit_missing_path'] edge_dir=(0, '') outside_explicit_ok=True
MUT MD_absent_gets_new family_red=['no_trace_anywhere'] edge_dir=(1, 'ОТКАЗ: --model-trace ожидает путь …') outside_explicit_ok=True
MUT ME_new_only_in_project family_red=[] edge_dir=(1, 'ОТКАЗ: --model-trace ожидает путь …') outside_explicit_ok=False
MUT MF_model_prefix_only family_red=['explicit_missing_path'] edge_dir=(1, 'ОТКАЗ: нет свидетельства модели: orchestrator') outside_explicit_ok=True
rc=0
```
- MA (снят признак явности), MC (явный не-файл → проектная трасса), MD (новый диагноз при полном отсутствии), MF (распознавание по префиксу модели) — пойманы замороженной семьёй.
- MB (`-e` вместо `-f`: каталог проходит проверку) и ME (новый диагноз только в проектном корне, вне проекта — старый) семья НЕ ловит. OBJECT на этих входах корректен (`explicit_dir` и `OUTSIDE explicit_model` выше). Это пробел барьера в зоне architect, не дефект реализации → советы С-1, С-2.

## 5. Атомарность, история, норма

- Один коммит `ab3cf479c` «implementer: 169 — …», одна задача, ссылка на предмет. Связок нет.
- Правка `roles/orchestrator.md` — не тихая правка нормы: шаг 0 прямо требует §Предмет, ПРОВОДКА role= и ЗОНА implementer. Изменённая строка равна ПРОВОДКА-строке контракта (count 1). Других строк роли дифф не меняет.
- Генерат: `npm run -s gen:harness -- --check` (клон, OBJECT) → `харнес соответствует roles/ (12 ролей)`, rc=0; строка `169): в проектном корне` в `.omp/agents/orchestrator.md` — 1.

## 6. Гейты контракта на OBJECT (клон)

```
bash scripts/pre_critic.sh --repo . contracts/169-…md      → «КРИТИК: дверь зелёная», rc=0
bash scripts/check_provodka.sh . contracts/169-…md          → rc=0 (вывода нет)
bash scripts/check_project_sources.sh --repo . --contract contracts/169-…md --stage done → rc=0
grep model_trace_169 registry/ci-steps.tsv .github/workflows/ci.yml → 0 совпадений
```

## 7. ПРОВОДКА (038)

- role-канал: `roles/orchestrator.md` шаг 0 несёт норма-строку дословно; генерат совпадает.
- guard=`scripts/make_task.sh`: сама дверь, выдающая именованный отказ, — барьер именно этого предмета (явный не-файл отказывает до брифа).
- Барьер-семья 169 в CI ещё не подключена (Н-1). `check_provodka` rc 0 этого не ловит, поэтому done держится на шаге оркестратора, названном контрактом.

## 8. Паразитная сложность (050)

| артефакт | (1) свойство | (2) состояние | (3) файлов вместе | (4) глубина | (5) потребитель / повтор | класс |
|---|---|---|---|---|---|---|
| переменная `TRACE_EXPLICIT` + ветвь явного аргумента | §Предмет: явный и незаданный — разные входы; явный не маскируется fallback | новое, явное: выставляется только разбором `--model-trace` | 1 (без роста) | CLI не изменён; новых флагов, env, кодов возврата нет | `red_model_trace_169.sh` клетки explicit_*; грамматику не повторяет | ESSENTIAL |
| внутренний `if [ -z "$TRACE" ]` в `else`-ветви | — (в `else` `TRACE` всегда пуст) | нет | 1 | мёртвое условие | тот же шаг | ACCIDENTAL, совет С-3 (не называет непроходящего свойства) |
| строка шага 0 (роль + генерат) | ПРОВОДКА role= | нет | 2, как у всех ролей | — | `orchestrator_step_0`, `check:gen` | ESSENTIAL |

## 9. Стандарты / режим проекта

СВЕРКА-СТАНДАРТОВ: не применимо. `AGENTS.md` не объявляет документа архитектуры и стандарта кода: `grep -c 'ARCHITECTURE|CODING-STANDARDS|стандарт кода' AGENTS.md` → 0. `harness.project.json` упоминает `CODING-STANDARDS.md`/`ARCHITECTURE.md` строками contextPack с `mandatory:false`, но файлов в дереве OBJECT нет (`ls` → No such file).

Режим проекта 996: `harness.project.json` есть, `sourceCanon` не объявлен → сверка карты не требуется; `check_project_sources --stage done` rc 0 (§6).

Детектор основного чекаута перед материализацией: `bash scripts/check_no_leak.sh --check /home/harness/dev-harness` → `основной чекаут чист`, rc=0.

## Находки (класс каждой; подробно — `.review/2026-11-09-93.md`)

- **Н-1 (БЛОК done, адресат orchestrator; не блок accept реализации).** Шаг `bash fixtures/workshop_project/model_trace_169/red_model_trace_169.sh` не записан в `registry/ci-steps.tsv`/`ci-zamery.tsv`/`ci.yml`. Контракт: «До подключения CI guard-канала done невозможен».
- **С-1 (совет, architect).** Мутант MB (`-e` вместо `-f`) жив: в семье нет клетки «явный каталог», хотя §Предмет говорит «не указывающий на обычный файл».
- **С-2 (совет, architect).** Мутант ME (новый диагноз только в проектном корне) жив: все клетки семьи — проектный мир, явного не-файла вне проекта нет.
- **С-3 (совет, implementer; 050).** `make_task.sh`: внутренний `if [ -z "$TRACE" ]; then … fi` в `else`-ветви — мёртвое условие.
- **О-1 (наблюдение, orchestrator).** Предвызовной строки `СУД: … предмет=169; … роль=reviewer` в HANDOFF main (41218f7cf) нет (grep `предмет=169` → 0). Зеркалирую строку в шапке этого вердикта.
- **О-2 (наблюдение, orchestrator).** На origin ветка кандидата — `wip/int-169/implementer`; `wip/169/implementer` есть только локально (→ OBJECT). Вердикт связан с SHA, не с именем ветки.
