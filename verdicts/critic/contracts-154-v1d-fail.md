FAIL
OBJECT=0e5cff12353d4eafffb1ce1f607137ddf025650f
СУД: repo=dev-harness; предмет=154; фаза=контракт (+красная батарея); роль=critic; вызов=4/5 (исправительный по HANDOFF.md:1); модель-план=openai-codex/gpt-6-sol; сессия=Crit154d; модель-факт=openai-codex/gpt-6-sol; SHA=0e5cff12353d4eafffb1ce1f607137ddf025650f; предыдущий=FAIL (contracts-154-v1c-fail.md, OBJECT 832dab55d, вызов 3; вызовы 1/2 — contracts-154-v1-fail.md, contracts-154-v1b-fail.md); исключение=нет.

Предмет — commit (`git cat-file -t OBJECT` → `commit`), изолированный клон `/tmp/dev-harness-verify/Crit154d/repo` на OBJECT; основной репозиторий и ветка автора не правились. Дельта v1d от 832dab55d затронула только контракт и `probe.py`. Её автор Arch154e — zai/glm-5.3; прямое слово владельца 2026-11-02 назначило Sol критиком 154, модель-факт судьи openai-codex/gpt-6-sol. Счёт 4/5 сверён с записью ДО вызова в HANDOFF и тремя предыдущими вердиктами; дописку факта сессии в HANDOFF по трейсу до материализации выполняет оркестратор. Письменного названного спора автора нет; повтор Б8 сам по себе не вызывает арбитраж (§Быстрый-процесс §Остановка).

Итог: **FAIL, один блокирующий класс — Б8**. Частный мутант `if subject==001` пойман, но свойство «кап не зависит от активного номера предмета» не доказано: простое расширение списка допустимых тестовых номеров 001,152 вновь делает батарею зелёной и разрешает шестой вызов действующего нового предмета 154. Б1–Б7 и прежние С1–С10 на проверенных поверхностях не регрессировали.

## БЛОКИРУЕТ

