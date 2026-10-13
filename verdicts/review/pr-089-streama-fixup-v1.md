accept — PR#89 @ be25b1350 годен к штатному ленду. 4/4 санкции совпадают с §1 регламента дословно. l7: 3/3 блоба равны frozen-тегам. PR-CI 12/12 success на head (run 38409857551, сверено через API). Пять исторических барьеров дали rc=0 полным режимом и на head, и на предполагаемом merge-результате (land_agent → 9492e967 поверх main 6945111a7). Критерий Г предъявлен красным мутациями. Критерий В: 5/5 файлов побайтово. Зоны: 15/15 путей. Блокирующих находок нет. Рв-1…Рв-7 — процесс, документация и наблюдения, они не блокируют.

# Review PR#89 `integration/streamA-fixup` — исправляющий интеграционный пакет переходного регламента 2026-10-13

МОДЕЛЬ: `anthropic/claude-opus-5-5`, трасса `scripts/models_actual.sh --tsv` → `reviewer	anthropic/claude-opus-5-5	allowed`. Авторы пакета: architect на `claude-fable` (регламент, «Модели этой части работы»), implementer на `zai/glm-5.3`, critic на `openai-codex/gpt-6-astra`. Architect и я — одно семейство anthropic. Асимметрия записана. Поэтому каждое утверждение о коммитах architect ниже проверено прогоном или побайтовой сверкой, а не чтением.

**Субъект.** PR https://github.com/a3ka/dev-harness/pull/89, head `be25b1350ffc0cd7e05ee5c2adb079ede42cae31`, база `e8d7f25226dd6908352e26a93796704ff59408ee` (`git merge-base` = база), ветка `integration/streamA-fixup`. Текущий `origin/main` = `6945111a7682a5826fa95baceb49f1e16eb5a62b`. Это на 5 служебных коммитов дальше базы: HANDOFF ×3, NABLIUDENIA Н-276, verdicts/review 093-v5.

**Сборка.** Одноразовый SSH-клон `/tmp/dev-harness-verify/pr89-1791901418/repo`, `git clone ssh://git@github.com/a3ka/dev-harness.git`, detached на `be25b1350`. Перед прогонами `git status --porcelain` дал 0 строк. Барьеры гонялись в полном режиме: без `--incr`, без кеша. Предполагаемый merge-результат собран в отдельном одноразовом клоне `/tmp/dev-harness-verify/pr89-1791901418/land` (ниже, §8). Ничего не пушилось.

**Нормы.** `docs/owner/2026-10-13-perehodnyj-reglament.md` прочитан целиком: §1 со строками владельца, §2 с критериями Г/В/З, §4 с маршрутом, «Действия оркестратору» и «Оценка l2».

## Состав: бриф сосчитан своей мерой

`git log --format='%h %an %s' e8d7f2522..be25b1350` даёт **10** коммитов, `git log --merges e8d7f2522..be25b1350 | wc -l` = **0** (история линейная). В брифе в заголовке написано «8 коммитов», а в списке стоит 10. Верно 10.

| # | коммит | автор=коммиттер | пути (name-status) |
|---|---|---|---|
| 1 | `e12fdccb9` | architect | M `fixtures/_krasnye_071.sh`, M `fixtures/gitw_predpolet/red_predpolet_071.sh` |
| 2 | `e650d043d` | architect | M `NABLIUDENIA_ARCHITECT.md` (только добавления) |
| 3 | `2daced448` | architect | M `contracts/094-prinyatie-i-publikatsiya-kandidata.md` |
| 4 | `2c53b0a17` | architect | M `contracts/095-profil-i-vhod-agenta-contextpack.md` |
| 5 | `1e88c83b3` | architect | M `contracts/097-doverennaya-osnova-i-podgotovka-obekta.md` |
| 6 | `2c266d218` | architect | A `fixtures/dokazatelstva_098/.probe-only` |
| 7 | `68462ffc8` | implementer | M `scripts/check_skills.sh` |
| 8 | `c85f22f13` | architect | M `NABLIUDENIA_ARCHITECT.md` (только добавления) |
| 9 | `b237251fd` | implementer | M `scripts/check_protected.sh` |
| 10 | `be25b1350` | critic | A ×5 `verdicts/critic/contracts-{094-v4,099-v4,100-v2,100-v3,100-v4}.md` |

Итого 14 файлов, +991/−101 (`git diff --stat e8d7f2522 be25b1350`). В брифе к коммиту 1 указан один файл, но коммит трогает и `fixtures/_krasnye_071.sh`: это 2 строки комментария, «20 стабов» → «21 стаб». Путь в зоне architect 071, см. §6.

## 1. Санкции РАЗРЕШИЛ-ВЛАДЕЛЕЦ: символ в символ

Скрипт `sanctions.sh` берёт строки `^РАЗРЕШИЛ-ВЛАДЕЛЕЦ:` из блока §1 регламента на `be25b1350` и проверяет каждую такую строку тела коммита через `grep -Fxq`, то есть на полное совпадение строки. Дополнительно сверены sha256 и длина в байтах. Вывод, rc=0:

