# Обманный стаб батареи 150: мутация модели КОДОМ (Н-39); привязка к клетке —
# ТОЛЬКО source.json:.stab_vhod. Мутирует копию model/, не дерево харнесса.
def mutiruj(koren):
    """наивный гейт: сигнатура ищется по ВСЕМУ ns — архив диагностики упавшей
    первой попытки 995 (ns/diagnostics/attempt-1, сохраняется и при
    RECOVERED-зелёном) соблазняет гейт publishes в зелёном job (блокер 4
    круга 1: обход через сохранённую диагностику frozen 995/5)."""
    p = koren / 'mobile' / 'scripts' / 'zamer_obryva.sh'
    t = p.read_text(encoding='utf-8')
    staryj = ('sovpadenija="$(grep -rlE --exclude-dir=diagnostics '
              '"$SIGNATURY_RE" "$NS" 2>/dev/null | head -20)"')
    novyj = 'sovpadenija="$(grep -rlE "$SIGNATURY_RE" "$NS" 2>/dev/null | head -20)"'
    assert staryj in t, 'gate grep ne najden'
    p.write_text(t.replace(staryj, novyj, 1), encoding='utf-8')
