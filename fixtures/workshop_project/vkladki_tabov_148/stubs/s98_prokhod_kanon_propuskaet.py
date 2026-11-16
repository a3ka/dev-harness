"""Стаб s98 (prokhod-kanon): канонические цели лейсте (testID 999 +
gespraech-mitte) не судятся — флоу без нажатия Mitte проходит
незамеченным (И-6/SPEC §4 v5; контент-имена не пинируются)."""
from _produkt import m, run

m.PROKHOD_ID_KANON = []
run()
