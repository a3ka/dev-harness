# s05 — обман: expo судит всё по имени без токенов argv — run:android и
# prebuild проходят. Наблюдаем: a09 (отказ по токенам).
IMJA = 's05-expo-bez-tokenov'
ZAMENA = [
    (('dvojniki', '_jadro.sh'),
     ('    if [ "$a" = "run:android" ] || [ "$a" = "prebuild" ]; then',
      '    if false; then')),
]
