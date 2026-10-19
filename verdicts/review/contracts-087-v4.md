accept
OBJECT=449ff8a26ce8d948a8d7435adf21e75c6ff80cc8

# Вердикт ревьюера 087, микро-круг К12 (форк n087-krug3-kap, решение (А)) — accept

Находки — `/tmp/dev-harness-verify/Rev087k12/review.md` (status: ready; блокирующих нет,
советы Р4-1…Р4-4 и статус Р3-1…Р3-5). Судил ТОЛЬКО клетку К12 и шаг реестра
`check:gen-ci-steps-coherence`; остальное в 087 не судилось.

Клон: `git clone ssh://git@github.com/a3ka/dev-harness.git /tmp/dev-harness-verify/Rev087k12/clone`,
`git checkout 449ff8a26ce8d948a8d7435adf21e75c6ff80cc8`. Мутанты — одноразовые клоны
`m-tri`, `m-tri-old`, `m-coherence`, `m-stepif`, `c2` (дерево после strip) там же. Основной
чекаут не тронут.

## 1. Область правки

`git log --format='%h an=%an cn=%cn' 551c3809..debec6d6`:
- `5c8132d4 an=architect cn=architect` — fixtures/ci_b_087/{_orakul.py, model/ci.yml, red_ci_b_087.sh}
  ⊆ «ЗОНА architect: … fixtures/ci_b_087/ …» (frozen-блоб 087/1, строка 226).
- `debec6d6 an=implementer cn=implementer` — registry/ci-steps.tsv, .github/workflows/ci.yml
  ⊆ «ЗОНА implementer: … registry/ci-steps.tsv .github/workflows/ci.yml …» (строка 228);
  ci.yml тронут только в блоке `BEGIN/END GENERATED CI JOBS (083)` (строка l6 keys) —
  «блоки 083 — только перегенерацией gen_ci_steps.sh» (строка 230) соблюдено (см. §8).
- `git show --stat 449ff8a2` — ровно 5 файлов, сверх двух коммитов ничего.
- `git diff --quiet frozen/contracts/087/1^{commit} HEAD -- contracts/087-ci-b-klassy-izmenenij-hesh-koda.md` → rc 0.
- `git diff --quiet 551c3809 HEAD -- contracts/ roles/` → rc 0.
- `git diff --quiet 551c3809 HEAD -- fixtures/ci_gen_083 scripts/ fixtures/_krasnye_083.sh` → rc 0
  (барьеры 083 и скрипты 087 не тронуты).

Превышения зон нет.

## 2. Сырой вывод (мои прогоны на OBJECT)

- `bash fixtures/_krasnye_087.sh` (clone) → rc 0, «ИТОГ 087: клеток ok=110 КРАСНО=0; стаб-пак: поймано 31/31 (subject)», 67.6 с.
- `bash fixtures/ci_b_087/red_ci_b_087.sh --model` → rc 0, «ok=110 КРАСНО=0; … 31/31 (model)».
- То же на дереве после strip (c2: `ci_klass.sh strip d7a75fc3…` → «удалено учётных путей 1240») → rc 0, ok=110, 31/31; К12 и К12C — ok.
- `bash scripts/gen_ci_steps.sh --check` → rc 0 (0.244 с real).
- `bash scripts/gen_ci_steps.sh --write; git status --porcelain; git diff --stat` → rc 0, пусто: ci.yml == генерация.
- `bash scripts/verify_ci_parity.sh` → rc 0, «workflow-команд: 19 · скриптов в приёмке: 73 · … расхождений: 0».
- `bash scripts/run_ci_lane.sh check:gen-ci-steps-coherence` → rc 0, «замер: check:gen-ci-steps-coherence 1»; после strip — rc 0, «замер: … 0».
- `bash fixtures/ci_b_087/zamer_087.sh 39245598859` → rc 0, «окно после 39245598859: прогонов 25, push в main 11, приземлений кода 3, нарушений 0».

## 3. К12 не переписана под код

Implementer (debec6d6) фикстур не касался. Дифф архитектора: новые ветвь `K12` в
`k_check`, функция `K12C`, 2 вызова `cell`, 3 строки `stab`, ветви `K12-*` в `stab_tree`;
единственная правка существующего кода — вынос разбора lane-матрицы К6 в `lane_keys_of`
(тот же код построчно); К6 ok, три стаба К6 (`K-legkij-*`) пойманы на KS K6 (прогон §2).
Модель: добавлена lane l3 с тремя step-ключами К10 — иначе `--model` (А3) красна на К12.

## 4. Красное предъявлено (независимые мутанты, не стабы автора)

Мутатор `/tmp/dev-harness-verify/Rev087k12/mut.py` — удаление токенов из всех `keys:` живого ci.yml
(форма не равна стабу `K12-vyrezany-tri`, который режет целую lane модели; мутант 69b44626
в origin отсутствует: `git cat-file -t 69b44626…` → «could not get object info»).

| мутант | К12 (`_orakul.py kcheck K12`) | gen --check | батарея 087 |
|---|---|---|---|
| m-tri: три ключа К10 вырезаны из l3/l4 | rc 1 «…вне lane-матрицы ci: check:pokrytie-079-family-selftest check:ops-server-family-selftest check:runner-hygiene» | rc 1 «дрейф блока JOBS» | rc 1, «ok=109 КРАСНО=1; 31/31», КРАСНО: К12 |
| m-tri-old: тот же ci.yml + фикстуры 087 из 551c3809 | — | — | rc 0, «ok=108 КРАСНО=0; 28/28» — красное новое |
| m-coherence: вырезан сам `check:gen-ci-steps-coherence` | rc 1 «…: check:gen-ci-steps-coherence» | rc 1 | — |
| m-comment: ключ в YAML-комментарии строки keys | rc 1 «…: check:runner-hygiene» | rc 1 | — |

