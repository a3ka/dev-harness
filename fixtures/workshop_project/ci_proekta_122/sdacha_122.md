# СДАЧА 122 v+1 (дельта-205, слово владельца 2026-11-18 ~18:58 UTC, через консультанта 205) — у station-джоб не проверяется вычисляемый алфавит run/env; сохранность: сверка объявленности, YAML, разбор working-directory, STATION-JOB, все отказы local

ПРЕДЫДУЩИЙ ВЕРДИКТ: verdicts/critic/contracts-122-v5.md

Происхождение дельты (прозой): задание `/tmp/dev-harness-verify/task-122-architect-delta205.md` (адресная дельта, дельта-пакет) + отчёт консультанта `/tmp/dev-harness-verify/consult205-report.md` (строки 126 и 132 — дословные формулировки; диагноз: в кандидате `otkaz_vyrazhenija` для run/env вызывается в `model/ci_preflight.sh:222–226` ДО ветки `if cls == 'station'` (:243)); база `a05247cdaa` (v5 + merge main `b5dc206db3`). Дельта = инвариант контракта (станция с литеральным маркером не судится по run/env, класс до отказа, всё прочее станции сохранено, `CIPREFLIGHT_OK jobs=0 station=N` ≠ required CI, §4(б) не расширяется), модель (`ne_suditsya_run_env`, маркер `МУТАЦИЯ-122:stantsiya-propusk`), девять клеток p11 (парные свидетели кодом `p11_par` — шаблон `@@KLASS@@`, различие только класс), два стаба (мутант «станция не пропускает», обёртка «пропускает всё»), обновление чисел контракта по факту. Команды листа rc-стабильны.

## Двери

- pre_critic · bash scripts/pre_critic.sh contracts/122-ci-proekta.md · 0 · 0
- spec_ready · bash scripts/check_spec_ready.sh . contracts/122-ci-proekta.md · 0 · 0
- precision-gate · bash scripts/check_precision_gate.sh . contracts/122-ci-proekta.md · 0 · 0
- provodka-grammar · bash scripts/check_provodka.sh --grammar . contracts/122-ci-proekta.md · 0 · 0
- threat-model · bash scripts/check_threat_model.sh . contracts/122-ci-proekta.md · 0 · 0
- красное-до (голый прогон, субъект v1) · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh · 1 · 1
- батарея --model (зелёное-после) · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model · 0 · 0
- клетка p9 --model · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell p9 · 0 · 0
- клетка p10 --model · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell p10 · 0 · 0
- клетка p11 --model · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell p11 · 0 · 0

## Карта классов

