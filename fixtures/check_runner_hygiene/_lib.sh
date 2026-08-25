# НЕ ФИКСТУРА (нет case_-префикса): общая библиотека зелёных корней для фикстур
# барьера check_runner_hygiene (контракт 011). Подключается строкой
#   . "$(dirname "$0")/_lib.sh"
# в каждом case_*.sh. Зелёный корень = эталонный раннер (_ref_runner.sh) + ПОЛНАЯ норма
# (маркер приёмки судьи v2 + carve-out правила 16 + аннотированный 010). Красный корень
# каждая фикстура делает сама, ломая в нём ровно одну вещь — дефект обманки наблюдаем
# ровно на той ветви, куда её подают (Н-39).
HYG="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mk_norm_agents() {  # <корень> — AGENTS.md с полной зелёной нормой
  cat > "$1/AGENTS.md" <<'EOF'
# Устав (игрушечный — материал фикстур check_runner_hygiene, контракт 011)

## Воркфлоу

ПРИЁМКА-СУДЬИ (v2, Н-48): судья (критик/адверсарий/ревьюер) гоняет ТОЛЬКО scoped-регресс
затронутых барьеров (`verify_antiplacebo --scope <ключ>`) и git-diff неизменности
frozen-барьеров; полный прогон — только CI, от судьи он не требуется.

16. Всё по-русски. Временное — в `./tmp`, не в системном `/tmp`.
    ИСКЛЮЧЕНИЕ (carve-out, РАЗРЕШИЛ-ВЛАДЕЛЕЦ 2026-08-24): scratch раннера
    `scripts/verify_antiplacebo.sh` живёт вне стерегомого дерева (в системном `/tmp`
    или под `$VERIFY_ANTIPLACEBO_SCRATCH`).
EOF
}

mk_010_annotated() {  # <корень> — contracts/010 с пометкой v+1 у п.8
  mkdir -p "$1/contracts"
  cat > "$1/contracts/010-topologija-orkestrator-arhitektor.md" <<'EOF'
# Контракт 010 (игрушечный — материал фикстур check_runner_hygiene, контракт 011)

## §Приёмка

8. Регресс: `npm run check:ci-parity` → 0; `bash scripts/verify_antiplacebo.sh` → 0
   (отменено грилингом 2026-08-24, см. contracts/011: судье — scoped-регресс затронутых
   барьеров, полный прогон — CI, Н-48).
EOF
}

mk_green_root() {  # <каталог> — эталонный раннер + полная норма
  mkdir -p "$1/scripts"
  cp "$HYG/_ref_runner.sh" "$1/scripts/verify_antiplacebo.sh"
  chmod +x "$1/scripts/verify_antiplacebo.sh"
  mk_norm_agents "$1"
  mk_010_annotated "$1"
}
