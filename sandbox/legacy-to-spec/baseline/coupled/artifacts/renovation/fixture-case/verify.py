from pathlib import Path
from html.parser import HTMLParser
import hashlib, json, re, shutil, subprocess

root=Path(__file__).resolve().parents[3]
out=Path(__file__).parent
checks=[]
def check(name, passed, detail):
 checks.append({'check':name,'passed':bool(passed),'detail':detail})

manifest=json.loads((root/'manifest.json').read_text())
source_records=[]
all_hash_ok=True
for entry in manifest['files']:
 p=Path(entry['path'])
 if not p.is_relative_to(root):
  raise RuntimeError('Refusing to read outside the case')
 b=p.read_bytes()
 ok=hashlib.sha256(b).hexdigest()==entry['sha256']
 all_hash_ok &= ok
 if entry['category']=='source':
  text=b.decode('utf-8',errors='strict')
  source_records.append({'path':str(p.relative_to(root)),'sha256':hashlib.sha256(b).hexdigest(),'matches_manifest':ok,'encoding':'UTF-8','line_endings':'CRLF' if b'\r\n' in b else 'LF','lines':len(text.splitlines())})
check('manifest hashes (provided skill and input snapshots)',all_hash_ok,{'entries':len(manifest['files']),'sources':source_records})
check('exact one scoped root',manifest['root_entry']=='inputs/frontend/Case.jsp' and manifest['scope_id']=='fixture-case',manifest['root_entry'])

mds=sorted((root/'artifacts').rglob('*.md'))
html=root/'artifacts/design/fixture-case/prototypes/SCR-01.html'
texts={p:p.read_text() for p in mds+[html]}
check('no unresolved template placeholders or skeleton',all('{{' not in t and 'data-template-only' not in t and 'template-slot' not in t for t in texts.values()),[str(p.relative_to(root)) for p in texts])

def slug(s):
 s=re.sub(r'[^\w\s-]','',s.strip().lower(),flags=re.UNICODE)
 return re.sub(r'\s','-',s)

def anchors(p):
 return {slug(m.group(1)) for m in re.finditer(r'^#{1,6}\s+(.+)$',p.read_text(),re.M)}
link_errors=[]
links_count=0
for p,t in texts.items():
 links=re.findall(r'\[[^\]]*\]\(([^)]+)\)',t) if p.suffix=='.md' else re.findall(r'href="([^"]+)"',t)
 for link in links:
  links_count+=1
  if '://' in link or link.startswith('mailto:'):
   link_errors.append({'from':str(p.relative_to(root)),'link':link,'reason':'external link'})
   continue
  path,sep,anchor=link.partition('#')
  dest=(p.parent/path).resolve() if path else p
  if not dest.is_relative_to(root) or not dest.exists():
   link_errors.append({'from':str(p.relative_to(root)),'link':link,'reason':'missing or outside case'})
  elif anchor and dest.suffix=='.md' and anchor not in anchors(dest):
   link_errors.append({'from':str(p.relative_to(root)),'link':link,'reason':'anchor missing'})
check('local document links and anchors',not link_errors,{'links':links_count,'errors':link_errors})

class Parse(HTMLParser):
 def __init__(self):
  super().__init__(convert_charrefs=True); self.attrs=[]; self.stack=[]; self.product_attrs=[]; self.ids=[]; self.resources=[]
 def handle_starttag(self,tag,attrs):
  a=dict(attrs); self.attrs.append((tag,a));
  if 'id' in a: self.ids.append(a['id'])
  if tag in ('script','img','iframe','link','source','audio','video'):
   self.resources.extend(a[k] for k in ('src','href') if k in a)
  if any(x=='main' for x in self.stack) or tag=='main': self.product_attrs.append((tag,a))
  if tag not in ('input','meta','link','br','hr','img','source'): self.stack.append(tag)
 def handle_endtag(self,tag):
  if tag in self.stack:
   while self.stack and self.stack.pop()!=tag: pass