```
regulation lines: 4
== e12fdccb9 sanction-lines=0 first-line-is-sanction=no
== e650d043d sanction-lines=0 first-line-is-sanction=no
== 2daced448 sanction-lines=1 first-line-is-sanction=yes
   EXACT  sha256=fd38b537547ca112 len=387
== 2c53b0a17 sanction-lines=1 first-line-is-sanction=yes
   EXACT  sha256=2ed48b37db5250ea len=327
== 1e88c83b3 sanction-lines=1 first-line-is-sanction=yes
   EXACT  sha256=b0d00798f5722e85 len=333
== 2c266d218 sanction-lines=0 first-line-is-sanction=no
== 68462ffc8 sanction-lines=0 first-line-is-sanction=no
== c85f22f13 sanction-lines=0 first-line-is-sanction=no
== b237251fd sanction-lines=1 first-line-is-sanction=yes
   EXACT  sha256=369be3d3db98d3b7 len=512
== be25b1350 sanction-lines=0 first-line-is-sanction=no
-- regulation line hashes
   sha256=fd38b537547ca112 len=387 ontracts/094-prinyatie-i-publikatsiya-kandidata.md — переход
   sha256=2ed48b37db5250ea len=327 ontracts/095-profil-i-vhod-agenta-contextpack.md — переходны
   sha256=b0d00798f5722e85 len=333 ontracts/097-doverennaya-osnova-i-podgotovka-obekta.md — пер
   sha256=369be3d3db98d3b7 len=512 cripts/check_protected.sh — переходный регламент 2026-10-13:
```

Все 4 санкции совпадают дословно. Каждая стоит в первой колонке первой строки тела того коммита, который меняет соответствующий файл. Каждая из 4 строк регламента использована ровно один раз. Коммитов с уставной дельтой и без строки нет. Сверено и так: уставные пути пакета — это только `contracts/094|095|097`, и каждый трогает ровно один коммит со своей строкой. Коммит 2 (`e650d043d`, NABLIUDENIA) уставным не является: бриф ошибочно отнёс его к «трогающим уставные файлы» (2–5, 9). Санкция ему не нужна.

## 2. l7: тексты контрактов равны frozen-блобам

```
== frozen/contracts/094/2 contracts/094-prinyatie-i-publikatsiya-kandidata.md
tag-blob=40e8d7909746183b2333645903decade3708fa9c head-blob=40e8d7909746183b2333645903decade3708fa9c base-blob=f7eda8558f3bf6178335706e872a85acefcfb9af main-blob=f7eda8558f3bf6178335706e872a85acefcfb9af
diff-rc=0 lines=0
== frozen/contracts/095/1 contracts/095-profil-i-vhod-agenta-contextpack.md
tag-blob=ccf4b28a917516745bef0ab7bab5e6405a8d19d0 head-blob=ccf4b28a917516745bef0ab7bab5e6405a8d19d0 base-blob=dfc5e21fe889c4dc00ace2077a444a1bcb4527ae main-blob=dfc5e21fe889c4dc00ace2077a444a1bcb4527ae
diff-rc=0 lines=0
== frozen/contracts/097/1 contracts/097-doverennaya-osnova-i-podgotovka-obekta.md
tag-blob=60ed764307cb534bff1f0e66458122a62910caa3 head-blob=60ed764307cb534bff1f0e66458122a62910caa3 base-blob=6023457247b3b061e39733bbcb1e1474a17ce1fd main-blob=6023457247b3b061e39733bbcb1e1474a17ce1fd
diff-rc=0 lines=0
```

Команды: `git diff frozen/contracts/NNN/V be25b1350 -- contracts/NNN-*.md` пуст для всех трёх. Блоб на HEAD равен блобу тега и блобу, названному в санкции. Критерий З регламента («блоб контракта равен указанному frozen-блобу») выполнен на head. На merge-результате он проверен в §8.

## 3. PR-CI: живьём, на текущем head

`gh pr checks 89 --repo a3ka/dev-harness`, rc=0:

```
antiplacebo (ap1, check_runner_hygiene drill_startup_digest check_ci_gate gc_agent_branches orch_...	pass	5m30s	https://github.com/a3ka/dev-harness/actions/runs/38409857551/job/115339464993
antiplacebo (ap2, check_scope_select freeze_contract check_skills land_agent check_decisions chec...	pass	2m45s	https://github.com/a3ka/dev-harness/actions/runs/38409857551/job/115339465705
antiplacebo (ap3, check_staged check_zones check_nabludenia check_scoped_run check_approval check...	pass	2m52s	https://github.com/a3ka/dev-harness/actions/runs/38409857551/job/115339465456
antiplacebo (ap4, check_protected check_hooks check_charter drill_gate_draft check_document drill...	pass	1m33s	https://github.com/a3ka/dev-harness/actions/runs/38409857551/job/115339465586
antiplacebo (ap5, verify_ci_parity check_ids check_ceilings check_contract_frozen drill_next_id_r...	pass	1m23s	https://github.com/a3ka/dev-harness/actions/runs/38409857551/job/115339465816
ci (l1, check:charter)	pass	16m20s	https://github.com/a3ka/dev-harness/actions/runs/38409857551/job/115339465187
ci (l2, check:gitw-predpolet-family-selftest)	pass	11m54s	https://github.com/a3ka/dev-harness/actions/runs/38409857551/job/115339465636
ci (l3, check:zones check:ceilings check:gen check:precision-battery check:precision-gate-043 dri...	pass	2m35s	https://github.com/a3ka/dev-harness/actions/runs/38409857551/job/115339465469
ci (l4, check:protected check:declared-path-family-selftest check:fix-090-orch-peak-home-family-s...	pass	4m6s	https://github.com/a3ka/dev-harness/actions/runs/38409857551/job/115339465762
ci (l5, check:orch-restart-family-selftest check:sharing-family-selftest check:cikl-perezapuska-0...	pass	7m19s	https://github.com/a3ka/dev-harness/actions/runs/38409857551/job/115339465332
ci (l6, check:protected-call-budget check:zones-call-budget check:context-pack-095-family-selftes...	pass	5m59s	https://github.com/a3ka/dev-harness/actions/runs/38409857551/job/115339465471
ci (l7, check:contract-frozen check:samodostatochnost-family-selftest check:approval check:docume...	pass	3m23s	https://github.com/a3ka/dev-harness/actions/runs/38409857551/job/115339465674
```

