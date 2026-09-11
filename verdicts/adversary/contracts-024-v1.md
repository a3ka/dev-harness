FAIL

# Адверсарий: контракт 024, круг 3

Судимая база: `main` `d1ef0ec41ddea1ed7f4fc07dd739345dc6d07d21`,
`frozen/contracts/024/2 = 01ed097b8155b604ccbe838d0d4b0807667c71c1` (предковый).
HEAD включает фикс-коммит `04ba744` (PATH-подделка sha256sum и symlink-подмена
снимка) после `b73cb7a`. Все мутации и репро ниже сделаны только в одноразовых
клонах под `/tmp/dev-harness-verify/adv024k3-attack/...`; основной checkout
менялся только этим вердиктом. Н-39 дословно: «стабы к ветвям привязывает
architect по коду, НЕ проза контракта; контракт несёт инварианты + rc-команды».

## Перепроверка контрпримеров круга 2

Оба контрпримера к2 (с `01ed097`) проверены против текущего `scripts/check_no_leak.sh`
(фикс `04ba744` слит в `b73cb7a`).

### `S-path-forged-sha256` — закрыт фиксом

Поддельная `sha256sum` в `/tmp/dev-harness-verify/adv024k3-attack/fake-bin/`
возвращает константный `0000…0000`. Детектор пин-резолвит sha256sum через
`TRUSTED_PATH=/usr/bin:/bin:/usr/local/bin` и валидирует sanity-хэшем пустого
ввода (`e3b0c442…`). Подмена вне доверенных путей не достигает вызова.
Исполнено (одноразовый клон, те же имена, что в к2):

```text
PATH=/tmp/dev-harness-verify/adv024k3-attack/fake-bin:/usr/bin:/bin \
TMPDIR=/tmp/dev-harness-verify/adv024k3-attack/round2-verify \
  bash scripts/check_no_leak.sh --snapshot $REPO                 # rc=0
PATH=/tmp/dev-harness-verify/adv024k3-attack/fake-bin:/usr/bin:/bin \
TMPDIR=/tmp/dev-harness-verify/adv024k3-attack/round2-verify \
  bash scripts/check_no_leak.sh --check    $REPO                 # rc=1 «ОТКАЗ:
                                                                #   основной чекаут
                                                                #   загрязнён:
                                                                #   extra-leak-round2»
```

Снимок содержит реальный sha256 утечки (не подставной), дельта на сверке пуста
не потому, что манифесты равны, а потому что новый untracked-путь отсутствовал
в базе. Закрытие фикса подтверждено именованным rc=1.

### `S-external-snapshot-symlink` — закрыт фиксом

Подмена `$SNAP` симлинком на другой снимок того же корня. Детектор делает
`[ -L "$SNAP" ]` ДО чтения и отвергает с `ОТКАЗ: снимок — симлинк: <путь> — replacement через симлинк недопустим (ЗАЩИТА-СНИМКА к2 адверсария)`, rc=1. Также
проверяется `$SNAP_DIR` на симлинк. Исполнено:

```text
mv /tmp/.../symlink-a/dev-harness-leak/916ae6db/porcelain \
   /tmp/.../symlink-a/dev-harness-leak/916ae6db/porcelain-base
ln -s /tmp/.../symlink-b/dev-harness-leak/916ae6db/porcelain \
      /tmp/.../symlink-a/dev-harness-leak/916ae6db/porcelain
TMPDIR=/tmp/.../symlink-a \
  bash scripts/check_no_leak.sh --check $REPO                    # rc=1 «ОТКАЗ:
                                                                #   снимок — симлинк»
```

Закрытие фикса подтверждено именованным rc=1.

## Контрпримеры круга 3 — атака на сам фикс

### Блокер 1 — `S-path-fake-git-clean`: поддельный `git` на PATH делает манифест пустым ⇒ дельта пуста ⇒ «чисто»

Фикс пин-резолвит ТОЛЬКО `sha256sum` (`TRUSTED_PATH`-only + sanity-хэш пустого
ввода). `git`, `sort`, `comm`, `mkdir`, `mktemp` — резолвятся через полный PATH,
и комментарий фикса (`scripts/check_no_leak.sh:131-149`) утверждает:
«Подмена git/sort/comm НЕ даёт «чистого» обхода: git status возвращает rc≠0 →
ловится превентив 1 (манифест не прочитан)». Утверждение неверно: поддельный
`git`, возвращающий rc=0 и пустой stdout на `status --porcelain`, проходит
превентив 1 (статус «успешен»), emit_manifest выдаёт пустой stdout, оба снимка
пусты, дельта пуста, вердикт «основной чекаут чист» rc=0. Реальные `init.txt` и
`S-path-fake-git` и добавленный `extra-leak` — не названы.

