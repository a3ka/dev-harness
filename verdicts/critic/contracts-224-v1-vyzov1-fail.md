FAIL
OBJECT=6c021128eb8ecde054b26ad22700910412d88f7b
СУД: repo=dev-harness; предмет=224; фаза=контракт; роль=critic; вызов=1/2 (полный; новый предмет); модель-план=openai-codex/gpt-6.1-terra; сессия=Crit224; модель-факт=openai-codex/gpt-6.1-terra; автор Architect224 — gpt-6.1-sol, другая сессия; SHA=6c021128eb8ecde054b26ad22700910412d88f7b; предыдущий=нет; исключение=нет

## Блоки

БЛОКИРУЕТ contracts/224-svezhest-verdikta-done.md:44 — новая грамматика запрещает прямо сохранённые положительные входы замороженного 201 и не предусматривает их согласования.
ОБЯЗАТЕЛЬСТВО: строка 49 сохраняет прочие обязательства двери; frozen/contracts/201/1, contracts/201-done-dver-soderzhatelnaja-sverka.md:15,75, требует не запереть честный 186 и rc 0 для `v-riskovyi-sopostavimyj-object`. Задание требует именованного отказа отсутствующего номера; простое молчаливое исключение не является решением.
СОСТОЯНИЕ: реальный мир клетки 201 строит в HEAD единственный `verdicts/adversary/contracts-777-impl-a1.md`, accept на тот же OBJECT, что review (dver_probe.py:210-211,418-421). Это не выдуманное имя. Кроме того, в самом frozen 201 присутствуют настоящие `contracts-186-impl-v2.md`, `contracts-186-impl-v2-vyzov1.md`, `contracts-186-impl-v2-vyzov2.md`: v2 здесь обозначает версию реализации, а не единый номер вызова; два последних файла относятся к разным вызовам. Правило строк 44–45 сочтёт их дублем 2.
НАБЛЮДЕНИЕ: на реальной клетке 201 с полной reference-дверью 224 проверка `world201.live` дала `CASE v-riskovyi-sopostavimyj-object expected rc=0` и `RESULT (1, 'done: VERDICT_ROUND_MISSING: adversary: verdicts/adversary/contracts-777-impl-a1.md\n')`. Отдельно перенос трёх реальных имён/блобов 186 в Git-мир с заменой только идентификатора 186→777 дал `RC 1 STDOUT b'' STDERR b'done: VERDICT_ROUND_DUPLICATE: adversary: 2: verdicts/adversary/contracts-777-impl-v2-vyzov1.md\n'`. Батарея 224 использует иные имена и этот регресс не показывает.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: согласовать новый порядок и обязательный fail-closed со всеми применимыми frozen-положительными входами и историческими носителями; доказать это реальными клетками и объявить необходимые зоны/пересечения. Если требуется изменить замороженное обязательство или разрешённый риск, решение принимает полномочная роль, а не критик или исполнитель.
ПРОИСХОЖДЕНИЕ: пропущен-ранее
КЛАСС: К-03

БЛОКИРУЕТ contracts/224-svezhest-verdikta-done.md:46 — обязательная честная модель пропускает противоречащий второй вызов в одной строке СУД.
ОБЯЗАТЕЛЬСТВО: объявленный вызов должен совпадать с номером имени, конфликт даёт VERDICT_ROUND_CONFLICT до done; приёмка :58 требует зелёную честную модель.
СОСТОЯНИЕ: реальный Git-мир `review-no-metadata` конструктора 224, после которого к вердикту `contracts-777-impl-v4.md` добавлена и закоммичена строка `СУД: вызов=4/9; вызов=3/9`. Авторская предметная операция model/done_contract.sh:142 извлекает только первое совпадение regex в строке и не обнаруживает второе поле. Вход использует заявленный канал самостоятельной строки СУД и явно заявленный отказ конфликтующих метаданных.
НАБЛЮДЕНИЕ: `python3 critic_probe.py` в одноразовом клоне, полная модель и настоящий done CLI:
```text
INPUT: СУД: вызов=4/9; вызов=3/9
RC 0 STDOUT b'' STDERR b''
TAGS 'done/contracts/777/1'
```
Модель ставит тег вопреки собственному обязательству. Это дефект самой обязательной модели, не специально придуманного мутанта.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: проверить все объявленные поля вызова в поддерживаемой СУД-записи и отказать неоднозначным/противоречащим без тега; доказать для обеих ролей и не запереть честное свободное пояснение.
ПРОИСХОЖДЕНИЕ: пропущен-ранее
КЛАСС: К-09

