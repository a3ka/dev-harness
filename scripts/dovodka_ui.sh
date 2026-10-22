#!/usr/bin/env bash
# dovodka_ui.sh — шаг визуальной доводки UI после implementer (контракт 133 dovodka-ui).
#
# Трое ворот оркестратору (шаг dovodka-ui: слово владельца 2026-10-21,
# docs/owner/2026-10-21-ekrany-bystree.md §Порядок п.2), сходятся на ЗАДАНИИ:
#   zadanie — построить задание доводчику (единственный носитель шага): ТОЛЬКО при красном
#             кадре сверки 123; модель — тир vision (overlay rc 0 И модель перечислена omp
#             с images=yes — дыру overlay.sh:129 ворота закрывают сами, overlay не правится);
#             граница экрана — ЗАМОРОЖЕННЫЙ blob этого экрана: тег frozen/contracts/<NNN>/<v>
#             харнесс-репозитория (грамматика тега — единый источник с дверью 095,
#             make_task.sh:371), файл экрана от вызывающего не принимается (блокер 2 круга 2);
#             задание несёт кадры, макеты, числа сверки ДОСЛОВНО, UI-зону (⊆ ЗОНА implementer
#             замороженного экрана) и БАЗУ — sha HEAD продукта ДО доводки. Выдача фиксируется
#             В GIT-СОСТОЯНИИ продукта: refs/dovodka/baza = БАЗА, refs/dovodka/zadanie = blob
#             байтов задания (блокер 3 круга 2: текст задания после выдачи не доказательство);
#             повторный запуск при НЕПОГАШЕННОЙ выдаче (есть коммиты после БАЗЫ) — отказ:
#             повторной выдачей нельзя переякорить базу мимо приёма zona.
#   zona    — принять работу доводчика: задание сверяется с refs выдачи побайтово
#             (изменённое задание — «байты расходятся»), БАЗА берётся ИЗ refs/dovodka/baza
#             (git-состояние), а не из текста задания; экран — замороженный тег из задания,
#             ЗОНА implementer перечитывается из блоба ВСЕГДА; дифф БАЗА..HEAD (--no-renames,
#             оба пути переименования) ⊆ UI-зона; пустой дифф — отказ; успех гасит refs
#             выдачи (следующая доводка — новой выдачей).
#   sudjam  — выдать судьям артефакт с числами похожести ДО/ПОСЛЕ на каждый кадр; кадр
#             ниже порога в ПОСЛЕ — именованный отказ ПОСЛЕ записи артефакта (числа
#             предъявлены и красному исходу).
#
# Сосед overlay.sh — механизм способностей (npm run overlay ≡ bash scripts/overlay.sh,
# package.json:18-19); сверка 123 — единственный источник чисел (KADR-строки, инвариант 4
# контракта 123): мера не переизобретается, строки читаются дословно.
#
# Коды: 0 — сделано; 1 — «ОТКАЗ dovodka: …»; 2 — «НЕЧЕМ СУДИТЬ dovodka: …».
set -uo pipefail
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DATABASE \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_CEILING_DIRECTORIES

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SELF_DIR/.." && pwd)"
OVERLAY="$SELF_DIR/overlay.sh"
CFG="$ROOT/.omp/config.yml"

otkaz()  { printf 'ОТКАЗ dovodka: %s\n' "$1" >&2; exit 1; }
nechem() { printf 'НЕЧЕМ СУДИТЬ dovodka: %s\n' "$1" >&2; exit 2; }

TMP_DIAG="$(mktemp)" || nechem 'скратч не создаётся'
trap 'rm -f "$TMP_DIAG"' EXIT

