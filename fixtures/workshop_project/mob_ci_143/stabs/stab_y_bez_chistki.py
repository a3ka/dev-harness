#!/usr/bin/env python3
# Обманный стаб батареи 143 (Н-39, Fix143c): первому checkout build-apk
# выставлен clean: false — остатки прежнего дерева (сборки чужой ревизии
# на переиспользуемом self-hosted раннере) выживают и подмешиваются в
# сборку; ref/порядок/сверка честны. Критик Crit143x подтверждал красноту
# вручную (CASE=unclean-tree) — здесь мутация посеяна в батарею.
# Наблюдаем на входе y19-outputs-provodka: checkout без clean: true.
# argv[1] — каталог копии модели.
import sys
from pathlib import Path

d = Path(sys.argv[1])
p = d / ".github/workflows/mobile.yml"
s = p.read_text(encoding="utf-8")
blok = ("      # persist-credentials: false — токен не остаётся на диске.\n"
        "      - uses: actions/checkout@v7\n"
        "        with:\n"
        "          persist-credentials: false\n"
        "          clean: true\n")
if blok not in s:
    print("MUTACIJA_NE_NAIDENA: блок checkout build-apk не найден", file=sys.stderr)
    sys.exit(1)
s = s.replace(blok,
              "      # persist-credentials: false — токен не остаётся на диске.\n"
              "      - uses: actions/checkout@v7\n"
              "        with:\n"
              "          persist-credentials: false\n"
              "          clean: false\n", 1)
p.write_text(s, encoding="utf-8")
