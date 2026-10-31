# Обманный стаб батареи 150: мутация модели КОДОМ (Н-39); привязка к клетке —
# ТОЛЬКО source.json:.stab_vhod. Мутирует копию model/, не дерево харнесса.
import yaml


def mutiruj(koren):
    """путь загрузки рассогласован: with.path ведёт в несуществующий каталог —
    зелёный шаг upload молча грузит пустоту (if-no-files-found: ignore),
    публикация недоказуема (атака критика 150 круг 1, блокер 6)."""
    p = koren / '.github' / 'workflows' / 'mobile.yml'
    wf = yaml.safe_load(p.read_text(encoding='utf-8'))
    shagi = wf['jobs']['e2e-proba-obryv']['steps']
    for s in shagi:
        if str(s.get('name') or '').startswith('Замер обрыва: артефакт'):
            s['with']['path'] = 'mobile/zamer-out-NEVER'
            break
    else:
        raise AssertionError('artefakt-shag ne najden')
    p.write_text(yaml.safe_dump(wf, allow_unicode=True, sort_keys=False),
                 encoding='utf-8')
