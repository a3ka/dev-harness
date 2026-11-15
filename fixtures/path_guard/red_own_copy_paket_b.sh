#!/usr/bin/env bash
# КРАСНОЕ ПАКЕТ-Б (слово владельца 2026-11-15 «пакет Б — да»): изолированный
# работник с парой WORKTREE=/BRANCH= в задании (пин = АДРЕС ДОСТАВКИ, приём —
# accept_task_commit ведущей) пишет в СВОЮ копию — каталог сессии omp (ctx.cwd →
# JudgeInput.sessionCwd), если копия проходит ВСЕ условия М1 037
# (isSelfContainedCwdEligible: .git-каталог, worktree list==1, под realpath($HOME),
# не сам HOME, owner.json рядом с id == sessionName, без .git-предков). Граница —
# ТОЛЬКО внутри копии, лексически И по реальному пути ближайшего существующего предка.
#
# Боль: модели OpenAI под изоляцией отказываются писать вне своей копии, а пин
# задания разрешал запись ТОЛЬКО в WORKTREE= (Sol 14.11, Adversary179Impl2 15.11
# на gpt-6.1-terra). Живая проба ISO-PIN 2026-11-15 (Terra ведущая, Sol работник):
# с этой ветвью работник пишет и коммитит в копии, ACCEPTED tip d30efe57.
#
# СУБЪЕКТ: .omp/extensions/path-guard.ts — judge()/pathAllowed()/realAncestorWithin().
# Probe-only каталог (fixtures/path_guard/.probe-only): гоняют судьи и автор правки,
# не CI. Регресс-соседи: red_pin_spawn_zadanie.sh (032), red_self_contained_cwd.sh
# (037), red_extract_pin_actual_066.sh (066), red_pin_allowlist.sh (025).
#
# ПРИВЯЗКА К КОДУ (Н-39): каждая ветвь красна на СВОЁМ входе.
#   * б1 (позитив write, пин из задания) — до пакета Б block «запись вне пина»;
#     стаб «ветви своей копии нет» умирает здесь.
#   * б2 (позитив bash, абсолютный операнд) — стаб «ветвь только в judgeEditWrite,
#     pathAllowed bash её не видит» умирает здесь.
#   * б3 (позитив без пина, actual=null — форма edit/write, где omp не несёт cwd,
#     остаток Н-173б) — стаб «sessionCwd судится только при пине» умирает здесь.
#   * б4 (контроль: запись в пин WORKTREE= по-прежнему pass) — стаб «своя копия
#     ВМЕСТО пина» умирает здесь.
#   * б5 (основной-чекаут-подобный self-contained ВНЕ $HOME как sessionCwd) —
#     стаб «sessionCwd без М1-проверки» умирает здесь: ожидание block.
#   * б6 (владелец-корреляция: sessionName ≠ owner.json.id) — стаб «М1 без
#     sessionName» умирает здесь: ожидание block.
#   * б7 (..-побег: <копия>/../escape) — стаб «isWithin по сырому пути без
#     lexNormalize» умирает здесь: ожидание block.
#   * б8 (соседний префикс: <копия>-x/f) — стаб «startsWith без разделителя»
#     умирает здесь: ожидание block.
#   * б9 (symlink внутри копии наружу: <копия>/lnk -> вне) — стаб «без
#     realAncestorWithin, только лексика» умирает здесь: ожидание block.
#   * б10 (висячая ссылка: <копия>/dang -> вне/несуществующий) — стаб «realAncestor
#     без lstat: поднимается к родителю-копии» умирает здесь: ожидание block.
#   * б11 (sessionCwd нет — пиннованный пишет в копию) — стаб «копия угадывается
#     из args.cwd/actual» умирает здесь: ожидание block.
#   * б12 (sessionCwd — подкаталог копии, не toplevel) — стаб «М1 по любому
#     предку с .git» умирает здесь: ожидание block.
#   * б13 (symlink, затем «..»: <копия>/lnk/../f — лексически внутри копии, а ОС
#     разрешает lnk раньше «..» и пишет рядом с целью ссылки) — стаб «реальный
#     предок по лексически нормализованному пути» умирает здесь: ожидание block.
ROOT="${1:-$(cd "$(dirname "$0")/../.." && pwd)}"
SUBJ="$ROOT/.omp/extensions/path-guard.ts"

