FAIL
OBJECT=87d81815e7573cc7d385db403ed915ab9e626b28
СУД: repo=dev-harness; предмет=156; фаза=контракт (+красная батарея/спецификация); роль=critic; вызов=1/5; модель-план=openai-codex/gpt-6-sol; сессия=01a1a609-1889-74ef-b4b5-9fdb1232d0a6; модель-факт=openai-codex/gpt-6-sol; SHA=87d81815e7573cc7d385db403ed915ab9e626b28; предыдущий=нет; исключение=нет; автор — Arch156 (GLM zai/glm-5.3): независимость есть. Трейс Crit156.jsonl: `model_change openai-codex/gpt-6-sol`, `resolvedModelIsFallback=false`.

## Блокирующие классы

БЛОКИРУЕТ contracts/156-agent-fon-zakrytie.md:38,48-50 — вложенный родитель-субагент без собственного фона паркуется раньше, чем сканер заметит потерю ребёнка. Класс причины: «ведущая никогда не паркуется» ошибочно перенесено на «любую сессию с каталогом детей»; scanner-мирам батареи не задан idle-TTL родителя.
ОБХОД: `W --model` rc 0; при `ArchRodytel.jsonl` без собственного фона сканирование в t=0/300000, парковка после завершения хода в t=420000, а ребёнок с недоставленным `bg_4` пока молчит только 8 минут. После 15 минут родитель уже не сканирует; ни родитель, ни владелец не получат обещанного сигнала. Та же модель при моделировании штатной парковки scanner-родителя дала `parent=ArchRodytel.jsonl fatal=None parked=True signals=0 times=[] now=420000`.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: на каждом обещанном уровне вложенности сигнал имеет живого получателя при парковке непосредственного родителя; приёмка моделирует TTL родителя-субагента и позднюю потерю ребёнка. Это не допущение A1: у родителя НЕТ фоновой работы и будильник ему не назначен.

БЛОКИРУЕТ contracts/156-agent-fon-zakrytie.md:38,48-49,67 — не учитываются все недоставленные задания ребёнка. Класс причины: хранение только последнего фон-старта в пределах последних 64 КиБ журнала вместо состояния всех ещё ожидаемых результатов.
ОБХОД: честная модель проходит `W --model` rc 0, но `[start bg_1, start bg_2, async-result bg_2, session_exit]` даёт `signals=0` при недоставленном `bg_1`; а `[start bg_1, 400 других ходов, session_exit]` (журнал 125428 байт) даёт `signals=0`, поскольку старт за границей хвоста. Оба допустимы и не оговорены разделом НЕ ЗАЩИЩАЕТ.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: при любой ещё недоставленной фоновой задаче после закрытия или молчания возникает сигнал, включая одновременно запущенные задания и длинный журнал; красные клетки предъявляют оба случая.

БЛОКИРУЕТ contracts/156-agent-fon-zakrytie.md:44-45,50,67 — приёмка роли Б нечувствительна к имени ребёнка: все её клетки используют `ArchX.jsonl`, а k04 с `Task-7` проверяет лишь будильники роли А. Класс причины: инвариантность к имени предъявлена только на другом канале.
ОБХОД: собственная точечная мутация модели вне байтового блока грамматики: `if (!imya.endsWith('.jsonl')) continue` → `if (imya !== 'ArchX.jsonl') continue`. `W --candidate /tmp/dev-harness-verify/Crit156/candidate` прошёл 16/16 субъектных клеток, rc 0 `OK`; с недоставленным `bg_9` и `session_exit` у `Task-7.jsonl` эталон выдаёт 1 сигнал, мутация — 0.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: любое допустимое имя ребёнка получает ту же детекцию недоставленного фона; мутация имени краснеет в батарее.

БЛОКИРУЕТ contracts/156-agent-fon-zakrytie.md:43,49,67 — повторные сигналы по ОДНОМУ молчащему ребёнку. Класс причины: изменяющийся `ageMin` принят за стабильную метку дедупликации (`molchit-${ageMin}`), а виртуальный планировщик не сдвигает часы `shov.nowMs()`; модельная клетка ложно зелена.
ОБХОД: `W --model` rc 0; при том же ребёнке с начальным молчанием 16,5 минуты, если сдвигать часы на каждом тике, модель даёт `signals=3 times=[0, 300000, 600000]`, будит родителя трижды вместо РОВНО ОДНОГО сигнала.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: сканирования той же потери через 0/5/10 минут дают один сигнал; батарея переводит виртуальные часы вместе с тиками.

