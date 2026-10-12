from pathlib import Path
import hashlib,json,re,yaml
R=Path('artifacts/renovation/AF-AFY10400');D=Path('artifacts/design/AF-AFY10400');I=Path('artifacts/integration/AF-AFY10400');target=R/'continuation-document-check.json'
target.write_text(json.dumps({'status':'RUNNING','kind':'continuation-static-document-check'})+'\n')
checks=[]
def check(label,ok,detail=''):
 checks.append({'check':label,'status':'PASS' if ok else 'FAIL','detail':detail})
manifest=json.loads(Path('manifest.json').read_text())
for x in manifest['files']:
 p=Path(x['path']);check('manifest unchanged '+x['path'],p.is_file() and hashlib.sha256(p.read_bytes()).hexdigest()==x['sha256'])
# Compare historical report artifacts byte-for-byte to immutable provided snapshots.
for name in ['behavior-check.json','design-metadata-check.json','source-inventory.json','structural-check.json','structural-first-run.json','template-selection.json','artifact-inventory.json']:
 check('initial report retained '+name,(R/name).read_bytes()==(Path('inputs/previous-artifacts/renovation/AF-AFY10400')/name).read_bytes())
mds=list(D.rglob('*.md'))+list(I.glob('*.md'))+list(R.glob('*.md'))
def getanchors(p):
 t=p.read_text();out=set(re.findall(r'<a id="([^"]+)"',t))
 for heading in re.findall(r'^#+ (.+)$',t,re.M):out.add(re.sub(r'[^\w\u4e00-\u9fff -]','',heading.lower()).replace(' ','-'))
 return out
link_count=0;table_count=0
for p in mds:
 t=p.read_text();check('no template markers '+str(p),'{{' not in t)
 expected=None
 for n,line in enumerate(t.splitlines(),1):
  if line.startswith('|'):
   cells=re.split(r'(?<!\\)\|',line)[1:-1]
   if expected is None:expected=len(cells);table_count+=1
   check('table cells '+str(p)+':'+str(n),len(cells)==expected,str(len(cells))+' versus '+str(expected))
  else:expected=None
  for label,ref in re.findall(r'\[([^\]\n]+)\]\(([^)\n]+)\)',line):
   link_count+=1
   if ref.startswith(('http://','https://','mailto:')):continue
   f,sep,a=ref.partition('#');q=(p.parent/f).resolve() if f else p.resolve();ok=q.is_file()
   if ok and sep and q.suffix=='.md':ok=a in getanchors(q)
   check('local link '+str(p)+':'+str(n)+' '+label,ok,ref)
  # Remove complete inline Markdown links and image links; remaining open opener is a true malformed reference.
  stripped=re.sub(r'!?\[[^\]\n]*\]\([^\n)]*\)','',line)
  check('no truncated link '+str(p)+':'+str(n),'](' not in stripped)
# STYLE declarations in final CSS are mapped one-to-one, retaining existing stable IDs.
styles_count=0;token_count=0
for c in ['PAGE','FORM','COVER','MESSAGE']:
 p=D/'components'/('CMP-'+c)/'DESIGN.md';t=p.read_text();front=re.match(r'---\n(.*?)\n---',t,re.S);tokens=yaml.safe_load(front.group(1))
 css=(D/'styles'/('CMP-'+c+'.css')).read_text();clean=re.sub(r'/\*.*?\*/','',css,flags=re.S);decls=[]
 for sel,body in re.findall(r'([^{}]+)\{([^{}]*)\}',clean):
  for item in body.split(';'):
   if ':' in item:
    prop,val=item.split(':',1);decls.append((sel.strip(),prop.strip(),val.strip()))
 rows=[line for line in t.splitlines() if line.startswith('| STYLE-')]
 check('STYLE count CMP-'+c,len(rows)==len(decls),str(len(rows))+' rows vs '+str(len(decls))+' CSS declarations')
 for idx,(line,(sel,prop,val)) in enumerate(zip(rows,decls),1):
  styles_count+=1;style=f'STYLE-{c}-{idx:02}'
  check('STYLE/CSS exact '+style,style in line and '`'+sel+'`' in line and '`'+prop+': '+val+'`' in line)
  check('STYLE concrete mapping '+style,'部分值对应frontmatter' not in line and ('無 token' in line or 'colors.' in line or 'typography.' in line))
  check('STYLE local evidence/context '+style,'tracking.md#e-' in line and ('L' in line) and ('CMP-' in line or 'UI-' in line) and 'TODO-07' in line)
  match=re.search(r'\| (colors\.\w+|typography\.\w+\.\w+) \|',line)
  if match:
   token_count+=1;v=tokens
   for key in match.group(1).split('.'):v=v[key]
   def normal(x):
    x=str(x).replace(' ','').replace("'",'').replace('"','').lower()
    if re.fullmatch(r'#[0-9a-f]{3}',x):x='#'+''.join(ch*2 for ch in x[1:])
    return x
   check('token value '+style,normal(v)==normal(val),match.group(1))
  if c=='PAGE' and idx==26:check('F06 red E03','[E-03]' in line and 'L191/193' in line)
  if c=='PAGE' and idx in [27,28,29]:check('F06 print E07 '+style,'[E-07]' in line and 'L101–112' in line)
 for oldid in re.findall(r'\| (STYLE-'+c+r'-\d+) \|',(Path('inputs/previous-artifacts/design/AF-AFY10400/components')/('CMP-'+c)/'DESIGN.md').read_text()):check('stable STYLE id '+oldid,oldid in t)
