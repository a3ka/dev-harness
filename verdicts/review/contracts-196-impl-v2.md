accept
OBJECT=f354c7c3c3bf87204b23df0f5faccb251ae6ba92
СУД: репо=dev-harness; предмет=196; фаза=реализация; роль=reviewer; вызов=1; сессия=Rev196; модель-факт=anthropic/claude-opus-5-5 (метаданные станции, поле Model); автор Architect196b — architect; предыдущий=нет

# Reviewer 196 — ремонт клетки verify-runner-dropin (PR #1450), вызов 1 (полный)

**БЛОКИРУЕТ: нет.**

**СОВЕТ: 2** — файл `.review/2026-11-27-1961.md` (`status: ready`):

- С-1, адресат orchestrator → владелец/architect 216/074. Сверка `verify_mob_tmpdir` (216) в `fixtures/` ничем не защищена. Мой мутант M2 (`return 0`) зелен во всём дереве. К 196 это не относится.
- С-2, адресат architect 196, низкий приоритет. Под setgid-TMPDIR положительный контроль ложно краснеет. Воспроизведено. Простая форма — `root.chmod(0o755)`.

Класс риска «обычный» (frozen 196, строка 2) подтверждаю. Дифф меняет только мир фикстуры: в нём нет прав, секретов, денег и ПД. Адверсарий не нужен.

## Область правки

Подготовка выполнена по заданию: в копии `pwd` = `/home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/t3f6094cd4/m` добавлен remote origin, сделан fetch и `git switch --detach`. `git rev-parse HEAD` = `f354c7c3c3bf87204b23df0f5faccb251ae6ba92` = OBJECT. origin/main = merge-base = `ea20d3326edb7299724ab16f5d978fc18f63a379`. `origin/wip/196/orchestrator-i1` = OBJECT, это головной коммит PR #1450 (`gh pr view 1450 --json headRefOid` → `f354c7c3c…`, state OPEN, files = только probe.py).

```
$ git diff origin/main HEAD --stat
 .../workshop_project/ops_ci_artifacts_196/probe.py | 24 +++++++++++++++++++++-
 1 file changed, 23 insertions(+), 1 deletion(-)
$ git diff --name-status origin/main HEAD
M	fixtures/workshop_project/ops_ci_artifacts_196/probe.py
$ git log --format='%H %an <%ae> %s' origin/main..HEAD
f354c7c3c3bf87204b23df0f5faccb251ae6ba92 architect-b <architect-b@dev-harness.local> fix(196): prepare canonical runner TMPDIR before artifact verification
```

- Зона. `git show 'frozen/contracts/196/1^{commit}:contracts/196-lokalnye-artefakty-ci-stanciya.md' | grep '^ЗОНА architect'` → `ЗОНА architect: contracts/196-lokalnye-artefakty-ci-stanciya.md fixtures/workshop_project/ops_ci_artifacts_196/`. Единственный файл диффа лежит в этой зоне.
- Чего дифф не трогает. `git diff --quiet origin/main HEAD -- ops/ model/ stabs/ contracts/ …/ops_ci_artifacts_196/stabs …/ops_ci_artifacts_196/model` → rc 0. Контракт против заморозки: `git diff --quiet 'frozen/contracts/196/1^{commit}' HEAD -- contracts/196-…md` → rc 0. После заморозки батарею менял только этот коммит: `git log frozen/contracts/196/1^{commit}..HEAD -- fixtures/…/ops_ci_artifacts_196` → одна строка, `f354c7c3c architect-b`.
- Норма. Норм, ролей и вердиктов дифф не трогает.
- Атомарность. Один коммит на одну задачу, в сообщении ссылка на 196. Коммит несёт две правки: довершение мира и `Path.resolve()`. Обе нужны строкам приёмки одного ремонта: голый вызов и `--repo` дают rc 0, `--repo .` тоже. Обе объявлены в постановке Diag196/Architect196b.

## Проверки не переписаны под код

Дифф прочитан целиком (3 хунка). Клетка не ослаблена:

