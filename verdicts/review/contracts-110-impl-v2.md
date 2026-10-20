FAIL
OBJECT=530e8a4a64087ffb44bab909224b466ee1911657

# Суд реализации 110 (done волны), круг 2 — Rev110r2

Находки (reslop, status: ready): `/tmp/dev-harness-verify/Rev110r2/review.md`. Блокер один:
Б3, с названным обходом. Б1/Б2 круга 1 закрыты, С4 закрыт. С1/С2/С3/С5 остаются советами,
новые советы С7–С12.

## Блокер

**Б3 — И-8, контракт 050.** `scripts/done_wave.sh` отказывает непустой причине, если все её
строки начинаются с `#` (`NON_COMMENT=…; [ -n "$NON_COMMENT" ] || die "причина пуста (только
комментарные строки)"`). Отказ срабатывает после NFR/e2e.
**Обход:** дерево W. Критерий выполнен: probe 71/71 rc 0, matrix mismatches=0. Мир `own.sh` H
— честная волна с причиной `#42 волна 3 принята`. Дверь отвечает rc 1 «причина пуста», тега
нет. Эталон model на том же мире — rc 0 v1, причина в аннотации.
**Более простая форма:** удалить две строки, `--cleanup=verbatim` оставить. Дерево W2 даёт
probe rc 0, 71/71.

## Сырые команды и rc

Сборка W: archive 9bb5beb30, поверх 32e3f3790 (fixtures 110 + контракт), поверх 530e8a4a6
(4 файла зоны), `git init`.

```
# ПРИЁМКА-СУДЬИ v2 (дерево W)
bash fixtures/workshop_project/done_volny_110/probe.sh            → rc=0 «ИТОГ: случаев 71, зелёных честных 14/14, отказных с именованной причиной 57/57» (real 6.24 s)
bash fixtures/workshop_project/done_volny_110/probe.sh --matrix   → «mismatches=0», 50 строк «МУТАНТ», ~300 s (rc не снят: фоновой задачей вернулся только вывод)
bash scripts/verify_antiplacebo.sh --scope verify_ci_parity check_provodka → rc=0 «барьеров: 2 · фикстур: 54 · предъявлено красным повторным прогоном: 54»
bash scripts/gen_ci_steps.sh --check                              → rc=0
bash scripts/verify_ci_parity.sh                                  → rc=0 «… расхождений: 0»
bash fixtures/workshop_project/done_volny_110/provodka.sh         → rc=0
bash scripts/check_provodka.sh . contracts/110-done-volny.md      → rc=0
# неизменность frozen (основной репо, только чтение)
git diff --exit-code 'frozen/contracts/110/1^{commit}' 32e3f3790 -- contracts/110-done-volny.md → rc=0
git diff --exit-code 'frozen/contracts/110/1^{commit}' 530e8a4a6 -- contracts/110-done-volny.md → rc=0
python3 cmp/bytes.py   → contract bytes equal W vs frozen: True; frozen CASES block (52 cells) 17192 байт — подстрока нового probe.py с той же позиции: True; provodka.sh equal: True
python3 cmp/cmp.py     → old cases 52 new 71; old mut 31 new mut 50; first52 equal by value True; константы равны; старые мутанты: только якорь HEAD→${HEAD_SHA}
# область
git diff --stat 9bb5beb30 530e8a4a6 → .github/workflows/ci.yml, package.json, registry/ci-steps.tsv, scripts/done_wave.sh (4 файла = ЗОНА implementer)
git diff --name-only 9bb5beb30 32e3f3790 → 3 пути в fixtures/workshop_project/done_volny_110/ (⊆ ЗОНА architect)
per-commit: b4b7e0674 — 4 файла зоны; c60d3f668, 8ca324644, 530e8a4a6 — только scripts/done_wave.sh; автор implementer; 32e3f3790 — автор architect
# красное
W3 (реализация круга 1 + батарея круга 2): probe.sh → rc=1 «зелёных честных 12/14, отказных 53/57», красные a1 a1b a2 a3 a4 b1
decoys_r2.py (13 заглушек Adv110 на батарее круга 2): каждая probe rc=1; своей d*-клеткой пойманы D2 D3 D7 D12 D13 D14 D15 D16 D22 D23 D25 D29 D31
W2 без строки «НЕ БАРЬЕР:»: verify_antiplacebo.sh --scope verify_ci_parity → rc=1 «FAIL done_wave.sh: не классифицирован», «расхождений: 1»
# свои миры (own.sh, против W/scripts/done_wave.sh)
R race (параллельный коммит 083 во время e2e) → rc=0 v1; H0=58e1a02c… == peeled=58e1a02c…   (Б1 закрыт)
U e2e.sh неотслеживаемый, на HEAD нет            → rc=0 v1   (С7)
I e2e.sh в .gitignore                           → rc=0 v1   (С7)
H причина «#42 волна 3 принята»                 → rc=1 «причина пуста (только комментарные строки)», refs done/waves: 0; модель → rc=0 v1   (Б3)
D метрика «.» при le 10                         → rc=0 v1   (С3)
E e2e проверяет GIT_CONFIG_GLOBAL               → rc=1 «сквозной запуск волны красный: rc=1»   (С2)
A честная волна                                 → rc=0 v1; type=tag; peeled == HEAD; tagger=Implementer <implementer@dev-harness.local>   (С1)
Q грязная не-ASCII находка (HEAD ready)         → rc=1 «рабочее дерево расходится с HEAD: ".review/\320…"» вместо отказа по HEAD   (С8)
S корень — symlink на вершину                   → rc=0 v1
# простая форма Б3
W2 (без NON_COMMENT): probe.sh → rc=0 «случаев 71, зелёных честных 14/14, отказных с именованной причиной 57/57»
# вес CI
/usr/bin/time probe.sh ×3 → 6.28 / 6.27 / 5.80 s (16 ядер); вес в ci-steps.tsv = 5   (С10)
```

