FAIL
OBJECT=f6bd9d2a48fef4683a81f47d192264867a9a070c
СУД: repo=dev-harness; предмет=109 (v5); фаза=контракт; роль=critic-sol; вызов=1/2; модель-план=openai-codex/gpt-6-sol; сессия=Critic109f; модель-факт=openai-codex/gpt-6-sol; SHA=f6bd9d2a48fef4683a81f47d192264867a9a070c; предыдущий=critic 109 v4 (1/2 FAIL verdicts/critic/contracts-109-v4-krug1.md, 2/2 accept verdicts/critic/contracts-109-v4.md); исключение=нет. Автор Architect109v5/v5b — zai/glm-5.3; независимость сохранена. Ветка не опубликована, SHA проверен в клоне автора: `git cat-file -t f6bd9d2a48fef4683a81f47d192264867a9a070c` → `commit`, rc 0; checkout ровно этого OBJECT. Отсутствие РАЗРЕШИЛ-ВЛАДЕЛЕЦ в сообщении до работы оркестратора не использовано как блокер.

## БЛОКИРУЕТ

БЛОКИРУЕТ contracts/109-cmp-bck-004-stend-evidence.md:51 — форма переменной не сохраняется: `lane_tag_iz_okruzhenija` в сданной пробе применяет `.strip()` ДО проверки формы. Класс — принятие недопустимой формы без объявленного отказа; `W --model` зелён, поскольку среди `forma:*` нет ведущего/замыкающего пробела или перевода строки. Закрывающее свойство: валидировать исходное значение `STEND109_TAG` как точную строку формы `frozen/contracts/109/<N>` и отвергать whitespace вариантом `STEND109_TAG_FORM`, а в критерии различать этот дефект от честной пробы.
ОБЯЗАТЕЛЬСТВО: контракт: любая форма вне `frozen/contracts/109/<N>`, N целое ≥4, → `STEND109_TAG_FORM`, fail-closed CLI rc 2; источник тега только окружение. Приёмка 13 (`contracts/109-cmp-bck-004-stend-evidence.md:27`) обещает красные клетки для кривой формы.
СОСТОЯНИЕ: настоящий H-checkout `frozen/contracts/109/4` на HEAD одноимённого тега в отдельном клоне; `STEND109_TAG='frozen/contracts/109/4 '` (или ведущий пробел, или `\n`). Это достижимое значение окружения и недопустимая полная форма, а не подмена CI доверенной средой.
НАБЛЮДЕНИЕ: `probe.py:2196` читает `os.environ.get(...).strip()`; вызов `lane_tag_iz_okruzhenija(h-tag4)` на исходном кандидате вернул для `'frozen/contracts/109/4 '` **`('frozen/contracts/109/4', None)`**; для ведущего пробела и перевода строки тот же успешный результат. `W --model --base back-main` тем временем rc 0/51 зелёных. Критерий разрешает объявить форму готовой, не реализовав заявленный отказ.
ОБХОД: при CI-env `frozen/contracts/109/4 ` и H-checkout коммита тега проба молча преобразует НЕ объявленный тег в `frozen/contracts/109/4`; ожидаемое `STEND109_TAG_FORM` никогда не предъявляется, а порождаемые `forma:*` остаются зелёными. Для отдельного `frozen/contracts/109/04` после создания одноимённого легковесного тега получено `('frozen/contracts/109/04', None)`; семантика ведущего нуля в «целом N» не определена, достаточно несомненного контрпримера с whitespace.

### Сырой repro обязательства

