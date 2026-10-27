FAIL
OBJECT=214aa63055dbc7fa55fd44d3b1f595c73a478552
СУД: repo=dev-harness; предмет=143; фаза=контракт; роль=critic-sol; вызов=2/2; модель-план=openai-codex/gpt-6-sol; сессия=не предоставлена судье (OMP_SESSION_ID отсутствует); модель-факт=openai-codex/gpt-6-sol (workstation); SHA=214aa63055dbc7fa55fd44d3b1f595c73a478552; предыдущий=verdicts/critic/contracts-143-v1-krug1.md FAIL (OBJECT 83b2fe0f21b9d8037e2b56cc02af9f207b89082f); исключение=нет; независимость: автор zai/glm-5.3, судья Sol.

## БЛОКИРУЕТ

БЛОКИРУЕТ contracts/143-mob-ci-razdelenie.md:113-115 — отложенная p01 даёт зелёный exit status, несмотря на прямо объявленную обязательную предпосылку cutover 995/5. Класс причины: ложная достаточность и противоречие AGENTS.md:217-218 (нереализованное → rc 2 NOT_IMPLEMENTED, не 0). `W --model` ×3 возвратил rc0 при «клеток 68, зелёных 67, красных 0 / NEEDS_PRECEDENT 1»; `W --stabs` также rc0 с этим пробелом; движок probe.py:1661-1664 возвращает 0 при пустом массиве красных независимо от отложенных. Это не счётная придирка: если четыре модельных файла перенести в продукт при старом пине `.harness` 66052cdf, 67 проверяемых клеток могут стать зелёными, а неподтверждённый P-каталог останется общей выборкой. Закрывающее свойство: при обязательной, но ещё не исполненной предпосылке общий код выхода НЕ 0 (rc2/NOT_IMPLEMENTED); rc0 только если p01 исполнялась и зелена. Отдельно честно поддерживается диагностический отложенный статус.
ОБХОД: один непроверенный обязательный testcase маркируется NEEDS_PRECEDENT, но команда приёмки и контроль обманных стабов возвращают успех rc0 без подтверждения фиксированного исполняемого набора P. На текущем OBJECT это наблюдалось без всякой мутации.

БЛОКИРУЕТ contracts/143-mob-ci-razdelenie.md:47,120 — W принимает DAG без обязательного `needs: build-apk` у всех пяти workers. Класс причины: ложная достаточность DAG-критерия. В одноразовой копии модели заменил ВСЕ пять `needs: [select-screens, build-apk]` на `needs: [select-screens]`; `W --repo <копия>` → rc0, 68 клеток, 67 зелёных, 0 красных (+ p01 отложена). Выражения `needs.build-apk.outputs.*` остались в работниках, но `build-apk` отсутствует в их контексте `needs`: скачивание точного APK не сможет получить имя и digest; selected worker не способен выполнить заявленную проверку, а батарея зелёная. Это нарушает явное И-3 и И-4 даже без предположения об исходе физического раннера. Закрывающее свойство: красная клетка каждому worker, утратившему ребро build-apk/select-screens; DAG зависимостей проверяется независимо от наличия строк `needs.build-apk.outputs` в теле.
ОБХОД: все пять работников имеют тело digest и job outputs, но ни один не зависит от сборки; батарея печатает `клеток 68, зелёных 67, красных 0` с rc0, а артефакт единственной сборки работниками недоступен по обещанному `needs`.

БЛОКИРУЕТ contracts/143-mob-ci-razdelenie.md:52,115,133-134 — ключ предшественника 995/5 противоречит схеме карты, на которую его обязали опираться. Класс причины: взаимоисключающие нормативные входы на стыке зон 995 и 143. И-8 и подписываемый draft/995-v5-draft.md:44-51 ДВАЖДЫ предписывают P читать `integracija.fikirovannyj_nabor`, а committed модель `model/mobile/ci-screens.json:93`, selector и probe.py:1469 читают `integracija.fiksirovannyj_nabor` (буква `s` после `fik` присутствует только у модели). При буквальном исполнении предписанного 995 v5 карты 143 не имеют обязательного ключа → `SKHEMA_KARTY`, набора P нет; если исполнитель сам догадается исправить draft, это уже не адресная миграция «по ТОЧНОМУ» черновику. Закрывающее свойство: одна и та же точная схема ключа в предшественнике, contract И-8, модели продукта и исполняемой p01, включая отрицательный вход при отсутствующем ключе.
ОБЯЗАТЕЛЬСТВО: P нового H обязан извлечь фиксированный набор из единственной карты 143 и стать зелёным до cutover.
СОСТОЯНИЕ: P 995/5 реализован по draft, карта продукта скопирована из эталонной модели 143.
НАБЛЮДЕНИЕ: требуемое поле `fikirovannyj_nabor` отсутствует; draft требует именной отказ, а не зелёное исполнение P. Грамматическое отличие подтверждено поиском контракт/draft/model/probe.

