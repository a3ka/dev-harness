accept
OBJECT=f2680049863e1a5f83d4328bd43adc2b37ef858c
СУД: репо=dev-harness; предмет=204; роль=reviewer; вызов=2; фаза=реализация; модель-план=anthropic/claude-opus-5-5; модель-факт=anthropic/claude-opus-5-5 (`bash scripts/models_actual.sh --tsv --bind --session Rev204S | cut -f1-3` → `reviewer	anthropic/claude-opus-5-5	allowed`, rc 0); предыдущий=archive/204/reviewer-v1-fail-98028af789; класс риска=обычный
КЛАСС=КОДОВЫЙ (КЛАСС РИСКА: обычный; вызов 2 — исправительный scoped по Б-1 вызова 1; бюджет «полный + один scoped» этим вызовом исчерпан)
Контракт: contracts/204-karta-vyzova-po-faze.md, frozen/contracts/204/1 (тег 58117ad6fc → коммит fd294feda1). `git diff --stat frozen/contracts/204/1 HEAD -- contracts/204-karta-vyzova-po-faze.md` → пусто.
Находки: блоков 0; Б-1 вызова 1 закрыт. Советов 0, наблюдений 2 (`.review/2026-11-22-146.md`).

# Вердикт reviewer — 204, реализация, вызов 2 (scoped: закрытие Б-1 и зависимый регресс)

## Итог

**accept.** Б-1 вызова 1 закрыт.

- Клетка `m1-fail-v-samom-merge` с привязкой `PATERN:BEZ-M` ловит мутант «обход имён без `-m`» на реальной батарее `--repo`. Ловит ровно на этой клетке.
- Я построил свой мир с другой топологией merge: FAIL появляется переименованием в evil-merge второй стороны. На этом мире тот же мутант лжёт (rc 0), а OBJECT отказывает (rc 1, К-09). Значит, клетка автора закрывает класс «имя FAIL видно только в diff merge-коммита», а не только мир автора.
- Регресс 204, 193, pre_critic и сдаточная дверь — зелёные.
- Прочие мутанты вызова 1 по-прежнему красны.

## Блоков нет

Вызов 1 нашёл одно нарушение — Б-1, и его закрывающее свойство теперь выполнено:
- `--repo .` зелёный на OBJECT: 23/23/0;
- мутант «без `-m`» привязан в `stabs.tsv` к merge-клетке и пойман;
- `--stabs` вырос на одну связь: 10/12/12/0;
- код `scripts/lib_karta_sdachi.sh` не менялся.

## 1. Объект и область правки

```
pwd → /home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/tb51b60efa/m
git fetch ssh://git@github.com/a3ka/dev-harness.git refs/heads/wip/204/orch-impl → rc 0
git switch --detach f2680049863e1a5f83d4328bd43adc2b37ef858c; git rev-parse HEAD → f2680049863e1a5f83d4328bd43adc2b37ef858c
git diff --stat c9de3a0f79 f2680049863e1a5f83d4328bd43adc2b37ef858c:
  fixtures/workshop_project/karta_vyzova_204/SDACHA.md | 31 +++-
  fixtures/workshop_project/karta_vyzova_204/probe.py  | 31 +++
  fixtures/workshop_project/karta_vyzova_204/stabs.tsv |  1 +
  registry/contracts.tsv                               |  2 +-
  4 files changed, 63 insertions(+), 2 deletions(-)
git log --format='%H %P %an|%cn %s' c9de3a0f79..HEAD:
  f2680049863e… 3993f57911… c7ca855406…  orchestrator|orchestrator  merge main (c7ca85540) в int-204
  3993f57911… c9de3a0f79… 28a915950b…  orchestrator|orchestrator  merge wip/204/architect-g (Arch204g)
  28a915950b… c9de3a0f79…              architect|architect        204: Б-1 Rev204 v1 — merge-мир m1-fail-v-samom-merge и стаб PATERN:BEZ-M
  c7ca855406… (main) GitHub merge PR #1243 ← 79bf3372a7 owner|owner «registry 204 → frozen/contracts/204/1 (REPLACE)» (registry/contracts.tsv | 2 +-)
git diff-tree --cc 3993f5791 → только строка sha (пусто)
git diff-tree --cc f26800498 → только строка sha (пусто)
git diff --stat c9de3a0f79 HEAD -- scripts/lib_karta_sdachi.sh contracts/ → пусто, rc 0
registry/contracts.tsv: единственная строка `-204 → e357a903d3…` / `+204 → 58117ad6fccac6d34950dcb558641656a2a128fd` = `git ls-remote … refs/tags/frozen/contracts/204/1` (58117ad6fc…)
```