Фейк `git` (одноразовый, в `/tmp/dev-harness-verify/adv024k3-attack/fake-bin2/`):

```sh
#!/bin/sh
case "$*" in
  *rev-parse*--git-dir*) exit 0 ;;
  *rev-parse*HEAD*)       echo "0000000000000000000000000000000000000000"; exit 0 ;;
  *status*)               exit 0 ;;
  *)                      exit 0 ;;
esac
```

Исполнено (конформный живой git-checkout, `S-path-fake-git` пустой перед
снимком и однобайтный после, плюс добавлен `extra-leak`):

```text
PATH=/tmp/dev-harness-verify/adv024k3-attack/fake-bin2:/usr/bin:/bin \
TMPDIR=/tmp/dev-harness-verify/adv024k3-attack/fake-git \
  bash scripts/check_no_leak.sh --snapshot $REPO                 # rc=0
                                                                # (манифест пуст)
# …truncate S-path-fake-git + echo > extra-leak …
PATH=/tmp/dev-harness-verify/adv024k3-attack/fake-bin2:/usr/bin:/bin \
TMPDIR=/tmp/dev-harness-verify/adv024k3-attack/fake-git \
  bash scripts/check_no_leak.sh --check    $REPO                 # rc=0
                                                                # «основной чекаут чист»
```

Все три файла остаются на диске в основном чекауте — детектор их не называет.
Это именно класс «инструмент мимо PATH», не прежний закрытый класс rc 127 или
«утилита отсутствует» (Н-39 — стабы к ветвям привязывает architect по коду, не
эта проза).

**Положительный контроль.** На том же репо с НАСТОЯЩИМ `git` (PATH=`/usr/bin:/bin`,
fake-bin снят с пути) повтор `--check` дал `rc=1`, `ОТКАЗ: основной чекаут
загрязнён: S-path-fake-git, extra-leak-round2` — значит, контрпример не
перепутанный; реальная дельта ловится на честной форме и НЕ ловится на подмене.

### Блокер 2 — `S-path-fake-comm-clean`: поддельный `comm` на PATH возвращает пустую дельту ⇒ «чисто»

Фикс пинит `comm` через `command -v` с полным PATH (комментарий:
«sort/comm, выдающие «мусор» вместо сортировки/деления, дают дельту ≠ 0 →
ложная тревога, не «чисто»»). Утверждение верно для мусорного comm (ложная
тревога), но ложная тревога ≠ «чисто» — это разные исходы; фейк `comm`,
возвращающий rc=0 и ПУСТОЙ stdout (не мусор, не ошибка), даёт `delta=""`,
условие `[ -n "$delta" ]` ложно, вердикт «основной чекаут чист». Снимок
делается на честном PATH (real manifest), подмена включается только на сверке.

Фейк `comm` (одноразовый, в `/tmp/dev-harness-verify/adv024k3-attack/fake-bin6/`):

```sh
#!/bin/sh
cat >/dev/null; cat >/dev/null; exit 0
```

Исполнено:

```text
# снимок на честном PATH:
PATH=/usr/bin:/bin TMPDIR=/tmp/.../fake-comm-test \
  bash scripts/check_no_leak.sh --snapshot $REPO                 # rc=0
# …добавлен extra-leak-round2 в репо…
# сверка с фейком comm на PATH:
PATH=/tmp/.../fake-bin6:/usr/bin:/bin TMPDIR=/tmp/.../fake-comm-test \
  bash scripts/check_no_leak.sh --check    $REPO                 # rc=0
                                                                # «основной чекаут чист»
```

Манифест базы содержит реальные sha утечек; дельта считается через поддельный
`comm -23`, которая возвращает пустую строку; `cur` и `base` не нужны для
обхода, важно только, что `delta` пусто.

**Положительный контроль.** На том же снимке с НАСТОЯЩИМ `comm` (PATH=`/usr/bin:/bin`)
повтор `--check` дал `rc=1`, `ОТКАЗ: основной чекаут загрязнён: extra-leak-round2`
— реальная дельта ловится, обход живёт только при подмене.

### Блокер 3 — `S-mv-replace-no-verify`: замена снимка без строки `verify` обходит self-verify полностью

Фикс вводит «Self-verify (ОПЦИОНАЛЬНО): последняя строка снимка — `verify
<sha256>`, sha по всему предыдущему содержимому. На check: если строка есть,
она ОБЯЗАНА сойтись; если строки нет (стабы/старые снимки — без неё), проверка
пропускается». То есть self-verify ОБЪЯВЛЕНО ОПЦИОНАЛЬНЫМ, и check пропускает
проверку, если строки нет. Атакующий, имеющий право писать в `$TMPDIR/.../porcelain`
(свой TMPDIR, к которому есть доступ на запись; фикс не закрывает «mv+replace
валидным свежим снимком» — Демаркация, «сговор»), кладёт snapshot БЕЗ строки
verify, и check пропускает verify-чек. Дальше delta считается от манифеста,
который атакующий аккуратно подгоняет под текущее состояние, — пуста ⇒ «чисто».
Это НЕ «mv+replace с валидным verify» (названный предел), а именно
mv+replace БЕЗ verify — проще, потому что не надо вычислять sha и подгонять
последнюю строку; verify-чек всё равно пропускается, потому что строки нет.