## Пункты роли

1. Область. Реализация ⊆ ЗОНА implementer, architect ⊆ ЗОНА architect. Пересечения
   соблюдены: в package.json и ci-steps только добавления, ci.yml регенерирован. Принято.
2. Сырой вывод. Всё выше — мои прогоны. Отчётам implementer/architect я не верил.
3. Проверка не переписана под реализацию. Контракт и 52 клетки байтово равны frozen.
   Implementer фикстуры не трогал. В 530e8a4a6 фразы кода подогнаны под клетки, обратного
   направления нет. Совет С9: клетки a1/a1b/a2/a3 закрепляют фразы, которых нет в контракте.
4. Красное предъявлено. Новые клетки красные на реализации круга 1 и на 13 заглушках Adv110.
   Матрица — 50 мутантов, mismatches=0. Б2 красный без строки шапки.
5. Атомарность. Все 4 коммита implementer относятся к одному предмету 110 и разбиты по
   кругам, автор `implementer`. У architect один коммит, автор `architect`.
6. Норма не тронута: roles/, AGENTS.md и контракт не менялись.
7. Заявленное равно сделанному — по моей мере (python-импорт CASES/MUTANTS, подсчёт строк
   «МУТАНТ»): 71 = 52 + 19, 14 ok / 57 refuse, 50 = 31 + 19. Совпадает с заявленным.

§Предмет реализован: в моих мирах A, R и S дверь ставит аннотированный тег на снятый HEAD с
причиной в аннотации. На refuse-мирах отказ именованный, refs не меняются. Проводка 038:
guard probe.sh подключён ключом → ci-steps → ci.yml, provodka.sh и check_provodka дают rc 0.
Регресс antiplacebo и CI-паритета: rc 0.

## Паразитная сложность (контракт 050)

- `scripts/done_wave.sh`, раздут против круга 1. Новые ветви: A3 toplevel, HEAD_SHA, цикл
  профиля A2, проверка грязного дерева со списком HEAD_SOURCES, REASON_FILE + verbatim,
  NON_COMMENT, отказ на символическую ссылку профиля.
  (1) A3/A2/A1 — клетки a3/a2/a1/a1b (вердикты impl-v1). HEAD_SHA — И-8. verbatim — И-8
  «причина в аннотации». NON_COMMENT — свойства нет (Б3). Ветке символической ссылки
  профиля свойства тоже нет (С12).
  (2) Состояние — только ref тега, видно по stdout `v<N>` и rc. Неявная часть — по-прежнему
  GIT_CONFIG_*=/dev/null (С2).
  (3) Число файлов при правке того же свойства не выросло: дверь + probe.py + model.
  (4) Интерфейс прежний (3 аргумента, rc 0/1/2, env не читается), работа выросла — модуль
  углубился.
  (5) Потребитель — probe.sh, строка 4 приёмки, CI-step. Логика lib_plan повторяется (С5).
  Вывод: ESSENTIAL, кроме NONCOMMENT (ACCIDENTAL, блок Б3), HEAD_SOURCES + porcelain
  (кандидат в ACCIDENTAL, С8, простая форма не проверена — совет) и символической ссылки
  (С12, совет).
- `probe.py` — новые ключи спеки extra_files/rm_files/root_suffix/allow_moved_branch,
  refnames_only, необязательные manifest2/flow.rm_files; семья из 19 клеток и 19 мутантов.
  (1) Вердикты impl-v1 через И-1…И-8. (2) Состояние явное, в спеке клетки. (3) Клетка, мутант
  и модель меняются вместе — как и раньше. (4) Ключи по умолчанию нейтральны для старых
  клеток. (5) Потребитель — строки 2–4 приёмки. ESSENTIAL.
- `model/done_wave_model.sh` (+46 строк). (1) Эталон для матрицы. (2)–(5) как в круге 1.
  ESSENTIAL.
- package.json / ci-steps.tsv / ci.yml не изменились с круга 1, ESSENTIAL. Вес и комментарий
  устарели — С10.

Чтобы закрыть круг, нужен Б3 на новом OBJECT и повтор probe 71/71 и `own.sh` H (rc 0 v1,
причина в аннотации). Рекомендую architect добавить клетку «причина с #» (ok) и мутант,
восстанавливающий NON_COMMENT.
