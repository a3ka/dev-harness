"""140: внешний носитель и удостоверенная доставка. Ожидания заданы до субъекта."""
import hashlib
import json
from pathlib import Path


CASES = {
    'p01-produktovyj-start': 'продуктовая-пара;контракт-в-OBJECT;START-настоящий',
    'p02-produktovyj-object-chuzhoj': 'продуктовая-пара;OBJECT-не-tip',
    'p03-peredacha-zapis': 'передача;append-PEREDACHA;без-START-и-сдвига-веток',
    'p04-produkt-bez-kontrakta': 'суд-продукта;точный-frozen-только-продукта',
    'p05-frozen-riskovyj': 'frozen-рисковый;ревьюер-до-адверсария',
    'p06-frozen-ne-main-ne-latest': 'frozen-точный;новый-main-и-tag-не-источники',
    'p07-kontrakt-kandidata-prioritet': 'OBJECT-обычный;frozen-рисковый;приоритет-frozen',
    'p08-kontrakt-kandidata-isporchen': 'OBJECT-без-декларации;frozen-обычный;приоритет-frozen',
    'p09-frozen-net': 'передача;нет-frozen;отказ-до-записей',
    'p10-frozen-podmenen': 'передача;tag-object-подменён',
    'p11-avtor-produkta-chuzhoj': 'передача;автор-продуктового-коммита-не-рабочий',
    'p12-remote-produkta-chuzhoj': 'передача;origin-не-canonicalRemote',
    'p13-tip-produkta-sdvinut': 'передача;живой-tip-не-OBJECT',
    'p14-pustoj-rezultat': 'передача;пустой-коммит-не-сдача',
    'p15-start-ne-tot': 'передача;digest-последнего-START-не-совпадает',
    'p16-svidetelstvo-ne-opublikovano': 'передача;receipt-вне-origin/main',
    'p17-svidetelstvo-ne-orchestrator': 'передача;receipt-не-авторизован-станцией',
    'p18-avtor-ne-sdal': 'передача;нет-сдачи-исходного-рабочего',
    'p19-zhivoj-sudja': 'передача;живой-судья-не-снимается',
    'p20-pravka-ucheta': 'суд;proof-учёта-не-совпадает-с-Git',
    'p21-pustoj-start-ne-peredacha': 'новый-START-не-наследует-старую-передачу',
    'p22-povtornyj-sud': 'передача-не-обнуляет-роль-OBJECT',
    'p23-release-ne-menjaet-object': 'RELEASE-и-TTL-не-меняют-D9',
    'p24-receipt-schema': 'передача;лишнее-поле-свидетельства',
    'p25-uchet-start-podmenen': 'суд;исходный-START-изменён-после-передачи',
    'p26-frozen-ne-po-reestru': 'передача;версия-не-совпадает-с-реестром-свидетельства',
    'p27-paket-frozen-otkat': 'пакет;плохой-frozen;нет-частичного-START',
    'p28-frozen-derevo-protivorechivo': 'frozen;все-файлы;конфликт-класса',
    'p29-net-svidetelstva': 'суд;подложная-PEREDACHA-без-Git-свидетельства',
    'p30-pravka-nositelya-posle-peredachi': 'суд;remote-после-передачи-перепроверяется',
    'p31-verdikt-posle-peredachi': 'передача;вердиктный-хвост;OBJECT-и-proof-неизменны',
    'p32-frozen-obychnyj-object-riskovyj': 'OBJECT-рисковый;frozen-обычный;reviewer-допущен',
    'p33-peredacha-nepustogo-merge': 'передача-197;непустой-merge;author-и-START-сохранены',
    'p34-produkt-riskovyj-stancija-obychnyj': 'продукт-рисковый;станция-обычная;владелец-не-подменён',
    'p35-produkt-obychnyj-stancija-riskovaja': 'продукт-обычный;станция-рисковая;владелец-не-подменён',
    'p36-produkt-frozen-commit-podmenen': 'передача;commit-продуктового-frozen-не-совпадает',
    'p37-produkt-pin-net': 'прямой-продуктовый-START;pin-отсутствует-у-владельца',
    'p38-legacy-prjamoj-obychnyj': 'прямой-продукт;legacy-обычный;станция-без-записи',
    'p39-legacy-prjamoj-konflikt': 'прямой-продукт;legacy-обычный;станция-рисковая',
    'p40-legacy-prjamoj-riskovyj': 'прямой-продукт;legacy-рисковый;станция-обычная',
    'p41-legacy-peredannyj-obychnyj': 'переданный-продукт;legacy-обычный;станция-без-записи',
    'p42-legacy-peredannyj-konflikt': 'переданный-продукт;legacy-обычный;станция-рисковая',
    'p43-legacy-peredannyj-riskovyj': 'переданный-продукт;legacy-рисковый;станция-обычная',
    'p44-legacy-prjamoj-net-zapisi': 'прямой-продукт;legacy-нет-записи;станция-обычная;fail-closed',
    'p45-legacy-peredannyj-net-zapisi': 'переданный-продукт;legacy-нет-записи;станция-обычная;fail-closed',
    'p46-legacy-stancija-obychnyj': 'станционный-предмет;legacy-обычный;кандидат-рисковый',
    'p47-legacy-stancija-riskovyj': 'станционный-предмет;legacy-рисковый;кандидат-обычный',
    'p48-override-peredacha-schema': 'общая-строка;передача;прерывание-после-schema;разовый-пропуск',
}

