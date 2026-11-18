accept
OBJECT=c1f73e89c6916f5c5d991729ba647b5e19213d0e

# Ревьюер, scoped-повтор: owner-PR a3ka/dev-harness#1100 (`owner/adr-schet-uzkih`) — закрытие Б-1 `Rev1100` и регресс дельты

СУД: repo=dev-harness; предмет=owner-PR #1100 (манифест двери SUBJECT=129 — технический номер, пара `wip/129/architect` сдвинута на OBJECT по прецеденту Rev1087b); фаза=scoped-повтор (закрытие Б-1 и регресс дельты); роль=reviewer; вызов=scoped 1 из ≤1 (предел 1 полный + ≤1 scoped; полный — `Rev1100` FAIL); модель-план=anthropic/claude-opus-5-5; сессия=Rev1100b; модель-факт=anthropic/claude-opus-5-5 (allowed); SHA=c1f73e89c6916f5c5d991729ba647b5e19213d0e; предыдущий=`verdicts/review/owner-adr-schet-uzkih-1100.md` (FAIL, OBJECT 5956004d69, ветка `verdict/rev1100-owner-adr-schet-uzkih` `b31c75c344`, PR #1104); исключение=нет. Запись до вызова — в state-HANDOFF; дописку факта делает оркестратор.

- Модель-факт: `bash scripts/models_actual.sh --tsv --bind --session Rev1100b | cut -f1-3`, основной чекаут `/home/harness/dev-harness`, только чтение, rc 0, Wed Nov 18 19:33:25 UTC 2026.
- Клон: `/tmp/dev-harness-verify/Rev1100b/repo` (`git clone ssh://git@github.com/a3ka/dev-harness.git`, `git fetch --tags origin`). `origin/owner/adr-schet-uzkih` = OBJECT; origin/main = `b5dc206db3`; merge-base `662d6a7442`.
- Дельта к прежнему объекту: один коммит `c1f73e89` (author=committer=owner), 2 файла, +4/−4, оба в `docs/owner/adr/`.
- Файл находок (reslop): `.review/2026-11-18-115.md`.
- Объём: только п.1 (закрытие Б-1) и п.2 (регресс дельты) задания. Полный повторный обзор не проводился.

## Итог

accept. Б-1 закрыт вариантом (а). В двух ADR одна и та же фраза сохраняет шаг арбитража устава после третьего вызова критика без accept. В обеих секциях cognitive-only записан риск, что кап кругов серию FAIL→accept не ловит. Ловцы названы. Дельта — ровно 2 ADR-файла. Устав, роли, скрипты и frozen не тронуты. `check_charter` и `check_protected` на дереве OBJECT дают rc 0. Блоков нет, советы ниже.

## 1. Закрытие Б-1

**Новый текст** (оба места дословно одинаковы; своя мера — sha256 вырезанных фраз совпадает, вывод ниже):
- `schet-uzkih-vyzovov.md:8` (п.2) и `ekrany-mob-byudzhet-sudov.md:7` (п.1): «Арбитраж не заменяется: после третьего вызова критика по предмету без accept санкция по этому счёту — только после арбитража о конечной границе (AGENTS.md §Арбитр, `roles/critic.md §Остановка`); арбитра созывает сессия без владельца (правило 15), узкий вызов на исполнение решения арбитра — по §Остановка.»
- `schet-uzkih-vyzovov.md:15` и `ekrany-mob-byudzhet-sudov.md:21` (cognitive-only): «Кап кругов `freeze_contract.sh` серию FAIL→accept не ловит (подряд одинаковые классы сжимаются) — пропуск арбитража после третьего вызова машина не видит.»

**Достижимое состояние Б-1, пройденное по новому тексту.**
1. Вызов 1 (полный) — FAIL. Вызов 2 (исправительный) — FAIL. В счёт п.1 они не входят.
2. Вызов 3 — санкция №1 консультанта. Это совпадает с «один по санкции» в roles/critic.md:32 §Остановка. Результат — FAIL.
3. Санкция №2 теперь допустима только после арбитража о конечной границе. Это и есть AGENTS.md:103–106: «3 вызова критика → один арбитраж о границе → один узкий вызов». Вызов 4 — «узкий вызов на исполнение решения арбитра — по §Остановка». Это roles/critic.md:32: «после исполнения — один узкий вызов критика только на исполнение решения арбитра».
4. После вызова 4 счёт п.1 исчерпан, дальше — владелец (`schet:9`, `ekrany:9`). Это AGENTS.md:106 «дальше — слово владельца».

