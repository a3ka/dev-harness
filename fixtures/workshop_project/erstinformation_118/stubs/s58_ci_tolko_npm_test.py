#!/usr/bin/env python3
"""Dishonest same-run judge: a checker invocation is treated as sufficient.

On ci-bez-srok-testov and ci-staryj-otchet the checker sees stale/missing
report without a Jest run; on ci-bez-otcheta-sroka it runs before Jest.
"""

def verdict(events, rc):
    return 'checker' in events