BINDINGS = {
    's56-frozen-vmesto-kandidata': [
        'p07-kontrakt-kandidata-prioritet', 'p08-kontrakt-kandidata-isporchen',
        'p32-frozen-obychnyj-object-riskovyj',
        'q29-stancija-frozen-obychnyj-object-riskovyj',
        'q30-stancija-frozen-riskovyj-object-obychnyj',
        'p46-legacy-stancija-obychnyj', 'p47-legacy-stancija-riskovyj'],
    's76-receipt-merge-bez-roditelja': ['p33-peredacha-nepustogo-merge'],
    's77-frozen-stancija-vmesto-vladelca': [
        # Прямой critic без станционного frozen использует bootstrap; рисковый
        # fallback неотличим от честного риска. Различимы только эти входы:
        'p03-peredacha-zapis', 'p35-produkt-obychnyj-stancija-riskovaja'],
    's78-risk-stancija-vmesto-produkta': [
        'p34-produkt-riskovyj-stancija-obychnyj', 'p35-produkt-obychnyj-stancija-riskovaja'],
    's79-legacy-stancija-vmesto-vladelca': [
        'p38-legacy-prjamoj-obychnyj', 'p39-legacy-prjamoj-konflikt',
        'p40-legacy-prjamoj-riskovyj', 'p41-legacy-peredannyj-obychnyj',
        'p42-legacy-peredannyj-konflikt', 'p43-legacy-peredannyj-riskovyj',
        'p44-legacy-prjamoj-net-zapisi', 'p45-legacy-peredannyj-net-zapisi'],
    's80-legacy-proverka-stancii': [
        'p38-legacy-prjamoj-obychnyj', 'p41-legacy-peredannyj-obychnyj'],
    's81-legacy-chtenie-stancii': [
        'p39-legacy-prjamoj-konflikt', 'p40-legacy-prjamoj-riskovyj',
        'p42-legacy-peredannyj-konflikt', 'p43-legacy-peredannyj-riskovyj'],
}


