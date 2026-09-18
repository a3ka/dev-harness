#!/usr/bin/env bash
# Барьер классификатора форков (контракт 029, Н-104).
#
# Три маршрута а/б/в с четвёртым исходом для неизвестного/пустого КЛАСС, вторая
# подпись-свидетельство для воли-владельца, свойства СОревью, флаш батча, счётчик
# передаточных, запрет двойной роли, деградация. Реализует инварианты 1–7 контракта;
# инварианты 8–10 живут в verify_consultant.sh (грамматика ответа, переисполнение
# команд с белым списком, граница Г1–Г4).
#
# Коды возврата: 0 — порядок (в том числе напечатанные ФЛАШ/ЖДЁМ/ДЕГРАДАЦИЯ),
#                1 — нарушение (поимённое), 2 — нечем проверить (нет git/sha256sum/date -d).
# Запрещено `cmd && echo PASS`: вердикт — код возврата.

set -uo pipefail

# ── аргументы ────────────────────────────────────────────────────────────────
ROOT=""
MODE=""  # пусто / "flush" / "schet"
while [ "$#" -gt 0 ]; do
  case "$1" in
    --root)  ROOT="$2"; shift 2 ;;
    --flush) MODE="flush"; shift ;;
    --schet) MODE="schet"; shift ;;
    -h|--help)
      printf 'usage: check_fork_route.sh --root <корень> [--flush|--schet]\n' >&2
      exit 2 ;;
    *) printf 'check_fork_route.sh: неизвестный аргумент «%s»\n' "$1" >&2; exit 2 ;;
  esac
done

[ -n "$ROOT" ] || { printf 'check_fork_route.sh: --root обязателен\n' >&2; exit 2; }
[ -d "$ROOT" ] || { printf 'check_fork_route.sh: --root %s не каталог\n' "$ROOT" >&2; exit 2; }

# ── инструменты (код 2 «нечем проверить») ────────────────────────────────────
command -v git >/dev/null 2>&1 || { printf 'check_fork_route.sh: нет инструмента git\n' >&2; exit 2; }
command -v date >/dev/null 2>&1 || { printf 'check_fork_route.sh: нет инструмента date\n' >&2; exit 2; }
date -d @0 >/dev/null 2>&1 || { printf 'check_fork_route.sh: date -d не работает\n' >&2; exit 2; }

# sha256sum проверяется РЕАЛЬНЫМ вызовом на пустом вводе, а не `command -v`:
# обёртка с тем же именем проходит `command -v` и не проходит фактический запуск
# (находка 1 адверсария круга 2: `route-fake-sha-zero-wrong-empty` rc=0 при
# sha256sum-обёртке, печатающей «deadbeef  -» и выходящей в 0). Сверка с
# известным empty-hash отличает настоящий sha256sum от любой обёртки-плацебо.
# Тот же способ проверки, что уже применён в verify_consultant.sh (там адверсарий
# круга 2 подтвердил корректность: `fake_sha_rc127` rc=2 на подменённом sha256sum).
# ИНВ. 10 (арбитраж tcb-granica-put-029.md §3, замер 3c): rc привязывается
# НЕЗАВИСИМО от текста — обёртка, печатающая корректный empty-hash и выходящая
# ненулём (1 или 127), иначе проходит текстовую сверку. Успех = верный ТЕКСТ И
# нулевой rc; отказ — rc=2 «нечем проверить».
EXPECTED_EMPTY_SHA='e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'
GOT_EMPTY_SHA="$(printf '' | sha256sum | cut -d' ' -f1)"
SHA_RC=$?
if [ "$SHA_RC" -ne 0 ]; then
  printf 'check_fork_route.sh: sha256sum непригоден — нечем проверить (rc=%s)\n' "$SHA_RC" >&2
  exit 2
fi
if [ "$GOT_EMPTY_SHA" != "$EXPECTED_EMPTY_SHA" ]; then
  printf 'check_fork_route.sh: sha256sum не работает (ожидался %s, получен %s)\n' \
         "$EXPECTED_EMPTY_SHA" "$GOT_EMPTY_SHA" >&2
  exit 2
fi

