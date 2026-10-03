accept

# Контракт 080 — критик, микро-круг v2 (blob-идентичность)

Предмет микро-круга: тождество contracts/080-dver-bugfiks-perezapuska.md на HEAD
origin/wip/080/architect (27b1f05eec6bc8ac883f18f2943560c017a746a3) блобу
frozen/contracts/080/1 (f93fb8749f834b48a46eeec366a2689f9e761d05). Живая проверка:
git show origin/wip/080/architect:contracts/080-dver-bugfiks-perezapuska.md |
git hash-object --stdin → f93fb8749f834b48a46eeec366a2689f9e761d05;
git show frozen/contracts/080/1:... | git hash-object --stdin → то же значение.
Тождество — против frozen/contracts/080/1 (итоговый блоб после правок 36e5b310/1681aba3
внутри самой заморозки v1), НЕ против SHA предмета круга 2 (9734d4e..., иной блоб
307c3b17...). Полный суд (5 вопросов, батарея, советы) НЕ повторяется — принят в
contracts-080-v1.md круга 2, предмет не менялся. Причина v2: forks/080-frozen-tag-
disconnect.md — тег v1 указывает на orphan-коммит вне истории ветки/main.
