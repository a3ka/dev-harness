#!/usr/bin/env python3
"""Independent public-door probes for the 187 cutover. Synthetic projects own their .git.

v2 (contract 187/2): two toy grammars. `legacy` answers locate with a bare component id
(the 170/187-1 fixture world); `realshape` mirrors the REAL CompliorOS-architecture CLI:
multi-line JSON locate with matches[].components, full JSON check body whose GREEN answer
still carries "status": "NOT_EVALUATED" (implementation evidence, not a verdict), brief
delivered only through the package script (npm run), and package-lock semantics for
dependencies. Expected answers are immutable tuples in the verifier, never read back from
the subject. Mutation is one named coordinate at a time; each mutant is paired with its OWN
red case (Н-39: stub-to-branch binding lives in this code, not in contract prose).
v2-r1 (critic verdict, block 1): union of matches[].components over several matches and
several components in one match, ARCH_CLASS_MISSING on the make_task/done doors, and
ARCH_PIN for a correct 40-hex absent from the clone — each with its own cell and stub."""
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile

from probe import world, put, git, run, CONTRACT, REVIEW, TOOLS
from ci_wiring import BATTERY, DIRECT

CASES = (
    ('task-valid', 'task', '', 0, '', 'task'),
    ('task-line-missing', 'task', 'line-missing', 1, 'ARCH_LINE_MISSING', 'task'),
    ('task-line-blank', 'task', 'line-blank', 1, 'ARCH_LINE_MISSING', 'task'),
    ('task-l3', 'task', 'l3', 1, 'ARCH_OWNER', 'task'),
    ('task-unmapped', 'task', 'unmapped', 1, 'PATH_WITHOUT_COMPONENT', 'task'),
    ('brief-lock', 'task', 'brief-lock', 0, '', 'task'),
    ('brief-no-local-copy', 'task', 'no-local', 0, '', 'task'),
    ('brief-with-rules', 'task', 'with-rules', 0, '', 'task'),
    ('brief-no-rules', 'task', 'no-rules', 0, '', 'task'),
    ('freeze-valid', 'freeze', '', 0, '', 'freeze'),
    ('freeze-no-line', 'freeze', 'freeze-no-line', 1, 'ARCH_LINE_MISSING', 'freeze'),
    ('freeze-foreign', 'freeze', 'foreign', 1, 'ARCH_ZONE', 'freeze'),
    ('freeze-unmapped', 'freeze', 'unmapped', 1, 'PATH_WITHOUT_COMPONENT', 'freeze'),
    ('freeze-draft', 'freeze', 'draft', 1, 'ARCH_DRAFT', 'freeze'),
    ('freeze-draft-marker', 'freeze', 'draft-marker', 1, 'ARCH_DRAFT', 'freeze'),
    ('freeze-draft-schema', 'freeze', 'draft-schema', 1, 'ARCH_DRAFT', 'freeze'),
    ('check-valid', 'precritic', '', 0, '', 'precritic'),
    ('check-failure', 'precritic', 'check-1', 1, 'ARCH_CHECK', 'precritic'),
    ('check-not-evaluated', 'precritic', 'check-2', 1, 'ARCH_NOT_EVALUATED', 'precritic'),
    ('check-digest-mismatch', 'precritic', 'digest-mismatch', 1, 'ARCH_CHECK', 'precritic'),
    ('done-valid', 'done', '', 0, '', 'done'),
    ('done-review-missing', 'done', 'review-missing', 1, 'ARCH_REVIEW', 'done'),
    ('done-ci-missing', 'done', 'ci-missing', 1, 'ARCH_CI', 'done'),
    ('done-ci-other-sha', 'done', 'ci-other-sha', 1, 'ARCH_CI', 'done'),
    ('done-ci-red', 'done', 'ci-red', 1, 'ARCH_CI', 'done'),
    ('done-ci-skipped', 'done', 'ci-skipped', 1, 'ARCH_CI', 'done'),
    ('done-ci-head-ahead', 'done', 'ci-head-ahead', 1, 'ARCH_CI', 'done'),
    ('legacy-mob', 'freeze', 'mobile', 0, '', 'freeze'),
    ('legacy-harness', 'freeze', 'harness', 0, '', 'freeze'),
    ('wiring-valid', 'wiring', 'wiring-valid', 0, '', 'wiring'),
    ('wiring-omitted', 'wiring', 'wiring-omitted', 1, 'CI_BATTERY_187_MISSING_OR_NOT_EXACT', 'wiring'),
    ('wiring-no-repo', 'wiring', 'wiring-no-repo', 1, 'CI_BATTERY_187_MISSING_OR_NOT_EXACT', 'wiring'),
    ('wiring-python', 'wiring', 'wiring-python', 1, 'CI_BATTERY_187_MISSING_OR_NOT_EXACT', 'wiring'),
    ('wiring-direct-missing', 'wiring', 'wiring-direct-missing', 1, 'CI_DIRECT_ARCH_187_MISSING', 'wiring'),
    # ── v2: дверь на настоящей модели (контракт 187/2) ──────────────────────────
    ('locate-json-conform', 'freeze', 'real-valid', 0, '', 'freeze'),
    ('locate-json-foreign', 'freeze', 'real-foreign', 1, 'компоненту api.billing', 'freeze'),
    ('zone-comma-list', 'freeze', 'real-comma', 0, '', 'freeze'),
    ('path-unplaced-product', 'freeze', 'real-unplaced', 1, 'PATH_WITHOUT_COMPONENT', 'freeze'),
    ('check-green-status-field', 'precritic', 'real-status', 0, '', 'precritic'),
    ('brief-npm-doorway', 'task', 'real-brief', 0, '', 'task'),
    ('pin-symbolic', 'freeze', 'pin-symbolic', 1, 'ARCHITECTURE_NET', 'freeze'),
    ('pin-lock-empty', 'freeze', 'pin-empty', 1, 'ARCHITECTURE_NET', 'freeze'),
    ('model-root-unset', 'door', 'root-unset', 1, 'ARCHITECTURE_NET', 'door'),
    ('deps-door-refusal', 'door', 'real-deps', 2, 'ARCH_DEPS', 'door'),
    ('precritic-full-zone', 'precritic', 'precritic-foreign', 1, 'ARCH_ZONE', 'precritic'),
    ('precritic-line-missing', 'precritic', 'precritic-no-line', 1, 'ARCH_LINE_MISSING', 'precritic'),
    ('precritic-draft', 'precritic', 'precritic-draft', 1, 'ARCH_DRAFT', 'precritic'),
    ('freeze-class-missing', 'freeze', 'class-missing', 1, 'ARCH_CLASS_MISSING', 'freeze'),
    ('precritic-class-missing', 'precritic', 'class-missing', 1, 'ARCH_CLASS_MISSING', 'precritic'),
    ('operation-optional', 'freeze', 'operation-optional', 0, '', 'freeze'),
    ('component-required-no-local', 'task', 'component-required', 1, 'ARCH_COMPONENT_NET', 'task'),
    ('live-real-pin', 'door', 'live-real', 0, 'ARCH_187A_OK', 'door'),
    # ── v2-r1: три обязательства без различающей клетки (вердикт критика, блок 1) ──
    ('locate-union-conform', 'freeze', 'union-conform', 0, '', 'freeze'),
    ('locate-union-foreign', 'freeze', 'union-foreign', 1, 'компоненту api.hub', 'freeze'),
    ('live-real-union', 'door', 'live-real-union', 0, 'ARCH_187A_OK', 'door'),
    ('task-class-missing', 'task', 'class-missing', 1, 'ARCH_CLASS_MISSING', 'task'),
    ('done-class-missing', 'done', 'class-missing', 1, 'ARCH_CLASS_MISSING', 'done'),
    ('pin-foreign-hex', 'freeze', 'pin-foreign-hex', 1, 'ARCH_PIN', 'freeze'),
)
STABS = {
    'task-no-line': ('task-line-missing', 'allow-line'),
    'task-blank-accepted': ('task-line-blank', 'allow-line'),
    'structure-dropped': ('task-valid', 'omit-structure'),
    'obsolete-doc-reintroduced': ('task-valid', 'include-old-doc'),
    'task-l3-auto': ('task-l3', 'allow-l3'),
    'task-unmapped-path': ('task-unmapped', 'allow-unmapped'),
    'brief-from-head': ('brief-lock', 'use-head'),
    'brief-requires-local-copy': ('brief-no-local-copy', 'requires-local'),
    'brief-rules-omitted': ('brief-with-rules', 'omit-rules'),
    'brief-rules-leaked': ('brief-no-rules', 'leak-rules'),
    'zone-foreign': ('freeze-foreign', 'allow-zone'),
    'zone-unmapped': ('freeze-unmapped', 'allow-zone'),
    'freeze-line-ignored': ('freeze-no-line', 'allow-zone'),
    'draft-operation': ('freeze-draft', 'allow-draft'),
    'draft-spaced-token-only': ('freeze-draft-marker', 'draft-spaced-only'),
    'draft-schemas-ignored': ('freeze-draft-schema', 'draft-id-only'),
    'check-not-called': ('check-failure', 'skip-check'),
    'check-rc-ignored': ('check-not-evaluated', 'rc2-green'),
    'check-base-without-snapshot': ('check-valid', 'bare-base'),
    'check-digest-omitted': ('check-valid', 'omit-digest'),
    'check-digest-self-computed': ('check-digest-mismatch', 'self-digest'),
    'reviewer-line-ignored': ('done-review-missing', 'ignore-review'),
    'ci-not-read': ('done-ci-missing', 'ignore-ci'),
    'ci-sha-ignored': ('done-ci-other-sha', 'ignore-ci'),
    'ci-conclusion-ignored': ('done-ci-red', 'ignore-ci'),
    'ci-skipped-green': ('done-ci-skipped', 'ignore-ci'),
    'ci-sha-from-origin-ref': ('done-ci-head-ahead', 'sha-from-origin-ref'),
    'mob-required': ('legacy-mob', 'require-all'),
    'harness-required': ('legacy-harness', 'require-all'),
    'ci-step-omitted': ('wiring-omitted', 'ignore-wiring'),
    'ci-step-without-repo': ('wiring-no-repo', 'ignore-wiring'),
    'ci-step-python-instead': ('wiring-python', 'ignore-wiring'),
    'ci-direct-replaced-by-battery': ('wiring-direct-missing', 'ignore-wiring'),
    # ── v2 стабы: каждая ветвь — своей клетке (Н-39) ────────────────────────────
    'locate-first-line-json': ('locate-json-conform', 'locate-first-line'),
    'zone-comma-unsplit': ('zone-comma-list', 'comma-unsplit'),
    'zone-disk-heuristic': ('path-unplaced-product', 'disk-heuristic'),
    'check-not-evaluated-substring': ('check-green-status-field', 'status-substring'),
    'deps-refusal-green': ('deps-door-refusal', 'deps-green'),
    'deps-named-not-evaluated': ('deps-door-refusal', 'deps-not-evaluated'),
    'brief-node-direct': ('brief-npm-doorway', 'brief-node'),
    'pin-symbolic-resolved': ('pin-symbolic', 'pin-head-allowed'),
    'pin-net-old-name': ('pin-lock-empty', 'old-pin-name'),
    'root-unset-old-name': ('model-root-unset', 'old-pin-name'),
    'class-missing-skip': ('freeze-class-missing', 'class-skip'),
    'precritic-class-skip': ('precritic-class-missing', 'class-skip'),
    'precritic-model-only': ('precritic-full-zone', 'precritic-model-only'),
    'precritic-model-only-line': ('precritic-line-missing', 'precritic-model-only'),
    'precritic-model-only-draft': ('precritic-draft', 'precritic-model-only'),
    'operation-required': ('operation-optional', 'operation-required'),
    'applicability-local-dir': ('component-required-no-local', 'local-dir-only'),
    # ── v2-r1 стабы: ветви двери по коду (Н-39), каждая — своей клетке ──────────
    'locate-first-match-component': ('locate-union-conform', 'first-match-component'),
    'union-any-component': ('locate-union-foreign', 'union-any-component'),
    'task-class-skip': ('task-class-missing', 'class-skip'),
    'done-class-skip': ('done-class-missing', 'class-skip'),
    'pin-net-for-hex': ('pin-foreign-hex', 'pin-net-name'),
}

