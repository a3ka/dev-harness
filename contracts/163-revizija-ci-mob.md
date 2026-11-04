# Контракт 163 — ревизия CI мобильного проекта

КЛАСС ЗАДАЧИ: кодовый (контракт + исполняемая красная батарея, модель и обманные стабы; реализация CI — в Complior-mob). КЛАСС РИСКА: рисковый — ложная зелень required `android-e2e` health-продукта после переноса проверок в lanes: прецедент frozen 143/2:3, основание из закрытого перечня — ПД/health-данные. ТРЕК: полный (кодовый, красные тесты; после accept обязательны adversary и reviewer).

КОНТЕКСТ: слово владельца 2026-11-04 ~19:40 UTC: мобильная CI реализуется мобильной сессией; восемь решений записаны в задании architect 163; `docs/ci/REVISION-PLAN.md` Complior-mob PR #160, head `2d16bf8a` (§§1–9), план предшествует исполнению. Живая голова `/home/harness/projects/Complior-mob` `934917b0af80417f90cc5f139a066ddeaedc2231`: `verify_ci_parity.sh` даёт rc 1, 22 расхождения при 143 workflow-командах/92 исключениях, файл долга есть (проба 04.11). Плановый worktree `/home/harness/dev-harness-projects/complior-mob/wt/wip-136-ci` пока не имеет корневого package.json, паритет там rc 2 — вход приёмки только после включения PR #156/главного дерева, а не ложное «22» на том worktree.

## Существующее

- `scripts/verify_ci_parity.sh` (020; проектный режим 136): сверка workflow `run:` и корневого package.json в обе стороны, rc 1 на 22 непрозрачных шагах, исключения из профильного `.harness/registry/ci_parity_exceptions.txt`; обход содержимого вызванных lane-скриптов НЕ выполняет. `scripts/check_precision_gate.sh` (043) зовёт паритет на freeze; храповик долга до 18.11: `.harness/registry/ci_parity_debt.txt`. Харнес 161 ревизует МЕХАНИЗМ и проектное размещение `verify_ci_parity.sh`: сначала 161, затем 163 пользуется его результатом без правки этого скрипта и без второго механизма паритета.
- `fixtures/workshop_project/mob_ci_143/`, frozen `143/2`: DAG/карта/селектор/агрегат/вынос/лекало screen-job; шаблон `model/screen-job.template.yml` сам содержит непрозрачный шаг и перестаёт быть шаблоном для новых экранов без 143 v3. Frozen `141/2` фиксирует тела run-шага 135/118/995 и replay; `118/2` фиксирует same-job Jest до checker; `117/5` требует дословный шаг сверки 123, оставляем его в YAML; `991/2` судит rehearsal/version в ОБОИХ workflows; `139/3` судит отсутствие retry-workflow. Теги `frozen/contracts/{141/2,118/2,143/2,117/5,991/2,139/3}` существуют в дереве станции; это обязательства, а не разрешение тихой правки.
- Прецедент модели/обманных стабов — `fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --model|--stabs|--repo`; живые CI Complior-mob: `.github/workflows/mobile.yml`, `mobile-cloud-e2e.yml`, `mobile/ci-screens.json`, `mobile/scripts/select-ci-screens.cjs`, `ci-aggregate.cjs`, корневой package.json. Инвентарь 22 строк, DAG, целевая схема и риски измерены `docs/ci/REVISION-PLAN.md` PR #160 (§1.1, §2, §4, §6); PR #156 — предпосылка паритетного дерева. Реестр `registry/plan.tsv` уже содержит 141/143 и соседние предметы; PR #501 owner передаёт моб в станцию, PR #160 — план моба.

## Предмет

Один результат: мобильный CI вызывает те же проверки и публикует те же доказательства через один `mobile/scripts/run-mobile-ci.cjs --lane <имя>` и `mobile/scripts/ci-*.{sh,cjs}`; корневой package.json объявляет `ci:*`, КАЖДЫЙ lane-вызов в ОБОИХ workflow — однострочный `npm run ci:<lane>`, а не прямой вызов значения npm-скрипта; 22 непрозрачных шага §1.1 вынесены, файл долга удалён, новых исключений паритета относительно базового `934917b0a` нет. `bash scripts/verify_ci_parity.sh <репо моба>` возвращает 0 с `расхождений: 0`; снятие файла без переноса не принимается. `123 сверка кадров с макетом` в e2e-splash остаётся дословно как в базе (имя и тело), H-checkout и порог 117 не меняются.

