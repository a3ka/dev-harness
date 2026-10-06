#!/usr/bin/env bash
# Стаб-пак контракта 086: обманные реализации точек сведения против клеток семьи.
#   bash fixtures/gejty_svedenija_086/red_stuby_086.sh [<корень дерева>]
# Каждый стаб — дерево-подмена (копия scripts/ и .githooks/ проверяемого дерева с ОДНОЙ
# заменой); поймано ⟺ привязанная клетка КРАСНА на стабе; диффпроба ⟺ клетка, где дефект
# стаба НЕ наблюдаем, на том же стабе ЗЕЛЕНА (клетка красна от дефекта, не от каркаса).
# rc 0 — пойманы все и все диффпробы зелёные; rc 1 — живой стаб либо красная диффпроба;
# rc 2 — снимок до-086 недоступен (история дерева без коммита T86_DO_086) либо пробой.
#
# Н-39: привязка стаба к клетке живёт ЗДЕСЬ, в таблице PAK, — не в прозе контракта.
#   код  подмена                                        поймана клеткой  диффпроба
#   s1   accept до 086 (пропускает (а)/(в), диагноз (б) чужой)   A1          A4
#   s2   land до 086 (пропускает (а)/(б)/(в))                    L2          L4
#   s3   pre-merge-commit отсутствует                            H1          H2
#   s4   spawn до 086 (core.hooksPath не ставится)               S1          S0
#   s5   accept: (а) на каждый путь каждого коммита              A4          A1
#   s6   land: (а) на каждый путь каждого коммита                L4          L1
#   s7   хук отказывает любому merge                             H2          H1
#   s8   accept: суд зон во всех открытых окнах (без land-метки) A5          A1
#   s9   land: (в) без границы первой заморозки файла            L5          L3
#   s10  land: sync только по второму родителю                   L2b         L2
#   s11  land: любой merge в окне — sync                         L6          L2
#   s12  land: полная история вместо окна                        L7          L1
#   s13  land: отказ оставляет merge --no-commit в чекауте      L1          L4
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "$HERE/_toy.sh"
TREE="$(t86_derevo "${1:-}" "$HERE")" || { printf 'NOT_IMPLEMENTED: корень дерева не найден\n' >&2; exit 2; }
HIST="$(git -C "$TREE" rev-parse --show-toplevel 2>/dev/null)" || { printf 'NOT_IMPLEMENTED: дерево без git-истории\n' >&2; exit 2; }
for f in accept_task_commit.sh land_agent.sh spawn_agent.sh; do
  git -C "$HIST" cat-file -e "$T86_DO_086:scripts/$f" 2>/dev/null \
    || { printf 'NOT_IMPLEMENTED: снимок до-086 %s:scripts/%s недоступен\n' "$T86_DO_086" "$f" >&2; exit 2; }
done
S="$(mktemp -d "${TMPDIR:-/tmp}/gejty086_stuby.XXXXXX")" || exit 2
trap 'rm -rf "$S"' EXIT
TOY="$HERE/_toy.sh"

do086() { git -C "$HIST" show "$T86_DO_086:scripts/$1"; }

stub_derevo() {  # <код> → печать пути дерева-подмены
  local d="$S/derevo-$1"
  mkdir -p "$d" && cp -r "$TREE/scripts" "$d/scripts" && cp -r "$TREE/.githooks" "$d/.githooks" || return 1
  do086 accept_task_commit.sh > "$d/scripts/accept_task_commit.do086.sh"
  do086 land_agent.sh > "$d/scripts/land_agent.do086.sh"
  case "$1" in
    s1) cp "$d/scripts/accept_task_commit.do086.sh" "$d/scripts/accept_task_commit.sh" ;;
    s2) cp "$d/scripts/land_agent.do086.sh" "$d/scripts/land_agent.sh" ;;
    s3) rm -f "$d/.githooks/pre-merge-commit" ;;
    s4) do086 spawn_agent.sh > "$d/scripts/spawn_agent.sh" ;;
    s5) cat > "$d/scripts/accept_task_commit.sh" <<EOF
