# fixtures/handoff_rotate/_toy.sh — каркас toy-миров семьи handoff_rotate (контракт 091
# «ротация HANDOFF»). Имя НЕ red_*/case_*: сам он фикстурой не является. Подключают его
# раннер fixtures/_krasnye_091.sh (список субъектов), батарея red_rotate_091.sh и стаб-пак
# red_stuby_091.sh. При подключении — только определения и скратч, побочных действий вне
# скратча нет.
#
# ЧТО ДАЁТ:
#  * H91_SUBJECTS — ЕДИНСТВЕННЫЙ список «предмет присутствует» (scripts/handoff_rotate.sh);
#    раннер читает его отсюда, второй копии списка нет.
#  * Константы грамматики — побайтово из контракта 091 (И-1–И-7): префикс заголовка секции,
#    маркеры 084 (И-5 того контракта; 091 несёт их константами — прецедент константы k7,
#    арбитраж 088 круг 5), порог 30 КБ, именованные строки отказов, строка stdout.
#  * МОДЕЛЬ МИРА В ПАМЯТИ (W_*): куски HANDOFF — префикс, секция «## ГДЕ МЫ», маркерный
#    блок, хвост — как строки в переменных; toy-файл пишется ИЗ модели, оракул (байты
#    архива, байты итогового HANDOFF) — ТОЛЬЖЕ из модели (правило 8: ожидание — в памяти
#    проверяющего ДО вызова субъекта; диск субъекта не перечитывается).
#  * Построители: h91_rnd_line — конформная случайная непустая строка (алфавит исключает
#    `## `-начала и маркерные строки — грамматика входа не нарушается случайностью);
#    h91_set_konform — конформный набор кусков (секция с `###`-подразделами и пустыми
#    строками, маркерный блок); h91_write_toy — пишет toy-корень из W_*.
#  * Прогон субъекта h91_probe_run: rc/stdout/stderr в файлах скратча; субъект задаётся
#    env H91_SUBJECT (умолчание — $ROOT/scripts/handoff_rotate.sh); стаб-пак подставляет
#    туда мини-субъекты.
#
# ГЕРМЕТИЧНОСТЬ: git не используется вовсе — предмет 091 чистая трансформация файлов;
# toy-корни и ожидания живут в скратче mktemp.

H91_SUBJECTS=(scripts/handoff_rotate.sh)

# h91_missing_subjects <корень> — печатает через пробел отсутствующие субъекты.
h91_missing_subjects() {
  local root="$1" s miss=''
  for s in "${H91_SUBJECTS[@]}"; do
    [ -f "$root/$s" ] || miss="$miss $s"
  done
  printf '%s' "${miss# }"
}

# ── Грамматика контракта 091 (побайтово) ────────────────────────────────────────────────
H91_SEC='## ГДЕ МЫ'
H91_H2='## '
H91_BEGIN='<!-- BEGIN GENERATED NEXT SESSION -->'
H91_END='<!-- END GENERATED NEXT SESSION -->'
H91_LIMIT=30720
H91_ARCHDIR='docs/handoff-archive'
H91_DATE_RE='^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
# Именованные строки отказов (И-2; единый источник — здесь):
H91_OTKAZ_NET='ОТКАЗ: HANDOFF.md отсутствует'
H91_OTKAZ_DATE='ОТКАЗ: --date вне грамматики YYYY-MM-DD'
H91_OTKAZ_NOL='ОТКАЗ: в HANDOFF.md нет раздела «## ГДЕ МЫ»'
H91_OTKAZ_MANY='ОТКАЗ: в HANDOFF.md больше одного раздела «## ГДЕ МЫ»'
H91_OTKAZ_BIG='ОТКАЗ: итоговый HANDOFF.md больше 30 КБ'
H91_OTKAZ_EXIST_PRE='ОТКАЗ: архив уже существует: '
# Строка stdout успеха (И-1): «архив: docs/handoff-archive/<дата>.md»
H91_OK_PRE='архив: '
# Фиксированная дата клеток (детерминизм; default-дата субъекта — живой прогон ж1).
H91_DATE='2030-01-01'

SCR="$(mktemp -d "${TMPDIR:-/tmp}/handoff091.XXXXXX")" \
  || { printf 'NOT_IMPLEMENTED: нет скратча\n' >&2; exit 2; }

# ── Случайность (bash RANDOM; значения случайны на прогон) ─────────────────────────────
h91_rnd() { H91_R=$(( (RANDOM * 32768 + RANDOM) % $1 )); }
h91_pick() { local a=("$@"); h91_rnd "${#a[@]}"; H91_P="${a[$H91_R]}"; }

