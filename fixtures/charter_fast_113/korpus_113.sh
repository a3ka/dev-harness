#!/usr/bin/env bash
# korpus_113.sh — построитель корпусов дифференциальных деревьев контракта 113.
# Прецедент герметичности: fixtures/check_charter/_repo.sh (gpgsign/hooksPath/GIT_CONFIG_GLOBAL).
# Каждый корпус — ПОДСТАВНОЙ репозиторий ВНЕ стерегомого дерева (скратч батареи).
#
# Использование:  korpus_113.sh <скратч-каталог> <имя>
# Выход:          ROOT=<путь>  и, где есть, CACHE=<путь к файлу кеша --incr>
#
# Имена и предмет (Δ-номера — клетки red_113.sh):
#   d0_chistoe     чистое: замороженный план, черновичная правка ДО заморозки, чистый кончик
#   d1_staroe      нарушение на глубине ~46 (50 наполнятелей до, 45 после)
#   d2_merge       unlawful правка на боковой + merge --no-ff (судятся И коммит, И merge)
#   d3_otkat       нарушение + откат к побайтово замороженному содержимому
#   d4_udalenie    удаление замороженного плана без строки
#   d5_pereim      переименование AGENTS.md без строки
#   d7_kesh_linii  кеш сторонней линии (в′): нарушение на боковой, влитое clean-merge'ом с пустой дельтой
#   d8_kesh_valid  валидный кеш = HEAD~1, нарушение в HEAD
#   d9_bokovaja_zamorozka  кеш от успешного барьера ДО заморозки плана; заморозка на
#                 БОКОВОЙ линии (тег не предок кеша) влита merge -s ours (пустая
#                 дельта к первому родителю): per-document окно since..HEAD включает
#                 коммит-кеш, глобальное cache..HEAD — теряет (обход круга 2 критика)
#   d10_novoe_imja  свежее уставное имя из nonce РАННЕРА (KORPUS113_NONCE; литера-
#                 ла нет ни в одной клетке — «зашитая константа» не может его знать;
#                 вердикт адверсария круг 1): документ добавлен и заморожен В КОРПУСЕ,
#                 затем правка БЕЗ строки; плюс законная правка AGENTS.md СО строкой
set -euo pipefail

BASEROOT() {  # <каталог> — общее основание: AGENTS+ROADMAP+план, черновик, заморозка, ustav
  local r="$1"
  mkdir -p "$r/plans" "$r/contracts" "$r/tmp"
  printf '# норма системы\nправило 1: правило без механизма не существует\n' > "$r/AGENTS.md"
  printf '# роадмап\nшаг 5 сделан\n'                                        > "$r/ROADMAP.md"
  printf 'предмет плана, критерий готовности, исполнители\n'                > "$r/plans/001-p.md"
  _git "$r" init -q -b main
  _git "$r" config user.name Фикстура113
  _git "$r" config user.email fixture113@local
  _git "$r" config commit.gpgsign false
  _git "$r" config core.hooksPath /dev/null
  _commit_all "$r" 'основание: норма, роадмап, план'
  # черновичная правка плана ДО заморозки (M-статус, без строки — законный черновик)
  printf 'уточнение черновика до заморозки\n' >> "$r/plans/001-p.md"
  _commit_all "$r" 'правка черновика плана до заморозки'
  _git "$r" tag -a frozen/plans/001/1 -m 'план утверждён'
  _git "$r" tag -a ustav/1 -m 'устав действует'
}

_git() {
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -c user.name=Фикстура113 -c user.email=fixture113@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null -C "$1" "${@:2}"
}
_commit_all() { _git "$1" add -A; _git "$1" commit -q -m "$2"; }
_commit_body() { _git "$1" add -A; _git "$1" commit -q -F -; }
_filler() {  # <каталог> <n> — наполнятель истории: каждый коммит несёт РЕАЛЬНУЮ дельту
  # (правка не-уставного файла). Пустые коммиты не расходуют бюджет `-n` окна git log
  # (коммиты с пустым диффом пропускаются ДО лимита) — окно лжи s1 обязано быть
  # измеримо меньше глубины нарушения.
  local i
  for ((i = 0; i < "$2"; i++)); do
    printf 'наполнитель %d\n' "$i" >> "$1/napolnitel.txt"
    _commit_all "$1" "наполнитель $i"
  done
}

BARRIER113="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/scripts/check_charter.sh"
# Единственный источник свежего имени d10: раннер логирует (вызов --imja), корпус
# строит (KORPUS113_NONCE), обманный стаб s11 его не знает — в этом и предмет клетки.
_novoe_imja() {  # <nonce> → contracts/<NNN>-novoe-imja-<slug>.md; NNN — ровно три цифры
  local h nnn
  h="$(printf '%s' "$1" | sha256sum)"; h="${h%% *}"
  nnn=$(( (0x${h:0:4}) % 900 + 100 ))
  printf 'contracts/%s-novoe-imja-%s.md' "$nnn" "${h:4:10}"
}
case "${1:-}" in
  --imja)  # korpus_113.sh --imja <nonce> → печать имени для лога раннера
    [ -n "${2:-}" ] || { printf 'ОТКАЗ: --imja требует nonce\n' >&2; exit 2; }
    _novoe_imja "$2"; exit 0 ;;
