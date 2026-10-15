import json
import os
from http.server import BaseHTTPRequestHandler, HTTPServer

VERSION = os.environ.get("APP_VERSION", "dev")
ENVIRONMENT = os.environ.get("APP_ENV", "local")


class Handler(BaseHTTPRequestHandler):
    def _send(self, code, payload):
        body = json.dumps(payload).encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        if self.path == "/health":
            self._send(200, {"status": "ok"})
        elif self.path == "/":
            self._send(200, {
                "app": "demo-app",
                "version": VERSION,
                "environment": ENVIRONMENT,
            })
        else:
            self._send(404, {"error": "not found"})


if __name__ == "__main__":
    HTTPServer(("0.0.0.0", 8000), Handler).serve_forever()