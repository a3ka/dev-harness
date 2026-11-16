#!/usr/bin/env python3
"""Isolated Git worlds: real baseline diff, fake GitHub network, observed merge argv.

186 v+1 (слово владельца 2026-11-16 ~12:20 UTC): ожидаемая модель критика —
НАЗНАЧЕНИЕ роли critic в toy-реестре харнесса двери (tmp/config/agent_models.json),
не семейство GLM; оракул (resolve_critic в памяти) заморожен ДО вызова субъекта.
Контроль и субъект исполняются из изолированной install-копии рядом с реестром
(tmp/control.py, tmp/scripts/merge_architecture_pr.sh); живой реестр харнесса
батареей не читается, перестановки реестра правки кода не требуют.
Клетки Н-1/Н-2/Н-3 (вердикт Adv186Impl): чужое имя поля / симлинк с чужим
соседним реестром / алиас-цикл назначения — честная дверь отказывает без
слияния; стабы wrong_field, symlink_cwd_registry, alias_terminal (и привязки
тех же мутаций ко вторым входам) ловятся каждая своим входом (Н-39).
"""
import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

HERE = Path(__file__).resolve().parent
DEFAULT_REPO = HERE.parents[2]
REPO = 'a3ka/CompliorOS-architecture'

FAKE_GH = '''#!/usr/bin/env python3
import json, os, pathlib, sys
state = json.loads(pathlib.Path(os.environ['TOY_STATE']).read_text())
args = sys.argv[1:]
if args[:2] == ['pr', 'view']:
    print(json.dumps(state['pr']))
elif args == ['api', 'user']:
    print(json.dumps({'login': state['operator']}))
elif args[:2] == ['api', 'repos/a3ka/CompliorOS-architecture/pulls/42/reviews']:
    print(json.dumps(state['reviews']))
elif args[0] == 'api' and ('repos/a3ka/CompliorOS-architecture/commits/' + state['pr']['headRefOid'] + '/check-runs') in args[1:]:
    pages = state.get('check_pages')
    if pages and '--paginate' in args:
        for page in pages:
            print(json.dumps(page))
    elif pages:
        print(json.dumps(pages[0]))
    else:
        print(json.dumps({'check_runs': state['checks']}))
elif args[:2] == ['pr', 'merge']:
    import subprocess
    sha = state['pr']['headRefOid']
    if '--match-head-commit' in args and args[args.index('--match-head-commit') + 1] != sha:
        sys.exit(41)
    subprocess.run(['git', 'switch', '-q', 'main'], check=True)
    subprocess.run(['git', '-c', 'user.name=station-orchestrator',
                    '-c', 'user.email=station@dev-harness.local',
                    'merge', '-q', '--no-ff', 'pr-42', '-m', 'Merge toy architecture PR'],
                   check=True)
    pathlib.Path(os.environ['TOY_MERGE_LOG']).write_text(json.dumps(args))
else:
    print('unexpected gh: ' + repr(args), file=sys.stderr)
    sys.exit(43)
'''
FAKE_NPM = '''#!/usr/bin/env python3
import json, pathlib, sys
from pathlib import Path
args = sys.argv[1:]
if args != ['run', 'check', '--', '--base', 'governance/baseline/approved.json', '--report']:
    print('unexpected npm: ' + repr(args), file=sys.stderr)
    sys.exit(43)
base = json.loads(Path('governance/baseline/approved.json').read_text())
current = json.loads(Path('governance/current.json').read_text())
mismatches = [key for key in sorted(set(base) | set(current)) if base.get(key) != current.get(key)]
print(json.dumps({'baselineStatus': 'PASS' if not mismatches else 'FAIL',
                  'findings': [{'code': 'BASELINE_MISMATCH', 'section': section}
                               for section in mismatches],
                  'contractReadiness': {'incompatibleContracts': []}}))
sys.exit(2)
'''


TOY_MODELS = {'glm': 'zai/glm-5.3', 'gpt-terra': 'openai-codex/gpt-6.1-terra',
              'gpt-sol': 'openai-codex/gpt-6.1-sol', 'gpt-astra': 'openai-codex/gpt-6-astra',
              'gpt-luna': 'openai-codex/gpt-6-luna',
              # клетки ослабления сравнения (вердикт Crit186V2, UM-2/UM-3):
              # иная модель ТОГО ЖЕ семейства zai и «ядро»-подстрока полной
              # строки glm — значения toy-реестра, живой реестр не читается
              'glm-prev': 'zai/glm-4.6', 'glm-core': 'zai/glm'}


def toy_registry(model_alias='@glm', fallback_alias='@gpt-terra'):
    """Toy установочный реестр харнесса двери (186 v+1): ожидаемая модель
    критика — назначение роли critic; значения — фиксированные toy-данные,
    не живой реестр. Первый тир словаря — НЕ тир critic: стаб «первый тир
    вместо назначения роли» обязан разрешаться в ЧУЖУЮ модель, чтобы быть
    различимым на своём входе (Н-39)."""
    return {
        'roles': {'critic': 'critic-main', 'architecture-steward': 'steward-arch'},
        'tiers': {
            'steward-arch': {'model': '@gpt-sol', 'fallback': '@gpt-astra'},
            'critic-main': {'model': model_alias, 'fallback': fallback_alias},
        },
        'models': dict(TOY_MODELS),
    }


def resolve_critic(registry):
    tier = registry['tiers'][registry['roles']['critic']]
    return registry['models'][tier['model'][1:]]


def call(argv, cwd, env=None):
    return subprocess.run(argv, cwd=cwd, env=env, text=True, capture_output=True)


def write(root, name, data):
    path = root / name
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(data, encoding='utf-8')
    return path