Исполнено:

```text
PATH=/usr/bin:/bin TMPDIR=/tmp/.../verify-removal2 \
  bash scripts/check_no_leak.sh --snapshot $REPO                 # rc=0
# …добавлен MASSIVE-LEAK (45 байт) в репо…
PATH=/usr/bin:/bin TMPDIR=/tmp/.../verify-removal2 \
  bash scripts/check_no_leak.sh --check    $REPO                 # rc=1 «ОТКАЗ:
                                                                #   основной чекаут
                                                                #   загрязнён:
                                                                #   MASSIVE-LEAK»
# атакующий вычисляет sha MASSIVE-LEAK и пишет свой porcelain:
chmod 444 /tmp/.../verify-removal2/malicious-snap
mv -f   /tmp/.../verify-removal2/malicious-snap \
       $TMPDIR/dev-harness-leak/18b868b6/porcelain
# содержимое: «root <canon>\n??:<sha> MASSIVE-LEAK\n» (NO verify line)
PATH=/usr/bin:/bin TMPDIR=/tmp/.../verify-removal2 \
  bash scripts/check_no_leak.sh --check    $REPO                 # rc=0
                                                                # «основной чекаут чист»
```

Mode-check: `stat -c '%a'` = `444`, биты 0222 = 0, проходит. Symlink-check:
`$SNAP` — регулярный файл, `$SNAP_DIR` — каталог, оба не симлинки, проходит.
Root-check: первая строка совпадает с `root $CANON`, проходит. Verify-check:
`grep -E '^verify [0-9a-f]{64}$'` — нет матча (строка `verify …` отсутствует),
`[ -n "$verify_line" ]` ложно, проверка пропускается, явная ветка «verify не
сошёлся» НЕ достигается. Delta: `cur` (честный manifest) минус `base` (подделан
под текущий) = пусто. ⇒ rc=0 «чисто». Файл `MASSIVE-LEAK` остаётся в основном
чекауте.

Это НЕ противоречит Демаркации «mv+replace содержимого валидным свежим снимком»,
поскольку там речь про «валидный verify». Здесь — обход verify-чека через его
ОТСУТСТВИЕ, и это не названный предел. Self-verify объявлено ОПЦИОНАЛЬНЫМ —
значит, атакующий имеет прямой, документированный способ его обойти.

**Положительный контроль.** На репо `verify-removal-pos` (отдельный init) с реальным
снимком и добавленным `LEAK-CONTROL` без атаки: `PATH=/usr/bin:/bin
TMPDIR=… bash check_no_leak.sh --check $REPO` дал `rc=1`, `ОТКАЗ: основной
чекаут загрязнён: LEAK-CONTROL`. Значит, контрпример не перепутанный.

## Что фикс НЕ покрывает (новые предметы)

1. **PATH-резолв `git`.** Фикс пин-резолвит ТОЛЬКО `sha256sum`, оставляя `git`
   под полным PATH с единственной защитой «git status вернёт rc≠0». Поддельный
   `git`, возвращающий rc=0 и пустой stdout, проходит (Блокер 1). Прецедент
   `fixtures/check_judge_gate/stab_detektor_bez_predproverki.sh` имитирует
   `S-no-sha256sum`, но не симметричный кейс `git`. Не достаёт ни пина `git`
   через TRUSTED_PATH, ни живого red-контрпримера, закрывающего «fake-git
   возвращает пустой porcelain с rc=0».
2. **PATH-резолв `comm`.** Фикс пинит `comm` через `command -v`, но не закрывает
   сценарий «comm возвращает пустой stdout с rc=0» — дельта пуста, детектор
   говорит «чисто». Прецедента red-контрпримера нет (Блокер 2).
3. **Self-verify объявлен ОПЦИОНАЛЬНЫМ.** Фикс пишет: «если строки нет — проверка
   пропускается. Совместимость с red_detektor_utechek.sh и
   probe_slabyh_detektora.sh, которые подменяют детектор на stab_* без verify».
   Обратная совместимость со стабами ≠ оправдание продакшен-чека: внешний
   атакующий не обязан подкладывать verify. Verify-чек обязан быть ОБЯЗАТЕЛЬНЫМ
   для любого снимка из прод-режима (отсутствие verify в прод-снимке =
   аномалия, не «совместимость со стабом»), иначе его можно просто не писать
   (Блокер 3).