# Neutral contracts permit literal diagnostic user text but no implementation-based requirements.
for p in [D/'specification.md',D/'common-contracts.md']:
 t=p.read_text();check('neutral implementation symbols '+p.name,not any(x in t for x in ['Prototype','jQuery','WIUtil','PageUI','document keypress','data=null','window.init','overDiv','button,submit','HTTP','JSON','getElementsByName','Form.serialize']))
check('DEP 15 seven-column rows',len(re.findall(r'^\| DEP-\d+ \|', (R/'plan.md').read_text(),re.M))==15)
check('TODO-01..07 remain open',all('<a id="todo-'+str(n).zfill(2)+'"></a>' in (R/'tracking.md').read_text() for n in range(1,8)) and (R/'tracking.md').read_text().count('尚未解决')>=7)
# Browser attribution checks only reports explicitly authorized by parent, never scenarios or other reports.
life=json.loads(Path('reports/lifecycle-browser.json').read_text());browser=json.loads(Path('reports/browser.json').read_text())
for p,h in life['runtimeHashes'].items():check('final browser runtime hash '+p,hashlib.sha256(Path(p).read_bytes()).hexdigest()==h)
check('parent browser 18 PASS',len(browser['checks'])==18 and all(x['status']=='PASS' for x in browser['checks']))
check('parent lifecycle 2 PASS',len(life['checks'])==2 and all(x['status']=='PASS' for x in life['checks']))
check('browser no runtime/errors/network',not browser['errors'] and not browser['networkAttempts'] and not life['errors'] and not life['networkAttempts'])
for name,key,count in [('continuation-runtime-check.json','checks',5),('behavior-check-v2.json','results',12)]:
 j=json.loads((R/name).read_text());check(name+' PASS',len(j[key])==count and all(x['status']=='PASS' for x in j[key]))
meta=json.loads((R/'design-metadata-check-v2.json').read_text());check('final four metadata PASS',meta['status']=='PASS' and len(meta['results'])==4)
check('partial delivery remains','本輪判定仍為部分交付' in (R/'tracking.md').read_text())
fails=[x for x in checks if x['status']=='FAIL'];report={'status':'FAIL' if fails else 'PASS','kind':'continuation-static-document-and-authorized-report-check','counts':{'checks':len(checks),'failures':len(fails),'manifest_files':len(manifest['files']),'markdown_links':link_count,'markdown_tables':table_count,'style_declarations':styles_count,'direct_frontmatter_tokens':token_count},'checks':checks,'findings':fails,'limits':['Single-line Markdown link and table scanner; installed mistune/markdown_it were unavailable, no parser installation or external call performed.','STYLE mapping checks verify declared values, token references, local E anchors and source locators; manual source recheck supports semantics, not a full CSS browser fidelity proof.','Authorized parent browser runtime hashes validate tested HTML/JS/CSS; report DESIGN hashes are not used to claim final document verification.','Original unknown dependencies and backend handoffs remain open.']}
target.write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n');print(json.dumps({'status':report['status'],'counts':report['counts'],'findings':fails},ensure_ascii=False,indent=2))
files=[]
for p in sorted(Path('artifacts').rglob('*')):
 if p.is_file() and p.name!='artifact-inventory-v2.json':files.append({'path':str(p),'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'bytes':p.stat().st_size})
(R/'artifact-inventory-v2.json').write_text(json.dumps({'scope':'AF-AFY10400','version':'v2','files':files,'browser_runtime_verified':list(life['runtimeHashes']),'limits':['Inventory itself excluded; initial inventory retained as historical artifact.','Does not close TODOs or prove backend integration.']},ensure_ascii=False,indent=2)+'\n')
if fails:raise SystemExit(1)
