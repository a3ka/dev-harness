# Обманный стаб батареи 150: мутация модели КОДОМ (Н-39); привязка к клетке —
# ТОЛЬКО source.json:.stab_vhod. Мутирует копию model/, не дерево харнесса.
import yaml


def mutiruj(koren):
    """Сбор виден в here-doc, но shell исполняет только cat; журнал пуст."""
    p = koren / '.github' / 'workflows' / 'mobile.yml'
    wf = yaml.safe_load(p.read_text(encoding='utf-8'))
    shagi = wf['jobs']['e2e-proba-obryv']['steps']
    for s in shagi:
        if str(s.get('name') or '').startswith('Замер обрыва: сбор'):
            run = str(s['run'])
            kljuch = '--out mobile/zamer-out-$ZAMER_EKRAN'
            assert kljuch in run, 'kanon --out ne najden'
            s['run'] = run.replace(
                'bash mobile/scripts/zamer_obryva.sh sbor',
                "cat <<'ZAMER_EOF'\nbash mobile/scripts/zamer_obryva.sh sbor", 1
            ).replace(kljuch, kljuch + "\nZAMER_EOF", 1)
            break
    else:
        raise AssertionError('sbor-shag ne najden')
    p.write_text(yaml.safe_dump(wf, allow_unicode=True, sort_keys=False),
                 encoding='utf-8')