def dobavit(K, p):
    def command(door, m, receipt):
        return p.run([p.BASH, str(door), '--peredat', '--sostojanie', str(m.sost),
                      '--zhurnaly', str(m.zhurnaly), '--repo', str(m.repo), '197', receipt])

    def product(m, contract=None, author='implementer', empty=False, merge=False,
                risk='обычный', conflict=False, legacy=False):
        wt = m.root / 'product'
        wt.mkdir()
        def git(*args):
            r = p.run(['git', '-c', 'user.name='+author, '-c', 'user.email=i@t',
                       '-c', 'commit.gpgsign=false', *args], cwd=str(wt))
            assert r.returncode == 0, r.stderr
            return r.stdout.strip()
        git('init', '-q')
        git('remote', 'add', 'origin', p.MOB_REMOTE)
        # Frozen и реестр принадлежат продукту; станция этих объектов не получает.
        git('checkout', '-q', '-b', 'frozen-owner')
        (wt / 'contracts').mkdir()
        (wt / 'contracts/197-product.md').write_text(
            '# old frozen without risk declaration\n' if legacy else 'КЛАСС РИСКА: '+risk+'\n')
        if conflict:
            (wt / 'contracts/197-second.md').write_text('КЛАСС РИСКА: рисковый\n')
        git('add', '-A')
        git('commit', '-qm', 'product frozen')
        tag = 'frozen/contracts/197/3'
        git('tag', '-a', tag, '-m', 'frozen')
        (wt / 'registry').mkdir()
        (wt / 'registry/contracts.tsv').write_text('197 → '+git('rev-parse', tag)+'\n')
        if legacy:
            blob = git('rev-parse', tag+'^{commit}:contracts/197-product.md')
            (wt / 'registry/risk-legacy.tsv').write_text(blob+'\t'+risk+'\told\towner\n')
        git('add', '-A')
        git('commit', '-qm', 'product pin')
        branch = 'wip/197/implementer-v3'
        git('checkout', '-q', '-b', branch)
        for path in (wt / 'contracts').iterdir():
            path.unlink()
        if not empty:
            (wt / 'product.txt').write_text('real delivered change\n')
        if contract is not None:
            (wt / 'contracts/197-product.md').write_text(contract, encoding='utf-8')
        git('add', '-A')
        git('commit', '-q', '-m', 'delivered')
        if empty:
            git('commit', '-q', '--allow-empty', '-m', 'empty final result')
        if merge:
            git('switch', '-q', '-c', 'merge-side')
            (wt / 'merged.txt').write_text('nonempty delivery against first parent\n')
            git('add', '-A')
            git('commit', '-qm', 'side payload')
            git('switch', '-q', branch)
            git('merge', '-q', '--no-ff', 'merge-side', '-m', 'delivered merge')
        return wt, branch, git('rev-parse', 'HEAD')

    def setup(m, contract=None, risk='обычный', author='implementer', empty=False,
              receipt_author='orchestrator', extra=False, conflict=False, merge=False,
              bad_commit=False, legacy=False):
        wt0, br0, _ = m.worktree('197')
        m.start('197', 'Impl197', rol='implementer', wt=wt0, branch=br0)
        m.zhurnal('Impl197', sdal=True)
        wt, branch, obj = product(m, contract, author, empty, merge, risk, conflict, legacy)
        tag = 'frozen/contracts/197/3'
        def product_git(*args):
            r = p.run(['git', *args], cwd=str(wt))
            assert r.returncode == 0, r.stderr
            return r.stdout.strip()
        tag_object = product_git('rev-parse', tag)
        frozen = product_git('rev-parse', tag+'^{commit}')
        if bad_commit:
            frozen = obj
        worker = m.ledg()[0]
        digest = hashlib.sha256(json.dumps(worker, sort_keys=True, separators=(',', ':'),
                                          ensure_ascii=False).encode()).hexdigest()
        proof = dict(version=1, repoId=p.REPO_ID, subjectId='197', holder='Impl197',
                     author='implementer', workerStart=digest, canonicalRemote=p.MOB_REMOTE,
                     worktree=str(wt), branch=branch, object=obj, frozenTag=tag,
                     frozenObject=tag_object, frozenCommit=frozen)
        if extra:
            proof['untrustedExtra'] = True
        receipt_path = m.repo / 'registry/dostavki/197.json'
        receipt_path.parent.mkdir(parents=True)
        # Честная эквивалентная JSON-запись: отступы и обратный порядок ключей.
        receipt_path.write_text(json.dumps(dict(reversed(list(proof.items()))),
                                          ensure_ascii=False, indent=2)+'\n', encoding='utf-8')
        (m.repo / 'registry/contracts.tsv').write_text('197 → '+tag_object+'\n', encoding='utf-8')
        m.git(['add', '-A'])
        r = p.run(['git', '-c', 'user.name='+receipt_author, '-c', 'user.email=o@t',
                   '-c', 'commit.gpgsign=false', 'commit', '-q', '-m', 'receipt'], cwd=str(m.repo))
        assert r.returncode == 0, r.stderr
        receipt = m.git(['rev-parse', 'HEAD']).stdout.strip()
        m.git(['update-ref', 'refs/remotes/origin/main', receipt])
        return dict(wt=wt, branch=branch, obj=obj, receipt=receipt, proof=proof,
                    original=m.ledger.read_bytes(), worker=worker, old_wt=wt0, old_br=br0)

    def fixture_transfer(m, s):
        # Готовое конформное состояние, не результат вызова проверяемого субъекта.
        row = dict(t='PEREDACHA', repoId=p.REPO_ID, subjectId='197',
                   receipt=s['receipt'], proof=s['proof'], at='2026-11-19T12:00:00Z')
        with m.ledger.open('a') as f:
            f.write(json.dumps(row, ensure_ascii=False)+'\n')

    def judge(door, m, s, role='critic', obj=None):
        event = m.sobytie('judge.json', [p.item(role, 'Judge197',
                         ['SUBJECT=197', 'OBJECT='+(obj or s['obj'])])])
        return p.sudit(door, m, event)

    def refusal(r, reason):
        return [p.k_rc(r, 1, 'именованный-отказ'), p.k_prichina(r, reason, 'причина')]

    def cell(name, fn):
        K[name] = dict(osi=CASES[name], run=fn)

    def p01(m, door):
        wt, br, obj = product(m, 'КЛАСС РИСКА: обычный\n')
        assert m.git(['cat-file', '-e', obj]).returncode != 0
        event = m.sobytie('start.json', [p.item('implementer', 'Impl197',
                           ['SUBJECT=197', 'WORKTREE='+str(wt), 'BRANCH='+br], isolated=True)])
        r = p.sudit(door, m, event)
        m.zhurnal('Impl197', sdal=True)
        r2 = judge(door, m, dict(obj=obj))
        return [p.k_rc(r, 0, 'продуктовый-START'), p.k_rc(r2, 0, 'суд'),
                p.k_stroka(m, 'пара-продукта', holder='Impl197', worktree=str(wt), branch=br)]
    cell('p01-produktovyj-start', p01)

    def p02(m, door):
        wt, br, obj = product(m, 'КЛАСС РИСКА: обычный\n')
        m.start('197', 'Impl197', rol='implementer', wt=str(wt), branch=br)
        m.zhurnal('Impl197', sdal=True)
        before = p.snimok_fajlov(m.sost)
        r = judge(door, m, dict(obj=obj), obj=p.OBJECT_DUMMY)
        return p.k_otkaz_bez_effektov(r, m, 'OBJECT_RASHODITSJA', before)
    cell('p02-produktovyj-object-chuzhoj', p02)

    def p03(m, door, merge=False):
        s = setup(m, merge=merge)
        before = p.snimok_fajlov(m.sost)
        tip0 = p.run(['git', 'rev-parse', s['old_br']], cwd=s['old_wt']).stdout
        r = command(door, m, s['receipt'])
        rows = m.ledg()
        expected = dict(t='PEREDACHA', repoId=p.REPO_ID, subjectId='197',
                        receipt=s['receipt'], proof=s['proof'])
        actual = [{k:v for k,v in row.items() if k!='at'} for row in rows[1:]]
        after = p.snimok_fajlov(m.sost)
        unchanged = {k:v for k,v in after.items() if k!='uchet.jsonl'}
        return [p.k_rc(r, 0, 'передача'),
                None if actual==[expected] else 'не одна проверяемая PEREDACHA: '+repr(actual),
                None if m.ledger.read_bytes().startswith(s['original']) else 'исходный START переписан',
                None if unchanged=={k:v for k,v in before.items() if k!='uchet.jsonl'} else 'занятие изменено',
                p.k_chislo_startov(m, 'без-фиктивного-START', 1),
                None if p.run(['git','rev-parse',s['old_br']],cwd=s['old_wt']).stdout==tip0 else 'ветка рабочего сдвинута',
                None if p.run(['git','rev-parse',s['branch']],cwd=str(s['wt'])).stdout.strip()==s['obj'] else 'продукт сдвинут']
    cell('p03-peredacha-zapis', p03)
    cell('p33-peredacha-nepustogo-merge', lambda m, d: p03(m, d, merge=True))

    def judge_case(m, door, variant):
        contract = None
        risk = 'обычный'
        role = 'critic'
        reason = None
        if variant in ('risky','present'):
            risk='рисковый'; role='reviewer'
        if variant in ('risky', 'present'): reason='ADVERSARIJ_DO_REVJUERA'
        if variant=='present': contract='КЛАСС РИСКА: обычный\n'
        if variant=='bad-contract': contract='# no declaration\n'; role='reviewer'
        if variant=='opposite': contract='КЛАСС РИСКА: рисковый\n'; role='reviewer'
        if variant=='conflict': role='critic'; reason='KLASS_RISKA_NET'
        if variant=='station-ordinary': risk='рисковый'
        s=setup(m,contract=contract,risk=risk,conflict=(variant=='conflict'))
        if variant in ('station-ordinary', 'station-risky'):
            m.kontrakt('197', 'обычный' if variant=='station-ordinary' else 'рисковый')
            m.git(['tag', '-a', 'frozen/contracts/197/3', '-m', 'station frozen'])
            station_pin=m.git(['rev-parse','frozen/contracts/197/3']).stdout.strip()
            # HEAD станции конфликтует; опубликованный receipt остаётся неизменным.
            (m.repo/'registry/contracts.tsv').write_text('197 → '+station_pin+'\n')
            m.git(['add','-A']); m.git(['commit','-qm','station pin'])
            role='reviewer'
            reason='ADVERSARIJ_DO_REVJUERA' if variant=='station-ordinary' else None
        fixture_transfer(m,s)
        if variant=='newer':
            role='reviewer'
            # Новые main/tag самого владельца не подменяют pinned receipt.
            r=p.run(['git','switch','-q','-c','newer-frozen'],cwd=str(s['wt']))
            assert r.returncode==0,r.stderr
            (s['wt']/'contracts/197-product.md').write_text('КЛАСС РИСКА: рисковый\n')
            for args in (['add','-A'], ['-c','user.name=implementer','-c','user.email=i@t',
                                      'commit','-qm','newer contract'],
                         ['-c','user.name=implementer','-c','user.email=i@t',
                          'tag','-a','frozen/contracts/197/4','-m','newer'],
                         ['switch','-q',s['branch']]):
                r=p.run(['git',*args],cwd=str(s['wt']))
                assert r.returncode==0,r.stderr
        if variant=='ledger':
            rows=m.ledg(); rows[-1]['proof']['canonicalRemote']=p.BACK_REMOTE
            m.ledger.write_text(''.join(json.dumps(x,ensure_ascii=False)+'\n' for x in rows))
            reason='PEREDACHA_NEDOSTOVERNA'
        if variant=='start-edit':
            rows=m.ledg(); rows[0]['at']='2026-11-19T23:59:59Z'
            m.ledger.write_text(''.join(json.dumps(x,ensure_ascii=False)+'\n' for x in rows))
            reason='PEREDACHA_NEDOSTOVERNA'
        if variant=='remote-late':
            p.run(['git','remote','set-url','origin',p.BACK_REMOTE],cwd=str(s['wt']))
            reason='PEREDACHA_REMOTE'
        if variant=='no-receipt':
            rows=m.ledg(); rows[-1]['receipt']='0'*40
            m.ledger.write_text(''.join(json.dumps(x,ensure_ascii=False)+'\n' for x in rows))
            reason='PEREDACHA_NEDOSTOVERNA'
        if variant=='new-start':
            m.start('197','Empty197',rol='implementer',wt=s['old_wt'],branch=s['old_br'])
            m.zhurnal('Empty197',sdal=True)
            reason='OBJECT_RASHODITSJA'
        if variant=='repeat':
            m.start('197','OldJudge',klass='sudja',rol='critic',obj=s['obj'])
            m.zhurnal('OldJudge',sdal=True)
            reason='OBJECT_UZHE_SUZHEN'
        state_before = p.snimok_fajlov(m.sost)
        before=m.ledger.read_bytes()
        r=judge(door,m,s,role)
        if variant == 'repeat':
            return p.k_otkaz_bez_effektov(r, m, reason, state_before)
        if reason in ('KLASS_RISKA_NET', 'OBJECT_RASHODITSJA', 'OBJECT_UZHE_SUZHEN'):
            return p.k_warn(r, m, reason, '197') + [
                None if m.ledger.read_bytes().startswith(before) else 'переписан исходный учёт']
        if reason:
            return refusal(r,reason)+[None if m.ledger.read_bytes()==before else 'отказ дописал учёт']
        return [p.k_rc(r,0,'суд-переданного'),p.k_stroka(m,'START-судьи',holder='Judge197',object=s['obj'])]

    for name, variant in [
        ('p04-produkt-bez-kontrakta','good'),('p05-frozen-riskovyj','risky'),
        ('p06-frozen-ne-main-ne-latest','newer'),('p07-kontrakt-kandidata-prioritet','present'),
        ('p32-frozen-obychnyj-object-riskovyj','opposite'),
        ('p08-kontrakt-kandidata-isporchen','bad-contract'),('p20-pravka-ucheta','ledger'),
        ('p21-pustoj-start-ne-peredacha','new-start'),('p22-povtornyj-sud','repeat'),
        ('p25-uchet-start-podmenen','start-edit'),('p28-frozen-derevo-protivorechivo','conflict'),
        ('p29-net-svidetelstva','no-receipt'),('p30-pravka-nositelya-posle-peredachi','remote-late')]:
        cell(name,lambda m,d,v=variant:judge_case(m,d,v))

    def transfer_override(m, door, code, variant):
        s = setup(m)
        fixture_transfer(m, s)
        if code == 'PEREDACHA_REMOTE':
            p.run(['git','remote','set-url','origin',p.BACK_REMOTE],cwd=str(s['wt']))
        else:
            rows = m.ledg()
            rows[-1]['proof']['canonicalRemote'] = p.BACK_REMOTE
            m.ledger.write_text(''.join(json.dumps(row)+'\n' for row in rows))
        n = '198' if variant == 'subject' else '197'
        c = 'PAUZA_VLADELTSA' if variant == 'code' else code
        target = p.OBJECT_DUMMY if variant == 'object' else s['obj']
        line = 'РАЗРЕШИЛ-ВЛАДЕЛЕЦ-ЗАМОК: '+n+' '+c+' '+target
        def event(name, role='critic'):
            return m.sobytie(name+'.json', [p.item(role,name,
                ['SUBJECT=197','OBJECT='+s['obj'],line])])
        before = m.ledger.read_bytes()
        r = p.sudit(door,m,event('Override197'))
        if variant != 'once':
            return refusal(r,code)+[
                None if m.ledger.read_bytes()==before else 'чужая санкция изменила учёт']
        rows = [row for row in m.ledg() if row.get('t')=='override'
                and row.get('kod')==code and row.get('subjectId')=='197']
        problems = [p.k_rc(r,0,'разовая-передача'),
            p.k_stroka(m,'START',holder='Override197'),
            None if len(rows)==1 else 'нет единственного override передачи']
        m.zhurnal('Override197',sdal=True)
        before = m.ledger.read_bytes()
        # Другая роль: проверяем повтор receipt-санкции, не ранний D11.
        r2 = p.sudit(door,m,event('Again197', 'adversary'))
        return problems+refusal(r2,code)+[
            None if m.ledger.read_bytes()==before else 'повтор санкции изменил учёт']

    for code in ('PEREDACHA_NEDOSTOVERNA','PEREDACHA_REMOTE'):
        for variant in ('once','subject','code','object'):
            name = 'o03-'+code.lower()+'-'+variant
            K[name] = dict(osi='общая-строка;'+code+';'+variant,
                run=lambda m,d,c=code,v=variant:transfer_override(m,d,c,v))

    def rejected_transfer(m,door,variant):
        s=setup(m,author=('architect' if variant=='author' else 'implementer'),
                empty=(variant=='empty'),receipt_author=('battery' if variant=='receipt-author' else 'orchestrator'),
                extra=(variant=='schema'),bad_commit=(variant=='bad-commit'))
        reason='PEREDACHA_NEDOSTOVERNA'
        if variant=='no-frozen':
            p.run(['git','tag','-d','frozen/contracts/197/3'],cwd=str(s['wt'])); reason='KLASS_RISKA_NET'
        if variant=='bad-tag':
            p.run(['git','-c','user.name=implementer','-c','user.email=i@t',
                   'tag','-f','-a','frozen/contracts/197/3','-m','tampered'],cwd=str(s['wt']))
            reason='KLASS_RISKA_NET'
        if variant=='bad-commit': reason='KLASS_RISKA_NET'
        if variant in ('author','receipt-author'): reason='PEREDACHA_AVTOR'
        if variant=='remote':
            p.run(['git','remote','set-url','origin',p.BACK_REMOTE],cwd=str(s['wt'])); reason='PEREDACHA_REMOTE'
        if variant=='tip':
            # Непустой новый кандидат: именно расхождение OBJECT, не [D50].
            (s['wt'] / 'moved.txt').write_text('different delivered change\n')
            p.run(['git','add','moved.txt'],cwd=str(s['wt']))
            p.run(['git','-c','user.name=implementer','-c','user.email=i@t','commit','-q','-m','moved'],cwd=str(s['wt']))
            reason='OBJECT_RASHODITSJA'
        if variant=='start':
            rows=m.ledg(); rows[0]['at']='different'
            m.ledger.write_text(json.dumps(rows[0])+'\n')
        if variant=='unpublished': m.git(['update-ref','-d','refs/remotes/origin/main'])
        if variant=='active': m.zhurnal('Impl197',sdal=False); reason='ZAMOK_ZHIV'
        if variant=='judge':
            m.start('197','LiveJudge',klass='sudja',rol='critic',obj=s['obj'])
            m.zhurnal('LiveJudge',sdal=False); reason='ZAMOK_ZHIV'
        if variant=='registry':
            # Другая авторизованная receipt-ревизия с несогласованным реестром.
            (m.repo/'registry/contracts.tsv').write_text('197 → '+'0'*40+'\n',encoding='utf-8')
            m.git(['add','-A'])
            p.run(['git','-c','user.name=orchestrator','-c','user.email=o@t','commit','-q','-m','bad registry'],cwd=str(m.repo))
            s['receipt']=m.git(['rev-parse','HEAD']).stdout.strip()
            m.git(['update-ref','refs/remotes/origin/main',s['receipt']]); reason='KLASS_RISKA_NET'
        before=p.snimok_fajlov(m.sost)
        r=command(door,m,s['receipt'])
        warning = reason in ('KLASS_RISKA_NET', 'OBJECT_RASHODITSJA', 'PEREDACHA_AVTOR')
        problems = p.k_warn(r, m, reason, '197', start=False) if warning else refusal(r,reason)
        if variant=='empty':
            # Тот же пустой tip не является OBJECT для судьи; --peredat выше
            # диагностирует прежде всего пустой payload удостоверенной передачи.
            resolved=p.run([p.BASH,str(door),'--object','--repo',str(s['wt']),
                            '197',s['branch']])
            problems+=refusal(resolved,'OBJECT_RASHODITSJA')
        if warning:
            return problems + [p.k_chislo_startov(m, 'передача-без-START', 1),
                None if any(row.get('t')=='PEREDACHA' for row in m.ledg())
                else 'предупреждение не записало передачу']
        return problems+[None if p.snimok_fajlov(m.sost)==before else 'отказ передачи изменил долговечное состояние']

    for name,variant in [
        ('p09-frozen-net','no-frozen'),('p10-frozen-podmenen','bad-tag'),
        ('p11-avtor-produkta-chuzhoj','author'),('p12-remote-produkta-chuzhoj','remote'),
        ('p13-tip-produkta-sdvinut','tip'),('p14-pustoj-rezultat','empty'),
        ('p15-start-ne-tot','start'),('p16-svidetelstvo-ne-opublikovano','unpublished'),
        ('p17-svidetelstvo-ne-orchestrator','receipt-author'),('p18-avtor-ne-sdal','active'),
        ('p36-produkt-frozen-commit-podmenen','bad-commit'),
        ('p19-zhivoj-sudja','judge'),('p24-receipt-schema','schema'),('p26-frozen-ne-po-reestru','registry')]:
        cell(name,lambda m,d,v=variant:rejected_transfer(m,d,v))

    def p23(m,door):
        s=setup(m)
        m.zhurnal('Impl197',sdal=False,vozrast_min=90)
        r=p.osvobodit(door,m,'197','Impl197')
        m.zhurnal('Impl197',sdal=True)
        r2=judge(door,m,s)
        return [p.k_rc(r,0,'освобождение')]+p.k_warn(r2,m,'OBJECT_RASHODITSJA','197')
    cell('p23-release-ne-menjaet-object',p23)

    def p27(m,door):
        s=setup(m)
        fixture_transfer(m,s)
        p.run(['git','tag','-d','frozen/contracts/197/3'],cwd=str(s['wt']))
        wt,br,_=m.worktree('198')
        event=m.sobytie('batch.json',[
            p.item('architect','Arch198',['SUBJECT=198','WORKTREE='+wt,'BRANCH='+br],isolated=True),
            p.item('critic','Judge197',['SUBJECT=197','OBJECT='+s['obj']])])
        before=p.snimok_fajlov(m.sost)
        r=p.sudit(door,m,event)
        return p.k_warn(r,m,'KLASS_RISKA_NET','197') + [
            p.k_chislo_startov(m,'пакет-записан',3),
            p.k_zanyat(m,'198','Arch198','рабочий-пакета'),
            p.k_zanyat(m,'197','Judge197','судья-пакета')]
    cell('p27-paket-frozen-otkat',p27)

    def p31(m, door):
        s = setup(m)
        fixture_transfer(m, s)
        before = m.ledger.read_bytes()
        path = s['wt'] / 'verdicts/adversary/contracts-197-impl-v1.md'
        path.parent.mkdir(parents=True)
        path.write_text('accept\nOBJECT='+s['obj']+'\n')
        r = p.run(['git', 'add', '-A'], cwd=str(s['wt']))
        assert r.returncode == 0, r.stderr
        r = p.run(['git', '-c', 'user.name=adversary', '-c', 'user.email=a@t',
                   'commit', '-qm', 'verdict only'], cwd=str(s['wt']))
        assert r.returncode == 0, r.stderr
        tip = p.run(['git', 'rev-parse', s['branch']], cwd=str(s['wt'])).stdout
        r = judge(door, m, s)
        return [p.k_rc(r, 0, 'суд-исходного-OBJECT-после-вердикта'),
                None if m.ledger.read_bytes().startswith(before) else 'переписан proof/START',
                None if m.ledg()[-1].get('object') == s['obj'] else 'OBJECT сдвинут',
                None if p.run(['git', 'rev-parse', s['branch']], cwd=str(s['wt'])).stdout == tip
                else 'ветка сдвинута']
    cell('p31-verdikt-posle-peredachi', p31)

    cell('p34-produkt-riskovyj-stancija-obychnyj',
         lambda m,d: judge_case(m,d,'station-ordinary'))
    cell('p35-produkt-obychnyj-stancija-riskovaja',
         lambda m,d: judge_case(m,d,'station-risky'))

    def p37(m, door):
        wt, br, obj = product(m)
        m.start('197','Impl197',rol='implementer',wt=str(wt),branch=br)
        m.zhurnal('Impl197',sdal=True)
        (wt/'registry/contracts.tsv').write_text('')
        for args in (['add','-A'], ['-c','user.name=implementer','-c','user.email=i@t',
                                  'commit','-qm','remove product pin']):
            r=p.run(['git',*args],cwd=str(wt))
            assert r.returncode==0,r.stderr
        obj=p.run(['git','rev-parse','HEAD'],cwd=str(wt)).stdout.strip()
        before=m.ledger.read_bytes()
        return p.k_warn(judge(door,m,dict(obj=obj)),m,'KLASS_RISKA_NET','197')+[
            None if m.ledger.read_bytes().startswith(before) else 'START переписан']
    cell('p37-produkt-pin-net',p37)

    def legacy_product(m, door, transferred, risk, station, missing=False):
        # Один и тот же frozen blob имеет независимые привязки в двух .git.
        # OBJECT декларирует противоположный класс и не заменяет старый frozen.
        contract = 'КЛАСС РИСКА: '+('рисковый' if risk=='обычный' else 'обычный')+'\n'
        if transferred:
            s = setup(m, contract=contract, risk=risk, legacy=True)
        else:
            wt, branch, obj = product(m, contract=contract, risk=risk, legacy=True)
            s = dict(wt=wt, branch=branch, obj=obj)
            event = m.sobytie('start.json', [p.item('implementer', 'Impl197',
                ['SUBJECT=197', 'WORKTREE='+str(wt), 'BRANCH='+branch], isolated=True)])
            r = p.sudit(door, m, event)
            if r.returncode:
                return [p.k_rc(r, 0, 'прямой-START')]
            m.zhurnal('Impl197', sdal=True)
        blob = p.run(['git', 'rev-parse',
                      'frozen/contracts/197/3^{commit}:contracts/197-product.md'],
                     cwd=str(s['wt'])).stdout.strip()
        assert len(blob)==40
        if station is not None:
            m.risk_legacy(blob, station)
        if missing:
            # Отсутствие файла у владельца при допустимой станционной привязке.
            (s['wt'] / 'registry/risk-legacy.tsv').unlink()
        problems = []
        if transferred:
            before = p.snimok_fajlov(m.sost)
            r = command(door, m, s['receipt'])
            problems += [p.k_rc(r, 0, 'передача-legacy')]
            problems += [None if m.ledger.read_bytes().startswith(s['original'])
                         else 'передача переписала исходный START']
            problems += [p.k_chislo_startov(m, 'передача-без-START', 1)]
            problems += [None if {k:v for k,v in p.snimok_fajlov(m.sost).items()
                                  if k!='uchet.jsonl'} ==
                                 {k:v for k,v in before.items() if k!='uchet.jsonl'}
                         else 'передача изменила замок']
            if r.returncode:
                return problems
            rows = m.ledg()
            problems += [None if len(rows)==2 and rows[-1].get('t')=='PEREDACHA'
                         and rows[-1].get('proof')==s['proof']
                         else 'legacy-передача не записала настоящий proof']
        before = p.snimok_fajlov(m.sost)
        r = judge(door, m, s, 'reviewer')
        reason = 'ADVERSARIJ_DO_REVJUERA' if missing or risk=='рисковый' else None
        if reason:
            return problems+refusal(r, reason)+[
                None if {k:v for k,v in p.snimok_fajlov(m.sost).items() if k!='uchet.jsonl'} ==
                        {k:v for k,v in before.items() if k!='uchet.jsonl'}
                else 'отказ legacy изменил замок']
        return problems+[p.k_rc(r, 0, 'legacy-reviewer'),
                         p.k_stroka(m, 'legacy-START', holder='Judge197', object=s['obj'])]

    for name, transferred, risk, station, missing in [
        ('p38-legacy-prjamoj-obychnyj', False, 'обычный', None, False),
        ('p39-legacy-prjamoj-konflikt', False, 'обычный', 'рисковый', False),
        ('p40-legacy-prjamoj-riskovyj', False, 'рисковый', 'обычный', False),
        ('p41-legacy-peredannyj-obychnyj', True, 'обычный', None, False),
        ('p42-legacy-peredannyj-konflikt', True, 'обычный', 'рисковый', False),
        ('p43-legacy-peredannyj-riskovyj', True, 'рисковый', 'обычный', False),
        ('p44-legacy-prjamoj-net-zapisi', False, 'обычный', 'обычный', True),
        ('p45-legacy-peredannyj-net-zapisi', True, 'обычный', 'обычный', True),
    ]:
        cell(name, lambda m,d,t=transferred,r=risk,s=station,x=missing:
             legacy_product(m,d,t,r,s,x))

    def legacy_station(m, door, risk):
        wt, br, _ = m.worktree('141', kontrakty=[
            ('fajl', '141-stub.md', '# station old frozen without risk declaration\n')])
        blob = m.blob_kandidata('141', '141-stub.md')
        m.risk_legacy(blob, risk)
        # Кандидат и его локальный реестр не являются источниками станции.
        opposite = 'рисковый' if risk=='обычный' else 'обычный'
        (Path(wt) / 'contracts/141-stub.md').write_text('КЛАСС РИСКА: '+opposite+'\n')
        (Path(wt) / 'registry').mkdir()
        (Path(wt) / 'registry/risk-legacy.tsv').write_text(blob+'\t'+opposite+'\told\towner\n')
        for args in (['add','-A'], ['-c','user.name=implementer','-c','user.email=i@t',
                                  'commit','-qm','station candidate']):
            result = p.run(['git',*args],cwd=wt)
            assert result.returncode==0,result.stderr
        obj = p.run(['git','rev-parse','HEAD'],cwd=wt).stdout.strip()
        m.start('141','Impl141',rol='implementer',wt=wt,branch=br)
        m.zhurnal('Impl141',sdal=True)
        event = m.sobytie('review.json',[p.item('reviewer','Rev141',
                           ['SUBJECT=141','OBJECT='+obj])])
        before = p.snimok_fajlov(m.sost)
        r = p.sudit(door,m,event)
        if risk=='рисковый':
            return refusal(r,'ADVERSARIJ_DO_REVJUERA')+[
                None if p.snimok_fajlov(m.sost)==before else 'отказ станции изменил состояние']
        return [p.k_rc(r,0,'станционный-legacy'),
                p.k_stroka(m,'станционный-START',holder='Rev141',object=obj)]

    cell('p46-legacy-stancija-obychnyj',lambda m,d:legacy_station(m,d,'обычный'))
    cell('p47-legacy-stancija-riskovyj',lambda m,d:legacy_station(m,d,'рисковый'))

    def override_transfer(m, door):
        s = setup(m, extra=True)
        # Два независимых дефекта: schema (лишнее поле), затем worker digest.
        # Санкция ровно на первый; честная дверь не исполняет второй этап.
        s['proof']['workerStart'] = '0' * 64
        receipt_path = m.repo / 'registry/dostavki/197.json'
        receipt_path.write_text(json.dumps(s['proof'])+'\n')
        m.git(['add', '-A'])
        r = p.run(['git', '-c', 'user.name=orchestrator', '-c', 'user.email=o@t',
                   'commit', '-qm', 'schema and digest input'], cwd=str(m.repo))
        assert r.returncode == 0, r.stderr
        s['receipt'] = m.git(['rev-parse', 'HEAD']).stdout.strip()
        m.git(['update-ref', 'refs/remotes/origin/main', s['receipt']])
        fixture_transfer(m, s)
        line = 'РАЗРЕШИЛ-ВЛАДЕЛЕЦ-ЗАМОК: 197 PEREDACHA_NEDOSTOVERNA '+s['obj']
        it = p.item('critic', 'Override197', ['SUBJECT=197', 'OBJECT='+s['obj'], line])
        before = m.ledger.read_bytes()
        r = p.sudit(door, m, m.sobytie('override.json', [it]))
        overrides = [row for row in m.ledg() if row.get('t') == 'override'
                     and row.get('subjectId') == '197'
                     and row.get('kod') == 'PEREDACHA_NEDOSTOVERNA'
                     and row.get('object') == s['obj']]
        problems = [p.k_rc(r, 0, 'прерывание-передачи'),
                    p.k_stroka(m, 'START-после-санкции', holder='Override197', object=s['obj']),
                    None if len(overrides) == 1 else 'не записано ровно одно применение',
                    None if m.ledger.read_bytes().startswith(before) else 'переписан исходный учёт']
        m.zhurnal('Override197', sdal=True)
        before2 = m.ledger.read_bytes()
        # Тот же OBJECT/override, другая роль: дефект наблюдаем в D55, не D11.
        r2 = p.sudit(door, m, m.sobytie('again.json', [dict(it, agent='adversary', name='Again197')]))
        return problems + refusal(r2, 'PEREDACHA_NEDOSTOVERNA') + [
            None if m.ledger.read_bytes() == before2 else 'повтор санкции изменил учёт']

    cell('p48-override-peredacha-schema', override_transfer)


