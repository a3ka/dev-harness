#!/usr/bin/env python3
"""Run the real producer/reader; vary only its unavailable-refusal envelope."""
import subprocess
import sys

PREFIX = 'ОТКАЗ: ARCH_BRIEF_PIN: unavailable'.encode()
DETAIL = b': symbolic link loop'


def main():
    mode, *command = sys.argv[1:]
    result = subprocess.run(command, capture_output=True)
    rc, out, err = result.returncode, result.stdout, result.stderr
    lines = err.splitlines(keepends=True)
    # Never manufacture a named refusal for an unrelated failure or traceback.
    if rc == 1 and not out and lines and lines[0].startswith(PREFIX):
        lines[0] = lines[0].rstrip(b'\r\n') + DETAIL + b'\n'
        err = b''.join(lines)
        if mode == 'refusal_rc':
            rc = 17
        elif mode == 'refusal_stdout':
            out = b'PARTIAL-PACK\n'
        elif mode == 'refusal_no_prefix':
            err = b'symbolic link loop\n'
        elif mode == 'refusal_empty_stderr':
            err = b''
        elif mode == 'refusal_traceback':
            err = b'Traceback (most recent call last):\n' + err
        elif mode != 'explain':
            raise ValueError('unknown refusal mode: ' + mode)
    sys.stdout.buffer.write(out)
    sys.stderr.buffer.write(err)
    return rc


if __name__ == '__main__':
    sys.exit(main())
