#!/usr/bin/env python3
"""Мутатор набора ekrannyj_nabor_158: клетка f22-tsel-perekryta — перекрыта непрозрачным абсолютным братом (класс 13).

РОВНО ОДНА замена (якорь count==1) в одноразовой копии референса.
CLI: <имя>.py <корень-копии-референса>. Код возврата 0 — замена применена;
2 — якорь не найден ровно один раз (мутатор не применён)."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _mutator import primenit  # noqa: E402

FAJL = 'mobile/src/bootstrap/tab-shell.tsx'
YAKOR = '              <Pressable testID="gespraech-mitte"\n                onPress={() => setMenu(\'open\')}\n                onLongPress={() => onCommandRef.current?.({ kind: \'voice\' })}\n                delayLongPress={Number(MOTION_TOKENS[\'press-long\'].replace(\'ms\', \'\'))}\n                style={styles.ziel}><Text>Gespräch</Text></Pressable>'
ZAMENA = '              <Pressable testID="gespraech-mitte"\n                onPress={() => setMenu(\'open\')}\n                onLongPress={() => onCommandRef.current?.({ kind: \'voice\' })}\n                delayLongPress={Number(MOTION_TOKENS[\'press-long\'].replace(\'ms\', \'\'))}\n                style={styles.ziel}><Text>Gespräch</Text></Pressable>\n              <View style={{ position: \'absolute\', top: 0, left: 0, right: 0, bottom: 0, backgroundColor: \'#000000\' }} />'

if __name__ == '__main__':
    sys.exit(primenit(sys.argv[1], FAJL, YAKOR, ZAMENA))
