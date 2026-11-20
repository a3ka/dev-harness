#!/usr/bin/env python3
"""Батарея 193 «Л2 — сдаточный лист architect и карта классов вердикта».

Семья sdacha_193. Субъекты: scripts/check_sdacha.sh (дверь листа),
scripts/check_verdict_karta.sh (дверь карты вердикта), нога (к) в
scripts/pre_critic.sh (вставлена патчем к реальной двери — якорь
«printf 'КРИТИК: дверь зелёная»; пост-реализация опознаётся по метке ноги
и не дублируется) и нога карты в scripts/freeze_contract.sh (якорь
«# ── 6а. SPEC-PREFLIGHT»).

Режимы: --repo <корень> (умолчание — живое дерево) и голый: субъекты —
ТОЛЬКО реальные файлы выбранного дерева, ноги pre_critic/freeze НЕ
достраиваются патчем (К-11 Crit193V1: до реализации реальные ноги
отсутствуют и клетки ног честно красны); --model (честная модель из
model/scripts; ноги — патч к реальным дверям живого дерева, пост-реализация
опознаётся меткой); --stabs (обманные реализации из stabs/ и адресные
мутации операций PATERN:* по привязкам stabs.tsv; мутации дверей/lib —
якорная замена честной операции с проверкой применённости в РЕАЛЬНОМ файле
живого дерева, в окне до реализации — в файле модели; мутации ног — к
реальной ноге, в окне — к ноге модели; Н-39: привязки данными батареи,
не прозой контракта).

Проектная ось 193↔996 (С-10/С-6): клетка v13–v23/f05–f07 судит грамматику
пути вердикта против ЭФФЕКТИВНОГО workflowPaths.verdicts (единый
project_paths_resolve из next_id.sh живого дерева, доставляемого в мир
вместе с profile_resolver.sh и настоящим harness.project.json): профильный
путь честной карты зелёный, корневая приманка/чужая роль/битый профиль/
побег за ROOT красны; интеграционные ноги freeze — по профильным
contracts/verdicts.

Оракул — в памяти пробы: ожидания сняты до вызова субъекта (К-11); таймаут
убивает ГРУППУ процессов субъекта (рекурсивная обманка не переживает прогон).
"""
import argparse
import json
import os
import shutil
import signal
import subprocess
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
DEREVO = HERE.parents[2]            # живое дерево: гейты, pre_critic, freeze
MIR = HERE / 'mir'
MIRSKRIPTY = HERE / 'mirskripty'
MODEL = HERE / 'model'
STABS = HERE / 'stabs'

TOY_GEJTY = ('check_precision_gate.sh', 'check_spec_ready.sh', 'verify_ci_parity.sh')
LIBS = ('lib_incr.sh', 'lib_plan.sh', 'lib_registry.sh', 'lib_roles.sh',
        'lib_session.sh', 'lib_zones.sh')
FORMA_GEJTY = ('check_threat_model.sh', 'check_ceilings.sh', 'check_provodka.sh')
FREEZE_LIBS = ('next_id.sh', 'lib_registry.sh')

PACKAGE_JSON = ('{"name":"toy","version":"1.0.0","scripts":'
                '{"check:precision-gate":"bash scripts/check_precision_gate.sh",'
                '"check:spec-ready":"bash scripts/check_spec_ready.sh"}}\n')
CI_YML = ('name: toy-ci\non: [push]\njobs:\n  toy:\n    runs-on: ubuntu-latest\n'
          '    steps:\n'
          '      - run: npm run check:precision-gate -- . contracts/777-toy.md\n'
          '      - run: npm run check:spec-ready -- . contracts/777-toy.md\n')

VNESHNIJ_SKRIPT = ('#!/usr/bin/env bash\n'
                   '# скрипт вне корня мира (Rev193 С-1 M04): существует и честно даёт rc 0\n'
                   'exit 0\n')

KONTRAKT = 'contracts/777-toy.md'
VERDIKT = 'verdicts/critic/contracts-777-v1.md'

# ── проектная ось 193↔996 (С-10/С-6, ConsKarta1118 §3б): профильная
# раскладка workflowPaths — как у реального проекта режима 996. Резолвер
# настоящий (scripts/next_id.sh + scripts/profile_resolver.sh живого дерева
# доставляются в миры как sibling-зависимости двери), данные профиля —
# настоящие harness.project.json + project-layer.json в корне мира.
PROFIL_STANDART = {'contracts': '.harness/tasks', 'verdicts': '.harness/verdicts',
                   'registry': '.harness/ledger', 'fixtures': '.harness/probes'}
PROFIL_DRUGOJ = dict(PROFIL_STANDART, verdicts='workflow/judgements')
PROFIL_VERDIKT = '.harness/verdicts/critic/contracts-777-v1.md'
PROFIL_KONTRAKT = '.harness/tasks/777-toy.md'

# ── ноги, вставляемые патчем в реальные двери (модель = реальное + нога) ──────
NOGA_PRE_CRITIC = '''# ── (к) СДАТОЧНЫЙ ЛИСТ (контракт 193, Л2) ────────────────────────────────────
# Дверь листа вооружается от BASE (канон ног ж/з/и): скрипта в BASE нет —
# нога пропускается молча. SDACHA_OKRUG=1 — маркер внутреннего прогона двери
# листа: нога по нему пропускается (разрыв рекурсии лист↔дверь, И6).
if [ "${SDACHA_OKRUG:-0}" != "1" ] && [ -x "$BASE/scripts/check_sdacha.sh" ]; then
  noga_formy "сдаточный лист красен" "scripts/check_sdacha.sh" "$BASE" "$CONTRACT" --run
fi

'''

NOGA_PRE_CRITIC_IZ_ROOTA = '''# ── (к) СДАТОЧНЫЙ ЛИСТ — мутация PATERN:IZ-ROOTA (батарея 193) ──────────────
# Дверь вооружается из ROOT (дерева двери), а не из BASE (судимого дерева):
# прочтение, ломающее канон 191 — чужому --repo-миру навязывается дверь
# дерева двери. Различающий вход — клетка p02.
if [ "${SDACHA_OKRUG:-0}" != "1" ] && [ -x "$ROOT/scripts/check_sdacha.sh" ]; then
  _r193=0
  _o193="$(bash "$ROOT/scripts/check_sdacha.sh" "$BASE" "$CONTRACT" --run 2>&1)" || _r193=$?
  [ "$_r193" -eq 0 ] || refuse "сдаточный лист красен (rc=$_r193): $(printf '%s' "$_o193" | head -n 1)"
fi

'''
NOGA_PRE_CRITIC_VSEGDA_OTKAZ = '''# ── (к) СДАТОЧНЫЙ ЛИСТ — мутация PATERN:VSEGDA-OTKAZ (батарея 193) ──────────
# Нога отказывает БЕЗ прогона двери: ложный отказ и на честном листе
# (блок критика Crit193V1 К-14). Различающий вход — клетка p03: прямой
# вызов с честным листом и зелёной вооружённой дверью обязан пройти.
if [ "${SDACHA_OKRUG:-0}" != "1" ] && [ -x "$BASE/scripts/check_sdacha.sh" ]; then
  refuse "сдаточный лист красен"
fi

'''
NOGA_PRE_CRITIC_RC2_MASKIRUET = '''# ── (к) СДАТОЧНЫЙ ЛИСТ — мутация PATERN:PRE-RC2-MASKIRUET (батарея 193, Rev193 С-1 M14)
# Нога отказывает только на rc 1 двери: «нечем проверять» (rc 2) молча
# считается зелёным — fail-open на NOT_IMPLEMENTED. Различающий вход —
# клетка p04: нецелые швы двери дают rc 2, честная нога обязана отказать.
if [ "${SDACHA_OKRUG:-0}" != "1" ] && [ -x "$BASE/scripts/check_sdacha.sh" ]; then
  _r193=0; bash "$BASE/scripts/check_sdacha.sh" "$BASE" "$CONTRACT" --run >/dev/null 2>&1 || _r193=$?; [ "$_r193" -ne 1 ] || refuse "сдаточный лист красен (rc=$_r193)"
fi

'''
YAKOR_PRE_CRITIC = "printf 'КРИТИК: дверь зелёная"

NOGA_FREEZE = '''# ── 6. КАРТА КЛАССОВ ВЕРДИКТА (контракт 193, Л2) ───────────────────────────────
# Нога карты: ПОСЛЕ §6 (первая строка вердикта — accept/FAIL/ESCALATE) и ДО §6а
# (spec-preflight): вердикт уже прочитан, тега ещё нет (И8 контракта 193).
# Контракт, чей HEAD-блоб несёт строку «СДАЧА: », замораживается только при rc 0
# двери карты классов на accept-вердикте этой версии; отказ — именованный
# «карта классов вердикта … красна», тег не ставится (отказ атомарен — как §6а).
# Контракт без строки «СДАЧА: » картой не судится (старые предметы — прежний
# порядок). Двери карты в дереве нет — нога пропускается молча (окно
# freeze..implementer, канон 191).
# Условие — here-string, не конвейер: `printf | grep -q` под pipefail ловил
# SIGPIPE на контракте >64 КиБ и молча пропускал ногу (Б-1 Rev193, И8).
_k193_head="$(g cat-file -p "HEAD:$TARGET" 2>/dev/null || true)"
if grep -q '^СДАЧА: ' <<<"$_k193_head"; then
  if [ -x "$SELF_DIR/check_verdict_karta.sh" ]; then
    _k193_rc=0
    _k193_out="$(bash "$SELF_DIR/check_verdict_karta.sh" "$ROOT" "$verdict" 2>&1)" || _k193_rc=$?
    [ "$_k193_rc" -eq 0 ] || die "карта классов вердикта $verdict красна (rc=$_k193_rc): $(printf '%s' "$_k193_out" | head -n 1)"
  fi
fi

'''
NOGA_FREEZE_USPEH_KRASIT = '''# ── 6-карта — мутация PATERN:USPEH-KRASIT (батарея 193) ──────────────────────
# Инициализация результата заменена на 1: успех двери карты его не обнуляет,
# заморозка ложно отказывает и на зелёной карте (блок критика Crit193V1
# К-14). Различающий вход — клетка f03: карта зелёная, честная нога обязана
# пропустить заморозку дальше (отказ позже и по чужой причине).
_k193_head="$(g cat-file -p "HEAD:$TARGET" 2>/dev/null || true)"
if grep -q '^СДАЧА: ' <<<"$_k193_head"; then
  if [ -x "$SELF_DIR/check_verdict_karta.sh" ]; then
    _k193_rc=1
    _k193_out="$(bash "$SELF_DIR/check_verdict_karta.sh" "$ROOT" "$verdict" 2>&1)" || _k193_rc=$?
    [ "$_k193_rc" -eq 0 ] || die "карта классов вердикта $verdict красна (rc=$_k193_rc): $(printf '%s' "$_k193_out" | head -n 1)"
  fi
fi

'''
NOGA_FREEZE_STARY_KONVEJER = '''# ── 6-карта — мутация PATERN:KONVEJER-FREEZE (батарея 193, Rev193 Б-1) ────────
# Возврат прежнего дефекта: условие — конвейер printf | grep -q под pipefail;
# на контракте >64 КиБ grep -q закрывает трубу на строке СДАЧА, конвейер ловит
# SIGPIPE 141 и нога молча пропускается (fail-open; И8). Ловец — f01.
if printf '%s\\n' "$(g cat-file -p "HEAD:$TARGET" 2>/dev/null)" | grep -q '^СДАЧА: '; then
  if [ -x "$SELF_DIR/check_verdict_karta.sh" ]; then
    _k193_rc=0
    _k193_out="$(bash "$SELF_DIR/check_verdict_karta.sh" "$ROOT" "$verdict" 2>&1)" || _k193_rc=$?
    [ "$_k193_rc" -eq 0 ] || die "карта классов вердикта $verdict красна (rc=$_k193_rc): $(printf '%s' "$_k193_out" | head -n 1)"
  fi
fi

'''
NOGA_FREEZE_RC2 = '''# ── 6-карта — мутация PATERN:FREEZE-RC2-PROPUSKAET (батарея 193, Rev193 С-1 M12)
# Отказ ноги только на rc 1: rc 2 двери карты (NOT_IMPLEMENTED — например, нет
# lib рядом с дверью) пропускается — fail-open на «нечем проверить».
# Различающий вход — клетка f04: мир без lib, честная нога обязана отказать.
_k193_head="$(g cat-file -p "HEAD:$TARGET" 2>/dev/null || true)"
if grep -q '^СДАЧА: ' <<<"$_k193_head"; then
  if [ -x "$SELF_DIR/check_verdict_karta.sh" ]; then
    _k193_rc=0
    _k193_out="$(bash "$SELF_DIR/check_verdict_karta.sh" "$ROOT" "$verdict" 2>&1)" || _k193_rc=$?
    [ "$_k193_rc" -eq 2 ] || [ "$_k193_rc" -eq 0 ] || die "карта классов вердикта $verdict красна (rc=$_k193_rc): $(printf '%s' "$_k193_out" | head -n 1)"
  fi
fi

'''
YAKOR_FREEZE = '# ── 6а. SPEC-PREFLIGHT'

