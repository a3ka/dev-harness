#!/usr/bin/env python3
"""Extend provider 129's HTTP handler; all successful/tool traffic stays in 129."""
import io
import json
import runpy
import sys
from http.server import ThreadingHTTPServer

plan = json.load(open(sys.argv[2]))
original_init = ThreadingHTTPServer.__init__


def initialize(server, address, handler, *args, **kwargs):
    original_post = handler.do_POST

    def post(self):
        raw = self.rfile.read(int(self.headers.get('content-length') or 0))
        body = json.loads(raw)
        model = body.get('model', '')
        sib = plan['_sib_marker'] in json.dumps(body.get('messages', []))
        mode = plan['models'].get(model)
        if isinstance(mode, dict):
            mode = mode['sib' if sib else 'default']
        errors = {
            'flagged': (400, 'This content was flagged for possible cybersecurity risk'),
            'cyber': (400, 'cyber_policy'),
            'filter': (400, 'content_filter'),
            'short429': (429, 'temporary overload'),
            'other': (400, 'unrelated request error'),
            'near-token': (400, 'notcyber_policyx notcontent_filterx'),
        }
        if mode not in errors:
            self.rfile = io.BytesIO(raw)
            return original_post(self)
        status, message = errors[mode]
        marker = plan['_sib_marker'] if sib else plan['_marker']
        with open(sys.argv[3], 'a') as log:
            log.write(json.dumps({'model': model, 'sib': sib, 'status': mode,
                                  'turn': bool(body.get('tools'))}) + '\n')
        payload = json.dumps({'error': {'type': 'invalid_request_error',
                                      'message': message + ' [stub129 ' + marker + ']'}}).encode()
        self._json(status, payload, [('retry-after-ms', '1')] if status == 429 else ())

    handler.do_POST = post
    return original_init(server, address, handler, *args, **kwargs)


ThreadingHTTPServer.__init__ = initialize
runpy.run_path(plan['_provider_base'], run_name='__main__')
