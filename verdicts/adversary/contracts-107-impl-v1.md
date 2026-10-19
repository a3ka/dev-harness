FAIL
OBJECT=87c5bef4db7854bb2cf6aadba987b3a4da6cb6bf

# Adv107 — суд реализации C CMP-MOB-003

Проверялся реальный C в `/tmp/dev-harness-verify/Adv107/mob`, без подстановки модели. H получен по SSH и закреплён на `cd15c80761b44fe0ab513b5d1dd720718bcaf6dd`. Нативный Maestro/эмулятор не запускался: **NOT_RUN**, честная граница задания.

## Блокирующие обходы обычных проб

Обычные пробы наблюдают экран через прямые порты и mock/runtime, но не наблюдают composition route и HTTP runtime. Поэтому следующие ошибочные деревья были установлены непосредственно поверх C; обе обычные пробы остались зелёными, а независимый исполняемый Jest-свидетель был красным. До каждой негативной пробы тот же свидетель на неизменённом C был зелёным.

| Обход на C | Нарушение | static / behavioral | независимый свидетель |
|---|---|---:|---:|
| `composition-recheck-noop` | `(entry)/erstinformation.tsx`: `recheck` становится no-op. После confirm экран вызывает порт, но route не перечитывает `runtime.api.getDisclosureGate()`, вопреки инварианту 5 и оговорке композиции. | `0 / 0` | `1` |
| `composition-hardcoded-gate` | route игнорирует реальный `snap` и подаёт литеральный CURRENT_CONFIRMED. Runtime возвращает PENDING, но продукт показывает evidence вместо `disclosure.pending`: зашитая константа вместо данных gate. | `0 / 0` | `1` |
| `http-masked-fallback` | `http-runtime.getDisclosureGate()` возвращает поддельный CURRENT_CONFIRMED вместо именованного `PILOT_HTTP_UNAVAILABLE`. Это отказ, замаскированный успехом, против требования fail-closed/инварианта 5. | `0 / 0` | `1` |

Это исполняемые контрпримеры, не статический обзор: независимые свидетели рендерят именно entry route с подменённым `@pilot/runtime`, ждут реальный вызов gate и проверяют отображённое состояние; HTTP-свидетель импортирует настоящий `bootstrap/http-runtime.ts` при `EXPO_PUBLIC_API_MODE=http` и требует rejected Promise с `PILOT_HTTP_UNAVAILABLE`.

Следовательно карта К5′–К9′ не закрывает обязательные швы композиции и HTTP: годная ветка C проходит положительные контроли, негодные ветки проходят штатные 22/265, но падают только в независимых свидетелях.

## Унаследованные обходы критика

Все пять мутантов Critic107r2 и оба варианта `Critic107r3/full_bypass.py` были наложены на C по одному с восстановлением дерева. Для каждого статическая проба ожидаемо не применима и осталась `rc=0`; поведенческая проба стала красной `rc=1`:

| Мутант | наблюдаемая красная семья |
|---|---|
| `evidence-coabsent-fallback` | `EVIDENCE_PROD_*` |
| `retry-business-transition` | `ACTION_VECTOR_*_FAILED_*_RETRY` |
| `recheck-before-settlement` | `ACK_OUTCOME_*_MOVED1_*` |
| `recheck-success-only` | `ACK_OUTCOME_*_REJECT` |
| `runtime-incomplete-gate` | `RUNTIME_GATE_SNAPSHOT` |
| `full-bypass-empty-display-fallback` | `RUNTIME_GATE_SNAPSHOT` |
| `full-bypass-omitted-display-fallback` | `RUNTIME_GATE_SNAPSHOT` |

Таким образом старые пять осей и обход полного fallback теперь действительно ловятся на C; это не снимает три новых обхода выше.

## Фактические команды и rc

```text
# cwd=/tmp/dev-harness-verify/Adv107
python3 H/fixtures/workshop_project/erstinfo_107/erstinfo_static_probe.py --repo mob
rc=0; static 22/22

python3 H/fixtures/workshop_project/erstinfo_107/erstinfo_probe.py --repo mob
rc=0; honest 265/265

git -C mob status --short --untracked-files=all
rc=0; stdout пуст

python3 run_inherited_mutants.py
rc=0; 7/7 мутантов: static_rc=0, behavior_rc=1, clean=True

python3 run_new_bypasses.py
rc=0; положительные контроли 3/3 witness_rc=0; обходы 3/3: static_rc=0, behavior_rc=0, witness_rc=1, clean=True

# cwd=mob/mobile
npm run lint
rc=1; react-hooks/set-state-in-effect в src/app/(entry)/erstinformation.tsx:43:10

npm run typecheck
rc=2; TS2322 ×2 в src/bootstrap/__tests__/pilot.test.tsx: mock ApiClient не содержит acknowledgeDisclosure/getDisclosureGate

npm run test
rc=0; 3 suites, 17 tests passed
```

После всех проб `git status --short --untracked-files=all` в C и H пуст. `git diff --name-only 76ac10fa HEAD` перечисляет ровно девять заявленных путей implementer-зоны; выхода за зону не найдено.

Даже без трёх обходов качество C не проходит: lint и typecheck имеют ненулевые rc. Вердикт: **FAIL**.
