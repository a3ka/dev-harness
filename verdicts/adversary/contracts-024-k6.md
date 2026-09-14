FAIL

# Адверсарий: контракт 024, круг к6 — детектор утечек основного чекаута

Судимый HEAD: `473e8a8404d60e22e6d8cbbe1e3a3f7cf05eb765` (`land: wip/024/implementer`). Предмет и весь контракт прочитаны; испытания выполнены в одноразовом клоне `/tmp/dev-harness-adv024k6`, а toy-репозитории — только в `/tmp/dev-harness-verify/adv024k6/`.

Стенограмма перед вердиктом: `bash scripts/check_no_leak.sh --check /home/aka/Documents/dev-harness` → rc=1, `ОТКАЗ: основной чекаут загрязнён: .git/hooks/*.sample, .git/config`. Это наблюдаемая дельта актуального `.git` от прежнего snapshot, не моя toy-проба и не выдана за дефект.

## Повтор к5: закрыто

Один драйвер создавал честные baseline, затем заражал только check:

```text
guard-git-injection-still-red rc=1: ОТКАЗ: основной чекаут загрязнён: leak-guard
command-function-still-red rc=1: ОТКАЗ: основной чекаут загрязнён: leak-guard
home-poison-still-red rc=1: ОТКАЗ: основной чекаут загрязнён: tracked, leak-home
dotgit-regular-files-red rc=1: ОТКАЗ: основной чекаут загрязнён: .git/hooks/pre-push, .git/config
```

Следовательно `_CNL_SANITIZED=1` больше не обходит снятие `GIT_DIR`/`GIT_WORK_TREE`; прежняя BASH_ENV-функция `command` снята; hostile `$HOME/.gitconfig` с `core.excludesFile`/`core.fsmonitor` не скрывает tracked и untracked; обычные `.git/hooks/pre-push` и `.git/config` вошли в manifest. `env -u HOME git config --global --get core.excludesFile` → `fatal: $HOME not set`, rc=128: git не делает fallback к прежнему home. При несуществующем TMPDIR `mktemp` именованно отказывает rc=2, не ложно зеленеет.

`bash fixtures/check_judge_gate/red_detektor_utechek.sh` исполнен дважды: оба rc=0, «18 ворот зелены», включая ворота 16. `bash fixtures/check_judge_gate/canary_zhivoj_024.sh /tmp/dev-harness-adv024k6` → rc=0: snapshot, check, повторный check зелёные. Блокер к5 по воротам 16 закрыт; позитивный контроль жив.

## Блокер 1 — S-bashenv-unset-override

На `scripts/check_no_leak.sh:187` новая граница начинается обычным `unset -f command`; все следующие попытки снять BASH_ENV, Git-env и функции тоже вызывают непиннованный `unset`. BASH_ENV может определить функцию `unset`, которая имеет приоритет над builtin и выключает санитизацию до её первого действия. Остаётся вредоносная `command`, возвращающая запиненный якобы git атакующего.

Полный контрпример (честный snapshot, заражён только check):

```bash
repo=$(mktemp -d /tmp/dev-harness-verify/adv024k6/repo.XXXXXX)
tmp=$(mktemp -d /tmp/dev-harness-verify/adv024k6/tmp.XXXXXX)
git init -q "$repo"
git -C "$repo" -c user.name=t -c user.email=t@e commit --allow-empty -qm base
TMPDIR="$tmp" bash scripts/check_no_leak.sh --snapshot "$repo"
printf 'leak\n' | tee "$repo/leak"
printf '#!/bin/sh\nexit 0\n' | tee "$repo/fake-git"
chmod +x "$repo/fake-git"
printf '%s\n' 'unset() { :; }' \
  'command() { if [ "$1" = "-v" ] && [ "$2" = "git" ]; then builtin printf "%s\\n" "$FAKE_GIT"; else builtin command "$@"; fi; }' \
  | tee "$repo/env"
BASH_ENV="$repo/env" FAKE_GIT="$repo/fake-git" TMPDIR="$tmp" \
  bash scripts/check_no_leak.sh --check "$repo"
```

Факт: rc=0, `основной чекаут чист` при живом `leak`. fake-git даёт rc=0 и пустой porcelain, dotgit-config одинаков на обоих концах. Позитивный контроль — та же сверка без BASH_ENV/FAKE_GIT — rc=1 `ОТКАЗ: основной чекаут загрязнён: leak`.

## Блокер 2 — S-bashenv-cd-rebind

Даже без функции `unset` строка 345 исполняет обычный `cd "$ROOT_ARG"`; функция `cd` из BASH_ENV не снимается. Она канонизирует аргумент грязной жертвы в другой, заранее snapshot-нутый чистый репозиторий. Путь snapshot и все git-вызовы смотрят туда.

```bash
# victim и clean — честные git-репозитории, $tmp существует.
TMPDIR="$tmp" bash scripts/check_no_leak.sh --snapshot "$victim"
TMPDIR="$tmp" bash scripts/check_no_leak.sh --snapshot "$clean"
printf 'leak\n' | tee "$victim/leak-cd"
printf '%s\n' "cd() { builtin cd '$clean'; }" | tee "$env"
BASH_ENV="$env" TMPDIR="$tmp" bash scripts/check_no_leak.sh --check "$victim"
```

Факт: rc=0, `основной чекаут чист`; без BASH_ENV rc=1 с `leak-cd`. Это правильный ответ о чужом корне, нарушение И-7. Дополнительный независимый опыт: BASH_ENV-функция `printf`, подавляющая только форматы porcelain `%s:%s\t%s%s\n`/`%s:@head:%s\t%s%s\n` и делегирующая остальные builtin, также дала rc=0 при новом untracked `leak`; без неё — rc=1. Alias `cd` с `expand_aliases` был проверен, но дал fail-closed rc=2, не зачтён как контрпример.

## Блокер 3 — S-dotgit-hook-symlink

Новая dotgit-рекурсия сознательно делает `[ -L "$entry" ] && continue` на строке 453. Но `.git/hooks/pre-push` как симлинк на внешний исполняемый файл — активная подмена pre-push, а не «нет утечки».

```bash
TMPDIR="$tmp" bash scripts/check_no_leak.sh --snapshot "$repo"
printf '#!/bin/sh\nexit 0\n' | tee "$outside"
chmod +x "$outside"
ln -s "$outside" "$repo/.git/hooks/pre-push"
TMPDIR="$tmp" bash scripts/check_no_leak.sh --check "$repo"
```

Факт: rc=0, `основной чекаут чист`. Позитивный контроль: заменить симлинк обычным `.git/hooks/pre-push` с теми же байтами — rc=1 `ОТКАЗ: основной чекаут загрязнён: .git/hooks/pre-push`. Следовательно manifest пропустил активный hook, ради которого переносилась находка 5.

## Наблюдение G подтверждено без симлинков

Это названный остаток «сговор с валидным свежим snapshot», поэтому не отдельный блокер. `$TMPDIR` выбирает весь namespace snapshot (`:356-358`): после честного snapshot в `$honest` и записи `leak-tmpdir` атакующий создаёт обычный `$attacker`, затем:

```bash
TMPDIR="$attacker" bash scripts/check_no_leak.sh --snapshot "$repo"
TMPDIR="$attacker" bash scripts/check_no_leak.sh --check "$repo"
```

Последняя команда дала rc=0 `основной чекаут чист`; с `$honest` — rc=1 и `leak-tmpdir`. Симлинков нет, свежий snapshot имеет честный verify.

Новые блокеры 1–3 имеют честный baseline и позитивный контроль той же формы. Вердикт: FAIL.