## Воспроизведение специальных проверок

В одноразовом локальном клоне OBJECT импортировался `fixtures/workshop_project/svezhest_verdikta_done_224/probe.py` через `importlib.util.spec_from_file_location`. `critic_probe.py` вызывал `make_world(work, 'review-no-metadata')`, добавлял показанную строку к `world/verdicts/review/contracts-777-impl-v4.md`, коммитил `commit(world, 'conflicting second call')`, устанавливал неизменённые bytes `model/done_contract.sh` через `install(work, model, root)` и запускал `bash <установленная модель> <target> <reason> <world>`; вывод выше сырой. Все world и тег были внутри TemporaryDirectory клона.

`critic_frozen.py`: импорт того же probe, `world201.build(work, 'v-riskovyi-sopostavimyj-object', 'station')`, отдельная копия scripts с неизменённой `model/done_contract.sh`, затем `world201.live(tools, subject, contract, facts)`; вывод выше сырой. `critic_historic.py`: `make_world(work, 'adversary-no-metadata')`, заменить adversary-файлы тремя файлами 186 из OBJECT, заменив только 186 на 777 в basename, коммит, далее полный CLI модели; вывод выше сырой. Это отдельные временные репозитории, не изменения OBJECT.

Пять независимых изменений операций reference, каждое отдельно в `scripts/done_contract.sh` одноразового клона, затем `bash fixtures/workshop_project/svezhest_verdikta_done_224/red_svezhest_verdikta_done_224.sh --repo <клон>`; между изменениями восстанавливалась неизменённая reference. Это не авторские текстовые замены из MUTATIONS. Ниже сырые итоговые строки каждого прогона и наблюдённые RED (GREEN-строки остальных клеток опущены):
```text
COMMAND reverse_round
REPO review-late-fail RED RC,DIAGNOSIS,TAG_ON_REFUSAL rc=0 stderr=b''
REPO adversary-late-fail RED RC,DIAGNOSIS,TAG_ON_REFUSAL rc=0 stderr=b''
KLETKI 32 KRASNYH 6
STDERR '' RC 1
COMMAND duplicate_forget
REPO review-duplicate RED RC,DIAGNOSIS,TAG_ON_REFUSAL rc=0 stderr=b''
REPO adversary-duplicate RED RC,DIAGNOSIS,TAG_ON_REFUSAL rc=0 stderr=b''
KLETKI 32 KRASNYH 2
STDERR '' RC 1
COMMAND missing_default_one
REPO review-missing RED DIAGNOSIS rc=1 stderr=b'done: VERDICT_ROUND_CONFLICT: review: verdicts/review/contracts-777-impl-final.md\n'
REPO adversary-missing RED DIAGNOSIS rc=1 stderr=b'done: VERDICT_ROUND_CONFLICT: adversary: verdicts/adversary/contracts-777-impl-final.md\n'
KLETKI 32 KRASNYH 2
STDERR '' RC 1
COMMAND date_comparison_disabled
REPO review-date-order RED RC,DIAGNOSIS,TAG_ON_REFUSAL rc=0 stderr=b''
REPO adversary-date-order RED RC,DIAGNOSIS,TAG_ON_REFUSAL rc=0 stderr=b''
KLETKI 32 KRASNYH 2
STDERR '' RC 1
COMMAND object_frozen_binding_disabled
REPO review-old-object RED RC,DIAGNOSIS,TAG_ON_REFUSAL rc=0 stderr=b''
KLETKI 32 KRASNYH 1
STDERR '' RC 1
```
Замены соответственно: `[ "$key" -gt "$best" ]` → `[ "$key" -gt "$best" ] && [ "$best" -eq 0 ]`; `seen="$seen$number "` → `seen=" "`; `die "done: VERDICT_ROUND_MISSING: $role: $f"` → `number=1`; `[ "$prior_n" -lt "$number" ]` → `[ "$prior_n" -lt 0 ]`; операция `merge-base --is-ancestor "$frozen_commit" "$object_sha"` и её `|| bind_rc=$?` заменена `bind_rc=0`. Первый мутант также красит parallel/linear обеих ролей. Это проверка различимости указанных операций, не доказательство полноты батареи.

