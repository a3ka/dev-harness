ПОДТВЕРЖДЕНО: воля-владельца

# Свидетельство класса форка forks/161-land-owner-committer.md

ПРЕДМЕТ: forks/161-land-owner-committer.md (SUBJECT 161, OBJECT 1f7208440d2b51b8aef4a78f7db447f9cd8f01e1)
МОДЕЛЬ: anthropic/claude-fable-5-1 (АВТОР записи zai/glm-5.3 — самоподтверждения нет)
ВОПРОС: ленд 161a в main заблокирован дверью land_agent И-9 на коммитах диапазона main..wip/161/architect (6d6f4fcd — расщеплённая identity вердикта; 2c7abb6e — author=committer=owner); выбор (а) owner-merge своей identity / (б) разовые исключения / (в) переиздание базы — воля/риск, не инженерия?

## Основание (сверка по дереву)

1. Запись: поля ФОРК/ВОПРОС/КЛАСС/ПРИЗНАК/МАРШРУТ/ЗАВЕДЁН/АВТОР/ВЫЗВАН/БЛОКИРУЕТ полны; АВТОР zai/glm-5.3 ≠ anthropic/claude-fable-5-1.
2. Факты дерева:
   - 2c7abb6e6ac30cc7c848a0e1172a30ed94ebc54c: author=owner <owner@dev-harness.local>, committer=owner, «land: wip/161/architect (форма пробы #535)», merge с родителями 371be2ff и b99c667b (оба уже в main); в main НЕ входит; лежит в main..wip/161/architect.
   - Диапазон main..wip/161/architect (7 коммитов): 7ee42362 orchestrator|orchestrator; 6d6f4fcd critic|orchestrator (РАСЩЕПЛЕНА); baa080c2, eec120d6, 0bb025e2, 3157dc61 architect|architect; 2c7abb6e owner|owner.
   - frozen/contracts/161/1: tag-object 92a28122d → 6d6f4fcd, tagger orchestrator, тело несёт РАЗРЕШИЛ-ВЛАДЕЛЕЦ; на origin НЕ опубликован (контракт 130).
   - verdicts/critic/contracts-161-v1.md = 6d6f4fcd (scoped 7/7 accept, OBJECT baa080c24, сессия Critic161GlmV7) — на ветке.
   - Реестр ролей ЗОНА-строк: adversary arbiter architect consultant critic implementer orchestrator reviewer — owner отсутствует намеренно; land_agent.sh на ветке и в main идентичен (не менялся с a05961c6, 16.10).
   - Репродукция land_agent в одноразовом клоне (identity orchestrator через GIT_CONFIG_COUNT): tip 7ee42362 → rc1 «identity расщеплена: 6d6f4fcd author=critic committer=orchestrator» (И-9 newest-first падает до 2c7abb6e); tip baa080c2 → rc1 «имя вне реестра ролей: 2c7abb6e — committer owner …».
3. Альтернативы без санкции владельца проверены и отсутствуют: rebase/cherry-pick переписывает SHA под frozen-тегом (норма «frozen-тег НЕ трогать») и коммиттеров чужих коммитов; merge мимо land_agent оркестратором — обход двери; add owner в реестр ЗОНА-строк — правка замороженного контракта; исключение одного SHA — прецедент только по подписи владельца.

## Вывод

РЕКОМЕНДАЦИЯ: класс «воля-владельца» с ПРИЗНАК «риск» подтверждаю — ни один из выходов не существует без санкции владельца. Оговорка для формулировки выбора: «исключение только для 2c7abb6e» ленд НЕ разблокирует — на текущем tip первый отказ И-9 на 6d6f4fcd (расщеплённая identity вердикта); вариант (б) требует исключений для ДВУХ коммитов либо пере-коммита вердикта с author==committer (меняет SHA под frozen-тегом). Вариант (а) — owner-merge всей ветки своей identity, land_agent не вызывается — работает как описано и остаётся рекомендацией.

ПОДТВЕРЖДЕНО: воля-владельца