Привязка к SHA проверена отдельно через GitHub API, а не по выводу `gh pr checks`:

```
gh pr view 89 → {"headRefName":"integration/streamA-fixup","headRefOid":"be25b1350ffc0cd7e05ee5c2adb079ede42cae31","state":"OPEN",...}
gh api .../actions/runs/38409857551 → {"conclusion":"success","event":"pull_request","head_sha":"be25b1350ffc0cd7e05ee5c2adb079ede42cae31","run_attempt":1,"status":"completed"}
jobs: 12 строк, у каждой head_sha be25b1350, completed, success
gh api .../commits/be25b1350.../check-runs → total_count 12, {"success":12}
```

12/12 `success` на `be25b1350`. Нет ни `skipped`, ни `neutral`, ни отсутствующих jobs. Набор ap1–ap5 и l1–l7 полон. Workflow выставляет `ref: ${{ github.event.pull_request.head.sha }}` (`.github/workflows/ci.yml:68,125`). Значит, CI судил именно head, а не синтетический merge-ref. Отсюда требование регламента §4 предъявить барьерам и merge-результат: я сделал это сам, см. §8.

## 4–5. Пять исторических барьеров на `be25b1350`: полный режим, своим прогоном

Все прогоны: `reslop t -- bash scripts/<барьер>.sh` в клоне `repo` на `be25b1350`, без `--incr`.

**check_protected → rc=0**
```
ok: true  passed: 97  failed: 0  skipped: 0
  ok   исчез с явного разрешения: verdicts/consultant/263-grandfather-b7a0c276-klass-v1.md
  ok   исчез с явного разрешения: verdicts/consultant/263-grandfather-b7a0c276-v1.md
  ok   исчез с явного разрешения: verdicts/consultant/266-orch-loop-test-mode-soreview-v1.md
область: :(literal)decisions/proxy/ :(literal)plans/ :(literal)verdicts/adversary/ :(literal)verdicts/arbitration/ :(literal)verdicts/consultant/ :(literal)verdicts/critic/ :(literal)verdicts/review/ · коммитов пройдено: 4308 · существовало: 918 · на HEAD: 821 · исчезло: 0 · с разрешения: 77 · перенесено: 20
exit: 0
check_protected rc=0
```
Счёт своей мерой: 918 − 821 = 97 = 77 + 20, исчезло 0. Пяти восстановленных файлов critic нет в списке исчезнувших: они на HEAD.

**check_charter → rc=0** (817 с)
```
ok: true  passed: 290  failed: 0  skipped: 0
  ok   уставной документ изменён с разрешения владельца: contracts/094-prinyatie-i-publikatsiya-kandidata.md в 2daced44
  ok   уставной документ изменён с разрешения владельца: contracts/094-prinyatie-i-publikatsiya-kandidata.md в f97044d0
  ok   contracts/094-prinyatie-i-publikatsiya-kandidata.md — уставной с frozen/contracts/094/1, коммитов в диапазоне 383, изменений без разрешения нет
  ok   уставной документ изменён с разрешения владельца: contracts/095-profil-i-vhod-agenta-contextpack.md в 2c53b0a1
  ok   … 095 в 6d1d23d4 / 5c4752bc / ae8836c6
  ok   contracts/095-profil-i-vhod-agenta-contextpack.md — уставной с frozen/contracts/095/1, коммитов в диапазоне 334, изменений без разрешения нет
  ok   уставной документ изменён с разрешения владельца: contracts/097-doverennaya-osnova-i-podgotovka-obekta.md в 1e88c83b
  ok   contracts/097-doverennaya-osnova-i-podgotovka-obekta.md — уставной с frozen/contracts/097/1, коммитов в диапазоне 117, изменений без разрешения нет
уставных документов: 93 · изменений в них: 197 · с разрешения: 197
exit: 0
check_charter rc=0
```
Три коммита пакета признаны как изменения с разрешения: `2daced44`, `2c53b0a1`, `1e88c83b`. На прежнем HEAD `ec863f786` ломало отсутствие санкций в merge-коммитах. Здесь merge-коммитов нет (§Состав), поэтому этой причины на head нет.

**check_zones → rc=0**
```
ok: true  passed: 82  failed: 0
  FAIL строка ЗОНА вне объявленной грамматики в contracts/055-izoljacija-sostojanija-po-projectid.md: «ЗОНА architect (до-заморозочная батарея по ДЕЙСТВУЮЩЕЙ заморозке каталога):» — у автора «architect (до-заморозочная батарея по ДЕЙСТВУЮЩЕЙ заморозке каталога)» не назван ни один путь
замороженных контрактов: 94 · объявленных авторов: 3 · коммитов в диапазонах: 10332 · проверено по зонам: 2637
exit: 0
check_zones rc=0
```
Строка FAIL про 055 при rc=0 существовала до этого PR, PR её не вносит: `git diff --stat e8d7f2522 be25b1350 -- scripts/check_zones.sh contracts/055-*` пуст. Механизм: `scripts/check_zones.sh:405` передаёт нарушения в `| while … bad "$line"`, и `fails` растёт в подоболочке конвейера. Это уже записано в Н-181 («локально FAIL только 055-грамматика, rc не красит»). Подробнее в Рв-6.