Две санкции консультанта на этом пути ложатся ровно на два дополнительных вызова §Остановка: третий по санкции и узкий после арбитража. Поэтому «дополнительные вызовы разрешаются только по §Остановка» (roles/critic.md:28 §Контракт, §Быстрый-процесс) тоже соблюдено.

**«Устав не меняется» теперь правдиво.** `schet:14` («что не меняется: … роли, устав …») и `ekrany:14` («… текст ролей, устав») больше не расходятся с решением. Шаг §Арбитр сохранён прямо, со ссылками на оба уставных места. Прямого противоречия с AGENTS.md §Арбитр (:103–109), roles/critic.md §Остановка (:32), §Счёт (:34) и roles/critic.md:168–172 («третий вызов по санкции, после него арбитраж о конечной границе и один узкий вызов») не установлено.

**Согласованность двух ADR.** Фраза об арбитраже стоит в ADR экранов в п.1 (Счёт). На п.1 ссылается и п.2 «основание от судьи реализации» («счёт и предел — по п.1»). Значит, условие арбитража связывает и вызовы по основанию от ревьюера или адверсария. В ADR счёта фраза стоит в п.2 (условия вызова), который действует на каждую санкцию по этой ADR. Риск-строки в обеих cognitive-only одинаковы.

**Риск и ловец (правило 1, AGENTS.md:218–219).** Риск записан в обеих ADR. Своя мера подтверждает его: блок счёта кругов `scripts/freeze_contract.sh` (найден шаблоном от `_events="$(mktemp)"` до `trap - EXIT`), исполненный на синтетической истории, даёт `FAIL FAIL FAIL accept → circles=2 cap=not-triggered`. Контроль красного: `FAIL accept FAIL accept → circles=4 cap=TRIGGERED`. Ловцы названы: ревьюер предмета по записи СУД и внешний консультант по журналу (`schet:15`, `ekrany:21`). Пропуск арбитража ревьюер видит по записи СУД, сверяя её с наличием `verdicts/arbitration/` с титулом предмета.

**Новая дыра в формулировке — блоков нет.** Разобраны следующие случаи.
- *Что считать «третьим вызовом».* Фраза говорит «третьего вызова критика по предмету», а не «по счёту п.1». Значит, считаются все вызовы, включая базовые и по слову владельца. Правило счёта взято по ссылке из roles/critic.md:32: «считая вызов с accept и новые платные сессии после обрыва; версия, переименование и арбитраж счёт не обнуляют». Расхождения с уставом нет.
- *Кто ведёт учёт.* Счёт ведёт консультант сессии по записям СУД в HANDOFF (`schet:15`). Запись делает оркестратор, а ревьюер и арбитр её сверяют (roles/critic.md:34 §Счёт). Это не противоречит уставу.
- *Вызов по слову владельца на месте третьего.* Пример: базовые 1–2 FAIL, вызов 3 по слову владельца FAIL, арбитраж, вызов 4 — санкция №1 на исполнение решения арбитра, FAIL. По счёту п.1 остаётся санкция №2 (вызов 5), хотя устав после узкого вызова говорит «дальше — слово владельца». Это следствие исходного правила счёта, а не дельты. Слово владельца исключено из счёта ещё в `5956004d` (`schet:7`). Санкция по ADR 17.11 и 18.11 — стоячее слово владельца: так уже принято в `Rev1100`, раздел «Правило 12». roles/critic.md:32 «оркестратору НЕ делегированы» консультанта сессии не касается. Блока по порогу задания нет, это совет С-5.
- *«Без accept» при accept раньше.* Пример по ADR экранов п.2: вызов 2 — accept, вызов 3 по основанию от судьи реализации — accept. Тогда вызов 4 по тексту возможен без арбитража. Но формулировка повторяет условие устава («после третьего вызова без accept», roles/critic.md:32) и новой дыры не вносит. Общий предел трёх вызовов «считая вызов с accept» здесь перекрыт стоячим словом владельца (ADR 17.11), как и в предыдущем пункте.

