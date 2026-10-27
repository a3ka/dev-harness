accept
OBJECT=ca6f863c4c6365072dc4425f4f2366e58c9b8320
СУД: repo=dev-harness; предмет=141; фаза=контракт v2 (адресная по 143, правка по вердикту); роль=critic; вызов=2/2; модель-план=openai-codex/gpt-6-sol; сессия=Crit141b; модель-факт=openai-codex/gpt-6-sol (workstation); SHA=ca6f863c4c6365072dc4425f4f2366e58c9b8320; предыдущий=contracts-141-v2-krug1-fail FAIL; исключение=нет. Фактическую независимость модели автора сверяет оркестратор по трейсу до материализации (трейс автора в задании отсутствует). Коммит и push запрещены заданием.

Блокер предыдущего вердикта закрыт. `contracts/141-obryv-adb-diagnostika.md:47` требует `select-screens` в `needs` каждой из трёх задач с каноническим `if`; `:52-55` требует красный `REBRO_NEEDS`. Единственный `JOB_IF_KANON` в `probe.py:353-362` даёт имя ребра через `split('.')[1]`; проверка `upravlenie_job` проходит по всем трём задачам, по отдельности возвращает `REBRO_NEEDS`. Все три атаки удалением ребра при неизменных `if` и `run` краснят только `struktura-upravlenie-job`. Н-39: пять новых `s-upr-job-rebro-*` — пять *кодовых* мутантов (`probe.py:1118-1157`), каждый пойман на своём входе; `source.json` задаёт лишь привязки. Блокирующих находок в области scoped-повтора нет.

СОВЕТ contracts/141-obryv-adb-diagnostika.md:47 — `needs: [select-screens, false]` (некорректная для GitHub Actions форма, YAML-разбор принимает) возвращает `UPRAVLYAYUSHCHIJ_KLYUCH`, а не `REBRO_NEEDS`: элементы списка явно не проверяются на строковость. Но батарея по этому кандидату уже rc 1, 45 ok/1 KRASNO: прежний обход и ложная зелень отсутствуют; это лишь точность диагноза для недопустимого Actions-значения, вне класса предыдущего блокера. Сырой результат ниже.

Подготовка: `git cat-file -t ca6f863c4c6365072dc4425f4f2366e58c9b8320` → `commit`, rc 0; `git clone /tmp/dev-harness-verify/Addr141/repo /tmp/dev-harness-verify/Crit141b/repo` → HEAD ca6f863c, rc 0; `git clone ssh://git@github.com/a3ka/dev-harness.git /tmp/dev-harness-verify/Crit141b/origin` → rc 0; `cp -a /tmp/dev-harness-verify/Addr141/target-tree /tmp/dev-harness-verify/Crit141b/target-tree` → rc 0. Монолит склонирован в собственный каталог: `git -C Crit141b/monolith rev-parse HEAD` → `d0140101c6c4fca94687cf88c418344cd9601d59`, rc 0.

Батареи запускались последовательно из `Crit141b/repo`:
```
$ bash fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --model
rc=0; CASE ok=46
$ bash fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --stabs
STAB s-upr-job-rebro-118-net struktura-upravlenie-job KRASEN
STAB s-upr-job-rebro-135-net struktura-upravlenie-job KRASEN
STAB s-upr-job-rebro-995-net struktura-upravlenie-job KRASEN
STAB s-upr-job-rebro-ne-spisok struktura-upravlenie-job KRASEN
STAB s-upr-job-rebro-pusto struktura-upravlenie-job KRASEN
SVJAZI 66
zhivykh 0
rc=0; CASE ok=46, STAB KRASEN=66
$ bash fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Addr141/target-tree
rc=0; CASE ok=46
$ bash fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Crit141b/monolith
CASE 135-oflin-povtor-spas KRASNO (SHAG_135_NET)
CASE 118-oflin-povtor-spas KRASNO (SHAG_118_NET)
CASE 995-diag-signatura KRASNO (SHAG_995_NET)
CASE struktura-upravlenie-job KRASNO (JOB_NET: e2e-first-run)
rc=1; CASE KRASNO=36 (15/12/8/1, только адресные семейства), CASE ok=10
```

