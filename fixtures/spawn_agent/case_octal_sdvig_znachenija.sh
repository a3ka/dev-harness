# ПРИЧИНА: уже существует
#
# Контракт 019 v2 (блокер 1 критика, :119): проба обязана пиновать ЗНАЧЕНИЕ ветки.
# Живой факт (измерен критиком на main): `--nnn 042` давал rc 0 и BRANCH=wip/034/architect
# (042-октал = 34) — тихая съезжка; rc-последовательность «rc 0 → rc 1 повтор» НЕ
# отличала фикшенный код от сломанного. Красное предъявляется ПИНОМ ЗНАЧЕНИЯ, а не rc.
#
# Контракт 023, ветвь (ii) — гейт явного номера: зелёный --nnn-спавн теперь требует
# ПРОВЕНАНС = DUAL-CONTROL (тег id/CONTRACT/<NNN> на origin ∧ строка
# «<NNN> → <tag-object-sha>» в манифесте registry/contracts.tsv на origin/main ∧ sha
# совпали), потому положительный контроль строит резерв ЦЕЛИКОМ в toy (mint_rezerv:
# toy-origin — file-path bare, прецедент 022 red_push_*; ls-remote без сети). Прежняя
# редакция контроля (голый --nnn 19 без резерва) на новом коде умирает «номер 019 не
# выдан» — конверсия 023, не ослабление пробы.
#
# Входы (А-82 — различающие ассерты ДО первой зелёно-красной пары):
#   * зелёный контроль: mint_rezerv 019 → `--nnn 19` rc 0, BRANCH=wip/019/architect;
#   * предмет (ассерт ДО красного кандидата, А-73): mint_rezerv 042 → `--nnn 042`
#     rc 0, BRANCH=wip/042/architect ДОСЛОВНО + refs/heads/wip/042/architect жив
#     (значение подтверждено предметом, не только печатью спавна);
#   * красный кандидат: повторный спавн того же номера → rc 1 «уже существует» —
#     прежнее поведение сохраняется (уникальный ключ спавна Q2); засчитывается
#     повторным прогоном раннера.
# Побочный эффект спавна — worktree вне toy (${TMPDIR}/dev-harness-worktrees/):
# каждый успешный спавн разбирается своим WORKTREE= (как red_gejt).
set -uo pipefail
# shellcheck disable=SC1091
. "$(dirname "$0")/_repo.sh"

R="$WORK/repo"
make_repo "$R"
toy_origin "$R" >/dev/null

# spawn через $BARRIER (учёт вызовов раннера); out/rc — глобальные, worktree убран
spawn() {  # <аргументы spawn>… → $out/$rc
  out="$("$BARRIER" --root "$R" "$@" 2>"$WORK/err")" && rc=0 || rc=$?
  local wt
  wt="$(printf '%s\n' "$out" | sed -n 's/^WORKTREE=//p' | head -1)"
  if [ -n "$wt" ] && [ -d "$wt" ]; then rm -rf "$wt"; fi
}

# ── зелёный контроль: спавн без ведущего нуля при ПОЛНОМ резерве ───────────────
mint_rezerv "$R" 019
spawn --author architect --nnn 19
br="$(printf '%s\n' "$out" | awk -F= '/^BRANCH=/ {print $2; exit}')"
if [ "$rc" -ne 0 ] || [ "$br" != 'wip/019/architect' ]; then
  printf 'ОТКАЗ: --nnn 19 при полном резерве дал rc %s BRANCH=%s, ожидался rc 0 wip/019/architect: %s %s\n' "$rc" "${br:-<пусто>}" "$(cat "$WORK/err")" "$out" >&2
  exit 1
fi

# ── предмет: ведущий ноль даёт ЗНАЧЕНИЕ 042, а не октал-съезжку 034 ────────────
mint_rezerv "$R" 042
spawn --author architect --nnn 042
br="$(printf '%s\n' "$out" | awk -F= '/^BRANCH=/ {print $2; exit}')"
if [ "$br" != 'wip/042/architect' ]; then
  printf 'ОТКАЗ: --nnn 042 дал BRANCH=%s, ожидался дословно wip/042/architect — октал-съезжка значения: %s %s\n' "${br:-<пусто>}" "$(cat "$WORK/err")" "$out" >&2
  exit 1
fi
if ! git -C "$R" show-ref --verify --quiet refs/heads/wip/042/architect; then
  printf 'ОТКАЗ: ветки wip/042/architect нет в refs/heads — значение BRANCH не подтверждено предметом\n' >&2
  exit 1
fi

# ── повторный спавн того же номера → именованный отказ (прежнее поведение) ─────
spawn --author architect --nnn 042   # ожидание: rc 1 «уже существует»
