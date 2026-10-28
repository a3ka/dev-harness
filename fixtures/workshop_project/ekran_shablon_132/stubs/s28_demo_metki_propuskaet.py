"""Стаб s28 (demo-bez-metki/demo-v-sostave/demo-bez-otdelenija): метки и
отделение демо не проверяются — демо-переключатель без demo:true, демо в
составе продукта и демо без отделения проходят."""
from _model import m, run

_bez = m.check_prokhodimost
_BEZ = {'DEMO_NE_OTMECHEN', 'DEMO_V_SOSTAVE', 'DEMO_BEZ_OTDELENIJA'}


def _check_prokhodimost_bez_demo(f, kadry):
    return [o for o in _bez(f, kadry) if o.split('\t')[1] not in _BEZ]


m.check_prokhodimost = _check_prokhodimost_bez_demo
run()
