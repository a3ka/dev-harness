#!/usr/bin/env bash
# Стаб jest-krasnyj (клетка s-ekran-ispolnim, блок 1 Crit149b): фиктивная
# jest-среда с ЗАШИТЫМ КРАСНЫМ итогом — контрольный прогон зонда падает
# УПАВШИМ АССЕРТОМ (rc 1, JSON: success false, assertionResults со
# status failed). Клетка обязана отказать ISPOLNIMYJ_KONTROL_KRASEN на
# исходных компонентах R; судья, засчитывающий красный контроль зелёным
# (или превращающий его в пропуск), оставил бы вход незаметным —
# STAB_ZHIV rc 1 (Н-39; прецедент proba_live_put 145: падение загрузки
# и провал ассертов различаются — здесь провал именно АССЕРТОВ).
set -u
cat <<'JSON'
{"numFailedTestSuites":1,"numFailedTests":2,"numPassedTestSuites":0,"numPassedTests":0,"numPendingTests":0,"numRuntimeErrorTestSuites":0,"numTodoTests":0,"numTotalTestSuites":1,"numTotalTests":10,"success":false,"testResults":[{"assertionResults":[{"ancestorTitles":["gespraech-tekst-chat"],"failureMessages":["Expected test to be truthy"],"status":"failed","title":"zond-kontrol"}],"endTime":0,"message":"","name":"gespraech-zond","startTime":0,"status":"failed","summary":""}],"wasInterrupted":false}
JSON
exit 1
