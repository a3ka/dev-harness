accept
OBJECT=a73637c06edc7aa4bf2fc81f66b170e20f4c0ab3

СУД: repo=dev-harness; предмет=169; фаза=контракт; роль=critic; вызов=1/2; модель-план=zai/glm-5.3 (назначение roles.critic=apex-sol → @glm); сессия=Critic169ModelTrace; модель-факт=zai/glm-5.3; OBJECT=a73637c0; предыдущий=нет; исключение=нет. Примечание учёта: предвызовной строки СУД по предмету=169 в HANDOFF на момент суда не нашёл (последние — 143/158); строка зеркалится судом согласно §Счёт, оркестратору — дописать при материализации. Совпадение модели судьи с моделью автора отказа не даёт (контракт 166).

## Предмет и решение

Судится закоммиченный контракт `contracts/169-model-trace-put-i-project-brief.md` и семья `fixtures/workshop_project/model_trace_169/` (`.probe-only`, `probe.py`, `red_model_trace_169.sh`) на OBJECT `a73637c0` («169: distinguish explicit model trace path and project briefing», git-identity architect). Тождество содержания: blob-ы контракта `d6326248e` и всех трёх файлов семьи побайтово равны на OBJECT (ветка wip/169/architect) и на main `e280a34c2` (ленд) — проверено `git ls-tree` с обеих сторон; рабочий файл совпадает с HEAD. Реализация отсутствует и не предмет суда (production не судится). Минт стоит: `registry/contracts.tsv:178` (`169 → 75a1d23e4`); `registry/plan.tsv` строки 169 не несёт — «не объявляет самостоятельную реализацию» верно; другой незавершённой ветки/PR по 169 не нашёл (grep `model-trace` по contracts/: только замороженные 095/103/112/133/136/166 и сам 169).

Набор артефактов полон: предмет (различить явный `--model-trace` и незаданный; новый дословный диагноз для явного не-файла; старый диагноз только при полном отсутствии трассы; проектный fallback `<registry>/trace.tsv` зелёный без аргумента; шаг 0 роли показывает оба способа), исполняемый критерий с rc-командами по каждому пункту, КЛАСС ЗАДАЧИ кодовый, КЛАСС РИСКА «обычный» с основанием (грамматика `обычный|рисковый` — zamok_predmeta.sh:188; предмет — текст диагноза и подсказки запуска, прав/авторизации/денег/ПД/юридических действий не меняет; обычный → адверсарий по §Реализация не вызывается, до-кодовая атака выполнена мной в одноразовом клоне), ЗОНА-строки по всем раздаваемым путям, модель угроз (ЗАЩИЩАЕТ 2 / НЕ ЗАЩИЩАЕТ 1), «Незаполненные требования: нет».

## Живые прогоны (одноразовые миры probe.py; сырые rc)

Красное ДО правки, ветка OBJECT:
```
bash fixtures/workshop_project/model_trace_169/red_model_trace_169.sh --repo   # rc 1
169 project_no_arg ok rc=0 stderr=''                    # 136-fallback жив сегодня
169 explicit_model_string KRASNO rc=1 stderr='ОТКАЗ: нет свидетельства модели: orchestrator'
169 explicit_missing_path KRASNO rc=1 stderr='ОТКАЗ: нет свидетельства модели: orchestrator'
169 no_trace_anywhere ok rc=1 stderr='ОТКАЗ: нет свидетельства модели: orchestrator'
169 orchestrator_step_0 KRASNO                          # шаг 0 роли ещё без пути/fallback
```
Ровно три названные критерием красные клетки красны, оба контроля (`project_no_arg`, `no_trace_anywhere`) зелёны и не заменяют красноту; `trace_oracle` молчит (трасса не переписана субъектом).