**Б8 (повтор класса: приёмка зафиксировала конечные имена вместо предметного свойства). БЛОКИРУЕТ contracts/154-schet-vyzovov-kritika.md:35, :44, :47–49, :186; fixtures/workshop_project/schet_vyzovov_154/probe.py:25–32, :632–660, :680–707.**
ОБЯЗАТЕЛЬСТВО: И-1/И-2 — для любого нового `(repoId,subjectId)` после пяти critic START нельзя начать шестой, после шестого нельзя freeze; ЗАЩИЩАЕТ :186 прямо обещает независимость порога от активного номера. Приёмка :49 должна отличать обход от честной реализации.
КЛАСС ПРИЧИНЫ: установленную реализацию W/`--domain`/`--live` испытывают лишь на активных номерах 001 и 152 и старом 137. `--model`/`--domain-model`/`--stabs` устанавливают собственную честную модель во временном мире и поэтому не видят изменений поставленных scripts. Стаб subject-only-001 проверяет одно конкретное условие, а не общее свойство.
СОСТОЯНИЕ: одноразовый `ins` — эталонная модель батареи вставлена в НАСТОЯЩИЕ `scripts/zamok_predmeta.sh` и `scripts/freeze_contract.sh`, затем в обоих скриптах бюджет исполняется лишь при `subject == 001 || subject == 152` (строки `$sv`/`$NNN` соответственно). Никакие другие ветви не менялись. `id/CONTRACT/154` уже выдан; `git merge-base --is-ancestor id/CONTRACT/154 5ca237e4e` → rc 1 (НОВЫЙ). Toy `contracts/154-x.md` закоммичен, ledger START/verdict корректны; подмена журнала или тега не используется.
ОБХОД: W и W --domain на поставленных обманных scripts дают все клетки зелёными, W --live тоже. Прямой допустимый сценарий для 154 на тех же scripts разрешает шестой START (spawn rc 0 вместо KAP) и замораживает после шестого (freeze rc 0 с тегом и реестром вместо KAP). Честная установка на этих же двух входах зелена.
НАБЛЮДЕНИЕ — все команды атаки реально исполнены из корня `ins`, дословный вывод (для длинных матриц в самой выполненной команде отфильтрованы ТОЛЬКО строки `GREEN`, число которых показано; `pipefail` сохраняет rc):
```
$ python3 /tmp/dev-harness-verify/Crit154d/subject_bypass.py /tmp/dev-harness-verify/Crit154d/ins
zamok_predmeta.sh budget enforced only for 001 or 152
freeze_contract.sh budget enforced only for 001 or 152
$ bash -o pipefail -c 'bash fixtures/workshop_project/schet_vyzovov_154/red_schet_vyzovov_154.sh | python3 -c "import sys; ls=sys.stdin.read().splitlines(); print(chr(10).join(x for x in ls if not x.startswith(\"GREEN \"))); print(\"GREEN_ROWS=\",sum(x.startswith(\"GREEN \") for x in ls))"'
CELLS=49 GREEN=49
GREEN_ROWS= 49
[exit=0]
$ bash -o pipefail -c 'bash fixtures/workshop_project/schet_vyzovov_154/red_schet_vyzovov_154.sh --domain | python3 -c "import sys; ls=sys.stdin.read().splitlines(); print(chr(10).join(x for x in ls if not x.startswith(\"GREEN \"))); print(\"GREEN_ROWS=\",sum(x.startswith(\"GREEN \") for x in ls))"'
CELLS=210 GREEN=210
GREEN_ROWS= 210
$ bash fixtures/workshop_project/schet_vyzovov_154/red_schet_vyzovov_154.sh --live
GREEN live-old-door-shestoj
GREEN live-old-freeze-klapan
GREEN live-old-freeze-kap
GREEN live-new-tag-door
GREEN live-new-tag-freeze
GREEN live-new-notag-door
GREEN live-no-granica-door
GREEN live-old2-door-shestoj
GREEN live-old2-freeze-klapan
CELLS=9 GREEN=9
[exit=0]
$ PYTHONPATH=fixtures/workshop_project/schet_vyzovov_154 python3 -c "import probe; print(probe.scenario('subject154-spawn-sixth',5,'spawn',subject='154') or 'GREEN')"
subject154-spawn-sixth: expected KAP_VYZOVOV_KRITIKA, actual rc 0:
$ PYTHONPATH=fixtures/workshop_project/schet_vyzovov_154 python3 -c "import probe; print(probe.scenario('subject154-freeze-six',6,'freeze',subject='154') or 'GREEN')"
subject154-freeze-six: expected KAP_VYZOVOV_KRITIKA, actual rc 0: OK secrets=0 variables=0 environments=0 settings=0
  ok   заморожено: contracts/154-x.md → frozen/contracts/154/1 («criterion accepted»)
  ok   реестр закоммичен: 154 → f7fc90d5b9bfb272f66cb26ebc8d1343404f2994
  ok   реестр записан: 154 → f7fc90d5b9bfb272f66cb26ebc8d1343404f2994
```
После переустановки честной модели прямые два `scenario` напечатали `spawn: GREEN` и `freeze: GREEN`. Проверка `--model`/`--domain-model`/`--stabs` на обманной паре отдельно не запускалась: режимы создают свою модель, это следует из `probe.py:710–745`; их rc на исходном дереве измерены ниже.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: приёмка поставленных scripts проверяет кап для предметных и repoId-ключей независимо от фиксированных имён 001/152, включая текущий новый номер 154 и станционный repoId, на двери и freeze. Эта обманная пара краснеет собственными клетками, честная зелена. Способ построения динамических входов/параметрического испытания автор выбирает сам; добавление очередного постоянного имени без свойства не закрывает причину.

## Закрытие прежних классов; сырые замеры

