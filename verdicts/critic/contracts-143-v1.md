accept
OBJECT=5e1b7ac8504474e45272e3e4ea4144fe5a3e44de
СУД: repo=dev-harness; предмет=143; фаза=контракт; роль=critic-sol; вызов=scoped-повтор после арбитража (дополнительный вызов по стоячему слову владельца 25.10); модель-план=openai-codex/gpt-6-sol; сессия=Critic143d (идентификатор сессии из задания/ростера; OMP_SESSION_ID отсутствует); модель-факт=openai-codex/gpt-6-sol (workstation); SHA=5e1b7ac8504474e45272e3e4ea4144fe5a3e44de; предыдущий=verdicts/critic/contracts-143-v1-krug2.md FAIL (OBJECT 214aa6305); исключение=нет; независимость=автор zai/glm-5.3, судья openai-codex/gpt-6-sol.

Суждение по конечной границе `verdicts/arbitration/contracts-143-arbitraz.md`, прочитан целиком в main: Б1–Б4 закрыты, новая семантика субъекта не внесена. Исходник предмета взят `git clone /tmp/dev-harness-verify/Architect143/repo /tmp/dev-harness-verify/Critic143d/repo`, `git cat-file -t 5e1b7ac8504474e45272e3e4ea4144fe5a3e44de` → `commit`, затем checkout OBJECT. Раннеры, `gh run`, эмуляторы и workflow не запускались; push/commit не делались. Все копии мутантов — только под `/tmp/dev-harness-verify/Critic143d/`.

БЛОКИРУЕТ: нет.
СОВЕТ: нет.

## Исполненные команды и наблюдения

`W=bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh`, cwd `/tmp/dev-harness-verify/Critic143d/repo` (в командах ниже раскрыто `W`). Батареи запускались последовательно.

**Б1: отложенность не зелёная, приоритет красного и живого стаба.**

```
$ bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --model
[rc=2]
клеток 69, зелёных 68, красных 0
КЛЕТКА p01-P-nabor: NEEDS_PRECEDENT: 995 v5 — исполняемый набор P ещё rglob (frozen 995/4); место: drafts/995-v5-draft.md, freeze 995/5, перепин .harness модели 143 и носителей p-66052cdf.py/ci-e2e-995-4.sh в source.json ОТЛОЖЕНА
NOT_IMPLEMENTED: NEEDS_PRECEDENT 1 — клетка не зелёная и не красная, место названо выше
$ bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --stabs
[rc=2]
клеток 69, зелёных 68, красных 0
КЛЕТКА p01-P-nabor: NEEDS_PRECEDENT: 995 v5 — исполняемый набор P ещё rglob (frozen 995/4); место: drafts/995-v5-draft.md, freeze 995/5, перепин .harness модели 143 и носителей p-66052cdf.py/ci-e2e-995-4.sh в source.json ОТЛОЖЕНА
NOT_IMPLEMENTED: NEEDS_PRECEDENT 1 — клетка не зелёная и не красная, место названо выше
стабов 33, привязок 49, непойманных 0
```

`bash W` без флагов (реальная команда: `bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh`) → rc 1, первая строка `клеток 69, зелёных 0, красных 69 — SUBJECT_ABSENT (задайте --repo <корень продукта> или --model)` и 69 строк `КЛЕТКА <имя> КРАСНА: SUBJECT_ABSENT`. Локальная read-only копия #124 `mob` с HEAD `c617f6fb236d11574df75fb09ae41870bf8c29d6`:

