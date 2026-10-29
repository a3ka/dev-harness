#!/usr/bin/env python3
"""Стаб 145: pose() расходится с референсом ВНЕ сетки — обход критика 1/2.

Форма дословная: единственная точка t = 3624.158 мс (НЕ сетка 60 fps, НЕ
кейфрейм, НЕ таблица) получает R + 5; все пиннованные входы честны. t —
ПЕРВЫЙ сеяный сэмпл клетки p14 (mulberry32, seed 145 — дефолт раннера:
t₀ = round(rnd()*6000000)/1000), т.е. дефект НАБЛЮДАМ ровно на входе,
который судит p14 (Н-39). Ожидание p14 вычисляет референс в памяти ДО
субъекта — «таблица под клетку» здесь не работает. Ловится ИМЕННО клеткой
p14-pose-sejanye-vhody (сетка 60 fps / p01 / кейфреймы эту точку не
содержат). Остаток «порт, знающий seed» — класс B4: ловится перезапуском
раннера с иным --seed (право судьи), принят владельцем 2026-10-28."""
import sys, pathlib
cel = pathlib.Path(sys.argv[1])
p = cel / 'faden-motion.js'
t = p.read_text(encoding='utf-8')
jakor = "pose: pose, path: path, svg: svg"
zamena = ("pose: function (state, o) { var p = pose(state, o); "
          "if (o && o.t === 3624.158) { p = Object.assign({}, p); p.R = p.R + 5; } "
          "return p; }, path: path, svg: svg")
if jakor not in t:
    print('jakor ne najden: eksport pose v CompliorFaden', file=sys.stderr); sys.exit(1)
p.write_text(t.replace(jakor, zamena, 1), encoding='utf-8')
