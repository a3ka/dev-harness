#!/usr/bin/env bash
# red_roli_v_profil_105.sh — клетка И-3 контракта 105: роли харнеса
# материализуются в каталог агента ПРОФИЛЯ — `$HOME/.omp/profiles/dev/agent/
# agents/*.md`, где $HOME — тот HOME, который получает ребёнок-omp (env-дамп
# стаба); состав файлов = состав roles/ установки, а каждый файл несёт
# полное тело соответствующей роли (оба оракула в памяти до запуска).
# `$HOME/.omp/agent/agents` (каталог НЕ профиля — omp под --profile его не
# читает, omp://config-usage.md «Profiles») этим запуском НЕ создаётся.
# Путь берётся из строки `AGENTS: <путь>` stdout (одна строка).
# Независимые миры N=2..5 и N=0; содержимое судится и на пустой установке.
#
# rc 0 — зелёная; rc 1 — красная («105 И-3 КРАСНО: …»); rc 2 — мир сломан.
# ДО реализации на живом workshop — красная: роли ложатся в $HOME/.omp/agent/
# agents (workshop:869), строки AGENTS: нет.

cell() {
  local agents n_ag home_child got_roles role_bodies
  # Единый парсер roles.ts; снимок ДО субъекта, не повторное чтение его диска.
  role_bodies="$(node --input-type=module - "$ROOT" <<'JS'
import {pathToFileURL} from 'node:url';
const root = process.argv[2];
const {loadRoles} = await import(pathToFileURL(`${root}/scripts/roles.ts`));
const roles = loadRoles(`${root}/roles`);
if (!roles.length || roles.some(r => !r.body)) process.exit(2);
process.stdout.write(JSON.stringify(roles.map(r => [r.slug, r.body])));
JS
  )" || die_pack "не удалось снять тела ролей установки"
  run_live k3
  [ "$RC" -eq 0 ] || { pokazat k3; krasno "живой запуск упал rc=$RC"; return; }
  [ "$(launch_n k3)" -eq 1 ] || { krasno "стаб-omp запущен $(launch_n k3) раз, ожидался ровно 1"; return; }
  n_ag="$(out_vals k3 AGENTS | wc -l)"
  [ "$n_ag" -eq 1 ] || { krasno "строк AGENTS: в stdout $n_ag, ожидалась ровно 1"; return; }
  agents="$(out_vals k3 AGENTS)"
  home_child="$(sed -n 's/^HOME=//p' "$WORK/k3.env")"
  [ -n "$home_child" ] || { krasno "в окружении ребёнка-omp нет HOME"; return; }
  [ "$agents" = "$home_child/.omp/profiles/dev/agent/agents" ] \
    || { krasno "AGENTS: $agents ≠ <HOME ребёнка>/.omp/profiles/dev/agent/agents (HOME=$home_child)"; return; }
  [ -d "$agents" ] || { krasno "каталога $agents нет"; return; }
  got_roles="$(ls "$agents" | sorted)"
  [ "$got_roles" = "$EXPECT_ROLES" ] || { krasno "состав $agents ≠ состав roles/ установки"; return; }
  # Модель копирует исходную роль, генератор меняет frontmatter и добавляет
  # обрамление. Полное тело обязано оставаться блоком целых строк в обоих
  # форматах: проверка имён/размера или отдельного маркера этого не доказывает.
  printf '%s' "$role_bodies" | node --input-type=module -e '
import {readFileSync, statSync} from "node:fs";
const roles = JSON.parse(readFileSync(0, "utf8"));
for (const [slug, body] of roles) {
  const path = `${process.argv[1]}/${slug}.md`;
  let text;
  try {
    if (!statSync(path).isFile()) throw new Error("not a file");
    text = readFileSync(path, "utf8");
  } catch {
    console.error(`агент ${slug}: нет читаемого файла`);
    process.exit(1);
  }
  if (!(`\n${text}\n`).includes(`\n${body}\n`)) {
    console.error(`агент ${slug}: тело роли отсутствует или изменено`);
    process.exit(1);
  }
}
' "$agents" || { krasno "агентные файлы не материализуют тела ролей установки"; return; }
  [ ! -e "$home_child/.omp/agent/agents" ] \
    || { krasno "создан $home_child/.omp/agent/agents — каталог вне профиля dev, omp под --profile его не читает"; return; }
  return 0
}
rc=0
for scenario in nonempty empty; do
  (
    CELL="И-3"
    # shellcheck source=_mir_105.sh
    . "$(dirname "${BASH_SOURCE[0]}")/_mir_105.sh"
    if [ "$scenario" = empty ]; then
      rm -- "${EXPECT_EXT[@]}" || die_pack "не удалось опустошить установку"
      EXPECT_EXT=()
      EXT_N=0
    fi
    cell
    case_rc=$?
    printf '105 И-3: установка несёт %s расширений; клетка %s\n' "$EXT_N" "$([ $case_rc -eq 0 ] && printf 'зелёная' || printf 'красная')"
    exit "$case_rc"
  )
  case_rc=$?
  [ "$case_rc" -le "$rc" ] || rc=$case_rc
done
exit "$rc"
