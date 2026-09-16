#!/usr/bin/env bash
# Детектор утечек основного чекаута (контракт 024, семейство 2 записи Н-85).
# НЕ БАРЬЕР: детектор зовётся церемонией с наблюдаемым rc (норма-строка 024 в
# roles/orchestrator.md); красные/стабы/проба/канарейка живут вне case-глоба в
# семейном каталоге fixtures/check_judge_gate/ мета-барьера scripts/check_judge_gate.sh
# (замороженный текст 024, прецедент red_mera_parallelnosti_okon.sh контракта 021)
# — verify_antiplacebo не покрывает.
#
# Зачем. Правки субагентов, оставленные относительным путём без cwd, ложатся в основное дерево
# сессии (А-72/А-95/А-99; ×5 утечек 2026-09-08..10, две ночные при живых Н-85-инструкциях).
# Дисциплина измерено мертва — нужна механизация, а не правило (Н-85:2271-2280). Решение владельца
# 2026-09-10 (Г5): «D→среда ДА, D детектор (дёшев, независим, механизирует ручную меру), среда
# превенция». Этот файл — D.
#
# КАК ЗОВЁТСЯ. Два режима, ОДИН абсолютный корень основного чекаута:
#   --snapshot <абс-корень>  манифест состояния дерева в файле ВНЕ стерегомого;
#   --check    <абс-корень>  дельта манифеста: новые строки ⇒ rc 1 «основной чекаут загрязнён».
# Относительный путь в обоих режимах ⇒ rc 1 «корень обязан быть абсолютным» ДО какого-либо cd
# (блокер 5 вердикта 4d1d265).
#
# КОРНЕВОЙ СРЕЗ ИСТОЧНИКА МАНИФЕСТА (v6, 2026-09-15, путь 1 владельца; Н-89: порочность
# перечисления носителей ослепления, 8 классов / 8 адверсарий-кругов).
# Манифест — ОБЪЕДИНЕНИЕ трёх ног, единый sort:
#   1. TRACKED (tracked-байты): `git ls-files -z` (пинованный $GIT) перечисляет КАЖДЫЙ
#      tracked-путь — флаги assume-unchanged/skip-worktree на перечисление НЕ влияют
#      (замер 2026-09-15). Строка ноги несёт sha256 БАЙТОВ рабочего файла и sha1
#      staged-блоба (`git ls-files -s`); путь вне диска (sparse/deleted) — маркер
#      MISSING; gitlink/submodule — @head + РЕКУРСИЯ с префиксом.
#      Поглощает tracked-половину porcelain emit_manifest (XY не нужно — байты КАЖДОГО
#      пути независимо от состояния); поглощает INDEXFLAG (флаги больше ничего не
#      ослепляют — дельта по байтам).
#   2. UNTRACKED (untracked-байты): `git ls-files --others -z` БЕЗ --exclude-standard
#      перечисляет КАЖДЫЙ неотслеживаемый путь с sha256 байтов, МИМО ЛЮБЫХ ignore-правил
#      (.gitignore, .git/info/exclude, core.excludesFile, env-config). Заменяет
#      porcelain-untracked и emit_gitignore_walk как источник. Само-скрывающийся
#      .gitignore сам — untracked-путь ноги 2, виден.
#   3. DOTGIT (dot-git) — БЕЗ ИЗМЕНЕНИЙ v5: обход .git/hooks|info|config с Б3 (симлинки
#      + CONTENT-строки), Б8 (gitdir-резолв из .git-файла), carve-out .git/info/refs.
#      Не удаляется: ls-files --others НЕ видит .git; исходный инцидент 024 (подмена
#      pre-push) закрывается только этой ногой.
# ПОЧЕМУ КОРНЕВОЙ СРЕЗ: каждый новый носитель ослепления porcelain-форм стоил
# адверсарий-круг (8 классов / 8 кругов). Срез судит БАЙТЫ (TRACKED-нога) и ВИДИМОСТЬ
# (UNTRACKED-нога мимо ignore), а не перечисление форм доверия git. Внешняя цель
# core.excludesFile более не наблюдаема как dot-git-строка (EXCLUDES-строка удалена);
# её слепящий эффект нейтрализован UNTRACKED-ногой (утечка видна напрямую).
#
# ФАЙЛ-СНИМОК. Первая строка — «root <канонический корень>» (защита от hash8-коллизии каталогов
# снимков, совет 1 вердикта), далее отсортированные строки манифеста, последняя строка —
# «verify <sha256-всего-предыдущего-содержимого>» (самопроверка целостности снимка, см.
# раздел ЗАЩИТА-СНИМКА ниже). Хранится ВНЕ стерегомого — `${TMPDIR:-/tmp}/dev-harness-leak/
# <hash8-канонического-корня>/porcelain` (hash8-паттерн spawn_agent.sh:250, TMPDIR уважается,
# перезапись: последний выигрывает).
#
# ЧТО Судится/НЕ Судится (Демаркация контракта 024). Сверка — ПОДМНОЖЕСТВО: новая строка
# манифеста (новый путь, новые байты, новый staged-отпечаток, новый маркер MISSING)
# ⇒ утечка; исчезновение — чистка. Записи в ignored-пути по v6 БОЛЬШЕ НЕ вне 024
# (UNTRACKED-нога видит все пути, МИМО ignore) — узкая грань с именованной Демаркацией
# пересмотрена срезом: ignored-запись ВИДНА детектору (корневой срез её нейтрализует
# как носитель ослепления); утечка, дошедшая до КОММИТА до ближайшей --check, остаётся
# вне 024 (судит состояние, не историю). Снятие/сверка НЕ меняют porcelain стерегомого
# (ворота 14; снимок лежит в TMPDIR, все git-вызовы -C).
#
# ГИГИЕНА Н-85. Корень проверяется на абсолютность ДО cd; все git-вызовы `git -C <канон>` —
# cwd не влияет на решение НИ В ОДНУ сторону (блокер 2 вердикта, ворота 7/8); rc фиксируется
# БЕЗ пайпов (Н-84: pipefail-обёртка для суждения не используется).
#
# ЗАЩИТА-УТИЛИТ (контрпример S-path-forged-sha256 адверсария к2 01ed097:
# поддельная sha256sum в PATH перед /usr/bin — `command -v sha256sum` ловит
# СУЩЕСТВОВАНИЕ, не ПОДЛИННОСТЬ; два снимка дают одинаковый постоянный
# отпечаток, допись в untracked-путь проходит как «чисто»).
# Класс-фикс (вердикт к3 8911b68, контрпримеры S-path-fake-git-clean /
# S-path-fake-comm-clean): фикс 04ba744 пинил ТОЛЬКО sha256sum и оставлял
# git/sort/comm/mkdir/mktemp под полным PATH; адверсарий показал, что
# любая внешняя утилита, резолвленная мимо TRUSTED_PATH, даёт «чистый»
# обход (git: rc=0 + пустой porcelain ⇒ пустой манифест ⇒ дельта пуста;
# comm: rc=0 + пустой stdout ⇒ дельта пуста). Это ОДИН класс «инструмент
# мимо PATH» (Н-39: стабы к ветвям привязывает architect по коду), закрыт
# ВЕРТИКАЛЬНО — пином КАЖДОЙ внешней утилиты, которую скрипт зовёт.
# Решение: PATH сужается до ДОВЕРЕННЫХ системных префиксов
# (/usr/bin /bin /usr/local/bin) ДО резолва; КАЖДАЯ утилита кэшируется в
# абсолютный путь через `PATH="$TRUSTED_PATH" command -v`; sha256sum
# дополнительно сверяется sanity-хэшем пустого ввода (e3b0c442…).
# Голое имя утилиты в коде детектора после блока пина — дефект.
# Список пин-резолвленных утилит (импортирован architect'ом, сверен
# следующим адверсарием): git, sha256sum, sort, comm, mkdir, mktemp,
# stat, chmod, mv, cat, head, tail, grep, rm, readlink.
#
# ЗАЩИТА-СНИМКА (контрпример S-external-snapshot-symlink адверсария к2 01ed097: после
# baseline-снимка внешний файл манифеста подменяется симлинком на снимок ТОГО ЖЕ корня,
# сделанный ПОСЛЕ модификации tracked-файла; root-строка совпадает, дельта пуста ⇒ «чисто»).
# Реализованные меры (комбинация «механически проверяемое», меню из задания):
#   1. Reject-symlink (ОБЯЗАТЕЛЬНО): `$SNAP`, `$SNAP_DIR` И ПРОМЕЖУТОЧНЫЙ
#      `${TMPDIR:-/tmp}/dev-harness-leak` ОБЯЗАНЫ быть регулярными файлом/каталогом,
#      НЕ симлинками. Прямой симлинк-обход (заявленный кейс к2 адверсария) и обход
#      через симлинк-родитель (`$SNAP_DIR`) — отвергнуты с именованной фразой «снимок —
#      симлинк» / «каталог снимка — симлинк», rc=1. Промежуточный симлинк на
#      `$TMPDIR/dev-harness-leak` (наблюдение H адверсария к5 4dfc0ff: атакующий
#      подменяет каталог целиком симлинком на свежее дерево с валидным verify-снимком,
#      обходя проверки -L на $SNAP/$SNAP_DIR) — отвергнут фразой «промежуточный
#      каталог — симлинк», rc=1.
#   2. Mode-lock (ОБЯЗАТЕЛЬНО): после записи `chmod 0444` на `$SNAP`; на check — mode
#      содержит бит 0444 (ровно read для всех; смягчено до «mode содержит 0444», не
#      «mode равен 0444», чтобы umask-вариации не стреляли). Сам по себе не ловит
#      атаку, но повышает планку: `cat new > old` сохраняет inode и (как правило) не
#      обнуляет бит чтения, но режим-сюрприз «на снимке вдруг нет 0444» — диагностика.
#   3. Self-verify (ОБЯЗАТЕЛЬНО для прод-снимков, класс-фикс вердикта к3 — контрпример
#      S-mv-replace-no-verify 8911b68): последняя строка снимка — «verify <sha>», sha
#      по всему предыдущему содержимому. На check отсутствие verify в прод-снимке =
#      именованный отказ (не молчаливый пропуск ветки «if -n verify_line»). Совместимость
#      со стабами `fixtures/check_judge_gate/stab_detektor_*.sh` (подмена детектора на
#      stab_* в пробе) не нарушается: они НЕ зовут продовский --check (их ворота 12/13
#      итд. судит сам stab, а canary и red_detektor_utechek.sh работают с прод-детектором
#      и его снимки ВСЕГДА пишут verify — обратная совместимость со стабами держится через
#      их обособленный код, а не через глобальное послабление verify). Ловит байтовую
#      модификацию снимка на месте И mv+replace БЕЗ verify (явный лимит «сговор с
#      валидным verify» Демаркации остаётся).
# Связка с деревом на check — через канонический корень (`$CANON` ⇒ путь снимка ⇒
# содержимое корневой строки), и через `--check <абс-корень>` (тот же CANON на обоих
# концах). То, что не закрыто — mv+replace содержимого ВАЛИДНЫМ свежим снимком (с
# правильным verify на текущем дереве); это ограничение Демаркации («сговор»).
#
# Выход: 0 — снимок сделан / дельта пуста («основной чекаут чист»); 1 — именованный
#               отказ («основной чекаут загрязнён: <имена>» / «снимок отсутствует» /
#               «корень обязан быть абсолютным» / «снимок чужого корня» /
#               «снимок не прочитан» / «снимок — симлинк» / «каталог снимка — симлинк»
#               / «промежуточный каталог — симлинк» — наблюдение H к5 адверсария
#               / «снимок: режим не read-only» / «снимок: verify не сошёлся» /
#               «снимок: verify-строка отсутствует — обязательна для прод-снимков»
#               — кейс v4: чтение снимка cat||true тот же класс
#               «отказ producer ≠ молчаливый успех», имя дано);
#               2 — окружение не годится (нет утилит закрытого списка, sha256sum не
#               прошёл sanity-хэш, git status rc≠0, нет git, каталог/репозиторий
#               недоступны, sha256sum не смог прочесть tracked-файл, HEAD submodule
#               не читается — кейс v4: константы 'ERR'/'--' маскировали отказ как
#               валидный отпечаток; теперь именованный NOT_IMPLEMENTED rc 2, формат —
#               для последующей сверки побайтово воротами 17/18 фикс-круга
#               архитектора 024).
# ─── ЗАЩИТА-СРЕДЫ (фикс блокеров 1-4 адверсария к5 4dfc0ff; блокеров 1-2 к4 01ed097) ──
# Коммит daaee0a принёс `env -i` re-exec с часовым `_CNL_SANITIZED=1`. Адверсарий
# к5 (4dfc0ff) показал, что часовой — user-controllable env var: установка
# `_CNL_SANITIZED=1` в окружении выключает всю санитизацию целиком, и оба
# вектора к4 (BASH_ENV `command`, GIT_DIR/GIT_WORK_TREE) воскресают
# (S-cnl-sanitized-guard-off, блокер 1 к5).
#
# СТРУКТУРНОЕ ЗАКРЫТИЕ: re-exec с user-controllable guard НЕПРИГОДЕН. Решение —
# in-process санитизация в текущем bash-процессе, без re-exec, без env-часового.
# Перечисленные ниже классы атак снимаются ЯВНЫМ unset в текущем скрипте; новые
# переменные/функции, не перечисленные адверсарием, остаются на следующие круги
# (Н-39: стабы к ветвям привязывает architect по коду; новые классы — новый
# круг адверсария, не треадмилл-перечисление).
#
# Закрытые классы (вердикт к4 01ed097 + вердикт к5 4dfc0ff):
#   (1) S-bashenv-command-function (к4 блокер 1): `unset -f command` снимает
#       shell-функцию `command`, определённую BASH_ENV в родительском bash
#       ДО старта скрипта и перехватывающую TRUSTED_PATH-резолв
#       (`PATH="$TRUSTED_PATH" command -v git`). Без снятия пин возвращает
#       путь к фейковому бинарю, и вся защита TRUSTED_PATH обходится.
#   (2) S-git-dir-work-tree-injection (к4 блокер 2): `unset GIT_DIR GIT_WORK_TREE
#       GIT_INDEX_FILE GIT_OBJECT_DIRECTORY GIT_OBJECT_DATABASE
#       GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES`
#       снимает переменные, перенаправляющие ВСЕ git-вызовы на чужой репозиторий
#       даже при запиненном пути к `git`-бинарю. Объединение списков из
#       scripts/spawn_agent.sh:38-40 и scripts/check_ci_gate.sh:25-26 (включая
#       GIT_OBJECT_DATABASE, прецедент check_ci_gate — скорее всего опечатка,
#       но включено для устойчивости прецедента).
#   (3) S-cnl-sanitized-guard-off (к5 блокер 1): re-exec с env-часовым
#       `_CNL_SANITIZED` снят; вместо него — in-process санитизация без
#       часового. Атакующий, выставляющий `_CNL_SANITIZED=1` в окружении,
#       теперь НЕ обходит защиту, потому что нет if-check на user-controllable
#       переменную и нет re-exec.
#   (4) S-home-git-config-excludes / S-home-fsmonitor-tracked (к5 блокеры 2, 3):
#       `unset HOME` + `export GIT_CONFIG_GLOBAL=/dev/null
#       GIT_CONFIG_SYSTEM=/dev/null` + `unset XDG_CONFIG_HOME XDG_DATA_HOME
#       XDG_CACHE_HOME` снимают чтение `$HOME/.gitconfig` (где атакующий через
#       core.excludesFile прячет untracked-мусор) и core.fsmonitor (где
#       атакующий подсовывает свой fsmonitor-хук и делает tracked-модификации
#       невидимыми для porcelain). HOME из whitelist `env -i HOME=${HOME:-/root}`
#       коммита daaee0a давал атакующему прямой контроль; фикс — HOME снимается
#       и не наследуется.
#   (5) S-git-config-count-env (Н-96 адверсария contracts-024-k10):
#       `unset GIT_CONFIG_COUNT` снимает счётчик семейства
#       `GIT_CONFIG_KEY_<n>`/`GIT_CONFIG_VALUE_<n>` — без COUNT git
#       игнорирует все KEY_n/VALUE_n (документировано в git-config(1):
#       «If GIT_CONFIG_COUNT is not set, all GIT_CONFIG_KEY_<n>/VALUE_<n>
#       are ignored»). Ровно тот же класс «переменная подсовывает
#       core.excludesFile», что уже закрыт через GIT_CONFIG_GLOBAL/SYSTEM
#       и HOME; минимальный класс-фикс — одно имя. Без него атакующий
#       делает `GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=core.excludesFile
#       GIT_CONFIG_VALUE_0=/path/to/rules` перед запуском детектора, и
#       porcelain прячет утечку как и в (4), но мимо снятого
#       GIT_CONFIG_GLOBAL (потому что окружение первичнее).
#
# ПОБОЧНЫЙ ЭФФЕКТ отказа от `env -i PATH=$TRUSTED_PATH`: фикс регрессии приёмочной
# команды `bash fixtures/check_judge_gate/red_detektor_utechek.sh` ворот 16
# (S-no-sha256sum, блокер 2 d67ac4b). До фикса фикстура BIN16 могла снять
# sha256sum с PATH и наблюдать «манифест не годится ⇒ rc 2 именованный». После
# коммита daaee0a `env -i PATH=$_cnl_trusted` стирал PATH фикстуры и находил
# настоящий sha256sum в /usr/bin — ворота 16 краснели на судимом HEAD (бисект
# коммита 4dfc0ff ровно к этому коммиту). Отказ от `env -i` восстанавливает
# ворота 16: детектор использует запиненный $SHA256SUM (абсолютный путь из
# TRUSTED_PATH) для РАБОТЫ, но предпроверка `command -v sha256sum` идёт по
# унаследованному PATH церемонии — фикстура BIN16 снова наблюдаема.
#
# ПОБОЧНЫЙ ЭФФЕКТ (H к5): `unset IFS` снимает отравление IFS (например,
# IFS=':' ломает `for util in git sha256sum …`), тот же класс «переменная
# меняет поведение» что (1)/(2). На существующем коде IFS в `read` сбрасывается
# через `IFS= read -r …`, но `for util in …` идёт со глобальным IFS.
#
# Остаточный риск (назван прям, не молчит): BASH_ENV, переопределяющий
# функции `printf`/`[`/`cd`/`exec`/`set` ДО нашего скрипта — те же, что в
# оговорке шапки daaee0a (омнипотентный атакующий внутри bash-процесса).
# Адверсарий к5 не продемонстрировал этот класс против in-process санитизации;
# следующий круг адверсария, если найдёт, добавит `unset -f printf cd` etc.
# Перечисление ВСЕХ имён — треадмилл (Н-39); структурно: каждая конкретная
# функция, ИМЯ которой известно, снимается по факту демонстрации.
unset -f command 2>/dev/null || true
unset BASH_ENV ENV
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY \
      GIT_OBJECT_DATABASE GIT_ALTERNATE_OBJECT_DIRECTORIES \
      GIT_TEMPLATE_DIR GIT_CEILING_DIRECTORIES \
      GIT_CONFIG_GLOBAL GIT_CONFIG_SYSTEM GIT_CONFIG_NOSYSTEM \
      GIT_CONFIG_COUNT