# Approved snapshot inside the pinned tree (2.5.x layout of the real model, as run-arch.js
# and verify-pin.js read it); the lock names it by canonical digest, format 167.
SNAPSHOT = 'governance/baseline/approved.json'
CHECK_OPTIONS = ('model', 'report', 'strict', 'base', 'base-digest')

# Real model pin, snapshot №4 (measured on the station 2026-11-11): the live cell judges
# the door against the REAL CompliorOS-architecture clone, no secrets involved.
REAL_PIN_ENV = 'ARCH187_REAL_ROOT'
REAL_PIN = 'bfc3f45996fa9ec1db3b7ba79158071cb9e89d63'
REAL_DIGEST = '28858bc8743c411485f50aa86db470f6dfd0032a1daa16664f5f7d5ec26c5200'

# Variations whose toy model speaks the real-CLI grammar (multi-line JSON locate,
# package-script brief, package-lock dependency semantics).
REAL_VARIATIONS = frozenset((
    'real-valid', 'real-foreign', 'real-comma', 'real-unplaced', 'real-status',
    'real-brief', 'real-deps', 'live-real', 'live-real-union',
    'union-conform', 'union-foreign'))

# Union world (v2-r1, блок 1(a) вердикта): the real CLI can answer SEVERAL matches
# with SEVERAL components in one match (observed at the pin: server/src/handlers/x.js
# → one match with ["gateway.effects","documents.coordinator"]). Single source: the
# toy CLI bytes and the verifier's honest control both read these constants.
UNION_PREFIX = 'app/multi/'
UNION_MATCHES = (
    {'module': 'module.gateway', 'components': ['api.hub'],
     'specification': 'app/multi/gateway.js', 'explicit': False, 'matched': 'app/multi/'},
    {'module': 'module.handlers', 'components': ['api.documents', 'api.effects'],
     'specification': 'app/multi/handlers.js', 'explicit': False, 'matched': 'app/multi/'},
)

