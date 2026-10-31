# Обманный стаб батареи 150: мутация модели КОДОМ (Н-39); привязка к клетке —
# ТОЛЬКО source.json:.stab_vhod. Мутирует копию model/, не дерево харнесса.
import yaml


def mutiruj(koren):
    """арбитраж 150 П1: ИСПОЛНЯЕМЫЙ --out сбора ведёт в чужой каталог, а
    правильная строка сохранена КОММЕНТАРИЕМ в run шага сбора (with.path и
    env остаются каноническими). Старый z05 удовлетворялся подстрокой
    'mobile/zamer-out-$ZAMER_EKRAN' где угодно в run — комментарий её
    давал; публикация при этом недоказуема (upload грузит пустоту)."""
    p = koren / '.github' / 'workflows' / 'mobile.yml'
    wf = yaml.safe_load(p.read_text(encoding='utf-8'))
    shagi = wf['jobs']['e2e-proba-obryv']['steps']
    for s in shagi:
        if str(s.get('name') or '').startswith('Замер обрыва: сбор'):
            run = str(s['run'])
            assert '--out mobile/zamer-out-$ZAMER_EKRAN' in run, 'kanon --out ne najden'
            s['run'] = run.replace(
                '--out mobile/zamer-out-$ZAMER_EKRAN',
                '--out mobile/zamer-out-NEVER'
            ) + '\n# historical --out mobile/zamer-out-$ZAMER_EKRAN\n'
            break
    else:
        raise AssertionError('sbor-shag ne najden')
    p.write_text(yaml.safe_dump(wf, allow_unicode=True, sort_keys=False),
                 encoding='utf-8')
