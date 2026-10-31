# Обманный стаб батареи 150: мутация модели КОДОМ (Н-39); привязка к клетке —
# ТОЛЬКО source.json:.stab_vhod. Мутирует копию model/, не дерево харнесса.
import yaml


def mutiruj(koren):
    """Круг 3, блок 1 (П1): вызов sbor спрятан в ПРАВЫЙ операнд `||` у
    `true` — сбор гарантированно пропускается, текстовый --out остаётся
    каноническим, шаг rc 0; старый z05 разбирал `||` как границу и считал
    неисполняемый вызов доказанным (ATTACK_RC 0, 17/17 зелёных). Новый z05
    требует БЕЗУСЛОВНУЮ позицию вызова — SBOR_NE_BEZUSLOVEN."""
    p = koren / '.github' / 'workflows' / 'mobile.yml'
    wf = yaml.safe_load(p.read_text(encoding='utf-8'))
    shagi = wf['jobs']['e2e-proba-obryv']['steps']
    for s in shagi:
        if str(s.get('name') or '').startswith('Замер обрыва: сбор'):
            run = str(s['run'])
            kljuch = 'bash mobile/scripts/zamer_obryva.sh sbor'
            assert kljuch in run, 'kanon vyzov sbor ne najden'
            s['run'] = run.replace(kljuch, 'true || ' + kljuch, 1)
            break
    else:
        raise AssertionError('sbor-shag ne najden')
    p.write_text(yaml.safe_dump(wf, allow_unicode=True, sort_keys=False),
                 encoding='utf-8')