# ── сверка 123: KADR<TAB>id<TAB>score<TAB>porog<TAB>hudshij<TAB>OK|NIZHE_POROGA ──
# TAB — разделитель вне алфавитов полей (инвариант 4 контракта 123). Пустая сверка — не
# «нечего проверять», а нечем судить; вердикт пересчитывается из чисел: score<porog при
# OK — фальсификация, а не вход. Дубли кадра — то же, что KADR_NEODNOZNACHEN у 123.
parse_sverka() {
  awk -F'\t' '
    $1 == "KADR" {
      if (NF != 6 || $2 == "" || $3 !~ /^[0-9]+\.[0-9]+$/ || $4 !~ /^[0-9]+\.[0-9]+$/ || ($6 != "OK" && $6 != "NIZHE_POROGA")) {
        diag = "строка сверки вне грамматики: " $0; bad = 4; exit }
      if (($3 + 0 >= $4 + 0) != ($6 == "OK")) {
        diag = "сверка сфальсифицирована: " $2 " score=" $3 " porog=" $4 " verdikt=" $6; bad = 6; exit }
      if ($2 in seen) { diag = "кадр дважды в сверке: " $2; bad = 5; exit }
      seen[$2] = 1
      print
      k++
    }
    END {
      if (!bad && k == 0) { diag = "пустая сверка — строк KADR нет"; bad = 3 }
      if (diag != "") printf "%s\n", diag > "/dev/stderr"
      if (bad) exit bad
    }
  ' "$1"
}

SV=""
sverka_read() {  # $1 файл сверки → SV (дословные строки KADR); отказ — именованный
  SV="$(parse_sverka "$1" 2>"$TMP_DIAG")"
  local rc=$?
  case "$rc" in
    0) ;;
    3) nechem "$(cat "$TMP_DIAG")" ;;
    *) nechem "$(cat "$TMP_DIAG")" ;;
  esac
}

# ── UI-зона: пути (каталог с завершающей / либо точный файл), грамматика ЗОНА-путей
# check_zones: относительно, без .., без / в начале, без glob-символов; CR/LF — вне
# алфавита: путь сериализуется одной строкой задания (блокер B1 вердикта адверсария) ──
ZONY=()
zona_gram() {  # $1 путь → 0 в грамматике
  case "$1" in
    ''|../*|..|*'/../'*|..*|/*|*'*'*|*'?'*|*'['*|*'{'*|*'*'|*$'\r'*|*$'\n'*) return 1 ;;
    */) return 0 ;;
    *)  return 0 ;;
  esac
}

zona_read() {  # $1 файл UI-зоны → ZONY; пустая/вне грамматики — отказ
  local f="$1" l
  [ -f "$f" ] || nechem "файл UI-зоны не читается: $f"
  ZONY=()
  while IFS= read -r l || [ -n "$l" ]; do
    [ -n "$l" ] || continue
    zona_gram "$l" || otkaz "путь UI-зоны вне грамматики: $l"
    ZONY+=("$l")
  done < "$f"
  [ "${#ZONY[@]}" -gt 0 ] || otkaz 'пустая UI-зона — нечего править доводчику'
}

covered() {  # $1 путь; остальные аргументы — зоны (каталог с / либо точный файл): префиксное покрытие
  local p="$1" z
  shift
  for z in "$@"; do
    case "$z" in
      */) case "$p" in "$z"*) return 0 ;; esac ;;
      *)  [ "$p" = "$z" ] && return 0 ;;
    esac
  done
  return 1
}

# ── экран — ЗАМОРОЖЕННЫЙ blob этого экрана (блокер 2 круга 2): ЗОНА implementer
# читается из тега frozen/contracts/<NNN>/<v> харнесс-репозитория; грамматика выбора
# тега — единый источник с дверью 095 (make_task.sh:371: tag -l + sort -V + tail -1) ──
EKZ=()
ekran_max_tag() {  # $1 NNN $2 harness → stdout: последний тег заморозки (пусто = не заморожен)
  git -C "$2" tag -l "frozen/contracts/$1/*" | LC_ALL=C sort -V | tail -n 1
}

