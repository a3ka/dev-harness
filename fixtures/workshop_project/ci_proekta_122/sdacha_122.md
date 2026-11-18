# СДАЧА 122 v+1 (круг закрытия Crit122V5) — три блока вердикта: К-09 (скобка `}` в строковом аргументе), К-10 (исходное значение унаследованного working-directory), К-01 (прозаические привязки стабов в контракте)

ПРЕДЫДУЩИЙ ВЕРДИКТ: verdicts/critic/contracts-122-v5.md

Происхождение дельты (прозой): задание `/tmp/dev-harness-verify/task-122-architect-fix-v5.md` (исправительный круг, дельта-пакет) + вердикт `Crit122V5` (FAIL, OBJECT=ebf7ac6b62692c51753c6ad8e2767e2130af19fc); дельта = сканер границ выражений в модели (замена regexp `[^}]*` — маркер `МУТАЦИЯ-122:kavychki-vyrazhenija`), исходное значение `working-directory` до подстановки в отказе о побеге (`d0`), три новые клетки (p9-wd-dotdot-vne-kopii-defaults-workflow, p9-wd-dotdot-vne-kopii-defaults-dzhoby, p10-format-skobka-v-stroke), мутант `stab_preflight_kavychki_vyrazhenij.sh`, снятие прозаических привязок стаб→ветвь из строк 53/62/108 контракта (привязки остаются в шапках стабов — код), обновление чисел контракта по факту. Команды листа rc-стабильны; красное окно голого прогона (49/16) — приёмка контракта п.1: реализация v+1 — отдельная пачка implementer, здесь её нет.

## Двери

- pre_critic · bash scripts/pre_critic.sh contracts/122-ci-proekta.md · 0 · 0
- spec_ready · bash scripts/check_spec_ready.sh . contracts/122-ci-proekta.md · 0 · 0
- precision-gate · bash scripts/check_precision_gate.sh . contracts/122-ci-proekta.md · 0 · 0
- provodka-grammar · bash scripts/check_provodka.sh --grammar . contracts/122-ci-proekta.md · 0 · 0
- threat-model · bash scripts/check_threat_model.sh . contracts/122-ci-proekta.md · 0 · 0
- красное-до (голый прогон, дерево v1) · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh · 1 · 1
- батарея --model (зелёное-после) · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model · 0 · 0
- клетка p9 --model · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell p9 · 0 · 0
- клетка p10 --model · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell p10 · 0 · 0

## Карта классов