Честный контроль (мутация замороженного `frozen/contracts/166/2:scripts/make_task.sh`, побайтово равного текущему scripts/make_task.sh — diff пуст):
```
bash fixtures/workshop_project/model_trace_169/red_model_trace_169.sh --model   # rc 0
169 explicit_model_string ok rc=1 stderr='ОТКАЗ: --model-trace ожидает путь к TSV-файлу трассы (роль<TAB>модель<TAB>allowed); в проектном корне аргумент можно опустить — берётся <registry>/trace.tsv'
169 explicit_missing_path ok rc=1 stderr='<та же дословная строка>'
169 no_trace_anywhere ok rc=1 stderr='ОТКАЗ: нет свидетельства модели: orchestrator'
169 project_no_arg ok rc=0 (TRACE: role=orchestrator model=openai-codex/gpt-6-sol fallback=allowed)
```
Дословность сверена байтами: литерал stderr в контракте == константа ERROR в probe.py (оба с префиксом `ОТКАЗ: ` от die()), текст die()+префикс == ERROR; старый диагноз `ОТКАЗ: нет свидетельства модели: orchestrator` сохранён и закреплён клеткой. «stdout пуст» и «ровно одна строка stderr» enforcement-ом клетки (`actual == [expected_line]`).

Обманные стабы архитектора (`--stabs`, rc 0, все пять пойманы, живых нет; адреса мутант→вход закреплены ТОЛЬКО кодом probe.py через replace_one по якорям реального кода — Н-39, в прозе контракта пар нет):
```
169 STAB old_missing_error   caught @ explicit_model_string   # возврат общего диагноза
169 STAB explicit_falls_back caught @ explicit_model_string   # неверный явный аргумент замаскирован проектным fallback (rc=0 у обеих явных клеток)
169 STAB no_default          caught @ project_no_arg          # срезан проектный fallback
169 STAB missing_is_new      caught @ no_trace_anywhere       # старый диагноз подменён новым
169 STAB old_step            caught @ orchestrator_step_0     # шаг 0 без пути/fallback
```
Все пять стабов действительно привязаны к ветвям кода/роли: якоря — вставленный диагноз, условие 136-fallback (`if [ -z "$TRACE" ]; then\n  _PP_JSON=`), строка старого диагноза, историческая строка шага 0 (усечённая форма текущей roles/orchestrator.md:19 — неравенство STEP держит).

Мои мутации против красной батареи (одноразовый клон `/tmp/dev-harness-verify/Critic169ModelTrace`, полный проход кодового контракта):
```
mutA (значение-специфично: дословно только openai-codex/gpt-5.6-terra) → caught:
  explicit_missing_path KRASNO rc=0 (нелегитимный зелёный через fallback)
mutB (префикс openai-codex/*) → caught: explicit_missing_path KRASNO rc=0
  — «значения моделей не распознаются по префиксу» обеспечено батареей, не декларацией
mutC (эвристика косой черты: честный отказ только для строк с «/») → батареей НЕ пойман
  (все четыре CLI-входа ok); ручная проба: `--model-trace net-fayla.tsv` → rc 0,
  полный бриф по подложенной проектной трассе — нарушение предмета, но вход без «/»
  допустим лишь грамматикой парсера (наблюдаемого рабочего случая нет) → СОВЕТ, не блок (§Порог).
```

Гейты и старые контроли:
```
bash scripts/pre_critic.sh --repo . contracts/169-…md              # rc 0 «КРИТИК: дверь зелёная»
bash scripts/check_threat_model.sh . contracts/169-…md             # rc 0 (ЗАЩИЩАЕТ 2, НЕ ЗАЩИЩАЕТ 1)
bash scripts/check_precision_gate.sh <clone> contracts/169-…md     # rc 0 «OK» (новая семья+зоны)
bash scripts/check_provodka.sh <clone> contracts/169-…md           # rc 1 «норма-строка не найдена
                                                                   # в role-файле» — done-гейт принуждает
                                                                   # обновление нормы, красное ДО ожидаемо
bash fixtures/context_pack_095/red_svidetelstvo_modeli.sh          # rc 0 (прежний отказ без свидетеля жив)
bash fixtures/workshop_project/sessii_136/red_sessii_136.sh --model # rc 0, 87/87 зелёных
```

## Пять вопросов роли

