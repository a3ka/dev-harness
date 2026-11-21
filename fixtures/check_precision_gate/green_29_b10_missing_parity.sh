#!/usr/bin/env bash
# Б-10 (е): отсутствующий инструмент остаётся skip rc 2.
exec bash "$(dirname "${BASH_SOURCE[0]}")/_b10.sh" e