**check_ids → rc=0**
```
ok: true  passed: 1  failed: 0
exit: 0
check_ids rc=0
```

**check_contract_frozen → rc=0**
```
ok: true  passed: 94  failed: 0
exit: 0
check_contract_frozen rc=0
```

## 4а. Критерий Г: новая grandfather-тройка красна без себя и не шире пары

Регламент («Действия оркестратору», l4) требует: «точная пара разрешена, другой SHA или путь отвергнут». В PR нет ни новой клетки, ни предъявления этого требования. Я предъявил его сам скриптом `mut_protected.sh` в одноразовом worktree. Он делает четыре мутации и одну пробу историей, и всё удалено после прогона:

```
== C0 rc=0                                   (немутированный барьер)
   … исчезло: 0 · с разрешения: 77 · перенесено: 20
-- M1 diff vs orig: 5 removed lines           (ветвь 66e3a0b9 удалена = состояние базы)
== M1 rc=1
     FAIL защищённый артефакт существовал и на HEAD его нет: verdicts/consultant/263-grandfather-b7a0c276-klass-v1.md
     FAIL защищённый артефакт существовал и на HEAD его нет: verdicts/consultant/263-grandfather-b7a0c276-v1.md
     FAIL защищённый артефакт существовал и на HEAD его нет: verdicts/consultant/266-orch-loop-test-mode-soreview-v1.md
   … исчезло: 3 · с разрешения: 74 · перенесено: 20
-- M2 diff lines: 1                           (ветвь сужена до двух путей — соседний путь)
== M2 rc=1
     FAIL защищённый артефакт существовал и на HEAD его нет: verdicts/consultant/266-orch-loop-test-mode-soreview-v1.md
   … исчезло: 1 · с разрешения: 76 · перенесено: 20
-- M3 diff lines: 1 (key -> 3e7aaf8d671275c3e76c6bee75f72a3224b2310c)   (ключ — другой SHA)
== M3 rc=1
     FAIL … 263-grandfather-b7a0c276-klass-v1.md
     FAIL … 263-grandfather-b7a0c276-v1.md
     FAIL … 266-orch-loop-test-mode-soreview-v1.md
   … исчезло: 3 · с разрешения: 74 · перенесено: 20
-- T1 probe HEAD=c47c5d3b parent-chain: c47c5d3b 35fb4d65 be25b135   (барьер НЕ мутирован; 266-… восстановлен и заново удалён НОВЫМ коммитом без ALLOW)
== T1 rc=1
     FAIL защищённый артефакт существовал и на HEAD его нет: verdicts/consultant/266-orch-loop-test-mode-soreview-v1.md
   … коммитов пройдено: 4310 · исчезло: 1 · с разрешения: 76 · перенесено: 20
```

Вывод: новая ветвь — единственная причина зелёного по трём путям (M1). Она держит именно пару «SHA + путь»: соседний путь без записи краснеет (M2), другой SHA-ключ не прощает (M3). Тот же путь, удалённый другим коммитом, на неизменённом барьере красен (T1). Так получается потому, что `excuse_for` судит самый новый удаляющий коммит, и grandfather не наследуется. Удаляющий коммит своей мерой: `git show --name-status 66e3a0b95` → ровно 3 строки `R085/R099/R095` с этими путями, `ALLOW-ARTIFACT-DELETE` в теле 0 раз. Свидетельство consultant о соответствии старого и нового вердикта (требование регламента) уже лежит в базе: `verdicts/consultant/fork-263-266-check-protected-content-changed-rename-v1.md`, автор consultant, коммит `52f1292c`.

## 4б. Критерий В: восстановления побайтовы

`restore.sh` ищет удаляющий коммит своей мерой: `git log e8d7f2522 --full-history --no-renames -m --diff-filter=D -1`. Номерам из сообщения коммита я не доверял.

```
== verdicts/critic/contracts-094-v4.md   deleting=2b592b6ff (critic) in-base=no
   blob@deleting^=645a8964147da603bd864ddb0ba393457f34510c blob@HEAD=645a8964147da603bd864ddb0ba393457f34510c BYTE-EQUAL
== verdicts/critic/contracts-099-v4.md   deleting=28eb17fdc (critic) in-base=no
   blob@deleting^=52a2df7d8c32077b2b9ddfaf1b68a15410f1c7a8 blob@HEAD=52a2df7d8c32077b2b9ddfaf1b68a15410f1c7a8 BYTE-EQUAL
   canonical contracts-099-krug{1,2,3}-fail.md on HEAD: present
== verdicts/critic/contracts-100-v2.md   deleting=1a84977b8 (critic) in-base=no
   blob@deleting^=e7fe453c4bbc8b19fed143afee32ab13145970f7 blob@HEAD=e7fe453c4bbc8b19fed143afee32ab13145970f7 BYTE-EQUAL
== verdicts/critic/contracts-100-v3.md   deleting=1a84977b8 (critic) in-base=no
   blob@deleting^=549ceb523950019af063943018aeb87405b3d799 blob@HEAD=549ceb523950019af063943018aeb87405b3d799 BYTE-EQUAL
== verdicts/critic/contracts-100-v4.md   deleting=9303f4f30 (critic) in-base=no
   blob@deleting^=3c42be05a64ddf6e7d6244f5e1795e2d45baa354 blob@HEAD=3c42be05a64ddf6e7d6244f5e1795e2d45baa354 BYTE-EQUAL
   canonical contracts-100-krug{1,2,3}-fail.md on HEAD: present
-- author of be25b1350 changes: critic; files: 5 A
```

