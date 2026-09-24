accept

# Контракт 037 M1 — третий адверсарий-круг: формальная перепроверка HOME-предиката

Проверен текущий `HEAD` SSH-клона `9f0114618083836a7964e96803851e2266eb94f8` против настоящего CLI предмета:

```sh
bash /tmp/dev-harness-verify/adversary-037-circle3-home-probe.sh .omp/extensions/path-guard.ts
```

Проба создала базу `/tmp/adversary-037-circle3.fMfs5A`, то есть **не** в `${TMPDIR:-/tmp}/dev-harness-verify`; scratch allowlist 025 не мог дать ложный `pass`. Каждый атакующий кандидат был обычным git-репозиторием с `.git`-каталогом и одной записью `git worktree list --porcelain`; `worktree:null`, а `sessionName` буквально совпадал с `id` соответствующего `.omp-isolation-owner.json`. Следовательно, до проверяемого предиката выполнены p.2, p.3 и p.5, а отказ не объясняется отсутствием owner-корреляции.

Живой вывод:

```text
base=/tmp/adversary-037-circle3.fMfs5A (not scratch allowlist)
legitimate_under_home=pass (expect pass)
outside_home_bypass=block (expect block)
home_itself_bypass=block (expect block)
HOME predicate probe: all scenarios matched
```

Атакующие сценарии — мои исходные из `verdicts/adversary/contracts-037-m1m2-recheck.md` (`5edeab8`):

- `outside_home_bypass`: `actual=$BASE/outside`, `HOME=$BASE/home`, владелец с совпадающим `id` в `$BASE/.omp-isolation-owner.json`; судья дал `block`.
- `home_itself_bypass`: `actual === HOME`, HOME сам является обычным репозиторием, владелец со совпадающим `id` лежит в родителе HOME; судья дал `block`.

Позитивный контроль не является «всегда block»: самодостаточный репозиторий строго внутри того же HOME, с тем же корректным owner-артефактом, дал `pass`.

Таким образом, конкретная регрессия из `5edeab8` закрыта правкой `20d821d`: оба отказа происходят на реальном `node .omp/extensions/path-guard.ts --judge`, а допустимая ветвь остаётся работоспособной. Это формальная адверсарная перепроверка именно HOME-предиката; она не отменяет отдельный вывод reviewer о необходимости различающих постоянных клеток в фикстуре.

— adversary, третий круг
