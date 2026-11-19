"""140: внешний носитель и удостоверенная доставка. Ожидания заданы до субъекта."""
import hashlib
import json
from pathlib import Path


CASES = {
    'p01-produktovyj-start': 'продуктовая-пара;контракт-в-OBJECT;START-настоящий',
    'p02-produktovyj-object-chuzhoj': 'продуктовая-пара;OBJECT-не-tip',
    'p03-peredacha-zapis': 'передача;append-PEREDACHA;без-START-и-сдвига-веток',
    'p04-produkt-bez-kontrakta': 'суд-продукта;точный-frozen-станции',
    'p05-frozen-riskovyj': 'frozen-рисковый;ревьюер-до-адверсария',
    'p06-frozen-ne-main-ne-latest': 'frozen-точный;новый-main-и-tag-не-источники',
    'p07-kontrakt-kandidata-prioritet': 'кандидат-обычный;frozen-рисковый;без-fallback',
    'p08-kontrakt-kandidata-isporchen': 'кандидат-без-декларации;fallback-запрещён',
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
}


def dobavit(K, p):
    def command(door, m, receipt):
        return p.run([p.BASH, str(door), '--peredat', '--sostojanie', str(m.sost),
                      '--zhurnaly', str(m.zhurnaly), '--repo', str(m.repo), '197', receipt])

    def product(m, contract=None, author='implementer', empty=False):
        wt = m.root / 'product'
        wt.mkdir()
        def git(*args):
            r = p.run(['git', '-c', 'user.name='+author, '-c', 'user.email=i@t',
                       '-c', 'commit.gpgsign=false', *args], cwd=str(wt))
            assert r.returncode == 0, r.stderr
            return r.stdout.strip()
        git('init', '-q')
        git('remote', 'add', 'origin', p.MOB_REMOTE)
        branch = 'wip/197/implementer-v3'
        git('checkout', '-q', '-b', branch)
        if not empty:
            (wt / 'product.txt').write_text('real delivered change\n')
        if contract is not None:
            (wt / 'contracts').mkdir()
            (wt / 'contracts/197-product.md').write_text(contract, encoding='utf-8')
        git('add', '-A')
        git('commit', '-q', '--allow-empty', '-m', 'delivered')
        return wt, branch, git('rev-parse', 'HEAD')

    def setup(m, contract=None, risk='обычный', author='implementer', empty=False,
              receipt_author='orchestrator', extra=False, conflict=False):
        m.kontrakt('197', risk)
        if conflict:
            (m.repo / 'contracts/197-second.md').write_text('КЛАСС РИСКА: рисковый\n', encoding='utf-8')
            m.git(['add', '-A'])
            m.git(['commit', '-q', '-m', 'conflicting frozen'])
        tag = 'frozen/contracts/197/3'
        assert m.git(['tag', '-a', tag, '-m', 'frozen']).returncode == 0
        tag_object = m.git(['rev-parse', tag]).stdout.strip()
        frozen = m.git(['rev-parse', tag+'^{commit}']).stdout.strip()
        wt0, br0, _ = m.worktree('197')
        m.start('197', 'Impl197', rol='implementer', wt=wt0, branch=br0)
        m.zhurnal('Impl197', sdal=True)
        wt, branch, obj = product(m, contract, author, empty)
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
        return refusal(judge(door, m, dict(obj=obj), obj=p.OBJECT_DUMMY), 'OBJECT_RASHODITSJA')
    cell('p02-produktovyj-object-chuzhoj', p02)

    def p03(m, door):
        s = setup(m)
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

    def judge_case(m, door, variant):
        contract = None
        risk = 'обычный'
        role = 'critic'
        reason = None
        if variant in ('risky','present'):
            risk='рисковый'; role='reviewer'
        if variant=='risky': reason='ADVERSARIJ_DO_REVJUERA'
        if variant=='present': contract='КЛАСС РИСКА: обычный\n'
        if variant=='bad-contract': contract='# no declaration\n'; reason='KLASS_RISKA_NET'
        if variant=='conflict': reason='KLASS_RISKA_NET'
        s=setup(m,contract=contract,risk=risk,conflict=(variant=='conflict'))
        fixture_transfer(m,s)
        if variant=='newer':
            role='reviewer'
            m.kontrakt('197','рисковый')
            m.git(['tag','-a','frozen/contracts/197/4','-m','newer'])
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
        before=m.ledger.read_bytes()
        r=judge(door,m,s,role)
        if reason:
            return refusal(r,reason)+[None if m.ledger.read_bytes()==before else 'отказ дописал учёт']
        return [p.k_rc(r,0,'суд-переданного'),p.k_stroka(m,'START-судьи',holder='Judge197',object=s['obj'])]

    for name, variant in [
        ('p04-produkt-bez-kontrakta','good'),('p05-frozen-riskovyj','risky'),
        ('p06-frozen-ne-main-ne-latest','newer'),('p07-kontrakt-kandidata-prioritet','present'),
        ('p08-kontrakt-kandidata-isporchen','bad-contract'),('p20-pravka-ucheta','ledger'),
        ('p21-pustoj-start-ne-peredacha','new-start'),('p22-povtornyj-sud','repeat'),
        ('p25-uchet-start-podmenen','start-edit'),('p28-frozen-derevo-protivorechivo','conflict'),
        ('p29-net-svidetelstva','no-receipt'),('p30-pravka-nositelya-posle-peredachi','remote-late')]:
        cell(name,lambda m,d,v=variant:judge_case(m,d,v))

    def rejected_transfer(m,door,variant):
        s=setup(m,author=('architect' if variant=='author' else 'implementer'),
                empty=(variant=='empty'),receipt_author=('battery' if variant=='receipt-author' else 'orchestrator'),
                extra=(variant=='schema'))
        reason='PEREDACHA_NEDOSTOVERNA'
        if variant=='no-frozen':
            m.git(['tag','-d','frozen/contracts/197/3']); reason='KLASS_RISKA_NET'
        if variant=='bad-tag':
            m.git(['tag','-f','-a','frozen/contracts/197/3','-m','tampered']); reason='KLASS_RISKA_NET'
        if variant in ('author','receipt-author'): reason='PEREDACHA_AVTOR'
        if variant=='remote':
            p.run(['git','remote','set-url','origin',p.BACK_REMOTE],cwd=str(s['wt'])); reason='PEREDACHA_REMOTE'
        if variant=='tip':
            p.run(['git','-c','user.name=implementer','-c','user.email=i@t','commit','-q','--allow-empty','-m','moved'],cwd=str(s['wt']))
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
        return refusal(r,reason)+[None if p.snimok_fajlov(m.sost)==before else 'отказ передачи изменил долговечное состояние']

    for name,variant in [
        ('p09-frozen-net','no-frozen'),('p10-frozen-podmenen','bad-tag'),
        ('p11-avtor-produkta-chuzhoj','author'),('p12-remote-produkta-chuzhoj','remote'),
        ('p13-tip-produkta-sdvinut','tip'),('p14-pustoj-rezultat','empty'),
        ('p15-start-ne-tot','start'),('p16-svidetelstvo-ne-opublikovano','unpublished'),
        ('p17-svidetelstvo-ne-orchestrator','receipt-author'),('p18-avtor-ne-sdal','active'),
        ('p19-zhivoj-sudja','judge'),('p24-receipt-schema','schema'),('p26-frozen-ne-po-reestru','registry')]:
        cell(name,lambda m,d,v=variant:rejected_transfer(m,d,v))

    def p23(m,door):
        s=setup(m)
        m.zhurnal('Impl197',sdal=False,vozrast_min=90)
        r=p.osvobodit(door,m,'197','Impl197')
        m.zhurnal('Impl197',sdal=True)
        r2=judge(door,m,s)
        return [p.k_rc(r,0,'освобождение')]+refusal(r2,'OBJECT_RASHODITSJA')
    cell('p23-release-ne-menjaet-object',p23)

    def p27(m,door):
        s=setup(m)
        fixture_transfer(m,s)
        m.git(['tag','-d','frozen/contracts/197/3'])
        wt,br,_=m.worktree('198')
        event=m.sobytie('batch.json',[
            p.item('architect','Arch198',['SUBJECT=198','WORKTREE='+wt,'BRANCH='+br],isolated=True),
            p.item('critic','Judge197',['SUBJECT=197','OBJECT='+s['obj']])])
        before=p.snimok_fajlov(m.sost)
        r=p.sudit(door,m,event)
        return refusal(r,'KLASS_RISKA_NET')+[None if p.snimok_fajlov(m.sost)==before else 'пакет оставил частичную запись']
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