#!/usr/bin/env bash
# стаб s5: (а) на каждый путь каждого коммита окна
. '$TOY'
while [ \$# -gt 1 ]; do case "\$1" in --root) R="\$2";; --source) SRC="\$2";; --branch) B="\$2";; --author) A="\$2";; esac; shift 2; done
git -C "\$R" fetch -q --no-tags "\$SRC" HEAD 2>/dev/null || exit 2
for c in \$(git -C "\$R" rev-list "\$B..FETCH_HEAD"); do
  git -C "\$R" diff-tree --no-commit-id -r --name-only "\$c" | while IFS= read -r p; do printf '  FAIL коммит вне зоны: %s %s %s\n' "\$A" "\${c:0:8}" "\$p"; done
done
printf 'ОТКАЗ 086 (accept): %s; %s\n' "\$O_A" "\$O_VA" >&2
exit 1
EOF
    ;;
    s6) cat > "$d/scripts/land_agent.sh" <<EOF
#!/usr/bin/env bash
# стаб s6: (а) на каждый путь каждого коммита окна
. '$TOY'
while [ \$# -gt 1 ]; do case "\$1" in --root) R="\$2";; --branch) B="\$2";; esac; shift 2; done
for c in \$(git -C "\$R" rev-list "main..\$B"); do
  git -C "\$R" diff-tree --no-commit-id -r --name-only "\$c" | while IFS= read -r p; do printf '  FAIL коммит вне зоны: %s %s\n' "\${c:0:8}" "\$p"; done
done
printf 'ОТКАЗ 086 (land): %s; %s\n' "\$O_A" "\$O_VA" >&2
exit 1
EOF
    ;;
    s7) cat > "$d/.githooks/pre-merge-commit" <<EOF
#!/usr/bin/env bash
# стаб s7: отказ любому merge
. '$TOY'
printf 'ОТКАЗ 086 (pre-merge-commit): %s; %s\n' "\$O_B" "\$O_VB" >&2
exit 1
EOF
    ;;
    s8) cat > "$d/scripts/accept_task_commit.sh" <<EOF
#!/usr/bin/env bash
# стаб s8: суд зон каждого коммита окна по union зон автора — без land-метки ветки
. '$TOY'
SELF="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"
ARGS=("\$@")
while [ \$# -gt 1 ]; do case "\$1" in --root) R="\$2";; --source) SRC="\$2";; --branch) B="\$2";; esac; shift 2; done
. "\$SELF/lib_zones.sh"; LIB_ZONES_ROOT="\$R"
out="\$(zones_load "\$R" 2>/dev/null)" || exit 2
git -C "\$R" fetch -q --no-tags "\$SRC" HEAD 2>/dev/null || exit 2
bad=0
for c in \$(git -C "\$R" rev-list --no-merges "\$B..FETCH_HEAD"); do
  an="\$(git -C "\$R" log -1 --format=%an "\$c")"
  awk -F'\t' -v a="\$an" '\$1 == a { f = 1 } END { exit !f }' "\$out/zones_scoped" || continue
  while IFS= read -r p; do
    zones_match_path "\$out" "\$an" "\$p" >/dev/null || { printf '  FAIL коммит вне зоны: %s %s %s\n' "\$an" "\${c:0:8}" "\$p"; bad=1; }
  done < <(git -C "\$R" diff-tree --no-commit-id -r --name-only "\$c")
done
rm -rf "\$out"
[ "\$bad" -eq 0 ] || { printf 'ОТКАЗ 086 (accept): %s; %s\n' "\$O_A" "\$O_VA" >&2; exit 1; }
exec bash "\$SELF/accept_task_commit.do086.sh" "\${ARGS[@]}"
EOF
    ;;
    s9) cat > "$d/scripts/land_agent.sh" <<EOF