# ── якоря РЕАЛЬНЫХ ног (пост-реализация): присутствие ноги опознаётся
# ФУНКЦИОНАЛЬНЫМ якорем — вооружением двери в реальном файле, а не меткой-
# комментарием (метки в ногах реализации ломают различение стабов: Impl193
# Развилка 1 — с метками --stabs терял 5 мутаций, без меток 2); якорь
# встречается либо 0 раз (окно до реализации), либо ровно 1 — больше
# означает сломанное дерево субъектов: ORACLE_TAMPERED rc 2, не «поймана».
# Ноги реализации перенесены с модели байт в байт — якоря общие с NOGA_* ──
USLOVIE_REAL_PRE = ('if [ "${SDACHA_OKRUG:-0}" != "1" ] && '
                    '[ -x "$BASE/scripts/check_sdacha.sh" ]; then')
VYZOV_REAL_PRE = ('noga_formy "сдаточный лист красен" '
                  '"scripts/check_sdacha.sh" "$BASE" "$CONTRACT" --run')
BLOK_REAL_PRE = USLOVIE_REAL_PRE + '\n  ' + VYZOV_REAL_PRE + '\nfi'
YAKOR_REAL_FREEZE = ('_k193_out="$(bash "$SELF_DIR/check_verdict_karta.sh" '
                     '"$ROOT" "$verdict" 2>&1)"')
USLOVIE_REAL_FREEZE = "if grep -q '^СДАЧА: ' <<<\"$_k193_head\"; then"

# ── адресные мутации операций (Arb193V1 решения 1–2: исполняемые изменения,
# фактически предъявленные критиками V1/V2, хранятся батареей как обманные
# стабы; якорь обязан встречаться в честном субъекте РОВНО один раз — нулевая
# замена поимкой не считается, ORACLE_TAMPERED rc 2) ─────────────────────────
MUTACII_DVERI = {
    # Crit193V1 latest-tag: сравнение выбора последней заморозки повреждено
    # (vmax остаётся 0 — не выбор минимума, а сохранение нуля). Ловец — s10.
    'PATERN:POSLED-ZAMOROZKA':
        ('(( 10#$k > vmax )) && vmax=$(( 10#$k ))',
         '(( 10#$k < vmax )) && vmax=$(( 10#$k ))'),
    # Crit193V1 head-verdict: предыдущий вердикт читается рабочим файлом
    # вместо HEAD-блоба. Ловец — s21.
    'PATERN:IZ-RABOCHEGO':
        ('telo="$(git -C "$ROOT" cat-file -p "HEAD:$PRED_VERDIKT" 2>/dev/null)"',
         'telo="$(cat "$ROOT/$PRED_VERDIKT" 2>/dev/null)"'),
    # Crit193V2 staged: предыдущий вердикт читается индексом (git show :).
    # Ловец — s24.
    'PATERN:IZ-INDEXA':
        ('cat-file -p "HEAD:$PRED_VERDIKT"', 'show ":$PRED_VERDIKT"'),
    # Crit193V1 delta-coverage: фильтр «блок» снят — покрытие не судится.
    # Ловец — s07.
    'PATERN:PROPUSK-BLOKOV':
        ('[ "$status" = \'блок\' ] || continue', 'continue'),
    # Crit193V1 recursion-marker: маркер рекурсии снят. Ловец — s19.
    'PATERN:BEZ-MARKERA': ('SDACHA_OKRUG=1 timeout', 'SDACHA_OKRUG=0 timeout'),
    # Crit193V1 / Arb193V1: команда не ограничена остатком бюджета листа.
    # Ловец — s22; прочие операции честной двери не изменяются.
    'PATERN:BEZ-OSTATKA-BJUDZHETA':
        ('(( ostalos < predel )) && predel="$ostalos"', ':'),
    # Rev193 Б-3: исполнение ряда возвращено к bash -c — хвост «|| true»
    # исполняется оболочкой и маскирует фактический rc команды. Ловец — s03.
    'PATERN:BASH-C-SPRYATAN':
        ('timeout -k "$KILL_SEK" "$predel" "${ARGV[@]}"',
         'timeout "$predel" bash -c "${KOMANDY[$i]}"'),
    # Rev193 Б-4: SIGKILL по -k снят — команда, переживающая TERM, держит
    # дверь дольше бюджета (не завершается). Ловец — s27 (таймаут клетки).
    'PATERN:BEZ-SIGKILL':
        ('timeout -k "$KILL_SEK" "$predel"', 'timeout "$predel"'),
    # Rev193 С-1 M01: дубль строки СДАЧА принимается дверью. Ловец — s28.
    'PATERN:DUBL-SDACHA':
        ('[ "$sdacha_strok" -le 1 ] || otkaz', 'true || otkaz'),
    # Rev193 С-1 M03: заявленные rc ряда «Двери» не сверяются. Ловец — s29.
    'PATERN:RC-RASHODJATSA':
        ('[ "$o1" = "$o2" ] || otkaz "строка $nom: заявленные rc расходятся ($o1',
         'true || otkaz "строка $nom: заявленные rc расходятся ($o1'),
    # Rev193 С-1 M04: команда bash с путём за корнем (../) допускается.
    # Ловец — s30.
    'PATERN:PUT-VNE-KORNJA':
        ('case "$second" in /*|*..*) return 1 ;; esac', ':'),
    # Rev193 С-1 M05: ряд «- » вне машинной секции пропускается. Ловец — s31.
    'PATERN:RJAD-VNE-SEKCII':
        ('*) otkaz "строка $n: ряд таблицы',
         '*) continue; otkaz "строка $n: ряд таблицы'),
    'PATERN:REF-BEZ-LAST-FAIL':
        ('poslednij="$(karta_poslednij_fail "$ROOT" "$PRED_VERDIKT" "$telo")" \\\n'
         '        || otkaz "последний FAIL: $poslednij"', 'poslednij=""'),
}
MUTACII_KARTY = {
    # Arb193V1 решение 1: источник карты — рабочий файл вместо HEAD-блоба,
    # прочие операции сохранены. Ловец — v07.
    'PATERN:KARTA-IZ-FAJLA':
        ('telo="$(git -C "$ROOT" cat-file -p "HEAD:$VERDICT" 2>/dev/null)"',
         'telo="$(cat "$ROOT/$VERDICT" 2>/dev/null)"'),
    # Arb193V1 решение 1: источник карты — индекс вместо HEAD-блоба.
    # Ловец — v09.
    'PATERN:KARTA-IZ-INDEXA':
        ('cat-file -p "HEAD:$VERDICT"', 'show ":$VERDICT"'),
    # Rev193 Б-2: поиск раздела возвращён к конвейеру printf | grep -q — на
    # вердикте >64 КиБ ложный отказ «без раздела» (SIGPIPE 141). Ловец — v01.
    'PATERN:KONVEJER-KARTA':
        ('grep -q \'^## Карта классов$\' <<<"$telo"',
         'printf \'%s\\n\' "$telo" | grep -q \'^## Карта классов$\''),
    # Rev193 С-1 M09: вердикт вне грамматики critic-каталога принимается.
    # Ловец — v12. Проектная ось: якорь ') : ;;' — единственная arm-ветка
    # грамматики пути, ровно одно вхождение в двери ДО ремонта и в модели
    # (якорь переживает ремонт: грамматика остаётся одним case-блоком).
    'PATERN:LJUBOJ-PREFIKS':
        (') : ;;', ') : ;;\n    *) : ;;'),
    # Проектная ось 193↔996: дверь принимает чужую роль review (профильный
    # префикс есть, critic-суффикса нет). Ловец — v16.
    'PATERN:CHUZHAJA-ROL-PRINIMAETSJA':
        (') : ;;', ') : ;;\n    .harness/verdicts/review/*) : ;;'),
    # Проектная ось 193↔996: корневой verdicts/critic остаётся запасным
    # источником при активном профильном каталоге. Ловец — v15.
    'PATERN:KOREN-ZAPASNOJ':
        (') : ;;', ') : ;;\n    verdicts/critic/*) : ;;'),
    # Проектная ось: гард ''|/*|*..* снят — путь с побегом за корень проходит
    # грамматику. Ловец — v23 (отказ теряет имя «вне грамматики»).
    'PATERN:BEZ-GRAMMATIKI-PUTA':
        ('\'\'|/*|*..*) otkaz "путь вердикта вне грамматики '
         '(относительный, внутри корня): $VERDICT" ;;',
         '*) : ;;'),
}
MUTACII_LIB = {
    # Crit193V1 map-duplicate: проверка дубля класса в lib отключена.
    # Ловец — v06 (отказ остаётся, но теряет имя «дубль»).
    'PATERN:LIB-BEZ-DUBLJA':
        ('if [ -n "${vidennye[$klass]:-}" ]; then', 'if false; then'),
    # Rev193 С-1 M10: строки вне секции карты судятся. Ловец — v01 (дубль
    # К-01 в хвосте фикстуры verdikt_chestnyj).
    'PATERN:VNE-SEKCII-SUDITSJA':
        ('[ "$v_sekcii" -eq 1 ] || continue', ':'),
    # Rev193 С-1 M11: секция карты не закрывается заголовком «## ».
    # Ловец — v01 (тот же дубль в хвосте).
    'PATERN:SEKCIJA-VECHNA':
        ("'## '*) v_sekcii=0 ;;", "'## '*) : ;;"),
    'PATERN:REF-VSEGDA-CHISTO':
        ('resolved="$(karta_klass "$klass" "$status" \'\')"',
         'resolved=чисто'),
    'PATERN:REF-BEZ-CIKLA':
        ('*"|$nom:$klass|"*)', 'NEVER_CYCLE)'),
    'PATERN:REF-BEZ-NALICHIJA':
        ('[ -n "${K193_TEKST[$nom]:-}" ] ||', 'true ||'),
    'PATERN:REF-BEZ-ODNOZNACHNOSTI':
        ('[ -n "${K193_BLOB[$nom]:-}" ] &&', 'false &&'),
    'PATERN:REF-OBJECT-KAK-REVIZIJA':
        ('telo="$(git -C "$root" cat-file -p "$blob")"',
         'telo="$(git -C "$root" cat-file -p "$blob")"; '
         'telo="$(git -C "$root" cat-file -p '
         '"${telo#*OBJECT=}:$f" 2>/dev/null)"'),
    'PATERN:REF-PEREPISAT-OBJECT':
        ('K193_TEKST[$nom]="$telo"',
         'K193_TEKST[$nom]="$telo"\n'
         '            telo="${telo/OBJECT=????????????????????????????????????????/'
         'OBJECT=$(git -C "$root" rev-parse HEAD)}"\n'
         '            printf \'%s\\n\' "$telo" > "$root/$f"'),
    'PATERN:REF-PREV-VSEGDA-CHISTO':
        ('status="$(karta_predydushchij "$1")"',
         'videl+=("$klass"$\'\\tчисто\'); continue; status=""'),
    'PATERN:REF-PREV-NE-VYCHITAET':
        ('nom="${nom%?}$((cifra - 1))$nuli"', 'nom="$K193_VYZOV"'),
    'PATERN:REF-PREV-BEZ-KONTEKSTA':
        ('[ "$K193_ROL" = critic ] && [ -n "$K193_VYZOV" ]', 'true'),
    'PATERN:REF-PREV-BEZ-PERVOGO':
        ('[ "$K193_VYZOV" != 1 ] ||', 'true ||'),
    'PATERN:REF-PREV-HVOST-LJUBOJ':
        (r'^без\ изменений\ с\ предыдущего\ вызова([.]|\ —\ .+)?$',
         r'^без\ изменений\ с\ предыдущего\ вызова'),
    # Crit193V7 К-09: раскрыт только запрошенный класс, полные карты
    # достигнутых источников не обходятся. Остальные операции честные.
    'PATERN:REF-TOLKO-ZAPROSHENNYJ-KLASS':
        ('ochered+=("$sledujushchie")', ':'),
}
MUTACII_NOGI_PRE = {
    # Crit193V1 pre-leg: условие ноги (к) отключено — нога не выполняется.
    # Ловец — p01.
    'PATERN:BEZ-PRE-NOGI': (USLOVIE_REAL_PRE, 'if false; then'),
}


MUTACII_REALNOJ_NOGI_PRE = {
    # Те же дефекты на РЕАЛЬНОЙ ноге (дерево после реализации): якорная
    # замена в копии реального файла, ровно одно вхождение — зеркально
    # мутациям ноги модели (тот же дефект, та же клетка).
    # условие ноги отключено — нога не выполняется. Ловец — p01.
    'PATERN:BEZ-PRE-NOGI': (USLOVIE_REAL_PRE, 'if false; then'),
    # нога вооружается из ROOT (дерева двери), а не BASE (судимого дерева):
    # чужому --repo-миру навязывается дверь дерева двери; якорь — блок
    # реальной ноги целиком. Ловец — p02.
    'PATERN:IZ-ROOTA': (BLOK_REAL_PRE,
                        'if [ "${SDACHA_OKRUG:-0}" != "1" ] && '
                        '[ -x "$ROOT/scripts/check_sdacha.sh" ]; then\n'
                        '  _r193=0\n'
                        '  _o193="$(bash "$ROOT/scripts/check_sdacha.sh" '
                        '"$BASE" "$CONTRACT" --run 2>&1)" || _r193=$?\n'
                        '  [ "$_r193" -eq 0 ] || refuse "сдаточный лист '
                        'красен (rc=$_r193): $(printf \'%s\' "$_o193" | '
                        'head -n 1)"\n'
                        'fi'),
    # нога отказывает БЕЗ прогона двери — ложный отказ и на честном листе
    # (блок критика Crit193V1 К-14). Ловец — p03.
    'PATERN:VSEGDA-OTKAZ': (VYZOV_REAL_PRE,
                            'refuse "сдаточный лист красен"'),
    # Rev193 С-1 M14: rc 2 двери листа маскируется ногой (отказ только на
    # rc 1, NOT_IMPLEMENTED считается зелёным). Ловец — p04.
    'PATERN:PRE-RC2-MASKIRUET': (VYZOV_REAL_PRE,
                                 '_r193=0; bash "$BASE/scripts/check_sdacha.sh" '
                                 '"$BASE" "$CONTRACT" --run >/dev/null 2>&1 || '
                                 '_r193=$?; [ "$_r193" -ne 1 ] || refuse '
                                 '"сдаточный лист красен (rc=$_r193)"'),
}


