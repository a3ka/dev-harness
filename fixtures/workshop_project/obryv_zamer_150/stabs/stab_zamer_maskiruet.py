# Обманный стаб батареи 150: мутация модели КОДОМ (Н-39); привязка к клетке —
# ТОЛЬКО source.json:.stab_vhod. Мутирует копию model/, не дерево харнесса.
import yaml

def mutiruj(koren):
    """маскировка красного: continue-on-error на экранный (продуктовый) шаг."""
    p = koren / '.github' / 'workflows' / 'mobile.yml'
    wf = yaml.safe_load(p.read_text(encoding='utf-8'))
    shagi = wf['jobs']['e2e-proba-obryv']['steps']
    for s in shagi:
        if str(s.get('name') or '').startswith('Экранная пачка'):
            s['continue-on-error'] = True
            break
    else:
        raise AssertionError('ekrannoj shag ne najden')
    p.write_text(yaml.safe_dump(wf, allow_unicode=True, sort_keys=False), encoding='utf-8')
