accept
OBJECT=1c75a7ec228a7bd3a30cf0041e3e99926fde3268
КЛАСС=задача: контракт v+1 замороженного + красные тесты (смешанный); риск: обычный (подтверждён: источник identity генератора CI и байты заголовка; права, авторизация, деньги, ПД не затронуты — строка :4 контракта соответствует дельте); порог: прежний (122 заведён 2026-10-21, до 5ca237e4), действующих блоков нет
СУД: repo=dev-harness; предмет=122; фаза=контракт (v+1 → v5, пакет 184 А10; Arch184Vplus4, коммит e8a091f02dc10376ab7e01c34616023956b97c45); роль=critic; вызов=1/2; модель-план=zai/glm-5.3 (fallback openai-codex/gpt-5.6-terra); сессия=Crit184Vplus8; модель-факт=zai/glm-5.3 (workstation сессии; провайдер поднят консультантом 10:10 UTC, healthz 200 — повторов не было); SHA=1c75a7ec228a7bd3a30cf0041e3e99926fde3268 (tip wip/184/architect); предыдущий=нет (нематериализованный FAIL Crit184Vplus `1f5845a4a994b13556918d529b4c43ae1c6a90bb` — обрыв без вердикта по модели вне тира; его блок проверен на закрытие ниже); исключение=нет

# Вердикт критика — контракт 122 v+1 (v5), пакет 184 (А10), вызов 1/2, повтор после обрыва

## Кандидат, независимость, законность вызова

- Клон `ssh://git@github.com/a3ka/dev-harness.git` в `/tmp/dev-harness-verify/Crit184Vplus8/repo`; OBJECT = tip `wip/184/architect` (ветка от `16a65dcb5`, main ушёл вперёд — сужено по diff коммита). Дельта предмета — коммит `e8a091f02dc10376ab7e01c34616023956b97c45`: контракт (+46/−27 против v+1 Arch184Vplus3), модель генератора (`ci_proekta_122/model/gen_project_workflow.sh` — projectId у резолвера, заголовок без `.harness/`), новая `model/profile_resolver.sh`, раннер (+клетки g9/g10/g11, PINNED), стабы `stab_gen_raw_profil.sh` и `stab_gen_zagolovok_harness.sh`. `frozen/contracts/122/4` ≡ базе `79b615f53`.
- Автор — `architect <architect@dev-harness.local>` (Arch184Vplus4). Судья — Crit184Vplus8 (zai/glm-5.3, apex-sol), собственной работы не судит.
- `РАЗРЕШИЛ-ВЛАДЕЛЕЦ:` в теле e8a091f02 дословно, ровно один раз: «РАЗРЕШИЛ-ВЛАДЕЛЕЦ: contracts/122-ci-proekta.md — v+1 только в объёме решения А10 (предмет 184); слово владельца 2026-11-10 ~20:44 UTC «г да» через консультанта».
- Имя файла — канон: vmax(`frozen/contracts/122/*`)=4 → `verdicts/critic/contracts-122-v5.md`; на main имени нет.
- Повтор законен (см. вердикт 054); автор СОГЛАСЕН с блоком в §Позиция автора.

## Что изменено против Arch184Vplus3 (76f93b0a → e8a091f02)

Приёмка Г1 дополнена мирами, где резолвер отказывает, а raw-разбор дал бы совпадение: g9-oba-profilja, g10-profil-symlink-naruzhu (`--write` → rc 1 `profil-rashozhdenie`, workflow не записан, в выводе фраза резолвера), g11-bajty-bez-ssylki. Счёты обновлены живыми замерами (52 клетки, PINNED_NAMES=52, 22 стаба); :13/:82 противоречие раздачи снято (architect правит toy-миры/модели/стабы до заморозки; implementer — только `scripts/gen_project_workflow.sh`); порядок ленда = (1) из 054 v+1. Г2/Г3, алфавит 16 причин, ПРЕДПОСЫЛКИ, ПРОВОДКА, предполёт не тронуты; буллет g5 модели угроз дополнен (второй парсер). Модель генератора в `--model` берёт projectId у модели резолвера — отдельного парсера больше нет.

## Закрытие прежнего блока

БЛОК (Г1: критерий не отличал генератор с raw-разбором от вызова резолвера) — ЗАКРЫТ.

Живой прогон батареи на OBJECT:

```
$ bash fixtures/workshop_project/ci_proekta_122/red_ci_proekta_122.sh --model
ИТОГ 122 (model): клеток 52, зелёных 52, красных 0   [rc=0]
$ … (bare)
ИТОГ 122 (red): клеток 52, зелёных 34, красных 18    [rc=1]
$ CI_PROEKTA_122_GEN=…/stabs/stab_gen_raw_profil.sh … --model
CASE g9-oba-profilja: rc=3 want=1 причина=profil-rashozhdenie КРАСНАЯ (rc 3 вместо 1; нет причины)
CASE g10-profil-symlink-naruzhu: rc=3 want=1 … КРАСНАЯ
ИТОГ 122 (model): клеток 52, зелёных 50, красных 2   [rc=1]
$ CI_PROEKTA_122_GEN=…/stabs/stab_gen_zagolovok_harness.sh … --model
CASE g11-bajty-bez-ssylki: rc=5 want=0 … КРАСНАЯ
ИТОГ 122 (model): клеток 52, зелёных 51, красных 1   [rc=1]
$ … --model --cell g9|g10|g11   → зелёных 1, красных 0 каждая [rc=0]
```

