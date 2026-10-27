accept
OBJECT=ec459197313f1891cf27b5e13d3ed9a3821a7a10
СУД: repo=dev-harness; предмет=109 (v5); фаза=контракт; роль=critic-sol; вызов=2/2; модель-план=openai-codex/gpt-6-sol; сессия=Critic109g; модель-факт=openai-codex/gpt-6-sol; SHA=ec459197313f1891cf27b5e13d3ed9a3821a7a10; предыдущий=critic 109 v5 вызов 1/2 FAIL (`verdicts/critic/contracts-109-v5-krug1.md`, OBJECT=f6bd9d2a48fef4683a81f47d192264867a9a070c); исключение=нет. Автор Architect109v5/b/c — zai/glm-5.3, независимость сохранена. `git cat-file -t OBJECT` → `commit`, rc 0; checkout HEAD = OBJECT. Коммит/пуш вердикта запрещены заданием, файл оставлен только в выделенном каталоге.

## БЛОКИРУЕТ

Нет. Причина FAIL 1/2 закрыта на исходном env: `LANE_TAG_RE = re.compile(r'frozen/contracts/109/([1-9][0-9]*)\Z')`, затем `.fullmatch(raw)` без `.strip()`; отсутствует/ровно пустое → ABSENT, прочая неправильная форма → FORM. Срез теперь содержит 11 новых forma-клеток и стаб возврата `.strip()` с тремя привязками. `ЗОНА architect` — контракт и stend_109; `ЗОНА implementer` — названные продуктовые пути, включая `.github/workflows/ci.yml`, `FILES.sha256` и `tests/tools/run_backend_ci.py`; класс риска «рисковый — права/роли БД» сохранён. Инварианты 1–8, 10 и ранее судившиеся зоны не ослаблены новой дельтой (только пять файлов контракта и stend_109 в новом commit поверх прежнего, помимо уже присутствующих независимых вердиктов других ролей). §НЕ ЗАЩИЩАЕТ признаёт доверенность CI env, пробный branch-vs-tag-object и отсутствие docker/N-матрицы в локальном замере.

## СОВЕТ

СОВЕТ contracts/109-cmp-bck-004-stend-evidence.md:237 — п.9 §Замер v5 всё ещё в будущем времени («делает ОРКЕСТРАТОР», «живая мера НОВОЙ пробы отсутствует»), хотя до этого суда выполнен run **40538676854**, job **122310866931**, новый probe SHA совпал с OBJECT. Зафиксировать исполненный прогон и честные ограничения в следующей редакционной записи, если исторический замер требуется хранить в самом контракте. Само доказательство не отсутствует: внешний CI API и лог реально проверены; это неточность прозы замера, не недостаточность приёмки и не новый блокер.
СОВЕТ contracts/109-cmp-bck-004-stend-evidence.md:237 — живой прогон выполнен на ветке-кандидате и N=14, а не на настоящем аннотированном frozen-теге и не на N=15 ветки 007. Эти границы уже объявлены в §НЕ ЗАЩИЩАЕТ и п.8 замера; будущую фиксацию п.9 не расширять до неизмеренного.

## Проверенные источники и живой прогон

`git fetch https://github.com/a3ka/dev-harness.git 53b5b7548963c4bb3085e04ffa8918b8eb25761a` → rc 0; `git show 53b5b754:fixtures/workshop_project/stend_109/probe.py | sha256sum` и `sha256sum` пробы OBJECT → оба `d910bb2abf7a564f645e9b1e6c6a9eaf5c4cda4fccfb7be1dded5380d2fa2bfa`; `git diff --name-status 53b5b754 OBJECT -- contracts/109-cmp-bck-004-stend-evidence.md fixtures/workshop_project/stend_109/` → пусто. То есть пробный dev-harness содержит байты предмета OBJECT, не старую пробу `5eb3577b…`.

