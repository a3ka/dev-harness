#!/usr/bin/env python3
"""Стаб: слово-форма вызова= в HANDOFF теряется молча — предмет без вердиктов
и агентов выпадает из таблицы целиком (инвариант 1: неузнаваемая форма обязана
давать не-установлен, а не потерю). Дефект наблюдаем на мире D: предмет 304,
чьья единственная СУД-строка — слово-форма в HANDOFF."""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'model'))
import zamer_model as M

M.handoff_unparsed = lambda repo: set()  # дефект: именованная потеря исчезает
sys.exit(M.main(sys.argv[1:]))
