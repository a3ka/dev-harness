accept
OBJECT=1c75a7ec228a7bd3a30cf0041e3e99926fde3268
КЛАСС=задача: контракт v+1 замороженного + красные тесты (смешанный); риск: обычный (подтверждён: мигрируется путь профиля, gate/источник/архив сохраняются — строка :10 контракта соответствует дельте); порог: прежний (996 заведён 2026-10-18, до 5ca237e4), действующих блоков нет
СУД: repo=dev-harness; предмет=996; фаза=контракт (v+1 → v3, пакет 184 А10; Arch184Vplus4, коммит 922b6bc0aec1c8139c2cd246852a4929bdc47ba0); роль=critic; вызов=1/2; модель-план=zai/glm-5.3 (fallback openai-codex/gpt-5.6-terra); сессия=Crit184Vplus8; модель-факт=zai/glm-5.3 (workstation сессии; провайдер поднят консультантом 10:10 UTC, healthz 200 — повторов не было); SHA=1c75a7ec228a7bd3a30cf0041e3e99926fde3268 (tip wip/184/architect); предыдущий=нет (нематериализованный FAIL Crit184Vplus `ac9b59fb83e2d417a0c204c305eec441268fc9b8` — обрыв без вердикта по модели вне тира; оба его блока проверены на закрытие ниже); исключение=нет

# Вердикт критика — контракт 996 v+1 (v3), пакет 184 (А10), вызов 1/2, повтор после обрыва

## Кандидат, независимость, законность вызова

- Клон `ssh://git@github.com/a3ka/dev-harness.git` в `/tmp/dev-harness-verify/Crit184Vplus8/repo`; OBJECT = tip `wip/184/architect` (ветка от `16a65dcb5`, main ушёл вперёд — сужено по diff коммита). Дельта предмета — коммит `922b6bc0aec1c8139c2cd246852a4929bdc47ba0`: контракт (+28 раздела v+1), `rezhim_996/model.py` (a10_refusal — дверь несёт тело фразы резолвера), `rezhim_996/probe.py` (клетки paths-root-only-profile, paths-both-profiles, freeze-root-only-profile; мутанты door-legacy-root, door-ignores-root). `frozen/contracts/996/2` ≡ базе `79b615f53`.
- Автор — `architect <architect@dev-harness.local>` (Arch184Vplus4). Судья — Crit184Vplus8 (zai/glm-5.3, apex-sol), собственной работы не судит.
- `РАЗРЕШИЛ-ВЛАДЕЛЕЦ:` в теле 922b6bc0a дословно, ровно один раз: «РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/996-rezhim-proekta-polnyj-cikl.md — v+1 только в объёме решения А10 (предмет 184); слово владельца 2026-11-10 ~20:44 UTC «г да» через консультанта».
- Имя файла — канон: vmax(`frozen/contracts/996/*`)=2 → `verdicts/critic/contracts-996-v3.md`; на main имени нет.
- Повтор законен (см. вердикт 054); автор СОГЛАСЕН с обоими блоками в §Позиция автора.

## Что изменено против Arch184Vplus3 (e919ce2b1 → 922b6bc0a)

Исключение legacy-self СНЯТО из текста («Правило одно для ЛЮБОГО R, включая установку dev-harness; исключения self/legacy-self нет»); дверь не судит профиль сама — несёт отказ `profile_resolver.sh` (тела P1/P10 из 054 v+1 дословно); профиль станции назначен переносом по 054 v+1 §Потребители; добавлены три клетки А10 (отказ до записи: stdout без раскладки, HEAD/refs/теги не меняются), два мутанта (Н-39), буллет модели угроз, демаркация («отказ собственной формулировкой двери — второй валидатор, неконформен»), порядок ленда одним слиянием и тег после слияния (контракт 130). Остальной текст (интерфейсы, пакеты A–E, гейты, fd/inode, sourceCanon, workflowPaths) не тронут.

## Закрытие прежних блоков

БЛОК-1 (self-canonical зеленеет только при запрещённом корневом fallback) — ЗАКРЫТ. Профиль станции назначен (перенос `git mv` в `.harness/`, исполнитель implementer пачки 184, зона — 054 v+1 §Потребители/ЗОНА). Живой замер на одноразовых деревьях от OBJECT:

```
$ bash <mutH>/…/rezhim_996/probe.sh --case self-canonical   (резолвер H 054 v+1 + перенос станции)
self-canonical: rc=0 / 996: examined=1 mutants=0 mismatches=0   [rc=0]
$ bash <mutF>/…/rezhim_996/probe.sh --case self-canonical   (резолвер F = H + корневой fallback)
self-canonical: rc=0 — но F краснит обе root-only клетки дверей (ниже): fallback больше не проходит батарею целиком
```

БЛОК-2 (отказ `profil` дверей на корневом профиле продукта не проверялся ни одним миром) — ЗАКРЫТ. Клетки предъявлены и живы; мутанты пойманы:

```
$ bash fixtures/workshop_project/rezhim_996/probe.sh --matrix
996: examined=114 mutants=78 mismatches=0   [rc=0]
  … mutation door-legacy-root: paths-root-only-profile: rc=1 A10_ROOT_PROFILE_ACCEPTED:paths-root-only-profile rc=0 stdout='{"contracts": "<tmp>/project/contracts", …}'
  … mutation door-legacy-root: freeze-root-only-profile: rc=1 A10_ROOT_PROFILE_ACCEPTED:freeze-root-only-profile rc=1 … «заморожено: .harness/tasks/777-toy.md → frozen/contracts/777/1»
  … mutation door-ignores-root: paths-both-profiles: rc=1 A10_ROOT_PROFILE_ACCEPTED:paths-both-profiles rc=0 …
$ bash fixtures/workshop_project/rezhim_996/probe.sh
996: examined=114 mutants=0 mismatches=99 / 996: проектный цикл не замкнут   [rc=1]
  (заявленные PROFILE_EXCHANGE_NOT_DELIVERED и три клетки А10 — в выводе есть)
```

