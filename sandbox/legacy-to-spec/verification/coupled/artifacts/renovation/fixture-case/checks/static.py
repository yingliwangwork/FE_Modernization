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
print('PASS V-07: declared affected definitions contain actual TODO and follow-up links; location table addresses selected IDs. Semantic exhaustiveness requires source review.')
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


# Review-guided 0.3: verify whole-page styling independently of the old selected map.
css=(root/'inputs/frontend/styles/base.css').read_text()
jsp=(root/'inputs/frontend/Case.jsp').read_text()
component=(root/'inputs/frontend/components/action-bar.jspf').read_text()
assert 'body {' in css and '.action-bar { margin-top: 8px; }' in css
assert '<body>' in jsp and 'components/action-bar.jspf' in jsp and 'class="action-bar"' in component
ui_ids=set(re.findall(r'<a id="(ui-\d+)"></a>',spec))
state_ids=set(re.findall(r'<a id="(st-\d+)"></a>',spec))
prototype_ui={a['data-ui-id'].lower() for a in x.attrs if 'data-ui-id' in a}
assert prototype_ui==ui_ids, ('UI definitions versus product prototype',prototype_ui,ui_ids)
style_expected={item.upper() for item in ui_ids|state_ids}|{'SCR-01','CMP-01','CMP-02','AC-11'}
groups=map_data['impacts']['TODO-06']['source_impacts']
assert set(groups['style']['ids'])==style_expected, ('whole-page style impact undercount',style_expected-set(groups['style']['ids']))
assert set(groups['bridge']['ids'])=={'FLOW-02','FLOW-03','BOUND-02','ST-02','AC-02','AC-03','AC-04','AC-05','AC-06','AC-10'}
assert set(map_data['impacts']['TODO-06']['ids'])==set(groups['style']['ids'])|set(groups['bridge']['ids'])
print('PASS V-10 source scope: body/action-bar style impacts cover all eight UI and eight same-screen ST definitions plus page-use components; style and bridge impacts distinguished.')

tracking=(root/'artifacts/renovation/fixture-case/tracking.md').read_text()
table=tracking[tracking.index('| TODO | 實際受影響定義位置 |'):].split('\n## ',1)[0].strip().splitlines()
assert table[1]=='| --- | --- | --- | --- |', 'impact table delimiter'
assert all(line.startswith('|') and line.endswith('|') for line in table), 'blank/detached impact table row'
pairs=[]
for line in table[2:]:
    columns=line.split('|')[1:-1]
    assert len(columns)==4, ('impact table column count',line)
    todo=columns[0].strip()
    match=re.search(r'\[(.*?)\]\(',columns[1]); assert match,line
    pairs.append((todo,match.group(1)))
expected={(todo,item) for todo,entry in map_data['impacts'].items() for item in entry['ids']}
expected|={(todo,entry['id']) for todo,entries in map_data['integration_impacts'].items() for entry in entries}
assert len(pairs)==len(set(pairs)) and set(pairs)==expected, 'table/map missing, duplicate or extra pairs'
print(f'PASS V-10 table: {len(pairs)} design/integration pairs render as one contiguous four-column Markdown table; selected map positions resolve.')

ac06=next(line for line in spec.splitlines() if '<a id="ac-06"></a>' in line)
for fact in ('請求 A','請求 B','A→B','B→A','ST-04','ST-03','A 仍可接收回應','待回應清空','DEMO-01','DEMO-02','沒有項目'):
    assert fact in ac06, ('AC-06 request/response identities or intermediate observations missing',fact)
print('PASS V-11 definition: AC-06 identifies A/B, start/arrival orders, corresponding empty/two-row synthetic results and intermediate/final observations.')

prior_tracking=(root/'inputs/prior-artifacts/renovation/fixture-case/tracking.md').read_text()
evidence_rows=lambda text: re.findall(r'^\| E-\d+ \|.*$',text,re.M)
assert evidence_rows(prior_tracking)==evidence_rows(tracking), 'prior E-01–15 evidence rows changed'
prior_html=(root/'inputs/prior-artifacts/design/fixture-case/prototypes/items.html').read_text()
assert re.search(r'<script>([\s\S]*?)</script>',prior_html).group(1)==script, 'product/review script behavior changed'
print('PASS V-12: E-01–15 evidence rows preserved verbatim and prototype executable script unchanged from prior delivery.')
print('LIMIT V-10/11/12: source-supported enumerated impacts and textual case checks do not establish external dependency completeness, browser rendering or real service behavior.')
