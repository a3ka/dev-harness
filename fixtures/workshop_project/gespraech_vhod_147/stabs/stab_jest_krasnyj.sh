#!/usr/bin/env bash
# Стаб jest-krasnyj (клетка s-ekran-ispolnim, цикл 2 Crit147k2b;
# прецедент 148/149): фиктивная jest-среда с ЗАШИТЫМ КРАСНЫМ итогом —
# контрольный прогон зонда падает УПАВШИМ АССЕРТОМ (rc 1, JSON: success
# false, assertionResults со status failed — реальная зона касания/токен
# press-long не соответствуют пачке). Клетка обязана отказать
# ISPOLNIMYJ_KONTROL_KRASEN на исходных компонентах дерева; судья,
# засчитывающий красный контроль зелёным (или превращающий его в
# пропуск), оставил бы вход незаметным — STAB_ZHIV rc 1 (Н-39;
# прецедент proba_live_put 145: падение загрузки и провал ассертов
# различаются — здесь провал именно АССЕРТОВ).
set -u
cat <<'JSON'
{"numFailedTestSuites":1,"numFailedTests":2,"numPassedTestSuites":0,"numPassedTests":0,"numPendingTests":0,"numRuntimeErrorTestSuites":0,"numTodoTests":0,"numTotalTestSuites":1,"numTotalTests":3,"success":false,"testResults":[{"assertionResults":[{"ancestorTitles":["gespraech-vhod"],"failureMessages":["Expected zone to be at least touch-target.min"],"status":"failed","title":"zond-kontrol-zony"},{"ancestorTitles":["gespraech-vhod"],"failureMessages":["Expected token to be 500, received 900"],"status":"failed","title":"zond-kontrol-token"}],"endTime":0,"message":"","name":"gespraech-vhod-zond","startTime":0,"status":"failed","summary":""}],"wasInterrupted":false}
JSON
exit 1