БЛОКИРУЕТ contracts/156-agent-fon-zakrytie.md:53,66-67,74-76 — обязательное зелёное предъявление модели и дверь `pre_critic` ложнокрасные при разрешённом параллельном суде. Класс причины: m01 засчитывает ЛЮБУЮ чужую запись в живой журнал станции (`mtime > marker`) как побочное действие своей батареи.
ОБЯЗАТЕЛЬСТВО: `W --model` rc 0, `check_spec_ready` и `pre_critic` rc 0 до заморозки; слово владельца от 2026-11-04 разрешает шесть независимых судей одновременно.
СОСТОЯНИЕ: во время работы батареи судьи Crit159c/Crit154e и агент проекта Critic154r1 законно дописывают свои `.jsonl`.
НАБЛЮДЕНИЕ: `check_spec_ready.sh` rc 1 «спек-гейт 036: проба красна без заявленной причины»; трасса модели: `CASE m01-germetichnost KRASNO (затронуты реальные журналы: .../Crit159c.jsonl; .../Crit154e.jsonl; .../Critic154r1.jsonl)`, остальные модельные клетки ZEL; `KLETKI subject 16 KRASNYH 1`. `pre_critic.sh` rc 1 «ОТКАЗ: spec-ready красен». Это не свидетельство записи батареи в чужие журналы.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: проверки герметичности отличают записи своего прогона от законной активности других сессий; настоящая запись своей батареи вне одноразового мира остаётся красной, параллельный запуск `W --model` и pre_critic — зелёный.

## Сырой вывод отрицательных проб (одноразовый архив OBJECT)

В `probe_local.py` заменены ТОЛЬКО пути временных миров `/tmp/dev-harness-verify/Arch156/` → `/tmp/dev-harness-verify/Crit156/`; SUBJECT, модель и оракул читаются из архива без изменения. `negative_examples.py` строит журналы штатными конструкторами `probe.py`; для parent-сценария добавляет TTL сканирующей субагентской сессии, для молчания переводит виртуальное `shov.nowMs` с `now`. `negative_tail.py` добавляет к штатному журналу 400 обычных ходов. `make_candidate.py` применяет описанную выше единственную подстановку модели в одноразовый кандидат.

```
$ python3 /tmp/dev-harness-verify/Crit156/make_candidate.py
candidate=/tmp/dev-harness-verify/Crit156/candidate/.omp/extensions/fon-guard.ts scannerRestrictedTo=ArchX.jsonl blockGrammarUnchanged=True
[rc=0]
$ python3 /tmp/dev-harness-verify/Crit156/probe_local.py --candidate /tmp/dev-harness-verify/Crit156/candidate
CASE k04-imya-invariantnost ZEL (инвариантность к имени агента: Task-7 защищён теми же будильниками, что и ProbeK01)
CASE s01-mertv-dispose ZEL ((г) закрытие с недоставленным фоном → родителю машинный сигнал дословной грамматики)
CASE m01-germetichnost ZEL (вне одноразовых каталогов ничего не тронуто)
CASE m02-grammatika-bajty ZEL (блок грамматики побайтово)
KLETKI subject 16 KRASNYH 0
OK
[rc=0; прочие 14 CASE также ZEL]
$ python3 /tmp/dev-harness-verify/Crit156/negative_name.py
model: Task-7 closed with undelivered bg_9; fatal=None signals=1
candidate: Task-7 closed with undelivered bg_9; fatal=None signals=0
[rc=0]
$ python3 /tmp/dev-harness-verify/Crit156/negative_examples.py
two-jobs-only-last-delivered: parent=2026-11-02T21-05-50-062Z_01a19e15-2bee-7741-aaa7-a4f74b1b4ab2.jsonl fatal=None parked=False signals=0 times=[] now=600000
silent-age-advances-on-every-tick: parent=2026-11-02T21-05-50-062Z_01a19e15-2bee-7741-aaa7-a4f74b1b4ab2.jsonl fatal=None parked=False signals=3 times=[0, 300000, 600000] now=600000
parent-parked-before-child-lost: parent=ArchRodytel.jsonl fatal=None parked=True signals=0 times=[] now=420000
[rc=0]
$ python3 /tmp/dev-harness-verify/Crit156/negative_tail.py
long-journal: journalBytes=125428 fatal=None signals=0
[rc=0]
```

## Остальные прогоны

