# Каркас красных проб анти-плацебо на КОНСУЛЬТАНТЕ (контракт 029, решение владельца Q2:
# механизм ПРОТИВ ВРУЩЕГО консультанта, а не дисциплина в прозе).
#
# Имя НЕ case_*.sh и НЕ red_*.sh намеренно (прецедент _repo.sh, _zhnets.sh).
#
# Контракт вызова: «$BARRIER --root <корень> --otvet <файл ответа>».
#
# ОРАКУЛ ЖИВЁТ В ПАМЯТИ ПРОВЕРЯЮЩЕГО (правило 8 анти-плацебо): честные rc и sha снимает
# САМ каркас ДО построения ответа, командой в игрушечном дереве; диск проверяемого как
# источник истины не перечитывается. Нормализация вывода — ЕДИНЫЙ примитив `sha_vyvoda`:
# захват `$( )` (завершающие LF отброшены) + sha256 от `printf '%s'`. Барьер обязан
# нормализовать ТАК ЖЕ; переизобретение нормализации в теле пробы запрещено.
if [ -z "${WORK:-}" ]; then
  REPO="$(cd "$(dirname "$0")/../.." && pwd -P)"
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/konsult029.XXXXXX")"
  BARRIER="$REPO/scripts/verify_consultant.sh"
  trap 'chmod -R u+w "$WORK" 2>/dev/null || true; rm -rf "$WORK"' EXIT
fi
export LC_ALL=C.UTF-8

kgi() {  # герметичный git в игрушке
  local r="$1"; shift
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$r" -c user.name=Фикстура -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"
}

# Игрушечное дерево: git-репозиторий с одним коммитом и каталогом вердиктов.
igrushka() {  # <корень>
  local r="$1"
  mkdir -p "$r/verdicts/consultant" "$r/forks"
  printf 'основание игрушки консультанта\n' > "$r/README.md"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$r"
  kgi "$r" add -- README.md
  kgi "$r" commit -q -m 'основание'
}

# ЧУЖОЙ КОНФИГ (граница Г2): внешний diff-драйвер проверяемого корня. Сам скрипт лежит
# ВНЕ корня — иначе он попал бы в `git status` игрушки и разошёл бы оракул близнеца;
# маркер пишется В корень, потому что предъявляется именно запись в проверяемое дерево.
vneshnij_diff() {  # <корень> <файл-маркера от корня> <каталог для скрипта вне корня>
  local r="$1" m="$2" s="$3/write-diff.sh"
  mkdir -p "$3"
  printf '#!/bin/sh\nprintf "side-effect\\n" > "%s/%s"\n' "$r" "$m" > "$s"
  chmod 755 "$s"
  kgi "$r" config diff.external "$s"
}

# ГОЛЫЙ ХУК (граница Г3): исполняемый хук в .git/hooks проверяемого корня. Конфиг при
# этом ПУСТ (ровно init-ключи) — канал живёт вне конфига.
krjuk_marker() {  # <корень> <имя хука> <файл-маркера от корня>
  local r="$1" h="$2" m="$3"
  printf '#!/bin/sh\nprintf "marker\\n" > "%s/%s"\n' "$r" "$m" > "$r/.git/hooks/$h"
  chmod 755 "$r/.git/hooks/$h"
}

# НЕВИННЫЙ локальный конфиг: оставить ровно то, что кладёт `git init` (перечень Г2).
konfig_nevinnyj() {  # <корень>
  local r="$1" k
  for k in $(kgi "$r" config --list --local | sed -n 's/^\([^=]*\)=.*/\1/p'); do
    case "$k" in
      core.repositoryformatversion|core.filemode|core.bare|core.logallrefupdates) ;;
      core.ignorecase|core.precomposeunicode|core.symlinks) ;;
      *) kgi "$r" config --unset-all "$k" ;;
    esac
  done
}

# СУПЕРПРОЕКТ С ГИТЛИНКОМ (граница Г4): конфиг КОРНЯ невинен, канал живёт в
# конфиг-пространстве субмодуля, недостижимом для скана корня.
superproekt() {  # <корень> <каталог-источник субмодуля>
  local r="$1" src="$2"
  igrushka "$src"
  igrushka "$r"
  kgi "$r" -c protocol.file.allow=always submodule add -q "$src" sub
  kgi "$r" add -- .gitmodules sub
  kgi "$r" commit -q -m 'гитлинк'
  konfig_nevinnyj "$r"
}

# Злые настройки СУБМОДУЛЯ: core.fsmonitor в его конфиге + его собственный хук.
zlo_submodulja() {  # <корень super> <маркер fsmonitor> <маркер хука> <каталог вне корня>
  local r="$1" mf="$2" mh="$3" s="$4/fsmon.sh"
  mkdir -p "$4"
  printf '#!/bin/sh\nprintf "marker\\n" > "%s/%s"\nexit 1\n' "$r" "$mf" > "$s"
  chmod 755 "$s"
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git --git-dir="$r/.git/modules/sub" config core.fsmonitor "$s"
  printf '#!/bin/sh\nprintf "marker\\n" > "%s/%s"\n' "$r" "$mh" \
    > "$r/.git/modules/sub/hooks/post-index-change"
  chmod 755 "$r/.git/modules/sub/hooks/post-index-change"
}