- Добавлена вложенная `install_runner_tmpdir` (`probe.py:1412–1424`). Она делает каталог `var/lib/ci-runner` мира и дописывает реального пользователя пробы в `known-users`, который читает getent-шим. Затем ставит швы `OPS_SERVER_MOB_TMP` и `OPS_SERVER_MOB_TMP_OWNER` в тот же `env` и вызывает `<install.sh> mob-tmpdir` субъекта. Вызывается только при `subj.kind == 'repo'` (`:1443`, `:1478`), после `artifacts`. Ненулевой rc этого шага — красная клетка с именем (`установка TMPDIR … не зелёная`), а не пропуск.
- Четыре отрицательных раунда остались на месте: D1/D2 × bytes/missing, `:1427–1463`. После довершения дрейф наносится на `…/<unit>.service.d/ci-artifacts.conf`. Требования прежние: `rc == 1` (`:1457`) и `'расхождение' in err and str(dropin) in err` (`:1459`), где `dropin` — путь к `ci-artifacts.conf`. Отказ, называющий только `tmpdir.conf`, клетку не проходит.
- Четыре положительных контроля 00/10/01/11 остались на месте (`:1466–1489`). Требования прежние: `verify` rc 0 и `'ci-artifacts: сверка 3/3' in out` (`:1485`).
- Режимы `--model` и `--stabs` идут без изменений: в модели `verify-artifacts` нет сверки 216. Довершение их не касается, и обманки по-прежнему ловятся (34/34).
- Довершение пишет только `tmpdir.conf`, `tmp1`/`tmp2` и daemon-reload. Дрейф наносится ПОСЛЕ довершения, поэтому скрыть дефект `ci-artifacts` довершением нельзя. Это показано мутантами ниже, M4 — прямо.
- Implementer батарею не трогал: автор единственного коммита — architect-b, зона architect. `ops/server/install.sh` не менялся.

## Свои мутанты по `ops/server/install.sh` (не из `stabs/`)

Каждый мутант — свой одноразовый клон OBJECT внутри копии с одной заменой (`tmp/scratch-rev196/mutate.py`, якорь ровно один). Прогон по одному: `bash tmp/after/…/red_ops_ci_artifacts_196.sh --repo <клон>`. Сырой вывод:

```
M1-verify-dropin-blind: применена        (install.sh:617  check_one …/ci-artifacts.conf … || return 1 → || true)
 ops/server/install.sh | 2 +-
— verify-runner-dropin: KRASNO (сверка слепа к bytes drop-in gh-runner-complior: rc=0, out: сверка: 10/10
ИТОГ 196: rc=1 KLETKI=25 ZELENYE=24 KRASNYE=1
M1-verify-dropin-blind rc=1
M2-verify-mobtmp-off: применена          (verify_mob_tmpdir() { return 0 …)
 ops/server/install.sh | 1 +
— verify-runner-dropin: OK
ИТОГ 196: rc=0 KLETKI=25 ZELENYE=25 KRASNYE=0
M2-verify-mobtmp-off rc=0
M3-install-dropin-first-only: применена  (install_ci_artifacts: ciart_install_dropin "$unit"; break)
 ops/server/install.sh | 2 +-
— verify-runner-dropin: KRASNO (установка не поставила drop-in при юните gh-runner-complior-2 (И-9е))
— install-runner-dropin: KRASNO (drop-in не установлен при юните gh-runner-complior-2)
ИТОГ 196: rc=1 KLETKI=25 ZELENYE=23 KRASNYE=2
M3-install-dropin-first-only rc=1
M4-mobtmp-corrupts-ciart: применена      (mobtmp_install_unit дописывает "X" в $dropin_dir/ci-artifacts.conf)
 ops/server/install.sh | 1 +
— verify-runner-dropin: KRASNO (сверка не назвала drop-in gh-runner-complior-2 (bytes): ОТКАЗ: расхождение …/etc/systemd/system/gh-runner-complior.service.d/ci-artifacts.conf)
ИТОГ 196: rc=1 KLETKI=25 ZELENYE=24 KRASNYE=1
M4-mobtmp-corrupts-ciart rc=1
M5-verify-dropin-first-only: применена   (verify_ci_artifacts: break после сверки первого юнита)
 ops/server/install.sh | 1 +
— verify-runner-dropin: KRASNO (сверка слепа к bytes drop-in gh-runner-complior-2: rc=0, out: сверка: 10/10
ИТОГ 196: rc=1 KLETKI=25 ZELENYE=24 KRASNYE=1
M5-verify-dropin-first-only rc=1
```

