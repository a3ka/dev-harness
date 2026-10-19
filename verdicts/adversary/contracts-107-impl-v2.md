FAIL
OBJECT=376eb1ae5776ca98a53fa0771ead1e8894d793d9

# Adv107r2 — суд реализации CMP-MOB-003, круг 2

Проверен C в `/tmp/dev-harness-verify/Adv107r2/mob` на указанном OBJECT. H получен по SSH и закреплён на `cd15c80761b44fe0ab513b5d1dd720718bcaf6dd`. Нативный Maestro/эмулятор не запускался: **NOT_RUN** по ограничению задания.

## Блокирующий новый обход: gate читается в W0

Контракт требует, что `getDisclosureGate` потребляется **только после закрытия W0 и достижения W1A** (инвариант 5; также это буквально записано в комментарии `Admission` в `mobile/src/api/api-client.ts`). Реальная композиция нарушает это на C:

- `(entry)/erstinformation.tsx` устанавливает `initialAdmission: 'W0'`;
- его mount-effect безусловно вызывает `fetchGate(api)`;
- `fetchGate` вызывает `apiClient.getDisclosureGate()`.

Независимый исполняемый свидетель `w1a-admission-witness.test.tsx` подменяет только публичный `@pilot/runtime`, рендерит настоящий entry-route и наблюдает вызов порта. Контроль честной минимальной границы сначала зелёный: при W0 gate не читается, после W1A читается ровно один раз (`rc=0`). На реальном C проверка запрета в W0 красная:

```text
node node_modules/jest/bin/jest.js --ci --runInBand --runTestsByPath ...adv107r2-w1a-admission.test.tsx --testNamePattern '^C bypass:'
rc=1; expected getDisclosureGate calls=0, received=1
```

Это наблюдаемый контрпример требованию канона, пропущенному обычной картой: штатные 265 клеток рендерят экран через порты и не исполняют entry-композицию с исходной W0 admission. Это не вопрос реального HTTP или отложенного Maestro: один реальный route вызывает публичный runtime-порт в запрещённой волне.

Дополнительно route не имеет входа, который передаёт ему реальную текущую admission; единственный `setAdmission('W1A')` находится в `handleContinue`, а Continue скрыт при исходном W0. Поэтому предусмотренная W1A-ветвь на стартовом route недостижима пользовательским путём. Основание FAIL достаточно уже первого, исполненного запрета W0.

## Закрытые обходы прошлого круга

На C вновь установлены и после каждой пробы восстановлены три обхода Adv107:

- `composition-recheck-noop`;
- `composition-hardcoded-gate`;
- `http-masked-fallback`.

`first_round_bypasses.py` сначала прогнал два независимых позитивных контроля (настоящая композиция передаёт PENDING и после ack перечитывает gate; HTTP runtime возвращает именованный отказ): оба `rc=0`. Каждый из трёх мутантов дал `rc=1` в соответствующем свидетеле. Итог: `controls=2 caught=3 status_rc=0`.

## Пять мутантов критика и full_bypass

На C повторены с байтовыми anchor-патчами пять декоев Critic107r2 и оба варианта Critic107r3/full_bypass:

- `evidence-coabsent-fallback`;
- `retry-business-transition`;
- `recheck-before-settlement`;
- `recheck-success-only`;
- `runtime-incomplete-gate`;
- `full-bypass-empty-display-fallback`;
- `full-bypass-omitted-display-fallback`.

Для каждого статическая проба осталась применимой и зелёной (`rc=0`), поведенческая проба без флагов дала `rc=1`. Итог runner: `mutants=7 caught=7 status_rc=0`. Следовательно прежние известные обходы на C закрыты; новый W0→gate обход остаётся непойманным.

## Обычные пробы, качество и чистота

```text
# cwd=/tmp/dev-harness-verify/Adv107r2
python3 h/fixtures/workshop_project/erstinfo_107/erstinfo_static_probe.py --repo mob
rc=0; static 22/22

python3 h/fixtures/workshop_project/erstinfo_107/erstinfo_probe.py --repo mob
rc=0; honest 265/265

# cwd=mob/mobile
npm run lint
rc=0
npm run typecheck
rc=0
npm test
rc=0; 3 suites, 17 tests passed

# cwd=/tmp/dev-harness-verify/Adv107r2
git -C mob status --short --untracked-files=all | wc -l
rc=0; 0
git -C h status --short --untracked-files=all | wc -l
rc=0; 0
```

`git diff --name-only 76ac10fa HEAD` содержит 9 путей и лежит в заявленной implementer-зоне. Артефакты мутаций и полные stdout/stderr с отдельными rc сохранены рядом с этим вердиктом: `first-round-*.log`, `*-static.log`, `*-behavior.log`, `w1a-*.log` и JSON-итоги.

Вердикт: **FAIL** — реальная entry-композиция читает disclosure gate в W0, хотя контракт допускает его только в W1A; обычные пробы не наблюдают этот путь.
