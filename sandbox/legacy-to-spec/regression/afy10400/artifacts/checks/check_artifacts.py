from pathlib import Path
from html.parser import HTMLParser
import json, re, subprocess, hashlib, datetime
ROOT=Path.cwd()
SCOPE='AF-AFY10400'
art=ROOT/'artifacts'
html=art/'design'/SCOPE/'prototypes/SCR-001.html'
spec=art/'design'/SCOPE/'specification.md'
tracking=art/'renovation'/SCOPE/'tracking.md'
records=[]
def check(name,ok,detail):
 records.append({'check':name,'passed':bool(ok),'actual':detail})
class Parser(HTMLParser):
 def __init__(self):super().__init__();self.ids=[];self.tags=[]
 def handle_starttag(self,tag,attrs):
  a=dict(attrs);self.tags.append((tag,a))
  if 'id' in a:self.ids.append(a['id'])
p=Parser();s=html.read_text();p.feed(s);p.close()
check('HTML identifiers unique',len(p.ids)==len(set(p.ids)),{'ids':len(p.ids),'unique':len(set(p.ids))})
check('Root metadata',all(v in s for v in ['data-scope-id="AF-AFY10400"','data-screen-id="SCR-001"','data-state-id="ST-001"']), 'Scope, screen and initial state metadata found')
check('Initial rows and defaults',not any('table1_row_' in a.get('id','') for _,a in p.tags) and s.count('value="L" selected')==1 and s.count('value="AT" selected')==1,'Parsed initial HTML contains no generated data row; defaults L and AT')
external=[]
for tag,a in p.tags:
 if (tag=='script' and a.get('src')) or (tag=='link' and a.get('rel')=='stylesheet') or (tag=='img' and a.get('src')):external.append((tag,a))
check('No external resource declarations',not external,external)
script=re.search(r'<script>([\s\S]*?)</script>',s).group(1)
scriptpath=art/'checks/prototype-script.js';scriptpath.write_text(script)
syntax=subprocess.run(['node','--check',str(scriptpath)],capture_output=True,text=True)
check('Embedded JavaScript syntax',syntax.returncode==0,{'command':'node --check artifacts/checks/prototype-script.js','exit_code':syntax.returncode,'stdout':syntax.stdout,'stderr':syntax.stderr})
check('No network call primitives',not re.search(r'\b(fetch|XMLHttpRequest|WebSocket)\s*\(',script),'No call to fetch, XMLHttpRequest or WebSocket found; static check only')
missing=[];link_count=0
for f in art.rglob('*.md'):
 for dest in re.findall(r'\]\(([^)]+)\)',f.read_text()):
  link_count+=1; base=dest.split('#')[0]
  if base and not base.startswith(('http:','https:')) and not (f.parent/base).exists():missing.append({'file':str(f.relative_to(ROOT)),'target':dest})
check('Markdown local links',not missing,{'checked':link_count,'missing':missing})
placeholders=[]
for f in art.rglob('*'):
 if f.suffix in ['.md','.html'] and re.search(r'\{\{[^}]+\}\}|data-template-only|template-slot',f.read_text()):placeholders.append(str(f.relative_to(ROOT)))
check('No unfilled template scaffold',not placeholders,placeholders)
product_ids=set(re.findall(r'(?:UI|FLOW|SCR|ST|CMP)-\d{3}',s));contract=spec.read_text()
unknown=sorted(i for i in product_ids if i not in contract)
check('Prototype product identifiers resolve in specification',not unknown,{'identifiers':sorted(product_ids),'unknown':unknown})
refs=set(re.findall(r'\bE-\d{3}(?:[A-Z])?\b','\n'.join(f.read_text() for f in art.rglob('*.md'))))
unknown=sorted(x for x in refs if x not in tracking.read_text())
check('Evidence identifiers resolve in tracking',not unknown,{'references':sorted(refs),'unknown':unknown})
man=json.loads((ROOT/'manifest.json').read_text());integrity=[]
for f in man['files']:
 actual=hashlib.sha256((ROOT/f['path']).read_bytes()).hexdigest()
 integrity.append({'path':f['path'],'actual':actual,'expected':f['sha256'],'match':actual==f['sha256']})
check('Immutable source and skill snapshot hashes',all(f['match'] for f in integrity),{'files_checked':len(integrity),'matched':sum(x['match'] for x in integrity)})
(art/'checks/input-integrity-final.json').write_text(json.dumps(integrity,ensure_ascii=False,indent=2))
result={'date':datetime.datetime.now().isoformat(),'environment':'local Python and node, no browser or backend calls','records':records,'passed':all(x['passed'] for x in records),'browser_scenarios':'not executed; parent will run independently','backend_integration':'not executed; forbidden by task'}
(art/'checks/local-checks.json').write_text(json.dumps(result,ensure_ascii=False,indent=2))
print(json.dumps(result,ensure_ascii=False,indent=2))
raise SystemExit(0 if result['passed'] else 1)
