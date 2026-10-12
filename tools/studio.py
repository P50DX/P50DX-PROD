"""Talk to Roblox Studio through StartStudioBridge.bat (Streamable HTTP MCP) from a cloud session.

    python3 tools/studio.py URL tools                      # list Studio's tools
    python3 tools/studio.py URL call TOOL '{"arg": 1}'     # call one tool with JSON arguments

URL is the bridge's tunnel address ending in /mcp. The MCP session id is cached in /tmp so repeated
calls reuse one Studio connection.
"""
import json, os, sys, urllib.request

SESSION_FILE = "/tmp/studio_mcp_session.json"


def _post(url, payload, sid=None):
    headers = {"Content-Type": "application/json", "Accept": "application/json, text/event-stream"}
    if sid:
        headers["Mcp-Session-Id"] = sid
    req = urllib.request.Request(url, data=json.dumps(payload).encode(), headers=headers, method="POST")
    with urllib.request.urlopen(req, timeout=120) as r:
        new_sid = r.headers.get("Mcp-Session-Id") or sid
        body = r.read().decode("utf-8", "replace")
    msgs = []
    for line in body.splitlines():                     # SSE framing: "data: {...}"
        if line.startswith("data:"):
            msgs.append(json.loads(line[5:].strip()))
    if not msgs and body.strip().startswith("{"):
        msgs.append(json.loads(body))
    return new_sid, msgs


def session(url):
    try:
        cached = json.load(open(SESSION_FILE))
        if cached.get("url") == url:
            return cached["sid"]
    except (OSError, ValueError):
        pass
    sid, _ = _post(url, {"jsonrpc": "2.0", "id": 1, "method": "initialize",
                         "params": {"protocolVersion": "2025-03-26", "capabilities": {},
                                    "clientInfo": {"name": "claude-cloud", "version": "1"}}})
    _post(url, {"jsonrpc": "2.0", "method": "notifications/initialized"}, sid)
    json.dump({"url": url, "sid": sid}, open(SESSION_FILE, "w"))
    return sid


def rpc(url, method, params=None):
    sid = session(url)
    try:
        _, msgs = _post(url, {"jsonrpc": "2.0", "id": 2, "method": method, "params": params or {}}, sid)
    except urllib.error.HTTPError as e:
        if e.code in (400, 404):                       # session expired: start a new one
            os.remove(SESSION_FILE)
            _, msgs = _post(url, {"jsonrpc": "2.0", "id": 2, "method": method, "params": params or {}}, session(url))
        else:
            raise
    for m in msgs:
        if m.get("id") == 2:
            return m
    return msgs


if __name__ == "__main__":
    url, cmd = sys.argv[1], sys.argv[2]
    if cmd == "tools":
        res = rpc(url, "tools/list")
        for t in res.get("result", {}).get("tools", []):
            print(f"- {t['name']}: {t.get('description', '').strip()[:200]}")
            print(f"    args: {json.dumps(t.get('inputSchema', {}).get('properties', {}))[:300]}")
    elif cmd == "call":
        args = json.loads(sys.argv[4]) if len(sys.argv) > 4 else {}
        res = rpc(url, "tools/call", {"name": sys.argv[3], "arguments": args})
        if "result" in res:
            for i, c in enumerate(res["result"].get("content", [])):
                if c.get("type") == "image":            # screenshots: save to a file
                    import base64
                    ext = c.get("mimeType", "image/png").split("/")[-1]
                    path = f"/tmp/studio_capture_{os.getpid()}_{i}.{ext}"
                    open(path, "wb").write(base64.b64decode(c["data"]))
                    print("IMAGE", path)
                else:
                    print(c.get("text", c))
            if res["result"].get("isError"):
                sys.exit(1)
        else:
            print(json.dumps(res, indent=1))
            sys.exit(1)