`gh api repos/a3ka/Complior-back/actions/runs/40538676854/jobs --jq '.jobs[] | [.id,.name,.conclusion,.runner_name] | @tsv'` → rc 0, девять jobs `success`, в том числе `122310866931 stend109 (...) success station-back-2`. Лог `/tmp/dev-harness-verify/orch/stend109-live-122310866931.log`: `Run git clone --depth=1 --branch "$STEND109_TAG" ...`, `STEND109_TAG: frozen/contracts/109/5` и на клоне, и на `Run python3 tests/tools/run_backend_ci.py --lane stend109 --out evidence/ci/stend109`; `[stend109] PASS rc=0 проба стенда 109 (контроль + 15 фактов + 53 клетки REJECTED_EXACT) (454.1 с)`; `итог: все lanes success`; артефакт evidence НЕ читан, 53 — строка раннера, не независимый счёт кейсов 57. Живая lane исполнилась с docker на одном дереве trial, не доказала всю N-матрицу, настоящий tag-object, будущий freeze или ветку N=15. Лог Actions показывает checkout merge-коммита `afcc20f3` PR #268, родитель trial `5ddb62b14`.

`git fetch https://github.com/a3ka/Complior-back.git 5ddb62b14aa0b971a27b171f0564f05d96baf153` → rc 0. Trial `.github/workflows/ci.yml` `STEND109_TAG: frozen/contracts/109/5` на `jobs.stend109.env` (стр.184–185), шаг клона стр.198–201 и шаг lane стр.202; `tests/tools/run_backend_ci.py:56` `STEND109_PIN = '53b5b7548963c4bb3085e04ffa8918b8eb25761a'` и дефолт того же тега стр.391. `sha256sum ci_job_env.yml` и `sha256sum` trial ci.yml → оба `4caa93bd8ea155fa2a636755c165fd29524bbc28f07d476d270b469a9b15fa5f`; `ci_shag_env.yml` и `git show 0d1df14:.github/workflows/ci.yml | sha256sum` → оба `c489941b876142410d84674280d4deeb4fe66b1fe0e99732072e01d351dc351b`. Предпосылка main-ветки продукта — шаговый env вместо job-level; зависимость implementer объявлена, поэтому её красная клетка не блокирует заморозку харнесса.

## Команды среза на OBJECT, сырой решающий вывод

На локальных read-only копиях Complior-back `back-main` @ `0d1df14` (N=14) и `back-007` @ `c381c3d` (N=15); зависимости node_modules предоставлены симлинком из уже установленной станции, `docker` не запускался. Первый диагностический `W --model` без node_modules дал rc 1, четыре `mir-*:delivery-tokem KRASNO ... node_modules/pg отсутствует`; после предоставления зависимостей — ниже реальные контролируемые прогоны, не приписываем диагностике успех.

```
$ bash fixtures/workshop_project/stend_109/red_migracii_109.sh --model --base /tmp/dev-harness-verify/Critic109g/back-main    # три раздельных прогона
forma:vedushij-probel                        ok
forma:zamykayushij-probel                    ok
forma:tab                                    ok
forma:perevod-stroki                         ok
forma:vozvrat-karetki                        ok
forma:crlf-v-kontse                          ok
forma:tolko-probely                          ok
forma:nol-v-nachale                          ok
ci:job-env                                   ok
ci:shag-env                                  ok
клеток 62, красных 0
rc=0 (каждый из трёх прогонов)
$ bash fixtures/workshop_project/stend_109/red_migracii_109.sh --model --base /tmp/dev-harness-verify/Critic109g/back-007
клеток 69, красных 0
rc=0
$ bash fixtures/workshop_project/stend_109/red_migracii_109.sh --stabs --base /tmp/dev-harness-verify/Critic109g/back-main
stab s-strip-pered-formoj @ forma:vedushij-probel ok
stab s-strip-pered-formoj @ forma:zamykayushij-probel ok
stab s-strip-pered-formoj @ forma:perevod-stroki ok
стабов 9, привязок 13, непойманных 0
клеток 75, красных 0
rc=0
$ bash fixtures/workshop_project/stend_109/red_migracii_109.sh --repo /tmp/dev-harness-verify/Critic109g/back-main
живой манифест /tmp/dev-harness-verify/Critic109g/back-main: N=14
полный CLI-прогон (PATH без docker): rc=1, отчёт=читается, красных фактов 0, красный контроль пуст
ci:zhivoj                                    KRASNO v=shag note=STEND109_TAG вне jobs.stend109.env (строка 195: уровень шага steps.* либо неблочная форма) — шаг lane env не наследует — ПРЕДПОСЫЛКА: env на уровень jobs.stend109 (зона implementer)
клеток 63, красных 1
rc=1
```