# A syntactically correct 40-hex that exists in NO clone (v2-r1, блок 1(c)):
# the door must name ARCH_PIN for it, not ARCHITECTURE_NET.
FOREIGN_HEX = 'deadbeefdeadbeefdeadbeefdeadbeefdeadbeef'


def digest(value):
    """Canonical SHA-256 of the real model: sorted keys, JSON.stringify bytes."""
    return hashlib.sha256(json.dumps(value, sort_keys=True, separators=(',', ':'),
                                     ensure_ascii=False).encode()).hexdigest()


def snapshot(number):
    return {'format': 'toy-architecture-baseline/1', 'snapshot': number,
            'components': ['api.identity'] + (['api.billing'] if number > 1 else [])}


def placed(path):
    """Placement map of the toy model (both grammars place identically): one component
    per product prefix; '' — the model does not place the path."""
    if path.startswith('app/identity/'):
        return 'api.identity'
    if path.startswith('app/billing/'):
        return 'api.billing'
    return ''

def placed_components(path):
    """Ordered union of matches[].components over ALL matches — the verifier's own
    reading of the real-CLI grammar (contract §«Размещение путей» v2). The union
    world is fed from UNION_MATCHES, the single source shared with the toy CLI."""
    if path.startswith(UNION_PREFIX):
        union = []
        for match in UNION_MATCHES:
            for component in match['components']:
                if component not in union:
                    union.append(component)
        return union
    single = placed(path)
    return [single] if single else []


def line_components(text):
    """Component ids of the «АРХИТЕКТУРА:» line, split by commas (v2: two-component
    lines are conform). None — no line; [] — empty list."""
    for line in text.splitlines():
        if line.startswith('АРХИТЕКТУРА: L'):
            rest = line[len('АРХИТЕКТУРА:'):].strip()
            ids = rest.split(' ', 1)[1] if ' ' in rest else ''
            return [i for i in ids.split(',') if i]
    return None


def toy_check(arch, revision, args):
    """Verifier's own reading of the real CLI `check` grammar (cli.js parseArguments,
    baseline.js inspectBaseline): a flag without value is MISSING_OPTION_VALUE rc 1,
    no snapshot or digest is NOT_EVALUATED rc 2, a foreign digest is rc 1."""
    options, i = {}, 0
    while i < len(args):
        key = args[i][2:] if args[i].startswith('--') else ''
        if key not in CHECK_OPTIONS:
            return 1, 'UNSUPPORTED_OPTION'
        if key == 'strict':
            options[key], i = True, i + 1
            continue
        value = args[i + 1] if i + 1 < len(args) else ''
        if not value or value.startswith('--'):
            return 1, 'MISSING_OPTION_VALUE'
        options[key], i = value, i + 2
    if not options.get('base') or not options.get('base-digest'):
        return 2, 'NOT_EVALUATED'
    if digest(json.loads(git(arch, 'show', f'{revision}:{options["base"]}'))) != options['base-digest']:
        return 1, 'BASELINE_DIGEST_MISMATCH'
    status = int(git(arch, 'show', revision + ':check-rc'))
    return status, 'NOT_EVALUATED' if status == 2 else ''


def drafted(line, mutant):
    """DRAFT is the case-insensitive token `draft` at a word boundary anywhere in the
    operation line: id, input schema, output schema, or an annotation."""
    if mutant == 'draft-spaced-only':
        op_id = line[len('ОПЕРАЦИЯ:'):].split(';')[0].strip().lower()
        return op_id == 'draft' or op_id.endswith('.draft') or ' DRAFT ' in f' {line} '
    field = line.split(';')[0] if mutant == 'draft-id-only' else line
    return re.search(r'(?<!\w)draft(?!\w)', field, re.I) is not None


# Toy CLI of the legacy grammar: locate answers with a BARE component id (170/187-1
# fixture worlds; v2 keeps them green — старые клетки не ослабляются). app/billing/**
# is placed into api.billing so the «foreign» case is an honest model placement, not a
# disk-existence heuristic (С2 removed).
TOY_CLI_LEGACY = '''const fs=require('fs');
const a=process.argv.slice(2); const name=a[0];
if (name==='brief') {
 const id=a[a.indexOf('--component')+1];
 if(id!=='api.identity'&&id!=='api.billing') process.exit(1);
 console.log('PINNED_BRIEF_187 '+id);
 if(a.includes('--with-rules')) console.log('RULES_FROM_PIN_187 semanticInvariant: no second writer; scope_id fixed');
} else if(name==='locate') {
 const p=a[a.indexOf('--path')+1];
 if(p.startsWith('app/identity/')) console.log('api.identity');
 else if(p.startsWith('app/billing/')) console.log('api.billing');
 else { console.error('PATH_WITHOUT_COMPONENT'); process.exit(1); }
} else if(name==='check') {
 const allowed=['model','report','strict','base','base-digest']; const o={};
 const out=(status,code,rc)=>{console.log(JSON.stringify({status,findings:code?[{code}]:[]}));process.exit(rc);};
 for(let i=1;i<a.length;i++){
  const f=a[i]; const k=f.startsWith('--')?f.slice(2):'';
  if(!allowed.includes(k)) out('FAIL','UNSUPPORTED_OPTION',1);
  if(k==='strict'){o[k]=true;continue;}
  const v=a[++i]; if(!v||v.startsWith('--')) out('FAIL','MISSING_OPTION_VALUE',1);
  o[k]=v;
 }
 if(!o.base||!o['base-digest']) out('NOT_EVALUATED','',2);
 const canon=v=>Array.isArray(v)?v.map(canon):(!v||typeof v!=='object')?v:Object.fromEntries(Object.keys(v).sort().map(k=>[k,canon(v[k])]));
 const d=require('crypto').createHash('sha256').update(JSON.stringify(canon(JSON.parse(fs.readFileSync(o.base,'utf8'))))).digest('hex');
 if(d!==o['base-digest']) out('FAIL','BASELINE_DIGEST_MISMATCH',1);
 const status=fs.readFileSync('check-rc','utf8').trim();
 if(status==='2') console.log('NOT_EVALUATED');
 process.exit(Number(status));
} else process.exit(2);
'''

