# ПРИЧИНА: харнес разошёлся с пином
# ОКРУЖЕНИЕ: PATH=$WORK/bin:$PATH
#
# Предмет `overlay.sh` — сверка ОСНОВАНИЯ контура. Красное предъявляется на нём, а не на
# разборе аргументов: фикстура «неизвестный аргумент» тоже даёт единицу, но о предмете
# барьера не говорит ничего.
#
# ПОДСТАВНОЙ `omp` НА PATH, а не установленный бинарь. Первая редакция требовала настоящий
# omp, и на машине без него барьер отвечал `NOT_IMPLEMENTED`. «Нечем проверить» не равно
# «проверено», значит фикстура была бы непрогоняемой в CI, а обеспечить барьеру инструменты —
# работа фикстуры, а не оправдание. Подставному нужно ровно два ответа: `--version` и
# `models list`, и второй строится ИЗ подставного конфига, чтобы соответствие модели задаче
# проверялось по-настоящему, а не пропускалось из-за пустого списка.
# ОКРУЖЕНИЕ ОБЪЯВЛЕНО В ШАПКЕ, а не подставлено по ходу — так решил арбитраж
# `verdicts/arbitration/oblast-i-porog.md`, вопрос 3. Прежняя редакция писала `PATH=…` перед
# вызовом, и повторный прогон проверяющего этого не воспроизводил; когда окружение стали
# записывать на диск, адверсарий его переписал и получил красное без единого настоящего
# красного вызова. Теперь добавка к окружению — закоммиченный текст, который читают адверсарий
# и ревьюер: подставить инструмент можно только ЯВНО.
#
# Пин на зелёном прогоне называет сумму подставного бинаря — так и должно быть: пин описывает
# ФАКТИЧЕСКИ установленный харнес, а установлен здесь подставной.
set -euo pipefail
mkdir -p "$WORK/scripts" "$WORK/config" "$WORK/bin" "$WORK/.omp" "$WORK/roles"
cp -r "$REPO/.omp/agents" "$WORK/.omp/"
cp "$REPO/.omp/config.yml" "$REPO/.omp/models.yml" "$WORK/.omp/"
cp "$REPO"/roles/*.md "$WORK/roles/"
cp "$REPO/scripts/gen-harness.ts" "$REPO/scripts/roles.ts" "$WORK/scripts/"

# Подставной omp: версия берётся из пина репозитория, список моделей — из подставного
# конфига, все с картинками, чтобы соответствие модели задаче было зелёным.
ver="$(python3 -c 'import json,sys;print(json.load(open(sys.argv[1]))["version"])' "$REPO/config/harness_pin.json")"
{
  printf 'if [ "${1:-}" = "--version" ]; then printf "omp/%s\\n"; exit 0; fi\n' "$ver"
  printf 'if [ "${1:-}" = "models" ]; then\n'
  printf '  printf "│ model │ a │ b │ c │ images │\\n"\n'
  grep -oE '"[a-z-]+/[^"]+"' "$WORK/.omp/config.yml" | tr -d '"' | sed 's|.*/||' | sort -u \
    | while IFS= read -r m; do printf '  printf "│ %s │ x │ x │ x │ yes │\\n"\n' "$m"; done
  printf '  exit 0\n'
  printf 'fi\n'
  printf 'printf "подставной omp: %%s не поддержан\\n" "${1:-}" >&2; exit 1\n'
} > "$WORK/bin/omp"
chmod +x "$WORK/bin/omp"

sum="$(sha256sum "$WORK/bin/omp" | cut -d' ' -f1)"
python3 - "$REPO/config/harness_pin.json" "$WORK/config/harness_pin.json" "$sum" <<'PY'
import json, sys
src, dst, sha = sys.argv[1], sys.argv[2], sys.argv[3]
pin = json.load(open(src))
pin['sha256'] = sha
json.dump(pin, open(dst, 'w'), indent=2, ensure_ascii=False)
PY

BARRIER_ROOT="$WORK" "$BARRIER" --check

# Порча предмета: сумма в пине больше не отвечает установленному харнесу.
python3 - "$WORK/config/harness_pin.json" <<'PY'
import json, sys
p = sys.argv[1]
pin = json.load(open(p))
pin['sha256'] = '0' * 64
json.dump(pin, open(p, 'w'), indent=2, ensure_ascii=False)
PY
BARRIER_ROOT="$WORK" "$BARRIER" --check