# ── разбор одной записи журнала ──────────────────────────────────────────────
# Поля — формат «КЛЮЧ: значение» по одной на строку.
record_field() {  # <путь к файлу> <имя поля>  → печатает значение или пусто
  local f="$1" field="$2"
  sed -n "s/^${field}:[[:space:]]*//p" "$f" 2>/dev/null | head -n 1
}

# Поле КЛАСС отдельно: нужно отличить «нет поля» (default-open) от «поле есть, значение
# пусто» (отказ «неизвестный класс»). record_field даст пустую строку в обоих случаях;
# здесь возвращаем «PRESENT:<значение>» либо «ABSENT».
record_class_state() {  # <путь к файлу>  → печатает «ABSENT» или «PRESENT:<v>»
  local f="$1" line val
  line="$(grep -E '^КЛАСС:' "$f" 2>/dev/null | head -n 1)"
  if [ -z "$line" ]; then
    printf 'ABSENT'
  else
    val="$(printf '%s' "$line" | sed -e 's/^КЛАСС:[[:space:]]*//' -e 's/[[:space:]]*$//')"
    printf 'PRESENT:%s' "$val"
  fi
}

# Раскрытие ISO-времени в epoch-секунды (UTC). Пусто/мусор → пустая строка.
iso_to_epoch() {  # <iso>
  local iso="$1"
  [ -n "$iso" ] || return 0
  date -u -d "$iso" +%s 2>/dev/null
}

# Жёсткая проверка формата «ГГГГ-ММ-ДДTчч:мм:ссZ» (контракт, инв. 4: время
# в журнале — ISO). Мусор вроде «18-09-2026 not-ISO» проходил `date -d`, ронял
# iso_to_epoch в пустую строку, и очередь молча считалась «головы нет» — то
# есть ФЛАШ по возрасту не срабатывал, а барьер печатал «ЖДЁМ» (находка 7
# адверсария, flush_bad_timestamp rc=0). Здесь формат проверяется ДО любой
# попытки `date -d` — неизмеримое время не молчит.
iso_is_valid() {  # <iso>  → 0 если формат корректен
  local iso="$1"
  [[ "$iso" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$ ]]
}

NOW="$(date -u +%s)"

# Перечень признаков воли (закрытый, инв. 2) и признаков дизайна (закрытый, инв. 3).
VOLI_PRIZNAKI='деньги риск норма приоритет'
DIZ_PRIZNAKI_VYSOKO='новый-механизм кросс-репо граница-безопасности портирование-контура необратимость'
DIZ_PRIZNAKI_ALL="$DIZ_PRIZNAKI_VYSOKO рутина"

# ── сбор записей журнала ─────────────────────────────────────────────────────
FORKS_DIR="$ROOT/forks"
mapfile -t RECORD_FILES < <(find "$FORKS_DIR" -maxdepth 1 -type f -name '*.md' 2>/dev/null | sort)
RECORD_COUNT="${#RECORD_FILES[@]}"

