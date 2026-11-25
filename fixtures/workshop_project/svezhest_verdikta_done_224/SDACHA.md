# СДАЧА 224 — исправление двух блоков Crit224

Обещание: числовой порядок носителей вместо их ancestry, с совместимостью frozen 201/186 и проверкой всех объявленных вызовов. Наблюдение: полный done CLI, rc, отдельные stdout/stderr, annotated тег на исходном HEAD, отсутствие тега при отказе. Ожидания сохраняются до субъекта; Git-миры автономны и удаляются TemporaryDirectory. TMPDIR — существующий tmp своей изолированной копии; shellcheck — пин 0.11.0 через VALIDATE_STD_SHELLCHECK.

Источник дельты: закоммиченный FAIL Crit224, вызов 1, verdicts/critic/contracts-224-v1.md из архивной ветки, указанной в task-architect224b. База задания 6c021128eb8ecde054b26ad22700910412d88f7b НЕ содержит этот последующий вердикт в HEAD; файл чужой зоны не копируется, ссылка не выдаётся за HEAD-вход гейта. Дельта покрывает К-03, К-07 и К-09 карты этого FAIL, команды исполняются листом. Замороженные контракты, production, реестры и CI architect не меняет.

КЛЕТКИ: 54. МУТАЦИИ: 19. СВЯЗИ: 30. Носители: 21; bash-носители вместе с обёрткой: 22. Единый источник клеток — CASES/probe.py, связей — MUTATIONS/build.py; source.json генерируется из них. Старые 32 клетки и 19 связей сохранены; новые номера стабов продолжают st12…st19.

Baseline 5fa6b2c294c2dfd677febb200c73dc27467461e6 и пин исторических блобов 6c021128eb8ecde054b26ad22700910412d88f7b — предки результата. Переносятся настоящие review/adversary-блобы 186 и review-блобы прямо названных frozen 201 честных 129/190; меняются идентификатор предмета и OBJECT/SHA на автономные Git-объекты. У 186 review impl-v3 с вызов=1 реализации v2 и у 129 impl-v3/v4 с вызовами 1/2 круга реализации 2 сохранены настоящие метаданные: синтетический filename-only не считается совместимостью.

Б-1 закрыт числовым ключом (поколение, вызов) и историческими формами impl-aN, impl-vV-vyzovK, фаза=реализация vV либо фаза=реализация…круг V вместе с вызовом K. Номер носителя, поколение реализации и локальный вызов различены. Singleton допустим, несколько файлов без определимого порядка отказываются; зарезервированный vyzov-суффикс не маскирует неканонический K. Б-2 закрыт обходом всех полей вызов=, включая второе в одной строке и одинаковый повтор. Канон/инструмент: настоящий Git/date/bash -n/shellcheck. Клетка нужна потому, что эти инструменты сами не удостоверяют семантику выбора вердикта; снятие/граница изменили бы заданное обязательство и не применены.

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

- К-01 · чисто · вход: двери формы листа и ПРОВОДКА guard-каналом; SDACHA_TIMEOUT_SEK=600 SDACHA_BUDZHET_SEK=2400 · - · -
- К-02 · чисто · вход: owner-затравка #1379, task-architect224b и два блока закоммиченного FAIL Crit224; новых предметов нет · - · -
- К-03 · чисто · вход: настоящая клетка 201 world201.live; шесть исторических блобов 186, включая review impl-v3 вызов=1; по четыре review-блоба 129/190 и парные поздние FAIL; frozen 201/186 неизменны · - · -
- К-04 · чисто · вход: только contracts/224 и новая семья 224; context.py читает высшие frozen и выдаёт реальные пересечения; production/CI/журналы чужих зон не правятся · - · -
- К-05 · чисто · вход: CLI W --repo/--model/--stabs/--sintaksis/--catalog/--compatibility/--independent-mutants, consumer и двери листа · - · -
- К-06 · чисто · вход: отсутствие Git/bash/jq/date/stat, carrier hash mismatch, поломка мира/синтаксиса — rc 2, не поимка; результат предмета вне 0/1 именуется ошибкой среды · - · -
- К-07 · чисто · вход: полный настоящий done, реальные check_provodka/check_consumers, Git и date; --model проверяет все поля вызова и старые положительные входы; модель не оракул ожидаемых rc · - · -
- К-08 · чисто · вход: MUTATIONS/build.py и source.json; все старые связи сохранены, новые адресные стабы исполняются отдельно; два независимых мутанта меняют иные операции · - · -
- К-09 · чисто · вход: обе роли × second-conflict/repeat-call/second-invalid и честное call-explanation; исторические version/call-координаты; отказ не создаёт тега · - · -
- К-10 · чисто · вход: rc, stdout/stderr, список done-тегов, peeled target и HEAD; legacy-regress сравнивает полные байты baseline; параллельность подтверждена Git в обе стороны · - · -
- К-11 · чисто · вход: ожидания, baseline bytes, исходный HEAD, source.json и хеши носителей сохранены до вызова; диск субъекта не перечитывается как ожидаемый результат · - · -
- К-12 · чисто · вход: Git plumbing, date ISO, bash -n, validate_std с пинованным shellcheck; генерация носителей из одного SELECTOR/build.py · - · -
- К-13 · н/п · новых секретов, сетевых свидетельств или токена нет; миры с синтетической identity и локальным bare-origin · - · -
- К-14 · чисто · вход: linear/equivalent/no-metadata/call-explanation/singleton-unnumbered; реальные 201/186; все парные честные записи остаются зелёными · - · -
- К-15 · чисто · вход: source.json/catalog и build.py согласуют 54 клетки, 19 мутаций, 30 связей; --model/--stabs выполняют другую меру · - · -
- К-16 · чисто · вход: авторизация done; прежние F/CID/OBJECT/same-OBJECT и fail-closed сохранены; согласованная ложь metadata — прежний остаток с ловцами pre_judge/замок/origin · - · -
- К-17 · н/п · станционный скрипт без продуктовой модели 188; новый writer/реестр/scope_id не вводится · - · -

