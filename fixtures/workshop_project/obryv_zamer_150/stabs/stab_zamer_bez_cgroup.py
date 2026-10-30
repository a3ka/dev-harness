# Обманный стаб батареи 150: мутация модели КОДОМ (Н-39); привязка к клетке —
# ТОЛЬКО source.json:.stab_vhod. Мутирует копию model/, не дерево харнесса.
def mutiruj(koren):
    """потеря строки cgroup: чтение файлов cgroup подменено на несуществующие."""
    p = koren / 'mobile' / 'scripts' / 'zamer_obryva.sh'
    t = p.read_text(encoding='utf-8')
    for staryj, novyj in (('"$CG/memory.current"', '"$CG/netu0"'),
                          ('"$CG/memory.events"', '"$CG/netu1"'),
                          ('"$CG/cpu.stat"', '"$CG/netu2"'),
                          ('"$CG/cpu.pressure"', '"$CG/netu3"'),
                          ('"$CG/memory.pressure"', '"$CG/netu4"')):
        assert staryj in t, staryj
        t = t.replace(staryj, novyj)
    p.write_text(t, encoding='utf-8')
