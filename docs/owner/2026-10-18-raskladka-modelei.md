# Решение владельца 2026-10-18: раскладка моделей по ролям

Слово владельца 2026-10-18 ~16:10 UTC: «да, так подходит». Ограничения владельца:
- architect — ресурсоёмкая роль, самые дорогие модели там «не покатят»: Opus либо GLM;
- арбитр — Fable, как окончательное слово;
- заменой Astra может быть только Fable, и наоборот.

Передал консультант. Действует через `config/agent_models.json` (tiers, roles, routing — единое место правил, решение `docs/owner/2026-10-18-pravila-modelei.md`).

| роль | модель | фолбек |
|---|---|---|
| orchestrator | Sonnet 5-5 | GLM-5.3 |
| architect | **GLM-5.3** | **Opus** (autoFallback) |
| implementer | MiniMax-M3 | Sonnet 5-5 |
| implementer-glm *(с контрактом pravila-modelei)* | GLM-5.3 | Sonnet 5-5 |
| critic | **Astra** | **Fable** |
| adversary | Terra | Opus |
| reviewer | Opus | gpt-6-sol |
| arbiter | **Fable** | **Astra** |
| consultant | Astra | **Fable** |
| steward | Haiku 4-5 | gpt-6-luna |
| тир vision | Sonnet 5-5 | gpt-6-sol |
| тир smol | MiniMax-lightning | — |

## Почему architect на GLM, а не на Opus

- **Семейство критика.** Критик — верхний уровень чужого семейства относительно architect (decisions/005). При architect на Opus критик был бы Astra, но его фолбек Fable оказался бы того же семейства, что автор.
- **Ревьюер.** При architect на GLM ревьюер на Opus не судит работу на модели автора.
- **Цена.** GLM дешевле Opus; architect на GLM уже работал до 13.10.

Риск — квота z.ai: на GLM architect, implementer-glm и фолбек оркестратора. При исчерпании квоты architect переходит на Opus автоматически. Если квота станет постоянной проблемой — включать 077 (профили по остатку подписок).

## Проверка до коммита

Fable 5-1, GLM-5.3 и Astra ответили на пробный запрос: `omp -p`, rc 0, консультант, 2026-10-18.

Отменяет временную подмену 15.10: architect → Astra, critic → Opus.
