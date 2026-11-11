accept
OBJECT=1c75a7ec228a7bd3a30cf0041e3e99926fde3268
КЛАСС=задача: контракт v+1 замороженного + красные тесты (смешанный); риск: обычный (подтверждён: адрес репо-профиля и судьба потребителей; права, авторизация, деньги, ПД не затронуты — строка :5 контракта соответствует дельте); порог: прежний (054 заведён 2026-09-28, до 5ca237e4), действующих блоков нет
СУД: repo=dev-harness; предмет=054; фаза=контракт (v+1 → v2, пакет 184 А10; Arch184Vplus4, коммит 123682b1392f3290184105b1338fd1484ee189e9); роль=critic; вызов=1/2; модель-план=zai/glm-5.3 (fallback openai-codex/gpt-5.6-terra); сессия=Crit184Vplus8; модель-факт=zai/glm-5.3 (workstation сессии; провайдер поднят консультантом 10:10 UTC, healthz 200 — повторов не было); SHA=1c75a7ec228a7bd3a30cf0041e3e99926fde3268 (tip wip/184/architect); предыдущий=нет (нематериализованный FAIL Crit184Vplus `b710d6ef67af8e353fe41184fb9f89340ed5dc78` — check_sud_model отказал «фолбэк вне списка тира», замок освобождён `obryv_bez_verdikta`; оба его блока проверены на закрытие ниже); исключение=нет

# Вердикт критика — контракт 054 v+1 (v2), пакет 184 (А10), вызов 1/2, повтор после обрыва

## Кандидат, независимость, законность вызова

- Клон `ssh://git@github.com/a3ka/dev-harness.git` в `/tmp/dev-harness-verify/Crit184Vplus8/repo`; `git fetch origin wip/184/architect` → `1c75a7ec228a7bd3a30cf0041e3e99926fde3268` = OBJECT; ветка основана на `16a65dcb5` (main ушёл вперёд — сужено по diff коммита). Дельта предмета — коммит `123682b1392f3290184105b1338fd1484ee189e9`: контракт (+59/−18) и новая architect-зона `fixtures/workshop_project/profil_a10_054/` (probe.py 275 строк, раннер). `frozen/contracts/054/1` ≡ базе `79b615f53` по тексту контракта (проверено в предыдущем вызове).
- Автор дельты — `architect <architect@dev-harness.local>` (Arch184Vplus4). Судья — сессия Crit184Vplus8 (zai/glm-5.3, тир apex-sol по назначению роли), собственной работы не судит.
- `РАЗРЕШИЛ-ВЛАДЕЛЕЦ:` в теле 123682b139 дословно, ровно один раз: «РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/054-profil-dva-sloja-launcher-proekta.md — v+1 только в объёме решения А10 (предмет 184); слово владельца 2026-11-10 ~20:44 UTC «г да» через консультанта». Путь и причина относятся к этому v+1 (cognitive-only, при одном uid подлинность механически не доказуема).
- Имя файла — канон `freeze_contract.sh`: vmax(`frozen/contracts/054/*`)=1 → `verdicts/critic/contracts-054-v2.md`. На main имени нет; перезаписан только черновик нематериализованного вызова в клоне.
- Повтор законен: прежний вызов Crit184Vplus вынес FAIL, но вердикты НЕ материализованы (check_sud_model: модель вне тира), круг по D11 не потрачен, замок освобождён причиной `obryv_bez_verdikta`; правка architect (Arch184Vplus4) содержит раздел «Позиция автора» с СОГЛАСИЕМ по обоим блокам.

## Что изменено против Arch184Vplus3 (70dc3d698 → 123682b139)