```
$ bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo /tmp/dev-harness-verify/Critic143d/mob
[rc=1]
клеток 69, зелёных 3, красных 65
КЛЕТКА s01-obshchij-kod: SUBJECT_ABSENT КРАСНА
КЛЕТКА s02-lokalnyj-ekran: SUBJECT_ABSENT КРАСНА
КЛЕТКА s03-novyj-pack: SUBJECT_ABSENT КРАСНА
КЛЕТКА s04-novyj-potok: SUBJECT_ABSENT КРАСНА
КЛЕТКА s05-potok-dvoe-vladeltsev: SUBJECT_ABSENT КРАСНА
КЛЕТКА s06-glob-suzhen: SUBJECT_ABSENT КРАСНА
КЛЕТКА s07-status-snjat: SUBJECT_ABSENT КРАСНА
КЛЕТКА s08-zapis-udalena: SUBJECT_ABSENT КРАСНА
КЛЕТКА s09-rename-vnutri: SUBJECT_ABSENT КРАСНА
КЛЕТКА s10-rename-vne-karty: SUBJECT_ABSENT КРАСНА
КЛЕТКА s11-udalenie-fajla: SUBJECT_ABSENT КРАСНА
КЛЕТКА s12-probel-v-imeni: SUBJECT_ABSENT КРАСНА
КЛЕТКА s13-unicode-v-imeni: SUBJECT_ABSENT КРАСНА
КЛЕТКА s14-perevod-stroki: SUBJECT_ABSENT КРАСНА
КЛЕТКА s15-tip-izmenenija: SUBJECT_ABSENT КРАСНА
КЛЕТКА s16-net-bazy: SUBJECT_ABSENT КРАСНА
КЛЕТКА s17-api-usechenie: SUBJECT_ABSENT КРАСНА
КЛЕТКА s18-oshibka-diffa: SUBJECT_ABSENT КРАСНА
КЛЕТКА s19-shema-karty: SUBJECT_ABSENT КРАСНА
КЛЕТКА s20-pustoj-reestr: SUBJECT_ABSENT КРАСНА
КЛЕТКА s21-doksi-fallback: SUBJECT_ABSENT КРАСНА
КЛЕТКА s22-noch-polnyj-nabor: SUBJECT_ABSENT КРАСНА
КЛЕТКА s23-push-do-posle: SUBJECT_ABSENT КРАСНА
КЛЕТКА s24-api-fallback-zhivoj: SUBJECT_ABSENT КРАСНА
КЛЕТКА s25-merge-gruppa: SUBJECT_ABSENT КРАСНА
КЛЕТКА a01-pustoj-nabor: SUBJECT_ABSENT КРАСНА
КЛЕТКА a02-vybrannyj-vne-reestra: SUBJECT_ABSENT КРАСНА
КЛЕТКА a03-vybrannyj-skip: SUBJECT_ABSENT КРАСНА
КЛЕТКА a04-vybrannyj-cancelled: SUBJECT_ABSENT КРАСНА
КЛЕТКА a05-vybrannyj-timeout: SUBJECT_ABSENT КРАСНА
КЛЕТКА a06-vybrannyj-failure: SUBJECT_ABSENT КРАСНА
КЛЕТКА a07-selector-upal: SUBJECT_ABSENT КРАСНА
КЛЕТКА a08-sborka-upala: SUBJECT_ABSENT КРАСНА
КЛЕТКА a09-kachestvo-upalo: SUBJECT_ABSENT КРАСНА
КЛЕТКА a10-digest-chuzhoj: SUBJECT_ABSENT КРАСНА
КЛЕТКА a11-staryj-artefakt: SUBJECT_ABSENT КРАСНА
КЛЕТКА a12-lishnij-rabotnik: SUBJECT_ABSENT КРАСНА
КЛЕТКА a13-skip-bez-prichiny: SUBJECT_ABSENT КРАСНА
КЛЕТКА a14-iskljuchennyj-objasnen: SUBJECT_ABSENT КРАСНА
КЛЕТКА a15-otmena-odnogo: SUBJECT_ABSENT КРАСНА
КЛЕТКА a16-pustoj-needs: SUBJECT_ABSENT КРАСНА
КЛЕТКА a17-digest-do-ustanovki: e2e-splash без шага digest КРАСНА
КЛЕТКА y01-nabor-jobs: jobs ['android-e2e', 'quality'] КРАСНА
КЛЕТКА y02-agregat-needs: needs агрегата quality КРАСНА
КЛЕТКА y03-agregat-if-always: if агрегата None КРАСНА
КЛЕТКА y07-uslovija-rabotnikov: if e2e-splash: None КРАСНА
КЛЕТКА y08-tajmauty: timeout e2e-splash КРАСНА
КЛЕТКА y09-sobytija-i-net-139: нет schedule/dispatch КРАСНА
КЛЕТКА y10-rabotniki-na-pule: runs-on e2e-splash: None КРАСНА
КЛЕТКА y11-apk-identichnost: build-apk без outputs идентичности КРАСНА
КЛЕТКА y12-avd-namespace: e2e-splash без PORT КРАСНА
КЛЕТКА y13-odin-uroven-vosstanovlenija: e2e-splash: маркеров ПОВТОР 0, канон 1 КРАСНА
КЛЕТКА y14-jest-118: нет same-job session-Jest КРАСНА
КЛЕТКА y15-h-checkouty: e2e-splash без checkout .harness123 КРАСНА
КЛЕТКА y16-noch-polnyj-nabor: селектор не знает schedule КРАСНА
КЛЕТКА y17-noch-ne-required: сигнал не ограничен schedule/dispatch КРАСНА
КЛЕТКА y18-marker-nochi: нет маркера ночи КРАСНА
КЛЕТКА y19-outputs-provodka: outputs build-apk: [] КРАСНА
КЛЕТКА y21-concurrency: грамматика concurrency вне канона (pull_request): -${{ github.ref }} КРАСНА
КЛЕТКА y22-needs-rabotnikov: e2e-splash: needs None; e2e-first-run: needs None; e2e-erstinformation: needs None; e2e-start: needs None; e2e-pilot: needs None КРАСНА
КЛЕТКА y20-tojson-needs: SUBJECT_ABSENT КРАСНА
КЛЕТКА f01-fiksirovannyj-nabor-P: SUBJECT_ABSENT КРАСНА
КЛЕТКА f02-vladenie-potokami: SUBJECT_ABSENT КРАСНА
КЛЕТКА f04-statusy-i-vhody: SUBJECT_ABSENT КРАСНА
КЛЕТКА f03-paki-v-karte: SUBJECT_ABSENT КРАСНА
КЛЕТКА p01-P-nabor: NEEDS_PRECEDENT: 995 v5 — исполняемый набор P ещё rglob (frozen 995/4); место: drafts/995-v5-draft.md, freeze 995/5, перепин .harness модели 143 и носителей p-66052cdf.py/ci-e2e-995-4.sh в source.json ОТЛОЖЕНА
NOT_IMPLEMENTED: NEEDS_PRECEDENT 1 — клетка не зелёная и не красная, место названо выше
```

