FAIL

СУД: контракт 143 v2, вызов 1/1 (+ не более одного scoped по этому FAIL); OBJECT `34648f768c663007887953a0d7935a85ac44548d`, родитель `18d8e7449`, модель-факт `openai-codex/gpt-6-sol`, автор OBJECT `architect`. Изолированный клон `/tmp/dev-harness-verify/Crit143v2`, ветка `wip/143/critic-v2`; продукт и frozen не менял.

БЛОКИРУЕТ contracts/143-mob-ci-razdelenie.md:70 — зарегистрированный `child_flows` не участвует во владении путями ВЫБОРОЧНОГО режима. Локальная правка child-flow законного экрана 148 запрещает PR вместо выбора работника, хотя режим инвентаризации признаёт этот же flow зарегистрированным. Приёмка `W --repo` на карте с child-flow даёт 78/78 зелёных без проверки выборочного PR по такому пути. Этот же класс охватывает изменение политики child-flows, не попадающее в подпись карты селектора. Опоры: И-1 `:54`, И-2 `:55`, И-13 `:66`, расширение 148 `:73`, приёмка `:115-138`, зелёное A2 `:268`.
ОБХОД: модель v2 + шестой `e2e-vkladki` с `flows=[mobile/.maestro/prokhod-vkladki.yaml]` и `child_flows=[mobile/.maestro/vkladki-tabshell-393.yaml]`, output и needs обоих агрегатов дают `W --repo` rc 0 78/78. На легитимной PR-правке только зарегистрированного child-flow селектор выдаёт rc 1 `VYBOR_OTKAZ: INVENTAR_KARTY: mobile/.maestro/vkladki-tabshell-393.yaml`; на таком же изменении корневого флоу rc 0 и `e2e-vkladki=true`. Проверяемое свойство закрытия: зарегистрированный child-flow участвует во владении/выборе как принадлежащий экрану, включая изменения его записи base/head, с красно-зелёной клеткой на настоящем diff. Не требуется менять архитектуру явных jobs.

### Живые атаки — команды и сырой вывод