Мутант критика F (корневой fallback резолвера) пойман красными клетками дверей на живых дверях:

```
$ bash <mutF>/…/rezhim_996/probe.sh   → rc 1
paths-root-only-profile: rc=1 A10_ROOT_PROFILE_ACCEPTED:paths-root-only-profile rc=0 stdout='{…"contracts": "<tmp>/project/.harness/tasks"…}' (корневая раскладка через fallback)
freeze-root-only-profile: rc=1 A10_ROOT_PROFILE_ACCEPTED:freeze-root-only-profile rc=0 … «заморожено» — freeze прошёл на корневом профиле
996: examined=114 mutants=0 mismatches=74
```

Двери «только адрес» (новый адрес якоря, корень не судится) краснеют на root-only клетках; «строгий» вариант прежнего вердикта (отказ собственной формулировкой `ОТКАЗ: profil: …`) неконформен по новой демаркации — грамматика отказа одна: фраза резолвера. Это уточнение обязательства, не ослабление: дверь без собственного валидатора запрещена явно.

Честное состояние (полный cutover критика: резолвер H + перенос станции + якоря `.harness/` + перенос отказа резолвера в project_paths_resolve/spawn/make): 996 bare строго улучшается — 99 красных OBJECT → 12, ни одна клетка не покраснела против OBJECT (сравнение множеств живьём); остаток 12 — прежние красные main (gitw-канон, reserve-origin, canon-stale-head, zones/staged, precritic-ноги), закрываемые реализацией самого 184; клетки А10 зелены.

## Обязательные мутации

«только корневой мир» — paths-root-only-profile + freeze-root-only-profile (и door-legacy-root красит ровно их); «оба профиля» — paths-both-profiles (+ door-ignores-root); «корневой профиль как вход/фолбэк» — mutF выше; «удаление клетки» — набор EXTRA_CASES закреплён в probe.py литералом списка (удаление строки клетки расходится с перечнем и красит матрицу — тот же механизм, что 054 CELLSET/122 PINNED); «симлинк наружу» — прежние клетки paths-symlink/accept-symlink матрицы зелены в --matrix (114/78/0); «обход резолвера» и «станция без манифеста» — вердикты 122/161.

## Гейты и прогоны (OBJECT, сырой вывод)

```
$ bash scripts/pre_critic.sh contracts/996-…polnyj-cikl.md     → «КРИТИК: дверь зелёная» [rc=0]
$ bash scripts/check_precision_gate.sh . contracts/996-…       → OK [rc=0]
$ bash scripts/check_threat_model.sh . contracts/996-…         → валидна (ЗАЩИЩАЕТ 6, НЕ ЗАЩИЩАЕТ 6) [rc=0]
$ bash scripts/check_provodka.sh . contracts/996-…             → [rc=0]
$ bash scripts/check_ceilings.sh .                             → потолки в порядке [rc=0]
$ bash fixtures/workshop_project/external_connection_184/red_external_connection_184.sh --model → rc 0; --stabs → rc 0
```

## Механические сверки (живой прогон)

:13 приёмка --matrix `examined=114 mutants=78 mismatches=0` ✓; bare `examined=114 mismatches=99` ✓; клетки А10 в bare-выводе есть ✓; шаг CI `check:rezhim-996-family-selftest` в реестре ✓ (проверено в прошлом вызове, реестр не менялся); toy-профили только в `.harness/` ✓ (`git grep -P '(?<!\.harness/)harness\.project\.json' -- fixtures/workshop_project/rezhim_996/` пуст). Прежнее расхождение 1 («rc 0 недостижимо») закрыто самим переносом профиля станции.

## Пересечения пакета

- 184/1: клеток не копирует; зоны implementer 996 и 184 пересекаются на одном имени implementer — ПЕРЕСЕЧЕНИЕ-строк не требуется (один автор имени).
- 054 v+1: профиль станции и правило входа назначены там; здесь — приёмка self-canonical и дверей.
- 161 v+1: те же якоря дверей — см. его вердикт; 122 v+1 — пересечений по путям нет.
- Порядок ленда: одним слиянием с реализацией 184; тег frozen/996/3 — после слияния (контракт 130). До слияния на main действует frozen/996/2 — текст v3 в ветке противоречия не создаёт.

## Советы (едут с accept)

СОВЕТ contracts/996-rezhim-proekta-polnyj-cikl.md:13 — «после cutover → rc 0» на честном дереве критика даёт 12 остаточных красных (все — прежние красные main до реализации 184: gitw-канон, reserve, canon-stale-head, zones/staged, precritic-ноги). Стоит при реализации 184 сверить их обнуление тем же прогоном, что здесь (сравнение множеств клеток).
СОВЕТ — клетки freeze-root-only/done-root-only прежнего цикла (ожидание корневого поведения pre-А10) после cutover будут судить станцию с перенесённым профилем; их полярность при смене адреса станции стоит перепроверить на слиянии (реализатор 184).

## Итог

`accept`: оба блока нематериализованного FAIL закрыты — профиль станции назначен и self-canonical зелена на честном резолвере без всякого fallback; корневой fallback резолвера и двери «только адрес» краснят новые root-only/both клетки с требованием тела фразы резолвера до записи. Матрица 114/78/0 и bare 114/99 совпали с приёмкой дословно; гейты зелёные. Советы автор закрывает по усмотрению.
