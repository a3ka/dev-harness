accept
OBJECT=4448dd1554530c3bc6099e61535be3bc102b9798
СУД: repo=dev-harness; предмет=186; фаза=реализация v2 (РИСКОВЫЙ; scoped-повтор); роль=adversary; вызов=2/2 (санкция оркестратора); модель-план=по config/agent_models.json; сессия=Adv186Narrow; модель-факт=openai-codex/gpt-6.1-terra; SHA=4448dd1554530c3bc6099e61535be3bc102b9798; предыдущий=verdicts/adversary/contracts-186-impl-v2-vyzov1.md; исключение=нет

# Суд реализации 186: повтор по Н-1, Н-2, Н-3

Новых блокирующих нарушений в пределах заданной дельты не установлено. Н-1, Н-2, Н-3 на их предыдущих входах закрыты. Это не полный повтор суда: не исследован заново остаток Arb186V1 и неизменённые поверхности без нового риска; полный прогон отведён CI. Текущий результат CI независимо не проверялся.

Объект — SSH-клон `ssh://git@github.com/a3ka/dev-harness.git` с отдельным `.git`, detached на указанном SHA. `git log -3 --format='%h %an %s'`:
```
4448dd15 implementer 186 v+1: дверь L1 — поле модель-факт с левой границей, реестр от реального файла скрипта, алиас-цикл отказом
a163e3d9 architect 186 v+1: красные клетки вердикта Adv186Impl Н-1/Н-2/Н-3 и стабы wrong_field/symlink_cwd_registry/alias_terminal
8b86533f implementer 186 v+1: ролевые нормы называют назначение роли critic реестром
```
Судья не является автором данных коммитов; совпадение модели не запрещено контрактом 166. `git diff --exit-code 'frozen/contracts/186/2^{commit}' 4448dd1554 -- contracts/186-hranitel-arhitektury.md` → rc 0. Дельта implementer-коммита — только `scripts/merge_architecture_pr.sh`; батарея изменена предыдущим коммитом architect (новые клетки/стабы, перезаякорение существующего стаба `skip_sud_fields` и правка контрольной модели).

## Живые проверки двери