ekran_chitaem() {  # $1 тег frozen/contracts/<NNN>/<v> $2 harness → EKZ (ЗОНА implementer из блоба)
  local tag="$1" h="$2" n='' v='' cpath
  case "$tag" in
    frozen/contracts/*/*) ;;
    *) otkaz "КОНТРАКТ ЭКРАНА не тег заморозки: $tag" ;;
  esac
  n="${tag#frozen/contracts/}"; n="${n%%/*}"
  v="${tag##*/}"
  case "$n" in ''|*[!0-9]*) otkaz "КОНТРАКТ ЭКРАНА вне алфавита NNN: $tag" ;; esac
  case "$v" in ''|*[!0-9]*) otkaz "КОНТРАКТ ЭКРАНА вне алфавита версии: $tag" ;; esac
  [ -d "$h/.git" ] || [ -f "$h/.git" ] || nechem "харнесс-репозиторий не читается: $h"
  cpath="$(git -C "$h" ls-tree --name-only "$tag" contracts/ 2>/dev/null | grep -E "^contracts/$n-[^/]+\.md$" | head -n 1)"
  [ -n "$cpath" ] || nechem "заморозка экрана не читается (нет контракта в блобе): $tag"
  EKZ=()
  mapfile -t EKZ < <(git -C "$h" show "$tag:$cpath" | awk '/^ЗОНА implementer:/ { for (i = 3; i <= NF; i++) print $i }')
  [ "${#EKZ[@]}" -gt 0 ] || nechem "в замороженном контракте экрана нет строк ЗОНА implementer: $tag"
}

zona_podmnozhestvo() {  # EKZ прочитан из замороженного блоба: каждая зона UI ⊆ ЗОНА implementer
  local z
  for z in "${ZONY[@]}"; do
    covered "$z" "${EKZ[@]}" || otkaz "UI-зона шире зоны implementer контракта экрана: $z"
  done
}

# ── модель доводчика: тир vision из .omp/config.yml; способность — overlay rc 0 И
# перечисление модели в omp models list с images=yes (грамматика списка — overlay.sh:112) ──
vision_model() {  # → stdout: короткое имя модели тира vision
  local ov ovrc vm caps img
  [ -f "$OVERLAY" ] || nechem "нет механизма способностей $OVERLAY (npm run overlay)"
  ov="$(bash "$OVERLAY" --check 2>&1 >/dev/null)"; ovrc=$?
  case "$ovrc" in
    0) ;;
    1) otkaz "слой не прошёл сверку способностей (overlay rc 1): $ov" ;;
    *) nechem "способности не проверены (overlay rc $ovrc): $ov" ;;
  esac
  # строка грамматики тира — overlay.sh:126, несётся побайтово (единый источник)
  vm="$(grep -oE '^\s+vision:\s*"[^"]+"' "$CFG" | sed 's/.*"\(.*\)"/\1/' | sed 's|.*/||')"
  [ -n "$vm" ] || otkaz 'тир vision не объявлен в .omp/config.yml — некому смотреть кадры (Н-20)'
  # Вердикт круга 1 (блокер 4): overlay.sh:128-131 судит images ТОЛЬКО у модели, ЕСТЬ в
  # непустом списке; неперечисленная модель проходит с vis=0. Overlay заморожен чужим
  # контрактом — дыру закрывают ворота: сверка с фактическим списком omp.
  caps="$(omp models list 2>/dev/null | awk -F'│' 'NF>4 {gsub(/^ +| +$/,"",$2); gsub(/^ +| +$/,"",$6); if ($2!="model" && $2!="") print $2"\t"$6}')"
  [ -n "$caps" ] || nechem 'способности не проверены: omp не перечислил модели (overlay rc 0)'
  # Блокер B1 круга 2 (impl-v2): способность images=yes не может переходить от одной
  # модели к другой с тем же коротким именем. Колонка model грамматики overlay.sh:112
  # несёт только последний компонент: провайдер — заголовок секции вне таблицы (станция:
  # 5 провайдеров, короткие имена повторяются), сопоставление по полному идентификатору
  # в замороженной грамматике невозможно. Неоднозначное короткое имя (>1 строки списка)
  # отвергается именованным отказом; однозначное имя принимается как раньше.
  amb="$(printf '%s\n' "$caps" | awk -F'\t' -v m="$vm" '$1==m {n++} END {print n+0}')"
  [ "$amb" -le 1 ] || otkaz "неоднозначное имя модели $vm: в списке omp $amb строки с этим коротким именем, провайдер таблицей не различается — способность чужой модели не доказательство для настроенной (И-4)"
  img="$(printf '%s\n' "$caps" | awk -F'\t' -v m="$vm" '$1==m { print $2; exit }')"
  [ -n "$img" ] || otkaz "модель vision-тира $vm не перечислена omp — способность видеть кадры не подтверждена"
  [ "$img" = "yes" ] || otkaz "модель vision-тира $vm не умеет картинки (omp images=$img)"
  printf '%s\n' "$vm"
}