def world(tmp, case):
    root = tmp / 'CompliorOS-architecture'
    root.mkdir()
    check = call(['git', 'init', '-q', '-b', 'main'], root)
    if check.returncode:
        raise RuntimeError(check.stderr)
    base = {'moduleBoundaries': {'api': ['identity']}, 'resources': {'identity': 'owner'}}
    current = json.loads(json.dumps(base))
    write(root, 'governance/baseline/approved.json', json.dumps(base))
    write(root, 'governance/current.json', json.dumps(current))
    write(root, 'package.json', json.dumps({'scripts': {'check': 'node tooling/checks/cli.js check'}}))
    check = call(['git', 'add', '.'], root)
    if check.returncode:
        raise RuntimeError(check.stderr)
    check = call(['git', '-c', 'user.name=architect', '-c', 'user.email=architect@dev-harness.local',
                  'commit', '-qm', 'toy baseline'], root)
    if check.returncode:
        raise RuntimeError(check.stderr)
    check = call(['git', 'switch', '-q', '-c', 'pr-42'], root)
    if check.returncode:
        raise RuntimeError(check.stderr)
    # Б-1 (ревьюер 186 вызов 1): содержание PR наследуется от базового мира,
    # состояние checkout задаётся отдельным классом миров ниже.
    content = case
    if case == 'checkout_main_l2':
        content = 'l2_without_owner'
    if case in ('checkout_main_l3', 'dirty_baseline_swap_l3'):
        content = 'l3_without_owner'
    if content == 'l2_without_owner':
        current['moduleBoundaries']['api'].append('new-api')
    if content == 'l3_without_owner':
        current['resources']['identity'] = 'public'
    write(root, 'governance/current.json', json.dumps(current))
    write(root, 'architecture/description.md', 'L1 corrected relationship\n')
    check = call(['git', 'add', '.'], root)
    if check.returncode:
        raise RuntimeError(check.stderr)
    check = call(['git', '-c', 'user.name=architect', '-c', 'user.email=architect@dev-harness.local',
                  'commit', '-qm', 'arch(L1): correct model'], root)
    if check.returncode:
        raise RuntimeError(check.stderr)
    sha = call(['git', 'rev-parse', 'HEAD'], root).stdout.strip()
    # 186 v+1: факт review строится из разрешения назначения роли critic в
    # toy-реестре В ПАМЯТИ до вызова субъекта (правило 8); значения реестра —
    # фиксированные toy-данные, живой реестр харнесса не читается.
    variant = ('@glm', '@gpt-terra')
    if case in ('registry_terra', 'accept_fact_glm'):
        variant = ('@gpt-terra', '@gpt-sol')
    if case == 'registry_sol':
        variant = ('@gpt-sol', '@gpt-astra')
    if case == 'accept_fact_fallback':
        # назначена основная модель тира (terra), факт — его РАЗРЕШЁННЫЙ
        # fallback (glm): ослабление «принимает {основная, fallback}»
        # обязано быть красным (UM-1 вердикта Crit186V2)
        variant = ('@gpt-terra', '@glm')
    if case == 'accept_fact_same_family':
        # факт — иная модель ТОГО ЖЕ семейства (тот же префикс до «/»)
        # после ротации версии: ловит сравнение по семейству (UM-2)
        variant = ('@glm-prev', '@gpt-terra')
    if case == 'accept_fact_superstring':
        # назначенная — собственная подстрока факта: ловит ослабление
        # «назначенная содержится в факте» (UM-3)
        variant = ('@glm-core', '@gpt-terra')
    registry = toy_registry(*variant)
    if case == 'registry_fallback_change':
        registry['tiers']['critic-main']['fallback'] = '@gpt-luna'
    if case == 'registry_no_critic_role':
        del registry['roles']['critic']
    if case == 'registry_no_tier':
        registry['roles']['critic'] = 'critic-ghost'
    if case == 'registry_alias_unresolvable':
        registry['tiers']['critic-main']['model'] = '@ghost'
    if case == 'registry_model_empty':
        registry['models']['glm'] = ''
    if case in ('alias_cycle_honest_fact', 'alias_cycle_fact_alias'):
        # Н-3 (Adv186Impl): алиас-цикл models.glm='@glm' — назначение
        # неразрешимо: CRITIC_MODEL_UNRESOLVED rc 1, слияния нет
        registry['models']['glm'] = '@glm'
    if case == 'alias_other_family_control':
        # Н-3 контроль: ЧУЖАЯ семья с алиасом не ломает честное разрешение
        # назначения critic — законное слияние
        registry['models']['gpt-terra'] = '@gpt-sol'
    broken_registry = case in ('registry_no_critic_role', 'registry_no_tier',
                               'registry_alias_unresolvable', 'registry_model_empty')
    fact = TOY_MODELS['glm'] if broken_registry else resolve_critic(registry)
    if case == 'accept_fact_glm':
        # назначена Terra, факт GLM: подмена факта красна В ОБЕ стороны,
        # не «любая не-GLM»
        fact = TOY_MODELS['glm']
    if case == 'alias_cycle_honest_fact':
        # Н-3: факт — честная полная строка glm при неразрешимом назначении:
        # отказ обязан называться CRITIC_MODEL_UNRESOLVED, а не «факт не совпал»
        fact = TOY_MODELS['glm']
    if case == 'accept_fact_fallback':
        # факт = fallback тира из toy-реестра В ПАМЯТИ (правило 8), не литерал
        fact = registry['models'][registry['tiers']['critic-main']['fallback'][1:]]
    if case in ('accept_fact_same_family', 'accept_fact_superstring'):
        # факт — полная строка glm: иная версия того же семейства zai и
        # надстройка над назначенной-подстрокой; литерал = старый пин 186/1,
        # старая GLM-дверь сливает → клетка честно красна на --repo .
        fact = TOY_MODELS['glm']
    if case == 'accept_fact_padded':
        # факт отличается от назначенной ТОЛЬКО формой записи: пробелы/табы
        # вокруг значения при назначенной без них — блокирующая находка
        # вердикта Crit186V2b, вход (а); ловит ослабление strip() значения
        fact = ' \t' + fact + ' \t'
    if case == 'accept_fact_padded_lead_space':
        # Арбитраж 186-1 РЕШЕНИЕ 2: чистый ОДНОСТОРОННИЙ экземпляр — ведущий
        # ПРОБЕЛ; двусторонний смешанный вход не различает lstrip и
        # удаление только пробела — четыре чистых экземпляра различают
        fact = ' ' + fact
    if case == 'accept_fact_padded_lead_tab':
        # чистый односторонний экземпляр — ведущий ТАБ; ловит lstrip('\t')
        fact = '\t' + fact
    if case == 'accept_fact_padded_tail_space':
        # чистый односторонний экземпляр — хвостовой ПРОБЕЛ; ловит rstrip(' ')
        fact = fact + ' '
    if case == 'accept_fact_padded_tail_tab':
        # чистый односторонний экземпляр — хвостовой ТАБ; ловит rstrip('\t')
        fact = fact + '\t'
    if case == 'accept_fact_fullwidth':
        # NFKC-эквивалент назначенной, не равный байтово: полноширинная
        # запись (вход (б)); ловит сравнение после Unicode-нормализации
        fact = 'ｚａｉ／ｇｌｍ－５．３'
    if case == 'accept_fact_bare':
        # bare-форма без префикса провайдера при назначенной с префиксом
        # (вход (в); норма 173 «zai/glm-5.3 ≡ glm-5.3» для check_sud_model.sh
        # на дверь НЕ переносится); ловит префикс-эквивалентность
        fact = fact.rsplit('/', 1)[-1]
    if case == 'accept_fact_suffixed':
        # надстройка СПЕРЕДИ: факт кончается на назначенную (совет
        # вердикта Crit186V2b, NM_endswith); ловит суффиксное сравнение
        fact = 'evil-' + fact
    if case in ('symlink_foreign_registry', 'own_tree_foreign_neighbor'):
        # Н-2 (Adv186Impl): рядом с дверью ЧУЖОЕ дерево с чужим реестром
        # (назначение terra); факт — назначение ЧУЖОГО реестра. Честная дверь
        # канонизирует путь скрипта и читает реестр СВОЕГО дерева (glm) —
        # отказ; стаб без канонизации читает реестр каталога ссылки — слияние.
        foreign = toy_registry('@gpt-terra')
        write(tmp, 'other/config/agent_models.json',
              json.dumps(foreign, ensure_ascii=False, indent=2) + '\n')
        fact = resolve_critic(foreign)
    state = {
        'pr': {'title': 'COMPLIOR-186 architectural correction', 'author': {'login': 'steward'},
               'headRefOid': sha, 'baseRefName': 'main'},
        'operator': 'station-orchestrator',
        'reviews': [{'state': 'APPROVED', 'commit_id': sha, 'user': {'login': 'critic'},
                     'body': 'accept\nСУД: repo=architecture; модель-факт=' + fact + '; SHA=' + sha}],
        'checks': [{'name': 'architecture', 'status': 'completed', 'conclusion': 'success',
                    'app': {'slug': 'github-actions'}}],
    }
    if case == 'no_accept':
        state['reviews'] = []
    if case == 'accept_other_head':
        state['reviews'][0]['commit_id'] = call(['git', 'rev-parse', 'main'], root).stdout.strip()
    if case == 'accept_author':
        state['pr']['author']['login'] = 'critic'
    # переименовано с accept_same_family (совет вердикта Crit186V2): факт —
    # модель ЧУЖОГО семейства (openai-codex при назначенной zai), имя — по
    # семантике входа, не по истории
    if case == 'accept_fact_foreign':
        state['reviews'][0]['body'] = state['reviews'][0]['body'].replace('zai/glm-5.3', 'openai-codex/gpt-6-sol')
    if case == 'ci_red':
        state['checks'][0]['conclusion'] = 'failure'
    if case == 'ci_architecture_missing':
        state['checks'][0]['name'] = 'unrelated-quality'
    if case == 'no_complior':
        state['pr']['title'] = 'Architectural correction'
    if case == 'author_merger':
        state['operator'] = 'steward'
    if case == 'title_two_ids':
        state['pr']['title'] = 'COMPLIOR-186 and COMPLIOR-187 architectural correction'
    if case == 'title_lowercase_id':
        state['pr']['title'] = 'complior-186 architectural correction'
    if case == 'title_suffixed_id':
        state['pr']['title'] = 'COMPLIOR-186a architectural correction'
    if case == 'author_casefold':
        state['pr']['author']['login'] = 'Station-Orchestrator'
    if case == 'author_unicode_lookalike':
        state['pr']['author']['login'] = 'station\uff0dorchestrator'
    if case == 'author_space_login':
        state['pr']['author']['login'] = 'station-orchestrator '
    if case == 'author_empty':
        state['pr']['author']['login'] = ''
    if case == 'author_bot_suffix':
        state['pr']['author']['login'] = 'station-orchestrator[bot]'
    if case == 'model_second_field':
        state['reviews'][0]['body'] = ('accept\nСУД: модель-факт=openai-codex/gpt-6-sol; '
                                       'модель-факт=zai/glm-5.3; SHA=' + sha)
    if case == 'field_renamed_foreign':
        # Н-1 (Adv186Impl): подстрока `модель-факт=` внутри ЧУЖОГО имени поля —
        # переименованное поле поля НЕ несёт, слияния нет
        state['reviews'][0]['body'] = state['reviews'][0]['body'].replace(
            'модель-факт=', 'ложная-модель-факт=')
    if case == 'field_inside_other_name':
        # Н-1: имя поля — ЗНАЧЕНИЕ чужого поля (реальная грамматика СУД:
        # `замечание=модель-факт=…`): левая граница не начало строки и не `;`
        state['reviews'][0]['body'] = state['reviews'][0]['body'].replace(
            'модель-факт=', 'замечание=модель-факт=')
    if case == 'field_after_separator_spaces':
        # Н-1 контроль: поле после `;` с ПРОБЕЛАМИ — законная левая граница
        # («; с опциональными пробелами»), честная дверь сливает: фикс имени
        # поля не запирает разделитель намертво
        state['reviews'][0]['body'] = state['reviews'][0]['body'].replace(
            '; модель-факт=', ';   модель-факт=')
    if case == 'accept_not_first':
        state['reviews'][0]['body'] = ('напоминание: слить после приёмки\n'
                                       + state['reviews'][0]['body'])
    if case == 'accept_case':
        state['reviews'][0]['body'] = state['reviews'][0]['body'].replace('accept\n', 'Accept\n')
    if case == 'accept_trailing_space':
        state['reviews'][0]['body'] = state['reviews'][0]['body'].replace('accept\n', 'accept \n')
    if case == 'sud_no_sha':
        state['reviews'][0]['body'] = 'accept\nСУД: repo=architecture; модель-факт=zai/glm-5.3'
    if case == 'sud_foreign_sha':
        state['reviews'][0]['body'] = ('accept\nСУД: repo=architecture; модель-факт=zai/glm-5.3; SHA='
                                       + call(['git', 'rev-parse', 'main'], root).stdout.strip())
    if case == 'review_not_approved':
        state['reviews'][0]['state'] = 'CHANGES_REQUESTED'
    if case == 'model_empty_value':
        state['reviews'][0]['body'] = 'accept\nСУД: модель-факт=; SHA=' + sha
    if case == 'model_case_distorted':
        state['reviews'][0]['body'] = ('accept\nСУД: repo=architecture; модель-факт=ZAI/GLM-5.3; SHA='
                                       + sha)
    if case == 'foreign_architecture_app':
        state['checks'][0]['app'] = {'slug': 'evil-ci', 'owner': {'login': 'attacker'}}
    if case == 'ci_skipped':
        state['checks'][0]['conclusion'] = 'skipped'
    if case == 'ci_neutral':
        state['checks'][0]['conclusion'] = 'neutral'
    if case == 'ci_cancelled':
        state['checks'][0]['conclusion'] = 'cancelled'
    if case == 'ci_in_progress':
        state['checks'][0]['status'] = 'in_progress'
        state['checks'][0]['conclusion'] = None
    if case == 'ci_two_architecture':
        state['checks'] = [
            {'name': 'architecture', 'status': 'completed', 'conclusion': 'success',
             'app': {'slug': 'evil-ci'}},
            {'name': 'architecture', 'status': 'completed', 'conclusion': 'failure',
             'app': {'slug': 'github-actions'}}]
    if case == 'paginated_red_run':
        filler = [{'name': 'unit-%d' % i, 'status': 'completed', 'conclusion': 'success',
                   'app': {'slug': 'github-actions'}} for i in range(99)]
        state['check_pages'] = [
            {'total_count': 101, 'check_runs': filler + [dict(state['checks'][0])],
             '_links': {'next': {'href': 'https://api.github.com/repos/a3ka/CompliorOS-architecture/'
                                         'commits/%s/check-runs?page=2' % sha}}},
            {'total_count': 101,
             'check_runs': [{'name': 'security', 'status': 'completed', 'conclusion': 'failure',
                             'app': {'slug': 'github-actions'}}]}]
    write(tmp, 'state.json', json.dumps(state))
    # toy-реестр харнесса двери: контроль/субъект читают его относительно
    # СВОЕГО местоположения (tmp/control.py → tmp/config, tmp/scripts/… →
    # tmp/config), не из живого дерева харнесса и не из cwd.
    if case == 'registry_invalid_json':
        write(tmp, 'config/agent_models.json', 'NOT-JSON {roles: critic-main')
    elif case != 'registry_missing':
        write(tmp, 'config/agent_models.json', json.dumps(registry, ensure_ascii=False, indent=2) + '\n')
    bin_dir = tmp / 'bin'
    bin_dir.mkdir()
    for name, program in (('gh', FAKE_GH), ('npm', FAKE_NPM)):
        path = write(bin_dir, name, program)
        path.chmod(0o755)
    env = dict(os.environ, PATH=str(bin_dir) + os.pathsep + os.environ['PATH'],
               TOY_STATE=str(tmp / 'state.json'), TOY_MERGE_LOG=str(tmp / 'merged.json'), TOY_HEAD=sha)
    # ── Б-1 (ревьюер 186 вызов 1): слияние судит ТО дерево, которое принято. ────
    # Checkout обязан стоять ровно на head PR и быть чистым; миры ниже уводят
    # checkout (main, detached, чужая ветка на том же sha — законно), пачкают
    # дерево (untracked, modified, подмена baseline — нападение) или ломают
    # Git-инфраструктуру (нет .git / мелкий клон — нечем судить).
    if case in ('checkout_main_l1', 'checkout_main_l2', 'checkout_main_l3'):
        check = call(['git', 'switch', '-q', 'main'], root)
        if check.returncode:
            raise RuntimeError(check.stderr)
    if case == 'dirty_untracked_l1':
        write(root, 'notes-untracked.txt', 'мусор вне индекса\n')
    if case == 'dirty_modified_l1':
        path = root / 'architecture/description.md'
        path.write_text(path.read_text(encoding='utf-8') + 'локальная правка вне коммита\n',
                        encoding='utf-8')
    if case == 'dirty_baseline_swap_l3':
        # подмена baseline в рабочем дереве: npm check на ГРЯЗНОМ дереве сказал бы
        # PASS (L1), а слитый коммит несёт L3 — дверь обязана отказаться ДО check
        write(root, 'governance/baseline/approved.json',
              json.dumps({'moduleBoundaries': {'api': ['identity']},
                          'resources': {'identity': 'public'}}))
    if case == 'dirty_reverted_l1':
        path = root / 'architecture/description.md'
        path.write_text(path.read_text(encoding='utf-8') + 'временная правка\n', encoding='utf-8')
        check = call(['git', 'checkout', '--', 'architecture/description.md'], root)
        if check.returncode:
            raise RuntimeError(check.stderr)
    if case == 'detached_head_l1':
        check = call(['git', 'switch', '-q', '--detach', sha], root)
        if check.returncode:
            raise RuntimeError(check.stderr)
    if case == 'other_branch_at_head':
        check = call(['git', 'switch', '-q', '-c', 'review-copy'], root)
        if check.returncode:
            raise RuntimeError(check.stderr)
    if case == 'no_git':
        shutil.rmtree(root / '.git')
    if case == 'shallow_clone':
        clone = tmp / 'shallow'
        clone_result = subprocess.run(
            ['git', 'clone', '-q', '--depth', '1', '--branch', 'pr-42',
             'file://' + str(root), str(clone)], capture_output=True, text=True)
        if clone_result.returncode:
            raise RuntimeError(clone_result.stderr)
        root = clone
    return root, env


