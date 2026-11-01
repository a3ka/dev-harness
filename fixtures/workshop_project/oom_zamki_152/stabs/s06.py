# s06 — обман: дверь замка не знает факта гибели (якорь session_exit
# сломан в обеих ветвях stare_holder) — погибшие держат замок как раньше.
# Наблюдаем: c01/c02/c03 (снятие), c07 (учёт), c08 (авто-снятие автора),
# c09 (гонка авто-снятия). Живой (c05) и тишина (c06) у стаба честны.
IMJA = 's06-zamok-bez-pogib'
ZAMENA = [
    ('zamok',
     ('if grep -Fq \'"customType":"session_exit"\' "$jf"; then printf \'pogib\'; return 0; fi',
      'if grep -Fq \'"customType":"session_exitX"\' "$jf"; then printf \'pogib\'; return 0; fi')),
    ('zamok',
     ('if [ -f "$roditel" ] && grep -Fq \'"customType":"session_exit"\' "$roditel"; then',
      'if false && [ -f "$roditel" ] && grep -Fq \'"customType":"session_exit"\' "$roditel"; then')),
]