Инварианты и порядок A–F (всё в одном окне интеграции; MiniMax — один implementer мобильного проекта; station v+1 — отдельные заморозки ДО опасного cutover):

| Этап | Проверяемый результат / команда |
|---|---|
| A | APK ×5, worker-identity ×5, Maestro-version ×2, HEAD/node/build-identity перенесены в ci-скрипты, исходные outputs/digest до install сохранены. `verify_ci_parity.sh <R>` сообщает уменьшение остатка, `red_mob_ci_143.sh --repo R` и живой mobile CI подтверждают digest/outputs. В обоих workflows отказ при `maestro --version != 2.11.0` остаётся обязательным после переноса; version gate переносится только вместе с 991 v3. |
| B | Селектор/outputs и вынос пачек по `--mode inventar`, без второго списка экранов; `red_mob_ci_143.sh --repo R` судит инвентарь и выбранные workers. |
| C | Тела 117/108 перенесены без изменения поведения; 123 в YAML дословно; батареи `red_mob_ci_143.sh --repo R` и `vkhod_117` в CI продукта судят первый экран. |
| D | Тела 135/118 и Jest-нога перенесены одновременно с новыми заморозками 141 v3, 118 v3, перепинами моделей 141/143 и носителей 147/149; `red_obryv_adb_diagnostika_141.sh --repo R`, батарея 118 `--repo R`, 143 `--repo R` судят replay и порядок внутри lane. Замороженные тексты не правятся без санкционированного v+1. |
| E | Все quality/пилот/cloud и новые экраны — lanes по карте и лекалу 143 v3; 150 (замер) сразу получает lane-форму. Вызовы во всех jobs обоих workflows — строго `npm run ci:<lane>` одной строкой; npm исполняет реальные проверки, прямой вызов того же раннера не засчитывается даже при rc 0 паритета; оба workflows проходят живой CI; `ci-aggregate.cjs`, needs/if/outputs, PNG/TSV/APK/маркер свежести сохранены. |
| F | Чистка мёртвых исключений и удаление долга только после A–E; `verify_ci_parity.sh <R>` rc 0, `расхождений: 0`, `test ! -e <R>/.harness/registry/ci_parity_debt.txt` rc 0; допуск нового исключения вместо переноса запрещён батареей 163. |

Восемь закрытых решений владельца: node `.cjs`; 123 без изменения; version gate скриптом с 991 v3; 150 под lane; cutover одним окном; v+1 станции 141/118/143/991 — работа харнесса в этом окне; lanes через npm-скрипты; до 18.11 ускорение параллельной подготовкой канонов, продление долга — только отдельное слово владельца. До freeze D/E оркестратор получает четыре заявки v+1 с точными frozen-дельтами; 163 сам ни frozen-текст, ни `verify_ci_parity.sh` не переписывает. Если единый контракт оказывается неделимым для freeze A–F, оркестратор решает нарезку до раздачи, не наращивает критерий при исполнении.

## Приёмочный критерий

`W = python3 fixtures/workshop_project/revizija_ci_mob_163/probe.py` (из корня харнесса). Конформный вход: YAML workflow и корневой package.json читаемы, соответствуют схеме GitHub Actions и npm; `.harness/registry/ci_parity_exceptions.txt` проекта содержит записи грамматики паритет-гейта; `--repo` указывает дерево Complior-mob, в том числе shallow checkout CI. Базовые 92 ключа исключений из коммита `934917b0a` сохранены в `baseline-exception-keys.sha256` отдельными SHA256 (сверены с git на входе пачки), читаются в память ДО проверяемого дерева: кандидат не обязан хранить исторический коммит. Валидный контрпример: структурно конформный вход, различающийся на заявленном инварианте; значения имён экрана/путей, не меняющие инвариант, не должны давать самопроизвольного отказа (cognitive-only: ловец — независимый критик на новом экране карты).

### Красное сейчас