`python3 adversary_scoped.py` в одноразовом клоне: каждая строка — отдельный Git toy `door_probe.world`, копия OBJECT-двери в `tmp/scripts/`, реестр в соседнем `tmp/config/`; fake GitHub фиксирует фактические аргументы merge. В N2 у ссылки соседний подложный реестр Terra, у файла двери реестр GLM; review несёт Terra. Это перепрогон условий предыдущего вердикта, не результат символьного чтения. Вывод:
```
l1_merge: rc=0 stdout='СЛИТО: a3ka/CompliorOS-architecture PR 42 head a802506004735b2a1ed298dea2e5fdb19937f7a9' stderr='' merge=['pr', 'merge', '42', '-R', 'a3ka/CompliorOS-architecture', '--merge', '--match-head-commit', 'a802506004735b2a1ed298dea2e5fdb19937f7a9']
field_renamed_foreign: rc=1 stdout='NO_CRITIC_ACCEPT_ON_HEAD' stderr='' merge=None
field_inside_other_name: rc=1 stdout='NO_CRITIC_ACCEPT_ON_HEAD' stderr='' merge=None
field_after_separator_spaces: rc=0 stdout='СЛИТО: a3ka/CompliorOS-architecture PR 42 head a802506004735b2a1ed298dea2e5fdb19937f7a9' stderr='' merge=['pr', 'merge', '42', '-R', 'a3ka/CompliorOS-architecture', '--merge', '--match-head-commit', 'a802506004735b2a1ed298dea2e5fdb19937f7a9']
alias_cycle_honest_fact: rc=1 stdout='CRITIC_MODEL_UNRESOLVED' stderr='' merge=None
alias_cycle_fact_alias: rc=1 stdout='CRITIC_MODEL_UNRESOLVED' stderr='' merge=None
alias_other_family_control: rc=0 stdout='СЛИТО: a3ka/CompliorOS-architecture PR 42 head d51439aed806a69637cc425c1f847a4996f84278' stderr='' merge=['pr', 'merge', '42', '-R', 'a3ka/CompliorOS-architecture', '--merge', '--match-head-commit', 'd51439aed806a69637cc425c1f847a4996f84278']
accept_other_head: rc=1 stdout='NO_CRITIC_ACCEPT_ON_HEAD' stderr='' merge=None
accept_author: rc=1 stdout='NO_CRITIC_ACCEPT_ON_HEAD' stderr='' merge=None
ci_red: rc=1 stdout='CI_NOT_GREEN_ON_HEAD' stderr='' merge=None
foreign_architecture_app: rc=1 stdout='CI_NOT_GREEN_ON_HEAD' stderr='' merge=None
paginated_red_run: rc=1 stdout='CI_NOT_GREEN_ON_HEAD' stderr='' merge=None
l2_without_owner: rc=1 stdout='L2_OWNER_APPROVAL_REQUIRED' stderr='' merge=None
l3_without_owner: rc=1 stdout='L3_OWNER_APPROVAL_REQUIRED' stderr='' merge=None
registry_missing: rc=1 stdout='CRITIC_MODEL_UNRESOLVED' stderr='' merge=None
no_accept: rc=1 stdout='NO_CRITIC_ACCEPT_ON_HEAD' stderr='' merge=None
N2_symlink: rc=1 stdout='NO_CRITIC_ACCEPT_ON_HEAD' stderr='' merge=None
N2_chain: rc=1 stdout='NO_CRITIC_ACCEPT_ON_HEAD' stderr='' merge=None
start: rc=0 stdout='СЛИТО: a3ka/CompliorOS-architecture PR 42 head 45b200b4f72742e299b086f5dbac1e2fd3ad9c22' stderr='' merge=['pr', 'merge', '42', '-R', 'a3ka/CompliorOS-architecture', '--merge', '--match-head-commit', '45b200b4f72742e299b086f5dbac1e2fd3ad9c22']
tabs: rc=0 stdout='СЛИТО: a3ka/CompliorOS-architecture PR 42 head 8685e1a6d885358e2f74e3932c4686d0aabe3e3d' stderr='' merge=['pr', 'merge', '42', '-R', 'a3ka/CompliorOS-architecture', '--merge', '--match-head-commit', '8685e1a6d885358e2f74e3932c4686d0aabe3e3d']
before_semicolon_space: rc=0 stdout='СЛИТО: a3ka/CompliorOS-architecture PR 42 head 8685e1a6d885358e2f74e3932c4686d0aabe3e3d' stderr='' merge=['pr', 'merge', '42', '-R', 'a3ka/CompliorOS-architecture', '--merge', '--match-head-commit', '8685e1a6d885358e2f74e3932c4686d0aabe3e3d']
double: rc=1 stdout='NO_CRITIC_ACCEPT_ON_HEAD' stderr='' merge=None
empty: rc=1 stdout='NO_CRITIC_ACCEPT_ON_HEAD' stderr='' merge=None
foreign_decoy: rc=1 stdout='NO_CRITIC_ACCEPT_ON_HEAD' stderr='' merge=None
semicolon_in_value: rc=0 stdout='СЛИТО: a3ka/CompliorOS-architecture PR 42 head 8685e1a6d885358e2f74e3932c4686d0aabe3e3d' stderr='' merge=['pr', 'merge', '42', '-R', 'a3ka/CompliorOS-architecture', '--merge', '--match-head-commit', '8685e1a6d885358e2f74e3932c4686d0aabe3e3d']
space_alias: rc=1 stdout='CRITIC_MODEL_UNRESOLVED' stderr='' merge=None
middle_at: rc=1 stdout='NO_CRITIC_ACCEPT_ON_HEAD' stderr='' merge=None
number: rc=1 stdout='CRITIC_MODEL_UNRESOLVED' stderr='' merge=None
array: rc=1 stdout='CRITIC_MODEL_UNRESOLVED' stderr='' merge=None
missing_readlink: rc=2 stdout='' stderr='DOOR_INFRA_ERROR: путь файла скрипта не разрешён' merge=None
```
`semicolon_in_value`: вход `модель-факт=zai/glm-5.3;foreign; SHA=<head>`; значение до разделителя равно назначенной модели. Это не демонстрация факта, отличного от назначения. Проверенный `middle_at` — реестр `vendor/@model`, а факт остался `zai/glm-5.3`, потому отказ ожидаем.