parser=Parse(); parser.feed(texts[html]); parser.close()
check('unique DOM IDs',len(parser.ids)==len(set(parser.ids)),parser.ids)
ui=[a['data-ui-id'] for _,a in parser.product_attrs if 'data-ui-id' in a]
expected={f'UI-{i:02}' for i in range(1,12)}
check('product UI IDs exact specification set',set(ui)==expected and len(ui)==11,ui)
flows={a['data-flow-id'] for _,a in parser.product_attrs if 'data-flow-id' in a}
components={a['data-component-id'] for _,a in parser.product_attrs if 'data-component-id' in a}
check('product flow and component IDs',flows=={'FLOW-02','FLOW-04'} and components=={'CMP-01'},{'flows':sorted(flows),'components':sorted(components)})
root_attrs=parser.attrs[0][1]
check('scope screen initial state mapping',root_attrs.get('data-scope-id')=='fixture-case' and root_attrs.get('data-screen-id')=='SCR-01' and root_attrs.get('data-state-id')=='ST-01',root_attrs)
spec=(root/'artifacts/design/fixture-case/specification.md').read_text()
check('all prototype contract attributes exist in specification',all(v in spec for _,a in parser.attrs for k,v in a.items() if k in ('data-ui-id','data-flow-id','data-component-id','data-screen-id','data-state-id')), 'Attribute values reverse checked against specification')
js='\n'.join(re.findall(r'<script\b[^>]*>(.*?)</script>',texts[html],re.S))
script=out/'prototype-script.js'; script.write_text(js)
check('dynamic state IDs declared',all(x in spec for x in re.findall(r"setState\('(ST-\d+)'\)",js)),re.findall(r"setState\('(ST-\d+)'\)",js))
connection_patterns=r'\b(?:fetch|XMLHttpRequest|WebSocket|EventSource|sendBeacon)\s*\(|\bwindow\.open\s*\(|\blocation\.(?:href|assign|replace)\s*[=(]'
remote_resources=parser.resources+re.findall(r'url\s*\(\s*[\'"]?(https?[^)\s\'"]+)',texts[html])
check('offline resources and connection code',not remote_resources and not re.search(connection_patterns,js),{'resources':remote_resources,'connection_primitives':re.findall(connection_patterns,js)})
check('quantity has no local backend calculation/store',not re.search(r'(?:parseInt|parseFloat|Ledger|\.store\s*\(|quantityNode\.value\s*[*/])',js),'Prototype only checks exact empty string and records original text at boundary')
node=shutil.which('node')
if node:
 r=subprocess.run([node,'--check',str(script)],capture_output=True,text=True)
 check('JavaScript syntax via node --check',r.returncode==0,{'exit_code':r.returncode,'stdout':r.stdout,'stderr':r.stderr})
else:
 check('JavaScript syntax via node --check',False,'Not executed: node executable unavailable')

api=(root/'artifacts/integration/fixture-case/api-spec.md').read_text()
backend=(root/'inputs/backend/api-contract.md').read_text()
required=['searchItems','POST /v2/items/search','application/json','queryText','unitId','outcome','rows','rowId','label','OK','EMPTY','DENIED']
check('known operation identifiers and wire terms preserved',all(t in api and t in backend for t in required),required)
check('no invented integration endpoints',set(re.findall(r'/(?:v\d+/)[A-Za-z0-9/_-]+',api))=={'/v2/items/search'},sorted(set(re.findall(r'/(?:v\d+/)[A-Za-z0-9/_-]+',api))))
tracking=(out/'tracking.md').read_text()
coverage=tracking.split('## 4. 來源到契約覆蓋\n',1)[1].split('共 25',1)[0]
coverage_rows=[s for s in coverage.splitlines() if s.startswith('| ')][2:]
check('source coverage row count',len(coverage_rows)==25,{'rows':len(coverage_rows),'unknown_dependency_internals_excluded':True})
results={'date':'2026-10-12','scope':'fixture-case','status':'partial','checks':checks,'all_static_checks_passed':all(c['passed'] for c in checks),'not_executed':['Browser render and actual interaction','Browser console and network observation','Legacy runtime comparison','Real backend integration or Ledger persistence'],'claims_limited_to':'Provided source and documents plus static checks; no runtime behavior, pixel equivalence or deployed API verification'}
(out/'verification.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({'static_checks':len(checks),'passed':sum(c['passed'] for c in checks),'failed':[c for c in checks if not c['passed']],'report':str((out/'verification.json').relative_to(root))},ensure_ascii=False,indent=2))
