# СДАЧА 122 v+1 — явно ограниченная недостающая GHA-семантика предполёта (слово владельца 2026-11-18 12:16 UTC, OWNER-BATCH-1118 №2)

Происхождение дельты (прозой: у всех восьми вердиктов 122 — `verdicts/critic/contracts-122-{krug1..3,v1..v5}.md` — карты классов «## Карта классов» нет, `grep -c` → 0 у каждого; машинная строка ПРЕДЫДУЩИЙ ВЕРДИКТ не даётся): задание v+1 `/tmp/dev-harness-verify/task-122-architect-vplus1.md` + решение консультанта `ConsPre149` §1–§3; дельта = перечень семантики из замера прототипа (контракт «Существующее» п.8), новые причины `working-directory-vne-kopii`/`vyrazhenie-ne-podderzhano`, клетки p9/p10, три мутанта v+1 (ORACLE_TAMPERED), сдаточный лист (этот). Команды листа rc-стабильны ДО и ПОСЛЕ реализации v+1; красное окно голого прогона (49/13) живёт в приёмке контракта п.1, не здесь — лист судит согласованность заявленного и фактического.

## Двери

- pre_critic · bash scripts/pre_critic.sh contracts/122-ci-proekta.md · 0 · 0
- spec_ready · bash scripts/check_spec_ready.sh . contracts/122-ci-proekta.md · 0 · 0
- precision-gate · bash scripts/check_precision_gate.sh . contracts/122-ci-proekta.md · 0 · 0
- provodka-grammar · bash scripts/check_provodka.sh --grammar . contracts/122-ci-proekta.md · 0 · 0
- батарея --model · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model · 0 · 0
- клетка p9 --model · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell p9 · 0 · 0
- клетка p10 --model · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell p10 · 0 · 0

## Карта классов

- К-01 · чисто · bash scripts/pre_critic.sh contracts/122-ci-proekta.md · 0 · 0
- К-02 · чисто · вход: слово владельца 2026-11-18 12:16 UTC (OWNER-BATCH-1118 №2) — заголовок и КОНТЕКСТ v+1; основание ConsPre149 §1–§3; перечень семантики обоснован замером прототипа (Существующее п.8: все 11 джоб mobile.yml, обе пробы A/B) · - · -
- К-03 · чисто · вход: v+1 меняет только собственный текст 122 и свою батарею (зона architect); контракт 149, 197, продукт, scripts/* не тронуты (git diff --stat в докладе); отказы v1 не переименованы и не ослаблены — клетки p8 зелёны голым прогоном (приёмка п.1: 49 из 62) · - · -
- К-04 · чисто · bash scripts/check_precision_gate.sh . contracts/122-ci-proekta.md · 0 · 0
- К-05 · чисто · вход: приёмка п.1–9 — команды с rc (голый прогон rc 1 сегодня → rc 0 после реализации; --model rc 0; мутанты rc 1; тамперы rc 2) · - · -
- К-06 · чисто · вход: python-yaml-nedostupen — rc 2, клеткой не покрыта (заявлено в алфавите); `--cell net-takoj` → rc 2 с перечнем (замер) · - · -
- К-07 · чисто · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model · 0 · 0
- К-08 · чисто · вход: мутанты красят ровно клетки своих шапок — v+1: stab_preflight_bez_workspace «53/9» (p9×8 + p10-uses), stab_preflight_ws_bez_granicy «60/2» (оба побега), stab_preflight_bez_otkaza_vyrazhenij «58/4» (четыре p10); v1: 59/3, 60/2, 55/7, 57/5, 57/5 (замеры приёмки п.6) · - · -
- К-09 · чисто · вход: p9 — восемь ветвей (wd шага, run, env, defaults workflow, переопределение defaults джобы, побег `..`, побег симлинком, форма mobile.yml с --contract); p10 — пять (run, env, функция, отказ ДО исполнения первого шага, uses-граница) · - · -
- К-10 · чисто · вход: клетка зелена только при фактическом rc == литералу И причине-литерале в полном выводе (run_case; rc — первичная мера) · - · -
- К-11 · чисто · вход: ожидания — литералы кода батареи, сняты до вызова субъекта; миры одноразовые под /tmp/dev-harness-verify; голый прогон судит настоящий scripts/ci_preflight.sh, не двойник · - · -
- К-12 · чисто · вход: YAML судится настоящим PyYAML (yaml.safe_load субъекта и модели); формат — сравнением литералов вывода, не самописным разбором формата · - · -
- К-13 · н/п · секреты не предмет v+1 (в батарее — заглушки и фикстурный gh; ПРЕДПОСЫЛКИ контракта — setting, новых секретов нет) · - · -
- К-14 · чисто · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell p9 · 0 · 0
- К-15 · чисто · вход: числа приёмки из ИТОГ-строк прогонов (62/49/13, 62/62, 24/38, 38/24, 53/9, 60/2, 58/4, 59/3, 60/2, 55/7, 57/5, 57/5, 44/18, 39/23, 54/8, 0/62); вторая мера — счёт по исходнику: 62 вызова run_case, rc 0 у 24, rc 1 у 38 · - · -
- К-16 · чисто · bash scripts/check_threat_model.sh . contracts/122-ci-proekta.md · 0 · 0
- К-17 · н/п · tooling/checks/cli.js и бриф архитектуры 188 в объекте отсутствуют (ls tooling — нет каталога; предмет — механизм харнесса, не модуль проекта) · - · -

## Дельта

- К-08 · клетка · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell p10 · 0 · 0
- К-09 · клетка · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell p9 · 0 · 0
- К-14 · клетка · bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model --cell p9 · 0 · 0
