#!/usr/bin/env python3
"""Мутатор набора ekrannyj_nabor_158: клетка f12-zona-rebenok-44 — Pressable 20×20, testID и 44-бокс на дочернем Text (класс 12-уточнение).

РОВНО ОДНА замена (якорь count==1) в одноразовой копии референса.
CLI: <имя>.py <корень-копии-референса>. Код возврата 0 — замена применена;
2 — якорь не найден ровно один раз (мутатор не применён)."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _mutator import primenit  # noqa: E402

FAJL = 'mobile/src/bootstrap/tab-shell.tsx'
YAKOR = '              <Pressable testID="gespraech-mitte"\n                onPress={() => setMenu(\'open\')}\n                onLongPress={() => onCommandRef.current?.({ kind: \'voice\' })}\n                delayLongPress={Number(MOTION_TOKENS[\'press-long\'].replace(\'ms\', \'\'))}\n                style={styles.ziel}><Text>Gespräch</Text></Pressable>'
ZAMENA = '              <Pressable\n                onPress={() => setMenu(\'open\')}\n                onLongPress={() => onCommandRef.current?.({ kind: \'voice\' })}\n                delayLongPress={Number(MOTION_TOKENS[\'press-long\'].replace(\'ms\', \'\'))}\n                style={{ width: 20, height: 20 }}><Text testID="gespraech-mitte" style={{ width: 44, height: 44 }}>Gespräch</Text></Pressable>'

if __name__ == '__main__':
    sys.exit(primenit(sys.argv[1], FAJL, YAKOR, ZAMENA))
