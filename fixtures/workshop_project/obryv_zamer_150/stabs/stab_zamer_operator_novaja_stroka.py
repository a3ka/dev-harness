# Обманный стаб: оператор || с переносом строки скрывает неисполняемый сбор.
import yaml


def mutiruj(koren):
    p = koren / '.github' / 'workflows' / 'mobile.yml'
    wf = yaml.safe_load(p.read_text(encoding='utf-8'))
    for s in wf['jobs']['e2e-proba-obryv']['steps']:
        if str(s.get('name') or '').startswith('Замер обрыва: сбор'):
            key = 'bash mobile/scripts/zamer_obryva.sh sbor'
            assert key in s['run']
            s['run'] = s['run'].replace(key, 'true ||\n' + key, 1)
            break
    else:
        raise AssertionError('sbor-shag ne najden')
    p.write_text(yaml.safe_dump(wf, allow_unicode=True, sort_keys=False),
                 encoding='utf-8')
