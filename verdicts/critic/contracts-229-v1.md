FAIL
OBJECT=58dbcdaf7147932db1858b31f0362964d0dc5d1c
СУД: репо=dev-harness; предмет=229; фаза=контракт; роль=critic; вызов=3 (последний исправительный; дельта Architect229c); модель-план=openai-codex/gpt-6.1-terra; сессия=Crit229c; модель-факт=openai-codex/gpt-6.1-terra; автор Architect229c — openai-codex/gpt-6.1-sol; предыдущий=archive/229/critic-v2-fail-94c98a209d; исключение=санкция оркестратора в задании на OBJECT.

Фактические модели и разные сессии подтверждены `scripts/models_actual.sh --bind --session Crit229c` и `--session Architect229c`, обе allowed. Scoped-повтор: проверены прежние блоки и последствия нового фазового счёта. Основание дополнительной проверки К-03 — новая семантика содержательных лимитов на contracts/229-g1-g9-judges-policy.md:54 и ранее не установленная совместимость с живым frozen 154, которую прямо требует задание. Предыдущий вердикт отмечал, что совместимость прочих frozen не установлена.

## Блок

БЛОКИРУЕТ contracts/229-g1-g9-judges-policy.md:53-54,74-75 — заявленные автоматические технические повторы не согласованы с замороженным позиционным бюджетом критика 154.
ОБЯЗАТЕЛЬСТВО: 229 обещает исходный запуск и два автоповтора после обрыва/среды, исключая эти исходы из содержательного предела; замороженный `frozen/contracts/154/2:contracts/154-schet-vyzovov-kritika.md:37-38,42` требует считать ВСЕ START critic/critic-sol, включая обрывы, и для позиции 3 требует отдельную адресную SANKTSIYA с committed основанием; freeze независимо пересчитывает тот же журнал.
СОСТОЯНИЕ: новый предмет, включённая станционная политика; первый critic и первый автоматический повтор на одном OBJECT оба завершились obryv_bez_verdikta, содержательных вердиктов ноль, адресной санкции на позицию 3 нет. Это прямо поддерживаемый Г-3 сценарий.
НАБЛЮДЕНИЕ: 229 требует допустить второй автоповтор, тогда как 154 требует отказать в третьем START и не позволяет freeze узаконить непокрытую позицию. На одном журнале реальная модель 229 разрешила третий START, модель frozen 154 отказала. Установка 154 после 229 лишь откладывает конфликт; два счётчика с разными именами его не снимают. 229 не объявляет пересечения с 154 и не предъявляет способа совместной приёмки либо полномочного изменения frozen-обязательства. Закрывающее свойство: совместно определить и доказать исполнимый порядок для тех же START и freeze, не отменяя frozen 154 без полномочного решения о его изменении.
ПРОИСХОЖДЕНИЕ: пропущен-ранее
КЛАСС: К-03

АРБИТР: созвать арбитра о конечной границе между автоматическими техническими повторами 229 и замороженным позиционным счётом 154; если требуется смена разрешённого риска или frozen-обязательства, передать решение владельцу. Третий вызов не даёт accept и не открывает новый полный круг.

## Карта классов

К-01: чисто — check_sdacha --run и pre_critic в чистом origin-клоне rc 0
К-02: без изменений с вызова 2
К-03: блок — автоматические технические повторы против frozen 154
К-04: чисто — check_precision_gate.sh rc 0
К-05: без изменений с вызова 2
К-06: чисто — tmpdir_229.py blocked rc 2 без предметного красного
К-07: чисто — реальные CLI stop и arbiter на входе вызова 2 выдали требуемые отказы
К-08: чисто — пять независимых мутаций новых операций пойманы адресными клетками
К-09: чисто — enum_229c.py rc 0 предъявил удаление enum и восемь красных клеток
К-10: без изменений с вызова 2
К-11: без изменений с вызова 2
К-12: без изменений с вызова 2
К-13: без изменений с вызова 2
К-14: чисто — обе политики и граница ниже предела предъявляются phase_cells.py
К-15: чисто — --catalog rc 0 вывел 133 клетки 34 стаба 44 связи
К-16: без изменений с вызова 2
К-17: без изменений с вызова 2

