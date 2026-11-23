accept
OBJECT=872a0641cc8a3268c5d2d6bf62108b584ddc75f6
СУД: репо=dev-harness; предмет=208; роль=reviewer; вызов=3 (узкий по санкции консультанта); фаза=реализация; модель-план=anthropic/claude-opus-5-5; модель-факт=anthropic/claude-opus-5-5 (`bash scripts/models_actual.sh --tsv --bind --session Rev208c | cut -f1-3` → `reviewer	anthropic/claude-opus-5-5	allowed`, rc 0); предыдущий=archive/208/reviewer-v2-fail-a7ffb514a5; класс риска=рисковый
КЛАСС=КОДОВЫЙ. Скоуп: строго блок Б-2 вызова 2 и регресс. Находки: блоков 0. Б-2 закрыт. Совет 1 (С-10) в `.review/2026-11-23-150.md`. С-8 и С-9 перенесены туда открытыми, вне скоупа.

# Вердикт reviewer — 208, реализация, вызов 3 (узкий)

## Итог

**accept: блок Б-2 закрыт, новых блоков нет.**

Лист `SDACHA.md:87` теперь заявляет `· 0 · 0`. Факт той же команды на OBJECT: rc 0, `SUBJEKT 208: KLETKI 35 KRASNYH 0`. `check_sdacha --run` и `pre_critic` дают rc 0. Дверь, модель, клетки и стабы диффом не тронуты. Регресс не ухудшился. Мутация st44 по-прежнему красит ровно r31 и r32.

## 1. Объект и область правки

```
pwd → /home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/t8d4976d3d/m
git fetch ssh://git@github.com/a3ka/dev-harness.git refs/heads/wip/208/orch-lin4 → rc 0
git switch --detach 872a0641cc8a…; git rev-parse HEAD → 872a0641cc8a3268c5d2d6bf62108b584ddc75f6
git rev-parse HEAD^ → 4b5c1f0310acfaf16d30e804b29c57d5a35e22f7   (прежний OBJECT вызова 2)
git diff --stat 4b5c1f031 872a0641c →
  fixtures/workshop_project/zamok_object_predok_208/SDACHA.md | 4 ++--
  1 file changed, 2 insertions(+), 2 deletions(-)
git show -s HEAD → author=architect <architect@dev-harness.local> committer=architect
git diff --name-only 4b5c1f031 HEAD -- scripts contracts registry …/model …/stabs …/stabs-konstanty-208d …/probe208.py …/source.json | wc -l → 0
sha256sum scripts/zamok_predmeta.sh …/model/zamok_predmeta.sh → оба 47de5c0244b548d275b268a0530f634e90a09e7224b8542bb2cbe1601826bdfe
```
Один коммит. Зона architect, автор architect. Правка только в сдаточном листе. Норма, контракт и реестр не тронуты.

## 2. Закрытие Б-2

Обе команды гонялись по одной, `TMPDIR=$PWD/.scratch-rev208c`:
```
bash scripts/check_sdacha.sh "$PWD" contracts/208-zamok-object-predok.md --run
  → СДАЧА: лист зелёный (двери=14 карта=17/17 дельта=4)        RC_SDACHA=0
bash scripts/pre_critic.sh contracts/208-zamok-object-predok.md
  → ok гейт предпосылок: PREDPOSYLKI_OK … ok гейт трека … ok модель угроз красна … ok потолки красны
    … ok проводка красна … ok сдаточный лист красен / КРИТИК: дверь зелёная   RC_PRE=0
```

Красное до правки: на 4b5c1f031 дерево двери то же, отличается только строка 87 со значением `· 1 · 1`. Там `check_sdacha --run` давал rc 1 (`ОТКАЗ: строка 87: фактический rc=0 ≠ заявленного 1`), а `pre_critic` rc 1. Замер вызова 2, `archive/208/reviewer-v2-fail-a7ffb514a5`.

Форма строки 87 проверена своей мерой (python над строкой):
- `count(" · ") = 3` — ровно три разделителя полей, внутри текста разделителя нет;
- имя ряда `Red-do` побайтно `52 65 64 2d 64 6f`, как в прежнем листе (латиница).

