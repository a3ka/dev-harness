# ── чек (5, контракт 087 И-5): код в main только через PR ─────────────────────
# МОДЕЛЬ вставки в scripts/gitw_preflight_071.sh — НЕ субъект: батарея (режим --model)
# вставляет этот блок в копию живого предполёта перед строкой «# ── чек (1)». Класс
# пуша — ci_klass.sh vorota <вершина main цели> <отправляемый tip>: учётный пуш
# прозрачен без API; код — только при доказательстве тяжёлого прогона по хешу.
if ! git cat-file -e "${rmain}^{commit}" 2>/dev/null; then
  printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: код в main: вершина main цели %s не в локальной истории — сделай fetch\n' "$rmain" >&2
  exit 1
fi
vor_out="$(bash "$(dirname "${BASH_SOURCE[0]}")/ci_klass.sh" vorota "$rmain" "$send_tip" 2>&1)"
vor_rc=$?
if [ "$vor_rc" -ne 0 ]; then
  printf 'gitw ПРЕДПОЛЁТ-ОТКАЗ: %s\n' "${vor_out#ОТКАЗ: }" >&2
  exit 1
fi
printf 'gitw ПРЕДПОЛЁТ: код-через-PR: %s\n' "$vor_out" >&2

