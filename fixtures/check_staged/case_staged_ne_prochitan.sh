# ПРИЧИНА: staged не прочитан
# ОКРУЖЕНИЕ: PATH=$WORK/bin:$PATH
#
# Пост-заморозочное усиление 018 по находке F-1 адверсария (verdicts/adversary/contracts-018.md,
# проверен e5ca82c; страж ветки среза 1 не виновен — дефект в чтении staged):
# `mapfile -d '' staged < <(git -C "$ROOT" diff --cached --name-only -z 2>/dev/null)` не видит
# rc процесса в подстановке: отказ git diff (rc 127 PATH-двойник, rc 1) даёт пустой stdout,
# неотличимый от пустого staged → «нечего судить: staged пуст», rc 0. Зонированный автор с живой
# wip/<NNN>/<автор>, коммитящий вне своей ветки, обходит И-1: судимый путь есть, а суда нет.
#
# ЛИТЕРАЛ НОВОЙ ПРИЧИНЫ (единый источник, Н-39): «staged не прочитан». implementer обязан
# выдать его ДОСЛОВНО (строка вывода, rc 1) на входе «git diff --cached --name-only -z
# завершился кодом ≠ 0». До правки этот вход обязан краснить раннер («красное не предъявлено»)
# — предъявление красным ДО правки кода, правило 3.
#
# Механика входа — как у адверсария: PATH-первый git-двойник в $WORK/bin, делегирующий всё
# настоящему git, КРОМЕ `git -C <красный репо> diff --cached --name-only -z` — диагностика в
# stderr и rc 127. Адрес красного репо подставлен в двойник: отказ наблюдаем ТОЛЬКО на входе
# F-1 (Н-39: стаб к ветви, где его дефект различим; зелёный репо двойник не трогает).
#
# Зелёный контроль: тот же двойник в PATH (делегирует), легальный репо, staged пуст →
# rc 0 «нечего судить: staged пуст». Доказывает: двойник сам по себе барьер не ломает —
# красное attributable именно отказу diff, а не присутствию двойника в PATH.
#
# Красное: профиль И-1 (implementer с живой wip/018/implementer, HEAD на main, staged
# scripts/b.sh) + падающий diff → сейчас rc 0 «нечего судить: staged пуст» (маскировка F-1,
# предмет этой фикстуры); после правки — rc 1 «staged не прочитан». Вызовы через || true (А-32).
set -uo pipefail
# shellcheck disable=SC1091
. "$(dirname "$0")/_repo.sh"

# ── зелёный репо: легальный вход, staged пуст ──────────────────────────────────
GREEN="$WORK/repo_green"
make_repo "$GREEN"

# ── красный репо: профиль И-1 — ветка жива, чекаут main, staged непуст ─────────
RED="$WORK/repo_red"
make_repo "$RED"
mk_wip "$RED" wip/018/implementer
stage "$RED" scripts/b.sh 'работа мимо worktree — staged непуст, судимый предмет есть'

# ── git-двойник (пёс F-1): делегирует всё, кроме чтения staged КРАСНОГО репо ───
RED_CANON="$(cd "$RED" && pwd -P)"   # барьер канонизирует корень до git-вызова
REAL_GIT="$(command -v git)"         # честный git ВНЕ подмены: фикстура бежит с обычным PATH
mkdir -p "$WORK/bin"
cat > "$WORK/bin/git" <<STUB
#!/bin/sh
# git-двойник F-1: rc процесса в подстановке не наблюдается — моделирует отказ чтения staged
fail=0; isdiff=0; c=0; n=0; z=0; prev=""
for a in "\$@"; do
  [ "\$a" = "diff" ] && isdiff=1
  [ "\$a" = "--cached" ] && c=1
  [ "\$a" = "--name-only" ] && n=1
  [ "\$a" = "-z" ] && z=1
  if [ "\$prev" = "-C" ]; then
  case "\$a" in "$RED_CANON"|"$RED") fail=1 ;; esac
  fi
  prev="\$a"
done
if [ "\$fail\$isdiff\$c\$n\$z" = "11111" ]; then
  printf 'git: simulated unavailable diff\n' >&2
  exit 127
fi
exec "$REAL_GIT" "\$@"
STUB
chmod +x "$WORK/bin/git"
[ -x "$WORK/bin/git" ] && [ -n "$REAL_GIT" ] \
  || { printf 'NOT_IMPLEMENTED: не удалось собрать git-двойник\n' >&2; exit 2; }

# ── вызовы барьера: серийные, через || true (А-32) ─────────────────────────────
"$BARRIER" "$GREEN" || true   # ожидание: rc 0 «нечего судить: staged пуст»
"$BARRIER" "$RED" || true     # сейчас: rc 0 «нечего судить: staged пуст» (маскировка F-1);
                             # после правки: rc 1 «staged не прочитан»