Область соответствует заданию:
- три файла зоны architect в `fixtures/workshop_project/karta_vyzova_204/`;
- `registry/contracts.tsv` из main, коммит владельца;
- lib, контракт и семья 193 не тронуты;
- автор равен коммиттеру на каждом коммите, каждый коммит в своей зоне.

Неподгонка проверки. Батарею менял architect — зона Н-39, — а не автор реализации:
- ожидания честной lib не ослаблены: в diff probe.py только добавления, существующие клетки и ожидания стабов не изменены;
- новая клетка требует отказа rc 1, а не разрешения.

## 2. Закрытие Б-1: мутант M3b своей рукой

Мутант M3b собран так:
- копия `scripts/` взята `git archive HEAD scripts` в scratch;
- замена с единственным якорем (assert count==1) `--full-history -m HEAD` → `--full-history HEAD`;
- `bash -n` → rc 0;
- `diff` показал одну строку 205.

```
bash fixtures/workshop_project/karta_vyzova_204/red_karta_vyzova_204.sh --repo <scratch>/m3b
  204 m1-fail-v-samom-merge KRASNO rc=0 СДАЧА: лист зелёный (двери=1 карта=17/17 дельта=0)
  204 ожидалось rc=1 ОТКАЗ: блок К-09 предыдущего вердикта не закрыт в «## Дельта»
  ИТОГ 204: rc=1 KLETKI=23 ZELENYE=22 KRASNYE=1           → rc 1 (красна ровно m1)
bash … --repo .   (честная lib OBJECT)
  204 m1-fail-v-samom-merge ok rc=1 ОТКАЗ: блок К-09 предыдущего вердикта не закрыт в «## Дельта»
  ИТОГ 204: rc=0 KLETKI=23 ZELENYE=23 KRASNYE=0           → rc 0
bash … --stabs
  204 PATERN:BEZ-M -> m1-fail-v-samom-merge POIMAN rc=0 СДАЧА: лист зелёный (двери=1 карта=17/17 дельта=0)
  ИТОГ 204: rc=0 MUTACII=10 SVJAZI=12 POIMANY=12 ZHIVYH=0 → rc 0
```

Якорь стаба `--full-history -m HEAD` встречается ровно один раз и в модели (`model/lib_karta_sdachi.sh:139`), и в production (`scripts/lib_karta_sdachi.sh:205`). Поэтому стаб адресный.

### Свой мир (топология, отличная от клетки автора)

Клетка автора кладёт FAIL в merge-коммит первой линии main. Мой мир (`world_rev.sh side-evil-rename`) устроен так:
- реальные `scripts/` взяты из `git archive HEAD`;
- контракт `contracts/777-toy.md` (`СДАЧА: sdacha.md`), каталог `verdicts/critic/`.

Шаги построения:
1. main: `contracts-777-v3-call-01.md` (accept 01).
2. Ветка side: FAIL 02 (`К-09: блок`) кладётся черновиком ВНЕ каталога — `drafts/krug2.md`.
3. Ветка third от side: посторонний коммит.
4. На side: `merge --no-ff --no-commit third` + `git mv drafts/krug2.md verdicts/critic/contracts-777-v3-krug2-fail.md`. Это evil-merge второй стороны с переименованием в каталог.
5. main: посторонний коммит, затем `merge --no-ff side` — обычное вливание.
6. main: accept 03 (`contracts-777-v3-call-03.md`) и лист без дельты.

Имя FAIL появляется только в diff двух merge-коммитов, ни в одном не-merge коммите:
```
git log --format= --name-only --no-renames --full-history HEAD -- verdicts/critic/ | sort -u   (без -m)
  .keep, contracts-777-v3-call-01.md, contracts-777-v3-call-03.md
… --full-history -m HEAD …  (с -m)
  .keep, contracts-777-v3-call-01.md, contracts-777-v3-call-03.md, contracts-777-v3-krug2-fail.md
```

`bash <W>/scripts/check_sdacha.sh <W> contracts/777-toy.md --run`:
```
OBJECT lib                     rc=1 ОТКАЗ: блок К-09 предыдущего вердикта не закрыт в «## Дельта»
M3b (без -m)                   rc=0 СДАЧА: лист зелёный (двери=1 карта=17/17 дельта=0)    ← ложь
M3a (без --full-history, с -m) rc=1 ОТКАЗ: блок К-09 предыдущего вердикта не закрыт в «## Дельта»
lib 409836ed5d (до 204)        rc=1 ОТКАЗ: блок К-09 предыдущего вердикта не закрыт в «## Дельта»
```

Мой мир различает тот же мутант, что и клетка автора, а батарея этот мутант уже ловит (выше: rc 1 на m1). Значит, класс закрыт, а не только мир автора. Условие блока из задания («твой мир мутант пропускает на батарее») не выполнено.