Сырые красные строки собственных атак: `python3 attack_needs.py` в `Crit141b` копировал каждую версию через `cp -a` в `Crit141b/attack-<метка>`, менял только `needs` названного job и выполнял `W --repo` по одной копии за раз. Ниже вывод скрипта для всех девяти W: `CASE ok` — число опущенных из печати зелёных строк; *полные* 46-строчные логи сохранены под `Crit141b/attack-<метка>.log`. Общий rc скрипта 1 только из-за его дополнительного утверждения о *точном имени диагноза* девятой формы; все девять W имеют rc 1.
```
$ python3 attack_needs.py
$ bash /tmp/dev-harness-verify/Crit141b/repo/fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Crit141b/attack-135-net
MUTATION e2e-first-run.needs='needs: [build-apk]'
CASE struktura-upravlenie-job KRASNO (REBRO_NEEDS: job e2e-first-run: нет ребра select-screens в needs=['build-apk'] (канонический if ссылается на needs.select-screens.outputs — без ребра работа не выбирается по селектору, шаги не исполняются; канон 143 И-3 (модель): needs=['select-screens', 'build-apk']))
rc=1; CASE ok=45; CASE KRASNO=1; log=/tmp/dev-harness-verify/Crit141b/attack-135-net.log
$ bash /tmp/dev-harness-verify/Crit141b/repo/fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Crit141b/attack-118-net
MUTATION e2e-erstinformation.needs='needs: [build-apk]'
CASE struktura-upravlenie-job KRASNO (REBRO_NEEDS: job e2e-erstinformation: нет ребра select-screens в needs=['build-apk'] (канонический if ссылается на needs.select-screens.outputs — без ребра работа не выбирается по селектору, шаги не исполняются; канон 143 И-3 (модель): needs=['select-screens', 'build-apk']))
rc=1; CASE ok=45; CASE KRASNO=1; log=/tmp/dev-harness-verify/Crit141b/attack-118-net.log
$ bash /tmp/dev-harness-verify/Crit141b/repo/fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Crit141b/attack-995-net
MUTATION e2e-pilot.needs='needs: [build-apk]'
CASE struktura-upravlenie-job KRASNO (REBRO_NEEDS: job e2e-pilot: нет ребра select-screens в needs=['build-apk'] (канонический if ссылается на needs.select-screens.outputs — без ребра работа не выбирается по селектору, шаги не исполняются; канон 143 И-3 (модель): needs=['select-screens', 'build-apk']))
rc=1; CASE ok=45; CASE KRASNO=1; log=/tmp/dev-harness-verify/Crit141b/attack-995-net.log
$ bash /tmp/dev-harness-verify/Crit141b/repo/fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Crit141b/attack-string-trap
MUTATION e2e-first-run.needs='needs: select-screens, build-apk'
CASE struktura-upravlenie-job KRASNO (REBRO_NEEDS: job e2e-first-run: needs='select-screens, build-apk' не список (канонический if ссылается на needs.select-screens.outputs — контекст выбора даёт только ребро needs; канон 143 И-3 (модель): needs=['select-screens', 'build-apk']))
rc=1; CASE ok=45; CASE KRASNO=1; log=/tmp/dev-harness-verify/Crit141b/attack-string-trap.log
$ bash /tmp/dev-harness-verify/Crit141b/repo/fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Crit141b/attack-string-plain
MUTATION e2e-first-run.needs='needs: "build-apk"'
CASE struktura-upravlenie-job KRASNO (REBRO_NEEDS: job e2e-first-run: needs='build-apk' не список (канонический if ссылается на needs.select-screens.outputs — контекст выбора даёт только ребро needs; канон 143 И-3 (модель): needs=['select-screens', 'build-apk']))
rc=1; CASE ok=45; CASE KRASNO=1; log=/tmp/dev-harness-verify/Crit141b/attack-string-plain.log
$ bash /tmp/dev-harness-verify/Crit141b/repo/fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Crit141b/attack-empty
MUTATION e2e-first-run.needs='needs: []'
CASE struktura-upravlenie-job KRASNO (REBRO_NEEDS: job e2e-first-run: нет ребра select-screens в needs=[] (канонический if ссылается на needs.select-screens.outputs — без ребра работа не выбирается по селектору, шаги не исполняются; канон 143 И-3 (модель): needs=['select-screens', 'build-apk']))
rc=1; CASE ok=45; CASE KRASNO=1; log=/tmp/dev-harness-verify/Crit141b/attack-empty.log
$ bash /tmp/dev-harness-verify/Crit141b/repo/fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Crit141b/attack-absent
MUTATION e2e-first-run.needs=None
CASE struktura-upravlenie-job KRASNO (REBRO_NEEDS: job e2e-first-run: needs=None не список (канонический if ссылается на needs.select-screens.outputs — контекст выбора даёт только ребро needs; канон 143 И-3 (модель): needs=['select-screens', 'build-apk']))
rc=1; CASE ok=45; CASE KRASNO=1; log=/tmp/dev-harness-verify/Crit141b/attack-absent.log
$ bash /tmp/dev-harness-verify/Crit141b/repo/fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Crit141b/attack-expression
MUTATION e2e-first-run.needs='needs: ${{ fromJSON(\'["select-screens","build-apk"]\') }}'
CASE struktura-upravlenie-job KRASNO (REBRO_NEEDS: job e2e-first-run: needs='${{ fromJSON(\'["select-screens","build-apk"]\') }}' не список (канонический if ссылается на needs.select-screens.outputs — контекст выбора даёт только ребро needs; канон 143 И-3 (модель): needs=['select-screens', 'build-apk']))
rc=1; CASE ok=45; CASE KRASNO=1; log=/tmp/dev-harness-verify/Crit141b/attack-expression.log
$ bash /tmp/dev-harness-verify/Crit141b/repo/fixtures/workshop_project/obryv_adb_diagnostika_141/red_obryv_adb_diagnostika_141.sh --repo /tmp/dev-harness-verify/Crit141b/attack-not-all-strings
MUTATION e2e-first-run.needs='needs: [select-screens, false]'
CASE struktura-upravlenie-job KRASNO (UPRAVLYAYUSHCHIJ_KLYUCH: job e2e-first-run: needs на несуществующую работу False)
rc=1; CASE ok=45; CASE KRASNO=1; log=/tmp/dev-harness-verify/Crit141b/attack-not-all-strings.log
UNEXPECTED NEEDS VERDICT
```

