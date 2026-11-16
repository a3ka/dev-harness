# Обманный стаб: сбор без результата — sbor-ветвь скрипта выходит 0 после
# echo, не создавая itog/signatury (событие запуска есть, результата нет);
# судья результата z06 обязан краснеть SBOR_150_RESULT_NET.
def mutiruj(koren):
    p = koren / 'mobile' / 'scripts' / 'zamer_obryva.sh'
    tekst = p.read_text(encoding='utf-8')
    staryj = "  {\n    mkdir -p \"$OUT\"\n"
    assert staryj in tekst, 'nachalo sbora ne najdeno'
    # подменить всю сборочную группу на безрезультатный echo (rc 0)
    nachalo = tekst.index(staryj)
    kon = tekst.index("  } || ubyto 'ZAMER_SBOR_OTKAZ: sbor ne zavershilsja (sm. markery vyshe)'",
                      nachalo)
    novyj = ("  {\n"
             "    printf 'ZAMER_SBOR: (obmannyj stabil) nichego ne sobrano\\n'\n"
             "  }\n")
    tekst = tekst[:nachalo] + novyj + tekst[kon:]
    p.write_text(tekst, encoding='utf-8')
