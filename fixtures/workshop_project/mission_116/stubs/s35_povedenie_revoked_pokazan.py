# Стаб (Н-39): копия честной статической пробы 116, отключена ровно одна проверка (sud_revoked_skryt); на своём входе stab_vhod пропускает дефект, на остальных ведёт себя честно.
#!/usr/bin/env python3
# Статическая проба 116 (третий субъект батареи): поведенческие оси F05
# (issue #9) и рендер состояний composer без PNG — ПО КОДУ ЭКРАНА
# (mobile/src/features/conversation/conversation-screen.tsx), не по
# декларации манифеста. Ожидания — закрытые литералы ЗДЕСЬ (оракул в
# памяти проверяющего, правило 8: значения каталога — побайтово из
# BrokerOS_UI_Copy_DE, токены — из ds/tokens.css, суффикс чипа — из
# компонентов D2.2.5.1); манифест пачки — вторичная декларация, сверяется
# с закрытым эталоном пробы. rc 1 — PRICHINA по имени ветви; rc 0 — тихо.
import argparse
import json
import re
import sys
from pathlib import Path

SCREEN = 'mobile/src/features/conversation/conversation-screen.tsx'

# Каталог (побайтово из BrokerOS_UI_Copy_DE.json): только ключи, которые
# рендерят состояния composer без PNG.
KATALOG = {
    'frame.F05.07.title': 'Nicht gesendeter Entwurf',
    'frame.F05.07.body':
        'Ihre Nachricht wurde noch nicht gesendet. Sie können sie weiterbearbeiten.',
    'frame.F05.05.title': 'Antwort wird vorbereitet',
    'frame.F05.05.body':
        'Sie können die Bearbeitung unterbrechen. Bereits vorliegende Ergebnisse bleiben sichtbar.',
    'state.G06.title': 'Keine Verbindung',
    'global.retry': 'Erneut prüfen',
    'frame.F05.02.title': 'Gesprächsverlauf',
    'action.F05.A01': 'Nachricht senden',
}

# Закрытая карта состояний: кадр → (условие блока, testID, токены класса).
# Манифест sostojanija_bez_png.json обязан совпасть с этой картой.
SOSTOJANIJA = {
    'F05.07': ("sendState === 'draft'", 'mission_frame_f05_07',
               ('panel', 'on-card', 'line', 'ink-muted')),
    'F05.V01': ("sendState === 'queued_offline'", 'mission_queued_offline',
                ('warm', 'on-warm', 'panel')),
    'F05.V02': ("response === 'interrupted'", 'mission_response_interrupted',
                ('panel', 'ink', 'line')),
    'F05.V04': ("sendState === 'already_accepted'",
                'mission_already_accepted', ('calm', 'on-calm', 'panel')),
}
CHIP = {
    'uslovie': "sendState === 'attachment_pending'",
    'testid': 'mission_chip_wird_gelesen',
    'suffiks': ' · wird gelesen',
}
AUDIT_TOKENOV = {
    'panel', 'on-card', 'line', 'ink-muted', 'warm', 'on-warm', 'ink',
    'calm', 'on-calm',
}


def prichina(imja, detal):
    print('PRICHINA\t%s\t%s' % (imja, detal), file=sys.stderr)


def blok(screen, uslovie):
    """Условный блок состояния: от '{<cond> ? (' до парного ') : null}'."""
    nach = screen.find('{%s ? (' % uslovie)
    if nach < 0:
        return None
    konec = screen.find(') : null}', nach)
    return None if konec < 0 else screen[nach:konec]


def klassy(b):
    m = re.search(r'className="([a-z0-9 -]+)"', b)
    return set(m.group(1).split()) if m else set()


def strokovye_litery(b):
    """Пользовательские строки блока: одинарно-кавычные литералы со
    пробелом, без разметки ({, }, <, >) и переводов строк внутри."""
    return [m for m in re.findall(r"'([^'{}<>\n]+ [^'{}<>\n]+)'", b)
            if re.match(r"[A-Za-zÄÖÜäöüß]", m)]


