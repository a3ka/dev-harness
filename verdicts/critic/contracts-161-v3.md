FAIL
OBJECT=eec120d6b24b4cdba1504afce5485d6f30dcc3dd
СУД: repo=dev-harness; предмет=161; фаза=контракт; роль=critic; вызов=6/6 (5/5→6/6 по слову владельца 2026-11-06 ~23:10 UTC дословно «а как мы пойдем дальше по 161 без доп суда? если уже начали делать, то надо и еще один суд делать»); модель-план=zai/glm-5.3; сессия=Critic161GlmV6; модель-факт=zai/glm-5.3 (workstation; judge-trace ниже); предыдущий=Critic161BareRetry accept 5/5 на 2c7abb6e (НЕ материализован: check_sud_model rc1 Н-270); материализованные: contracts-161-v1-fail.md (FAIL), contracts-161-v2.md (accept); автор=openai-codex/gpt-6-sol (независимость семейств glm≠gpt по трейсу продюсера).

# Критик 161a — вызов 6/6: суд дельты приёмки 2c7abb6e..eec120d6

Судил OBJECT eec120d6 в одноразовом SSH-клоне (origin ssh://git@github.com/a3ka/dev-harness.git, импорт bundle `wip/161/architect ^origin/main`, FETCH_HEAD=eec120d6, ветка judge-161, рабочее дерево чисто). Предмет суда: контракт contracts/161-…md + обязательная модель (батарея fixtures/workshop_project/proektnaja_raskladka_161/probe.py) на OBJECT; дельта = перевод приёмки на реальные двери с честным красным (3157dc61 → 0bb025e2 → eec120d6).

## Честность красного дельты — подтверждена живьём

Ядро дельты (правило `--model`/`--stabs`, contracts/161-…md:27; SPEC «Прогоны» п.3) кодировано правильно: контроль благословляет ровно два честных состояния — до-cutover bare rc 1 ровно два класса (счётчик кратностей + якорные подстроки) либо после-cutover bare rc 0 без нарушений; полусостояния и подмены классов отбрасываются `CONTROL_INVALID`. Живые атаки на зубы контроля (одноразовые копии scratch-B/scratch-C, мутации только в зоне implementer):

- Мутация B (полу-cutover: манифест наружу в `$TMPDIR/ext-state-161`, spawn не читает) — bare: `PROFILE_PATH_MISSING` + `MANIFEST_MAIN_ONLY` ×2 (positive spawn + foreign-layer spawn); `--model` → `CONTROL_INVALID: honest product outcome is neither post-cutover green nor the measured two-class pre-cutover red`, rc 1. Поймано кратностью.
- Мутация C (spawn молча принимает отсутствующий манифест, `i15_gate` → `exit 0`) — bare: + `MANIFEST_MAIN_ONLY: positive spawn`, `SPAWN_WRONG_BRANCH`, `SPAWN_NO_WORKTREE`, `WORKTREE_IN_MAIN`, `SPAWN_FOREIGN_REPOSITORY`, `MANIFEST_MISSING: missing pack not rejected before mint`; `--model` → `CONTROL_INVALID`, rc 1. Слияние классов невозможно.
- `--stub-invoke` достижим только из самой батареи (probe.py перезапускает себя); субъект-дверь не может подсунуть себе стаб. Bare-прогон стабами не подменяется (`--stabs` сначала честный контроль, затем мутанты поверх базовой картины, ровно +1 собственный класс: STAB_CAUGHT ×3, rc 0).

Счётные утверждения контракта сверены с живыми источниками, расхождений НЕТ: make_task.sh:340-343 (optional skip: `die "источник недоступен"` / `continue`), :402-428 (поиск незамороженного черновика в переданном worktree), :555-557 (`$REPO/.omp/context/${CONTRACT}.tsv`), spawn_agent.sh:104-125 (i15_gate `$ROOT/.omp/context/<NNN>.tsv`, «ОТКАЗ: нет манифеста make_task»), :155-159 (нога ДО «1. тег жив локально»), zamok_predmeta.sh:150-201 (`registry/pauzy.tsv` → `.harness/registry/pauzy.tsv`).

Гейты на OBJECT (клон, дословно): pre_critic rc 0 «КРИТИК: дверь зелёная»; check_precision_gate rc 0 `OK`; check_threat_model rc 0 (ЗАЩИЩАЕТ 2 / НЕ ЗАЩИЩАЕТ 2); check_spec_ready rc 0 `OK`; check_ceilings rc 0 «потолки в порядке»; check_provodka rc 1 «guard не подключён» — ожидаемый до-реализационный класс. Батарея: bare rc 1 `MANIFEST_MAIN_ONLY: no unique external manifest before spawn` + `PROFILE_PATH_MISSING: absent optional row accepted`; `--model` rc 0 `CONTROL: honest product expected red: MANIFEST_MAIN_ONLY, PROFILE_PATH_MISSING`; `--stabs` rc 0 + `STAB_CAUGHT: optional-skipped/foreign-make/missing-spawn`. Воспроизводит заявленные факты Architect161aVerify побайтно.

## Блокирующая находка

БЛОКИРУЕТ contracts/161-revizija-mekhanizmov-proektnaja-raskladka.md:26 (+ SPEC.md «Отрицательные входы»: «→ LAYER_FOREIGN либо собственный контекст, без чужих bytes и побочных эффектов»; оба текста входят в предъявленный кандидат, SPEC-строка переписана самой дельтой) — клетка конфликта обещает механические доказательства, которых обязательная модель не несёт; критерий слабее предмета. Три проявления одного класса:
(а) «rc 0 … без записи в чужой проект» — в probe.py нет ни одного снимка состояния foreign-проекта: инструмент `snapshot()` (HEAD/индекс/status) применяется только к mob (probe.py:124,142,169,190,221); `foreign` используется лишь как источник байтов rows и значение HARNESS_PROJECT_LAYER_ROOT;
(б) «отказывает rc 1 LAYER_FOREIGN ДО побочного эффекта» для make_task — на ветви отказа не проверяется отсутствие выданного пакета (парная проверка для PROFILE_PATH_MISSING существует: probe.py:167 `not no_optional.stdout`);
(в) тот же порядок для spawn — на ветви отказа sp_conflict не проверяется отсутствие ветки/worktree (парная проверка для MANIFEST_MISSING существует: probe.py:184-186 `wip/762/architect not in branches`; создание ветки не видно снимку main, ветка — ref, не статус).
ОБЯЗАТЕЛЬСТВО: contracts/161-…md:26 — исход клетки («тогда каждый либо отказывает rc 1 LAYER_FOREIGN до побочного эффекта, либо rc 0 только со своими байтами контекста/манифеста и без записи в чужой проект») обязан наблюдаться W механически (ПРОВОДКА-ЭНФОРСМЕНТ; Н-39: инварианты + rc-команды).
СОСТОЯНИЕ: реализация, разрешившая конфликт собственным профилем rc 0 и оставившая запись в чужом проекте (или выдавшая пакет/ветку до отказа LAYER_FOREIGN), проходит bare W rc 0 после cutover и контроль rc 0 — обещанное свойство не доказано ничем.
НАБЛЮДЕНИЕ (живая атака A, одноразовая копия scratch-A, мутация в зоне implementer): в make_task.sh перед записью манифеста добавлен блок `if [ -n "${HARNESS_PROJECT_LAYER_ROOT:-}" ]; then mkdir -p "$HARNESS_PROJECT_LAYER_ROOT/.omp" && printf 'x' >"$HARNESS_PROJECT_LAYER_ROOT/.omp/cache-161a"; fi` — прямое нарушение «без записи в чужой проект»; результат побайтно тот же честный красный: bare rc 1 ровно `MANIFEST_MAIN_ONLY: no unique external manifest before spawn` + `PROFILE_PATH_MISSING: absent optional row accepted`; `--model` rc 0 `CONTROL: honest product expected red: MANIFEST_MAIN_ONLY, PROFILE_PATH_MISSING`. Батарея слепа к нарушению; после cutover тот же дефект сидит внутри зелёного прогона.
ОБХОД: источник входа — конформный конфликтный вход самой клетки критерия (contracts/161-…md:26 «Дано: два валидных проекта … конфликтный HARNESS_PROJECT_LAYER_ROOT», SPEC «Отрицательные входы», демаркация: локальные проекты/bare-origin); источник ошибочного механизма — отсутствие обещанной проверки в обязательной модели при том, что парная проверка (MAIN_DIRTY-снимок) в той же батарее существует и применена только к целевому проекту (probe.py:142,190,221) — воспроизведение документированного обещания без его механизма (тот же класс, что v1-находка предмета 161: «критерий не доказывает паритет, который прямо обещает»).
Закрывающее свойство (не единственная реализация): симметрично существующим проверкам — снимок HEAD/индекса/status foreign-проекта до/после обеих клеток конфликта, пустой stdout на ветви отказа make_task, отсутствие ветки на ветви отказа spawn. Правка ~4 строки в probe.py, зона architect, до заморозки; перезаписи фикстур не требуется.

## Прочее, проверено и не блокирует

- КЛАСС РИСКА: рисковый — основание «замок/чужой предмет» (авторизация) совпадает с предметом; рисковый маршрут (adversary) заявлен в HANDOFF фаза 1.1. Модель угроз валидна и по форме, и по площади: незакрытая проверка (а) лежит в приёмочном критерии, НЕ в границе ЗАЩИЩАЕТ/НЕ ЗАЩИЩАЕТ — сужать обещание критерия молча нельзя (§Порог), потому находка блокирующая, а не совет.
- Зоны/исполнители: implementer = ровно оба файла, которые придётся тронуть (make_task.sh, spawn_agent.sh); zamok/resolver/dual-control явно сохраняются и судятся своими батареями (140, 023) — названо в «Существующее». Н-39 соблюдён: стабы привязаны к ветвям кодом probe.py, контракт несёт инварианты + rc-правило.
- Замечаний к honest-red кодировке дельты нет (см. атаки B/C выше); красное до реализации честно и не выдаётся за готовность («rc 0 контроля не выдаётся за успешную реализацию» — SPEC, соблюдено).

## Советы (едут с вердиктом, не блокируют)

СОВЕТ HANDOFF (main d3b31f33 на момент суда): строка `СУД:` вызова 6/6 в HANDOFF отсутствует — зеркалирована заданием судьи и этим вердиктом; оркестратору дописать по §Счёт до материализации.
СОВЕТ contracts/161-…md:16 — механизм размещения внешнего манифеста (куда именно и как spawn его находит из project-main) не назван; свойство связано сквозным доказательством (уникальный внешний манифест + spawn находит его без сотрудничества пробы: проба не выставляет env расположения), но реализатору стоит назвать механизм в реализационном решении, чтобы не выбирать молча.

## Сырые команды и выводы (одноразовый клон /tmp/dev-harness-verify/Critic161GlmV6)

- `git clone ssh://git@github.com/a3ka/dev-harness.git repo` → rc 0, origin/main=d3b31f330f; bundle-импорт `wip/161/architect` → FETCH_HEAD=eec120d6b24b4cdba1504afce5485d6f30dcc3dd, `git status` чист.
- Гейты: см. выше, все rc подтверждены живым запуском в клоне.
- `bash fixtures/workshop_project/proektnaja_raskladka_161/red_proektnaja_raskladka_161.sh` → rc 1, две строки классов (дословно в «Честность красного»).
- Атака A (scratch-A, инъекция в make_task.sh перед блоком манифеста): bare → rc 1, те же две строки; `--model` → rc 0 `CONTROL: honest product expected red: MANIFEST_MAIN_ONLY, PROFILE_PATH_MISSING`.
- Атака B (scratch-B, `$REPO/.omp/context` → `${TMPDIR}/ext-state-161` в make_task.sh:555-557): bare → rc 1 `PROFILE_PATH_MISSING: absent optional row accepted` + `MANIFEST_MAIN_ONLY: positive spawn: ОТКАЗ: нет манифеста make_task: 761` + `MANIFEST_MAIN_ONLY: foreign-layer spawn has no readable external manifest: ОТКАЗ: нет манифеста make_task: 761`; `--model` → rc 1 `CONTROL_INVALID…`.
- Атака C (scratch-C, i15_gate `[ ! -s "$mf" ]` → `exit 0`): bare → rc 1, 7 строк (см. выше); `--model` → rc 1 `CONTROL_INVALID…`.
- Клоны scratch-A/B/C и judge-клон одноразовые; основной репозиторий не тронут (записей вне verdicts/critic/ нет, push не выполнялся).

## Judge-trace и материализация (после коммита вердикта)

- `bash scripts/models_actual.sh --tsv --bind | awk -F'\t' -v s=Critic161GlmV6 '$4==s'` (из основного корня) → дословно:
  `critic	zai/glm-5.3	allowed	Critic161GlmV6	eec120d6b24b4cdba1504afce5485d6f30dcc3dd` (×2; allowed = без фолбэка).
  Примечание: полный прогон models_actual завершается rc 2 «NOT_IMPLEMENTED: session-id вне алфавита [A-Za-z0-9._-]: Arbiter079Б1» — посторонняя старая сессия с кириллицей в имени, на строки данной сессии не влияет; оркестратору убрать мусорную сессию из зоны.
- `bash scripts/check_sud_model.sh --verdict critic --trace <tsv> --object eec120d6b24b4cdba1504afce5485d6f30dcc3dd --session Critic161GlmV6 --root /home/harness/dev-harness` → `СУДЬЯ СВОЕЙ МОДЕЛИ: вердикт critic материализуется`, rc 0.
- `bash scripts/check_staged.sh` (клон судьи, identity critic) → rc 0 («нечего судить: staged пуст» — записи спавна нет, ожидаемо).
