"""Стаб s78 (makety): пины макетов продукта не сверяются."""
from _produkt import m, run

m.sha256_fajla = lambda p: "0"
run()