Все 5 восстановлений равны блобу из последнего состояния перед удалением. Это ровно те удаляющие SHA, которые назвал critic. Канонические переименованные файлы сохранены. Коммит только добавляет файлы, M/D в нём нет.

## 6. Зоны: каждый путь своей мерой

`zones_own.sh` — отдельная мера, а не `check_zones`. Она собирает 1088 строк «автор / путь / контракт» из ЗОНА-строк высших заморозок всех контрактов и сверяет каждый путь каждого коммита с зоной его автора: точный файл или каталог-префикс.

```
e12fdccb9 architect   fixtures/_krasnye_071.sh                         071
e12fdccb9 architect   fixtures/gitw_predpolet/red_predpolet_071.sh     071
e650d043d architect   NABLIUDENIA_ARCHITECT.md                         011,…,094,095,097,098
2daced448 architect   contracts/094-prinyatie-i-publikatsiya-kandidata.md   094
2c53b0a17 architect   contracts/095-profil-i-vhod-agenta-contextpack.md     095
1e88c83b3 architect   contracts/097-doverennaya-osnova-i-podgotovka-obekta.md 097
2c266d218 architect   fixtures/dokazatelstva_098/.probe-only           098
68462ffc8 implementer scripts/check_skills.sh                          095
c85f22f13 architect   NABLIUDENIA_ARCHITECT.md                         011,…,094,095,097,098
b237251fd implementer scripts/check_protected.sh                       039,040,083
be25b1350 critic      verdicts/critic/contracts-*.md (×5)              011,…,053
```

Строк «ВНЕ-ЗОНЫ» 0 из 15. Каждый путь лежит в зоне своего автора и, кроме журнала NABLIUDENIA и `check_protected.sh`, именно в зоне того контракта, который назван в задании: contracts/094|095|097 у architect своего NNN, `.probe-only` у architect 098, `check_skills.sh` у implementer 095, l2-фикстуры у architect 071. Путь `scripts/check_protected.sh` не входит ни в одну текущую контрактную зону, только в зоны implementer давно закрытых 039/040/083. Для этого коммита основание — собственная дословная санкция владельца (§1). Так допускает регламент («Implementer барьера: три точные grandfather-пары»). Механический `check_zones` тоже rc=0 (§4–5).

Авторство при cherry-pick (`patchid.sh`, `src_local.sh`): у всех 7 перенесённых коммитов patch-id совпадает с источником.

```
e12fdccb9 <- 3a1314a61 patch-id EQUAL  (источник: только локально, wip/071/architect)
e650d043d <- 1611c4696 patch-id EQUAL  (источник: только локально, wip/071/architect)
2daced448 <- c7f29c4e0 patch-id EQUAL  same-sha=no (источник: только локально, wip/094/architect)
2c53b0a17 <- 659c7f84c patch-id EQUAL  same-sha=no (источник: только локально, wip/095/architect)
1e88c83b3 <- 2798ee55c patch-id EQUAL  same-sha=no (источник: только локально, wip/097/architect)
2c266d218 <- a89497d6  patch-id EQUAL  author+date равны источнику, origin/wip/098/architect, -x trailer 1
68462ffc8 <- 111761f5  patch-id EQUAL  author+date равны источнику, origin/wip/095/implementer, -x trailer 1
```

В брифе написано «сохранён SHA c7f29c4e0/659c7f84c/2798ee55c». Это неверно: SHA другие, равен только patch-id, то есть содержание и авторство. Подробнее в Рв-2.

## 7. Проверки не ослаблены: красное предъявлено

**l2 (`red_predpolet_071.sh`, Н-275).** Правка — постановка клетки, а не страж: `scripts/gitw_preflight_071.sh` и `scripts/gitw` в diff не входят. Пункты «Оценки l2» сверены по коду (`red_predpolet_071.sh:415-452,851-855,915-940,1242-1252`):
1. Предпосылка доказана до стража, каждый сбой подготовки останавливает клетку через `die_cell`. `tag_only_local` проверяет: тег есть локально, тег есть на bare, удаление из bare прошло, тега на bare нет, тег по-прежнему есть локально.
2. Отсутствие создаётся удалением тега **только из одноразового bare** (`git -C "$B1" tag -d`), а не новым свободным номером. Тег `frozen/contracts/099/1` mk_world создаёт сам через `tag -f` (строка 330), поэтому коллизии с реальной заморозкой нет при любом состоянии реальных тегов.
3. Отрицательное ожидание сохранено и стало строже. п3а требует отказа с именем тега, дополнительно «цель нет» (иначе это п3б), `bare_frozen` и `tag_absent_on_bare`.
4. Положительная пара есть: `tag_synced п1` (тот же тег, тот же объект на обеих сторонах).
5. Красное: новый стаб s21 «FROZEN-NET-PROPUSK» (`[ -z "$r" ] && continue`, то есть отсутствующий тег пропускается молча) привязан к п3а. Он входит в стаб-пак, а стаб-пак — часть `check:gitw-predpolet-family-selftest`.

