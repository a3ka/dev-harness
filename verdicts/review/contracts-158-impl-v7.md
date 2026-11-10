FAIL
OBJECT=b7c08e926b2ce961d2fbf3191d8a1f58b4b43767
КЛАСС=КОДОВЫЙ (КЛАСС РИСКА: обычный; ТРЕК набора: ПОЛНЫЙ)
СУД: repo=dev-harness; предмет=158; фаза=реализация (перелэнд r7 по frozen/contracts/158/4; PR #697); роль=reviewer; вызов=7 (предмет до 2026-10-24 — прежний порядок, предел вызовов не применяется; маршрут арбитража verdicts/arbitration/158-ikonka-b7-b8.md шаг 5); модель-план=anthropic/claude-opus-5-5; сессия=Rev158v7; модель-факт=anthropic/claude-opus-5-5; SHA=b7c08e926b2ce961d2fbf3191d8a1f58b4b43767 (tip wip/158/implementer-r7); предыдущий=verdicts/review/contracts-158-impl-v4.md (FAIL @2089cede); исключение=нет
НЕЗАВИСИМОСТЬ: автор OBJECT — implementer (4 коммита, minimax/MiniMax-M3); судья — reviewer, кода не правил; мутанты — в одноразовом worktree клона вне дерева, восстановлен (status пуст).
НАХОДКИ: в тексте вердикта (каталог .review/ вне зоны reviewer по ЗОНА 158). Блок Б-10 (implementer). Закрыты Б-8, Б-9, С-15, С-16, С-7. Советы: С-13 (повтор), С-17 (повтор), С-18 (architect), С-19 (architect).

## Вердикт

FAIL по одному блоку — Б-10. Всё, что требовал маршрут арбитража, сделано и подтверждено
моими прогонами: Б-8 и Б-9 закрыты, С-15 и С-16 закрыты клетками, которые ловят мои мутанты.
Все пять режимов W дали rc 0 на OBJECT.

**Б-10 (адресат implementer; область правки, норма 1, и контракт 050).** Четвёртый коммит
`b7c08e92` («корень референса станции — переменная окружения») выходит за объявленные границы
и вводит скрытое состояние, которого не требует ни одно свойство frozen 158/4.

- Граница. Маршрут арбитража, шаг 4: «перелэндит … ровно тремя коммитами … Основа —
  содержимое 2089cede, нового кода только на С-15/С-16». Задание implementer
  `/tmp/dev-harness-verify/orch/task-158-impl-refs.md`, шаг 2, разрешает новые коммиты только
  при условии «Если красная клетка — реальный дефект реализации в твоей зоне, ИСПРАВЬ его».
  Отсутствие референсов там же названо «ПРЕДПОСЫЛКА прогона, не дефект реализации».
  Сообщение коммита это подтверждает: «предпосылка, а не дефект батареи».
- Фрагмент. `fixtures/workshop_project/ekrannyj_nabor_158/probe.py:132-139`
  (`os.environ.get('NABOR_158_REF_CLEAN')`, `os.environ.get('NABOR_158_MOB_REF')`),
  докстринг `:31-38`, `nositeli/ref-clean-provennost.md:36-40`.
- Отсутствующее свойство. Во frozen 158/4 этого свойства нет. Контракт §Существующее
  называет корни станции `/tmp/dev-harness-verify/Arch147t/ref-clean` и
  `/tmp/dev-harness-verify/Arch148t/mob-ref`. SPEC §4 задаёт `istochnik` карты как этот путь;
  `model/karta-ref-clean.json:3` и `model/karta-mob-ref.json:3` его несут. Если корня нет —
  rc 2 LIVE_PREDPOSYLKA. Переменная скрыта: корень станции не печатается, кроме случая
  отсутствия (`probe.py:1919`, `:2084`). Через `istochnik_ref_clean()` и
  `stanciya_obrazca()` от неё зависят c05, f03–f39 и при `--repo mob-ref`, и при
  `--repo ref-clean`. Замер D-1 (ниже): с
  `NABOR_158_REF_CLEAN=/tmp/dev-harness-verify/Impl158Refs2/ref-clean` d01 молча даёт
  `{"rc": 0, "pri": [], "mark": []}`, а карта по-прежнему объявляет `istochnik` Arch147t.
  Вывод прогона не позволяет понять, какой референс судился.
- Более простая форма. Константы корней — код `4087b83b` (коммит C) плюс восстановление
  референсов по носителю происхождения на канонических путях. Она проходит те же строки
  приёмки: все мои прогоны ниже шли без переменных (`env | grep -c '^NABOR_158'` → 0), то есть
  по каноническим путям, и дали rc 0 во всех пяти режимах.
- Что закрывает. Убрать переопределение из `probe.py`: revert `b7c08e92` либо правка
  `REFERENSI` обратно к константам. Носитель `nositeli/ref-clean-provennost.md` можно оставить
  без абзаца про переменную. Без переменных путь исполнения совпадает с тем, что прогнано
  здесь. Повторный суд можно ограничить диффом: `git diff 4087b83b <новый tip> --
  fixtures/workshop_project/ekrannyj_nabor_158/probe.py` пуст, носитель без env.

СВЕРКА-СТАНДАРТОВ: не применимо — дифф в харнесе dev-harness (fixtures/ + scripts/).
Документов docs/ARCHITECTURE.md / docs/CODING-STANDARDS.md продуктового бэкенда он не касается.
Референсы mob-ref/ref-clean и клон Complior-mob только читались.

ПРОВОДКА (038): guard `fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh`
— дверь именно этого предмета, побайтово равна тегу 158/4 (rc 0 ниже). CI-шаг 158 не
подключён: grep `ekrannyj_nabor_158` по `registry/`, `.github/` → 0 строк. По маршруту
(шаг 6) и контракту это окно оркестратора freeze..done, к блоку реализации не относится.

## Пункты задания и маршрута (шаг 5) — сырой вывод

cwd `/tmp/dev-harness-verify/Rev158v7/repo` (клон `ssh://git@github.com/a3ka/dev-harness.git`,
HEAD = FETCH_HEAD = OBJECT), W = `bash fixtures/workshop_project/ekrannyj_nabor_158/red_ekrannyj_nabor_158.sh`.

### (1) frozen 158/4 существует и покрывает Б-7/Б-8

```text
$ git fetch origin wip/158/implementer-r7; git rev-parse FETCH_HEAD   → b7c08e926b2ce961d2fbf3191d8a1f58b4b43767
$ git rev-parse 'frozen/contracts/158/3^{commit}' 'frozen/contracts/158/4^{commit}'  → 033c3fa9…, bcd5b796…
$ git diff --stat 158/3 158/4 -- contracts/158-ekrannyj-nabor.md   → 1 file, +5 −4 (Иконка живого mob-ref; И-1(г) четыре условия; И-2; п.2 приёмки; Демаркация)
$ git diff --stat 158/3 158/4 -- …/SPEC.md                          → 1 file, +14 −2 (§4 вид цели; §5 a11yNadpis; §6A a14; §6F f34–f39; §7 st14→f36–f39)
blob контракт/SPEC/дверь на e2a38742 = 1e46ddda = тег 158/4: 955a49e6 / b38a0754 / 72a6cc9b
verdicts/critic/contracts-158-v4.md: «accept», OBJECT=e2a38742 (scoped, арбитраж шаг 3)
$ git diff --quiet 'frozen/contracts/158/4^{commit}' HEAD -- contracts/158-ekrannyj-nabor.md …/SPEC.md …/red_ekrannyj_nabor_158.sh → rc 0
$ (то же против origin/main 18544ce8) → rc 0
```

Код против четырёх условий И-1(г) (`zond/helpery.ts:369-389`): (i) непустой после trim Text в
поддереве хозяина, видимый или невидимый → `KARTA_NADPIS_NE_SOVPALA` (`tekstySoderzhaniem`, без
проверки видимости); (ii) поле не объявлено → `A11Y_IMJA_NE_OBYAVLENO`; (iii) пусто после trim →
`A11Y_IMJA_PUSTOE`; (iv) `accessibilityLabel` самого хозяина отсутствует или `!==` объявленному
→ `NADPIS_NEVIDIMA`. Порядок совпадает с SPEC §5. Б-8 закрыт.

### (2) Атомарность r7 (Б-9)

```text
$ git log origin/main..HEAD
1c017a3c implementer  158: батарея ekrannyj_nabor_158 по SPEC 158/4 — без ветки цели-иконки   (63 файла, каталог набора)
6c280bed implementer  158: гейт трека экрана и нога (д3) двери критика — одним коммитом         (scripts/check_trek_ekrana.sh, scripts/pre_critic.sh)
4087b83b implementer  158: ветка цели-иконки — a11yNadpis …, клетки f34–f39, st14, мутаторы     (10 файлов)
b7c08e92 implementer  158: корень референса станции — переменная окружения …                    (2 файла) ← Б-10
$ git merge-base --is-ancestor 8ce8808a b7c08e92 → rc 0   (8ce8808a «revert 158 implementer v3 land (71551fb1 -m 1)» — шаг 1 маршрута)
отдельный откат на OBJECT (одноразовый worktree):
  git revert --no-commit b7c08e92 → rc=0 unmerged=0 changed=2
  git revert --no-commit 4087b83b → rc=0 unmerged=0 changed=10
  git revert --no-commit 6c280bed → rc=0 unmerged=0 changed=2
$ git diff --quiet 2089cede HEAD -- scripts/pre_critic.sh scripts/check_trek_ekrana.sh → rc 0 (B = основа 2089cede)
$ git merge-tree --write-tree origin/main HEAD → rc 0 (384e4d37; main ушёл на 11 коммитов, пути набора не задеты)
```

Красное п.1 на коммите A (worktree `1c017a3c`, мой прогон):

```text
$ W   (@1c017a3c)
CASE z01-gate-v-dereve KRASNO: ожидался rc=0, факт rc=2 (причины факта: SUBJECT_ABSENT: scripts/check_trek_ekrana.sh в дереве отсутствует)
CASE z02-noga-pre-critic KRASNO: ожидался rc=0, факт rc=2 (причины факта: SUBJECT_ABSENT: нога (д3) — вызова check_trek_ekrana.sh — нет)
клеток 40, зелёных 38, красных 2
wall 451.84 s   rc=1
```

Красное до C: клетки ветки на HEAD против зонда коммита B (`git checkout 6c280bed -- zond`, пины
переопечатаны в одноразовой копии):

```text
f34 KRASNO: нет причины NADPIS_NEVIDIMA (факт: NADPIS_NULL_NE_PODDERZHAN)
f35…f39 KRASNO: … (факт: КОНТРОЛЬ С ИСХОДНОЙ КАРТОЙ НЕ ЗЕЛЁНЫЙ: rc=1)  — трасса: ZOND shell-profile-entry 390|393 KRASNO NADPIS_NULL_NE_PODDERZHAN
wall 38.03 s
```

Совпадает с заявлением в сообщении коммита 4087b83b. Б-9 закрыт: три задачи маршрута лежат
тремя коммитами, каждый откатывается отдельно. Четвёртый коммит атомарен, но выходит за
маршрут (Б-10).

### (3) Приёмка SPEC 158/4 (референсы на канонических путях, env NABOR_158_* не задан)

Референсы: `/tmp/dev-harness-verify/Arch147t/ref-clean` (HEAD cc38881a, tab-shell.tsx sha256
afcd8ee7… = носитель 147; tokens.json cb39fb94… = kompakt11) и
`/tmp/dev-harness-verify/Arch148t/mob-ref` (HEAD 6b5ef760, tokens.json cb39fb94…). Оба совпадают
с `nositeli/*-provennost.md`, node_modules — симлинк на Impl158Refs2/install.

```text
$ W                                   → rc=0; «клеток 40, зелёных 40, красных 0» (wall 399.26 s)
$ W --model                           → rc=0; «клеток 37, зелёных 37, красных 0» (wall 386.10 s)
$ W --stabs                           → rc=0; «клеток 37, зелёных 37, красных 0»; 14 строк «STAB <файл> KRASEN»; «SVJAZI 30» (wall 542.47 s)
      PROSHYOL: st03→b07, st06→e01 (каждый стаб пойман хотя бы на одном своём входе — SPEC §7)
      STAB st14-zond-bez-a11y.py f36 KRASEN, f37 KRASEN, f38 KRASEN, f39 KRASEN
$ W --repo /tmp/dev-harness-verify/Arch148t/mob-ref   → rc=0; «клеток 80, зелёных 80, красных 0» (wall 717.30 s); c05, d01, f00–f02, f34–f39, g08 ok
$ W --repo /tmp/dev-harness-verify/Arch147t/ref-clean → rc=0; «клеток 80, зелёных 80, красных 0» (wall 658.08 s)
$ W --oracle-tamper                   → rc=2; «ORACLE_TAMPERED: ORAKUL_PIN:NE_SOVPAL:nositeli/e2e-147.sh»
$ W --nesuschestvujuschij             → rc=2; «probe.py: error: unrecognized arguments»
$ bash scripts/check_trek_ekrana.sh . contracts/158-ekrannyj-nabor.md → rc 0, «ТРЕК ЛЁГКИЙ (по умолчанию)»
```

Счёты двумя мерами (вторая мера — source.json и самоописание, не вывод батареи):

```text
$ python3 (source.json): vsego 80; F 39; bez_F_c05 40; семьи a14 z2 b7 c5 d3 e2 f39 g8; stab 14; svjazi 30; st14 → f36,f37,f38,f39
$ python3 samoopisanie/samoopisanie.py → {"kletok": 80, "nositelej": 46, "piny": 7, …, "stabov": 14, "svjazej": 30} rc 0
$ grep лог --stabs: строк «STAB <файл> KRASEN» = 14; строк связей (KRASEN|PROSHYOL) = 30
перепись SPEC ↔ source.json: spec 80, oracle 80, вне SPEC [], нет в оракуле []; стабы 14 = 14, расхождений нет (С-7 закрыт: a14 в SPEC §6A)
--model 37 = 40 − {z01, z02, g08}
```

Прежние замеры (W 40, --model 37, --repo 78, SVJAZI 29) изменились ровно на дельту SPEC 158/4:
+f38, +f39 (78 → 80) и st14 f34,f36,f37 → f36–f39 (29 → 30).

### Мутанты ветки иконки (маршрут: HZ1–HZ4 и Z7 пойманы своими клетками)

Мутанты хелпера в одноразовом worktree OBJECT, пин `zond/helpery.ts` в source.json копии
переопечатан. Клетки f00, f34–f39 на mob-ref:

```text
базовый (без мутации): f00 ok, f34–f39 ok  (wall 84.42 s)
M1 = HZ3/С-15 (`imya !== obyavlenie` → `false`):  f38 KRASNO «ОЖИДАЛАСЬ ПРИЧИНА NADPIS_NEVIDIMA, ФАКТ: —» — ПОЙМАН; прочие ok
M2 = Z7/С-16 (Text считается, только если виден):  f39 KRASNO «ОЖИДАЛАСЬ ПРИЧИНА KARTA_NADPIS_NE_SOVPALA, ФАКТ: —» — ПОЙМАН; прочие ok
M3 (сравнение имён после trim):                  f00, f34–f39 ok — ЖИВ (С-18)
M4 (имя берётся у первого потомка с именем):     f00, f34–f39 ok — ЖИВ (С-19)
```

HZ1, HZ2, HZ4 судились в вызове 6 (код ветвей (i)–(iii) не изменился, кроме (i), а его ловит
M2). Клетки f35–f37 на базе зелёны с нужными причинами: f35 KARTA_NADPIS_NE_SOVPALA, f36
A11Y_IMJA_NE_OBYAVLENO, f37 A11Y_IMJA_PUSTOE. С-15 и С-16 закрыты.

### (4) frozen-diff неизменности

```text
$ git diff --quiet 4eeb2aff HEAD -- contracts/ fixtures/workshop_project/{gespraech_vhod_147,vkladki_tabov_148,gespraech_tekst_149,gespraech_otdacha_151,mob_ci_143,pustoj_produkt_159} scripts/sverka_maketa.py scripts/ekran_shablon.py scripts/check_pustoj_produkt.sh → rc 0
$ git diff --name-only 4eeb2aff HEAD | wc -l → 71; вне каталога набора — scripts/check_trek_ekrana.sh, scripts/pre_critic.sh; изменён (M) только scripts/pre_critic.sh; SPEC.md и дверь не тронуты
```

### (5) Находки .review/2026-11-09-94.md

- Б-8 — закрыт (п.1, мутанты).
- Б-9 — закрыт (п.2).
- С-15 — закрыт: клетка f38, M1 пойман.
- С-16 — закрыт: клетка f39 с парным контролем, M2 пойман.
- С-17 — открыт (совет, implementer): `zond/nabor-zond-158.test.tsx:137` по-прежнему ставит
  `A11Y_IMJA_PUSTOE` для пустой `nadpis` текстовой цели. По арбитражу это не блок.
- С-13 — открыт (совет): `nositeli/mob-ref-provennost.md` ссылается на рецепты
  `/tmp/dev-harness-verify/scratch158/…`. `ls /tmp/dev-harness-verify/scratch158/` → «No such
  file or directory»: рецепт пропал вместе с перезагрузкой. Новый `ref-clean-provennost.md`
  описывает сборку таблицей в дереве, это правильный образец; mob-ref стоит довести до того же.
- С-7 — закрыт (a14 в SPEC 158/4 §6A).
- С-1, С-8 (architect) — вне дельты маршрута, не переоткрываю.
- О-1 — закрыт revert'ом 8ce8808a.

### (6) Зоны — scoped (lib_zones), полный check_zones не запускался

```text
$ git fetch --tags origin
$ /bin/bash zones_scoped.sh <клон> 1c017a3c 6c280bed 4087b83b b7c08e92   (source scripts/lib_zones.sh; zones_load; zones_match_path по автору коммита)
zones_load rc=0
ЗОНА 158: implementer fixtures/workshop_project/ekrannyj_nabor_158/ · scripts/check_trek_ekrana.sh · scripts/pre_critic.sh; architect contracts/158-…, …/SPEC.md, …/red_ekrannyj_nabor_158.sh; reviewer verdicts/review/
provereno=77 vne_zony=0   rc=0
```

(Встроенный `sed` оболочки инструмента ломает `registry_state`: там выходит missing-remote.
Поэтому прогон шёл под `/bin/bash`; об этом есть QA-отчёт.)

### (7) CI PR #697

```text
$ gh pr view 697 → OPEN, head wip/158/implementer-r7 @ b7c08e926b2ce961d2fbf3191d8a1f58b4b43767
$ gh api …/commits/b7c08e92…/check-runs → run 42904806466: 16 success (tyazhelyj-itog, ci l1–l7, antiplacebo ap1–ap5, obshchij, klass, legkij), 1 skipped (vorota) — зелёный
CI батарею 158 не гоняет (CI-шаг 158 — окно оркестратора).
```

## Советы

- [ ] **С-18 (architect, SPEC §6F).** Ни одна клетка не держит «сравнение без trim» из И-1(г).
  Мутант M3 (`imya.trim() !== obyavlenie.trim()`) проходит f00 и f34–f39. Сам код сравнивает
  без trim. Нужна клетка, где имя хозяина отличается от объявленного только пробелом в конце.
  Это прежний R2 вызова 6.
- [ ] **С-19 (architect, SPEC §6F).** «Дочернее имя не заменяет имя хозяина» (И-1(г)) не
  держит ни одна клетка. Мутант M4 (имя берётся у первого потомка) проходит f00 и f34–f39. Сам
  код читает `svojstva(hozjain)`. Нужна клетка, где имя перенесено с хозяина на дочерний Svg.
  Это прежний R1 вызова 6.

Оба совета относятся к SPEC (Н-39: клетки к ветвям привязывает architect) и реализацию не
блокируют.

## Паразитная сложность (контракт 050) — дельта 2089cede → r7

Пять вопросов: (1) свойство; (2) состояние; (3) файлы, меняющиеся вместе; (4) глубина; (5) потребитель.

- `tekstySoderzhaniem(uzel)` и переписанная `a11yNadpis` (`zond/helpery.ts:340-389`).
  (1) И-1(г) 158/4: «в поддереве интерактивного хозяина НЕТ Text с непустым после trim
  содержимым, видимого или невидимого». (2) Состояние явное: поля карты
  `nadpis`/`accessibilityLabel`, причина попадает в трассу `ZOND … KRASNO <ПРИЧИНА>`. (3)
  helpery.ts, nabor-zond-158.test.tsx, probe.py (имена причин) и пин в source.json — как в
  2089cede, число не выросло. (4) Одна функция, четыре ветви в порядке SPEC §5, интерфейс не
  вырос. (5) f34–f39, st14. ESSENTIAL: более простая форма (только видимые строки, код
  2089cede) не проходит f39 — это мутант M2.
- `k_f38`, `k_f39` и `a11y_obrazec` с несколькими фазами (`probe.py:2735-2865`); мутаторы
  `model/mutanty/profil-a11y-ne-sovpala.py`, `profil-nevidimyj-text.py`. (1) SPEC 158/4 §6F f38,
  f39. (2) Состояние явное: фазы передаются аргументом, ожидание держится в памяти, контроль
  идёт до мутации на каждой фазе. (3) Каждый новый образец — мутатор, строка оракула и строки
  KLETKI/STANCIYA_OBRAZTSA/KLETKI_FUNK. (4) Модуль глубокий: один интерфейс фаз на шесть
  клеток. (5) Строки оракула f38, f39. ESSENTIAL.
- `stubs/st14-zond-bez-a11y.py` (одна якорная замена). (1) SPEC §7 st14 → f36–f39. ESSENTIAL.
- `REFERENSI` с `os.environ.get('NABOR_158_REF_CLEAN' | 'NABOR_158_MOB_REF')`
  (`probe.py:132-139`, докстринг `:31-38`, `nositeli/ref-clean-provennost.md:36-40`). (1)
  Во frozen 158/4 свойства нет (см. Б-10). (2) Состояние скрытое: две новые читаемые
  env-переменные, корень в выводе не печатается. (3) Число мест выросло: путь станции теперь
  живёт в коде, в карте (`istochnik`) и в env. (4) Интерфейс вырос на две env, функциональность
  — нет. (5) Потребителя в строке приёмки или шаге CI нет: grep `NABOR_158_REF_CLEAN|NABOR_158_MOB_REF`
  по `.github/`, `registry/`, `scripts/` → 0. ACCIDENTAL. Фрагмент, отсутствующее свойство и
  более простая форма названы — блок Б-10.
- `nositeli/ref-clean-provennost.md` (кроме абзаца про env). Носитель происхождения, пара к
  `mob-ref-provennost.md`. Состояния не вводит, хэши в нём совпали с моим замером.
  Находки нет.

## Замер D-1 (Б-10)

```text
$ NABOR_158_REF_CLEAN=/tmp/dev-harness-verify/Impl158Refs2/ref-clean python3 -c '… probe.REFERENSI[0][1]; probe.istochnik_ref_clean(); zapustit_kletku("d01-karty-polny", …) …'
REFERENSI[0]= /tmp/dev-harness-verify/Impl158Refs2/ref-clean
istochnik_ref_clean()= /tmp/dev-harness-verify/Impl158Refs2/ref-clean
d01 {"rc": 0, "pri": [], "mark": []} sudit= []
rc=0
$ grep istochnik model/karta-ref-clean.json → "istochnik": "/tmp/dev-harness-verify/Arch147t/ref-clean"
```
