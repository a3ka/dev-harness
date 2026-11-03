#!/usr/bin/env python3
# Батарея контракта 159 «пустой продукт красный» (guard-канал §ПРОВОДКА).
# СУБЪЕКТЫ: (1) экранные батареи харнесса в режиме --repo — на каждом
# входе домена «пустой продукт» (четыре формы слова владельца
# 2026-11-03: (а) форма пачки {}, (б1) пустой каталог, (б2) отсутствующий
# каталог, (в) карта без целей ekrany:[], (г) один лишь корневой
# компонент без содержимого) КАЖДАЯ обязана быть КРАСНОЙ: rc ≠ 0 с
# ИМЕНОВАННОЙ причиной; (2) живой гейт scripts/check_pustoj_produkt.sh
# (зона implementer; до ленда — клетки SUBJECT_ABSENT) — существует и
# на каждом входе домена равен эталону rc-кодом и причиной ПОБАЙТОВО;
# эталон — model/check_pustoj_produkt_159.py, грамматика пустоты —
# ЕДИНЫЙ источник (инвариант 1 контракта), ожидания вычислены в ПАМЯТИ
# проверяющего ДО запуска субъектов (правило 8): карта вход→причина —
# константа OZHIDAEMYE ниже, с диска субъекта не перечитывается.
#
# Режимы (argv):
#   (без флага)  судится живое дерево: клетки W-<батарея>/<вход> по
#                каждой экранной батарее (закрытый перечень BATAREI,
#                найден grep-ом --repo по экранным семьям, состав
#                зафиксирован контрактом 159 §Существующее), клетки
#                s-gate-* по живому гейту; до ленда реализации красны
#                поимённо (SUBJECT_ABSENT / BATAREJA_ZELENA_NA_PUSTOM)
#   --model      субъект = эталон гейта (контроль входов и эталона):
#                каждый вход домена → ровно его причина, конформный
#                продукт → rc 0
#   --stabs      контроль + три обманных варианта (stabs/); перечень
#                входов каждого — source.json stab_vhod, привязка к
#                ветвям обнаружения — КОДОМ ниже (Н-39), не прозой
#                контракта; SVJAZI == число вариантов
#   --piny-only  (служебный) только проверка пинов носителей
#
# Коды возврата: 0 — зелено; 1 — красная клетка/живой вариант/нет
# субъекта/недостоверный вариант; 2 — ORACLE_TAMPERED, нечем проверять.
import hashlib
import json
import os
import shutil
import subprocess
import sys
import tempfile
ZDE = os.path.dirname(os.path.abspath(__file__))
KOREN = os.path.abspath(os.path.join(ZDE, '..', '..', '..'))
MODEL = os.path.join(ZDE, 'model')
STABY = os.path.join(ZDE, 'stabs')
ETALON = os.path.join(MODEL, 'check_pustoj_produkt_159.py')
ZHIVOJ_GATE = os.path.join(KOREN, 'scripts', 'check_pustoj_produkt.sh')


# Закрытый перечень экранных батарей с режимом W --repo (159
# §Существующее): перечислены по grep -l "'--repo'" probe.py экранных
# семей, отбор — ФАКТИЧЕСКИЙ приём флага CLI, измерен на текущем
# дереве (замер Arch159 2026-11-03): 147/148/149/151 принимают;
# ekran_shablon_132, erstinformation_118, first_run_ekran_135,
# mission_116, shablon_dvizhenie_146, start_ekran_138 — упоминание
# --repo только во внутренних argv валидатора/комментариях, их W
# --repo даёт argparse-отказ rc 2 «unrecognized arguments» — вне
# домена W --repo (их предмет — пачки, не живой продукт). Новая
# экранная батарея с --repo без гейта — отдельный предмет.
BATAREI = [
    ('gespraech_otdacha_151', 'red_gespraech_otdacha_151.sh'),
    ('gespraech_tekst_149', 'red_gespraech_tekst_149.sh'),
    ('gespraech_vhod_147', 'red_gespraech_vhod_147.sh'),
    ('vkladki_tabov_148', 'red_vkladki_tabov_148.sh'),
]

