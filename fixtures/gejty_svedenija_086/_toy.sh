# fixtures/gejty_svedenija_086/_toy.sh — каркас семьи 086 «гейты точек сведения».
#
# Имя НЕ red_*.sh / case_*.sh намеренно: каркас пробой не считается (прецедент _repo.sh).
# Подключается source'ом из red_*.sh семьи; сам ничего не исполняет.
#
# Содержит: (1) оракул грамматики отказа — строки И-4 контракта 086 побайтово, в ПАМЯТИ
# батареи (правило 8: ожидание не перечитывается с диска проверяемого); (2) строитель
# игрушечного мира (главный чекаут, замороженный контракт 900, устав ustav/1); (3) клетки
# точек accept / land / pre-merge-commit / spawn; (4) обманные стабы — генераторы стаб-деревьев.
# Привязка стаба к клетке (Н-39) — ТОЛЬКО в red_stuby_086.sh, в коде, не в прозе контракта.
#
# Соглашение клетки: kletka_<код> <ДЕРЕВО> <СКРАТЧ> → rc 0 зелёная, rc 1 красная (печатает
# причину одной строкой), rc 2 не исполнена (игрушка не построилась — пробой, НЕ красное
# предъявление). ДЕРЕВО — корень проверяемого дерева: его scripts/ и .githooks/ копируются в
# игрушку, точки зовутся из ДЕРЕВО/scripts/.

O_A='правило (а) путь вне frozen-ЗОНЫ автора'
O_B='правило (б) sync-merge'
O_V='правило (в) устав-путь без строки РАЗРЕШИЛ'
O_VA='выход: путь в зону — v+1 со словом владельца'
O_VB='выход: пересобери ветку без merge main'
O_VV='выход: строка РАЗРЕШИЛ-ВЛАДЕЛЕЦ в том же коммите — словом владельца'
O_OTKAZ='ОТКАЗ 086 ('

# Снимок точек ДО контракта 086 — коммит, на котором написан контракт (источник обманных
# стабов-снимков s1/s2/s4: «точка, пропускающая нарушение»).
T86_DO_086=b25a0262d55263c164f8fb5fe815dbcdf48bf78b

t86_g() {  # <репо> <git…> — герметичный git сборки игрушки (хуки выключены)
  local r="$1"; shift
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git -C "$r" -c commit.gpgsign=false -c core.hooksPath=/dev/null -c init.defaultBranch=main "$@"
}
t86_kak() {  # <репо> <роль> <git…> — git от имени роли: author == committer
  local r="$1" a="$2"; shift 2
  t86_g "$r" -c user.name="$a" -c user.email="$a@dev-harness.local" "$@"
}
t86_zhivoj() {  # <репо> <роль> <git…> — git роли с АКТИВНЫМИ хуками репо (суд хука — предмет)
  local r="$1" a="$2"; shift 2
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
    git -C "$r" -c commit.gpgsign=false -c user.name="$a" -c user.email="$a@dev-harness.local" "$@"
}
t86_kom() {  # <репо> <роль> <сообщение> [<путь> <содержимое>]…
  local r="$1" a="$2" msg="$3"; shift 3
  while [ "$#" -ge 2 ]; do
    mkdir -p "$r/$(dirname "$1")" && printf '%s\n' "$2" > "$r/$1" && t86_g "$r" add -- "$1" || return 1
    shift 2
  done
  t86_kak "$r" "$a" commit -q --allow-empty -m "$msg"
}
t86_mir() {  # <R> <ДЕРЕВО> — главный чекаут игрушки
  local R="$1" TREE="$2" t
  mkdir -p "$R" && t86_g "$R" init -q -b main >/dev/null 2>&1 || return 1
  cp -r "$TREE/scripts" "$R/scripts" && cp -r "$TREE/.githooks" "$R/.githooks" || return 1
  mkdir -p "$R/contracts" "$R/src" "$R/doc900"
  printf '# Норма игрушки 086\n' > "$R/AGENTS.md"
  printf '# Роадмап игрушки 086\n' > "$R/ROADMAP.md"
  printf '# Контракт 900 — игрушка 086\n\nЗОНА implementer: src/\nЗОНА architect: doc900/ ROADMAP.md contracts/900-igrushka.md\n' \
    > "$R/contracts/900-igrushka.md"
  printf 'k\n' > "$R/src/.keep"; printf 'k\n' > "$R/doc900/.keep"
  t86_g "$R" add -A && t86_kak "$R" Фикстура commit -q -m 'основание игрушки 086' || return 1
  for t in ustav/1 frozen/contracts/900/1 id/CONTRACT/901 id/CONTRACT/902; do
    t86_kak "$R" Фикстура tag -a "$t" -m "$t" || return 1
  done
}
t86_klon() {  # <R> <КЛОН> <ветка> — одноразовый клон агента на ветке (без core.hooksPath)
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git clone -q "$1" "$2" 2>/dev/null \
    && t86_g "$2" checkout -q -B rabota "origin/$3"
}
t86_est() { printf '%s' "$1" | grep -Fq -- "$2"; }
t86_net_lishnih() {  # <вывод> <ярлык…> — ни одного ярлыка чужого правила
  local out="$1" s; shift
  for s in "$@"; do t86_est "$out" "$s" && { printf 'лишний ярлык «%s» — диагноз не изолирован\n' "$s"; return 1; }; done
  return 0
}
t86_nesjot() {  # <вывод> <строка…> — каждая строка присутствует
  local out="$1" s; shift
  for s in "$@"; do t86_est "$out" "$s" || { printf 'вывод не несёт «%s»\n' "$s"; return 1; }; done
  return 0
}
t86_accept() { bash "$1/scripts/accept_task_commit.sh" --root "$2" --source "$3" --branch "$4" --author "$5" 2>&1; }
t86_land() { bash "$1/scripts/land_agent.sh" --root "$2" --branch "$3" --worktree "$4" 2>&1; }

