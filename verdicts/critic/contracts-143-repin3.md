accept
OBJECT=8053f51052631d5f701265235235d0e35e945bd1
СУД: repo=dev-harness; предмет=143; фаза=реализация-перепин (итог по арбитражу + доп-перепин по живой приёмке); роль=critic; вызов=scoped по перечню арбитра (после 2/2 FAIL); модель-план=роль critic; сессия=Crit143r3; модель-факт=openai-codex/gpt-6-sol; SHA=8053f51052631d5f701265235235d0e35e945bd1; предыдущий=critic 143 repin 1/2 FAIL, 2/2 FAIL, арбитраж БЛОКЕР; исключение=нет

ИТОГ: блокер арбитра P1/P2 закрыт на допустимых мутациях; дополнительный перепин `.harness117` адресен и не даёт ложной зелени. Никаких новых осей суда не открывал. Само принятие батареи НЕ означает зелёный живой CI: продукт до отдельной поставки 117 v5 имеет 34 уже существовавших красных поведенческих W1A-клетки; не скрывать этот остаток при cutover.

### Статус перечня арбитра

1. ЗАКРЫТО. В клоне `git cat-file -t 8053f51052631d5f701265235235d0e35e945bd1` → `commit`, rc 0; `git rev-parse HEAD` → `8053f51052631d5f701265235235d0e35e945bd1`, rc 0. Из корня клона `W=bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh`: `W --model` три независимых исполнения, каждое rc 0, сырой вывод каждого: `клеток 69, зелёных 69, красных 0`; `W --stabs` rc 0, вывод `клеток 69, зелёных 69, красных 0` / `стабов 33, привязок 49, непойманных 0`; `W` rc 1, первая строка вывода `клеток 69, зелёных 0, красных 69 — SUBJECT_ABSENT (задайте --repo <корень продукта> или --model)`, далее 69 строк `КЛЕТКА … КРАСНА: SUBJECT_ABSENT` (от s01 до p01).
2. ЗАКРЫТО. `python3 /tmp/dev-harness-verify/Crit143r3/attack_p.py` → rc 0; одноразовые копии модели, каждая `W --repo <копия>`; ниже сырой вывод повторного полного прогона (в первом проходе собственная ошибка утверждения `'8' not in 'зелёных 68'` оборвала прогон после б1; это дефект только throwaway-assertion, исправлен до полного прогона):
```
second-full-P: rc=1; клеток 69, зелёных 68, красных 1
    КЛЕТКА p01-P-nabor: запусков P 2: e2e-pilot[7], e2e-pilot[9] — И-8 требует ровно один запуск P в e2e-pilot КРАСНА
android-e2e-P: rc=1; клеток 69, зелёных 68, красных 1
    КЛЕТКА p01-P-nabor: запусков P 2: e2e-pilot[7], android-e2e[1] — И-8 требует ровно один запуск P в e2e-pilot КРАСНА
./.harness: rc=1; клеток 69, зелёных 68, красных 1
    КЛЕТКА p01-P-nabor: пин .harness 66052cdf (frozen 995/4): P копирует ВЕСЬ каталог rglob-ом — Maestro запрошен ['cmp-mob-002-tabs.yaml', 'cmp-mob-004-start.yaml', 'erstinformation.yaml', 'first-run-ekran.yaml', 'pilot.yaml', 'rehearsal.yaml', 'start.yaml', 'vkhod-117-splash-vhod.yaml'], фиксированный набор P (И-8) не исполняется; перепин на 4ac99af9fe8b02f16206b5c98bb9556556c05e74 обязателен КРАСНА
.harness/: rc=1; клеток 69, зелёных 68, красных 1
    КЛЕТКА p01-P-nabor: пин .harness 66052cdf (frozen 995/4): P копирует ВЕСЬ каталог rglob-ом — Maestro запрошен ['cmp-mob-002-tabs.yaml', 'cmp-mob-004-start.yaml', 'erstinformation.yaml', 'first-run-ekran.yaml', 'pilot.yaml', 'rehearsal.yaml', 'start.yaml', 'vkhod-117-splash-vhod.yaml'], фиксированный набор P (И-8) не исполняется; перепин на 4ac99af9fe8b02f16206b5c98bb9556556c05e74 обязателен КРАСНА
${{ github.workspace }}/.harness: rc=1; клеток 69, зелёных 68, красных 1
    КЛЕТКА p01-P-nabor: путь checkout неизмерим: ${{ github.workspace }}/.harness КРАСНА
.harness: rc=1; клеток 69, зелёных 68, красных 1
    КЛЕТКА p01-P-nabor: пин .harness 66052cdf (frozen 995/4): P копирует ВЕСЬ каталог rglob-ом — Maestro запрошен ['cmp-mob-002-tabs.yaml', 'cmp-mob-004-start.yaml', 'erstinformation.yaml', 'first-run-ekran.yaml', 'pilot.yaml', 'rehearsal.yaml', 'start.yaml', 'vkhod-117-splash-vhod.yaml'], фиксированный набор P (И-8) не исполняется; перепин на 4ac99af9fe8b02f16206b5c98bb9556556c05e74 обязателен КРАСНА
bad-before-good: rc=0; клеток 69, зелёных 69, красных 0
bad-after-P: rc=0; клеток 69, зелёных 69, красных 0
good-alias: rc=0; клеток 69, зелёных 69, красных 0
```
3. ЗАКРЫТО. Последние три строки выше — обратные зелёные ветви: плохой→хороший exact, retired ПОСЛЕ P, хороший `./.harness` ДО P соответственно. Контроль double-exact остаётся красен исполнением rglob и восемью флоу; стаб `_p_rglob_kataloga` не переписан, привязки по коду — решение architect, Н-39.
4. ЗАКРЫТО. `osi.md:112-145` и `_ref_harness_h` docstring `probe.py:978-1010` называют P1 (единственный литеральный P-run по всем jobs), P2 (нормализация checkout-каталога и красный динамический путь), остаток (P без литерала в run; shell-перезапись H; живая семантика needs/if/concurrency) и ловцов (ревью cutover-PR, адверсарий, живая приёмка). `git diff frozen/contracts/143/1 HEAD -- contracts/143-mob-ci-razdelenie.md` → пусто, rc 0; `git show -s --format=%an HEAD` → `architect`, rc 0; `bash scripts/check_zones.sh` → итог `замороженных контрактов: 141 · объявленных авторов: 5 · коммитов в диапазонах: 35335 · проверено по зонам: 7682`, rc 0 (первый прогон с deadline 180 s был прерван; второй завершился через 318.87 s). `python3 tamper_matrix.py` → rc 0: порча 12 piny и 9 chernoviki_piny, retired-нагрузка corrupt/delete/replace — каждый отдельный запуск W rc 2 `ORACLE_TAMPERED` ДО клеток; последняя сырая строка `21 pins + retired corrupt/delete/replace: rc2 all`. Census кодом: `model=4, nositeli=8, stabs=33, drafts=9; pins=12+9=21; cells=69; stab_vhod=33, bindings=49`. Новая модель-piny `0ca3317edf8e8c930801902803b1350c819769dc0d1ee3965d99a3ea87abbe83`; её одиночная порча отдельно дала `rc 2 stderr ORACLE_TAMPERED: пин: sha256 model/.github/workflows/mobile.yml`.
5. СОБЛЮДЕНО. Неназванные арбитром формы исполнения — остаток/СОВЕТ, не новые блокирующие оси. Следующий FAIL по иной причине — к владельцу, здесь действительных блокеров нет.

