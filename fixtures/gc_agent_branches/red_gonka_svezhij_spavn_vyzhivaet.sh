# Красное предъявление 3/3 контракта 030 — Н-107: гонка спавн/close-out в жнеце веток.
#
# ВХОД: игрушка — main (base); wip/031/architect — СВЕЖИЙ СПАВН (пустая ветка на tip
# main, reflog-файл только что создан) с живым worktree; wip/030/young23 — пустая,
# reflog −23ч (моложе дефолтной грации); wip/030/aged25 — пустая, reflog −25ч (старше
# дефолтной грации, моложе фиксированных 48ч — различитель дефолта); wip/030/oldcrash —
# старая пустая, −3 дня; wip/030/no-log — пустая, reflog-файл УДАЛЁН (fail-closed);
# wip/029/merged — молодая НЕпустая слитая (коммит на ветке, main поглощает --no-ff).
#
# ПОРЯДОК АССЕРТОВ = порядок инвариантов контракта (часть 3), ДВА прогона жнеца:
#   A (без флага):
#   1) gc rc 0;
#   2) свежая пустая ref+worktree ЖИВЫ (инвариант 3.2) — сегодня краснеет: гонка Н-107;
#   3) young23 ЖИВА — дефолт ≥ 24ч, а не ноль/меньше (инвариант 3.4, дефолт);
#   4) no-log ЖИВА — fail-closed при недоступном reflog (инвариант 3.3);
#   5) aged25 СНЕСЕНА — дефолт ≤ 24ч, а не фиксированные 48 (инвариант 3.4, дефолт);
#   6) oldcrash снесена — гигиена упавших спавнов жива;
#   7) merged снесена — грация НЕ тормозит чистку (инвариант 3.5);
#   8) КАНАЛ stderr (файл отдельный от stdout) несёт строки-связки «ветка ↔ причина»:
#      wip/031/architect + «граци», wip/030/young23 + «граци», wip/030/no-log +
#      «reflog» — без пина полной фразы (круг 1, Б4: сообщение только в stdout —
#      потеря канала и потери связи «эта ветка — эта причина»);
#   B (--wip-grace-hours 3):
#   9)  gc rc 0;
#   10) young23 СНЕСЕНА — положительное N ПРИМЕНЯЕТСЯ (23ч ≥ 3ч; игнорирующий N
#       жнец оставил бы её по дефолту 24ч);
#   11) свежая ЖИВА (0ч < 3ч), no-log ЖИВА (fail-closed не зависит от N);
#   хвост) --wip-grace-hours 0 → rc 1, отказ называет «положитель» (инвариант 3.4).
#
# СТАБ-ПРИВЯЗКИ (Н-39: живут здесь, не в прозе контракта):
#   S-nikogda     — «пустые никогда не сносятся» (frontier В-1): умирает на ассерте 6;
#   S-vsyo-gracia — «грация на ВСЕ достижимые»: умирает на ассерте 7 (слитая с
#                   работой пережила gc);
#   S-48h         — «фиксированные 48ч вместо дефолта 24» (обход круга 1): умирает
#                   на ассерте 5 (aged25 моложе 48, но старше 24 — обязана сноситься);
#   S-nol-del     — «нет reflog = сносить» (обход круга 1): умирает на ассерте 4;
#   S-ignore-N    — «N принимается, но игнорируется» (обход круга 1): умирает на
#                   ассерте 10 (прогон B);
#   S-zero-grace  — «грация ноль/минуты: всё пустое сносится сразу»: умирает на
#                   ассерте 3 (young23 моложе 24ч);
#   S-stdout-only — «сообщение выживания только в stdout» (обход круга 1, Б4):
#                   умирает на ассерте 8 — stderr-файл пуст на связку ветка↔причина;
#   S-bez-flaga   — «флаг без валидации»: умирает на хвостовом ассерте (0 принят
#                   или отказ безымянный).
# На текущем HEAD (замер пачки на этой же игрушке): gc сносит ВСЕ ветки и worktree
# спавна → краснеет ассертом 2 — гонка Н-107 воспроизведена живым прогоном.
set -uo pipefail

# Каркас метапрогона (прецедент _zhnets.sh): WORK/BARRIER/REPO назначает проверяющий;
# прямой прогон назначает сам.
if [ -z "${WORK:-}" ]; then
  REPO="$(cd "$(dirname "$0")/../.." && pwd -P)"
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/gonka030.XXXXXX")"
  BARRIER="$REPO/scripts/gc_agent_branches.sh"
  trap 'chmod -R u+w "$WORK" 2>/dev/null || true; rm -rf "$WORK"' EXIT
fi
command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }
[ -n "${BARRIER:-}" ] && [ -x "$BARRIER" ] || { printf 'NOT_IMPLEMENTED: барьер не найден: %s\n' "${BARRIER:-}" >&2; exit 2; }

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null
zgi() {  # герметичный git игрушки (прецедент _zhnets.sh)
  local r="$1"; shift
  git -C "$r" -c user.name=Фикстура -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"
}

