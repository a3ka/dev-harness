// Расширение omp: на tool_result с isError=true вызывает scripts/draft_nabludenia.sh
// для записи черновика наблюдения.
//
// Контракт 015, механизм 2 (Н-62-ядро). Тонкая обёртка — авто-дискавери omp,
// своё не проектируем. Регистрирует РОВНО ОДИН handler на tool_result:
//   - для bash-результата с isError=true вызывает scripts/draft_nabludenia.sh
//     (путь — относительно своего файла, ../../scripts/draft_nabludenia.sh);
//   - isError=false → вызова нет.
// Фильтр гейт-паттерна — В скрипте (единственный источник), расширение его
// НЕ дублирует. Падение/отказ скрипта handler проглатывает (fail-open:
// расширение в общем процессе, не имеет права ломать работу).

import { execFile } from 'node:child_process';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = dirname(fileURLToPath(import.meta.url));
const DRAFTER = resolve(HERE, '..', '..', 'scripts', 'draft_nabludenia.sh');

type ToolResultContentPiece = { readonly text?: unknown };

function isObject(v: unknown): v is Record<string, unknown> {
  return typeof v === 'object' && v !== null;
}

function isToolResultContentPiece(v: unknown): v is ToolResultContentPiece {
  return isObject(v);
}

export default function register(pi: unknown): void {
  if (!isObject(pi) || typeof pi.on !== 'function') return;
  const on = pi.on;

  on.call(pi, 'tool_result', (result: unknown) => {
    if (!isObject(result)) return;
    if (result.isError !== true) return;
    if (result.tool !== 'bash') return;

    let text = '';
    if (Array.isArray(result.content)) {
      for (const c of result.content) {
        if (!isToolResultContentPiece(c)) continue;
        if (typeof c.text === 'string') {
          text += (text ? '\n' : '') + c.text;
        }
      }
    }

    const nl = text.indexOf('\n');
    const command = nl === -1 ? text : text.slice(0, nl);
    const failHead = nl === -1 ? '' : text.slice(nl + 1);

    try {
      execFile(DRAFTER, [command.trim(), failHead], () => { /* fail-open: игнор */ });
    } catch { /* fail-open: расширение не валит процесс */ }
  });
}
