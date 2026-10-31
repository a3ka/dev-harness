# Обманный стаб батареи 150: мутация модели КОДОМ (Н-39); привязка к клетке —
# ТОЛЬКО source.json:.stab_vhod. Мутирует копию model/, не дерево харнесса.
def mutiruj(koren):
    """no-op замер: гейт сигнатуры всегда закрыт — артефакт не собирается."""
    p = koren / 'mobile' / 'scripts' / 'zamer_obryva.sh'
    t = p.read_text(encoding='utf-8')
    staryj = ('sovpadenija="$(grep -rlE --exclude-dir=diagnostics '
              '"$SIGNATURY_RE" "$NS" 2>/dev/null | head -20)"')
    novyj = 'sovpadenija=""'
    assert staryj in t
    p.write_text(t.replace(staryj, novyj, 1), encoding='utf-8')
