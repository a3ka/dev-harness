# s03 — обман: счётчик эмуляторов всегда ноль — третий эмулятор проходит.
# Наблюдаем: b02 (два живых, третий обязан отказать). В scope честен.
IMJA = 's03-schetchik-vsegda-nol'
ZAMENA = [
    (('dvojniki', '_jadro.sh'),
     ('n="$(pgrep -f \'[q]emu-system\' 2>/dev/null | grep -vFx "$$" | wc -l | tr -d \' \')"',
      'n=0')),
]