## Закрытие двух блоков вызова 2

Честная модель, полный объект criticCalls=1, один START/RELEASE verdikt_zakommiten, тот же OBJECT, настоящая команда замка (временный драйвер над `probe.world/profile/add_failed/old.sudit`), сырой вывод:
```
stop rc= 1 stdout= '' stderr= 'ОТКАЗ: BUDGET_EXHAUSTED: repo=dev-harness subject=141 role=critic object=dccc27cc7ddb31983d8fe87faaf8fe10bf856523 limit=1 fact=1\n'
arbiter rc= 1 stdout= '' stderr= 'ОТКАЗ: ARBITRATION_REQUIRED: repo=dev-harness subject=141 role=critic object=cd371a77606d352d2ca271551e5d6d788a961f70 limit=1 fact=1\n'
unexpected rc= 1 stdout= '' stderr= "POLICY_INVALID: POLICY_INVALID: 'unexpected' is not one of ['arbiter', 'stop']\n\nFailed validating 'enum' in schema['properties']['onExhaustion']:\n    {'enum': ['arbiter', 'stop']}\n\nOn instance['onExhaustion']:\n    'unexpected'\nprofile ОТКАЗ: judges.policy: POLICY_INVALID\n\nОТКАЗ: BITYJ_VHOD: judges.policy: POLICY_INVALID\n"
```
`python3 fixtures/workshop_project/judges_policy_229/enum_229c.py` rc 0 после дословного удаления enum: сырой вывод включает `MUTANT_VALIDATE_RC 0`, восемь строк `policy-exhaustion-* KRASNO RC 0!=1 'PUSCHEM Next229 dev-harness/141 (sudja/critic)\n' ''`, `KLETKI 133 KRASNYH 8`, `MUTANT_REPO_RC 1`. Все остальные клетки, включая оба допустимых действия, зелёные. Оба блока вызова 2 закрыты. Границы всех трёх ролей, чужая роль, новый OBJECT, технический исход и сохранение санкции предъявляются `phase_cells.py`; старые клетки `probe.py` в diff 845086599..OBJECT не удалены.

## Контраст frozen 154

Временный драйвер на `probe.world`, `profile` и `add_failed` создал два critic START/RELEASE obryv_bez_verdikta, затем вызвал реальный замок модели 229, убрал только пробную третью START из одноразового журнала и вызвал `python3 fixtures/workshop_project/schet_vyzovov_154/model/budget.py --sostojanie <журнал> --repo <мир> --subject 141 --object <тот же OBJECT> --phase spawn`. Сырой вывод:
```
229 third START 0 'PUSCHEM ThirdRetry dev-harness/141 (sudja/critic)\n' ''
154 third START 1 '' 'ОТКАЗ: SCHET_NEIZVESTEN: неоднозначный использованный источник: 3\n'
```
Блобы модели 154 и её контракта идентичны HEAD и frozen/154/2. Модели — свидетельство несовместимости на одном входе, не утверждение о наличии уже внедрённой реализации 154.

## Независимые мутации

