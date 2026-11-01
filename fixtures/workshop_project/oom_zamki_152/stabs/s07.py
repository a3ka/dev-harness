# s07 — обман: приоритет yield сломан — сдавший (yield + session_exit)
# считается погибшим. Наблюдаем: c04 (prichina=yield у --osvobodit).
IMJA = 's07-yield-ne-prioriten'
ZAMENA = [
    ('zamok',
     ('if grep -Fq \'"toolName":"yield"\' "$jf"; then printf \'yield\'; return 0; fi',
      'if false && grep -Fq \'"toolName":"yield"\' "$jf"; then printf \'yield\'; return 0; fi')),
]
