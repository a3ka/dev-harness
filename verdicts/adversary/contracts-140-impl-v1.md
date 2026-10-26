FAIL
OBJECT=73aa92b7a0b0d756f26c35a06f5f529154cf37da
СУД: repo=dev-harness; предмет=140; фаза=реализация; роль=adversary; вызов=1/2; модель-план=zai/glm-5.3; сессия=Adv140; модель-факт=openai-codex/gpt-5.6-terra; SHA=73aa92b7a0b0d756f26c35a06f5f529154cf37da; предыдущий=нет; исключение=нет

Независимость: автор Impl140/Impl140b — zai/glm-5.3 (задание); судья — openai-codex/gpt-5.6-terra. Предмет прочитан из изолированного SSH-клона `/tmp/dev-harness-verify/Adv140/repo`; `git rev-parse HEAD` дал `73aa92b7a0b0d756f26c35a06f5f529154cf37da`.

## БЛОКИРУЕТ

БЛОКИРУЕТ `scripts/zamok_predmeta.sh:158-163`, контракт 140 инвариант 6 — рисковый предмет допускает reviewer без завершённого adversary, когда в реестре два контракта с одинаковым SUBJECT и конфликтующим `КЛАСС РИСКА`.

ОБЯЗАТЕЛЬСТВО: для `рисковый` + `reviewer` дверь пропускает только после yield adversary; отсутствие однозначного источника риска должно быть fail-closed (`KLASS_RISKA_NET` либо отдельная именованная причина), а не произвольно обычным.

КЛАСС ПРИЧИНЫ: правильный ответ не на тот вопрос / неоднозначный источник. `klass_riska()` читает только первый результат `find "$REPO/contracts" -name "$1-*.md" | sed -n '1p'`; SUBJECT содержит только NNN и не несёт slug, поэтому выбор файла неканоничен.

СОСТОЯНИЕ: изолированный мир с `contracts/141-a.md` … `141-f.md`; первый путь, который реализация фактически выбирает, содержит `КЛАСС РИСКА: обычный`, другой matching-файл — `КЛАСС РИСКА: рисковый`; автор 141 имеет START и yield на tip, adversary START/yield отсутствует.

НАБЛЮДЕНИЕ (сырая команда и вывод):
```text
$ env -i PATH=/usr/bin:/bin HOME=/tmp/dev-harness-verify/Adv140/home TMPDIR=/tmp/dev-harness-verify/Adv140/tmp python3 /tmp/dev-harness-verify/Adv140/semantic_attacks.py
CONFLICTING_RISK selected=141-d.md risky=141-b.md rc=0 stdout='PUSCHEM Reviewer141 dev-harness/141 (sudja/reviewer)' stderr=''
[rc=0]
```

Это достижимый обход порядка adversary→reviewer: один рискованный контракт того же предмета существует, но reviewer создан без adversary. `W` также зелёный на доставленной двери, следовательно существующая батарея не предъявляет этот класс: `KLETKI 48 KRASNYH 0` при `W`; её s09/s10 создают ровно один `contracts/<NNN>-*.md`.

ЗАКРЫВАЮЩЕЕ СВОЙСТВО: при двух либо более matching `contracts/<NNN>-*.md` с несовпадающей/неоднозначной классификацией дверь именованно отказывает до START и до создания дочернего агента; батарея имеет негатив reviewer-without-adversary для этого состояния и позитив только для однозначного обычного либо рискованного после yielded adversary.

## СОВЕТ

Нет.

## Проверенные классы и сырые результаты

1. Позитивный контроль и реальная дверь, изолированные mktemp-миры:
```text
$ env -i PATH=/usr/bin:/bin HOME=... TMPDIR=... bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh
SUBJEKT: /tmp/dev-harness-verify/Adv140/repo/scripts/zamok_predmeta.sh
KLETKI 48 KRASNYH 0
[rc=0]
$ ... red_odin_agent_140.sh --model
48 CASE ... ok
[rc=0]
$ ... red_odin_agent_140.sh --stabs
SVJAZI 39
SUBJEKT_SVJAZI 39
[rc=0]
```
Проверены стабы отказа/ложного успеха, констант, пустого входа, чужого поля и нейтрализации: 27 маркерных стабов и x01 «всегда PUSCHEM» красны по 39 связям; подставленная дверь также прошла контроль 48 клеток. Это позитивный контроль, но не закрывает найденный отдельный класс неоднозначного канона.

