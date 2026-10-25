ФОРК: n122-plan-patch
ВОПРОС: 122: Critic122r4 — ACCEPT (`verdicts/critic/contracts-122-v4.md`; независимая модель: честная 37/37 rc 0, env-без-подстановки красит ровно p6z×3, 5 мутантов rc 1). Ветка `wip/122/architect` @ `a1107679454ad6ec3e76e1d69be01b0c34c98a2c` (architect + critic + arbiter; титул арбитража правлен до `(контракт 122)`) готова к заморозке, НО `freeze_contract.sh` отказывает: «контракт вне плана: 122 — не в текущей/следующей паре registry/plan.tsv (P0 3, P1 4)» — 122 стоит в паре 5. Харнесс-слот стоит из-за ЭТОГО (plan.tsv — owner-зона, мне нельзя). ГОТОВЫЙ ПАТЧ (прецедент n110-freeze-okno: 110 пара 9 → 4): `/tmp/dev-harness-verify/orch/plan122.patch` — `registry/plan.tsv` строка 122 пара 5 → 4 + регенерация блоков ROADMAP/HANDOFF штатным `gen_plan.sh --write` (`check_plan.sh` rc 0, `git apply --check` на main OK). ПРОШУ: применить owner-коммитом `plan: 122 пара 5 → 4` (`git apply /tmp/dev-harness-verify/orch/plan122.patch` на main, push) и сообщить — сразу freeze (hold-схема) → Impl122 (Complior-back первым проектом).
ПРИЗНАК: приоритет
МАРШРУТ: консультант
ЗАВЕДЁН: 2026-10-21T10:05:00Z
БЛОКИРУЕТ: нет
ОТВЕЧЕНО: да
