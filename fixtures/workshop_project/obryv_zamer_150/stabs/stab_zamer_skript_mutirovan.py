# Обманный стаб: скрипт замера мутирован одним байтом — пин sha256
# (z04) обязан отличить подмену канона скрипта.
def mutiruj(koren):
    p = koren / 'mobile' / 'scripts' / 'zamer_obryva.sh'
    b = bytearray(p.read_bytes())
    i = b.index(b'ZAMER_VERSIJA=')
    b[i + 14] = b[i + 14] ^ 0x01
    p.write_bytes(bytes(b))
