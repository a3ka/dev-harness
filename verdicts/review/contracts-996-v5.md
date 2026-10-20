accept
OBJECT=1ff62e97f868f5a4fa5530090889e67802f12a9e

# Контракт 996 — reviewer (Rev996r5), круг 5, ось Р4-1 + регресс

Находки: `review.md` (status: ready). Блокирующих нет. Р4-1 закрыт. Советы: С5-1 (050, якорь мутанта
привязан к тексту выражения), С4-1 (перенесён), С4-5 (перенесён, условие done, ждёт владельца).

Клон: `git clone ssh://git@github.com/a3ka/dev-harness.git /tmp/dev-harness-verify/Rev996r5/clone`,
`git checkout 1ff62e97f868f5a4fa5530090889e67802f12a9e`, rc=0.

## (1) Проба и матрица (клон @ OBJECT)

```
$ bash fixtures/workshop_project/rezhim_996/probe.sh
996: examined=111 mutants=0 mismatches=0                                    rc=0
$ bash fixtures/workshop_project/rezhim_996/probe.sh --matrix
996: examined=111 mutants=76 mismatches=0                                   rc=0
mutation fallback-canon-null: fallback-canon-unit: rc=1 FALLBACK_CANON_UNIT_DROPPED rc=0 stdout='{…"sourceCanon":null…'
```
Свой подсчёт по логу матрицы (не вывод пробы): строк клеток `^name: rc=` — 111, красных среди них 0;
уникальных мутантов в строках `mutation …` — 76; строк `mutation` — 149, из них не `rc=1` — 0.

Красное своей мерой: клон_red = клон + `git checkout 2437db821 -- scripts/next_id.sh` (код до фикса,
литерал null):
```
$ bash fixtures/workshop_project/rezhim_996/probe.sh      (clone_red)
fallback-canon-unit: rc=1 FALLBACK_CANON_UNIT_DROPPED rc=0 stdout='{"contracts":…
996: examined=111 mutants=0 mismatches=1                                    rc=1
```

## (2) Повтор свидетельства круга 4 — exp/exp.py (вне дерева; probe.world + настоящие скрипты)

Профиль `world`+`canon()`, workflowPaths удалён; варианты: канон в профиле, канон в defaults слоя,
канона нет. OBJECT:
```
== profile   (== layer — побайтно то же)
project_workflow rc=0 sourceCanon={"sources":[{"path":"SOURCE.md","priority":0}],"gate":["/usr/bin/python3","source_gate.py","literal ; $(not-shell)"]}
make_task --print-context {critic,reviewer,adversary,implementer,architect,arbiter,orchestrator} rc=0 sourceCanon={…SOURCE.md…}  (7/7)
workshop --print-context rc=0 sourceCanon={…SOURCE.md…}
workshop --probe (+.env, pin, omp-ловушка) rc=0 PROBE_OK=True omp_trap=False prompt=['WORKFLOW_handoff=<R>/HANDOFF.md', 'sourceCanon:{"sources":[{"path":"SOURCE.md","priority":0}],…}', 'SOURC…']
pre_critic rc=0 'КРИТИК: дверь зелёная'
== nocanon
project_workflow / make_task ×7 / workshop --print-context rc=0 sourceCanon=null
workshop --probe rc=0 PROBE_OK=True prompt=[…, 'sourceCanon:null']
exp.py rc=0
```
Тот же сценарий на clone_red (до фикса): везде `sourceCanon=null`, промпт `'sourceCanon:null'`,
pre_critic rc=0 — дефект круга 4 воспроизведён, на OBJECT он исчез.

## (3) Toy-миры 058/060 (клон @ OBJECT)

```
$ bash fixtures/_krasnye_058.sh  → честная часть: 16/16 зелёная; стабы 9/9 + дифф 9/9 + честные 16/16; итог 058: rc=0   rc=0
$ bash fixtures/_krasnye_060.sh  → диффпробы стабов без ручек: нет; стерегомое дерево харнесса: не тронуто; итог 060: rc=0   rc=0
$ bash scripts/verify_antiplacebo.sh --scope next_id → барьеров: 1 · фикстур: 1 · предъявлено красным повторным прогоном: 1   rc=0
```