Дельта: `git diff --name-only HEAD~1..HEAD` → `contracts/141-obryv-adb-diagnostika.md`, `fixtures/workshop_project/obryv_adb_diagnostika_141/probe.py`, `.../source.json` (все ЗОНА architect). 139 v3 — промежуточный коммит `aa1894d3`; `git diff --quiet aa1894d3 HEAD -- contracts/139-e2e-avtoperezapusk.md fixtures/workshop_project/e2e_avtoperezapusk_139` → rc 0. Поэтому `git diff 03b15d21 ca6f863c` включает также уже принятый 139 v3; собственная исправительная дельта 141 — только ось needs. `sha256sum` модели/носителя/целевого workflow → `e9c705efcb8612f85299ac07573f05bf191fcda9da7b94b58bba655914e6d3e2` / `b4c83b888d3ec1e2daa9c9b014b3cf3ee3fa741c71e5098d38f81e2006140341` / `e9c705efcb8612f85299ac07573f05bf191fcda9da7b94b58bba655914e6d3e2`; модель/носитель не менялись относительно 03b15d21 (`git diff --quiet` rc 0). `source.json`: 41→46 клеток, 47→52 стабов, 61→66 связей; прежние 47/47 привязок и 40/41 клеток неизменны (одна дополнена лишь семантикой needs), прежние пины равны.

Гейты, все из `Crit141b/repo`:
```
$ bash scripts/pre_critic.sh --repo . contracts/141-obryv-adb-diagnostika.md
КРИТИК: дверь зелёная
rc=0
$ bash scripts/check_precision_gate.sh . contracts/141-obryv-adb-diagnostika.md
OK
rc=0
$ bash scripts/check_spec_ready.sh . contracts/141-obryv-adb-diagnostika.md
OK
rc=0
$ bash scripts/check_ceilings.sh .
потолки в порядке
rc=0
$ bash scripts/check_threat_model.sh . contracts/141-obryv-adb-diagnostika.md
модель угроз: секция валидна (ЗАЩИЩАЕТ 13 буллет(ов), НЕ ЗАЩИЩАЕТ 10 буллет(ов))
rc=0
```

Не проверено: живой GitHub Actions PR и реальное поведение эмулятора — область отдельного CI-прогона. `scripts/check_provodka.sh` не вызывался: проводка оркестратора после заморозки, вне scoped-суда.