**Б2: новые собственные мутанты `needs`.** Команда `python3 /tmp/dev-harness-verify/Critic143d/attacks.py` создала отдельные копии модели, заменила все пять `needs: [select-screens, build-apk]` на названные строки; затем запустила следующие реальные команды (stdout без изменений):

```
$ bash /tmp/dev-harness-verify/Critic143d/repo/fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo /tmp/dev-harness-verify/Critic143d/attacks/without-build-all
[rc=1]
клеток 69, зелёных 65, красных 3
КЛЕТКА a17-digest-do-ustanovki: e2e-splash: РЕНДЕР_ВНЕ_АЛФАВИТА: needs.build-apk.outputs.artifact_name КРАСНА
КЛЕТКА y22-needs-rabotnikov: e2e-splash: needs ['select-screens']; e2e-first-run: needs ['select-screens']; e2e-erstinformation: needs ['select-screens']; e2e-start: needs ['select-screens']; e2e-pilot: needs ['select-screens'] КРАСНА
КЛЕТКА y20-tojson-needs: РЕНДЕР_ВНЕ_АЛФАВИТА: needs.build-apk.outputs.artifact_name КРАСНА
КЛЕТКА p01-P-nabor: NEEDS_PRECEDENT: 995 v5 — исполняемый набор P ещё rglob (frozen 995/4); место: drafts/995-v5-draft.md, freeze 995/5, перепин .harness модели 143 и носителей p-66052cdf.py/ci-e2e-995-4.sh в source.json ОТЛОЖЕНА
NOT_IMPLEMENTED: NEEDS_PRECEDENT 1 — клетка не зелёная и не красная, место названо выше
$ bash /tmp/dev-harness-verify/Critic143d/repo/fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo /tmp/dev-harness-verify/Critic143d/attacks/without-selector-all
[rc=1]
клеток 69, зелёных 67, красных 1
КЛЕТКА y22-needs-rabotnikov: e2e-splash: needs ['build-apk']; e2e-first-run: needs ['build-apk']; e2e-erstinformation: needs ['build-apk']; e2e-start: needs ['build-apk']; e2e-pilot: needs ['build-apk'] КРАСНА
КЛЕТКА p01-P-nabor: NEEDS_PRECEDENT: 995 v5 — исполняемый набор P ещё rglob (frozen 995/4); место: drafts/995-v5-draft.md, freeze 995/5, перепин .harness модели 143 и носителей p-66052cdf.py/ci-e2e-995-4.sh в source.json ОТЛОЖЕНА
NOT_IMPLEMENTED: NEEDS_PRECEDENT 1 — клетка не зелёная и не красная, место названо выше
$ bash /tmp/dev-harness-verify/Critic143d/repo/fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo /tmp/dev-harness-verify/Critic143d/attacks/with-neighbor-all
[rc=1]
клеток 69, зелёных 67, красных 1
КЛЕТКА y22-needs-rabotnikov: e2e-splash: needs ['select-screens', 'build-apk', 'e2e-splash']; e2e-first-run: needs ['select-screens', 'build-apk', 'e2e-splash']; e2e-erstinformation: needs ['select-screens', 'build-apk', 'e2e-splash']; e2e-start: needs ['select-screens', 'build-apk', 'e2e-splash']; e2e-pilot: needs ['select-screens', 'build-apk', 'e2e-splash'] КРАСНА
КЛЕТКА p01-P-nabor: NEEDS_PRECEDENT: 995 v5 — исполняемый набор P ещё rglob (frozen 995/4); место: drafts/995-v5-draft.md, freeze 995/5, перепин .harness модели 143 и носителей p-66052cdf.py/ci-e2e-995-4.sh в source.json ОТЛОЖЕНА
NOT_IMPLEMENTED: NEEDS_PRECEDENT 1 — клетка не зелёная и не красная, место названо выше
```

