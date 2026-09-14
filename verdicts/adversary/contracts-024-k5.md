FAIL

# Адверсарий: контракт 024, круг 5 (детектор утечек основного чекаута)

Судимая база: `main` `b4f3fc40256410084ffd853e624335928ca10aea`; судимая правка —
implementer-коммит `daaee0a` («структурная санитизация окружения (env -i)»).
Все атаки выполнялись в одноразовом клоне
`/tmp/dev-harness-adv024k5-p6GsJc/repo` и toy-репозиториях под
`/tmp/dev-harness-verify/adv024k5/`; основной чекаут атаками не мутировался,
снимок церемонии (`--snapshot` основного корня) я НЕ переснимал — переснятие
стёрло бы базу церемонии.

Драйверы контрпримеров (сохранены целиком, каждый воспроизводим одной командой):
`/tmp/dev-harness-verify/adv024k5/test_env_vectors.sh`,
`test_home_class.sh`, `test_more.sh`, `test_guard.sh`.

Стенограмма детектора: `check_no_leak --check /home/aka/Documents/dev-harness → rc=1`
(`bash scripts/check_no_leak.sh --check /home/aka/Documents/dev-harness` дал
`ОТКАЗ: основной чекаут загрязнён: verdicts/adversary/contracts-025-k4.md` — файл
параллельного судьи контракта 025, не моя правка).

## (а) Два вектора круга к4 закрыты — но условно, не структурно

Повтор обоих контрпримеров к4 против `daaee0a`
(`bash /tmp/dev-harness-verify/adv024k5/test_env_vectors.sh`):

```text
[control] snapshot rc=0
[control] check rc=1 ОТКАЗ: основной чекаут загрязнён: leak-control
[bashenv] check rc=1 ОТКАЗ: основной чекаут загрязнён: leak-bashenv
[gitenv]  check rc=1 ОТКАЗ: основной чекаут загрязнён: leak-gitenv
```

То есть `S-bashenv-command-function` и `S-git-dir-work-tree-injection` при
РАБОТАЮЩЕМ re-exec действительно умирают: `env -i` их снимает. Позитивный
контроль (`[control]`) красный на честной утечке и зелёный на снимке — набор не
вечно-красный.

НО заявка коммита — «ни одна НЕ ПЕРЕЧИСЛЕННАЯ явно ниже переменная не переживает
re-exec, независимо от имени» — не держится: сам re-exec включается/выключается
переменной окружения (блокер 1), а два имени из ПЕРЕЧИСЛЕННЫХ (`HOME`, `TMPDIR`)
несут ровно тот же класс «переменная меняет поведение утилиты» (блокеры 2, 3).

## Блокер 1 — `S-cnl-sanitized-guard-off`: `_CNL_SANITIZED=1` выключает всю санитизацию, оба вектора к4 воскресают

`scripts/check_no_leak.sh:120` — `if [ -z "${_CNL_SANITIZED:-}" ]; then … exec env -i
_CNL_SANITIZED=1 …`. Часовой самого барьера — обычная переменная окружения
атакующего: выставив её, атакующий пропускает `exec env -i` целиком, и весь
входящий env (включая `BASH_ENV`, `GIT_DIR`, `GIT_WORK_TREE`) доживает до тела
детектора. Это не «омнипотентный атакующий внутри процесса» из оговорки в шапке:
переопределять `exec`/`printf` не нужно вовсе — достаточно одного присваивания.

Воспроизведение (`bash /tmp/dev-harness-verify/adv024k5/test_guard.sh`), снимок
ЧЕСТНЫЙ (без инъекции), заражён только `--check`:

```text
[I] honest snapshot rc=0
[I] guard-bypass check rc=0 основной чекаут чист
[I] without guard var (sanitized) rc=1 ОТКАЗ: основной чекаут загрязнён: leak-I
[J] honest snapshot rc=0
[J] guard-bypass check rc=0 основной чекаут чист
[J] without guard var (sanitized) rc=1 ОТКАЗ: основной чекаут загрязнён: leak-J
```

Минимальная команда `[I]` (victim и clean — два честных toy-репозитория, утечка
`leak-I` лежит в victim ПОСЛЕ снимка):

```bash
_CNL_SANITIZED=1 GIT_DIR="$clean/.git" GIT_WORK_TREE="$clean" TMPDIR="$snap" \
  bash scripts/check_no_leak.sh --check "$victim"
# ожидалось: rc 1 «основной чекаут загрязнён: leak-I»
# фактически: rc 0 «основной чекаут чист»
```

`[J]` — тот же приём с `BASH_ENV`, подменяющим builtin `command` на выдачу
фейкового `git` (дословно контрпример к4): `rc=0 основной чекаут чист`.
Позитивный контроль в обоих кейсах — та же команда без `_CNL_SANITIZED`: `rc=1`
с именем утечки. Следовательно, фикс `daaee0a` не понижает планку атаки на
класс, а добавляет ровно один символ к строке атаки.