Свои самостоятельные формы на tag4 checkout (его `HEAD = rev-parse frozen/contracts/109/4^{commit} = e8001e8d...`): `$ python3 tag_attack.py`, rc 0, реальные строки:
```
None: 'STEND109_TAG_ABSENT'; OK
'': 'STEND109_TAG_ABSENT'; OK
' ': 'STEND109_TAG_FORM'; OK
'frozen/contracts/109/4': 'frozen/contracts/109/4'; OK
'frozen/contracts/109/4 ': 'STEND109_TAG_FORM'; OK
' frozen/contracts/109/4': 'STEND109_TAG_FORM'; OK
'frozen/contracts/109/4\t': 'STEND109_TAG_FORM'; OK
'frozen/contracts/109/4\r\n': 'STEND109_TAG_FORM'; OK
'frozen/contracts/109/04': 'STEND109_TAG_FORM'; OK
'frozen/contracts/109/４': 'STEND109_TAG_FORM'; OK
'frozen/contracts/109/4\u200b': 'STEND109_TAG_FORM'; OK
'Frozen/contracts/109/4': 'STEND109_TAG_FORM'; OK
'frozen/contracts/109/%34': 'STEND109_TAG_FORM'; OK
'frozen/contracts/109/4/../3': 'STEND109_TAG_FORM'; OK
```
`os.environ['STEND109_TAG']='...\x00'` Python отклонил до вызова субъекта (`ValueError: embedded null byte`, rc 1), это недостижимый env в ОС, не непойманный обход; `LANE_TAG_RE.fullmatch('frozen/contracts/109/4\x00')` → `None`, rc 0. `[0-9]` исключает Unicode fullwidth `４` (вместо `\d`).