Б-1 — **закрыт**.

## 2. Регресс дельты

- `git diff --name-only 5956004d69..c1f73e89` даёт ровно `docs/owner/adr/2026-11-18-ekrany-mob-byudzhet-sudov.md` и `docs/owner/adr/2026-11-18-schet-uzkih-vyzovov.md`. `--stat` и `--numstat`: 2 файла, +4/−4 (2/2 в каждом). Совпадает с заявленным.
- Вне `docs/owner/adr/` изменений нет: `git diff --quiet 5956004d69 c1f73e89 -- . ':!docs/owner/adr'` → rc 0. Устав и смежное (`AGENTS.md ROADMAP.md roles scripts frozen plans contracts config .github`) не тронуты: `--quiet` → rc 0 и для дельты, и для `origin/main...OBJECT`.
- `bash scripts/check_charter.sh` → rc 0 («уставных документов: 181 · изменений в них: 525 · с разрешения: 525»). `bash scripts/check_protected.sh` → rc 0 («коммитов пройдено: 8436 · … исчезло: 0»). Оба запуска — на дереве OBJECT в одноразовом клоне.
- roles/critic.md §Быстрый-процесс: §Контракт :28 («дополнительные вызовы разрешаются только по §Остановка») — соответствует (см. п.1). §Остановка :32 и §Счёт :34 — соответствует. Противоречий нет.
- ADR 2026-11-17 (`uzkij-kritik-konsultant-sessii.md:5`): «правило применяется поверх» §Остановка. Арбитраж оно не отменяет, предметы старого порядка оставляет за арбитром. Новая фраза с ним согласуется. Противоречий нет.
- Прочий текст обеих ADR по сравнению с `5956004d` не изменён: в каждой правке добавлено по одной фразе в две строки, и больше ничего.

## Блоки

Нет.

## Советы (не блокируют) — в `.review/2026-11-18-115.md`

- С-1…С-4 из `Rev1100` (`.review/2026-11-18-114.md`) дельта не трогает, они остаются советами. С-2: поля «рассмотренные варианты» в `schet-uzkih-vyzovov.md` по-прежнему нет. С-3: в ADR экранов:5 «… без изменений» осталось.
- С-5. Стоит одной фразой сказать, что после узкого вызова на исполнение решения арбитра следующий вызов — только словом владельца, даже если по счёту п.1 санкция ещё осталась (случай «вызов 3 по слову владельца», п.1 выше). Так текст совпадёт с AGENTS.md:106 «дальше — слово владельца» без опоры на стоячее слово.
- С-6. Ссылка «(правило 15)» относится к созыву «без согласия автора» (AGENTS.md:261–262). Созыв «без владельца» прямо записан в AGENTS.md:111–112 (§Арбитр: «Будить владельца ради спора двух ролей — трата…») и в roles/critic.md:174–175. Ссылку точнее дать на §Арбитр. На суть это не влияет.

## ОСТАТОК (строки `НЕ ЗАЩИЩАЕТ` с ловцом reviewer; манифест двери — 192/129)
- ОСТАТОК: contracts/192-normy-roley-svyazki.md:41, :43, :45 — не укусили. Дельта не трогает `roles/`, `norms.tsv`, `drafts/` и якоря ролей (`--quiet` по `roles` → rc 0).
- В contracts/129-fallback-subagent.md строк с ловцом reviewer нет. Это установлено полным проходом `Rev1100`, а файл в дельте не менялся.

## СВЕРКА-СТАНДАРТОВ
СВЕРКА-СТАНДАРТОВ: н/п. `AGENTS.md` харнесса не объявляет `docs/ARCHITECTURE.md`/`docs/CODING-STANDARDS.md`, дифф некодовый.

## СВЕРКА-АРХИТЕКТУРЫ
СВЕРКА-АРХИТЕКТУРЫ: размещение — `docs/owner/adr/`, соответствует. Зависимостей, писателей и операций не добавлено. `bindings.json` не тронут. Долг не расширен: риск записан в cognitive-only. Diff модели нет, L-уровня нет, `finding new` не заводился.