def mutacii(z):
    """Адресные удаления/замены существующих операций модели; привязки — source.json."""
    def legacy(t, check, read):
        # D64 separates owner from payload wt; mutate the same D30 fields.
        owner = 'owner' if '  owner="${4:-$wt}"' in t else 'wt'
        old = '''    if [ -z "$val" ] && [ -f "$%s/registry/risk-legacy.tsv" ]; then
      val="$(awk -F'\\t' -v b="$blob" 'b!="" && $1==b {print $2; exit}' "$%s/registry/risk-legacy.tsv")"
    fi''' % (owner, owner)
        new = '''    if [ -z "$val" ] && [ -f "$%s/registry/risk-legacy.tsv" ]; then
      val="$(awk -F'\\t' -v b="$blob" 'b!="" && $1==b {print $2; exit}' "$%s/registry/risk-legacy.tsv")"
    fi''' % ('REPO' if check else owner, 'REPO' if read else owner)
        return z(t, old, new)
    return {
        's49-receipt-bez-origin': lambda t:z(t,
            '  git -C "$REPO" merge-base --is-ancestor "$c" refs/remotes/origin/main 2>/dev/null \\\n    || perenos_otkaz PEREDACHA_NEDOSTOVERNA \'свидетельство не опубликовано на origin/main\'',
            '  : # стаб: происхождение receipt не проверяется'),
        's50-receipt-bez-worker': lambda t:z(t,
            '  [ "$digest" = "$(printf \'%s\' "$P_JSON" | jq -r .workerStart)" ] \\',
            '  [ -n "$digest" ] \\'),
        's51-receipt-bez-remote': lambda t:z(t,
            '  [ "$(git -C "$P_WT" remote get-url origin 2>/dev/null)" = "$(printf \'%s\' "$P_JSON" | jq -r .canonicalRemote)" ] \\',
            '  true \\'),
        's52-receipt-bez-tip': lambda t:z(t,
            '  [ "$(object_kandidata "$P_WT" "$n" "refs/heads/$P_BRANCH")" = "$P_OBJECT" ] \\',
            '  true \\'),
        's53-receipt-bez-avtora': lambda t:z(t,
            '  [ "$(git -C "$P_WT" show -s --format=%an "$P_OBJECT" 2>/dev/null)" = "$(printf \'%s\' "$P_JSON" | jq -r .author)" ] \\',
            '  true \\'),
        's54-receipt-bez-frozen-ref': lambda t:z(t,
            '    && [ "$(git -C "$P_WT" rev-parse --verify "refs/tags/$ptag" 2>/dev/null)" = "$pobj" ] \\',
            '    && true \\'),
        's55-receipt-ne-pereproverjaet-proof': lambda t:z(t,
            '        [ "$(printf \'%s\' "$transfer" | jq -cS .proof)" = "$(printf \'%s\' "$P_JSON" | jq -cS .)" ] \\',
            '        true \\'),
        's56-frozen-vmesto-kandidata': lambda t:z(t,
            '      kr="$(klass_riska "$sv" "$risk_repo" "$P_FROZEN")"',
            '      kr="$(klass_riska "$sv" "$r_wt" "$obj")"'),
        's57-frozen-iz-main': lambda t:z(t,
            '      kr="$(klass_riska "$sv" "$risk_repo" "$P_FROZEN")"',
            '      kr="$(klass_riska "$sv" "$risk_repo" HEAD)"'),
        's58-receipt-bez-append': lambda t:z(t,
            '    \'{t:"PEREDACHA",repoId:$r,subjectId:$n,receipt:$c,proof:$proof,at:$at}\' >> "$LEDGER"',
            '    \'{t:"PEREDACHA",repoId:$r,subjectId:$n,receipt:$c,proof:$proof,at:$at}\' > /dev/null'),
        's59-receipt-bez-reestra': lambda t:z(t,
            '  [ "$reg" = "$n → $pobj" ] \\', '  true \\'),
        's60-receipt-pustoj-rezultat': lambda t:z(t,
            '  [ -n "$(puti_kommita "$P_WT" "$P_OBJECT")" ] \\',
            '  true \\'),
        's76-receipt-merge-bez-roditelja': lambda t:z(t,
            '  [ -n "$(puti_kommita "$P_WT" "$P_OBJECT")" ] \\',
            '  [ -n "$(git -C "$P_WT" diff-tree --root --no-commit-id --name-only -r "$P_OBJECT" 2>/dev/null)" ] \\'),
        's61-receipt-bez-grammatiki': lambda t:z(t,
            "    1) perenos_otkaz PEREDACHA_NEDOSTOVERNA 'схема свидетельства' ;;",
            "    1) : ;; # стаб: схема игнорируется"),
        's77-frozen-stancija-vmesto-vladelca': lambda t: z(z(z(z(t,
            'git -C "$P_WT" rev-parse --verify "refs/tags/$ptag"',
            'git -C "$REPO" rev-parse --verify "refs/tags/$ptag"'),
            'git -C "$P_WT" cat-file -t "$pobj"',
            'git -C "$REPO" cat-file -t "$pobj"'),
            'git -C "$P_WT" rev-parse --verify "$pobj^{commit}"',
            'git -C "$REPO" rev-parse --verify "$pobj^{commit}"'),
            'frozen_predmeta "$sv" "$risk_repo"', 'frozen_predmeta "$sv" "$REPO"'),
        's78-risk-stancija-vmesto-produkta': lambda t:z(t,
            '      kr="$(klass_riska "$sv" "$risk_repo" "$P_FROZEN")"',
            '      kr="$(klass_riska "$sv" "$REPO" "$(frozen_predmeta "$sv")")"'),
        's79-legacy-stancija-vmesto-vladelca': lambda t: legacy(t, True, True),
        's80-legacy-proverka-stancii': lambda t: legacy(t, True, False),
        's81-legacy-chtenie-stancii': lambda t: legacy(t, False, True),
    }