### Доп-перепин D (`model/.github/workflows/mobile.yml:285-322`)

D1 ЗАКРЫТО. Замена только `.harness117` 8d3f48b8 → 4ac99af9, имя freeze 117/5, версия pyyaml и комментарий; diff к предыдущему кандидату `3278b713` меняет ТОЛЬКО модельный `mobile.yml` и её SHA-пин `source.json`, НЕ `probe.py`, носителей, клеток, стабов, черновиков. Зона architect покрывает оба файла. В инвентаре 143:73 117 перепиняется собственной пачкой, в §Порядок:133-134 модель cutover передаётся интегратору после подписи адресных v+1; v5 уже заморожена, `git merge-base --is-ancestor frozen/contracts/117/5 4ac99af9…` rc 0 и `git diff --exit-code 4ac99af9 frozen/contracts/117/5 -- fixtures/workshop_project/vkhod_117/` rc 0. Здесь батарея 143 только пинует уже готовую отдельную пачку для *собственной* cutover-модели; никакой правки контрактов или батареи 117 в 143 нет. Модель продукта cutover cb03387 и модель HEAD `cmp -s ...mobile.yml` → rc 0 до будущей правки PR.

D2 ЗАКРЫТО С НАЗВАННЫМ ОСТАТКОМ. Инвентарь YAML всех `.harness*` checkout: quality `.harness=b9b4c66f`, `.harness117=4ac99af9`; `e2e-splash`, `e2e-first-run`, `e2e-erstinformation`: три `.harness123=5d98a1cd`; `e2e-first-run` `.harness135=ca277b3a`; `e2e-erstinformation` `.harness118=5dbcb549`; `e2e-pilot` `.harness=4ac99af9`. Других checkout `.harness*` нет. Прогнаны в порядке исполнимые без сети/эмулятора шаги `jobs.quality` на **копии** продукта cb03387 с извлечёнными из точных git-пинов H и 117 и штатным `mobile/node_modules`, без записи в продукт; сырой журнал команд и rc для КАЖДОГО — `/tmp/dev-harness-verify/Crit143r3/quality_clean.py` и `quality-clean-logs/{имя}.out,.err`. `python3 quality_clean.py` → rc 0 (драйвер не маскирует индивидуальные rc: печатает каждый). Сырые итоговые строки:
```
RC cmp-test=0
RC cmp-source=0
RC 995-check=0
RC 995-runtime=0
RC 995-bundle=0
RC 995-schema=0
RC 995-frozen_matrix=0
RC 995-transport=0
RC 995-admission=0
RC 995-stale=0
RC 995-types=0
RC 995-pins=0
RC 995-admission_family=0
RC 995-stale_table=0
RC 999-nav=0
RC 999-ui=0
RC 999-shell_static=0
RC 999-copy=0
RC 108-start_static=0
RC 108-start=0
RC 111-first_run_static=0
RC 111-first_run=0
RC 117-static=0
RC 117-behavior=1
RC npm-test=0
RC npm-lint=0
RC npm-typecheck=0
RC npm-doctor=0
```
Статическая 117: `static 70/70` (включая все три `SVERKA_123_*`); поведенческая `failed 34 of 191` — ранее существовавшие W1A из продуктового экрана, НЕ зелёная живая quality до поставки 117 v5. Контроль: `python3 compare_117.py` → `monolith rc 1 summary failed 34 of 191` / `split rc 1 summary failed 34 of 191` / `same output True stderr `; `git diff --exit-code ed852ee cb03387 -- mobile/src` rc 0. Первые два экспериментальных запуска quality на копиях с неправильно *добавленным* symlink `node_modules/node_modules` дали ложные rc 1/2 (`Invalid hook call` / `ASSERTION_SET_MISMATCH`); обнаружена ошибка подготовки disposable-копии (оригинальный node_modules УЖЕ присутствовал), чистый повтор без symlink с теми же пинами дал результаты выше. Имена логов прежних невалидных попыток `quality-logs/`, `quality-real-logs/` — не свидетельство регрессии. npm ci, pip install и эмулятор/Maestro/артефакты/реальный GitHub rerun локально не исполнялись.