Новая architect-зона `profil_a10_054/` (клетки internal-only, root-only, both, neither, root-only-no-layer, both-no-layer, internal-symlink-outside + station-self в bare; CELLSET-пин; 6 стабов, привязанных по Н-39). Контракт: КЛАСС ЗАДАЧИ/КЛАСС РИСКА (:4-5), §Существующее переписан (:8-12), §Потребители корневого профиля (:56-60: профиль станции — `git mv` побайтно, исполнитель implementer пачки 184, зона; семьи фикстур — полный перечень; порядок ленда — два слияния), ЗОНА architect + `.harness/harness.project.json` в ЗОНА implementer (:313), приёмка переписана под новую семью (:361-373), буллет модели угроз (:271-273), P1–P10 (:254), счёт стабов 20 (:453), раздел «Позиция автора». Остальное — как в прошлом вызове; батарея 184 не тронута: `git diff --quiet frozen/contracts/184/1 HEAD -- fixtures/workshop_project/external_connection_184/` → rc 0.

## Закрытие прежних блоков

БЛОК-1 (И-1 root-only fallback не различался критерием) — ЗАКРЫТ. Семья `profil_a10_054/` предъявлена и жива:

```
$ bash fixtures/workshop_project/profil_a10_054/red_profil_a10_054.sh --model   → rc 0
CELL internal-only: ok … CELL internal-symlink-outside: ok
054-a10 (model): examined=7 red=0
$ … --stabs   → rc 0
STAB root-fallback@root-only: caught … STAB no-boundary@internal-symlink-outside: caught
054-a10 stabs: examined=6 caught=6
$ … (bare, OBJECT)   → rc 1, имена дословно как в приёмке
CELL internal-only: RED … CELL root-only: RED (expected rc 1 refusal, got rc 0)
CELL both: RED … CELL neither: RED … CELL root-only-no-layer: RED (… got: profile ОТКАЗ: корень слоя проекта не задан/недоступен…)
CELL both-no-layer: RED … CELL station-self: RED (station tracks ['harness.project.json'] …)
054-a10 (red): examined=8 red=7
```

Мутант критика F прежнего вердикта пойман красной клеткой правки (одноразовые worktree от OBJECT; F = H + корневой fallback, станция перенесена):

```
$ bash <mutF>/…/red_profil_a10_054.sh   → rc 1
CELL root-only: RED (expected rc 1 refusal, got rc 0)
CELL root-only-no-layer: RED (expected phrase '…нет .harness/harness.project.json…', got: …корень слоя проекта не задан/недоступен…)
054-a10 (red): examined=8 red=2
$ bash <mutH>/…/red_profil_a10_054.sh   → rc 0, examined=8 red=0   (честный H + перенесённый профиль станции)
$ python3 worlds054.py <tree>   (миры формы 184)
OBJECT: root-only rc=0 repoId=toy-184;  mutH: root-only rc=1 P1;  mutF: root-only rc=0 repoId=toy-184 (оба → rc 1 P10 у всех трёх, кроме OBJECT)
```

Порядок входов I-1/I-2 проверен клетками root-only-no-layer/both-no-layer (P1/P10 до чтения слоя; на OBJECT красны — текущая реализация читает слой раньше).

БЛОК-2 (неназначенные потребители корневого профиля) — ЗАКРЫТ. §Потребители (:56-60):
- Профиль станции: перенос `git mv` побайтно, исполнитель — implementer пачки 184, зона — `.harness/harness.project.json` (строка ЗОНА :313). Проверено на одноразовом дереве (H + перенос): `rezhim_996/probe.sh --case self-canonical` → rc 0; `proektnaja_raskladka_161` клетка STATION_MANIFEST_MISSING зелена (спавн станции без пакета → `нет манифеста make_task`, worktree не создан), а на дереве БЕЗ переноса — КРАСНА (см. вердикт 161).
- Семьи фикстур: перечень сверен с живым замером `git grep -l -P '(?<!\.harness/)harness\.project\.json' -- fixtures` — 109 файлов, все покрыты перечнем контракта (расхождений нет); для каждой назван исполнитель и зона (union замороженных зон; architect пакета — project_paths_103 и два файла check_judge_gate), «Семья, покрасневшая на cutover вне перечня и вне зоны, — СТОП и доклад».
- Порядок ленда: два слияния названы; между ними main зелёный; шаг 122 CI гоняет `--model`.

## Обязательные мутации (сырой вывод)

