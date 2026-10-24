# Стаб (Н-39): копия честной статической пробы 116, отключена ровно одна
# ветвь (sud_ci_shag: continue-on-error строки блока); на своём входе stab_vhod пропускает дефект,
# на остальных ведёт себя честно.
#!/usr/bin/env python3
# Статическая проба 116 (третий субъект батареи) — страж ФОРМЫ по
# арбитражу 0259fb00 (е): закрытые множества (членство testID/токенов,
# литералы каталога, запрет hex, draftStore/value-порты как РАННИЙ СИГНАЛ
# — не суд поведения). Поведение и фактический рендер судит ИСПОЛНЯЕМАЯ
# семья продукта (Jest/RNTL, product-CI, клетки K1-K19), её проводку
# держат ТРИ закрытые проверки ЗДЕСЬ: байт-пин текста пробы (б) и ПИН
# БЛОКА ШАГА mobile.yml (в; арбитраж 4cadfc54 а: класс echo-подмен
# перечнем командных позиций НЕ замыкается — разбор shell УБРАТ, страж
# формы = замкнутое множество, байт-равенство блока шага пину ГДЕ БЫ
# ОН НИ ВСТРЕТИЛСЯ в workflow; r9, 675465e2: принадлежность
# required-job из статики УДАЛЕНА — ложный YAML-membership). Факт
# запуска, гейта и принадлежности required-job семью статикой НЕ
# судится: их судит runtime-строка критерия product-CI с ДОКАЗАННОЙ
# СВЯЗЬЮ (gh pr checks --required ∧ check-run required job android-e2e
# → шаг conclusion success ∧ лог Tests: 19 passed, 19 total — :38).
# Ожидания — закрытые литералы ЗДЕСЬ (оракул в памяти проверяющего,
# правило 8). rc 1 — PRICHINA по имени ветви; rc 0 — тихо.
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

# Пин исполняемой пробы (0259fb00 б): текст семьи K1-K19 в продукте
# байт-идентичен артефакту батареи teksty/povedenie.test.stand-in.tsx
# (sha256 ниже; носитель — source.json.povedenie_proba).
PROBA_PUT = 'mobile/src/features/conversation/__tests__/mission-116.test.tsx'
PROBA_SHA256 = 'dab2efebea58f15c92a76989436d4a23d97fc72d9238f9c7efa816606438dac9'

# Проводка product-CI (0259fb00 в; арбитраж 4cadfc54 а): страж ФОРМЫ —
# ПИН БЛОКА ШАГА, замкнутое множество. В mobile.yml ровно один блок
# шага, начинающийся строкой пина; блок (до первой строки с отступом
# <= отступа '-', пустые строки и YAML-комментарии отброшены, строки
# по .strip()) побайтово равен двум строкам пина (носитель —
# source.json.mobile_ci_tekst), других ключей в блоке нет. Блок ищется
# ГДЕ БЫ ОН НИ ВСТРЕТИЛСЯ в workflow: родитель-job, required-статус и
# формы ключа job (кавычки, YAML-комментарий, отступ, indentless
# steps) статикой НЕ судятся (r9, 675465e2 — YAML-membership удалён:
# конечное множество распознанных имён не замыкает произвольный YAML).
# Любая форма run кроме пина (echo-подмена, ||, if:, continue-on-error,
# cd &&, многострочный честный) красна — fail-closed принят арбитражем.
CI_PUT = '.github/workflows/mobile.yml'
CI_PIN = [
    '- name: 116 mission behaviour render',
    'run: npx jest src/features/conversation/__tests__/mission-116.test.tsx',
]


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
    if 'revoked !== true' not in screen \
            or 'sourcesVisible.map' not in screen:
        return [('POVEDENIE_REVOKED_ISTOCHNIK_POKAZAN', 'filter')]
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


def sud_proba_povedenija(repo, _opis):
    """Байт-пин текста пробы (замкнутое множество — полна по построению)."""
    put = repo / PROBA_PUT
    if not put.is_file():
        return [('PROBA_POVEDENIJA_OTSUTSTVUET', PROBA_PUT)]
    import hashlib
    fakt = hashlib.sha256(put.read_bytes()).hexdigest()
    if fakt != PROBA_SHA256:
        return [('PROBA_POVEDENIJA_PODMENENA', fakt)]
    return []


def sud_ci_shag(repo, _opis):
    """Страж формы шага mobile.yml = ПИН БЛОКА ШАГА (арбитраж 4cadfc54
    а: замкнутое множество). Блок шага байт-равен двум строкам пина
    ГДЕ БЫ ОН НИ ВСТРЕТИЛСЯ в workflow; разбор shell (командные
    позиции, echo, комментарии) и YAML-membership (родитель-job,
    required-статус, формы ключа job) УБРАНЫ (r9, 675465e2: класс
    перечнем не замыкается, любая форма run кроме пина красна
    fail-closed). Принадлежность required-job и факт запуска судит
    runtime-строка критерия product-CI, не статика."""
    put = repo / CI_PUT
    if not put.is_file():
        return [('CI_BEZ_SHAGA_POVEDENIJA', CI_PUT)]
    linii = put.read_text(encoding='utf-8').splitlines()
    nacheta = [i for i, l in enumerate(linii) if l.strip() == CI_PIN[0]]
    if not nacheta:
        return [('CI_BEZ_SHAGA_POVEDENIJA', 'shag')]
    if len(nacheta) > 1:
        return [('CI_SHAG_POVEDENIJA_NE_PO_PINU',
                 'blokov shaga %d' % len(nacheta))]
    i = nacheta[0]
    otstup = len(linii[i]) - len(linii[i].lstrip())
    blok = [linii[i].strip()]
    for l in linii[i + 1:]:
        if l.strip() == '' or l.lstrip().startswith('#'):
            continue
        if len(l) - len(l.lstrip()) <= otstup:
            break
        blok.append(l.strip())
    # СТАБ: строки continue-on-error игнорируются перед сравнением с пином.
    blok = [b for b in blok
             if not b.startswith("continue-on-error:")]
    if blok != CI_PIN:
        # детализация (4cadfc54 а): найденный негейтящий ключ называется,
        # но вердикт rc определяет равенство пину, не перечень
        for kljuch in ('continue-on-error', 'if'):
            if any(b.startswith(kljuch + ':') for b in blok):
                return [('CI_SHAG_POVEDENIJA_NE_PO_PINU', kljuch)]
        return [('CI_SHAG_POVEDENIJA_NE_PO_PINU', 'blok shaga')]
    # блок байт-равен пину (r9, 675465e2): membership required-job
    # статикой НЕ судится — его судит runtime-строка критерия (:38).
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
    otkazy += sud_proba_povedenija(Path(a.repo), opis)
    otkazy += sud_ci_shag(Path(a.repo), opis)
    for imja, detal in otkazy:
        prichina(imja, detal)
    return 1 if otkazy else 0


if __name__ == '__main__':
    sys.exit(main())
