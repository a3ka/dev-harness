accept
OBJECT=fa8393d8fc5075df278b639cd993931442bd04ca
КЛАСС=кодовый (КЛАСС РИСКА: обычный — contracts/141-obryv-adb-diagnostika.md:4, regex двери `обычный` сходится; основание честное: диагностика/повтор CI, без прав/денег/ПД/согласий)
СУД: repo=dev-harness; предмет=141; фаза=контракт v3-испр. 2 (v+1, суд вместе с работниками); роль=critic; вызов=1/3; модель-план=zai/glm-5.3; сессия=Crit141v3; модель-факт=zai/glm-5.3 (trace-ac3.tsv: critic zai/glm-5.3 allowed, fallback не сработал); SHA=fa8393d8fc5075df278b639cd993931442bd04ca; предыдущий=verdicts/critic/contracts-141-v2.md (accept v2); исключение=нет. Коммит вердикта в wip/141/critic от origin/main (0814d2f5), identity critic, push по заданию не делаю.

Полный вызов 1/3 новой фазы v+1. Набор артефактов полон: предмет (:8-10), критерий готовности командами с rc (§Приёмка), исполнители/границы (§Зоны, ЗОНА-строки читает check_zones), КЛАСС РИСКА (:4), модель угроз (ЗАЩИЩАЕТ 3 / НЕ ЗАЩИЩАЕТ 3, гейт rc 0), РАЗРЕШИЛ-ВЛАДЕЛЕЦ v+1 в контракте (:6) и в теле коммита объекта. Объект сверен: `git rev-parse origin/wip/141/architect` → fa8393d8fc5075df278b639cd993931442bd04ca, tip один изменяющий коммит автора поверх ранее судимых v3-коммитов, тело несёт `РАЗРЕШИЛ-ВЛАДЕЛЕЦ: … 2026-11-12: «141 v3-испр. 2 разрешено»`.

## Дыра закрыта по месту (главный предмет v3-испр. 2)

Обход «required-агрегат `android-e2e` гасит обязательную проверку PR при байт-в-байт шагах/скриптах» на кандидате НЕ воспроизводится; каждая выключающая форма краснеет ровно своей причиной в клетке `struktura-upravlenie-job`, место падения измерено. Живые прогоны (мои мутанты, одноразовые деревья, якорь замены — единственное вхождение строки `if:` блока `android-e2e` / ключа после заголовка `  android-e2e:`):

```
$ python3 /tmp/dev-harness-verify/Crit141v3/mutants141.py   # каждый мутант: bash red_obryv_adb_diagnostika_141.sh --repo <дерево>
== M4a agg-if-False (bool): rc=1
    CASE struktura-upravlenie-job KRASNO (UPRAVLYAYUSHCHIJ_KLYUCH: job android-e2e: if=False (канон 143 (модель): "always() && (github.event_name == 'pull_request' || …)") — required-агрегат с иным if гасит обязательную проверку PR)
== M4b agg-if-kavychki 'false': rc=1  → та же ветвь литерального if (if='false')
== M4c agg-if-${{ false }}: rc=1      → та же ветвь (if='${{ false }}')
== M5 dubl-android-e2e (второй блок if: false; pyyaml last-wins): rc=1 → та же ветвь (if=False)
== M6 agg-if-alias-lozh (if: *lozh141, якорь → false): rc=1 → та же ветвь (if=False)
== M3 agg-strategy-fail-fast: rc=1
    CASE struktura-upravlenie-job KRASNO (UPRAVLYAYUSHCHIJ_KLYUCH: job android-e2e: лишние ключи: strategy)
$ continue-on-error: true на android-e2e (назван в инварианте 2): rc=1 → лишние ключи: continue-on-error
== K0 model-bez-izmenenij: rc=0; CASE struktura-upravlenie-job ok   (честный вход зелёный)
```
Стабы автора s-upr-agg-if-false и s-upr-agg-if-always-false красны каждый своим значением литерального `if` (в `--stabs` ниже, обе связи пойманы). Пробельный/регистровый обман литерала (`False`, `'false'`, `${{ false }}`, алиас-ложь, дубль ключа) разобран YAML-ом до одной и той же литеральной сверки — отдельного обхода нет.

## Ничего не ослаблено (дельта к frozen/contracts/141/2, построчно)