Граница М3a в SDACHA.md записана честно. На моём мире M3a тоже даёт rc 1. Причина:
- в мире автора и моём, а также ours/addrm/evil вызова 1, при сохранном `-m` имя FAIL выдаётся и без `--full-history`;
- различающего мира я не нашёл;
- снятие обоих флагов (M3c) теперь ловит и батарея 204: `--repo <M3c>` → `m1 KRASNO rc=0 СДАЧА: лист зелёный…`, `ИТОГ 204: rc=1 KLETKI=23 ZELENYE=22 KRASNYE=1`;
- семья 193 ловит M3c тоже (r57, см. §3).

## 3. Регресс (по одному, последовательно; TMPDIR=$PWD/.scratch-rev204s)

```
bash fixtures/workshop_project/karta_vyzova_204/red_karta_vyzova_204.sh --repo .  → ИТОГ 204: rc=0 KLETKI=23 ZELENYE=23 KRASNYE=0     rc=0
bash fixtures/workshop_project/karta_vyzova_204/red_karta_vyzova_204.sh --model   → ИТОГ 204: rc=0 KLETKI=23 ZELENYE=23 KRASNYE=0     rc=0
bash fixtures/workshop_project/karta_vyzova_204/red_karta_vyzova_204.sh --stabs   → ИТОГ 204: rc=0 MUTACII=10 SVJAZI=12 POIMANY=12 ZHIVYH=0  rc=0
bash fixtures/workshop_project/sdacha_193/red_sdacha_193.sh --repo .  → ИТОГ 193: rc=0 KLETKI=152 ZELENYE=152 KRASNYE=0   rc=0 (65 с)
bash fixtures/workshop_project/sdacha_193/red_sdacha_193.sh --model   → ИТОГ 193: rc=0 KLETKI=152 ZELENYE=152 KRASNYE=0   rc=0 (84 с)
bash fixtures/workshop_project/sdacha_193/red_sdacha_193.sh --stabs   → ИТОГ 193: rc=0 OBMANOK=59 POIMANY=59 ZHIVYH=0      rc=0 (189 с)
   (в т.ч. «193 r57-merge-ne-skryvaet-fail-sdacha KRASNO rc=0 …», «193 PATERN:REF-BEZ-FULL-HISTORY POIMAN»)
bash scripts/pre_critic.sh contracts/204-karta-vyzova-po-faze.md     → «КРИТИК: дверь зелёная»   rc=0
bash scripts/check_sdacha.sh "$PWD" contracts/204-karta-vyzova-po-faze.md --run → «СДАЧА: лист зелёный (двери=5 карта=17/17 дельта=0)»  rc=0
```

Прочие мутанты вызова 1 проверены через `--stabs` 204 (каждая связь POIMAN с точным наблюдаемым результатом):

| мутант вызова 1 | стаб | клетка | результат |
|---|---|---|---|
| M1 (усечение фазы до первой цифры) | `PATERN:PERVAJA-CIFRA`, `PATERN:CUT-C1` | `v10-otdelno-ot-v1` | POIMAN rc=0 КАРТА: 17/17 зелёный |
| M2 (захват версии одной цифрой) | `PATERN:REGEX-ODNA-CIFRA` | `f4-vedushchie-nuli` | POIMAN rc=0 СДАЧА: лист зелёный |
| M3c (без обоих флагов) | `PATERN:REF-BEZ-FULL-HISTORY` (193) | r57 | POIMAN; плюс 204 `--repo` M3c → rc 1 (m1) |
| M5 (фаза из прозы СУД) | `PATERN:IZ-SUD` | `g1-bez-versii-kak-v1` | POIMAN rc=0 СДАЧА: лист зелёный |
| M7 (индекс без фазы) | `PATERN:BEZ-FAZY` | a1, v1-fail, f7 | POIMAN (3 связи) |

Счётные утверждения SDACHA.md (23/23/0, 10/12/12/0, 152/152/0, 59/59/0) совпадают с моими прогонами выше.

## ОСТАТОК (НЕ ЗАЩИЩАЕТ контракта 204, ловец reviewer)

