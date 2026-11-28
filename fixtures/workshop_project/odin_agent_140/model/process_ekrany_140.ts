// Reference for R0191 only. Imported into the real hook by the scoped battery.
// Production integration belongs to implementer, after critic/freeze.
import { realpathSync, readFileSync } from 'node:fs';
import { basename } from 'node:path';
import { spawnSync } from 'node:child_process';

export const POLICY = Object.freeze({
  remote: 'https://github.com/a3ka/Complior-mob.git',
  policyPath: 'docs/context/OWNER-DECISIONS-F0.md',
  policyBlob: '215246a1f0ddbe374797bc845dc8c5ea5aa65ff0',
  model: 'openai-codex/gpt-6.1-sol',
});

type Decision = { kind: 'ordinary' | 'pass' } | { kind: 'block'; reason: string };

function record(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null;
}

export function processEkrany(input: unknown, sessionFile: string): Decision {
  const items: unknown[] = record(input) && Array.isArray(input.tasks) ? input.tasks : [input];
  const requested = items.filter(item => record(item) && typeof item.task === 'string' &&
    item.task.split('\n').some(line => line.startsWith('PROCESS=')));
  if (!requested.length) return { kind: 'ordinary' };
  const refuse = (code: string): Decision => ({kind: 'block', reason: `ОТКАЗ: ${code}`});
  if (items.length !== 1) return refuse('PROCESS_EKRANY_PAKET');
  const item = items[0];
  if (!record(item) || typeof item.task !== 'string')
    return refuse('PROCESS_EKRANY_KONTEKST');
  const task = item.task;
  const field = (name: string, pattern: RegExp): string | null => {
    const rows = task.split('\n').filter(line => line.startsWith(name + '='));
    if (rows.length !== 1) return null;
    const value = rows[0].slice(name.length + 1);
    return pattern.test(value) ? value : null;
  };
  if (field('PROCESS', /^PROCESS-EKRANY$/) === null) return refuse('PROCESS_EKRANY_KONTEKST');
  if (item.agent !== 'reviewer' || item.model !== POLICY.model)
    return refuse('PROCESS_EKRANY_MODEL');
  if (typeof item.name !== 'string' || !/^[A-Za-z0-9._-]+$/.test(item.name))
    return refuse('PROCESS_EKRANY_KONTEKST');
  const object = field('OBJECT', /^[0-9a-f]{40}$/);
  const line = field('LINE', /^L[0-9]+[a-z]?$/);
  const branch = field('BRANCH', /^f0\/L[0-9]+[a-z]?$/);
  const worktree = field('WORKTREE', /^\/[^\t\r\n]+$/);
  const session = field('SESSION', /^[A-Za-z0-9._-]+$/);
  if (!object || !line || branch !== 'f0/' + line || !worktree || !session)
    return refuse('PROCESS_EKRANY_PIN');
  try {
    // Runtime session header, not text in a message or an env hint.
    const records: unknown[] = readFileSync(sessionFile, 'utf8').trim().split('\n').map(line => JSON.parse(line));
    const header = records.find(value => !record(value) || value.type !== 'title');
    if (!record(header) || header.type !== 'session' || typeof header.id !== 'string' ||
        basename(sessionFile) !== session + '.jsonl' ||
        typeof header.cwd !== 'string' ||
        realpathSync(header.cwd) !== realpathSync(process.cwd()) ||
        realpathSync(worktree) !== realpathSync(process.cwd()))
      return refuse('PROCESS_EKRANY_SESSION');
    const git = (...args: string[]): string => {
      const r = spawnSync('git', ['-C', process.cwd(), ...args], {encoding: 'utf8', timeout: 5000});
      if (r.status !== 0) throw new Error('git unavailable');
      return r.stdout.trim();
    };
    const remote = git('remote', 'get-url', 'origin');
    if (![POLICY.remote, 'ssh://git@github.com/a3ka/Complior-mob.git',
          'git@github.com:a3ka/Complior-mob.git'].includes(remote))
      return refuse('PROCESS_EKRANY_REMOTE');
    // Same publication trust boundary as D9: fetched origin-view. No fetch,
    // no extra ref, no wip alias. Exact tip excludes an old published OBJECT.
    if (git('rev-parse', '--verify', `refs/remotes/origin/${branch}^{commit}`) !== object ||
        git('rev-parse', '--verify', 'HEAD^{commit}') !== object)
      return refuse('PROCESS_EKRANY_OBJECT');
    if (git('ls-tree', object, '--', POLICY.policyPath) !==
        `100644 blob ${POLICY.policyBlob}\t${POLICY.policyPath}`)
      return refuse('PROCESS_EKRANY_POLICY');
    return { kind: 'pass' };
  } catch {
    return refuse('PROCESS_EKRANY_NEDOSTUPEN');
  }
}