MUTACII_REALNOJ_NOGI_FREEZE = {
    # нога карты отключена целиком — условие всегда ложно. Ловец — f01.
    'PATERN:BEZ-NOGI': (USLOVIE_REAL_FREEZE, 'if false; then'),
    # успех двери карты не обнуляет rc — ложный отказ и на зелёной карте
    # (блок критика Crit193V1 К-14). Ловец — f03.
    'PATERN:USPEH-KRASIT': ('_k193_rc=0', '_k193_rc=1'),
    # Rev193 Б-1: условие возвращено к конвейеру printf | grep -q — на
    # контракте >64 КиБ нога молча пропускается (SIGPIPE 141). Ловец — f01.
    'PATERN:KONVEJER-FREEZE': (USLOVIE_REAL_FREEZE,
                               'if printf \'%s\\n\' "$_k193_head" '
                               "| grep -q '^СДАЧА: '; then"),
    # Rev193 С-1 M12: rc 2 двери карты пропускается ногой (fail-open на
    # «нечем проверять»). Ловец — f04.
    'PATERN:FREEZE-RC2-PROPUSKAET':
        ('[ "$_k193_rc" -eq 0 ] || die',
         '[ "$_k193_rc" -eq 2 ] || [ "$_k193_rc" -eq 0 ] || die'),
    # Проектная ось 193↔996: нога отрезает профильный префикс пути вердикта
    # перед вызовом двери карты («простое отрезание .harness/ в freeze — не
    # ремонт», ConsKarta1118 §3а: HEAD:verdicts/… адресует другой блоб).
    # Ловец — f06.
    'PATERN:PROFIL-PREFIKS-OTREZAN':
        (YAKOR_REAL_FREEZE,
         '_k193_out="$(bash "$SELF_DIR/check_verdict_karta.sh" '
         '"$ROOT" "${verdict##*/}" 2>&1)"'),
}


def primenit(t: str, tablica: dict, imja: str) -> str:
    """Честный текст + одна адресная мутация; якорь ровно один, иначе отказ."""
    if imja not in tablica:
        raise RuntimeError('NET_MUTACII: %s' % imja)
    jakor, zamena = tablica[imja]
    if t.count(jakor) != 1:
        raise RuntimeError('JAKOR_NE_UNIKALEN: %s' % imja)
    rezultat = t.replace(jakor, zamena, 1)
    if rezultat == t:
        raise RuntimeError('TEKST_NE_IZMENEN: %s' % imja)
    return rezultat


def tekst(imja: str) -> str:
    return (MIR / imja).read_text(encoding='utf-8')


def git(kuda: Path, *args: str) -> None:
    subprocess.run(['git', '-C', str(kuda), '-c', 'user.name=orchestrator',
                    '-c', 'user.email=orchestrator@dev-harness.local'] + list(args),
                   check=True, capture_output=True)


def patched(istok: Path, jakor: str, noga: str, metka: str) -> str:
    """Реальная дверь + нога; пост-реализация (метка ноги в файле) — как есть."""
    t = istok.read_text(encoding='utf-8')
    if metka in t:
        return t
    if t.count(jakor) != 1:
        raise RuntimeError('YAKOR_NE_UNIKALEN: %s в %s' % (jakor, istok))
    return t.replace(jakor, noga + jakor, 1)


class Istochniki:
    """Субъекты мира: двери — из koren (живое дерево или модель); замены
    обманок — файлы stabs/; адресные мутации операций (PATERN:*) — якорные
    замены честного файла с проверкой применённости (Arb193V1). Ноги
    pre_critic/freeze при dostroat_nogi (режимы --model/--stabs): реальная
    нога в живом дереве ЕСТЬ (функциональный якорь вооружения, ровно одно
    вхождение) — субъект: реальный файл, нога-мутации применяются к
    РЕАЛЬНОЙ ноге; реальной ноги нет (окно до реализации) — патч ноги
    модели к реальной двери (модель — эталон переноса). В режимах голый/
    --repo ноги — РЕАЛЬНЫЕ файлы выбранного дерева без достройки
    проверяемого (К-11 Crit193V1: нет реальной ноги — клетки ног красны)."""

    def __init__(self, koren: Path, dver_zamena=None, karta_zamena=None,
                 lib_zamena=None, dver_mutacija=None, karta_mutacija=None,
                 lib_mutacija=None, pre_mutacija=None, freeze_mutacija=None,
                 dostroat_nogi=False):
        self.koren = koren
        self.dver_zamena = dver_zamena
        self.karta_zamena = karta_zamena
        self.lib_zamena = lib_zamena
        self.dver_mutacija = dver_mutacija
        self.karta_mutacija = karta_mutacija
        self.lib_mutacija = lib_mutacija
        self.pre_mutacija = pre_mutacija
        self.freeze_mutacija = freeze_mutacija
        self.dostroat_nogi = dostroat_nogi
        self._kesh = {}

    def _skopirovat(self, imja: str, zamena):
        vrem = Path(tempfile.mkdtemp(prefix='subj193-'))
        cel = vrem / imja
        shutil.copy2(zamena if zamena is not None else self.koren / 'scripts' / imja, cel)
        return cel

    def _subjekt(self, kljuch, imja, zamena, mutacija, tablica):
        """Субъект мира: честный файл корня | обманка-файл stabs/ | честный
        файл + адресная мутация (применённость — якорем, режим сохраняется)."""
        if kljuch not in self._kesh:
            cel = None
            if mutacija is not None:
                # Н-39/Б-блоки Rev193: мутация применяется к РЕАЛЬНОМУ файлу
                # живого дерева, когда предмет в нём реализован (якорь честной
                # операции обязан быть в нём ровно один раз); в окне до
                # реализации (реального файла нет) — к файлу модели.
                istok = self.koren / 'scripts' / imja
                real = DEREVO / 'scripts' / imja
                if real.exists() and not (mutacija.startswith('PATERN:REF-')
                                          and tablica[mutacija][0] not in real.read_text(encoding='utf-8')):
                    istok = real
                vrem = Path(tempfile.mkdtemp(prefix='subj193-'))
                cel = vrem / imja
                shutil.copy2(istok, cel)
                cel.write_text(primenit(istok.read_text(encoding='utf-8'),
                                        tablica, mutacija), encoding='utf-8')
            elif zamena is not None:
                cel = self._skopirovat(imja, zamena)
            else:
                put = self.koren / 'scripts' / imja
                cel = put if put.exists() else None
            self._kesh[kljuch] = cel
        return self._kesh[kljuch]

    def dver(self):
        return self._subjekt('dver', 'check_sdacha.sh', self.dver_zamena,
                             self.dver_mutacija, MUTACII_DVERI)

    def karta(self):
        return self._subjekt('karta', 'check_verdict_karta.sh', self.karta_zamena,
                             self.karta_mutacija, MUTACII_KARTY)

    def lib(self):
        return self._subjekt('lib', 'lib_karta_sdachi.sh', self.lib_zamena,
                             self.lib_mutacija, MUTACII_LIB)

    def pre_critic(self):
        if 'pre' not in self._kesh:
            if self.dostroat_nogi:
                real = DEREVO / 'scripts' / 'pre_critic.sh'
                t_real = real.read_text(encoding='utf-8')
                n_nog = t_real.count(VYZOV_REAL_PRE)
                if n_nog > 1:
                    raise RuntimeError('YAKOR_NE_UNIKALEN: реальная нога (к) '
                                       'предъявлена %d раза' % n_nog)
                if n_nog == 1:
                    # пост-реализация: субъект — РЕАЛЬНАЯ нога; мутация —
                    # одна локальная замена в копии реального файла; honest —
                    # реальный файл как есть (второй ноги модели в мире нет)
                    t = t_real
                    if self.pre_mutacija is not None:
                        t = primenit(t_real, MUTACII_REALNOJ_NOGI_PRE,
                                     self.pre_mutacija)
                else:
                    # окно до реализации: патч ноги модели к реальной двери
                    noga = NOGA_PRE_CRITIC
                    if self.pre_mutacija == 'PATERN:IZ-ROOTA':
                        noga = NOGA_PRE_CRITIC_IZ_ROOTA
                    elif self.pre_mutacija == 'PATERN:VSEGDA-OTKAZ':
                        noga = NOGA_PRE_CRITIC_VSEGDA_OTKAZ
                    elif self.pre_mutacija == 'PATERN:BEZ-PRE-NOGI':
                        noga = primenit(noga, MUTACII_NOGI_PRE, self.pre_mutacija)
                    elif self.pre_mutacija == 'PATERN:PRE-RC2-MASKIRUET':
                        noga = NOGA_PRE_CRITIC_RC2_MASKIRUET
                    t = patched(real, YAKOR_PRE_CRITIC, noga, '(к) СДАТОЧНЫЙ ЛИСТ')
                vrem = Path(tempfile.mkdtemp(prefix='nog193-'))
                (vrem / 'pre_critic.sh').write_text(t, encoding='utf-8')
                self._kesh['pre'] = vrem / 'pre_critic.sh'
            else:
                put = self.koren / 'scripts' / 'pre_critic.sh'
                self._kesh['pre'] = put if put.exists() else None
        return self._kesh['pre']

    def freeze(self):
        if 'freeze' not in self._kesh:
            if self.dostroat_nogi:
                real = DEREVO / 'scripts' / 'freeze_contract.sh'
                t_real = real.read_text(encoding='utf-8')
                n_nog = t_real.count(YAKOR_REAL_FREEZE)
                if n_nog > 1:
                    raise RuntimeError('YAKOR_NE_UNIKALEN: реальная нога '
                                       'карты предъявлена %d раза' % n_nog)
                if n_nog == 1:
                    # пост-реализация: субъект — РЕАЛЬНАЯ нога карты
                    t = t_real
                    if self.freeze_mutacija is not None:
                        t = primenit(t_real, MUTACII_REALNOJ_NOGI_FREEZE,
                                     self.freeze_mutacija)
                else:
                    # окно до реализации: BEZ-NOGI — реальный файл без ноги
                    # и есть мутант «ноги нет»; прочее — патч ноги модели
                    if self.freeze_mutacija == 'PATERN:BEZ-NOGI':
                        t = t_real
                    elif self.freeze_mutacija == 'PATERN:USPEH-KRASIT':
                        t = patched(real, YAKOR_FREEZE,
                                    NOGA_FREEZE_USPEH_KRASIT, '6-карта')
                    elif self.freeze_mutacija == 'PATERN:KONVEJER-FREEZE':
                        t = patched(real, YAKOR_FREEZE,
                                    NOGA_FREEZE_STARY_KONVEJER, '6-карта')
                    elif self.freeze_mutacija == 'PATERN:FREEZE-RC2-PROPUSKAET':
                        t = patched(real, YAKOR_FREEZE,
                                    NOGA_FREEZE_RC2, '6-карта')
                    else:
                        t = patched(real, YAKOR_FREEZE, NOGA_FREEZE, '6-карта')
                vrem = Path(tempfile.mkdtemp(prefix='nog193-'))
                (vrem / 'freeze_contract.sh').write_text(t, encoding='utf-8')
                self._kesh['freeze'] = vrem / 'freeze_contract.sh'
            else:
                put = self.koren / 'scripts' / 'freeze_contract.sh'
                self._kesh['freeze'] = put if put.exists() else None
        return self._kesh['freeze']


