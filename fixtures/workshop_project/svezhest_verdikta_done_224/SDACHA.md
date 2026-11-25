# СДАЧА 224 — числовой порядок и граница девяти цифр

Обещание: полный done CLI выбирает максимальный числовой круг отдельно для review/adversary, сохраняет прежние проверки F/CID/OBJECT и все объявления поддерживаемых полей СУД. Наблюдение: rc, раздельные stdout/stderr, done-тег на исходном HEAD; при отказе тега нет, HEAD неизменен. Ожидания — литералы в памяти до запуска субъекта, не значения из результата или диска субъекта.

Источник исправления: единственный блок К-08 Adv224, `0968979ed582624ba9081b584cf087e420367b35:verdicts/adversary/contracts-224-impl-v1.md`, прочитан целиком. База задания и фактический HEAD после fetch/switch: `4841a1a06693e902cdbd919e1fb1e7f510ed12e2`. Исправляется только семья фикстуры; production, frozen-контракт, CI, реестры и прежние семейства не меняются. Это ремонт проверки, не дефект честной production и не самостоятельное разрешение freeze/done.

## Существующее и дельта конструкции

`probe.py` уже строит настоящие Git-миры через world201.world/build, реальные F/OBJECT, две несравнимые ветви и два merge-коммита. `suite` сравнивает rc/трубы/тег/HEAD, регрессии дополнительно сравнивает побайтно с до-224 дверью. Исторические 186/129/190 и настоящий world201.live остаются положительными контролями. Модель и старые мутации генерируются `build.py`; их код не изменён.

КЛЕТКИ: 100. МУТАЦИИ: 23. СВЯЗИ: 62. Носители: 25; bash-носители с обёрткой: 26. Числа взяты из build/catalog; независимая мера — фактические model/stabs-прогоны. Прежние 92 клетки и 56 адресных связей сохранены.

Добавлены четыре сценария для каждой роли:

- `nine-ten-late-fail`: v9 accept, v10 FAIL; rc 1, диагноз называет impl-v10.md, done-тега нет.
- `nine-ten-accept`: v9 FAIL, v10 accept; rc 0, тег указывает на исходный HEAD, обе трубы пусты.
- `nine-digit`: единственный impl-v999999999 accept без СУД-метаданных; rc 0. Отсутствие метаданных изолирует границу номера имени от ограничений полей вызова/фазы.
- `ten-digit`: единственный impl-v1000000000 accept без СУД-метаданных; rc 1, `done: VERDICT_ROUND_INVALID: <роль>: <полный путь>`, done-тега нет.

Для пары v9/v10 номера и даты записываются сразу на двух независимых носителях, не переименовываются после merge. СУД несёт вызов=9/10 и вызов=10/10, даты 2026-11-24 и 2026-11-25; OBJECT один настоящий. До вызова CLI merge-base в обе стороны обязан вернуть 1; носители лендятся двумя --no-ff merge. Adversary-миры сохраняют независимый review accept на том же OBJECT.

## Закрытие К-08

Способ — клетка. Снятие числового порядка или границы девяти цифр ослабило бы frozen-обязательство; граница угроз здесь неприменима. Git/date проверяют объекты/даты, но не выбор максимума двери, поэтому требуется поведенческая клетка на существующем публичном шве.

Н-39: architect привязал стабы к различающим ветвям кодом MUTATIONS/build.py. `replace_one` требует ровно один якорь; старый/новый фрагменты совпадают с операциями предъявленных production-мутантов:

- st22-lexical-order: `if [ "$key" -gt "$best" ]; then` → `if [[ "$key" > "$best" ]]; then`. Отдельные связи к late-fail и accept обеих ролей; каждой связи нужна собственная краснота.
- st23-eight-digit-limit: `[ "${#version}" -le 9 ]` → `[ "${#version}" -le 8 ]`. Отдельные связи к nine-digit обеих ролей. Ten-digit не приписывается этому стабу: на десяти цифрах он отказывает честно.

