# ops/server

# ОБМАННЫЙ СТАБ s18 (Н-39: вход readme-anchors).
# Дефект: раздела «Локальные артефакты CI (контракт 196)» нет — README
# описывает только обвязку 074. Честная модель несёт раздел с якорями
# (путь интерфейса, команда установки, таймер, срок, группа harness,
# правило GitHub).

## Обвязка станции (инвентарь 074)

- `orch-loop` — цикл воркфлоу под пользователем harness (user-установка).
- `orch-peak` — пиковый сторож станции (root-установка).
- Юниты: `orch-peak@.service`, `orch-peak-warn.timer`, `orch-peak-stop.timer`,
  `orch-peak-start.timer`, `orch-peak-reenable.timer`, `orch-ctx.timer`.
- Установка станции: `bash ops/server/install.sh user|root`, сверка — `verify`.
- Журналы и маркеры: send-keys, гашение omp, настройка Node 26 и GITHUB_TOKEN.
