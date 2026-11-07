#!/usr/bin/env python3
"""The launched file has no post-gate work; its imported helper does."""
import sys

from kletka_v_chuzhom_fajle import forward_gate_then_cell

sys.exit(forward_gate_then_cell(sys.argv[1], sys.argv[2]))
