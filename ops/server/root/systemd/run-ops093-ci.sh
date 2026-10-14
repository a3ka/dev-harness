#!/usr/bin/env bash
# ops/server/root/systemd/run-ops093-ci.sh — CI-дверь второго uid для семьи 093
# (fork 093-provodka-ci-uid-door-ne-postroen; кандидат-тело —
# verdicts/consultant/fork-093-provodka-ci-uid-door-ne-postroen-v1.md).
#
# ПОЧЕМУ ЭТОТ КАТАЛОГ: файл НЕ является systemd-юнитом и станцией НЕ
# потребляется — install.sh копирует в /etc/systemd/system ТОЛЬКО именованные
# 7 юнитов (UNITS), rollback/verify тоже именованные. Каталог ops/server/root/
# systemd/ целиком входит в ЗОНА implementer замороженного контракта 093
# (frozen/contracts/093/4); путь scripts/run_ops093_ci.sh из вердикта
# консультанта зоной не покрыт, а условная sudo-ветка в общем lane-раннере
# scripts/run_ci_lane.sh ломала бы каждый шаг CI специальным случаем.
#
# ЧТО ДЕЛАЕТ (одноразовая VM GitHub Actions): создаёт системного
# непривилегированного пользователя ci093-agent (второй uid; НОВЫЙ sudoers НЕ
# выдаётся — используется существующий passwordless sudo runner-пользователя;
# агент sudo-прав НЕ получает), закрывает HOME раннера от чужого uid, строит
# скратч-копию дерева git archive HEAD (БЕЗ .git и credential-конфигурации
# чекаута; копию создаёт runner БЕЗ sudo — stat-uid корня остаётся uid
# раннера, euid семьи иной, ступень клетки 1 это различает), открывает
# /tmp/dev-harness-verify (sticky 1777 — обязательный скратч семейных клеток)
# и закрытый root:root 0700 /var/lib/orch-peak (защищаемый путь И-3/И-8 —
# семья обязана получить отказ ОС, это не стаб), затем исполняет НЕИЗМЕНЁННЫЙ
# guard (аргумент $1) от ci093-agent в чистой среде env -i и ПРОПУСКАЕТ его rc
# наверх без изменений. Арбитраж 093-i8b: граница исполнения ставится СНАРУЖИ
# — клетка 8 половина-Б зеленеет только через унаследованный чужой euid,
# поэтому сама семья/раннер uid не переключает.
#
# Предохранитель GITHUB_ACTIONS — защита от случайного локального запуска
# (useradd и chmod go-rwx "$HOME" на живой станции недопустимы), НЕ граница
# безопасности и не авторизация. Позитивный прогон измерим только на
# привилегированном раннере: ЗЕЛЁНО(093-bat) 10/10, все клетки rc 0,
# ИТОГ 093: rc=0.
#
# Использование (только lane CI, ключ
# check:granica-ispolneniya-093-family-selftest):
#   bash ops/server/root/systemd/run-ops093-ci.sh fixtures/_krasnye_093.sh
set -euo pipefail
[ "${GITHUB_ACTIONS:-}" = true ] || { printf 'CI-only door\n' >&2; exit 1; }
[ $# -eq 1 ] || { printf 'использование: run-ops093-ci.sh <guard>\n' >&2; exit 1; }
guard="$1"
# Второй uid: системный пользователь, закрытый пароль, собственный HOME,
# без группы sudo/runner. Идемпотентно — на повтор двери той же VM не падает.
id -u ci093-agent >/dev/null 2>&1 \
  || sudo -n useradd --system --user-group --create-home \
       --home-dir /var/lib/ci093-agent --shell /usr/sbin/nologin ci093-agent
chmod go-rwx "$HOME"
# Скратч семейных клеток (sticky 1777) и закрытый защищаемый путь И-3/И-8.
sudo -n install -d -o root -g root -m 1777 /tmp/dev-harness-verify
sudo -n install -d -o root -g root -m 700 /var/lib/orch-peak
# Копия дерева от uid раннера (НЕ sudo, БЕЗ chown агенту — uid владельца
# копии обязан отличаться от euid семьи, клетка 8 половина-А меряет stat vs id).
scratch="$(mktemp -d /tmp/dev-harness-verify/ci093-XXXXXX)"
trap 'rm -rf "$scratch"' EXIT
mkdir "$scratch/repo"
git archive HEAD | tar -x -C "$scratch/repo"
chmod 755 "$scratch" "$scratch/repo"
chmod -R a+rX,go-w "$scratch/repo"
cd "$scratch/repo"
sudo -n -H -u ci093-agent -- /usr/bin/env -i \
  PATH=/usr/bin:/bin HOME=/var/lib/ci093-agent LC_ALL=C.UTF-8 \
  /bin/bash "$guard"