## Паразитная сложность (контракт 050)
Новых артефактов нет: в два существующих ADR добавлено по две фразы.
1. Свойство — сохранение шага §Арбитр (Б-1).
2. Состояния не вводится.
3. При следующей правке того же свойства вместе меняются 2 файла (обе ADR). Число не выросло: правило счёта уже жило в обоих.
4. Интерфейса нет.
5. Потребители — консультант сессии и ревьюер по записи СУД.

ESSENTIAL.

## Сырые команды и вывод

```
$ git clone -q ssh://git@github.com/a3ka/dev-harness.git /tmp/dev-harness-verify/Rev1100b/repo && git fetch -q --tags origin && git checkout -q c1f73e89c6916f5c5d991729ba647b5e19213d0e && git log --oneline -3 && git branch -r --contains HEAD
c1f73e89 owner: ADR счёта и ADR экранов — арбитраж после третьего вызова без accept сохраняется (Rev1100 Б-1)
5956004d owner: ADR 2026-11-18 — счёт «не более двух» узких вызовов критика только по санкциям консультанта сессии, для всех предметов
662d6a74 land: wip/201/implementer ALLOW-ARTIFACT-DELETE: …
  origin/owner/adr-schet-uzkih
$ git rev-parse HEAD origin/main origin/owner/adr-schet-uzkih; git merge-base origin/main HEAD
c1f73e89c6916f5c5d991729ba647b5e19213d0e
b5dc206db32d0c0032a7262fb3edc82da8b67ae5
c1f73e89c6916f5c5d991729ba647b5e19213d0e
662d6a7442a95425ec791518e8b301fb4fdd3977
$ git log --format='%H %an <%ae> | %cn <%ce> | %s' 5956004d69..HEAD
c1f73e89c6916f5c5d991729ba647b5e19213d0e owner <owner@dev-harness.local> | owner <owner@dev-harness.local> | owner: ADR счёта и ADR экранов — арбитраж после третьего вызова без accept сохраняется (Rev1100 Б-1)
$ git diff --name-only 5956004d69..HEAD; echo rc=$?
docs/owner/adr/2026-11-18-ekrany-mob-byudzhet-sudov.md
docs/owner/adr/2026-11-18-schet-uzkih-vyzovov.md
rc=0
$ git diff --stat 5956004d69..HEAD
 docs/owner/adr/2026-11-18-ekrany-mob-byudzhet-sudov.md | 4 ++--
 docs/owner/adr/2026-11-18-schet-uzkih-vyzovov.md       | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)
$ git diff --numstat 5956004d69..HEAD
2	2	docs/owner/adr/2026-11-18-ekrany-mob-byudzhet-sudov.md
2	2	docs/owner/adr/2026-11-18-schet-uzkih-vyzovov.md
$ git diff --name-only origin/main...HEAD; git diff --stat origin/main...HEAD
docs/owner/adr/2026-11-18-ekrany-mob-byudzhet-sudov.md
docs/owner/adr/2026-11-18-schet-uzkih-vyzovov.md
 docs/owner/adr/2026-11-18-ekrany-mob-byudzhet-sudov.md |  4 ++--
 docs/owner/adr/2026-11-18-schet-uzkih-vyzovov.md       | 17 +++++++++++++++++
 2 files changed, 19 insertions(+), 2 deletions(-)
$ git diff --quiet 5956004d69 HEAD -- AGENTS.md ROADMAP.md roles scripts frozen plans contracts config .github; echo rc_quiet_delta=$?
rc_quiet_delta=0
$ git diff --quiet origin/main...HEAD -- AGENTS.md ROADMAP.md roles scripts frozen plans contracts config .github; echo rc_quiet_branch=$?
rc_quiet_branch=0
$ git diff --quiet 5956004d69 HEAD -- . ':!docs/owner/adr'; echo rc_quiet_outside_adr=$?
rc_quiet_outside_adr=0

$ (detached c1f73e89) bash scripts/check_charter.sh 2>&1 | tail -n 3; echo rc_charter=${PIPESTATUS[0]}
  ok   plans/007-reglament-vorkflou.md — уставной с frozen/plans/007/1, коммитов в диапазоне 8350, изменений без разрешения нет

уставных документов: 181 · изменений в них: 525 · с разрешения: 525
rc_charter=0
$ bash scripts/check_protected.sh 2>&1 | tail -n 3; echo rc_protected=${PIPESTATUS[0]}
  ok   исчез с явного разрешения: verdicts/review/contracts-105-land-v2.md

область: :(literal)decisions/proxy/ :(literal)plans/ :(literal)verdicts/adversary/ :(literal)verdicts/arbitration/ :(literal)verdicts/consultant/ :(literal)verdicts/critic/ :(literal)verdicts/review/ · коммитов пройдено: 8436 · существовало: 1957 · на HEAD: 1837 · исчезло: 0 · с разрешения: 98 · перенесено: 22
rc_protected=0

$ (cwd docs/owner/adr) for f in schet ekrany; do sed -n 's/.*\(Арбитраж не заменяется:.*§Остановка\.\).*/\1/p' $f | sha256sum; sed -n 's/.*\(Кап кругов `freeze_contract.sh` серию FAIL→accept не ловит[^.]*\.\).*/\1/p' $f | sha256sum; done
2026-11-18-schet-uzkih-vyzovov.md
79c7b6cbb519e0a7f1cec9869979df4574edb096efab83b5dc2987604a9ba6cc  -
aa670d1f58881350ff2466dc43d79c0c13594e3c8e300d94b10f7779ae45111e  -
2026-11-18-ekrany-mob-byudzhet-sudov.md
79c7b6cbb519e0a7f1cec9869979df4574edb096efab83b5dc2987604a9ba6cc  -
aa670d1f58881350ff2466dc43d79c0c13594e3c8e300d94b10f7779ae45111e  -

$ (cwd /home/harness/dev-harness) bash scripts/models_actual.sh --tsv --bind --session Rev1100b | cut -f1-3; echo rc=${PIPESTATUS[0]}; date -u
reviewer	anthropic/claude-opus-5-5	allowed
reviewer	anthropic/claude-opus-5-5	allowed
rc=0
Wed Nov 18 19:33:25 UTC 2026
```