```
$ git -C /tmp/dev-harness-verify/Critic109f/h-tag4 checkout -q frozen/contracts/109/4
rc=0
$ python3 -c 'import importlib.util,os,pathlib; p="fixtures/workshop_project/stend_109/probe.py";s=importlib.util.spec_from_file_location("probe109",p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);h=pathlib.Path("/tmp/dev-harness-verify/Critic109f/h-tag4");[(os.environ.__setitem__("STEND109_TAG",v),print(repr(v),repr(m.lane_tag_iz_okruzhenija(h)))) for v in ("frozen/contracts/109/4","frozen/contracts/109/4 "," frozen/contracts/109/4","frozen/contracts/109/4\n","frozen/contracts/109/04","frozen/contracts/109/4x","frozen/contracts/109/4/../3","frozen/contracts/109/%34","frozen/contracts/1090/4","FROZEN/contracts/109/4")]'
rc=0
'frozen/contracts/109/4' ('frozen/contracts/109/4', None)
'frozen/contracts/109/4 ' ('frozen/contracts/109/4', None)
' frozen/contracts/109/4' ('frozen/contracts/109/4', None)
'frozen/contracts/109/4\n' ('frozen/contracts/109/4', None)
'frozen/contracts/109/04' (None, 'STEND109_TAG_MISMATCH: тег frozen/contracts/109/04 не резолвится в /tmp/dev-harness-verify/Critic109f/h-tag4 (rc=128) — проба исполняется не с объявленного тега')
'frozen/contracts/109/4x' (None, "STEND109_TAG_FORM: 'frozen/contracts/109/4x' вне грамматики frozen/contracts/109/<N> (N — целое ≥ 4)")
'frozen/contracts/109/4/../3' (None, "STEND109_TAG_FORM: 'frozen/contracts/109/4/../3' вне грамматики frozen/contracts/109/<N> (N — целое ≥ 4)")
'frozen/contracts/109/%34' (None, "STEND109_TAG_FORM: 'frozen/contracts/109/%34' вне грамматики frozen/contracts/109/<N> (N — целое ≥ 4)")
'frozen/contracts/1090/4' (None, "STEND109_TAG_FORM: 'frozen/contracts/1090/4' вне грамматики frozen/contracts/109/<N> (N — целое ≥ 4)")
'FROZEN/contracts/109/4' (None, "STEND109_TAG_FORM: 'FROZEN/contracts/109/4' вне грамматики frozen/contracts/109/<N> (N — целое ≥ 4)")
```

## СОВЕТ

СОВЕТ contracts/109-cmp-bck-004-stend-evidence.md:228 — в §Замер v5 живой run достоверно зелёный, но фраза «007-голова (N=15) ... ledger N=15» не подтверждается коммитом run. GitHub API: run `40523445654` head `61b6e076b2f3f8799e33b960d5d141f0eaa66c8b`, success; его `server/infrastructure/migrations/manifest.json` имеет 14 записей, последний version 14, как и PR #263 @ `07f5c32c...` (срез на PR #263 даёт 51 клетку). N=15 и 58 клеток доказаны на другом дереве — PR #239 @ `c381c3deb...`; живой CI не доказал именно N=15. Уточнить измеренное; это неточность прозы замера, не отрицание success и не второй класс блокера.
СОВЕТ contracts/109-cmp-bck-004-stend-evidence.md:233 — после фактического п.8 оставлен второй п.8 в будущем времени с устаревшим планом («делает ОРКЕСТРАТОР», локальный `git tag` либо freeze до прогона); он противоречит выполненному clone одноразовой ветки-кандидата и запутывает границу доказанного. Удалить устаревший план. На замороженный критерий это не влияет.
СОВЕТ contracts/109-cmp-bck-004-stend-evidence.md:26 — `ci:zhivoj` отличает job-env от step-env, но на входе `STEND109_TAG: ""` выдаёт `job`, а не «пустое значение»: фактический CI-клон такой тег не клонирует; живой CI остаётся вторым отказом. Поименовать границу клетки/проверить значение, если требуется именно суд целостности env, а не уровня объявления. `W --repo` на изменённом trial-дереве rc 1 из-за `BACKEND_LINT_GUARD`, поэтому зелёный обход полной приёмки НЕ утверждаю.

## Доказательства и объём прогона (OBJECT)

Границы: diff `frozen/contracts/109/4..OBJECT` текста = 52 изменённые строки (44+/8-): сохранены приёмки 1–8,10, прежняя lane-гигиена ниже резолвера; новые предмет/инвариант 9/приёмка 13/предпосылка продукта и Замены v5 (12 пунктов) соответствуют дельте. `git show --stat OBJECT`: 7 файлов только `contracts/109-...md` и `fixtures/workshop_project/stend_109/` (зона architect); `ЗОНА implementer` — внешний продукт; риск рисковый («права/роли БД»). Проводка/пересечения соблюдены. `grep` по probe.py: `frozen/contracts/109/[0-9]` — только комментарии/история, `LANE_FROZEN_TAG` нет. Порядок в `lane_hygiene_fact`: маркер глубины, затем вызов `lane_tag_iz_okruzhenija`, затем проверки lane/docker/пина. При отсутствующем/пустом env — ABSENT, неверной форме без whitespace — FORM; старый/нерезолвящийся тег — MISMATCH; `rev-parse raw^{commit}` снимает commit как лёгкого, так и аннотированного тега. Аннотированный тег живым CI не проверен.