KARTA_S_ZAPISJU = {
    "schema": 1,
    "ekrany": [{
        "id": "demo-vkhod", "kontrakty": ["159"], "status": "in-development",
        "job": "e2e-demo-vkhod", "pack": "mobile/e2e-demo-vkhod/",
        "flows": [], "child_flows": [], "puti": ["mobile/e2e-demo-vkhod/"],
        "h_checkout": [], "output_namespace": "ekran-demo-vkhod",
    }],
}
FORMA = {"ekran": "demo-vkhod", "kadry": "kadry.json"}

# Оракул в памяти (правило 8): вход → (rc эталона, причина ДОСЛОВНО).
OZHIDAEMYE = {
    'a-forma-pusta': (1, 'PUSTOJ_PRODUKT: FORMA_PUSTA'),
    'b1-pustoj-katalog': (1, 'PUSTOJ_PRODUKT: KATALOG_PUST'),
    'b2-otsutstvujushchij': (1, 'PUSTOJ_PRODUKT: KATALOG_OTSUTSTVUET'),
    'v-karta-bez-celej': (1, 'PUSTOJ_PRODUKT: KARTA_BEZ_CELEJ'),
    'g-koren-bez-soderzhimogo': (1, 'PUSTOJ_PRODUKT: KOREN_BEZ_SODERZHIMOGO'),
    'konformnyj': (0, ''),
}
PUSTYE = [v for v in OZHIDAEMYE if v != 'konformnyj']



def utechka(n):
    sys.stderr.write('ORACLE_TAMPERED %s\n' % n)
    sys.exit(2)


def sha(p):
    return hashlib.sha256(open(p, 'rb').read()).hexdigest()


def vedro():
    src = json.load(open(os.path.join(ZDE, 'source.json'),
                         encoding='utf-8'))
    for imja in sorted(src['piny']['nositeli']):
        p = os.path.join(ZDE, imja)
        if not os.path.isfile(p) or sha(p) != src['piny']['sha'][imja]:
            utechka(imja)
    if set(src['staby']) != set(src['stab_vhod']):
        utechka('staby против stab_vhod')
    return src


def postav_src(md, soderzhatelno):
    """Компонентный слой: корень App.tsx всегда; подпапка features —
    только у содержательного продукта (конформные входы домена несут
    ВСЕ измерения, кроме изолируемого)."""
    if soderzhatelno:
        os.makedirs(os.path.join(md, 'src', 'features', 'demo'))
    else:
        os.makedirs(os.path.join(md, 'src'))
    open(os.path.join(md, 'src', 'App.tsx'), 'w').write(
        "export default function App() { return null; }\n")
    if soderzhatelno:
        open(os.path.join(md, 'src', 'features', 'demo', 'Demo.tsx'),
             'w').write("export function Demo() { return null; }\n")


def postavit(baza, vid):
    """Материализует вход домена в <baza>/<vid>/R; путь продукта."""
    r = os.path.join(baza, 'R-' + vid)
    if vid == 'b2-otsutstvujushchij':
        return os.path.join(baza, 'NETU-' + vid)  # каталог не создаём
    os.makedirs(r)
    if vid == 'b1-pustoj-katalog':
        return r
    md = os.path.join(r, 'mobile')
    if vid == 'a-forma-pusta':
        os.makedirs(os.path.join(md, 'e2e-demo-vkhod'))
        json.dump(KARTA_S_ZAPISJU,
                  open(os.path.join(md, 'ci-screens.json'), 'w'))
        json.dump({}, open(os.path.join(md, 'e2e-demo-vkhod',
                                        'ekran.json'), 'w'))
        postav_src(md, soderzhatelno=True)
    elif vid == 'v-karta-bez-celej':
        os.makedirs(os.path.join(md, 'e2e-demo-vkhod'))
        json.dump({"schema": 1, "ekrany": []},
                  open(os.path.join(md, 'ci-screens.json'), 'w'))
        json.dump(FORMA, open(os.path.join(md, 'e2e-demo-vkhod',
                                           'ekran.json'), 'w'))
        postav_src(md, soderzhatelno=True)
    elif vid in ('g-koren-bez-soderzhimogo', 'konformnyj'):
        os.makedirs(os.path.join(md, 'e2e-demo-vkhod'))
        json.dump(KARTA_S_ZAPISJU,
                  open(os.path.join(md, 'ci-screens.json'), 'w'))
        json.dump(FORMA, open(os.path.join(md, 'e2e-demo-vkhod',
                                           'ekran.json'), 'w'))
        postav_src(md, soderzhatelno=(vid == 'konformnyj'))
    else:
        raise ValueError('неизвестный вход %r' % vid)
    return r