# ── accept_task_commit.sh ────────────────────────────────────────────────────
t86_otkaz_accept() {  # <ДЕРЕВО> <R> <КЛОН> <ветка> <роль> <ярлык> <выход> <лишний1> <лишний2> <строка…>
  local TREE="$1" R="$2" SRC="$3" b="$4" a="$5" ja="$6" vy="$7" l1="$8" l2="$9" pered posle out rc; shift 9
  pered="$(t86_g "$R" rev-parse "$b")"
  out="$(t86_accept "$TREE" "$R" "$SRC" "$b" "$a")"; rc=$?
  posle="$(t86_g "$R" rev-parse "$b")"
  [ "$rc" -eq 1 ] || { printf 'rc=%s (ожидался 1 — именованный отказ)\n' "$rc"; return 1; }
  [ "$pered" = "$posle" ] || { printf 'ветка %s сдвинута при отказе\n' "$b"; return 1; }
  t86_nesjot "$out" "$O_OTKAZ" "$ja" "$vy" "$@" || return 1
  t86_net_lishnih "$out" "$l1" "$l2"
}
t86_prinjato() {  # <ДЕРЕВО> <R> <КЛОН> <ветка> <роль>
  local pered posle out rc
  pered="$(t86_g "$2" rev-parse "$4")"
  out="$(t86_accept "$1" "$2" "$3" "$4" "$5")"; rc=$?
  posle="$(t86_g "$2" rev-parse "$4")"
  [ "$rc" -eq 0 ] || { printf 'честный приём отвергнут rc=%s: %s\n' "$rc" "$(printf '%s' "$out" | grep -m1 -E 'ОТКАЗ|NOT_IMPLEMENTED')"; return 1; }
  [ "$pered" != "$posle" ] || { printf 'ветка %s не сдвинута при приёме\n' "$4"; return 1; }
  t86_net_lishnih "$out" "$O_OTKAZ"
}
kletka_A1() {  # (а) на accept: implementer коммитит путь вне своей зоны
  local R="$2/A1" SRC="$2/A1-klon" sha
  t86_mir "$R" "$1" && t86_g "$R" branch wip/900/implementer main && t86_klon "$R" "$SRC" wip/900/implementer \
    && t86_kom "$SRC" implementer 'путь вне зоны' docs/owner/vne-zony.md 'x' || return 2
  sha="$(t86_g "$SRC" rev-parse HEAD)"
  t86_otkaz_accept "$1" "$R" "$SRC" wip/900/implementer implementer "$O_A" "$O_VA" "$O_B" "$O_V" \
    docs/owner/vne-zony.md "${sha:0:8}"
}
kletka_A2() {  # (б) на accept: в клоне merge main → wip (sync-merge), main впереди ветки
  local R="$2/A2" SRC="$2/A2-klon" m
  t86_mir "$R" "$1" && t86_g "$R" branch wip/900/implementer main \
    && t86_kom "$R" orchestrator 'main ушёл вперёд' HANDOFF.md 'h' \
    && t86_klon "$R" "$SRC" wip/900/implementer \
    && t86_kom "$SRC" implementer 'в зоне' src/a.txt 'a' \
    && t86_kak "$SRC" implementer merge -q --no-ff -m "Merge branch 'main' into wip/900/implementer" origin/main || return 2
  m="$(t86_g "$SRC" rev-parse HEAD)"
  t86_otkaz_accept "$1" "$R" "$SRC" wip/900/implementer implementer "$O_B" "$O_VB" "$O_A" "$O_V" "$m"
}
kletka_A3() {  # (в) на accept: architect правит устав-путь своей зоны без строки РАЗРЕШИЛ
  local R="$2/A3" SRC="$2/A3-klon" sha
  t86_mir "$R" "$1" && t86_g "$R" branch wip/900/architect main && t86_klon "$R" "$SRC" wip/900/architect \
    && t86_kom "$SRC" architect 'правка роадмапа без строки' ROADMAP.md '# Роадмап игрушки 086, правка' || return 2
  sha="$(t86_g "$SRC" rev-parse HEAD)"
  t86_otkaz_accept "$1" "$R" "$SRC" wip/900/architect architect "$O_V" "$O_VV" "$O_A" "$O_B" ROADMAP.md "${sha:0:8}"
}
kletka_A4() {  # позитив accept: implementer в своей зоне
  local R="$2/A4" SRC="$2/A4-klon"
  t86_mir "$R" "$1" && t86_g "$R" branch wip/900/implementer main && t86_klon "$R" "$SRC" wip/900/implementer \
    && t86_kom "$SRC" implementer 'в зоне' src/a.txt 'a' || return 2
  t86_prinjato "$1" "$R" "$SRC" wip/900/implementer implementer
}
kletka_A5() {  # позитив accept: до-заморозочная пачка architect контракта 901 (зон 901 ещё нет)
  local R="$2/A5" SRC="$2/A5-klon"
  t86_mir "$R" "$1" && t86_g "$R" branch wip/901/architect main && t86_klon "$R" "$SRC" wip/901/architect \
    && t86_kom "$SRC" architect 'черновик 901 и его фикстура' contracts/901-chernovik.md '# Контракт 901 — черновик' \
         doc901/plan.md 'p' || return 2
  t86_prinjato "$1" "$R" "$SRC" wip/901/architect architect
}
kletka_A6() {  # позитив accept: правка устава со строкой РАЗРЕШИЛ в том же коммите
  local R="$2/A6" SRC="$2/A6-klon"
  t86_mir "$R" "$1" && t86_g "$R" branch wip/900/architect main && t86_klon "$R" "$SRC" wip/900/architect \
    && t86_kom "$SRC" architect "$(printf 'правка роадмапа со строкой\n\nРАЗРЕШИЛ-ВЛАДЕЛЕЦ: ROADMAP.md игрушечная причина 086')" \
         ROADMAP.md '# Роадмап игрушки 086, разрешённая правка' || return 2
  t86_prinjato "$1" "$R" "$SRC" wip/900/architect architect
}