БЛОКИРУЕТ contracts/143-mob-ci-razdelenie.md:81,114-120,134,150 — прежний блокер 123 формально получил файл, но обязанность иметь адресную миграцию НЕ защищена названной командой. Класс причины: ложная достаточность критерия поставки девяти черновиков. В одноразовой копии всей fixture удалён `drafts/123-v3-draft.md` (123/2 вновь неприменим к e2e-splash); `bash <копия>/red_mob_ci_143.sh --model` → rc0, «клеток 68, зелёных 67, красных 0», p01 отложена. y01 проверяет набор jobs, НЕ наличие и применимость миграции 123/2 критерий 6. На представленном HEAD файл есть и его исходный hunk совпадает с frozen/123/2, однако будущая названная приёмка пропускает дерево БЕЗ него. Закрывающее свойство: автоматический красный исход на отсутствие/неприменимость обязательной миграции 123 или другая явно названная команда с кодом возврата, которая это доказует; коммит файла сам по себе не является доказательством критерия.
ОБХОД: из кандидата исчезает единственный draft, переводящий frozen 123/2 критерий 6 в e2e-splash; 995/141/139 и прочие файлы остаются, W --model rc0, а прежний placement-критерий вновь несовместим с cutover.

АРБИТР: роль arbiter, предмет 143; это исправительный вызов 2/2 с FAIL. Отдельно арбитр разрешает повтор причины p01/995 (может ли отложенная обязательная проверка давать rc0 до предшественника) и 123 (достаточен ли не защищённый машиной draft), а также новые причины ребра DAG и противоречивого ключа карты. Решение арбитра само не подменяет accept и не открывает третий critic-вызов без слова владельца.

## СОВЕТ

СОВЕТ contracts/143-mob-ci-razdelenie.md:134,145 — 117-v5-draft опирается на frozen 117/3, в то время как v4 ещё идёт; оговорка о пересравнении поверх принятой v4 теперь есть, проверить при подписи. ROADMAP.md изменён отдельным process-файлом (`mob-ci-razdelenie` → `143`), но frozen contracts кроме 143 не менялись.

## Сырые исполнения и область

Рабочее дерево судьи: `/tmp/dev-harness-verify/Critic143c/repo`; `git cat-file -t 214aa63055dbc7fa55fd44d3b1f595c73a478552` → `commit` rc0; `git rev-parse HEAD` → тот же SHA rc0. Клон из `/tmp/dev-harness-verify/Architect143/repo`, ни push, ни commit не делались. `git diff 83b2fe0f2..214aa6305 --stat` → 26 файлов, +1966/-56 (9 drafts, 5 новых stabs, обновлённые модель/fixture/contract); `git diff origin/main..HEAD -- contracts/ ':!contracts/143-mob-ci-razdelenie.md'` → пусто; `git diff origin/main..HEAD --stat` → 62 файла +7420/-2 (включая ROADMAP, контракт и fixture). Девять original hunks drafts/111/116/117/118/123/138/139/141/995 совпали с frozen тегами 111/4,116/3,117/3,118/2,123/2,138/1,139/2,141/1,995/4 (диспоузабельный Python `git show` + последовательные context/removal); `^РАЗРЕШИЛ-ВЛАДЕЛЕЦ` по fixture → совпадений нет.

`jq` source.json → cells=68 (s25,a17,y21,f4,p1), stabs=32, links=47, pins=12. `bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh` rc1: `клеток 68, зелёных 0, красных 68 — SUBJECT_ABSENT`, все 68 клеток поимённо красные. `W --model` ×3 rc0 каждый:
```
клеток 68, зелёных 67, красных 0
КЛЕТКА p01-P-nabor: NEEDS_PRECEDENT: 995 v5 — исполняемый набор P ещё rglob (frozen 995/4); место: drafts/995-v5-draft.md, freeze 995/5, перепин .harness модели 143 и носителей p-66052cdf.py/ci-e2e-995-4.sh в source.json ОТЛОЖЕНА
NEEDS_PRECEDENT 1 — клетка не зелёная и не красная, место названо выше
```
`W --stabs` rc0: тот же контроль 67/0+1, `стабов 32, привязок 47, непойманных 0`. Пять структурно новых стабов действительно ловят a17/y19/y20/y21/p01, однако полноценного зелёного p01 нет до 995/5. `W --repo /tmp/dev-harness-verify/Critic143c/mob` на c617f6fb236d11574df75fb09ae41870bf8c29d6 rc1: `клеток 68, зелёных 3, красных 64`, зелёные y04/y05/y06, p01 NEEDS_PRECEDENT 1.

