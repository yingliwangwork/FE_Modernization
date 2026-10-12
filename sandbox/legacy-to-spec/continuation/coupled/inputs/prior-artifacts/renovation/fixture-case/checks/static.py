from pathlib import Path
import hashlib,json,re
from html.parser import HTMLParser
root=Path.cwd()
manifest=json.loads((root/'manifest.json').read_text())
for f in manifest['files']:
    data=(root/f['path']).read_bytes()
    assert hashlib.sha256(data).hexdigest()==f['sha256'], f['path']
    if f['category']=='source':
        data.decode('utf-8')
        assert b'\r\n' not in data
print('PASS V-01: all manifest snapshot hashes unchanged; source UTF-8/LF.')
files=list((root/'artifacts').rglob('*.md'))+list((root/'artifacts').rglob('*.html'))
for p in files:
    text=p.read_text()
    assert '{{' not in text and 'data-template-only' not in text, p
    links=re.findall(r'\[[^\]]*\]\(([^)]+)\)',text) if p.suffix=='.md' else re.findall(r'href="([^"]+)"',text)
    for link in links:
        assert not re.match(r'https?://',link), (p,link)
        target,_,fragment=link.partition('#')
        destination=(p.parent/target).resolve() if target else p
        assert destination.is_file(), (p,link)
        if fragment and destination.suffix=='.md':
            headings=re.findall(r'^#+\s+(.+)$',destination.read_text(),re.M)
            anchors=[re.sub(r'[^\w\-\u0080-\uffff ]','',h.lower()).replace(' ','-') for h in headings]
            assert fragment in anchors, (p,link,anchors)
print('PASS V-02a: Markdown/HTML local links and fragments resolve; no template placeholders.')
class Inspector(HTMLParser):
    def __init__(self):
        super().__init__(); self.attrs=[]; self.tags=[]
    def handle_starttag(self,tag,attrs):
        a=dict(attrs); self.attrs.append(a);self.tags.append(tag)
        for key in ('src','href','action'):
            if key in a:
                assert not re.match(r'(?:https?:)?//',a[key]),(tag,key)
html=(root/'artifacts/design/fixture-case/prototypes/items.html').read_text()
x=Inspector();x.feed(html)
assert any(a.get('data-scope-id')=='fixture-case' and a.get('data-screen-id')=='SCR-01' and a.get('data-state-id')=='ST-01' for a in x.attrs)
spec=(root/'artifacts/design/fixture-case/specification.md').read_text()
for attr in ('data-ui-id','data-flow-id','data-component-id'):
    for a in x.attrs:
        if attr in a: assert a[attr] in spec,(attr,a[attr])
assert all(f'UI-{n:02}' in html for n in range(1,9))
assert 'maxlength="12"' in html
for fact in ('max-width: 720px','margin: 24px','color: #222','border-collapse: collapse','border: 1px solid #555','padding: 6px','text-align: left','margin-top: 8px'):
    assert fact in html
script=re.search(r'<script>([\s\S]*?)</script>',html).group(1)
for forbidden in ('fetch(', 'XMLHttpRequest', 'WebSocket', 'Ledger.', 'quantity *', 'quantity*', 'location.href', '.submit('):
    assert forbidden not in script,forbidden
print('PASS V-02b: source visual constants, UI/FLOW/CMP IDs and local-only prototype structure checked.')
api=(root/'artifacts/integration/fixture-case/api-spec.md').read_text()
backend=(root/'inputs/backend/api-contract.md').read_text()
for fact in ('searchItems','POST /v2/items/search','application/json','queryText','outcome','rows','rowId','label','OK','EMPTY','DENIED'):
    assert fact in api and fact in backend
for unknown in ('認證','null','rankHint','没有可呼叫环境'):
    assert unknown in api
assert all(f'HANDOFF-{i:02}' in (root/'artifacts/integration/fixture-case/backend-handoff.md').read_text() for i in (1,2,3))
print('PASS V-02c: known selected API identifiers/fields/results retained; handoffs and explicit gaps present.')
print('LIMIT: these are static checks; browser rendering, actual authentication/transport and backend business execution unverified.')
