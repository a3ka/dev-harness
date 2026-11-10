FAIL
OBJECT=73e52a740ab5d0846b26980387a5a6c656ba7606
СУД: repo=dev-harness; предмет=185; фаза=контракт; роль=critic; вызов=1/2; модель-план=zai/glm-5.3; сессия=Crit185v1; модель-факт=openai-codex/gpt-5.6-terra (разрешённый autoFallback @gpt-terra); SHA=73e52a740ab5d0846b26980387a5a6c656ba7606; предыдущий=нет; исключение=нет.

# Вердикт критика — контракт 185 «pre_judge.sh в проектном режиме: детектор харнесса к корню проекта», полный вызов 1

## Предмет, независимость и полнота набора

Объект подтверждён в отдельном одноразовом SSH-клоне: `git rev-parse HEAD` дал `73e52a740ab5d0846b26980387a5a6c656ba7606` (rc 0), ровно OBJECT задания. `git show --format=fuller --stat --summary HEAD` показал автора `architect <architect@dev-harness.local>` и только три пути кандидата: контракт, `.probe-only` и `fixtures/workshop_project/pre_judge_leak_185/probe.py`; реализации предмета кандидат не меняет. Судья — отдельная сессия `Crit185v1`, собственную работу не судит. План роли — `zai/glm-5.3` (`config/agent_models.json:59-63,94`), факт сессии — `openai-codex/gpt-5.6-terra`, допустимый autoFallback `@gpt-terra` этого tier.

Набор не является неполным: закоммичены предмет, rc-критерии, класс риска и шесть `ЗОНА`-строк. Авторская дельта лежит в `ЗОНА architect`; зона реализации `scripts/pre_judge.sh` совпадает с frozen-172 зоной, а пересечение 172 явно объявлено в `contracts/185-pre-judge-proektnyj-rezhim.md:44`. `bash scripts/check_zones.sh .` завершился rc 0: `замороженных контрактов: 163 · объявленных авторов: 5 · коммитов в диапазонах: 52082 · проверено по зонам: 13696`.

## Блокирующие находки

БЛОКИРУЕТ contracts/185-pre-judge-proektnyj-rezhim.md:23 — контракт вводит guard для чужого проектного корня, но обязательная модель угроз имеет недействительную грамматику: обе метки помещены в начало буллетов, а не являются отдельными literal-строками со следующими за ними буллетами.
ОБЯЗАТЕЛЬСТВО: `roles/critic.md:214` требует для такого контракта секцию `## Модель угроз` со списками `ЗАЩИЩАЕТ:`/`НЕ ЗАЩИЩАЕТ:` и минимум одним буллетом в каждом; нарушение действующей нормы блокирует.
КЛАСС ПРИЧИНЫ: форма обязательной модели угроз не соответствует единственному механическому читателю.
СОСТОЯНИЕ: в строке 23 стоят `- ЗАЩИЩАЕТ: ...` и `- НЕ ЗАЩИЩАЕТ: ...`, тогда как `scripts/check_threat_model.sh` ищет побайтово равные отдельные строки меток.
НАБЛЮДЕНИЕ: `bash scripts/check_threat_model.sh . contracts/185-pre-judge-proektnyj-rezhim.md` завершился rc 1 с дословным выводом `модель угроз: список ЗАЩИЩАЕТ: отсутствует`.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: форма секции проходит названную команду с rc 0, а каждая из двух literal-меток имеет непосредственно следующий буллет.