## Что фикс покрывает (положительные наблюдения)

- `S-path-forged-sha256`: TRUSTED_PATH-pin + sanity-хэш закрывают форму к2.
- `S-external-snapshot-symlink`: `[ -L "$SNAP" ]` + `[ -L "$SNAP_DIR" ]` +
  mode-check 0222 закрывают форму к2.
- Verify-чек ловит подменённую verify-строку (тест на `verify-removal4`:
  `verify 0000…0000` отвергнут именованным «verify не сошёлся», rc=1).
- `S-no-sha256sum` (PATH без sha256sum) по-прежнему rc=2 NOT_IMPLEMENTED.
- `S-status-refusal` (git status rc≠0) по-прежнему rc=2 NOT_IMPLEMENTED.
- `S-empty-tree`: пустой репо ⇒ rc=0 «чисто» (без утечки).

## Исполненные отрицательные и положительные контроли

- `S-status-refusal`: фейк git с `*status*) exit 1` ⇒ `--snapshot` дал
  `NOT_IMPLEMENTED: манифест не прочитан: git status rc=1`, `rc=2`.
- `S-no-sha256sum`: PATH без sha256sum ⇒ `--snapshot` дал
  `NOT_IMPLEMENTED: утилита sha256sum отсутствует`, `rc=2`.
- `S-empty-tree`: чистый пустой git-repo ⇒ rc=0 «чисто», не объявлен утечкой.
- `S-positive-control` (для каждого из 3 контрпримеров к3): честный PATH на
  той же форме входа даёт именованный rc=1 с перечислением утечек.
- `bash fixtures/check_judge_gate/probe_slabyh_detektora.sh` → rc=0 (18 ворот,
  честная форма зелёная, 17 слабых умерли именованно, плацебо отвергнуто).
- `bash scripts/verify_antiplacebo.sh . --scope check_judge_gate` → rc=0
  (scoped-семья зелёная).
- `bash fixtures/check_judge_gate/red_stenogrammy_sudej_024.sh` на судимой базе
  → rc=0 (норма-строка приземлена, A+M-множество и pickaxe-граница работают).
- Ignored-путь не заявляется находкой: Демаркация контракта. «Сговор/спавн-
  без-вердикта» по Демаркации — когнитивный предел, не находка; но
  `S-mv-replace-no-verify` обходит verify не через «сговор», а через
  ОТСУТСТВИЕ verify-строки, что не названный предел.

## Приёмочные наблюдения

```text
bash scripts/verify_antiplacebo.sh . --scope check_judge_gate    # rc=0
 git diff --exit-code frozen/contracts/024/2..HEAD -- \
   fixtures/check_judge_gate/                                    # rc=0, пусто
                                                                # (барьер заморожен)
 git diff --exit-code frozen/contracts/024/2..HEAD -- \
   scripts/check_no_leak.sh                                      # rc=1, НЕ пусто:
                                                                # 250 строк фикса 04ba744
                                                                # (implementer-зона, НЕ
                                                                # замороженный барьер;
                                                                # правка уместна и
                                                                # ожидаема — реализация
                                                                # фикса к2)
```

На основном checkout исполнена заданная интерим-норма:

```text
стенограмма: check_no_leak --check → rc=0
```

## Требуемая правка

1. Пин-резолв `git` через `TRUSTED_PATH` (или хотя бы проверка, что
   `git status --porcelain -uall -z … < /dev/null` действительно обращается к
   репозиторию и выдаёт согласованный с `git rev-parse HEAD` формат). Без этого
   форма «fake-git возвращает rc=0 и пустой porcelain» остаётся живым обходом.
   Добавить живой red-контрпример `S-path-fake-git-clean` в
   `fixtures/check_judge_gate/`.
2. Пин-резолв `comm` через `TRUSTED_PATH` (или явная проверка, что
   `comm -23 <(cur) <(base)` не вернул пустую строку при непустом `cur` —
   например, через пересчёт дельты альтернативным способом и сверкой длин).
   Добавить живой red-контрпример `S-path-fake-comm-clean`.
3. Сделать verify-чек ОБЯЗАТЕЛЬНЫМ для прод-снимков (отсутствие `verify …` в
   прод-снимке = аномалия, не «совместимость со стабом»). Обратную совместимость
   со стабами держать через явное «стаб-режим»: либо стабы пишут свой verify с
   осмысленным sha (тогда verify-чек универсален), либо verify-чек имеет два
   режима — «строгий» (прод) и «ослабленный» (стаб). Добавить живой
   red-контрпример `S-mv-replace-no-verify`.
4. После правки повторить все контрпримеры к2 и к3, положительные контроли,
   probe, scoped `check_judge_gate`, frozen-diff. Полный прогон — задача
   CI (Н-48), не этого судьи.