# ── задание — единственный носитель шага; грамматика строк задаётся cmd_zadanie ──
ZAG='# Задание доводки UI (шаг dovodka-ui, контракт 133)'
# алфавит однострочных полей задания (блокер B1 вердикта адверсария impl-v1): CR/LF
# в значении, сериализуемом одной строкой, клал бы в задание вторую строку секции —
# newline-инъекция в --kadry/--makety давала две строки БАЗА; отказ ДО записи файла
# и refs выдачи
odna_stroka() {  # $1 значение $2 имя поля → 0 в алфавите (без CR/LF)
  case "$1" in *$'\r'*|*$'\n'*) otkaz "многострочное значение $2 — CR/LF вне алфавита строки задания" ;; esac
}
# zadanie_chitaem — конечный автомат ПОЛНОЙ грамматики (блокер B1): каждая строка
# файла — заголовок, поле обязательной секции РОВНО один раз (двойное поле — отказ)
# или тело открытой многострочной секции (UI-ЗОНА — пути, СВЕРКА — строки KADR);
# строка вне секций и неполный состав — именованный отказ: zona принимает только
# задание грамматики ворот, последнее вхождение поля ничего не перезаписывает
EKRAN=""
BAZA=""
zadanie_chitaem() {  # $1 задание $2 репозиторий → ZONY/EKRAN/BAZA; подмена — именованный отказ
  local f="$1" repo="$2" l='' otkryt='' zrepo='' first=1
  local m_model=0 m_repo=0 m_baza=0 m_ekran=0 m_kadry=0 m_makety=0 m_uiz=0 m_sv=0 m_zad=0
  [ -f "$f" ] || otkaz "задание не от ворот zadanie: файла нет: $f"
  ZONY=(); EKRAN=""; BAZA=""
  while IFS= read -r l || [ -n "$l" ]; do
    if [ "$first" -eq 1 ]; then
      first=0
      [ "$l" = "$ZAG" ] || otkaz "задание не от ворот zadanie: нет заголовка ворот: $l"
      continue
    fi
    case "$l" in
      "$ZAG") otkaz 'задание не от ворот zadanie: заголовок не первая строка' ;;
      'МОДЕЛЬ: '*)
        [ "$m_model" -eq 0 ] || otkaz 'задание не от ворот zadanie: строка МОДЕЛЬ дважды'
        m_model=1 ;;
      'РЕПОЗИТОРИЙ: '*)
        [ "$m_repo" -eq 0 ] || otkaz 'задание не от ворот zadanie: строка РЕПОЗИТОРИЙ дважды'
        zrepo="${l#РЕПОЗИТОРИЙ: }"; m_repo=1 ;;
      'БАЗА: '*)
        [ "$m_baza" -eq 0 ] || otkaz 'задание не от ворот zadanie: строка БАЗА дважды'
        BAZA="${l#БАЗА: }"; m_baza=1 ;;
      'КОНТРАКТ ЭКРАНА: '*)
        [ "$m_ekran" -eq 0 ] || otkaz 'задание не от ворот zadanie: строка КОНТРАКТ ЭКРАНА дважды'
        EKRAN="${l#КОНТРАКТ ЭКРАНА: }"; m_ekran=1 ;;
      'КАДРЫ: '*)
        [ "$m_kadry" -eq 0 ] || otkaz 'задание не от ворот zadanie: строка КАДРЫ дважды'
        m_kadry=1 ;;
      'МАКЕТЫ: '*)
        [ "$m_makety" -eq 0 ] || otkaz 'задание не от ворот zadanie: строка МАКЕТЫ дважды'
        m_makety=1 ;;
      'UI-ЗОНА:')
        [ "$m_uiz" -eq 0 ] || otkaz 'задание не от ворот zadanie: строка UI-ЗОНА дважды'
        otkryt=zona; m_uiz=1 ;;
      'СВЕРКА (дословно, числа похожести на каждый кадр):')
        [ "$m_sv" -eq 0 ] || otkaz 'задание не от ворот zadanie: строка СВЕРКА дважды'
        otkryt=sverka; m_sv=1 ;;
      'ЗАДАЧА: '*)
        [ "$m_zad" -eq 0 ] || otkaz 'задание не от ворот zadanie: строка ЗАДАЧА дважды'
        otkryt=''; m_zad=1 ;;
      *)
        case "$otkryt" in
          zona) ZONY+=("$l") ;;
          sverka) case "$l" in 'KADR'$'\t'*) ;; *) otkaz "задание не от ворот zadanie: строка сверки вне грамматики: $l" ;; esac ;;
          *) otkaz "задание не от ворот zadanie: строка вне секций: $l" ;;
        esac ;;
    esac
  done < "$f"
  [ -n "$BAZA" ] || otkaz 'задание не от ворот zadanie: нет строки БАЗА'
  case "$BAZA" in *[!0-9a-f]*|'') otkaz "задание не от ворот zadanie: БАЗА не sha: $BAZA" ;; esac
  [ "${#BAZA}" -eq 40 ] || otkaz "задание не от ворот zadanie: БАЗА не sha: $BAZA"
  [ "$m_ekran" -eq 1 ] || otkaz 'задание не от ворот zadanie: нет строки КОНТРАКТ ЭКРАНА'
  [ "$m_model" -eq 1 ] || otkaz 'задание не от ворот zadanie: нет строки МОДЕЛЬ'
  [ "$m_repo" -eq 1 ] || otkaz 'задание не от ворот zadanie: нет строки РЕПОЗИТОРИЙ'
  [ "$m_kadry" -eq 1 ] || otkaz 'задание не от ворот zadanie: нет строки КАДРЫ'
  [ "$m_makety" -eq 1 ] || otkaz 'задание не от ворот zadanie: нет строки МАКЕТЫ'
  [ "$m_uiz" -eq 1 ] || otkaz 'задание не от ворот zadanie: нет строки UI-ЗОНА'
  [ "$m_sv" -eq 1 ] || otkaz 'задание не от ворот zadanie: нет строки СВЕРКА'
  [ "$m_zad" -eq 1 ] || otkaz 'задание не от ворот zadanie: нет строки ЗАДАЧА'
  [ "${#ZONY[@]}" -gt 0 ] || otkaz 'задание не от ворот zadanie: пустая UI-зона'
  for l in "${ZONY[@]}"; do
    zona_gram "$l" || otkaz "задание не от ворот zadanie: UI-зона вне грамматики: $l"
  done
  [ "$zrepo" = "$repo" ] || otkaz "репозиторий расходится с заданием: $repo ≠ $zrepo"
}

