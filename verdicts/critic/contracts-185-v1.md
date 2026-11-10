accept
OBJECT=18e4ace89508b05efb76dd3b6e89e04df88c15ea
СУД: repo=dev-harness; предмет=185; фаза=контракт; роль=critic; вызов=2/2; модель-план=zai/glm-5.3; сессия=Crit185v3; модель-факт=openai-codex/gpt-5.6-terra; SHA=18e4ace89508b05efb76dd3b6e89e04df88c15ea; предыдущий=verdicts/critic/contracts-185-v1-krug1-fail.md; исключение=нет

# Вердикт критика — контракт 185 «pre_judge prepare: детектор харнесса судит корень проекта», исправительный вызов 2/2

## Кандидат, независимость и граница повтора

Объект проверен в отдельном одноразовом SSH-клоне: `git checkout --detach 18e4ace89508b05efb76dd3b6e89e04df88c15ea && git rev-parse HEAD` дал ровно `18e4ace89508b05efb76dd3b6e89e04df88c15ea` (rc 0). Автор объектного коммита — `architect`; судья — отдельная сессия `Crit185v3`, поэтому собственная работа не судится. Назначение critic — `apex-sol`, план `zai/glm-5.3`; фактический `openai-codex/gpt-5.6-terra` — разрешённый `@gpt-terra` autoFallback (`config/agent_models.json:12,59-63,94-95`).

Запуск разрешён: после `git fetch origin main` команда

```text
$ git log -G 'предмет=185;.*вызов=2/2' --format='%H%n%s' origin/main -- HANDOFF.md
ef8fe1c2433a2083e24060942e702fc6632575cc
HANDOFF: СУД reviewer 143 вызов 2/2 и critic 185 вызов 2/2 (записи до вызова)
[rc=0]
```

Это scoped-повтор: проверены закрытие двух классов из `verdicts/critic/contracts-185-v1-krug1-fail.md` и последствия изменённой семантики 18e4ace8 — фиксированного выбора детектора установки и нового составного входа «нет детектора установки + локальный fake». Неизменённые поверхности заново не исследовались.

## Закрытие блоков круга 1

1. Форма обязательной модели угроз закрыта: literal-метки и следующие за ними буллеты находятся в `contracts/185-pre-judge-proektnyj-rezhim.md:21-28`. Механический читатель теперь принимает секцию.
2. Ложная достаточность при отсутствии доверенного детектора закрыта: `contracts/185-pre-judge-proektnyj-rezhim.md:34` требует `missing_harness_local_fake`, а `fixtures/workshop_project/pre_judge_leak_185/probe.py:82-91,127-128,146-147` создаёт этот достижимый вход и привязывает к нему мутацию `fallback_to_local`. Честная модель возвращает rc 2 с пустым stdout; мутант возвращает ложный rc 0 и ловится. Моя независимая inline-мутация того же уже существующего отказа через условный fallback в `$R/scripts/check_no_leak.sh` также красная ниже.

`contracts/185-pre-judge-proektnyj-rezhim.md:15-17` сохраняет нужный результат: исполняется детектор рядом с данным `pre_judge.sh`, получает `--check "$R"`, проектный детектор не участвует, а отсутствие детектора установки остаётся rc 2. Текущий hotfix намеренно остаётся красным на `--repo` до реализации; это прямо заявленная предреализационная клетка, не ложная зелень.

## 172, зоны и изоляция fixture

Кандидат меняет только `contracts/185-pre-judge-proektnyj-rezhim.md` и `fixtures/workshop_project/pre_judge_leak_185/probe.py`, оба пути принадлежат `ЗОНА architect` (`contracts/185-pre-judge-proektnyj-rezhim.md:42`). Все найденные объявления `scripts/pre_judge.sh` принадлежат одному `implementer`: frozen 172 (`contracts/172-predverie-sudejskoj-provodki.md:36`) и 185 (`contracts/185-pre-judge-proektnyj-rezhim.md:43`); чужой зоны нет. `contracts/185-pre-judge-proektnyj-rezhim.md:48` явно объявляет пересечение и не меняет frozen-файл 172.

`contracts/185-pre-judge-proektnyj-rezhim.md:35,48` не маскирует регресс 172: после реализации старая неконформная `published`-клетка должна мигрировать отдельным owner-санкционированным 172 v+1 до done 185. В этом кандидате frozen fixture не менялась. Текущий регресс 172 зелёный на owner-hotfix, как и заявлено до реализации.

