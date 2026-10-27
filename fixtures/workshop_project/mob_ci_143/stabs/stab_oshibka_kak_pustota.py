#!/usr/bin/env python3
# Обманный стаб батареи 143 (Н-39: мутация модели КОДОМ; дефект наблюдаем на
# привязанных входах). argv[1] — каталог копии модели.
import sys
from pathlib import Path
d = Path(sys.argv[1])

p = d / "mobile/scripts/select-ci-screens.cjs"
s = p.read_text(encoding="utf-8")
staryj = '  } catch (e) { return { net: true, prichina: "NET_BAZY" }; }'
novyj = '  } catch (e) { return { z: Buffer.alloc(0) }; }'
if staryj not in s:
    print("MUTACIJA_NE_NAIDENA", file=sys.stderr)
    sys.exit(1)
s = s.replace(staryj, novyj, 1)
staryj = '  } catch (e) { return { net: true, prichina: "OSIBKA_DIFFA" }; }'
novyj = '  } catch (e) { return { z: Buffer.alloc(0) }; }'
if staryj not in s:
    print("MUTACIJA_NE_NAIDENA", file=sys.stderr)
    sys.exit(1)
s = s.replace(staryj, novyj, 1)
p.write_text(s, encoding="utf-8")
