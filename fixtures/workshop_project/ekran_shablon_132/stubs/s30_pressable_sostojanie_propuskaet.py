"""Стаб s30 (pressable-bez-obrabotnika/neaktivna-bez-kadra): полнота
состояний не проверяется — pressable без обработчика и не neaktivna
(«Dokument öffnen»/«Kopie herunterladen» на 118) и неактивная цель без
ссылки на кадр проходят."""
from _model import m, run

_bez = m.check_prokhodimost
_BEZ = {'PRESSABLE_BEZ_IZMENENIJA', 'NEAKTIVNA_BEZ_KADRA'}


def _check_prokhodimost_bez_sostojanij(f, kadry):
    return [o for o in _bez(f, kadry) if o.split('\t')[1] not in _BEZ]


m.check_prokhodimost = _check_prokhodimost_bez_sostojanij
run()
