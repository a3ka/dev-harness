# Обманный стаб: у ВТОРОГО child карты нет avd_port — serial этого child
# не выводим из карты (гейт/хук потеряли привязку порта именно у второго
# child; первый остаётся каноническим).
import json


def mutiruj(koren):
    p = koren / 'mobile' / 'ci-screens.json'
    karta = json.loads(p.read_text(encoding='utf-8'))
    for z in karta['ekrany']:
        if z['id'] == 'proba-matrica-dva':
            del z['avd_port']
    p.write_text(json.dumps(karta, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