- M1, M3, M5 — дефекты `ci-artifacts` (слепая сверка; установка только первого юнита; сверка только первого юнита). Все три красные, и клетка называет именно drop-in `ci-artifacts`.
- M4 портит `ci-artifacts.conf` самим шагом довершения `mob-tmpdir`. Клетка красная, отказ называет `ci-artifacts.conf`, а не прячет его. Значит, довершение не становится слепым пятном.
- M2 (`verify_mob_tmpdir` → `return 0`) зелёный, и это верно. По постановке ожидалось «краснеет», но И-10 и клетка судят drop-in'ы `ci-artifacts`, а не TMPDIR 216. Мутант убирает ровно ту сверку, из-за которой клетка была красной ДО ремонта, поэтому зелень — подтверждение диагноза Diag196, а не дыра 196. Ловца M2 в дереве нет вовсе → С-1.

## Регресс: ДО и ПОСЛЕ своими прогонами

Одноразовые клоны внутри копии: `tmp/before` = origin/main `ea20d3326`, `tmp/after` = OBJECT. `TMPDIR` — `$PWD/tmp/scratch-rev196`, прогоны по одному. `B=fixtures/workshop_project/ops_ci_artifacts_196/red_ops_ci_artifacts_196.sh`.

| Где | Команда | rc | Итог |
|---|---|---|---|
| ДО | `bash B` (голый) | 1 | `KLETKI=25 ZELENYE=24 KRASNYE=1`; красна `verify-runner-dropin (исправная конфигурация раннеров (gh-runner-complior) названа расхождением: rc=1, stderr: ОТКАЗ: расхождение …/gh-runner-complior.service.d/tmpdir.conf (нет файла))` |
| ДО | `bash B --repo .` | 1 | traceback `FileNotFoundError: … 'ops/server/root/ci-artifacts-clean'` (относительный корень при cwd мира) — то, что лечит `.resolve()` |
| ПОСЛЕ | `bash B` (голый) | 0 | `KLETKI=25 ZELENYE=25 KRASNYE=0` |
| ПОСЛЕ | `bash B --model` | 0 | `KLETKI=25 ZELENYE=25 KRASNYE=0` |
| ПОСЛЕ | `bash B --stabs` | 0 | `OBMANOK=34 POIMANY=34 ZHIVYH=0` |
| ПОСЛЕ | `bash B --repo "$PWD"` (абсолютный) | 0 | `KLETKI=25 ZELENYE=25 KRASNYE=0` |
| ПОСЛЕ | `bash B --repo .` | 0 | `KLETKI=25 ZELENYE=25 KRASNYE=0` |
| ПОСЛЕ | `bash scripts/gen_ci_steps.sh --check` | 0 | — |
| ПОСЛЕ | `reslop t -- bash scripts/verify_ci_parity.sh` | 0 | `passed: 29 failed: 0`; `расхождений: 0` |
| PR | `gh pr checks 1450 -R a3ka/dev-harness` | 0 | все pass (ap1–ap5, ci l1–l7, klass, legkij, obshchij, tyazhelyj-itog), vorota skipping |

Числа сверил своей мерой — подсчётом строк, а не по строке ИТОГ: `python3 -B probe.py | awk` → `own-count OK=25 KRASNO=0`; `probe.py --stabs | awk` → `own-count POIMAN=34 ZHIV=0`; `ls stabs | wc -l` = 34; `ls model | wc -l` = 6 (замеры контракта).

## Побочное: второй потребитель

`git grep -n -e mob-tmpdir -e MOB_TMP -e tmpdir.conf -- fixtures/workshop_project/ops_ci_artifacts_196/` → только `probe.py:1421–1423` (довершение). Другие repo-миры батареи вызывают `verify` с требованием «сверка 3/3»: `:1071–1089` (verify-drift), `:1019`, `:1037`, `:1129`, `:1152`. Юниты раннеров они не сотворяют (`runner_units=()`), поэтому `verify_mob_tmpdir` там отвечает «не применимо» и rc не роняет. Неотражённого второго потребителя нет: голый вызов 25/25.