if [ ! -f "$SUBJ" ]; then
  printf 'КРАСНОЕ ПАКЕТ-Б: субъект отсутствует — %s не существует\n' "$SUBJ" >&2
  exit 1
fi
command -v git  >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n'  >&2; exit 2; }
command -v node >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет node\n' >&2; exit 2; }

# Копия и чужие цели СОЗНАТЕЛЬНО вне ${TMPDIR:-/tmp}/dev-harness-verify — иначе pass
# даёт scratch-allowlist 025 и клетка ничего не доказывает (ловушка Н-85/А-122).
NS="/tmp/dev-harness-worktrees"
FAKEHOME_BASE="${TMPDIR:-/tmp}/dev-harness-fakehome-pb"
mkdir -p "$NS" "$FAKEHOME_BASE"
FAKEHOME="$(mktemp -d "$FAKEHOME_BASE/pgpbhome.XXXXXX")"
OUTSIDE_NS="$(mktemp -d "$NS/pgpbout.XXXXXX")"
PINWT="$(mktemp -d "$NS/pgpbpin.XXXXXX")"
MAINLIKE="$(mktemp -d "$NS/pgpbmain.XXXXXX")/m"
trap 'rm -rf "$FAKEHOME" "$OUTSIDE_NS" "$PINWT" "$(dirname "$MAINLIKE")"' EXIT

export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null

mkinit() {  # <путь> — минимальный репо, .git КАТАЛОГ, 1 коммит
  local p="$1"
  mkdir -p "$p"
  git -C "$p" init -q -b main
  printf 'x\n' > "$p/f.txt"
  git -C "$p" add f.txt
  git -C "$p" -c user.name=t -c user.email=t@t.local -c commit.gpgsign=false commit -qm init
}

# Своя копия изолированного работника: форма isolated:true клона omp
# (…/wt/<id>/m под HOME сессии, owner.json — в родителе, id = имя сессии).
COPY="$FAKEHOME/profiles/dev/wt/tpb/m"
mkinit "$COPY"
printf '{"pid":424242,"id":"OwnerPB","startToken":"1"}' > "$(dirname "$COPY")/.omp-isolation-owner.json"
mkdir -p "$COPY/sub"
ln -s "$OUTSIDE_NS" "$COPY/lnk"
ln -s "$OUTSIDE_NS/net-takogo.txt" "$COPY/dang"
mkdir -p "${COPY}-x"

# Основной-чекаут-подобный self-contained репо ВНЕ $HOME с owner.json рядом.
mkinit "$MAINLIKE"
printf '{"pid":424242,"id":"OwnerPB","startToken":"1"}' > "$(dirname "$MAINLIKE")/.omp-isolation-owner.json"

ORDER=(б1 б2 б3 б4 б5 б6 б7 б8 б9 б10 б11 б12 б13)
declare -A ST RAN
for m in "${ORDER[@]}"; do ST[$m]=0; RAN[$m]=0; done
fail() {
  RAN["$1"]=1; ST["$1"]=1
  printf 'КРАСНОЕ ПАКЕТ-Б: ветвь «%s» — %s\n' "$1" "$2" >&2
}

expect_judge() {  # <ветвь> <block|pass> <json>
  local vetka="$1" want="$2" evt="$3" out rc dec
  RAN["$vetka"]=1
  out="$(HOME="$FAKEHOME" node "$SUBJ" --judge "$evt")"; rc=$?
  if [ "$rc" -ne 0 ]; then
    fail "$vetka" "субъект не ответил решением (rc $rc, вывод: ${out:-<пусто>})"
    return
  fi
  dec="$(printf '%s' "$out" | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{try{const j=JSON.parse(s);console.log(j.decision??"")}catch(e){console.log("BAD_JSON")}})')"
  if [ "$dec" != "$want" ]; then
    fail "$vetka" "ожидалось $want, получено $dec (вывод: $out)"
    return
  fi
  if [ "$want" = block ]; then
    case "$out" in
      *"Н-85"*) ;;
      *) fail "$vetka" "reason без «Н-85»: $out" ;;
    esac
  fi
}