БЛОКИРУЕТ contracts/185-pre-judge-proektnyj-rezhim.md:15,17,29-30 — приёмка ложно достаточна для обязательства «всегда детектор установки; локальный детектор не участвует; отсутствие установочного даёт rc 2». Она не предъявляет достижимую комбинацию отсутствующего детектора установки и локального `R/scripts/check_no_leak.sh` с `exit 0`.
ОБХОД: заменив существующую операцию отказа из модели `fixtures/workshop_project/pre_judge_leak_185/probe.py:19`, `[ -f "$DETECTOR" ] || skip ...`, на fallback `DETECTOR="$R/scripts/check_no_leak.sh"` с последующей прежней проверкой существования, дверь принимает проектный поддельный детектор после удаления установочного. Обязательные `--model` и `--stabs` остаются зелёными: `probe.py:76-82` создаёт local_fake только для `local_fake`, а удаляет harness-detector только для `missing_harness`; варианты взаимно исключены.
ОБЯЗАТЕЛЬСТВО: предмет в строках 15 и 17 выбирает вариант (а) «всегда детектор установки к R», запрещает участие локального детектора даже при наличии и требует отказ, а приёмка в строках 29-30 требует `CHECK_NO_LEAK_KRASEN` для fake и rc 2/пустой stdout при отсутствии установки.
КЛАСС ПРИЧИНЫ: красная батарея не различает отсутствие доверенного детектора с присутствующей локальной подменой и fallback к этой подмене.
СОСТОЯНИЕ: это поддерживаемый `prepare --repo R` на независимых Git-деревьях, прямо составленный из явно предъявленных контрактом входов: local_fake (строка 29) и missing_harness (строка 30). До вызова снят настоящий снимок; затем в R добавлен локальный `scripts/check_no_leak.sh` с `exit 0`, а `<установка>/scripts/check_no_leak.sh` удалён.
ИСТОЧНИК ОШИБОЧНОГО МЕХАНИЗМА: существующая предметная операция в модели — отказ `[ -f "$DETECTOR" ] || skip "нет детектора утечки харнесса: scripts/check_no_leak.sh"` (`probe.py:19`). Мутация заменяет именно этот уже имеющийся отказ fallback-выбором `$R/scripts/check_no_leak.sh`, не добавляет постороннюю ветвь.
НАБЛЮДЕНИЕ: честная модель на том же входе вернула rc 2 и пустой stdout; мутант вернул rc 0, `OBJECT` и `SOSTOJANIE`, то есть фиктивно допустил судью. Сырой вывод и команда ниже.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: обязательная пробы/стабы предъявляют вход одновременно с отсутствующим установочным детектором и локальным `exit 0`; честная модель и реализация обязаны дать rc 2 с пустым stdout, а описанная замена существующей операции — красный результат пробы.

```text
$ python3 -c 'import importlib.util,tempfile; from pathlib import Path; f=Path("fixtures/workshop_project/pre_judge_leak_185/probe.py"); s=importlib.util.spec_from_file_location("probe185", f); p=importlib.util.module_from_spec(s); s.loader.exec_module(p); honest=p.source("--model"); old="[ -f \"$DETECTOR\" ] || skip \"нет детектора утечки харнесса: scripts/check_no_leak.sh\""; new="[ -f \"$DETECTOR\" ] || DETECTOR=\"$R/scripts/check_no_leak.sh\"\n  [ -f \"$DETECTOR\" ] || skip \"нет детектора утечки харнесса: scripts/check_no_leak.sh\""; mutant=p.substitute(honest, old, new); tc=tempfile.TemporaryDirectory(prefix="critic185-control-"); wc=p.World(Path(tc.name), honest); (wc.project / "scripts").mkdir(); (wc.project / "scripts/check_no_leak.sh").write_text("#!/bin/sh\nexit 0\n", encoding="utf-8"); wc.detector.unlink(); gc=wc.invoke(); print(f"185 control_harness_missing_with_local_fake rc={gc.returncode} stdout={gc.stdout!r} stderr={gc.stderr!r}", flush=True); tm=tempfile.TemporaryDirectory(prefix="critic185-mutant-"); wm=p.World(Path(tm.name), mutant); (wm.project / "scripts").mkdir(); (wm.project / "scripts/check_no_leak.sh").write_text("#!/bin/sh\nexit 0\n", encoding="utf-8"); wm.detector.unlink(); gm=wm.invoke(); print(f"185 mutant_fallback_to_local rc={gm.returncode} stdout={gm.stdout!r} stderr={gm.stderr!r}", flush=True); assert gc.returncode == 2 and gc.stdout == "" and gc.stderr.startswith("NOT_IMPLEMENTED: нет детектора утечки харнесса:"); assert gm.returncode == 0 and gm.stdout.startswith("OBJECT=") and "SOSTOJANIE=" in gm.stdout and gm.stderr == ""; tc.cleanup(); tm.cleanup()'
185 control_harness_missing_with_local_fake rc=2 stdout='' stderr='NOT_IMPLEMENTED: нет детектора утечки харнесса: scripts/check_no_leak.sh\n'
185 mutant_fallback_to_local rc=0 stdout='OBJECT=9ca5b3e2fdb460e67e105114e1e18fad074b22c8\nSOSTOJANIE=/tmp/critic185-mutant-2zf_l66m/state\n' stderr=''
[rc=0]
```

