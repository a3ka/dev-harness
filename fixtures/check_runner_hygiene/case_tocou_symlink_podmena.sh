# ПРИЧИНА: между канонизацией и созданием
# Ветвь (tocou): раннер проверяет scratch (спуск до существующего предка + pwd -P), а
# создаёт его отдельным `mkdir -p "$SCRATCH"` — имя разрешается ЗАНОВО, и подмена
# symlink-компонента между проверкой и созданием уводит lock/run ВНУТРЬ стерегомого
# дерева (находка 1 адверсария, круг 2). Ветвь подменяет symlink обёрткой mkdir ДО
# настоящего mkdir — детерминированно, без гонки на время. Зелёный контроль — эталон:
# создаёт скратч от канонического физического предка (подмена бессильна); красный —
# раннер, чтущий проверенный путь буквально (mkdir по исходной строке).
set -euo pipefail
. "$(dirname "$0")/_lib.sh"
G="$WORK/green"; mk_green_root "$G"
"$BARRIER" "$G" tocou

R="$WORK/red"; mkdir -p "$R/scripts"
cat > "$R/scripts/verify_antiplacebo.sh" <<'EOF'
#!/usr/bin/env bash
# обманка: канонизация-проверка есть, создание — ПО ИСХОДНОМУ имени: mkdir -p
# разрешает подменённый symlink заново (как раннер до закрытия находки 1, круг 2)
set -uo pipefail
R="${1:-}"; [ -n "$R" ] || exit 1
R="$(cd "$R" 2>/dev/null && pwd)" || exit 1
S="${VERIFY_ANTIPLACEBO_SCRATCH:-}"; [ -n "$S" ] || exit 1
case "$S" in /*) ;; *) S="$PWD/$S" ;; esac
_p="$S"; _t=""
while [ ! -d "$_p" ] && [ -n "$_p" ]; do _t="/${_p##*/}$_t"; _p="${_p%/*}"; done
if [ -n "$_p" ] && _c="$(cd "$_p" 2>/dev/null && pwd -P)"; then
  _r="$(cd "$R" 2>/dev/null && pwd -P)"
  case "$_c$_t" in "$_r"|"$_r"/*) echo 'ОТКАЗ: scratch внутри дерева' >&2; exit 2 ;; esac
fi
mkdir -p "$S"
D="$S/run-$$"; mkdir -p "$D"; printf 'log\n' > "$D/log"
printf '%s %s %s\n' "$$" 0 "$(date +%s)" > "$S/verify_antiplacebo-00000000.lock"
sleep 2
exit 0
EOF
chmod +x "$R/scripts/verify_antiplacebo.sh"
"$BARRIER" "$R" tocou