def postroit_mir(kuda: Path, ist: Istochniki, kontrakt_f, sdacha_f=None,
                 verdikt_f=None, teg=None, dveri=(), toy_gejty=False,
                 posle_kommita=(), posle_staging=(), posle_staging_rabochij=(),
                 koren_sdacha=None, plany=False, verdikt_put=None,
                 bez_lib=False, profil=None, profil_bityj=False,
                 verdikts_simlink=False, kontrakt_put=None,
                 dop_fajly=()) -> Path:
    """Toy-мир батареи 193: git-репозиторий с контрактом, листом, вердиктом.

    dveri ⊆ {'sdacha','karta','pre_critic','freeze'} — субъекты в scripts/ мира
    (замены и адресные мутации субъекта берутся из ist: режим --stabs);
    toy_gejty — копии настоящих гейтов живого дерева для ног (а)/(б)/(ж)/(з)/(и)
    pre_critic. posle_kommita — записи рабочих файлов ПОСЛЕ коммита (HEAD не
    меняют); posle_staging — запись + git add (индекс расходится с HEAD,
    рабочий файл следует индексу); posle_staging_rabochij — запись поверх
    staging без add (рабочий файл расходится и с индексом: три источника
    различаются — Arb193V1 решение 1).

    Проектная ось 193↔996: profil — workflowPaths проекта (настоящий
    harness.project.json + project-layer.json в корне мира, профильные
    каталоги создаются); profil_bityj — мусорный harness.project.json (битый
    профиль, корневой приманки достаточно); verdikts_simlink — профильный
    verdicts-каталог становится симлинком наружу мира (побег за ROOT);
    kontrakt_put/dop_fajly — контракт и дополнительные файлы по своим путям
    (до коммита). Настоящие sibling-зависимости резолвера (next_id.sh,
    profile_resolver.sh живого дерева) доставляются рядом с дверью карты
    и заморозкой всегда — обязательство не подменяется заранее зелёным JSON.
    """
    for d in ('scripts', 'contracts', 'verdicts/critic', '.github/workflows', 'config'):
        (kuda / d).mkdir(parents=True, exist_ok=True)
    (kuda / 'package.json').write_text(PACKAGE_JSON, encoding='utf-8')
    (kuda / '.github/workflows/ci.yml').write_text(CI_YML, encoding='utf-8')
    (kuda / 'config/ci_parity_exceptions.txt').write_text('', encoding='utf-8')
    for f in MIRSKRIPTY.iterdir():
        shutil.copy2(f, kuda / 'scripts' / f.name)
    if plany:
        (kuda / 'plans').mkdir(exist_ok=True)
        (kuda / 'plans' / '007-toy.md').write_text(
            '# План 007 — toy (батарея 193)\n\n## Незаполненные требования:\nнет\n',
            encoding='utf-8')
    else:
        cel_kontrakt = kuda / (kontrakt_put if kontrakt_put is not None
                               else KONTRAKT)
        cel_kontrakt.parent.mkdir(parents=True, exist_ok=True)
        cel_kontrakt.write_text(tekst(kontrakt_f), encoding='utf-8')
    if sdacha_f is not None:
        (kuda / 'sdacha.md').write_text(tekst(sdacha_f), encoding='utf-8')
    if koren_sdacha is not None:
        (kuda / 'SDACHA.md').write_text(tekst(koren_sdacha), encoding='utf-8')
    if verdikt_f is not None:
        cel_verdikt = verdikt_put if verdikt_put is not None else VERDIKT
        (kuda / cel_verdikt).parent.mkdir(parents=True, exist_ok=True)
        (kuda / cel_verdikt).write_text(tekst(verdikt_f), encoding='utf-8')
    if profil is not None or profil_bityj:
        if profil_bityj:
            (kuda / 'harness.project.json').write_text(
                'не JSON — мусорный профиль (батарея 193, проектная ось)\n',
                encoding='utf-8')
        else:
            (kuda / 'harness.project.json').write_text(json.dumps({
                'schemaVersion': 1,
                'repoId': 'toy-193-profilnaya-os',
                'language': 'bash',
                'projectLayer': {'version': '1',
                                 'profilePath': 'project-layer.json'},
                'workflowPaths': profil,
                'commands': {'test': 'bash scripts/progiban_ok.sh',
                             'build': 'bash scripts/progiban_ok.sh',
                             'typecheck': 'bash scripts/progiban_ok.sh',
                             'lint': 'bash scripts/progiban_ok.sh'},
                'git': {'canonicalRemote': 'https://example.invalid/toy-193.git'},
                'ci': {'workflow': '.github/workflows/ci.yml'},
                'barriers': {'mandatory': [], 'optional': []}},
                indent=1, ensure_ascii=False) + '\n', encoding='utf-8')
            (kuda / 'project-layer.json').write_text(json.dumps({
                'schemaVersion': 1, 'version': '1', 'projectId': 'toy193',
                'workspaceId': 'w193', 'defaults': {}},
                indent=1, ensure_ascii=False) + '\n', encoding='utf-8')
            for put_kataloga in profil.values():
                if verdikts_simlink and put_kataloga == profil['verdicts']:
                    # побег за ROOT: verdicts-каталог — симлинк наружу мира
                    # (внутри — честная карта, недостижимая из HEAD мира)
                    (kuda / put_kataloga).parent.mkdir(parents=True,
                                                       exist_ok=True)
                    vneshnij = kuda.parent / ('vneshne-' + kuda.name)
                    (vneshnij / 'critic').mkdir(parents=True, exist_ok=True)
                    (vneshnij / 'critic' / 'contracts-777-v1.md').write_text(
                        tekst('verdikt_chestnyj.md'), encoding='utf-8')
                    os.symlink(vneshnij, kuda / put_kataloga)
                else:
                    (kuda / put_kataloga).mkdir(parents=True, exist_ok=True)
    for otn, imja_fajla in dop_fajly:
        cel = kuda / otn
        cel.parent.mkdir(parents=True, exist_ok=True)
        cel.write_text(tekst(imja_fajla), encoding='utf-8')
    if toy_gejty:
        for f in TOY_GEJTY + LIBS + FORMA_GEJTY:
            shutil.copy2(DEREVO / 'scripts' / f, kuda / 'scripts' / f)
    dver_subj = ist.dver()
    if 'sdacha' in dveri and dver_subj is not None:
        shutil.copy2(dver_subj, kuda / 'scripts' / 'check_sdacha.sh')
    karta_subj = ist.karta()
    if 'karta' in dveri and karta_subj is not None:
        shutil.copy2(karta_subj, kuda / 'scripts' / 'check_verdict_karta.sh')
        # настоящие sibling-зависимости резолвера 996 — из живого дерева
        # (модель заменяет только дверь, не резолвер и не данные профиля)
        for f in ('next_id.sh', 'profile_resolver.sh'):
            shutil.copy2(DEREVO / 'scripts' / f, kuda / 'scripts' / f)
    if 'sdacha' in dveri or 'karta' in dveri:
        if not bez_lib:
            lib_subj = ist.lib()
            if lib_subj is not None:
                shutil.copy2(lib_subj, kuda / 'scripts' / 'lib_karta_sdachi.sh')
    if 'pre_critic' in dveri:
        subj = ist.pre_critic()
        if subj is not None:
            shutil.copy2(subj, kuda / 'scripts' / 'pre_critic.sh')
    if 'freeze' in dveri:
        subj = ist.freeze()
        if subj is not None:
            shutil.copy2(subj, kuda / 'scripts' / 'freeze_contract.sh')
            # libs заморозки — от того же источника, что и сама нога
            lib_istok = DEREVO if ist.dostroat_nogi else ist.koren
            for f in FREEZE_LIBS:
                if (lib_istok / 'scripts' / f).exists():
                    shutil.copy2(lib_istok / 'scripts' / f, kuda / 'scripts' / f)
            # профильному миру нужен настоящий profile_resolver.sh рядом
            shutil.copy2(DEREVO / 'scripts' / 'profile_resolver.sh',
                         kuda / 'scripts' / 'profile_resolver.sh')
    git(kuda, 'init', '-q', '-b', 'main')
    git(kuda, 'add', '-A')
    git(kuda, 'commit', '-qm', 'toy193: init')
    if teg == 'zamorozhen':
        git(kuda, 'tag', 'frozen/contracts/777/1')
    elif teg == 'v1-zatem-v2':
        git(kuda, 'tag', 'frozen/contracts/777/1')
        (kuda / KONTRAKT).write_text(tekst('kontrakt_v2_draft.md'), encoding='utf-8')
        git(kuda, 'add', '-A')
        git(kuda, 'commit', '-qm', 'toy193: v+1 draft')
    for otn, soderzhimoe in posle_kommita:
        cel = kuda / otn
        cel.parent.mkdir(parents=True, exist_ok=True)
        cel.write_text(soderzhimoe, encoding='utf-8')
    for otn, soderzhimoe in posle_staging:
        cel = kuda / otn
        cel.parent.mkdir(parents=True, exist_ok=True)
        cel.write_text(soderzhimoe, encoding='utf-8')
        git(kuda, 'add', '--', otn)
    for otn, soderzhimoe in posle_staging_rabochij:
        cel = kuda / otn
        cel.parent.mkdir(parents=True, exist_ok=True)
        cel.write_text(soderzhimoe, encoding='utf-8')
    return kuda


