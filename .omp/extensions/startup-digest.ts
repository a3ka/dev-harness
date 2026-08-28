// Расширение omp: на session_start вызывает scripts/nabludenia_digest.sh --for-session
// и шлёт РОВНО ОДИН sendMessage (deliverAs: "nextTurn") с выводом.
//
// Контракт 015, механизм 3 (Н-62-ядро). Тонкая обёртка — авто-дискавери omp.
// Скрипт упал → sendMessage с одной строкой «дайджест не собран» — процесс жив.

import { execFile } from 'node:child_process';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = dirname(fileURLToPath(import.meta.url));
const DIGEST = resolve(HERE, '..', '..', 'scripts', 'nabludenia_digest.sh');

function isObject(v: unknown): v is Record<string, unknown> {
  return typeof v === 'object' && v !== null;
}

export default function register(pi: unknown): void {
  if (!isObject(pi)) return;
  const on = pi.on;
  const send = pi.sendMessage;
  if (typeof on !== 'function' || typeof send !== 'function') return;

  on.call(pi, 'session_start', () => {
    try {
      execFile(DIGEST, ['--for-session'], { maxBuffer: 1024 * 1024 }, (err: Error | null, stdout: string) => {
        const text = err || !stdout ? 'дайджест не собран' : stdout;
        try {
          send.call(pi, text, { deliverAs: 'nextTurn' });
        } catch { /* fail-open: расширение не валит процесс */ }
      });
    } catch {
      try {
        send.call(pi, 'дайджест не собран', { deliverAs: 'nextTurn' });
      } catch { /* ignore */ }
    }
  });
}