D3 ЗАКРЫТО. `git diff --exit-code 5d98a1cd745ce08eeb21b89f8e05750c4e769a0e 4ac99af9… -- scripts/sverka_maketa.py fixtures/workshop_project/mob_sverka_123/` rc 0: форма/порог/манифест/скрипт у оставленного `.harness123` эквивалентны ревизии v5; черновик 123 v3 меняет только текст *placement*-критерия 6 (android-e2e → e2e-splash), критерий 5 и checker не переписаны. 117 v5 `source.json:sverka_123.provodka` требует ref по форме 40-hex, не несуществующий точный ref 117: поэтому оставленное трижды 5d98a1cd измеримо и не требует внепланового перепина.

D4 ЗАКРЫТО. Смена пина НЕ заменила проверку заглушкой и не ослабила её: `python3 H117-old/.../vkhod_static_probe.py --repo monolith` → rc 0 `static 40/40`; тот же старый v2 на cutover → rc 1 ровно `RED SVERKA_123_STEP_UNCONDITIONAL`, `RED SVERKA_123_MANIFEST_CANON`, `RED SVERKA_123_HARNESS_PIN`; новый v5 на cutover → rc 0 `static 70/70`, на монолите → rc 1 ровно те же три RED, остальные 67 зелёны (вывод 67 case). Новый v5 ещё требует `SVERKA_123_CATCHES_CLASS_B`; остальные байты checker и манифеста неизменны (D3). Поведенческая на обоих деревьях rc 1 ровно `failed 34 of 191` до адресной продуктовой поставки: одинаковый сырой stdout (см. D2), а не введённая перепином смена порога. Путь live CI не перепроверен локально: это остаток живой приёмки, не основание выдавать зелёный PR #136.

БЛОКИРУЮЩИХ НАХОДОК НЕТ. Нерасширенная граница угроз P и красная 117 до отдельного продуктового PR указаны как остатки, а не замаскированы `accept`.