## Блокер 2 — `S-home-git-config-excludes`: `HOME` из списка пропускаемых ⇒ глобальный gitconfig скрывает untracked-утечку (санитизация РАБОТАЕТ)

`env -i … HOME="${HOME:-/root}"` пропускает `HOME` из заражённого окружения, а git
читает `$HOME/.gitconfig` безусловно. Ключ `core.excludesFile` (и он же через
`[include] path`) делает утечку невидимой для `git status --porcelain -uall` — то
есть для ЕДИНСТВЕННОГО источника манифеста. `_CNL_SANITIZED` не выставляется,
re-exec происходит, PATH-пин и verify целы.

Воспроизведение (`bash /tmp/dev-harness-verify/adv024k5/test_home_class.sh`) —
снимок честный, заражён только `--check`:

```text
[A] honest snapshot rc=0
[A] poisoned check rc=0 основной чекаут чист
[A] positive control (clean HOME) rc=1 ОТКАЗ: основной чекаут загрязнён: leak-A
[C] honest snapshot rc=0
[C] poisoned check (include) rc=0 основной чекаут чист
```

Минимальная команда:

```bash
printf '*\n' | tee "$home/globalignore"
printf '[core]\n\texcludesFile = %s/globalignore\n' "$home" | tee "$home/.gitconfig"
printf 'utechka\n' | tee "$repo/leak-A"      # утечка ПОСЛЕ честного снимка
HOME="$home" TMPDIR="$snap" bash scripts/check_no_leak.sh --check "$repo"
# ожидалось: rc 1 «основной чекаут загрязнён: leak-A»
# фактически: rc 0 «основной чекаут чист»
```

Это НЕ названное Демаркацией сужение «записи в ignored-пути вне 024»: в честной
конфигурации путь не игнорируется, игнор СОЗДАЁТСЯ инъекцией. Доказательство
разделения:

```text
git -C A-repo check-ignore -v leak-A                 → rc 1 (не игнорируется)
HOME=A-home git -C A-repo check-ignore -v leak-A     → rc 0, A-home/globalignore:1:*  leak-A
```

## Блокер 3 — `S-home-fsmonitor-tracked`: тот же `HOME` скрывает МОДИФИКАЦИЮ tracked-файла (форма `M .githooks/pre-push` инварианта И-2)

`core.fsmonitor` из глобального конфига заставляет git доверять индексу для всех
путей, о которых не сообщил хук; хук — исполняемый файл атакующего в его же
`$HOME`. Модификация tracked-файла перестаёт быть видимой в porcelain, а вместе с
`core.excludesFile` исчезают ОБЕ формы измеренных ночных утечек (untracked-мусор
и `M .githooks/pre-push`) одновременно.

Воспроизведение (`bash /tmp/dev-harness-verify/adv024k5/test_more.sh`):

```text
[D] poisoned snapshot rc=0
[D] poisoned check rc=0 основной чекаут чист
[D] positive control (clean HOME) rc=1 ОТКАЗ: основной чекаут загрязнён: .githooks/pre-push
[E] poisoned snapshot rc=0
[E] poisoned check rc=0 основной чекаут чист
[E] positive control (clean HOME) rc=1 ОТКАЗ: основной чекаут загрязнён: .githooks/pre-push, leak-untracked-E
```

Минимальная команда `[D]`:

```bash
printf '#!/bin/sh\nprintf "adv"\nprintf "\\000"\n' | tee "$home/fsm"; chmod +x "$home/fsm"
printf '[core]\n\tfsmonitor = %s/fsm\n' "$home" | tee "$home/.gitconfig"
HOME="$home" TMPDIR="$snap" bash scripts/check_no_leak.sh --snapshot "$repo"
printf 'LEAK\n' | tee -a "$repo/.githooks/pre-push"
HOME="$home" TMPDIR="$snap" bash scripts/check_no_leak.sh --check "$repo"
# ожидалось: rc 1 «основной чекаут загрязнён: .githooks/pre-push»
# фактически: rc 0 «основной чекаут чист»
```

Честная граница находки: `[K]` драйвера `test_guard.sh` показывает, что при
ЧЕСТНОМ снимке и заражённом только `--check` fsmonitor утечку не скрывает
(`rc=1 … tracked`) — инъекция обязана присутствовать и на снимке. Для
`core.excludesFile` (блокер 2) такого условия НЕТ: там достаточно заражения одной
сверки.

## Блокер 4 — регрессия приёмочной rc-команды: `red_detektor_utechek.sh` ворота 16 краснеют ИМЕННО из-за `daaee0a`

Приёмочный критерий 024 («После реализации»): «red-ворота → rc 0 (живой
предмет), два прогона подряд». На судимом HEAD:

```bash
cd <клон>
bash fixtures/check_judge_gate/red_detektor_utechek.sh   # ДВА прогона подряд
```

```text
ОТКАЗ ворота 16 (нет sha256sum): S-no-sha256sum: --snapshot rc=0 (ожидался 2) …
run1 rc=1
ОТКАЗ ворота 16 (нет sha256sum): S-no-sha256sum: --snapshot rc=0 (ожидался 2) …
run2 rc=1
```