Своя мера по риску cognitive-only: `/tmp/dev-harness-verify/Rev1100b/circles_probe.sh`, вне репозитория. Скрипт вырезает блок счёта кругов из `freeze_contract.sh` дерева OBJECT шаблоном (`/^_events="\$(mktemp)"$/,/^trap - EXIT$/`) и исполняет его на синтетическом git-репозитории. В этом репозитории один файл `verdicts/critic/contracts-301-v1-probe.md`, первая строка которого меняется коммитами:
```
$ for s in "FAIL FAIL FAIL accept" "FAIL FAIL FAIL FAIL accept" "FAIL accept FAIL accept" "FAIL FAIL accept FAIL"; do bash circles_probe.sh repo/scripts/freeze_contract.sh $s; echo rc=$?; done
seq=FAIL FAIL FAIL accept circles=2 cap=not-triggered
rc=0
seq=FAIL FAIL FAIL FAIL accept circles=2 cap=not-triggered
rc=0
seq=FAIL accept FAIL accept circles=4 cap=TRIGGERED
rc=0
seq=FAIL FAIL accept FAIL circles=3 cap=TRIGGERED
rc=0
```

Номер `.review`:
```
$ git fetch -q origin '+refs/heads/*:refs/remotes/origin/*'; for r in $(git for-each-ref --format='%(refname)' refs/remotes/origin); do git ls-tree --name-only "$r" .review/; done | sed -n 's#^\.review/2026-11-18-\([0-9]*\)\.md$#\1#p' | sort -un
104 105 106 107 108 109 110 111 112 113 114
(refs: 1088) → 115
```

## Развилки
1. Практика 147: `Crit147G2` вызван как «санкция консультанта сессии №1 из 2, ADR 2026-11-18» при 17 вердиктах критика и без арбитража с титулом «(контракт 147)». Это установлено полным проходом `Rev1100`. По новому тексту такая санкция требовала бы арбитража. Как считать уже выданный accept 147 — вне объёма этого повтора, решение за консультантом или владельцем.
2. Номер `.review/2026-11-18-115.md` взят как следующий свободный по origin/main и всем 1088 remote-ref. Если параллельный ревьюер возьмёт тот же номер, носитель переименует файл при материализации.
