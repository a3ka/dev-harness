# СДАЧА 147 — v+7 правка по FAIL критика (вызов 1): обязательность lane экранной приёмки доказана батареей

Круг закрывает блоки К-05/К-08/К-09/К-10 вердикта `verdicts/critic/contracts-147-v6.md`
(archive/147/critic-v6-fail-309e8d84b0, OBJECT dde53fe039): класс «содержимое lane не исполняет
обязательную приёмку» — непустой ключ `ci:ekran-gespraech-vhod` пропускал пустышку `echo skipped`
(REGISTRACIJA_OK rc 0, `npm run` печатает `skipped` без валидатора и Maestro). Форма закрытия —
побайтовое сравнение значения lane приёмки с каноном единого источника MODEL_PKG
(`bash mobile/scripts/ci-ekran-gespraech-vhod.sh`) в `sudi_lineju`: расхождение — именованный
отказ LANE_NE_KANON (rc 1). Связка worker → lane → скрипт приёмки теперь различает работающую
форму от пустышки и подавления: пустышка и хвост `|| true` внутри значения lane красны, честная
запись зелена, отсутствие ключа по-прежнему LANEJA_NET. Зона не расширена: значения lanes канона
197 (`ci:artefakt-*`) судятся только существованием — наблюдение критика о пустышке писателя есть
граница с ловцом-семьёй 197 (frozen-зависимость, слово «не меняй канон 197»), проверка значения
писателя не вводится, мутация-пара не нужна. MODEL_YML и значения MODEL_PKG не менялись: модельные
package.json/workflow старой и новой батареи побайтово идентичны (замер ниже).

Дельта-список по способам: на каждый блок вердикта — способ `канон/инструмент` (побайтовое
сравнение значения lane с каноном MODEL_PKG, единый источник уже в батарее), команда прогоном
ниже в «Двери»; на каждый новый предикат — мутация, которая его красит (пустышка `echo skipped` →
LANE_NE_KANON, канон с хвостом `|| true` → LANE_NE_KANON), и честная эквивалентная запись,
остающаяся зелёной (точное значение канона → rc 0 REGISTRACIJA_OK). Красное-до: тот же мутант
критика на батарее OBJECT зелён в `--repo` (rc 0 REGISTRACIJA_OK), на обновлённой — rc 1
PRICHINA LANE_NE_KANON (живой замер этой пачки 23.11, сырой вывод в «Фактические двери»).

ПРЕДЫДУЩИЙ ВЕРДИКТ: verdicts/critic/contracts-147-v5.md

## Двери

- ci-model · fixtures/workshop_project/gespraech_vhod_147/red_ci_147.py --model · 0 · 0
- ci-stabs · fixtures/workshop_project/gespraech_vhod_147/red_ci_147.py --stabs · 0 · 0
- legacy-model · bash fixtures/workshop_project/gespraech_vhod_147/red_gespraech_vhod_147.sh --model · 0 · 0
- legacy-stabs · bash fixtures/workshop_project/gespraech_vhod_147/red_gespraech_vhod_147.sh --stabs · 0 · 0
- threat-form · bash scripts/check_threat_model.sh . contracts/147-gespraech-vhod-menu.md · 0 · 0
- provodka-grammar · bash scripts/check_provodka.sh --grammar . contracts/147-gespraech-vhod-menu.md · 0 · 0
- product-spec-zone · bash scripts/check_precision_gate.sh . contracts/147-gespraech-vhod-menu.md · 0 · 0
- product-carrier-zones · bash fixtures/workshop_project/gespraech_vhod_147/check_zone_147.sh · 0 · 0
- spec-ready · bash scripts/check_spec_ready.sh . contracts/147-gespraech-vhod-menu.md · 0 · 0

## Карта классов

