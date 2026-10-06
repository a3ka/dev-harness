FAIL

Контракт 088 не принят. `scripts/check_staged.sh` принимает строку-указатель
из недоверенной переменной окружения `PTR_088`, хотя И-5 требует строку
`HANDOFF_PTR` из k7.

## Воспроизведённый обход И-5/И-6

В изолированном SSH-клоне на `8bc5e68` включён обычный
`core.hooksPath=.githooks`. Был staged корневой `HANDOFF.md` без k7:

```text
# H

## ГДЕ МЫ

attacker
```

Команда

```bash
PTR_088=attacker git -c user.name=orchestrator \
  -c user.email=orchestrator@dev-harness.local -c commit.gpgsign=false \
  commit -m 'adversary pointer environment probe'
```

создала коммит `7478988a` с rc 0; хук вывел `judged: HANDOFF.md` и
`ok: staged в зоне автора orchestrator (1 путь/путей)`. Ожидался отказ И-7
и несдвинутый HEAD. Причина: `_handoff_ptr="${PTR_088:-}"` позволяет
коммитёру заменить обязательное значение hook environment-ом.

Полный позитивный контроль на чистом SSH-клоне был зелёным:
`bash fixtures/_krasnye_088.sh` → 6/6 D, 12/12 B, 15/15 стабов, rc 0;
`bash fixtures/_krasnye_088.sh fast` → D1/B1, rc 0. Батарея не ловит обход,
потому что `_toy.sh` сам экспортирует корректный `PTR_088`. Нужна B-клетка с
конфликтующим `PTR_088`, проверяющая, что production берёт k7 независимо от
environment.

## Второй зелёный обманный стаб

Контракт допускает basename журналов с ведущей точкой. Минимальная дверь,
которая в остальной честной логике отбрасывает все имена `.*`, прошла штатную
D-батарею:

```text
bash fixtures/strazh_088/red_dver_088.sh . --dver /tmp/dev-harness-verify/door-dot-ignore.sh
L1, D0, D1, D2, D3, D4 — зелёные; rc=0
```

На D1 с единственным свежим `.Skrytyj.jsonl` тот же стаб дал rc 1
`ОТКАЗ: HEAD расходится с origin/main` вместо требуемого отказа
`живые субагенты: .Skrytyj`. Нужна постоянная D-клетка/параметризация D1 для
ведущего-точечного basename с честной диффпробой.

## Остальные выполненные проверки

На чистом clone: `pre_critic`, `check_threat_model`, `check_ceilings` — rc 0.
`git diff --exit-code HEAD~1 -- scripts/lib_session.sh ops/server/root/orch-peak`
— rc 0. Вопреки заданию, тот же diff против `592fc4e` здесь тоже rc 0.
Дифф `HEAD~1..HEAD` среди `scripts/` содержит ровно две implementer-пути:
`scripts/orch_restart.sh`, `scripts/check_staged.sh`.
