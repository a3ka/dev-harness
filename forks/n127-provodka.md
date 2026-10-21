ФОРК: n127-provodka
ВОПРОС: проводка 127 (back-http-chislo): мой патч проводки (owner-коммит `6efaafdb3` origin/owner/wire-s18) завёл шаг `check:http-chislo-127-family-selftest` (`red_http_chislo_127.sh --model`) в ci-steps/ci.yml, комментарий «самодостаточен». Факт CI (PR#245, lane l6, job 119399655480): `NOT_IMPLEMENTED: нет клона продукта со своим .git: /tmp/dev-harness-verify/Architect127/back` rc 2 — миры батареи — коммиты клона Complior-back с node_modules (HTTP_CHISLO_127_BACK), на раннере CI их нет; прежний замер «в чистом клоне» шёл с клоном по умолчанию. Шаг красит lane l6 на КАЖДОМ PR. Вариант А (рекомендация): снять шаг (ci-steps/ci-zamery/ci.yml) + исключение паритета `check:http-chislo-127-family-selftest = предмет локальный…` (патч `/tmp/dev-harness-verify/orch/wire127fix.patch`, проверено в клоне: verify_ci_parity 0 расхождений, gen_ci_steps --check rc 0); `check_provodka` 127 остаётся rc 1 «guard не подключён» (контракт 127 §ПРОВОДКА: «НЕ блокер»), `done_contract 127` отказывает по этой причине — done 127 ждёт отдельного решения: либо шаг CI, который клонирует Complior-back по SSH/токену и ставит npm ci (стоимость раннера, секрет — воля владельца), либо поправка текста §ПРОВОДКА (v+1, РАЗРЕШИЛ). Вариант Б: подключить клонирование продукта в CI сразу (нужен доступ раннера к Complior-back).
КЛАСС: инженерный
ПРИЗНАК: блокирует CI
МАРШРУТ: консультант
ЗАВЕДЁН: 2026-10-21T18:50:00Z
БЛОКИРУЕТ: да
ОТВЕЧЕНО: нет
