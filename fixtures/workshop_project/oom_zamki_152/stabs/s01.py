# s01 — обман: ветка scope-запрета отключена целиком (всё проходит).
# Наблюдаем: клетки A-блока (входы со scope-маркером обязаны отказать).
# Вне scope стаб честен (счётчик не тронут) — потому привязки только A.
IMJA = 's01-dvojnik-propuskaet-vse'
ZAMENA = [
    (('dvojniki', '_jadro.sh'),
     ('if [ "$v_scope" = "1" ] && [ "$zapret" = "1" ]; then',
      'if false && [ "$v_scope" = "1" ] && [ "$zapret" = "1" ]; then')),
]
