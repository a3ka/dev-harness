"""Слово владельца 21.11 12:06: общая разовая санкция, не обход живого автора."""

PREFIX = 'РАЗРЕШИЛ-ВЛАДЕЛЕЦ-ЗАМОК: '


def dobavit(K, p):
    def register(name, axes, fn):
        K[name] = dict(osi=axes, run=fn)

    def worker(m, wt, br, name, line, isolated=True):
        return p.item('architect', name, ['SUBJECT=140', 'WORKTREE='+wt,
                      'BRANCH='+br, line], isolated=isolated)

    def pause(m, door, variant):
        wt, br, obj = m.worktree('140', kontrakty=[
            ('fajl', '140-fixture.md', 'КЛАСС РИСКА: обычный\n')])
        m.pauza('140')
        subject, code, target = '140', 'PAUZA_VLADELTSA', ''
        if variant == 'subject': subject = '141'
        if variant == 'code': code = 'PEREDACHA_REMOTE'
        if variant == 'object': target = ' '+p.OBJECT_DUMMY
        if variant == 'bound': target = ' '+obj
        line = PREFIX+subject+' '+code+target
        judge = variant in ('object', 'bound')
        if judge:
            m.start('140', 'Author140', wt=wt, branch=br)
            m.zhurnal('Author140', sdal=True)
            event_item = p.item('critic', 'Override140', ['SUBJECT=140', 'OBJECT='+obj, line])
        else:
            event_item = worker(m, wt, br, 'Override140', line)
        before = m.ledger.read_bytes()
        event = m.sobytie('override.json', [event_item])
        r = p.sudit(door, m, event)
        allowed = variant in ('once', 'bound')
        if not allowed:
            return [p.k_rc(r, 1, 'чужая-санкция'), p.k_prichina(r, 'PAUZA_VLADELTSA', 'причина'),
                    None if m.ledger.read_bytes() == before else 'чужая строка израсходовала санкцию']
        problems = [p.k_rc(r, 0, 'разовая-санкция'),
                    p.k_stroka(m, 'START', holder='Override140')]
        overrides = [row for row in m.ledg() if row.get('t') == 'override'
                     and row.get('kod') == 'PAUZA_VLADELTSA' and row.get('subjectId') == '140']
        problems += [None if len(overrides) == 1 else 'нет единственного override предмета/кода']
        m.zhurnal('Override140', sdal=True)
        again = dict(event_item, name='Again140')
        event2 = m.sobytie('again.json', [again])
        before2 = m.ledger.read_bytes()
        r2 = p.sudit(door, m, event2)
        return problems + [p.k_rc(r2, 1, 'повтор-санкции'),
            p.k_prichina(r2, 'PAUZA_VLADELTSA', 'исчерпана'),
            None if m.ledger.read_bytes() == before2 else 'повтор строки изменил учёт']

    for variant in ('once', 'bound', 'subject', 'code', 'object'):
        register('o01-pauza-'+variant, 'общая-строка;PAUZA;'+variant,
                 lambda m,d,v=variant: pause(m,d,v))

    def forbidden(m, door, code):
        wt, br, obj = m.worktree('140', kontrakty=[
            ('fajl', '140-fixture.md', 'КЛАСС РИСКА: обычный\n')])
        line = PREFIX+'140 '+code
        isolated = code != 'NE_IZOLIROVAN'
        it = worker(m, wt, br, 'Next140', line, isolated)
        if code in ('RABOCHIJ_ZHIV', 'AVTOR_ESHCHO_RABOTAET', 'SUDJA_ZHIV'):
            judge = code == 'SUDJA_ZHIV'
            m.start('140', 'Live140', wt=wt, branch=br,
                    klass='sudja' if judge else 'rabochij', rol='critic' if judge else 'architect',
                    zanyat=code != 'AVTOR_ESHCHO_RABOTAET')
            m.zhurnal('Live140', sdal=False)
            if code == 'AVTOR_ESHCHO_RABOTAET':
                it = p.item('critic', 'Next140', ['SUBJECT=140', 'OBJECT='+obj, line])
        if code == 'ZANYATO_RESHENIEM':
            (m.sost / 'zamki' / p.REPO_ID / '140' / 'mutex').mkdir(parents=True)
        items = [it, dict(it, name='Second140')] if code == 'DUBL_V_PAKETE' else [it]
        before = p.snimok_fajlov(m.sost)
        r = p.sudit(door, m, m.sobytie('forbidden.json', items))
        return [p.k_rc(r, 1, 'неотменяемый-отказ'), p.k_prichina(r, code, 'причина'),
                None if p.snimok_fajlov(m.sost) == before else 'запрещённая санкция изменила состояние']

    for code in ('NE_IZOLIROVAN', 'RABOCHIJ_ZHIV', 'ZANYATO_RESHENIEM',
                 'AVTOR_ESHCHO_RABOTAET', 'SUDJA_ZHIV', 'DUBL_V_PAKETE'):
        register('o02-neotmenjaemyj-'+code.lower(), 'общая-строка;неотменяемый='+code,
                 lambda m,d,c=code: forbidden(m,d,c))

    def default_risk(m, door, role, adversary):
        wt, br, obj = m.worktree('140', kontrakty=[
            ('fajl', '140-fixture.md', '# нет класса риска\n')])
        m.start('140', 'Author140', wt=wt, branch=br)
        m.zhurnal('Author140', sdal=True)
        if adversary:
            m.start('140', 'Adv140', klass='sudja', rol='adversary', obj=obj, zanyat=False)
            m.zhurnal('Adv140', sdal=True)
        event = m.sobytie('risk.json', [p.item(role, 'Risk140',
            ['SUBJECT=140', 'OBJECT='+obj])])
        r = p.sudit(door,m,event)
        if role == 'reviewer' and not adversary:
            return [p.k_rc(r,1,'по-умолчанию-рисковый'),
                p.k_prichina(r,'ADVERSARIJ_DO_REVJUERA','порядок'),
                p.k_chislo_startov(m,'нет-START-ревьюера',1)]
        return p.k_warn(r,m,'KLASS_RISKA_NET','140')

    for role, adv in (('critic',False),('reviewer',False),('reviewer',True)):
        register('o04-risk-default-'+role+'-'+str(int(adv)),
            'риск=нет-записи;по-умолчанию=рисковый;роль='+role+';адверсарий='+str(adv),
            lambda m,d,r=role,a=adv:default_risk(m,d,r,a))


