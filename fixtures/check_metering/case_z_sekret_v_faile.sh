# ПРИЧИНА: буквальное значение секрета найдено в файлах
#
# Ветвь (з): в РЕПОЗИТОРИИ нет буквальных значений секретов — grep значения
# порождённого токена по ВСЕМ файлам вне ./tmp и ./.git. Красный — копия
# реального ПРОКСИ, протекающая токеном в файл репозитория: каждый принятый
# запрос дописывает токен в scripts/proxy/token-leak.env (вне tmp). Значение
# реального прогона лежит в дереве — ветвь обязана его найти.
# Прокси, а не барьер: драйвер анти-плацебо кладёт в BARRIER_ROOT свежую копию
# барьера при каждом вызове — патч барьера стирается, патч прокси живёт.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$(make_repo)"
WORK_REPO="$R"

BARRIER_ROOT="$R" "$BARRIER" >/dev/null 2>&1 \
  || die "зелёный прогон не 0 — честное дерево не проходит ветвь (з)"

python3 - "$R/scripts/proxy/metering_proxy.ts" <<'PY'
import sys
p = sys.argv[1]
s = open(p, encoding='utf-8').read()
old = "const MAX_SAFE_BIG = 9007199254740992n"
new = ("const MAX_SAFE_BIG = 9007199254740992n\n"
       "// ПРОБОЙ ВЕТВИ (з): протекающий прокси дампит СОДЕРЖИМОЕ своего файла секретов\n"
       "// (METERING_TOKEN_<role>=<токен> — ровно то, что грепает ветвь) в файл репозитория\n"
       "// рядом с исходником (вне ./tmp). СИНХРОННО НА ЗАГРУЗКЕ МОДУЛЯ: до listen, до healthz,\n"
       "// до любой ветви — главный прокси поднимается в setup ПЕРЕД ветвью (з), гонки нет.\n"
       "try {\n"
       "  const _ci = process.argv.indexOf('--config')\n"
       "  if (_ci >= 0) {\n"
       "    const _cfg = JSON.parse(fs.readFileSync(process.argv[_ci + 1], 'utf8'))\n"
       "    fs.appendFileSync(new URL('./token-leak.env', import.meta.url), fs.readFileSync(_cfg.secrets_env, 'utf8'))\n"
       "  }\n"
       "} catch { /* утечка молчит — не роняем предмет */ }")
assert s.count(old) == 1, "якорь не уникален: healthz"
open(p, 'w', encoding='utf-8').write(s.replace(old, new))
PY

set +e
out="$(BARRIER_ROOT="$R" "$BARRIER" 2>&1)"
rc=$?
set -e
[ "$rc" = "1" ] || die "красный прогон не 1: rc=$rc; вывод: $out"
printf '%s' "$out" | grep -qF "з: буквальное значение секрета найдено в файлах" \
  || die "красный прогон не назвал причину «з: буквальное значение секрета найдено в файлах»: $out"
exit 0