# ── 0) Грамматика журнала (ИМЕНОВАННЫЙ отказ rc 1, до любых режимов) ────────
# Имя файла — ASCII [a-z0-9-]+; поле ФОРК: обязано совпасть с именем; поле
# КЛАСС: встречается НЕ БОЛЕЕ одного раза (иначе запись неразборчива);
# время ЗАВЕДЁН (если есть) — ISO «ГГГГ-ММ-ДДTчч:мм:ссZ»; ФОРК: уникален
# между файлами. Старая редакция это не судила, и запись могла нести
# нечитаемый id, противоречивые КЛАСС/ФОРК и мусор вместо ISO — всё молча
# принималось (находка 5 адверсария, record_grammar rc=0). Здесь ВСЁ
# проверяется один раз ДО режимов SCHET/FLUSH/обычный, чтобы ошибка грамматики
# НЕ маскировалась под «всё хорошо, ЖДЁМ».
declare -A FORK_SEEN=()
for f in "${RECORD_FILES[@]}"; do
  id="$(basename "$f" .md)"
  if ! [[ "$id" =~ ^[a-z0-9-]+$ ]]; then
    printf 'грамматика записи: имя «%s» вне ASCII [a-z0-9-]+: %s\n' "$id" "$f" >&2
    exit 1
  fi
  fork_val="$(record_field "$f" "ФОРК")"
  if [ -z "$fork_val" ]; then
    printf 'грамматика записи: отсутствует поле ФОРК: %s\n' "$id" >&2
    exit 1
  fi
  if [ "$fork_val" != "$id" ]; then
    printf 'грамматика записи: ФОРК «%s» не совпадает с именем «%s»: %s\n' \
           "$fork_val" "$id" "$f" >&2
    exit 1
  fi
  if [ -n "${FORK_SEEN[$fork_val]:-}" ]; then
    printf 'грамматика записи: дубликат ФОРК «%s» между файлами: %s и %s\n' \
           "$fork_val" "${FORK_SEEN[$fork_val]}" "$f" >&2
    exit 1
  fi
  FORK_SEEN["$fork_val"]="$f"
  klass_count="$(grep -cE '^КЛАСС:' "$f" 2>/dev/null)"
  if [ "${klass_count:-0}" -gt 1 ]; then
    printf 'грамматика записи: поле КЛАСС встречается %s раз — должно быть одно: %s\n' \
           "$klass_count" "$id" >&2
    exit 1
  fi
  zavedjon_val="$(record_field "$f" "ЗАВЕДЁН")"
  if [ -n "$zavedjon_val" ] && ! iso_is_valid "$zavedjon_val"; then
    printf 'грамматика записи: ЗАВЕДЁН «%s» не ISO: %s\n' "$zavedjon_val" "$id" >&2
    exit 1
  fi
done

# ── 1) предварительный обход: для каждой записи определить, валидна ли она как
#    ЗАСВИДЕТЕЛЬСТВОВАННАЯ воля владельца (для счётчика передаточных, инв. 5).
declare -a RECORD_IDS=()
declare -A RECORD_VOLJA_OK=()
declare -A RECORD_ROUTE=()       # консультант / батч / со-ревью / свой

for f in "${RECORD_FILES[@]}"; do
  id="$(basename "$f" .md)"
  RECORD_IDS+=("$id")
  RECORD_VOLJA_OK["$id"]=0
  RECORD_ROUTE["$id"]="$(record_field "$f" "МАРШРУТ")"

  klass_state="$(record_class_state "$f")"
  case "$klass_state" in
    PRESENT:воля-владельца) ;;
    *) continue ;;
  esac

  priznak="$(record_field "$f" "ПРИЗНАК")"
  avtor="$(record_field "$f" "АВТОР")"
  route="${RECORD_ROUTE[$id]}"

  # Признак из перечня.
  found_priznak=0
  for p in $VOLI_PRIZNAKI; do [ "$p" = "$priznak" ] && found_priznak=1; done

  # Свидетельство: файл существует, несёт ПОДТВЕРЖДЕНО: воля-владельца, МОДЕЛЬ ≠ АВТОР.
  witness_ok=0
  for vf in "$ROOT/verdicts/consultant/$id-klass-v"*.md; do
    [ -f "$vf" ] || continue
    if grep -q '^ПОДТВЕРЖДЕНО: воля-владельца' "$vf" 2>/dev/null; then
      witness_model="$(record_field "$vf" "МОДЕЛЬ")"
      if [ -n "$witness_model" ] && [ "$witness_model" != "$avtor" ]; then
        witness_ok=1
        break
      fi
    fi
  done

  if [ "$route" = "батч" ] && [ "$found_priznak" = "1" ] \
     && [ -n "$avtor" ] && [ "$witness_ok" = "1" ]; then
    RECORD_VOLJA_OK["$id"]=1
  fi
done

# ── 2) режим SCHET (инв. 5): печатает ДВА числа ──────────────────────────────
if [ "$MODE" = "schet" ]; then
  if [ "$RECORD_COUNT" -eq 0 ]; then
    printf 'просмотрено 0\n'
    exit 1
  fi
  peredatochnyh=0
  for id in "${RECORD_IDS[@]}"; do
    route="${RECORD_ROUTE[$id]}"
    if [ "$route" = "батч" ] && [ "${RECORD_VOLJA_OK[$id]}" != "1" ]; then
      peredatochnyh=$((peredatochnyh + 1))
    fi
  done
  printf 'просмотрено %d\n' "$RECORD_COUNT"
  printf 'передаточных %d\n' "$peredatochnyh"
  exit 0