# h91_rnd_line — КОНФОРМНАЯ непустая строка: не начинается с `#`, не маркер, 8–70 байт.
# Алфавит: кириллица/латиница/цифры/пунктуация бытовых строк HANDOFF (включая ведущий
# `- ` маркер пункта), НИКОГДА не `## ГДЕ МЫ…`/`## …`/`<!-- … -->` — случайность не
# рождает границу секции (демаркация §Приёмки 091).
h91_rnd_line() {
  local words=('состояние' 'чекпойнт' 'ветка' 'тег' 'прогон' 'красная' 'зелёная' 'файл'
    'строка' 'байт' 'отказ' 'причина' 'сессия' 'субагент' 'заморозка' 'контракт' 'реестр'
    'порог' 'архив' 'ротация' 'маркер' 'пара' 'трек' 'источник' 'owner' 'verdict' 'wip'
    'main' 'CI' 'git' 'bash' 'python3' 'sha256' 'cmp' 'grep' 'awk' 'HEAD' 'PR' 'run')
  local n i w line
  h91_rnd 6; n=$((H91_R + 2))
  line=''
  for ((i = 0; i < n; i++)); do
    h91_pick "${words[@]}"; w="$H91_P"
    case $i in
      0) h91_rnd 4; case $H91_R in 0) line="- $w" ;; 1) line="$w:" ;; 2) line="**$w** —" ;; *) line="$w" ;; esac ;;
      *) line="$line $w" ;;
    esac
  done
  h91_rnd 4
  case $H91_R in
    0) line="$line." ;;
    1) line="$line;" ;;
    2) line="$line ($w)" ;;
    *) line="$line," ;;
  esac
  H91_LINE="$line"
}

# h91_set_konform — модель конформного HANDOFF в W_PREFIX/W_SECTION/W_MARKERS/W_TAIL:
# секция с заголовком «## ГДЕ МЫ (…)», ≥2 пустыми строками, ≥2 `###`-подразделами и
# ≥4 непустыми строками; маркерный блок 084-формы (BEGIN, заголовок генерации, пустая,
# строка плана, END). По умолчанию префикс и хвост пусты (живая форма: секция первая,
# маркеры в конце файла).
h91_set_konform() {
  local n i pod=''
  W_PREFIX=''
  W_TAIL=''
  W_ARCH_EXIST=''
  W_ARCH_BYTES=''
  W_ARCH_FOREIGN=''
  W_SECTION="## ГДЕ МЫ (2030-01-01, ~0$((RANDOM % 9 + 1)):00 UTC) — чекпойнт"
  h91_rnd 4; n=$((H91_R + 5))
  for ((i = 0; i < n; i++)); do
    case $((i % 3)) in
      0) W_SECTION="$W_SECTION
" ;;
      1) h91_rnd_line; W_SECTION="$W_SECTION
$H91_LINE" ;;
      *) pod="$((pod + 1))"; W_SECTION="$W_SECTION
### Подраздел $pod — $H91_LINE" ;;
    esac
  done
  # Каждый непустой кусок несёт завершающий LF — склейка кусков не сливает строки.
  W_SECTION="$W_SECTION
"
  W_MARKERS="$H91_BEGIN
## Следующая сессия (генерируется: bash scripts/gen_plan.sh --write)

- 082 · пара 1 · заморожен · трек CI
$H91_END
"
}

# h91_write_toy <dir> — пишет toy из W_*: HANDOFF.md = префикс+секция+маркеры+хвост
# (каждый кусок может быть пуст; куски несут свои завершающие LF в модели). Существующий
# архив клетки создают сами: W_ARCH_EXIST='да' + W_ARCH_BYTES, чужой файл —
# W_ARCH_FOREIGN (2029-12-31.md).
h91_write_toy() {
  local d="$1"
  rm -rf "$d"; mkdir -p "$d" || return 2
  printf '%s%s%s%s' "$W_PREFIX" "$W_SECTION" "$W_MARKERS" "$W_TAIL" > "$d/HANDOFF.md" || return 2
  if [ "${W_ARCH_EXIST:-}" = 'да' ]; then
    mkdir -p "$d/$H91_ARCHDIR" || return 2
    printf '%s' "${W_ARCH_BYTES:-}" > "$d/$H91_ARCHDIR/$H91_DATE.md" || return 2
  fi
  if [ -n "${W_ARCH_FOREIGN:-}" ]; then
    mkdir -p "$d/$H91_ARCHDIR" || return 2
    printf '%s' "$W_ARCH_FOREIGN" > "$d/$H91_ARCHDIR/2029-12-31.md" || return 2
  fi
}

# h91_expected_archive / h91_expected_result — оракул ИЗ МОДЕЛИ (правило 8).
h91_expected_archive() { printf '%s' "$W_SECTION"; }
h91_expected_result()  { printf '%s%s%s' "$W_PREFIX" "$W_MARKERS" "$W_TAIL"; }

# h91_sha <файл> — sha256 для атомарности отказов.
h91_sha() { sha256sum < "$1" | cut -d' ' -f1; }

# h91_probe_run <toy> [аргументы…] — прогон субъекта: rc в H91_RC, stdout/stderr —
# файлы $SCR/out, $SCR/err. Субъект: env H91_SUBJECT, умолчание — $H91_ROOT/scripts/
# handoff_rotate.sh. Вызов: bash <субъект> --root <toy> <аргументы клетки> — дату несёт
# клетка (--date $H91_DATE либо дефектная форма клеток о6/о8).
h91_probe_run() {
  local toy="$1"; shift
  local subj="${H91_SUBJECT:-$H91_ROOT/scripts/handoff_rotate.sh}"
  bash "$subj" --root "$toy" "$@" > "$SCR/out" 2> "$SCR/err"
  H91_RC=$?
}

# h91_err_has <литеральная строка> — stderr несёт её самостоятельной строкой.
h91_err_has() { grep -Fxq -- "$1" "$SCR/err"; }