cmd_zadanie() {  # $1 сверка $2 репо $3 ui-зона $4 NNN экрана $5 harness $6 кадры $7 макеты $8 задание
  local sverka="$1" repo="$2" uiz="$3" ekn="$4" harn="$5" kadry="$6" makety="$7" out="$8"
  local red n vm baza ekt bref blob
  sverka_read "$sverka"
  red="$(printf '%s\n' "$SV" | awk -F'\t' '$6=="NIZHE_POROGA"')"
  if [ -z "$red" ]; then otkaz 'все кадры не ниже порога — шаг не зовётся (dovodka-ui только по красному кадру)'; fi
  n="$(printf '%s\n' "$red" | grep -c .)"
  zona_read "$uiz"
  # экран — ТОЛЬКО замороженный blob этого экрана (блокер 2 круга 2): произвольный
  # --kontrakt-ekrana от вызывающего не принимается вовсе — аргумента нет
  case "$ekn" in ''|*[!0-9]*) otkaz "контракт экрана вне алфавита NNN: $ekn" ;; esac
  ekt="$(ekran_max_tag "$ekn" "$harn")"
  [ -n "$ekt" ] || otkaz "контракт экрана не заморожен: $ekn"
  ekran_chitaem "$ekt" "$harn"
  zona_podmnozhestvo
  vm="$(vision_model)"; vrc=$?
  # отказ/нечем из vision_model умирают в подстановке: rc проносится вручную
  # (диагностика уже напечатана в stderr самой функцией)
  if [ "$vrc" -ne 0 ]; then exit "$vrc"; fi
  # БАЗА — состояние продукта ДО доводки: фиксируется воротами в момент задания,
  # вызывающий её больше не выбирает (вердикт круга 1, блокер 3: --base HEAD прятал
  # уже закоммиченные вне-зонные правки пустым диффом)
  command -v git >/dev/null 2>&1 || nechem 'нет git'
  baza="$(git -C "$repo" rev-parse HEAD^{commit} 2>/dev/null)" || nechem "репозиторий продукта не читается: $repo"
  # непогашенная выдача (блокер 3 круга 2): повторный запуск zadanie НЕ переякоривает
  # базу мимо приёма zona — сначала приём работы или откат доводки к базе выдачи
  if bref="$(git -C "$repo" rev-parse -q --verify 'refs/dovodka/baza^{commit}' 2>/dev/null)"; then
    [ "$bref" = "$baza" ] || otkaz "непогашенная выдача: с момента задания есть коммиты ($bref..$baza) — примите работу zona или откатите доводку к базе выдачи"
  fi
  # алфавит однострочных полей (блокер B1 вердикта адверсария impl-v1): значения,
  # сериализуемые одной строкой задания, — без CR/LF: отказ ДО записи — задание
  # не пишется, refs не выдаются
  odna_stroka "$vm" 'МОДЕЛЬ'
  odna_stroka "$repo" 'РЕПОЗИТОРИЙ'
  odna_stroka "$baza" 'БАЗА'
  odna_stroka "$ekt" 'КОНТРАКТ ЭКРАНА'
  odna_stroka "$kadry" 'КАДРЫ'
  odna_stroka "$makety" 'МАКЕТЫ'
  {
    printf '%s\n' "$ZAG"
    printf 'МОДЕЛЬ: %s (тир vision, overlay rc 0, images=yes)\n' "$vm"
    printf 'РЕПОЗИТОРИЙ: %s\n' "$repo"
    printf 'БАЗА: %s\n' "$baza"
    printf 'КОНТРАКТ ЭКРАНА: %s\n' "$ekt"
    printf 'КАДРЫ: %s\n' "$kadry"
    printf 'МАКЕТЫ: %s\n' "$makety"
    printf 'UI-ЗОНА:\n'
    printf '%s\n' "${ZONY[@]}"
    printf 'СВЕРКА (дословно, числа похожести на каждый кадр):\n'
    printf '%s\n' "$SV"
    printf 'ЗАДАЧА: править только пути UI-ЗОНА; цикл правка → e2e → сверка 123; все кадры не ниже порога; судьям — результат с числами.\n'
  } > "$out"
  # выдача фиксируется в git-состоянии продукта (блокер 3 круга 2): задание после
  # выдачи неизменяемо — байты и БАЗА судятся zona по refs, а не по тексту задания
  blob="$(git -C "$repo" hash-object -w "$out")" || nechem 'выдача не фиксируется: hash-object задания'
  git -C "$repo" update-ref refs/dovodka/baza "$baza" || nechem 'выдача не фиксируется: update-ref refs/dovodka/baza'
  git -C "$repo" update-ref refs/dovodka/zadanie "$blob" || nechem 'выдача не фиксируется: update-ref refs/dovodka/zadanie'
  printf 'DOVODKA: задание %s; красных кадров %s\n' "$out" "$n"
}

