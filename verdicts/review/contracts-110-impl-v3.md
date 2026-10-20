FAIL
OBJECT=dce75f00a513678acd4ad7bed43e662aba6947fb

# Reviewer, круг 3: реализация контракта 110 (done-волны)

Батарея: wip/110/architect@d41494b06. Реализация: wip/110/implementer@dce75f00a.
Находки (reslop): `/tmp/dev-harness-verify/Rev110r3/review.md` (status: ready).
Сборка судимого дерева W — по заданию: 9bb5beb30, поверх батарея d41494b06, поверх 4 файла
dce75f00a, `git init`. Чистая копия объекта P — `git archive dce75f00a`.

## Блокер — один

**Б4. Приёмка-судьи v2: `gen_ci_steps.sh --check` красный на самом объекте.** Тот же сбой
дал бы CI-шаг `check:gen-ci-steps-coherence`. Нарушено ПЕРЕСЕЧЕНИЕ контракта
«.github/workflows/ci.yml — производная регенерация после записи реестра».
Коммит dce75f00a поднял вес шага 110 в `registry/ci-steps.tsv` с 6 до 8, а ci.yml не
перегенерировал: последняя правка ci.yml — 953be6f26.

```
$ (P = git archive dce75f00a) bash scripts/gen_ci_steps.sh --check
gen_ci_steps: дрейф блока JOBS — побайтовое расхождение с генерацией из реестра
rc=1
$ (W) bash scripts/gen_ci_steps.sh --check            → rc=1 (тот же дрейф)
$ (git archive 953be6f26, родитель) gen_ci_steps --check → rc=0  ← дрейф внесён именно dce75f00a
$ (P) bash scripts/gen_ci_steps.sh --write            → rc=0
$ (P) bash scripts/gen_ci_steps.sh --check            → rc=0
$ (P) bash scripts/verify_ci_parity.sh                → rc=0 «расхождений: 0»
```

Это не обход двери, а красная обязательная строка приёмки: принять объект с красным
шагом CI нельзя. Починка — `gen_ci_steps.sh --write` и коммит ci.yml, зона implementer.
Меняются 6 строк `keys:`, семантика двери не затрагивается.

## Обходов двери (проба зелёная, тег ставится неверно) в пределах решённого — нет

- Проба (W): `bash fixtures/workshop_project/done_volny_110/probe.sh` → rc=0, «случаев 84,
  зелёных честных 17/17, отказных с именованной причиной 67/67».
- Матрица (W): `probe.sh --matrix` → rc=0, «mismatches=0»: у каждого из 62 мутантов ≥1 различающая клетка (493 с). Новые mn1/mn1b/mb3/mn2/mn3 убиты своими клетками.
- Б3 закрыт. Мир H из Rev110r2/own.sh, перезапущен как Rev110r3/own.sh: причина «#42 волна 3
  принята» → `[H] rc=0 out=v1`, refs done/waves: 1, аннотация `%(contents)` = «#42 волна 3
  принята» дословно.
- N1 в написании `bash e2e.sh` закрыт: миры U и I → rc=1 «команда не на HEAD: e2e.sh».
- Гонка R: peeled == H0. Корень-symlink S: rc 0. Не-ASCII находка Q: отказ по HEAD.
- Совет С13 (решать оркестратору/architect, не блокер против реализации). Написания `./e2e.sh`,
  `bash -x e2e.sh`, `sh -e e2e.sh`, `bash -c "bash e2e.sh"` при неотслеживаемом e2e.sh дают
  rc=0 и тег v1, хотя e2e на чистом HEAD красная (127/127/2/127). Так ведут себя и дверь, И
  модель architect: решение (a) объявлено как «первый токен после интерпретатора», а И-5
  контракта не требует, чтобы код e2e был на HEAD. Если N1 должен быть закрыт по существу,
  нужна клетка `./e2e.sh` и расширение грамматики (a).

## Область, неизменность, проверки не переписаны

- implementer (9bb5beb30..dce75f00a): ровно `scripts/done_wave.sh package.json
  registry/ci-steps.tsv .github/workflows/ci.yml` — это зона из frozen-блоба. В package.json
  добавлен +1 ключ 110, в ci-steps +1 строка 110 — оба в пределах ПЕРЕСЕЧЕНИЙ. Все 6 коммитов
  от implementer; батарею implementer не трогал (`git diff --quiet frozen/contracts/110/1
  dce75f00a -- fixtures/…done_volny_110/` rc 0).
- architect (9bb5beb30..d41494b06): 3 файла под `fixtures/workshop_project/done_volny_110/`.
  Контракт байтово = frozen/contracts/110/1 (`git diff --quiet` rc 0).
- Своя мера (`sub.py`): блок CASES заморозки (17193 байт, 52 клетки) — байтовая подстрока
  нового probe.py; клеток 84, мутантов 62 (m 31, md 13, ma 5, mb 2, me 6, mn 5). Хелперы
  заморозки не изменены. Old-литералы шести старых мутантов следуют за правкой модели
  (HEAD: → ${HEAD_SHA}:) — совет С14, подмена у них та же.

## Регресс (scoped, W)

```
verify_antiplacebo.sh --scope verify_ci_parity check_provodka → rc=0 (54/54 красным повтором)
gen_ci_steps.sh --check                                       → rc=1  ← Б4
verify_ci_parity.sh                                           → rc=0 расхождений: 0
fixtures/workshop_project/done_volny_110/provodka.sh          → rc=0
check_provodka.sh . contracts/110-done-volny.md               → rc=0
```

## Советы (не блокируют; подробно — в review.md)

С1 (tagger прибит «Implementer»), С2 (GIT_CONFIG_GLOBAL=/dev/null наследует e2e), С3 (метрика
«.»), С9 (фразы клеток — от architect, не из контракта), С10' (шапка: «вес 6, 6.0..6.5 с» при
реестре 8; разбивка мутантов в ci-steps «…+18 mmm» неверна, итог 62 верен), С11 (пустая
причина отклоняется ПОСЛЕ A3/профиля, вопреки И-8 и модели; тега нет, refs неизменны),
С12 (ветка symlink профиля без клетки и мутанта — ACCIDENTAL-совет), С13 (N1-написания), С14.

Что нужно для accept: перегенерированный и закомиченный ci.yml (`gen_ci_steps --check` rc 0)
на новом SHA. Остальное — на усмотрение оркестратора.
