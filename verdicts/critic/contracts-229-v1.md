FAIL
OBJECT=845086599020fd964172d301cb381d921969930f
СУД: репо=dev-harness; предмет=229; фаза=контракт; роль=critic; вызов=2/2 (исправительный; по существу после формы вызова 1); модель-план=openai-codex/gpt-6.1-terra; сессия=Crit229b; модель-факт=openai-codex/gpt-6.1-terra; автор Architect229b — openai-codex/gpt-6.1-sol; предыдущий=archive/229/critic-v1-fail-4c23273854; исключение=санкция оркестратора в задании на OBJECT.

Модели подтверждены `bash scripts/models_actual.sh --bind --session Crit229b` и для Architect229b: обе `allowed`, сессии разные. Вызов 1 остановился на форме, поэтому задание санкционирует полный содержательный проход; открытые ниже классы не являются новым поиском по закрытым поверхностям. До содержательного суда в чистом сетевом origin-клоне OBJECT с собственным TMPDIR сдаточный лист вернул rc 0; прежний К-01 закрыт на предъявленном состоянии.

## Блоки

БЛОКИРУЕТ contracts/229-g1-g9-judges-policy.md:54-55,74-76 — зелёная обязательная модель не осуществляет содержательные фазовые пределы и не выдаёт заданное действие исчерпания.
ОБХОД: честная модель из OBJECT с полным валидным объектом `criticCalls=1, onExhaustion=stop`, одним START/RELEASE `verdikt_zakommiten` и запросом второго critic на тот же OBJECT возвращает rc 1, но старый `OBJECT_UZHE_SUZHEN` с сообщением про SANKCIJA, а не требуемый `BUDGET_EXHAUSTED`; `onExhaustion=arbiter` аналогично не вызывается механизмом этого предела. Достижимый вход — поддерживаемые профиль и учёт уже завершённого суда. Причина в обязательной модели: `model/scripts/judges_policy.py:59-73` считает только две технические причины, а сохранённая операция `model/scripts/zamok_predmeta.sh:1457-1462` проверяет старое правило санкции без обращения к `criticCalls`. В `probe.py:155-163` проверяется действие исчерпания лишь для `interruptionRetries=0`, а не для содержательных `criticCalls/reviewerCalls/adversaryCalls`. `--model` и вся штатная батарея при этом зелёные. Закрывающее свойство: отдельно различать исчерпание и неисчерпание каждого содержательного лимита для обеих политик выхода, сохраняя предусмотренную адресную санкцию и учёт технических исходов; модель и приёмка должны проверять именно наблюдаемый отказ/отсутствие START.
ПРОИСХОЖДЕНИЕ: пропущен-ранее
КЛАСС: К-08

БЛОКИРУЕТ contracts/229-g1-g9-judges-policy.md:59,74-76 — батарея принимает кандидата с удалённой обязательной валидацией значения onExhaustion.
ОБХОД: в одноразовой копии модели удалено существующее поле `schema.properties.onExhaustion.enum` из `config/judges-policy.json`, без добавления новой ветви или фильтра; на поддерживаемом входе полный объект с `onExhaustion="unexpected"` проходит `judges_policy.py validate`, rc 0, хотя контракт требует fail-closed. Затем полная `W --repo <копия-модели>` возвращает rc 0, `KLETKI 53 KRASNYH 0`. Источник входа — явно объявленная замкнутая грамматика на :59 и профильный объект; источник ошибочного механизма — удаление уже существующего enum в модели `model/config/judges-policy.json:47-52`. Клетки `probe.py:31-36,145-163` не предъявляют неизвестное значение этого поля. Закрывающее свойство: различать неразрешённое действие исчерпания и оба допустимых действия на настоящем профильном пути до START; корректная альтернативная политика остаётся зелёной.
ПРОИСХОЖДЕНИЕ: пропущен-ранее
КЛАСС: К-09

## Карта классов

К-01: чисто — чистый origin-клон OBJECT и check_sdacha --run rc 0, pre_critic rc 0
К-02: чисто — затравка origin/main и таблица Г-1…Г-9 контракта
К-03: н/п — precision rc 0 и frozen 140 прочитан, полная смысловая совместимость прочих frozen не установлена
К-04: чисто — check_precision_gate.sh rc 0 и зоны контракта
К-05: н/п — живая rollout-приёмка и её команды исполняются после реализации
К-06: чисто — tmpdir_229.py blocked rc 2 без предметного красного
К-07: блок — обязательная модель не осуществляет фазовые пределы
К-08: блок — обязательная модель не осуществляет фазовые пределы
К-09: блок — удаление enum onExhaustion проходит батарею
К-10: чисто — env-release и setup-hook через реальные Git и hook в контрольной батарее
К-11: чисто — ожидания probe.py создаются до вызова субъекта
К-12: чисто — модель использует Draft202012Validator и настоящий resolver
К-13: н/п — новые секреты не заявлены
К-14: чисто — policy-causal и policy-stop-action в полном зелёном прогоне
К-15: чисто — catalog.py rc 0 выдал 28 имён и 45 мест, цель 16 плюс динамические коды
К-16: чисто — рисковый допуск судей, раздел модели угроз и условие слова владельца в контракте
К-17: н/п — станционная дверь, продуктовая модель не меняется