## Прогоны кандидата

`SDACHA_TIMEOUT_SEK=600 SDACHA_BUDZHET_SEK=2400 bash scripts/check_sdacha.sh "$PWD" contracts/224-svezhest-verdikta-done.md --run` с пином shellcheck: rc 0, сырой итог `СДАЧА: лист зелёный (двери=13 карта=17/17 дельта=0)`. `bash scripts/pre_critic.sh contracts/224-svezhest-verdikta-done.md`: первый запуск без пина shellcheck rc 1 на `--sintaksis` rc 2; повтор с заданными TMPDIR, пином и бюджетом rc 0, сырой итог `КРИТИК: дверь зелёная`. `bash scripts/check_precision_gate.sh "$PWD" contracts/224-svezhest-verdikta-done.md`: rc 0, `OK`. `uptime`: `load average: 33.72, 25.43, 22.38`.

Сырые итоговые строки отдельных W-прогонов:
```text
KLETKI 32 KRASNYH 14
REPO_RC=1
KLETKI 32 KRASNYH 0
MODEL_RC=0
STABY 11 SVJAZI 19 ZHIVYH 0
STABS_RC=0
```
До реализации красны для каждой роли parallel, late-fail, duplicate, missing, conflict, date-order, name-date-conflict; остальные 18 клеток зелёны. Честная модель и контроль стабов по 32 клетки зелёные. Это не опровергает два воспроизведённых выше блока. Затравка 5fa6b2c сохранена по имени, номеру и основной боли; расширение на adversary прямо задано. Замена только межвердиктной предковости на общий выбор максимального корректного круга, с сохранением проверок F/CID/OBJECT, могла бы устранить исходную боль; текущий контракт дополнительно обязан разрешить описанное противоречие frozen и исправить reference.

## Карта классов
К-01: чисто — check_sdacha --run rc 0 и повтор pre_critic rc 0 с пином
К-02: чисто — вход owner-затравка 5fa6b2c и task-architect224
К-03: блок — frozen-положительные входы 201 отказываются
К-04: чисто — context.py rc 0 показал 73 объявленных пересечения и зоны предмета
К-05: чисто — вход раздел Приёмка содержит W и rc-команды
К-06: чисто — вход probe.py различает rc 2 среды и предметные rc 0/1
К-07: блок — обязательная reference принимает конфликт метаданных
К-08: чисто — входы пяти мутаций и --stabs rc 0
К-09: блок — второе поле вызова в одной СУД-строке
К-10: чисто — вход probe.py проверяет обе трубы HEAD и цель done-тега
К-11: чисто — вход probe.py сохраняет ожидания и HEAD до субъекта
К-12: чисто — вход model использует git и date для заданных операций
К-13: н/п — секреты и сетевые свидетельства не вводятся
К-14: чисто — входы linear equivalent и no-metadata в --model зелёные
К-15: чисто — --catalog и выводы W подтверждают 32 клетки 11 стабов 19 связей
К-16: чисто — вход авторизация допуска done и раздел Модель угроз
К-17: н/п — станционный скрипт без продуктовой архитектурной модели

## НЕ ЗАЩИЩАЕТ
Согласованная подделка всех метаданных и удаление вердикта из истории остаются в заявленной границе с ловцами pre_judge, замком и origin; этот остаток не оправдывает пропуск обнаруженного конфликта.

## Советы
СОВЕТ contracts/224-svezhest-verdikta-done.md:38 — при уточнении источника номера различить версию реализации и номер оплаченного вызова на реальных исторических примерах, не только на синтетических именах.
