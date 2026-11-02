#!/usr/bin/env bash
# Стаб jest-zelenyj (клетка s-ekran-ispolnim, цикл 2 Crit147k2b;
# прецедент 148/149): фиктивная jest-среда с ЗАШИТЫМ ЗЕЛЁНЫМ итогом —
# и контроль, и ЛЮБОЙ мутант батареи проходят (success true). Настоящий
# судья обязан убить каждого мутанта УПАВШИМ АССЕРТОМ: мутант tab-zona-20
# (Pressable вкладки 20×20) и press-long-900 (токен 900 вместо 500)
# краснеют на РЕАЛЬНОМ зонде; судья, всегда пишущий «зелено», —
# ISPOLNIMYJ_MUTANT_ZHIV, вход не замечен — STAB_ZHIV rc 1 (Н-39).
set -u
cat <<'JSON'
{"numFailedTestSuites":0,"numFailedTests":0,"numPassedTestSuites":1,"numPassedTests":3,"numPendingTests":0,"numRuntimeErrorTestSuites":0,"numTodoTests":0,"numTotalTestSuites":1,"numTotalTests":3,"success":true,"testResults":[{"assertionResults":[{"ancestorTitles":["gespraech-vhod"],"failureMessages":[],"status":"passed","title":"zond-kontrol-zony"},{"ancestorTitles":["gespraech-vhod"],"failureMessages":[],"status":"passed","title":"zond-kontrol-token"},{"ancestorTitles":["gespraech-vhod"],"failureMessages":[],"status":"passed","title":"zond-mutant"}],"endTime":0,"message":"","name":"gespraech-vhod-zond","startTime":0,"status":"passed","summary":""}],"wasInterrupted":false}
JSON
exit 0
