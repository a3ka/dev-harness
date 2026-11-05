#!/usr/bin/env python3
"""Мутатор набора ekrannyj_nabor_158: клетка f21-tsel-za-klipom — вне клипа overflow:'hidden' предка (класс 13).

РОВНО ОДНА замена (якорь count==1) в одноразовой копии референса.
CLI: <имя>.py <корень-копии-референса>. Код возврата 0 — замена применена;
2 — якорь не найден ровно один раз (мутатор не применён)."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _mutator import primenit  # noqa: E402

FAJL = 'mobile/src/bootstrap/tab-shell.tsx'
YAKOR = '              <Pressable testID="gespraech-mitte"\n                onPress={() => setMenu(\'open\')}\n                onLongPress={() => onCommandRef.current?.({ kind: \'voice\' })}\n                delayLongPress={Number(MOTION_TOKENS[\'press-long\'].replace(\'ms\', \'\'))}\n                style={styles.ziel}><Text>Gespräch</Text></Pressable>'
ZAMENA = '              <View style={{ overflow: \'hidden\', width: 100, height: 44 }}>\n              <Pressable testID="gespraech-mitte"\n                onPress={() => setMenu(\'open\')}\n                onLongPress={() => onCommandRef.current?.({ kind: \'voice\' })}\n                delayLongPress={Number(MOTION_TOKENS[\'press-long\'].replace(\'ms\', \'\'))}\n                style={[styles.ziel, { position: \'absolute\', left: 200 }]}><Text>Gespräch</Text></Pressable>\n              </View>'

if __name__ == '__main__':
    sys.exit(primenit(sys.argv[1], FAJL, YAKOR, ZAMENA))