#!/usr/bin/env bash
# стаб s9: (в) по каждому коммиту окна без границы первой заморозки файла
. '$TOY'
SELF="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"
ARGS=("\$@")
while [ \$# -gt 1 ]; do case "\$1" in --root) R="\$2";; --branch) B="\$2";; esac; shift 2; done
CHARTER_LIB=1; . "\$SELF/check_charter.sh"; set +e
g() { git -C "\$R" "\$@"; }; bad() { :; }
viol=0
for c in \$(git -C "\$R" rev-list "main..\$B"); do
  while IFS= read -r f; do
    [ -n "\$f" ] || continue
    is_charter_path "\$f" "\$R" || continue
    razreshil "\$c" "\$f" || { printf '  FAIL уставной документ изменён без разрешения владельца: %s в %s\n' "\$f" "\${c:0:8}"; viol=1; }
  done < <(charter_diff_paths "\$c" "\$R")
done
[ "\$viol" -eq 0 ] || { printf 'ОТКАЗ 086 (land): %s; %s\n' "\$O_V" "\$O_VV" >&2; exit 1; }
exec bash "\$SELF/land_agent.do086.sh" "\${ARGS[@]}"
EOF
    ;;
    s10|s11) cat > "$d/scripts/land_agent.sh" <<EOF
#!/usr/bin/env bash
# стаб $1: sync-проверка merge окна — s10: только второй родитель; s11: любой merge
. '$TOY'
SELF="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"
ARGS=("\$@")
while [ \$# -gt 1 ]; do case "\$1" in --root) R="\$2";; --branch) B="\$2";; esac; shift 2; done
for m in \$(git -C "\$R" rev-list --merges "main..\$B"); do
  p1="\$(git -C "\$R" rev-parse "\$m^1")"; p2="\$(git -C "\$R" rev-parse "\$m^2")"
  if [ '$1' = s11 ] || { git -C "\$R" merge-base --is-ancestor "\$p2" main && ! git -C "\$R" merge-base --is-ancestor "\$p2" "\$p1"; }; then
    printf 'ОТКАЗ 086 (land): %s; sha %s; %s\n' "\$O_B" "\$m" "\$O_VB" >&2; exit 1
  fi
done
exec bash "\$SELF/land_agent.do086.sh" "\${ARGS[@]}"
EOF
    ;;
    s12) cat > "$d/scripts/land_agent.sh" <<EOF
#!/usr/bin/env bash
# стаб s12: полные check_zones/check_charter на проспективном ленде вместо окна
. '$TOY'
SELF="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"
ARGS=("\$@")
while [ \$# -gt 1 ]; do case "\$1" in --root) R="\$2";; --branch) B="\$2";; esac; shift 2; done
T="\$(mktemp -d)"; trap 'git -C "\$R" worktree remove --force "\$T/p" >/dev/null 2>&1; rm -rf "\$T"' EXIT
git -C "\$R" worktree add -q --detach "\$T/p" main >/dev/null 2>&1 || exit 2
git -C "\$T/p" -c user.name=s12 -c user.email=s12@l -c commit.gpgsign=false -c core.hooksPath=/dev/null merge -q --no-ff -m "land: \$B" "\$B" >/dev/null 2>&1 || exit 2
viol=0
zo="\$(bash "\$SELF/check_zones.sh" "\$T/p" 2>&1)" || { printf '%s\n' "\$zo" | grep -F 'FAIL коммит вне зоны:'; printf 'ОТКАЗ 086 (land): %s; %s\n' "\$O_A" "\$O_VA" >&2; viol=1; }
co="\$(bash "\$SELF/check_charter.sh" "\$T/p" 2>&1)" || { printf '%s\n' "\$co" | grep -F '  FAIL '; printf 'ОТКАЗ 086 (land): %s; %s\n' "\$O_V" "\$O_VV" >&2; viol=1; }
[ "\$viol" -eq 0 ] || exit 1
exec bash "\$SELF/land_agent.do086.sh" "\${ARGS[@]}"
EOF
    ;;
    s13) cat > "$d/scripts/land_agent.sh" <<EOF
