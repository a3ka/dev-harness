"""Toy-заглушка lane-файла мини-мира 121 (образ tests/tools/run_backend_ci.py).

Мини-мир той же раскладки, что продукт: lane-файл обязан содержать литерал
test:core — проводка ядра 001–004 в CI продукта (контракт 121).
"""
LANES = {
    'postgres': [
        ('runtime', 'test:core: ядро 001–004 на native PG18', ['npm', 'run', '-s', 'test:core']),
    ],
}