- К-01 · чисто · вход: провода guard=строк и грамматика — provodka-grammar rc 0 — CI-подключение шага red_ci_147.py за orchestrator в окне freeze..done · - · -
- К-02 · чисто · вход: слово владельца 22.11 п.(4)«А» в §Воля владельца дословно — правка круга в его границах (обновить модель и стабы — названо словом) · - · -
- К-03 · чисто · вход: frozen/contracts/147/5 не перемещался — геометрия И-12 и критерии 1–3/5–6 этой правкой не тронуты · - · -
- К-04 · чисто · bash fixtures/workshop_project/gespraech_vhod_147/check_zone_147.sh · 0 · 0
- К-05 · чисто · вход: критерий 4 несёт rc 0 REGISTRACIJA_OK и именованные rc 1 (PACHKA_*/ZAPIS_*/LANEJA_NET/LANE_NE_KANON/RABOTNIK_*/UPRAVLYAYUSHCHIJ_KLYUCH) · - · -
- К-06 · чисто · вход: отсутствие PyYAML/режима/каталога — rc 2 NOT_IMPLEMENTED с именованной причиной — битый YAML — RABOTNIKA_NET · - · -
- К-07 · чисто · bash fixtures/workshop_project/gespraech_vhod_147/check_zone_147.sh · 0 · 0
- К-08 · чисто · fixtures/workshop_project/gespraech_vhod_147/red_ci_147.py --stabs · 0 · 0
- К-09 · чисто · вход: каждая мутация красна своей именованной причиной — значение lane приёмки LANE_NE_KANON (пустышка echo skipped и хвост || true) — привязки в коде STABY по коду ветвей (Н-39) · - · -
- К-10 · чисто · вход: lane-вызовы судятся разобранными shell-словами — значение lane приёмки ПОБАЙТОВО против MODEL_PKG — связка worker → lane → скрипт приёмки различает пустышку от работающей формы · - · -
- К-11 · чисто · вход: MODEL_YML/MODEL_PKG разбираются в память ДО субъекта — --repo не читает ожидания из продукта (прецедент 141 v3 upravlenie_job) · - · -
- К-12 · чисто · вход: YAML — python3-pyyaml (предпосылка семей 143/149) — JSON — stdlib json — самописного разбора формата нет · - · -
- К-13 · н/п · секреты/учётные данные и внешняя сеть не предмет формы CI-регистрации — новых секретов нет · - · -
- К-14 · чисто · вход: структурное равенство ravno_modeli не зависит от порядка ключей — побайтовое сравнение значения lane не зависит от текстовой записи JSON — дубли ключей судятся последним значением · - · -
- К-15 · чисто · вход: счёт клеток и стабов печатает сам прогон (46/46 поимённо) — цифры листа взяты из вывода · - · -
- К-16 · чисто · bash scripts/check_threat_model.sh . contracts/147-gespraech-vhod-menu.md · 0 · 0
- К-17 · чисто · вход: новых продуктовых операций не вводится — lane-канон 197 потребляется без копирования (ci-artefakty.cjs и пины 197 не тронуты) — модель потребления И-11 · - · -

## Дельта

- К-05 · канон/инструмент · fixtures/workshop_project/gespraech_vhod_147/red_ci_147.py --stabs · 0 · 0
- К-08 · канон/инструмент · fixtures/workshop_project/gespraech_vhod_147/red_ci_147.py --stabs · 0 · 0
- К-09 · канон/инструмент · fixtures/workshop_project/gespraech_vhod_147/red_ci_147.py --stabs · 0 · 0
- К-10 · канон/инструмент · fixtures/workshop_project/gespraech_vhod_147/red_ci_147.py --stabs · 0 · 0

Блоки карты FAIL-вердикта v6 (К-05 блок, К-08 блок, К-09 блок, К-10 блок) закрыты одним
механизмом — побайтовым каноном значения lane приёмки; дверей, клеток и обязательств сверх
блоков нет. Наблюдение критика о пустышке lane писателя (канон 197) в требования этой зоны
не поднимано.

## Развилки

Форма доказательства выбрана из двух: побайтовое равенство значения ключа канону из
контракта/приёмки против исполнения lane в мире со следом запуска валидатора. Выбрано
побайтовое равенство: батарея клеток не исполняет shell по архитектуре семьи (docstring
red_ci_147.py), а равенство связки worker → lane → скрипт приёмки закрывает ровно класс блока
без нового рантайма и без расширения зоны. Проверка значения lane публикации НЕ вводится:
ключи и значения `ci:artefakt-*` — канон 197 (frozen-зависимость, слово задания «не меняй
канон 197», наблюдение критика не требование) — потому мутация-пара для lane публикации не
нужна. Развилок воли владельца нет: правка в границах слова 22.11 («обновить модель, адресные
стабы и SPEC»).

