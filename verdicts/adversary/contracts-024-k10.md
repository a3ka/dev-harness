FAIL

Судимый предмет: `scripts/check_no_leak.sh` на `4ada54121f49954d9939fead85c21bfa59a8aab8` (четыре producer'а manifest(): porcelain, dot-git walk, INDEXFLAG, WTIGNORE) плюс все десять `fixtures/check_judge_gate/*_024.sh`. Клон: `/tmp/adversary024k10`.

Стенограмма спавна: bash scripts/check_no_leak.sh --check /tmp/adversary024k10 → rc=0

## 1. Позитивный контроль — проверка не вечно-красная

Все десять фикстур на этом клоне rc=0: `red_dotgit_info_exclude_024`, `red_gitignore_selfhide_024`, `red_index_flags_024`, `red_info_refs_drift_024`, `red_norma_stroka_024`, `red_path_fake_utilit_024`, `red_stenogrammy_sudej_024`, `red_symlink_target_content_024`, `red_toctou_manifest_024`, `canary_zhivoj_024`. `bash scripts/verify_antiplacebo.sh . --scope check_judge_gate` → rc=0 (3 фикстуры предъявлены красными повторным прогоном).

Чистый клон: `--snapshot /tmp/adversary024k10` → rc=0; `--check /tmp/adversary024k10` → rc=0 «основной чекаут чист».

Честная правка tracked-файла поимённо: после снимка `git apply` дописал строку в `.omp/config.yml` → `--check` → rc=1, `ОТКАЗ: основной чекаут загрязнён: .omp/config.yml`. Восстановлено `git checkout HEAD -- .omp/config.yml`, повторный `--check` → rc=0.

## 2. БЛОКЕР Б7 — мутация внешней цели `core.excludesFile` невидима

Репро: `/tmp/dev-harness-verify/k10_external_exclude.sh`.

Toy-репо, ДО снимка выставлено `git config core.excludesFile <внешний-файл>`, внешний файл пуст. Снимок. После снимка меняются ТОЛЬКО байты внешней цели (в неё пишется имя будущей утечки) и создаётся сам файл утечки в корне. `.git/config` не меняется — его sha в манифесте стабилен; `git status --porcelain -uall` утечку не показывает (правило применено); WTIGNORE не при чём (это не `.gitignore`); INDEXFLAG не при чём (бит не ставится). Дельта пуста:

    external core.excludesFile target mutation: check rc=0; output=основной чекаут чист

Класс — ровно тот, что уже признан блокером дважды: Б1 ревью v1 (`.git/info/exclude` как носитель правил) и Б3 к8 (байты ЦЕЛИ симлинка `.git/info/exclude`). Здесь носитель указан не симлинком, а строкой конфигурации, и разрешения цели детектор не делает вовсе. Сужение Демаркации «(а) записи в ignored-пути вне 024» этот случай не покрывает: ослепляется сам ИСТОЧНИК манифеста, а не прячется отдельный ignored-путь — то же обоснование, по которому приняты Б1, Б3 и Б6.

## 3. БЛОКЕР Б8 — чекаут с `.git`-файлом (`--separate-git-dir`) не имеет dot-git половины манифеста вовсе

Репро: `/tmp/dev-harness-verify/k10_separate_gitdir_hook.sh` (атака) и `/tmp/dev-harness-verify/k10_separate_gitdir_positive.sh` (позитивный контроль той же формы).

`emit_dotgit_manifest` начинается с `[ -d "$1/.git" ] || return 0`. В чекауте, созданном `git init --separate-git-dir=<внешний-gitdir>`, `.git` — регулярный ФАЙЛ (`gitdir: …`), поэтому хуки, `.git/info/*` и `.git/config` не попадают ни в один манифест. Предъявляю ровно тот инцидент, ради которого заведён 024 — подмену активного барьера `pre-push`: до снимка хук существует (`exit 1`), после снимка заменён на `exit 0` с маркером; porcelain пуст:

    separate-git-dir pre-push hook replacement: check rc=0; output=основной чекаут чист

Позитивный контроль на той же форме доказывает, что вход конформный (живой чекаут, ≥1 коммит, tracked-файлы, `git rev-parse --git-dir` работает), и слепа именно dot-git половина:

    separate-git-dir ordinary untracked leak: check rc=1; output=ОТКАЗ: основной чекаут загрязнён: plain-leak-30123.txt

Второй носитель того же класса — конфигурация: `git config core.excludesFile <внешние-правила>` меняет `<внешний-gitdir>/config`, что в обычном чекауте поймал бы `DOTGIT:<sha> .git/config`, а здесь не ловится ничем (`/tmp/dev-harness-verify/k10_separate_gitdir.sh`):

    separate-git-dir config mutation through .git file: check rc=0; output=основной чекаут чист

Это НЕ Н-95: Н-95 — про worktree-чекаут и про ложный rc=1 (безопасное направление); здесь ложный rc=0 на основном чекауте, метаданные которого вынесены `.git`-файлом.

## 4. Дефект Н-96 — список снимаемых git-переменных неполон: `GIT_CONFIG_COUNT`/`GIT_CONFIG_KEY_n`/`GIT_CONFIG_VALUE_n`

Репро: `/tmp/dev-harness-verify/k10_git_config_env.sh`.

Скрипт снимает `GIT_CONFIG_GLOBAL GIT_CONFIG_SYSTEM GIT_CONFIG_NOSYSTEM` (и `HOME`/`XDG_*`) именно потому, что через них подставляется `core.excludesFile`. Семейство `GIT_CONFIG_COUNT`/`GIT_CONFIG_KEY_n`/`GIT_CONFIG_VALUE_n` даёт тот же эффект и НЕ снимается: запиненный `/usr/bin/git` применяет их во всех четырёх producer'ах, porcelain прячет утечку, дельта пуста:

    GIT_CONFIG_COUNT injected core.excludesFile: check rc=0; output=основной чекаут чист

Досягаемость называю честно: она требует контроля над окружением вызова детектора — ровно та же, что у уже снимаемых `GIT_CONFIG_GLOBAL`/`GIT_CONFIG_SYSTEM`. Это не BASH_ENV-класс (никакие командные слова не перехватываются, функции не определяются) — это пропуск в СОБСТВЕННОМ, уже принятом авторском списке unset. Класс-фикс, а не перечисление имён: сегодняшняя форма — `GIT_CONFIG_COUNT` + `GIT_CONFIG_KEY_n`/`VALUE_n`.

## 5. Что атаковано и НЕ пробито (охранные ветви)

* Подмена `git` через PATH не достигает нового producer'а Б5: при `assume-unchanged` + живой правке tracked-файла фейк не исполнился ни разу, пин держит (`/tmp/dev-harness-verify/k10_pinned_producers.sh`): `PATH fake git cannot replace pinned git ls-files: rc=1; fake-executed=no`.
* Подмена `find` через PATH не достигает producer'а Б6: `PATH fake find cannot replace pinned find: rc=1; fake-executed=no` — самоигнорирующий `.gitignore` назван, утечка не прошла.
* Мутация существующего `.git/info/sparse-checkout` после снимка ловится (`/tmp/dev-harness-verify/k10_sparse_checkout.sh`): `sparse-checkout rule mutation: check rc=1; output=ОТКАЗ: основной чекаут загрязнён: .git/info/sparse-checkout`.
* `GIT_CONFIG_COUNT` с `core.worktree` ослепления не дал: `git -C <toy> status` всё равно показал ` M tracked.txt` — как обход не предъявляю.
* НОВЫЙ тайминг против двойного чтения (Б4) — «симметричное повторение»: двойное чтение отказывает только когда чтения РАСХОДЯТСЯ, поэтому атака выполняла ОДИН И ТОТ ЖЕ цикл внутри каждого из двух чтений (бит `assume-unchanged` включён на время porcelain, выключен на время `ls-files -v`), с расширенными окнами (2000 файлов в `.git/info` — длинный dot-git walk между porcelain и ls-files; 2400 ignored-файлов в дереве — длинный хвост `find`). Измеренная база: чистый `--check` 9.741s, одно чтение ~4.87s; 5 попыток с разными долями расписания. Результат: `false-clean attempts: 0 of 5` — все пять дали rc=1 с именной причиной «мутировал во время сверки — повторное чтение разошлось с первым». Репро `/tmp/dev-harness-verify/k10_symmetric_race.sh`. Класс мной НЕ вскрыт: при неточном выравнивании расписания механизм валится в безопасную сторону.
* BASH_ENV-вариации не предъявлялись — кап тредмилла, арбитраж `verdicts/arbitration/bash-env-predel-024.md`.

## 6. Вердикт

FAIL. Три воспроизведённых обхода, каждый — ложный rc=0 с маркером «основной чекаут чист» при физически живой утечке/подмене на диске: Б7 (внешняя цель `core.excludesFile`), Б8 (`.git`-файл при `--separate-git-dir` — dot-git половина манифеста отсутствует целиком, включая подмену `pre-push`), Н-96 (`GIT_CONFIG_COUNT` мимо unset-списка). Правка — за автором; предмет и фикстуры я не трогал.