`W` = `bash fixtures/workshop_project/schet_vyzovov_154/red_schet_vyzovov_154.sh` из указанного корня; `repo` — OBJECT без реализации, `ins` — честная установленная модель ДО мутации. Режимы `--domain-model` и `--domain` были прогнаны последовательно, их полные выводы состоят из именованных GREEN/RED и строк итога; в отчёте показаны итоги и существенные клетки.
```
repo $ W                 → rc 1; CELLS=49 GREEN=10 (39 RED)
repo $ W --model         → rc 0; CELLS=52 GREEN=52
repo $ W --domain        → rc 1; CELLS=210 GREEN=82; все четыре domain-subject-152-*/domain-repoid-drugoj-* красны
repo $ W --domain-model  → rc 0; CELLS=214 GREEN=214 (214 строк GREEN)
repo $ W --stabs         → rc 0; SVJAZI=21 CAUGHT=21 LIVE=0; обе subject-only-001 свои: expected KAP, actual rc 0
repo $ W --live          → rc 1; CELLS=9 GREEN=5; обе live-old2-* зелены
ins  $ W                 → rc 0; CELLS=49 GREEN=49
ins  $ W --domain        → rc 0; CELLS=210 GREEN=210
ins  $ W --live          → rc 0; CELLS=9 GREEN=9
repo $ bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh → rc 1; KLETKI 66 KRASNYH 3
ins  $ bash fixtures/workshop_project/odin_agent_140/red_odin_agent_140.sh → rc 1; KLETKI 66 KRASNYH 3
ins  $ bash fixtures/plan_084/red_plan_084.sh → rc 1; ИТОГ: клеток 59, красных 6 (ф2/ф3/ф4/ф6/ф9/ф10 — SCHET_NEIZVESTEN), зелёных 53
ins  $ python3 fixtures/check_check_contract_ready/_doc027.py lifecycle → rc 1 DOC-lifecycle/freeze-doc-control, SCHET_NEIZVESTEN
ins  $ bash fixtures/workshop_project/red_samodostatochnost_repo_060.sh → rc 1; 17 клеток, зелёных 14; красны к3-е/к6б/к6е
ins  $ bash fixtures/workshop_project/rezhim_996/probe.sh --case freeze-cap → rc 1 PROJECT_CAP_BYPASSED
ins  $ bash fixtures/workshop_project/rezhim_996/probe.sh --case freeze-project-arbitration → rc 1 PROJECT_ARBITRATION_NOT_READ
ins  $ bash fixtures/workshop_project/rezhim_996/probe.sh --case freeze-root-arbitration → rc 1 PROJECT_CAP_BYPASSED
ins  $ bash fixtures/workshop_project/rezhim_996/probe.sh --case freeze-gate-preserved → rc 1 PROJECT_GATE_REPAIR_REFUSED:spec
ins  $ bash scripts/drill_contract_change.sh → rc 1, отказ SCHET_NEIZVESTEN на шаге «заморозка v1»
```
Это необходимая миграция потребителей, не ошибка честного бюджета: contract :13, :50, зоны :57 и ПЕРЕСЕЧЕНИЯ :73–76 требуют rc 0 ПОСЛЕ миграции. Frozen 084/1 показал владение architect отдельными файлами `fixtures/plan_084/`. Б1 закрыт двумя сторонами rc и зелёными клетками; Б2 назван и наблюдаем; Б3–Б5 имеют модель/домен, включая чужой repoId, чужой subjectId/роль, источник, verdict-сироту, засев и старую область. Б6 проверен живым снимком (старые 001 и 137, новые с тегом/без него); Б7 — осью одинакового OBJECT; все 21 стаб пойманы (Б3/Б7/старые классы включены). Отдельную подстановку каждого старого мутанта в установленную реализацию в этом scoped-повторе не повторяли. Неухудшение 140 подтверждено количеством до/после; имена трёх красных u01/w20/w21 установлены предыдущими судами, в выводе этого прогона печатался только итог.

