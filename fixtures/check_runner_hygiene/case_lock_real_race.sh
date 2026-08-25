# ПРИЧИНА: БЕЗ трёх полей
# Ветвь (race): барьер ловит НЕатомарный захват в РЕАЛЬНОЙ гонке — обманка создаёт
# lock ПУСТЫМ (set -C), выдерживает паузу и только затем пишет три поля обычным
# printf; второй одновременный старт, увидев пустой lock, считает владельца
# неназванным, УДАЛЯЕТ файл и захватывает его сам: оба старта выходят rc=0
# (обход круга 2 критика: последовательная проба после заполнения не наблюдала
# окна «создан — заполнен»). Зелёный контроль — эталон: захват create-с-содержимым
# (ln темпа), ровно один старт rc=3 «занят».
set -euo pipefail
. "$(dirname "$0")/_lib.sh"
G="$WORK/green"; mk_green_root "$G"
"$BARRIER" "$G" race

R="$WORK/red"; mkdir -p "$R/scripts"
cat > "$R/scripts/verify_antiplacebo.sh" <<'EOF'
#!/usr/bin/env bash
# обманка: пустое окно между созданием и заполнением lock (обход круга 2)
set -uo pipefail
S="${VERIFY_ANTIPLACEBO_SCRATCH:?}"
R1="$(cd "$1" && pwd)"
L="$S/verify_antiplacebo-$(printf '%s' "$R1" | sha256sum | cut -c1-8).lock"
for i in 1 2 3 4 5; do
  if [ -f "$L" ]; then
    pid=""; read -r pid _ < "$L" 2>/dev/null || true
    if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
      printf 'занят: уже идёт (pid %s)\n' "$pid" >&2
      exit 3
    fi
    rm -f "$L"        # пустой lock — «владелец неназван»: удалить и захватить — ДЕФЕКТ
    continue
  fi
  if ( set -C; : > "$L" ) 2>/dev/null; then break; fi
done
sleep 1.5             # окно «создан пустой — заполняется», наблюдаемо зондом барьера
printf '%s %s %s\n' "$$" "$(ps -o pgid= -p "$$" | tr -d ' ')" "$(date +%s)" > "$L"
D="$S/run-$$"; mkdir -p "$D"; printf 'log\n' > "$D/log"
trap 'rm -rf "$D"; rm -f "$L"' EXIT
sleep 1
exit 0
EOF
chmod +x "$R/scripts/verify_antiplacebo.sh"
"$BARRIER" "$R" race
