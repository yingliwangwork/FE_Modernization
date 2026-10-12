from pathlib import Path
import re,json,hashlib
from html.parser import HTMLParser
root=Path('artifacts');fail=[];links=0
for p in root.rglob('*.md'):
 text=p.read_text()
 if '{{' in text or '}}' in text:fail.append(f'placeholder {p}')
 for href in re.findall(r'\]\(([^)]+)\)',text):
  if href.startswith(('http:','https:')):continue
  dest=href.split('#')[0]
  target=p.parent/dest if dest else p
  if not target.exists():fail.append(f'broken link {p}: {href}')
  elif '#' in href and target.suffix=='.md':
   fragment=href.split('#',1)[1]
   headings=re.findall(r'^#{1,6} +(.+)$',target.read_text(),re.M)
   slugs={re.sub(r'[^\w\- ]','',h.lower()).replace(' ','-') for h in headings}
   if fragment not in slugs:fail.append(f'broken anchor {p}: {href}')
  links+=1
p=root/'design/AF-AFY10400/prototypes/SCR-01.html';html=p.read_text()
class Parse(HTMLParser):
 def __init__(self):super().__init__();self.ids=set();self.product=[];self.external=[]
 def handle_starttag(self,t,attrs):
  a=dict(attrs)
  if a.get('id') in self.ids:fail.append('duplicate HTML id '+a['id'])
  if 'id' in a:self.ids.add(a['id'])
  if 'data-scope-id' in a:self.product.append(a)
  for key in ['src','href']:
   if key in a and a[key].startswith(('http:', 'https:', '//')):self.external.append(a[key])
parser=Parse();parser.feed(html)
assert len(parser.product)==1
assert parser.product[0]['data-scope-id']=='AF-AFY10400'
assert parser.product[0]['data-screen-id']=='SCR-01'
assert parser.product[0]['data-state-id']=='ST-01'
if parser.external:fail.append('external references '+str(parser.external))
if re.search(r'fetch\s*\(|XMLHttpRequest|window\.open|\.submit\s*\(|https?://|url\(',html):fail.append('network/submission pattern in prototype')
js=re.search(r'<script>(.*?)</script>',html,re.S).group(1)
(root/'renovation/AF-AFY10400/checks/prototype-script.js').write_text(js)
inventory=json.loads((root/'renovation/AF-AFY10400/source-inventory.json').read_text())
assert all(x['matches_manifest'] for x in inventory)
assert all(hashlib.sha256(Path(x['path']).read_bytes()).hexdigest()==x['sha256'] for x in inventory)
result={'markdown_links_checked':links,'html_unique_ids':len(parser.ids),'source_hashes_verified':len(inventory),'external_resource_references':parser.external,'failures':fail,'limitations':['Static parsing is not browser rendering or network observation.','API baseline is Markdown; no invented OpenAPI JSON/YAML parser check.']}
(root/'renovation/AF-AFY10400/checks/static-result.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
print(json.dumps(result,ensure_ascii=False))
assert not fail