SPECSY = {
    'chestnyj': dict(kontrakt_f='kontrakt_chestnyj.md', sdacha_f='sdacha_chestnaja.md',
                     dveri=('sdacha',)),
    'novyj': dict(kontrakt_f='kontrakt_novogo.md', dveri=('sdacha',)),
    'lozhnyj_rc': dict(kontrakt_f='kontrakt_chestnyj.md', sdacha_f='sdacha_lozhnyj_rc.md',
                       dveri=('sdacha',)),
    'komanda_netu': dict(kontrakt_f='kontrakt_chestnyj.md', sdacha_f='sdacha_komanda_netu.md',
                         dveri=('sdacha',)),
    'karta_16': dict(kontrakt_f='kontrakt_chestnyj.md', sdacha_f='sdacha_karta_16.md',
                     dveri=('sdacha',), koren_sdacha='sdacha_chestnaja.md'),
    'status_vne': dict(kontrakt_f='kontrakt_chestnyj.md', sdacha_f='sdacha_status_vne.md',
                       dveri=('sdacha',)),
    'delta_nepolnaja': dict(kontrakt_f='kontrakt_chestnyj.md',
                            sdacha_f='sdacha_delta_nepolnaja.md',
                            verdikt_f='verdikt_fail_s_kartoj.md', dveri=('sdacha',)),
    'delta_polnaja': dict(kontrakt_f='kontrakt_chestnyj.md',
                          sdacha_f='sdacha_delta_polnaja.md',
                          verdikt_f='verdikt_fail_s_kartoj.md', dveri=('sdacha',)),
    'delta_head': dict(kontrakt_f='kontrakt_chestnyj.md',
                       sdacha_f='sdacha_delta_polnaja.md',
                       verdikt_f='verdikt_fail_s_kartoj.md', dveri=('sdacha',),
                       posle_kommita=[(VERDIKT, tekst('verdikt_rabochij_bez_blokov.md'))]),
    'delta_head_nepolnaja': dict(
        kontrakt_f='kontrakt_chestnyj.md', sdacha_f='sdacha_delta_nepolnaja.md',
        verdikt_f='verdikt_fail_s_kartoj.md', dveri=('sdacha',),
        posle_kommita=[(VERDIKT, tekst('verdikt_rabochij_bez_blokov.md'))]),
    # Arb193V1 решение 1 (К-08): индекс и рабочий файл расходятся с HEAD.
    'delta_index_nepolnaja': dict(
        kontrakt_f='kontrakt_chestnyj.md', sdacha_f='sdacha_delta_nepolnaja.md',
        verdikt_f='verdikt_fail_s_kartoj.md', dveri=('sdacha',),
        posle_staging=[(VERDIKT, tekst('verdikt_rabochij_bez_blokov.md'))],
        posle_staging_rabochij=[(VERDIKT, tekst('verdikt_fail_s_kartoj.md'))]),
    'delta_index_polnaja': dict(
        kontrakt_f='kontrakt_chestnyj.md', sdacha_f='sdacha_delta_polnaja.md',
        verdikt_f='verdikt_fail_s_kartoj.md', dveri=('sdacha',),
        posle_staging=[(VERDIKT, tekst('verdikt_rabochij_bez_blokov.md'))],
        posle_staging_rabochij=[(VERDIKT, tekst('verdikt_fail_s_kartoj.md'))]),
    'delta_bez_verdikta_staged': dict(
        kontrakt_f='kontrakt_chestnyj.md', sdacha_f='sdacha_delta_polnaja.md',
        dveri=('sdacha',),
        posle_staging=[(VERDIKT, tekst('verdikt_rabochij_bez_blokov.md'))]),
    'sposob_vne': dict(kontrakt_f='kontrakt_chestnyj.md', sdacha_f='sdacha_sposob_vne.md',
                       verdikt_f='verdikt_fail_s_kartoj.md', dveri=('sdacha',)),
    'staryj': dict(kontrakt_f='kontrakt_zamorozhennyj.md', teg='zamorozhen',
                   dveri=('sdacha',)),
    'vplus1': dict(kontrakt_f='kontrakt_zamorozhennyj.md', teg='v1-zatem-v2',
                   dveri=('sdacha',)),
    'plan': dict(kontrakt_f='kontrakt_novogo.md', plany=True, dveri=('sdacha',)),
    'patom': dict(kontrakt_f='kontrakt_chestnyj.md', sdacha_f='sdacha_s_patom.md',
                  dveri=('sdacha',)),
    'budzhet': dict(kontrakt_f='kontrakt_chestnyj.md', sdacha_f='sdacha_s_budzhetom.md',
                    dveri=('sdacha',)),
    'budzhet_poslednej': dict(kontrakt_f='kontrakt_chestnyj.md',
                              sdacha_f='sdacha_budzhet_poslednej.md',
                              dveri=('sdacha',)),
    'pustoj_listok': dict(kontrakt_f='kontrakt_chestnyj.md', sdacha_f='sdacha_pustaja.md',
                          dveri=('sdacha',)),
    'put_vne': dict(kontrakt_f='kontrakt_so_sdachej_vne.md', dveri=('sdacha',)),
    'stroka_vne': dict(kontrakt_f='kontrakt_chestnyj.md', sdacha_f='sdacha_stroka_vne.md',
                       dveri=('sdacha',)),
    'rekursija': dict(kontrakt_f='kontrakt_chestnyj.md', sdacha_f='sdacha_rekursivnaja.md',
                      dveri=('sdacha', 'pre_critic'), toy_gejty=True),
    'verdikt_chestnyj': dict(kontrakt_f='kontrakt_novogo.md',
                             verdikt_f='verdikt_chestnyj.md', dveri=('karta',)),
    'verdikt_karta_16': dict(kontrakt_f='kontrakt_novogo.md',
                             verdikt_f='verdikt_karta_16.md', dveri=('karta',)),
    'verdikt_status_vne': dict(kontrakt_f='kontrakt_novogo.md',
                               verdikt_f='verdikt_status_vne.md', dveri=('karta',)),
    'verdikt_pustoj_hvost': dict(kontrakt_f='kontrakt_novogo.md',
                                 verdikt_f='verdikt_pustoj_hvost.md', dveri=('karta',)),
    'verdikt_dubl': dict(kontrakt_f='kontrakt_novogo.md',
                         verdikt_f='verdikt_dubl.md', dveri=('karta',)),
    'verdikt_ne_zakommlchen': dict(
        kontrakt_f='kontrakt_novogo.md', dveri=('karta',),
        posle_kommita=[(VERDIKT, tekst('verdikt_chestnyj.md'))]),
    'verdikt_karta_rabochij': dict(
        kontrakt_f='kontrakt_novogo.md', verdikt_f='verdikt_karta_16.md',
        dveri=('karta',),
        posle_kommita=[(VERDIKT, tekst('verdikt_chestnyj.md'))]),
    'verdikt_karta_rabochij_chestnyj': dict(
        kontrakt_f='kontrakt_novogo.md', verdikt_f='verdikt_chestnyj.md',
        dveri=('karta',),
        posle_kommita=[(VERDIKT, tekst('verdikt_karta_16.md'))]),
    'verdikt_karta_index': dict(
        kontrakt_f='kontrakt_novogo.md', verdikt_f='verdikt_karta_16.md',
        dveri=('karta',),
        posle_staging=[(VERDIKT, tekst('verdikt_chestnyj.md'))],
        posle_staging_rabochij=[(VERDIKT, tekst('verdikt_karta_16.md'))]),
    'verdikt_karta_index_chestnyj': dict(
        kontrakt_f='kontrakt_novogo.md', verdikt_f='verdikt_chestnyj.md',
        dveri=('karta',),
        posle_staging=[(VERDIKT, tekst('verdikt_karta_16.md'))],
        posle_staging_rabochij=[(VERDIKT, tekst('verdikt_chestnyj.md'))]),
    'verdikt_staged_bez_head': dict(
        kontrakt_f='kontrakt_novogo.md', dveri=('karta',),
        posle_staging=[(VERDIKT, tekst('verdikt_chestnyj.md'))]),
    'freeze_karta': dict(kontrakt_f='kontrakt_chestnyj.md',
                         verdikt_f='verdikt_accept_bez_karty.md',
                         dveri=('karta', 'freeze')),
    'freeze_staryj': dict(kontrakt_f='kontrakt_zamorozhennyj.md',
                          verdikt_f='verdikt_accept_bez_karty.md',
                          dveri=('karta', 'freeze')),
    'freeze_zelenyj': dict(kontrakt_f='kontrakt_chestnyj.md',
                           verdikt_f='verdikt_chestnyj.md',
                           dveri=('karta', 'freeze')),
    'noga_krasna': dict(kontrakt_f='kontrakt_novogo.md', dveri=('sdacha', 'pre_critic'),
                        toy_gejty=True),
    'repo_bez_dveri': dict(kontrakt_f='kontrakt_novogo.md'),
    # Rev193 С-1 M01: дубль строки СДАЧА (рабочий файл после коммита).
    'dubl_sdacha': dict(kontrakt_f='kontrakt_chestnyj.md',
                        sdacha_f='sdacha_chestnaja.md', dveri=('sdacha',),
                        posle_kommita=[(KONTRAKT,
                                        tekst('kontrakt_chestnyj.md')
                                        + 'СДАЧА: drugaja.md\n')]),
    # Rev193 С-1 M03: заявленные rc ряда «Двери» расходятся (0 ≠ 1).
    'rashodka': dict(kontrakt_f='kontrakt_chestnyj.md',
                     sdacha_f='sdacha_chestnaja.md', dveri=('sdacha',),
                     posle_kommita=[('sdacha.md',
                                     tekst('sdacha_chestnaja.md').replace(
                                         'проба-ок · bash scripts/progiban_ok.sh · 0 · 0',
                                         'проба-ок · bash scripts/progiban_ok.sh · 0 · 1'))]),
    # Rev193 С-1 M04: команда bash с путём за корнем мира (../vneshnij.sh).
    'bash_put_vne': dict(kontrakt_f='kontrakt_chestnyj.md',
                    sdacha_f='sdacha_chestnaja.md', dveri=('sdacha',),
                    posle_kommita=[('sdacha.md',
                                    tekst('sdacha_chestnaja.md').replace(
                                        'проба-ок · bash scripts/progiban_ok.sh',
                                        'проба-vne · bash ../vneshnij.sh')),
                                    ('../vneshnij.sh', VNESHNIJ_SKRIPT)]),
    # Rev193 С-1 M05: ряд «- » до всякой машинной секции листа.
    'vne_sekcii': dict(kontrakt_f='kontrakt_chestnyj.md',
                       sdacha_f='sdacha_chestnaja.md', dveri=('sdacha',),
                       posle_kommita=[('sdacha.md',
                                       tekst('sdacha_chestnaja.md').replace(
                                           '## Двери',
                                           '- внесекционный ряд · вне машинных секций · 0 · 0\n\n'
                                           '## Двери', 1))]),
    # Rev193 С-1 M09: честный вердикт по пути вне verdicts/critic/.
    'verdikt_vne_critic': dict(kontrakt_f='kontrakt_novogo.md',
                               verdikt_f='verdikt_chestnyj.md',
                               verdikt_put='verdicts/other/contracts-777-v1.md',
                               dveri=('karta',)),
    # Rev193 С-1 M12: дверь карты в мире без lib — rc 2 NOT_IMPLEMENTED,
    # честная нога freeze обязана отказать именованно.
    'freeze_bez_lib': dict(kontrakt_f='kontrakt_chestnyj.md',
                           verdikt_f='verdikt_accept_bez_karty.md',
                           dveri=('karta', 'freeze'), bez_lib=True),
    # ── проектная ось 193↔996 (С-10/С-6): профильный verdicts-каталог ─────────
    # Профиль .harness/verdicts, честная карта 17/17 на HEAD (>64 КиБ —
    # проектный длинный вход прямой клетки).
    'profil_chestnyj': dict(kontrakt_f='kontrakt_novogo.md',
                            verdikt_f='verdikt_chestnyj.md',
                            verdikt_put=PROFIL_VERDIKT, dveri=('karta',),
                            profil=PROFIL_STANDART),
    # Другой законный эффективный verdicts-каталог (не .harness) — та же
    # семантика без привязки к имени.
    'profil_drugoj': dict(kontrakt_f='kontrakt_novogo.md',
                          verdikt_f='verdikt_chestnyj.md',
                          verdikt_put='workflow/judgements/critic/'
                                      'contracts-777-v1.md',
                          dveri=('karta',), profil=PROFIL_DRUGOJ),
    # При активном профильном каталоге честная корневая приманка (17/17)
    # не открывает дверь.
    'profil_primanka': dict(kontrakt_f='kontrakt_novogo.md',
                            verdikt_f='verdikt_chestnyj.md', dveri=('karta',),
                            profil=PROFIL_STANDART),
    # Чужая роль review под профильным префиксом — с честной картой 17/17.
    'profil_review': dict(kontrakt_f='kontrakt_novogo.md',
                          verdikt_f='verdikt_chestnyj.md',
                          verdikt_put='.harness/verdicts/review/'
                                      'contracts-777-v1.md',
                          dveri=('karta',), profil=PROFIL_STANDART),
    # Битый профиль + честная корневая приманка: fallback на корень запрещён.
    'profil_bityj': dict(kontrakt_f='kontrakt_novogo.md',
                         verdikt_f='verdikt_chestnyj.md', dveri=('karta',),
                         profil_bityj=True),
    # Симлинк-побег verdicts-каталога за ROOT + честная корневая приманка.
    'profil_pobeg': dict(kontrakt_f='kontrakt_novogo.md',
                         verdikt_f='verdikt_chestnyj.md', dveri=('karta',),
                         profil=PROFIL_STANDART, verdikts_simlink=True),
    # Staged «починка» плохого профильного HEAD не делает карту зелёной.
    'profil_staged_pochinka': dict(
        kontrakt_f='kontrakt_novogo.md', verdikt_f='verdikt_karta_16.md',
        verdikt_put=PROFIL_VERDIKT, dveri=('karta',), profil=PROFIL_STANDART,
        posle_staging=[(PROFIL_VERDIKT, tekst('verdikt_chestnyj.md'))]),
    # Незакоммиченное «ухудшение» честного профильного HEAD не делает её
    # красной.
    'profil_rab_uchudshenie': dict(
        kontrakt_f='kontrakt_novogo.md', verdikt_f='verdikt_chestnyj.md',
        verdikt_put=PROFIL_VERDIKT, dveri=('karta',), profil=PROFIL_STANDART,
        posle_kommita=[(PROFIL_VERDIKT, tekst('verdikt_karta_16.md'))]),
    # Профильного вердикта нет в HEAD (только staged) — отказ.
    'profil_staged_bez_head': dict(
        kontrakt_f='kontrakt_novogo.md', dveri=('karta',),
        profil=PROFIL_STANDART,
        posle_staging=[(PROFIL_VERDIKT, tekst('verdikt_chestnyj.md'))]),
    # Путь с сегментом «..» сквозь корневую грамматику (без профиля):
    # evil.md закоммичен в корне с честной картой — гард побега обязан
    # отказать ДО чтения блоба.
    'pobeg_dotdot': dict(kontrakt_f='kontrakt_novogo.md',
                         verdikt_f='verdikt_chestnyj.md',
                         verdikt_put='verdicts/critic/../../evil.md',
                         dveri=('karta',)),
    # Интеграция freeze: профильные contracts/verdicts, плохая карта — отказ
    # ИМЕННО картой, без тега и записи реестра.
    'freeze_profil_karta': dict(kontrakt_f='kontrakt_chestnyj.md',
                                kontrakt_put=PROFIL_KONTRAKT,
                                verdikt_f='verdikt_karta_16.md',
                                verdikt_put=PROFIL_VERDIKT,
                                dveri=('karta', 'freeze'),
                                profil=PROFIL_STANDART),
    # Интеграция freeze: честная карта проходит ИМЕННО карту и доходит до
    # следующего контролируемого этапа (toy spec-preflight rc 127 — не полная
    # успешная заморозка); контракт и вердикт >64 КиБ — проектный длинный
    # вход ноги.
    'freeze_profil_zelenyj': dict(kontrakt_f='kontrakt_chestnyj.md',
                                  kontrakt_put=PROFIL_KONTRAKT,
                                  verdikt_f='verdikt_chestnyj.md',
                                  verdikt_put=PROFIL_VERDIKT,
                                  dveri=('karta', 'freeze'),
                                  profil=PROFIL_STANDART),
}


# Ось ссылок v3: входы порождаются из одного шаблона 17 строк; ожидания ниже
# литеральны и сняты до вызова двери. Никаких чтений исходников из OBJECT.
def karta_vyzova(n, result='accept', zamena=None, tema='777'):
    zamena = zamena or {}
    stroki = [result, 'OBJECT=' + 'a' * 40,
              'СУД: repo=toy; предмет=%s; роль=critic; вызов=%s/9;' % (tema, n),
              '', '## Карта классов', '']
    for k in range(1, 18):
        status = 'н/п — вход: не предмет' if k in (13, 17) else 'чисто — вход: честный контроль'
        stroki.append('К-%02d: %s' % (k, zamena.get(k, status)))
    return '\n'.join(stroki) + '\n'