Как и прежние стабы, новые — полные bash-носители модели с одной заменённой операцией, не двойник Git. Модель не является оракулом ожидаемого результата. Каждый носитель проверяется bash -n, затем вызывается полный CLI. Ошибка среды/синтаксиса — rc 2, не поимка стаба.

Единственный редактируемый реестр связей — MUTATIONS/build.py. Генератор выпускает source.json и требуемый stabs.tsv; carriers() сравнивает TSV побайтно с каноническими строками из manifest до любых режимов, без собственного TSV-парсера. `--catalog` потребляет ту же карту; отдельного ручного словаря нет.

## Двери

W — `bash fixtures/workshop_project/svezhest_verdikta_done_224/red_svezhest_verdikta_done_224.sh`.

Все прогоны выполнены последовательно в выданной isolated-копии. TMPDIR=`$PWD/tmp/architect224d`, вне временных субъектов; VALIDATE_STD_SHELLCHECK=`/home/harness/.local/state/dev-harness/validators/shellcheck/0.11.0/shellcheck`. Baseline --stabs снят до изменения файлов; остальные — после генерации.

- Repo · bash fixtures/workshop_project/svezhest_verdikta_done_224/red_svezhest_verdikta_done_224.sh --repo . · 0 · 0
- Model · bash fixtures/workshop_project/svezhest_verdikta_done_224/red_svezhest_verdikta_done_224.sh --model · 0 · 0
- Stabs · bash fixtures/workshop_project/svezhest_verdikta_done_224/red_svezhest_verdikta_done_224.sh --stabs · 0 · 0
- Sintaksis · bash fixtures/workshop_project/svezhest_verdikta_done_224/red_svezhest_verdikta_done_224.sh --sintaksis · 0 · 0
- Catalog · bash fixtures/workshop_project/svezhest_verdikta_done_224/red_svezhest_verdikta_done_224.sh --catalog · 0 · 0
- Compatibility · bash fixtures/workshop_project/svezhest_verdikta_done_224/red_svezhest_verdikta_done_224.sh --compatibility · 0 · 0
- Independent-mutants · bash fixtures/workshop_project/svezhest_verdikta_done_224/red_svezhest_verdikta_done_224.sh --independent-mutants · 0 · 0

## Карта классов

- К-01 · чисто · вход: семь перечисленных дверей батареи, последовательный запуск; общие pre_critic/check_sdacha этим исправительным заданием не запускались · - · -
- К-02 · чисто · вход: task-architect224d и один блок К-08 закоммиченного Adv224; frozen-текст не правится · - · -
- К-03 · чисто · вход: world201.live и исторические 186/129/190, --compatibility rc 0 · - · -
- К-04 · чисто · вход: только семья fixtures/workshop_project/svezhest_verdikta_done_224/ · - · -
- К-05 · чисто · вход: полный CLI; v10 FAIL и десятизначный номер отказывают до тега · - · -
- К-06 · чисто · вход: прежний fail-closed среды/синтаксиса в suite/install, не менялся · - · -
- К-07 · чисто · вход: --model, все восемь новых клеток зелены, включая положительные полярности · - · -
- К-08 · чисто · вход: st22 и st23 красны каждой из шести новых адресных связей отдельно; --stabs 23/62/0 · - · -
- К-09 · чисто · вход: прежние RECORDS-клетки и четыре independent-mutants сохранены · - · -
- К-10 · чисто · вход: rc/обе трубы/тег/HEAD и побайтная legacy-regress в неизменённом suite · - · -
- К-11 · чисто · вход: литеральные ожидания, HEAD до субъекта и хеши носителей в carriers · - · -
- К-12 · чисто · вход: Git/date/bash -n/validate_std shellcheck; TSV генерируется и побайтно сравнивается с единым источником · - · -
- К-13 · н/п · новых секретов и сети в оракуле нет · - · -
- К-14 · чисто · вход: nine-ten-accept и nine-digit обеих ролей, положительные historical/frozen201 · - · -
- К-15 · чисто · вход: build/catalog 100/23/62, фактические model/stabs 100/0 и 23/62/0 · - · -
- К-16 · чисто · вход: F/CID/OBJECT/same-OBJECT не ослаблены; согласованная ложь остаётся за прежней границей pre_judge/замок/origin · - · -
- К-17 · н/п · станционная фикстура без продуктовой модели, новых writer/scope_id нет · - · -

