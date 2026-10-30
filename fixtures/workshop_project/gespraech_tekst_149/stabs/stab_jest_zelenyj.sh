#!/usr/bin/env bash
# Стаб jest-zelenyj (клетка s-ekran-ispolnim, блок 1 Crit149b): фиктивная
# jest-среда с ЗАШИТЫМ ЗЕЛЁНЫМ итогом — всякий прогон «проходит» (rc 0,
# JSON: success/numPassed == numTotal > 0, все ассерты passed). Под
# мутантом «пустой хост» такой jest всё равно зелён — клетка обязана
# отказать ISPOLNIMYJ_MUTANT_ZHIV; судья, пропускающий зелёный итог без
# убийства мутантов, оставил бы вход незаметным — STAB_ZHIV rc 1 (Н-39).
# Формат — итог jest --json (потребитель — klassifikirovat produkt_sud).
set -u
cat <<'JSON'
{"numFailedTestSuites":0,"numFailedTests":0,"numPassedTestSuites":1,"numPassedTests":10,"numPendingTests":0,"numRuntimeErrorTestSuites":0,"numTodoTests":0,"numTotalTestSuites":1,"numTotalTests":10,"success":true,"testResults":[{"assertionResults":[{"ancestorTitles":["gespraech-tekst-chat"],"failureMessages":[],"status":"passed","title":"zond"}],"endTime":0,"message":"","name":"gespraech-zond","startTime":0,"status":"passed","summary":""}],"wasInterrupted":false}
JSON
exit 0
