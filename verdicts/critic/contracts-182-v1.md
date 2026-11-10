accept
OBJECT=c21bffff1be835a3d5ed004711aada17875b9d4c
СУД: repo=dev-harness; предмет=182; фаза=контракт; роль=critic; вызов=2/2; модель-план=zai/glm-5.3; сессия=Crit182v2; модель-факт=openai-codex/gpt-5.6-terra; SHA=c21bffff1be835a3d5ed004711aada17875b9d4c; предыдущий=verdicts/critic/contracts-182-v1-krug1-fail.md; исключение=нет

# Вердикт критика — контракт 182 «актуальный срез „где мы по плану“ после перезапуска», исправительный вызов 2/2

OBJECT подтверждён в одноразовом SSH-клоне: `git rev-parse HEAD` дал `c21bffff1be835a3d5ed004711aada17875b9d4c`; до записи этого вердикта рабочее дерево было чистым. Автор кандидата — `architect <architect@dev-harness.local>`; судья — отдельная сессия `Crit182v2`, собственной работы не судит. План модели — `zai/glm-5.3`; фактическая модель сессии — `openai-codex/gpt-5.6-terra`.

Строка запуска 2/2 с тем же OBJECT и предыдущим `FAIL` доступна в опубликованном `HANDOFF.md`; она разрешает именно исправительную проверку. Область этого вызова ограничена закрытием единственного класса из `verdicts/critic/contracts-182-v1-krug1-fail.md` и последствиями семантической дельты `c21bffff^..c21bffff`: из 182 удалены миграция `brief`/клетки 095 и связанный `brief-die`-стаб. Неизменённые поверхности заново не исследовались.

## Закрытие прежнего блока

Прежний блок требовал не подменять active-fatal поведение frozen 095 без отдельно разрешённых v+1 и `РАЗРЕШИЛ-ВЛАДЕЛЕЦ:`. Он закрыт:

- `contracts/182-plan-posle-perezapuska.md:6,23` прямо сохраняет active-fatal правило 095, выносит маркерную миграцию в будущий предмет `095 v+1` и запрещает 182 менять `brief`, его legacy-клетку либо frozen 095.
- Дельта кандидата содержит только `contracts/182-plan-posle-perezapuska.md` и `fixtures/workshop_project/plan_restart_182/probe.py`; `scripts/make_task.sh`, `fixtures/context_pack_095/red_orch_brief_karta_legacy.sh` и `contracts/095-profil-i-vhod-agenta-contextpack.md` в ней не изменены.
- `git diff --exit-code frozen/contracts/095/1 -- contracts/095-profil-i-vhod-agenta-contextpack.md` чист; независимая legacy-клетка 095 прошла с rc 0. Тем самым прежний rc 1/пустой stdout для активного контракта без `## Предмет` сохранён фактической регрессией, а не только декларацией.
- Последствие дельты проверено по 182: модель теперь содержит девять клеток и четыре уместных стаба (`handoff`, `stale`, `local`, `no-roadmap`); старые brief-клетки и `brief-die` удалены вместе с изъятой семантикой. `contracts/182-plan-posle-perezapuska.md:27-38` сохраняет самостоятельный CLI-срез, отказ на расходящемся published `ROADMAP`, роль-потребитель только после успешного brief и явную границу незащищённого active-fatal пути.

Названный владельцем предмет — недопущение выдачи устаревших «ЖДЁТ УТРА» вместо порядка `ROADMAP` (`docs/owner/2026-11-10-dnevnye-resheniya.md:7-10`). Удаление неразрешённой миграции 095 не сужает это обязательство: самостоятельный срез и его red-модель остаются; часть о другой frozen-двери явно отделена до отдельного разрешённого предмета.

Новых блокирующих находок в изменённых областях и зависимой регрессии нет. Совет отсутствует.

## Выполненные прогоны

