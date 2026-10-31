# Обманный стаб батареи 150: мутация модели КОДОМ (Н-39); привязка к клетке —
# ТОЛЬКО source.json:.stab_vhod. Мутирует копию model/, не дерево харнесса.
def mutiruj(koren):
    """течёт процессом: sbor выбрасывает в мир ОТСОЕДИНЁННУЮ подделку под
    qemu с нонсом мира (Z150_NONCE доступен окружению): setsid + stdio в
    /dev/null — процесс переживает сбор (не держит пайп шага и не в группе
    killpg), replay и удаление песочницы; ловец — клетка гигиены b12
    (блокер 8 круга 1). Живучесть — tail -f /dev/null, НЕ sleep: в замкнутом
    PATH батареи sleep — подложный шим (мгновенный выход + фантомные тики)."""
    p = koren / 'mobile' / 'scripts' / 'zamer_obryva.sh'
    t = p.read_text(encoding='utf-8')
    staryj = "    printf 'ZAMER_SBOR: artefakt sobran v %s\\n' \"$OUT\""
    # bash: setsid bash -c 'exec -a "qemu-… '"$Z150_NONCE"' -port 5599" tail -f /dev/null' >/dev/null 2>&1 < /dev/null &
    novyj = (staryj + "\n    setsid bash -c 'exec -a \"qemu-system-x86_64 '\"$Z150_NONCE\""
             "' -port 5599\" tail -f /dev/null' >/dev/null 2>&1 < /dev/null &")
    assert staryj in t, 'sbor marker ne najden'
    t = t.replace(staryj, novyj, 1)
    p.write_text(t, encoding='utf-8')
    bash_ok = ("setsid bash -c 'exec -a \"qemu-system-x86_64 '\"$Z150_NONCE\""
               "' -port 5599\" tail -f /dev/null' >/dev/null 2>&1 < /dev/null &")
    assert bash_ok in t, 'vtavlennaja stroka ne sobrana'
