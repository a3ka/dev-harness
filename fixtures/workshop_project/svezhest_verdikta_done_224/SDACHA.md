# СДАЧА 224 — все объявления поддерживаемых полей СУД

Обещание: числовой порядок носителей вместо ancestry, совместимость frozen 201/186/129/190 и проверка всех объявлений поддерживаемых полей СУД. Наблюдение: настоящий полный done CLI, rc, отдельные stdout/stderr, annotated тег на исходном HEAD; при отказе тега нет, HEAD неизменен. Ожидания сохранены в памяти до субъекта. TMPDIR — .scratch224c внутри своей isolated-копии; shellcheck 0.11.0 через VALIDATE_STD_SHELLCHECK.

Источник исправления: FAIL Crit224, вызов 2, commit 859c0de39cf6b0be6a52165ee49d16746f5e59cb:verdicts/critic/contracts-224-v2.md; база ba70659fc5e9cae5b439f1d71c994ba92ee1f7e2. Вердикт прочитан целиком через git show, чужой файл в HEAD не копируется. Единственный блок К-09: первое совпадение поколения фазы в строке скрывает второе. К-07 той же карты закрывается честным контролем. Новых предметов, изменений production/frozen/реестров/CI нет. Позиция автора для §Остановка: блок принят; конечная граница — все объявления вызова, поколения фазы и даты, не новая грамматика всей СУД-прозы. Этот ремонт не даёт freeze и не отменяет маршрут арбитража оркестратором.

КЛЕТКИ: 92. МУТАЦИИ: 21. СВЯЗИ: 56. Носители: 23; bash-носители вместе с обёрткой: 24. CASES/probe.py — источник клеток; MUTATIONS/build.py — источник связей; source.json сгенерирован из них. Исходные 54 клетки и 30 связей сохранены; добавлены record-клетки обеих ролей, st20/st21. Старые st12/st18 адаптированы к новому шву без изменения их входов или красноты.

Baseline 5fa6b2c294c2dfd677febb200c73dc27467461e6 и источник исторических блобов 6c021128eb8ecde054b26ad22700910412d88f7b остаются предками результата. Реальная клетка 201 world201.live и полные исторические 186/129/190 остаются положительными контролями. Перенос меняет идентификатор предмета и OBJECT/SHA на автономные Git-объекты, не метаданные. Все новые record-клетки редактируют одну СУД-запись в настоящем мире historic186: review impl-v3 (вызов 1) либо adversary impl-v2-vyzov2 (вызов 2); сохраняют OBJECT и прочее содержимое. Клетка record-adversary-phase-v-second-conflict дословно предъявляет строку критика: `СУД: фаза=реализация v2; фаза=реализация v3; вызов=2/2`.

## Поля и правило

`вызов=N` или `вызов=N/M`: все объявления; повтор даже того же значения — CONFLICT; числа канонические, объявленный вызов согласован с применимой координатой имени/поколения.

`фаза=реализация vV` и `фаза=реализация…круг V`: одно поле поколения с двумя историческими формами; все объявления, включая смешанные; повтор даже той же версии — CONFLICT. Это сохраняет прежний запрет повторов между строками и делает его одинаковым внутри строки. Поколение требует вызов и совпадает с явной версией имени. Фаза без поколения остаётся свободной.

`дата=YYYY-MM-DD`: все объявления; повтор даже той же даты — CONFLICT; единственное значение проверяет date, оно совпадает с датой имени и не инвертирует порядок разных кандидатов.

Левая граница поддерживаемого имени — начало содержимого СУД, пробел или `;`; поля могут идти в любом порядке, через пробел либо `;` без обязательного пробела. Фаза не поглощает следующее поддерживаемое поле. Иные поля (репо/предмет/роль/сессия/модель и т.п.) не входят в грамматику порядка; слова без поля и свободное пояснение не превращаются в metadata. Повтор одинаковой даты у разных кандидатов допустим.

## Закрытие блока

Клетка, не снятие/граница: снятие либо ограничение первым совпадением ослабили бы обещание. Git/date/bash -n/shellcheck проверяют свои канонические свойства, но не семантику выбора, поэтому нужен поведенческий контроль. В SELECTOR/build.py один курсор по именам фаза/вызов/дата потребляет все объявления; значения проверяются в своей ветви. Ветви отказа получают адресные повтор/конфликт и честные единственные эквиваленты. Н-39: связи существуют только кодом, не контрактной прозой.

Обе роли: обе формы фазы, второе противоречие, одинаковый повтор, смешение форм в обе стороны, три объявления, вызов перед/между фазами, пробел вместо `;`, повтор между строками. Для даты — второе противоречие, повтор, три объявления, пробельный разделитель и единственный честный контроль. Для вызова прежние second-conflict/repeat-call/second-invalid сохранены, добавлены три объявления. Честные phase-v-single/phase-cycle-single/date-single/explanation зелены.

