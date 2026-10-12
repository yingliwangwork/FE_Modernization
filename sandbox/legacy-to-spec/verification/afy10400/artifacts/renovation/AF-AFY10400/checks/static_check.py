from pathlib import Path
import re,json,hashlib
from html.parser import HTMLParser
root=Path('artifacts');fail=[];links=0;gap_locations=[]
for p in root.rglob('*.md'):
 text=p.read_text()
 if p.parts[1] in ('design','integration'):
  if re.search(r'(?<!\[)TODO-\d{2}',text):fail.append(f'unlinked TODO {p}')
  for line_number,line in enumerate(text.splitlines(),1):
   gaps=re.findall(r'\[(TODO-\d{2})\]\(([^)]+)\)',line)
   if gaps:
    row_id=re.match(r'\| ([^|]+) \|',line)
    gap_locations.append({'document':str(p),'line':line_number,'position':row_id[1].strip() if row_id else 'prose','gaps':[{'id':i,'href':h} for i,h in gaps]})
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
manifest=json.loads(Path('manifest.json').read_text())
manifest_hashes={x['path']:x['sha256'] for x in manifest['files']}
assert all(hashlib.sha256(Path(x['path']).read_bytes()).hexdigest()==x['sha256'] for x in manifest['files'])
byte_result=json.loads((root/'renovation/AF-AFY10400/checks/source-byte-result.json').read_text())
for item, facts in zip(inventory,byte_result['files']):
 data=Path(item['path']).read_bytes()
 assert item['sha256']==manifest_hashes[item['path']]
 assert item['line_count']==len(data.splitlines())==facts['physical_lines']
 assert item['bytes']==len(data)
 assert item['newline_counts']=={'crlf':data.count(b'\r\n'),'lf':data.count(b'\n')-data.count(b'\r\n'),'cr':data.count(b'\r')-data.count(b'\r\n')}
 for codec,stored in item['strict_decoding'].items():
  try:
   data.decode(codec,errors='strict');actual={'status':'valid'}
  except UnicodeDecodeError as error:
   actual={'status':'invalid','byte_offset':error.start}
  assert actual==stored==facts['strict_decoding'][codec]
 if item['analysis_encoding'] is not None:assert item['strict_decoding'][item['analysis_encoding']]['status']=='valid'
date=next(x for x in inventory if x['path'].endswith('/date.js'))
assert date['analysis_encoding'] is None and date['line_count']==1089
assert date['strict_decoding']['cp950']=={'status':'invalid','byte_offset':40}
assert date['strict_decoding']['utf-8']=={'status':'invalid','byte_offset':8}
assert ':root .button, :root .button1, :root .buttonRed{padding:0px 10px}' in html
assert 'style="padding:0 15px"' in html
layer_indices={}
for cls in ('cover','review','msg-window','dragbox'):
 css=re.search(r'\.'+re.escape(cls)+r'\{([^}]+)\}',html).group(1)
 assert 'position:' in css
 layer_indices[cls]=int(re.search(r'z-index:(\d+)',css).group(1))
assert layer_indices['cover']==150
assert layer_indices['msg-window']==999
assert layer_indices['cover']<layer_indices['review']<layer_indices['msg-window']<layer_indices['dragbox']

flow_text=(root/'design/AF-AFY10400/specification.md').read_text().split('## 7.')[1].split('## 8.')[0]
assert not re.search(r'callback|complete|failureAction|helper|WIUtil|HTTP|JSON|response',flow_text)
(root/'renovation/AF-AFY10400/checks/gap-location-result.json').write_text(json.dumps({'locations':gap_locations,'decision':'DEC-01','follow_up_tasks':{'TODO-01':'TASK-06','TODO-02':'TASK-07','TODO-03':'TASK-08','TODO-04':'TASK-07','TODO-05':'TASK-08','TODO-06':'TASK-09'},'limit':'Actual linked gap occurrences; does not prove all unknown dependency internals were analyzed.'},ensure_ascii=False,indent=2)+'\n')
result={'markdown_links_checked':links,'html_unique_ids':len(parser.ids),'source_hashes_verified':len(inventory),'manifest_hashes_verified':len(manifest['files']),'source_byte_records_verified':len(inventory),'linked_gap_positions':len(gap_locations),'unconfirmed_source_encodings':[date['path']],'effective_button_padding_checked':True,'neutral_root_flows_checked':True,'source_product_and_review_layer_order_checked':layer_indices,'external_resource_references':parser.external,'failures':fail,'limitations':['Static parsing is not browser rendering or network observation.','API baseline is Markdown; no invented OpenAPI JSON/YAML parser check.']}
(root/'renovation/AF-AFY10400/checks/static-result.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
print(json.dumps(result,ensure_ascii=False))
assert not fail
