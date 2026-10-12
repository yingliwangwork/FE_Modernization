from pathlib import Path
import hashlib,json,re,os
from html.parser import HTMLParser
root=Path.cwd();out=Path('artifacts/renovation/AF-AFY10400');findings=[];checks=[]
def check(label,condition,detail=''):
 checks.append({'check':label,'status':'PASS' if condition else 'FAIL','detail':detail})
 if not condition:findings.append(label+': '+detail)
manifest=json.loads(Path('manifest.json').read_text())
for item in manifest['files']:
 p=Path(item['path']);check('unchanged '+str(p),p.is_file() and hashlib.sha256(p.read_bytes()).hexdigest()==item['sha256'],'manifest SHA-256 compare')
mds=list(Path('artifacts/design/AF-AFY10400').rglob('*.md'))+list(Path('artifacts/integration/AF-AFY10400').glob('*.md'))+list(Path('artifacts/renovation/AF-AFY10400').glob('*.md'))
def anchors(path):
 text=path.read_text();a=set(re.findall(r'<a id="([^"]+)"',text))
 for title in re.findall(r'^#+ (.+)$',text,re.M):a.add(re.sub(r'[^\w\u4e00-\u9fff -]','',title.lower()).replace(' ','-'))
 return a
for p in mds:
 t=p.read_text();check('no template placeholder '+str(p),'{{' not in t and '}}' not in t)
 for label,target in re.findall(r'\[([^\]\n]+)\]\(([^)\n]+)\)',t):
  if target.startswith(('http:','https:','mailto:')):continue
  fp,sep,fragment=target.partition('#');q=(p.parent/fp).resolve() if fp else p.resolve();ok=q.is_file()
  if sep and ok and q.suffix=='.md':ok=fragment in anchors(q)
  check('local link '+str(p)+': '+label,ok,target)
class Parser(HTMLParser):
 def __init__(self):super().__init__();self.ids=[];self.refs=[];self.scope=[];self.classes=[];self.flows=[];self.uis=[]
 def handle_starttag(self,tag,attrs):
  a=dict(attrs)
  if 'id' in a:self.ids.append(a['id'])
  if tag in ['script','link'] and ('src'in a or 'href'in a):self.refs.append(a.get('src',a.get('href')))
  if 'data-scope-id'in a:self.scope.append(a)
  if 'data-flow-id'in a:self.flows.append(a['data-flow-id'])
  if 'data-ui-id'in a:self.uis.append(a['data-ui-id'])
h=Path('artifacts/design/AF-AFY10400/prototypes/SCR-01.html');p=Parser();p.feed(h.read_text())
check('static HTML ids unique',len(p.ids)==len(set(p.ids)))
check('scope/screen/state markers',any(a.get('data-scope-id')=='AF-AFY10400' and a.get('data-screen-id')=='SCR-01' and a.get('data-state-id')=='ST-01' for a in p.scope))
for ref in p.refs:check('HTML local asset '+ref,not ref.startswith(('http:','https:','//')) and (h.parent/ref).is_file())
for flow in p.flows:check('HTML flow documented '+flow,flow in Path('artifacts/design/AF-AFY10400/specification.md').read_text())
for ui in p.uis:check('HTML UI documented '+ui,ui in Path('artifacts/design/AF-AFY10400/specification.md').read_text())
for js in ['model.js','prototype.js']:
 t=(h.parent/js).read_text();check('no network primitive '+js,not any(re.search(pat,t) for pat in [r'\bfetch\s*\(',r'new\s+XMLHttpRequest',r'https?://',r'\bnavigator\.sendBeacon',r'(?:oForm|document\.forms|HTMLFormElement)[^;]*\.submit\(' ]))
for css in Path('artifacts/design/AF-AFY10400/styles').glob('*.css'):check('CSS no remote/missing url '+css.name,'url(' not in css.read_text())
spec=Path('artifacts/design/AF-AFY10400/specification.md').read_text();check('neutral root avoids endpoint/framework syntax',all(x not in spec for x in ['/afy10400/','getElementsByName','Form.serialize','jQuery.ajax','RequestContext','Spring Boot']))
api=Path('artifacts/integration/AF-AFY10400/api-spec.md').read_text();backend=Path('inputs/backend/docs/OPENAPI.md').read_text()
for wire in ['afy10400DoExport','/afy10400/export','afy10400DoDownload','/afy10400/download','application/octet-stream','I_ID','POLICY_NO','rtnMap','fileName','code','msg','data']:
 check('API baseline token '+wire,wire in api and wire in backend)
check('no invented API target fields',not re.search(r'\| (?:body )?(?:table1_I_ID|table1_POLICY_NOs|downloadFileName|downloadFileFullPath) \|',api))
meta=json.loads((out/'design-metadata-check.json').read_text());check('all four DESIGN metadata',meta['status']=='PASS' and len(meta['results'])==4)
beh=json.loads((out/'behavior-check.json').read_text());check('all twelve behavior checks',len(beh['results'])==12 and all(x['status']=='PASS' for x in beh['results']))
check('delivery marked partial','部分交付' in (out/'tracking.md').read_text())
report={'status':'FAIL' if findings else 'PASS','counts':{'checks':len(checks),'failures':len(findings),'source_manifest_files':len(manifest['files'])},'checks':checks,'findings':findings,'limits':['Static HTML parsing cannot establish browser DOM recovery, computed styles, native UI, performance or pixel equivalence.','API token comparison is a supplemental locator check; actual wire meanings were manually compared with selected Markdown baseline.','No official OpenAPI/DESIGN format validator, live HTTP or external system was called.']}
(out/'structural-check.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n');print(json.dumps({'status':report['status'],'counts':report['counts'],'findings':findings},ensure_ascii=False,indent=2))
files=[]
for p in sorted(Path('artifacts').rglob('*')):
 if p.is_file() and p.name!='artifact-inventory.json':files.append({'path':str(p),'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'bytes':p.stat().st_size})
(out/'artifact-inventory.json').write_text(json.dumps({'scope':'AF-AFY10400','files':files,'limits':['Inventory itself is excluded from its own hash list.','Generated files only; does not assert behavior completeness.']},ensure_ascii=False,indent=2)+'\n')
if findings:raise SystemExit(1)