# ── land_agent.sh ────────────────────────────────────────────────────────────
# Отпечаток главного чекаута — оракул И-2 «ref main и главный чекаут не тронуты» (находка
# Critic086 круга 1: сверка одного ref main принимала отказ, оставивший в главном чекауте
# `merge --no-commit` — индекс с принесёнными правками и MERGE_HEAD; стаб s13). Строки:
# незавершённая операция — маркеры каталога git (merge, cherry-pick, revert, rebase, am,
# bisect); HEAD — ветка и коммит; файлы против индекса — отслеживаемые, неотслеживаемые и
# игнорируемые (status -uall --ignored); индекс с флагами (ls-files -s -v: флаги
# assume-unchanged/skip-worktree прячут правку файла от status). Снимается в ПАМЯТЬ оракула до
# и после вызова точки (правило 8); замер индекс не пишет (--no-optional-locks). ORIG_HEAD и
# FETCH_HEAD вне отпечатка: их пишут и честные операции, пригодность чекаута они не меняют.
t86_chekaut() {  # <R> → stdout отпечаток «<часть> <значение>» по строке; rc ≠ 0 — не снят
  local r="$1" gd fs idx m
  gd="$(t86_g "$r" rev-parse --absolute-git-dir)" \
    && fs="$(t86_g "$r" --no-optional-locks status --porcelain=v1 -uall --ignored)" \
    && idx="$(t86_g "$r" ls-files -s -v)" || return 1
  for m in MERGE_HEAD MERGE_MSG MERGE_MODE AUTO_MERGE MERGE_AUTOSTASH CHERRY_PICK_HEAD REVERT_HEAD \
           REBASE_HEAD sequencer rebase-merge rebase-apply BISECT_LOG; do
    [ ! -e "$gd/$m" ] || printf 'операция %s\n' "$m"
  done
  printf 'HEAD %s %s\n' "$(t86_g "$r" symbolic-ref -q HEAD)" "$(t86_g "$r" rev-parse -q --verify HEAD)"
  [ -z "$fs" ] || printf '%s\n' "$fs" | sed 's/^/файл /'
  [ -z "$idx" ] || printf '%s\n' "$idx" | tr '\t' ' ' | sed 's/^/индекс /'
}
t86_razlichie() {  # <отпечаток до> <отпечаток после> → первая расходящаяся строка (для причины)
  diff <(printf '%s\n' "$1") <(printf '%s\n' "$2") | grep -m1 -E '^[<>] ' \
    | sed -e 's/^< /было «/' -e 's/^> /стало «/' -e 's/$/»/'
}
t86_otkaz_land() {  # <ДЕРЕВО> <R> <ветка> <worktree> <ярлык> <выход> <лишний1> <лишний2> <строка…>
  local TREE="$1" R="$2" b="$3" wt="$4" ja="$5" vy="$6" l1="$7" l2="$8" pered posle ch_pered ch_posle out rc; shift 8
  pered="$(t86_g "$R" rev-parse main)"
  ch_pered="$(t86_chekaut "$R")" || return 2
  out="$(t86_land "$TREE" "$R" "$b" "$wt")"; rc=$?
  posle="$(t86_g "$R" rev-parse main)"
  ch_posle="$(t86_chekaut "$R")" || ch_posle='отпечаток не снят'
  [ "$rc" -eq 1 ] || { printf 'rc=%s (ожидался 1 — именованный отказ)\n' "$rc"; return 1; }
  [ "$pered" = "$posle" ] || { printf 'main сдвинут при отказе\n'; return 1; }
  [ "$ch_pered" = "$ch_posle" ] || { printf 'главный чекаут тронут при отказе (операция, HEAD, файлы или индекс): %s\n' "$(t86_razlichie "$ch_pered" "$ch_posle")"; return 1; }
  t86_nesjot "$out" "$O_OTKAZ" "$ja" "$vy" "$@" || return 1
  t86_net_lishnih "$out" "$l1" "$l2"
}
t86_posazheno() {  # <ДЕРЕВО> <R> <ветка> <worktree>
  local pered posle out rc
  pered="$(t86_g "$2" rev-parse main)"
  out="$(t86_land "$1" "$2" "$3" "$4")"; rc=$?
  posle="$(t86_g "$2" rev-parse main)"
  [ "$rc" -eq 0 ] || { printf 'честный ленд отвергнут rc=%s: %s\n' "$rc" "$(printf '%s' "$out" | grep -m1 -E 'ОТКАЗ|NOT_IMPLEMENTED|FAIL')"; return 1; }
  [ "$pered" != "$posle" ] || { printf 'main не сдвинут при ленде\n'; return 1; }
  t86_net_lishnih "$out" "$O_OTKAZ"
}
kletka_L1() {  # (а) на land: implementer коммитит путь вне зоны
  local R="$2/L1" W="$2/L1-wt" sha
  t86_mir "$R" "$1" && t86_g "$R" branch wip/900/implementer main && t86_g "$R" worktree add -q "$W" wip/900/implementer \
    && t86_kom "$W" implementer 'путь вне зоны' docs/owner/vne-zony.md 'x' || return 2
  sha="$(t86_g "$W" rev-parse HEAD)"
  t86_otkaz_land "$1" "$R" wip/900/implementer "$W" "$O_A" "$O_VA" "$O_B" "$O_V" docs/owner/vne-zony.md "${sha:0:8}"
}
kletka_L2() {  # (б) на land: ветка несёт merge main → wip (второй родитель — main)
  local R="$2/L2" W="$2/L2-wt" m
  t86_mir "$R" "$1" && t86_g "$R" branch wip/900/implementer main && t86_g "$R" worktree add -q "$W" wip/900/implementer \
    && t86_kom "$W" implementer 'в зоне' src/a.txt 'a' \
    && t86_kom "$R" orchestrator 'main ушёл вперёд' HANDOFF.md 'h' \
    && t86_kak "$W" implementer merge -q --no-ff -m "Merge branch 'main' into wip/900/implementer" main || return 2
  m="$(t86_g "$W" rev-parse HEAD)"
  t86_otkaz_land "$1" "$R" wip/900/implementer "$W" "$O_B" "$O_VB" "$O_A" "$O_V" "$m"
}
kletka_L2b() {  # (б) на land: sync-merge с main ПЕРВЫМ родителем (обратный порядок родителей)
  local R="$2/L2b" W="$2/L2b-wt" T="$2/L2b-tmp" m
  t86_mir "$R" "$1" && t86_g "$R" branch wip/900/implementer main && t86_g "$R" worktree add -q "$W" wip/900/implementer \
    && t86_kom "$W" implementer 'в зоне' src/a.txt 'a' \
    && t86_kom "$R" orchestrator 'main ушёл вперёд' HANDOFF.md 'h' \
    && t86_g "$R" worktree add -q --detach "$T" main \
    && t86_kak "$T" implementer merge -q --no-ff -m 'сведение main с веткой (обратный порядок)' wip/900/implementer || return 2
  m="$(t86_g "$T" rev-parse HEAD)"
  t86_g "$R" worktree remove --force "$T" && t86_g "$W" reset -q --hard "$m" || return 2
  t86_otkaz_land "$1" "$R" wip/900/implementer "$W" "$O_B" "$O_VB" "$O_A" "$O_V" "$m"
}
kletka_L3() {  # (в) на land: architect правит устав-путь своей зоны без строки РАЗРЕШИЛ
  local R="$2/L3" W="$2/L3-wt" sha
  t86_mir "$R" "$1" && t86_g "$R" branch wip/900/architect main && t86_g "$R" worktree add -q "$W" wip/900/architect \
    && t86_kom "$W" architect 'правка роадмапа без строки' ROADMAP.md '# Роадмап игрушки 086, правка' || return 2
  sha="$(t86_g "$W" rev-parse HEAD)"
  t86_otkaz_land "$1" "$R" wip/900/architect "$W" "$O_V" "$O_VV" "$O_A" "$O_B" ROADMAP.md "${sha:0:8}"
}
kletka_L4() {  # позитив land: честная ветка в зоне, main ушёл вперёд без конфликта
  local R="$2/L4" W="$2/L4-wt"
  t86_mir "$R" "$1" && t86_g "$R" branch wip/900/implementer main && t86_g "$R" worktree add -q "$W" wip/900/implementer \
    && t86_kom "$W" implementer 'в зоне' src/a.txt 'a' \
    && t86_kom "$R" orchestrator 'main ушёл вперёд' HANDOFF.md 'h' || return 2
  t86_posazheno "$1" "$R" wip/900/implementer "$W"
}
kletka_L5() {  # позитив land: правки черновика 902 ДО его первой заморозки (граница устава)
  local R="$2/L5" W="$2/L5-wt"
  t86_mir "$R" "$1" && t86_g "$R" branch wip/902/architect main && t86_g "$R" worktree add -q "$W" wip/902/architect \
    && t86_kom "$W" architect 'черновик 902' contracts/902-chernovik.md \
         "$(printf '# Контракт 902\n\nЗОНА architect: contracts/902-chernovik.md doc902/')" \
    && t86_kom "$W" architect 'черновик 902, правка до заморозки' contracts/902-chernovik.md \
         "$(printf '# Контракт 902 (правка)\n\nЗОНА architect: contracts/902-chernovik.md doc902/')" \
    && t86_kak "$W" Фикстура tag -a frozen/contracts/902/1 -m 'заморозка 902' || return 2
  t86_posazheno "$1" "$R" wip/902/architect "$W"
}
kletka_L6() {  # позитив land: внутреннее слияние двух линий ветки (ни один родитель не из main)
  local R="$2/L6" W="$2/L6-wt" B="$2/L6-bok"
  t86_mir "$R" "$1" && t86_g "$R" branch wip/900/implementer main && t86_g "$R" branch bok main \
    && t86_g "$R" worktree add -q "$W" wip/900/implementer && t86_g "$R" worktree add -q "$B" bok \
    && t86_kom "$B" implementer 'боковая линия' src/b.txt 'b' \
    && t86_kom "$W" implementer 'основная линия' src/a.txt 'a' \
    && t86_kak "$W" implementer merge -q --no-ff -m 'сведение двух линий ветки' bok || return 2
  t86_posazheno "$1" "$R" wip/900/implementer "$W"
}
kletka_L7() {  # позитив land: в main НИЖЕ базы окна — старые нарушения зоны и устава
  local R="$2/L7" O="$2/L7-old" W="$2/L7-wt"
  t86_mir "$R" "$1" && t86_g "$R" branch staraja main && t86_g "$R" worktree add -q "$O" staraja \
    && t86_kom "$O" implementer 'старое: путь вне зоны' docs/staroe.md 's' \
    && t86_kak "$R" orchestrator merge -q --no-ff -m 'land: wip/900/implementer' staraja \
    && t86_kom "$R" orchestrator 'старое: правка устава без строки' ROADMAP.md '# Роадмап игрушки 086, старая правка' \
    && t86_g "$R" worktree remove --force "$O" && t86_g "$R" branch -D staraja >/dev/null \
    && t86_g "$R" branch wip/900/implementer main && t86_g "$R" worktree add -q "$W" wip/900/implementer \
    && t86_kom "$W" implementer 'в зоне' src/a.txt 'a' || return 2
  t86_posazheno "$1" "$R" wip/900/implementer "$W"
}

