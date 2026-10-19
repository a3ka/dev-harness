FAIL
OBJECT=6d00deb681e0b70cad17147674bd120b6c2cccd4

# Адверсарий 996, круг 1

## Находка 1 — sourceCanon принимает источник за пределами проекта через symlink

**ОБХОД.** В проектном `harness.project.json` объявить `sourceCanon.sources[0].path = "linked-source.md"`, где `linked-source.md` — символьная ссылка на существующий файл вне корня проекта. `scripts/check_project_sources.sh` проверяет только `[ -f "$REPO/$p" ]`, который следует по ссылке, и не канонизирует источник с проверкой границы `R`. Gate запускается и возвращает зелёный, хотя контракт требует «существующих файлов внутри R». Таким образом проект подменяет канон внешним файлом, а source-gate объявляется зелёным.

Команда-доказательство на исходном OBJECT:
```text
$ python3 /tmp/dev-harness-verify/Adv996/symlink_source_repro.py
rc=0
```
Этот репро создаёт настоящий git-проект из `probe.py.world`, внешний `outside-source.md`, symlink `project/linked-source.md -> ../outside-source.md`, коммитит профиль и вызывает настоящий `scripts/check_project_sources.sh` через `probe.subject`.

**Красный тест-мутант:** `1116c646fe4209f16355af7b11fa58003ec455e4` удаляет отказ `*..*` из проверки пути источника. С этим намеренно неверным предметом внешний `../outside-source.md` принят:
```text
$ bash fixtures/workshop_project/rezhim_996/probe.sh --matrix
996: examined=75 mutants=56 mismatches=0
RC=0
$ python3 /tmp/dev-harness-verify/Adv996/traversal_source_repro.py
rc=0
RC=0
```
Матрица не содержит клетки для `..` и для symlink источника; следовательно не различает этот обход. Исторический коммит-мутант восстановлен следующим коммитом `893d381a5cbbd3b5b3e7ee48739dfafcf9a27b4e`.

## Находка 2 — обязательная package-команда семейства отсутствует; no-op проходит

**ОБХОД.** Приёмочный критерий требует ключ `check:rezhim-996-family-selftest` в `package.json`, но на OBJECT ключа нет. CI-реестр обходит эту поверхность прямой командой `bash fixtures/workshop_project/rezhim_996/probe.sh`, поэтому `scripts/gen_ci_steps.sh --check` и `scripts/verify_ci_parity.sh` остаются зелёными и не проверяют требуемый npm-контракт. Потребитель не может выполнить названную проверку:
```text
$ npm run check:rezhim-996-family-selftest
npm error Missing script: "check:rezhim-996-family-selftest"
RC=1

$ bash scripts/gen_ci_steps.sh --check; bash scripts/verify_ci_parity.sh
RC=0
workflow-команд: 19 · скриптов в приёмке: 72 · объявленных исключений: 27 · matrix-ключей: 47 · анти-плацебо-запусков: 2 · расхождений: 0
```

**Красный тест-мутант:** `8dd10c23b2a6104fcb40af4da6216475c454fb65` добавляет требуемый npm-ключ как зашитую заглушку `true`, а не `bash fixtures/workshop_project/rezhim_996/probe.sh --matrix`. Неверная реализация проходит обе заявленные поверхности:
```text
$ npm run check:rezhim-996-family-selftest
> true
RC=0
$ bash fixtures/workshop_project/rezhim_996/probe.sh --matrix
996: examined=75 mutants=56 mismatches=0
RC=0
```
Следующий коммит `22b8bff6c89ada7942b558ac494decd1cb26d8b0` удаляет заглушку и возвращает исходное отсутствие ключа. Проверки не связывают package-ключ с `probe.sh --matrix`; вакуумная зелень возможна.

## Позитивный контроль и счётчики

На немутированном OBJECT матрица завершилась зелёным:
```text
$ bash fixtures/workshop_project/rezhim_996/probe.sh --matrix
996: examined=75 mutants=56 mismatches=0
RC=0
```

`registry/ci-steps.tsv` действительно содержит `check:rezhim-996-family-selftest`, но его команда — `bash fixtures/workshop_project/rezhim_996/probe.sh` без `--matrix`; `.github/workflows/ci.yml` содержит этот ключ в lane l5. Это не исправляет отсутствующий npm-ключ и не проверяет его семантику.

Вердикт: FAIL. Исправления не вносились; после каждого мутанта его изменение восстановлено. Все мутации и этот вердикт коммитятся identity `adversary`.
