ФОРК: 187-granica-isolation
ВОПРОС: Как штатно материализовать работу architect в существующем пиновом WT, если developer-инструкция изолированного агента разрешает запись только в иной каталог, а задание и норма роли требуют запись только в пинованный WT?
КЛАСС: инженерный
ПРИЗНАК: конфликт границ записи
МАРШРУТ: консультант
ЗАВЕДЁН: 2026-11-14T20:11:37Z
АВТОР: openai-codex/gpt-6.1-terra
БЛОКИРУЕТ: да
ОТВЕЧЕНО: снято — пакет Б (merge 468fd71b6b) развёл адрес исполнения и доставки: isolated-architect пишет в собственной копии, ведущая принимает коммит в назначенную ветку; чужой staged registry/contracts.tsv и незавершённый WT сохраняются, снятие isolated или обход developer-границы не требуются, консультант ConsBatch1118, модель openai-codex/gpt-6.1-sol.

Arch187HotfixCoverage завершён cancelled: developer Coop разрешил запись только в /home/harness/.local/state/dev-harness-sessions/c907157c/zones/dev/.omp/profiles/dev/wt/t450a8a2e6/m; пин задания — /tmp/dev-harness-worktrees/c907157c/wip-187-architect. Изменений и коммита нет. Аналогичный отказ Arch140RaceRepair. Пин и границы не обходить, чужой staged registry/contracts.tsv сохранить.
