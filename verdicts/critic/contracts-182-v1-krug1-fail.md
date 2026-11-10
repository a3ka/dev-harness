FAIL
OBJECT=a5afc496e3e918d131a8b97702d45d981e6c68e7
СУД: repo=dev-harness; предмет=182; фаза=контракт; роль=critic; вызов=1/2; модель-план=zai/glm-5.3; сессия=Crit182v1; модель-факт=openai-codex/gpt-5.6-terra; SHA=a5afc496e3e918d131a8b97702d45d981e6c68e7; предыдущий=нет; исключение=нет

# Вердикт критика — контракт 182 «актуальный срез „где мы по плану“ после перезапуска», полный вызов 1

OBJECT подтверждён в одноразовом SSH-клоне: `git rev-parse HEAD` дал `a5afc496e3e918d131a8b97702d45d981e6c68e7`; рабочее дерево до вердикта было чистым. Предыдущего verdict 182 нет. Автор OBJECT — `architect <architect@dev-harness.local>`; судья — отдельная сессия `Crit182v1`, собственную работу не судит. План модели — `zai/glm-5.3`; фактическая модель сессии — `openai-codex/gpt-5.6-terra`, объявленный `autoFallback` тира `apex-sol` в `.omp/config.yml`.

Набор артефактов формально полон: есть закоммиченные предмет, rc-критерии, класс риска и ЗОНА-строки. `pre_critic` и форма модели угроз зелёные. Отсутствующий до реализации `scripts/orch_plan_slice.sh` объясняет ожидаемо красные `check_provodka` и `--repo .`; это само по себе не находка о тексте контракта.

## Блокирующая находка

БЛОКИРУЕТ contracts/182-plan-posle-perezapuska.md:11, :28, :58 — контракт одновременно признаёт, что frozen 095 И-12 требует fatal-отказ активному контракту без `## Предмет`, и предписывает заменить это поведение и его клетку на `WORK: <id> :: БЕЗ_ПРЕДМЕТА …`, но не задаёт законную миграцию замороженного обязательства. Формула «разрешение на новую семантику — предмет 182» не является ни 095 v+1, ни санкцией владельца.
ОБЯЗАТЕЛЬСТВО: `AGENTS.md:151-156,247-250` запрещает ослаблять замороженный критерий; изменение frozen-текста возможно только v+1 с новым судом и строкой `РАЗРЕШИЛ-ВЛАДЕЛЕЦ:` в изменяющем коммите. Новый предмет не вправе молча отменить действующее обязательство другого frozen-контракта.
СОСТОЯНИЕ: `contracts/095-profil-i-vhod-agenta-contextpack.md` побайтно равен `frozen/contracts/095/1` (`ccf4b28a917516745bef0ab7bab5e6405a8d19d0`); существует только тег `frozen/contracts/095/1`, v+1 нет. Его действующая клетка `fixtures/context_pack_095/red_orch_brief_karta_legacy.sh:65-70` требует для активного 888 без §Предмет rc 1, дословный `ОТКАЗ: брифинг: контракт без предмета: …` и пустой stdout. В 182 нет ни `РАЗРЕШИЛ-ВЛАДЕЛЕЦ:`, ни v+1/проверяемого prerequisite 095.
НАБЛЮДЕНИЕ: эта клетка на предъявленном дереве вернула rc 0 именно потому, что сохраняет прежнее требование; реализация 182 по её строкам :28 и :58 должна сделать ту же клетку зелёной на противоположном поведении. Значит после реализации одно из двух обязательств будет молча ослаблено или нарушено.
ЗАКРЫВАЮЩЕЕ СВОЙСТВО: до изменения active-fatal поведения контракт либо сохраняет frozen 095/1, либо называет проверяемую зависимость от отдельно разрешённой владельцем и замороженной 095 v+1, которая явно мигрирует это ожидание. Сам 182 не засчитывается такой санкцией.