1. Дано: живое основное дерево Complior-mob до cutover. Когда `W --repo /home/harness/projects/Complior-mob`. Тогда rc 1, `DOLG_NE_SNJAT` и `PARITET_RC_1` (22 расхождения). Если база дерева обновилась — та же команда на последней ветке до cutover и отдельный отчёт фактического rc, не фальшивый зелёный.

### После реализации

2. Дано: схема целевых lanes в `model/`. Когда `W --model`. Тогда rc 0: паритет rc 0; npm-команды двух workflows исполняют отдельные model lanes; Maestro 2.11.0 проходит, 2.10.0 отказывает с `MAESTRO_VERSION_MISMATCH` в station- и cloud-ветвях до батарей; 123 побайтово неизменен.
3. Дано: девять отдельных мутаций модели. Когда `W --stabs`. Тогда rc 0, «стабов 9, непойманных 0»: собственный отказ по утрате батареи, удалению долга без переноса, новому исключению, правке 123, прямому вызову раннера в каждом workflow при неизменном npm-скрипте, утрате version gate отдельно для station и cloud; честный контроль зелён до мутаций. Та же команда запускает `--repo`-контроль в одноразовом дереве БЕЗ `.git`: удалённый базовый коммит в shallow checkout не становится ложным отказом. Каждый мутант — отдельный rc 1 по собственному инварианту.
4. Дано: законченный продукт R после A–F и станции v+1. Когда `W --repo R`, `bash scripts/verify_ci_parity.sh R` и `python3 fixtures/workshop_project/rehearsal_991/probe.py --repo R` версии 991 v3. Тогда все три команды rc 0; паритет печатает строго `расхождений: 0`, файл долга отсутствует; 991 v3 `--repo R` исполняет version gate в ОБОИХ workflows с подставленной через PATH версией 2.10.0 → ненулевой rc и `MAESTRO_VERSION_MISMATCH`, с 2.11.0 → rc 0, а не только наличие имени шага; без такого replay 991 v3 cutover не принят. `red_mob_ci_143.sh --repo R`, 141 v3 `--repo R`, 118 v3 `--repo R` и 117 v5 `--repo R` rc 0, H-checkouts перепинены только на замороженные совместимые версии.
5. Дано: revision-ветка R. Когда GitHub Actions `mobile` и `mobile-cloud-e2e` исполняются на одном sha, тогда conclusion==success по обоим и upload-artifact содержит APK с digest, кадры, selection, TSV 123 и regression-marker. Для рискового required `android-e2e` после accept обязательны независимые adversary и reviewer; они сверяют фактические run id, вызовы батарей и загруженные артефакты. Когнитивный остаток до живого CI: модель не доказывает hosted/self-hosted env, KVM, секрет PILOT_DEMO_CODE.
6. Когда `bash scripts/pre_critic.sh contracts/163-revizija-ci-mob.md`, `bash scripts/check_ceilings.sh`, `bash scripts/check_precision_gate.sh . contracts/163-revizija-ci-mob.md`, `bash scripts/check_threat_model.sh . contracts/163-revizija-ci-mob.md`, `bash scripts/check_spec_ready.sh . contracts/163-revizija-ci-mob.md`. Тогда каждый rc 0; `bash scripts/check_provodka.sh . contracts/163-revizija-ci-mob.md` до freeze — именованный rc 1 (потребитель шага ещё не подключён), до done rc 0.

## Модель угроз

ЗАЩИЩАЕТ:
- Удаление временного долга без переноса вызывает паритетный отказ; новый обход исключением фиксируется отдельно относительно базового набора исключений проекта.
- `W --repo R` судит буквальный npm-маршрут каждого lane-вызова в обоих workflow, даже когда прямой вызов совпадает со значением npm-скрипта и паритет зелён.
- Модель отвергает пустую реализацию lane, утрату батареи, изменение шага 123 и утрату Maestro version gate в каждой из двух ветвей: ошибочная версия даёт именованный отказ до запуска батареи.
НЕ ЗАЩИЩАЕТ:
- Паритет и модель не видят выпадение настоящей батареи или version gate из lane-скрипта продукта; 991 v3 `--repo R` судит version replay в обоих workflows, адресные v+1 судят replay и пины остальных скриптов; adversary, reviewer и живой CI сверяют required health-результат.
- Локальная модель трёх lanes не подменяет системный прогон двенадцати job и независимую проверку новых экранов по карте.