- К-01 · чисто · вход: прозаические пары «стаб → ветвь/клетка» убраны из строк 53/62/108 (v5) и из буллетов модели угроз; контракт несёт инвариант и rc-команды, привязки — шапки stabs/ и диспетчер раннера (код) · - · -
- К-02 · чисто · вход: задание fix-v5 + вердикт Crit122V5 (OBJECT=ebf7ac6b62, база ветки f4d581bdd1 — материализованный вердикт) · - · -
- К-03 · чисто · вход: дельта — только contracts/122-ci-proekta.md и fixtures/workshop_project/ci_proekta_122/** (зона architect); 149/165, станционное исключение владельца, алфавит Г2 не расширен: выражение с функцией format(...) отказывает vyrazhenie-ne-podderzhano, не вычисляется · - · -
- К-04 · чисто · bash scripts/check_precision_gate.sh . contracts/122-ci-proekta.md · 0 · 0
- К-05 · чисто · вход: приёмка п.1–9 — команды с rc; все числа контракта обновлены по фактическим прогонам (65/49/16, 65/65/0, 24/41, 41/24 и замеры стабов) · - · -
- К-06 · чисто · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell net-takoj · 2 · 2
- К-07 · чисто · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model · 0 · 0
- К-08 · чисто · вход: мутанты красят ровно клетки своих шапок (замеры в прозе листа ниже); тамперы rc 2 замерены в обоих направлениях для нового мутанта · - · -
- К-09 · чисто · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell p10 · 0 · 0
- К-10 · чисто · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell p9 · 0 · 0
- К-11 · чисто · вход: ожидания — литералы кода батареи, сняты до вызова субъекта; миры одноразовые; --model судит честную модель, голый прогон — настоящий scripts/ci_preflight.sh · - · -
- К-12 · чисто · вход: YAML — настоящий PyYAML; границы выражений — сканер в самой модели (единый источник с субъектом-моделью), сверка — литералами вывода · - · -
- К-13 · н/п · секреты не предмет круга (в батарее заглушки и фикстурный gh; ПРЕДПОСЫЛКИ контракта — setting) · - · -
- К-14 · чисто · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell p9 · 0 · 0
- К-15 · чисто · вход: числа — из ИТОГ-строк прогонов (65/49/16 голый, 65/65/0 модель, 47/18, 39/26, 57/8, 0/65, 0/65, 24/41, 41/24, 62/3, 62/3, 58/7, 60/5, 60/5, 54/11, 61/4, 60/5, 64/1); вторая мера — счёт по исходнику: 65 вызовов run_case, литерал rc 0 у 24, rc 1 у 41 · - · -
- К-16 · чисто · bash scripts/check_threat_model.sh . contracts/122-ci-proekta.md · 0 · 0
- К-17 · н/п · tooling/checks/cli.js и бриф архитектуры 188 в объекте отсутствуют (предмет — механизм харнесса, не модуль проекта) · - · -

## Дельта

- К-01 · снятие · bash scripts/pre_critic.sh contracts/122-ci-proekta.md · 0 · 0
- К-07 · клетка · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model · 0 · 0
- К-09 · клетка · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell p10 · 0 · 0
- К-10 · клетка · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell p9 · 0 · 0

## Замеры стабов и мутантов (проза; env-интерфейс вне алфавита команд листа)

Штатный интерфейс батареи — env-переменные CI_PROEKTA_122_GEN/_PREFLIGHT/_GATES; режима --stabs у батареи нет (замер: `bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --stabs` → «ci122 ОТКАЗ: неизвестный ключ: --stabs», rc 2) — привязки стабов проверяются прогоном мутантов через штатный env-интерфейс, как делал критик.

Мутанты (все rc 1; красные клетки сверены с шапками): stab_preflight_bez_workspace → «54/11» (все десять p9 + p10-uses-ne-suditsa); stab_preflight_ws_bez_granicy → «61/4» (четыре клетки побега: шаговые p9-wd-dotdot-vne-kopii, p9-wd-simlink-pobeg и унаследованные p9-wd-dotdot-vne-kopii-defaults-workflow, p9-wd-dotdot-vne-kopii-defaults-dzhoby); stab_preflight_bez_otkaza_vyrazhenij → «60/5» (пять клеток p10, кроме uses); stab_preflight_kavychki_vyrazhenij → «64/1» (ровно p10-format-skobka-v-stroke — молчаливый rc 0 вместо отказа). v1: stab_preflight_bez_podstanovki → «62/3»; stab_preflight_bez_workflow_defaults → «62/3» (третья красная — новая p9-wd-dotdot-vne-kopii-defaults-workflow, шапка дополнена); stab_preflight_bez_env → «58/7»; stab_preflight_sverka_tolko_run → «60/5»; stab_preflight_env_bez_podstanovki → «60/5». Регрессия прежних клеток p1–p10: в зелёном прогоне --model 65/65/0 — все 62 прежние клетки зелёны, красное-до на дереве 49 зелёных / 16 красных (13 прежних v+1 + 3 новых, ровно новые клетки p9/p10).

Тампер-замер нового мутанта (оба направления, одноразовые копии модели под /tmp/dev-harness-verify): маркер МУТАЦИЯ-122:kavychki-vyrazhenija удалён (0 вхождений) → rc 2 «ORACLE_TAMPERED: mutant ОТКАЗ: маркер … 0 раз, нужен 1»; маркер продублирован (2 вхождения) → rc 2 «… 2 раз, нужен 1».

Стабы п.4–5 приёмки: stab_gen_postojannyj → «47/18»; stab_preflight_tolko_sintaksis → «39/26»; stab_predposylki_slepoy → «57/8»; stab_vsegda_zelenyj (все три субъекта) → «0/65»; stab_vsegda_krasnyj (все три) → «0/65»; stab_rc0_chestnyj_tekst (все три) → rc 1 «24/41»; stab_rc1_chestnyj_tekst (все три) → rc 1 «41/24»; объединение красных 65 из 65, пересечение 0.
