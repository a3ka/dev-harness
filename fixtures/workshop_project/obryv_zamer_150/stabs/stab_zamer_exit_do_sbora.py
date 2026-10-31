# Обманный стаб батареи 150: мутация модели КОДОМ (Н-39); привязка к клетке —
# ТОЛЬКО source.json:.stab_vhod. Мутирует копию model/, не дерево харнесса.
import yaml


def mutiruj(koren):
    """Круг 3, блок 1 (П1), родственный дефект класса «пропущенный сбор»
    (Н-62): безусловный `exit 0` выше вызова sbor — шаг завершается ДО
    сбора, upload грузит пустоту; старый z05 видел единственный вызов в
    безусловной позиции и был зелёным. Новый z05: безусловный exit до
    вызова — SBOR_NEDOSTIZHIM."""
    p = koren / '.github' / 'workflows' / 'mobile.yml'
    wf = yaml.safe_load(p.read_text(encoding='utf-8'))
    shagi = wf['jobs']['e2e-proba-obryv']['steps']
    for s in shagi:
        if str(s.get('name') or '').startswith('Замер обрыва: сбор'):
            run = str(s['run'])
            kljuch = 'bash mobile/scripts/zamer_obryva.sh sbor'
            assert kljuch in run, 'kanon vyzov sbor ne najden'
            s['run'] = run.replace(kljuch, 'exit 0\n' + kljuch, 1)
            break
    else:
        raise AssertionError('sbor-shag ne najden')
    p.write_text(yaml.safe_dump(wf, allow_unicode=True, sort_keys=False),
                 encoding='utf-8')