`probe.py` создаёт самостоятельные Git-деревья `harness` и `project` (`fixtures/workshop_project/pre_judge_leak_185/probe.py:44-65`), а `--model` был повторён из `/tmp`, вне cwd клона; это исполнимо подтвердило отсутствие зависимости от основного checkout (Н-193).

Полный `check_zones.sh` намеренно не запускался: для исправительного scoped-вызова задание разрешает не тратить 10+ минут на весь исторический диапазон. Вместо этого проверены ровно автор и два изменённых пути в дельте, все объявители `scripts/pre_judge.sh` и объявленное 172-пересечение выше.

## Выполненные прогоны

```text
$ bash scripts/pre_critic.sh contracts/185-pre-judge-proektnyj-rezhim.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=1
КРИТИК: дверь зелёная
[rc=0]

$ bash scripts/check_provodka.sh . contracts/185-pre-judge-proektnyj-rezhim.md
[rc=0; stdout/stderr пусты]

$ bash scripts/check_threat_model.sh . contracts/185-pre-judge-proektnyj-rezhim.md
модель угроз: секция валидна (ЗАЩИЩАЕТ 2 буллет(ов), НЕ ЗАЩИЩАЕТ 2 буллет(ов))
[rc=0]

$ bash scripts/check_precision_gate.sh . contracts/185-pre-judge-proektnyj-rezhim.md
OK
[rc=0]

$ bash scripts/check_spec_ready.sh . contracts/185-pre-judge-proektnyj-rezhim.md
OK
[rc=0]

$ bash scripts/check_project_sources.sh --repo . --contract contracts/185-pre-judge-proektnyj-rezhim.md --stage done
[rc=0; stdout/stderr пусты]
```

