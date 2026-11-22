"""Reference delta over the real, immutable guard/preflight; never installed in scripts/."""
import json
import subprocess

BASE = 'db56f44d1012854b6098a7076fccdae0855badeb'
NORM = ('В изолированном суде WORKTREE задания — адрес доставки, место записи — собственная копия pwd; '
        'scratch создавай внутри неё абсолютным путём либо с абсолютным cwd bash. '
        'Вердикт пиши и коммить в собственной копии на wip/<NNN>/<роль>, не в detached runtime-checkout и не в основном чекауте; '
        'перед коммитом вызови pre_judge.sh verdict --repo <своя-копия> --file <абсолют-вердикта>. '
        'При Н-85 используй подсказку только для переформулирования той же операции в той же разрешённой копии; '
        'не меняй цель на чужой WORKTREE или живой state и не обходи страж. '
        'Если допустимая форма вновь отказана, сохрани диагноз в вердикте среды и передай его оркестратору, а не завершай суд без вердикта.')
HINT = 'Н-85: форма записи: абсолютный path внутри своей копии; bash — с абсолютным cwd своей копии. WORKTREE задания — адрес доставки, не место записи изолированного судьи.'
ROLES = ('critic', 'adversary', 'reviewer')
FILES = ('.omp/extensions/path-guard.ts', 'scripts/pre_judge.sh', *(f'roles/{r}.md' for r in ROLES))

def replace(text, old, new):
    if text.count(old) != 1:
        raise RuntimeError(f'MODEL_ANCHOR: {old!r}')
    return text.replace(old, new)

def materialize(repo, dest):
    for name in FILES:
        data = subprocess.check_output(['git', '-C', str(repo), 'show', f'{BASE}:{name}']).decode()
        if name.endswith('path-guard.ts'):
            data = replace(data, "for (const kw of ['tee', 'cp',", "for (const kw of ['tee',")
            data = replace(data, '  const c = stripQuotes(cmd);\n  if (', '''  const first = tokenizeShell(cmd)[0] ?? '';
  if (['cp', 'mkdir'].includes(first.split('/').pop() ?? '')) return true;
  const c = stripQuotes(cmd);
  if (''')
            data = replace(data, '    const head = argv[0];', "    const head = argv[0].split('/').pop() ?? argv[0];")
            data = replace(data, '    // mkdir DIR [DIR …] — каждый не-флаг аргумент.', '''    // cp reads its sources; only the destination is a write operand.
    if (head === 'cp') {
      const paths = argv.slice(1).filter((a) => !a.startsWith('-'));
      if (paths.length >= 2) pushOp(paths[paths.length - 1]);
      continue;
    }
    // mkdir DIR [DIR …] — каждый не-флаг аргумент.''')
            data = replace(data, "  if (!cmd) return { decision: 'pass' };", '''  if (!cmd) return { decision: 'pass' };
  if (cmd.includes('\\0')) return { decision: 'block', reason: 'Н-85: NUL в команде' };''')
            # One public wrapper also covers the factory, not merely the CLI.
            data = replace(data, 'export function judge(input: JudgeInput): Decision {', 'function baseJudge(input: JudgeInput): Decision {')
            wrapper = '''export function judge(input: JudgeInput): Decision {
  const result = baseJudge(input);
  if (result.decision === 'pass') return result;
  return { ...result, reason: result.reason + '\\n' + %s };
}

''' % json.dumps(HINT, ensure_ascii=False)
            data = replace(data, '// ── CLI:', wrapper + '// ── CLI:')
        elif name.endswith('pre_judge.sh'):
            data = replace(data, '  exit 1\n}', '''  case "$1" in
    VERDIKT_VNE_REPO) printf 'ФОРМА: --repo <своя-копия> --file <абсолют-вердикта-в-своей-копии>\\n' >&2 ;;
    NE_SUDJSKAJA_VETKA) printf 'ФОРМА: в своей копии git switch -c wip/<NNN>/<роль>; не коммить в detached runtime-checkout\\n' >&2 ;;
  esac
  exit 1
}''')
        else:
            if name == 'roles/critic.md':
                data = replace(data, 'Работаешь в своём клоне (`git clone <основной> ./tmp/critic/repo`), но вердикт коммитишь в\n**ОСНОВНОЙ** репозиторий', 'Работаешь в своей изолированной копии; вердикт коммитишь в\nсобственную копию')
            else:
                data = replace(data, 'Пишешь вердикт файлом и коммитишь его в ОСНОВНОЙ репозиторий', 'Пишешь вердикт файлом и коммитишь его в собственную копию')
            data += '\n## Среда изолированного судьи (контракт 206)\n\n' + NORM + '\n'
        target = dest / name
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(data)