esac

SCRATCH="$1"; IMJA="$2"
mkdir -p "$SCRATCH"
R="$SCRATCH/$IMJA"
[ -e "$R" ] && { printf 'ОТКАЗ: корпус %s уже существует: %s\n' "$IMJA" "$R" >&2; exit 2; }

case "$IMJA" in
  d0_chistoe)
    BASEROOT "$R"
    printf 'предмет контракта, черновик\n' > "$R/contracts/077-chernovik.md"
    _commit_all "$R" 'добавление черновика контракта (не заморожен — не уставной)'
    ;;
  d1_staroe)
    BASEROOT "$R"
    _filler "$R" 50
    printf 'незаконная правка глубоко в истории\n' >> "$R/plans/001-p.md"
    _commit_all "$R" 'старое нарушение: правка замороженного плана без строки'
    _filler "$R" 45
    ;;
  d2_merge)
    BASEROOT "$R"
    printf 'после устава\n' >> "$R/AGENTS.md"
    printf 'РАЗРЕШИЛ-ВЛАДЕЛЕЦ: AGENTS.md правка по ходу предмета 113\n' | _commit_body "$R"
    _git "$R" checkout -q -b bunker
    printf 'plan v2 nezakonno\n' > "$R/plans/001-p.md"
    _commit_all "$R" 'bunker: правка замороженного плана без строки'
    _git "$R" checkout -q main
    _git "$R" merge --no-ff --no-edit -q bunker
    ;;
  d3_otkat)
    BASEROOT "$R"
    _FROZEN="$(_git "$R" show frozen/plans/001/1:plans/001-p.md)"
    printf 'нарушение с последующим откатом\n' >> "$R/plans/001-p.md"
    _commit_all "$R" 'нарушение: правка замороженного плана без строки'
    printf '%s\n' "$_FROZEN" > "$R/plans/001-p.md"
    _commit_all "$R" 'откат к побайтово замороженному содержимому'
    ;;
  d4_udalenie)
    BASEROOT "$R"
    # удаление без строки (D), затем ВОЗВРАТ файла (A — добавления не судятся):
    # файл обязан ЖИТЬ в HEAD, иначе ls-tree HEAD не даст пары и дерево уйдёт из-под
    # предмета целиком (грамматика барьера судит только живые в HEAD уставные пути).
    _FROZEN4="$(_git "$R" show frozen/plans/001/1:plans/001-p.md)"
    _git "$R" rm -q plans/001-p.md
    _git "$R" commit -q -m 'удаление замороженного плана без строки'
    mkdir -p "$R/plans"   # git rm удаляет опустевший каталог
    printf '%s\n' "$_FROZEN4" > "$R/plans/001-p.md"
    _commit_all "$R" 'возврат плана в HEAD (добавление — не судится)'
    ;;
  d5_pereim)
    BASEROOT "$R"
    # переименование без строки (D старого пути при --no-renames), затем откат
    # переименованием обратно — тот же принцип живого в HEAD пути.
    _git "$R" mv AGENTS.md AGENTS_RENAMED.md
    _git "$R" commit -q -m 'переименование AGENTS.md без строки'
    _git "$R" mv AGENTS_RENAMED.md AGENTS.md
    _git "$R" commit -q -m 'возврат имени AGENTS.md (добавление — не судится)'
    ;;
  d7_kesh_linii)
    BASEROOT "$R"
    # боковая линия от точки заморозки: та же правка X БЕЗ строки (V)
    _git "$R" checkout -q -b storona
    printf 'plan X obshhee soderzhanie\n' > "$R/plans/001-p.md"
    _commit_all "$R" 'V на боковой: та же правка X без строки'
    # main: та же правка X СО строкой (M3), затем clean-merge боковой В ЕЁ ТЕКУЩЕМ
    # ТИПЕ V (merge-дельта пуста: содержание X уже на main) — V входит в историю HEAD.
    _git "$R" checkout -q main
    printf 'plan X obshhee soderzhanie\n' > "$R/plans/001-p.md"
    printf 'РАЗРЕШИЛ-ВЛАДЕЛЕЦ: plans/001-p.md правка X по предмету 113\n' | _commit_body "$R"
    _git "$R" merge --no-ff --no-edit -q storona
    # ТОЛЬКО ТЕПЕРЬ боковая уходит дальше (S2 — НЕ-предок HEAD, ветвь (в′) lib_incr):
    # V — предок S2, окно лжи base..HEAD исключает V; честный режим обязан дать
    # полный прогон и поймать V.
    _git "$R" checkout -q storona
    _git "$R" commit -q --allow-empty -m 'S2: боковая продолжается после merge'
    _git "$R" rev-parse HEAD > "$R/kesh-storonnij-linii.sha"
    _git "$R" checkout -q main
    ;;
  d8_kesh_valid)
    BASEROOT "$R"
    printf 'нарушение в HEAD при валидном кеше\n' >> "$R/plans/001-p.md"
    _commit_all "$R" 'нарушение: правка замороженного плана без строки'
    _git "$R" rev-parse HEAD~1 > "$R/kesh-valid.sha"
    ;;
  d9_bokovaja_zamorozka)
    # основание БЕЗ заморозки плана: AGENTS/ROADMAP под ustav/1, план — черновик
    mkdir -p "$R/plans" "$R/contracts" "$R/tmp"
    printf '# норма системы\nправило 1: правило без механизма не существует\n' > "$R/AGENTS.md"
    printf '# роадмап\nшаг 5 сделан\n'                                        > "$R/ROADMAP.md"
    printf 'предмет плана, критерий готовности, исполнители\n'                > "$R/plans/001-p.md"
    _git "$R" init -q -b main
    _git "$R" config user.name Фикстура113
    _git "$R" config user.email fixture113@local
    _git "$R" config commit.gpgsign false
    _git "$R" config core.hooksPath /dev/null
    _commit_all "$R" 'основание: норма, роадмап, черновик плана (заморозки плана нет)'
    _git "$R" tag -a ustav/1 -m 'устав действует'
    # черновичная правка плана на main ДО заморозки — законна сейчас; после
    # появления заморозки в реестре HEAD старый барьер судит её задним числом
    printf 'черновичная правка до появления заморозки в реестре\n' >> "$R/plans/001-p.md"
    _commit_all "$R" 'черновичная правка плана (заморозки ещё нет)'
    # кеш от УСПЕШНОГО старого барьера: прогон ДО заморозки плана зелёный,
    # incr_finish пишет HEAD — этот черновичный коммит (проверенный кеш,
    # не поддельный SHA — совет критика круг 2 :86)
    _b113=0
    ( cd "$R" && bash "$BARRIER113" --incr "$R/kesh-bokovoj-linii.sha" "$R" ) >/dev/null 2>&1 || _b113=$?
    [ "$_b113" -eq 0 ] || { printf 'ОТКАЗ: d9: сеяный прогон барьера не зелёный (rc=%s)\n' "$_b113" >&2; exit 2; }
    # первая заморозка плана — на БОКОВОЙ линии от основания: тег НЕ предок кеша
    _git "$R" branch freeze-side "$(_git "$R" rev-list --max-parents=0 HEAD)"
    _git "$R" checkout -q freeze-side
    _git "$R" commit -q --allow-empty -m 'заморозка плана на боковой линии'
    _git "$R" tag -a frozen/plans/001/1 -m 'план утверждён на боковой линии'
    _git "$R" checkout -q main
    # вливание пустой дельтой к первому родителю: merge сам по себе невидим
    # для --diff-merges=first-parent, тег становится предком HEAD
    _git "$R" merge --no-ff -s ours --no-edit -q freeze-side
    ;;
  d10_novoe_imja)
    # НОВОЕ уставное имя (вердикт адверсария круг 1: зашитая константа пропускала
    # contracts/777-secret.md, батарея не имела клетки со свежим именем). Законная
    # правка AGENTS.md СО строкой: на дереве, где оракул теряет тела разрешений
    # (unbound __CH_BODY_CACHE, тот же дефект, что красит d2/d7), оракул даёт по
    # ней ЛОЖНЫЙ FAIL — клетка красна на дефектном HEAD названной причиной.
    [ -n "${KORPUS113_NONCE:-}" ] || { printf 'ОТКАЗ: d10 требует KORPUS113_NONCE (имя генерирует раннер)\n' >&2; exit 2; }
    BASEROOT "$R"
    printf 'после устава, законная правка клетки d10\n' >> "$R/AGENTS.md"
    printf 'РАЗРЕШИЛ-ВЛАДЕЛЕЦ: AGENTS.md законная правка для клетки d10\n' | _commit_body "$R"
    _novyj="$(_novoe_imja "$KORPUS113_NONCE")"
    printf 'предмет свежего уставного документа d10\n' > "$R/$_novyj"
    _commit_all "$R" 'добавление свежего уставного документа (черновик — добавление свободно)'
    _git "$R" tag -a "frozen/$(dirname "$_novyj")/$(basename "${_novyj%%-*}")/1" -m 'свежий документ заморожен'
    printf 'незаконная правка свежего замороженного документа\n' >> "$R/$_novyj"
    _commit_all "$R" 'правка свежего замороженного документа без строки'
    printf 'NOVOE_IMJA=%s\n' "$_novyj"
    ;;
  *)
    printf 'ОТКАЗ: неизвестный корпус: %s\n' "$IMJA" >&2; exit 2 ;;
esac

printf 'ROOT=%s\n' "$R"
case "$IMJA" in
  d7_kesh_linii) printf 'CACHE=%s\n' "$R/kesh-storonnij-linii.sha" ;;
  d8_kesh_valid) printf 'CACHE=%s\n' "$R/kesh-valid.sha" ;;
  d9_bokovaja_zamorozka) printf 'CACHE=%s\n' "$R/kesh-bokovoj-linii.sha" ;;
esac
