accept
OBJECT=3a60ded61fadf326ea6f9ce7f680cdc5724b66bc

СУД: repo=dev-harness; предмет=173; фаза=реализация; роль=reviewer; вызов=1 (полный; первый вызов на этот OBJECT не материализован: клон прошлой сессии потерян при аварийной перезагрузке, закоммиченного вердикта нет, освобождено `obryv_bez_verdikta`, круг не потрачен); модель-план=anthropic/claude-opus-5-5 (`config/agent_models.json`: reviewer→audit→@opus); модель-факт=anthropic/claude-opus-5-5; сессия=Rev173v1b; SHA=3a60ded61fadf326ea6f9ce7f680cdc5724b66bc (tip `wip/173/implementer`, один коммит автора `implementer` на aae959e1); контракт=frozen/contracts/173/1 → e9ce3992699fcf39147bbe508dd362711cfa4929; автор реализации — implementer, автор клеток — architect; предыдущий=нет; исключение=нет.

# Вердикт ревьюера — 173, реализация (вызов 1)

- Принятый блоб: `scripts/check_sud_model.sh` f0f1234fb20b78e0ebbd242b3b56539eb7c03ef9. Новая редакция файла это accept не наследует.
- Блобы контракта и семьи на OBJECT равны тегу: контракт d825acba, `probe.py` 00b5c281, `red_sud_model_173.sh` d213ab3d. Команда `git diff --stat frozen/contracts/173/1 3a60ded6 -- contracts/173-… fixtures/workshop_project/sud_model_173/ fixtures/zashchita_main_104/ contracts/104-…` дала пустой вывод.
- Базовая редакция `scripts/check_sud_model.sh` на aae959e1 равна `frozen/contracts/104/2` (`git diff --stat` пуст).
- Класс задачи — кодовый, класс риска — обычный, адверсарий не назначен.
- Находки: `.review/2026-11-10-98.md`. Блоков 0, советов 1 (С-1, architect), наблюдений 3 (Н-1 orchestrator, Н-2 и Н-3 к сведению).
- Клон одноразовый, со своим `.git`, origin по ssh: `/tmp/dev-harness-verify/Rev173v1b/repo`. Worktree ветки оркестратора для Н-1: `/tmp/dev-harness-verify/Rev173v1b/orch` на c3e1b83f.

## 1. Область правки ⊆ зоны

```
$ git show 'frozen/contracts/173/1^{commit}':contracts/173-normalizaciya-imyon-modelej-sudi.md | grep -n '^ЗОНА implementer\|^ПЕРЕСЕЧЕНИЕ implementer'
40:ЗОНА implementer: scripts/check_sud_model.sh
44:ПЕРЕСЕЧЕНИЕ implementer: scripts/check_sud_model.sh — 104 только три сравнения модели; привязка и алфавиты 104 без изменений.
$ git merge-base origin/main origin/wip/173/implementer
aae959e1b3e411216acb8e03da97d3eea319b941
$ git diff --name-only aae959e1..3a60ded6
scripts/check_sud_model.sh
$ git log --format='%h %an <%ae>' aae959e1..3a60ded6
3a60ded6 implementer <implementer@dev-harness.local>
$ git diff aae959e1 3a60ded6 --numstat
34	4	scripts/check_sud_model.sh
$ git merge-tree --write-tree origin/main 3a60ded6
0d35176e85cc7195d24a38eaa106e23e04148e2f          # rc 0, конфликтов нет
```

Удалено 4 строки, и это ровно то, что разрешает ПЕРЕСЕЧЕНИЕ:
- три сравнения `!=` на спавне (`:243`), на allowed primary (`:344`) и на denied fallback (`:353`); каждое заменено вызовом `sud_same_model`;
- одна строка комментария шапки `:43`, дописанная пояснением 173.

Добавлены функция `sud_same_model` (`:107-130`) и абзац шапки. Валидаторы алфавита (`sud_model_alphabet_ok`, `sud_session_alphabet_ok`, `sud_object_ok`), резолв roles→tiers→models, порядок «сессия → объект → модель», ветвь `frontmatter` и тексты отказов не тронуты. 104-батареи это подтверждают (§2).