fi

# ── 3) режим FLUSH (инв. 4) ──────────────────────────────────────────────────
if [ "$MODE" = "flush" ]; then
  # Каждая запись очереди обязана иметь ЗАВЕДЁН; без него — поимённый отказ.
  for f in "${RECORD_FILES[@]}"; do
    id="$(basename "$f" .md)"
    route="${RECORD_ROUTE[$id]}"
    otvecheno="$(record_field "$f" "ОТВЕЧЕНО")"
    [ "$route" = "батч" ] || continue
    [ "$otvecheno" = "да" ] && continue
    zavedjon="$(record_field "$f" "ЗАВЕДЁН")"
    if [ -z "$zavedjon" ]; then
      printf 'батч-запись без поля ЗАВЕДЁН — возраст головы неизмерим: %s\n' "$id" >&2
      exit 1
    fi
    if ! iso_is_valid "$zavedjon"; then
      printf 'батч-запись с невалидным ISO-временем ЗАВЕДЁН — возраст головы неизмерим: %s\n' "$id" >&2
      exit 1
    fi
  done

  # Собственно очередь и триггеры.
  queue_size=0
  head_age=-1
  any_blocking=0
  for id in "${RECORD_IDS[@]}"; do
    route="${RECORD_ROUTE[$id]}"
    otvecheno="$(record_field "$ROOT/forks/$id.md" "ОТВЕЧЕНО")"
    [ "$route" = "батч" ] || continue
    [ "$otvecheno" = "да" ] && continue
    queue_size=$((queue_size + 1))
    [ "$(record_field "$ROOT/forks/$id.md" "БЛОКИРУЕТ")" = "да" ] && any_blocking=1
    zavedjon_iso="$(record_field "$ROOT/forks/$id.md" "ЗАВЕДЁН")"
    zavedjon_epoch="$(iso_to_epoch "$zavedjon_iso")"
    if [ -n "$zavedjon_epoch" ]; then
      age=$(( NOW - zavedjon_epoch ))
      [ "$age" -lt 0 ] && age=0
      if [ "$head_age" -lt 0 ] || [ "$age" -gt "$head_age" ]; then
        head_age="$age"
      fi
    fi
  done

  threshold_age=$((2 * 3600))   # 2 часа
  if [ "$any_blocking" = "1" ] || [ "$queue_size" -ge 3 ] \
     || { [ "$head_age" -ge 0 ] && [ "$head_age" -ge "$threshold_age" ]; }; then
    printf 'ФЛАШ\n'
  else
    printf 'ЖДЁМ\n'
  fi
  exit 0
fi

# ── 4) ОБЫЧНЫЙ РЕЖИМ: валидация инв. 1–3, 6, 7 ──────────────────────────────
DEGRADATION_LINES=()  # для накопления, печатаются ПЕРЕД кодом возврата

# 4а. Двойная роль (инв. 6) — по всем <id>, у которых есть verdict-файлы.
for id in "${RECORD_IDS[@]}"; do
  consultant_models=()
  arbitration_models=()
  for vf in "$ROOT/verdicts/consultant/$id-"*.md; do
    [ -f "$vf" ] || continue
    m="$(record_field "$vf" "МОДЕЛЬ")"
    if [ -z "$m" ]; then
      printf 'двойная роль: артефакт без строки МОДЕЛЬ — запрет ненаблюдаем: %s\n' "$id" >&2
      exit 1
    fi
    consultant_models+=("$m")
  done
  for vf in "$ROOT/verdicts/arbitration/$id"*.md; do
    [ -f "$vf" ] || continue
    m="$(record_field "$vf" "МОДЕЛЬ")"
    if [ -z "$m" ]; then
      printf 'двойная роль: артефакт без строки МОДЕЛЬ — запрет ненаблюдаем: %s\n' "$id" >&2
      exit 1
    fi
    arbitration_models+=("$m")
  done
  # Совпадение значений МОДЕЛЬ на одном <id> между консультантом и арбитражем.
  for cm in "${consultant_models[@]}"; do
    for am in "${arbitration_models[@]}"; do
      if [ "$cm" = "$am" ]; then
        printf 'двойная роль на предмете %s: модель %s в роли консультанта и арбитра\n' \
               "$id" "$cm" >&2
        exit 1
      fi
    done
  done