ПРЕДПОСЫЛКИ:
- setting Существующие GitHub Actions mobile и mobile-cloud-e2e, required android-e2e, self-hosted runner/KVM и pinned H-checkout остаются доступными без новых permissions, variables или environments.
- setting Существующий secret PILOT_DEMO_CODE в CI Complior-mob остаётся объявленным только для e2e-pilot; новая секретная настройка не требуется.
- setting Существующие права upload-artifact, корневой package.json после PR #156 и проектный профиль нужны до проверки паритета; новые права и секреты не заводятся.

## Зоны и проводка

ЗОНА architect: contracts/163-revizija-ci-mob.md
ЗОНА architect: fixtures/workshop_project/revizija_ci_mob_163/
ЗОНА implementer: mobile/scripts/
ЗОНА implementer: mobile/scripts/run-mobile-ci.cjs
ЗОНА implementer: package.json
ЗОНА implementer: .github/workflows/mobile.yml .github/workflows/mobile-cloud-e2e.yml
ЗОНА implementer: .harness/registry/ci_parity_debt.txt .harness/registry/ci_parity_exceptions.txt
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml
ПЕРЕСЕЧЕНИЕ implementer: .github/workflows/mobile.yml — 151 существующая доставка Gespraech остаётся вызываемой из lane; собственный шаг 151 не меняется
ПЕРЕСЕЧЕНИЕ implementer: package.json — 011 продуктовый package.json получает только ci:*; пакет станции 011 не меняется
ПЕРЕСЕЧЕНИЕ implementer: package.json — 015 продуктовый package.json получает только ci:*; пакет станции 015 не меняется
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 добавление только шага 163; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 добавление только шага 163; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 добавление только шага 163; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 добавление только шага 163; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 добавление только шага 163; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 добавление только шага 163; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 добавление только шага 163; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 добавление только шага 163; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 добавление только шага 163; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 добавление только шага 163; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 добавление только шага 163; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 добавление только шага 163; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 добавление только шага 163; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 добавление только шага 163; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 добавление только шага 163; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 добавление только шага 163; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 добавление только шага 163; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 добавление только шага 163; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 добавление только шага 163; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 добавление только шага 163; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 добавление только шага 163; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 добавление только шага 163; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 добавление только шага 163; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 добавление только шага 163; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 добавление только шага 163; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 добавление только шага 163; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 добавление только шага 163; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 добавление только шага 163; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 добавление только шага 163; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 добавление только шага 163; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 добавление только шага 163; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 добавление только шага 163; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 добавление только шага 163; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 добавление только шага 163; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 добавление только шага 163; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 добавление только шага 163; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 добавление только шага 163; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 добавление только шага 163; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 добавление только шага 163; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 добавление только шага 163; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 добавление только шага 163; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 добавление только шага 163; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 добавление только шага 163; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 добавление только шага 163; чужие шаги не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 добавление только строки 163; чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 добавление только строки 163; чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 добавление только строки 163; чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 добавление только строки 163; чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 добавление только строки 163; чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 добавление только строки 163; чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 добавление только строки 163; чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 добавление только строки 163; чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 добавление только строки 163; чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 добавление только строки 163; чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 добавление только строки 163; чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 добавление только строки 163; чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 добавление только строки 163; чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 добавление только строки 163; чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 добавление только строки 163; чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 добавление только строки 163; чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 добавление только строки 163; чужие строки не меняются
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 добавление только замера 163; чужие строки не меняются


ПРОВОДКА:
- guard=fixtures/workshop_project/revizija_ci_mob_163/probe.py

ПРОВОДКА-ЭНФОРСМЕНТ: проверка CI является чистым enforcement; family-selftest `--stabs` в CI станции до продукта, `--repo <корень Complior-mob>` после cutover; оркестратор подключает строку своей батареи в окне freeze..done через `gen_ci_steps.sh --write` и `--check`, чужие строки не меняются.

## Незаполненные требования:
нет