2. Станционная интеграция через реальный хук, три последовательных прогона:
```text
$ ... bash fixtures/workshop_project/odin_agent_140/stancija_odin_agent_140.sh
PROB VSEGO 15 KRASNYH 0
S1_rc=0
... S2_rc=0
... S3_rc=0
```
Включая нейтрализацию `[ZAMOK140]` (m01), fail-closed rc 2 (p13), batch/гонку (p07/p08), порядок (p05) и живой учёт (p14).

3. Живая проба omp в отдельном HOME, с локальным stub-provider без сети. Проект обнаружил копии OBJECT `.omp/extensions/spawn-guard.ts` и `scripts/zamok_predmeta.sh`; session-dir был `<мир>/zones/dev/.omp/profiles/dev/agent/sessions`. Первый worker искусственно не yield-нулся (локальный provider вернул quota), после чего omp получил блок ДО второго child:
```text
LIVE140 rc=0
<task-result id="WorkerOne" agent="architect" status="failed (exit 1)" ...>
ОТКАЗ: RABOCHIJ_ZHIV: предмет 140: рабочий WorkerOne бежит без сдачи — дубль запрещён
REQUESTS=[..., {"model":"glm","status":"quota","turn":true}, {"model":"main","status":"main","turn":true}, ...]
SESSION_FILES=[..., ".../WorkerOne.jsonl", ...]
```
В requests/session-files нет WorkerTwo: дубль не создан. Тем же стендом замена второго task на `critic` с корректным OBJECT дала тот же `ОТКАЗ: RABOCHIJ_ZHIV`; Critic140 не был создан. Ранее честный одиночный worker с provider `ok` был создан и yielded:
```text
<task-result id="WorkerOne" agent="architect" status="completed" ...>
REQUESTS=[..., {"model":"glm","status":"ok","turn":true}, ...]
SESSION_FILES=[..., ".../WorkerOne.jsonl", ...]
```

4. Инструмент мимо PATH не объявлен успехом:
```text
$ env -i PATH=/tmp/dev-harness-verify/Adv140/empty-path HOME=... TMPDIR=... /usr/bin/bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --stabs
NOT_IMPLEMENTED: нет python3
EMPTY_PATH_rc=2
```

5. Гигиена 041:
```text
$ ... bash fixtures/parsing_hygiene_battery/run_battery.sh zamok_predmeta
БАТАРЕЯ zamok_predmeta: класс delimiter-collision      — закрыт (rc 0)
БАТАРЕЯ zamok_predmeta: класс regex-injection          — закрыт (rc 0)
БАТАРЕЯ zamok_predmeta: класс silent-drop              — закрыт (rc 0)
БАТАРЕЯ zamok_predmeta: класс self-application-green   — закрыт (rc 0)
БАТАРЕЯ zamok_predmeta: итог 4/4 классов закрыто
[rc=0]
```

6. Граница реализации:
```text
$ git diff --name-only origin/main..73aa92b7a0b0d756f26c35a06f5f529154cf37da
.omp/extensions/spawn-guard.ts
fixtures/parsing_hygiene_battery/profiles/zamok_predmeta.sh
scripts/zamok_predmeta.sh
[rc=0]
```

## Не проверено

`bash scripts/check_zones.sh` был запущен на клоне, но не завершился в лимите 60 s из-за собственного объёмного обхода истории (`Command timed out after 60 seconds`); не приписываю ему зелёный результат. Остальные названные проверки выполнены выше. Вердикт не меняет предмет или проверку; все пробные файлы и миры были только под `/tmp/dev-harness-verify/Adv140/`.