# Toy CLI of the REAL grammar (С1): locate prints pretty multi-line JSON with
# matches[].components; the GREEN check answer still carries "status": "NOT_EVALUATED"
# plus requiredModelGate PASS (exactly the real CLI at the pin — measured); brief is a
# PACKAGE-SCRIPT interface: it answers only under npm run (npm_lifecycle_event), the
# grammar 170 v2 prescribes for the door.
TOY_CLI_REAL = '''const fs=require('fs');
const a=process.argv.slice(2); const name=a[0];
const UNION=__UNION_MATCHES__;
const where=p=>p.startsWith('app/identity/')?'api.identity':p.startsWith('app/billing/')?'api.billing':'';
if (name==='brief') {
 if(process.env.npm_lifecycle_event!=='brief'){console.error('BRIEF_NOT_A_PACKAGE_RUN');process.exit(1);}
 const id=a[a.indexOf('--component')+1];
 if(id!=='api.identity'&&id!=='api.billing') process.exit(1);
 console.log('PINNED_BRIEF_187 '+id);
 if(a.includes('--with-rules')) console.log('RULES_FROM_PIN_187 semanticInvariant: no second writer; scope_id fixed');
} else if(name==='locate') {
 const p=a[a.indexOf('--path')+1];
 if(p.startsWith('__UNION_PREFIX__')){
  console.log(JSON.stringify({scope:'DECLARED_PLACEMENT_ONLY',path:p,status:'DECLARED',matches:UNION,implementationEvidence:'NOT_ASSESSED'},null,2));
 } else {
 const c=where(p);
 const dir=p.slice(0,p.lastIndexOf('/')+1);
 const mod='module.'+dir.split('/').filter(Boolean).join('.');
 const body=c?{scope:'DECLARED_PLACEMENT_ONLY',path:p,status:'DECLARED',matches:[{module:mod,components:[c],specification:dir+'module.js',explicit:false,matched:dir}],implementationEvidence:'NOT_ASSESSED'}:{scope:'DECLARED_PLACEMENT_ONLY',path:p,status:'UNRESOLVED',matches:[],implementationEvidence:'NOT_ASSESSED'};
 console.log(JSON.stringify(body,null,2));
 if(!c) process.exit(1);
 }
} else if(name==='check') {
 const allowed=['model','report','strict','base','base-digest']; const o={};
 const out=(status,code,rc)=>{console.log(JSON.stringify({status,findings:code?[{code}]:[]},null,2));process.exit(rc);};
 for(let i=1;i<a.length;i++){
  const f=a[i]; const k=f.startsWith('--')?f.slice(2):'';
  if(!allowed.includes(k)) out('FAIL','UNSUPPORTED_OPTION',1);
  if(k==='strict'){o[k]=true;continue;}
  const v=a[++i]; if(!v||v.startsWith('--')) out('FAIL','MISSING_OPTION_VALUE',1);
  o[k]=v;
 }
 if(!o.base||!o['base-digest']) out('NOT_EVALUATED','',2);
 const canon=v=>Array.isArray(v)?v.map(canon):(!v||typeof v!=='object')?v:Object.fromEntries(Object.keys(v).sort().map(k=>[k,canon(v[k])]));
 const d=require('crypto').createHash('sha256').update(JSON.stringify(canon(JSON.parse(fs.readFileSync(o.base,'utf8'))))).digest('hex');
 if(d!==o['base-digest']) out('FAIL','BASELINE_DIGEST_MISMATCH',1);
 const status=fs.readFileSync('check-rc','utf8').trim();
 if(status==='2') out('NOT_EVALUATED','',2);
 if(status==='1') out('FAIL','',1);
 console.log(JSON.stringify({status:'NOT_EVALUATED',requiredModelGate:'PASS',baselineStatus:'PASS',implementationEvidence:'NOT_ASSESSED',unresolved:[],findings:[],draftContracts:[]},null,2));
 process.exit(0);
} else process.exit(2);
'''
# The union placement is fed from the same python constants as the honest control
# (single source, no second grammar): the placeholders resolve before any write.
TOY_CLI_REAL = TOY_CLI_REAL.replace('__UNION_PREFIX__', UNION_PREFIX).replace(
    '__UNION_MATCHES__', json.dumps(UNION_MATCHES, separators=(',', ':')))

TOY_PACKAGE_LOCK = json.dumps({
    'name': 'toy-real-architecture', 'version': '1.0.0', 'lockfileVersion': 3,
    'requires': True, 'packages': {'': {'name': 'toy-real-architecture',
                                        'version': '1.0.0', 'dependencies': {}}}})


def architecture(base, root, variation):
    """A separate git repository with A pinned and a later, deliberately different B HEAD.
    v2: the toy speaks the real-CLI grammar for REAL_VARIATIONS, legacy otherwise."""
    arch = base / (root.name + '-model')
    arch.mkdir()
    git(arch, 'init', '-q', '-b', 'main')
    git(arch, 'config', 'user.name', 'Fixture')
    git(arch, 'config', 'user.email', 'fixture@local')
    git(arch, 'config', 'commit.gpgsign', 'false')
    put(arch, 'package.json', json.dumps({'scripts': {'brief': 'node tooling/checks/cli.js brief',
                                                       'check': 'node tooling/checks/cli.js check'}}))
    cli = TOY_CLI_REAL if variation in REAL_VARIATIONS else TOY_CLI_LEGACY
    put(arch, 'tooling/checks/cli.js', cli)
    if variation == 'real-deps':
        # Dependency semantics of the real pin: package-lock committed, node_modules NOT
        # in the tree; an honest door must npm ci (a stub npm on PATH fails it).
        put(arch, 'package-lock.json', TOY_PACKAGE_LOCK)
    put(arch, 'check-rc', (variation[-1] if variation in ('check-1', 'check-2') else '0') + '\n')
    put(arch, SNAPSHOT, json.dumps(snapshot(1)))
    git(arch, 'add', '-A')
    git(arch, 'commit', '-qm', 'published architecture')
    pinned = git(arch, 'rev-parse', 'HEAD')
    put(arch, 'tooling/checks/cli.js', cli.replace('PINNED_BRIEF_187', 'WRONG_HEAD_BRIEF_187').replace('RULES_FROM_PIN_187', 'WRONG_HEAD_RULES_187'))
    put(arch, SNAPSHOT, json.dumps(snapshot(2)))
    git(arch, 'add', '-A')
    git(arch, 'commit', '-qm', 'unpublished later architecture')
    # Lock format of backend 167: the digest names the approved snapshot, not the commit's
    # HEAD; digest-mismatch names B's snapshot while the commit stays A.
    lock = {'format': 'complioros-architecture-pin/1', 'repository': 'a3ka/CompliorOS-architecture',
            'snapshot': 1, 'status': 'APPROVED',
            'snapshotDigest': digest(snapshot(2 if variation == 'digest-mismatch' else 1)),
            'workItem': 'COMPLIOR-777'}
    if variation == 'pin-symbolic':
        lock['commit'] = 'HEAD'
    elif variation == 'pin-empty':
        pass  # no .commit at all: there is nothing pinned
    elif variation == 'pin-foreign-hex':
        lock['commit'] = FOREIGN_HEX  # correct 40-hex that exists in no clone
    elif variation in ('live-real', 'live-real-union'):
        lock['commit'] = REAL_PIN
        lock['snapshotDigest'] = REAL_DIGEST
        lock['snapshot'] = 4
    else:
        lock['commit'] = pinned
    put(root, 'architecture.lock.json', json.dumps(lock))
    return arch, pinned


def ci_bin(root):
    return root.parent / (root.name + '-bin')


def npm_bin(root):
    """PATH dir with a broken npm: the honest door's `npm ci` must turn into ARCH_DEPS."""
    directory = root.parent / (root.name + '-npm-bin')
    directory.mkdir()
    stub = directory / 'npm'
    stub.write_text('#!/usr/bin/env bash\nexit 1\n')
    stub.chmod(0o755)
    return directory


