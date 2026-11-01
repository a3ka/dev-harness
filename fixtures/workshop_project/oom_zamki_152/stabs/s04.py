# s04 — обман: счётчик всегда «переполнен» — честные запуски вне scope
# отказывают. Наблюдаем: b01 (ноль живых — запуск обязан пройти) и
# b03 (один живой — граница предела).
IMJA = 's04-schetchik-vsegda-perepolnen'
ZAMENA = [
    (('dvojniki', '_jadro.sh'),
     ('n="$(pgrep -f \'[q]emu-system\' 2>/dev/null | grep -vFx "$$" | wc -l | tr -d \' \')"',
      'n=99')),
]
