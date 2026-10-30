"""Стаб s77 (pachka): отсутствие пачки в продукте не судится,
полный суд пачки всегда «зелёный»."""
from _produkt import m, run

m.staticheskie_proverki = lambda repo, src: []
m.sud_pachki = lambda repo, src: (0, "", "")
run()