def zapusk_subekta(skript, vid, baza):
    """(rc, stdout+stderr) — субъект на СВЕЖЕЙ копии входа."""
    r = postavit(baza, vid)
    p = subprocess.run([sys.executable, skript, r],
                       capture_output=True, text=True, timeout=60)
    return p.returncode, p.stdout + p.stderr


def zapusk_batarei(zona, red, vid, baza):
    """(rc, pervaja_stroka, hvost) — W --repo на СВЕЖЕЙ копии входа.
    Гейт обязан быть ПЕРВЫМ действием --repo-ветви батареи: первая
    строка вывода — именованная причина гейта дословно."""
    r = postavit(baza, vid)
    cmd = ['bash', os.path.join(KOREN, 'fixtures', 'workshop_project',
                                zona, red), '--repo', r]
    try:
        p = subprocess.run(cmd, capture_output=True, text=True,
                           timeout=60, cwd=KOREN)
        rc, vyp = p.returncode, p.stdout + p.stderr
    except subprocess.TimeoutExpired:
        return 'VREMJA_ISTEKLO', '', ''
    stroki = vyp.strip().splitlines()
    pervaja = stroki[0] if stroki else ''
    hvost = stroki[-1][:100] if stroki else ''
    return rc, pervaja, hvost


def kontrol_modeli(baza):
    """Контроль входов и эталона: клетки ПО ВСЕМ входам домена."""
    kletki = []
    for vid in sorted(OZHIDAEMYE):
        try:
            rc, vyp = zapusk_subekta(ETALON, vid, baza)
        except subprocess.TimeoutExpired:
            kletki.append(('m-' + vid, False,
                           'эталон завис на входе %s' % vid))
            continue
        ozh_rc, ozh_prichina = OZHIDAEMYE[vid]
        stroka = (vyp.strip().splitlines() or [''])[0]
        ok = rc == ozh_rc and stroka == ozh_prichina
        kletki.append(('m-' + vid, ok,
                       '' if ok else
                       'rc=%d строка=%r, ожидалось rc=%d %r'
                       % (rc, stroka, ozh_rc, ozh_prichina)))
    return kletki


def pechat_i_itog(itogi, rezhim, svjazi=None, skolko_stabov=None):
    zelen = sum(1 for _, ok, _ in itogi if ok)
    krasn = len(itogi) - zelen
    for idk, ok, pochemu in itogi:
        print('CASE %s %s %s' % (idk, 'ok' if ok else 'KRASNO', pochemu))
    print('клеток %d, зелёных %d, красных %d; режим %s'
          % (len(itogi), zelen, krasn, rezhim))
    if krasn:
        return 1
    if svjazi is not None and svjazi != skolko_stabov:
        return 1
    return 0


