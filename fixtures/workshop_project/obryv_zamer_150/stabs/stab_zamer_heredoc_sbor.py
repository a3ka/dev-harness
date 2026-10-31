# Обманный стаб батареи 150: мутация модели КОДОМ (Н-39); привязка к клетке —
# ТОЛЬКО source.json:.stab_vhod. Мутирует копию model/, не дерево харнесса.
import yaml


def mutiruj(koren):
    """Круг 3, блок 1 (П1), here-doc из закрывающего свойства: вызов sbor
    получает here-doc (<<) — неkanonicheskaja форма исполнения шага сбора;
    старый z05 разбирал `<<` как две границы `<` и считал вызов зелёным.
    Новый разбор структуры исполнения: here-doc — именованный отказ
    SBOR_RUN_NE_RASPOZNAN."""
    p = koren / '.github' / 'workflows' / 'mobile.yml'
    wf = yaml.safe_load(p.read_text(encoding='utf-8'))
    shagi = wf['jobs']['e2e-proba-obryv']['steps']
    for s in shagi:
        if str(s.get('name') or '').startswith('Замер обрыва: сбор'):
            run = str(s['run'])
            kljuch = '--out mobile/zamer-out-$ZAMER_EKRAN'
            assert kljuch in run, 'kanon --out ne najden'
            s['run'] = run.replace(
                kljuch, kljuch + " <<'ZAMER_EOF'\ntelo here-doc ne kanon\nZAMER_EOF", 1)
            break
    else:
        raise AssertionError('sbor-shag ne najden')
    p.write_text(yaml.safe_dump(wf, allow_unicode=True, sort_keys=False),
                 encoding='utf-8')