«только корневой мир», «оба профиля», «корневой профиль как вход/фолбэк» — выше (bare клетки + worlds054 + mutF). «симлинк наружу»: клетка internal-symlink-outside зелена на OBJECT-реализации (резолвер v1 уже отказывает), красна на стабе no-boundary (`--stabs`: caught). «удаление клетки»:

```
(удалена строка CASES root-only в копии probe.py)
$ bash <del054>/…/red_profil_a10_054.sh --model   → rc 1
CELLSET drift: ran ['internal-only', 'both', …], pinned ['internal-only', 'root-only', …]
```

«станция без манифеста» — клетка station-self красна на OBJECT (профиль ещё в корне) и зелена после переноса (mutH rc 0); полный спавн-замер — в вердикте 161. «обход резолвера» — в вердикте 122.

## Гейты и прогоны (OBJECT, сырой вывод)

```
$ bash scripts/pre_critic.sh contracts/054-…054.md        → «КРИТИК: дверь зелёная» [rc=0]
$ bash scripts/check_precision_gate.sh . contracts/054-…  → OK [rc=0]   (после git fetch --tags: клон был без --tags)
$ bash scripts/check_threat_model.sh . contracts/054-…    → секция валидна (ЗАЩИЩАЕТ 1, НЕ ЗАЩИЩАЕТ 1) [rc=0]
$ bash scripts/check_provodka.sh . contracts/054-…        → [rc=0]
$ bash scripts/check_ceilings.sh .                        → потолки в порядке [rc=0]
$ bash fixtures/workshop_project/external_connection_184/red_external_connection_184.sh --model → rc 0; --stabs → rc 0; bare → rc 1 (RED ровно 9 — clean, internal-reference, ci-reference, readme-reference, configuration-reference, ignore-reference, nested-code-reference, legacy-root-profile, generator-good; совпадает с приёмкой)
$ bash fixtures/_krasnye_054.sh                           → стаб-пак: просмотрено 20, поймано 20; честная часть: проверено предъявлений 37; итог 054: rc=0
```

## Механические сверки (живой прогон)

Прежний список 1–6 закрыт: :7 мира «только корень» нет → теперь несёт семья profil_a10_054; к2б → клетки both/both-no-layer предъявлены; :453 «20 стабов» = живьём 20; :254 P1–P10; статус v+1; перечень красных клеток 184 = 9 живьём. Перечень семей (:58) полон (109/109). Заявленные состояния новой приёмки совпали живьём дословно (см. выше).

## Пересечения пакета

- 184/1: клеток не копирует, батарея не тронута (rc 0 diff), неизменность закреплена командой в §Зоны.
- 122 v+1: Г1 берёт effective projectId у этого резолвера; заголовок — без `.harness/`.
- 996/161 v+1: профиль станции и якоря дверей назначены здесь и проверены их батареями (см. их вердикты).
- Порядок ленда двух слияний непротиворечив: 054/122 замораживаются до реализации, 996/161 — после слияния cutover (контракт 130).

## Советы (едут с accept)

СОВЕТ contracts/054-profil-dva-sloja-launcher-proekta.md:373 — «после cutover → rc 0» для bare 184 включает реализацию самого 184 (сканер ссылок); на честном дереве критика (резолвер H + перенос станции + RES-генератор) red остаётся ровно 5 клеток `*-reference: expected=ssylka` — это ноги предмета 184, не этого v+1. Стоит при реализации 184 сверить этот список как её собственную приёмку.
СОВЕТ contracts/054-…:313 — сужение `fixtures/workshop_project/` из зоны implementer автор оспаривает (union 055/1); позиция записана в §Позиция автора, неизменность батареи 184 закреплена командой. Вопрос снят для этого v+1; при следующей раздаче в этой папке стоит помнить про union-семантику check_zones.

## Итог

`accept`: оба блока нематериализованного FAIL закрыты предъявленными красными проверками (мутанты F/удаление клетки/станция-без-переноса красны, честные состояния зелены), потребители корневого профиля названы с исполнителями, зонами и порядком ленда, перечень семей полон, гейты зелёные, механика прежнего списка исправлена. Советы автор закрывает по усмотрению.