1. **Критерий слабее предмета?** Названного обхода нет. Красное живое и адресное: ровно три названные клетки красны на конформном проектном профиле (двухслойный toy 095 с настоящим `ci.yml` для раннего резолвера 136), контростирующие входы зелёны и красноту не гасят (агрегация all() по самостоятельным клеткам, rc 1 при любой красной). Подмена реестра закрыта trace-оракулом памяти; маскировка неверного явного аргумента fallback-ом закрыта клеткой explicit_* (стаб explicit_falls_back пойман живьём).
2. **Готово недоказуемо командой?** Каждый пункт критерия имеет команду с rc: `--repo|--model|--stabs|CI-шаг без аргумента` (set -e: до реализации CI-красное, после — rc 0), `pre_critic.sh`, `check_provodka.sh`, `check_project_sources.sh --stage done`, старые контроли 095/136 с точными вызовами. Все прогнаны живьём выше.
3. **Решение оставлено исполнителю?** Диагноз и старый диагноз зафиксированы дословно (байт-сверка), строка шага 0 роли зафиксирована дословно (ПРОВОДКА-строка == константа STEP в probe.py, sha256 9ad5b39a63a974be обеих — шаг 0 не расходится между контрактом, батареей и будущей ролью), команда CI-строки названа точно, `.omp` — только регенерация из источника (check:gen в CI, ci.yml:282). Грамматика TSV, выбор модели, allowed|denied, резолвер `<registry>` 103/136/996 — объявлены неизменными.
4. **Границы исполнения?** Пять ЗОНА-строк покрывают все трогаемые пути: architect (контракт+семья), implementer (make_task.sh, roles/orchestrator.md, .omp/agents/orchestrator.md), critic, reviewer, orchestrator (ci-steps/ci-zamery/ci.yml); 44 ПЕРЕСЕЧЕНИЕ-строки ограничивают каждое касание «только шаг 0/строка 169». Семья probe-only (.probe-only маркер) — вне case_*-глоба раннера, барьер — собственный red-файл.
5. **Противоречие AGENTS.md?** Не установлено. Устав не правится, РАЗРЕШИЛ не нужен. Модель угроз валидна по форме и адекватна по существу: остаток (происхождение трассы/конфига установки) отнесён к границам 104/136. КЛАСС РИСКА совпадает с предметом.

## Счётная и механическая сверка (полный список)

`scripts/make_task.sh:119–134` (парсинг, `--model-trace` на :129) ✓; `:249–275` блок трассы ✓; `:268` общий тест отсутствия — дословно `if [ -z "$TRACE" ] || [ ! -f "$TRACE" ]; then die "нет свидетельства модели: $ROLE"; fi`, якорь в замороженном источнике уникален ✓; `connect_project.sh:255–260` сеет trace.tsv ✓; `roles/orchestrator.md:19` шаг 0 ✓; `frozen/contracts/166/2:scripts/make_task.sh` == текущему (diff пуст) ✓; `registry/contracts.tsv:178` минт 169 ✓; `registry/plan.tsv` без 169 ✓; «четыре независимых CLI-входа + шаг 0» = клетки probe.py (project_no_arg, explicit_model_string, explicit_missing_path, no_trace_anywhere, orchestrator_step_0 + trace_oracle) ✓; «пять стабов» = old_missing_error, explicit_falls_back, no_default, missing_is_new, old_step ✓. Расхождений не нашёл.

## Советы (не условия заморозки)

СОВЕТ contracts/169-model-trace-put-i-project-brief.md — батарея закрывает значение-специфику (mutA) и префикс (mutB) парой явных входов, но обе явные клетки содержат «/»: мутант, честно отказывающий только строкам с косой чертой, проходит все четыре CLI-входа (пойман живьём в моём клоне: `--model-trace net-fayla.tsv` → нелегитимный rc 0 с полным брифом). Один не-файл без «/» в cases() закрыл бы класс дёшево. Вход сегодня допустим лишь грамматикой — потому совет, не блок.
СОВЕТ contracts/169-model-trace-put-i-project-brief.md — для пункта про `.omp/agents/orchestrator.md` назвать команду `npm run check:gen` (package.json:12; ключ уже в ci.yml:282), чтобы пункт воспроизводился копированием.
СОВЕТ оркестратору (вне контракта) — предвызовная строка СУД по предмету=169 в HANDOFF отсутствует; зеркалирование выполнено судом в этом вердикте.

Правки репозитория — только этот вердикт в `verdicts/critic/` под identity critic. Push не выполнялся. Заморозка разрешена.