def ci_record(root):
    return root.parent / (root.name + '-ci-187.json')


def drop_local_copy(root):
    for file in (root / 'architecture').rglob('*'):
        if file.is_file():
            file.unlink()
    for directory in sorted((root / 'architecture').rglob('*'), reverse=True):
        if directory.is_dir():
            directory.rmdir()
    (root / 'architecture').rmdir()


def prepare(root, arch, pinned, variation):
    if variation.startswith('wiring-'):
        commands = [BATTERY, DIRECT]
        if variation == 'wiring-omitted': commands.remove(BATTERY)
        if variation == 'wiring-no-repo': commands[0] = BATTERY.removesuffix(' --repo .')
        if variation == 'wiring-python': commands[0] = BATTERY.replace('bash fixtures/', 'python3 fixtures/', 1)
        if variation == 'wiring-direct-missing': commands.remove(DIRECT)
        put(root, 'registry/ci-steps.tsv', ''.join(
            f'step\tarch-187-{i}\t1\t{command}\n' for i, command in enumerate(commands)))
    role = 'implementer' if variation == 'no-rules' else 'architect'
    task = root / 'task-187.md'
    task.write_text('SUBJECT=777\nАРХИТЕКТУРА: L1 api.identity\nЗОНА implementer: app/identity/model.js\n')
    if variation in ('mobile', 'harness'):
        put(root, CONTRACT, (root / CONTRACT).read_text().replace('АРХИТЕКТУРА: L1 api.identity\n', ''))
    trace = root / 'trace-187.tsv'
    trace.write_text(role + '\tzai/glm-5.3\tallowed\n')
    # The check-run report is external to the subject repo and names the final SHA.
    record = {'total_count': 1, 'check_runs': [
        {'id': 187, 'name': 'arch', 'status': 'completed', 'conclusion': 'success'}]}
    if variation == 'line-missing':
        task.write_text(task.read_text().replace('АРХИТЕКТУРА: L1 api.identity\n', ''))
    elif variation == 'line-blank':
        task.write_text(task.read_text().replace('АРХИТЕКТУРА: L1 api.identity', 'АРХИТЕКТУРА: '))
    elif variation == 'no-local' or variation == 'component-required':
        drop_local_copy(root)
    elif variation == 'freeze-no-line':
        put(root, CONTRACT, (root / CONTRACT).read_text().replace('АРХИТЕКТУРА: L1 api.identity\n', ''))
    elif variation == 'l3':
        task.write_text(task.read_text().replace('L1 api.identity', 'L3 api.identity'))
    elif variation == 'unmapped':
        task.write_text(task.read_text().replace('app/identity/model.js', 'server/src/auth/evil.js'))
        put(root, CONTRACT, (root / CONTRACT).read_text().replace('app/identity/model.js', 'server/src/auth/evil.js'))
    elif variation == 'foreign':
        put(root, CONTRACT, (root / CONTRACT).read_text().replace('app/identity/model.js', 'app/billing/evil.js'))
        put(root, 'app/billing/evil.js', 'module.exports=2;\n')
    elif variation == 'draft':
        put(root, CONTRACT, (root / CONTRACT).read_text().replace('identity.lookup', 'identity.draft'))
    elif variation == 'draft-marker':
        put(root, CONTRACT, (root / CONTRACT).read_text().replace(
            'ОПЕРАЦИЯ: identity.lookup;', 'ОПЕРАЦИЯ: identity.lookup (DRAFT);'))
    elif variation == 'draft-schema':
        put(root, CONTRACT, (root / CONTRACT).read_text().replace('вход schema.query', 'вход schema.draft'))
    elif variation == 'review-missing':
        put(root, REVIEW, 'ACCEPT\nNote: СВЕРКА-АРХИТЕКТУРЫ: mentioned in a quote, not reported by reviewer\n')
    elif variation in ('real-valid', 'real-status', 'real-brief', 'real-deps'):
        pass  # конформный контракт реальной грамматики — мир уже готов
    elif variation == 'real-foreign':
        put(root, CONTRACT, (root / CONTRACT).read_text().replace('app/identity/model.js', 'app/billing/model.js'))
        put(root, 'app/billing/model.js', 'module.exports=2;\n')
    elif variation == 'real-comma':
        put(root, CONTRACT, (root / CONTRACT).read_text().replace(
            'АРХИТЕКТУРА: L1 api.identity', 'АРХИТЕКТУРА: L1 api.identity,api.billing'
        ).replace('app/identity/model.js', 'app/billing/model.js'))
        put(root, 'app/billing/model.js', 'module.exports=2;\n')
    elif variation == 'real-unplaced':
        # The file EXISTS in the product; the model does not place it — v2: disk
        # existence no longer turns PATH_WITHOUT_COMPONENT into ARCH_ZONE (С2).
        put(root, CONTRACT, (root / CONTRACT).read_text().replace('app/identity/model.js', 'server/src/auth/x.js'))
        put(root, 'server/src/auth/x.js', 'module.exports=3;\n')
    elif variation == 'precritic-foreign':
        put(root, CONTRACT, (root / CONTRACT).read_text().replace('app/identity/model.js', 'app/billing/evil.js'))
        put(root, 'app/billing/evil.js', 'x\n')
    elif variation == 'precritic-no-line':
        put(root, CONTRACT, (root / CONTRACT).read_text().replace('АРХИТЕКТУРА: L1 api.identity\n', ''))
    elif variation == 'precritic-draft':
        put(root, CONTRACT, (root / CONTRACT).read_text().replace(
            'ОПЕРАЦИЯ: identity.lookup;', 'ОПЕРАЦИЯ: identity.lookup (DRAFT);'))
    elif variation == 'class-missing':
        put(root, CONTRACT, (root / CONTRACT).read_text().replace('КЛАСС ЗАДАЧИ: кодовый.\n', ''))
    elif variation == 'operation-optional':
        put(root, CONTRACT, (root / CONTRACT).read_text().replace(
            'ОПЕРАЦИЯ: identity.lookup; вход schema.query; выход schema.record\n', ''))
    elif variation == 'live-real':
        contract = (root / CONTRACT).read_text()
        put(root, CONTRACT, contract.replace(
            'АРХИТЕКТУРА: L1 api.identity', 'АРХИТЕКТУРА: L1 api.auth'
        ).replace('app/identity/model.js', 'server/src/auth/delivery.js'))
        task.write_text('SUBJECT=777\nАРХИТЕКТУРА: L1 api.auth\nЗОНА implementer: server/src/auth/delivery.js\n')
        put(root, 'server/src/auth/delivery.js', 'module.exports=4;\n')
    elif variation in ('union-conform', 'union-foreign'):
        contract = (root / CONTRACT).read_text().replace('app/identity/model.js', 'app/multi/x.js')
        if variation == 'union-conform':
            # The line names a NON-first component of a NON-first match: honest door
            # is green (the union intersects), «first component of first match» is red.
            contract = contract.replace('АРХИТЕКТУРА: L1 api.identity', 'АРХИТЕКТУРА: L1 api.effects')
        put(root, CONTRACT, contract)
        put(root, 'app/multi/x.js', 'module.exports=5;\n')
    elif variation == 'live-real-union':
        # Observed at the pin: server/src/handlers/x.js is placed in TWO components
        # (gateway.effects, documents.coordinator); the line names the SECOND.
        contract = (root / CONTRACT).read_text()
        put(root, CONTRACT, contract.replace(
            'АРХИТЕКТУРА: L1 api.identity', 'АРХИТЕКТУРА: L1 documents.coordinator'
        ).replace('app/identity/model.js', 'server/src/handlers/x.js'))
        task.write_text('SUBJECT=777\nАРХИТЕКТУРА: L1 documents.coordinator\n'
                        'ЗОНА implementer: server/src/handlers/x.js\n')
        put(root, 'server/src/handlers/x.js', 'module.exports=6;\n')
    # CI report mutations happen after commit: the report must reference the final SHA.
    git(root, 'add', '-A')
    git(root, 'commit', '-qm', 'isolated scenario ' + (variation or 'valid'))
    if variation == 'no-rules':
        git(root, 'tag', 'frozen/contracts/777/1')
    record['check_runs'][0]['head_sha'] = git(root, 'rev-parse', 'HEAD')
    if variation == 'ci-missing': record = {'total_count': 0, 'check_runs': []}
    if variation == 'ci-other-sha': record['check_runs'][0]['head_sha'] = 'f' * 40
    if variation == 'ci-red': record['check_runs'][0]['conclusion'] = 'failure'
    if variation == 'ci-skipped': record['check_runs'][0]['conclusion'] = 'skipped'
    ci_record(root).write_text(json.dumps(record))
    git(root, 'push', '-q', 'origin', 'main')
    if variation == 'ci-head-ahead':
        # Local HEAD moves past origin/main after push; the green arch run stays on the old SHA.
        put(root, 'app/identity/model.js', 'module.exports = 3;\n')
        git(root, 'commit', '-qam', 'unpushed change after green arch')
    bin_dir = ci_bin(root)
    bin_dir.mkdir()
    fake_curl = bin_dir / 'curl'
    fake_curl.write_text('#!/usr/bin/env bash\n'
                         'case "${@: -1}" in *"/commits/"*"/check-runs?\"*) cat \"$ARCH187_CURL_RESPONSE\" ;; *) exit 31 ;; esac\n')
    fake_curl.chmod(0o755)
    return task, trace, role