CASES = {
    'l1_merge': (0, None),
    'no_accept': (1, 'NO_CRITIC_ACCEPT_ON_HEAD'),
    'accept_other_head': (1, 'NO_CRITIC_ACCEPT_ON_HEAD'),
    'accept_author': (1, 'NO_CRITIC_ACCEPT_ON_HEAD'),
    'accept_fact_foreign': (1, 'NO_CRITIC_ACCEPT_ON_HEAD'),
    'ci_red': (1, 'CI_NOT_GREEN_ON_HEAD'),
    'ci_architecture_missing': (1, 'CI_NOT_GREEN_ON_HEAD'),
    'l2_without_owner': (1, 'L2_OWNER_APPROVAL_REQUIRED'),
    'l3_without_owner': (1, 'L3_OWNER_APPROVAL_REQUIRED'),
    'no_complior': (1, 'NO_COMPLIOR_ID'),
    'author_merger': (1, 'AUTHOR_IS_MERGER'),
    'title_two_ids': (1, None),
    'author_casefold': (1, None),
    'model_second_field': (1, None),
    'accept_not_first': (1, None),
    'foreign_architecture_app': (1, None),
    'paginated_red_run': (1, None),
    'title_lowercase_id': (1, 'NO_COMPLIOR_ID'),
    'title_suffixed_id': (1, 'NO_COMPLIOR_ID'),
    'author_unicode_lookalike': (0, None),
    'author_space_login': (0, None),
    'author_empty': (2, None),
    'author_bot_suffix': (0, None),
    'accept_case': (1, 'NO_CRITIC_ACCEPT_ON_HEAD'),
    'accept_trailing_space': (1, 'NO_CRITIC_ACCEPT_ON_HEAD'),
    'sud_no_sha': (1, 'NO_CRITIC_ACCEPT_ON_HEAD'),
    'sud_foreign_sha': (1, 'NO_CRITIC_ACCEPT_ON_HEAD'),
    'review_not_approved': (1, 'NO_CRITIC_ACCEPT_ON_HEAD'),
    'model_empty_value': (1, 'NO_CRITIC_ACCEPT_ON_HEAD'),
    'model_case_distorted': (1, 'NO_CRITIC_ACCEPT_ON_HEAD'),
    'ci_skipped': (1, 'CI_NOT_GREEN_ON_HEAD'),
    'ci_neutral': (1, 'CI_NOT_GREEN_ON_HEAD'),
    'ci_cancelled': (1, 'CI_NOT_GREEN_ON_HEAD'),
    'ci_in_progress': (1, 'CI_NOT_GREEN_ON_HEAD'),
    'ci_two_architecture': (1, 'CI_NOT_GREEN_ON_HEAD'),
    # 186 v+1: назначение модели критика — из toy-реестра харнесса двери
    'registry_terra': (0, None),
    'registry_sol': (0, None),
    'registry_fallback_change': (0, None),
    'accept_fact_glm': (1, 'NO_CRITIC_ACCEPT_ON_HEAD'),
    # клетки ослабления сравнения модель-факт (блокирующая находка
    # вердикта Crit186V2): fallback тира / то же семейство / подстрока
    'accept_fact_fallback': (1, 'NO_CRITIC_ACCEPT_ON_HEAD'),
    'accept_fact_same_family': (1, 'NO_CRITIC_ACCEPT_ON_HEAD'),
    'accept_fact_superstring': (1, 'NO_CRITIC_ACCEPT_ON_HEAD'),
    # клетки нормализации значения модель-факт (блокирующая находка
    # вердикта Crit186V2b): форма записи не расширяет множество
    # принимаемых значений — пробелы/NFKC/bare/суффикс
    'accept_fact_padded': (1, 'NO_CRITIC_ACCEPT_ON_HEAD'),
    # Арбитраж 186-1 РЕШЕНИЕ 2: четыре ОДНОСТОРОННИХ экземпляра SPACE/TAB
    # (ведущий/хвостовой); двусторонний смешанный сохранён выше — каждый
    # экземпляр исполняется отдельным миром и различим своим выводом
    'accept_fact_padded_lead_space': (1, 'NO_CRITIC_ACCEPT_ON_HEAD'),
    'accept_fact_padded_lead_tab': (1, 'NO_CRITIC_ACCEPT_ON_HEAD'),
    'accept_fact_padded_tail_space': (1, 'NO_CRITIC_ACCEPT_ON_HEAD'),
    'accept_fact_padded_tail_tab': (1, 'NO_CRITIC_ACCEPT_ON_HEAD'),
    'accept_fact_fullwidth': (1, 'NO_CRITIC_ACCEPT_ON_HEAD'),
    'accept_fact_bare': (1, 'NO_CRITIC_ACCEPT_ON_HEAD'),
    'accept_fact_suffixed': (1, 'NO_CRITIC_ACCEPT_ON_HEAD'),
    'registry_missing': (1, 'CRITIC_MODEL_UNRESOLVED'),
    'registry_invalid_json': (1, 'CRITIC_MODEL_UNRESOLVED'),
    'registry_no_critic_role': (1, 'CRITIC_MODEL_UNRESOLVED'),
    'registry_no_tier': (1, 'CRITIC_MODEL_UNRESOLVED'),
    'registry_alias_unresolvable': (1, 'CRITIC_MODEL_UNRESOLVED'),
    'registry_model_empty': (1, 'CRITIC_MODEL_UNRESOLVED'),
    # Н-1 (вердикт Adv186Impl): подстрока `модель-факт=` внутри чужого имени
    # поля — слияния нет; законная левая граница `;`+пробелы — контроль зелёный
    'field_renamed_foreign': (1, 'NO_CRITIC_ACCEPT_ON_HEAD'),
    'field_inside_other_name': (1, 'NO_CRITIC_ACCEPT_ON_HEAD'),
    'field_after_separator_spaces': (0, None),
    # Н-2 (Adv186Impl): реестр канонически от файла скрипта, не от каталога
    # ссылки; контроль — та же раскладка без симлинка, из своего дерева
    'symlink_foreign_registry': (1, 'NO_CRITIC_ACCEPT_ON_HEAD'),
    'own_tree_foreign_neighbor': (1, 'NO_CRITIC_ACCEPT_ON_HEAD'),
    # Н-3 (Adv186Impl): алиас-цикл — неразрешимое назначение, отказ
    # CRITIC_MODEL_UNRESOLVED при честном факте и при факте-алиасе; контроль —
    # чужая алиасная семья не ломает честное разрешение
    'alias_cycle_honest_fact': (1, 'CRITIC_MODEL_UNRESOLVED'),
    'alias_cycle_fact_alias': (1, 'CRITIC_MODEL_UNRESOLVED'),
    'alias_other_family_control': (0, None),
    # Б-1: checkout не на head PR / грязное дерево — именованный отказ ДО npm check
    'checkout_main_l1': (1, 'CHECKOUT_NOT_AT_PR_HEAD', 'main'),
    'checkout_main_l2': (1, 'CHECKOUT_NOT_AT_PR_HEAD', 'main'),
    'checkout_main_l3': (1, 'CHECKOUT_NOT_AT_PR_HEAD', 'main'),
    'dirty_untracked_l1': (1, 'CHECKOUT_DIRTY'),
    'dirty_modified_l1': (1, 'CHECKOUT_DIRTY'),
    'dirty_baseline_swap_l3': (1, 'CHECKOUT_DIRTY'),
    # законные состояния: откат, detached на head, иная ветка на том же sha
    'dirty_reverted_l1': (0, None),
    'detached_head_l1': (0, None),
    'other_branch_at_head': (0, None),
    # нечем судить: Git-инфраструктура недоступна / мелкий клон без main
    'no_git': (2, None, ''),
    'shallow_clone': (2, None),
}
MUTATIONS = {
    'skip_accept': ('if not accepted:', 'if False:', 'no_accept'),
    'skip_head': ("r['commit_id'] != sha", 'False', 'accept_other_head'),
    'skip_author': ("r['user']['login'] == pr['author']['login']", 'False', 'accept_author'),
    'skip_family': ("fields[1].split(';', 1)[0] != critic_model",
                    "fields[1].split(';', 1)[0] not in (critic_model, 'openai-codex/gpt-6-sol')",
                    'accept_fact_foreign'),
    'stub_hardcode_glm': ('= assigned_critic_model()', "= 'zai/glm-5.3'", 'registry_terra'),
    'stub_hardcode_gpt': ('= assigned_critic_model()', "= 'openai-codex/gpt-6.1-terra'", 'l1_merge'),
    'stub_first_tier': ("name = roles.get('critic') if isinstance(roles, dict) else None",
                        "name = next(iter(registry.get('tiers', {}))) if isinstance(registry.get('tiers'), dict) else None",
                        'registry_terra'),
    'stub_silent_glm_fallback': (
        "    critic_model = assigned_critic_model()\n"
        "    if critic_model is None:\n"
        "        return fail('CRITIC_MODEL_UNRESOLVED')",
        "    critic_model = assigned_critic_model()\n"
        "    if critic_model is None:\n"
        "    critic_model = 'zai/glm-5.3'", 'registry_missing'),
    # стабы ослабления сравнения — каждый к входу, где его дефект наблюдаем
    # (Н-39): образец — мутации UM-1/UM-2/UM-3 вердикта Crit186V2
    'stub_fallback_tolerated': (
        "fields[1].split(';', 1)[0] != critic_model",
        "fields[1].split(';', 1)[0] not in {critic_model, "
        "(lambda r: r['models'].get(r['tiers'][r['roles']['critic']].get('fallback', '')[1:]))"
        "(json.loads(REGISTRY.read_text(encoding='utf-8')))}",
        'accept_fact_fallback'),
    'stub_family_prefix': (
        "fields[1].split(';', 1)[0] != critic_model",
        "fields[1].split(';', 1)[0].split('/', 1)[0] != critic_model.split('/', 1)[0]",
        'accept_fact_same_family'),
    'stub_substring': (
        "fields[1].split(';', 1)[0] != critic_model",
        "critic_model not in fields[1].split(';', 1)[0]",
        'accept_fact_superstring'),
    # стабы нормализации сравнения — образец мутаций NM_strip_fact/
    # NM_strip_both/NM_nfkc/NM_bare_equiv/NM_endswith вердикта Crit186V2b;
    # каждый к входу, где его дефект наблюдаем (Н-39)
    'stub_strip_fact': (
        "fields[1].split(';', 1)[0] != critic_model",
        "fields[1].split(';', 1)[0].strip() != critic_model",
        'accept_fact_padded'),
    # одностороннее обрезание значения — Арбитраж 186-1 РЕШЕНИЕ 2
    # (образец NM_lstrip/NM_rstrip критика Crit186V3): lstrip/rstrip
    # различимы только на чистых односторонних входах (Н-39)
    'stub_lstrip_fact': (
        "fields[1].split(';', 1)[0] != critic_model",
        "fields[1].split(';', 1)[0].lstrip() != critic_model",
        'accept_fact_padded_lead_space'),
    'stub_rstrip_fact': (
        "fields[1].split(';', 1)[0] != critic_model",
        "fields[1].split(';', 1)[0].rstrip() != critic_model",
        'accept_fact_padded_tail_space'),
    'stub_nfkc': (
        "fields[1].split(';', 1)[0] != critic_model",
        "__import__('unicodedata').normalize('NFKC', fields[1].split(';', 1)[0]) != "
        "__import__('unicodedata').normalize('NFKC', critic_model)",
        'accept_fact_fullwidth'),
    'stub_bare_equiv': (
        "fields[1].split(';', 1)[0] != critic_model",
        "fields[1].split(';', 1)[0] not in (critic_model, critic_model.split('/', 1)[-1])",
        'accept_fact_bare'),
    'stub_endswith': (
        "fields[1].split(';', 1)[0] != critic_model",
        "fields[1].split(';', 1)[0] != critic_model and not fields[1].split(';', 1)[0].endswith(critic_model)",
        'accept_fact_suffixed'),
    'skip_ci': ("c['conclusion'] != 'success'", 'False', 'ci_red'),
    'skip_architecture_ci': ("not any(c.get('name') == 'architecture' for c in runs)",
                             'False', 'ci_architecture_missing'),
    'skip_baseline': ('if mismatches:', 'if False:', 'l2_without_owner'),
    'skip_l3': ("return fail('L3_OWNER_APPROVAL_REQUIRED')",
                "return fail('L2_OWNER_APPROVAL_REQUIRED')", 'l3_without_owner'),
    'skip_id': ("if len(re.findall(r'\\bCOMPLIOR-[0-9]+\\b', pr['title'])) != 1:",
                'if False:', 'no_complior'),
    'skip_merger': ("if pr['author']['login'].casefold() == operator.casefold():",
                    'if False:', 'author_merger'),
    'skip_head_pin': ("'--match-head-commit', sha", "'--delete-branch'", 'l1_merge'),
    'skip_unique_id': ("if len(re.findall(r'\\bCOMPLIOR-[0-9]+\\b', pr['title'])) != 1:",
                       "if not re.search(r'\\bCOMPLIOR-[0-9]+\\b', pr['title']):", 'title_two_ids'),
    'skip_id_case': ("re.findall(r'\\bCOMPLIOR-[0-9]+\\b', pr['title'])",
                     "re.findall(r'\\bCOMPLIOR-[0-9]+\\b', pr['title'], re.IGNORECASE)",
                     'title_lowercase_id'),
    'skip_id_edge': ("re.findall(r'\\bCOMPLIOR-[0-9]+\\b', pr['title'])",
                     "re.findall(r'\\bCOMPLIOR-[0-9]+', pr['title'])", 'title_suffixed_id'),
    'skip_login_casefold': ("if pr['author']['login'].casefold() == operator.casefold():",
                            "if pr['author']['login'] == operator:", 'author_casefold'),
    'skip_login_unicode': ("if pr['author']['login'].casefold() == operator.casefold():",
                           "if __import__('unicodedata').normalize('NFKC', pr['author']['login']).casefold()"
                           " == __import__('unicodedata').normalize('NFKC', operator).casefold():",
                           'author_unicode_lookalike'),
    'skip_login_space': ("if pr['author']['login'].casefold() == operator.casefold():",
                         "if pr['author']['login'].strip().casefold() == operator.strip().casefold():",
                         'author_space_login'),
    'skip_login_empty': ("raise RuntimeError('в PR нет автора — слияние невозможно судить')",
                         'pass', 'author_empty'),
    'skip_login_bot': ("if pr['author']['login'].casefold() == operator.casefold():",
                       "if pr['author']['login'].removesuffix('[bot]').casefold() == operator.casefold():",
                       'author_bot_suffix'),
    'skip_sud_fields': ("fields = sud[0].split('модель-факт=') if len(bounded) == 1 else []",
                        "fields = sud[0].split('модель-факт=')[-2:] if sud else []",
                        'model_second_field'),
    'skip_model_empty': ("fields[1].split(';', 1)[0] != critic_model",
                         "fields[1].split(';', 1)[0] not in (critic_model, '')",
                         'model_empty_value'),
    'skip_model_case': ("fields[1].split(';', 1)[0] != critic_model",
                        "fields[1].split(';', 1)[0].casefold() != critic_model",
                        'model_case_distorted'),
    'skip_sud_sha': ("not sud[0].endswith('; SHA=' + sha)", 'False', 'sud_no_sha'),
    'skip_sud_sha_value': ("not sud[0].endswith('; SHA=' + sha)",
                           "'; SHA=' not in sud[0]", 'sud_foreign_sha'),
    'skip_review_state': ("if r['state'] != 'APPROVED' or r['commit_id'] != sha:",
                          "if r['commit_id'] != sha:", 'review_not_approved'),
    'skip_accept_first': ("not lines or lines[0] != 'accept'",
                          "not any(line == 'accept' for line in lines)", 'accept_not_first'),
    'skip_accept_case': ("not lines or lines[0] != 'accept'",
                         "not lines or lines[0].casefold() != 'accept'", 'accept_case'),
    'skip_accept_space': ("not lines or lines[0] != 'accept'",
                          "not lines or lines[0].strip() != 'accept'", 'accept_trailing_space'),
    'skip_ci_app': ("c.get('app', {}).get('slug') != 'github-actions'", 'False',
                    'foreign_architecture_app'),
    'skip_ci_pages': ("['gh', 'api', '--paginate', f'repos/{repo}/commits/{sha}/check-runs']",
                      "['gh', 'api', f'repos/{repo}/commits/{sha}/check-runs']",
                      'paginated_red_run'),
    'skip_ci_skipped': ("c['conclusion'] != 'success'", "c['conclusion'] == 'failure'",
                        'ci_skipped'),
    'skip_ci_neutral': ("c['conclusion'] != 'success'",
                        "c['conclusion'] not in ('success', 'neutral')", 'ci_neutral'),
    'skip_ci_cancelled': ("c['conclusion'] != 'success'",
                          "c['conclusion'] not in ('success', 'cancelled')", 'ci_cancelled'),
    'skip_ci_status': ("c['status'] != 'completed' or c['conclusion'] != 'success'",
                       "c['conclusion'] == 'failure'", 'ci_in_progress'),
    'skip_ci_siblings': ("if any(c['status'] != 'completed' or c['conclusion'] != 'success' for c in runs):\n"
                         "        return fail('CI_NOT_GREEN_ON_HEAD')\n"
                         "    if not runs or not any(c.get('name') == 'architecture' for c in runs):\n"
                         "        return fail('CI_NOT_GREEN_ON_HEAD')\n"
                         "    if any(c.get('app', {}).get('slug') != 'github-actions'\n"
                         "           for c in runs if c['name'] == 'architecture'):\n"
                         "        return fail('CI_FOREIGN_ARCHITECTURE_APP')",
                         "if not any(c.get('name') == 'architecture' and c['conclusion'] == 'success'"
                         " for c in runs):\n"
                         "        return fail('CI_NOT_GREEN_ON_HEAD')",
                         'ci_two_architecture'),
    # Б-1: сверка checkout с head PR и чистотой дерева снята — раньше зелёная
    # приёмка; каждый стаб различим на СВОЕЙ клетке (Н-39)
    'skip_head_checkout': ('if head != sha:', 'if False:', 'checkout_main_l1'),
    'skip_dirty': ("if call(['git', 'status', '--porcelain'], project).strip():",
                   'if False:', 'dirty_untracked_l1'),
    # стабы вердикта Adv186Impl (Н-1/Н-2/Н-3) — каждый к входу, где его дефект
    # НАБЛЮДАЕМ (Н-39); повторные привязки той же мутации — вторым входам того
    # же дефекта; контроли ловят пере-жатые мутации (сепаратор без пробелов,
    # реестр по cwd, алиасность чужой семьи)
    'wrong_field': (
        "bounded = re.findall(r'(?:\\A|;[ \\t]*)модель-факт=', sud[0][5:]) if len(sud) == 1 else []",
        "bounded = re.findall(r'модель-факт=', sud[0]) if len(sud) == 1 else []",
        'field_renamed_foreign'),
    'wrong_field_foreign_name': (
        "bounded = re.findall(r'(?:\\A|;[ \\t]*)модель-факт=', sud[0][5:]) if len(sud) == 1 else []",
        "bounded = re.findall(r'модель-факт=', sud[0]) if len(sud) == 1 else []",
        'field_inside_other_name'),
    'stub_separator_tight': (
        "bounded = re.findall(r'(?:\\A|;[ \\t]*)модель-факт=', sud[0][5:]) if len(sud) == 1 else []",
        "bounded = re.findall(r'(?:\\A|;)модель-факт=', sud[0][5:]) if len(sud) == 1 else []",
        'field_after_separator_spaces'),
    'symlink_cwd_registry': (
        "REGISTRY = Path(__file__).resolve().parent / 'config' / 'agent_models.json'",
        "REGISTRY = Path(os.path.abspath(__file__)).parent / 'config' / 'agent_models.json'",
        'symlink_foreign_registry'),
    'cwd_registry': (
        "REGISTRY = Path(__file__).resolve().parent / 'config' / 'agent_models.json'",
        "REGISTRY = Path.cwd() / 'config' / 'agent_models.json'",
        'own_tree_foreign_neighbor'),
    'alias_terminal': (
        "    if isinstance(model, str) and model.strip() and not model.startswith('@'):\n"
        "        return model\n"
        "    return None",
        "    if isinstance(model, str) and model.strip():\n"
        "        return model\n"
        "    return None",
        'alias_cycle_fact_alias'),
    'alias_terminal_honest_fact': (
        "    if isinstance(model, str) and model.strip() and not model.startswith('@'):\n"
        "        return model\n"
        "    return None",
        "    if isinstance(model, str) and model.strip():\n"
        "        return model\n"
        "    return None",
        'alias_cycle_honest_fact'),
    'stub_alias_any_family': (
        "    if isinstance(model, str) and model.strip() and not model.startswith('@'):\n"
        "        return model\n"
        "    return None",
        "    if (isinstance(model, str) and model.strip() and not model.startswith('@')\n"
        "            and not any(isinstance(value, str) and value.startswith('@')\n"
        "                        for value in models.values())):\n"
        "        return model\n"
        "    return None",
        'alias_other_family_control'),
}


