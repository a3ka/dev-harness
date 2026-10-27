FAIL
OBJECT=03b15d210616bc819a6be52904d6d19a3add6cb0
СУД: repo=dev-harness; предмет=141; фаза=контракт (адресная v+1 по 143); роль=critic; вызов=1/2; модель-план=openai-codex/gpt-6-sol; сессия=Crit141a (идентификатор агента; отдельный session-id в задании/окружении не предоставлен); модель-факт=openai-codex/gpt-6-sol (workstation); SHA=03b15d210616bc819a6be52904d6d19a3add6cb0; предыдущий=нет; исключение=нет. Автор коммита — architect; фактическая модель автора в доступном трейсе не указана: независимость модели автора подтверждает оркестратор до materialize.

БЛОКИРУЕТ contracts/141-obryv-adb-diagnostika.md:47 — класс причины: каноническое условие выбора job без нужного ребра `needs` не исполняет шаги, однако 141 признаёт кандидата полностью зелёным. 141 называет исполнение трёх шагов, литеральный `if: needs.select-screens.outputs['<job>'] == 'true'` и J2 («каждая работа needs существует»); 143 И-3 требует у экранного работника одновременно `[select-screens, build-apk]`. Из J2 не следует наличие нужной зависимости: удаление `select-screens` оставляет каждое существующее `needs` валидным, но обращение к отсутствующему `needs.select-screens` даёт ложный выбор. Владелец требует адресной миграции, а задание суда прямо требует красной клетки 141 на этом мутанте.
ОБХОД: в допустимой копии целевого дерева заменить только `e2e-first-run.needs: [select-screens, build-apk]` на `[build-apk]`; `if` и тела всех трёх целевых шагов оставить неизменными. `W --repo` даёт rc 0, 41/41 ok; на PR работа first-run не выбирается по селектору (отсутствующий needs-контекст), диагностика/повтор 135 не исполняются. Закрывающее свойство: 141 проверяет, что канонический job-if каждого из трёх носителей ссылается на явно присутствующую в `needs` работу `select-screens`, и мутация краснит адресную клетку (без изменения тел, кадров и порогов). Это не второй класс про полноту всего DAG 143.

Сырая атака (копия `/tmp/dev-harness-verify/Addr141/target-tree` создана `cp -a` в `/tmp/dev-harness-verify/Crit141a/mutant-tree`, изменён только YAML в копии):
```
$ python3 mutate.py needs && bash repo/fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Crit141a/mutant-tree
MUTATION needs replacement 1
CASE 135-oflin-povtor-spas ok
CASE 135-adb-notfound ok
CASE 135-serial-notfound ok
CASE 135-devserverdied-povtor-krasen ok
CASE 135-chistyj-proval ok
CASE 135-zelenyj ok
CASE 135-boot-ne-zagruzilsja ok
CASE 135-stabil-nedostizhima ok
CASE 135-emulator-log-hvost ok
CASE 135-install-failed-bez-povtora ok
CASE 135-pustoj-maestro-out ok
CASE 118-oflin-povtor-spas ok
CASE 118-devserverdied-povtor-spas ok
CASE 118-povtor-tozhe-krasen ok
CASE 118-chistyj-proval ok
CASE 118-zelenyj ok
CASE 118-boot-ne-zagruzilsja ok
CASE 118-stabil-nedostizhima ok
CASE 118-emulator-log-hvost ok
CASE 995-diag-signatura ok
CASE 995-chistyj-proval ok
CASE 995-zelenyj ok
CASE struktura-shag135 ok
CASE struktura-shag118 ok
CASE struktura-shag995 ok
CASE struktura-pereformat135 ok
CASE struktura-pereformat118 ok
CASE struktura-pereformat995 ok
CASE struktura-signatura135 ok
CASE struktura-signatura118 ok
CASE struktura-signatura995 ok
CASE struktura-vyrazhenija ok
CASE struktura-upravlenie-shag135 ok
CASE struktura-upravlenie-shag118 ok
CASE struktura-upravlenie-shag995 ok
CASE struktura-upravlenie-job ok
CASE struktura-upravlenie-workflow ok
CASE derevo-bez-141 ok
CASE derevo-chuzhoj-shag ok
CASE derevo-job-zakonnaja-pravka ok
CASE derevo-shag-net ok
rc=0
```