## Дельта

- К-08 · клетка · bash fixtures/workshop_project/svezhest_verdikta_done_224/red_svezhest_verdikta_done_224.sh --stabs · 0 · 0

## Сырые результаты

```text
ДО, --stabs, rc 0:
STABY 21 SVJAZI 56 ZHIVYH 0

Генерация, rc 0:
NOSITELI 25 STABY 23 SVJAZI 62
--catalog, rc 0:
KLETKI 100 STABY 23 SVJAZI 62
--sintaksis, rc 0:
SINTAKSIS 26 SHELLCHECK 2
--repo ., rc 0:
KLETKI 100 KRASNYH 0
--model, rc 0:
KLETKI 100 KRASNYH 0
MODEL_RC=0

ПОСЛЕ, --stabs, rc 0:
stabs/st22-lexical-order/done_contract.sh review-nine-ten-late-fail RED RC,DIAGNOSIS,TAG_ON_REFUSAL rc=0 stderr=b''
stabs/st22-lexical-order/done_contract.sh review-nine-ten-accept RED RC,TAG_TARGET,STDERR rc=1
stabs/st22-lexical-order/done_contract.sh adversary-nine-ten-late-fail RED RC,DIAGNOSIS,TAG_ON_REFUSAL rc=0 stderr=b''
stabs/st22-lexical-order/done_contract.sh adversary-nine-ten-accept RED RC,TAG_TARGET,STDERR rc=1
stabs/st23-eight-digit-limit/done_contract.sh review-nine-digit RED RC,TAG_TARGET,STDERR rc=1
stabs/st23-eight-digit-limit/done_contract.sh adversary-nine-digit RED RC,TAG_TARGET,STDERR rc=1
STABY 23 SVJAZI 62 ZHIVYH 0
STABS_RC=0
--independent-mutants, rc 0:
INDEPENDENT_MUTANTS 4 ZHIVYH 0
INDEPENDENT_RC=0
--compatibility, rc 0:
world201.live (0, '')
HISTORIC_RAW historic186 RAW 0 b'' b''
HISTORIC_RAW historic186 GREEN
HISTORIC_RAW historic129 RAW 0 b'' b''
HISTORIC_RAW historic129 GREEN
HISTORIC_RAW historic190 RAW 0 b'' b''
HISTORIC_RAW historic190 GREEN
COMPATIBILITY_RC=0
```

У положительных nine-ten-клеток st22 stderr называет impl-v9.md не accept; у nine-digit st23 — `VERDICT_ROUND_INVALID` с ролью и impl-v999999999.md. Честные model/production проходят все новые клетки. В выдержке выше строки с rc=1 приведены без длинного байтового stderr; полный вывод находится в транскрипте прогона. До-стабы заняли 215.35 с; --repo — 142.58 с; последовательная цепь model/stabs/independent/compatibility — 567.37 с. Это длительности команд, не отдельные оценки вложенных режимов.

## Наблюдение процесса

Кандидат для main-журнала без самовольного А-номера: числовой максимум и его лексикографическая подмена неразличимы на однозначных раундах; зелёные 92 клетки и 21/56/0 не доказывали разноразрядность. Источник — Adv224 К-08, класс — конструкция проверки. Закрыто настоящими v9/v10-мирами обеих полярностей и двумя границами ширины для обеих ролей; новые шесть адресных связей красны. NABLIUDENIA_ARCHITECT.md в wip не меняется. WORKTREE из задания — адрес доставки; записи и коммит сделаны только в фактически выданной isolated-копии.