cmd_zona() {  # $1 репо $2 задание $3 harness (база — из refs выдачи, экран — из замороженного тега задания)
  local repo="$1" zad="$2" harn="$3"
  local changed p n=0 base zref zsha
  command -v git >/dev/null 2>&1 || nechem 'нет git'
  zadanie_chitaem "$zad" "$repo"
  # привязка к выдаче ворот (блокер 3 круга 2): байты задания ↔ refs/dovodka/zadanie,
  # БАЗА — refs/dovodka/baza (git-состояние): правка задания после выдачи не проходит
  zref="$(git -C "$repo" rev-parse -q --verify refs/dovodka/zadanie 2>/dev/null)" \
    || otkaz 'задание не от ворот zadanie: нет ref выдачи (refs/dovodka/zadanie)'
  zsha="$(git -C "$repo" hash-object "$zad")" || nechem "задание не читается: $zad"
  [ "$zsha" = "$zref" ] || otkaz 'задание не от ворот zadanie: байты расходятся с refs/dovodka/zadanie'
  base="$(git -C "$repo" rev-parse -q --verify 'refs/dovodka/baza^{commit}' 2>/dev/null)" \
    || otkaz 'задание не от ворот zadanie: нет базового ref выдачи (refs/dovodka/baza)'
  [ "$BAZA" = "$base" ] || otkaz 'задание не от ворот zadanie: БАЗА расходится с refs/dovodka/baza'
  ekran_chitaem "$EKRAN" "$harn"
  zona_podmnozhestvo
  git -C "$repo" cat-file -e "${base}^{commit}" 2>/dev/null || nechem "база диффа не читается: $base"
  changed="$(git -C "$repo" diff --no-renames --name-only "$base" HEAD)" || nechem 'дифф репозитория не читается'
  [ -n "$changed" ] || otkaz 'дифф пуст — работы доводки нет (БАЗА выдачи = HEAD)'
  while IFS= read -r p; do
    [ -n "$p" ] || continue
    n=$((n + 1))
    covered "$p" "${ZONY[@]}" || otkaz "правка вне UI-зоны: $p"
  done <<<"$changed"
  # приём состоялся — выдача погашена: следующая доводка начинается новой выдачей
  git -C "$repo" update-ref -d refs/dovodka/zadanie 2>/dev/null || nechem 'выдача не гасится: update-ref -d refs/dovodka/zadanie'
  git -C "$repo" update-ref -d refs/dovodka/baza 2>/dev/null || nechem 'выдача не гасится: update-ref -d refs/dovodka/baza'
  printf 'ЗОНА: чисто (путей %s)\n' "$n"
}