Другие сырые атаки (во всех запусках 41 CASE, остальные `ok`; приведён диагностический CASE и реальный rc):
```
$ python3 mutate.py rename && bash repo/fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Crit141a/mutant-tree
MUTATION rename replacement 1
CASE 135-oflin-povtor-spas KRASNO (SHAG_135_NET)
CASE struktura-upravlenie-job KRASNO (JOB_NET: e2e-first-run)
rc=1
$ python3 mutate.py if && bash repo/fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Crit141a/mutant-tree
MUTATION if replacement 1
CASE struktura-upravlenie-job KRASNO (UPRAVLYAYUSHCHIJ_KLYUCH: job e2e-first-run: if=False (канон 143: "needs.select-screens.outputs['e2e-first-run'] == 'true'"))
rc=1
$ python3 mutate.py strategy && bash repo/fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Crit141a/mutant-tree
MUTATION strategy replacement 1
CASE struktura-upravlenie-job KRASNO (UPRAVLYAYUSHCHIJ_KLYUCH: job e2e-first-run: лишние ключи: strategy)
rc=1
$ python3 mutate.py continue && bash repo/fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Crit141a/mutant-tree
MUTATION continue replacement 1
CASE struktura-upravlenie-job KRASNO (UPRAVLYAYUSHCHIJ_KLYUCH: job e2e-pilot: лишние ключи: continue-on-error)
rc=1
```

Проверено: `git cat-file -t OBJECT` → commit; SHA родом от frozen 141/1; `git diff frozen/contracts/141/1 OBJECT -- contracts/141-obryv-adb-diagnostika.md` — только версия, предмет, инвариант 11 и §Замены v2; `python3 check_drafts.py` → `141 draft removed 2 added 2 missing old 0 missing new 0`. `sha256sum` моделей 141 и 143 и целевого workflow совпали: `e9c705efcb8612f85299ac07573f05bf191fcda9da7b94b58bba655914e6d3e2`; 135/118/995 `run` побайтово равны frozen 141/1 (4304/4545/1390 байт). source.json: 41/47/61, имена и связи стабов не менялись, сигнатуры и пин старого носителя сохранены; 9 перепривязанных job-стабов реально красны на `struktura-upravlenie-job`.

```
$ bash fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --model
rc=0; 41 строк CASE … ok
$ bash fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --stabs
SVJAZI 61
zhivykh 0
rc=0; 41 CASE ok, 61 STAB KRASEN
$ bash fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Addr141/target-tree
rc=0; 41 CASE ok
$ bash fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Crit141a/monolith
CASE 135-oflin-povtor-spas KRASNO (SHAG_135_NET)
CASE 118-oflin-povtor-spas KRASNO (SHAG_118_NET)
CASE 995-diag-signatura KRASNO (SHAG_995_NET)
CASE struktura-upravlenie-job KRASNO (JOB_NET: e2e-first-run)
CASE struktura-upravlenie-workflow ok
rc=1; 36 красных адреса, 5 зелёных
```
Гейты: `bash scripts/check_precision_gate.sh . contracts/141-obryv-adb-diagnostika.md` rc 0 `OK`; `bash scripts/pre_critic.sh --repo . contracts/141-obryv-adb-diagnostika.md` rc 0 `КРИТИК: дверь зелёная`; `bash scripts/check_spec_ready.sh . contracts/141-obryv-adb-diagnostika.md` rc 0 `OK`; `bash scripts/check_ceilings.sh .` rc 0 `потолки в порядке`; `bash scripts/check_threat_model.sh . contracts/141-obryv-adb-diagnostika.md` rc 0 `модель угроз: секция валидна`; `bash scripts/check_provodka.sh . contracts/141-obryv-adb-diagnostika.md` rc 1 `проводка: guard не подключён` — это явно отложенный до интеграции ПРОВОДКА-ЭНФОРСМЕНТ, не самостоятельный блокер адресной миграции.

НЕ проверено: GitHub Actions на живом раннере и платформа `needs` в реальном PR; соответствующий обманный YAML доказан статическим/контрактным противоречием и rc 0 батареи. Отдельный session-id и модель-факт автора недоступны по данному заданию, требуют оркестраторской сверки перед материализацией. Коммит и push вердикта запрещены заданием.
