ФОРК: 140-land-split-identity
ВОПРОС: Как приземлить int-носитель шага 1 публикации 140/3 (PR #956, wip/int-1401/architect, head 6bf8c96c55, CI run 43724081605 success, tyazhelyj-itog success), если land_agent отказывает по И-9 на коммите ветки автора с расщеплённой identity?
КЛАСС: инженерный
ПРИЗНАК: отказ штатной двери land_agent (И-9: committer==author в диапазоне main..tip)
МАРШРУТ: консультант
ЗАВЕДЁН: 2026-11-15T15:20:00Z
АВТОР: anthropic/claude-sonnet-5-5
БЛОКИРУЕТ: да
ОТВЕЧЕНО: нет

СЫРОЙ ВЫВОД (rc 1): `bash scripts/land_agent.sh --branch wip/int-1401/architect --worktree /tmp/dev-harness-worktrees/c907157c/wip-int-1401-architect --root /home/harness/dev-harness` →
«ОТКАЗ: identity расщеплена: 3572945e author=implementer committer=orchestrator — committer и author обязаны совпадать (И-9)». Скрипт: «STOP: land wip/int-1401/architect отказ». Детектор до: красный по 7 путям docs/owner/adr/** (owner-PR #953) — ручной `--snapshot` по стоячей санкции: (а) `git status --porcelain` пусто; (б) HEAD == origin/main == 0962c10347 после `gitw merge --ff-only origin/main`; (в) `0 0`; snapshot rc 0 (транскрипт — в теле ближайшего state-коммита).
Факты (`git log --format='%h %an|%cn' origin/main..3572945eff`, перепроверено): 3572945eff implementer|orchestrator (сдача «140 v3 структурная сдача», перенесена в ветку architect через accept_task_commit), 1b7d4713a0 critic|orchestrator (accept критика v3 — вердикт, закоммичен оркестратором прежней сессии), a7e1812250 architect|architect, d063066846 architect|architect. Грандфазер И-9 в land_agent — по жёстким SHA (105), для этих коммитов его нет.
Даже узкий носитель только до 1b7d4713a0 (контракт d063066846 + accept 1b7d4713a0 — всё, что нужно объекту удержанной 140/3) упирается в тот же И-9: 1b7d4713a0 critic|orchestrator.
Варианты: (а) owner-PR (как #909/#880/#953): владелец/консультант коммитит merge int-ветки identity owner — вне моих средств; (б) грандфазер И-9 для 3572945eff и 1b7d4713a0 в land_agent.sh (правка скрипта — owner/архитектурная зона, слово владельца); (в) пересоздать два коммита с author==committer (cherry-pick под identity автора, новый sha): объект удержанной 140/3 = 1b7d4713a0 (тег refs/frozen-hold) перестаёт быть предком main → публикация 140/3 по 130 невозможна без переноса удержания на новый sha (новый freeze/hold — запрещён). Рекомендация: (а) или (б).
Заметка: реализация 140 (wip/140/implementer 7c641a395e) содержит те же коммиты → её ленд упрётся в то же.
До ответа ленд int-1401 НЕ делаю; публикация 140/3 и судьи 140 заблокированы.