Свой прогон l2 на `be25b1350`: `reslop t -- bash fixtures/_krasnye_071.sh` → `exit: 0`, `krasnye_071 rc=0`, 453 с. Сырой лог, выдержка:
```
ok: само-проверка: зелёный мир зелёный (4/4 чека)
…
ok: стаб-s21 прожил «frozen-net» и проходит чистый мир
стаб-пак: 21/21 поймано, диффпроба 21/21
ok: п1: зелёный мир — push прошёл, bare на tip
ok: п3а: задержанный frozen-тег не уезжает
ok: п14а: отсутствующий тег — локальный sha и «цель нет» в отказе (Р-6)
честные клетки: 41/41 зелёные; стаб-пак 21/21 + дифф 21/21
```
Смысл «прожил» (`run_stub_pack`, :760-830): в мире-нарушении `frozen-net` строится ровно та же предпосылка, что в п3а (`tag_only_local … frozen/contracts/099/1`). Там стаб s21 НЕ отказывает с «локальный тег не на origin: frozen/contracts/099/1», хотя настоящий страж обязан отказать: иначе `die_cell «не обманут»`. На чистом мире тот же стаб проходит с rc 0 (диффпроба). Получается, что против порчи «отсутствующий тег пропускается» клетка п3а красна (стаб принимает то, что п3а обязана отвергнуть), а на настоящем страже 41/41 зелёные. Это и есть пункт 5 «Оценки l2».

**ap2 (`check_skills.sh`, Н-269).** Свой прогон `ap2.sh`:
```
== verify_antiplacebo --scope check_skills @head(be25b1350) rc=0
   ok-lines: 12
   tail: барьеров: 1 · фикстур: 12 · предъявлено красным повторным прогоном: 12
== verify_antiplacebo --scope check_skills @base(e8d7f2522) rc=1
   ok-lines: 0
      FAIL check_skills/case_a_ne_obnaruzhen.sh: нет положительного контроля — …   (и т.д., 12 фикстур)
   tail: барьеров: 1 · фикстур: 12 · предъявлено красным повторным прогоном: 0
   tail: расхождений: 13 · прогон оставлен в /tmp/verify_antiplacebo-a759d52c/run-3651649
== check_skills . @head rc=0
   барьер зелёный: 8 ветвей пройдены (ветвь (и) — дельта 095)
== check_skills . @head+mutant(make_task architect без writing-for-agents) rc=1
ОТКАЗ: матрица 13.4: сборщик разошёлся с §13.4 (роль «architect»: «grilling tdd» ≠ «grilling writing-for-agents tdd»)
```
На базе красно (12 FAIL без положительного контроля), на head зелено: 12 из 12 фикстур красны после порчи. Красная сторона ветви (и) жива на мутации `make_task.sh` в действующем чекауте. Недостающий файл в фикстуры не добавлен: каталог `fixtures/check_skills/` в diff не входит.

**ap1–ap5 (`fixtures/dokazatelstva_098/.probe-only`).** Маркер непустой (13 строк с причиной). В каталоге 14 `red_*.sh` и 0 `case_*.sh`, барьерного ключа `scripts/dokazatelstva_098.sh` нет. Это легальный probe-only по `verify_antiplacebo.sh:226-230` и `scope_select.sh:61-66`. Штатный раннер 098 `fixtures/_krasnye_098.sh` маркер не читает (`grep -c probe-only` → 0), поэтому производственные клетки 098 из раннера не исключены, как и требует регламент. В тексте маркера стоит «12 клеток red_*.sh», а своей мерой (`find … -name 'red_*.sh' | wc -l`) их 14. См. Рв-4.

**Норма не тронута.** Регламент, `roles/`, `AGENTS.md` и `ROADMAP.md` в diff не входят. Контракты 094/095/097 меняются ровно возвратом к заморозке по санкции владельца (§1–2).

## 8. Предполагаемый merge-результат (регламент §4)

`land_sim.sh` в одноразовом клоне: `main` = `6945111a7` (текущий origin/main), ветка `integration/streamA-fixup` = `be25b1350`, worktree ветки. Ленд — штатным `scripts/land_agent.sh` из дерева кандидата, identity по умолчанию — `orchestrator`. Ничего не пушилось.

```
main=6945111a7 tip=be25b1350 status-lines=0
merge-tree conflicts check:
9acaa099600ac08dcc0db114030eff938065a3d1
merge-tree rc=0
Deleted branch integration/streamA-fixup (was be25b135).
LANDED main=9492e9671e425c651cea4a17c3b97958306989f4 branch=integration/streamA-fixup
land_agent rc=0
-- merge commit:
9492e9671e425c651cea4a17c3b97958306989f4
 parents=6945111a7682a5826fa95baceb49f1e16eb5a62b be25b1350ffc0cd7e05ee5c2adb079ede42cae31
 author=orchestrator committer=orchestrator
---
land: integration/streamA-fixup
РАЗРЕШИЛ-ВЛАДЕЛЕЦ: scripts/check_protected.sh — переходный регламент 2026-10-13: три точечных grandfather-пары … слово владельца 2026-10-13.
РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/097-doverennaya-osnova-i-podgotovka-obekta.md — … слово владельца 2026-10-13.
РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/095-profil-i-vhod-agenta-contextpack.md — … слово владельца 2026-10-13.
РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/094-prinyatie-i-publikatsiya-kandidata.md — … v3 сохраняется на рабочей ветке; иных правок нет; слово владельца 2026-10-13.
-- delta to first parent:
 14 files changed, 991 insertions(+), 101 deletions(-)
```

