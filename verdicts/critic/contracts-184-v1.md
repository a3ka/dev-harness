accept
OBJECT=14b549566f57c3448b3e8f01ea118ab372107565
СУД: repo=dev-harness; предмет=184; фаза=контракт; роль=critic; вызов=4/2 (исправительный по санкции оркестратора №2); модель-план=zai/glm-5.3; сессия=c907157c; модель-факт=openai-codex/gpt-5.6-terra; SHA=14b549566f57c3448b3e8f01ea118ab372107565; предыдущий=verdicts/critic/contracts-184-v1-vyzov3-fail.md; исключение=санкция оркестратора №2 (§Остановка)

# Вердикт критика — контракт 184 «внешняя замена подключения проекта (А10)», исправительный вызов 4/2

## Кандидат, независимость и законность вызова

OBJECT проверен в отдельном одноразовом SSH-клоне: `git fetch origin wip/184/architect` дал `14b549566f57c3448b3e8f01ea118ab372107565`, detached `HEAD` установлен на этот SHA. Автор OBJECT — `architect <architect@dev-harness.local>`; судья — отдельная сессия `c907157c`, собственной работы не судит. План модели — `zai/glm-5.3`; фактическая модель — `openai-codex/gpt-5.6-terra`, допустимый autoFallback тира `apex-sol` (`config/agent_models.json:59-63,94`).

Запуск 4/2 законен только как одноразовая исправительная проверка: `origin/wip/012/orchestrator:HANDOFF.md` содержит `САНКЦИЯ-ОРКЕСТРАТОРА №2` именно для предмета 184, этого OBJECT, предыдущего `verdicts/critic/contracts-184-v1-vyzov3-fail.md`, письменного согласия автора и класса остаточного риска подмены `probe.py`. Поэтому проверены закрытие единственного блока вызова 3 и последствия его дельты; неизменённые поверхности заново не исследовались.

## Закрытие блока вызова 3

Блок закрыт. `contracts/184-vneshnyaya-zamena-podkljucheniya-proekta.md:41` называет ранее наблюдённую конформную подмену `probe.py` на `raise SystemExit(0)`, её наблюдение (полная CI-цепочка возвращает rc 0 без клеток) и границу прямого Python-вызова. `contracts/184-vneshnyaya-zamena-podkljucheniya-proekta.md:52` явно относит эту подмену, включая точный путь и `raise SystemExit(0)`, к `НЕ ЗАЩИЩАЕТ`, помечает остаток `cognitive-only` и называет ловцы: reviewer по git-diff неизменности батареи, `check_contract_frozen` для текста и CI-стражи зон для файлов.

Граница не противоречит `ЗАЩИЩАЕТ` на строках 46–47: те буллеты защищают ссылки в product-файлах и FD/inode-границу внешнего файла, а не собственную целостность выполняемой пробы. Отказ добавлять счётчики обоснован: подменённый проверяемый `probe.py` способен напечатать ожидаемые счётчики, поэтому stdout не докажет происхождение вычисления. Это прямо соответствует правилу 8 `AGENTS.md`: исходник на диске в ходе прогона — территория проверяемого, а не независимое свидетельство.

Дельта OBJECT относительно родителя содержит только пять добавленных строк контракта; fixture-батарея не менялась. Она не вводит новый исполнимый механизм, новую зону или новое обязательство, кроме явной границы уже наблюдённого риска. Новых доказанных блокирующих нарушений в этой дельте нет.

## Выполненные прогоны

```text
$ git diff --check 14b549566f57c3448b3e8f01ea118ab372107565^ 14b549566f57c3448b3e8f01ea118ab372107565 && git diff --quiet 14b549566f57c3448b3e8f01ea118ab372107565^ 14b549566f57c3448b3e8f01ea118ab372107565 -- fixtures/workshop_project/external_connection_184/ && printf '%s\n' 'DELTA_OK only-contract; BATTERY_UNCHANGED'
DELTA_OK only-contract; BATTERY_UNCHANGED
[rc=0]

$ bash scripts/check_precision_gate.sh . contracts/184-vneshnyaya-zamena-podkljucheniya-proekta.md && bash scripts/pre_critic.sh contracts/184-vneshnyaya-zamena-podkljucheniya-proekta.md && bash scripts/check_threat_model.sh . contracts/184-vneshnyaya-zamena-podkljucheniya-proekta.md && bash scripts/check_ceilings.sh . && bash fixtures/workshop_project/external_connection_184/red_external_connection_184.sh --model && bash fixtures/workshop_project/external_connection_184/red_external_connection_184.sh --stabs
OK
  ok   гейт предпосылок: PREDPOSYLKI_OK secrets=0 variables=0 environments=0 settings=2
КРИТИК: дверь зелёная
модель угроз: секция валидна (ЗАЩИЩАЕТ 2 буллет(ов), НЕ ЗАЩИЩАЕТ 3 буллет(ов))
  ok   персоны: 12 файл(ов), потолок 61440 байт
  ok   правила: 1 файл(ов), потолок 30720 байт
  ok   раздел требований: 169 черновик(ов) судится, замороженные — по тегам
потолки в порядке
CELL clean: ok (expected=ok, got=ok)
CELL internal-reference: ok (expected=ok, got=ok)
CELL ci-reference: ok (expected=ssylka, got=ssylka)
CELL readme-reference: ok (expected=ssylka, got=ssylka)
CELL configuration-reference: ok (expected=ssylka, got=ssylka)
CELL ignore-reference: ok (expected=ssylka, got=ssylka)
CELL nested-code-reference: ok (expected=ssylka, got=ssylka)
CELL legacy-root-profile: ok (expected=profil, got=profil)
CELL swapped-identity: ok (expected=profil, got=profil)
CELL generator-good: ok (expected=ok, got=ok)
CELL generator-wrong-id: ok (expected=profil, got=profil)
CELL ci-entrypoint: ok
STAB scan-internal@internal-reference: caught (expected=ok, got=ssylka)
STAB no-ci@ci-reference: caught (expected=ssylka, got=ok)
STAB no-docs@readme-reference: caught (expected=ssylka, got=ok)
STAB no-config@configuration-reference: caught (expected=ssylka, got=ok)
STAB no-ignore@ignore-reference: caught (expected=ssylka, got=ok)
STAB root-only@nested-code-reference: caught (expected=ssylka, got=ok)
STAB root-profile@legacy-root-profile: caught (expected=profil, got=ok)
STAB trust-any-profile@generator-good: caught (expected=ok, got=profil)
STAB trust-manifest@generator-wrong-id: caught (expected=profil, got=ok)
STAB absent-entrypoint@ci-entrypoint: caught
STAB invalid-entrypoint@ci-entrypoint: caught
STAB no-probe@ci-entrypoint: caught
STAB swallowed-rc@ci-entrypoint: caught
[rc=0]
```

Вердикт: `accept`. Единственный блок вызова 3 закрыт объявленной границей риска и ловцами; проверенная исправительная дельта не открыла нового блокирующего класса.