### Адверсарий на одноразовых копиях модели (команда каждой строки: `bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo /tmp/dev-harness-verify/Critic143c/attack-*/subject`; для отсутствующего draft — `bash <копия>/red_mob_ci_143.sh --model`). `attacks.py`/`prior_attacks.py` создавали независимые `tempfile.TemporaryDirectory` и удаляли его после каждой команды. Ни workflows, ни runners, ни эмуляторы не запускались.
```
remove-aggregate-always: rc=1
клеток 68, зелёных 66, красных 1
КЛЕТКА y03-agregat-if-always: if агрегата "(github.event_name == 'pull_request' || github.event_name == 'push' || github.event_name == 'merge_group')" КРАСНА
remove-aggregate-worker: rc=1
клеток 68, зелёных 66, красных 1
КЛЕТКА y02-agregat-needs: needs агрегата ['select-screens', 'quality', 'build-apk', 'e2e-splash', 'e2e-first-run', 'e2e-erstinformation', 'e2e-pilot'] КРАСНА
remove-cron: rc=1
клеток 68, зелёных 66, красных 1
КЛЕТКА y09-sobytija-i-net-139: нет schedule/dispatch КРАСНА
previous-digest-dead-branch (5 workers if false &&): rc=1
клеток 68, зелёных 66, красных 1
КЛЕТКА a17-digest-do-ustanovki: e2e-splash: шаг digest прошёл с подложным APK (rc 0) — проверки до установки нет КРАСНА
previous-id-missing: rc=1
клеток 68, зелёных 65, красных 2
КЛЕТКА y19-outputs-provodka: e2e-start: шаг идентичности без id: ident (GITHUB_OUTPUT без id не попадает в needs) КРАСНА
КЛЕТКА y20-tojson-needs: needs-контекст по семантике ГитХаба красит агрегат: AGREGAT_OTKAZ: APK_DIGEST_RASKHOZHDENIE — e2e-start: нет ≠ 6007250b70d53104fd20618ba8878574a2cfb2cb7f59e4d6c42a0a977a8e27b6 КРАСНА
previous-aggregate-no-checkout: rc=1
клеток 68, зелёных 66, красных 1
КЛЕТКА y19-outputs-provodka: android-e2e: агрегат без checkout (скрипта на чистом раннере нет) КРАСНА
previous-cancel-disabled: rc=1
клеток 68, зелёных 66, красных 1
КЛЕТКА y21-concurrency: cancel-in-progress при pull_request: False ≠ True КРАСНА
previous-P-rglob-after-repin: rc=1
клеток 68, зелёных 67, красных 1
КЛЕТКА p01-P-nabor: Maestro запрошен набор ['cmp-mob-002-tabs.yaml', 'cmp-mob-004-start.yaml', 'erstinformation.yaml', 'first-run-ekran.yaml', 'pilot.yaml', 'rehearsal.yaml', 'start.yaml', 'vkhod-117-splash-vhod.yaml'] — вне фиксированного набора P: лишние ['cmp-mob-004-start.yaml', 'erstinformation.yaml', 'first-run-ekran.yaml', 'vkhod-117-splash-vhod.yaml'], без повторов [], дубли 0 КРАСНА
previous-123-draft-removed: rc=0
клеток 68, зелёных 67, красных 0
КЛЕТКА p01-P-nabor: NEEDS_PRECEDENT: 995 v5 — исполняемый набор P ещё rglob (frozen 995/4); место: drafts/995-v5-draft.md, freeze 995/5, перепин .harness модели 143 и носителей p-66052cdf.py/ci-e2e-995-4.sh в source.json ОТЛОЖЕНА
new-concurrency-push-cancel: rc=1
клеток 68, зелёных 66, красных 1
КЛЕТКА y21-concurrency: cancel-in-progress при pull_request: False ≠ True КРАСНА
new-worker-without-build-dependency (all five): rc=0
клеток 68, зелёных 67, красных 0
КЛЕТКА p01-P-nabor: NEEDS_PRECEDENT: 995 v5 — исполняемый набор P ещё rglob (frozen 995/4); место: drafts/995-v5-draft.md, freeze 995/5, перепин .harness модели 143 и носителей p-66052cdf.py/ci-e2e-995-4.sh в source.json ОТЛОЖЕНА
new-empty-selection-after-error (replace process.exit(1) by [] + rc0): rc=1
клеток 68, зелёных 59, красных 8
КЛЕТКА s03-novyj-pack: rc=0, канон rc=1 (VYBOR_OTKAZ: INVENTAR_KARTY: mobile/e2e-mission/kontrakt.md) КРАСНА
КЛЕТКА s04-novyj-potok: rc=0, канон rc=1 (VYBOR_OTKAZ: INVENTAR_KARTY: mobile/.maestro/mission.yaml) КРАСНА
КЛЕТКА s05-potok-dvoe-vladeltsev: rc=0, канон rc=1 (VYBOR_OTKAZ: INVENTAR_KARTY: поток mobile/.maestro/start.yaml заявлен 2 владельцами: splash,pilot) КРАСНА
КЛЕТКА s16-net-bazy: rc=0, канон rc=1 (VYBOR_OTKAZ: NET_BAZY: git) КРАСНА
КЛЕТКА s17-api-usechenie: rc=0, канон rc=1 (VYBOR_OTKAZ: USECHENIE_API: api: polucheno=2 vsego=37; git: OSIBKA_DIFFA) КРАСНА
КЛЕТКА s18-oshibka-diffa: rc=0, канон rc=1 (VYBOR_OTKAZ: OSIBKA_DIFFA: git) КРАСНА
КЛЕТКА s19-shema-karty: rc=0, канон rc=1 (VYBOR_OTKAZ: SKHEMA_KARTY: map head: head) КРАСНА
КЛЕТКА s20-pustoj-reestr: rc=0, канон rc=1 (VYBOR_OTKAZ: PUSTOJ_REESTR: map head: head) КРАСНА
```
В каждой строке с p01 старый H-пин оставляет дополнительно `NEEDS_PRECEDENT 1`; полные необрезанные выводы имеются в вызовах этого суда; показаны их outcome/именные отклонения. В частности a17 вызывает `_ispolni_shag` из replay работников, а y20 исполняет GITHUB_OUTPUT-шаг и подаёт отрендеренные job-level outputs в настоящий node `ci-aggregate.cjs` (потеря id создаёт настоящий `AGREGAT_OTKAZ`). y21 вычисляет четыре события закрытым алфавитом: подмена выражения cancel на push красна.