Конфликтов нет. `land_agent` перенёс в тело merge все 4 санкции дословно (И-10 контракта 065). Ровно отсутствие этих строк в merge-коммитах ломало `check:charter` на прежнем HEAD `ec863f786`. Дельта merge к первому родителю совпадает с дельтой PR к базе: те же 14 файлов, +991/−101.

Пять исторических барьеров на `9492e9671` (полный режим, `reslop t`):

```
MERGE-RESULT check_protected: ok: true passed: 97 failed: 0 · коммитов пройдено: 4314 · существовало: 919 · на HEAD: 822 · исчезло: 0 · с разрешения: 77 · перенесено: 20 · exit: 0 → rc=0
MERGE-RESULT check_zones:     ok: true passed: 82 failed: 0 · замороженных контрактов: 94 · объявленных авторов: 3 · коммитов в диапазонах: 10402 · проверено по зонам: 2641 · exit: 0 → rc=0
                              (та же прежняя строка FAIL 055 при rc=0, Рв-6)
MERGE-RESULT check_ids:       ok: true passed: 1 failed: 0 · «номера уникальны и согласованы с регистром выдачи» · exit: 0 → rc=0
MERGE-RESULT check_contract_frozen: ok: true passed: 94 failed: 0 · exit: 0 → rc=0
   ok   contracts/094-prinyatie-i-publikatsiya-kandidata.md — заморожен v2, блоб совпадает побайтово, вердикты v1..v2 разрешают
   ok   contracts/095-profil-i-vhod-agenta-contextpack.md — заморожен v1, блоб совпадает побайтово, вердикты v1..v1 разрешают
   ok   contracts/097-doverennaya-osnova-i-podgotovka-obekta.md — заморожен v1, блоб совпадает побайтово, вердикты v1..v1 разрешают
MERGE-RESULT check_charter: ok: true · уставных документов: 93 · изменений в них: 200 · с разрешения: 200 · exit: 0 → rc=0 (909 с)
   ok   уставной документ изменён с разрешения владельца: contracts/094-prinyatie-i-publikatsiya-kandidata.md в 9492e967
   ok   уставной документ изменён с разрешения владельца: contracts/095-profil-i-vhod-agenta-contextpack.md в 9492e967
   ok   уставной документ изменён с разрешения владельца: contracts/097-doverennaya-osnova-i-podgotovka-obekta.md в 9492e967
   ok   contracts/094-… — уставной с frozen/contracts/094/1, коммитов в диапазоне 389, изменений без разрешения нет
   ok   contracts/095-… — уставной с frozen/contracts/095/1, коммитов в диапазоне 340, изменений без разрешения нет
   ok   contracts/097-… — уставной с frozen/contracts/097/1, коммитов в диапазоне 123, изменений без разрешения нет
```
Счёт своей мерой по check_charter: 200 = 197 на head плюс 3 (merge-коммит `9492e967` судится по дельте к первому родителю и признан по всем трём контрактам, потому что land_agent перенёс санкции). Счёт по check_protected: на merge «существовало» 919 и «на HEAD» 822, на head PR было 918 и 821. Разница +1 с обеих сторон — это `verdicts/review/contracts-093-v5.md` из main (`6945111a`), «исчезло» остаётся 0. Критерий З на результате ленда выполнен: все три контракта «блоб совпадает побайтово» с высшей заморозкой.

## Находки

```markdown
---
status: ready
subject: PR#89 integration/streamA-fixup @ be25b1350 (база e8d7f2522; main 6945111a7)
verdict: verdicts/review/pr-089-streama-fixup-v1.md
---
- [ ] Рв-1 (процесс, не блокирует): форма интеграции расходится с буквой §4 регламента («ветки-источники входят в неё через merge --no-ff с сохранением авторства и санкций»). Пакет собран линейным cherry-pick. Свойства, которые охраняет норма, измерены как сохранённые: авторство (author=committer=исходная роль), санкции (дословно, §1) и содержание (patch-id совпадает у 7 из 7). Причина записана открыто (HANDOFF e8eaf0e0: merge-коммиты без санкции ломали check:charter). Оркестратору — признать отклонение строкой в HANDOFF/журнале. Норму этим вердиктом не переписываю.
- [ ] Рв-2 (прослеживаемость, не блокирует): у 5 из 7 перенесённых коммитов (e12fdccb9, e650d043d, 2daced448, 2c53b0a17, 1e88c83b3) нет трейлера `(cherry picked from …)`, а их источники (3a1314a61, 1611c4696, c7f29c4e0, 659c7f84c, 2798ee55c) есть только в локальном репо, на origin их нет. В брифе «сохранён SHA» — неверно, SHA другие. Перед лендом запушить ветки-источники wip/071|094|095|097/architect или записать соответствие SHA в HANDOFF, иначе связь «коммит main → источник» с origin не восстанавливается.
- [ ] Рв-3 (документация барьера, не блокирует): `scripts/check_protected.sh:465` в шапке по-прежнему говорит «— 3 пары (SHA, путь)», хотя ниже (:474) «Шесть пар». В комментарии `excuse_for` (:530) — «входит в ровно эти 2 строки». Счёт в комментариях расходится с кодом (6 пар). Правка — implementer барьера, следующим касанием файла. Отдельная санкция для неё не нужна только если это не новая запись allowlist, а это не она.
- [ ] Рв-4 (счётное утверждение, не блокирует): `fixtures/dokazatelstva_098/.probe-only` говорит «12 клеток red_*.sh», своей мерой 14. Поправить architect 098.
- [ ] Рв-5 (бриф, не блокирует): в брифе «8 коммитов», фактически 10. Коммит 2 (NABLIUDENIA) отнесён к «трогающим уставные файлы», а он не уставной. У коммита 1 в брифе не указан `fixtures/_krasnye_071.sh`.
- [ ] Рв-6 (вне PR, существовавший ранее дефект барьера): `scripts/check_zones.sh:405`: `… | while IFS= read -r line; do bad "$line"; done` — `bad` увеличивает `fails` в подоболочке конвейера, и нарушения грамматики ЗОНА печатаются как FAIL при rc=0. Сегодня так висит `contracts/055` (Н-181). Ложный зелёный класса «напечатал, не покрасил». Оркестратору — завести отдельным предметом (implementer зоны check_zones + красная клетка). Этот PR не трогает.
- [ ] Рв-7 (среда, к сведению): мой прогон `verify_antiplacebo.sh` на базе e8d7f2522 оставил `/tmp/verify_antiplacebo-a759d52c/` (раннер сам сохраняет красный прогон). Удалить мне запретил write-guard Н-85 (путь вне /tmp/dev-harness-verify). Каталог одноразовый, удалить оркестратору. Раннер, пишущий вне /tmp/dev-harness-verify, — родня Н-85/А-122.
```

