# ops/server

Модель README для батареи 196: раздел ниже — исполнительная модель предъявления
И-11 (контракт 196). Реальный ops/server/README.md несёт инвентарь 074 и этот
раздел, не переписывая чужие темы.

## Локальные артефакты CI (контракт 196)

Артефакты станционных прогонов CI хранятся локально на станции, и на GitHub артефакты не загружаются
(квота GitHub Actions не расходуется). Интерфейс пути: `/var/lib/ci-artifacts/<репо>/<run_id>-<run_attempt>/<имя>/`.

- Корни и владельцы: `/var/lib/ci-artifacts/Complior-mob/` — владелец `harness` (писатель моб-раннера),
  `/var/lib/ci-artifacts/Complior-back/` — владелец `ci-back` (писатель бэк-раннера); оба — группа harness,
  режим 2775 (setgid: созданное наследует группу).
- Установка (root): `sudo bash ops/server/install.sh artifacts`; сверка: `sudo bash ops/server/install.sh verify`
  (успех — `ci-artifacts: сверка 3/3`; до установки — `ci-artifacts: не установлены`, это не расхождение).
- Таймер: `ci-artifacts-clean.timer` — ежедневно 04:30 Asia/Singapore, Persistent=true (пропущенная за простоем
  чистка навёрстывается). Включение/выключение: `sudo systemctl enable --now ci-artifacts-clean.timer` /
  `sudo systemctl disable --now ci-artifacts-clean.timer`.
- Срок хранения: 14 суток; шов `CI_ARTIFACTS_RETENTION_DAYS` (env юнита/чистильщика), меняется правкой юнита в репо
  (установленное == репо).
- Семантика очистки: прогон молод, пока хотя бы одна запись его дерева моложе границы; старые прогоны удаляются
  целиком; отклонения от грамматик имён — именованные отказы `ОТКАЗ:` с путём, чистильщик не молчит.
- Судьи читают артефакты из группы harness; на GitHub артефакты не загружаются.
