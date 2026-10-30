# Обманный стаб батареи 150: мутация модели КОДОМ (Н-39); привязка к клетке —
# ТОЛЬКО source.json:.stab_vhod. Мутирует копию model/, не дерево харнесса.
def mutiruj(koren):
    """зелёный краснеет: закрытый гейт выходит 1 — обёртка меняет итог job."""
    p = koren / 'mobile' / 'scripts' / 'zamer_obryva.sh'
    t = p.read_text(encoding='utf-8')
    staryj = "    printf 'ZAMER_SBOR: signatur obryva v %s net — artefakt ne publikuetsja\\n' \"$NS\"\n    exit 0"
    novyj = "    printf 'ZAMER_SBOR: signatur obryva v %s net — artefakt ne publikuetsja\\n' \"$NS\"\n    exit 1"
    assert staryj in t, 'marker ghejta ne najden'
    p.write_text(t.replace(staryj, novyj, 1), encoding='utf-8')