Отдельно `python3 neighbor.py` заменил только needs задачи `e2e-splash` на `[select-screens, build-apk, e2e-first-run]`, остальные четыре не трогал:

```
$ bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo /tmp/dev-harness-verify/Critic143d/attacks/with-neighbor-single
[rc=1]
клеток 69, зелёных 67, красных 1
КЛЕТКА y22-needs-rabotnikov: e2e-splash: needs ['select-screens', 'build-apk', 'e2e-first-run'] КРАСНА
КЛЕТКА p01-P-nabor: NEEDS_PRECEDENT: 995 v5 — исполняемый набор P ещё rglob (frozen 995/4); место: drafts/995-v5-draft.md, freeze 995/5, перепин .harness модели 143 и носителей p-66052cdf.py/ci-e2e-995-4.sh в source.json ОТЛОЖЕНА
NOT_IMPLEMENTED: NEEDS_PRECEDENT 1 — клетка не зелёная и не красная, место названо выше
```

Приоритет `STAB_ZHIV` проверен отдельной копией батареи: замена только `stabs/stab_y_bez_build_apk.py` на честный no-op (никаких других правок); `--stabs` не смог принять его зелёным при одновременно отложенной p01:

```
$ bash /tmp/dev-harness-verify/Critic143d/attacks/surviving-stub/red_mob_ci_143.sh --stabs
[rc=1]
клеток 69, зелёных 68, красных 0
КЛЕТКА p01-P-nabor: NEEDS_PRECEDENT: 995 v5 — исполняемый набор P ещё rglob (frozen 995/4); место: drafts/995-v5-draft.md, freeze 995/5, перепин .harness модели 143 и носителей p-66052cdf.py/ci-e2e-995-4.sh в source.json ОТЛОЖЕНА
NOT_IMPLEMENTED: NEEDS_PRECEDENT 1 — клетка не зелёная и не красная, место названо выше
стабов 33, привязок 49, непойманных 2
STAB_ZHIV: stab_y_bez_build_apk прошёл вход y22-needs-rabotnikov
STAB_ZHIV: stab_y_bez_build_apk прошёл вход a17-digest-do-ustanovki
```

**Б3: единый ключ.** `grep` по контракту и всей батарее `fikirovannyj` → ни одного совпадения; `fiksirovannyj_nabor` обнаружен в `contracts/143-mob-ci-razdelenie.md:52`, `drafts/995-v5-draft.md:45,51`, `probe.py:111,1506`, `model/mobile/ci-screens.json:93`, `model/mobile/scripts/select-ci-screens.cjs:68`, `stabs/stab_f_P_vkljuchaet_ekran.py:11`. Клетка f01 в source.json — `f01-fiksirovannyj-nabor-P`, тестовый стаб модели `--stabs` пройден. Текст и субъект согласованы.