Атрибуция — прямой бисект по одному файлу в клоне:

```bash
git checkout daaee0a^ -- scripts/check_no_leak.sh
bash fixtures/check_judge_gate/red_detektor_utechek.sh   # rc 0, «18 ворот зелены», ворота 16 ok
git checkout HEAD -- scripts/check_no_leak.sh
bash fixtures/check_judge_gate/red_detektor_utechek.sh   # rc 1, ворота 16 ОТКАЗ
```

Причина содержательная, не косметическая: `exec env -i … PATH="$_cnl_trusted"`
стирает минимальный `PATH` фикстуры (BIN16 без `sha256sum`), поэтому ветвь
«окружение не годится ⇒ rc 2 именованный» (блокер 2 вердикта `d67ac4b`) на входе
«утилиты нет» больше НЕ наблюдаема через окружение вовсе: детектор всегда
находит настоящий `sha256sum` в `/usr/bin`. Предмет сдан с красной замороженной
приёмочной командой; правка фикстуры — зона architect, не implementer, поэтому
закрытие требует круга нормы/архитектора, а не молчаливого подтягивания
фикстуры.

## Находка 5 — `S-dot-git-leak`: утечка в `.git/` основного чекаута не ловится и НЕ покрыта ни одним из трёх названных сужений

Без единой переменной окружения (`bash /tmp/dev-harness-verify/adv024k5/test_more.sh`,
секция `[F]`):

```bash
bash scripts/check_no_leak.sh --snapshot "$repo"              # rc 0
printf '#!/bin/sh\n# LEAK\nexit 0\n' | tee "$repo/.git/hooks/pre-push"
chmod +x "$repo/.git/hooks/pre-push"
git -C "$repo" config adv.leaked true                          # правка .git/config
bash scripts/check_no_leak.sh --check "$repo"
```

```text
[F] check rc=0 основной чекаут чист
[F] check-ignore rc=1                 (путь НЕ игнорируется)
[F] hook on disk: 1                   (подменённый активный хук на диске остался)
```

Демаркация 024 называет три сужения: ignored-пути, скоммиченная история,
запись «мимо рабочего дерева (в /tmp, чужие каталоги, ignored-пути)». `.git/hooks/`
и `.git/config` — ВНУТРИ каталога основного чекаута, не игнорируются (`check-ignore`
rc 1) и не коммит; при этом подмена активного `pre-push` отключает сам
pre-push-барьер — ровно тот артефакт, утечка в который (`.githooks/pre-push`,
ночь 2026-09-10) и породила контракт. Сужение либо должно быть названо явно, либо
класс должен ловиться.

## Наблюдения (в объявленном капе Демаркации «сговор с валидным verify», не блокеры)

- `[G]` `test_more.sh`: `TMPDIR` тоже в списке пропускаемых; `--snapshot` с чужим
  `TMPDIR` после утечки + `--check` с тем же `TMPDIR` → `rc 0 основной чекаут
  чист`, снимок церемонии при этом НЕ тронут (позитивный контроль с TMPDIR
  церемонии: `rc 1 … leak-G`).
- `[H]` `test_more.sh`: мера «Reject-symlink» проверяет `-L` только на `$SNAP` и
  `$SNAP_DIR`; симлинк на ПРОМЕЖУТОЧНЫЙ `$TMPDIR/dev-harness-leak` не проверяется
  — `rc 0 основной чекаут чист` при живой утечке `leak-H`. Эффект тот же, что у
  объявленного капа, но заявка шапки «обход через симлинк-родитель — отвергнут»
  на промежуточном каталоге неверна.

## Приёмочные наблюдения (клон, судимый HEAD)

- `bash fixtures/check_judge_gate/probe_slabyh_detektora.sh` → rc 0 (18 ворот,
  плацебо отвергнуто).
- `bash fixtures/check_judge_gate/red_path_fake_utilit_024.sh` → rc 0 (16 ветвей).
- `bash scripts/verify_antiplacebo.sh . --scope check_judge_gate` → rc 0.
- `bash fixtures/check_judge_gate/red_stenogrammy_sudej_024.sh` → rc 0
  (вакуумно-зелёная: норма-строка 024 в `roles/orchestrator.md` не приземлена —
  `grep -n check_no_leak roles/orchestrator.md` пуст).
- `bash fixtures/check_judge_gate/red_detektor_utechek.sh` → **rc 1** (блокер 4).

Вердикт `FAIL`: четыре воспроизводимых дефекта, три из них — ложный `rc 0`
«основной чекаут чист» при живой утечке, каждый с независимым позитивным
контролем той же формы, и один — красная замороженная приёмочная rc-команда,
атрибутированная бисектом ровно к судимому коммиту. Кап «ПОВТОР КЛАССА» не
применим: блокер 1 выключает заявленную структурную меру целиком, блокеры 2–3
идут через ПЕРЕЧИСЛЕННЫЕ в whitelist переменные (`HOME`), которые фикс объявил
безопасными по построению, а находка 5 вовсе не использует окружение.
