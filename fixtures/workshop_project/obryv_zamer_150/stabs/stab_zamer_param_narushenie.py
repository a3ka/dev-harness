# Обманный стаб: тип параметра рендера — у ВТОРОГО работника ns карты
# ведёт наружу воркспейса (env согласован с картой, потому z02 молчит):
# закрытый тип ns (mobile/… без '..') — KANON_150_PARAM, рендер канона
# невозможен; гейт с ns-побегом грепил бы чужие каталоги.
import json


def mutiruj(koren):
    p = koren / 'mobile' / 'ci-screens.json'
    karta = json.loads(p.read_text(encoding='utf-8'))
    for z in karta['ekrany']:
        if z['id'] == 'proba-drugoj':
            z['output_namespace'] = '../vne-vorkspejsa'
    p.write_text(json.dumps(karta, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    w = koren / '.github' / 'workflows' / 'mobile.yml'
    tekst = w.read_text(encoding='utf-8')
    assert tekst.count('ZAMER_NS: mobile/maestro-out-drugoj') == 2
    tekst = tekst.replace('ZAMER_NS: mobile/maestro-out-drugoj',
                          'ZAMER_NS: ../vne-vorkspejsa')
    w.write_text(tekst, encoding='utf-8')
