# s02 — обман: имя запрета берётся из $0 без realpath/basename — абсолютный
# путь к двойнику и симлинк выпадают из замкнутого списка (pass-through/127).
# Наблюдаем: a11 (резолв-формы; мутация entry-файла emulator — abs-форма);
# bare/bash-c/env формы у стаба честны.
IMJA = 's02-dvojnik-put-propuskaet'
ZAMENA = [
    (('dvojniki', 'emulator'),
     ('Z="$(realpath "$0")"\nexec "$(dirname "$Z")/_jadro.sh" "$(basename "$Z")" "$@"',
      'exec "$(dirname "$0")/_jadro.sh" "$0" "$@"')),
]
