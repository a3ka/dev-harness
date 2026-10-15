# Вердикт adversary: контракт 104, land-v3

**ACCEPT.** Фокусная перепроверка PR#97 на назначенной голове
`b442d7ac10b1bae6e9d0611065a327458ba2e4ea` не нашла регрессии 104 после
`rebase --onto` и последующего sync-merge. Это отдельный круг только для
закрытий топологии Рв97-12/Рв97-13 и регрессии батареи; содержательные
закрытия Рв97-3/A104-1, принятые в land-v2, заново по существу не судились.

## Доставка

Проверено на SSH-клоне, затем на назначенном tip:

```text
$ git merge-base --is-ancestor frozen/contracts/104/1 origin/wip/104/implementer2
# rc=0

$ gh pr view 97 --json headRefOid,mergeable,mergeStateStatus,state
{"headRefOid":"b442d7ac10b1bae6e9d0611065a327458ba2e4ea","mergeStateStatus":"UNSTABLE","mergeable":"MERGEABLE","state":"OPEN"}
```

Следовательно, frozen-тег снова является предком головы ветки, а PR механически
сливаем (`mergeable: MERGEABLE`). `UNSTABLE` не означает конфликт: GitHub
сообщает, что проверки/статус ещё нестабильны.

`bash scripts/check_contract_frozen.sh` также завершился `rc=0`; для
`contracts/104-uzkij-doverennyj-gejt-sudi.md` напечатано, что v1 заморожен и
блоб совпадает побайтово.

## Регрессия обманных субъектов

Дважды на новом tip исполнена полная батарея:

```text
$ bash fixtures/_krasnye_104.sh
стаб-пак: 17/17 поймано
клеток просмотрено: 6
ИТОГ 104: rc=0
# rc=0 (оба запуска)
```

Каждая из семнадцати селективных заглушек была поймана своей клеткой. В
частности, сохраняются именно мутанты круга 2, закрывающие Рв97-3/A104-1:

| Мутант | Неверное поведение | Ловящая клетка |
|---|---|---|
| `t104-m14` | `--spawn`/frontmatter берёт тир `critic` для любой роли | `red_sud_model_dver_spavna.sh` |
| `t104-m15` | `--verdict` берёт тир `critic` для любой роли | `red_sud_model_materializatsija.sh` |
| `t104-m16` | `judge_gate` передаёт двери константу `critic` | `red_judge_gate_svidetelstvo_sudi.sh` |
| `t104-m17` | судится только первая строка роли | `red_sud_model_materializatsija.sh` |

Остальные классы также не прошли: отказ/пустой ввод и отсутствие входных
субъектов (`m1`–`m7`, `m11`–`m13`), чужая роль/объект/сессия (`m8`, `m9`),
зашитое разрешение любого denied-фолбэка (`m10`). Это не «всегда красный»
прогон: полный пакет завершился зелёным только потому, что его клетки отвергли
каждый неверный субъект.

## Позитивные контроли

Честная отдельная трасса reviewer прошла настоящую дверь:

```text
$ bash scripts/check_sud_model.sh --verdict reviewer \
    --trace tmp/adv104r3/reviewer.tsv \
    --object 22cb801bb0ede34ee992a76bac5aa7eb72d99112 \
    --session S1 --root .
СУДЬЯ СВОЕЙ МОДЕЛИ: вердикт reviewer материализуется
# rc=0
```

Она содержит ровно строку `reviewer / anthropic/claude-opus-5-5 / allowed`
с той же сессией и объектом. Дополнительно настоящий шлюз CI сохранил обе
ветви:

```text
$ bash scripts/check_judge_gate.sh
… красный CI → judge_gate RC≠0, звал check_ci_gate
… зелёный CI → judge_gate RC=0 + «OK» + передал sha=GOOD-SHA-…
check_judge_gate: ветви «all» зелены
# rc=0
```

Итак, sync-merge не сломал ни позитивную ветку reviewer, ни селективное
отклонение 17 обманных реализаций. Рв97-12 и Рв97-13 закрыты наблюдаемыми
топологическим и PR-предикатами; нового дефекта проверок 104 в заданном
фокусе не найдено.