## (4) Frozen-барьеры не ослаблены

```
$ git diff --stat frozen/contracts/996/1 HEAD -- contracts/996* frozen fixtures/workshop_project/rezhim_996
  model.py 243 / probe.py 719 / probe.sh 26 — contracts/996-rezhim-proekta-polnyj-cikl.md: изменений НЕТ
$ git show 2437db821 --numstat → model.py 11+/2-, probe.py 93+/0-
```
probe.py в круге 5 — только добавления: клетка `fallback-canon-unit` (`probe.py:441`, `:1212-1265`),
`FALLBACK_ANCHOR`/`FALLBACK_CANON_EXPR`/`fallback_literal_null` (`:218-243`), строка мутанта (`:1504`).
model.py: 2 удалённые строки — `paths = dict(p['workflowPaths'])` уходит в ветвь `if`
(старое поведение сохранено), и `print(json.dumps(paths))` становится `{**paths, 'sourceCanon': …}`.
Ни одна старая клетка не ослаблена; матрица 76/76 красная.
Мутант — настоящий байтовый патч `scripts/next_id.sh` одноразовой установки, без имитатора (Н-358).
Привязка к ветви по коду (Н-39). Норма 996/1: у самого dev-harness sourceCanon не объявлен
(`jq .sourceCanon harness.project.json` → ABSENT; project_workflow → null), поэтому гейт сверки на HEAD
здесь не применяется.

## (5) Зоны

```
$ git show --stat c880fd285 → implementer: scripts/next_id.sh (5+/3-)
$ git show --stat 20df2b86c → implementer: scripts/next_id.sh (2+/4-)
$ git show --stat 2437db821 → architect: fixtures/workshop_project/rezhim_996/{model,probe}.py
$ git diff 2437db821 HEAD -- scripts/next_id.sh → 3+/3-, итог: printf-формат `"sourceCanon":%s`
  + аргумент `$(printf '%s' "$MERGED" | jq -c '.sourceCanon.value // null')` + удалена пустая строка
```
Implementer правил только scripts/next_id.sh. Атомарность: оба коммита implementer ссылаются на Р4-1.

## 050 — по артефактам диффа

- next_id.sh:417 (аргумент printf): (1) §A L65/§D L63 — эффективный юнит во всех ролях;
  (2) нового состояния нет, значение видно в выводе; (3) правка того же свойства — 1 файл, но выражение
  теперь в 2 местах (`:417`, `:473`), раньше было в 1; (4) интерфейс не вырос; (5) потребитель —
  клетка fallback-canon-unit и матрица. Свойство ESSENTIAL. Повтор выражения вызван якорем мутанта —
  совет С5-1.
- Клетка fallback-canon-unit: (1) Р4-1/§A L65; (2) мир во временном каталоге, явный; (3) 1 файл;
  (4) интерфейс пробы не менялся; (5) probe.sh и матрица. ESSENTIAL.
- Мутант fallback-canon-null + FALLBACK_ANCHOR/FALLBACK_CANON_EXPR: (1) красное к клетке; (2) патч
  установки, явный; (3) правка выражения в next_id.sh тянет за собой probe.py — растёт до 2 файлов;
  (4) мелкий: якорь на тексте; (5) матрица. Проверено: форма c880fd285 даёт
  `mutation fallback-canon-null: fallback-canon-unit: rc=0`, `mismatches=1`, rc=1. Прорехи нет,
  но форма ACCIDENTAL — совет С5-1 (более простая форма названа в review.md).
- model.py ветвь layout без workflowPaths: (1) честная модель FALLBACK-NO-WORKFLOW (к7 060);
  (2) нет; (3) 1 файл; (4) —; (5) режим model пробы. ESSENTIAL.

## Сырые команды своей меры

```
$ python3 exp/exp.py clone          rc=0   (вывод выше)
$ python3 exp/exp.py clone_red profile   rc=0   (везде null)
$ git -C clone_red checkout c880fd285 -- scripts/next_id.sh && probe.sh --matrix → mismatches=1 rc=1 (С5-1)
```
Клоны clone/ и clone_red/ удалены после записи вердикта; exp/exp.py оставлен рядом с вердиктом.