Последовательные ворота:
```
$ bash scripts/pre_critic.sh contracts/154-schet-vyzovov-kritika.md → rc 0; КРИТИК: дверь зелёная
$ bash scripts/check_ceilings.sh → rc 0; 148 черновик(ов) судится
$ bash scripts/check_precision_gate.sh . contracts/154-schet-vyzovov-kritika.md → rc 0; OK
$ bash scripts/check_threat_model.sh . contracts/154-schet-vyzovov-kritika.md → rc 0; ЗАЩИЩАЕТ 5, НЕ ЗАЩИЩАЕТ 6
$ bash scripts/check_provodka.sh . contracts/154-schet-vyzovov-kritika.md → rc 1; guard не подключён (до CI, ожидаемо)
$ bash scripts/check_zones.sh . → rc 0; замороженных контрактов: 148 · объявленных авторов: 5 · коммитов в диапазонах: 42110 · проверено по зонам: 10037
```
Последний гейт завершился этой сводкой без `FAIL` (в скрипте `bad()` печатает `FAIL` на любой ошибке, итоговая ветка без ошибок — `exit 0`); отчёт Arch154e измерял 42091/10018, разница +19/+19 из-за дрейфа истории между клонами, не число в тексте контракта. Гейты не запускались параллельно.

## САМООПИСАНИЕ — полный список механических расхождений

- **САМООПИСАНИЕ contracts/154-schet-vyzovov-kritika.md:27:** текст «на момент замера v1d их 163 [тега]» → живой `git tag -l 'id/CONTRACT/*' | wc -l` в клоне печатает **164**. Динамическая команда в тексте корректна; историческое число дрейфовало, единственный неэквивалентный для двух граничных коммитов тег остаётся `id/CONTRACT/138` (проверены все 164). Это НЕ блокирующее расхождение.
- Совпали все другие числовые утверждения контракта: 49 клеток/39 красных, 52=49+3, 210/214=136+8+22+12+16+12+4+4 (живая группировка DOMAIN: 72 spawn + 64 freeze + 8 arb + 22 source + 12 foreign + 16 do-zhurnala + 12 object + 2 subject + 2 repoid), 20 уникальных мутантов/21 стаб-клетка (две subject-only-001), live 9, 084 59/6, 060 17/14, 140 66/3, потолки 148. `probe.py:376/:379` — адреса ПРЕЖНЕГО вердикта v1b, в тексте кандидата их нет; теперь gate `probe.py:381`, oracle `probe.py:395`. Совпали адрес `zamok_predmeta.sh:127–129`, AGENTS.md:171–173, frozen 140 §Приёмочный критерий п.9, BASELINE 7fd217d79. Числа 42091/10018 были только в отчёте автора, а не в тексте контракта (живое 42110/10037). Не обнаружено новых ошибок С1–С10.

## СОВЕТ

- **СОВЕТ contracts/154-schet-vyzovov-kritika.md:40, :200.** Засев `doZhurnala=1` при ≥4 до-журнальных вердиктах 148 недосчитывает реальные платные сессии. Контракт теперь ЯВНО помещает нижнюю границу в НЕ ЗАЩИЩАЕТ и отдаёт выбор владельцу/уполномоченному оркестратору; вне этой границы это не новый инженерный блок. Цена риска и кому доверить засев — решение владельца, передать до принятия границы, а не молчаливый auto-accept.
- **СОВЕТ contracts/154-schet-vyzovov-kritika.md:57, :73–76.** Frozen 084/1 относит отдельные файлы `fixtures/plan_084/*` к architect; frozen 008/2 относит check_check_contract_ready/ к architect. ПЕРЕСЕЧЕНИЕ с 084 и 008 не названо, но precision и zones сейчас пропускают; прежний совет v1c без механического блока.

НЕ проверено: полный перенос потребителей после реализации, вся батарея `fixtures/freeze_contract/`, живой `spawn-guard.ts → task`, внешний CI, Android/нативные сборки. Одноразовая мутация осталась только под `/tmp/dev-harness-verify/Crit154d/`, не в ветке автора.