# Привязки сняты с операций двери cb9713b0ee, не из прозы контракта.
BINDINGS = {
    # b03 теперь предупреждает, а не вызывает otp; s31 с потерянной
    # декларацией по умолчанию рисковый, как и честный вход. Это не различающие
    # предъявления данным мутациям после упрощения (Н-39).
    's20-otkaz-ne-ostanavlivaet': ['b07-paket-izolirovan-otkat'],
    's28-pervyj-rezultat-find': [
        's23-klass-riska-konflikt-ab', 's24-klass-riska-konflikt-ba',
        's25-klass-riska-net-stroki-vo-vtorom', 's28-klass-riska-shest-fajlov',
        's29-klass-riska-realnaja-116', 's30-klass-riska-realnaja-139',
        's33-klass-riska-dve-deklaracii-odinakovye', 's35-klass-riska-vne-alfavita',
        's36-klass-riska-simlink', 's37-klass-riska-citata-shablona'],
    's29-klass-riska-tolko-nachalo-stroki': [
        's29-klass-riska-realnaja-116', 's30-klass-riska-realnaja-139',
        's37-klass-riska-citata-shablona'],
    's82-override-bez-zapisi': ['o01-pauza-once', 'o01-pauza-bound'],
    's83-override-bez-abort': ['p48-override-peredacha-schema'],
    's84-preduprezhdenie-bez-zapisi': [
        's08-rabochego-net', 'w13-limit-harness', 'p17-svidetelstvo-ne-orchestrator'],
    # К-01: авто-RELEASE в sudit-пути больше нет; различающий вход стаба —
    # явный --osvobodit брошенного держателя (RELEASE обязан быть записан).
    's85-broshennyj-bez-release': ['w05-osvobodit-broshennyj'],
    # D9/D11 208 теперь отказывают до START. Фактический tip различим
    # на оставшемся A2 fallback: неконформный вердиктный корень q17.
    's86-start-zaproshennyj-object': ['q17-object-predydushchego-verdikta'],
}


def mutacii(z):
    def no_abort(t):
        # Все три D55: одна операция раннего возврата на разных этапах receipt.
        old = '  [ -z "$PEREDACHA_PRORYVAN" ] || return 1'
        if t.count(old) != 3:
            raise RuntimeError('D55: ожидались три этапа прерывания передачи')
        return t.replace(old, '  : # стаб: продолжаем после пропущенного отказа')

    def no_warn_record(t):
        old = '''  [ -n "$ZAPISI" ] && printf '%s\\n' "$ZAPISI" >> "$LEDGER"'''
        if t.count(old) != 2:
            raise RuntimeError('D56: ожидались запись передачи и запись спавна')
        return t.replace(old, '  : # стаб: буфер предупреждений в учёт не пишется')

    return {
        's82-override-bez-zapisi': lambda t: z(t,
            '''  zapis_dodat "$(jq -nc --arg t override''',
            '''  : "$(jq -nc --arg t override'''),
        's83-override-bez-abort': no_abort,
        's84-preduprezhdenie-bez-zapisi': no_warn_record,
        's85-broshennyj-bez-release': lambda t: z(t,
            '''  jq -nc --arg t RELEASE --arg r "$REPO_ID" --arg s "$NNN_ARG" --arg h "$h_holder" \\
        --arg p "$prichina" --arg at "$(ts_now)" \\
    '{t:$t,repoId:$r,subjectId:$s,holder:$h,prichina:$p,at:$at}' >> "$LEDGER"''',
            '''  : # стаб: явное --osvobodit не пишет RELEASE брошенного держателя'''),
        's86-start-zaproshennyj-object': lambda t: z(t,
            '''    [ -n "$fakt" ] && obj="$fakt"''',
            '''    : # стаб: START сохраняет запрошенный, не фактический OBJECT'''),
    }