st20-first-phase-only имеет один якорь запрета повторной фазы; st21-first-date-only — один якорь даты. Каждая связь исполняется отдельно; кратность каждого якоря проверяет replace_one. Независимые first-each-field и last-each-field вмешиваются в курсор записи, а не якоря стабов: на КАЖДОМ из полей вызова, обеих форм поколения и даты, отдельно для обеих ролей, предъявляются одинаковые повторы. Нельзя зачесть полю красноту соседнего поля. Прежние два независимых мутанта сохранены; хвост после первого поля отрезается ПОСЛЕ проверки его значения, иначе новый шов даёт честный отказ на пустом вызове.

## Двери

- Red-do · bash fixtures/workshop_project/svezhest_verdikta_done_224/red_svezhest_verdikta_done_224.sh --repo . · 1 · 1
- Model · bash fixtures/workshop_project/svezhest_verdikta_done_224/red_svezhest_verdikta_done_224.sh --model · 0 · 0
- Stabs · bash fixtures/workshop_project/svezhest_verdikta_done_224/red_svezhest_verdikta_done_224.sh --stabs · 0 · 0
- Sintaksis · bash fixtures/workshop_project/svezhest_verdikta_done_224/red_svezhest_verdikta_done_224.sh --sintaksis · 0 · 0
- Catalog · bash fixtures/workshop_project/svezhest_verdikta_done_224/red_svezhest_verdikta_done_224.sh --catalog · 0 · 0
- Compatibility · bash fixtures/workshop_project/svezhest_verdikta_done_224/red_svezhest_verdikta_done_224.sh --compatibility · 0 · 0
- Independent-mutants · bash fixtures/workshop_project/svezhest_verdikta_done_224/red_svezhest_verdikta_done_224.sh --independent-mutants · 0 · 0
- Precision · bash scripts/check_precision_gate.sh . contracts/224-svezhest-verdikta-done.md · 0 · 0
- Spec-ready · bash scripts/check_spec_ready.sh . contracts/224-svezhest-verdikta-done.md · 0 · 0
- Threat-model · bash scripts/check_threat_model.sh . contracts/224-svezhest-verdikta-done.md · 0 · 0
- Predposylki · bash scripts/check_predposylki.sh . contracts/224-svezhest-verdikta-done.md · 0 · 0
- Ceilings · bash scripts/check_ceilings.sh . · 0 · 0
- Ids · bash scripts/check_ids.sh . · 0 · 0
- Provodka-grammar · bash scripts/check_provodka.sh --grammar . contracts/224-svezhest-verdikta-done.md · 0 · 0
- CI-canon · bash scripts/gen_ci_steps.sh --check · 0 · 0

## Карта классов

- К-01 · чисто · вход: двери формы листа, ПРОВОДКА guard-каналом; SDACHA_TIMEOUT_SEK=600 SDACHA_BUDZHET_SEK=2400 · - · -
- К-02 · чисто · вход: task-architect224c и единственный блок закоммиченного FAIL Crit224 вызов 2, класс всех объявлений поддерживаемого поля · - · -
- К-03 · чисто · вход: world201.live и исторические 186/129/190 с исходными metadata, frozen неизменны · - · -
- К-04 · чисто · вход: только контракт 224 и его семья; context.py/precision читают настоящие высшие frozen; production/реестры/CI/журналы вне правки · - · -
- К-05 · чисто · вход: полный CLI W и двери формы; повтор любого поддерживаемого поля именован CONFLICT до тега · - · -
- К-06 · чисто · вход: ошибка среды/носителя/синтаксиса — rc 2, не поимка стаба · - · -
- К-07 · чисто · вход: W --model, все record-клетки на полном CLI, rc/трубы/тег/HEAD; модель не оракул ожидаемого rc · - · -
- К-08 · чисто · вход: st20/st21 и независимые first-each-field/last-each-field проверяются по каждой связи/каждому полю отдельно, не суммарной краснотой · - · -
- К-09 · чисто · вход: RECORDS/probe.py, обе формы поколения, обе роли, повтор/второе противоречие/три поля/смешение/порядок/межстрочный повтор; дата и вызов не исключены · - · -
- К-10 · чисто · вход: rc, обе трубы, отсутствие тега на отказе, peeled target на успехе, HEAD и побайтная legacy-regress · - · -
- К-11 · чисто · вход: литеральные ожидания в памяти, исходный HEAD и carrier hashes до субъекта; диск субъекта не источник ожиданий · - · -
- К-12 · чисто · вход: Git/date/bash -n/validate_std shellcheck; SELECTOR/build.py — единственный источник генерируемого кода · - · -
- К-13 · н/п · новые секреты и сеть в оракуле не вводятся · - · -
- К-14 · чисто · вход: phase-v-single/phase-cycle-single/date-single/explanation обеих ролей и исторические положительные контроли · - · -
- К-15 · чисто · вход: catalog/source.json: 92 клетки, 21 мутация, 56 связей; --model/--stabs — другая мера · - · -
- К-16 · чисто · вход: авторизация done, F/CID/OBJECT/same-OBJECT сохранены; согласованная ложь остаётся у pre_judge/замка/origin · - · -
- К-17 · н/п · станционный скрипт без продуктовой модели; новых writer/scope_id нет · - · -