Мутант критика RAW прежнего вердикта (генератор без вызова резолвера, raw-разбор профиля и слоя — операция модели 122 после 76f93b0a) пойман клетками правки на честном дереве (резолвер H по 054 v+1 + перенос станции + сам генератор в `scripts/`):

```
$ python3 mut122.py <tree> RAW|RES   (патч scripts/gen_project_workflow.sh)
$ bash <mutW-raw>/…/red_ci_proekta_122.sh        → rc 1: g9, g10 КРАСНАЯ (rc 3 — workflow записан); 50/2
$ bash <mutW-res>/…/red_ci_proekta_122.sh        → rc 0: ИТОГ 122 (red): клеток 52, зелёных 52, красных 0
$ python3 gen122.py <tree>   (миры формы 184, --write)
RES: clean rc=0 written; both rc=1 profil-rashozhdenie (фраза резолвера, не записан);
     symlink-outside rc=1 profil-rashozhdenie (не записан)
RAW: both rc=0 WRITTEN; symlink-outside rc=0 WRITTEN   — но эти миры краснят g9/g10 батареи
$ python3 gen122root.py <tree>   (мир «только корень»)
RES: rc=1 profil-otsutstvuet (фраза резолвера); RAW: rc=1 profil-otsutstvuet
```

Мутант «оставь `.harness/ci.json` в шапке» (RES + прежний HEADER) → `CASE g11-bajty-bez-ssylki: КРАСНАЯ (rc 5)`, rc 1 — прежде его видела только батарея 184, теперь и 122. «Удаление клетки»:

```
(удалена g5 из CELLS раннера в копии дерева)
$ bash <del122>/…/red_ci_proekta_122.sh --model
ИТОГ 122 (model): клеток 51, зелёных 51, красных 0
ci122 ОТКАЗ: набор клеток расходится с закреплённым (51 из 52)   [rc=1]
```

## Обязательные мутации

«обход резолвера» — RAW выше; «оба профиля» — g9 + gen122 both; «симлинк наружу» — g10 + gen122 symlink-outside; «только корневой мир» — gen122root (RES отказывает фразой резолвера); «удаление клетки» — PINNED выше; «корневой профиль как вход/фолбэк» и «станция без манифеста» — вердикты 054/161 (резолвер и двери ниже по стеку).

## Гейты и прогоны (OBJECT, сырой вывод)

```
$ bash scripts/pre_critic.sh contracts/122-ci-proekta.md        → «КРИТИК: дверь зелёная» [rc=0]
$ bash scripts/check_precision_gate.sh . contracts/122-ci-proekta.md → OK [rc=0]
$ bash scripts/check_threat_model.sh . contracts/122-ci-proekta.md   → валидна (ЗАЩИЩАЕТ 7, НЕ ЗАЩИЩАЕТ 6) [rc=0]
$ bash scripts/check_provodka.sh . contracts/122-ci-proekta.md       → [rc=0] (122 done/1, проводка подключена)
$ bash scripts/check_ceilings.sh .                                  → потолки в порядке [rc=0]
$ CI_PROEKTA_122_{GEN,PREFLIGHT,GATES}=stabs/stab_rc0_chestnyj_tekst.sh … --model → зелёных 18, красных 34
$ … stab_rc1_chestnyj_tekst.sh … → зелёных 34, красных 18
$ stab_gen_check_tekstom.sh → 50/2 (g8 две) [rc=1]
```

## Механические сверки (живой прогон против приёмки v+1)

52 клетки ✓; 22 стаба ✓ (`ls stabs/ | wc -l` = 22); bare 34/18 ✓; `--model` 52/52 ✓; подмена rc 18/34 и 34/18 ✓; стаб-замеры :4 совпали (raw 50/2, zagolovok 51/1, check_tekstom 50/2); `--cell g9/g10/g11` → зелёных 1 ✓; PINNED_N=52 ✓; провода rc 0 ✓. Прежний список 1–9 закрыт живыми замерами; исторические числа объявлены историей.

## Пересечения пакета

- 184/1: cells generator-good/wrong-id цитируются, не копируются; на честном дереве (RES) обе зелены, bare 184 red = только 5 reference-клеток (ноги 184).
- 054 v+1: порядок ленда общий (054/122 заморозка до реализации; шаг CI 122 гоняет `--model` rc 0 — проверено).
- 996/161 v+1: пересечений по путям нет.

## Советы (едут с accept)

СОВЕТ contracts/122-ci-proekta.md:1 — «после реализации → rc 0 52/52» доказано на дереве критика (RES + резолвер H); при cutover реализатора стоит сверить именно полный bare (не только `--model`), как сделано здесь.
СОВЕТ — стабы `stab_predposylki_*`/`stab_preflight_*` прежних кругов не перепрогонялись в этом вызове (не связаны дельтой); их счёт в :4 совпадает с живым `--model`-прогоном семейства, отдельные замеры 22×rc1 не снимались.

## Итог

`accept`: блок нематериализованного FAIL закрыт — генератор, обходящий резолвер, краснеет на g9/g10 (миры «оба профиля» и «symlink наружу», workflow записывается — наблюдаемый обход), заголовок с `.harness/ci.json` краснеет на g11, удаление клетки ломает PINNED, честный RES даёт 52/52 bare. Гейты зелёные, механика приёмки совпала живьём. Советы автор закрывает по усмотрению.