## Паразитная сложность (контракт 050): строки по новым и раздутым артефактам

- **`check_protected.sh`, ветвь `66e3a0b9` в `excuse_for` (+5 строк кода, +6 комментария).** (1) Критерий Г §2 регламента, три точные пары. (2) Новое состояние — статическая таблица пар: видна в коде и названа в выводе («исчез с явного разрешения: <путь>»). (3) При следующей правке меняется 1 файл, как и прежде. (4) Интерфейс (аргументы, rc, env) не вырос. (5) Потребители — l4 `check:protected` и ap4. Грамматика повторяет три существующие ветви, вложенный `case` — минимальная форма для трёх путей одного SHA. ESSENTIAL.
- **`check_skills.sh`, `SELF_DIR`/`ACTING_ROOT`/`MAKE_TASK` (+12).** (1) Свойство ветви (и) 095: матрица сборщика сверяется с §13.4, и положительный контроль ap2 обязан быть зелёным. (2) Новое состояние — корень действующего чекаута, выводится из `$0`, не из env и не из флагов. Источник матрицы больше не следует за аргументом `REPO`. Это осознанная смена семантики: для `check_skills.sh <другой корень>` ветвь (и) сверяет make_task этого чекаута, а не цели. Записано в шапке правки. (3) Меняется 1 файл. (4) Интерфейс не вырос. (5) Потребитель — ap2 и `check:skills`. ESSENTIAL. Более простая форма «положить make_task.sh в каждую фикстуру» регламентом прямо запрещена.
- **`fixtures/dokazatelstva_098/.probe-only` (новый файл).** (1) Барьер полноты фикстур (034 инв.1) для каталога 098 без барьерного ключа. (2) Состояния нет, есть объявление с причиной. (3) Меняется 1 файл. (4) Не применимо. (5) Потребитель — ap1–ap5 `verify_antiplacebo`. Механизм уже существует (прецеденты context_pack_095 и perezapusk_sessii), и маркер его не дублирует. ESSENTIAL.
- **`red_predpolet_071.sh`: `tag_only_local`/`tag_synced`/`tag_absent_on_bare` и стаб s21 (+72/−16).** (1) Инвариант 4 контракта 071 (отказ, если локального тега нет на цели) и пункты 1–5 «Оценки l2». (2) Состояние — одноразовые toy-репо/bare. Ошибки подготовки названы через `die_cell`. (3) Меняется 1 файл плюс 2 строки комментария в `_krasnye_071.sh`. (4) Интерфейс батареи не изменился. (5) Потребитель — l2 `check:gitw-predpolet-family-selftest`. Три хелпера используются 7 раз (п1, п3а, п3в, п14а, s4, s21), и встраивать их в каждое место было бы хуже. ESSENTIAL.
- **5 восстановленных вердиктов critic.** (1) Критерий В §2. (2)–(5) Это не код: побайтовое восстановление, без интерфейса. ESSENTIAL.

Находок ACCIDENTAL нет.

## Чего этот круг не судил

Содержание журналов NABLIUDENIA_ARCHITECT А-405…А-408 (только добавления, 32 строки) судил только по зоне и типу правки. Тексты v3/иных редакций контрактов 094/095/097 на рабочих ветках не судил: их нет в PR. Post-merge CI — шаг оркестратора после ленда.

## Вердикт

accept. Каждое требование регламента к исправляющему пакету проверено своей мерой, и вывод приложен выше: санкции, З, Г, В, полнота CI, зоны, неослабление проверок, merge-результат. Условие ленда одно: штатный `land_agent` (merge --no-ff identity orchestrator). Он переносит санкции в тело merge, а без этого `check:charter` на main краснеет. Если перед лендом main сдвинется (новые служебные коммиты), merge-результат нужно предъявить барьерам заново (регламент §4). Затем `gitw push` и post-merge CI. Рв-1…Рв-7 раздаются оркестратором по норме 050 и ленд не держат.

Вердикт связан с head `be25b1350ffc0cd7e05ee5c2adb079ede42cae31`. Новый head не наследует этот accept.

Скрипты своей меры (одноразовые, вне дерева): `/tmp/dev-harness-verify/pr89-1791901418/{sanctions,patchid,src_local,restore,mut_protected,zones_own,ap2,mutant_msg,land_sim}.sh`.