def owner_check(p, before=False):
    """Один и тот же конформный мир против принятой модели до/после К-02/К-16."""
    import tempfile
    K = p.kejsy()
    legacy = BINDINGS['s79-legacy-stancija-vmesto-vladelca']
    distinguishing = BINDINGS['s77-frozen-stancija-vmesto-vladelca'] + legacy
    controls = ['p09-frozen-net', 'p10-frozen-podmenen', 'p26-frozen-ne-po-reestru',
                'p33-peredacha-nepustogo-merge', 'p36-produkt-frozen-commit-podmenen',
                'p37-produkt-pin-net', 'q29-stancija-frozen-obychnyj-object-riskovyj',
                'q30-stancija-frozen-riskovyj-object-obychnyj',
                'p46-legacy-stancija-obychnyj', 'p47-legacy-stancija-riskovyj']
    failed = 0
    with tempfile.TemporaryDirectory(prefix='owner140-') as directory:
        door = p.MODEL
        if before:
            old = p.run(['git', 'show',
                         '971a5dfc2b681e519dbd544f2ffc6c72110239a8:'
                         'fixtures/workshop_project/odin_agent_140/model/zamok_predmeta.sh'],
                        cwd=str(p.REEPOR))
            if old.returncode:
                print('OWNER140_BASE_ABSENT', old.stderr)
                return 2
            door = Path(directory) / 'before.sh'
            door.write_text(old.stdout)
        for name in legacy if before else distinguishing + controls:
            problems = p.progon(door, name, K[name]['run'])
            print('OWNER_BEFORE' if before else 'OWNER_MODEL', name, problems or 'ok')
            failed += bool(problems)
        if not before:
            base = p.MODEL.read_text()
            for mutant in ('s77-frozen-stancija-vmesto-vladelca',
                           's78-risk-stancija-vmesto-produkta',
                           's79-legacy-stancija-vmesto-vladelca',
                           's80-legacy-proverka-stancii', 's81-legacy-chtenie-stancii'):
                path = Path(directory) / (mutant+'.sh')
                path.write_text(p.STAB_MUTACII[mutant](base))
                for name in BINDINGS[mutant]:
                    problems = p.progon(path, name, K[name]['run'])
                    print('OWNER_MUTANT', mutant, name, problems or 'LIVE')
                    failed += not bool(problems)
    print('OWNER140_FAILURES', failed)
    return int(bool(failed))
