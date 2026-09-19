# Вердикт adversary — контракт 033 v3, пост-v2

**ACCEPT.** Два блокирующих корня к2 `348b108` закрыты на `bbe0d4d68ba695bd2ae920131b1873fff3145bdd`: probe-only каталоги больше не делают scoped-приёмку 033 ложнокрасной, а гвард замера имеет исполненный известный ответ и ловит ровно подмену ветки на `.`. Замороженный текст `033/2` не менялся.

## Провенанс и границы

Проверка выполнена в отдельном клоне, созданном ровно по назначенному маршруту:

```text
$ git clone /home/aka/Documents/dev-harness /tmp/dev-harness-verify/adv-033-k3/repo
$ git rev-parse HEAD
bbe0d4d68ba695bd2ae920131b1873fff3145bdd
```

Основной checkout, ветки и worktree не изменялись. Полный CI намеренно не запускался: по назначению это CI-прогон, а его зелёное состояние 6/6 на `bbe0d4d` дано контекстом задания. В ходе первых параллельных запусков двух экземпляров `check_zones` столкнулись временные каталоги `lib_zones` и оба дали ложный rc 1 (`cp: cannot stat .../zones_scoped`). Эти результаты отброшены; все нижеуказанные приёмочные вызовы `check_zones` выполнены последовательно и получили устойчивый результат.

## Замороженная приёмка 033/2 — собственные прогоны

### 1. Scoped-регресс семьи 033

```text
$ VERIFY_ANTIPLACEBO_SCRATCH=/tmp/dev-harness-verify/adv-033-k3/scratch-scoped-rerun \
    bash scripts/verify_antiplacebo.sh --scope check_zones
SCOPED: барьеров 1 из выборки — не для приёмки
  ok   check_zones/case_avtor_s_tabuljaciej.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «табуляцию»
  ok   check_zones/case_chuzhoe_okno_ne_suditsja.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «коммит вне зоны»
  ok   check_zones/case_done_diapazony_neizmenny.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «коммит вне зоны»
  ok   check_zones/case_draft_priznanie.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «коммит вне зоны»
  ok   check_zones/case_dver_minta_priznanie.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «дверь минта 031: дельта манифеста не только-добавление»
  ok   check_zones/case_kommit_vne_zony.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «коммит вне зоны»
  ok   check_zones/case_konec_diapazona_done.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «коммит вне зоны»
  ok   check_zones/case_ni_zon_ni_otkaza.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «ни зон, ни отказа от раздачи»
  ok   check_zones/case_otkaz_bez_prichiny.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «причина пуста»
  ok   check_zones/case_prjamoj_kommit_objavlennogo_avtora.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «коммит вне зоны»
  ok   check_zones/case_protsessnye_vne_suda.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «коммит вне зоны»
  ok   check_zones/case_put_s_kavychkami.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «кавычку»
  ok   check_zones/case_reestr_nedostupen.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «реестр заморозок»
  ok   check_zones/case_regress_posledovatel_naja_istorija.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «коммит вне зоны»
  ok   check_zones/case_spaseno_ne_nazvannyj_hash.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «коммит вне зоны»
  ok   check_zones/case_spaseno_vne_grammatiki.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «СПАСЕНО вне объявленной грамматики»
  ok   check_zones/case_svoja_merge_delta_suditsja.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «коммит вне зоны»
  ok   check_zones/case_union_zon_vseh_zamorozok.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «коммит вне зоны»
  ok   check_zones/case_zona_vne_grammatiki.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «вне объявленной грамматики»
  ok   check_zones/case_zones_critic_v_others.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «коммит вне зоны»
  ok   check_zones/case_zony_drugogo_kontrakta.sh: зелёный контроль есть, повторный прогон красный кодом 1 — «коммит вне зоны»

барьеров: 1 · фикстур: 21 · предъявлено красным повторным прогоном: 21
[rc 0]
```

Тем самым исходная Б1-краснота `fixtures/qa_kanal_xd` и `fixtures/workshop_inventory` не возвращается до исполнения выбранной семьи.

### 2. Живой замер и гвард-1 v2

```text
$ bash scripts/check_zones.sh .
...
замороженных контрактов: 32 · объявленных авторов: 3 · коммитов в диапазонах: 1245 · проверено по зонам: 792
[rc 0]

$ n="$(bash scripts/check_zones.sh . 2>&1 | sed -n 's/.*проверено по зонам: \([0-9][0-9]*\).*/\1/p')"; test -n "$n" && test "$n" -gt 0
N=792
rc=0
```

Обе записанные пустые ветви проверены тем же предикатом, не только чтением текста:

```text
$ # пустой диапазон: ... коммитов в диапазонах: 0 · проверено по зонам: 0
N=0
rc=1

$ # ноль объявленных зон: «замороженных контрактов: 0 · зон не объявлено — проверять нечего»
N=
rc=1
```

### 3. Заморозка и неизменность frozen-барьера