# ЧЕСТНЫЙ оракул: rc команды в корне игрушки (в память проверяющего).
rc_komandy() {  # <корень> <команда>
  local r="$1" c="$2" rc=0
  ( cd "$r" && eval "$c" ) >/dev/null 2>&1 || rc=$?
  printf '%s' "$rc"
}

# ЧЕСТНЫЙ оракул: sha256 нормализованного вывода (stdout+stderr) команды в корне игрушки.
sha_vyvoda() {  # <корень> <команда>
  local r="$1" c="$2" o
  o="$( cd "$r" && eval "$c" 2>&1 )" || true
  printf '%s' "$o" | sha256sum | cut -d' ' -f1
}

# Ответ консультанта. Шапка обязательна; тройки ОСНОВАНИЕ-ДЕРЕВО добавляются `osnovanie`.
otvet_shapka() {  # <файл> <предмет> <модель> <рекомендация>
  {
    printf 'ПРЕДМЕТ: %s\n' "$2"
    printf 'МОДЕЛЬ: %s\n' "$3"
    printf 'ВОПРОС: подставной инженерный форк\n'
    printf 'РЕКОМЕНДАЦИЯ: %s\n' "$4"
  } > "$1"
}

# Тройка блока основания — ЕДИНЫЙ источник грамматики блока.
osnovanie() {  # <файл> <команда> <rc> <sha>
  {
    printf 'ОСНОВАНИЕ-ДЕРЕВО:\n'
    printf 'КОМАНДА: %s\n' "$2"
    printf 'RC: %s\n' "$3"
    printf 'ВЫВОД-SHA256: %s\n' "$4"
  } >> "$1"
}

# Честное основание: оракул снимается каркасом сам.
osnovanie_chestnoe() {  # <файл> <корень> <команда>
  osnovanie "$1" "$3" "$(rc_komandy "$2" "$3")" "$(sha_vyvoda "$2" "$3")"
}

zapusk() {  # <аргументы барьера…>
  rc=0
  out="$("$BARRIER" "$@" 2>&1)" || rc=$?
}

# СЛОМАННЫЙ ИНСТРУМЕНТ (инв. 10, «нечем проверить»): обёртка `sha256sum`, печатающая
# КОРРЕКТНЫЙ текст настоящего инструмента на пустом вводе и выходящая ненулём. Текст
# снят с НАСТОЯЩЕГО sha256sum при загрузке каркаса — единый источник значения, побайтово;
# переизобретение empty-hash в теле пробы запрещено. Оракулы проб (`sha_vyvoda`,
# `rc_komandy`) снимаются настоящим инструментом ДО затенения — правило 8.
#
# PATH-затенение здесь — СИМУЛЯЦИЯ НЕРАБОТОСПОСОБНОГО ИНСТРУМЕНТА, НЕ защита от
# враждебного PATH: граница доверия закрыта арбитражем (`verdicts/arbitration/
# tcb-granica-put-029.md`, §2) — среда вызова целиком есть TCB, недоверенные входы ровно
# два (файл ответа и дерево `--root`). Ловится связка «текст верен, rc не привязан» при
# ЛЮБОМ способе поломки инструмента: busybox-вариант, битый диск, частичная установка —
# атакующий для этого класса не нужен.
SHA_PUSTOGO_TEKST="$(printf '' | sha256sum)"

slomannyj_sha256sum() {  # <каталог> <код выхода>
  local d="$1" code="$2"
  mkdir -p "$d"
  cat > "$d/sha256sum" <<EOF
#!/bin/sh
cat >/dev/null 2>&1 || true
printf '%s\n' '$SHA_PUSTOGO_TEKST'
exit $code
EOF
  chmod 755 "$d/sha256sum"
}

# Вызов барьера с обёрткой ПЕРВОЙ в PATH: затенение живёт только на время вызова.
zapusk_pod_obertkoj() {  # <каталог обёртки> <аргументы барьера…>
  local d="$1"; shift
  rc=0
  out="$(PATH="$d:$PATH" "$BARRIER" "$@" 2>&1)" || rc=$?
}

zhdu_rc() {  # <ожидаемый rc> <что предъявляется>
  [ "$rc" -eq "$1" ] || {
    printf 'ОТКАЗ: %s — барьер вернул rc %s, ожидался %s. Вывод:\n%s\n' "$2" "$rc" "$1" "$out" >&2
    exit 1; }
}

zhdu_text() {  # <подстрока> <что предъявляется>
  printf '%s\n' "$out" | grep -Fq -- "$1" || {
    printf 'ОТКАЗ: %s — в выводе нет «%s». Вывод:\n%s\n' "$2" "$1" "$out" >&2
    exit 1; }
}

net_texta() {  # <подстрока> <что предъявляется>
  if printf '%s\n' "$out" | grep -Fq -- "$1"; then
    printf 'ОТКАЗ: %s — в выводе ЕСТЬ «%s», а его быть не должно. Вывод:\n%s\n' "$2" "$1" "$out" >&2
    exit 1
  fi
}