cmd_sudjam() {  # $1 сверка ДО $2 сверка ПОСЛЕ $3 артефакт судьям
  local fdo="$1" fposle="$2" out="$3"
  local _ id sc po hu vd
  sverka_read "$fdo"
  local DO="$SV"
  sverka_read "$fposle"
  local PO="$SV"
  local -A POSLE=()
  local -A DO_IDS=()
  local rest pres psc ppo phu pvd
  local fk_id="" fk_sc="" fk_po=""
  while IFS=$'\t' read -r _ id sc po hu vd; do
    [ -n "$id" ] || continue
    POSLE["$id"]="$sc|$po|$hu|$vd"
  done <<<"$PO"
  while IFS=$'\t' read -r _ id sc po hu vd; do
    [ -n "$id" ] || continue
    DO_IDS["$id"]=1
  done <<<"$DO"
  while IFS=$'\t' read -r _ id sc po hu vd; do
    [ -n "$id" ] || continue
    if [ -z "${DO_IDS[$id]+x}" ]; then otkaz "кадр появился в сверке ПОСЛЕ: $id"; fi
  done <<<"$PO"
  while IFS=$'\t' read -r _ id sc po hu vd; do
    [ -n "$id" ] || continue
    if [ -z "${POSLE[$id]+x}" ]; then otkaz "кадр пропал из сверки ПОСЛЕ: $id"; fi
    pres="${POSLE[$id]}"
    psc="${pres%%|*}"; rest="${pres#*|}"; ppo="${rest%%|*}"; rest="${rest#*|}"; phu="${rest%%|*}"; pvd="${rest#*|}"
    if [ "$po" != "$ppo" ]; then nechem "порог кадра разошёлся между прогонами: $id ($po ≠ $ppo)"; fi
    printf 'SUD\t%s\t%s\t%s\t%s\t%s\t%s\n' "$id" "$sc" "$psc" "$po" "$phu" "$pvd"
    if [ "$pvd" != "OK" ]; then fk_id="$id"; fk_sc="$psc"; fk_po="$ppo"; fi
  done <<<"$DO" > "$out"
  if [ -n "$fk_id" ]; then
    otkaz "не завершена: кадр $fk_id score=$fk_sc ниже порога $fk_po — числа предъявлены в $out, шаг продолжается"
  fi
  printf 'СУДЬЯМ: числа предъявлены (кадров %s)\n' "${#DO_IDS[@]}"
}