```text
$ git show-ref --verify refs/tags/frozen/contracts/033/2 && \
  test "$(git for-each-ref --format='%(objecttype)' refs/tags/frozen/contracts/033/2)" = tag && \
  test "$(git rev-parse frozen/contracts/033/2:contracts/033-union-semantika-zon-check-zones.md)" = \
       "$(git hash-object contracts/033-union-semantika-zon-check-zones.md)"
134b7db80f79b971c604b0539d795360b6c07dbc refs/tags/frozen/contracts/033/2
[rc 0]

$ git diff --exit-code frozen/contracts/033/2 HEAD -- contracts/033-*.md
[rc 0]
```

Команда `Закрытие-Н-100-проверка` на этом пред-done дереве закономерно даёт rc 1 без вывода: последняя backtick-группа Н-100 пока `КОД ЗАКРЫТ ... / СУДЕЙСКАЯ ФОРМАЛИЗАЦИЯ ОТКРЫТА`, а не финальный токен 033. Это не дефект корней Б1/Б2 и не выдаётся за зелёный результат: её условие должно быть выполнено оркестратором при переходе `accept → done/033`.

## Исполненные атаки на закрытия 034

### Б1 — probe-only класс и нейтрализация

Положительный контроль и границы текущего раннера:

```text
$ bash fixtures/verify_antiplacebo_probe/red_katalog_ne_flagaetsa.sh
ворота 1 (полный): rc 0 — probe-only каталог не флагается
ворота 2 (scoped): rc 0 — посторонний probe-каталог не красит scoped семьи
ворота 3 (--changed): rc 0 — правка probe-only ничего не выбирает у барьеров
ворота 4 (к1-Б1): нулевая выборка не легализует нелегальный каталог — rc 1
ворота 5 (к1-Б2): нуль выбора наблюдаем — селектор needs-full/2 без KEY, раннер MODE: none без case
[rc 0]

$ bash fixtures/verify_antiplacebo_probe/red_granicy_klassa.sh
ворота 1: case-каталог без барьера флагается — не ослабление
ворота 2: probe-only каталог с case_* флагается — роль каталога одна
ворота 3: маркер в барьерном каталоге флагается — противоречие не молчит
[rc 0]
```

Отдельно построен неверный нейтрализованный двойник: в копии единственный `scripts/verify_antiplacebo.sh` заменён на `exit 0`. Это реализация, которая ошибочно принимает и легальный probe-only, и нелегальный каталог. Проверка не приняла её:

```text
$ bash fixtures/verify_antiplacebo_probe/red_katalog_ne_flagaetsa.sh
ворота 1 (полный): rc 0 — probe-only каталог не флагается
ворота 2 (scoped): rc 0 — посторонний probe-каталог не красит scoped семьи
ворота 3 (--changed): rc 0 — правка probe-only ничего не выбирает у барьеров
ОТКАЗ: ворота 4 — rc 0
[rc 1]
```

Именно ворота 4 различают годную ветвь и нейтрализованный отказ: ожидают rc 1 и именованный `FAIL fixtures/stranaja`, а не просто зелёный запуск.

### Б2 — выполненная подмена счётчика на `.`

```text
$ bash fixtures/check_zones/red_zamer_podstavnoj_schetchik.sh
ворота 1: живое дерево rc 0, проверено по зонам: 792 — непустота держится
ворота 2: toy K=3, счётчик 3 == известному ответу
ворота 3: старый N>0-гвард ПРИНИМАЕТ подмену (N=1>0) — плацебо показано исполнением
ворота 4: известный ответ 5 ≠ подменённый 1 — гвард КРАСЕН: подставной счётчик
ворота 5: на абсолютном корне подмена честна (счётчик 5) — дефект наблюдаем ровно на «.»
[rc 0]
```

Это не текстовая декларация: предъявление само строит K=3 и K=5 toy-деревья, затем исполняет дословную к2-подмену — раннюю ветку `if [ "${1:-}" = "." ]`, константу `проверено по зонам: 1`, rc 0. Старый N>0 предикат действительно её принимает на воротах 3; известный ответ текущего гварда отвергает её на воротах 4. Ворота 2 — честный положительный контроль, ворота 5 локализуют ветку именно на приёмочной форме `.`.

### Инструмент вне PATH

Команда предмета не считает отсутствие инструментария успехом:

```text
$ env PATH=/nonexistent /bin/bash scripts/check_zones.sh .
scripts/check_zones.sh: line 68: dirname: command not found
scripts/check_zones.sh: line 68: cd: null directory
[rc 1]

$ env PATH=/nonexistent /bin/bash fixtures/check_zones/red_zamer_podstavnoj_schetchik.sh
...
NOT_IMPLEMENTED: нет git
[rc 2]
```

Следовательно, отсутствующий инструмент не даёт ложного rc 0 ни барьеру, ни предъявлению.

## Детектор 024

```text
$ bash scripts/check_no_leak.sh --check /home/aka/Documents/dev-harness
основной чекаут чист
[rc 0]
```

## Решение

Принять 033/v2 после 034. Б1 закрыта исполнением probe-only класса в полном, scoped и `--changed` режимах с fail-closed нулевой выборкой; Б2 закрыта известным ответом, который на живо исполненной к2-подмене различает `K=5` и константу `1`. Очередь: `done/033`, затем 030/031. Приземление полного текста — оркестратором в `verdicts/adversary/contracts-033-v3.md` с `user.name=adversary`; текущие main/worktree/ветки данным судом не менялись.