Строка не лжёт:
- Заявлено `· 0 · 0`. Факт `--repo .`: rc 0, `SUBJEKT 208: KLETKI 35 KRASNYH 0` (§3).
- Ссылки строки существуют. «## Дельта» п.1 (`SDACHA.md:136`) — воспроизведение rc 1 и r31/r32 на двери с sha `d79af60e…`. «## Ручная проба круга h» (`SDACHA.md:233`) — та же картина мутацией st44.
- Строка 70 бюллетеня («прогон на двери ДО правки implementer; на OBJECT … rc 0 — ряд «## Двери»») не расходится с фактом. Замер на двери до правки — исторический, OBJECT зелёный.

## 3. Регресс (по одному)

```
red_zamok_object_predok_208.sh --repo .     → SUBJEKT 208: KLETKI 35 KRASNYH 0                 RC=0
red_zamok_object_predok_208.sh --model      → MODEL 208: KLETKI 35 KRASNYH 0                   RC=0
red_zamok_object_predok_208.sh --stabs      → MODEL 208: KLETKI 35 KRASNYH 0 / STABY 208: SVJAZI 73 ZHIVYH 0   RC=0
red_zamok_object_predok_208.sh --sintaksis  → SINTAKSIS OK (VALIDATE_STD_SHELLCHECK=…/shellcheck/0.11.0/shellcheck)   RC=0
run_battery.sh zamok_predmeta               → итог 4/4 классов закрыто                           RC_HYG=0
red_obryv_167.sh --repo .                   → MERGE partial ok / MERGE other_ref ok              RC_167=0
red_odin_agent_140.sh (без флага)           → KLETKI 245 KRASNYH 12                              RC_140=1
red_odin_agent_140.sh --model               → MODEL_KLETKI 244 KRASNYH 0                         RC_140M=0
```

140 без флага: красные клетки поимённо (`grep KRASNO | cut -f2 | sort -u`, 12 имён) те же, что в вызовах 1 и 2:
- o03-peredacha_nedostoverna-once, o03-peredacha_remote-once;
- p02-produktovyj-object-chuzhoj, p22-povtornyj-sud, p48-override-peredacha-schema;
- q02-tip-verdikta-ne-novyj-object, q05-chuzhoj-predmet, q10-povtor-roli, q12-ne-predok, q20-pustoj-finalnyj-merge;
- s03-object-rashoditsja, s06-object-uzhe-suzhen.

Это вариант А (С-3 вызова 1), не ухудшение.

## 4. Мутация st44 (своя сборка, корень удалён сразу)

Мутант собран своим скриптом из `scripts/zamok_predmeta.sh` дерева, а не копией стаба:
- якорь `    verdikt_put "$n" "$p" || return 0` встречается ровно один раз (`assert count == 1`);
- якорь заменён прежними двумя строками glob `.review/*`.

```
cmp <мутант> stabs-konstanty-208d/st44-glob-review-granicy/zamok_predmeta.sh → CMP_ST44=0 (побайтно равен стабу)
red_zamok_object_predok_208.sh --repo <корень мутанта>
  → SUBJEKT 208: KLETKI 35 KRASNYH 2; KRASNAJA-KLETKA r31-review-txt-vperjod, r32-review-vlozhenyj-vperjod
    (rc 1 ≠ 0, «OBJECT_RASHODITSJA … впереди кандидата …, но не кодовая граница»)   RC_MUT44=1
```
Возврат Б-1 по-прежнему различим. Корень `$TMPDIR/mut44` удалён после каждого прогона.

## ОСТАТОК (контракт 192)

- **ОСТАТОК: «реализация может расходиться с решением (отказы шире/уже)», ловец — reviewer/adversary (`contracts/208-zamok-object-predok.md:190`) — не укусил.** Место в диффе: нет, дверь диффом не тронута (sha `47de5c02…` равен вызову 2). Батарея 35/0, st44 красит r31/r32.
- **ОСТАТОК: «батарея — конечный набор; остаток — судьи», ловец adversary → reviewer (`:197`) — не укусил.** Место в диффе: `SDACHA.md:70,87`, только текст листа. Пробел батареи M7/M9 (С-8) остался как был и в этот скоуп не входит.

## СВЕРКА-СТАНДАРТОВ

н/п. `AGENTS.md` не объявляет документов архитектуры и стандарта кода (сверено в вызове 1). Дифф затрагивает только сдаточный лист фикстуры.

## СВЕРКА-АРХИТЕКТУРЫ

н/п: `bindings.json` и sourceCanon не объявлены, находок L1-L3 нет.
- размещение — правка листа в его зоне;
- зависимостей, писателей и операций не добавлено;
- долг не расширен;
- diff модели пуст (sha модели не изменился).

## Паразитная сложность (050)

Новых или раздутых артефактов в диффе нет: две строки существующего листа, без скриптов, флагов, env и состояния. Вопросы (1)-(5) не к чему применить.

## НЕ ЗАЩИЩАЕТ (этот вердикт)

- Скоуп узкий, только Б-2. С-1…С-9, остатки adversary, порядок труб и TOCTOU A2 не судились (п.4 задания).
- Красное до правки для Б-2 не перегонялось. Взят замер вызова 2 на 4b5c1f031: дерево двери то же, отличается одна строка листа.
- `check_zones.sh` не гонялся: зона сверена по автору и единственному пути коммита.
- Мобильного экрана в предмете нет.
- Модель-факт взята из трассы сессии Rev208c. Запись СУД в HANDOFF дописывает оркестратор.