unset HOME XDG_CONFIG_HOME XDG_DATA_HOME XDG_CACHE_HOME
unset IFS

set -uo pipefail
export LC_ALL=C

# ЕДИНЫЙ источник фраз — Демаркация контракта 024, потребители несут побайтово.
P_ZAGR='основной чекаут загрязнён'
P_CHISTO='основной чекаут чист'
P_NET_SNIMKA='снимок отсутствует'
P_ABS='корень обязан быть абсолютным'
P_CHUZH='снимок чужого корня'

usage() {
  printf 'ОТКАЗ диспетчер: использование: check_no_leak.sh --snapshot|--check <абс-корень>\n' >&2
  exit 1
}
[ "$#" -eq 2 ] || usage
MODE="$1"; ROOT_ARG="$2"
case "$MODE" in
  --snapshot|--check) ;;
  *) usage ;;
esac

# Абсолютность — ДО какого-либо cd (блокер 5 вердикта 4d1d265). Ловит форму, молча
# принимающую относительный путь и резолвящую его от случайного cwd (Н-85-класс).
case "$ROOT_ARG" in
  /*) ;;
  *)
    printf 'ОТКАЗ: %s: %s (CLI судит абсолютный корень основного чекаута — относительный путь резолвится от случайного cwd, Н-85-класс)\n' \
      "$P_ABS" "$ROOT_ARG" >&2
    exit 1
    ;;
esac

# ─── ЗАЩИТА-УТИЛИТ: пин ВСЕХ внешних утилит через TRUSTED_PATH (класс-фикс) ──
# Контрпример S-path-forged-sha256 адверсария к2 01ed097: поддельная sha256sum
# на PATH возвращает КОНСТАНТНЫЙ валидный hex → два снимка одинаковы → допись
# в untracked-путь проходит «чисто». Детектор ловил СУЩЕСТВОВАНИЕ утилит
# (`command -v X`), но не ПОДЛИННОСТЬ — фикс 04ba744 закрыл sha256sum.
#
# Класс «инструмент мимо PATH» (вердикт к3 8911b68) — контрпримеры
# S-path-fake-git-clean и S-path-fake-comm-clean: фикс 04ba744 пинил ТОЛЬКО
# sha256sum и оставлял git/sort/comm/mkdir/mktemp под полным PATH. Это НЕ
# «закрытый случай» — адверсарий показал, что любая внешняя утилита,
# резолвленная мимо TRUSTED_PATH, даёт «чистый» обход:
#   * поддельный git, возвращающий rc=0 + пустой porcelain ⇒ пустой манифест ⇒
#     оба снимка пусты ⇒ дельта пуста ⇒ «чисто»;
#   * поддельный comm, возвращающий rc=0 + пустой stdout ⇒ дельта пуста ⇒
#     «чисто» (форма «мусорный comm» даёт ложную тревогу ≠ «чисто» — но
#     «чистый пустой stdout» неотличим от «дельты нет»).
# Дополнительный класс (stat/chmod/mv/cat/head/grep/rm — голое имя в коде
# детектора): подмена через PATH даёт аналогичный обход (cat → поддельный
# cat с rc=0 + пустым stdout ⇒ «снимок не прочитан» ОТЛОВИМ, но «подмена
# printf '%s' "$base"» — отдельный путь). Закрытие — ВЕРТИКАЛЬНО: пин
# КАЖДОЙ внешней утилиты, которую скрипт зовёт. Н-39: стабы к ветвям
# привязывает architect по коду, не проза контракта — здесь одна вертикаль.
#
# ИТОГОВЫЙ СПИСОК пин-резолвленных утилит (коммит-сообщение несёт побайтово;
# architect импортирует и сверит следующий адверсарий):
#   git, sha256sum, sort, comm, mkdir, mktemp, stat, chmod, mv, cat,
#   head, tail, grep, rm, readlink
# — каждая через `PATH="$TRUSTED_PATH" command -v` кэшируется в абсолютный
# путь. Любое отсутствие в доверенных путях ⇒ NOT_IMPLEMENTED rc 2 именованный.
# Голое имя утилиты в коде детектора после этого блока — дефект.
TRUSTED_PATH=""
for d in /usr/bin /bin /usr/local/bin; do
  if [ -d "$d" ]; then
    TRUSTED_PATH="${TRUSTED_PATH:+$TRUSTED_PATH:}$d"
  fi
done
[ -n "$TRUSTED_PATH" ] \
  || { printf 'NOT_IMPLEMENTED: нет ни одного доверенного системного каталога (/usr/bin /bin /usr/local/bin)\n' >&2; exit 2; }

# Предпроверка ЗАКРЫТОГО списка утилит ДО любой работы (блокер 2 d67ac4b +
# контрпример S-no-sha256sum 8911b68: предпроверка через PATH, чтобы gate 16
# фикстуры red_detektor_utechek.sh мог симулировать «нет sha256sum» —
# BIN16 фикстуры кладёт минимальный PATH без sha256sum). Список — минимальный
# (только те 6 утилит, что нужны предпроверке для gate 15/16). Для новых
# утилит (stat/chmod/mv/cat/head/grep/rm) доверие обеспечивает пин ниже:
# резолв через TRUSTED_PATH-only; если в BIN16 нет stat и пин п утит на
# stat — это НЕ ожидаемая ветка, но и не ломает gate 16 (gate 16 идёт
# первым через sha256sum, которого в BIN16 нет). На честном PATH новые
# утилиты присутствуют (любой Linux /usr/bin).
#
# Структурное обоснование (фикс блокера 4 к5): фикстура BIN16 манипулирует
# PATH, чтобы наблюдать rc 2 «утилита отсутствует». До коммита daaee0a
# `env -i PATH=$TRUSTED_PATH` стирал этот PATH — gate 16 краснела. Отказ
# от env -i (in-process санитизация выше) восстанавливает предпроверку как
# наблюдаемый rc 2 в BIN16.
for util in git sha256sum sort comm mkdir mktemp; do
  command -v "$util" >/dev/null 2>&1 \
    || { printf 'NOT_IMPLEMENTED: утилита %s отсутствует\n' "$util" >&2; exit 2; }
done

# ПИН ВСЕХ ВНЕШНИХ УТИЛИТ через TRUSTED_PATH-only резолв. Каждая —
# абсолютный путь + sanity-проверка `[ -x "$X" ]`. sha256sum дополнительно
# sanity-хэшем пустого ввода e3b0c442… (S-path-forged-sha256): фейк,
# возвращающий константный 64-hex на ЛЮБОЙ ввод, sanity-хэш даст 000…000
# вместо e3b0c442… и НЕ сойдётся — NOT_IMPLEMENTED rc 2 именованный.
# head заменяет голое `head -n1` на пин-путь `$HEAD -n1` (sha256sum-вывод
# парсится первым токеном, атака на head тривиальна: пустая строка +
# поддельный sha — пиновый head резолвится из /usr/bin, не из fake-bin).
GIT="$(PATH="$TRUSTED_PATH" command -v git)"
[ -n "$GIT" ] && [ -x "$GIT" ] \
  || { printf 'NOT_IMPLEMENTED: git в доверенных путях отсутствует\n' >&2; exit 2; }
SORT="$(PATH="$TRUSTED_PATH" command -v sort)"
[ -n "$SORT" ] && [ -x "$SORT" ] \
  || { printf 'NOT_IMPLEMENTED: sort в доверенных путях отсутствует\n' >&2; exit 2; }
COMM="$(PATH="$TRUSTED_PATH" command -v comm)"
[ -n "$COMM" ] && [ -x "$COMM" ] \
  || { printf 'NOT_IMPLEMENTED: comm в доверенных путях отсутствует\n' >&2; exit 2; }
MKTEMP="$(PATH="$TRUSTED_PATH" command -v mktemp)"
[ -n "$MKTEMP" ] && [ -x "$MKTEMP" ] \
  || { printf 'NOT_IMPLEMENTED: mktemp в доверенных путях отсутствует\n' >&2; exit 2; }
MKDIR="$(PATH="$TRUSTED_PATH" command -v mkdir)"
[ -n "$MKDIR" ] && [ -x "$MKDIR" ] \
  || { printf 'NOT_IMPLEMENTED: mkdir в доверенных путях отсутствует\n' >&2; exit 2; }
STAT="$(PATH="$TRUSTED_PATH" command -v stat)"
[ -n "$STAT" ] && [ -x "$STAT" ] \
  || { printf 'NOT_IMPLEMENTED: stat в доверенных путях отсутствует\n' >&2; exit 2; }
CHMOD="$(PATH="$TRUSTED_PATH" command -v chmod)"
[ -n "$CHMOD" ] && [ -x "$CHMOD" ] \
  || { printf 'NOT_IMPLEMENTED: chmod в доверенных путях отсутствует\n' >&2; exit 2; }
MV="$(PATH="$TRUSTED_PATH" command -v mv)"
[ -n "$MV" ] && [ -x "$MV" ] \
  || { printf 'NOT_IMPLEMENTED: mv в доверенных путях отсутствует\n' >&2; exit 2; }
CAT="$(PATH="$TRUSTED_PATH" command -v cat)"
[ -n "$CAT" ] && [ -x "$CAT" ] \
  || { printf 'NOT_IMPLEMENTED: cat в доверенных путях отсутствует\n' >&2; exit 2; }
HEAD="$(PATH="$TRUSTED_PATH" command -v head)"
[ -n "$HEAD" ] && [ -x "$HEAD" ] \
  || { printf 'NOT_IMPLEMENTED: head в доверенных путях отсутствует\n' >&2; exit 2; }
GREP="$(PATH="$TRUSTED_PATH" command -v grep)"
[ -n "$GREP" ] && [ -x "$GREP" ] \
  || { printf 'NOT_IMPLEMENTED: grep в доверенных путях отсутствует\n' >&2; exit 2; }
TAIL="$(PATH="$TRUSTED_PATH" command -v tail)"
[ -n "$TAIL" ] && [ -x "$TAIL" ] \
  || { printf 'NOT_IMPLEMENTED: tail в доверенных путях отсутствует\n' >&2; exit 2; }
RM="$(PATH="$TRUSTED_PATH" command -v rm)"
[ -n "$RM" ] && [ -x "$RM" ] \
  || { printf 'NOT_IMPLEMENTED: rm в доверенных путях отсутствует\n' >&2; exit 2; }
# readlink — фикс блокера 3 адверсария contracts-024-k6 (S-dotgit-hook-symlink):
# симлинк .git/hooks/pre-push на внешний исполняемый файл ранее давал ложный
# rc=0 «чисто», потому что emit_dotgit_manifest_walk пропускал симлинки целиком.
# Теперь симлинки внутри .git/hooks/ включаются в отпечаток строкой
# DOTGIT:SYMLINK:<readlink-цель>\t<путь> — подмена цели меняет отпечаток.
READLINK="$(PATH="$TRUSTED_PATH" command -v readlink)"
[ -n "$READLINK" ] && [ -x "$READLINK" ] \
  || { printf 'NOT_IMPLEMENTED: readlink в доверенных путях отсутствует\n' >&2; exit 2; }
SHA256SUM="$(PATH="$TRUSTED_PATH" command -v sha256sum)"
[ -n "$SHA256SUM" ] && [ -x "$SHA256SUM" ] \
  || { printf 'NOT_IMPLEMENTED: sha256sum в доверенных путях отсутствует\n' >&2; exit 2; }
EXPECTED_EMPTY='e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'
GOT_EMPTY="$("$SHA256SUM" </dev/null 2>/dev/null | "$HEAD" -n1)"
[ "${GOT_EMPTY%% *}" = "$EXPECTED_EMPTY" ] \
  || { printf 'NOT_IMPLEMENTED: sha256sum в %s не прошёл sanity-хэш (подмена?)\n' "$SHA256SUM" >&2; exit 2; }

# Канонизация корня — cd + pwd -P. После этого ВСЕ дальнейшие операции идут по $CANON,
# cwd детектора не имеет значения (ворота 7/8: грязный cwd не влияет на решение).
CANON="$(cd "$ROOT_ARG" 2>/dev/null && pwd -P)" \
  || { printf 'NOT_IMPLEMENTED: %s не каталог\n' "$ROOT_ARG" >&2; exit 2; }
"$GIT" -C "$CANON" rev-parse --git-dir >/dev/null 2>&1 \
  || { printf 'NOT_IMPLEMENTED: %s не репозиторий git\n' "$CANON" >&2; exit 2; }

# Снимок ВНЕ стерегомого дерева (И-1/И-8). Путь — от канонического корня через hash8:
# два вызова с разными cwd сходятся в один файл (И-7). TMPDIR уважается. hash8 —
# через bash-substring (${X:0:8}), не внешний cut (узкое место: cut тоже пришлось бы
# пинить, что не даёт ничего поверх substring; substring — builtin, не зависит от PATH).
_canonsum="$(printf '%s' "$CANON" | "$SHA256SUM")"
HASH8="${_canonsum%% *}"; HASH8="${HASH8:0:8}"
TMPDIR_BASE="${TMPDIR:-/tmp}"
SNAP_DIR="$TMPDIR_BASE/dev-harness-leak/$HASH8"
SNAP="$SNAP_DIR/porcelain"
unset _canonsum
# ─── КОДИРОВАНИЕ ПУТЕЙ МАНИФЕСТА (фикс блокера к13 адверсария contracts-024-k13) ─
# Манифест — построчный текст, передаётся через line-oriented `sort`/`comm`. Путь в
# строке идёт ПОСЛЕ таба как литеральная последовательность байт. Если путь содержит
# `\n` (0x0A) или `\t` (0x09) — он разрывает ОДНУ строку на НЕСКОЛЬКО, и фрагмент
# префикса становится самостоятельной строкой манифеста. Контрпример к13:
#   каталог-носитель с именем `inject\nDOTGIT:<sha>\tnested` (перевод строки +
# табуляция в имени) порождает DOTGIT-строку, которая после split на `\n` даёт
# строку `DOTGIT:<sha>\tnested/.git/hooks/pre-push` — побайтовое совпадение со
# строкой РЕАЛЬНОГО будущего вложенного `.git/hooks/pre-push`. После удаления
# carrier исчезновение игнорируется по семантике подмножества (`comm -23`), а
# новая строка уже совпадает со старой подделкой ⇒ дельта пуста ⇒ rc 0 при
# живом payload. Это не форма имени в диагностике — это полноценная подделка
# самой строки манифеста до передачи в `comm`.
#
# Решение: ОБРАТИМОЕ кодирование байт-разрушителей пути в стиле printf-%q/git-escape
#   `\`  (0x5C) → `\\` (два байта 0x5C 0x5C) — иначе следующий шаг ввёл бы
#                     ложный escape-символ; ПЕРВЫЙ шаг обязателен.
#   `\n` (0x0A)  → `\n` (два байта 0x5C 0x6E) — реальный перевод строки разорвал
#                     бы строку манифеста на две.
#   `\t` (0x09)  → `\t` (два байта 0x5C 0x74) — табуляция-сеттер манифеста
#                     (разделитель sha-поля от пути), коллизия через колонки.
# Применяется ЕДИНОЙ функцией `enc_path` во ВСЕХ emit_* ногах — иначе инъекция
# переезжает между ногами (carrier может быть сформирован любой из трёх; правка
# только DOTGIT-ноги оставляет TRACKED/UNTRacked-ветки уязвимыми).
# Дешифрование детектору НЕ нужно: verify-строка снимка (sha256 поверх байт файла)
# привязывает состояние, а не представление; sort/comm работают над байтами строк
# и не интерпретируют escape-пары как метасимволы. Диагностика «основной чекаут
# загрязнён: <имена>» выводит закодированный путь — допустимо по контракту
# («при пробе с \n в имени допускается экранированный вывод — как уже делает
# sha256sum»); все red_*.sh/canary_*.sh/probe_slabyh фикстуры используют ASCII
# без спецсимволов в именах мусора, закодированная форма равна исходной.
# Совместимость со стабами `fixtures/check_judge_gate/stab_detektor_*.sh`
# (НЕ используют прод-кодировщик, у каждого своя печать) держится через их
# обособленный код: проба идёт мимо enc_path, стабы проверяются собственной
# веткой слабого детектора.
enc_path() {
  local p="$1"
  p="${p//\\/\\\\}"     # \ → \\  (первый шаг — иначе ввели бы ложный escape)
  p="${p//$'\n'/\\n}"   # 0x0A → \n (литеральная пара байт 0x5C 0x6E)
  p="${p//$'\t'/\\t}"   # 0x09 → \t (литеральная пара байт 0x5C 0x74)
  printf '%s' "$p"
}

# ─── v6 КОРНЕВОЙ СРЕЗ: producers манифеста ────────────────────────────────────
# НОГА-1 — TRACKED (tracked-байты). Источник — `git ls-files -z` (пути) и
# `git ls-files -s -z` (mode/sha1/stage), то же семейство ls-files. Гранулярность:
# КАЖДЫЙ tracked-путь (флаги assume-unchanged/skip-worktree на перечисление НЕ
# влияют — замер 2026-09-15). Формат строки:
#   TRACKED:<sha256-байтов-рабочего-файла>:<sha1-staged-блоба>\t<путь>
# Нечитаемый / отсутствующий (sparse, deleted) рабочий файл — маркер MISSING
# вместо sha256 (именованный маркер, не молчание): TRACKED:MISSING:<sha1>\t<путь>.
# Без такого маркера два нечитаемых состояния были бы неотличимы — превентив
# класса ERR-константы из v4 (детализация в Н-39-формате стабов). gitlink/
# submodule (mode 160000 в `ls-files -s`) — строка `TRACKED:@head:<sha HEAD>\t<путь>`
# плюс РЕКУРСИЯ манифеста внутрь с префиксом пути (правка внутри уже-грязного
# submodule меняет вложенный отпечаток; ворота 11). Достижимость внутреннего
# репозитория — через `$full` каталог (если gitlink развёрнут; иначе — маркер
# MISSING для вложенного подмодуля: `--separate-gitdir`-форма отдельного
# gitdir'а отличается от рабочего дерева, см. Б8 фикс в emit_dotgit_manifest).
# Детализация sha1-staged сохраняет закрытый класс индексной подсадки
# (`git update-index --cacheinfo` при нетронутых байтах даёт смену sha1 в
# строке TRACKED, новая строка ⇒ дельта ⇒ rc 1) — замер E8 матрицы 2026-09-15.
# Все rc-отказы producer'а распространяются вверх через `|| return 2` (Н-84).
emit_tracked_manifest() {  # <канон-корень> <префикс-путей>
  local root="$1" prefix="$2" tmpf_s tmpf_p path full mode sha1 fp head
  tmpf_s="$("$MKTEMP")" || {
    printf 'NOT_IMPLEMENTED: mktemp отказал в emit_tracked_manifest\n' >&2
    return 2
  }
  tmpf_p="$("$MKTEMP")" || {
    "$RM" -f -- "$tmpf_s"
    printf 'NOT_IMPLEMENTED: mktemp отказал в emit_tracked_manifest\n' >&2
    return 2
  }
  # 1) Заполняем ассоциативный массив mode/sha1 из `ls-files -s -z`.
  # rc producer'а фиксируется ДО чтения файла (Н-84/Н-85: rc без пайпов).
  if ! "$GIT" -C "$root" ls-files -s -z > "$tmpf_s" 2>/dev/null; then
    local _lfrc=$?
    "$RM" -f -- "$tmpf_s" "$tmpf_p"
    printf 'NOT_IMPLEMENTED: манифест не прочитан: git ls-files -s rc=%d в %s\n' \
      "$_lfrc" "$root" >&2
    return 2
  fi
  declare -A TRACKED_INFO=()
  while IFS= read -r -d '' entry; do
    # Грамматика ls-files -s: "<mode> <sha1> <stage>\t<path>" (NUL-separated).
    # Первые три поля — пробелами; имя пути идёт после первого TAB.
    mode="${entry%% *}"
    sha1="${entry#* }"; sha1="${sha1%% *}"
    path="${entry#*$'\t'}"
    TRACKED_INFO["$path"]="$mode:$sha1"
  done < "$tmpf_s"
  "$RM" -f -- "$tmpf_s"
  # 2) Перечисляем пути через `ls-files -z` (порядок тот же, что у ls-files -s -z).
  if ! "$GIT" -C "$root" ls-files -z > "$tmpf_p" 2>/dev/null; then
    "$RM" -f -- "$tmpf_p"
    printf 'NOT_IMPLEMENTED: git ls-files отказал в %s\n' "$root" >&2
    return 2
  fi
  while IFS= read -r -d '' path; do
    info="${TRACKED_INFO[$path]:-::}"
    mode="${info%%:*}"
    sha1="${info#*:}"
    full="$root/$path"
    # gitlink/submodule (mode 160000 в `ls-files -s`): @head + рекурсия.
    if [ "$mode" = "160000" ]; then
      if [ -d "$full" ]; then
        if ! head="$("$GIT" -C "$full" rev-parse HEAD 2>/dev/null)"; then
          "$RM" -f -- "$tmpf_p"
          printf 'NOT_IMPLEMENTED: HEAD недостижим в %s\n' "$full" >&2
          return 2
        fi
        printf 'TRACKED:@head:%s\t%s\n' "$head" "$(enc_path "${prefix}${path}")"
        # Рекурсия с префиксом «<path>/» — внутренние tracked-пути
        # попадают в манифест с префиксом; изменение внутри развёрнутого
        # submodule (ворота 11) меняет вложенный отпечаток.
        emit_tracked_manifest "$full" "$prefix$path/" || {
          "$RM" -f -- "$tmpf_p"
          return 2
        }
        emit_untracked_manifest "$full" "$prefix$path/" || {
          "$RM" -f -- "$tmpf_p"
          return 2
        }
        emit_dotgit_manifest "$full" "$prefix$path/" || {
          "$RM" -f -- "$tmpf_p"
          return 2
        }
      else
        # gitlink без развёрнутого рабочего дерева — маркер MISSING.
        printf 'TRACKED:@head:MISSING\t%s\n' "$(enc_path "${prefix}${path}")"
      fi
      continue
    fi
    # Обычный tracked-файл: sha256 байтов через пин-путь $SHA256SUM.
    # Превентив v4 (ERR-константа): нечитаемый/отсутствующий файл — маркер
    # MISSING, чтобы дельта ловила появление/удаление/повреждение.
    if [ -f "$full" ] && [ -r "$full" ]; then
      if ! fp="$("$SHA256SUM" -- "$full" 2>/dev/null)"; then
        "$RM" -f -- "$tmpf_p"
        printf 'NOT_IMPLEMENTED: не смог прочитать %s\n' "$full" >&2
        return 2
      fi
      fp="${fp%% *}"
      printf 'TRACKED:%s:%s\t%s\n' "$fp" "$sha1" "$(enc_path "${prefix}${path}")"
    else
      printf 'TRACKED:MISSING:%s\t%s\n' "$sha1" "$(enc_path "${prefix}${path}")"
    fi
  done < "$tmpf_p"
  "$RM" -f -- "$tmpf_p"
  unset TRACKED_INFO
}
# НОГА-2 — UNTRACKED (untracked-байты). Источник — `git ls-files --others -z`
# БЕЗ `--exclude-standard`. КАЖДЫЙ неотслеживаемый путь с sha256 байтов,
# МИМО ЛЮБЫХ ignore-правил (.gitignore, .git/info/exclude, core.excludesFile,
# env-config GIT_CONFIG_COUNT/KEY_n/VALUE_n, --exclude-per-directory и пр.).
# По умолчанию (без `--exclude-standard`) ls-files --others НЕ применяет
# ни одно ignore-правило, и НЕ сворачивает untracked-каталоги (--directory
# по умолчанию выключен). Поведенческий контроль-КОНТРОЛЬ Б6 (self-hide):
# новый самоигнорирующийся `.gitignore` сам — untracked-путь ноги 2
# (ls-files --others его видит, никакое правило его не скрывает).
# Замена porcelain-untracked И emit_gitignore_walk как источника — оба
# поглощены корневым срезом.
# Формат строки:
#   UNTRACKED:<sha256-байтов>\t<путь>
#   UNTRACKED-REPO:<sha HEAD>\t<путь>          — вложенный неотслеживаемый git-repo
#                                                (правка внутри него меняет вложенный
#                                                отпечаток; ворота-11 семантика для
#                                                untracked-вложенных репо, симметрия
#                                                с TRACKED-ногой @head)
#   UNTRACKED-REPO:HEAD_UNREACHABLE\t<путь>    — вложенный .git есть, но rev-parse HEAD
#                                                отказал (orphan-ветка / битый refs);
#                                                именованный маркер, не молчание, не
#                                                падение всего снимка
#   UNTRACKED-DIR:NON_GIT\t<путь>              — не-git каталог; именованный маркер,
#                                                не молчание, не падение снимка
# gitlink'и не входят в `ls-files --others` (это tracked-категория).
# recursion в развёрнутые submodule'ы — для утечки-внутри-submodule
# (замер 2026-09-15: без --recurse-submodules untracked-категория
# верхнего уровня НЕ включает вложенные submodule-каталоги; с
# --recurse-submodules — включает; для симметрии с TRACKED-ногой и
# превентива «утечка внутри уже-развёрнутого submodule» — рекурсия
# добавлена). АНАЛНОГИЧНО для НЕОТСЛЕЖИВАЕМЫХ вложенных git-репо: ls-files
# --others отдаёт сам каталог с trailing slash (НЕ рекурсирует внутрь
# из-за границы .git); запись-каталог обрабатывается отдельной веткой —
# rev-parse HEAD (пин $GIT) + рекурсия emit_tracked_manifest/emit_untracked_manifest
# того репо с префиксом (та же семья, отдельные вызовы с -C <dir>). Эталон
# семантики — СТАРЫЙ emit_manifest (история до корневого среза, 8d065d8~1):
# @head:<sha HEAD> + РЕКУРСИЯ внутрь с префиксом. Внутренний rc≠0 (mktemp
# отказал, ls-files отказал, sha256sum не смог прочесть, rev-parse HEAD
# внутри рекурсии) распространяется через `|| return 2` — НЕ маскируется
# внешним 0. Защита от циклов symlink — канонизация корня (уже есть в
# проекте, верхний уровень): на каждом шаге рекурсии путь внутри
# фиксирован, и ls-files --others не зацикливается (граница .git).
emit_untracked_manifest() {  # <канон-корень> <префикс-путей>
  local root="$1" prefix="$2" tmpf path full sha_line sha rest clean_path head
  tmpf="$("$MKTEMP")" || {
    printf 'NOT_IMPLEMENTED: mktemp отказал в emit_untracked_manifest\n' >&2
    return 2
  }
  # ls-files --others БЕЗ --exclude-standard: ВСЕ untracked, мимо ignore-правил.
  # Рекурсия в submodule'ы для untracked идёт ЧЕРЕЗ emit_tracked_manifest
  # (когда gitlink развёрнут — recursive вызов emit_untracked_manifest на
  # внутреннем корне), НЕ через флаг `--recurse-submodules` (тот
  # поддерживает ТОЛЬКО --cached/--stage режимы git-ls-files, --others
  # даёт «unsupported mode» rc 128 — замер 2026-09-15).
  if ! "$GIT" -C "$root" ls-files --others -z > "$tmpf" 2>/dev/null; then
    "$RM" -f -- "$tmpf"
    printf 'NOT_IMPLEMENTED: git ls-files --others отказал в %s\n' "$root" >&2
    return 2
  fi
  # БАТЧЕВЫЙ sha256sum: один spawn на ВСЕ файлы (экономия: N spawn'ов → 1;
  # canary_vremya требует t_check ≤ 3*t_raw + 3 c, ARG_MAX 2MB позволяет
  # тысячи файлов за один argv). Каталоги (запись с trailing slash от
  # ls-files --others — это вложенный неотслеживаемый git-repo, см. ниже)
  # обрабатываются ОТДЕЛЬНОЙ веткой (рекурсия), не идут в БАТЧ.
  local -a paths=()
  while IFS= read -r -d '' path; do
    # ls-files --others отдаёт каталоги с trailing slash (`tmp/t4/`) —
    # снимаем его для пути в манифесте (формат манифеста без слэша, см.
    # форматы строк выше).
    clean_path="${path%/}"
    # Класс пропуска под `.zones/`: harness-рантайм — SQLite WAL/SHM (ЛЮБАЯ база:
    # `agent.db-wal`, `agent.db-shm`, `history.db-wal`, `history.db-shm`, и любая
    # будущая `*.db-wal`/`*.db-shm` под `agent/`), живой транскрипт сессии
    # (`sessions/*.jsonl` на ЛЮБОЙ глубине под sessions/) и лог-файлы рантайма
    # (`omp.YYYY-MM-DD.N.log` и любой `*.log` под `logs/`). Содержимое легитимно
    # дрейфует от САМОЙ работающей сессии harness'а между снимком и сверкой
    # (SQLite write-ahead log пишется непрерывно; JSONL-транскрипт сессии
    # аппендится; лог-файлы ротируются оркестратором); включение этих путей
    # в манифест давало ложные rc=1 «основной чекаут загрязнён» при ПОЛНОЙ
    # тишине оркестратора (корневой срез №2 2026-09-15: rc=1 «мутировал во
    # время сверки» ВСЕГДА на основном дереве — выявлено find -newer за 60с;
    # полный набор расходящихся путей: `.zones/.../agent/history.db-wal`,
    # `.zones/.../agent/history.db-shm`, `.zones/.../logs/omp.*.log`).
    # Паттерны `*` в case матчат `/` (НЕ как pathname-glob) — покрывают ЛЮБУЮ
    # глубину профиля (`.zones/dev/.omp/profiles/dev/agent/...`).
    # Класс закрыт именной строкой-пропуском по прецеденту `.git/info/refs`
    # в `emit_dotgit_manifest_walk` (тот же механизм `case` с glob);
    # Н-39: новые классы — новый круг адверсария, не перечисление.
    # Имена паттернов ИСЧЕРПЫВАЮЩЕ названы; НЕ весь `.zones/` — ЛЮБЫЕ
    # другие пути под `.zones/` остаются в манифесте и утечки туда ловятся
    # (`.zones/.../evil.txt`, `.zones/.../agent/evil.db` (не -wal/-shm),
    # `.zones/.../logs/evil.bin` — НЕ проходят под carve-out).
    case "$clean_path" in
      .zones/*/agent/*.db-wal) continue ;;         # harness SQLite WAL (любая база)
      .zones/*/agent/*.db-shm) continue ;;         # harness SQLite SHM (любая база)
      .zones/*/agent/sessions/*.jsonl) continue ;; # harness живой jsonl-транскрипт сессии (любая глубина)
      .zones/*/logs/*.log) continue ;;             # harness лог-файлы рантайма
    esac
    full="$root/$clean_path"
    if [ ! -e "$full" ]; then
      # Может случиться после конкурентного удаления между ls-files и
      # проверкой; пропускаем как обычное исчезновение (детектор судит
      # состояние, не историю — в следующий снимок путь не появится).
      continue
    fi
    if [ -d "$full" ]; then
      # ВЕТКА ВЛЕТКИ (задание 024-v6 +семантика для untracked-вложенных):
      # ls-files --others отдаёт сам каталог с trailing slash, потому что
      # внутри есть .git (граница рекурсии git). Две развилки:
      #   (а) `.git` (файл или каталог) есть — вложенный неотслеживаемый
      #       git-repo. Пин `$GIT -C <full> rev-parse HEAD` снимает @head;
      #       на успехе — строка UNTRACKED-REPO:<sha> + РЕКУРСИЯ
      #       (tracked-нога и untracked-нога ТОГО репо с префиксом
      #       <prefix+clean_path>/). На отказе rev-parse — именованный
      #       маркер UNTRACKED-REPO:HEAD_UNREACHABLE (orphan / битый refs);
      #       НЕ молчание (v4 класс ERR-константы — отказ producer'а
      #       ВЫГЛЯДИТ как валидный отпечаток), НЕ падение всего снимка.
      #   (б) `.git` нет — обычный не-git каталог (теоретически ls-files
      #       --others их рекурсивно РАСКРЫВАЕТ до файлов, но симлинк-
      #       петля / особая конфигурация могут дать запись-каталог).
      #       Именованный маркер UNTRACKED-DIR:NON_GIT, не молчание, не
      #       падение снимка.
      # Рекурсия — та же семья, отдельные вызовы `emit_tracked_manifest`
      # и `emit_untracked_manifest` с -C <full> (как и в emit_tracked_manifest
      # для gitlink:472-479); внутренний fail-closed распространяется
      # через `|| return 2`. Глубина конечна (вложенность tmp-скратча
      # замеряна ≤ 8 на основном дереве, сегодня), циклы через symlink
      # — канонизация корня на верхнем уровне + граница .git для ls-files.
      if [ -e "$full/.git" ]; then
        if ! head="$("$GIT" -C "$full" rev-parse HEAD 2>/dev/null)"; then
          # Недостижимый HEAD — именованный маркер, не молчание, не rc=2.
          printf 'UNTRACKED-REPO:HEAD_UNREACHABLE\t%s\n' "$(enc_path "${prefix}${clean_path}")"
        else
          printf 'UNTRACKED-REPO:%s\t%s\n' "$head" "$(enc_path "${prefix}${clean_path}")"
          # || return 2 — внутренний fail-closed (mktemp отказ, ls-files
          # отказ, sha256sum нечитаемый файл в рекурсии, и т.п.) НЕ
          # маскируется внешним 0; это та же механика, что в
          # emit_tracked_manifest для submodule (line:472-479).
          emit_tracked_manifest "$full" "$prefix$clean_path/" || {
            "$RM" -f -- "$tmpf"
            return 2
          }
          emit_untracked_manifest "$full" "$prefix$clean_path/" || {
            "$RM" -f -- "$tmpf"
            return 2
          }
          emit_dotgit_manifest "$full" "$prefix$clean_path/" || {
            "$RM" -f -- "$tmpf"
            return 2
          }
        fi
      else
        # Не-git каталог — именованный маркер, не молчание, не rc=2.
        printf 'UNTRACKED-DIR:NON_GIT\t%s\n' "$(enc_path "${prefix}${clean_path}")"
      fi
      continue
    fi
    if [ ! -r "$full" ]; then
      # Превентив 1 (v4): нечитаемый путь → NOT_IMPLEMENTED rc 2 именованный.
      # ДОЛЖЕН упасть ДО записи снимка: иначе детектор судит по деградировавшему
      # манифесту и теряет мутацию в нечитаемом пути (v4 класс ERR-константы).
      "$RM" -f -- "$tmpf"
      printf 'NOT_IMPLEMENTED: не смог прочитать %s (UNTRACKED)\n' "$full" >&2
      return 2
    fi
    paths+=("$full")
  done < "$tmpf"
  if [ "${#paths[@]}" -gt 0 ]; then
    # ЧАНКИНГ батча sha256sum (live-блокер к11: 17318 путей × ~102B = 1.77MB
    # превышает ARG_MAX=2MB на грани; лимит в ~64КБ на argv даёт запас ×30 и
    # держит каждый spawn детерминированно ниже ARG_MAX, не «у грани»). Цикл
    # по батчам: rc КАЖДОГО sha256sum проверяется ИМЕННО (НЕ pipefail,
    # НЕ «&&» — кейс v4: класс ERR-константы маскировал отказ producer'а
    # как валидный отпечаток). На отказе — NOT_IMPLEMENTED rc 2 именованный,
    # файл снимка удаляется (как и до чанкинга). Замер canary_vremya:
    # batch ≤ ~5ms каждый на /tmp/dev-harness ⇒ ~500 spawn ≈ 2.5с overhead,
    # вписывается в бюджет «3*t_raw + 3 c» (t_raw замерено ~2c).
    : > "${tmpf}.sum"
    local -a chunk=()
    local chunk_bytes=0
    local CHUNK_MAX=65536
    local p pb
    for p in "${paths[@]}"; do
      pb=${#p}
      if [ "$chunk_bytes" -gt 0 ] && [ $((chunk_bytes + pb + 1)) -gt "$CHUNK_MAX" ]; then
        if ! "$SHA256SUM" -- "${chunk[@]}" >> "${tmpf}.sum" 2>/dev/null; then
          "$RM" -f -- "$tmpf" "${tmpf}.sum"
          printf 'NOT_IMPLEMENTED: не смог прочитать untracked в %s (UNTRACKED batch)\n' "$root" >&2
          return 2
        fi
        chunk=()
        chunk_bytes=0
      fi
      chunk+=("$p")
      chunk_bytes=$((chunk_bytes + pb + 1))
    done
    if [ "${#chunk[@]}" -gt 0 ]; then
      if ! "$SHA256SUM" -- "${chunk[@]}" >> "${tmpf}.sum" 2>/dev/null; then
        "$RM" -f -- "$tmpf" "${tmpf}.sum"
        printf 'NOT_IMPLEMENTED: не смог прочитать untracked в %s (UNTRACKED batch)\n' "$root" >&2
        return 2
      fi
    fi
  else
    : > "${tmpf}.sum"
  fi
  while IFS= read -r sha_line; do
    # Формат sha256sum: "<64hex>  <file>" (два пробела между sha и file —
    # второй спецификация GNU coreutils для машинной парсинга).
    sha="${sha_line%% *}"
    rest="${sha_line#*  }"
    # rest — абсолютный путь; восстанавливаем относительный.
    # clean_path используется для представления (без trailing slash, если
    # был), но здесь path — реальный файл без trailing slash, так что
    # rest сводится к относительному пути файла. Симметрия с TRACKED-ногой:
    # в манифесте путь файла идёт КАК ЕСТЬ (с компонентами), без нормализации.
    rest="${rest#"$root"/}"
    printf 'UNTRACKED:%s\t%s\n' "$sha" "$(enc_path "${prefix}${rest}")"
  done < "${tmpf}.sum"
  "$RM" -f -- "$tmpf" "${tmpf}.sum"
}
# НОГА-3 — DOTGIT (БЕЗ ИЗМЕНЕНИЙ v5). emit_dotgit_manifest_walk обходит
# .git/hooks и .git/info рекурсивно с симлинк-развилкой (Б3 CONTENT/DANGLING)
# и carve-out `.git/info/refs`. emit_dotgit_manifest резолвит `.git`-файл
# (Б8, --separate-git-dir форма) и хеширует содержимое `.git/config`.
# В v6 УДАЛЕНА: ветка DOTGIT:EXCLUDES для внешней цели core.excludesFile.
# ПОЧЕМУ: новая UNTRACKED-нога видит саму утечку МИМО ignore-правил
# (порочность перечисления носителей ослепления — Н-89); слепящий эффект
# core.excludesFile нейтрализован корневым срезом без отдельной ветки.
# Замер красной пробы переносится с имени носителя ($EXT/rules) на имя
# утечки ($UTECHKA) — re-анкер контролей 2/3 red_excludes_target_024.sh
# в приёмочной пачке architect'а (правка вне зоны implementer).
emit_dotgit_manifest_walk() {  # <dir> <prefix-от-канон-корня>
  local dir="$1" pre="$2" entry fp target
  for entry in "$dir"/*; do
    [ -e "$entry" ] || [ -L "$entry" ] || continue   # -e лжёт на dangling, -L тоже нужен
    # Класс пропуска внутри .git/info/: git-сопровождаемые кэш-файлы.
    # Текущий (и единственный в git 2.x) представитель — `refs`, генерируется
    # `git update-server-info` (вызывается косвенно через `git gc`, `git repack`,
    # server-side receive-pack). Содержимое легитимно дрейфует между снимком
    # и сверкой из-за ОБЫЧНЫХ git-операций (коммиты/ветки/worktree → новый SHA
    # → новая строка) БЕЗ участия враждебной стороны; включение refs в
    # манифест давало ложные «основной чекаут загрязнён» на честном входе
    # (прогон оркестратора на долгоживущем чекауте после многих часов работы).
    # Класс закрыт именной строкой-пропуском (Н-39: новые классы — новый круг,
    # не перечисление): git документирует содержимое .git/info/ в
    # gitrepository-layout(5) и `git help update-server-info`; сегодня класс
    # = {refs}. Появление нового файла того же класса — расширение списка с
    # тем же обоснованием. exclude / attributes / sparse-checkout / grafts —
    # пользовательские rules, НЕ кэш — остаются в обходе (блокер Б1 ревью v1).
    # Паттерн `*/info/refs` ловит и корневой `.git/info/refs`, и refs вложенных
    # dot-git (recursive emit_dotgit_manifest через gitlink/untracked-repo, префикс
    # вида `sub/info` либо `nested/info`): один и тот же класс кэша по прецеденту
    # вердикта к11 3c6791d — refs дрейфует легитимно между снимком и сверкой
    # (update-server-info), включение в манифест давало бы ложные «загрязнён»
    # при живой git-операции (commit/new branch).
    case "$pre/${entry##*/}" in
      */info/refs) continue ;;     # git-кэш dumb-HTTP transport (root + nested)
    esac
    if [ -L "$entry" ]; then
      # Симлинк внутри .git/hooks/: включаем в отпечаток через readlink
      # (фикс блокера 3, S-dotgit-hook-symlink). readlink работает и на
      # dangling — для подмены достаточно самого факта симлинка.
      if ! target="$("$READLINK" -- "$entry" 2>/dev/null)"; then
        printf 'NOT_IMPLEMENTED: не смог прочитать цель симлинка %s\n' "$entry" >&2
        return 2
      fi
      printf 'DOTGIT:SYMLINK:%s\t%s\n' "$(enc_path "$target")" "$(enc_path "${pre}/${entry##*/}")"
      # Б3 (фикс адверсария contracts-024-k8, S-dotgit-symlink-target-mutation):
      # одна SYMLINK-строка с readlink-целью НЕ ловит подмену БАЙТОВ цели —
      # цель мутирует (`.git/info/exclude` → симлинк `../hidden-exclude` ВНЕ
      # .git, либо симлинк ВНЕ канон-корня целиком — оба репро адверсария к8
      # доказывают явно), readlink-цель НЕ меняется, SYMLINK-строка стабильна,
      # git следует симлинку и молча начинает игнорировать утечку ⇒ «чисто».
      # Решение: РАЗРЕШИТЬ цель полностью через `readlink -f` (канонизация
      # «.»/«..», цель МОЖЕТ лежать вне .git и вне канон-корня); если резолв
      # ведёт в читаемый регулярный файл — добавить ВТОРУЮ строку манифеста
      # ПО ТОМУ ЖЕ ключу-пути `<pre>/<name>` с sha256 БАЙТОВ цели. Подмена
      # байтов цели меняет CONTENT-строку ⇒ дельта ⇒ rc=1 именованный.
      # `readlink -f` возвращает rc≠0 только на нерезолвимой канонизации —
      # именованный NOT_IMPLEMENTED rc=2. Dangling (цель не существует) и
      # не-файл (каталог/FIFO/устройство) — маркерная строка DOTGIT:DANGLING,
      # чтобы не молчать и не падать неназванно: snapshot и check несут
      # РАЗНЫЕ маркеры (DANGLING↔CONTENT либо разные CONTENT-sha) при подмене,
      # дельта ловит оба направления.
      if ! resolved="$("$READLINK" -f -- "$entry" 2>/dev/null)"; then
        printf 'NOT_IMPLEMENTED: readlink -f отказал на %s (цель=%s)\n' "$entry" "$target" >&2
        return 2
      fi
      if [ -n "$resolved" ] && [ -f "$resolved" ] && [ -r "$resolved" ]; then
        if ! fp="$("$SHA256SUM" -- "$resolved" 2>/dev/null)"; then
          printf 'NOT_IMPLEMENTED: не смог прочитать цель симлинка %s (%s)\n' "$entry" "$resolved" >&2
          return 2
        fi
        fp="${fp%% *}"
        printf 'DOTGIT:CONTENT:%s\t%s\n' "$fp" "$(enc_path "${pre}/${entry##*/}")"
      else
        printf 'DOTGIT:DANGLING:%s\t%s\n' "$(enc_path "$resolved")" "$(enc_path "${pre}/${entry##*/}")"
      fi
      continue
    fi
    if [ -f "$entry" ]; then
      if ! fp="$("$SHA256SUM" -- "$entry" 2>/dev/null)"; then
        printf 'NOT_IMPLEMENTED: не смог прочитать %s\n' "$entry" >&2
        return 2
      fi
      fp="${fp%% *}"
      printf 'DOTGIT:%s\t%s\n' "$fp" "$(enc_path "${pre}/${entry##*/}")"
    elif [ -d "$entry" ]; then
      emit_dotgit_manifest_walk "$entry" "$pre/${entry##*/}" || return 2
    fi
  done
}
emit_dotgit_manifest() {  # <канон-корень>
  local root="$1" pre="$2" gitdir hooksdir infodir gdot_content resolved mod name
  [ -n "$pre" ] || pre=""
  gitdir="$root/.git"
  # Б8: `.git` ФАЙЛ (не каталог) — `--separate-git-dir` или worktree-форма.
  # Резолвим реальный gitdir из файла (формат: `gitdir: <path>\n`). Парсим
  # первую строку, убираем `gitdir: ` префикс, снимаем trailing newline.
  # Относительные пути резолвятся от $1 (worktree часто пишет относительный
  # путь к `.git/worktrees/<n>/`); абсолютные — как есть. Канонизация через
  # `readlink -f` (пинованный $READLINK; TRUSTED_PATH-only) снимает
  # симлинки/`.`/`..`. Если `.git`-файл не читаем или `readlink -f` отказал —
  # NOT_IMPLEMENTED rc=2 именованный (отказ producer'а ≠ молчаливый успех).
  if [ -f "$gitdir" ]; then
    if ! gdot_content="$("$CAT" -- "$gitdir" 2>/dev/null)"; then
      printf 'NOT_IMPLEMENTED: не смог прочитать %s\n' "$gitdir" >&2
      return 2
    fi
    resolved="${gdot_content#gitdir: }"
    resolved="${resolved%$'\n'}"
    case "$resolved" in
      /*) ;;
      *)  resolved="$root/$resolved" ;;
    esac
    if ! resolved="$("$READLINK" -f -- "$resolved" 2>/dev/null)"; then
      printf 'NOT_IMPLEMENTED: readlink -f отказал на %s\n' "$resolved" >&2
      return 2
    fi
    gitdir="$resolved"
  fi
  [ -d "$gitdir" ] || return 0   # нет .git/ — нечего хешировать
  # 1. .git/hooks/* (рекурсивно, не-симлинк). Префикс путей: «<pre>.git/hooks[/...]»
  # для корневого вызова (pre="") — `.git/hooks[/...]`, для рекурсивного из
  # gitlink/untracked-repo — `<путь-вложенного-репо>/hooks[/...]` (закрывает
  # блокер S-nested-dotgit-blind адверсария contracts-024-k12, нога-3 в рекурсии).
  hooksdir="$gitdir/hooks"
  if [ -d "$hooksdir" ]; then
    emit_dotgit_manifest_walk "$hooksdir" "${pre}.git/hooks" || return 2
  fi
  # 3. .git/info/* — per-repo rules (exclude/sparse-checkout/attributes/grafts).
  # Правка exclude САМА ПО СЕБЕ невидима porcelain И ослепляет источник манифеста
  # для файлов под новым правилом (блокер Б1 ревью v1). Закрытие ВЕРТИКАЛЬНОЕ —
  # emit_dotgit_manifest_walk по всему каталогу .git/info/. Н-39: новые классы —
  # новый круг адверсария, не перечисление.
  infodir="$gitdir/info"
  if [ -d "$infodir" ]; then
    emit_dotgit_manifest_walk "$infodir" "${pre}.git/info" || return 2
  fi
  # 2. .git/config (один файл — точка контроля receive.denyCurrentBranch и пр.,
  # влияющих на всё поведение git; подмена эквивалентна конфигурированию
  # «зеркального» репозитория).
  if [ -f "$gitdir/config" ]; then
    if ! fp="$("$SHA256SUM" -- "$gitdir/config" 2>/dev/null)"; then
      printf 'NOT_IMPLEMENTED: не смог прочитать %s\n' "$gitdir/config" >&2
      return 2
    fi
    fp="${fp%% *}"
    printf 'DOTGIT:%s\t%s\n' "$fp" "$(enc_path "${pre}.git/config")"
  fi
  # 4. .git/modules/<имя>/ — gitdir'ы подмодулей, физически лежат ВНУТРИ
  # корневого .git. Существуют только для ТРЕКЕД-сабмодулей (untracked-вложенные
  # репо не порождают .git/modules/<name>/). Рекурсивный вызов emit_dotgit_manifest
  # из emit_tracked_manifest для gitlink (`<root>/sub/.git` файл, резолвится
  # в `<root>/.git/modules/sub/`) ИДЁТ ПО ТЕМ ЖЕ ФАЙЛАМ с другим префиксом
  # (`sub/hooks/...` вместо `.git/modules/sub/hooks/...`): двойной обход даёт
  # ДВЕ строки манифеста на один и тот же файл — обе в snapshot/check, обе
  # синхронны по sha, ложных дельт нет. Это сознательный defense-in-depth: если
  # кто-то подменит `.git/modules/<name>/` (минуя `.git`-файл сабмодуля) — корневой
  # walk ловит; если кто-то подменит сам gitdir (внутри `..`) — обе строки дельтятся
  # синхронно, имена обоих префиксов в выводе. Закрывает сценарий B адверсария
  # contracts-024-k12 (подмена pre-push в gitdir'е подмодуля
  # `<root>/.git/modules/<name>/hooks/pre-push`).
  if [ -z "$pre" ] && [ -d "$gitdir/modules" ]; then
    for mod in "$gitdir/modules"/*; do
      [ -e "$mod" ] || [ -L "$mod" ] || continue
      [ -d "$mod" ] || continue   # только каталоги (стандартная форма)
      name="${mod##*/}"
      emit_dotgit_manifest "$mod" ".git/modules/$name/" || return 2
    done
  fi
  # УДАЛЕНО в v6: ветка DOTGIT:EXCLUDES для внешней цели core.excludesFile.
  # Слепящий эффект core.excludesFile нейтрализован корневым срезом —
  # нога-2 (UNTRACKED) видит КАЖДЫЙ неотслеживаемый путь с sha256 байтов
  # МИМО ЛЮБЫХ ignore-правил (включая саму внешнюю цель и её правила).
  # Замер красной пробы (red_excludes_target_024) переносится с имени
  # носителя на имя утечки — re-анкер контролей 2/3 в приёмочной пачке
  # architect'а (зона architect, не implementer).
}
# manifest() сшивает три ноги v6 (TRACKED + UNTRACKED + DOTGIT) и сортирует
# ЕДИНЫМ sort. Каждый producer вызывается через прямую командную подстановку
# (НЕ через `{ p1; p2; } | sort` — регрессия ворот 15 круга k6/k7: группа
# `{ }` в пайпе отдаёт для pipefail rc ПОСЛЕДНЕЙ команды внутри группы,
# теряя rc более ранней; здесь `$?` читается СРАЗУ после каждой отдельной
# подстановки — Н-84/Н-85: rc без пайпов, каждый producer явно).
# Финальный `:` в группе — гарантия rc=0 группы при pipefail: если ПОСЛЕДНИЙ
# producer пуст, его `[ -n "" ] && printf` возвращает 1 (test ложен ⇒
# конструкция возвращает 1), и pipeline отдаёт rc=1 даже когда sort и
# предыдущие producer'ы прошли успешно. Прецедент «группа в пайпе отдаёт
# rc последней команды» обходится финальным `:` после всех `&& printf` —
# он всегда успешен и перебивает 1 от ложного теста в хвосте.
manifest() {
  local out_a out_b out_c rc
  out_a="$(emit_tracked_manifest "$1" "${2:-}")"
  rc=$?
  [ "$rc" -eq 0 ] || return "$rc"
  out_b="$(emit_untracked_manifest "$1" "${2:-}")"
  rc=$?
  [ "$rc" -eq 0 ] || return "$rc"
  out_c="$(emit_dotgit_manifest "$1" "${2:-}")"
  rc=$?
  [ "$rc" -eq 0 ] || return "$rc"
  {
    [ -n "$out_a" ] && printf '%s\n' "$out_a"
    [ -n "$out_b" ] && printf '%s\n' "$out_b"
    [ -n "$out_c" ] && printf '%s\n' "$out_c"
    :
  } | "$SORT"
}

do_snapshot() {
  local m manifest_rc
  m="$(manifest "$CANON" '')"
  manifest_rc=$?
  if [ "$manifest_rc" -ne 0 ]; then
    # rc=2 NOT_IMPLEMENTED (mktemp отказ, sha256sum/rev-parse fail в
    # рекурсии — превентивы 1/2) — сообщение уже напечатано в producer'е;
    # rc 2 контракта 024 для непригодного окружения должен сохраняться,
    # а не превращаться в rc 1 «ОТКАЗ».
    [ "$manifest_rc" -eq 2 ] && exit 2
    printf 'ОТКАЗ: status отказал в %s (rc=%d)\n' "$CANON" "$manifest_rc" >&2
    exit 1
  fi
  "$MKDIR" -p "$SNAP_DIR" \
    || { printf 'NOT_IMPLEMENTED: %s не создать\n' "$SNAP_DIR" >&2; exit 2; }
  # Перезапись: последний выигрывает (И-1, ворота 6). Атомарность записи снимка
  # через temp + mv: сначала пишем в .tmp, fsync, переименовываем; одновременно
  # вычисляем sha содержимого для verify-строки и самой записи в финал.
  local tmp_snap verify_payload verify_sha
  tmp_snap="$("$MKTEMP" "$SNAP_DIR/.porcelain.tmp.XXXXXX")" \
    || { printf 'NOT_IMPLEMENTED: mktemp для снимка отказал\n' >&2; exit 2; }
  # Файл строится в три приёма, склеивается в sha-вход и на финал:
  #   строка 1: root <CANON>
  #   тело:     отсортированные строки манифеста
  #   строка N: verify <sha256 всего предыдущего содержимого>
  # Verify охватывает и «root», и тело — то есть СВЯЗЫВАЕТ снимок с каноническим
  # корнем (через первую строку) и с состоянием дерева (через тело). На check
  # проверка ВСЕГДА обязательна (класс-фикс вердикта к3, контрпример
  # S-mv-replace-no-verify 8911b68): отсутствие verify-строки в прод-снимке
  # = именный отказ «verify-строка отсутствует — обязательна для прод-снимков».
  # Совместимость со стабами `fixtures/check_judge_gate/stab_detektor_*.sh`
  # держится НЕ через глобальное послабление, а через обособленный код стабов:
  # canary и red_detektor_utechek.sh работают с прод-детектором и его снимки
  # ВСЕГДА пишут verify; стабы НЕ зовут прод-verify и проверяются собственной
  # веткой слабого детектора (probe_slabyh_detektora.sh, фаза 1 «честная форма»
  # против стaba с verify-строкой — то же имя, та же грамматика verify).
  {
    printf 'root %s\n' "$CANON"
    printf '%s\n' "$m"
  } > "$tmp_snap"
  # sha256sum прямо из файла: $(cat …) в bash срезает хвостовые \n, что сдвигает
  # sha256 на 1 байт и рвёт verify-чек на check. Чтение через stdin — без потерь.
  verify_sha="$("$SHA256SUM" < "$tmp_snap" | "$HEAD" -n1)"
  verify_sha="${verify_sha%% *}"
  printf 'verify %s\n' "$verify_sha" >> "$tmp_snap"
  # Mode-lock: только-read для всех — defense-in-depth (иммутабельность файла
  # после записи; атакующий, чтобы переписать содержимое, обязан сначала снять
  # бит записи). На check — sanity mode (бит 0444 присутствует); см. do_check.
  "$CHMOD" 0444 -- "$tmp_snap" 2>/dev/null \
    || { "$RM" -f -- "$tmp_snap"; printf 'NOT_IMPLEMENTED: chmod 0444 на снимок отказал\n' >&2; exit 2; }
  "$MV" -f -- "$tmp_snap" "$SNAP" \
    || { "$RM" -f -- "$tmp_snap"; printf 'NOT_IMPLEMENTED: переименование снимка отказало\n' >&2; exit 2; }
}

do_check() {
  local first base cur delta names l p manifest_rc snap_mode verify_line verify_stored verify_recomp
  # И-4 fail-closed: снимок отсутствует — отказ, НЕ пропуск.
  if [ ! -e "$SNAP" ]; then
    printf 'ОТКАЗ: %s (%s) — снимок ДО спавна пачки обязателен: без него сверка отказывает, а не пропускает (fail-closed)\n' \
      "$P_NET_SNIMKA" "$SNAP" >&2
    exit 1
  fi
  # ЗАЩИТА-СНИМКА — мера 1: явный запрет симлинков. Контрпример S-external-snapshot-symlink
  # адверсария к2 01ed097: после baseline-снимка файл `$SNAP` заменяется симлинком на
  # снимок ТОГО ЖЕ корня, сделанный ПОСЛЕ модификации tracked-файла; root-строка
  # совпадает, дельта пуста ⇒ «чисто». `[ -L ]` ловит ровно эту подмену.
  if [ -L "$SNAP" ]; then
    printf 'ОТКАЗ: снимок — симлинк: %s — replacement через симлинк недопустим (ЗАЩИТА-СНИМКА к2 адверсария)\n' "$SNAP" >&2
    exit 1
  fi
  # Мера 1б: симлинк на КАТАЛОГ снимка. Тот же класс подмены через `ln -s` на $SNAP_DIR.
  if [ -L "$SNAP_DIR" ]; then
    printf 'ОТКАЗ: каталог снимка — симлинк: %s — replacement каталога недопустим (ЗАЩИТА-СНИМКА к2 адверсария)\n' "$SNAP_DIR" >&2
    exit 1
  fi
  # Мера 1в (наблюдение H адверсария к5 4dfc0ff): симлинк на ПРОМЕЖУТОЧНЫЙ
  # `$TMPDIR/dev-harness-leak`. Атакующий снимает оригинальный `$TMPDIR/dev-harness-leak`
  # и создаёт симлинк `$TMPDIR/dev-harness-leak` → `$stash/dev-harness-leak`,
  # где `$stash/dev-harness-leak/$HASH8/porcelain` — СВЕЖИЙ снимок ТОГО ЖЕ корня,
  # сделанный ПОСЛЕ модификации tracked-файла (root-строка совпадает, verify валиден).
  # `$SNAP` и `$SNAP_DIR` при таком обходе — регулярные (атакующий контролирует
  # содержимое stash), проверки -L на них ПРОХОДЯТ, дельта пуста, rc 0 «чисто».
  # Единственная защита — `[ -L ]` на самом промежуточном `$TMPDIR/dev-harness-leak`.
  if [ -L "$TMPDIR_BASE/dev-harness-leak" ]; then
    printf 'ОТКАЗ: промежуточный каталог — симлинк: %s/dev-harness-leak — replacement промежуточного каталога недопустим (ЗАЩИТА-СНИМКА наблюдение H адверсария к5)\n' \
      "$TMPDIR_BASE" >&2
    exit 1
  fi
  # `[ ! -f ]` оставлен ПОСЛЕ симлинк-чека: регулярный файл ≠ симлинк, но
  # != каталог/FIFO/устройство. Все четыре несимлинк-но-не-файл класса — отказ.
  if [ ! -f "$SNAP" ]; then
    printf 'ОТКАЗ: снимок — не регулярный файл: %s\n' "$SNAP" >&2
    exit 1
  fi
  # (mode-check ПЕРЕНЕСЁН НИЖЕ — после root-line-чека. Иначе gate 13 (фейковый
  # снимок чужого корня, mode 644) стреляет по mode раньше, чем по root-строке.)
  # Первая строка — root <канон>. Не сошлась — чужой снимок (hash8-коллизия ИЛИ подмена,
  # совет 1 вердикта). Имена НЕ извлекаем — это не утечка, это ошибка церемонии.
  #
  # ПРЕВЕНТИВ 3: `|| true` маскировал отказ cat как пустую базу (направление
  # безопасное, ложное «загрязнён» вместо «чисто», но причина безымянна). Теперь
  # именный fail-closed rc=1 ОТКАЗ рядом с «снимок отсутствует»/«снимок чужого
  # корня» — снимок существовал по `[ -f "$SNAP" ]`, но прочесть нельзя.
  #
  # Два ОТДЕЛЬНЫХ чтения (НЕ shared fd через `{ read; cat; } < "$SNAP"`): shared fd
  # при провале редиректа оставляет first/base не присвоенными — set -u стреляет на
  # следующем обращении к $first, маскируя наш именный отказ. С отдельными
  # `< "$SNAP"` bash возвращает явный код возврата на каждом.
  first=""
  if ! IFS= read -r first < "$SNAP"; then
    printf 'ОТКАЗ: снимок не прочитан: %s\n' "$SNAP" >&2
    exit 1
  fi
  base=""
  if ! base="$("$CAT" -- "$SNAP" 2>/dev/null)"; then
    printf 'ОТКАЗ: снимок не прочитан: %s\n' "$SNAP" >&2
    exit 1
  fi
  if [ "$first" != "root $CANON" ]; then
    printf 'ОТКАЗ: %s: снимок = [%s], сверяется [%s] — hash8-коллизия либо чужой файл; переснимите свою пачку\n' \
      "$P_CHUZH" "$first" "$CANON" >&2
    exit 1
  fi
  # Мера 2 (mode-lock, ПЕРЕНЕСЕНО из до-чтения сюда — после root-line-чека).
  # Семантика: «если снимок НАШ (root-строка сошлась), то mode ОБЯЗАН быть
  # read-only» — защита от «а cat new > old сохранил write-бит». Если root
  # НЕ сошёлся, мы уже отвергли снимок ранее (gate 13) и сюда не доходим; тем
  # самым фейковые снимки (чужие или стабы) не ловятся по mode, а ловятся по
  # root — это и есть желаемая диагностика gate 13 («снимок чужого корня»).
  snap_mode="$("$STAT" -c '%a' -- "$SNAP" 2>/dev/null)" \
    || { printf 'NOT_IMPLEMENTED: stat отказал на %s\n' "$SNAP" >&2; exit 2; }
  case "$snap_mode" in
    *[!0-7]*) printf 'NOT_IMPLEMENTED: stat вернул не-octal mode %s\n' "$snap_mode" >&2; exit 2 ;;
  esac
  # write-биты 0222 (owner+group+other) ОБЯЗАНЫ быть 0 — иначе файл write-able,
  # что противоречит mode-lock после snapshot. 8# — stat -c %a печатает octal
  # без ведущего нуля; без префикса bash читает «444» как десятичное 444.
  if [ $((8#$snap_mode & 0222)) -ne 0 ]; then
    printf 'ОТКАЗ: снимок: режим %s не read-only (биты 022 ≠ 0) — подмена или рассинхрон\n' "$snap_mode" >&2
    exit 1
  fi
  # Мера 3: ОБЯЗАТЕЛЬНЫЙ self-verify (класс-фикс вердикта к3 — контрпример
  # S-mv-replace-no-verify 8911b68). Последняя строка `verify <sha>` ОБЯЗАНА
  # присутствовать в прод-снимке: атакующий, имеющий право писать в свой TMPDIR,
  # делает `mv -f` своего снимка БЕЗ verify — старая ветка «if -n verify_line»
  # пропускала verify-чек, дельта считалась от подогнанного манифеста ⇒ «чисто».
  # Теперь отсутствие verify — НЕ молчаливый пропуск, а именный rc=1 ОТКАЗ.
  # Совместимость со стабами `fixtures/check_judge_gate/stab_detektor_*.sh`
  # (НЕ пишут verify) держится через их обособленный код — canary и red_detektor
  # используют прод-детектор (ВСЕГДА пишет verify) и проверяются против него;
  # стабы — отдельный код, проверяются своей веткой слабого детектора и к
  # прод-verify-чеку не приходят.
  verify_line="$(printf '%s' "$base" | "$GREP" -E '^verify [0-9a-f]{64}$' | "$TAIL" -n1 || true)"
  if [ -z "$verify_line" ]; then
    printf 'ОТКАЗ: снимок: verify-строка отсутствует — обязательна для прод-снимков (отсутствие verify = подмена/сговор, не «совместимость со стабом»; контрпример S-mv-replace-no-verify к3 8911b68)\n' >&2
    exit 1
  fi
  # Содержимое ДО verify-строки (включая завершающий \n перед verify) — это всё,
  # что verify коммитит. do_snapshot кладёт «root …\n + sorted-строки\n» и потом
  # дописывает «verify <sha>\n»; на check берём всё ДО «verify <sha>» — последний
  # \n (тот, что отделял тело от verify) сохраняем, иначе sha256 не совпадёт
  # (cat -- | sha256sum vs printf '%s' … | sha256sum — лишний/недостающий \n).
  verify_payload="${base%verify *}"
  # Точная копия правила из do_snapshot:
  verify_recomp="$(printf '%s' "$verify_payload" | "$SHA256SUM" | "$HEAD" -n1)"
  verify_recomp="${verify_recomp%% *}"
  verify_stored="${verify_line#verify }"
  if [ "$verify_recomp" != "$verify_stored" ]; then
    printf 'ОТКАЗ: снимок: verify не сошёлся (хранимый=%s, пересчёт=%s) — байтовая модификация снимка на месте\n' \
      "$verify_stored" "$verify_recomp" >&2
    exit 1
  fi
  # Б4 (фикс адверсария contracts-024-k8, S-porcelain-dotgit-toctou): один
  # прочёт манифеста читает TRACKED/UNTRACKED (`emit_tracked_manifest` +
  # `emit_untracked_manifest`) и dot-git walk (`emit_dotgit_manifest`)
  # НЕАТОМАРНО, ТРЕМЯ отдельными producer-вызовами — между ними окно, в
  # которое атакующий переключает `.git/info/exclude` (скрыть-утечку →
  # восстановить-baseline) так, что untracked-нога видит скрытое, а dot-git
  # walk видит уже восстановленное (или наоборот); все три producer'а по
  # отдельности выглядят «согласованными со снимком», хотя физически файл
  # утечки существует. Повторный прогон адверсария — 5 из 5 ложных «чисто».
  #
  # Решение: вычислить ПОЛНЫЙ комбинированный манифест (`manifest()` целиком)
  # ДВАЖДЫ ПОДРЯД, без другой работы между вызовами. Если оба чтения СОВПАДАЮТ
  # байт-в-байт — дерево было согласованным на протяжении обоих прочтений
  # (окно гонки не поймало мутацию), и дальше судим по ОБЫЧНОЙ дельте против
  # снимка (как раньше). Если чтения РАСХОДЯТСЯ — сам факт расхождения ЕСТЬ
  # сигнал «дерево мутировало во время сверки»: `--check` ОБЯЗАН отказать
  # ИМЕННО, а не молча доверять первому/второму чтению (оба уже показали,
  # что видели РАЗНЫЕ состояния одного и того же дерева в одну сверку).
  #
  # Carve-out `.git/info/refs` (легитимный git-дрейф, red_info_refs_drift_024)
  # не ломается: refs вообще НЕ входит ни в одно из двух чтений манифеста
  # (пропуск в emit_dotgit_manifest_walk), поэтому обычный дрейф refs МЕЖДУ
  # двумя чтениями не может вызвать их расхождение — оба чтения одинаково
  # НЕ видят refs.
  cur1="$(manifest "$CANON" '')"
  manifest_rc=$?
  if [ "$manifest_rc" -ne 0 ]; then
    [ "$manifest_rc" -eq 2 ] && exit 2
    printf 'ОТКАЗ: status отказал в %s (rc=%d)\n' "$CANON" "$manifest_rc" >&2
    exit 1
  fi
  cur2="$(manifest "$CANON" '')"
  manifest_rc=$?
  if [ "$manifest_rc" -ne 0 ]; then
    [ "$manifest_rc" -eq 2 ] && exit 2
    printf 'ОТКАЗ: status отказал в %s (rc=%d)\n' "$CANON" "$manifest_rc" >&2
    exit 1
  fi
  if [ "$cur1" != "$cur2" ]; then
    printf 'ОТКАЗ: %s: основной чекаут мутировал во время сверки — повторное чтение разошлось с первым (три producer-ноги идут неатомарно; фикс блокера Б4 адверсария contracts-024-k8)\n' \
      "$P_ZAGR" >&2
    exit 1
  fi
  cur="$cur1"
  # Дельта — ПОДМНОЖЕСТВО: новые строки манифеста ⇒ утечка. Исчезновения — чистка, не краснеем.
  delta="$(printf '%s\n' "$cur" | "$COMM" -23 - <(printf '%s\n' "$base" | "$SORT"))"
  if [ -n "$delta" ]; then
    names=""
    while IFS= read -r l; do
      [ -n "$l" ] || continue
      p="${l#*$'\t'}"
      if [ -z "$names" ]; then names="$p"; else names="$names, $p"; fi
    done <<< "$delta"
    printf 'ОТКАЗ: %s: %s\n' "$P_ZAGR" "$names" >&2
    exit 1
  fi
  printf '%s\n' "$P_CHISTO"
}

case "$MODE" in
  --snapshot) do_snapshot ;;
  --check)    do_check ;;
esac
exit 0