# ── .githooks/pre-merge-commit и spawn_agent.sh ─────────────────────────────
t86_mir_s_hukami() {  # <R> <ДЕРЕВО> <ветка> <worktree> — хуки репо активны, ветка с коммитом в зоне
  t86_mir "$1" "$2" && t86_g "$1" config core.hooksPath .githooks \
    && t86_g "$1" branch "$3" main && t86_g "$1" worktree add -q "$4" "$3" \
    && t86_kom "$4" implementer 'в зоне' src/a.txt 'a'
}
kletka_H1() {  # (б) на pre-merge-commit: merge main в wip-ветку при активных хуках
  local R="$2/H1" W="$2/H1-wt" pered posle out rc
  t86_mir_s_hukami "$R" "$1" wip/900/implementer "$W" && t86_kom "$R" orchestrator 'main ушёл вперёд' HANDOFF.md 'h' || return 2
  pered="$(t86_g "$W" rev-parse HEAD)"
  out="$(t86_zhivoj "$W" implementer merge --no-ff -m "Merge branch 'main' into wip/900/implementer" main 2>&1)"; rc=$?
  posle="$(t86_g "$W" rev-parse HEAD)"
  [ "$rc" -ne 0 ] || { printf 'sync-merge создан (rc 0) — хук не отказал\n'; return 1; }
  [ "$pered" = "$posle" ] || { printf 'HEAD ветки сдвинут при отказе\n'; return 1; }
  t86_nesjot "$out" "$O_OTKAZ" "$O_B" "$O_VB" || return 1
  t86_net_lishnih "$out" "$O_A" "$O_V"
}
kletka_H2() {  # позитив хука: merge ветки В main (направление ленда) при активных хуках
  local R="$2/H2" W="$2/H2-wt" pered posle out rc
  t86_mir_s_hukami "$R" "$1" wip/900/implementer "$W" && t86_kom "$R" orchestrator 'main ушёл вперёд' HANDOFF.md 'h' || return 2
  pered="$(t86_g "$R" rev-parse main)"
  out="$(t86_zhivoj "$R" orchestrator merge --no-ff -m 'land: wip/900/implementer' wip/900/implementer 2>&1)"; rc=$?
  posle="$(t86_g "$R" rev-parse main)"
  [ "$rc" -eq 0 ] && [ "$pered" != "$posle" ] || { printf 'merge в main отвергнут rc=%s: %s\n' "$rc" "$(printf '%s' "$out" | grep -m1 -E 'ОТКАЗ|NOT_IMPLEMENTED')"; return 1; }
  return 0
}
kletka_H3() {  # позитив хука: merge боковой линии (не main) в wip-ветку при активных хуках
  local R="$2/H3" W="$2/H3-wt" B="$2/H3-bok" pered posle out rc
  t86_mir_s_hukami "$R" "$1" wip/900/implementer "$W" && t86_g "$R" branch bok main \
    && t86_g "$R" worktree add -q "$B" bok && t86_kom "$B" implementer 'боковая линия' src/b.txt 'b' || return 2
  pered="$(t86_g "$W" rev-parse HEAD)"
  out="$(t86_zhivoj "$W" implementer merge --no-ff -m 'сведение двух линий ветки' bok 2>&1)"; rc=$?
  posle="$(t86_g "$W" rev-parse HEAD)"
  [ "$rc" -eq 0 ] && [ "$pered" != "$posle" ] || { printf 'несинхронный merge отвергнут rc=%s: %s\n' "$rc" "$(printf '%s' "$out" | grep -m1 -E 'ОТКАЗ|NOT_IMPLEMENTED')"; return 1; }
  return 0
}
t86_spawn() {  # <ДЕРЕВО> <R> <TMPDIR> → stdout spawn_agent
  TMPDIR="$3" bash "$1/scripts/spawn_agent.sh" --author implementer --root "$2" 2>&1
}
kletka_S0() {  # позитив spawn: worktree и ветка созданы (контракт выхода 016)
  local R="$2/S0" out rc wt
  t86_mir "$R" "$1" && mkdir -p "$2/S0-tmp" || return 2
  out="$(t86_spawn "$1" "$R" "$2/S0-tmp")"; rc=$?
  wt="$(printf '%s\n' "$out" | sed -n 's/^WORKTREE=//p')"
  [ "$rc" -eq 0 ] && [ -d "$wt" ] && t86_g "$R" show-ref --verify --quiet refs/heads/wip/001/implementer \
    || { printf 'спавн не создал worktree/ветку rc=%s\n' "$rc"; return 1; }
  return 0
}
kletka_S1() {  # (б) в worktree от spawn_agent: хуки активны без ручной настройки клона
  local R="$2/S1" out rc wt pered posle
  t86_mir "$R" "$1" && mkdir -p "$2/S1-tmp" || return 2
  out="$(t86_spawn "$1" "$R" "$2/S1-tmp")"; rc=$?
  wt="$(printf '%s\n' "$out" | sed -n 's/^WORKTREE=//p')"
  [ "$rc" -eq 0 ] && [ -d "$wt" ] || { printf 'спавн отказал rc=%s: %s\n' "$rc" "$(printf '%s' "$out" | grep -m1 'ОТКАЗ')"; return 1; }
  t86_kom "$wt" implementer 'в зоне' src/a.txt 'a' && t86_kom "$R" orchestrator 'main ушёл вперёд' HANDOFF.md 'h' || return 2
  pered="$(t86_g "$wt" rev-parse HEAD)"
  out="$(t86_zhivoj "$wt" implementer merge --no-ff -m "Merge branch 'main' into wip/001/implementer" main 2>&1)"; rc=$?
  posle="$(t86_g "$wt" rev-parse HEAD)"
  [ "$rc" -ne 0 ] && [ "$pered" = "$posle" ] || { printf 'sync-merge в worktree спавна создан — хуки неактивны\n'; return 1; }
  t86_nesjot "$out" "$O_B" "$O_VB"
}

