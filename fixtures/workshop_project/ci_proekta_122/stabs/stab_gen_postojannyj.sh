#!/usr/bin/env bash
# ОБМАННЫЙ СТАБ (Н-39): генератор-пустышка — всегда rc 0, манифест/профиль не читает,
# байтов не пишет. Наблюдаемое расхождение с честной реализацией: клетки g1 (нет манифеста
# обязана дать rc 1), g2, g3 (ручная правка обязана дать rc 1), g5–g7; связка --write/--check
# ловится клетками g3-write-vosstanavlivaet и g4 (недетерминизм/отсутствие записи).
case "${1:-}" in
  --repo) : ;;
esac
case "${2:-}${3:-}" in
  *--check*) printf 'gen OK: check\n'; exit 0 ;;
  *--write*) printf 'gen OK: write\n'; exit 0 ;;
esac
printf 'gen OK: check\n'
exit 0
