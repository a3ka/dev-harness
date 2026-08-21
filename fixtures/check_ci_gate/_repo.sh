# Каркас подставного репозитория для фикстур `check_ci_gate`.
#
# Имя НЕ case_*.sh намеренно: сам каркас фикстурой не считается.
#
# Собирает репозиторий с одним коммитом, remote origin (парсится гейтом) и
# веткой origin/main, указывающей на HEAD — зелёная основа гейта. curl
# подменяется скриптом в $WORK/bin: он печатает содержимое $WORK/curl.json,
# какой ответ нужен — решает фикстура. Гейт живой сети не видит.
g() {
  local r="$1"; shift
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$r" \
      -c user.name=Фикстура -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null \
      -c init.defaultBranch=main "$@"
}

make_repo() {  # <каталог>
  local r="$1"
  mkdir -p "$r" "$r/files"
  printf 'предмет\n' > "$r/files/a.txt"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$r"
  g "$r" add -A
  g "$r" commit -q -m 'основание'
  g "$r" remote add origin https://github.com/example/probe.git
  g "$r" update-ref refs/remotes/origin/main "$(g "$r" rev-parse HEAD)"
  mkdir -p "$WORK/bin"
  printf '#!/usr/bin/env bash\ncat "%s/curl.json"\n' "$WORK" > "$WORK/bin/curl"
  chmod +x "$WORK/bin/curl"
  ci_green > "$WORK/curl.json"
}

# Ответы CI: один и тот же коммит, разные исходы.
ci_green() {
  printf '{"total_count":2,"check_runs":[{"name":"ci","conclusion":"success"},{"name":"lint","conclusion":"success"}]}'
}
ci_red() {
  printf '{"total_count":2,"check_runs":[{"name":"ci","conclusion":"success"},{"name":"test","conclusion":"failure"}]}'
}
ci_empty() {
  printf '{"total_count":0,"check_runs":[]}'
}
ci_dead() {  # curl-образный отказ: сеть/HTTP — код 7, тела нет
  printf '#!/usr/bin/env bash\necho "curl: (7) Failed to connect" >&2\nexit 7\n' > "$WORK/bin/curl"
}