Собственные обманные мутации только в копиях `stend_109`, `$ python3 mutate109.py` → rc 0; его дочерние `W --model --base back-main` дословно напечатали:
```
lstrip env: forma:vedushij-probel                        KRASNO v=None note=NEEDS_ENV: docker недоступен — замороженная батарея на чистом H требует EGRESS_GUARD, lane
lstrip env: forma:tolko-probely                          KRASNO v=None note=STEND109_TAG_ABSENT: STEND109_TAG не задан (пуст) в окружении — CI продукта обязан объявит
lstrip env: клеток 62, красных 2; rc=1
rstrip env: forma:zamykayushij-probel                    KRASNO v=None note=NEEDS_ENV: docker недоступен — замороженная батарея на чистом H требует EGRESS_GUARD, lane
rstrip env: forma:tab                                    KRASNO v=None note=NEEDS_ENV: docker недоступен — замороженная батарея на чистом H требует EGRESS_GUARD, lane
rstrip env: forma:perevod-stroki                         KRASNO v=None note=NEEDS_ENV: docker недоступен — замороженная батарея на чистом H требует EGRESS_GUARD, lane
rstrip env: forma:vozvrat-karetki                        KRASNO v=None note=NEEDS_ENV: docker недоступен — замороженная батарея на чистом H требует EGRESS_GUARD, lane
rstrip env: forma:crlf-v-kontse                          KRASNO v=None note=NEEDS_ENV: docker недоступен — замороженная батарея на чистом H требует EGRESS_GUARD, lane
rstrip env: forma:tolko-probely                          KRASNO v=None note=STEND109_TAG_ABSENT: STEND109_TAG не задан (пуст) в окружении — CI продукта обязан объявит
rstrip env: клеток 62, красных 6; rc=1
model/manifest.json + newline: 109 SEZ: ORACLE_TAMPERED: пин model/manifest.json f125f6729724 != байтам eb129afc8f7d; rc=2
ci_nositeli/ci_job_env.yml + newline: 109 SEZ: ORACLE_TAMPERED: пин ci_nositeli/ci_job_env.yml 4caa93bd8ea1 != байтам 510bacae1d04; rc=2
source.json stab_vhod rename: 109 SEZ: ORACLE_TAMPERED: рассинхрон stab_vhod: source.json ['s-forma-ne-proverjaetsja', 's-konstanta-14', 's-konstanta-tega', 's-manifest-iz-fikstury', 's-ozhidanie-iz-fajlov', 's-pustoj-env-umolchanie', 's-pustoj-prinjat', 's-strip-pered-formoj-DELETED', 's-teg-bez-sverki-s-golovoj'] != коду ['s-forma-ne-proverjaetsja', 's-konstanta-14', 's-konstanta-tega', 's-manifest-iz-fikstury', 's-ozhidanie-iz-fajlov', 's-pustoj-env-umolchanie', 's-pustoj-prinjat', 's-strip-pered-formoj', 's-teg-bez-sverki-s-golovoj']; rc=2
source.json ci digest zero: 109 SEZ: ORACLE_TAMPERED: пин ci_nositeli/ci_job_env.yml 000000000000 != байтам 4caa93bd8ea1; rc=2
```
По коду `STABY`/`TEG_VHODY`/`TEG_OZHID` и `source.json:stab_vhod` совпадают все 9 имён и 13 привязок: новый s-strip действительно восстанавливает доформенное срезание `.strip()`, судится на переднем/заднем пробеле и переводе строки; прежние пять tag-стабов и четыре ledger-стаба остались пойманы. Своё `lstrip`/`rstrip` прогонял через отдельные копии кода, не только вызовом резолвера.

Гейты на OBJECT (команды последовательно из клона):
```
$ bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Critic109g/repo contracts/109-cmp-bck-004-stend-evidence.md
OK
rc=0
$ bash scripts/check_provodka.sh /tmp/dev-harness-verify/Critic109g/repo contracts/109-cmp-bck-004-stend-evidence.md
[пустой stdout]
rc=0
$ bash scripts/check_threat_model.sh /tmp/dev-harness-verify/Critic109g/repo contracts/109-cmp-bck-004-stend-evidence.md
модель угроз: секция валидна (ЗАЩИЩАЕТ 11 буллет(ов), НЕ ЗАЩИЩАЕТ 9 буллет(ов))
rc=0
$ bash scripts/check_spec_ready.sh /tmp/dev-harness-verify/Critic109g/repo contracts/109-cmp-bck-004-stend-evidence.md
[15 ZONE_MOVE_EXEMPT для внешнего продуктового репо]
OK
rc=0
$ bash scripts/check_ceilings.sh /tmp/dev-harness-verify/Critic109g/repo
потолки в порядке
rc=0
$ bash scripts/pre_critic.sh --repo /tmp/dev-harness-verify/Critic109g/repo contracts/109-cmp-bck-004-stend-evidence.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=3
КРИТИК: дверь зелёная
rc=0
```
Первый параллельный запуск `check_precision_gate` вместе с другими гейтами написал `lib_zones.sh ... /tmp/lib_zones.<id>/zones_scoped: No such file or directory`, при этом вернул rc 0; последовательный повтор дал `OK` rc 0, `check_provodka` повторён последовательно rc 0. Эти сообщения гонки не трактуются доказательством дефекта предмета.