def sud_draft_v_kompozere(screen, opis):
    if 'value={draft}' not in screen or 'onChangeText={setDraft}' not in screen:
        return [('POVEDENIE_DRAFT_V_KOMPOZERE', 'value/onChangeText')]
    return []


def sud_draft_v_hranilishche(screen, opis):
    if 'let draftStore' not in screen or 'useState(draftStore)' not in screen \
            or 'draftStore = next;' not in screen:
        return [('POVEDENIE_DRAFT_V_HRANILISHCHE', 'draftStore')]
    return []


def _telo_funkcii(screen, imja):
    m = re.search(r'const %s = (?:async )?\(' % imja, screen)
    if not m:
        return ''
    k = screen.find('};', m.start())
    return screen[m.start():k]


def sud_draft_snimaetsja(screen, opis):
    otkazy = []
    m = re.search(r"if \(status === 'accepted'\) \{(.*?)\}", screen, re.S)
    if not m or "setDraft('')" not in m.group(1):
        otkazy.append(('POVEDENIE_DRAFT_SNIMAETSJA', 'accepted'))
    if "setDraft('')" not in _telo_funkcii(screen, 'onNewTopic'):
        otkazy.append(('POVEDENIE_DRAFT_SNIMAETSJA', 'novaja_tema'))
    return otkazy


def sud_draft_terjaetsja(screen, opis):
    telo = _telo_funkcii(screen, 'onAttach')
    if "setDraft('')" in telo:
        return [('POVEDENIE_DRAFT_TERJAETSJA', 'vlozhenie')]
    return []


def sud_intent_otdelnyj(screen, opis):
    telo = _telo_funkcii(screen, 'onNewTopic')
    i_intent, i_post = telo.find('api.createIntent('), telo.find('api.postMessage(')
    if i_intent < 0 or i_post < 0 or not i_intent < i_post:
        return [('POVEDENIE_INTENT_NE_OTDELEN', 'createIntent>postMessage')]
    return []


def sud_already_accepted_bez_dublja(screen, opis):
    m = re.search(r"if \(status === 'already_accepted'\) \{(.*?)\}", screen, re.S)
    if not m:
        return [('POVEDENIE_ALREADY_ACCEPTED_BEZ_DUBLJA', 'vetka')]
    telo = m.group(1)
    if 'setMessages' in telo or 'appendMessages' in telo or 'messages.concat' in telo:
        return [('POVEDENIE_ALREADY_ACCEPTED_DUBL', 'append')]
    if 'setSendState' not in telo:
        return [('POVEDENIE_ALREADY_ACCEPTED_BEZ_DUBLJA', 'sostojanie')]
    return []


def sud_interrupted_ne_completed(screen, opis):
    b = blok(screen, SOSTOJANIJA['F05.V02'][0])
    if b is None:
        return [('POVEDENIE_INTERRUPTED_NE_ZAVERSHEN', 'blok')]
    if 'completeMission' in b or "response === 'completed'" in b:
        return [('POVEDENIE_INTERRUPTED_KAK_COMPLETED', 'completeMission')]
    return []


def sud_revoked_skryt(screen, opis):
    return []


def sud_render_bloki(screen, opis):
    otkazy = []
    kadr_vhodi = {k['id']: k for k in opis.get('kadry_bez_png', [])}
    for kadr, (uslovie, testid, tokeny) in SOSTOJANIJA.items():
        opis_k = kadr_vhodi.get(kadr, {})
        if opis_k.get('testid') != testid:
            otkazy.append(('RENDER_MANIFEST_TESTID_CHUZHOJ', kadr))
        b = blok(screen, uslovie)
        if b is None:
            otkazy.append(('RENDER_BLOK_OTSUTSTVUET', kadr))
            continue
        if ('testID="%s"' % testid) not in b:
            otkazy.append(('RENDER_TESTID_NE_V_BLOKE', testid))
        ssylki = set(re.findall(r"copy\['([a-zA-Z0-9_.]+)'\]\.text", b))
        if not ssylki:
            otkazy.append(('RENDER_PUSTOJ_KONTAINER', kadr))
        else:
            for kljuch in opis_k.get('kljuchi_kopii', []):
                if kljuch not in ssylki:
                    otkazy.append(('RENDER_KLJUCH_BEZ_RENDERA',
                                   '%s %s' % (kadr, kljuch)))
        klass = klassy(b)
        if not klass:
            otkazy.append(('RENDER_BEZ_TOKENOV', kadr))
        else:
            for t in opis_k.get('tokeny', []):
                if t.lstrip('-') not in klass:
                    otkazy.append(('RENDER_TOKEN_NE_V_KLASSE',
                                   '%s %s' % (kadr, t)))
    return otkazy


