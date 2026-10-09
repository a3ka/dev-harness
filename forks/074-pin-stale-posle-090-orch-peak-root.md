ФОРК: 074-pin-stale-posle-090-orch-peak-root
ВОПРОС: l6 PR#76 (run 37958537999, job 113915157481) красен НОВОЙ причиной после починки В1/В3/В4 — check:ops-server-family-selftest → fixtures/_krasnye_074.sh → cell_k5: «ops/server/root/orch-peak разошёлся с пином станции». Живая сверка: PIN контракта 074 (fixtures/ops_server/red_server_obvjazka_074.sh:116, root/orch-peak → e80bfbfb33f60c4571e55764b77c49600113745ae419072c608c6f6b4b13cc53, подписан «живая станция 2026-10-02») НЕ совпадает с текущим sha256sum ops/server/root/orch-peak = 8479a02b2f48cb0f06ebdcd49693d394c9bb2f1d06e0ca69d15e5797c8d6552e. Та же причина, что В4 (085): легитимная продакшн-правка d18d4d8f (контракт 090, §П3, добавление ${ORCH_UHOME:-...} в строку 18) ушла в прод ПОСЛЕ последней синхронизации PIN контракта 074 — та же маскировка: раньше л6 падал РАНЬШЕ (getent-клетка 090), поэтому _krasnye_074.sh вообще не исполнялся до этой сессии; теперь 090 зелёный, и досе-скрытый красный 074/к5 стал видимым. Нужен ли post-done пакет architect 074 (аналог В4), синхронизирующий ТОЛЬКО PIN root/orch-peak в fixtures/ops_server/red_server_obvjazka_074.sh:116 на новый sha256 — без правки production-кода, ci.yml, текста контракта 074?
КЛАСС: инженерный
ПРИЗНАК: рутина
МАРШРУТ: консультант
ЗАВЕДЁН: 2026-10-09T16:30:00Z
АВТОР: anthropic/claude-sonnet-5
БЛОКИРУЕТ: да
ОТВЕЧЕНО: нет