def kletki_ssylok(miry):
    pred = 'verdicts/critic/contracts-777-call-03.md'
    pervyj = 'verdicts/critic/contracts-777-call-01.md'
    vtoroj = 'verdicts/critic/contracts-777-call-02.md'
    chastye = {k: 'без изменений с вызова 03.' for k in (1, 2, 3, 4, 5, 6, 12, 13, 16, 17)}
    chistyj = karta_vyzova('03')
    fail = karta_vyzova('04', 'FAIL', chastye | {11: 'блок — вход: новый дефект оракула'})
    chain = [(pervyj, karta_vyzova('01', zamena={2: 'блок — вход: исходный блок'})),
             (vtoroj, karta_vyzova('02', zamena={2: 'без изменений с вызова 01.'})),
             (pred, karta_vyzova('03', zamena={2: 'без изменений с вызова 02 — цепочка'}))]
    # имя, предъявленный текст, артефакты истории, покрытые классы, rc, причина
    cases = [
        ('r01-prjamaja', fail, [(pred, chistyj)], (11,), 0, 'лист зелёный'),
        ('r02-cepochka', karta_vyzova('04', zamena={2: 'без изменений с вызова 03.'}),
         chain, (2,), 0, 'лист зелёный'),
        ('r03-unasledovannyj-blok', karta_vyzova('04', zamena={2: 'без изменений с вызова 03.'}),
         chain, (), 1, 'блок К-02'),
        ('r04-net-vyzova', karta_vyzova('04', zamena={2: 'без изменений с вызова 99.'}),
         [(pred, chistyj)], (), 1, 'отсутствует вызов 99'),
        ('r05-cikl', karta_vyzova('04', zamena={2: 'без изменений с вызова 03.'}),
         [(pred, karta_vyzova('03', zamena={2: 'без изменений с вызова 02.'})),
          (vtoroj, karta_vyzova('02', zamena={2: 'без изменений с вызова 03.'}))],
         (), 1, 'цикл ссылок'),
        ('r06-neodnoznachnost', fail,
         [(pred, chistyj), (pervyj, karta_vyzova('03', zamena={2: 'блок — вход: иной вызов'}))],
         (11,), 1, 'неоднозначный вызов 3'),
        # Воспроизведение 206: лист ссылается на старый accept 03, HEAD хранит
        # более новый FAIL 04 с К-11, а не «закрытие» этого блока из вызова 03.
        ('r07-staryj-accept-ne-skryvaet-fail', chistyj,
         [(VERDIKT, fail)], (), 1, 'блок К-11'),
        ('r08-poslednij-fail-zakryt', chistyj,
         [(VERDIKT, fail)], (11,), 0, 'лист зелёный'),
        ('r09-poslednij-fail-nepolnaja-karta', chistyj,
         [(VERDIKT, '\n'.join(x for x in fail.splitlines() if not x.startswith('К-17:')) + '\n')],
         (11,), 1, 'К-17'),
        ('r10-istoricheskij-object', fail, [(pred, chistyj)], (11,), 0, 'лист зелёный'),
        ('r11-staged-skryvaet-cel', karta_vyzova('04', zamena={2: 'без изменений с вызова 03.'}),
         chain, (), 1, 'блок К-02'),
        ('r12-staged-portit-chestnuju-cel', fail, [(pred, chistyj)], (11,), 0, 'лист зелёный'),
        ('r13-staged-ne-sozdaet-vyzov', karta_vyzova('04', zamena={2: 'без изменений с вызова 03.'}),
         [], (), 1, 'отсутствует вызов 3'),
        ('r14-chuzhoj-predmet', fail,
         [(pred, chistyj), (pervyj, karta_vyzova('09', 'FAIL', {1: 'блок — чужой'}, tema='888'))],
         (11,), 0, 'лист зелёный'),
        ('r15-vedushchie-nuli', karta_vyzova('04', zamena={2: 'без изменений с вызова 003.'}),
         [(pred, chistyj)], (), 0, 'лист зелёный'),
        ('r16-istoriya-togo-zhe-puti', fail, [(VERDIKT, chistyj)], (11,), 0, 'лист зелёный'),
    ]
    previous = 'без изменений с предыдущего вызова'
    previous_fail = karta_vyzova('04', 'FAIL', {2: previous, 11: 'блок — вход: новый дефект'})
    previous_history = [(vtoroj, karta_vyzova('02')), (pred, karta_vyzova('03', zamena={2: previous}))]
    cases.extend([
        ('r34-predydushchij', karta_vyzova('03', zamena={2: previous}),
         [(vtoroj, karta_vyzova('02'))], (), 0, 'лист зелёный'),
        ('r35-predydushchij-blok', karta_vyzova('03', zamena={2: previous}),
         [(vtoroj, karta_vyzova('02', zamena={2: 'блок — вход: унаследованный блок'}))],
         (), 1, 'блок К-02'),
        ('r36-predydushchij-cepochka', karta_vyzova('04', zamena={2: previous + '.'}),
         [(vtoroj, karta_vyzova('02', zamena={2: 'блок — вход: унаследованный блок'})),
          (pred, karta_vyzova('03', zamena={2: previous}))], (2,), 0, 'лист зелёный'),
        ('r37-predydushchij-net-vyzova', karta_vyzova('03', zamena={2: previous}),
         [(pervyj, karta_vyzova('01'))], (), 1, 'отсутствует вызов 2'),
        ('r38-predydushchij-istoriya', karta_vyzova('03', zamena={2: previous}),
         [(VERDIKT, karta_vyzova('02', zamena={2: 'блок — вход: исторический блок'}))],
         (2,), 0, 'лист зелёный'),
        ('r39-predydushchij-posle-fail', karta_vyzova('03', zamena={2: previous}),
         [(vtoroj, karta_vyzova('02')), (VERDIKT, previous_fail)],
         (), 1, 'блок К-11'),
        ('r40-predydushchij-fail-zakryt', karta_vyzova('03', zamena={2: previous}),
         [(vtoroj, karta_vyzova('02')), (VERDIKT, previous_fail)],
         (11,), 0, 'лист зелёный'),
        ('r41-predydushchij-istoricheskij-fail', karta_vyzova('03', zamena={2: previous}),
         previous_history + [(VERDIKT, previous_fail),
                             (VERDIKT, karta_vyzova('05', 'FAIL', {11: previous}))],
         (), 1, 'блок К-11'),
        ('r42-predydushchij-istoricheskij-fail-zakryt', karta_vyzova('03', zamena={2: previous}),
         previous_history + [(VERDIKT, previous_fail),
                             (VERDIKT, karta_vyzova('05', 'FAIL', {11: previous}))],
         (11,), 0, 'лист зелёный'),
        # Относительная ссылка принадлежит историческому 03, а не 04/HEAD.
        ('r43-javnyj-na-predydushchij', karta_vyzova('04', zamena={2: 'без изменений с вызова 03.'}),
         [(vtoroj, karta_vyzova('02', zamena={2: 'блок — вход: исторический блок'})),
          (pred, karta_vyzova('03', zamena={2: previous + ' — тот же класс'}))],
         (2,), 0, 'лист зелёный'),
        ('r44-predydushchij-bez-konteksta',
         '\n'.join(line for line in karta_vyzova('03', zamena={2: previous}).splitlines()
                   if not line.startswith('СУД:')) + '\n',
         [(vtoroj, karta_vyzova('02'))], (), 1, 'предыдущий вызов требует СУД'),
        ('r45-predydushchij-pervyj', karta_vyzova('01', zamena={2: previous}),
         [], (), 1, 'у вызова 1 нет предыдущего вызова'),
        ('r46-predydushchij-vne-grammatiki', karta_vyzova('03', zamena={2: previous + 'X'}),
         [(vtoroj, karta_vyzova('02'))], (), 1, 'ссылка вне грамматики'),
        ('r47-predydushchij-nuli', karta_vyzova('0010', zamena={2: previous}),
         [(vtoroj, karta_vyzova('0009'))], (), 0, 'лист зелёный'),
        ('r48-predydushchij-bolshoj', karta_vyzova('100000000000000000000', zamena={2: previous}),
         [(vtoroj, karta_vyzova('99999999999999999999'))], (), 0, 'лист зелёный'),
        ('r49-prjamoj-status-s-poyasneniem',
         karta_vyzova('03', zamena={2: 'чисто — ' + previous, 13: 'н/п — без изменений с вызова 99.'}),
         [], (), 0, 'лист зелёный'),
        # Crit193V7: текущий К-02 ведёт в прямой К-02 исторического 03,
        # но другая строка источника обязана раскрыться полностью.
        ('r50-drugoj-klass-net-vyzova', karta_vyzova('04', zamena={2: previous}),
         [(pred, karta_vyzova('03', zamena={3: previous}))],
         (), 1, 'отсутствует вызов 2'),
        ('r51-drugoj-klass-glubzhe', karta_vyzova('04', zamena={2: previous}),
         [(vtoroj, karta_vyzova('02', zamena={1: previous})),
          (pred, karta_vyzova('03', zamena={17: 'без изменений с вызова 02.'}))],
         (), 1, 'отсутствует вызов 1'),
        ('r52-drugoj-klass-chestnyj', karta_vyzova('04', zamena={2: previous}),
         [(vtoroj, karta_vyzova('02')),
          (pred, karta_vyzova('03', zamena={3: previous}))],
         (), 0, 'лист зелёный'),
        ('r53-drugoj-klass-glubzhe-chestnyj', karta_vyzova('04', zamena={2: previous}),
         [(pervyj, karta_vyzova('01')),
          (vtoroj, karta_vyzova('02', zamena={1: previous})),
          (pred, karta_vyzova('03', zamena={17: 'без изменений с вызова 02.'}))],
         (), 0, 'лист зелёный'),
        ('r54-drugoj-klass-cikl', karta_vyzova('04', zamena={2: previous}),
         [(vtoroj, karta_vyzova('02', zamena={3: 'без изменений с вызова 03.'})),
          (pred, karta_vyzova('03', zamena={3: previous}))],
         (), 1, 'цикл ссылок'),
        ('r55-drugoj-klass-neodnoznachnost', karta_vyzova('04', zamena={2: previous}),
         [(vtoroj, karta_vyzova('02')),
          (pervyj, karta_vyzova('02', zamena={3: 'блок — вход: иной вызов'})),
          (pred, karta_vyzova('03', zamena={3: previous}))],
         (), 1, 'неоднозначный вызов 2'),
        # Цикл карт не равен циклу пары вызов/класс: обе цепи прямые.
        ('r56-drugoj-klass-vstrechnye-karty', karta_vyzova('04', zamena={2: previous}),
         [(pred, karta_vyzova('03', zamena={3: 'без изменений с вызова 04.'}))],
         (), 0, 'лист зелёный'),
    ])
    # Каждый класс последнего FAIL проверяется своим предъявлением, не первой
    # красной точкой объединённого входа; два класса не считаются одним тестом.
    for klass in range(1, 18):
        cases.append(('r%02d-last-fail-k%02d' % (16 + klass, klass), chistyj,
                      [(VERDIKT, karta_vyzova('04', 'FAIL', {klass: 'блок — вход: непокрытый класс'}))],
                      (), 1, 'блок К-%02d' % klass))

    K = []
    for name, current, history, closed, rc, marker in cases:
        for door in ('sdacha', 'karta'):
            # Покрытие дельты — только дверь листа; остальные свойства общие.
            if door == 'karta' and name not in {
                    'r01-prjamaja', 'r02-cepochka', 'r04-net-vyzova',
                    'r05-cikl', 'r06-neodnoznachnost', 'r10-istoricheskij-object',
                    'r11-staged-skryvaet-cel', 'r12-staged-portit-chestnuju-cel',
                    'r13-staged-ne-sozdaet-vyzov', 'r14-chuzhoj-predmet',
                    'r15-vedushchie-nuli', 'r16-istoriya-togo-zhe-puti',
                    'r34-predydushchij', 'r36-predydushchij-cepochka',
                    'r37-predydushchij-net-vyzova', 'r38-predydushchij-istoriya',
                    'r43-javnyj-na-predydushchij', 'r44-predydushchij-bez-konteksta',
                    'r45-predydushchij-pervyj', 'r46-predydushchij-vne-grammatiki',
                    'r47-predydushchij-nuli', 'r48-predydushchij-bolshoj',
                    'r49-prjamoj-status-s-poyasneniem',
                    'r50-drugoj-klass-net-vyzova', 'r51-drugoj-klass-glubzhe',
                    'r52-drugoj-klass-chestnyj', 'r53-drugoj-klass-glubzhe-chestnyj',
                    'r54-drugoj-klass-cikl', 'r55-drugoj-klass-neodnoznachnost',
                    'r56-drugoj-klass-vstrechnye-karty'}:
                continue
            exp_rc, exp_marker = rc, marker
            if door == 'karta' and name == 'r11-staged-skryvaet-cel':
                exp_rc = 0
            if door == 'karta' and exp_rc == 0:
                exp_marker = 'КАРТА: 17/17 зелёный'
            state = {}

            def snapshot(root):
                files = tuple((str(p.relative_to(root)), p.read_bytes())
                              for p in sorted((root / 'verdicts/critic').glob('*.md')))
                head = subprocess.run(['git', '-C', str(root), 'rev-parse', 'HEAD'],
                                      check=True, capture_output=True).stdout
                index = (root / '.git/index').read_bytes()
                return files, head, index

            def argv(name=name, current=current, history=history, closed=closed,
                     door=door, state=state):
                root = postroit_mir(miry.vrem / (name + '-' + door), miry.ist,
                                    'kontrakt_chestnyj.md', 'sdacha_chestnaja.md',
                                    dveri=('sdacha', 'karta'))
                for path, text in history:
                    (root / path).write_text(text, encoding='utf-8')
                    git(root, 'add', '-A')
                    git(root, 'commit', '-qm', 'toy193: historical call')
                path = pred if name.startswith(('r07-', 'r08-', 'r09-', 'r39-', 'r40-', 'r41-', 'r42-')) or '-last-fail-' in name else VERDIKT
                (root / path).write_text(current, encoding='utf-8')
                sheet = ('ПРЕДЫДУЩИЙ ВЕРДИКТ: ' + path + '\n\n' + tekst('sdacha_chestnaja.md')
                         + '\n## Дельта\n\n'
                         + ''.join('- К-%02d · клетка · bash scripts/progiban_ok.sh · 0 · 0\n' % k
                                   for k in closed))
                (root / 'sdacha.md').write_text(sheet, encoding='utf-8')
                git(root, 'add', '-A')
                git(root, 'commit', '-qm', 'toy193: current call and sheet')
                if name.startswith(('r11-', 'r12-', 'r13-')):
                    bad = karta_vyzova('03', zamena={2: 'блок — вход: staged ухудшение'})
                    (root / pred).write_text(bad if name.startswith('r12-') else chistyj,
                                             encoding='utf-8')
                    git(root, 'add', '--', pred)
                state['root'], state['before'] = root, snapshot(root)
                command = ['bash', str(root / 'scripts' / ('check_sdacha.sh' if door == 'sdacha'
                                                          else 'check_verdict_karta.sh'))]
                return command + [str(root), KONTRAKT, '--run'] if door == 'sdacha' \
                    else command + [str(root), path]

            K.append(Kletka(name + '-' + door, argv, exp_rc, [exp_marker],
                            tajmaut=12,
                            posle=lambda state=state: snapshot(state['root']) == state['before']))
    return K