def sud_render_stroki(screen, opis):
    otkazy = []
    kadr_vhodi = {k['id']: k for k in opis.get('kadry_bez_png', [])}
    for kadr, (uslovie, _t, _k) in SOSTOJANIJA.items():
        b = blok(screen, uslovie)
        if b is None:
            continue
        razresheno = {KATALOG[k] for k in kadr_vhodi.get(kadr, {})
                      .get('kljuchi_kopii', []) if k in KATALOG}
        for lit in strokovye_litery(b):
            if lit not in razresheno and lit != CHIP['suffiks']:
                otkazy.append(('RENDER_STROKA_VNE_KATALOGA',
                               '%s %r' % (kadr, lit)))
    return otkazy


def sud_render_tokeny(screen, opis):
    otkazy = []
    for kadr, (uslovie, _t, _k) in SOSTOJANIJA.items():
        b = blok(screen, uslovie)
        if b is None:
            continue
        chuzhie = klassy(b) - AUDIT_TOKENOV
        if chuzhie:
            otkazy.append(('RENDER_TOKEN_VNE_AUDITA',
                           '%s %s' % (kadr, ' '.join(sorted(chuzhie)))))
    return otkazy


def sud_render_chip(screen, opis):
    b = blok(screen, CHIP['uslovie'])
    if b is None:
        return [('RENDER_CHIP_BLOK_OTSUTSTVUET', CHIP['testid'])]
    otkazy = []
    if ('testID="%s"' % CHIP['testid']) not in b:
        otkazy.append(('RENDER_TESTID_NE_V_BLOKE', CHIP['testid']))
    if "CHIP_LESET_SUFFIX" not in b:
        otkazy.append(('RENDER_CHIP_BEZ_SUFFIKSA', CHIP['testid']))
    if ("'%s'" % CHIP['suffiks']) not in screen:
        otkazy.append(('RENDER_CHIP_SUFFIKS_CHUZHOJ', CHIP['suffiks']))
    return otkazy


def sud_render_literaly(screen, opis):
    if re.search(r"'#[0-9a-fA-F]{3,8}'", screen):
        return [('RENDER_LITERAL_VNE_AUDITA', 'hex')]
    return []


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--pack', required=True)
    ap.add_argument('--repo', required=True)
    ap.add_argument('--harness', default=None)
    a = ap.parse_args()
    put = Path(a.repo) / SCREEN
    if not put.is_file():
        print('PRICHINA\tPOVEDENIE_EKRAN_OTSUTSTVUET\t%s' % SCREEN,
              file=sys.stderr)
        return 1
    screen = put.read_text(encoding='utf-8')
    opis = json.loads((Path(a.pack) / 'sostojanija_bez_png.json')
                      .read_text(encoding='utf-8'))
    proverki = (
        sud_draft_v_kompozere, sud_draft_v_hranilishche, sud_draft_snimaetsja,
        sud_draft_terjaetsja, sud_intent_otdelnyj,
        sud_already_accepted_bez_dublja, sud_interrupted_ne_completed,
        sud_revoked_skryt, sud_render_bloki, sud_render_stroki,
        sud_render_tokeny, sud_render_chip, sud_render_literaly,
    )
    otkazy = []
    for p in proverki:
        otkazy += p(screen, opis)
    for imja, detal in otkazy:
        prichina(imja, detal)
    return 1 if otkazy else 0


if __name__ == '__main__':
    sys.exit(main())