Полный `check_zones.sh .` локально я не досчитал: остановлен через 340 с, rc 143 (SIGTERM). До остановки в выводе были только строки `ok … СПАСЕНО` по 043/045. Это не затронутый барьер, и по заданию полный прогон делает CI (шаг `check:zones`). Принадлежность зоне я сверил своей мерой выше: имена файлов диффа ⊆ `ЗОНА implementer` на теге, автор единственного коммита — `implementer`.

## 2. Приёмка на OBJECT — мой прогон, не вывод автора

Строки приёмки 3–4: CI-маршрут и `--repo` на реализации.

```
$ git rev-parse HEAD
3a60ded61fadf326ea6f9ce7f680cdc5724b66bc
$ bash fixtures/workshop_project/sud_model_173/red_sud_model_173.sh --repo
173 spawn_bare_opus ZELENO
173 spawn_bare_glm ZELENO
173 verdict_bare_primary ZELENO
173 verdict_bare_fallback ZELENO
173 verdict_bare_glm ZELENO
173 dynamic_bare_opus ZELENO
173 spawn_prefixed ZELENO
173 verdict_prefixed ZELENO
173 fallback_prefixed ZELENO
173 spawn_wrong_version ZELENO
173 spawn_foreign_provider ZELENO
173 verdict_wrong_version ZELENO
173 verdict_foreign_provider ZELENO
173 fallback_wrong_version ZELENO
173 fallback_foreign_provider ZELENO
173 spawn_suffix_bare ZELENO
173 verdict_suffix_bare_primary ZELENO
173 verdict_suffix_bare_fallback ZELENO
173 verdict_fallback_tail_fragment ZELENO
rc=0
$ bash fixtures/workshop_project/sud_model_173/red_sud_model_173.sh --model
(те же 19 строк ZELENO)
rc=0
$ bash fixtures/workshop_project/sud_model_173/red_sud_model_173.sh --stabs
173 control_spawn_exact ZELENO
173 mutant_spawn_exact KRASNO: rc=1 … stderr='ОТКАЗ: модель не тира роли: reviewer тир audit спавн claude-opus-5-5\n' …
STAB spawn_exact caught: spawn_bare_opus
STAB primary_exact caught: verdict_bare_primary
STAB fallback_exact caught: verdict_bare_fallback
STAB spawn_any_provider caught: spawn_foreign_provider
STAB primary_any_provider caught: verdict_foreign_provider
STAB fallback_any_provider caught: fallback_foreign_provider
STAB spawn_suffix_glob caught: spawn_suffix_bare
STAB primary_suffix_glob caught: verdict_suffix_bare_primary
STAB fallback_suffix_glob caught: verdict_suffix_bare_fallback
STAB fallback_tail_glob caught: verdict_fallback_tail_fragment
rc=0
$ bash fixtures/workshop_project/sud_model_173/red_sud_model_173.sh        # CI: --repo, --model, --stabs
ci rc=0
$ bash fixtures/zashchita_main_104/red_sud_model_dver_spavna.sh
ЗЕЛЕНО: red_sud_model_dver_spavna
rc=0
$ bash fixtures/zashchita_main_104/red_sud_model_materializatsija.sh
ЗЕЛЕНО: red_sud_model_materializatsija
rc=0
```

Счёт сверен своей мерой: токены вывода и перечни в коде пробы, а не строки-итоги автора.

```
$ … --repo | awk '{print $NF}' | sort | uniq -c
     19 ZELENO
$ … --stabs | awk '/^STAB/{print $3}' | sort | uniq -c
     10 caught:
$ python3 -c 'import probe; …'
CASES 19 STABS 10 stab-labels-distinct 10
```

Заявленные числа подтверждены: 19/19 `ZELENO`, 10/10 `STAB … caught`, `ZHIV` 0. У каждого стаба своя клетка-различитель, 10 различных меток.

Те же прогоны через `reslop t --`, все exit 0: CI-маршрут 173, обе 104-батареи и `scripts/check_ceilings.sh` («потолки в порядке», passed 3). `bash scripts/pre_critic.sh --repo . contracts/173-…` → rc 0, «КРИТИК: дверь зелёная», `PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=1`. `bash scripts/gen_ci_steps.sh --check` → rc 0.