- `git cat-file -t 87d81815e7573cc7d385db403ed915ab9e626b28` → `commit`, rc 0. Архив с отдельными git-метаданными и HEAD=OBJECT; основной чекаут не менялся.
- `python3 /tmp/dev-harness-verify/Crit156/probe_local.py` → rc 1; именованные `CASE k01-fon-bez-exita KRASNO (SUBJECT_ABSENT: субъекта нет: .../.omp/extensions/fon-guard.ts)`, аналогично s01/s07 и всем 16 субъектным клеткам; `CASE k00-bazelin-smert ZEL`, `CASE m01-germetichnost ZEL`, итог `KLETKI subject 16 KRASNYH 16`.
- `python3 /tmp/dev-harness-verify/Crit156/probe_local.py --model` → rc 0, `CASE s07-molchanie-15 ZEL`, `CASE s09-signal-odin-raz ZEL`, `KLETKI subject 16 KRASNYH 0`, `OK`.
- `python3 /tmp/dev-harness-verify/Crit156/probe_local.py --stabs` → rc 0; сырой вывод: `STAB signal-bez-dostavki POIMAN клеткой s03-zdorovyj: сигналов 1 ≠ 0`; `STAB zapret-po-imeni POIMAN клеткой k04-imya-invariantnost: будильники [] ≠ [300000, 600000]`; `STAB poslednee-soobshchenie POIMAN клеткой s02-dozhdalsya-lozh: сигналов 0 ≠ 1`; `STAB budilnik-odin-raz POIMAN клеткой k02-dlinnyj-fon: будильники [300000, 645000, 990000, 1335000, 1680000] ≠ [300000, 600000, 900000, 1200000, 1500000]`; `STAB lyuboj-exit POIMAN клеткой s04-vozrozhdennyj: сигналов 1 ≠ 0`; `STAB yield-slep POIMAN клеткой s05-yield-posle-fona: сигналов 1 ≠ 0`; `STAB signal-v-log POIMAN клеткой s01-mertv-dispose: сигналов 0 ≠ 1`; `SVJAZI 7`.
- `bash scripts/check_spec_ready.sh . contracts/156-agent-fon-zakrytie.md` → rc 1 `спек-гейт 036: проба красна без заявленной причины` (трасса m01 выше); `bash scripts/pre_critic.sh --repo . contracts/156-agent-fon-zakrytie.md` → rc 1 `ОТКАЗ: spec-ready красен: contracts/156-agent-fon-zakrytie.md`.
- `bash scripts/check_precision_gate.sh . contracts/156-agent-fon-zakrytie.md` → rc 0 `OK`; `bash scripts/check_threat_model.sh . contracts/156-agent-fon-zakrytie.md` → rc 0 `модель угроз: секция валидна (ЗАЩИЩАЕТ 4 буллет(ов), НЕ ЗАЩИЩАЕТ 5 буллет(ов))`; `bash scripts/check_ceilings.sh .` → rc 0 `потолки в порядке`.
- `bash scripts/check_provodka.sh . contracts/156-agent-fon-zakrytie.md` → rc 1 `проводка: guard не подключён: fixtures/workshop_project/agent_fon_156/red_agent_fon_156.sh не вызывается в .githooks/ или .github/workflows/` — ОЖИДАЕМО до ленда.
- `bash scripts/check_zones.sh --incr /tmp/dev-harness-verify/Crit156/zones.cache .` → rc 0 (кеш записал SHA OBJECT); сырой итог: `замороженных контрактов: 148 · объявленных авторов: 5 · коммитов в диапазонах: 43953 · проверено по зонам: 10419`; полный прогон длился 604,90 секунды.
- `bash fixtures/workshop_project/wait_guard_128/red_wait_guard_128.sh --model` → rc 1; `РАСХОЖДЕНИЕ c08-porog-env:driver-rc-0:—`, `ИТОГ 128 (модель): клеток 18, сошлось 17, расхождений 1 (seed 591272316)`; пустой stdout одного Node-драйвера, причина не установлена, зелень не заявляю.

## Не проверено

- Живая проба omp после ленда (допущение A1), как предусмотрено контрактом; отсутствие её ДО ленда само по себе не блок.
- Реализация `.omp/extensions/fon-guard.ts` отсутствует; безфлаговый `W` обязан быть красным. CI-проводка до ленда ожидаемо отсутствует.
- Положительный исход регрессии 128 не доказан в данном прогоне (c08 с пустым stdout, rc 1); источник сбоя не установлен.