## Фактические двери (правка по FAIL, 2026-11-23)

Копия: `${TMPDIR-base} .scratch-147w` внутри изолированной копии architect-w, ветка
`wip/147/architect-w`, база OBJECT dde53fe039b7947b42a715b12f8ad6855a7c4306. Продукт —
`git archive` дерева PR #248 `wip/209/implementer` @ d3a17dd247a2c876890a823686b47304d65370ef
из живого репо (только чтение), распакован в scratch и удалён после замера.

| Команда (из корня копии) | Сырой rc | Вывод |
|---|---:|---|
| red_ci_147.py --model | 0 | MODEL_OK |
| red_ci_147.py --stabs | 0 | 46/46, каждая PRICHINA своя, непойманных 0 |
| red_ci_147.py --repo <модель postroj_model> | 0 | REGISTRACIJA_OK |
| red_ci_147.py (батарея OBJECT, извлечена git show) --repo <модель> контроль | 0 | REGISTRACIJA_OK |
| мутант значения lane `echo skipped`, батарея OBJECT, --repo | 0 | REGISTRACIJA_OK — красное-до: дыра воспроизведена |
| мутант значения lane `echo skipped`, обновлённая батарея, --repo | 1 | PRICHINA LANE_NE_KANON: значение 'echo skipped' != канону 'bash mobile/scripts/ci-ekran-gespraech-vhod.sh' |
| мутант значения lane канон + ` \|\| true`, обновлённая батарея (--stabs 12/46) | 1 (в матрице) | PRICHINA LANE_NE_KANON |
| bash red_gespraech_vhod_147.sh --model | 0 | геометрия 8/8, legacy 76/76 |
| bash red_gespraech_vhod_147.sh --stabs | 0 | геометрия 5/5, legacy SVJAZI 18 |
| bash scripts/verify_ci_parity.sh <копия> | 0 | расхождений 0 (база критика — то же) |
| bash scripts/verify_ci_parity.sh <PR #248 @ d3a17dd2> | 1 | расхождений 172 — равен замеру v6 на том же дереве, не хуже базы |
| модельные миры старой/новой батареи | — | package.json и mobile.yml побайтово идентичны (сравнение байт), паритет обоих rc 2 NOT_IMPLEMENTED (нет config/ci_parity_exceptions.txt) — одинаково |
| bash scripts/pre_critic.sh contracts/147-gespraech-vhod-menu.md | 1 | единственная красная нога — «последний FAIL 2: карта 0 строк» (разовое слово владельца 23.11, предмет 213) |
| bash scripts/check_sdacha.sh <копия> contracts/147-gespraech-vhod-menu.md --run | 1 | та же единственная причина через дверь листа |
| bash scripts/check_spec_ready.sh <копия> contracts/… · check_ids · check_ceilings · check_provodka --grammar · check_precision_gate · check_threat_model · check_predposylki · check_trek_ekrana · check_zone_147.sh | 0 | все девять дверей зелёные (сырой вывод в трассе круга) |
| bash scripts/check_provodka.sh <копия> contracts/… (полная, не --grammar) | 1 | именованный «guard не подключён: red_ci_147.py не вызывается в .githooks/ или .github/workflows/» — состояние базы OBJECT без изменения, проводка CI-шага за orchestrator в окне freeze..done |

Эмулятор, Maestro, RN/Jest и живой CI продукта не запускались: предмет круга — форма
CI-модели; исполнение пачки и lanes судит валидатор 132 v3 на работнике (критерии 3/4).
Правок .sh в этой пачке нет, bash -n не применялся; shellcheck на станции отсутствует
(ограничение среды, НЕ зелёная проверка). Значение lane приёмки судится побайтово против
MODEL_PKG — скрипт `mobile/scripts/ci-ekran-gespraech-vhod.sh` и его тело остаются зоной
implementer (ловец — валидатор 132 v3 на честной пачке критерия 3 и ревьюер).
