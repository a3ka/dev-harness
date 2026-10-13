ПРЕДМЕТ: 093-rv2-6-orchagent-harness-group
МОДЕЛЬ: openai-codex/gpt-6-astra
ВОПРОС: Рекомендуй конкретное решение (а: добавить в группу harness при bootstrap, с точным местом правки файла/строки; или б: альтернатива) с оценкой риска (это граница привилегий станции).
РЕКОМЕНДАЦИЯ: Стоп на выборе новой границы безопасности в инженерном маршруте уже-frozen 093. Вариант (а) нельзя считать узкой починкой доступа к omp: измеренные групповые права открывают изменение runtime/config владельца станции. Применимая существующая норма требует оставить агента без доступа к /home/harness; для конкретной поставки runtime/рабочего дерева вне этого дома нужен отдельно адресованный дизайн-предмет до круга критика. Этот файл фиксирует диагноз и блокер маршрута, а не выдаёт позднее СОревью или санкцию изменения групп.

## Живые команды и выводы

`stat /home/harness` — rc 0:
```text
Access: (0750/drwxr-x---) Uid: (1004/harness) Gid: (1005/harness)
```
`id orchagent` — rc 1:
```text
id: 'orchagent': no such user
```
`getent group harness` — rc 0:
```text
harness:x:1005:
```
`namei -l /home/harness/.local/bin/omp` — rc 0:
```text
drwxr-xr-x root    root    /
drwxr-xr-x root    root    home
drwxr-x--- harness harness harness
drwxrwxr-x harness harness .local
drwxrwxr-x harness harness bin
-rwxr-xr-x harness harness omp
```
`stat -c '%a %U:%G %n' /home/harness/.local/state /home/harness/.local/state/dev-harness-sessions /home/harness/.config /home/harness/.ssh` — rc 0:
```text
755 harness:harness /home/harness/.local/state
755 harness:harness /home/harness/.local/state/dev-harness-sessions
775 harness:harness /home/harness/.config
700 harness:harness /home/harness/.ssh
```

Секреты и содержимое сессий не читались. Отказ живого запуска под orchagent не предъявлялся: пользователя нет; sudo/useradd не исполнялись.

## Точное место существующего provisioning
На main f559fe69 install.sh ещё не содержит provisioning 093. Исследован install.sh реального кандидата 34c6aa6e6b31df97f87dd6662ac0a950b0e94233, названного ревьюером.

Функция provision_orchagent(), участок около строк 110–125: после getent passwd вызывается
```sh
useradd --system --shell /usr/sbin/nologin \
  --home-dir "$AGENT_HOME" --no-create-home "$AGENT_USER"
```
Дополнительной группы нет. Затем создаётся AGENT_HOME, ставятся владелец AGENT_USER:AGENT_USER и режим 755. После этого записывается sudoers harness→AGENT_USER. Функция вызывается root-веткой после копий и блокировки .git/config; при швах SBIN_DST/ETC_DST provisioning пропускается.

Если бы вариант (а) был отдельно разрешён, его место — этот provisioning сразу после обеспечения существования пользователя, причём правка должна охватить И уже существующую учётную запись: добавление -G только в useradd не обновит существующего orchagent. Это локализация места изменения, НЕ рекомендация выполнить usermod и НЕ разрешение на станционную операцию.

## Почему «добавить группу» не соответствует текущей границе
Frozen/contracts/093/1 прямо требует отдельного пользователя без доступа к /home/harness, недоступности ~/.ssh/**, ~/.config/**, живых dev-harness-sessions и публикационного credential. Текст кандидата с frozen совпадает, собственный diff rc 0.

[INFERENCE] Членство в harness даст агенту не только traversal /home/harness: групповые rwx на .local/bin позволят удалять/подменять находящийся там omp независимо от режима 0755 самого файла; rwx на .config откроет изменение доступных записей каталога. Это нарушение границы между агентом и владельцем станции, а не безопасное расширение PATH. Режим 0700 на .ssh сам по себе не спасает остальные контрольные пути. Наличие 0755 на .local/state/dev-harness-sessions открывает traversal этих уровней; полный доступ к вложенным файлам не утверждается без проверки их режимов.

Направление, которое сохраняет уже утверждённую норму: runtime и рабочее дерево агента размещаются вне /home/harness, HOME агента остаётся /var/lib/orch-agent, станционные ключи/config/state туда не копируются, членство harness и рекурсивные ACL не добавляются. Возможные адресаты для отдельно проектируемой поставки — root-owned runtime под /opt и agent-owned рабочее дерево под /var/lib/orch-agent; здесь их существование, состав runtime и работоспособность не проверялись и решением не объявляются.

Для закрытия нового дизайн-предмета недостаточно одного успешного omp --version: нужны запуск реального workshop под новым uid с обязательным пределом, собственное доступное рабочее дерево без зависимостей от защищённого дома, отказ чтения/записи контрольных путей и отсутствие publication credential. Эти условия следуют из существующего И-3/И-4/И-5, не заменяют предстоящее СОревью конкретной поставки.

## Маршрут и подпись
Контракт 029 относит новый выбор границы безопасности к дизайн-СОревью ДО критика. Исходное задание объявляет инженерный анализ, а 093 уже frozen; консультант не вправе сам переклассифицировать запись или писать СОревью задним числом. Оркестратору — этот поимённый блокер и необходимость нового адресованного дизайн-предмета. Решение принять дополнительный станционный риск, если оно потребуется, относится к воле владельца/риск, но инженерное нарушение И-3 нельзя превратить в допустимость одной самодекларацией класса. В исходной записи нет АВТОР с model-id; klass-свидетельство не выдаётся.

## Основание
Команды выполнены в /home/harness/dev-harness под env -i, PATH=/usr/bin, LC_ALL=C.UTF-8, GIT_CONFIG_GLOBAL/GIT_CONFIG_SYSTEM=/dev/null, GIT_OPTIONAL_LOCKS=0, core.hooksPath=/dev/null. RC самого процесса; SHA собственного printf %s от наблюдённого stdout+stderr без хвостовых LF. Полный барьер Г2 не заявляется пройденным.
Первый вывод — 055c0618bc626e8e439193adb45c6d37e0166cff и cadf4b9a423d0aa682250e55fa50422d3e351470, по значению на строку. Второй вывод пуст.

ОСНОВАНИЕ-ДЕРЕВО:
КОМАНДА: git rev-parse 34c6aa6e6b31df97f87dd6662ac0a950b0e94233:ops/server/install.sh frozen/contracts/093/1:contracts/093-granica-ispolneniya-i-postavka-ops.md
RC: 0
ВЫВОД-SHA256: f7d32a95155146c9944784977ed8c031a0c8d8aba114dec17f01864064aad494
КОМАНДА: git diff --quiet frozen/contracts/093/1:contracts/093-granica-ispolneniya-i-postavka-ops.md 34c6aa6e6b31df97f87dd6662ac0a950b0e94233:contracts/093-granica-ispolneniya-i-postavka-ops.md
RC: 0
ВЫВОД-SHA256: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