## Выполненные прогоны

```text
$ bash scripts/pre_critic.sh contracts/182-plan-posle-perezapuska.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=2
КРИТИК: дверь зелёная
[rc=0]

$ bash scripts/check_threat_model.sh . contracts/182-plan-posle-perezapuska.md
модель угроз: секция валидна (ЗАЩИЩАЕТ 2 буллет(ов), НЕ ЗАЩИЩАЕТ 2 буллет(ов))
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
GREEN brief-marker
GREEN brief-snapshot
GREEN brief-no-source
CELLS=12 GREEN=12
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
GREEN brief-marker
GREEN brief-snapshot
GREEN brief-no-source
STAB handoff caught: no-stale
STAB stale caught: no-stale
STAB local caught: local-isolation
STAB no-roadmap caught: roadmap
STAB brief-die caught: brief-marker
STABS=5 CAUGHT=5
[rc=0]

$ bash fixtures/workshop_project/plan_restart_182/red_plan_restart_182.sh --repo .
RED published: rc=127 bash: /tmp/dev-harness-verify/Crit182v1/repo/scripts/orch_plan_slice.sh: No such file or directory
RED frozen: rc=127 bash: /tmp/dev-harness-verify/Crit182v1/repo/scripts/orch_plan_slice.sh: No such file or directory
RED pause: rc=127 bash: /tmp/dev-harness-verify/Crit182v1/repo/scripts/orch_plan_slice.sh: No such file or directory
RED done: rc=127 bash: /tmp/dev-harness-verify/Crit182v1/repo/scripts/orch_plan_slice.sh: No such file or directory
RED roadmap: rc=127 bash: /tmp/dev-harness-verify/Crit182v1/repo/scripts/orch_plan_slice.sh: No such file or directory
RED no-stale: rc=127 bash: /tmp/dev-harness-verify/Crit182v1/repo/scripts/orch_plan_slice.sh: No such file or directory
RED local-isolation: rc=127 bash: /tmp/dev-harness-verify/Crit182v1/repo/scripts/orch_plan_slice.sh: No such file or directory
RED structural: rc=127 bash: /tmp/dev-harness-verify/Crit182v1/repo/scripts/orch_plan_slice.sh: No such file or directory
RED source-mismatch: rc=127 stdout='' bash: /tmp/dev-harness-verify/Crit182v1/repo/scripts/orch_plan_slice.sh: No such file or d
RED brief-marker: rc=1 ОТКАЗ: брифинг: контракт без предмета: /tmp/dev-harness-verify/context-pack-095-restart182-1199414-20995/repo/contracts/154-brief.md
RED brief-snapshot: rc=1 ОТКАЗ: брифинг: контракт без предмета: /tmp/dev-harness-verify/context-pack-095-restart182-1199414-20995/repo/contracts/154-brief.md
RED brief-no-source: rc=1 stdout='' ОТКАЗ: брифинг: контракт без предмета: /tmp/dev-harness-verify/context-pack-095-restart182
CELLS=12 GREEN=0
[rc=1 — ожидаемое красное состояние до реализации]

$ bash fixtures/context_pack_095/red_orch_brief_karta_legacy.sh
[нет stdout/stderr]
[rc=0]

$ git diff --exit-code frozen/contracts/095/1 -- contracts/095-profil-i-vhod-agenta-contextpack.md
[нет stdout/stderr]
[rc=0]

$ git tag --list 'frozen/contracts/095/*'
frozen/contracts/095/1

$ git tag --list 'done/contracts/095/*'
[нет stdout/stderr]
```

Пять заданных обманных направлений были исполнены в `--stabs`: срез из HANDOFF, устаревшее «ЖДЁТ», чтение локального дерева вместо published `origin/main`, сохранённый `brief-die` и срез без этапа ROADMAP; все пойманы. Это не закрывает отдельное противоречие с frozen 095.