R="$WORK/repo-gonka"
git init -q -b main "$R"
zgi "$R" commit -q --allow-empty -m base

# СВЕЖИЙ СПАВН: пустая ветка от tip main + worktree (церемония 016: спавн = ветка+worktree).
zgi "$R" branch wip/031/architect main
zgi "$R" worktree add "$WORK/wt-spawn" wip/031/architect >/dev/null 2>&1

# Возрастные пустые: возраст = mtime reflog-файла ветки (touch-управляемые).
# young23 −23ч и aged25 −25ч обрамляют дефолт 24ч: обе стороны границы наблюдаемы.
zgi "$R" branch wip/030/young23 main
zgi "$R" branch wip/030/aged25 main
zgi "$R" branch wip/030/oldcrash main
for b in wip/030/young23 wip/030/aged25 wip/030/oldcrash; do
  LOG="$R/.git/logs/refs/heads/$b"
  [ -f "$LOG" ] || { printf 'NOT_IMPLEMENTED: reflog-файл ветки не создан (%s) — мера возраста недоступна фикстуре\n' "$LOG" >&2; exit 2; }
done
touch -d "@$(( $(date +%s) - 23*3600 ))" "$R/.git/logs/refs/heads/wip/030/young23"
touch -d "@$(( $(date +%s) - 25*3600 ))" "$R/.git/logs/refs/heads/wip/030/aged25"
touch -d "@$(( $(date +%s) - 3*86400 ))" "$R/.git/logs/refs/heads/wip/030/oldcrash"

# Пустая без reflog-файла: источник возраста/пустоты недоступен → fail-closed.
zgi "$R" branch wip/030/no-log main
rm "$R/.git/logs/refs/heads/wip/030/no-log"

# Молодая НЕпустая слитая: работа на ветке, main поглощает merge-коммитом.
zgi "$R" branch wip/029/merged main
zgi "$R" checkout -q wip/029/merged
zgi "$R" commit -q --allow-empty -m work
zgi "$R" checkout -q main
zgi "$R" merge -q --no-ff -m merge wip/029/merged

ref_zhiv() { git -C "$R" show-ref --verify --quiet "refs/heads/$1"; }
svjazka() {  # <файл> <ветка> <токен-причины>: строка-связка «ветка ↔ причина» в канале
  grep -Eq "$2.*$3|$3.*$2" "$1"
}

# ── ПРОГОН A: дефолтная грация; stdout и stderr — РАЗНЫЕ файлы (Б4) ───────────
outA="$(mktemp "$WORK/gc-outA.XXXXXX")"; errA="$(mktemp "$WORK/gc-errA.XXXXXX")"; rc=0
"$BARRIER" --root "$R" >"$outA" 2>"$errA" || rc=$?

# 1) rc 0: зависших нет, OID-отказов нет.
[ "$rc" -eq 0 ] || { printf 'ОТКАЗ: gc rc %s, ожидался 0:\n%s\n%s\n' "$rc" "$(cat "$outA")" "$(cat "$errA")" >&2; exit 1; }

# 2) Свежая пустая ЖИВА: ref и worktree — живая гонка Н-107 (сегодня gc сносит обе).
if ! ref_zhiv wip/031/architect; then
  printf 'ОТКАЗ: свежая пустая wip/031/architect снесена gc при нуле коммитов — гонка спавн/close-out (Н-107)\n%s\n%s\n' "$(cat "$outA")" "$(cat "$errA")" >&2
  exit 1
fi
[ -d "$WORK/wt-spawn" ] || { printf 'ОТКАЗ: worktree свежего спавна снесен вместе с веткой (Н-107)\n%s\n%s\n' "$(cat "$outA")" "$(cat "$errA")" >&2; exit 1; }

# 3) young23 (−23ч) ЖИВА при дефолте: грация не ноль и не минуты (S-zero-grace).
ref_zhiv wip/030/young23 || { printf 'ОТКАЗ: пустая wip/030/young23 (−23ч) снесена при дефолтной грации 24ч — грация не применяется\n%s\n%s\n' "$(cat "$outA")" "$(cat "$errA")" >&2; exit 1; }

# 4) no-log ЖИВА: reflog недоступен → fail-closed (S-nol-del, обход круга 1).
ref_zhiv wip/030/no-log || { printf 'ОТКАЗ: ветка без reflog-файла wip/030/no-log снесена — недоступный источник обязан выживать (инвариант 3.3)\n%s\n%s\n' "$(cat "$outA")" "$(cat "$errA")" >&2; exit 1; }

