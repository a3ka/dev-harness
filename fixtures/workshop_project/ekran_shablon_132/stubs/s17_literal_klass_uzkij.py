"""Стаб s17 (literal-klass-uzkij): литералы судятся перечнем частных
образцов (hex/rgb()/rgba()/hsl()/hsla(); px/pt/sp/dp/rem/em/vw/vh) —
hwb()/проценты/ch и прочие представители КЛАССА проходят (обход круга 2)."""
import re

from _model import m, run

m.RE_CVET = re.compile(r'#[0-9a-fA-F]{3,8}\b|(?:rgb|rgba|hsl|hsla)\([0-9, .%]*\)')
m.RE_RAZMER = re.compile(r'\b[0-9]+(?:\.[0-9]+)?(?:px|pt|sp|dp|rem|em|vw|vh)\b')
run()
