FAIL

Судимый предмет: `scripts/check_no_leak.sh` на `c2846895d09fc822dbe50b14895ad75cc904d698` и 15 относящихся к 024 фикстур в `fixtures/check_judge_gate/`. Свежий клон: `/tmp/dev-harness-verify/adversary024-k11`.

Стенограмма до вердикта: bash scripts/check_no_leak.sh --check /tmp/dev-harness-verify/adversary024-k11 → rc=0; output=основной чекаут чист

## Позитивный контроль

Все 15 фикстур дали rc=0 одним прогоном: 12 `red_*_024.sh` (`red_dotgit_info_exclude_024`, `red_excludes_target_024`, `red_git_config_env_024`, `red_gitignore_selfhide_024`, `red_index_flags_024`, `red_info_refs_drift_024`, `red_norma_stroka_024`, `red_path_fake_utilit_024`, `red_separate_gitdir_024`, `red_stenogrammy_sudej_024`, `red_symlink_target_content_024`, `red_toctou_manifest_024`), `canary_zhivoj_024`, `red_detektor_utechek`, `probe_slabyh_detektora`. Последняя предъявила честную форму зелёной на всех 18 воротах и отвергла все 18 слабых форм по их воротам и причинам. `bash scripts/verify_antiplacebo.sh . --scope check_judge_gate` → rc=0; три case-фикстуры повторно предъявлены красными.

Чистый клон: `--snapshot` → rc=0, затем `--check` → rc=0 с «основной чекаут чист». Честная правка tracked `scripts/roles.ts` после снимка дала `--check` → rc=1, «основной чекаут загрязнён: scripts/roles.ts»; файл восстановлен.

## Блокер Б9: INDEXFLAG, поставленный до снимка, ослепляет последующую правку

Репро: `/tmp/dev-harness-verify/k11_indexflag_prebaseline.sh`.

Два конформных toy-репозитория (один коммит, tracked `tracked.txt`). До `--snapshot` на tracked-файле ставится соответственно `git update-index --assume-unchanged tracked.txt` либо `--skip-worktree tracked.txt`. Между снимком и сверкой меняются байты только `tracked.txt`. Флаг в `git ls-files -v` остаётся тем же, поэтому строка `INDEXFLAG:h`/`INDEXFLAG:S` в обоих манифестах идентична; porcelain модификацию не показывает. Детектор сообщает ложный успех при физически изменённом tracked-файле:

    flag=--assume-unchanged index_before=[h tracked.txt] index_after=[h tracked.txt] tracked=[mutated-after-snapshot] porcelain=[] check_rc=0 output=[основной чекаут чист]
    flag=--skip-worktree index_before=[S tracked.txt] index_after=[S tracked.txt] tracked=[mutated-after-snapshot] porcelain=[] check_rc=0 output=[основной чекаут чист]

Это не уже закрытый случай Б5: существующая фикстура ловит переход флага после снимка. Здесь нейтрализация включена до базы и остаётся стабильной; текущий манифест хранит только сам флаг, но не sha256 содержимого такого tracked-пути. Позитивный контроль на той же форме из `red_index_flags_024.sh` остаётся зелёным: постановка флага после снимка + правка ловится rc=1. Следовательно проверка различает только смену флага, а не правку, скрытую неизменным флагом.

## Атаки новых поверхностей, не давших обхода

* Gitdir-резолвер: `/tmp/dev-harness-verify/k11_gitdir_forms.sh`. `.git` как цепочка двух симлинков к валидному pointer-файлу отдельного gitdir даёт snapshot rc=0, а подмена `hooks/pre-push` — rc=1 с `.git/hooks/pre-push`. Некорректный `.git` без `gitdir: ` и указатель на файл-pointer другого worktree оба отвергнуты до манифеста как «не репозиторий git», rc=2. Ложного rc=0 нет.
* EXCLUDES: `/tmp/dev-harness-verify/k11_relative_excludes_control.sh` подтверждает, что относительный `core.excludesFile=rules` в живом git скрывает созданную утечку, а детектор всё же даёт rc=1 по хэшу цели. `/tmp/dev-harness-verify/k11_excludes_target_forms.sh` подтверждает UNREADABLE→CONTENT: при появлении цели с правилом porcelain пуст, но `--check` rc=1 и называет цель. Цель-каталог заставляет `git status` вернуть rc=128; snapshot останавливается именованным rc=2, а не успехом. FIFO не предъявляю повторно: это известный Н-3 liveness-класс, прямо исключённый из новых блокеров.
* Комбинация separate-git-dir + внешний excludesFile и env `GIT_CONFIG_COUNT` покрыта текущими `red_separate_gitdir_024`, `red_excludes_target_024`, `red_git_config_env_024`: все rc=0. Новый тайминг изменения excludes-цели между porcelain и её хэшем пробовался `/tmp/dev-harness-verify/k11_relative_excludes_timing.sh`; пять запусков дали только rc=1 (дельта цели либо «мутировал во время сверки»), не ложный успех.
* `red_toctou_manifest_024` отдельно прошла пять попыток существующей гонки двойного чтения: в каждой rc=1 с «мутировал во время сверки»/«разошлось с первым».

## Вердикт

FAIL: Б9 — воспроизведённый ложный rc=0 «основной чекаут чист» при изменённом tracked-файле. Нужно, чтобы манифест для tracked-пути с уже установленным `assume-unchanged` или `skip-worktree` содержал наблюдение его байтов либо чтобы такая база fail-closed; одной строки о неизменном флаге недостаточно. Предмет и фикстуры не изменялись.
