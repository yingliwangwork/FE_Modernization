from pathlib import Path
import re,json,hashlib
from html.parser import HTMLParser
base=Path.cwd();out=base/'artifacts';issues=[];checks=[]
def require(condition,message):
 if not condition:issues.append(message)
manifest=json.loads((base/'manifest.json').read_text())
for entry in manifest['files']:
 p=base/entry['path'];require(hashlib.sha256(p.read_bytes()).hexdigest()==entry['sha256'],'Changed protected input: '+str(p))
checks.append('All manifest input/skill hashes unchanged')
class Parse(HTMLParser):
 def __init__(self):super().__init__();self.links=[];self.tags=[]
 def handle_starttag(self,tag,attrs):
  a=dict(attrs);self.tags.append((tag,a))
  for key in ['href','src']:
   if key in a:self.links.append(a[key])
html=out/'design/fixture-case/prototypes/SCR-01.html';parsed=Parse();parsed.feed(html.read_text())
for p in out.rglob('*'):
 if not p.is_file() or p.suffix not in ['.md','.html']:continue
 text=p.read_text();require('{{' not in text,'Placeholder: '+str(p))
 links=re.findall(r'\[[^\]]*\]\(([^)]+)\)',text) if p.suffix=='.md' else parsed.links
 for link in links:
  if link.startswith(('http:','https:','mailto:')):issues.append('Unexpected external link '+link);continue
  link=link.strip('<>');path,_,anchor=link.partition('#');target=(p.parent/path).resolve() if path else p
  require(target.exists(),str(p)+' broken link '+link)
  if target.exists() and anchor:
   t=target.read_text();headings=re.findall(r'^#+ (.+)$',t,re.M)
   anchors=[re.sub(r'[^\w\-\u4e00-\u9fff ]','',h.lower()).replace(' ','-') for h in headings]
   anchors+=re.findall(r'id="([^"]+)"',t)
   require(anchor in anchors,str(p)+' missing anchor '+link)
checks.append('Local Markdown and HTML resources, anchors and placeholders checked')
css=[out/'design/fixture-case/styles'/name for name in ['CMP-PAGE.css','CMP-TABLE.css','CMP-SEARCH-ACTION.css']]
require(''.join(p.read_text() for p in css)==(base/'inputs/frontend/styles/base.css').read_text(),'Product CSS diverges from supplied source')
links=[a.get('href') for t,a in parsed.tags if t=='link']
require(links==['../styles/'+p.name for p in css],'Loaded CSS mapping incorrect')
require(all('style' not in a for _,a in parsed.tags),'Inline product styling added')
checks.append('Three loaded CSS files concatenate exactly to all 4 source lines; no inline styles')
tokens=json.loads((out/'design/fixture-case/styles/tokens.json').read_text());count=0
for group,items in tokens.items():
 for name,t in items.items():
  count+=1;v=t['$value']
  if t['$type']=='dimension':require(v['unit']=='px' and isinstance(v['value'],(float,int)),'Invalid local dimension')
  elif t['$type']=='color':require(v['colorSpace']=='srgb' and len(v['components'])==3 and v['alpha']==1,'Invalid local color')
  else:issues.append('Unexpected token type')
expected={'page':{'maxWidth':720,'margin':24},'table':{'marginBlock':16,'borderWidth':1,'cellPadding':6},'action':{'marginTop':8}}
for group,items in expected.items():
 for name,value in items.items():require(tokens[group][name]['$value']=={'value':value,'unit':'px'},'Token value differs '+group+'.'+name)
require(tokens['page']['textColor']['$value']['components']==[34/255]*3,'Page color mismatch')
require(tokens['table']['borderColor']['$value']['components']==[85/255]*3,'Border color mismatch')
require(count==8,'Unexpected token count');checks.append('8 supported DTCG token values and local structure checked; no official validator')
spec=(out/'design/fixture-case/specification.md').read_text()
loc={'TODO-01':['DATA-01','UI-02','ST-INIT','FLOW-01'],'TODO-02':['DATA-04','UI-06','ST-ROWS','FLOW-02'],'TODO-03':['DATA-05','DATA-06','DATA-07','UI-07','ST-SUBMIT','FLOW-03'],'TODO-04':['DATA-08','ST-WAIT','ST-UNCLASSIFIED','FLOW-02']}
for todo,ids in loc.items():
 for id in ids:
  if id.startswith('FLOW'):
   section=spec.split('id="'+id.lower()+'"',1)[1].split('\n<a id="flow-',1)[0].split('\n## 6.',1)[0]
  else:section=next(line for line in spec.splitlines() if 'id="'+id.lower()+'"' in line)
  require('#'+todo.lower() in section,'Missing local TODO '+todo+' at '+id)
checks.append('18 impacted DATA/UI/ST/FLOW definition positions reread for local TODO links')
require('fetch(' not in (html.parent/'prototype.js').read_text(),'Unexpected live fetch')
checks.append('No live network call in prototype script')
result={'kind':'Static local checks only; no browser/runtime, official schema validator or live backend proof.','checks':checks,'issues':issues,'passed':not issues}
(out/'renovation/fixture-case/checks/static-results.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
print(json.dumps(result,ensure_ascii=False,indent=2));raise SystemExit(bool(issues))