done

# 4б. Деградация (инв. 7) — накапливается, печатается, не валит rc.
for id in "${RECORD_IDS[@]}"; do
  f="$ROOT/forks/$id.md"
  route="${RECORD_ROUTE[$id]}"
  [ "$route" = "консультант" ] || continue
  vyzvan_iso="$(record_field "$f" "ВЫЗВАН")"
  [ -n "$vyzvan_iso" ] || continue
  vyzvan_epoch="$(iso_to_epoch "$vyzvan_iso")"
  [ -n "$vyzvan_epoch" ] || continue
  age=$(( NOW - vyzvan_epoch ))
  [ "$age" -ge 1800 ] || continue   # <30 мин — рано
  # Ответ пришёл?
  if compgen -G "$ROOT/verdicts/consultant/$id-v*.md" >/dev/null 2>&1; then
    continue
  fi
  DEGRADATION_LINES+=("ДЕГРАДАЦИЯ: $id")
done

# 4в. Валидация инв. 1–3 по каждой записи.
for f in "${RECORD_FILES[@]}"; do
  id="$(basename "$f" .md)"
  klass_state="$(record_class_state "$f")"
  route="${RECORD_ROUTE[$id]}"
  priznak="$(record_field "$f" "ПРИЗНАК")"

  case "$klass_state" in
    ABSENT|PRESENT:инженерный)
      # ── МАРШРУТ (а): инженерный → консультант ────────────────────────────
      case "$route" in
        консультант) ;;  # ок
        батч)
          printf 'передаточное касание: инженерный форк адресован владельцу: %s\n' "$id" >&2
          exit 1 ;;
        со-ревью|свой)
          printf 'инженерный форк вне консультанта — маршрут (а) не подменяется: %s\n' "$id" >&2
          exit 1 ;;
        *)
          printf 'инженерный форк без распознанного МАРШРУТ: %s\n' "$id" >&2
          exit 1 ;;
      esac
      ;;
    PRESENT:воля-владельца)
      # ── МАРШРУТ (б): воля владельца → батч-очередь ──────────────────────
      # Проверка 1: МАРШРУТ обязан быть «батч».
      if [ "$route" != "батч" ]; then
        printf 'воля-владельца не в батче — маршрут (б) обязывает батч: %s\n' "$id" >&2
        exit 1
      fi
      # Проверка 2: ПРИЗНАК из закрытого перечня.
      found_p=0
      for p in $VOLI_PRIZNAKI; do [ "$p" = "$priznak" ] && found_p=1; done
      if [ "$found_p" != "1" ]; then
        printf 'признак «%s» вне перечня {деньги,риск,норма,приоритет}: %s\n' "$priznak" "$id" >&2
        exit 1
      fi
      # Проверка 3: АВТОР обязан присутствовать.
      avtor="$(record_field "$f" "АВТОР")"
      if [ -z "$avtor" ]; then
        printf 'воля без автора — независимость подписи неизмерима: %s\n' "$id" >&2
        exit 1
      fi
      # Проверка 4: свидетельство существует.
      witness_files=( "$ROOT/verdicts/consultant/$id-klass-v"*.md )
      if [ ! -e "${witness_files[0]}" ]; then
        printf 'без подтверждения класса — свидетельство отсутствует: %s\n' "$id" >&2
        exit 1
      fi
      # Поищем свидетельство с корректным ПОДТВЕРЖДЕНО.
      witness_model=""
      witness_podtv=0
      for vf in "${witness_files[@]}"; do
        [ -f "$vf" ] || continue
        m="$(record_field "$vf" "МОДЕЛЬ")"
        if grep -q '^ПОДТВЕРЖДЕНО: воля-владельца' "$vf" 2>/dev/null; then
          witness_model="$m"
          witness_podtv=1
          break
        fi
        # Сохраняем последнюю увиденную модель для проверки самоподтверждения.
        witness_model="$m"
      done
      # Проверка 5: МОДЕЛЬ свидетельства ≠ АВТОР записи.
      if [ -n "$witness_model" ] && [ "$witness_model" = "$avtor" ]; then
        printf 'самоподтверждение класса — модель свидетельства равна автору записи: %s\n' "$id" >&2
        exit 1
      fi
      # Проверка 6: в свидетельстве есть «ПОДТВЕРЖДЕНО: воля-владельца».
      if [ "$witness_podtv" != "1" ]; then
        printf 'класс не подтверждён — свидетельство без «ПОДТВЕРЖДЕНО: воля-владельца»: %s\n' "$id" >&2
        exit 1
      fi
      ;;
    PRESENT:дизайн)
      # ── МАРШРУТ (в): дизайн → со-ревью/свой ─────────────────────────────
      found_p=0
      is_rutina=0
      for p in $DIZ_PRIZNAKI_ALL; do
        if [ "$p" = "$priznak" ]; then
          found_p=1
          [ "$p" = "рутина" ] && is_rutina=1
        fi
      done
      if [ "$found_p" != "1" ]; then
        printf 'признак дизайна «%s» вне перечня: %s\n' "$priznak" "$id" >&2
        exit 1
      fi
      if [ "$is_rutina" = "1" ]; then
        if [ "$route" = "со-ревью" ]; then
          printf 'СОревью на рутине — ловец over-триггера (цена: вызов сильной модели): %s\n' "$id" >&2
          exit 1
        fi
        [ "$route" = "свой" ] || {
          printf 'рутинный дизайн обязан идти в «свой»: %s\n' "$id" >&2
          exit 1; }
      else
        if [ "$route" != "со-ревью" ]; then
          printf 'высокоставочный дизайн обязан идти в «со-ревью»: %s\n' "$id" >&2
          exit 1
        fi
        # Файл СОревью: ровно один.
        mapfile -t soreview_files < <(find "$ROOT/verdicts/consultant" -maxdepth 1 -type f \
                                       -name "${id}-soreview-v*.md" 2>/dev/null | sort)
        soreview_count="${#soreview_files[@]}"
        if [ "$soreview_count" -eq 0 ]; then
          printf 'СОревью не вызван — высокоставочный дизайн без файла обзора: %s\n' "$id" >&2
          exit 1
        fi
        if [ "$soreview_count" -ge 2 ]; then
          printf 'второй СОревью на одном предмете — обзор ОДИН: %s\n' "$id" >&2
          exit 1
        fi
        sf="${soreview_files[0]}"
        # Файл НЕ должен содержать самостоятельной строки accept либо reject.
        if grep -qE '^accept[[:space:]]*$' "$sf" 2>/dev/null \
           || grep -qE '^reject[[:space:]]*$' "$sf" 2>/dev/null; then
          printf 'СОревью вынес вердикт — самостоятельная строка accept/reject: %s\n' "$id" >&2
          exit 1
        fi
        # СОревью должно быть ДО вердикта критика по тому же предмету.
        critic_files=( "$ROOT/verdicts/critic/$id-v"*.md )
        if [ -e "${critic_files[0]}" ]; then
          if [ "$(stat -c %Y "$sf")" -gt "$(stat -c %Y "${critic_files[0]}")" ]; then
            printf 'СОревью после критика — mtime СОревью позже mtime критика: %s\n' "$id" >&2
            exit 1
          fi
        fi
      fi
      ;;
    PRESENT:*)
      value="${klass_state#PRESENT:}"
      printf 'неизвестный класс «%s» — допустимы только {инженерный,воля-владельца,дизайн}: %s\n' \
             "$value" "$id" >&2
      exit 1 ;;
    *)
      printf 'нераспознанное состояние КЛАСС для записи %s\n' "$id" >&2
      exit 1 ;;
  esac
done

# 4г. Все валидации прошли — печатаем деградации (если есть) и выходим с rc 0.
for line in "${DEGRADATION_LINES[@]}"; do
  printf '%s\n' "$line"
done
exit 0