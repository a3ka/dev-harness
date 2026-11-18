accept
OBJECT=45721274721fcd6fab4b3497880cd973f0d23184
КЛАСС=КОДОВЫЙ (дверь `scripts/check_verdict_karta.sh`; КЛАСС РИСКА: обычный; адверсарий не вызывался)
СУД: repo=dev-harness; предмет=193; фаза=реализация v2; роль=reviewer; вызов=scoped №2 из ≤2 по слову владельца ~20:25 UTC 2026-11-18 («193 — ещё один узкий ревьюер, да»): только закрытие Б-1 и зависимый регресс; основание — вердикт Rev193c FAIL (`verdicts/review/contracts-193-impl-v3.md`, `.review/2026-11-18-118.md`; archive-ref `archive/193/rev193c-verdict`, PR #1110); сессия=Rev193d; модель-факт=anthropic/claude-opus-5-5 (`bash scripts/models_actual.sh --tsv --bind --session Rev193d | cut -f1-3` из `/home/harness/dev-harness` → `reviewer	anthropic/claude-opus-5-5	allowed`); независимость: автор правки — implementer (MiniMax, Impl193Fix1-2), батарею и контракт писал architect; судья — другой исполнитель (reviewer)
Находки: `.review/2026-11-18-119.md` (блоков 0; Б-1 Rev193c закрыт; советов 2 новых — С-6 и С-7; С-1…С-5 Rev193c перенесены).

# Вердикт reviewer — 193, реализация v2, scoped-вызов №2

## Итог

**accept.** Б-1 вердикта Rev193c закрыт. Правка — одна строка нормализации `%/` с комментарием, новых дефектов не вносит. Зависимый регресс зелёный: батарея во всех трёх режимах 65/65, 65/65, 41/41; красное-до своей мерой — ровно 10 клеток п.9; ручные миры m1–m8 дают ожидаемые rc; `check_sdacha --run` rc 0; `pre_critic` rc 0 (§3).

Новых советов два. С-6: клетки на хвостовой `/` нет, модель-эталон без нормализации. Это зона architect (Н-39). С-7: значения с двойным `/` — freeze отказывает ещё до ноги карты, и так же было до правки.

## 1. Объект и область правки (повестка 2)

```
pwd: /tmp/dev-harness-verify/Rev193d/repo   (origin ssh://git@github.com/a3ka/dev-harness.git; ветка wip/193/implementer)
git rev-parse HEAD origin/wip/193/implementer → 45721274721fcd6fab4b3497880cd973f0d23184 ×2
git ls-remote origin refs/heads/wip/193/implementer → 45721274721fcd6fab4b3497880cd973f0d23184
git diff --numstat 4fcd981700 45721274 → 6	0	scripts/check_verdict_karta.sh
git log 4fcd981700..45721274 → 45721274 implementer/implementer 193: хвостовой / в workflowPaths.verdicts нормализуется (%/) перед сборкой critic-каталога двери карты — блок Б-1 вердикта Rev193c
bash -n scripts/check_verdict_karta.sh → rc=0
```
- Один коммит, один путь, +6/−0: 5 строк комментария и одна строка кода `:77`. Путь лежит в `ЗОНА implementer` (`contracts/193-svyazka-sdatochnyj-list.md:349`). Атомарность соблюдена, есть ссылка на предмет и на блок.
- Батарея, контракт и реестр не трогались. Подгонки проверки под код нет.
- Место строки (`scripts/check_verdict_karta.sh:68-81`): нормализация стоит после вывода резолвера и после ветви «вне корня» (`:68-71`), но до шаблона `"$_k193_verdicts_rel"/critic/*` (`:80`). Каталог не хардкодится, резолвер не обходится. Отказ резолвера остаётся именованным и без fallback (`:64-65` не менялись). Источник карты — по-прежнему HEAD-блоб (`git cat-file -p "HEAD:$VERDICT"`, без изменений).
- Класс Н-446: `grep -nE 'grep -q|bash -c|timeout|\| *(head|tail|grep)' scripts/check_verdict_karta.sh` даёт:
  ```
  64:  || otkaz "профиль битый или workflowPaths вне репо: $(printf '%s' "$_k193_paths" | tail -n 1)"
  94:grep -q '^## Карта классов$' <<<"$telo" \
  ```
  Обе строки старые: Rev193c §5 (тогда `:64`, `:88`) — сдвиг на +6. Новая строка — чистая подстановка параметра без конвейера. `bash -c` и `timeout` нет.
- Граница не ослаблена. `%/` снимает ровно один хвостовой `/` у пути, который уже прошёл резолвер и проверку `"$ROOT"/*`. Гард пути `''|/*|*..*` (`:84-86`) не тронут. Пустым `rel` стать не может: значение `./` (корень) резолвер отвергает сам (m8f). Граничные миры со слэшем — m5a2, m5b2, m5c, m6b в §2.

## 2. Б-1 закрыт — свой зонд (повестка 1)

Зонд `/tmp/dev-harness-verify/Rev193d/manual.sh`: зонд Rev193c плюс варианты лексической формы значения. Дверь — из клона OBJECT, ROOT — свой git-мир. Профиль — настоящие `harness.project.json` и `project-layer.json`, вердикт — честная карта `mir/verdikt_chestnyj.md`, закоммиченная по каждому пути.
```
DOOR=/tmp/dev-harness-verify/Rev193d/repo/scripts/check_verdict_karta.sh
[m1-bez-profilja] path=verdicts/critic/c-777-v1.md rc=0 | КАРТА: 17/17 зелёный
[m1-bez-profilja] path=.harness/verdicts/critic/c-777-v1.md rc=1 | ОТКАЗ: путь вердикта вне грамматики verdicts/critic/…: .harness/verdicts/critic/c-777-v1.md
[m2-profil] path=.harness/verdicts/critic/c-777-v1.md rc=0 | КАРТА: 17/17 зелёный
[m2-profil] path=verdicts/critic/c-777-v1.md rc=1 | ОТКАЗ: путь вердикта вне грамматики .harness/verdicts/critic/…: verdicts/critic/c-777-v1.md
[m3-drugoj] path=workflow/judgements/critic/c-777-v1.md rc=0 | КАРТА: 17/17 зелёный
[m3-drugoj] path=.harness/verdicts/critic/c-777-v1.md rc=1 | ОТКАЗ: путь вердикта вне грамматики workflow/judgements/critic/…: .harness/verdicts/critic/c-777-v1.md
[m3b-drugoj-slash] path=workflow/judgements/critic/c-777-v1.md rc=0 | КАРТА: 17/17 зелёный
[m3b-drugoj-slash] path=.harness/verdicts/critic/c-777-v1.md rc=1 | ОТКАЗ: путь вердикта вне грамматики workflow/judgements/critic/…: .harness/verdicts/critic/c-777-v1.md
[m4-bityj] path=verdicts/critic/c-777-v1.md rc=1 | ОТКАЗ: профиль битый или workflowPaths вне репо: файл не JSON: /tmp/dev-harness-verify/Rev193d/mir.pQmI/m4-bityj/harness.project.json
[m5a-dotdot] path=verdicts/critic/c-777-v1.md rc=1 | ОТКАЗ: профиль битый или workflowPaths вне репо: project_paths_resolve: workflowPaths вне репо: verdicts
[m5a-dotdot] path=../out/critic/c-777-v1.md rc=1 | ОТКАЗ: профиль битый или workflowPaths вне репо: project_paths_resolve: workflowPaths вне репо: verdicts
[m5a2-dotdot-slash] path=verdicts/critic/c-777-v1.md rc=1 | ОТКАЗ: профиль битый или workflowPaths вне репо: project_paths_resolve: workflowPaths вне репо: verdicts
[m5a2-dotdot-slash] path=../out/critic/c-777-v1.md rc=1 | ОТКАЗ: профиль битый или workflowPaths вне репо: project_paths_resolve: workflowPaths вне репо: verdicts
[m5b-abs] path=verdicts/critic/c-777-v1.md rc=1 | ОТКАЗ: профиль битый или workflowPaths вне репо: project_paths_resolve: workflowPaths вне репо: verdicts
[m5b2-abs-slash] path=verdicts/critic/c-777-v1.md rc=1 | ОТКАЗ: профиль битый или workflowPaths вне репо: project_paths_resolve: workflowPaths вне репо: verdicts
[m5b2-abs-slash] path=/tmp/out-abs/critic/c-777-v1.md rc=1 | ОТКАЗ: профиль битый или workflowPaths вне репо: project_paths_resolve: workflowPaths вне репо: verdicts
[m5c-vnutri-dotdot] path=verdicts/critic/c-777-v1.md rc=1 | ОТКАЗ: профиль битый или workflowPaths вне репо: project_paths_resolve: workflowPaths вне репо: verdicts
[m5c-vnutri-dotdot] path=.harness/verdicts/critic/c-777-v1.md rc=1 | ОТКАЗ: профиль битый или workflowPaths вне репо: project_paths_resolve: workflowPaths вне репо: verdicts
[m6-simlink] path=.harness/verdicts/critic/c-777-v1.md rc=1 | ОТКАЗ: профиль битый или workflowPaths вне репо: project_paths_resolve: workflowPaths вне репо: verdicts
[m6-simlink] path=verdicts/critic/c-777-v1.md rc=1 | ОТКАЗ: профиль битый или workflowPaths вне репо: project_paths_resolve: workflowPaths вне репо: verdicts
[m6b-simlink-slash] path=.harness/verdicts/critic/c-777-v1.md rc=1 | ОТКАЗ: профиль битый или workflowPaths вне репо: project_paths_resolve: workflowPaths вне репо: verdicts
[m6b-simlink-slash] path=verdicts/critic/c-777-v1.md rc=1 | ОТКАЗ: профиль битый или workflowPaths вне репо: project_paths_resolve: workflowPaths вне репо: verdicts
[m7a-bez-verdicts] path=verdicts/critic/c-777-v1.md rc=1 | ОТКАЗ: профиль битый или workflowPaths вне репо: project_paths_resolve: профиль без workflowPaths.verdicts
[m7b-nowp] path=verdicts/critic/c-777-v1.md rc=0 | КАРТА: 17/17 зелёный
[m8a-slash] path=.harness/verdicts/critic/c-777-v1.md rc=0 | КАРТА: 17/17 зелёный
[m8a-slash] path=.harness/verdicts//critic/c-777-v1.md rc=1 | ОТКАЗ: путь вердикта вне грамматики .harness/verdicts/critic/…: .harness/verdicts//critic/c-777-v1.md
[m8a-slash] path=verdicts/critic/c-777-v1.md rc=1 | ОТКАЗ: путь вердикта вне грамматики .harness/verdicts/critic/…: verdicts/critic/c-777-v1.md
[m8a-slash] path=.harness/verdicts/review/c-777-v1.md rc=1 | ОТКАЗ: путь вердикта вне грамматики .harness/verdicts/critic/…: .harness/verdicts/review/c-777-v1.md
[m8b-dot] path=.harness/verdicts/critic/c-777-v1.md rc=1 | ОТКАЗ: путь вердикта вне грамматики ./.harness/verdicts/critic/…: .harness/verdicts/critic/c-777-v1.md
[m8b-dot] path=./.harness/verdicts/critic/c-777-v1.md rc=0 | КАРТА: 17/17 зелёный
[m8c-dot-slash] path=.harness/verdicts/critic/c-777-v1.md rc=1 | ОТКАЗ: путь вердикта вне грамматики ./.harness/verdicts/critic/…: .harness/verdicts/critic/c-777-v1.md
[m8c-dot-slash] path=./.harness/verdicts/critic/c-777-v1.md rc=0 | КАРТА: 17/17 зелёный
[m8d-dbl-tail] path=.harness/verdicts/critic/c-777-v1.md rc=1 | ОТКАЗ: путь вердикта вне грамматики .harness/verdicts//critic/…: .harness/verdicts/critic/c-777-v1.md
[m8d-dbl-tail] path=.harness/verdicts//critic/c-777-v1.md rc=1 | ОТКАЗ: вердикт не закоммичен (AGENTS п.9): .harness/verdicts//critic/c-777-v1.md нет на HEAD
[m8e-dbl-mid] path=.harness/verdicts/critic/c-777-v1.md rc=1 | ОТКАЗ: путь вердикта вне грамматики .harness//verdicts/critic/…: .harness/verdicts/critic/c-777-v1.md
[m8e-dbl-mid] path=.harness//verdicts/critic/c-777-v1.md rc=1 | ОТКАЗ: вердикт не закоммичен (AGENTS п.9): .harness//verdicts/critic/c-777-v1.md нет на HEAD
[m8f-koren-slash] path=critic/c-777-v1.md rc=1 | ОТКАЗ: профиль битый или workflowPaths вне репо: project_paths_resolve: workflowPaths вне репо: verdicts
[m8f-koren-slash] path=./critic/c-777-v1.md rc=1 | ОТКАЗ: профиль битый или workflowPaths вне репо: project_paths_resolve: workflowPaths вне репо: verdicts
[m8f-koren-slash] path=/critic/c-777-v1.md rc=1 | ОТКАЗ: профиль битый или workflowPaths вне репо: project_paths_resolve: workflowPaths вне репо: verdicts
[m8f-koren-slash] path=verdicts/critic/c-777-v1.md rc=1 | ОТКАЗ: профиль битый или workflowPaths вне репо: project_paths_resolve: workflowPaths вне репо: verdicts
[m9-env] path=verdicts/critic/c-777-v1.md rc=0 | КАРТА: 17/17 зелёный
```
Тот же зонд против двери `4fcd981700`: `DOOR=…/bat/slash-unfixed/scripts/check_verdict_karta.sh`. Сибсы `next_id.sh` и `profile_resolver.sh` — того же дерева. Изменились только строки со слэш-значением:
```
[m3b-drugoj-slash] path=workflow/judgements/critic/c-777-v1.md rc=1 | ОТКАЗ: путь вердикта вне грамматики workflow/judgements//critic/…: workflow/judgements/critic/c-777-v1.md
[m8a-slash] path=.harness/verdicts/critic/c-777-v1.md rc=1 | ОТКАЗ: путь вердикта вне грамматики .harness/verdicts//critic/…: .harness/verdicts/critic/c-777-v1.md
[m8c-dot-slash] path=./.harness/verdicts/critic/c-777-v1.md rc=1 | ОТКАЗ: путь вердикта вне грамматики ./.harness/verdicts//critic/…: ./.harness/verdicts/critic/c-777-v1.md
[m8d-dbl-tail] path=.harness/verdicts/critic/c-777-v1.md rc=1 | ОТКАЗ: путь вердикта вне грамматики .harness/verdicts///critic/…: .harness/verdicts/critic/c-777-v1.md
(m5a2/m5b2/m6b/m8e/m8f — те же отказы резолвера, что на OBJECT)
```

**Freeze по вариантам значения** — `/tmp/dev-harness-verify/Rev193d/f06var.py`. Берётся мир `freeze_profil_zelenyj` батареи. Значение `workflowPaths.verdicts` правится в копии мира и коммитится, затем freeze запускается напрямую. Честный вердикт физически лежит в `.harness/verdicts/critic/`.
```
### OBJECT
== verdicts=".harness/verdicts"      freeze rc=1 | ОТКАЗ: spec-preflight 036 красен (rc=127): bash: …/var-dharness_verdicts/scripts/check_spec_ready.sh: No such file or directory | теги: <нет>
== verdicts=".harness/verdicts/"     freeze rc=1 | ОТКАЗ: spec-preflight 036 красен (rc=127): bash: …/var-dharness_verdicts_/scripts/check_spec_ready.sh: No such file or directory | теги: <нет>
== verdicts="./.harness/verdicts/"   freeze rc=1 | ОТКАЗ: spec-preflight 036 красен (rc=127): bash: …/var-d_dharness_verdicts_/scripts/check_spec_ready.sh: No such file or directory | теги: <нет>
== verdicts=".harness/verdicts//"    freeze rc=1 | ОТКАЗ: заморозка v1 без вердикта критика: на HEAD нет .harness/verdicts//critic/contracts-777-v1.md. Утверждение плана или контракта невозможно без гейта критика — это механическая форма требования владельца | теги: <нет>
== verdicts=".harness//verdicts"     freeze rc=1 | ОТКАЗ: заморозка v1 без вердикта критика: на HEAD нет .harness//verdicts/critic/contracts-777-v1.md. Утверждение плана или контракта невозможно без гейта критика — это механическая форма требования владельца | теги: <нет>
### unfixed door 4fcd981700 (копия slash-unfixed)
== verdicts=".harness/verdicts"      freeze rc=1 | ОТКАЗ: spec-preflight 036 красен (rc=127): … | теги: <нет>
== verdicts=".harness/verdicts/"     freeze rc=1 | ОТКАЗ: карта классов вердикта .harness/verdicts/critic/contracts-777-v1.md красна (rc=1): ОТКАЗ: путь вердикта вне грамматики .harness/verdicts//critic/…: .harness/verdicts/critic/contracts-777-v1.md | теги: <нет>
== verdicts="./.harness/verdicts/"   freeze rc=1 | ОТКАЗ: карта классов вердикта ./.harness/verdicts/critic/contracts-777-v1.md красна (rc=1): ОТКАЗ: путь вердикта вне грамматики ./.harness/verdicts//critic/…: ./.harness/verdicts/critic/contracts-777-v1.md | теги: <нет>
== verdicts=".harness/verdicts//"    freeze rc=1 | ОТКАЗ: заморозка v1 без вердикта критика: на HEAD нет .harness/verdicts//critic/contracts-777-v1.md. … | теги: <нет>
== verdicts=".harness//verdicts"     freeze rc=1 | ОТКАЗ: заморозка v1 без вердикта критика: на HEAD нет .harness//verdicts/critic/contracts-777-v1.md. … | теги: <нет>
```
По перечню задания:

- **Хвостовой `/`.** `.harness/verdicts/` и `workflow/judgements/`: честный путь `<каталог>/critic/…` — rc 0 (m8a, m3b). На двери до правки было rc 1. Через freeze нога карты больше не отказывает: при `.harness/verdicts/` и `./.harness/verdicts/` freeze доходит до spec-preflight 036, следующего контролируемого этапа. До правки здесь был отказ картой. Закрывающее свойство Б-1 выполнено для всех значений, которые нога freeze доводит до двери: дверь и `freeze_contract.sh:107` собирают один critic-каталог `${rel%/}/critic`.
- **Без слэша** (m2, m3) — rc 0, как и раньше.
- **`./`-префикс** (m8b, m8c) — принимается `./`-форма, именно её передаёт freeze. Совет С-1 Rev193c остаётся в силе (каноническая форма без `./` отвергается).
- **Двойной `/`** (m8d `.harness/verdicts//`, m8e `.harness//verdicts`) — честный путь двери отвергнут. Freeze отказывает раньше ноги карты, своей проверкой «на HEAD нет `…//critic/…`», и так же ведёт себя дверь `4fcd981700`. Правка этого не вводила и не меняла. Дверь и freeze здесь собирают один и тот же каталог (`.harness/verdicts//critic`). Совет С-7, вне зоны 193.
- **Красные контроли без fallback:**
  - корневая приманка при профиле (m2 и m8a — `verdicts/critic/…`);
  - чужая роль (m8a `review/`);
  - битый профиль (m4);
  - `..` и абсолютный путь, со слэшем и без (m5a, m5a2, m5b, m5b2, m5c);
  - симлинк-побег, со слэшем и без (m6, m6b);
  - профиль без verdicts (m7a);
  - двойной слэш в пути вердикта (m8a второй строкой).

  Везде rc 1, честная корневая карта рядом не подхватывается.

## 3. Зависимый регресс — сырой вывод (повестка 3)

Обёртка `/tmp/dev-harness-verify/Rev193d/bat.sh`: логи в `bat/<имя>.log`, строка — итог лога.
```
repo rc=0 (27s) | ИТОГ 193: rc=0 KLETKI=65 ZELENYE=65 KRASNYE=0                  (клон, bash …/red_sdacha_193.sh --repo .)
model rc=0 (27s) | ИТОГ 193: rc=0 KLETKI=65 ZELENYE=65 KRASNYE=0                 (клон, --model)
stabs rc=0 (155s) | ИТОГ 193: rc=0 OBMANOK=41 POIMANY=41 ZHIVYH=0                (копия copy-stabs, --stabs)
дверь из e142302749eb4a8b59eaf6183af65abee54ca77c
before rc=1 (22s) | ИТОГ 193: rc=1 KLETKI=65 ZELENYE=55 KRASNYE=10               (копия before: дверь 82d5cfabb7, батарея OBJECT)
slash rc=0 (26s) | ИТОГ 193: rc=0 KLETKI=65 ZELENYE=65 KRASNYE=0                 (копия slash: OBJECT, PROFIL_STANDART verdicts='.harness/verdicts/')
slash-unfixed rc=1 (26s) | ИТОГ 193: rc=1 KLETKI=65 ZELENYE=59 KRASNYE=6         (то же, дверь 4fcd981700)
```
Выдержки:
```
before KRASNO: v13-profil-996-chestnyj v14-drugoj-verdiks-katalog v15-kornevaja-primanka v17-bityj-profil v18-simlink-pobeg-verdikts v19-staged-pochinka-plohogo v20-rabochee-uhudshenie-chestnogo v21-net-v-head-staged f05-freeze-profil-karta-krasna f06-freeze-profil-noga-zelenaja
slash-unfixed KRASNO: v13-profil-996-chestnyj v19-staged-pochinka-plohogo v20-rabochee-uhudshenie-chestnogo v21-net-v-head-staged f05-freeze-profil-karta-krasna f06-freeze-profil-noga-zelenaja
slash-unfixed: 193 v13-profil-996-chestnyj KRASNO rc=1 ОТКАЗ: путь вердикта вне грамматики .harness/verdicts//critic/…: .harness/verdicts/critic/contracts-777-v1.md
slash (OBJECT): 193 v13-profil-996-chestnyj ok rc=0 КАРТА: 17/17 зелёный
repo: 193 v15-kornevaja-primanka ok rc=1 ОТКАЗ: путь вердикта вне грамматики .harness/verdicts/critic/…: verdicts/critic/contracts-777-v1.md
repo: 193 v17-bityj-profil ok rc=1 ОТКАЗ: профиль битый или workflowPaths вне репо: файл не JSON: /tmp/batareja-193-8wqlkvcs/mir-profil_bityj/har
repo: 193 v18-simlink-pobeg-verdikts ok rc=1 ОТКАЗ: профиль битый или workflowPaths вне репо: project_paths_resolve: workflowPaths вне репо: verdicts
repo: 193 v22-absoljutnyj-put ok rc=1 ОТКАЗ: путь вердикта вне грамматики .harness/verdicts/critic/…: /tmp/batareja-193-8wqlkvcs/mir-profil_chestnyj
repo: 193 v23-tochki-za-koren ok rc=1 ОТКАЗ: путь вердикта вне грамматики (относительный, внутри корня): verdicts/critic/../../evil.md
stabs: 193 PATERN:KOREN-ZAPASNOJ POIMAN / PATERN:BEZ-GRAMMATIKI-PUTA POIMAN / PATERN:PROFIL-PREFIKS-OTREZAN POIMAN
```
- Красное-до своей мерой: 10 клеток, набор совпадает с п.9 контракта (v13 v14 v15 v17 v18 v19 v20 v21 f05 f06).
- Красное правки — пара `slash-unfixed` 59/6 → `slash` 65/65. Различаются ровно одной строкой `:77`.

Счётные утверждения автора, своя мера (другой командой):
- `grep -cE '^193 \S+ ok ' repo.log` → 65; то же по `model.log` → 65;
- `grep -c 'POIMAN$' stabs.log` → 41;
- `grep -vcE '^\s*(#|$)' stabs.tsv` → 41;
- `grep -E '^193 PATERN' stabs.log | grep -vc 'POIMAN$'` → 0.

Всё совпадает с докладом автора (65/65, 65/65, 41/41/0, слэш-копия 65/65).

```
$ bash scripts/check_sdacha.sh . contracts/193-svyazka-sdatochnyj-list.md --run
СДАЧА: лист зелёный (двери=5 карта=17/17 дельта=2)
rc=0
$ bash scripts/check_provodka.sh . contracts/193-svyazka-sdatochnyj-list.md            → rc=0
$ bash scripts/check_provodka.sh --grammar . contracts/193-svyazka-sdatochnyj-list.md  → rc=0
```
`pre_critic`: первый прогон дал rc 1, причина — окружение, а не правка:
```
$ bash scripts/pre_critic.sh --repo . contracts/193-svyazka-sdatochnyj-list.md
ОТКАЗ: precision-gate красен: contracts/193-svyazka-sdatochnyj-list.md
rc=1
$ bash scripts/check_precision_gate.sh . contracts/193-svyazka-sdatochnyj-list.md
precision-гейт 043: реестр заморозок не читается: missing-remote
rc=1
```
После моего `fetch` origin получил новый тег `frozen/contracts/122/5`. Тот же класс, что у `check_zones` в Rev193c §6. После повторного `git fetch --tags origin`:
```
$ git fetch --tags origin   →  * [new tag]  frozen/contracts/122/5 -> frozen/contracts/122/5
$ bash scripts/pre_critic.sh --repo . contracts/193-svyazka-sdatochnyj-list.md
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=1
  ok   гейт трека: 
  ok   дверь архитектуры 187а: ARCH_187A_SKIP: проект не в режиме 187а (repoId/пин модели)
  ok   модель угроз красна
  ok   потолки красны
  ok   проводка красна
КРИТИК: дверь зелёная
  ok   сдаточный лист красен
rc=0
```

## 4. Блоки

Нет. Б-1 Rev193c закрыт (§2).

**Закрывающее свойство и его доказательство.** Для всех значений `workflowPaths.verdicts`, которые нога freeze доводит до двери, дверь и `scripts/freeze_contract.sh:107` собирают один critic-каталог. Честный путь `<каталог>/critic/…` зелёный при прямом вызове (m8a, m3b) и проходит ногу карты freeze (f06var, `.harness/verdicts/` и `./.harness/verdicts/`).

Строка, которая это даёт, — `scripts/check_verdict_karta.sh:77`:
```
_k193_verdicts_rel="${_k193_verdicts_rel%/}"
```

## 5. Паразитная сложность (050) — артефакт диффа

| Артефакт | (1) свойство | (2) состояние | (3) сопряжённые файлы | (4) глубина | (5) потребитель | класс |
|---|---|---|---|---|---|---|
| `:77` `_k193_verdicts_rel="${_k193_verdicts_rel%/}"` + комментарий `:72-76` | И7 «внутри critic-каталога эффективного `workflowPaths.verdicts`» и И8 (нога freeze на том же каталоге) | нет нового; производная вывода резолвера | дверь + `freeze_contract.sh:107` (та же форма `%/`) + модель (С-6). Сопряжение не выросло: freeze уже нёс эту форму | интерфейс не изменился (2 аргумента, rc 0/1/2) | f06 на слэш-профиле (копия `slash`); в штатной батарее клетки нет — С-6 | ESSENTIAL: проще одной подстановки формы нет; повторяет грамматику freeze, а не изобретает новую |

## 6. Строки сверок

СВЕРКА-СТАНДАРТОВ: н/п. `AGENTS.md` харнесса не объявляет `docs/ARCHITECTURE.md` и `docs/CODING-STANDARDS.md`, в дереве их нет (Rev193c §8; дифф этого не меняет).

СВЕРКА-АРХИТЕКТУРЫ: н/п по инструменту — `tooling/checks/cli.js` и `bindings.json` в дереве отсутствуют, находки записаны в `.review/2026-11-18-119.md`. По существу:

- **Размещение.** Одна строка в существующем файле зоны implementer.
- **Зависимости.** Новых нет.
- **Писатели и операции.** Без изменений.
- **Долг модели.** Модель-эталон отстаёт на одну строку (С-6, зона architect). Уровень diff модели — L1: форма одной подстановки, поведение на значениях без хвостового `/` совпадает (`--model` 65/65).

Проводка (038/1): канал не менялся. Guard `red_sdacha_193.sh` подключён строкой `registry/ci-steps.tsv:318`.

Режим проекта (996/1): у харнесса `sourceCanon` нет — неприменимо.

Норма не тронута: `roles/`, `AGENTS.md`, `docs/owner/` в диффе отсутствуют.

## 7. Остаток контракта (НЕ ЗАЩИЩАЕТ, ловец reviewer)

- ОСТАТОК: НЗ-1 (смысловая достаточность, содержательное закрытие блока) — не укусил. Закрытие Б-1 доказано своим зондом и freeze-зондом (§2), а не зелёной дверью. Лист перепрогнан: `check_sdacha --run` rc 0.
- ОСТАТОК: К-04 (охват дверей формы, расположение листа) — не укусил. Дифф листа и батареи не касается.
- ОСТАТОК: НЗ-4 (карта исторических FAIL-вердиктов) — не укусил. Предыдущий вердикт Rev193c FAIL карты не несёт и следующему листу не предъявлен. Этот вердикт — reviewer, не critic, нога freeze его не судит.
- ОСТАТОК: НЗ-5 (универсальная полнота мутаций; сговор субъекта с батареей) — укусил в части полноты, место в диффе — `scripts/check_verdict_karta.sh:77`. Снятие строки штатная батарея не ловит (С-6). Сговора нет: `git diff 4fcd981700 45721274 -- fixtures contracts registry` пуст.
- ОСТАТОК: НЗ-6 (профильная раскладка контрактов в тегах заморозок) — дифф не затрагивает.

## 8. Что не проверено

- Общий регресс (п.7: 103/191/192/189/190) и `check_zones` — по заданию за CI (PR #1099). Сам не гонял.
- Мутации MU1–MU6 Rev193c не перегонялись: строки, на которых они стоят, правкой не тронуты.
- `HARNESS_PROJECT_LAYER_ROOT` при наличии профиля и значение verdicts, указывающее на симлинк внутри репо, — как в Rev193c §10, не исследовались.

## Развилки

1. **Развилка автора (модель без нормализации, клетки на хвостовой `/` нет) — не блок.** Б-1 закрыт, и это доказано ручным зондом и копией `slash`, как и допускает задание. Сторож регресса — решение architect по коду (Н-39): совет С-6.
2. **Двойной `/` (С-7) — совет, а не блок.** Состояние достижимо: резолвер такое значение принимает. Но отказ даёт собственная нога freeze («на HEAD нет …//critic/…», `freeze_contract.sh`, не дверь 193), и до правки было так же. Обязательство двери (И7: тот же critic-каталог, что у резолвера и freeze) не нарушено. Канонизация значения — вопрос 996.