#!/usr/bin/env bash
# стаб s13: верный диагноз (а), но отказ оставляет в главном чекауте merge --no-commit ветки
# (индекс с принесёнными правками, MERGE_HEAD); ref main не тронут — обход Critic086 круга 1
. '$TOY'
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null
SELF="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"
ARGS=("\$@")
while [ \$# -gt 1 ]; do case "\$1" in --root) R="\$2";; --branch) B="\$2";; esac; shift 2; done
. "\$SELF/lib_zones.sh"; LIB_ZONES_ROOT="\$R"
out="\$(zones_load "\$R" 2>/dev/null)" || exit 2
bad=0
for c in \$(git -C "\$R" rev-list --no-merges "main..\$B"); do
  an="\$(git -C "\$R" log -1 --format=%an "\$c")"
  awk -F'\t' -v a="\$an" '\$1 == a { f = 1 } END { exit !f }' "\$out/zones_scoped" || continue
  while IFS= read -r p; do
    zones_match_path "\$out" "\$an" "\$p" >/dev/null || { printf '  FAIL коммит вне зоны: %s %s %s\n' "\$an" "\${c:0:8}" "\$p"; bad=1; }
  done < <(git -C "\$R" diff-tree --no-commit-id -r --name-only "\$c")
done
rm -rf "\$out"
[ "\$bad" -eq 0 ] || {
  git -C "\$R" -c user.name=s13 -c user.email=s13@l -c commit.gpgsign=false -c core.hooksPath=/dev/null merge -q --no-ff --no-commit "\$B" >/dev/null 2>&1
  printf 'ОТКАЗ 086 (land): %s; %s\n' "\$O_A" "\$O_VA" >&2
  exit 1
}
exec bash "\$SELF/land_agent.do086.sh" "\${ARGS[@]}"
EOF
    ;;
    *) return 1 ;;
  esac
  chmod +x "$d/scripts/"*.sh "$d/.githooks/"* 2>/dev/null
  printf '%s\n' "$d"
}

PAK=(
  's1 A1 A4' 's2 L2 L4' 's3 H1 H2' 's4 S1 S0' 's5 A4 A1' 's6 L4 L1'
  's7 H2 H1' 's8 A5 A1' 's9 L5 L3' 's10 L2b L2' 's11 L6 L2' 's12 L7 L1'
  's13 L1 L4'
)
pojmano=0; diff_zel=0; vsego=0; probojev=0
for str in "${PAK[@]}"; do
  read -r kod kl dif <<<"$str"
  vsego=$((vsego + 1))
  d="$(stub_derevo "$kod")" || { printf 'ПРОБОЙ: %s: дерево-подмена не построено\n' "$kod"; probojev=$((probojev + 1)); continue; }
  msg="$("kletka_$kl" "$d" "$S/$kod-k" 2>&1)"; rc=$?
  case "$rc" in
    1) pojmano=$((pojmano + 1)); printf 'стаб %s: пойман клеткой %s (%s)\n' "$kod" "$kl" "$(printf '%s' "$msg" | tail -n 1)" ;;
    0) printf 'СТАБ ЖИВ: %s прошёл клетку %s\n' "$kod" "$kl" ;;
    *) probojev=$((probojev + 1)); printf 'ПРОБОЙ: %s: клетка %s не исполнена\n' "$kod" "$kl" ;;
  esac
  msg="$("kletka_$dif" "$d" "$S/$kod-d" 2>&1)"; rc=$?
  case "$rc" in
    0) diff_zel=$((diff_zel + 1)); printf 'диффпроба %s: клетка %s зелёная\n' "$kod" "$dif" ;;
    1) printf 'ДИФФПРОБА КРАСНА: %s на клетке %s: %s\n' "$kod" "$dif" "$(printf '%s' "$msg" | tail -n 1)" ;;
    *) probojev=$((probojev + 1)); printf 'ПРОБОЙ: %s: диффпроба %s не исполнена\n' "$kod" "$dif" ;;
  esac
done
printf 'стаб-пак 086: %d/%d поймано, диффпроба %d/%d\n' "$pojmano" "$vsego" "$diff_zel" "$vsego"
[ "$probojev" -eq 0 ] || exit 2
[ "$vsego" -gt 0 ] && [ "$pojmano" -eq "$vsego" ] && [ "$diff_zel" -eq "$vsego" ] || exit 1
exit 0