Команда `bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --model` выполнена трижды; каждый раз rc 0 и stdout:
```
клеток 78, зелёных 78, красных 0
```
Команда `bash fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --stabs` → rc 0:
```
клеток 78, зелёных 78, красных 0
стабов 60, привязок 76, непойманных 0
```
Команда `python3 /tmp/dev-harness-verify/Crit143v2-attack.py` (одноразовые директории в `/tmp/critic143-attacks-*`). Дословный вывод обёртки и батареи:
```
===== A1 original legacy implementation COMMAND=bash /tmp/dev-harness-verify/Crit143v2/fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo /tmp/critic143-attacks-8ecg9vjx/before RC=1 =====
клеток 78, зелёных 76, красных 2
КЛЕТКА i01-inventar-dereva: честное дерево: rc=1 VYBOR_OTKAZ: REZHIM: mode=inventar; пачка без регистрации: rc=1 VYBOR_OTKAZ: REZHIM: mode=inventar; запись без пачки: rc=1 VYBOR_OTKAZ: REZHIM: mode=inventar; symlink-пачка: rc=1 VYBOR_OTKAZ: REZHIM: mode=inventar; флоу без владельца: rc=1 VYBOR_OTKAZ: REZHIM: mode=inventar; флоу записи отсутствует: rc=1 VYBOR_OTKAZ: REZHIM: mode=inventar КРАСНА
КЛЕТКА i05-vynos-iz-inventarja: НЕТ_ИНВЕНТАРИЗАЦИИ: в quality нет шага с вызовом селектора --mode inventar КРАСНА
===== A2 six-worker extension COMMAND=bash /tmp/dev-harness-verify/Crit143v2/fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo /tmp/critic143-attacks-8ecg9vjx/after RC=0 =====
клеток 78, зелёных 78, красных 0
===== MUT-a coordinated legacy removal COMMAND=bash /tmp/dev-harness-verify/Crit143v2/fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo /tmp/critic143-attacks-8ecg9vjx/remove-map-and-dag RC=1 =====
клеток 78, зелёных 74, красных 4
КЛЕТКА y13-odin-uroven-vosstanovlenija: e2e-splash: маркеров ПОВТОР 0, канон 1 КРАСНА
КЛЕТКА y15-h-checkouty: e2e-splash без checkout .harness123 КРАСНА
КЛЕТКА y23-ispolnenie-povtora: e2e-splash: нет шага с веткой повтора (ПОВТОР: в run) КРАСНА
КЛЕТКА i07-legacy-opora: LEGACY_UDALJON_IZ_KARTY: ['e2e-splash'] КРАСНА
===== MUT-c DAG worker not in map COMMAND=bash /tmp/dev-harness-verify/Crit143v2/fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo /tmp/critic143-attacks-8ecg9vjx/extra-job RC=1 =====
клеток 78, зелёных 75, красных 3
КЛЕТКА y01-nabor-jobs: jobs ['android-e2e', 'build-apk', 'e2e-erstinformation', 'e2e-extra', 'e2e-first-run', 'e2e-pilot', 'e2e-splash', 'e2e-start', 'mobile-regression-signal', 'quality', 'select-screens'] ≠ служебные ['android-e2e', 'build-apk', 'mobile-regression-signal', 'quality', 'select-screens'] ∪ работники карты КРАСНА
КЛЕТКА i02-jobs-iz-karty: job без карты: ['e2e-extra']; карта без job: [] КРАСНА
КЛЕТКА i06-lekalo-rabotnika: инстанциация: sud_joby_iz_karty: job без карты: ['e2e-extra']; карта без job: [] КРАСНА
===== MUT-d manual pack move bypassing inventory COMMAND=bash /tmp/dev-harness-verify/Crit143v2/fixtures/workshop_project/mob_ci_143/red_mob_ci_143.sh --repo /tmp/critic143-attacks-8ecg9vjx/manual-move RC=1 =====
клеток 78, зелёных 77, красных 1
КЛЕТКА i05-vynos-iz-inventarja: ВЫНОС_ВРУЧНУЮ: персональный mv пачки экрана (v1-форма) КРАСНА
===== MUT-b changed template outside pin COMMAND=bash /tmp/critic143-attacks-8ecg9vjx/tampered-fixture/red_mob_ci_143.sh --model RC=2 =====
ORACLE_TAMPERED: пин: sha256 model/screen-job.template.yml
```
Команда `python3 /tmp/dev-harness-verify/Crit143v2-child-flow.py` создаёт временный Git-репозиторий, commits base/head и исполняет selector двумя diff на идентичной карте (сначала child, затем root flow). Дословный вывод:
```
CASE
vkladki-tabshell-393.yaml
COMMAND
node mobile/scripts/select-ci-screens.cjs --mode pull_request --repo /tmp/critic143-child-2wiirbwk --base-sha 5370b516d35a3392c5ae492231e743d728b2e9c4 --head-sha a4034c6121f82ee48c7b8fc2452dfb021031b733 --out /tmp/critic143-child-2wiirbwk/selection.json
RC
1
STDOUT

STDERR
VYBOR_OTKAZ: INVENTAR_KARTY: mobile/.maestro/vkladki-tabshell-393.yaml

SELECTION
ABSENT
CASE
prokhod-vkladki.yaml
COMMAND
node mobile/scripts/select-ci-screens.cjs --mode pull_request --repo /tmp/critic143-child-2wiirbwk --base-sha 5370b516d35a3392c5ae492231e743d728b2e9c4 --head-sha 8b33f849d461ef9dbb4513aecf3b41e9d48532c2 --out /tmp/critic143-child-2wiirbwk/selection.json
RC
0
STDOUT
VYHOD e2e-splash=false
VYHOD e2e-first-run=false
VYHOD e2e-erstinformation=false
VYHOD e2e-start=false
VYHOD e2e-vkladki=true
VYHOD e2e-pilot=false
VYBOROK 1 из 6

STDERR

SELECTION
{
  "mode": "pull_request",
  "base": "5370b516d35a3392c5ae492231e743d728b2e9c4",
  "head": "8b33f849d461ef9dbb4513aecf3b41e9d48532c2",
  "karta_sha256": {
    "base": "db11ab07a36a41e40d4b2779992fb53848880e35bd8ad689aec876224ccb93f7",
    "head": "db11ab07a36a41e40d4b2779992fb53848880e35bd8ad689aec876224ccb93f7"
  },
  "diff_istochnik": "git",
  "izmenenija": [
    {
      "status": "M",
      "old": "mobile/.maestro/prokhod-vkladki.yaml",
      "nov": "mobile/.maestro/prokhod-vkladki.yaml"
    }
  ],
  "policy_change": false,
  "full_set": false,
  "prichiny": [],
  "selected": [
    {
      "id": "vkladki",
      "job": "e2e-vkladki",
      "reason": "AFFECTED"
    }
  ],
  "excluded": [
    {
      "id": "splash",
      "job": "e2e-splash",
      "reason": "NOT_SELECTED"
    },
    {
      "id": "first-run",
      "job": "e2e-first-run",
      "reason": "NOT_SELECTED"
    },
    {
      "id": "erstinformation",
      "job": "e2e-erstinformation",
      "reason": "NOT_SELECTED"
    },
    {
      "id": "start",
      "job": "e2e-start",
      "reason": "NOT_SELECTED"
    },
    {
      "id": "pilot",
      "job": "e2e-pilot",
      "reason": "NOT_SELECTED"
    }
  ],
  "notes": []
}
```