Эталон зелёный (§2). Пара честности К12C зелёная. Стабы (Н-39, привязка по коду
`stab_tree` → ветвь `K12` в `k_check`): `K12-vyrezan-odin`, `K12-vyrezany-tri`,
`K12-v-legkij-run` пойманы на KS K12, диффпроба K10 зелена.

## 5. Атомарность

Два коммита, по роли, каждый — один предмет со ссылкой «087 К12 … LANE-087».

## 6. Норма не тронута

contracts/, roles/ — 0 путей в диффе (§1).

## 7. Счётные утверждения своей мерой

- ok=110 — мой пересчёт строк `ok` клеток прогона §2 по группам (А0 1, А1 27, А2 1, А8 1,
  А3 10, А9 1, А4 8, А5 3, А6 3, А7 11, Б1 10, Б2 5, К1–К9 13, К-исп 7, К10 2, К11 3, К12 2, В 2) = 110;
  стабов 31 (28 прежних + 3 K12-*).
- Связность своей мерой (python по блоку GENERATED ci.yml HEAD и реестру HEAD):
  «matrix-keys 56 uniq 56 reg-step 56 missing [] extra []».
- «Вес ≤ 5 с по замеру time (0.28 с)» (комментарий реестра): мой замер 0.244 с, lane-замер 1 с / 0 с — вес 5 — верхняя граница, не замер (Р4-3).

## 8. Шаг реестра `check:gen-ci-steps-coherence`

- Строка `step\tcheck:gen-ci-steps-coherence\t5\tbash scripts/gen_ci_steps.sh --check` (registry/ci-steps.tsv:114).
- В ci.yml: lane l6 (`.github/workflows/ci.yml:282`); `--write` даёт тот же файл (§2).
- Парити: `verify_ci_parity.sh:262-281` разбирает step-строки реестра, команда `bash …` →
  `REGISTRY_STEP_BASH[gen_ci_steps]`; «скриптов в приёмке: 73» (у адверсария на дереве до
  К12 — 72). `scripts/gitw_preflight_071.sh` на gen_ci_steps не ссылается (grep — 0 совпадений) — и не обязан.
- Читаемые пути (реестр, ci.yml) — кодовые (И-1 запрещает uchet над ними), шаг зелёный после strip.

## 9. Бюджет legkij ≤ 120 с

Реестр 551c3809 и HEAD: legkij-строк 6, сумма весов 60 (awk по `$1=="legkij"`); `+legkij`
строк в диффе 0; run-строка legkij `.github/workflows/ci.yml:129` не тронута (дифф ci.yml —
одна строка l6). К11 (3 клетки) ok. Новый шаг — step тяжёлой lane, legkij не касается.

## 10. Паразитная сложность (050) — (1) свойство; (2) состояние; (3) файлов на правку; (4) глубина; (5) потребитель

- `lane_keys_of` — (1) единый разбор lane-матрицы для К6 и К12; (2) нет; (3) 1, число не выросло (дубль снят); (4) 1 аргумент, чистая; (5) К6, К12. ESSENTIAL.
- ветвь `K12` в `k_check` — (1) форк (А): «К12 каждый step-ключ реестра присутствует в matrix-include»; (2) нет; (3) оракул; (4) переиспользует `reg_rows`, `lane_keys_of`; (5) клетка К12, 3 стаба. Повторяет свойство Г3 батареи 083 (Р4-1) — ACCIDENTAL-кандидат, не блок: строка форка (А) требует именно клетку К12, форма «без клетки» её не проходит.
- `K12C` — (1) пара честности 050 (смена состава зелена); (2) временный `$T/k12-chestno`, явный; (3) 1; (5) клетка. ESSENTIAL.
- семья стабов `K12-*` (одним артефактом) — (1) Н-39; (2) нет; (5) стаб-пак 31/31. ESSENTIAL.
- lane l3 модели — (1) А3 `--model` rc 0 под К12; ESSENTIAL.
- step `check:gen-ci-steps-coherence` — (1) строка implementer форка (А); (2) нет; (3) реестр + ci.yml генератором — 2, как у любого step; (5) lane l6. Повторяет Г1 батареи 083, которая уже в CI (Р4-1) — ACCIDENTAL-кандидат, не блок по той же причине.

## Итог

accept. К12 красна на независимом мутанте и нова (батарея 087 до К12 на том же мутанте
зелёная), шаг реестра честен (ci.yml == `--write`, ключ в l6, парити видит), legkij не тронут.
Обхода К12 в её замороженной форме не найдено. Советы (review.md): Р4-1 — посылка LANE-087
«gen --check не вызывается workflow» неверна (батарея 083 в obshchij красна на том же мутанте);
Р4-2 — обход другого свойства (условный lane-шаг джобы ci) зелёный на всех барьерах — к
адверсарию/архитектору, вне круга К12; Р4-3 — вес 5 не по замеру; Р4-4 — два стаба К12 на одну ветвь. Круг 3: Р3-4 закрыт мерой (zamer_087 rc 0), Р3-1/Р3-2/Р3-3/Р3-5 открыты.
