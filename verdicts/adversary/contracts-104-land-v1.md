FAIL

# Вердикт adversary: контракт 104, land-v1

Проверен PR #97, head `6c366f54a802e52a5a681c5189954771017fcb26`
(`wip/104/implementer2`). Блоб
`contracts/104-uzkij-doverennyj-gejt-sudi.md` на head совпадает с
`frozen/contracts/104/1`, frozen-тег — предок head. Репро — в одноразовом
SSH-клоне `/tmp/dev-harness-verify/adversary-104-pr97-*`; push не выполнялся.

## BLOCKS — A104-1: батарея не отличает дверь судьи, зашитую на `critic`

`check_sud_model.sh` судит замкнутый алфавит из четырёх ролей: `critic`,
`adversary`, `reviewer`, `arbiter` (Демаркация 104). Но все позитивные и
негативные вызовы трёх ног двери в семье `fixtures/zashchita_main_104/`
используют только `critic`:

- `red_sud_model_dver_spavna.sh` — только `--spawn critic` и `--frontmatter critic`;
- `red_sud_model_materializatsija.sh` — только `--verdict critic`
  (строки `adversary` во входе 3 — лишь «чужая роль в трассе», спрашивается
  всё равно `critic`);
- `red_judge_gate_svidetelstvo_sudi.sh` — только `--sud critic …`.

Мигрированная регрессия 098 покрытие не расширяет: единственный построитель
свидетельства `_d98_sud` в `fixtures/dokazatelstva_098/_mir.sh` всегда
печатает `--sud critic`.

### Исполненная заглушка («зашитая константа»)

В одноразовом клоне вместо `check_sud_model.sh` подложен адаптер: для каждого
вызова `--spawn`, `--frontmatter` или `--verdict` он заменяет второй argv
(заявленную роль) литералом `critic` и затем исполняет НАСТОЯЩИЙ
`scripts/check_sud_model.sh`. Реализация неверна: честный `reviewer` не может
материализовать вердикт, а судья любой роли судится по тиру `critic`.

Против заглушки обе реальные батареи — полностью зелёные:

```text
D104_SUBJECTS_DIR=/tmp/dev-harness-verify/adversary-104-hardcode \
  bash fixtures/_krasnye_104.sh
# стаб-пак: 13/13 поймано; 6/6 клеток ЗЕЛЕНО; клеток просмотрено: 6; ИТОГ 104: rc=0

D98_SUBJECTS_DIR=/tmp/dev-harness-verify/adversary-104-hardcode/subjects \
  bash fixtures/_krasnye_098.sh
# ИТОГ стаб-пак 098: rc=0 (s1…s21 ПОЙМАН); 18 клеток rc=0; ИТОГ 098: rc=0
```

Позитивный контроль (честный субъект, конформная 5-полевая трасса reviewer
на `anthropic/claude-opus-5-5` allowed — тир `audit`):

```text
bash scripts/check_sud_model.sh --verdict reviewer --trace reviewer.tsv \
  --object 22cb801bb0ede34ee992a76bac5aa7eb72d99112 --session S1
СУДЬЯ СВОЕЙ МОДЕЛИ: вердикт reviewer материализуется
# rc=0
```

Та же трасса через заглушку — ложный отказ:

```text
ОТКАЗ: трасса без строки роли: critic
# rc=1
```

Значит, дефект в проверке, не в заглушке: батарея принимает реализацию,
отвечающую «правильно не на тот вопрос» (о `critic`, а не о роли вызова).
Симметричная порча — тир `critic` (`apex`) для любой роли — тоже не видна
ни одной клетке, поскольку никакая другая роль не предъявляется. Цель
контракта — свидетельство модели/сессии/объекта для ВСЕХ судей; для
`reviewer`/`adversary`/`arbiter` оно не доказано. Сама реализация
(`scripts/check_sud_model.sh`) на reviewer работает верно — блокер в
доказательстве, зона architect (`fixtures/zashchita_main_104/`).

### Необходимое закрытие

1. `--spawn`/`--frontmatter`: честная и чужая модель/тир хотя бы для одной
   не-`critic` роли (лучше — для всех трёх: `adversary`, `reviewer`, `arbiter`);
2. `--verdict`: честная 5-полевая трасса не-`critic` роли → rc 0; её же
   строка, спрошенная от имени другой допустимой роли, → rc 1;
3. `judge_gate --verdict-row --sud`: хотя бы один не-`critic` сценарий с
   литеральной сверкой argv двери;
4. стаб-пак: порча «любая роль → `critic`», пойманная ровно новым
   не-`critic` входом (rc 1), при зелёном честном каркасе.

## Исполненные пробы без находки

- **Инструмент мимо PATH:** `env -i PATH=/nonexistent bash scripts/check_sud_model.sh
  --spawn critic openai-codex/gpt-6-astra` → `NOT_IMPLEMENTED: нет jq`, rc=2
  (не успех).
- **Пустой вход:** пустая TSV-трасса для `--verdict critic` →
  `ОТКАЗ: трасса без строки роли: critic`, rc=1.
- **Нейтрализация свидетельства:** стаб `t104-m11` (judge_gate пишет строку
  без `--sud`) пойман клеткой `red_judge_gate_svidetelstvo_sudi.sh`; m1–m13
  пойманы каждый своей клеткой.
- **Позитивный контроль честного дерева:** `bash fixtures/_krasnye_104.sh`
  rc=0 (13/13, 6/6); `bash fixtures/_krasnye_098.sh` rc=0 (21/21, 18/18);
  `bash fixtures/_krasnye_095.sh` rc=0; `bash scripts/check_judge_gate.sh` rc=0.

## Наблюдение (не блокер)

Хук `spawn-guard.ts` на `{toolName:"task", input:{tasks:[]}}` возвращает
`undefined` (пропуск): пустой batch не судится. Агента он не создаёт, поэтому
обхода Н-270 не даёт; клетки И-1 этот вход не предъявляют.