**Б4: census и пины.** `python3 attacks.py` отдельно копировал весь каталог батареи, удалял `123-v3-draft.md`, портил первый байт `995-v5-draft.md`, добавлял `extra.md`:

```
$ bash /tmp/dev-harness-verify/Critic143d/attacks/delete-123/red_mob_ci_143.sh --model
[rc=2]
ORACLE_TAMPERED: черновики: перепись ['111-v5-draft.md', '116-v4-draft.md', '117-v5-draft.md', '118-v3-draft.md', '123-v3-draft.md', '138-v2-draft.md', '139-v3-draft.md', '141-v2-draft.md', '995-v5-draft.md'] ≠ дерево ['111-v5-draft.md', '116-v4-draft.md', '117-v5-draft.md', '118-v3-draft.md', '138-v2-draft.md', '139-v3-draft.md', '141-v2-draft.md', '995-v5-draft.md']
$ bash /tmp/dev-harness-verify/Critic143d/attacks/corrupt-995/red_mob_ci_143.sh --model
[rc=2]
ORACLE_TAMPERED: черновик: sha256 995-v5-draft.md
$ bash /tmp/dev-harness-verify/Critic143d/attacks/extra-draft/red_mob_ci_143.sh --model
[rc=2]
ORACLE_TAMPERED: черновики: перепись ['111-v5-draft.md', '116-v4-draft.md', '117-v5-draft.md', '118-v3-draft.md', '123-v3-draft.md', '138-v2-draft.md', '139-v3-draft.md', '141-v2-draft.md', '995-v5-draft.md'] ≠ дерево ['111-v5-draft.md', '116-v4-draft.md', '117-v5-draft.md', '118-v3-draft.md', '123-v3-draft.md', '138-v2-draft.md', '139-v3-draft.md', '141-v2-draft.md', '995-v5-draft.md', 'extra.md']
```

`python3 -c '...source.json...'` → `cells 69 stubs 33 bindings 49 pins 21 drafts 9` (12 основных пинов + 9 черновиков). `python3 check_hunks.py` сверил старые строки original hunks с frozen-текстами из `frozen/contracts/123/2` и `frozen/contracts/995/4` → `123 v2: old hunk matches frozen; 1 removed line(s), 1 old context line(s)`; `995 v4: old hunk matches frozen; 2 removed line(s), 9 old context line(s)`; применимость остальных семи не пересуждалась (их пины не менялись).

**Зависимый регресс и механика.** `git diff 214aa6305 5e1b7ac85 --stat` → 6 файлов, только 143 контракт, `osi.md`, `probe.py`, `source.json`, `stabs/stab_y_bez_build_apk.py`, `drafts/995-v5-draft.md`; прежние клетки и стабы байт-неизменны. `git diff origin/main..HEAD -- contracts/ ':!contracts/143-mob-ci-razdelenie.md'` → пусто. Поиск `^РАЗРЕШИЛ-ВЛАДЕЛЕЦ` в fixtures/workshop_project/mob_ci_143/ → пусто. `bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Critic143d/repo contracts/143-mob-ci-razdelenie.md` → rc 0 `OK`; `check_spec_ready.sh` с теми же двумя аргументами → rc 0 `OK`; `check_ceilings.sh` → rc 0 `потолки в порядке`; `check_threat_model.sh` → rc 0 `модель угроз: секция валидна (ЗАЩИЩАЕТ 9 буллет(ов), НЕ ЗАЩИЩАЕТ 9 буллет(ов))`; `bash scripts/pre_critic.sh --repo /tmp/dev-harness-verify/Critic143d/repo contracts/143-mob-ci-razdelenie.md` → rc 0 `КРИТИК: дверь зелёная`.

Соседи, по одному: `bash fixtures/workshop_project/pilot_995/restart/red_ci_e2e_restart_995.sh --stabs` → rc 0, `SVJAZI 60`, `zhivykh 0`; `bash fixtures/workshop_project/e2e_avtoperezapusk_139/red_e2e_avtoperezapusk_139.sh --stabs` → rc 0, `SVJAZI 60`; `bash fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --stabs` → rc 0, `SVJAZI 61`, `zhivykh 0`. Соседние батареи — локальные replay, без запуска workflow/эмуляторов.