def mutacii(z):
    """Адресные удаления/замены существующих операций модели; привязки — source.json."""
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
            '    && [ "$(git -C "$REPO" rev-parse --verify "refs/tags/$ptag" 2>/dev/null)" = "$pobj" ] \\',
            '    && true \\'),
        's55-receipt-ne-pereproverjaet-proof': lambda t:z(t,
            '        [ "$(printf \'%s\' "$transfer" | jq -cS .proof)" = "$(printf \'%s\' "$P_JSON" | jq -cS .)" ] \\',
            '        true \\'),
        's56-frozen-vmesto-kandidata': lambda t:z(t,
            '      if [ -n "$P_FROZEN" ] && ! kontrakt_v_kandidate "$sv" "$r_wt" "$obj"; then',
            '      if [ -n "$P_FROZEN" ]; then'),
        's57-frozen-iz-main': lambda t:z(t,
            '        kr="$(klass_riska "$sv" "$REPO" "$P_FROZEN")"',
            '        kr="$(klass_riska "$sv" "$REPO" HEAD)"'),
        's58-receipt-bez-append': lambda t:z(t,
            '    \'{t:"PEREDACHA",repoId:$r,subjectId:$n,receipt:$c,proof:$proof,at:$at}\' >> "$LEDGER"',
            '    \'{t:"PEREDACHA",repoId:$r,subjectId:$n,receipt:$c,proof:$proof,at:$at}\' > /dev/null'),
        's59-receipt-bez-reestra': lambda t:z(t,
            '  [ "$reg" = "$n → $pobj" ] \\', '  true \\'),
        's60-receipt-pustoj-rezultat': lambda t:z(t,
            '  [ -n "$(git -C "$P_WT" diff-tree --root --no-commit-id --name-only -r "$P_OBJECT" 2>/dev/null)" ] \\',
            '  true \\'),
        's61-receipt-bez-grammatiki': lambda t:z(t,
            "    1) perenos_otkaz PEREDACHA_NEDOSTOVERNA 'схема свидетельства' ;;",
            "    1) : ;; # стаб: схема игнорируется"),
    }
