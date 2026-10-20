accept
OBJECT=0100eddbf181a6ff87f333a89af263730f723402

Критик 996 v2 (док-правка, режим проекта). Предмет — ТОЛЬКО 5 добавленных строк
contracts/996-rezhim-proekta-polnyj-cikl.md:156-160 на HEAD 0100eddbf (architect/architect).
Клон: git clone /tmp/dev-harness-worktrees/c907157c/wip-996-architect /tmp/dev-harness-verify/Critic996v2/h

## 0. Разница к frozen v1 — только добавления
$ git diff frozen/contracts/996/1^{commit} HEAD --numstat -- contracts/996-rezhim-proekta-polnyj-cikl.md
5	0	contracts/996-rezhim-proekta-polnyj-cikl.md
$ git show --stat HEAD → 1 file changed, 5 insertions(+) (только контракт)
Добавлено: :156 замер-строка; :157-160 четыре строки ПОТРЕБИТЕЛЬ. Ни одной удалённой/изменённой
строки: предмет, критерии, ЗОНА, ПРОВОДКА (role-строки + guard=fixtures/workshop_project/rezhim_996/probe.sh)
побайтово те же, что в frozen/contracts/996/1 → (4) поведение/критерии/инварианты/пробы rezhim_996 в
контракте НЕ изменены, v2-заморозка не требуется по этому основанию.

## 1. Строки называют реальные пробы реальных потребителей (сверка с реестром)
$ cat scripts/consumers.d/*.tsv
scripts/done_contract.sh	scripts/check_spec_ready.sh
scripts/freeze_contract.sh	fixtures/check_check_contract_ready/
scripts/freeze_contract.sh	fixtures/drill_contract_change/
scripts/freeze_contract.sh	scripts/spawn_agent.sh
scripts/lib_registry.sh	scripts/check_spec_ready.sh
scripts/lib_registry.sh	scripts/spawn_agent.sh
Тронутые писатели окна frozen/contracts/996/1..HEAD (все коммиты — свои ленды wip/996/implementer,
author/committer implementer, не исключаются):
$ git log --no-merges --format=%h frozen/contracts/996/1..HEAD -- scripts/freeze_contract.sh → 0939a103c 734cad7be edb0cc20e
$ … -- scripts/done_contract.sh → 0939a103c b9250524d 734cad7be 845589ee3 edb0cc20e
$ … -- scripts/lib_registry.sh → (пусто) — не тронут, строки не нужны
Требуемые пары: freeze→{check_check_contract_ready/, drill_contract_change/, spawn_agent.sh}, done→{check_spec_ready.sh}
= ровно 4 строки :157-160, пути потребителей совпадают с реестром побайтово (гейт матчит sed по пути).
Пробы запущены живьём в cwd клона:
$ bash fixtures/check_check_contract_ready/doc_048/probe_zhivoy_vyzov_048.sh → «check_check_contract_ready: ветви «all» зелены» rc=0
  (exec scripts/check_check_contract_ready.sh — живой вызов барьера семьи-потребителя)
$ bash scripts/verify_antiplacebo.sh --scope drill_contract_change → барьеров 1 · фикстур 1 · красным 1, rc=0
$ bash scripts/verify_antiplacebo.sh --scope spawn_agent → барьеров 1 · фикстур 2 · красным 2, rc=0
  (case_octal_sdvig_znachenija проходит гейт 3в spawn_agent.sh:223 — ls-remote refs/tags/frozen/contracts/<NNN>/*)
$ bash scripts/verify_antiplacebo.sh --scope check_spec_ready → барьеров 1 · фикстур 8 · красным 8, rc=0
Форма строк — прецедент замороженных 038:567-570 / 060:337-340 / 992:66-69 (строка check_spec_ready — вариант 038).

## 2. Census-замер `= 6` верен другой мерой
$ ls scripts/consumers.d/*.tsv | wc -l → 6
$ for f in scripts/consumers.d/*.tsv: awk 'END{print NR}' → 1 1 1 1 1 1 (сумма 6)
$ cat scripts/consumers.d/*.tsv | wc -l → 6
$ git ls-tree -r --name-only frozen/contracts/996/1 -- scripts/consumers.d/ → 6 tsv + .probe-only (маркер, не tsv);
  git log frozen/contracts/996/1..HEAD -- scripts/consumers.d/ → пусто (реестр в окне не менялся).
Строка :156 побайтово под census_pattern check_consumers.sh (п1-b активен: на frozen-теге consumers.d непуст).

## 3. check_consumers rc0 — как зовёт done_contract.sh шаг 6а (done_contract.sh:208: bash check_consumers.sh "$ROOT" "$contract_rel")
$ bash scripts/check_consumers.sh . contracts/996-rezhim-proekta-polnyj-cikl.md → rc=0 (19.7 с)
Не вакуум — отрицательные контроли в scratch-клоне (коммиты поверх 0100eddbf, теги frozen подтянуты):
(a) удалена строка :159 (spawn_agent) →
    «потребители 116: писатель scripts/freeze_contract.sh изменён, потребитель scripts/spawn_agent.sh не верифицирован: нет ПОТРЕБИТЕЛЬ-пробы» rc=1
(b) удалена строка :156 (замер) →
    «потребители 116: замер маппинга отсутствует (контракт правит писателя scripts/freeze_contract.sh scripts/done_contract.sh)» rc=1
    (подтверждает: тронутые писатели = freeze_contract.sh + done_contract.sh, окно НЕ пустое)
(c) :160 заменена на `ПОТРЕБИТЕЛЬ scripts/check_spec_ready.sh: exit 1` →
    «потребители 116: ПОТРЕБИТЕЛЬ-проба красна: scripts/check_spec_ready.sh: rc 1» rc=1

## 4. Находки
Блокирующих нет: не найдено состояния дерева, при котором :156-160 зелёны, а зарегистрированный
потребитель тронутого писателя не исполнен — гейт исполняет каждую пробу (контроль c), требует
каждую пару (контроль a) и замер (контроль b).

СОВЕТ contracts/996-rezhim-proekta-polnyj-cikl.md:159 — `--scope spawn_agent` исполняет только
case_*.sh (2 шт.); fixtures/spawn_agent/red_gejt_stroka_frozen_sha.sh — единственная фикстура,
проверяющая потребление spawn_agent.sh именно frozen-строки реестра писателя freeze_contract.sh
(036-г5б) — классом red_* в scoped-прогон verify_antiplacebo не входит (verify_antiplacebo.sh:218-231),
и в registry/ci-steps.tsv отдельного раннера для fixtures/spawn_agent/red_* не найдено (grep пуст).
Это свойство нормы 038 (та же строка заморожена в 038:568, 060:339, 992:68), не дефект 996 v2;
автор отвечать не обязан. Обход для 996 не называется: писатель в окне менял путь реестра
(freeze_contract.sh:527-541, профильный _PROFILE_REGISTRY_PATH, fail-closed :90-96), а spawn_agent.sh
читает MANIFEST_REG тем же профилем (:176/:191) — связка писатель→потребитель вне предмета этого круга.

СОВЕТ contracts/996-rezhim-proekta-polnyj-cikl.md:160 — для check_spec_ready взят вариант 038
(`verify_antiplacebo --scope`), тогда как 029/060/992 зовут `check_spec_ready.sh . contracts/<свой>.md`
(живой вызов потребителя на самом контракте). Оба прецедента заморожены; вкус.

Вердикт: accept. Текст роли critic не трогал. Клоны /tmp/dev-harness-verify/Critic996v2/{h,scratch} удалены после записи.