```
$ bash scripts/check_precision_gate.sh <клон> contracts/109-cmp-bck-004-stend-evidence.md
OK
rc=0
$ bash scripts/check_provodka.sh <клон> contracts/109-cmp-bck-004-stend-evidence.md
[пустой stdout]
rc=0
$ bash scripts/check_threat_model.sh <клон> contracts/109-cmp-bck-004-stend-evidence.md
модель угроз: секция валидна (ЗАЩИЩАЕТ 11 буллет(ов), НЕ ЗАЩИЩАЕТ 9 буллет(ов))
rc=0
$ bash scripts/check_spec_ready.sh <клон> contracts/109-cmp-bck-004-stend-evidence.md
спек-гейт 036: перенос зоны: backend/compose.dev.yml (implementer): исключение ZONE_MOVE_EXEMPT (контракт 109, продуктовый репо)
[ещё 14 ZONE_MOVE_EXEMPT по указанным путям]
OK
rc=0
$ bash scripts/check_ceilings.sh <клон>
  ok   персоны: 12 файл(ов), потолок 61440 байт
  ok   правила: 1 файл(ов), потолок 30720 байт
  ok   раздел требований: 137 черновик(ов) судится, замороженные — по тегам
потолки в порядке
rc=0
$ bash scripts/pre_critic.sh --repo <клон> contracts/109-cmp-bck-004-stend-evidence.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=3
КРИТИК: дверь зелёная
rc=0
```

`sha256sum probe.py` на OBJECT и `git show be7f7857:.../probe.py | sha256sum`: оба `5eb3577bb6225cae4e09e99d6e5ab51280bd116238f8469c843f51ef06e33c28`. `sha256sum ci_job_env.yml` = `4caa93bd8ea155fa2a636755c165fd29524bbc28f07d476d270b469a9b15fa5f`, `git show 61b6e076b:.github/workflows/ci.yml | sha256sum` — тот же; `ci_shag_env.yml` и `git show 0d1df14:.github/workflows/ci.yml` — оба `c489941b876142410d84674280d4deeb4fe66b1fe0e99732072e01d351dc351b`. Trial `STEND109_PIN = 'be7f7857e36518b7fb46d889d328db84d075fdc5'`, job-level `STEND109_TAG: frozen/contracts/109/5` подтверждены живыми байтами. API `/actions/runs/40523445654/jobs`: 9/9 success, включая `stend109` id `122256518000` на `station-back-2`. Сырой лог `/tmp/dev-harness-verify/orch/stend109-live-122256518000.log`:
```
Run git clone --depth=1 --branch "$STEND109_TAG" https://github.com/a3ka/dev-harness.git "$RUNNER_TEMP/h"
  STEND109_TAG: frozen/contracts/109/5
Run python3 tests/tools/run_backend_ci.py --lane stend109 --out evidence/ci/stend109
  STEND109_TAG: frozen/contracts/109/5
[stend109] PASS       rc=0 проба стенда 109 (контроль + 15 фактов + 53 клетки REJECTED_EXACT) (412.2 с)
итог: все lanes success; evidence: /var/lib/ci-runner-back/runner2/_work/Complior-back/Complior-back/evidence/ci/stend109
```
Метка «53» в stdout раннера — застарелый литерал, не детальная мера 57 кейсов; артефакт evidence не читался. Выполнен docker-слой lane на ОДНОМ дереве trial, не W N-матрица/main и не аннотированный tag-object.