def main():
    argv = sys.argv[1:]
    rezhim = ('stabs' if '--stabs' in argv else
              'model' if '--model' in argv else
              'piny' if '--piny-only' in argv else 'derevo')
    for dop in ('--repo', '--seed'):
        if dop in argv:
            sys.stderr.write('нет режима %s у этой батареи\n' % dop)
            return 2
    src = vedro()
    if rezhim == 'piny':
        print('PINY ok')
        return 0
    if not os.path.isfile(ETALON):
        sys.stderr.write('NOT_IMPLEMENTED: нет python3-эталона\n')
        return 2

    itogi = []
    if rezhim in ('model', 'stabs'):
        baza = tempfile.mkdtemp(prefix='pustoj159-model-')
        try:
            itogi.extend(kontrol_modeli(baza))
        finally:
            shutil.rmtree(baza, ignore_errors=True)

    if rezhim == 'stabs':
        # Ожидания эталона — УЖЕ в памяти (OZHIDAEMYE), вычислены до
        # субъектов; диск вариантов истиной не перечитывается.
        svjazi = 0
        for stab, svaz in sorted(src['stab_vhod'].items()):
            put = os.path.join(ZDE, src['staby'][stab])
            baza = tempfile.mkdtemp(prefix='pustoj159-stab-')
            poymal = 0
            try:
                # валидность контрпримера (демаркация): на конформном
                # входе вариант ведёт себя как честный состав (rc 0)
                rc_k, vyp_k = zapusk_subekta(put, 'konformnyj', baza)
                if rc_k != 0:
                    itogi.append(('v-' + stab, False,
                                  'ЛОЖНЫЙ ОТКАЗ на конформном: rc=%d %s'
                                  % (rc_k, vyp_k.strip()[:80])))
                else:
                    for vid in svaz['vhody']:
                        if vid not in OZHIDAEMYE:
                            utechka('stab_vhod %s вход %s' % (stab, vid))
                        rc, vyp = zapusk_subekta(put, vid, baza)
                        ozh_rc, _ = OZHIDAEMYE[vid]
                        # ветвь обнаружения: честный красен, вариант зелён
                        if ozh_rc == 1 and rc == 0:
                            if svaz.get('forma') == 'trace-ignored' \
                                    and 'ignored' not in vyp:
                                itogi.append(('v-' + stab, False,
                                              'нет трассы вызова гейта '
                                              'на %s' % vid))
                                continue
                            poymal += 1
                            print('STAB %s KRASEN %s' % (stab, vid))
                    uze_krasen = any(idk == 'v-' + stab and not ok
                                     for idk, ok, _ in itogi)
                    if poymal == 0 and not uze_krasen:
                        itogi.append(('v-' + stab, False,
                                      'недостоверный вариант: ни одного '
                                      'расхождения на заявленных входах'))
                    elif poymal:
                        svjazi += 1
            finally:
                shutil.rmtree(baza, ignore_errors=True)
        print('SVJAZI %d' % svjazi)
        return pechat_i_itog(itogi, rezhim,
                             svjazi=svjazi,
                             skolko_stabov=len(src['stab_vhod']))

    if rezhim == 'derevo':
        # (1) живой гейт: существует и равен эталону на всём домене
        if not os.path.isfile(ZHIVOJ_GATE):
            itogi.append(('s-gate-v-dereve', False,
                          'SUBJECT_ABSENT scripts/check_pustoj_produkt.sh'))
            itogi.append(('s-gate-raven-etalonu', False,
                          'SUBJECT_ABSENT гейт не судится'))
        else:
            itogi.append(('s-gate-v-dereve', True, ''))
            baza = tempfile.mkdtemp(prefix='pustoj159-gate-')
            try:
                for vid in sorted(OZHIDAEMYE):
                    r = postavit(baza, vid)
                    p = subprocess.run(['bash', ZHIVOJ_GATE, r],
                                       capture_output=True, text=True,
                                       timeout=60)
                    ozh_rc, ozh_prichina = OZHIDAEMYE[vid]
                    stroka = ((p.stdout.strip().splitlines()
                               or [''])[0])
                    ok = (p.returncode == ozh_rc
                          and stroka == ozh_prichina)
                    itogi.append(('s-gate-raven-etalonu/' + vid, ok,
                                  '' if ok else
                                  'rc=%d строка=%r, эталон rc=%d %r'
                                  % (p.returncode, stroka, ozh_rc,
                                     ozh_prichina)))
            finally:
                shutil.rmtree(baza, ignore_errors=True)
        # (2) батареи: на каждом пустом входе первая строка вывода —
        # причина ГЕЙТА (гейт — первое действие --repo-ветви), rc != 0
        for zona, red in BATAREI:
            for vid in PUSTYE:
                baza = tempfile.mkdtemp(prefix='pustoj159-W-')
                try:
                    rc, pervaja, hvost = zapusk_batarei(zona, red, vid,
                                                        baza)
                finally:
                    shutil.rmtree(baza, ignore_errors=True)
                idk = 'W-%s/%s' % (zona, vid)
                ozh_rc, ozh_prichina = OZHIDAEMYE[vid]
                if rc == 0:
                    itogi.append((idk, False,
                                  'BATAREJA_ZELENA_NA_PUSTOM %s' % hvost))
                elif rc == 'VREMJA_ISTEKLO':
                    itogi.append((idk, False, 'VREMJA_ISTEKLO'))
                elif pervaja != ozh_prichina:
                    itogi.append((idk, False,
                                  'GATE_NE_VYZVAN_PERVYM первая=%r'
                                  % pervaja))
                else:
                    itogi.append((idk, True, ozh_prichina))

    return pechat_i_itog(itogi, rezhim)


if __name__ == '__main__':
    sys.exit(main())
