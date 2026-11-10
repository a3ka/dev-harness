#!/usr/bin/env python3
"""Мутатор набора ekrannyj_nabor_158: клетка f39-nadpis-null-u-nevidimogo-text —
у вкладки shell-tab-start надпись «Start» СКРЫТА (opacity:0, обход Z7), а её
хозяин получает доступное имя «Start» — ровно то, что объявляет карта
(вид «иконка»). Остальные вкладки и их надписи не меняются.

РОВНО ОДНА замена (якорь count==1) в одноразовой копии референса: якорь —
блок вкладки от testID до строки opacity надписи; замена вносит ДВА
изменения этого блока (имя хозяина + невидимая надпись своей вкладки).
CLI: <имя>.py <корень-копии-референса>
Код возврата 0 — замена применена; 2 — якорь не найден ровно один раз
(мутатор не применён)."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _mutator import primenit  # noqa: E402

FAJL = 'mobile/src/bootstrap/tab-shell.tsx'

YAKOR = (
    "              testID={`shell-tab-${id}`}\n"
    "            >\n"
    "              <View style={{ opacity: active ? 1 : INACTIVE_OPACITY }}>\n"
    "                <TabIcon active={active} color={tokens.ink} id={id} "
    "size={ab.w(NAV.icon)} />\n"
    "              </View>\n"
    "              <Text\n"
    "                style={[\n"
    "                  styles.tabLabel,\n"
    "                  {\n"
    "                    color: tokens.ink,\n"
    "                    fontSize: ab.w(NAV.label.fontSize),\n"
    "                    lineHeight: ab.y(NAV.label.lineHeight),\n"
    "                    marginTop: ab.y(2),\n"
    "                    opacity: active ? 1 : INACTIVE_OPACITY,\n"
)

ZAMENA = (
    "              accessibilityLabel={id === 'start' ? 'Start' : undefined}\n"
    "              testID={`shell-tab-${id}`}\n"
    "            >\n"
    "              <View style={{ opacity: active ? 1 : INACTIVE_OPACITY }}>\n"
    "                <TabIcon active={active} color={tokens.ink} id={id} "
    "size={ab.w(NAV.icon)} />\n"
    "              </View>\n"
    "              <Text\n"
    "                style={[\n"
    "                  styles.tabLabel,\n"
    "                  {\n"
    "                    color: tokens.ink,\n"
    "                    fontSize: ab.w(NAV.label.fontSize),\n"
    "                    lineHeight: ab.y(NAV.label.lineHeight),\n"
    "                    marginTop: ab.y(2),\n"
    "                    opacity: id === 'start' ? 0 : "
    "(active ? 1 : INACTIVE_OPACITY),\n"
)

if __name__ == '__main__':
    sys.exit(primenit(sys.argv[1], FAJL, YAKOR, ZAMENA))