`git diff frozen/contracts/141/2^{commit}..fa8393d8f -- fixtures` и программная сверка оракулов:
- `kejsy`: 46=46, множество ключей прежнее, содержимое изменено ТОЛЬКО у трёх `opisanie` (kanon → вызов скрипта); удалений 0.
- `signatury_regex`, `signatur_vstrech` {135:2, 118:2, 995:1}, `signatury_ostatok_zapret` — байт-неизменны.
- `stab_vhod`: 52→56 стабов (новые: s-vyzov-obojden-135, s-script-net-995, s-upr-agg-if-false, s-upr-agg-if-always-false), связей 66→71 (+1 связь s-podmena-signatury-diag-118 → 118-devserverdied-povtor-spas), удалений 0. Замер заявленный 56/71 — сходится.
- `alfavit_vyrazhenij` = [] — СТРОЧЕЕ, не слабее: судимого выражения в скриптах не осталось (любое `${{ … }}` в скрипте субъекта → `VYRAZHENIE_VNE_ALFAVITA`); перенос побайтово сверен моим скриптом `perenos141.py`: 135/118 отличались от тел v2 ТОЛЬКО отступом выемки, судимые строки канона (grep-сигнатуры, ПОВТОР, boot/diag) не тронуты.
- Санкция v3-переноса (2026-11-05) покрывает ровно перенос: три тела → три скрипта + вызовы; дельта v3-испр. 2 — только агрегат (слово владельца 2026-11-12).

## Гейты и батарея (все исполнением, из корня клона на OBJECT)

```
$ bash scripts/pre_critic.sh --repo . contracts/141-obryv-adb-diagnostika.md  → КРИТИК: дверь зелёная, rc=0
$ bash scripts/check_precision_gate.sh . contracts/141-…md → OK, rc=0
$ bash scripts/check_threat_model.sh . contracts/141-…md → секция валидна (3/3), rc=0
$ bash scripts/check_ceilings.sh . → потолки в порядке, rc=0
$ bash scripts/check_spec_ready.sh . contracts/141-…md → OK, rc=0
$ bash scripts/check_provodka.sh . contracts/141-…md → rc=0
$ bash …/red_obryv_adb_diagnostika_141.sh            → rc=1, SUBJECT_ABSENT, 46 KRASNO
$ bash …/red_obryv_adb_diagnostika_141.sh --model    → rc=0, 46 ok / 0 KRASNO (22 replay = 11×135+8×118+3×995, 15 struktura, 9 derevo)
$ bash …/red_obryv_adb_diagnostika_141.sh --stabs    → rc=0, 46 CASE ok, 71 STAB … KRASEN (56 стабов), SVJAZI 71, zhivykh 0
$ python3 …/repo_control.py → rc=0: CONTROL_REPO_GREEN rc=0 cases=46; CONTROL_DIAG118_REPLAY_RED ×2; CONTROL_PIN_RED rc=1 SKRIPT_PIN_RASHOZHDENIE; CONTROL_CALL_RED rc=1 VYZOV_SKRIPTA
$ bash …/red_obryv_adb_diagnostika_141.sh --repo /home/harness/projects/Complior-mob → rc=1, 29 KRASNO: 13×SKRIPT_135_NET, 9×SKRIPT_118_NET, 4×SKRIPT_995_NET, 3×VYZOV_SKRIPTA — ожидаемое красное названо в приёмке дословно
```

## Н-39, согласованность, счёт

Привязка стабов — по КОДУ (`probe.py`: STAB_MUTACII/sdelat_stab, `m_upr_agg_*` через `_zameni_if_raboty` по блоку android-e2e), `stab_vhod` — только связи входов; pre_critic rc 0. Согласованность с замороженными: модель v3 равна frozen 141/2 и 143/1 по needs/if агрегата, работников и шагам агрегата (программная сверка yaml: все ключи True); имя `android-e2e` сохранено за required-агрегатом (нарезка 143), `mobile-regression-signal` вне required и вне суда 141 — конфликта нет; 163 ждёт именно `mobile/scripts/ci-*.{sh,cjs}` — v3 их заводит, lane-проводка остаётся окном 163 (v+1 заявок по его тексту); зоны 998-регистра не тронуты. Счётные утверждения контракта сверены ПОЛНЫМ списком, расхождений нет: 46/22(11+8+3)/15/9; 2-2-1; 52→56; 66→71; 29=13+9+4(+3 VYZOV); SVJAZI 71; zhivykh 0; «66 связей» в §Существующее = замер frozen 141/2 (исполнено: sum(stab_vhod)=66).

## Карта классов (К-01…К-17, LOOP-DESIGN.md §1)