### Сверка рамок и гейты

- Перепись `source.json` отдельным `python3 -c`: 78 клеток (S25/A17/Y24/F4/I7/P1), 60 стабов/76 привязок, 22 пина (5 моделей); дерево — 60 `stab_*.py`, 9 drafts, 8 носителей рекурсивно. `MUT-b` доказал пин лекала (rc 2).
- Astra §2: И-12 инвентарь jobs/outputs/needs, И-13 инвентаризация до выноса, И-14 pinned template, И-15 legacy-опора есть; отступление §2.1 — зарегистрированные child flows не доступны в selective PR (блок выше). §2.2 запрещает wildcard/персональные mv; §2.3 сохраняет явные jobs, H-пин/AVD/recovery; §2.4 разделяет пин эталона и расширяемый продукт. §3 — названные зоны architect/implementer/orchestrator и адресные ПЕРЕСЕЧЕНИЯ, включая STRUCTURE.md. §4 п.6–10 — freeze перед реализацией, собранная приёмка, adversary до reviewer, экранная диагностика до freeze. Семь классов остатка §7 перечислены в НЕ ЗАЩИЩАЕТ (:231–241): нестабильность эмулятора; неполные пути зависимостей; граница доверия карты; Arb143r/Rev143b; freshness/required; хвосты 143/146; незаконченная приёмка реального worker. Отвергнутые frontier'ы byte-pin продукта навечно, «модель ⊆ продукт», matrix не реинтродуцированы (:45–47).
- Живые scoped-гейты: `bash scripts/pre_critic.sh --repo /tmp/dev-harness-verify/Crit143v2 contracts/143-mob-ci-razdelenie.md` rc 0; `bash scripts/check_precision_gate.sh /tmp/dev-harness-verify/Crit143v2 contracts/143-mob-ci-razdelenie.md` rc 0, итог `OK` (stderr содержал предупреждения lib_zones.sh о временных файлах); `bash scripts/check_spec_ready.sh /tmp/dev-harness-verify/Crit143v2 contracts/143-mob-ci-razdelenie.md` rc 0 `OK`; `bash scripts/check_ceilings.sh /tmp/dev-harness-verify/Crit143v2 contracts/143-mob-ci-razdelenie.md` rc 0 `потолки в порядке`; `bash scripts/check_threat_model.sh /tmp/dev-harness-verify/Crit143v2 contracts/143-mob-ci-razdelenie.md` rc 0 `модель угроз: секция валидна (ЗАЩИЩАЕТ 10 буллет(ов), НЕ ЗАЩИЩАЕТ 10 буллет(ов))`; `bash scripts/check_provodka.sh /tmp/dev-harness-verify/Crit143v2 contracts/143-mob-ci-razdelenie.md` rc 0. Настоящий product CI не запускался: отдельная стадия §Порядок п.7–9.
