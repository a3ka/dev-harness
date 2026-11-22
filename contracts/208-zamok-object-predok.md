# Контракт 208 — замок предмета: OBJECT судьи допускается по предковости, а не по равенству tip последнего рабочего START (D9)

КЛАСС РИСКА: рисковый — дверь замка предмета решает, на какой OBJECT допускается судья (critic/adversary/reviewer) предмета; ошибка открывает суд чужой/непроверенной работе или навсегда блокирует done-путь; основание закрытого перечня: «безопасность/авторизация» (периметр допуска судей станции).

КОНТЕКСТ: номер 208 выдан `next_id` (тег `id/CONTRACT/208`, строка реестра `6739c25cc`); owner-затравка влита (PR #1232 `25b66070fd`, РАЗРЕШИЛ-ВЛАДЕЛЕЦ: «стартовые затравки двух новых контрактов станции — ускорение check_zones --incr и допуск судьи по предковому OBJECT в замке (D9); боль и решение, заменяются архитектором целиком; SLOVO обоих в учёт замка»); строка плана 208 — owner #1239 (пара 3); направления консультанта 22.11 13:58 (предковость+публикация) и 14:10 (очередь, adversary → reviewer); задание станции `/tmp/dev-harness-verify/task-arch208.md`.

## Существующее

Дерево — истина; срез `b8ecb8053` (origin/main).

1. **Дверь уже стоит и заморожена** — `scripts/zamok_predmeta.sh` (контракт 140, frozen 5; эталон `fixtures/workshop_project/odin_agent_140/model/zamok_predmeta.sh`): режим `--sudit` судит пакет спавна; судейская ветка гейта `[D9]` сегодня требует `OBJECT задания == object_kandidata(ветка последнего рабочего START)` — точное равенство; кандидат — peeled tip (вердиктный хвост снимается, D43/D44-D49); `[D50]` пустая дельта tip против первого родителя — отказ. Общий resolver `--object/--snapshot` потребляют `pre_judge.sh` (172) и `--peredat` — тем же кодом.
2. **Повтор роли уже ограничен** — `[D11]`: повтор той же роли на том же OBJECT — `OBJECT_UZHE_SUZHEN`; слово владельца 21.11 00:55 добавило строку задания `РАЗРЕШИЛ-ВЛАДЕЛЕЦ-ПОВТОР: <NNN> <роль> <OBJECT>` (ровно одна, адресная, один круг при `krugov_suda == 1`); круги считает `krugov_suda`, обрыв `obryv_bez_verdikta` круг не тратит (контракт 167). Второй класс боли (152/177): слово владельца, записанное в учёте, дверью не читается — назначение «по одному scoped adversary на <OBJECT>» неисполнимо без правки текста задания.
3. **Измеренная боль первого класса** (бэкенд 179/007/182, 152/177): равенство отказывает там, где работа и судимый OBJECT связаны предковостью — accept ревьюера на предке кандидата (`OBJECT_RASHODITSJA`), судья на ушедшей вперёд работе (`OBJECT_RASHODITSJA`/`VETKA_NEDOSTUPNA`), merge с «неверным» порядком родителей даёт пустую дельту tip → резолвер отказывает.
4. **Батареи-соседи** (не дублируются): `fixtures/workshop_project/odin_agent_140/` (дверь целиком; на этом дереве `--model` rc 0, 172 клетки), `fixtures/workshop_project/obryv_167/` (rc 0), `fixtures/parsing_hygiene_battery/profiles/zamok_predmeta.sh` (гигиена парсинга двери, клетки повтора и-о; rc 0), `fixtures/workshop_project/sdacha_193/` (форма сдаточного листа).
5. **Пересечение с живой работой 140 A2**: PR #1238 (`wip/int-140/orch-sh2h` `378e45782e`, accept Rev140A2S) переписывает `na_pauze` и цикл паузы той же двери; ленд A2 — после 207; реализация 208 — ПОСЛЕ ленда A2 (одна дверь — один пишущий в момент).
6. **Третий класс боли — вне предмета**: `scripts/done_contract.sh` берёт вердикт адверсария под фиксированным именем `verdicts/adversary/contracts-<NNN>-v1.md` (станция, done 992, 22.11) и не видит свежий вердикт под другим номером. Это ДРУГОЙ механизм (done-путь, выбор вердикта по имени), другая зона (`scripts/done_contract.sh`) и другой наблюдаемый результат; по правилу «один новый отказ — один контракт» (061) и вертикальному слайсу (050) выносится в отдельный предмет — здесь только граница в «НЕ ЗАЩИЩАЕТ».

## Предмет и последовательность

Один наблюдаемый результат: судья предмета допускается дверью на OBJECT, связанный ПРЕДКОВОСТЬЮ с кандидатом K последнего рабочего START и ОПУБЛИКОВАННЫЙ (в `refs/remotes/origin/main` либо в tip какой-либо `refs/remotes/origin/wip/<NNN>/*` носителя), без ручного override; «старый OBJECT мимо новой непроверенной работы» остаётся красным; повтор роли на том же OBJECT допускается также по записанной в учёте санкции. Класс: правка существующей двери.

Последовательность (порядок — зависимость):
1. Ленд A2 контракта 140 (PR #1238) — до раздачи реализации 208.
2. Implementer: `scripts/zamok_predmeta.sh` — блок D9 и блок D11 режима `--sudit` по инвариантам ниже; эталон семантики — `fixtures/workshop_project/zamok_object_predok_208/model/zamok_predmeta.sh` (поведение судится батареей, не побайтовым сравнением текста); той же пачкой `fixtures/parsing_hygiene_battery/profiles/zamok_predmeta.sh` пополняется клетками грамматики санкции (та же семья).
3. Оркестратор: `gen_ci_steps.sh --write` (шаг батареи 208; до ленда реализации шаг несёт `--stabs` + ногу `bash -n scripts/zamok_predmeta.sh`, после — безфлаговый), `--check` rc 0.
4. Судьи по регламенту (класс «рисковый»: адверсарий до ревьюера); имя вердикта критика — `verdicts/critic/contracts-208-v1.md` (v1 — новый предмет).

## Инварианты

1. **Резолвер не меняется**: `object_kandidata`, `puti_kommita` и потребители `--object/--snapshot/--peredat`, `pre_judge.sh` сохраняют поведение (отказы `OBJECT_RASHODITSJA`/`OBJECT_NE_KANONICHEN`/`VETKA_NE_OPUBLIKOVANA` на своих входах — те же). Равенство `OBJECT == K` остаётся допуском без новых условий.
2. **Допуск по предковости (D9a)**: `merge-base --is-ancestor OBJECT K` в носителе → допуск при опубликованности OBJECT: `merge-base --is-ancestor OBJECT refs/remotes/origin/main` либо OBJECT — предок tip какой-либо `refs/remotes/origin/wip/<NNN>/*` (носитель — тот же `r_wt`, где резолвился кандидат). Неопубликованность — именованный отказ (причина: «не опубликован», выход: fetch/опубликовать), не молчаливый допуск; устарелый origin-view носителя даёт отказ (fail-closed).
3. **Допуск «вперёд» (D9b)**: `merge-base --is-ancestor K OBJECT` → допуск только если OBJECT — КОДОВАЯ граница (дельта против первого родителя содержит путь вне белого списка вердиктных артефактов предмета — тот же список, что у резолвера) И опубликован (та же публикация). Вердиктный хвост не становится объектом суда и «вперёд»: OBJECT-вердикткоммит — именованный отказ (причина: «не кодовая граница», выход: OBJECT работы).
4. **Порядок родителей merge (D9c)**: если резолвер отверг ветку из-за пустой дельты tip против первого родителя, а tip — merge (родители 40-hex, ≥2), кандидатом для допуска считается сам tip; допуск решается инвариантами 1–3 (перестановка родителей merge решение не меняет). Пустой НЕ-merge tip и прочие отказы резолвера — прежние отказы (D50 не ослаблен для одиночных коммитов).
5. **Негатив «мимо новой работы»**: OBJECT не равен K и не связан с ним предковостью — прежний `OBJECT_RASHODITSJA`; текст отказа называет причину (кандидат K приведён) и выход (новый OBJECT либо опубликовать ветку с работой). Отказ не пишет учёт и не трогает замок (как сегодня).
6. **Санкция повтора в учёте (D11b)**: повтор той же роли на том же OBJECT допускается при (а) неизменной строке задания `РАЗРЕШИЛ-ВЛАДЕЛЕЦ-ПОВТОР` (слово 21.11 00:55) ИЛИ (б) записи в `uchet.jsonl`: `{"t":"SANKCIJA","repoId":…,"subjectId":…,"rol":<роль из JUDGES>,"object":<40hex>}` с теми же предметом/ролью/OBJECT — и только пока круг не исчерпан (`krugov_suda == 1`, общая граница обоих источников). SLOVO (лимит группы) санкцией повтора не является; иных источников повтора нет; иначе — прежний `OBJECT_UZHE_SUZHEN` с выходом в тексте. Грамматика записи — замкнутые алфавиты, сравнение литеральное.
7. **Регресс**: `PAUZA_VLADELTSA`, `VETKA_NEDOSTUPNA`, `OBJECT_OTSTUTSVUET`, `SUBEKT_DVA_OBJECTA`, `GRAMMATIKA_OBJECTA`, остальные отказы и порядок гейтов для входов вне свойств 2–6 не ослаблены и не переименованы; семьи 140/167 и профиль гигиены парсинга зелены до и после реализации (механический якорь порядка и регресса).

## Приёмка

### Красное сейчас (до реализации)

- `bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --repo .` → красная: КРАСНОЕ 208

Красные клетки производства (замер прогона на `b8ecb8053`): `SUBJEKT 208: KLETKI 18 KRASNYH 5` — r02-predok-opublikovan-v-main, r03-predok-opublikovan-v-vetke, r05-vperjod-opublikovan, r08-merge-pustaja-delta, r11-sankcija-v-uchete (боли 179/007-182/152-177 и второй класс); остальные 13 клеток — регрессионные (отказы той же роли, что и сегодня).

### Зелёные контроли (rc 0)

- `bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --model`
- `bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --stabs`
- `bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --sintaksis`
- `bash fixtures/parsing_hygiene_battery/run_battery.sh zamok_predmeta`
- `bash fixtures/workshop_project/obryv_167/red_obryv_167.sh --repo .`

Замеры (пересчитываются гейтом):
замер: `ls fixtures/workshop_project/zamok_object_predok_208/model/* | wc -l` = 1 census fixtures/workshop_project/zamok_object_predok_208/model/*
замер: `ls -d fixtures/workshop_project/zamok_object_predok_208/stabs/* | wc -l` = 12 census fixtures/workshop_project/zamok_object_predok_208/stabs/*

Числа прогона на этом дереве: `--model` → `MODEL 208: KLETKI 18 KRASNYH 0`; `--stabs` → `MODEL 208: KLETKI 18 KRASNYH 0`, `STABY 208: SVJAZI 16 ZHIVYH 0`; `--repo .` → `SUBJEKT 208: KLETKI 18 KRASNYH 5`, rc 1. Регресс соседа (не проба листа — медленная): `bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --model` → `MODEL_KLETKI 172 KRASNYH 0`, rc 0.

### После реализации (гейты ленда, выполняет оркестратор/судьи)

```
bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh            # rc 0
bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --repo .   # rc 0 (KLETKI 18 KRASNYH 0)
bash fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh --stabs   # rc 0 (SVJAZI 16, ZHIVYH 0)
bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh --model                     # rc 0 (172/0)
bash fixtures/workshop_project/obryv_167/red_obryv_167.sh --repo .                              # rc 0
bash fixtures/parsing_hygiene_battery/run_battery.sh zamok_predmeta                             # rc 0 (с клетками санкции)
bash scripts/gen_ci_steps.sh --check                                                            # rc 0 (шаг 208 подключён оркестратором)
```

## Зоны и проводка

ЗОНА architect: contracts/208-zamok-object-predok.md fixtures/workshop_project/zamok_object_predok_208/
ЗОНА implementer: scripts/zamok_predmeta.sh fixtures/parsing_hygiene_battery/profiles/zamok_predmeta.sh
ЗОНА critic: verdicts/critic/
ЗОНА adversary: verdicts/adversary/
ЗОНА reviewer: verdicts/review/
ЗОНА orchestrator: registry/ci-steps.tsv registry/ci-zamery.tsv .github/workflows/ci.yml
ПЕРЕСЕЧЕНИЕ implementer: scripts/zamok_predmeta.sh — 140 только блок D9 (допуск по предковости/публикации/merge-порядку) и блок D11 (санкция SANKCIJA) режима --sudit; грамматика пина, лимиты, учёт START/RELEASE, resolver --object/--snapshot/--peredat и именованные отказы неизменны; реализация 208 — ПОСЛЕ ленда A2 (PR #1238, na_pauze/цикл паузы той же двери).
ПЕРЕСЕЧЕНИЕ implementer: scripts/zamok_predmeta.sh — 154 только блоки D9/D11 --sudit этой пачки; счёт вызовов критика и карта листа не затрагиваются.
ПЕРЕСЕЧЕНИЕ implementer: scripts/zamok_predmeta.sh — 167 только блоки D9/D11 --sudit этой пачки; семантика оборванного судьи (krugov_suda, obryv_bez_verdikta) и RELEASE не меняются.
ПЕРЕСЕЧЕНИЕ implementer: scripts/zamok_predmeta.sh — 199 только блоки D9/D11 --sudit этой пачки; isolated рабочего, привязка сдачи и факт isolated в START не затрагиваются.
ПЕРЕСЕЧЕНИЕ implementer: fixtures/parsing_hygiene_battery/profiles/zamok_predmeta.sh — 140 только новые клетки грамматики записи SANKCIJA (та же семья профиля двери); прежние клетки профиля не меняются.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 083 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 084 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 087 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 090 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 092 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 093 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 094 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 095 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 103 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 110 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 112 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 113 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 114 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 994 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 996 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 997 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-steps.tsv — 998 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: registry/ci-zamery.tsv — 114 только замер шага 208; чужие замеры неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 011 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 015 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 002 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 003 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 004 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 005 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 006 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 007 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 008 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 016 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 020 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 021 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 027 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 036 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 038 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 039 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 040 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 043 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 045 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 057 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 058 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 059 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 060 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 062 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 063 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 070 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 071 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 072 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 078 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 083 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 084 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 087 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 090 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 092 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 093 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 094 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 095 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 099 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 100 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 109 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 110 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 112 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 114 только сгенерированный шаг 208; чужие шаги неизменны.
ПЕРЕСЕЧЕНИЕ orchestrator: .github/workflows/ci.yml — 996 только сгенерированный шаг 208; чужие шаги неизменны.

СДАЧА: fixtures/workshop_project/zamok_object_predok_208/SDACHA.md

ПРОВОДКА:
- guard=fixtures/workshop_project/zamok_object_predok_208/red_zamok_object_predok_208.sh
ПРОВОДКА-ЭНФОРСМЕНТ: допуск судьи и санкция повтора — чистый энфорсмент двери (guard-канал); `--stabs` в CI до ленда реализации, безфлаговый режим после; строку своей батареи подключает оркестратор (`gen_ci_steps.sh --write`, `--check` rc 0), команда шага несёт ногу `bash -n scripts/zamok_predmeta.sh` — имя guard появляется в ci-steps для guard_is_wired done-гейта (прецедент 190/199), чужие строки не меняются.

## Модель угроз

ЗАЩИЩАЕТ:
- От вечной блокировки done-пути при связи предковостью: судья допускается на предка кандидата (боль 179) и на ушедшую вперёд кодовую границу (боли 007/182) при опубликованности; порядок родителей merge допуск не меняет (боли 152/177) — инварианты 2–4, клетки r02/r03/r05/r08.
- От суда непроверенной работе: публикация обязательна в обоих направлениях (fail-closed: нет origin-view в носителе — отказ с выходом), «старый OBJECT мимо новой работы» и расхождение — прежний отказ с причиной и выходом — инварианты 2/5, клетки r04/r07/r10.
- от подмены объекта суда вердиктом: OBJECT «вперёд» обязан быть кодовой границей по тому же белому списку, что у резолвера; вердиктный хвост объектом суда не становится — инвариант 3, клетка r06.
- От потери границы «один повтор»: санкция SANKCIJA адресна (предмет+роль+OBJECT), действует только при неисчерпанном круге, SLOVO ею не является; строка задания 21.11 00:55 не тронута — инвариант 6, клетки r11–r15.
- От регресса замка: равенство, D50 для одиночных коммитов, ПАУЗА, недоступная ветка, грамматика OBJECT и порядок гейтов — клетки r01/r09/r16–r18 и семьи соседей в приёмке.

НЕ ЗАЩИЩАЕТ:
- Свежесть origin-view носителя не гарантируется: устарелый `refs/remotes/origin/*` в `r_wt` даёт отказ (fail-closed), обновление — за пределами двери; живая публикация судится преддверием (172), здесь не меняется.
- Преддверие (`scripts/pre_judge.sh`, 172) остался равенству tip: prepare берёт OBJECT из tip опубликованной ветки и отказывает `VETKA_NE_OPUBLIKOVANA`/`OBJECT_NE_KANONICHEN` на своих входах; полный маршрут «судья на предке/ушедшей работе» может дополнительно требовать отдельного предмета преддверия (ловец — оркестратор на живом прогоне, боль задокументирована).
- Третий класс боли — выбор вердикта адверсария по фиксированному имени `-v1` в `scripts/done_contract.sh` — вне предмета (отдельная зона и механизм, см. Существующее п.6); ловец — отдельный контракт по слову владельца.
- Учёт станции — доверенная зона: пишущий в `state/zamok/uchet.jsonl` может дописать SANKCIJA, как и SLOVO сегодня; дверь не аутентифицирует автора записи (граница существующего доверия, изменение — отдельный предмет).
- Батарея — конечный закрытый набор на объявленные механизмы (18 клеток / 12 обманных дверей / 16 связей по source.json, счёт по выводу движка), не доказательство эквивалентности произвольной программы; остаток — судьи (adversary → reviewer) на живом дереве.

ПРЕДПОСЫЛКИ:
- setting нужны bash, git, jq, python3 (rc 2 при отсутствии); новых CI secrets/variables/environments и настроек репозитория не требуется.

## Незаполненные требования:
нет