### Пины, живые источники, двери

`python3 tamper.py` (на отдельных одноразовых копиях) →
```
model/.github/workflows/mobile.yml rc= 2 stdout=  stderr= ORACLE_TAMPERED: пин: sha256 model/.github/workflows/mobile.yml
nositeli/p-66052cdf.py rc= 2 stdout=  stderr= ORACLE_TAMPERED: пин: sha256 nositeli/p-66052cdf.py
```
`sha256sum mob/.github/workflows/mobile.yml nositeli/mobile-124.yml` → оба `f45c68230eb83b12c8aa81173da4b9d46608b966acfef7da7ba6178d21087421`; `mob/mobile/scripts/ci-e2e.sh` и nositeli/ci-e2e-995-4.sh → оба `0fa425b5db4752633c7ea453065503bfa8ecefa67e1bef8a7e66102426897f30`; `git show 66052cdf:fixtures/workshop_project/pilot_995/maestro_probe.py | sha256sum` и nositeli/p-66052cdf.py → оба `9a556b48cf4f84a988ba520e6e9ec7389004f461173a8202c6dfb34528803749`; pilot.yaml оригинал и nositeli → оба `3cda11a94ba324fd55cdb9fad039935dbbb1cad8a7719e42aa03c4ff66977e1a`. `gh api repos/a3ka/Complior-mob/pulls/124 --jq '{head:.head.sha,base:.base.sha,changed_files:.changed_files}'` → `{"base":"c3235fbc5a6820d4316b13589521b491ddd38787","changed_files":37,"head":"c617f6fb236d11574df75fb09ae41870bf8c29d6"}`. Остальные API-носители не изменились относительно суда 1/2, тогда проверялись побайтово; сейчас не заявляю повторной внешней сверки всех API.

`bash scripts/pre_critic.sh --repo <клон> contracts/143-mob-ci-razdelenie.md` → rc0 `PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=4 / КРИТИК: дверь зелёная`; `check_precision_gate.sh` rc0 `OK`; `check_spec_ready.sh` rc0 `OK`; `check_ceilings.sh` rc0 `потолки в порядке`; `check_threat_model.sh` rc0 `ЗАЩИЩАЕТ 9, НЕ ЗАЩИЩАЕТ 8`; `check_provodka.sh` на OBJECT rc1 `guard не подключён`, на одноразовом клоне с незакомментированной step-строкой вызова `bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --stabs` rc0 (без вывода). `check_zones.sh` запущен на клоне и завершился итогом `замороженных контрактов: 140 · объявленных авторов: 5 · коммитов в диапазонах: 33880 · проверено по зонам: 7146`; фоновый инструмент не предоставил итоговый exit code. Живой GitHub DAG, gh run, физические runners, maestro/emulator/workflow по заданию НЕ запускались; фактическая интеграция на платформе остаётся только будущим этапом, как и объявлено §НЕ ЗАЩИЩАЕТ.
