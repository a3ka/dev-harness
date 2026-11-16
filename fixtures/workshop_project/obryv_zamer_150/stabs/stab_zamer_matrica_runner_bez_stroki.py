# Обманный стаб: канонические строки вызова хука исчезли из раннера —
# раннер больше не передаёт stdout/stderr Maestro в диагностический ns и
# не запускает сэмплер/сбор у child (KANON_150_MATRICA у КАЖДОГО child,
# включая второго).
def mutiruj(koren):
    p = koren / 'mobile' / 'scripts' / 'run-ci-screen.cjs'
    tekst = p.read_text(encoding='utf-8')
    staryj = "['mobile/scripts/zamer_child_hook.sh', 'maestro',"
    assert staryj in tekst
    tekst = tekst.replace(staryj, "['mobile/scripts/zamer_NIKOGDA-net.sh', 'maestro',", 1)
    p.write_text(tekst, encoding='utf-8')