```text
$ python3 fixtures/workshop_project/pre_judge_leak_185/probe.py --repo
185 clean ZELENO rc=0 stdout='OBJECT=4977cb396c4cb3c12639c4af9ee6fc048a94470f\nSOSTOJANIE=/tmp/pre-judge-185-48ob2o7o/state\n' stderr=''
185 dirty ZELENO rc=1 stdout='' stderr='ОТКАЗ: основной чекаут загрязнён: tracked.txt\nОТКАЗ: CHECK_NO_LEAK_KRASEN\nscripts/check_no_leak.sh --check /tmp/pre-judge-185-lpo44qum/project вернул rc=1\n'
185 local_fake KRASNO rc=0 stdout='OBJECT=96eed2f9475ff5836276a62534aa01d186c6cd41\nSOSTOJANIE=/tmp/pre-judge-185-8ylmzjwz/state\n' stderr=''
185 missing_harness KRASNO rc=2 stdout='' stderr='NOT_IMPLEMENTED: нет детектора утечки: scripts/check_no_leak.sh\n'
185 missing_harness_local_fake KRASNO rc=0 stdout='OBJECT=96eed2f9475ff5836276a62534aa01d186c6cd41\nSOSTOJANIE=/tmp/pre-judge-185-ofleudj4/state\n' stderr=''
[rc=1; ожидаемо на ещё не реализованном `scripts/pre_judge.sh`]

$ python3 fixtures/workshop_project/pre_judge_leak_185/probe.py --model
185 clean ZELENO rc=0 stdout='OBJECT=4977cb396c4cb3c12639c4af9ee6fc048a94470f\nSOSTOJANIE=/tmp/pre-judge-185-l4t5eh3j/state\n' stderr=''
185 dirty ZELENO rc=1 stdout='' stderr='ОТКАЗ: основной чекаут загрязнён: tracked.txt\nОТКАЗ: CHECK_NO_LEAK_KRASEN\nscripts/check_no_leak.sh --check /tmp/pre-judge-185-j9a3k9ml/project вернул rc=1\n'
185 local_fake ZELENO rc=1 stdout='' stderr='ОТКАЗ: основной чекаут загрязнён: tracked.txt, scripts/check_no_leak.sh\nОТКАЗ: CHECK_NO_LEAK_KRASEN\nscripts/check_no_leak.sh --check /tmp/pre-judge-185-3vmhvf78/project вернул rc=1\n'
185 missing_harness ZELENO rc=2 stdout='' stderr='NOT_IMPLEMENTED: нет детектора утечки харнесса: scripts/check_no_leak.sh\n'
185 missing_harness_local_fake ZELENO rc=2 stdout='' stderr='NOT_IMPLEMENTED: нет детектора утечки харнесса: scripts/check_no_leak.sh\n'
[rc=0]

$ python3 fixtures/workshop_project/pre_judge_leak_185/probe.py --stabs
185 control_no_call ZELENO rc=1 stdout='' stderr='ОТКАЗ: основной чекаут загрязнён: tracked.txt\nОТКАЗ: CHECK_NO_LEAK_KRASEN\nscripts/check_no_leak.sh --check /tmp/pre-judge-185-upg27kgq/project вернул rc=1\n'
185 mutant_no_call KRASNO rc=0 stdout='OBJECT=4977cb396c4cb3c12639c4af9ee6fc048a94470f\nSOSTOJANIE=/tmp/pre-judge-185-v5tbbn2v/state\n' stderr=''
185 STAB no_call caught
185 control_ignore_rc ZELENO rc=1 stdout='' stderr='ОТКАЗ: основной чекаут загрязнён: tracked.txt\nОТКАЗ: CHECK_NO_LEAK_KRASEN\nscripts/check_no_leak.sh --check /tmp/pre-judge-185-ees5yk83/project вернул rc=1\n'
185 mutant_ignore_rc KRASNO rc=0 stdout='OBJECT=96eed2f9475ff5836276a62534aa01d186c6cd41\nSOSTOJANIE=/tmp/pre-judge-185-fi3xr9tf/state\n' stderr=''
185 STAB ignore_rc caught
185 control_copy_in_project ZELENO rc=1 stdout='' stderr='ОТКАЗ: основной чекаут загрязнён: tracked.txt, scripts/check_no_leak.sh\nОТКАЗ: CHECK_NO_LEAK_KRASEN\nscripts/check_no_leak.sh --check /tmp/pre-judge-185-h54f1kg0/project вернул rc=1\n'
185 mutant_copy_in_project KRASNO rc=0 stdout='OBJECT=bd102160706adcbf4170f24f302965ff19f8b81f\nSOSTOJANIE=/tmp/pre-judge-185-d_34armj/state\n' stderr=''
185 STAB copy_in_project caught
185 control_wrong_root ZELENO rc=1 stdout='' stderr='ОТКАЗ: основной чекаут загрязнён: tracked.txt\nОТКАЗ: CHECK_NO_LEAK_KRASEN\nscripts/check_no_leak.sh --check /tmp/pre-judge-185-w82p6ecp/project вернул rc=1\n'
185 mutant_wrong_root KRASNO rc=0 stdout='OBJECT=bd102160706adcbf4170f24f302965ff19f8b81f\nSOSTOJANIE=/tmp/pre-judge-185-wv9xbmm/state\n' stderr=''
185 STAB wrong_root caught
185 control_red_as_green ZELENO rc=1 stdout='' stderr='ОТКАЗ: основной чекаут загрязнён: tracked.txt\nОТКАЗ: CHECK_NO_LEAK_KRASEN\nscripts/check_no_leak.sh --check /tmp/pre-judge-185-59mgepm2/project вернул rc=1\n'
185 mutant_red_as_green KRASNO rc=0 stdout='OBJECT=4db91891a2c71732434f8c6a337b6939cb1bb6a2\nSOSTOJANIE=/tmp/pre-judge-185-77xq3dho/state\n' stderr=''
185 STAB red_as_green caught
185 control_missing_as_green ZELENO rc=2 stdout='' stderr='NOT_IMPLEMENTED: нет детектора утечки харнесса: scripts/check_no_leak.sh\n'
185 mutant_missing_as_green KRASNO rc=0 stdout='OBJECT=4db91891a2c71732434f8c6a337b6939cb1bb6a2\nSOSTOJANIE=/tmp/pre-judge-185-5xbebmn6/state\n' stderr=''
185 STAB missing_as_green caught
185 control_fallback_to_local ZELENO rc=2 stdout='' stderr='NOT_IMPLEMENTED: нет детектора утечки харнесса: scripts/check_no_leak.sh\n'
185 mutant_fallback_to_local KRASNO rc=0 stdout='OBJECT=4db91891a2c71732434f8c6a337b6939cb1bb6a2\nSOSTOJANIE=/tmp/pre-judge-185-d651jk45/state\n' stderr=''
185 STAB fallback_to_local caught
[rc=0]

$ python3 -c 'import importlib.util,sys; from pathlib import Path; f=Path("fixtures/workshop_project/pre_judge_leak_185/probe.py"); s=importlib.util.spec_from_file_location("probe185",f); p=importlib.util.module_from_spec(s); s.loader.exec_module(p); honest=p.source("--model"); old="[ -f \"$DETECTOR\" ] || skip \"нет детектора утечки харнесса: scripts/check_no_leak.sh\""; new="[ -f \"$DETECTOR\" ] || { [ -f \"$R/scripts/check_no_leak.sh\" ] && DETECTOR=\"$R/scripts/check_no_leak.sh\"; }\n  [ -f \"$DETECTOR\" ] || skip \"нет детектора утечки харнесса: scripts/check_no_leak.sh\""; mutant=p.substitute(honest,old,new); sys.exit(0 if not p.check("critic_inline_fallback",mutant,"missing_harness_local_fake") else 1)'
185 critic_inline_fallback KRASNO rc=0 stdout='OBJECT=d74d581f9cca3e10f8571654f6f2b5597282a0b5\nSOSTOJANIE=/tmp/pre-judge-185-8jehy_l1/state\n' stderr=''
[rc=0; mutation caught]
```