Дополнительно `python3 adversary_extra.py`: null действительно записан JSON null, пустые массивы являются ответами fake GitHub; `absent_gh` — исполняемая заглушка с rc 127, а `registry_before_gh` отслеживает любое обращение к gh отдельным маркером:
```
null rc= 1 stdout= 'CRITIC_MODEL_UNRESOLVED' stderr= '' merge= None gh_invoked= False
empty_reviews rc= 1 stdout= 'NO_CRITIC_ACCEPT_ON_HEAD' stderr= '' merge= None gh_invoked= False
empty_checks rc= 1 stdout= 'CI_NOT_GREEN_ON_HEAD' stderr= '' merge= None gh_invoked= False
absent_gh rc= 2 stdout= '' stderr= 'DOOR_INFRA_ERROR: gh pr view 42 -R a3ka/CompliorOS-architecture --json title,author,headRefOid,baseRefName:' merge= None gh_invoked= True
registry_before_gh rc= 1 stdout= 'CRITIC_MODEL_UNRESOLVED' stderr= '' merge= None gh_invoked= False
relative_link rc= 0 stdout= 'СЛИТО: a3ka/CompliorOS-architecture PR 42 head 154392ab6ef855e755e43472c4d76c33680528fd' stderr= '' merge= ["pr", "merge", "42", "-R", "a3ka/CompliorOS-architecture", "--merge", "--match-head-commit", "154392ab6ef855e755e43472c4d76c33680528fd"] gh_invoked= False
middle_at_match rc= 0 stdout= 'СЛИТО: a3ka/CompliorOS-architecture PR 42 head 154392ab6ef855e755e43472c4d76c33680528fd' stderr= '' merge= ["pr", "merge", "42", "-R", "a3ka/CompliorOS-architecture", "--merge", "--match-head-commit", "154392ab6ef855e755e43472c4d76c33680528fd"] gh_invoked= False
```
`relative_link` — относительный путь запуска и относительная цель симлинка. `middle_at_match`: факт и назначение обе `vendor/@model`; `@` внутри значения не является началом алиаса. Маркер gh в прочих случаях не установлен и не отражает сетевых вызовов.

## Атаки на проверку и позитивный контроль

`python3 adversary_mutants.py`: контрольная `door_control.py`, копия в toy-мире; 11 адресных клеток, среди них позитивные, Н-1/Н-2/Н-3, пустой реестр и отсутствие accept. Мутации по якорям самой батареи: снятие границы поля, путь ссылки вместо канонического, удаление проверки терминального алиаса, GLM-константа, отключение accept; а также процессы с кодами 1 и 127. `passed`/`failed` — число/имена клеток, соответствующих ожидаемым rc, причине, merge и ветке; не общая статистика батареи. Сырой вывод:
```
exit1 passed 0 failed ['l1_merge:rc1', 'field_renamed_foreign:rc1', 'field_inside_other_name:rc1', 'field_after_separator_spaces:rc1', 'symlink_foreign_registry:rc1', 'own_tree_foreign_neighbor:rc1', 'alias_cycle_fact_alias:rc1', 'alias_cycle_honest_fact:rc1', 'alias_other_family_control:rc1', 'registry_missing:rc1', 'no_accept:rc1']
exit127 passed 0 failed ['l1_merge:rc127', 'field_renamed_foreign:rc127', 'field_inside_other_name:rc127', 'field_after_separator_spaces:rc127', 'symlink_foreign_registry:rc127', 'own_tree_foreign_neighbor:rc127', 'alias_cycle_fact_alias:rc127', 'alias_cycle_honest_fact:rc127', 'alias_other_family_control:rc127', 'registry_missing:rc127', 'no_accept:rc127']
wrong_field passed 9 failed ['field_renamed_foreign:rc0', 'field_inside_other_name:rc0']
symlink_cwd_registry passed 10 failed ['symlink_foreign_registry:rc0']
alias_terminal passed 9 failed ['alias_cycle_fact_alias:rc0', 'alias_cycle_honest_fact:rc1']
stub_hardcode_glm passed 8 failed ['alias_cycle_fact_alias:rc1', 'alias_cycle_honest_fact:rc0', 'registry_missing:rc0']
skip_accept passed 6 failed ['field_renamed_foreign:rc0', 'field_inside_other_name:rc0', 'symlink_foreign_registry:rc0', 'own_tree_foreign_neighbor:rc0', 'no_accept:rc0']
```
Позитивный контроль честной двери — `l1_merge` выше, реальный двухродительский toy merge и один пинованный вызов. Ограничение: это адресная выборка и собственные повторения имеющихся мутаций, а не заявленные автором полные 101/95; эти числа здесь не подтверждаются. Сценарий отсутствующего readlink проверен заглушкой rc 127. Проверка по исходникам разрешает назначение до первого `gh`; маркером продемонстрировано отсутствие `gh` при неразрешимом алиасе. Наблюдений нарушения инварианта «сливать только при факт = полная назначенная строка реестра самой двери» нет.

Дополнительный позитивный контроль **честной эталонной реализации**, не мутанта:
```
$ python3 adversary_control.py
honest_control ok= True rc= 0 stdout= '' merge= ["pr", "merge", "42", "-R", "a3ka/CompliorOS-architecture", "--merge", "--match-head-commit", "5127ad7f1a24ceb2ae2510055db59f146b35f9ca"]
```
Оракул `door_probe.check` дополнительно проверил два родителя merge и head вторым родителем. Реестр OBJECT назначает adversary: `advisor → @gpt-terra → openai-codex/gpt-6.1-terra`; фактическая модель совпадает с назначением.