- К-01 · чисто · вход: два новых стаба дельты несут привязки к клеткам в шапках (код), контракт пар «стаб ↔ ветвь» не утверждает (Н-39); прежние привязки не тронуты · - · -
- К-02 · чисто · вход: задание delta205 + отчёт консультанта (строки 126/132 прочитаны целиком, цитаты в КОНТЕКСТ дельты-205 контракта) · - · -
- К-03 · чисто · вход: дельта — только contracts/122-ci-proekta.md и fixtures/workshop_project/ci_proekta_122/** (зона architect); алфавит Г2 не расширен, фиктивные контексты не введены, §4(б) не расширен · - · -
- К-04 · чисто · bash scripts/check_precision_gate.sh . contracts/122-ci-proekta.md · 0 · 0
- К-05 · чисто · вход: приёмка п.1–9 — команды с rc; все числа контракта из прогонов этой пачки (74/54/20, 72/2, 74/74/0, 56/18, 40/34, 66/8, 0/74, 26/48, 48/26 и мутанты) · - · -
- К-06 · н/п · средовая ветвь python-yaml-nedostupen rc 2 клетками не покрыта (PyYAML в окружении) · - · -
- К-07 · чисто · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model · 0 · 0
- К-08 · чисто · вход: стабы дельты замерены штатным env-интерфейсом (72/2 и 69/5, красные клетки сверены с шапками), тампер мутанта дельты — оба направления rc 2 ORACLE_TAMPERED · - · -
- К-09 · чисто · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell p10 · 0 · 0
- К-10 · чисто · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell p9 · 0 · 0
- К-11 · чисто · вход: ожидания — литералы кода батареи, сняты до вызова субъекта; парность p11 — по построению кода p11_par (один шаблон, различие только значение класса); красное-до — голый прогон на настоящем субъекте · - · -
- К-12 · чисто · вход: YAML — настоящий PyYAML; класс станции — литеральное сравнение в модели (единый источник), сверка — литералами вывода · - · -
- К-13 · н/п · секреты не предмета круга (заглушки и фикстурный gh; ПРЕДПОСЫЛКИ контракта — setting) · - · -
- К-14 · чисто · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell p11 · 0 · 0
- К-15 · чисто · вход: числа — из ИТОГ-строк прогонов; вторая мера — счёт по исходнику: 74 вызова run_case, литерал rc 0 у 26, rc 1 у 48 · - · -
- К-16 · чисто · bash scripts/check_threat_model.sh . contracts/122-ci-proekta.md · 0 · 0
- К-17 · н/п · tooling/checks/cli.js и бриф архитектуры 188 в объекте отсутствуют (предмет — механизм харнесса) · - · -

## Дельта

- К-11 · клетка · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh · 1 · 1
- К-07 · клетка · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model · 0 · 0
- К-08 · клетка · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell p11 · 0 · 0
- К-09 · клетка · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell p10 · 0 · 0
- К-10 · клетка · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell p9 · 0 · 0
- К-14 · клетка · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell p11 · 0 · 0

## Замеры стабов, мутантов и красного-до (проза; env-интерфейс и git-извлечение — вне алфавита команд листа)

Штатный интерфейс батареи — env-переменные CI_PROEKTA_122_GEN/_PREFLIGHT/_GATES; режима --stabs у батареи нет (замер прошлых кругов: `bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --stabs` → «ci122 ОТКАЗ: неизвестный ключ: --stabs», rc 2) — стабы дельты проверены прогоном через штатный env-интерфейс, как раньше.

Красное-до двумя мерами. Голый прогон (субъект v1 в дереве): `bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh` → rc 1, «клеток 74, зелёных 54, красных 20» — красны 16 клеток p9/p10 и поимённо 4 клетки p11 (p11-run-local-vyrazhenie, p11-env-local-vyrazhenie, p11-station-marker-ne-literal — у v1 нет vyrazhenie-ne-podderzhano; p11-station-wd-vne-kopii — нет working-directory-vne-kopii); 5 клеток p11 зелены у v1 (пропуск станции был и в v1). Модель без дельты: `git show a05247cdaa:fixtures/workshop_project/ci_proekta_122/model/ci_preflight.sh` в одноразовый файл под /tmp/dev-harness-verify, затем `CI_PROEKTA_122_PREFLIGHT=<файл> bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model` → rc 1, «клеток 74, зелёных 72, красных 2» — красны поимённо ровно p11-run-station-propusk и p11-env-station-propusk (кандидат до дельты отказывал станции); local-пары и сохранность зелены ДО и ПОСЛЕ.

Стабы дельты (оба rc 1): `CI_PROEKTA_122_PREFLIGHT=fixtures/workshop_project/ci_proekta_122/stabs/stab_preflight_stantsiya_ne_propuskaet.sh` → «72/2» — красны ровно p11-run-station-propusk и p11-env-station-propusk (свидетели-пропуском; клетки сохранности зелены); `CI_PROEKTA_122_PREFLIGHT=fixtures/workshop_project/ci_proekta_122/stabs/stab_preflight_stantsiya_propuskaet_vse.sh` → «69/5» — красны ровно p2-working-directory-otsutstvuet, p5-station-sekret-ne-perechislen, p11-station-sekret-ne-perechislen, p11-station-var-ne-perechislena, p11-station-wd-vne-kopii (сохранность).

Тампер-замер мутанта дельты (оба направления, одноразовые копии модели и стаба под /tmp/dev-harness-verify): маркер МУТАЦИЯ-122:stantsiya-propusk удалён (0 вхождений) → rc 2 «ORACLE_TAMPERED: mutant ОТКАЗ: маркер … 0 раз, нужен 1»; маркер продублирован (2 вхождения) → rc 2 «… 2 раз, нужен 1». У стаба-обёртки маркера нет — тампер неприменим (честная отметка).

Стабы п.4–5 приёмки: stab_gen_postojannyj → «56/18»; stab_preflight_tolko_sintaksis → «40/34»; stab_predposylki_slepoy → «66/8»; stab_vsegda_zelenyj (все три субъекта) → «0/74»; stab_vsegda_krasnyj (все три) → «0/74»; stab_rc0_chestnyj_tekst (все три) → rc 1 «26/48»; stab_rc1_chestnyj_tekst (все три) → rc 1 «48/26»; объединение красных 74 из 74, пересечение 0.

Мутанты (все rc 1; красные клетки сверены с шапками): v1 — stab_preflight_bez_podstanovki → «71/3»; stab_preflight_bez_workflow_defaults → «71/3»; stab_preflight_bez_env → «67/7»; stab_preflight_sverka_tolko_run → «67/7» (добавились p11-station-sekret/var — сверка только по run local); stab_preflight_env_bez_podstanovki → «69/5»; v+1 и круг Crit122V5 — stab_preflight_bez_workspace → «62/12» (добавилась p11-station-wd-vne-kopii — wd литералом); stab_preflight_ws_bez_granicy → «69/5» (добавилась p11-station-wd-vne-kopii — otsutstvuet вместо vne-kopii); stab_preflight_bez_otkaza_vyrazhenij → «66/8» (добавились обе local-пары p11 и маркер-негатив); stab_preflight_kavychki_vyrazhenij → «73/1». Шапки пяти стабов дополнены новыми клетками по факту (Н-39).