# ── прогон клеток файла ──────────────────────────────────────────────────────
# t86_prognat <ДЕРЕВО> <СКРАТЧ> <клетка…> — печать ЗЕЛЕНО/КРАСНО/НЕ ИСПОЛНЕНА по каждой;
# итог в T86_ZEL/T86_KRA/T86_NEI.
t86_prognat() {
  local TREE="$1" S="$2" k msg rc; shift 2
  T86_ZEL=0; T86_KRA=0; T86_NEI=0
  for k in "$@"; do
    msg="$("kletka_$k" "$TREE" "$S" 2>&1)"; rc=$?
    case "$rc" in
      0) T86_ZEL=$((T86_ZEL + 1)); printf 'ЗЕЛЕНО: %s\n' "$k" ;;
      1) T86_KRA=$((T86_KRA + 1)); printf 'КРАСНО: %s: %s\n' "$k" "$(printf '%s' "$msg" | tail -n 1)" ;;
      *) T86_NEI=$((T86_NEI + 1)); printf 'НЕ ИСПОЛНЕНА: %s: игрушка не построилась (пробой — не красное предъявление)\n' "$k" ;;
    esac
  done
}
t86_itog() {  # <имя файла> → rc 0 все зелёные; 1 есть красные; 2 есть неисполненные
  printf 'ИТОГ 086 %s: зелёных %d, красных %d, не исполнено %d\n' "$1" "$T86_ZEL" "$T86_KRA" "$T86_NEI"
  [ "$T86_NEI" -eq 0 ] || return 2
  [ "$T86_KRA" -eq 0 ] || return 1
  [ "$T86_ZEL" -gt 0 ] || { printf 'пустая выборка — не проверено ничего\n'; return 1; }
  return 0
}
t86_derevo() {  # <аргумент или пусто> <каталог семьи> → печать корня проверяемого дерева
  local d="${1:-$2/../..}"
  (cd "$d" 2>/dev/null && pwd -P) || return 1
}