def verdict_v2(root, arch, pinned, action, task, role, mutant, variation):
    """Honest control of the v2 cells: invariants of contract 187/2."""
    contract = (root / CONTRACT).read_text()
    if action == 'freeze':
        if variation == 'pin-symbolic':
            if mutant == 'pin-head-allowed':
                return 0, ''
            return 1, 'ARCHITECTURE_NET: lock не указывает на коммит архитектуры'
        if variation == 'pin-empty':
            if mutant == 'old-pin-name':
                return 1, 'ARCH_PIN: в architecture.lock.json нет закреплённого коммита'
            return 1, 'ARCHITECTURE_NET: нет закреплённого коммита'
        if variation == 'pin-foreign-hex':
            if mutant == 'pin-net-name':
                return 1, f'ARCHITECTURE_NET: коммит {FOREIGN_HEX} не разрешается в клоне модели'
            return 1, f'ARCH_PIN: коммит {FOREIGN_HEX} не разрешается в клоне модели'
        if variation == 'class-missing':
            if mutant == 'class-skip':
                return 0, ''
            return 1, 'ARCH_CLASS_MISSING: в контракте нет строки «КЛАСС ЗАДАЧИ:»'
        if variation == 'operation-optional':
            if mutant == 'operation-required':
                return 1, 'ARCH_DRAFT: предмет не объявляет операцию со схемами входа/выхода'
            return 0, ''
        if variation in ('real-valid', 'real-foreign', 'real-comma', 'real-unplaced'):
            ids = line_components(contract)
            path = next(line[len('ЗОНА implementer:'):].strip()
                        for line in contract.splitlines()
                        if line.startswith('ЗОНА implementer:'))
            comp = placed(path)
            if mutant == 'locate-first-line':
                comp = '{'  # первая строка многострочного JSON — не компонент
            if mutant == 'disk-heuristic' and not comp and (root / path).exists():
                return 1, f'ARCH_ZONE: путь {path} размещён в продукте, но модель не относит его к заявленному компоненту'
            if not comp:
                return 1, f'PATH_WITHOUT_COMPONENT: путь {path} не размещён в закреплённой модели'
            if mutant == 'comma-unsplit':
                return 1, (f'ARCH_ZONE: путь {path} отнесён моделью к компоненту {comp}, '
                           f'а строка «АРХИТЕКТУРА:» называет api.identity,api.billing')
            if comp not in ids:
                return 1, (f'ARCH_ZONE: путь {path} отнесён моделью к компоненту {comp}, '
                           f'а строка «АРХИТЕКТУРА:» называет {",".join(ids)}')
            return 0, ''
        if variation in ('union-conform', 'union-foreign'):
            ids = line_components(contract)
            path = next(line[len('ЗОНА implementer:'):].strip()
                        for line in contract.splitlines()
                        if line.startswith('ЗОНА implementer:'))
            union = placed_components(path)
            if mutant == 'first-match-component':
                union = union[:1]  # обман: только первый компонент первого матча
            if mutant == 'union-any-component':
                return 0, ''  # обман: размещённый путь зелён без сверки со строкой
            if not union:
                return 1, f'PATH_WITHOUT_COMPONENT: путь {path} не размещён в закреплённой модели'
            if not set(union) & set(ids):
                return 1, (f'ARCH_ZONE: путь {path} отнесён моделью к компоненту {union[0]}, '
                           f'а строка «АРХИТЕКТУРА:» называет {",".join(ids)}')
            return 0, ''
    if action == 'precritic':
        if variation == 'real-status':
            # Модель зелёная: rc 0, requiredModelGate PASS; поле status NOT_EVALUATED в
            # теле — не вердикт (подстрочный поиск — обман, стаб status-substring).
            if mutant == 'status-substring':
                return 1, 'ARCH_NOT_EVALUATED: check --base модели не вынес вердикта (rc=0)'
            return 0, ''
        if variation.startswith('precritic-'):
            if mutant == 'precritic-model-only':
                return 0, ''  # обман: только check, строка/зоны/операции не судятся
            if variation == 'precritic-no-line':
                return 1, 'ARCH_LINE_MISSING'
            if variation == 'precritic-draft':
                return 1, 'ARCH_DRAFT'
            return 1, 'ARCH_ZONE: путь app/billing/evil.js отнесён моделью к компоненту api.billing'
        if variation == 'class-missing':
            if mutant == 'class-skip':
                return 0, ''
            return 1, 'ARCH_CLASS_MISSING: в контракте нет строки «КЛАСС ЗАДАЧИ:»'
    if action == 'task':
        if variation == 'real-brief':
            if mutant == 'brief-node':
                return 1, 'ARCH_BRIEF_OTKAZ: api.identity (закреплённая модель не отдала бриф)'
            result = 'PINNED_BRIEF_187 api.identity\nRULES_FROM_PIN_187 semanticInvariant: no second writer; scope_id fixed'
            if mutant != 'omit-structure':
                result += '\nSTRUCTURE.md'
            return 0, result
        if variation == 'component-required':
            if mutant == 'local-dir-only':
                return 0, ''  # обман: применимость по локальному каталогу, а не по lock
            return 1, 'ARCH_COMPONENT_NET: требуется --arch-component (кодовый предмет, проект с закреплённой моделью)'
        if variation == 'class-missing':
            if mutant == 'class-skip':
                return 0, ''  # обман: бесклассовый черновик пропускается молча
            return 1, 'ARCH_CLASS_MISSING: в контракте нет строки «КЛАСС ЗАДАЧИ:»'
    if action == 'done':
        if variation == 'class-missing':
            if mutant == 'class-skip':
                return 0, ''  # обман: бесклассовый контракт молча проходит done
            return 1, 'ARCH_CLASS_MISSING: в контракте нет строки «КЛАСС ЗАДАЧИ:»'
    if action == 'door':
        if variation == 'root-unset':
            if mutant == 'old-pin-name':
                return 1, 'ARCH_PIN: закреплённый клон модели не задан (ARCHITECTURE_ROOT)'
            return 1, 'ARCHITECTURE_NET: нет репозитория архитектуры ARCHITECTURE_ROOT'
        if variation == 'real-deps':
            if mutant == 'deps-green':
                return 0, 'ARCH_187A_OK'  # обман: без зависимостей — зелёный
            if mutant == 'deps-not-evaluated':
                return 1, 'ARCH_NOT_EVALUATED: инструмент check --base не отработал'
            return 2, 'ARCH_DEPS: зависимости модели недоступны (npm ci --ignore-scripts)'
        if variation in ('live-real', 'live-real-union'):
            return 0, 'ARCH_187A_OK: архитектура сходится с закреплённой моделью'
    raise RuntimeError(f'unknown v2 disposition: {variation}/{action}')