```text
$ (cd /tmp && python3 /tmp/dev-harness-verify/Crit185v3/repo/fixtures/workshop_project/pre_judge_leak_185/probe.py --model)
185 clean ZELENO rc=0 stdout='OBJECT=31864642b83457c3f65b705ffef72f05c8f19ec7\nSOSTOJANIE=/tmp/pre-judge-185-8k3bqjna/state\n' stderr=''
185 dirty ZELENO rc=1 stdout='' stderr='ОТКАЗ: основной чекаут загрязнён: tracked.txt\nОТКАЗ: CHECK_NO_LEAK_KRASEN\nscripts/check_no_leak.sh --check /tmp/pre-judge-185-1lfkma6q/project вернул rc=1\n'
185 local_fake ZELENO rc=1 stdout='' stderr='ОТКАЗ: основной чекаут загрязнён: tracked.txt, scripts/check_no_leak.sh\nОТКАЗ: CHECK_NO_LEAK_KRASEN\nscripts/check_no_leak.sh --check /tmp/pre-judge-185-kximw3j8/project вернул rc=1\n'
185 missing_harness ZELENO rc=2 stdout='' stderr='NOT_IMPLEMENTED: нет детектора утечки харнесса: scripts/check_no_leak.sh\n'
185 missing_harness_local_fake ZELENO rc=2 stdout='' stderr='NOT_IMPLEMENTED: нет детектора утечки харнесса: scripts/check_no_leak.sh\n'
[rc=0]

$ bash fixtures/dver_pered_kritikom/predverie_172/red_predverie_172.sh
published ok (rc=0)
prepare_no_state ok (rc=1)
missing_origin ok (rc=1)
stale_origin ok (rc=1)
state_inside ok (rc=1)
manifest_wait ok (rc=1)
leak_reject ok (rc=1)
ff_sync ok (rc=0)
nonff_sync ok (rc=1)
judge_verdict ok (rc=0)
verdict_no_file ok (rc=1)
nonjudge_verdict ok (rc=1)
staged_main_verdict ok (rc=1)
committed_main_verdict ok (rc=1)
archive_free ok (rc=0)
archive_attached ok (rc=1)
published ok (rc=0)
prepare_no_state ok (rc=1)
missing_origin ok (rc=1)
stale_origin ok (rc=1)
state_inside ok (rc=1)
manifest_wait ok (rc=1)
leak_reject ok (rc=1)
ff_sync ok (rc=0)
nonff_sync ok (rc=1)
judge_verdict ok (rc=0)
verdict_no_file ok (rc=1)
nonjudge_verdict ok (rc=1)
staged_main_verdict ok (rc=1)
committed_main_verdict ok (rc=1)
archive_free ok (rc=0)
archive_attached ok (rc=1)
STAB stale_origin caught on stale_origin
STAB allow_incomplete_prepare caught on prepare_no_state
STAB state_inside caught on state_inside
STAB ignore_manifest caught on manifest_wait
STAB ignore_leak caught on leak_reject
STAB allow_nonff caught on nonff_sync
STAB ref_only_ff caught on ff_sync
STAB allow_main_verdict caught on staged_main_verdict
STAB allow_main_verdict caught on committed_main_verdict
STAB allow_incomplete_verdict caught on verdict_no_file
STAB allow_nonjudge_verdict caught on nonjudge_verdict
STAB allow_archive_worktree caught on archive_attached
[rc=0]
```

Вердикт: `accept`. Обе причины предыдущего FAIL закрыты исполнимыми проверками; дельта явно сохраняет rc 2 при отсутствии детектора установки, rc 1 `CHECK_NO_LEAK_KRASEN` при красном проектном корне и корень `R` для вызова установленного детектора. Блокирующих находок по scoped-повтору нет.