## Выполненные прогоны

```text
$ bash scripts/pre_critic.sh contracts/185-pre-judge-proektnyj-rezhim.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=1
КРИТИК: дверь зелёная
[rc=0]

$ bash scripts/check_provodka.sh . contracts/185-pre-judge-proektnyj-rezhim.md
[rc=0; stdout/stderr пусты]

$ bash scripts/check_project_sources.sh --repo . --contract contracts/185-pre-judge-proektnyj-rezhim.md --stage done
[rc=0; stdout/stderr пусты]

$ bash scripts/check_precision_gate.sh . contracts/185-pre-judge-proektnyj-rezhim.md
OK
[rc=0]

$ bash scripts/check_threat_model.sh . contracts/185-pre-judge-proektnyj-rezhim.md
модель угроз: список ЗАЩИЩАЕТ: отсутствует
[rc=1]

$ python3 fixtures/workshop_project/pre_judge_leak_185/probe.py --repo
185 clean KRASNO rc=2 stdout='' stderr='NOT_IMPLEMENTED: нет детектора утечки: scripts/check_no_leak.sh\n'
185 dirty KRASNO rc=2 stdout='' stderr='NOT_IMPLEMENTED: нет детектора утечки: scripts/check_no_leak.sh\n'
185 local_fake KRASNO rc=0 stdout='OBJECT=0297584a2100f4b80fd2dacfd5a4feee3e7d73ef\nSOSTOJANIE=/tmp/pre-judge-185-7_wc_n3y/state\n' stderr=''
185 missing_harness KRASNO rc=2 stdout='' stderr='NOT_IMPLEMENTED: нет детектора утечки: scripts/check_no_leak.sh\n'
[rc=1; ожидаемо до реализации]

$ python3 fixtures/workshop_project/pre_judge_leak_185/probe.py --model
185 clean ZELENO rc=0 stdout='OBJECT=833840ceb97469d2d6ee4633f849d78a34156c09\nSOSTOJANIE=/tmp/pre-judge-185-da1mj4xk/state\n' stderr=''
185 dirty ZELENO rc=1 stdout='' stderr='ОТКАЗ: основной чекаут загрязнён: tracked.txt\nОТКАЗ: CHECK_NO_LEAK_KRASEN\nscripts/check_no_leak.sh --check /tmp/pre-judge-185-wsc_o9fy/project вернул rc=1\n'
185 local_fake ZELENO rc=1 stdout='' stderr='ОТКАЗ: основной чекаут загрязнён: tracked.txt, scripts/check_no_leak.sh\nОТКАЗ: CHECK_NO_LEAK_KRASEN\nscripts/check_no_leak.sh --check /tmp/pre-judge-185-bbdh63nv/project вернул rc=1\n'
185 missing_harness ZELENO rc=2 stdout='' stderr='NOT_IMPLEMENTED: нет детектора утечки харнесса: scripts/check_no_leak.sh\n'
[rc=0]

$ python3 fixtures/workshop_project/pre_judge_leak_185/probe.py --stabs
185 control_no_call ZELENO rc=1 stdout='' stderr='ОТКАЗ: основной чекаут загрязнён: tracked.txt\nОТКАЗ: CHECK_NO_LEAK_KRASEN\nscripts/check_no_leak.sh --check /tmp/pre-judge-185-yku20bni/project вернул rc=1\n'
185 mutant_no_call KRASNO rc=0 stdout='OBJECT=0297584a2100f4b80fd2dacfd5a4feee3e7d73ef\nSOSTOJANIE=/tmp/pre-judge-185-ocfebnpy/state\n' stderr=''
185 STAB no_call caught
185 control_ignore_rc ZELENO rc=1 stdout='' stderr='ОТКАЗ: основной чекаут загрязнён: tracked.txt\nОТКАЗ: CHECK_NO_LEAK_KRASEN\nscripts/check_no_leak.sh --check /tmp/pre-judge-185-nobs3we7/project вернул rc=1\n'
185 mutant_ignore_rc KRASNO rc=0 stdout='OBJECT=0297584a2100f4b80fd2dacfd5a4feee3e7d73ef\nSOSTOJANIE=/tmp/pre-judge-185-9vxbus21/state\n' stderr=''
185 STAB ignore_rc caught
185 control_copy_in_project ZELENO rc=1 stdout='' stderr='ОТКАЗ: основной чекаут загрязнён: tracked.txt, scripts/check_no_leak.sh\nОТКАЗ: CHECK_NO_LEAK_KRASEN\nscripts/check_no_leak.sh --check /tmp/pre-judge-185-yqhcbzks/project вернул rc=1\n'
185 mutant_copy_in_project KRASNO rc=0 stdout='OBJECT=3686a4e44b54359bb460ea8317eecc8169c8deaa\nSOSTOJANIE=/tmp/pre-judge-185-b7p172s9/state\n' stderr=''
185 STAB copy_in_project caught
185 control_wrong_root ZELENO rc=1 stdout='' stderr='ОТКАЗ: основной чекаут загрязнён: tracked.txt\nОТКАЗ: CHECK_NO_LEAK_KRASEN\nscripts/check_no_leak.sh --check /tmp/pre-judge-185-nbmah1k5/project вернул rc=1\n'
185 mutant_wrong_root KRASNO rc=0 stdout='OBJECT=375649042622e92fbe06d7deaea4585cdd033f31\nSOSTOJANIE=/tmp/pre-judge-185-pwn9xbmm/state\n' stderr=''
185 STAB wrong_root caught
185 control_red_as_green ZELENO rc=1 stdout='' stderr='ОТКАЗ: основной чекаут загрязнён: tracked.txt\nОТКАЗ: CHECK_NO_LEAK_KRASEN\nscripts/check_no_leak.sh --check /tmp/pre-judge-185-fk0uwuav/project вернул rc=1\n'
185 mutant_red_as_green KRASNO rc=0 stdout='OBJECT=375649042622e92fbe06d7deaea4585cdd033f31\nSOSTOJANIE=/tmp/pre-judge-185-ysl3jkrp/state\n' stderr=''
185 STAB red_as_green caught
185 control_missing_as_green ZELENO rc=2 stdout='' stderr='NOT_IMPLEMENTED: нет детектора утечки харнесса: scripts/check_no_leak.sh\n'
185 mutant_missing_as_green KRASNO rc=0 stdout='OBJECT=6bbc2ed8a6f55c834bab4c750fd6e8be69347459\nSOSTOJANIE=/tmp/pre-judge-185-o_hvlmrb/state\n' stderr=''
185 STAB missing_as_green caught
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

$ (cd /tmp && python3 /tmp/dev-harness-verify/Crit185v1/repo/fixtures/workshop_project/pre_judge_leak_185/probe.py --model)
185 clean ZELENO rc=0 stdout='OBJECT=45c2d69814ee8765125213109761a452c2341d9d\nSOSTOJANIE=/tmp/pre-judge-185-q1owngdi/state\n' stderr=''
185 dirty ZELENO rc=1 stdout='' stderr='ОТКАЗ: основной чекаут загрязнён: tracked.txt\nОТКАЗ: CHECK_NO_LEAK_KRASEN\nscripts/check_no_leak.sh --check /tmp/pre-judge-185-1md790_f/project вернул rc=1\n'
185 local_fake ZELENO rc=1 stdout='' stderr='ОТКАЗ: основной чекаут загрязнён: tracked.txt, scripts/check_no_leak.sh\nОТКАЗ: CHECK_NO_LEAK_KRASEN\nscripts/check_no_leak.sh --check /tmp/pre-judge-185-qurdik0y/project вернул rc=1\n'
185 missing_harness ZELENO rc=2 stdout='' stderr='NOT_IMPLEMENTED: нет детектора утечки харнесса: scripts/check_no_leak.sh\n'
[rc=0]
```

Последний запуск выполнен вне cwd клона; пробы сами создают два независимых Git-дерева, поэтому доказательство не зависит от основного checkout. Замена `$R` на корень установки не использовалась.

## Советы

СОВЕТ contracts/185-pre-judge-proektnyj-rezhim.md:11 — текст утверждает, что Н-441 ещё не записан в `NABLIUDENIA.md`, но в объекте уже есть `NABLIUDENIA.md:8460` с Н-441. Это не ослабляет предмет или его приёмку, но контекст следует синхронизировать.

Вердикт: FAIL — два независимых блокирующих класса: обязательная модель угроз не проходит свой механический формат, а красная батарея пропускает воспроизводимую подмену локальным детектором при отсутствии доверенного. Зелёные `pre_critic`, `check_provodka`, `check_project_sources`, precision-гейт, честная модель, шесть авторских стабов и регресс 172 не отменяют rc 1 нормы и предъявленный обход критерия.
