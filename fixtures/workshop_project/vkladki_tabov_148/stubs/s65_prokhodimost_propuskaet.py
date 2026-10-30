"""Стаб s65 (prokhodimost): блок проходимости не судится — цели
<44pt, safe-zone, метки demo и повтор id проходят незамеченными."""
from _model import m, run

m.check_prokhodimost = lambda f, kadry: []
run()