## Исполненные пробы и сырой вывод

`SDACHA_TIMEOUT_SEK=1200 SDACHA_BUDZHET_SEK=2400 bash scripts/check_sdacha.sh "$PWD" contracts/229-g1-g9-judges-policy.md --run`, чистый origin-клон, rc 0:
```
СДАЧА: лист зелёный (двери=6 карта=17/17 дельта=1)
```
`bash scripts/pre_critic.sh contracts/229-g1-g9-judges-policy.md`, тот же клон, rc 0:
```
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=2
  ok   гейт трека:
  ok   модель угроз красна
  ok   потолки красны
  ok   проводка красна
  ok   сдаточный лист красен
КРИТИК: дверь зелёная
```
`python3 fixtures/workshop_project/judges_policy_229/tmpdir_229.py`, rc 0:
```
TMPDIR relocated rc=0 expected=0
TMPDIR spaces rc=0 expected=0
TMPDIR absent rc=0 expected=0
TMPDIR empty rc=0 expected=0
TMPDIR blocked rc=2 expected=2
```
Перестроение `build.py` в отдельном клоне с двумя разными TMPDIR, один с пробелом, дважды rc 0: `CARRIERS 36 STABS 25 LINKS 26`; оба sha256 `source.json`: `56ef3e31d60c66f423a2e2ba1d4c46f16570226609f30c6cb32644f2b4049618`. `git diff 96f4b120f 845086599 -- fixtures/workshop_project/judges_policy_229/probe.py` показывает перенос TMPDIR и проверку записи до клеток, удаления предметных проверок нет. `bash scripts/check_precision_gate.sh "$PWD" contracts/229-g1-g9-judges-policy.md` rc 0: `OK`.

`W --repo .` в чистом клоне OBJECT rc 1: `KLETKI 53 KRASNYH 48`. Красны, среди прочего, RELEASE среды, ограничения, известные неверные политики, setup/helper отсутствует, 11 старых диагнозов, бюджет кодов и нормы ролей. Это красное до реализации: нужно реализовать швы и доставить нормы с адресным разрешением владельца, не подменяя production моделью. Семантические решения LLM и настоящий спавн остаются cognitive-only с rollout и reviewer/arbiter.

Фазовый контрпример выполнен временным Python-драйвером над `probe.world`, `profile`, `add_failed` и `old.sudit` (реальный Git/замок):
```
criticCalls=1 after 1 verdict; request 2: rc= 1 stdout= '' stderr= 'ОТКАЗ: OBJECT_UZHE_SUZHEN: предмет 141: OBJECT ef7247d1c385df886c660a69103cae3e2de667d7 уже судился ролью critic; исправительный круг — новый sha; повтор — записанная в учёте санкция SANKCIJA (один круг, пока не исчерпан)\n'
```

Для атаки на схему скопирована `model/`, в `config/judges-policy.json` удалён только `schema.properties.onExhaustion.enum`; `python3 <копия>/scripts/judges_policy.py validate` получил JSON defaults с `onExhaustion=unexpected`; затем `bash fixtures/workshop_project/judges_policy_229/red_judges_policy_229.sh --repo <копия>`:
```
INVALID_POLICY rc 0 '{"criticCalls": 2, "reviewerCalls": 2, "adversaryCalls": 2, "environmentRetries": 2, "interruptionRetries": 2, "onExhaustion": "unexpected", "adversary": "risk-only", "testFinding": "residual", "waitingOwner": "yield-slot"}\n' ''
MUTATED_MODEL --repo rc 0
KLETKI 53 STABY 25 SVJAZI 26
... все 53 клетки ok ...
KLETKI 53 KRASNYH 0
```

Пять других одноразовых мутаций исходных операций, каждая отдельно, `W --repo <копия-модели> --case <имя>`:
```
environment-off-by-one: env-retry rc 1, KRASNO RC 1!=0, ARBITRATION_REQUIRED
release-verdict: env-release rc 1, KRASNO RELEASE prichina=verdikt_zakommiten
wrong-env-return: env-not-adversary rc 1, KRASNO RELEASE prichina=verdikt_zakommiten
early-arbiter: second-retry rc 1, KRASNO RC 1!=0, ARBITRATION_REQUIRED
lose-layer: policy-layer rc 1, KRASNO POLICY_VALUE None!=полный объект
```
Изменения соответственно: `environment >` на `>=`, причина `blok_sredy` на `verdikt_zakommiten`, `return 3` на `return 0` при среде, `interruptions >` на `interruptions + 1 >`, удаление ветви project-layer. Для этих пяти пойманных проб выше приведены сокращённые, не дословные строки; сырые результаты доступны в выводе запуска. Они не снимают два блока.

## НЕ ЗАЩИЩАЕТ

Содержательная достоверность команды БЛОК-СРЕДЫ и честность production не выводятся из формы: ловцы reviewer/arbiter и настоящие rollout-трассы, как в контракте. Смысловая совместимость всех исторических frozen-контрактов отдельно этим вердиктом не удостоверена; precision-gate проверяет пересечения, а не все их инварианты.