class Miry:
    """Миры строятся ленично и по одному; клетка ссылается на свой мир."""

    def __init__(self, vrem: Path, ist: Istochniki):
        self.vrem, self.ist = vrem, ist
        self._miry = {}

    def __getitem__(self, imja: str) -> Path:
        if imja not in self._miry:
            self._miry[imja] = postroit_mir(
                self.vrem / ('mir-' + imja), self.ist, **SPECSY[imja])
        return self._miry[imja]


class Kletka:
    def __init__(self, imja, argv, rc, markery=(), ne_markery=(), env=None, tajmaut=90, posle=None):
        self.imja, self.argv, self.rc = imja, argv, rc
        self.markery, self.ne_markery = list(markery), list(ne_markery)
        self.env, self.tajmaut = env, tajmaut
        self.posle = posle


def kletki(miry: Miry) -> list:
    K = []

    # argv клетки — леничный: мир строится к моменту ПРОГОНА клетки (не к
    # построению списка) — режим --stabs строит один мир на привязку
    # (Rev193: рост числа привязок не должен умножать время на все миры)
    def dver(imja_mira):
        return lambda: ['bash', str(miry[imja_mira] / 'scripts' / 'check_sdacha.sh'),
                        str(miry[imja_mira]), KONTRAKT, '--run']

    def karta(imja_mira):
        return lambda: ['bash', str(miry[imja_mira] / 'scripts' / 'check_verdict_karta.sh'),
                        str(miry[imja_mira]), VERDIKT]

    def zamorozka(imja_mira):
        return lambda: ['bash', str(miry[imja_mira] / 'scripts' / 'freeze_contract.sh'),
                        KONTRAKT, 'toy-причина-193', str(miry[imja_mira])]

    def karta_put(imja_mira, put):
        # проектная ось: произвольный путь вердикта (put может быть callable —
        # абсолютный путь требует адреса мира, который ленив)
        return lambda: ['bash',
                        str(miry[imja_mira] / 'scripts' / 'check_verdict_karta.sh'),
                        str(miry[imja_mira]),
                        put() if callable(put) else put]

    def zamorozka_profilnaja(imja_mira):
        return lambda: ['bash', str(miry[imja_mira] / 'scripts' / 'freeze_contract.sh'),
                        PROFIL_KONTRAKT, 'toy-причина-193', str(miry[imja_mira])]


    # половина (а): дверь сдаточного листа
    K.append(Kletka('s01-novyj-bez-sdachi', dver('novyj'), 1, ['СДАЧА:', 'обязательна']))
    K.append(Kletka('s02-chestnyj-listok', dver('chestnyj'), 0, ['лист зелёный']))
    K.append(Kletka('s03-lozhnyj-rc', dver('lozhnyj_rc'), 1, ['фактический rc=1']))
    K.append(Kletka('s04-komanda-netu', dver('komanda_netu'), 1, ['не существует']))
    K.append(Kletka('s05-karta-16', dver('karta_16'), 1, ['К-17']))
    K.append(Kletka('s06-status-vne', dver('status_vne'), 1, ['статус']))
    K.append(Kletka('s07-delta-nepolnaja', dver('delta_nepolnaja'), 1,
                    ['К-02', 'не закрыт']))
    K.append(Kletka('s08-delta-polnaja', dver('delta_polnaja'), 0, ['лист зелёный']))
    K.append(Kletka('s09-sposob-vne', dver('sposob_vne'), 1, ['способ']))
    K.append(Kletka('s10-staryj-zamorozhen', dver('staryj'), 0, ['не требуется']))
    K.append(Kletka('s11-vplus1-objazan', dver('vplus1'), 1, ['обязательна']))
    K.append(Kletka('s12-plan-vne',
                    lambda: ['bash', str(miry['plan'] / 'scripts' / 'check_sdacha.sh'),
                             str(miry['plan']), 'plans/007-toy.md', '--run'],
                    0, ['план']))
    K.append(Kletka('s13-net-git', dver('chestnyj'), 2, ['NOT_IMPLEMENTED', 'git'],
                    env={'PATH': '/nonexistent-193'}))
    K.append(Kletka('s14-tajmaut-komandy', dver('patom'), 1, ['таймаут'],
                    env={'SDACHA_TIMEOUT_SEK': '3'}))
    K.append(Kletka('s15-bjudzhet-lista', dver('budzhet'), 1, ['бюджет'],
                    env={'SDACHA_BUDZHET_SEK': '1'}))
    K.append(Kletka('s16-pustoj-listok', dver('pustoj_listok'), 1, ['без секции']))
    K.append(Kletka('s17-put-vne-kornya', dver('put_vne'), 1, ['путь листа вне грамматики']))
    K.append(Kletka('s18-stroka-vne-grammatiki', dver('stroka_vne'), 1,
                    ['вне грамматики']))
    K.append(Kletka('s19-rekursija-razorvana', dver('rekursija'), 0, ['лист зелёный'],
                    tajmaut=60))
    # К-08 Crit193V1: предыдущий вердикт — ТОЛЬКО HEAD-блоб; рабочий файл
    # вердикта скрывает блоки К-01/К-02 (закоммичены), суждение — по HEAD.
    K.append(Kletka('s20-verdikt-tolko-head', dver('delta_head'), 0, ['лист зелёный']))
    K.append(Kletka('s21-rabochij-verdikt-skryvaet-blok', dver('delta_head_nepolnaja'),
                    1, ['К-02', 'не закрыт']))
    # Arb193V1 решение 1 (К-08/К-09): индекс расходится с HEAD — staged-текст
    # не скрывает закоммиченный блок (s24) и не ломает честный лист (s25);
    # вердикта нет в HEAD — отказ и при staged-файле (s26).
    K.append(Kletka('s24-indeks-verdikt-skryvaet-blok',
                    dver('delta_index_nepolnaja'), 1, ['К-02', 'не закрыт']))
    K.append(Kletka('s25-indeks-verdikt-chestnyj', dver('delta_index_polnaja'), 0,
                    ['лист зелёный']))
    K.append(Kletka('s26-verdikt-netu-v-head-staged', dver('delta_bez_verdikta_staged'),
                    1, ['не закоммичен']))
    # К-07 Crit193V1: бюджет листа ограничивает и ВЫПОЛНЯЮЩУЮСЯ (последнюю)
    # команду; честная команда в пределах бюджета зелёная (s23).
    K.append(Kletka('s22-bjudzhet-poslednej-komandy', dver('budzhet_poslednej'), 1,
                    ['бюджет'],
                    env={'SDACHA_BUDZHET_SEK': '1', 'SDACHA_TIMEOUT_SEK': '10'}))
    K.append(Kletka('s23-bjudzhet-chestnyj-v-predelah', dver('budzhet_poslednej'), 0,
                    ['лист зелёный'],
                    env={'SDACHA_BUDZHET_SEK': '5', 'SDACHA_TIMEOUT_SEK': '10'}))
    # Rev193 Б-4: команда, переживающая TERM (SPAT_IGNOR_TERM=1), добивается
    # SIGKILL по -k — дверь завершается в пределах бюджета + KILL_SEK с
    # именованным отказом «убита SIGKILL»; дверь без -k не завершается сама —
    # клетка краснеет своим жёстким пределом (25 с), а не виснет.
    K.append(Kletka('s27-sigkill-posle-term', dver('patom'), 1, ['убита SIGKILL'],
                    env={'SDACHA_TIMEOUT_SEK': '2', 'SDACHA_BUDZHET_SEK': '4',
                         'SPAT_IGNOR_TERM': '1'}, tajmaut=25))
    # Rev193 С-1 (M01/M03/M04/M05): грамматика листа и алфавит команды.
    K.append(Kletka('s28-dubl-stroki-sdacha', dver('dubl_sdacha'), 1,
                    ['обязана быть одна']))
    K.append(Kletka('s29-zajavlennye-rc-rashodjatsja', dver('rashodka'), 1,
                    ['заявленные rc расходятся']))
    K.append(Kletka('s30-put-vne-kornja', dver('bash_put_vne'), 1, ['не существует']))
    K.append(Kletka('s31-rjad-vne-mashinnoj-sekcii', dver('vne_sekcii'), 1,
                    ['вне машинной секции']))
    # половина (б): дверь карты вердикта
    K.append(Kletka('v01-chestnyj-verdikt', karta('verdikt_chestnyj'), 0, ['17/17']))
    K.append(Kletka('v02-karta-16', karta('verdikt_karta_16'), 1, ['К-17']))
    K.append(Kletka('v03-status-vne', karta('verdikt_status_vne'), 1, ['статус']))
    K.append(Kletka('v04-pustoj-hvost', karta('verdikt_pustoj_hvost'), 1,
                    ['без команды или входа']))
    K.append(Kletka('v05-ne-zakommlchen', karta('verdikt_ne_zakommlchen'), 1,
                    ['не закоммичен']))
    K.append(Kletka('v06-dubl-klassa', karta('verdikt_dubl'), 1, ['дубль']))
    # Arb193V1 решение 1: источник карты — только HEAD-блоб. Плохой HEAD не
    # лечится рабочим файлом (v07) и индексом (v09); хороший HEAD не портится
    # их «ухудшением» (v08/v10); пути нет в HEAD — отказ и при staged (v11).
    K.append(Kletka('v07-rabochij-skryvaet-plohuju-kartu',
                    karta('verdikt_karta_rabochij'), 1, ['К-17']))
    K.append(Kletka('v08-rabochij-isportil-chestnyj',
                    karta('verdikt_karta_rabochij_chestnyj'), 0, ['17/17']))
    K.append(Kletka('v09-indeks-skryvaet-plohuju-kartu',
                    karta('verdikt_karta_index'), 1, ['К-17']))
    K.append(Kletka('v10-indeks-isportil-chestnyj',
                    karta('verdikt_karta_index_chestnyj'), 0, ['17/17']))
    K.append(Kletka('v11-staged-bez-head', karta('verdikt_staged_bez_head'), 1,
                    ['не закоммичен']))
    # Rev193 С-1 M09: путь вердикта вне verdicts/critic/ — отказ грамматики.
    K.append(Kletka('v12-put-vne-critic',
                    lambda: ['bash',
                             str(miry['verdikt_vne_critic'] / 'scripts' / 'check_verdict_karta.sh'),
                             str(miry['verdikt_vne_critic']),
                             'verdicts/other/contracts-777-v1.md'],
                    1, ['вне грамматики verdicts/critic']))
    # ── проектная ось 193↔996 (С-10/С-6, ConsKarta1118 §3б) ───────────────────
    # Прямой вызов двери на профильном пути: реальный профиль 996
    # (.harness/verdicts) и другой законный каталог (workflow/judgements),
    # HEAD accept с честной картой 17/17 — rc 0 «КАРТА: 17/17 зелёный».
    K.append(Kletka('v13-profil-996-chestnyj',
                    karta_put('profil_chestnyj', PROFIL_VERDIKT), 0, ['17/17']))
    K.append(Kletka('v14-drugoj-verdiks-katalog',
                    karta_put('profil_drugoj',
                              'workflow/judgements/critic/contracts-777-v1.md'),
                    0, ['17/17']))
    # При активном профильном каталоге честная корневая приманка verdicts/critic
    # (карта 17/17 на HEAD) не открывает дверь — корень не запасной источник.
    K.append(Kletka('v15-kornevaja-primanka',
                    karta_put('profil_primanka', VERDIKT), 1, ['вне грамматики']))
    # Чужая роль review под профильным префиксом — с честной картой 17/17.
    K.append(Kletka('v16-chuzhaja-rol-review',
                    karta_put('profil_review',
                              '.harness/verdicts/review/contracts-777-v1.md'),
                    1, ['вне грамматики']))
    # Битый профиль и симлинк-побег verdicts-каталога за ROOT: именованный
    # отказ резолвера, без fallback на корневую приманку.
    K.append(Kletka('v17-bityj-profil',
                    karta_put('profil_bityj', VERDIKT), 1, ['профиль битый']))
    K.append(Kletka('v18-simlink-pobeg-verdikts',
                    karta_put('profil_pobeg', VERDIKT), 1, ['профиль битый']))
    # HEAD-only на профильном пути: staged «починка» плохого HEAD не зелёная
    # (v19), незакоммиченное «ухудшение» честного HEAD не красная (v20),
    # отсутствующий HEAD-вердикт — отказ и при staged (v21).
    K.append(Kletka('v19-staged-pochinka-plohogo',
                    karta_put('profil_staged_pochinka', PROFIL_VERDIKT),
                    1, ['К-17']))
    K.append(Kletka('v20-rabochee-uhudshenie-chestnogo',
                    karta_put('profil_rab_uchudshenie', PROFIL_VERDIKT),
                    0, ['17/17']))
    K.append(Kletka('v21-net-v-head-staged',
                    karta_put('profil_staged_bez_head', PROFIL_VERDIKT),
                    1, ['не закоммичен']))
    # Абсолютный путь (файл существует) и путь с сегментом «..» (evil.md
    # закоммичен в корне с честной картой) не проходят грамматику.
    K.append(Kletka('v22-absoljutnyj-put',
                    karta_put('profil_chestnyj',
                              lambda: str(miry['profil_chestnyj'] / PROFIL_VERDIKT)),
                    1, ['вне грамматики']))
    K.append(Kletka('v23-tochki-za-koren',
                    karta_put('pobeg_dotdot', 'verdicts/critic/../../evil.md'),
                    1, ['вне грамматики']))
    # ноги: заморозка и pre_critic
    K.append(Kletka('f01-freeze-karta-krasna', zamorozka('freeze_karta'), 1,
                    ['карта классов вердикта']))
    K.append(Kletka('f02-freeze-staryj-bez-karty', zamorozka('freeze_staryj'), 1,
                    [], ['карта классов вердикта']))
    # К-14 Crit193V1: положительный мир ноги карты — карта зелёная, честная
    # нога пропускает заморозку дальше (отказ позже, по чужой причине —
    # spec-preflight rc 127 в toy-мире); ложный отказ ноги различается.
    K.append(Kletka('f03-freeze-noga-zelenaja', zamorozka('freeze_zelenyj'), 1,
                    ['spec-preflight'], ne_markery=['карта классов вердикта']))
    # Rev193 С-1 M12: дверь карты без lib даёт rc 2 NOT_IMPLEMENTED — честная
    # нога обязана отказать именованно («карта классов вердикта … красна»).
    K.append(Kletka('f04-karta-dver-r2', zamorozka('freeze_bez_lib'), 1,
                    ['карта классов вердикта']))
    # Проектная ось 193↔996, интеграция freeze с профильными
    # contracts/verdicts: плохая профильная карта отказывает ИМЕННО картой
    # (К-17 в первой строке отказа), честная проходит карту и доходит до
    # следующего контролируемого этапа — toy spec-preflight rc 127 (это НЕ
    # полная успешная заморозка: контракт >64 КиБ и вердикт >64 КиБ —
    # проектный длинный вход, чтобы ремонт не пропускал ногу молча).
    K.append(Kletka('f05-freeze-profil-karta-krasna',
                    zamorozka_profilnaja('freeze_profil_karta'), 1,
                    ['карта классов вердикта', 'К-17']))
    K.append(Kletka('f06-freeze-profil-noga-zelenaja',
                    zamorozka_profilnaja('freeze_profil_zelenyj'), 1,
                    ['spec-preflight'], ne_markery=['карта классов вердикта']))
    # И8-атомарность на профильном мире: после отказа картой нет ни тега
    # frozen/*, ни записи реестра .harness/ledger/contracts.tsv (мир тот же,
    # что у f05 — клетки идут по порядку, мир кэшируется).
    K.append(Kletka('f07-freeze-profil-bez-tega',
                    lambda: ['bash', '-c',
                             '_t="$(git -C "$1" tag --list "frozen/*")"; '
                             '[ -z "$_t" ] && [ ! -e "$2" ]',
                             'f07-193',
                             str(miry['freeze_profil_karta']),
                             str(miry['freeze_profil_karta']
                                 / '.harness/ledger/contracts.tsv')],
                    0))
    # p01 моделирует ПРЯМОЙ вызов pre_critic оркестратором (маркер рекурсии
    # погашен явно): внутри прогона двери листа маркер наследуется — и нога (к)
    # по канону И6 молчит; прямому вызову маркер не положен.
    K.append(Kletka('p01-noga-sdacha-krasna',
                    lambda: ['bash',
                             str(miry['noga_krasna'] / 'scripts' / 'pre_critic.sh'),
                             KONTRAKT], 1, ['ОТКАЗ: сдаточный лист красен'],
                    env={'SDACHA_OKRUG': '0'}))
    K.append(Kletka('p02-noga-propuskaet-chuzhoj-mir',
                    lambda: ['bash',
                             str(miry['rekursija'] / 'scripts' / 'pre_critic.sh'),
                             '--repo', str(miry['repo_bez_dveri']), KONTRAKT], 0,
                    ['КРИТИК: дверь зелёная']))
    # К-14 Crit193V1: положительный мир ноги (к) — честный лист, вооружённая
    # зелёная дверь, прямой вызов (маркер погашен): нога обязана пропустить.
    K.append(Kletka('p03-noga-listok-zelenyj',
                    lambda: ['bash',
                             str(miry['rekursija'] / 'scripts' / 'pre_critic.sh'),
                             KONTRAKT], 0, ['КРИТИК: дверь зелёная'],
                    env={'SDACHA_OKRUG': '0'}))
    # Rev193 С-1 M14: нецелые швы двери (SDACHA_TIMEOUT_SEK=abc) дают rc 2
    # NOT_IMPLEMENTED — честная нога отказывает на ЛЮБОМ rc≠0 (И6), мутант
    # «отказ только на rc 1» пропускает rc 2 молча.
    K.append(Kletka('p04-noga-dver-r2',
                    lambda: ['bash',
                             str(miry['noga_krasna'] / 'scripts' / 'pre_critic.sh'),
                             KONTRAKT], 1, ['сдаточный лист красен'],
                    env={'SDACHA_OKRUG': '0', 'SDACHA_TIMEOUT_SEK': 'abc'}))
    K.extend(kletki_ssylok(miry))
    return K


