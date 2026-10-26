#!/usr/bin/env bash
# СТАБ 142: белый список по букве слова владельца — судит только *_API_KEY/_TOKEN/_SECRET
# и пароли (PASSWORD/PASSWD); неназванные секретные имена (DATABASE_URL, PRIVATE_KEY,
# STRIPE_KEY, KEY_PASSPHRASE, AUTH, COOKIE) пропускаются — fail-open.
# Привязка к клеткам — source.json:.stab_vhod["stab_belyj-spisok-vladeltsa"] (Н-39, по коду).
# Генератор: $1 = каталог честной модели, $2 = путь субъекта-стаба.
set -eu
python3 - "$1/connect_project.sh" "$2" <<'PY'
import sys
src = open(sys.argv[1], encoding="utf-8").read()
a0 = "    _ku=$(printf '%s' \"$k\" | tr 'a-z' 'A-Z')\n"
a1 = "    fi\n    printf '%s\\n' \"$v\"\n"
assert src.count(a0) == 1 and src.count(a1) == 1, "точка правки модели не найдена: предикат 142"
i, j = src.index(a0), src.index(a1) + len(a1)
bel = """    case "$k" in
      *_API_KEY|*_TOKEN|*_SECRET|*PASSWORD*|*PASSWD*) ;;
      *) continue ;;
    esac
"""
open(sys.argv[2], "w", encoding="utf-8").write(src[:i] + bel + "    printf '%s\\n' \"$v\"\n" + src[j:])
PY