## Остатки (контракт 192)

В frozen 196 нет строк `К-NN`. Строки остатка, у которых ловец — reviewer, судятся по разделу «Конечная область испытаний и остаток»:

- ОСТАТОК: «низкоуровневые сбои копирования/хеширования — ловец ревьюер проходит дифф install.sh» — не укусил: `ops/server/install.sh` в диффе нет (`git diff --quiet origin/main HEAD -- ops/` rc 0).
- ОСТАТОК: «реальные UID/GID, systemd — живая установка шаг 12, принимает ревьюер» — не укусил в этой фазе: дифф не меняет установщик. Каталоги TMPDIR мира при этом сверяются по реальному владельцу пробы, а не по шиму. Зависимость от окружения (setgid-TMPDIR) → С-2.

## Норма 050 (паразитная сложность)

- `install_runner_tmpdir` (`probe.py:1412–1424`), вложенная функция:
  - (1) Требует И-10: положительные контроли 00/10/01/11 обязаны давать `verify` rc 0 на реальном субъекте, а его `verify` с 25.11 включает сверку 216. Без довершения мира строка приёмки «голый вызов rc 0, 25/25» не проходит. Ослабить `verify` нельзя — это ломает 216.
  - (2) Вводит каталог мира `var/lib/ci-runner`, строку в `known-users` и два шва в `env`. Всё явно: env передаётся тем же вызовам `verify`. Мутация переданного `env` — единственный побочный эффект, и он нужен, чтобы verify видел те же швы.
  - (3) Совместно меняется 1 файл (probe.py), число не выросло.
  - (4) Интерфейс `(w, env) → (rc, out, err)` закрывает 7 строк работы. Модуль небольшой, но не мелкий.
  - (5) Потребители — строки приёмки «голый вызов / `--repo`» контракта 196 и станционная приёмка. Чужой грамматики функция не повторяет: вызывает подкоманду субъекта, логику 216 не копирует.
  - ESSENTIAL.
- `Path(args[1]).resolve()` (`:1547`):
  - (1) строка приёмки `--repo .` rc 0 (ДО — traceback);
  - (2) состояния нет;
  - (3) 1;
  - (4) н/п;
  - (5) приёмка.
  - ESSENTIAL.

## Сверки

- СВЕРКА-АРХИТЕКТУРЫ: н/п. Frozen 196 не объявляет `АРХИТЕКТУРА`. В диффе нет `bindings.json`, новых писателей, операций и диффа модели. Долг не расширен.
- СВЕРКА-СТАНДАРТОВ: н/п. `AGENTS.md` станции не объявляет `docs/ARCHITECTURE.md` и `docs/CODING-STANDARDS.md` (`grep -c` = 0).
- Режим проекта 996: sourceCanon не объявлен (КОНТЕКСТ контракта), сверка карты н/п. Мобильного экрана нет.
- ПРОВОДКА (038): guard `red_ops_ci_artifacts_196.sh` существует, подключён CI-шагом `check:ops-ci-artifacts-196-family-selftest` (`--stabs`) и остаётся барьером именно этого предмета. ПРОВОДКА-ЭНФОРСМЕНТ (чистый энфорсмент) не затронута.

## Не проверено

- Живая станция (шаг 12: `sudo install.sh artifacts`, `mob-tmpdir`, `verify` под root на реальных юнитах) не прогонялась. Это не предмет данного ремонта.
- Как ведёт себя клетка под CI-раннером GitHub в режиме `--repo`, не проверено: CI гоняет только `--stabs`. [INFERENCE] Пользователь раннера разрешим через `getent`/`id -gn`, так что ложной красной там не ожидаю.

## Наблюдения (не находки)

- Н-1. Автор коммита — `architect-b`, а строка зоны — `ЗОНА architect`. `scripts/check_zones.sh` сравнивает `user.name` точно (`:768`, `grep -qxF`), поэтому этот коммит выпадает из машинного суда зон. Это задокументированный cognitive-only остаток (`check_zones.sh:43–48`). Принадлежность пути зоне я сверил руками (раздел «Область правки»).
- Н-2. Сбой `--repo .` до ремонта (traceback) — прежний дефект батареи, не связанный с 216. Исправлен тем же коммитом.