def sudit(k: Kletka) -> bool:
    env = dict(os.environ)
    # гигиена среды: маркер внутреннего прогона двери листа не протекает в
    # клетки — батарея, вызванная КАК команда листа (SDACHA_OKRUG=1 снаружи),
    # судит клетки в их собственных состояниях (иначе обманки рекурсии и
    # ноги (к) маскируются чужим маркером — измерено на door-check fix2)
    env.pop('SDACHA_OKRUG', None)
    # проектная ось 996: унаследованный HARNESS_PROJECT_LAYER_ROOT направил бы
    # резолвер мира на чужой слой проекта (workshop экспортирует слой станции
    # — измерено: заморозка мира тогда отказывает «нет файла слоя проекта»);
    # HARNESS_WORKFLOW_ROOT — та же гигиена для $3-лестницы freeze. Клетки
    # судятся в собственных состояниях мира, как в CI с чистой средой.
    env.pop('HARNESS_PROJECT_LAYER_ROOT', None)
    env.pop('HARNESS_WORKFLOW_ROOT', None)
    argv = k.argv() if callable(k.argv) else list(k.argv)
    if k.env and 'PATH' in k.env and argv[0] == 'bash':
        argv[0] = shutil.which('bash') or '/bin/bash'
    if k.env:
        env.update(k.env)
    try:
        p = subprocess.Popen(argv, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                             text=True, env=env, start_new_session=True)
        try:
            out, err = p.communicate(timeout=k.tajmaut)
            rc, vyvod = p.returncode, out + err
        except subprocess.TimeoutExpired:
            os.killpg(os.getpgid(p.pid), signal.SIGKILL)
            p.communicate()
            rc, vyvod = None, 'TIMEOUT'
    except FileNotFoundError:
        rc, vyvod = None, 'SUBJECT_ABSENT'
    ok = (rc == k.rc
          and all(m in vyvod for m in k.markery)
          and all(m not in vyvod for m in k.ne_markery)
          and (k.posle is None or k.posle()))
    pervyj = (vyvod.strip().splitlines() or ['<пусто>'])[0]
    print('193 %s %s rc=%s %s' % (k.imja, 'ok' if ok else 'KRASNO', rc, pervyj[:110]))
    return ok


def predposylki() -> None:
    for instrument in ('python3', 'git', 'bash'):
        r = subprocess.run(['bash', '-c', 'command -v %s' % instrument],
                           capture_output=True, text=True)
        if r.returncode != 0:
            print('LIVE_PREDPOSYLKA: нет %s — нечем исполнять батарею 193 '
                  '(чистый клон без зависимостей — именованный отказ, не '
                  'skip→pass)' % instrument, file=sys.stderr)
            sys.exit(2)


def rezhim_suda(miry: Miry) -> int:
    K = kletki(miry)
    zel = sum(1 for k in K if sudit(k))
    kras = len(K) - zel
    print('ИТОГ 193: rc=%d KLETKI=%d ZELENYE=%d KRASNYE=%d'
          % (0 if kras == 0 else 1, len(K), zel, kras))
    return 0 if kras == 0 else 1


def rezhim_stabs(vrem: Path) -> int:
    svjazi = []
    for line in (HERE / 'stabs.tsv').read_text(encoding='utf-8').splitlines():
        if not line.strip() or line.lstrip().startswith('#'):
            continue
        cols = line.split('\t')
        if len(cols) != 3:
            print('ORACLE_TAMPERED: строка привязки вне грамматики: %r' % line,
                  file=sys.stderr)
            return 2
        svjazi.append(cols)
    poimano, zhivyh = 0, 0
    for imja, fail, kletka_imja in svjazi:
        dver_zamena = karta_zamena = lib_zamena = None
        dver_mut = karta_mut = lib_mut = pre_mut = freeze_mut = None
        if imja.startswith('PATERN:'):
            if fail == 'scripts/pre_critic.sh':
                pre_mut = imja
            elif fail == 'scripts/freeze_contract.sh':
                freeze_mut = imja
            elif fail == 'scripts/check_sdacha.sh':
                dver_mut = imja
            elif fail == 'scripts/check_verdict_karta.sh':
                karta_mut = imja
            elif fail == 'scripts/lib_karta_sdachi.sh':
                lib_mut = imja
            else:
                print('ORACLE_TAMPERED: PATERN вне алфавита субъектов: %s' % fail,
                      file=sys.stderr)
                return 2
        else:
            put = STABS / imja
            if fail == 'scripts/check_sdacha.sh':
                dver_zamena = put
            elif fail == 'scripts/check_verdict_karta.sh':
                karta_zamena = put
            elif fail == 'scripts/lib_karta_sdachi.sh':
                lib_zamena = put
            else:
                print('ORACLE_TAMPERED: заменяемый файл вне алфавита: %s' % fail,
                      file=sys.stderr)
                return 2
        ist = Istochniki(MODEL, dver_zamena=dver_zamena, karta_zamena=karta_zamena,
                         lib_zamena=lib_zamena, dver_mutacija=dver_mut,
                         karta_mutacija=karta_mut, lib_mutacija=lib_mut,
                         pre_mutacija=pre_mut, freeze_mutacija=freeze_mut,
                         dostroat_nogi=True)
        try:
            miry = Miry(vrem / ('obmanka-' + imja.replace(':', '_')), ist)
            K = kletki(miry)
            kletka = next((k for k in K if k.imja.startswith(kletka_imja + '-')), None)
            if kletka is None:
                print('ORACLE_TAMPERED: клетка привязки не найдена: %s' % kletka_imja,
                      file=sys.stderr)
                return 2
            ulov = not sudit(kletka)  # обманка НЕ удовлетворяет ожиданию клетки
        except RuntimeError as e:
            # применённость мутации проверена якорем: нулевая замена — не поимка
            print('ORACLE_TAMPERED: мутация не применена: %s' % e, file=sys.stderr)
            return 2
        if ulov:
            poimano += 1
        else:
            zhivyh += 1
        print('193 %s %s' % (imja, 'POIMAN' if ulov else 'ZHIV — дефект не различим'))
    print('ИТОГ 193: rc=%d OBMANOK=%d POIMANY=%d ZHIVYH=%d'
          % (0 if zhivyh == 0 else 1, len(svjazi), poimano, zhivyh))
    return 0 if zhivyh == 0 else 1


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument('--repo', default=None)
    parser.add_argument('--model', action='store_true')
    parser.add_argument('--stabs', action='store_true')
    args = parser.parse_args()
    predposylki()
    vrem = Path(tempfile.mkdtemp(prefix='batareja-193-'))
    rc = 1
    try:
        if args.stabs:
            rc = rezhim_stabs(vrem)
        elif args.model:
            rc = rezhim_suda(Miry(vrem, Istochniki(MODEL, dostroat_nogi=True)))
        else:
            koren = Path(args.repo).resolve() if args.repo else DEREVO.resolve()
            rc = rezhim_suda(Miry(vrem, Istochniki(koren)))
    finally:
        shutil.rmtree(vrem, ignore_errors=True)
    return rc


if __name__ == '__main__':
    sys.exit(main())