```text
$ bash scripts/pre_critic.sh contracts/182-plan-posle-perezapuska.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=2
КРИТИК: дверь зелёная
[rc=0]

$ bash scripts/check_threat_model.sh . contracts/182-plan-posle-perezapuska.md
модель угроз: секция валидна (ЗАЩИЩАЕТ 2 буллет(ов), НЕ ЗАЩИЩАЕТ 2 буллет(ов))
[rc=0]

$ bash scripts/check_precision_gate.sh . contracts/182-plan-posle-perezapuska.md
OK
[rc=0]

$ bash scripts/check_provodka.sh . contracts/182-plan-posle-perezapuska.md
проводка: guard-файл не существует: scripts/orch_plan_slice.sh
[rc=1 — ожидаемое красное состояние до реализации]

$ bash fixtures/workshop_project/plan_restart_182/red_plan_restart_182.sh --model
GREEN published
GREEN frozen
GREEN pause
GREEN done
GREEN roadmap
GREEN no-stale
GREEN local-isolation
GREEN structural
GREEN source-mismatch
CELLS=9 GREEN=9
[rc=0]

$ bash fixtures/workshop_project/plan_restart_182/red_plan_restart_182.sh --stabs
GREEN published
GREEN frozen
GREEN pause
GREEN done
GREEN roadmap
GREEN no-stale
GREEN local-isolation
GREEN structural
GREEN source-mismatch
STAB handoff caught: no-stale
STAB stale caught: no-stale
STAB local caught: local-isolation
STAB no-roadmap caught: roadmap
STABS=4 CAUGHT=4
[rc=0]

$ bash fixtures/workshop_project/plan_restart_182/red_plan_restart_182.sh --repo .
RED published: rc=127 bash: /tmp/dev-harness-verify/Crit182v2/repo/scripts/orch_plan_slice.sh: No such file or directory
RED frozen: rc=127 bash: /tmp/dev-harness-verify/Crit182v2/repo/scripts/orch_plan_slice.sh: No such file or directory
RED pause: rc=127 bash: /tmp/dev-harness-verify/Crit182v2/repo/scripts/orch_plan_slice.sh: No such file or directory
RED done: rc=127 bash: /tmp/dev-harness-verify/Crit182v2/repo/scripts/orch_plan_slice.sh: No such file or directory
RED roadmap: rc=127 bash: /tmp/dev-harness-verify/Crit182v2/repo/scripts/orch_plan_slice.sh: No such file or directory
RED no-stale: rc=127 bash: /tmp/dev-harness-verify/Crit182v2/repo/scripts/orch_plan_slice.sh: No such file or directory
RED local-isolation: rc=127 bash: /tmp/dev-harness-verify/Crit182v2/repo/scripts/orch_plan_slice.sh: No such file or directory
RED structural: rc=127 bash: /tmp/dev-harness-verify/Crit182v2/repo/scripts/orch_plan_slice.sh: No such file or directory
RED source-mismatch: rc=127 stdout='' bash: /tmp/dev-harness-verify/Crit182v2/repo/scripts/orch_plan_slice.sh: No such file or d
CELLS=9 GREEN=0
[rc=1 — ожидаемое красное состояние до реализации]

$ bash fixtures/context_pack_095/red_orch_brief_karta_legacy.sh
[нет stdout/stderr]
[rc=0]

$ git diff --exit-code frozen/contracts/095/1 -- contracts/095-profil-i-vhod-agenta-contextpack.md
[нет stdout/stderr]
[rc=0]

$ git diff --exit-code c21bffff1be835a3d5ed004711aada17875b9d4c^ c21bffff1be835a3d5ed004711aada17875b9d4c -- scripts/make_task.sh fixtures/context_pack_095/red_orch_brief_karta_legacy.sh contracts/095-profil-i-vhod-agenta-contextpack.md
[нет stdout/stderr]
[rc=0]

$ git diff --name-only c21bffff1be835a3d5ed004711aada17875b9d4c^ c21bffff1be835a3d5ed004711aada17875b9d4c
contracts/182-plan-posle-perezapuska.md
fixtures/workshop_project/plan_restart_182/probe.py
[rc=0]
```
