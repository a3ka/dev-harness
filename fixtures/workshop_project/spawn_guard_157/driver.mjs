import { pathToFileURL } from 'node:url';

const [guard, sessionFile, taskInput, doorResult] = process.argv.slice(2);
process.env.PROBE_DOOR_RESULT = doorResult;
const module = await import(pathToFileURL(guard).href);
let handler;
module.default({ on: (name, callback) => {
  if (name === 'tool_call') handler = callback;
} });
if (typeof handler !== 'function') throw new Error('tool_call handler absent');
const event = { toolName: 'task', input: JSON.parse(taskInput) };
const verdict = await handler(event, { sessionManager: { getSessionFile: () => sessionFile } });
console.log(JSON.stringify(verdict === undefined ? { pass: true } : verdict));