def verdict(root, arch, pinned, action, task, role, mutant='', variation=''):
    if action == 'wiring':
        if mutant == 'ignore-wiring':
            return 0, ''
        if variation == 'wiring-omitted' or variation in ('wiring-no-repo', 'wiring-python'):
            return 1, 'CI_BATTERY_187_MISSING_OR_NOT_EXACT'
        if variation == 'wiring-direct-missing':
            return 1, 'CI_DIRECT_ARCH_187_MISSING'
        return 0, ''
    if variation in ('pin-symbolic', 'pin-empty', 'pin-foreign-hex', 'class-missing',
                     'operation-optional', 'component-required', 'live-real',
                     'live-real-union', 'root-unset') \
            or variation.startswith('real-') or variation.startswith('union-') \
            or variation.startswith('precritic-'):
        return verdict_v2(root, arch, pinned, action, task, role, mutant, variation)
    profile = json.loads((root / 'harness.project.json').read_text())
    if profile['repoId'] != 'Complior-back' and mutant != 'require-all':
        return 0, ''
    contract = (root / CONTRACT).read_text()
    if action == 'task':
        text = task.read_text()
        if (not any(line.startswith('АРХИТЕКТУРА: L1 ') or line.startswith('АРХИТЕКТУРА: L2 ')
                    or line.startswith('АРХИТЕКТУРА: L3 ') for line in text.splitlines())) and mutant != 'allow-line':
            return 1, 'ARCH_LINE_MISSING'
        if 'АРХИТЕКТУРА: L3 ' in text and mutant != 'allow-l3':
            return 1, 'ARCH_OWNER'
        if 'server/src/auth/' in text and mutant != 'allow-unmapped':
            return 1, 'PATH_WITHOUT_COMPONENT'
        revision = git(arch, 'rev-parse', 'HEAD') if mutant == 'use-head' else pinned
        if mutant == 'requires-local' and not (root / 'architecture').exists():
            return 1, 'ARCHITECTURE_NET'
        model = git(arch, 'show', revision + ':tooling/checks/cli.js')
        banner = 'PINNED_BRIEF_187' if 'PINNED_BRIEF_187' in model else 'WRONG_HEAD_BRIEF_187'
        result = banner + ' api.identity'
        needs_rules = role in ('architect', 'critic', 'arbiter')
        if mutant == 'omit-rules': needs_rules = False
        if mutant == 'leak-rules': needs_rules = True
        if needs_rules:
            result += '\nRULES_FROM_PIN_187 semanticInvariant: no second writer; scope_id fixed'
        if mutant != 'omit-structure': result += '\nSTRUCTURE.md'
        if mutant == 'include-old-doc': result += '\ndocs/ARCHITECTURE.md'
        return 0, result
    if action == 'freeze':
        if not any(line.startswith('АРХИТЕКТУРА: L1 ') for line in contract.splitlines()) and mutant not in ('allow-zone', 'require-all'):
            return 1, 'ARCH_LINE_MISSING'
        if any(drafted(line, mutant) for line in contract.splitlines()
               if line.startswith('ОПЕРАЦИЯ:')) and mutant != 'allow-draft':
            return 1, 'ARCH_DRAFT'
        if 'server/src/auth/' in contract and mutant != 'allow-zone':
            return 1, 'PATH_WITHOUT_COMPONENT'
        if 'app/billing/' in contract and mutant != 'allow-zone':
            return 1, 'ARCH_ZONE'
        return (1, 'ARCH_LINE_MISSING') if mutant == 'require-all' else (0, '')
    if action == 'precritic':
        lock = json.loads((root / 'architecture.lock.json').read_text())
        args = ['--base', SNAPSHOT, '--base-digest', lock['snapshotDigest']]
        if mutant == 'bare-base': args = ['--base']
        if mutant == 'omit-digest': args = ['--base', SNAPSHOT]
        if mutant == 'self-digest':
            args = ['--base', SNAPSHOT, '--base-digest',
                    digest(json.loads(git(arch, 'show', f'{pinned}:{SNAPSHOT}')))]
        check_rc, _ = toy_check(arch, pinned, args)
        if check_rc == 2 and mutant != 'rc2-green': return 1, 'ARCH_NOT_EVALUATED'
        if check_rc and mutant != 'skip-check': return 1, 'ARCH_CHECK'
        return 0, ''
    if action == 'done':
        if not any(line.startswith('СВЕРКА-АРХИТЕКТУРЫ:') and
                   line[len('СВЕРКА-АРХИТЕКТУРЫ:'):].strip()
                   for line in (root / REVIEW).read_text().splitlines()) and mutant != 'ignore-review':
            return 1, 'ARCH_REVIEW'
        response = json.loads(ci_record(root).read_text())
        runs = response['check_runs']
        arch_runs = [r for r in runs if r.get('name') == 'arch']
        final = git(root, 'rev-parse', 'refs/remotes/origin/main' if mutant == 'sha-from-origin-ref' else 'HEAD')
        if mutant != 'ignore-ci' and (not arch_runs or
                                      arch_runs[-1].get('head_sha') != final or
                                      arch_runs[-1].get('status') != 'completed' or
                                      arch_runs[-1].get('conclusion') != 'success'):
            return 1, 'ARCH_CI'
        return 0, ''
    if action == 'door':
        raise RuntimeError('door action is v2-only')
    raise RuntimeError('unknown action')