- ОСТАТОК: НЗ-1 (смысловая правдивость карты, достаточность, санкции) — не укусил. Дифф добавляет только клетку батареи и стаб, судебных санкций не вводит.
- ОСТАТОК: НЗ-2 (версия имени против СУД-прозы) — не укусил. Новая клетка классифицируется по имени `contracts-777-v3-*`, эвристики прозы в диффе нет, M5 пойман.
- ОСТАТОК: НЗ-3 (иные грамматики, вне critic-каталога) — не укусил. Клетка m1 живёт в `verdicts/critic/`. В моём мире черновик FAIL вне каталога (`drafts/`) по И5 не учитывается, пока не переименован в каталог, — это граница 193.
- ОСТАТОК: НЗ-4 (универсальность конечного набора мутаций, сговор правки батареи с субъектом) — в вызове 1 укусил (Б-1). На OBJECT не укусил:
  - M3b пойман клеткой m1 (`probe.py` m1 / `stabs.tsv:14`);
  - отличный от m1 мир (evil-merge второй стороны с переименованием) различает тот же мутант, класс закрыт;
  - сговора нет: батарею правил architect, lib и контракт относительно c9de3a0f79 не менялись (§1).

## ПРОВОДКА

`guard=fixtures/workshop_project/karta_vyzova_204/red_karta_vyzova_204.sh` не изменён. Он остаётся барьером предмета, подключение по CI-строке вызова 1 не тронуто: `registry/ci-steps.tsv` и `ci.yml` вне диффа. Новая клетка усилила именно эту ветвь guard (И5/И6, `-m`).

## ПАРАЗИТНАЯ СЛОЖНОСТЬ (050)

**Merge-клетка `m1-fail-v-samom-merge`** — поле `Cell.merge_fail`, ветвь `observe` (`probe.py` +13 строк), ожидание `mutant_expected` для `PATERN:BEZ-M`, строка `stabs.tsv`. Идёт одним артефактом семьи клеток.
1. Свойство: И5/И6 — `-m` и стороны merge в обходе имён. Это закрывающее свойство Б-1.
2. Состояние явное:
   - аргумент клетки — кортеж из 4 элементов, по умолчанию пустой, остальные клетки не затрагивает;
   - мир одноразовый в `tempfile`, вывод — строкой `204 m1… ok/KRASNO`.
3. Число файлов при правке того же свойства — `probe.py` + `stabs.tsv` (+ SDACHA.md прозой), как у любой клетки семьи. Не выросло.
4. Глубина: интерфейс батареи прежний — режимы `--repo/--model/--stabs`, rc, новых флагов и env нет; работа — построение merge-топологии git-ом.
5. Потребитель — приёмка 2/3/8 и CI-шаг `check:karta-vyzova-204-family-selftest`. Логику 193 не повторяет: r57 193 кладёт FAIL под путём main и ловит только M3c.

Более простая форма — линейная `history` без merge — не различает M3b, как доказал вызов 1 (22/22 при M3b). Вывод: ESSENTIAL.

**SDACHA.md, раздел «Б-1 Rev204 v1»** — проза сдачи, состояния не вводит, потребитель — critic/reviewer. Вывод: ESSENTIAL как запись границы М3a.

ACCIDENTAL-находок нет.

СВЕРКА-СТАНДАРТОВ: `AGENTS.md` не объявляет документов архитектуры и стандарта кода (`grep -c 'ARCHITECTURE.md\|CODING-STANDARDS.md' AGENTS.md` → 0). `docs/ARCHITECTURE.md` и `docs/CODING-STANDARDS.md` отсутствуют (`ls` → No such file). Сверять дифф не с чем. Дифф — фикстура батареи в существующей форме семьи (dataclass Cell, observe, stabs.tsv) — соответствует сложившейся форме модуля.

СВЕРКА-АРХИТЕКТУРЫ: модели архитектуры у харнесса нет: `harness.project.json` без sourceCanon (`grep -c` → 0), `architecture.lock.json` и `bindings.json` отсутствуют. Находку `finding new` заводить не по чему.
- Размещение: внутри каталога батареи 204.
- Зависимости: только git и python stdlib, новых нет.
- Писатели: только одноразовый мир в tempfile.
- Операции: +1 клетка, +1 стаб.
- bindings: нет.
- Долг не расширен.
- Уровень diff модели — L0.

## Наблюдения (не блок; `.review/2026-11-22-146.md`)

- Н-1. Замеры пачки в приёмках 2/3/8 замороженного контракта расходятся с батареей OBJECT:
  - контракт: `KLETKI=22`, `MUTACII=9 SVJAZI=11 POIMANY=11`, имитация `KLETKI=22 ZELENYE=20`;
  - батарея: 23/23/0 и 10/12/12/0.

  Рост — прямое следствие закрывающего свойства Б-1, его вызов 1 предписал. По Н-39 контракт несёт инварианты и rc-команды, rc-команды выполнены. Не блок.
- Н-2. Мир ревьюера (evil-merge второй стороны с переименованием) в батарею не добавлен и не требуется: он различает только уже пойманный M3b.

## Заметка о среде

Мутанты и мир жили в `$PWD/.scratch-rev204s` по одному и удалялись сразу. Перед докладом scratch удалён. Push не делался.