# 5) aged25 (−25ч) СНЕСЕНА при дефолте: дефолт 24ч, а не фиксированные 48 (S-48h).
if ref_zhiv wip/030/aged25; then
  printf 'ОТКАЗ: пустая wip/030/aged25 (−25ч) пережила gc — дефолтная грация не 24ч (обход круга 1: фиксированные 48)\n%s\n%s\n' "$(cat "$outA")" "$(cat "$errA")" >&2
  exit 1
fi

# 6) Старая пустая снесена — гигиена упавших спавнов (S-nikogda умирает здесь).
if ref_zhiv wip/030/oldcrash; then
  printf 'ОТКАЗ: старая пустая wip/030/oldcrash (−3д) пережила gc — гигиена упавших спавнов умерла\n%s\n%s\n' "$(cat "$outA")" "$(cat "$errA")" >&2
  exit 1
fi

# 7) Молодая слитая снесена — чистка close-out не заторможена (S-vsyo-gracia).
if ref_zhiv wip/029/merged; then
  printf 'ОТКАЗ: молодая слитая с работой wip/029/merged пережила gc — грация затормозила close-out (инвариант 3.5)\n%s\n%s\n' "$(cat "$outA")" "$(cat "$errA")" >&2
  exit 1
fi

# 8) Канал stderr несёт строки-связки «ветка ↔ причина» (S-stdout-only умирает здесь;
#    полная фраза НЕ пиннится — свобода формулировки, пиннуты канал и связь).
svjazka "$errA" 'wip/031/architect' 'граци' || { printf 'ОТКАЗ: stderr не объясняет выживание wip/031/architect — нет строки-связки с «граци» (канал потерян, круг 1 Б4)\nstderr:\n%s\n' "$(cat "$errA")" >&2; exit 1; }
svjazka "$errA" 'wip/030/young23' 'граци' || { printf 'ОТКАЗ: stderr не объясняет выживание wip/030/young23 — нет строки-связки с «граци»\nstderr:\n%s\n' "$(cat "$errA")" >&2; exit 1; }
svjazka "$errA" 'wip/030/no-log' 'reflog' || { printf 'ОТКАЗ: stderr не называет причину выживания wip/030/no-log — нет строки-связки с «reflog» (инвариант 3.3)\nstderr:\n%s\n' "$(cat "$errA")" >&2; exit 1; }

# ── ПРОГОН B: положительное N применяется (S-ignore-N умирает здесь) ─────────
outB="$(mktemp "$WORK/gc-outB.XXXXXX")"; errB="$(mktemp "$WORK/gc-errB.XXXXXX")"; rcB=0
"$BARRIER" --root "$R" --wip-grace-hours 3 >"$outB" 2>"$errB" || rcB=$?
[ "$rcB" -eq 0 ] || { printf 'ОТКАЗ: gc --wip-grace-hours 3 rc %s, ожидался 0:\n%s\n%s\n' "$rcB" "$(cat "$outB")" "$(cat "$errB")" >&2; exit 1; }

# 10) young23 (−23ч ≥ 3ч) СНЕСЕНА: N замещает дефолт, а не принимается молча.
if ref_zhiv wip/030/young23; then
  printf 'ОТКАЗ: wip/030/young23 (−23ч) пережила gc при --wip-grace-hours 3 — положительное N не применяется (обход круга 1)\n%s\n%s\n' "$(cat "$outB")" "$(cat "$errB")" >&2
  exit 1
fi

# 11) Свежая (0ч < 3ч) и no-log ЖИВЫ: грация коротка, но не гонка; fail-closed от N не зависит.
ref_zhiv wip/031/architect || { printf 'ОТКАЗ: свежая пустая wip/031/architect снесена при N=3 (0ч < 3ч) — грация N не различает свежий спавн\n%s\n%s\n' "$(cat "$outB")" "$(cat "$errB")" >&2; exit 1; }
[ -d "$WORK/wt-spawn" ] || { printf 'ОТКАЗ: worktree свежего спавна снесен при N=3 (Н-107)\n%s\n%s\n' "$(cat "$outB")" "$(cat "$errB")" >&2; exit 1; }
ref_zhiv wip/030/no-log || { printf 'ОТКАЗ: ветка без reflog wip/030/no-log снесена при N=3 — fail-closed не зависит от грации\n%s\n%s\n' "$(cat "$outB")" "$(cat "$errB")" >&2; exit 1; }

# хвост) Флаг грации: строго положительное, валидация при разборе argv (сегодня — «неизвестный аргумент»).
rc2=0; out2="$("$BARRIER" --root "$R" --wip-grace-hours 0 2>&1)" || rc2=$?
[ "$rc2" -eq 1 ] || { printf 'ОТКАЗ: --wip-grace-hours 0 вернул rc %s, ожидался 1:\n%s\n' "$rc2" "$out2" >&2; exit 1; }
printf '%s\n' "$out2" | grep -Fq 'положитель' || { printf 'ОТКАЗ: отказ по --wip-grace-hours 0 не называет «положительное»:\n%s\n' "$out2" >&2; exit 1; }

exit 0
