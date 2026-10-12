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
            anchors += re.findall(r'id="([^"]+)"', destination.read_text())
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

# Revision 0.2 checks inspect each actual contract position rather than its summary index.
map_data=json.loads((root/'artifacts/renovation/fixture-case/checks/gap-map.json').read_text())
for todo,entry in map_data['impacts'].items():
    for item in entry['ids']:
        anchor=f'<a id="{item.lower()}"></a>'
        assert spec.count(anchor)==1,(item,'missing or duplicate definition anchor')
        line=next(line for line in spec.splitlines() if anchor in line)
        if line.startswith('### '):
            block=spec[spec.index(line):]
            block=block.split('\n### ',1)[0].split('\n## ',1)[0]
        else:
            block=line
        assert f'tracking.md#{todo.lower()}' in block,(todo,item,'no actual-position TODO link')
        assert f'plan.md#{entry["task"].lower()}' in block,(todo,item,'no follow-up task link')
        assert f'#'+item.lower() in (root/'artifacts/renovation/fixture-case/tracking.md').read_text(),(todo,item,'not in verified position table')
print('PASS V-07: all expanded affected contract definitions contain actual TODO and follow-up links; location table addresses actual IDs.')
for i in range(1,9):
    assert len(re.findall(r'^\| API-AC-'+f'{i:02}'+r' \|',api,re.M))==1, i
assert 'AC-02 核对 trim、空字串、12长度、null不合法' not in api
for sample in ('{}','{"queryText":""}','{"queryText":null}','123456789012','1234567890123'):
    assert sample in api,sample
print('PASS V-08: eight independent API contract cases include absent/empty/null/length/type and known response shape; unsupported AC-02 coverage claim removed.')
print('LIMIT V-08: documentation comparison only; no service call or backend validator executed.')

for rel in ('design/fixture-case/specification.md','integration/fixture-case/api-spec.md','integration/fixture-case/backend-handoff.md','renovation/fixture-case/plan.md','renovation/fixture-case/tracking.md'):
    before=(root/'inputs/prior-artifacts'/rel).read_text()
    after=(root/'artifacts'/rel).read_text()
    prior=set(re.findall(r'\b(?:E|LOGIC|DEP|DEC|TASK|TODO|FLOW|DATA|ST|UI|SCR|TR|BR|AC|API|HANDOFF|CMP|V|CHANGE)-\d+\b',before))
    current=set(re.findall(r'\b(?:E|LOGIC|DEP|DEC|TASK|TODO|FLOW|DATA|ST|UI|SCR|TR|BR|AC|API|HANDOFF|CMP|V|CHANGE)-\d+\b',after))
    assert prior <= current,(rel,prior-current)
print('PASS V-09: prior scope IDs and evidence references retained across all five Markdown artifacts.')

for todo,entries in map_data['integration_impacts'].items():
    for entry in entries:
        document=(root/'artifacts'/entry['file']).read_text()
        section=document.split('## '+entry['id']+'\n',1)[1].split('\n## ',1)[0]
        assert 'tracking.md#'+todo.lower() in section,(todo,entry['id'])
        assert 'plan.md#'+entry['task'].lower() in section,(todo,entry['id'])
print('PASS V-07 integration: API-01 and three HANDOFF actual sections retain linked gaps and follow-up tasks.')