Прогоны среза (все на OBJECT; base main `0d1df14`, 007 implementation PR #239 `c381c3d`):
```
$ bash fixtures/workshop_project/stend_109/red_migracii_109.sh --model --base <back-main>   # x3
ci:job-env                                   ok 
ci:shag-env                                  ok 
клеток 51, красных 0
rc=0 каждый из трёх прогонов
$ bash fixtures/workshop_project/stend_109/red_migracii_109.sh --model --base <back-007-impl>
клеток 58, красных 0
rc=0
$ bash fixtures/workshop_project/stend_109/red_migracii_109.sh --stabs --base <back-main>
stab s-konstanta-tega @ teg-4:zeleno         ok 
stab s-konstanta-tega @ env:otsutstvuet      ok 
stab s-teg-bez-sverki-s-golovoj @ teg-4:staryj-teg ok 
stab s-pustoj-env-umolchanie @ teg-4:pustoj-env ok 
stab s-forma-ne-proverjaetsja @ forma:ne-celoe ok 
стабов 8, привязок 10, непойманных 0
клеток 61, красных 0
rc=0
$ bash fixtures/workshop_project/stend_109/red_migracii_109.sh --repo <back-main>
живой манифест /tmp/dev-harness-verify/Critic109f/back-main: N=14
полный CLI-прогон (PATH без docker): rc=1, отчёт=читается, красных фактов 0, красный контроль пуст
ci:zhivoj                                    KRASNO v=shag note=STEND109_TAG вне jobs.stend109.env (строка 195: уровень шага steps.* либо неблочная форма) — шаг lane env не наследует — ПРЕДПОСЫЛКА: env на уровень jobs.stend109 (зона implementer)
клеток 52, красных 1
rc=1
$ bash fixtures/workshop_project/stend_109/red_migracii_109.sh --repo <back-007-impl>
живой манифест /tmp/dev-harness-verify/Critic109f/back-007-impl: N=15
ci:zhivoj                                    KRASNO v=shag note=STEND109_TAG вне jobs.stend109.env (строка 195: уровень шага steps.* либо неблочная форма) — шаг lane env не наследует — ПРЕДПОСЫЛКА: env на уровень jobs.stend109 (зона implementer)
клеток 59, красных 1
rc=1
$ bash fixtures/workshop_project/stend_109/red_migracii_109.sh --repo <back-trial>
живой манифест /tmp/dev-harness-verify/Critic109f/back-trial: N=14
ci:zhivoj                                    ok 
клеток 52, красных 0
rc=0
```
На PR #263 `07f5c32c` проверен также `--model`: 51/0 rc0 (его N=14, не PR #239 с N=15). Структурный `sudit_ci` на исходных байтах и YAML-мутантах: comment=`net`, other-job=`net`, with=`shag`, run=`shag`, step-env=`shag`, empty-job-env=`job`; комментарии/другие job/`with`/`run`/step-env не были ошибочно объявлены job-level.

Свои атаки: отдельно созданные копии каталога `stend_109` в `/tmp/dev-harness-verify/Critic109f/attack-*` (оригинал OBJECT не тронут); драйвер `/tmp/dev-harness-verify/Critic109f/attack109.py`. Ниже команды и дословные решающие строки stdout каждой атаки (все остальные строки `mir-*`/`ci:*` — `ok`):
```
$ bash /tmp/dev-harness-verify/Critic109f/attack-constant/red_migracii_109.sh --model --base /tmp/dev-harness-verify/Critic109f/back-main
teg-5:zeleno                                 KRASNO v=None note=STEND109_TAG_MISMATCH: тег frozen/contracts/109/4 не резолвится в /tmp/srez109-f14x7spu/te
forma:istoricheskij-3                        KRASNO v=None note=NEEDS_ENV: docker недоступен — замороженная батарея на чистом H требует EGRESS_GUARD, lane
grep:teg-v-sudjashchem                       KRASNO нарушений 1: probe.py:2196
клеток 51, красных 10
rc=1
$ bash /tmp/dev-harness-verify/Critic109f/attack-skip_head/red_migracii_109.sh --model --base /tmp/dev-harness-verify/Critic109f/back-main
teg-4:staryj-teg                             KRASNO v=None note=NEEDS_ENV: docker недоступен — замороженная батарея на чистом H требует EGRESS_GUARD, lane
клеток 51, красных 7
rc=1
$ bash /tmp/dev-harness-verify/Critic109f/attack-default_empty/red_migracii_109.sh --model --base /tmp/dev-harness-verify/Critic109f/back-main
cli:teg-otsutstvuet                          KRASNO rc=2 имён=0
cli:teg-pustoj                               KRASNO rc=2 имён=0
grep:teg-v-sudjashchem                       KRASNO нарушений 1: probe.py:2196
клеток 51, красных 3
rc=1
$ bash /tmp/dev-harness-verify/Critic109f/attack-skip_form/red_migracii_109.sh --model --base /tmp/dev-harness-verify/Critic109f/back-main
forma:ne-celoe                               KRASNO v=None note=STEND109_TAG_MISMATCH: тег frozen/contracts/109/x не резолвится в /tmp/srez109-8czo9roe/te
клеток 51, красных 5
rc=1
$ bash /tmp/dev-harness-verify/Critic109f/attack-check_branch/red_migracii_109.sh --model --base /tmp/dev-harness-verify/Critic109f/back-main
teg-4:chuzhoj-kommit                         KRASNO v=None note=NEEDS_ENV: docker недоступен — замороженная батарея на чистом H требует EGRESS_GUARD, lane
клеток 51, красных 7
rc=1
```
Привязки четырёх авторских теговых стабов в коде `STABY`/`TEG_VHODY`/`TEG_OZHID` сверены с исполняемыми мутантами; 8/10/0. Порча оракула (драйвер `attack_pins109.py` на копиях; сырые строки):
```
$ bash /tmp/dev-harness-verify/Critic109f/attack-pin-model-bytes/red_migracii_109.sh --model --base /tmp/dev-harness-verify/Critic109f/back-main
109 SEZ: ORACLE_TAMPERED: пин model/manifest.json f125f6729724 != байтам 66ce91e8ed49
rc=2
$ bash /tmp/dev-harness-verify/Critic109f/attack-pin-stab-vhod/red_migracii_109.sh --model --base /tmp/dev-harness-verify/Critic109f/back-main
109 SEZ: ORACLE_TAMPERED: рассинхрон stab_vhod: source.json ['s-forma-ne-proverjaetsja', 's-konstanta-14', 's-manifest-iz-fikstury', 's-ozhidanie-iz-fajlov', 's-pustoj-env-umolchanie', 's-pustoj-prinjat', 's-teg-bez-sverki-s-golovoj'] != коду ['s-forma-ne-proverjaetsja', 's-konstanta-14', 's-konstanta-tega', 's-manifest-iz-fikstury', 's-ozhidanie-iz-fajlov', 's-pustoj-env-umolchanie', 's-pustoj-prinjat', 's-teg-bez-sverki-s-golovoj']
rc=2
$ bash /tmp/dev-harness-verify/Critic109f/attack-pin-anchor/red_migracii_109.sh --stabs --base /tmp/dev-harness-verify/Critic109f/back-main
109 SEZ: STAB_ANCHOR_MISSING: якорь стаба s-forma-ne-proverjaetsja не найден — пере-якорение
rc=2
$ bash /tmp/dev-harness-verify/Critic109f/attack-pin-ci-bytes/red_migracii_109.sh --model --base /tmp/dev-harness-verify/Critic109f/back-main
109 SEZ: ORACLE_TAMPERED: пин ci_nositeli/ci_job_env.yml 4caa93bd8ea1 != байтам 68999a1878db
rc=2
$ bash /tmp/dev-harness-verify/Critic109f/attack-pin-ci-bytes/red_migracii_109.sh --repo /tmp/dev-harness-verify/Critic109f/back-main
живой манифест /tmp/dev-harness-verify/Critic109f/back-main: N=14
109 SEZ: ORACLE_TAMPERED: пин ci_nositeli/ci_job_env.yml 4caa93bd8ea1 != байтам 68999a1878db
rc=2
$ bash /tmp/dev-harness-verify/Critic109f/attack-pin-ci-pin/red_migracii_109.sh --model --base /tmp/dev-harness-verify/Critic109f/back-main
109 SEZ: ORACLE_TAMPERED: пин ci_nositeli/ci_job_env.yml 000000000000 != байтам 4caa93bd8ea1
rc=2
$ bash /tmp/dev-harness-verify/Critic109f/attack-pin-ci-section/red_migracii_109.sh --model --base /tmp/dev-harness-verify/Critic109f/back-main
109 SEZ: ORACLE_TAMPERED: pin_ci_nositeli отсутствует/неполон (нужны оба носителя)
rc=2
```
Отдельно атака якоря с `--model` дала rc 0/51: она гарантирована **только в `--stabs`**, как и сформулировано в приёмке 11; это не обход заявленного критерия. Путь docker намеренно не запускался; артефакт evidence не читался. Коммит/push вердикта не делался по прямому ограничению задания.