## 3. Красное предъявлено

**Строка приёмки 1, та же семья на дереве базы aae959e1:**

```
$ git checkout -q --detach aae959e1 && bash fixtures/workshop_project/sud_model_173/red_sud_model_173.sh --repo
173 spawn_bare_opus KRASNO: rc=1 stdout='' stderr='ОТКАЗ: модель не тира роли: reviewer тир audit спавн claude-opus-5-5\n'; expected rc=0 …
173 spawn_bare_glm KRASNO: rc=1 … 'ОТКАЗ: модель не тира роли: critic тир apex спавн glm-5.3\n' …
173 verdict_bare_primary KRASNO: rc=1 … 'ОТКАЗ: вердикт не материализуется: судья reviewer на модели claude-opus-5-5, тир audit (Н-270)\n' …
173 verdict_bare_fallback KRASNO: rc=1 … 'ОТКАЗ: фолбэк вне списка тира: reviewer на gpt-6-sol, тир audit (Н-270)\n' …
173 verdict_bare_glm KRASNO: rc=1 … 'ОТКАЗ: вердикт не материализуется: судья critic на модели glm-5.3, тир apex (Н-270)\n' …
173 dynamic_bare_opus KRASNO: rc=1 … 'ОТКАЗ: модель не тира роли: reviewer тир audit спавн claude-opus-67e5c188fe36\n' …
173 spawn_prefixed ZELENO
… (ещё 12 ZELENO: prefixed ×2, wrong_version ×3, foreign_provider ×3, suffix_bare ×3, tail_fragment)
rc=1
```

Итог: ровно шесть названных bare-клеток `KRASNO`, остальные 13 `ZELENO`, rc 1.

**Мутанты самого предмета.** Ноги `--model` и `--stabs` исполняют закреплённого кандидата 104/2, а не рабочее дерево (Н-3). Поэтому красное против сломанной реализации я предъявляю правкой `scripts/check_sud_model.sh` в клоне: мутант → `--repo` → восстановление, после прогона `git status` чистый.

```
A_any_provider          (:119 обе-с-префиксом → сравнение без провайдера)  rc 1 KRASNO 3 [spawn_foreign_provider, verdict_foreign_provider, fallback_foreign_provider]
C_suffix_glob           (:125 → case "$fact" in "${want#*/}"*)             rc 1 KRASNO 3 [spawn_suffix_bare, verdict_suffix_bare_primary, verdict_suffix_bare_fallback]
F_tail_glob             (:125 → case "$want" in *"$fact")                  rc 1 KRASNO 1 [verdict_fallback_tail_fragment]
E_spawn_exact           (:243 → прежний !=)                                rc 1 KRASNO 3 [spawn_bare_opus, spawn_bare_glm, dynamic_bare_opus]
H_primary_exact         (:344 → прежний !=)                                rc 1 KRASNO 2 [verdict_bare_primary, verdict_bare_glm]
G_fallback_exact        (:353 → прежний !=)                                rc 1 KRASNO 1 [verdict_bare_fallback]
D_longest_strip         (:125 ${want#*/} → ${want##*/})                    rc 0 KRASNO 0
I_fact_prefixed_strip_any (:120 ${fact#*/} → ${fact##*/})                 rc 0 KRASNO 0
```

Шесть мутантов из восьми батарея ловит, и каждый — на клетках своей точки. D и I выживают: в семье нет ID из нескольких сегментов через `/`. Контракт выносит такие ID из семьи, и все модели реестра однослешевые. Поэтому это совет С-1, а не блок. Реализация на таком входе корректна (§4).

## 4. Инварианты контракта своей мерой

Входы вне перечня клеток, игрушечный корень с теми же назначениями (reviewer `anthropic/claude-opus-5-5`, fallback `openai-codex/gpt-6-sol`, critic `zai/glm-5.3` без fallback), OBJECT:

