#!/usr/bin/env python3
# Обманный стаб батареи 143 (Н-39: мутация модели КОДОМ; дефект наблюдаем на
# привязанных входах). argv[1] — каталог копии модели.
import sys
from pathlib import Path
d = Path(sys.argv[1])

p = d / "mobile/scripts/ci-aggregate.cjs"
s = p.read_text(encoding="utf-8")
staryj = '  if (o.apk_sha256 !== apkSha) otkaz("APK_DIGEST_RASKHOZHDENIE", `${j}: ${o.apk_sha256 || "нет"} ≠ ${apkSha}`);'
novyj = '  // digest не сверяется'
if staryj not in s:
    print("MUTACIJA_NE_NAIDENA", file=sys.stderr)
    sys.exit(1)
s = s.replace(staryj, novyj, 1)
staryj = '  if (o.artifact_name !== artefakt) otkaz("CHUZHOJ_ARTEFAKT", `${j}: ${o.artifact_name || "нет"} ≠ ${artefakt}`);'
novyj = '  // артефакт не сверяется'
if staryj not in s:
    print("MUTACIJA_NE_NAIDENA", file=sys.stderr)
    sys.exit(1)
s = s.replace(staryj, novyj, 1)
staryj = '  if (o.run_id !== runId) otkaz("STARYJ_ARTEFAKT", `${j}: run ${o.run_id || "нет"} ≠ ${runId}`);'
novyj = '  // run-identity не сверяется'
if staryj not in s:
    print("MUTACIJA_NE_NAIDENA", file=sys.stderr)
    sys.exit(1)
s = s.replace(staryj, novyj, 1)
p.write_text(s, encoding="utf-8")
