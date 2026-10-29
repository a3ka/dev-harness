#!/usr/bin/env python3
"""Стаб 145: инстанс расходится с референсом только при dt ∉ {0, DT}.

Все входы батареи до p15 шагают инстанс либо ровно по сетке DT = 1000/60
(реплей сцен, прогрев, p12/p13/d02/d03), либо с dt = 0 (несколько set() в
одном кадре). Мутация подмешивает дрейф smoothAmp только на «несетковых»
шагах — покадровый реплей и сетки её НЕ видят. Дефект наблюдаем ТОЛЬКО на
сеяных инстанс-скриптах клетки p15 (кадры идут случайными dt с тремя
десятичными — никогда не DT и не 0): привязка Н-39 к p15."""
import sys, pathlib
cel = pathlib.Path(sys.argv[1])
p = cel / 'faden-motion.js'
t = p.read_text(encoding='utf-8')
jakor = "      var dt = Math.min(64, now - last); last = now;"
zamena = ("      var dt = Math.min(64, now - last); "
          "if (dt !== 0 && Math.abs(dt - 1000 / 60) > 1e-9) smoothAmp += 0.05; "
          "last = now;")
if jakor not in t:
    print('jakor ne najden: step(dt) v mount', file=sys.stderr); sys.exit(1)
p.write_text(t.replace(jakor, zamena, 1), encoding='utf-8')
