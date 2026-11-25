# Дополнение к вердикту contracts-222-impl-v1

OBJECT=465b42261ed6b1964da3121cfee50ba43349e85b
Все команды ниже выполнены в одноразовом клоне кандидата с собственными временными мирами, фиктивными конфигом/трассой и TMPDIR внутри изолированной копии. Это дополнительные результаты, не новый вердикт.

## Регресс: сырой итог команд

```text
222 --stabs: rc=0
MODEL 222: KLETKI 76 KRASNYH 0
STABY 222: STABS 33 ZHIVYH 0
222 --sintaksis: rc=0
198 --repo .: rc=0
REPO_CELLS=12 FAILURES=0
198 --model: rc=0
CELLS=28 FAILURES=0
198 --stabs: rc=0
STABS=17 CAUGHT=17
104 battery_stubs.sh: rc=0
стаб-пак: 17/17 поймано
173 --model: rc=0, 19 ZELENO
173 --stabs: rc=0, 10 стабов пойманы
fixtures/check_fork_route/red_*.sh: все 11 rc=0
scripts/verify_antiplacebo.sh --scope check_fork_route: rc=0
барьеров: 1 · фикстур: 5 · предъявлено красным повторным прогоном: 5
scripts/check_provodka.sh . contracts/222-sudja-ljubaja-model.md: rc=0
scripts/pre_critic.sh contracts/222-sudja-ljubaja-model.md: rc=0
КРИТИК: дверь зелёная
scripts/check_sdacha.sh . contracts/222-sudja-ljubaja-model.md --run: rc=0
СДАЧА: лист зелёный (двери=10 карта=17/17 дельта=5)
```

## Дополнительные самостоятельные мутации

Изменения по отдельности в другом одноразовом клоне; после каждой испытуемый файл восстановлен. Усечение effort у `sud_same_model`: `--repo . --case verdict-effort-fact-truncated`, rc 1, `SUBJEKT 222: KLETKI 1 KRASNYH 1`. Приведение имени к нижнему регистру: `--repo . --case verdict-fact-case`, rc 1, `KLETKI 1 KRASNYH 1`.

Замена обеих сторон компаратора на `${1##*/}` / `${2##*/}` ошибочно отбрасывает провайдера у обеих полных моделей. Полная 222-батарея мутанта прошла: rc 0, `SUBJEKT 222: KLETKI 76 KRASNYH 0`. Но соседний `red_sud_model_173.sh --repo` rc 1, клетки `verdict_foreign_provider` и `fallback_foreign_provider` KRASNO. Это не дополнительный блок: обязательный соседний тест данный обход ловит. На конкретной клетке 222 `verdict-fact-case` та же мутация rc 0, что само по себе не доказательство, будто она задевает данный вход.