def check(root, env, script, case):
    result = call(['python3', str(script), str(root), '42'] if script.suffix == '.py' else
                  ['bash', str(script), str(root), '42'], root, env)
    expected = CASES[case]
    expected_rc, expected_reason = expected[0], expected[1]
    branch = expected[2] if len(expected) > 2 else 'pr-42'
    log = Path(env['TOY_MERGE_LOG'])
    merged = json.loads(log.read_text()) if log.exists() else None
    if expected_rc == 0:
        expected = ['pr', 'merge', '42', '-R', REPO, '--merge', '--match-head-commit', env['TOY_HEAD']]
        parents = call(['git', 'rev-list', '--parents', '-n', '1', 'HEAD'], root).stdout.split()
        return (result.returncode == 0 and merged == expected and len(parents) == 3
                and parents[2] == env['TOY_HEAD']), result
    if expected_rc == 2:
        return (result.returncode == 2 and merged is None
                and call(['git', 'branch', '--show-current'], root).stdout.strip() == branch), result
    return (result.returncode == expected_rc
            and (expected_reason is None or expected_reason in result.stdout.splitlines())
            and merged is None
            and call(['git', 'branch', '--show-current'], root).stdout.strip() == branch), result


def main():
    parser = argparse.ArgumentParser()
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--model', action='store_true')
    group.add_argument('--stabs', action='store_true')
    group.add_argument('--repo', type=Path)
    args = parser.parse_args()
    source = (args.repo or DEFAULT_REPO).resolve()
    if not (source / '.git').exists():
        parser.error('ожидается корень Git-репозитория')
    failed = False
    jobs = [(name, case, old, new) for name, (old, new, case) in MUTATIONS.items()] if args.stabs else [
        (case, case, None, None) for case in CASES]
    for name, case, old, new in jobs:
        with tempfile.TemporaryDirectory(prefix='arch-door-186-') as directory:
            tmp = Path(directory)
            project, env = world(tmp, case)
            if args.model or args.stabs:
                # v+1: контроль исполняется из изолированной install-копии
                # tmp/control.py, чтобы назначение critic читалось из toy-реестра
                # tmp/config/agent_models.json, а не из живого дерева харнесса.
                original = (HERE / 'door_control.py').read_text(encoding='utf-8')
                if args.stabs:
                    if original.count(old) != 1:
                        raise RuntimeError('non-unique mutant anchor: ' + name)
                    original = original.replace(old, new)
                    if name == 'skip_baseline':
                        fallback = "if status['baselineStatus'] != 'PASS' or status['contractReadiness']['incompatibleContracts']:"
                        if original.count(fallback) != 1:
                            raise RuntimeError('missing baseline fallback mutant anchor')
                        original = original.replace(fallback, 'if False:')
                control = write(tmp, 'control.py', original)
            else:
                door = source / 'scripts/merge_architecture_pr.sh'
                if not door.is_file():
                    print(f'186 door {name} KRASNO: merge door missing')
                    failed = True
                    continue
                # v+1: субъект тоже из изолированной install-копии tmp/scripts/,
                # реестр — тот же toy tmp/config/agent_models.json.
                control = write(tmp, 'scripts/merge_architecture_pr.sh',
                                door.read_text(encoding='utf-8'))
            if case == 'symlink_foreign_registry':
                # Н-2 (Adv186Impl): дверь зовётся по СИМЛИНКУ из чужого
                # дерева — стаб читает реестр, соседний со ССЫЛКОЙ; честная
                # дверь канонизирует путь скрипта и читает реестр своего дерева
                link_name = ('control.py' if control.suffix == '.py'
                             else 'scripts/merge_architecture_pr.sh')
                link = tmp / 'other' / link_name
                link.parent.mkdir(parents=True, exist_ok=True)
                link.symlink_to(control)
                control = link
            ok, result = check(project, env, control, case)
            if args.stabs:
                ok = not ok and result.returncode != 2
            label = ('caught' if ok else 'ZHIV') if args.stabs else ('ok' if ok else 'KRASNO')
            print(f'186 door {name} {label}: rc={result.returncode} output={result.stdout.strip()} {result.stderr.strip()}')
            failed |= not ok
    return int(failed)


if __name__ == '__main__':
    raise SystemExit(main())