```
spawn reviewer '/claude-opus-5-5'              1  ОТКАЗ: модель не тира роли: reviewer тир audit спавн /claude-opus-5-5
spawn reviewer 'anthropic/'                    1  ОТКАЗ: модель не тира роли: … спавн anthropic/
spawn reviewer 'x/anthropic/claude-opus-5-5'   1  ОТКАЗ: модель не тира роли: … спавн x/anthropic/claude-opus-5-5
spawn reviewer 'claude-opus-5-5/'              1  ОТКАЗ: …
spawn reviewer 'anthropic/claude-opus-5-5/'    1  ОТКАЗ: …
spawn reviewer 'ANTHROPIC/claude-opus-5-5'     1  ОТКАЗ: …                       # провайдер побайтно, регистр различается
spawn reviewer 'Claude-opus-5-5'               1  ОТКАЗ: …
spawn reviewer 'claude-opus-5'                 1  ОТКАЗ: …                       # укороченная версия
spawn reviewer 'opus-5-5'                      1  ОТКАЗ: …                       # хвостовой фрагмент на спавне
spawn reviewer '-n'                            1  ОТКАЗ: …                       # `[ = ]` не путает аргумент с опцией
spawn reviewer '='                             2  ОТКАЗ: модель вне алфавита: = …  # алфавит 104 до сравнения, как прежде
verdict critic 'glm-5.3' denied                1  ОТКАЗ: фолбэк вне списка тира: critic на glm-5.3, тир apex (Н-270)   # fallback null — bare не открывает denied
verdict reviewer 'claude-opus-5-5' denied      1  ОТКАЗ: фолбэк вне списка тира: …   # primary не засчитан как fallback
verdict reviewer 'gpt-6-sol' allowed           1  ОТКАЗ: вердикт не материализуется: …  # fallback не засчитан как primary
verdict reviewer '/gpt-6-sol' denied           1  ОТКАЗ: фолбэк вне списка тира: …   # пустой провайдер при prefixed назначении — отказ
verdict reviewer 'evil/claude-opus-5-5' allowed 1 ОТКАЗ: вердикт не материализуется: …
```

Вывод по каждому инварианту:
- **Эквивалентность.** bare ≡ prefixed на всех трёх точках (§2, клетки bare_*), в обе стороны по форме функции.
- **Префиксы.** Обе строки с префиксом сравниваются только побайтно (`evil/…`, `ANTHROPIC/…`, `x/anthropic/…`).
- **Литеральность.** Обе bare сравниваются побайтно. Шаблоны `*/` в `case` и `${…#*/}` — литералы кода, значение модели в шаблон не попадает. Факт проходит алфавит 104 (без `* ? [`) до каждого из трёх сравнений (`:239`, `:314`). Ожидание приходит из реестра и встречается только как субъект `case` и операнд `[ = ]`.
- **Выводимые ID.** Отказы и `СУДЬЯ СВОЕЙ МОДЕЛИ: … модель <факт>` печатают исходную строку факта: `/claude-opus-5-5`, `claude-opus-5-5` в клетках `spawn_bare_*`, сверено с оракулом пробы.
- **Источник и привязка.** Источник назначений, тексты отказов и порядок привязки не менялись; их держат 104-батареи (§2, rc 0).

## 5. Проверка не подогнана, атомарность, норма

- Коммит автора не трогает `fixtures/`, `contracts/` и 104-семью: блобы равны тегу (шапка). Файлы проверок с момента заморозки менял только architect, до тега: b2455418, 83f88e7a, edb3af45.
- Литералы фикстуры (`Sud173_A`, `evil`, `20261101`, `gpt-6-terra`, `toy`) в коде реализации не встречаются. `anthropic/claude-opus-5-5` есть только в комментарии шапки `:45` как пример из контракта.
- Логика `sud_same_model` совпадает с честной моделью `HELPER` в `probe.py:25-31` (Н-2). Клетки при этом не менялись, а различающая сила реализации подтверждена мутантами §3 и входами §4. Это заимствование формы, а не проверка, подогнанная под код.
- Атомарность: один коммит, одна задача, ссылка на предмет «173:». ok.
- Нормативные документы (`roles/`, `contracts/`, нормы, `docs/owner/`) диффом не тронуты.

## 6. ПРОВОДКА (038)