- К-01: чисто — шесть гейтов rc 0 (выводы выше).
- К-02: чисто — источники названы: слово владельца 2026-11-12 (тело коммита объекта, процитировано в шапке), санкция переноса 2026-11-05, Н-407; `source.json.istochniki` {osnova, kandidat, lekalo, osnova_v2, osnova_v3}.
- К-03: чисто — затронутые frozen перечислены (141/2 замена по v+1; 135/118/995 перенос санкционирован; 143/163/998 — сверено выше, конфликтов нет).
- К-04: чисто — ЗОНА-строки на шесть ролей; производные (source.json, пины, модельные скрипты) в ЗОНЕ architect; продукт — зона implementer.
- К-05: чисто — каждый пункт §Приёмки командой с rc (все исполнены).
- К-06: чисто — rc 2 ветки в guard (нет python3 → rc 2 NOT_IMPLEMENTED; рассинхрон пинов → rc 2 ORACLE_TAMPERED); ПРЕДПОСЫЛКИ названы.
- К-07: чисто — CONTROL_REPO_GREEN rc=0 cases=46 на одноразовом дереве продукта; K0 зелёный.
- К-08: чисто — --stabs 56/71/0 живых; мои мутанты M3/M4a-c/M5/M6/continue-on-error красны ровно своим местом падения.
- К-09: совет — входы выключения агрегата покрыты (if-семейство, ключи, отсутствие); значения `needs`/`timeout-minutes` агрегата не покрыты (СОВЕТ 1/2 ниже).
- К-10: чисто — replay судит rc/записи/вывод сценарием, не маркеры субъекта; CONTROL_DIAG118_REPLAY_RED ловит подмену поведения при зелёном пине.
- К-11: чисто — оракул и пины в памяти ДО чтения субъекта, зона architect ≠ субъект.
- К-12: чисто — YAML разбирает pyyaml (шаг 117 пинит ту же версию); самописного разбора формата нет.
- К-13: чисто — замкнутые алфавиты: PATH-утилиты, ключи шага/job/workflow, выражения скриптов.
- К-14: чисто — зелёные ключи агрегата (name, permissions) остались зелёными (замер rc=0), pereformat-кейсы зелёные.
- К-15: чисто — все числа сверены живым выводом (список выше), расхождений нет.
- К-16: чисто — КЛАСС РИСКА обычный, основание совпадает с предметом; НЕ ЗАЩИЩАЕТ называет остаток (живой эмулятор/qemu, шаги до целевых, события on:).
- К-17: н/п — ARCH-INTEGRATION/схемы архитектуры в этом репозитории нет; предмет — батарея харнесса, не проектная архитектура бэкенда.

## Советы (едут с accept, закрытие на усмотрение автора)

СОВЕТ contracts/141-obryv-adb-diagnostika.md:19 — фраза инварианта 2 «needs агрегата сверяются по модели» реализована только как перекрёстная проверка МОДЕЛИ (`probe.py upravlenie_job`: model needs ⊇ {e2e-first-run, e2e-erstinformation, e2e-pilot}, иначе ORACLE_TAMPERED); субъектная needs агрегата не судится. Мои мутанты зелёные: needs агрегата обрезан до [select-screens, quality, build-apk] / [] / строкой / расширен mobile-regression-signal — все rc 0. Направление безопасное, обходного класса нет: живой продуктовый `mobile/scripts/ci-aggregate.cjs` (норма 143 И-5, сверен чтением) fail-closed — VNE_REESTRA при выбранных работниках вне needs, SLUZHEBNAYA_NE_ZELENA при отсутствии quality/build, PUSTOJ_NEEDS при пустом, mobile-regression-signal исключён из реестра работников по имени. Предложение: сверять субъектную needs с моделью тем же литеральным способом, что и `if`, либо переформулировать фразу как перекрёстную проверку модели, чтобы текст не обещал несудимую проверку.

СОВЕТ contracts/141-obryv-adb-diagnostika.md:19 — `timeout-minutes` агрегата значением не судится (мутант `timeout-minutes: 0` на android-e2e — rc 0; у работников J3 `tm >= 1` есть). Направление безопасное: нулевой таймаут в Actions — отмена/ошибка задания, required красный, не зелень; но симметрию J3 можно распространить на агрегат одной строкой кода.

СОВЕТ contracts/141-obryv-adb-diagnostika.md:14 — перенос тела 995 добавил кавычки вокруг `"$GITHUB_WORKSPACE"` (3 места: --repo/--apk/--out) сверх заявленной операции «с заменой только ${{ github.workspace }}/${{ github.run_id }}/${{ github.run_attempt }}»; семантически инертно (эквивалентно при путях без пробелов, корректнее при пробелах), судимое выражение не затронуто, пин покрывает фактический текст. Предложение: назвать нормализацию кавычек в тексте переноса или вернуть дословность.

## Не проверено

Живой GitHub Actions PR и реальный обрыв adb — вне батареи (§НЕ ЗАЩИЩАЕТ, ловец — первое живое падение CI). Проводка строки CI харнесса — оркестратор после freeze (по контракту).