def live(tools, root, arch, pinned, action, task, trace, role, variation=''):
    env = {k: v for k, v in os.environ.items() if not k.startswith('GIT_')}
    env.update(GIT_CONFIG_GLOBAL='/dev/null', GIT_CONFIG_SYSTEM='/dev/null',
               HARNESS_PROJECT_LAYER_ROOT=str(root), ARCHITECTURE_ROOT=str(arch))
    if variation == 'root-unset':
        env.pop('ARCHITECTURE_ROOT', None)
    if variation in ('live-real', 'live-real-union'):
        env['ARCHITECTURE_ROOT'] = os.environ[REAL_PIN_ENV]
    if variation == 'real-deps':
        env['PATH'] = str(npm_bin(root)) + os.pathsep + env.get('PATH', '')
    if action == 'done':
        env['ARCH187_CURL_RESPONSE'] = str(ci_record(root))
        env['PATH'] = str(ci_bin(root)) + os.pathsep + env.get('PATH', '')
    if action == 'wiring':
        return run('bash', TOOLS / 'fixtures/workshop_project/architecture_process_187/red_architecture_process_187.sh',
                   '--wiring', root, cwd=root, env=env)
    if action == 'door':
        return run('bash', tools / 'scripts/check_architecture_contract.sh', '--repo', root,
                   CONTRACT, cwd=root, env=env)
    if action == 'task':
        command = ['bash', tools / 'scripts/make_task.sh', '--repo', root, '--role', role,
                   '--kind', 'task', '--contract', '777', '--task-file', task,
                   '--model-trace', trace]
        if variation != 'component-required':
            command += ['--arch-component', 'api.identity']
    else:
        command = {'freeze': ['bash', tools / 'scripts/freeze_contract.sh', CONTRACT, 'toy reason', root],
                   'precritic': ['bash', tools / 'scripts/pre_critic.sh', '--repo', root, CONTRACT],
                   'done': ['bash', tools / 'scripts/done_contract.sh', CONTRACT, 'toy reason', root]}[action]
    return run(*command, cwd=root, env=env)


def real_pin_available(clone):
    """The live cell's prerequisite: a local clone that resolves the snapshot №4 pin.
    Returns '' when fine; otherwise the named LIVE_PREDPOSYLKA reason (rc 2, не зелёный)."""
    if not clone:
        return f'{REAL_PIN_ENV} не задан'
    probe = subprocess.run(['git', '-C', str(clone), 'cat-file', '-e',
                            f'{REAL_PIN}^{{commit}}'], capture_output=True, text=True)
    if probe.returncode != 0:
        return f'клон {clone} не разрешает пин {REAL_PIN}'
    return ''


def main():
    import argparse
    p = argparse.ArgumentParser()
    modes = p.add_mutually_exclusive_group()
    modes.add_argument('--model', action='store_true')
    modes.add_argument('--stabs', action='store_true')
    modes.add_argument('--repo', type=Path)
    args = p.parse_args()
    tools = args.repo.resolve() if args.repo else TOOLS
    failures = []
    skipped = 0
    with tempfile.TemporaryDirectory(prefix='workflow-187-') as temp:
        base = Path(temp)
        for label, action, variation, expected, reason, _ in CASES:
            if label in ('live-real-pin', 'live-real-union') and not args.model and not args.stabs:
                obstacle = real_pin_available(os.environ.get(REAL_PIN_ENV, ''))
                if obstacle == '':
                    pass  # живая клетка исполняется
                elif obstacle.startswith(REAL_PIN_ENV):
                    print(f'SKIP {label}: {obstacle} — живая клетка не исполнялась (не зелёная)')
                    skipped += 1
                    continue
                else:
                    print(f'LIVE_PREDPOSYLKA: {obstacle}', file=sys.stderr)
                    return 2
            kind = 'mobile' if variation == 'mobile' else 'harness' if variation == 'harness' else 'backend'
            root = world(base, label, kind)
            arch, pinned = architecture(base, root, variation)
            task, trace, role = prepare(root, arch, pinned, variation)
            honest_rc, honest_out = verdict(root, arch, pinned, action, task, role, variation=variation)
            if honest_rc != expected or (reason and reason not in honest_out):
                raise RuntimeError(f'broken fixture: {label} expected {expected}/{reason}, got {honest_rc}/{honest_out}')
            if args.model or args.stabs:
                rc, output = honest_rc, honest_out
            else:
                result = live(tools, root, arch, pinned, action, task, trace, role, variation)
                rc, output = result.returncode, result.stdout + result.stderr
            ok = (rc == expected and (not reason or reason in output))
            if action == 'task' and not expected:
                if 'PINNED_BRIEF_187' not in output or 'WRONG_HEAD_BRIEF_187' in output:
                    ok = False
                if 'STRUCTURE.md' not in output or 'docs/ARCHITECTURE.md' in output:
                    ok = False
                if role == 'implementer' and 'RULES_FROM_PIN_187' in output:
                    ok = False
                if role in ('architect', 'critic', 'arbiter') and 'RULES_FROM_PIN_187' not in output:
                    ok = False
            if not args.model and not args.stabs and expected and action in ('freeze', 'done'):
                marker = 'frozen' if action == 'freeze' else 'done'
                if git(root, 'tag', '-l', marker + '/contracts/777/*'): ok = False
            if not ok: failures.append(label)
            print(f'{"GREEN" if ok else "RED"} {label}: rc={rc} expected={expected}' +
                  (f' reason={reason}' if reason else '') + (f' output={output[:350]!r}' if not ok else ''))
            if args.stabs:
                for name, (case, mutant) in STABS.items():
                    if case != label: continue
                    fake_rc, fake_out = verdict(root, arch, pinned, action, task, role, mutant, variation=variation)
                    caught = fake_rc != expected or (reason and reason not in fake_out)
                    if not expected and action == 'task':
                        caught = caught or ('PINNED_BRIEF_187' not in fake_out or
                            'WRONG_HEAD_BRIEF_187' in fake_out or
                            'STRUCTURE.md' not in fake_out or
                            'docs/ARCHITECTURE.md' in fake_out or
                            (role == 'implementer' and 'RULES_FROM_PIN_187' in fake_out) or
                            (role in ('architect', 'critic', 'arbiter') and 'RULES_FROM_PIN_187' not in fake_out))
                    print(f'STAB {name} {"caught" if caught else "ZHIV"} @ {label}')
                    if not caught: failures.append(name)
        print(f'CELLS={len(CASES)} STABS={len(STABS) if args.stabs else 0} '
              f'FAILURES={len(failures)} SKIPPED={skipped}')
    return int(bool(failures))


if __name__ == '__main__':
    raise SystemExit(main())