PIN="\"worktree\":\"$PINWT\",\"skipActualCheck\":true"

expect_judge б1 pass \
  "{\"tool\":\"write\",\"args\":{\"path\":\"$COPY/sub/f1.txt\"},$PIN,\"sessionName\":\"OwnerPB\",\"sessionCwd\":\"$COPY\"}"
expect_judge б2 pass \
  "{\"tool\":\"bash\",\"args\":{\"command\":\"printf x > $COPY/f2.txt\"},$PIN,\"sessionName\":\"OwnerPB\",\"sessionCwd\":\"$COPY\"}"
expect_judge б3 pass \
  "{\"tool\":\"write\",\"args\":{\"path\":\"$COPY/f3.txt\"},\"worktree\":null,\"actual\":null,\"sessionName\":\"OwnerPB\",\"sessionCwd\":\"$COPY\"}"
expect_judge б4 pass \
  "{\"tool\":\"write\",\"args\":{\"path\":\"$PINWT/f4.txt\"},$PIN,\"sessionName\":\"OwnerPB\",\"sessionCwd\":\"$COPY\"}"
expect_judge б5 block \
  "{\"tool\":\"write\",\"args\":{\"path\":\"$MAINLIKE/f5.txt\"},$PIN,\"sessionName\":\"OwnerPB\",\"sessionCwd\":\"$MAINLIKE\"}"
expect_judge б6 block \
  "{\"tool\":\"write\",\"args\":{\"path\":\"$COPY/f6.txt\"},$PIN,\"sessionName\":\"OwnerPB.Chuzhoj\",\"sessionCwd\":\"$COPY\"}"
expect_judge б7 block \
  "{\"tool\":\"write\",\"args\":{\"path\":\"$COPY/../escape7.txt\"},$PIN,\"sessionName\":\"OwnerPB\",\"sessionCwd\":\"$COPY\"}"
expect_judge б8 block \
  "{\"tool\":\"write\",\"args\":{\"path\":\"${COPY}-x/f8.txt\"},$PIN,\"sessionName\":\"OwnerPB\",\"sessionCwd\":\"$COPY\"}"
expect_judge б9 block \
  "{\"tool\":\"write\",\"args\":{\"path\":\"$COPY/lnk/f9.txt\"},$PIN,\"sessionName\":\"OwnerPB\",\"sessionCwd\":\"$COPY\"}"
expect_judge б10 block \
  "{\"tool\":\"write\",\"args\":{\"path\":\"$COPY/dang\"},$PIN,\"sessionName\":\"OwnerPB\",\"sessionCwd\":\"$COPY\"}"
expect_judge б11 block \
  "{\"tool\":\"write\",\"args\":{\"path\":\"$COPY/f11.txt\",\"cwd\":\"$COPY\"},$PIN,\"actual\":\"$COPY\",\"sessionName\":\"OwnerPB\"}"
expect_judge б12 block \
  "{\"tool\":\"write\",\"args\":{\"path\":\"$COPY/sub/f12.txt\"},$PIN,\"sessionName\":\"OwnerPB\",\"sessionCwd\":\"$COPY/sub\"}"
expect_judge б13 block \
  "{\"tool\":\"write\",\"args\":{\"path\":\"$COPY/lnk/../f13.txt\"},$PIN,\"sessionName\":\"OwnerPB\",\"sessionCwd\":\"$COPY\"}"

RED=0; GRN=0; NORUN=0
for m in "${ORDER[@]}"; do
  if [ "${RAN[$m]}" -eq 0 ]; then NORUN=$((NORUN+1));
  elif [ "${ST[$m]}" -eq 1 ]; then RED=$((RED+1)); else GRN=$((GRN+1)); fi
done
if [ "$NORUN" -gt 0 ]; then
  printf 'КРАСНОЕ ПАКЕТ-Б: %d ветвей НЕ прогнаны (пустая выборка — красное, не зелёное)\n' "$NORUN" >&2
  exit 1
fi
printf 'ИТОГ ПАКЕТ-Б (path_guard): ветвей %d, красных %d, зелёных %d\n' "${#ORDER[@]}" "$RED" "$GRN"
[ "$RED" -eq 0 ] || exit 1
exit 0