Канал один: `guard=fixtures/workshop_project/sud_model_173/red_sud_model_173.sh`. Это барьер именно этого предмета: 19 клеток адресуют три точки сравнения 173, 10 стабов привязаны каждый к своей ветви (§2). ПРОВОДКА-ЭНФОРСМЕНТ обоснована честно. Меняется сравнение идентификаторов внутри существующей двери, поведенческой нормы роли нет, поэтому role-канал не нужен.

```
$ bash scripts/check_provodka.sh . contracts/173-normalizaciya-imyon-modelej-sudi.md          # OBJECT
проводка: guard не подключён: fixtures/workshop_project/sud_model_173/red_sud_model_173.sh не вызывается в .githooks/ или .github/workflows/
provodka rc=1
$ (cd ../orch @ c3e1b83f = origin/wip/173/orchestrator) bash scripts/check_provodka.sh . contracts/173-…
provodka@orch rc=0
$ git diff 3a60ded6 c3e1b83f -- registry/ci-steps.tsv registry/ci-zamery.tsv | grep '^[+-][^+-]'
+step	check:sud-model-173-family-selftest	4	bash fixtures/workshop_project/sud_model_173/red_sud_model_173.sh
+check:sud-model-173-family-selftest	4	8	0
```

Так и ожидалось: контракт относит подключение CI-шага к оркестратору после ленда. На c3e1b83f блоб `scripts/check_sud_model.sh` тот же, f0f1234f. Это наблюдение Н-1, к предмету данного суда не относится.

## 7. Паразитная сложность (050)

| Артефакт | (1) свойство | (2) состояние | (3) файлов на правку свойства | (4) глубина | (5) потребитель / повтор | Класс |
|---|---|---|---|---|---|---|
| функция `sud_same_model` (`:113-130`) | §Предмет: bare ≡ prefixed, prefixed/prefixed и bare/bare — побайтно, на трёх точках | нет, чистая функция двух аргументов, rc 0/1 | 1 (было 3 места сравнения, теперь одно) | интерфейс 2 аргумента + rc; за ним 3 ветви | три вызова; все 19 клеток. Другой нормализации имени модели в `scripts/` нет (grep `same_model\|#*/`). Совпадение с `HELPER` пробы — независимая модель architect, не дерево | ESSENTIAL |
| три вызова на точках `:243`, `:344`, `:353` | §Предмет: «сравнить на каждой из трёх существующих точек» | нет | 1 | — | клетки spawn_*, verdict_*, fallback_* | ESSENTIAL |
| абзац шапки `:43-48` и комментарий функции `:107-112` | документация двери в шапке (прежний стиль 104) | нет | 1 | — | — | ESSENTIAL (документация) |

Нового флага, env-переменной, файла состояния или ветви барьера дифф не вводит.

## СВЕРКА-СТАНДАРТОВ

Не применимо. `AGENTS.md` харнесса не объявляет `docs/ARCHITECTURE.md` и `docs/CODING-STANDARDS.md`. `sourceCanon` не объявлен: `jq 'has("sourceCanon")' harness.project.json` → false, `registry/harness-project.json` → false. Поэтому норма 996/1 не применяется. Мобильного экрана нет.

## Итог

accept для OBJECT 3a60ded61fadf326ea6f9ce7f680cdc5724b66bc на frozen/contracts/173/1. Блоков нет.
- Зона: только `scripts/check_sud_model.sh`; изменены только три сравнения и добавлен хелпер, привязка и алфавиты 104 нетронуты.
- Приёмка: на базе `--repo` дал rc 1 (6 KRASNO и 13 ZELENO). На OBJECT `--repo` 19/19, `--model` 19/19, `--stabs` 10/10 caught, CI rc 0, 104-батареи rc 0, `pre_critic` rc 0, `gen_ci_steps --check` rc 0.
- Своей мерой: 6 из 8 мутантов предмета красные. Два выживших лежат вне семьи (С-1). Пограничные входы ведут себя по контракту.

Совет С-1 и наблюдения Н-1, Н-2, Н-3 — в `.review/2026-11-10-98.md`. Done по-прежнему требует ленда проводки orchestrator и зелёного `check_provodka`.