# ── позитивный контроль: честные ленды 080–083 из истории (контракт 086 §Приёмочный критерий)
# Таблица ожиданий — в ПАМЯТИ батареи: <код> <land-merge> <ветка> <rc> <ярлык|-> <sha|-> <путь|->.
# Ожидаемо красные — ровно принятые находки (И-9 контракта 086); любое иное расхождение —
# красная клетка с названным лендом.
T86_ISTORIJA=(
  'R1 55e74368b720611b27cb77dd729350a56e3f01b2 wip/080/architect 0 - - -'
  'R2 09dd3d7ce77c41319bbb85b55873acd33c544eee wip/080/architect 0 - - -'
  'R3 0b79145d538f97e9e51f6a069c65937066083a1c wip/080/b2-architect 1 б 6ffc8f92c625ed38e07b94beca1ee233a9e3f7c3 -'
  'R4 60c0b424030b5969601e8163da82bded685f49cf wip/080/b3-implementer 1 б f1d7f73733597b5e47807a1e38f57162b71ff85c -'
  'R5 c63a35bc0b8fb642a2bf00e06f166a0b29706068 wip/081/architect-v2 0 - - -'
  'R6 4290f17f6b952f0ca44123dfb7d0b6175837ec9f wip/081/architect 0 - - -'
  'R7 939de6ef4f41c6f5811f760359eadc9ea4baf304 wip/082/architect 0 - - -'
  'R8 9bfbfd6795e7361dc75f47a1cbb02d533e6accd0 wip/083/architect 1 а 7dcfef2f7baea8b96f8d62efccc6a1531986548c docs/owner/2026-10-05-a3-pr-vs-push-analiz.md'
  'R9 b9843999c0c6cb61a2ff8f2dbfb7e05d84276d38 wip/083/architect 1 б 2c01b1ed9c93f2ad14959f99511581de5526f68d -'
)
T86_LIMIT_SEK=60
t86_istorija_klon() {  # <ДЕРЕВО> <КЛОН> — клон истории дерева; main := верхний ленд таблицы (R9)
  local hist
  hist="$(git -C "$1" rev-parse --show-toplevel 2>/dev/null)" || return 1
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git clone -q --shared --no-checkout "$hist" "$2" 2>/dev/null || return 1
  t86_g "$2" cat-file -e b9843999c0c6cb61a2ff8f2dbfb7e05d84276d38^{commit} 2>/dev/null || return 1
  t86_g "$2" update-ref refs/heads/main b9843999c0c6cb61a2ff8f2dbfb7e05d84276d38 || return 1
  t86_g "$2" for-each-ref --format='%(refname)' refs/remotes/ | while IFS= read -r r; do t86_g "$2" update-ref -d "$r"; done
  t86_g "$2" show-ref --verify --quiet refs/tags/ustav/1 || return 1
}
t86_istorija() {  # <ДЕРЕВО> <КЛОН> <строка таблицы> → rc 0 зелёная, 1 красная, 2 не исполнена
  local TREE="$1" K="$2" kod m vetka orc ja sha put p1 p2 out rc t0 t1 dt jl
  read -r kod m vetka orc ja sha put <<<"$3"
  t86_g "$K" cat-file -e "$m^{commit}" 2>/dev/null || return 2
  p1="$(t86_g "$K" rev-parse "$m^1")" && p2="$(t86_g "$K" rev-parse "$m^2")" || return 2
  t0="$(date +%s)"
  out="$(bash "$TREE/scripts/gejt_svedenija.sh" okno "$K" "$p1" "$p2" "$vetka" land 2>&1)"; rc=$?
  t1="$(date +%s)"; dt=$((t1 - t0))
  [ "$dt" -le "$T86_LIMIT_SEK" ] || { printf '%s: проверка окна %s с > %s с\n' "$kod" "$dt" "$T86_LIMIT_SEK"; return 1; }
  [ "$rc" -eq "$orc" ] || { printf '%s: rc=%s (ожидался %s) за %s с: %s\n' "$kod" "$rc" "$orc" "$dt" "$(printf '%s' "$out" | grep -m1 -E 'ОТКАЗ|NOT_IMPLEMENTED')"; return 1; }
  case "$ja" in
    -) t86_net_lishnih "$out" "$O_OTKAZ" || return 1 ;;
    а) t86_nesjot "$out" "$O_A" "$O_VA" "${sha:0:8}" "$put" && t86_net_lishnih "$out" "$O_B" "$O_V" || return 1 ;;
    б) t86_nesjot "$out" "$O_B" "$O_VB" "$sha" && t86_net_lishnih "$out" "$O_A" "$O_V" || return 1 ;;
  esac
  printf '%s: %s за %s с\n' "$kod" "$( [ "$orc" -eq 0 ] && echo 'зелёный' || echo "принятая находка ($ja ${sha:0:8})")" "$dt"
  return 0
}
t86_istorija_fajl() {  # <ДЕРЕВО> <СКРАТЧ> <код…> — прогон подмножества таблицы
  local TREE="$1" S="$2" kod str msg rc; shift 2
  T86_ZEL=0; T86_KRA=0; T86_NEI=0
  if [ ! -f "$TREE/scripts/gejt_svedenija.sh" ]; then
    printf 'красная: предмет отсутствует: %s/scripts/gejt_svedenija.sh\n' "$TREE"
    for kod in "$@"; do printf 'КРАСНО: %s: НЕ ИСПОЛНЯЛАСЬ (предмет отсутствует)\n' "$kod"; T86_KRA=$((T86_KRA + 1)); done
    return 0
  fi
  t86_istorija_klon "$TREE" "$S/hist" || { printf 'НЕ ИСПОЛНЕНА: история 080–083 недоступна (клон, объекты лендов, ustav/1)\n'; T86_NEI=1; return 0; }
  for kod in "$@"; do
    for str in "${T86_ISTORIJA[@]}"; do
      [ "${str%% *}" = "$kod" ] || continue
      msg="$(t86_istorija "$TREE" "$S/hist" "$str" 2>&1)"; rc=$?
      case "$rc" in
        0) T86_ZEL=$((T86_ZEL + 1)); printf 'ЗЕЛЕНО: %s\n' "$msg" ;;
        1) T86_KRA=$((T86_KRA + 1)); printf 'КРАСНО: %s\n' "$(printf '%s' "$msg" | tail -n 1)" ;;
        *) T86_NEI=$((T86_NEI + 1)); printf 'НЕ ИСПОЛНЕНА: %s: объект ленда отсутствует\n' "$kod" ;;
      esac
    done
  done
}