case "${1:-}" in
  zadanie)
    shift
    A_SVERKA=""; A_REPO=""; A_UIZ=""; A_EKRAN=""; A_HARNESS=""; A_KADRY=""; A_MAKETY=""; A_OUT=""
    while [ $# -gt 0 ]; do
      case "$1" in
        --sverka) A_SVERKA="$2"; shift 2 ;;
        --repo) A_REPO="$2"; shift 2 ;;
        --ui-zona) A_UIZ="$2"; shift 2 ;;
        --ekran) A_EKRAN="$2"; shift 2 ;;
        --harness) A_HARNESS="$2"; shift 2 ;;
        --kadry) A_KADRY="$2"; shift 2 ;;
        --makety) A_MAKETY="$2"; shift 2 ;;
        --out) A_OUT="$2"; shift 2 ;;
        *) nechem "неизвестный аргумент zadanie: $1" ;;
      esac
    done
    if [ -z "$A_SVERKA" ] || [ -z "$A_REPO" ] || [ -z "$A_UIZ" ] || [ -z "$A_EKRAN" ] || [ -z "$A_HARNESS" ] || [ -z "$A_KADRY" ] || [ -z "$A_MAKETY" ] || [ -z "$A_OUT" ]; then
      nechem 'zadanie: нужны --sverka --repo --ui-zona --ekran <NNN> --harness <git> --kadry --makety --out'
    fi
    cmd_zadanie "$A_SVERKA" "$A_REPO" "$A_UIZ" "$A_EKRAN" "$A_HARNESS" "$A_KADRY" "$A_MAKETY" "$A_OUT"
    ;;
  zona)
    shift
    A_REPO=""; A_ZAD=""; A_HARNESS=""
    while [ $# -gt 0 ]; do
      case "$1" in
        --repo) A_REPO="$2"; shift 2 ;;
        --zadanie) A_ZAD="$2"; shift 2 ;;
        --harness) A_HARNESS="$2"; shift 2 ;;
        *) nechem "неизвестный аргумент zona: $1 (база/UI-зона/экран — из --zadanie и refs выдачи, не от вызывающего)" ;;
      esac
    done
    if [ -z "$A_REPO" ] || [ -z "$A_ZAD" ] || [ -z "$A_HARNESS" ]; then
      nechem 'zona: нужны --repo --zadanie --harness'
    fi
    cmd_zona "$A_REPO" "$A_ZAD" "$A_HARNESS"
    ;;
  sudjam)
    shift
    A_DO=""; A_POSLE=""; A_OUT=""
    while [ $# -gt 0 ]; do
      case "$1" in
        --do) A_DO="$2"; shift 2 ;;
        --posle) A_POSLE="$2"; shift 2 ;;
        --out) A_OUT="$2"; shift 2 ;;
        *) nechem "неизвестный аргумент sudjam: $1" ;;
      esac
    done
    if [ -z "$A_DO" ] || [ -z "$A_POSLE" ] || [ -z "$A_OUT" ]; then
      nechem 'sudjam: нужны --do --posle --out'
    fi
    cmd_sudjam "$A_DO" "$A_POSLE" "$A_OUT"
    ;;
  *)
    nechem "неизвестный режим: ${1:-} (zadanie|zona|sudjam)"
    ;;
esac
