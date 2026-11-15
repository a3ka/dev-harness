# Обманный стаб: дочерний хук матричного child не собирает до повтора —
# ветвь maestro-обёртки молчит при сигнатуре (stdout/stderr в ns остаются,
# сбора до finally нет): z07 обязан краснеть SBOR_150_RESULT_NET.
def mutiruj(koren):
    p = koren / 'mobile' / 'scripts' / 'zamer_child_hook.sh'
    tekst = p.read_text(encoding='utf-8')
    staryj = ("    if [ \"$rc\" -ne 0 ] && grep -qE \"$SIGNATURY_RE\" \"$NS/maestro.log\" 2>/dev/null; then\n")
    assert staryj in tekst, 'vetka sbora huka ne najdena'
    tekst = tekst.replace(staryj, '    if false; then\n', 1)
    p.write_text(tekst, encoding='utf-8')