## Дельта

- К-03 · клетка · bash fixtures/workshop_project/svezhest_verdikta_done_224/red_svezhest_verdikta_done_224.sh --compatibility · 0 · 0
- К-07 · клетка · bash fixtures/workshop_project/svezhest_verdikta_done_224/red_svezhest_verdikta_done_224.sh --independent-mutants · 0 · 0
- К-09 · клетка · bash fixtures/workshop_project/svezhest_verdikta_done_224/red_svezhest_verdikta_done_224.sh --independent-mutants · 0 · 0

## Сырой red-do до реализации

`W --repo .` rc 1. Красны 23 клетки: для каждой роли review/adversary parallel, late-fail, duplicate, missing, conflict, date-order, name-date-conflict, second-conflict, repeat-call, second-invalid; дополнительно historic186-phase-conflict, historic186-phase-no-call и historic186-bad-call-name. Остальные зелёные, включая настоящие 201/186/129/190 и их поздние FAIL.

```text
REPO review-second-conflict RED RC,DIAGNOSIS,TAG_ON_REFUSAL rc=0 stderr=b''
REPO review-repeat-call RED RC,DIAGNOSIS,TAG_ON_REFUSAL rc=0 stderr=b''
REPO review-second-invalid RED RC,DIAGNOSIS,TAG_ON_REFUSAL rc=0 stderr=b''
REPO adversary-second-conflict RED RC,DIAGNOSIS,TAG_ON_REFUSAL rc=0 stderr=b''
REPO adversary-repeat-call RED RC,DIAGNOSIS,TAG_ON_REFUSAL rc=0 stderr=b''
REPO adversary-second-invalid RED RC,DIAGNOSIS,TAG_ON_REFUSAL rc=0 stderr=b''
REPO historic186-phase-conflict RED RC,DIAGNOSIS,TAG_ON_REFUSAL rc=0 stderr=b''
REPO historic186-phase-no-call RED RC,DIAGNOSIS,TAG_ON_REFUSAL rc=0 stderr=b''
REPO historic186-bad-call-name RED RC,DIAGNOSIS,TAG_ON_REFUSAL rc=0 stderr=b''
KLETKI 54 KRASNYH 23
world201.live (0, '')
HISTORIC_RAW historic186 RAW 0 b'' b''
HISTORIC_RAW historic186 GREEN
HISTORIC_RAW historic129 RAW 0 b'' b''
HISTORIC_RAW historic129 GREEN
HISTORIC_RAW historic190 RAW 0 b'' b''
HISTORIC_RAW historic190 GREEN
```

## Сырой честный контроль

`W --model` rc 0; итог полного прогона:

```text
KLETKI 54 KRASNYH 0
```

## Наблюдение процесса

Адрес доставки WORKTREE и BRANCH architect-b в задании отличаются от фактической isolated-копии и требуемой заданием для контракта ветки wip/224/architect. Работа остаётся в выданной isolated-копии, на guard-совместимой ветке; фактические pwd/sha передаются ведущему. Журнал NABLIUDENIA_ARCHITECT.md не правится в wip; кандидат для main без самовольного А-номера: выдавать единую пару actual-cwd/guard-совместимая ветка. Расхождение предотвращает доставка по фактическому sha, не запись в чужой WORKTREE. К ВЛАДЕЛЬЦУ по предмету ничего не вынесено: обязательства и риск frozen не меняются.

Кандидат наблюдения main (класс: процедура дешёвого префлайта; источник: свой прогон): st18 потерял экранирование пробела в bash-regex; ошибка синтаксиса обнаружилась после честного контроля, цена прогона 286.62 с. Rc 2 не зачтён как поимка стаба. После ремонта именно генератора `--sintaksis` дал rc 0 (`SINTAKSIS 22 SHELLCHECK 2`) ДО повторного полного `--stabs`; ловец следующей пачки — дешёвый синтаксис всех сгенерированных носителей перед поведенческой батареей.

## Сырые итоги отдельных режимов

После ремонта st18: `W --stabs`, `W --sintaksis`, `W --catalog`, `W --compatibility`, `W --independent-mutants` — каждый rc 0. Итоги без перевода:

```text
STABY 19 SVJAZI 30 ZHIVYH 0
SINTAKSIS 22 SHELLCHECK 2
KLETKI 54 STABY 19 SVJAZI 30
INDEPENDENT_MUTANTS 2 ZHIVYH 0
first-call-tail review-second-conflict RED RC,DIAGNOSIS,TAG_ON_REFUSAL rc=0 stderr=b''
first-call-tail adversary-second-conflict RED RC,DIAGNOSIS,TAG_ON_REFUSAL rc=0 stderr=b''
single-a-rejected frozen201-risk-same-object RAW 1 b'' b'done: VERDICT_ROUND_MISSING: adversary: verdicts/adversary/contracts-777-impl-a1.md\n'
```

## Финальные двери

С пином shellcheck и бюджетами из раздела «Двери»: pre_critic rc 0 (489.24 с); check_sdacha --run rc 0 (776.16 с); отдельный check_precision_gate rc 0 (15.76 с), с полным набором frozen/done-тегов. Сырые итоги:

```text
КРИТИК: дверь зелёная
СДАЧА: лист зелёный (двери=15 карта=17/17 дельта=3)
OK
```