## Дельта

- К-07 · клетка · bash fixtures/workshop_project/svezhest_verdikta_done_224/red_svezhest_verdikta_done_224.sh --model · 0 · 0
- К-09 · клетка · bash fixtures/workshop_project/svezhest_verdikta_done_224/red_svezhest_verdikta_done_224.sh --independent-mutants · 0 · 0

## Сырые результаты отдельных прогонов

W --repo .: rc 1, `KLETKI 92 KRASNYH 53`. Исходные 23 красных сохранены: обе роли × parallel/late-fail/duplicate/missing/conflict/date-order/name-date-conflict/second-conflict/repeat-call/second-invalid; historic186-phase-conflict/phase-no-call/bad-call-name. Новые красные: обе роли × record-{role}-phase-v-second-conflict/phase-cycle-second-conflict/phase-v-repeat/phase-cycle-repeat/phase-mixed/phase-reverse-mixed/phase-three/call-before-phase/date-second-conflict/date-repeat/date-three/phase-spaces/phase-multiline/call-three/date-spaces. Каждый новый красный: `RED RC,DIAGNOSIS,TAG_ON_REFUSAL rc=0 stderr=b''`. Единственные объявления и свободное пояснение зелены ДО реализации.

```text
KLETKI 92 KRASNYH 53
KLETKI 92 KRASNYH 0
STABY 21 SVJAZI 56 ZHIVYH 0
SINTAKSIS 24 SHELLCHECK 2
KLETKI 92 STABY 21 SVJAZI 56
world201.live (0, '')
HISTORIC_RAW historic186 RAW 0 b'' b''
HISTORIC_RAW historic186 GREEN
HISTORIC_RAW historic129 RAW 0 b'' b''
HISTORIC_RAW historic129 GREEN
HISTORIC_RAW historic190 RAW 0 b'' b''
HISTORIC_RAW historic190 GREEN
INDEPENDENT_MUTANTS 4 ZHIVYH 0
```

W --model rc 0 (117.64 с); W --stabs rc 0 (199.83 с), W --sintaksis rc 0, W --catalog rc 0, W --compatibility rc 0 (5.87 с), W --independent-mutants rc 0 (34.86 с). Первый independent-прогон дал rc 1 ZHIVYH 2: старый tail-мутант очищал значение ДО проверки и потому честно отказывал. Исправлен только его якорь; никакой зелёный результат не объявлен по первому прогону. Новые first/last-each-field красны каждый на своих полях уже в первом прогоне.

## Наблюдение процесса

Адрес доставки WORKTREE и ветка architect-c задания отличаются от выданной runtime isolated-копии и guard-совместимой ветки wip/224/architect. Пишется только выданная копия; ведущему доставляются фактические pwd/sha. Scratch тоже внутри копии, не в чужом /tmp. Журнал NABLIUDENIA_ARCHITECT.md в wip не правится. Кандидат для записи main без самовольного А-номера (класс: конструкция проверки; источник: первый --independent-mutants; цена: 28.93 с): при смене шва старый мутант может превратиться в честный отказ; его anchor переносится вместе с операцией, адресные входы и требование красноты сохраняются. Закрыто переносом очистки хвоста после проверки первого значения и повторным --independent-mutants rc 0. Расхождение cwd уже наблюдалось в предыдущем листе; нужна единая пара actual-cwd/guard-ветка в выдаче.

## Финальные двери

`bash scripts/check_precision_gate.sh "$PWD" contracts/224-svezhest-verdikta-done.md` rc 0 (14.25 с), сырой вывод `OK`.

`bash scripts/pre_critic.sh contracts/224-svezhest-verdikta-done.md` rc 0 (711.64 с) с VALIDATE_STD_SHELLCHECK и SDACHA_TIMEOUT_SEK=600 SDACHA_BUDZHET_SEK=2400; полный прогон, без SDACHA_OKRUG. Он исполнил дверь сдаточного листа с командами разделов «Двери» и «Дельта»; ограничение изолированной копии не возникло.

```text
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=2
  ok   гейт трека:
  ok   модель угроз красна
  ok   потолки красны
  ok   проводка красна
  ok   сдаточный лист красен
КРИТИК: дверь зелёная
```

Фразы «красна/красен» здесь — дословные статические имена ног pre_critic после `ok`, не ненулевой rc. Отдельный повтор check_sdacha после этого не запускался: дверь уже выполнена настоящим pre_critic; stdout вложенной двери он подавляет.