Каждая — отдельная копия модели и `W --repo <копия> --case <имя>`; менялась существующая операция, а не добавлялся запрет входа. Не использованы готовые стабы: сравнение `substantive+1 > limit` заменено на `substantive > limit` и отдельно `substantive+2 > limit`; выбор лимита роли заменён выбором другой роли; результат действия stop/arbiter обращён; к содержательному счёту добавлен только blok_sredy. Сырой вывод:
```
MUTATION late-limit CASE phase-critic-stop-one rc 1
KLETKI 133 STABY 34 SVJAZI 44
phase-critic-stop-one KRASNO DIAGNOSIS ОТКАЗ: BUDGET_EXHAUSTED:: 'ОТКАЗ: OBJECT_UZHE_SUZHEN: предмет 141: OBJECT 81cc5dd9c9926da8af2643dd3f237ba117f14c84 уже судился ролью critic; исправительный круг — новый sha; повтор — записанная в учёте санкция SANKCIJA (один круг, пока не исчерпан)\n'
KLETKI 1 KRASNYH 1

MUTATION early-limit CASE phase-reviewer-arbiter-below rc 1
KLETKI 133 STABY 34 SVJAZI 44
phase-reviewer-arbiter-below KRASNO RC 1!=0 '' 'ОТКАЗ: ARBITRATION_REQUIRED: repo=dev-harness subject=141 role=reviewer object=a0f3c02ca3c3f152b82a023a56775d2efdfe71bb limit=2 fact=1\n'
KLETKI 1 KRASNYH 1

MUTATION wrong-role-limit CASE phase-critic-stop-one rc 1
KLETKI 133 STABY 34 SVJAZI 44
phase-critic-stop-one KRASNO DIAGNOSIS ОТКАЗ: BUDGET_EXHAUSTED:: 'ОТКАЗ: OBJECT_UZHE_SUZHEN: предмет 141: OBJECT 4997abcab59b2f8fe3db235bdea7c757f086a0fe уже судился ролью critic; исправительный круг — новый sha; повтор — записанная в учёте санкция SANKCIJA (один круг, пока не исчерпан)\n'
KLETKI 1 KRASNYH 1

MUTATION reversed-action CASE phase-critic-stop-one rc 1
KLETKI 133 STABY 34 SVJAZI 44
phase-critic-stop-one KRASNO DIAGNOSIS ОТКАЗ: BUDGET_EXHAUSTED:: 'ОТКАЗ: ARBITRATION_REQUIRED: repo=dev-harness subject=141 role=critic object=2bac9d2df8b3766417d7dbb3af3c7e94412425c7 limit=1 fact=1\n'
KLETKI 1 KRASNYH 1

MUTATION count-env CASE phase-reviewer-arbiter-environment rc 1
KLETKI 133 STABY 34 SVJAZI 44
phase-reviewer-arbiter-environment KRASNO RC 1!=0 '' 'ОТКАЗ: ARBITRATION_REQUIRED: repo=dev-harness subject=141 role=reviewer object=ff7558955a9012e94dba08664ddbef72d42d1c46 limit=1 fact=1\n'
KLETKI 1 KRASNYH 1
```

## Двери чистого origin-клона

`SDACHA_TIMEOUT_SEK=1200 SDACHA_BUDZHET_SEK=2400 bash scripts/check_sdacha.sh "$PWD" contracts/229-g1-g9-judges-policy.md --run`, rc 0: `СДАЧА: лист зелёный (двери=6 карта=17/17 дельта=3)`. Лист последовательно запускает --model, --stabs, --sintaksis, --catalog, --repo и frozen-overlaps и сравнивает rc; полный вывод этих вложенных команд лист подавляет. Отдельно `--sintaksis` и `--catalog`, rc 0:
```
KLETKI 133 STABY 34 SVJAZI 44
SINTAKSIS 0
KLETKI 133 STABY 34 SVJAZI 44
```
`pre_critic.sh` rc 0, сырой вывод:
```
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=2
  ok   гейт трека: 
  ok   модель угроз красна
  ok   потолки красны
  ok   проводка красна
  ok   сдаточный лист красен
КРИТИК: дверь зелёная
```
`check_precision_gate.sh` rc 0: `OK`. `tmpdir_229.py` rc 0:
```
TMPDIR relocated rc=0 expected=0
TMPDIR spaces rc=0 expected=0
TMPDIR absent rc=0 expected=0
TMPDIR empty rc=0 expected=0
TMPDIR blocked rc=2 expected=2
```
До реализации `--repo .` ожидаемо красен: лист проверил rc 1; полный набор красных отдельно не снимался. Implementer должен реализовать перечисленные CLI-швы и доставить роли после адресного разрешения владельца; rollout проверяет живую работу.

## НЕ ЗАЩИЩАЕТ

Достоверность сообщения о среде, честность production и поведение LLM не следуют из формы: ловцы reviewer/arbiter, журнал task и фактические rollout-трассы. До правки нормативных ролей требуется адресное слово владельца, которого в пачке нет; статическое наличие нормы не заменяет живой спавн арбитра.
