from pathlib import Path
import hashlib,json,re
from html.parser import HTMLParser
base=Path.cwd(); check=Path('artifacts/renovation/AF-AFY10400/checks'); manifest=json.loads(Path('manifest.json').read_text())
rows=[]
for entry in manifest['files']:
 p=Path(entry['path']); b=p.read_bytes(); sha=hashlib.sha256(b).hexdigest()
 enc='not attempted';lines=None
 if entry['category']=='source':
  for codec in ['utf-8','big5','cp950','big5hkscs']:
   try: s=b.decode(codec); enc=codec;lines=len(s.splitlines());break
   except UnicodeDecodeError: pass
  else: enc='strict decoding unknown (utf-8/big5/cp950/big5hkscs failed)'
 rows.append({'path':str(p.relative_to(base)),'sha256':sha,'matches_manifest':sha==entry['sha256'],'encoding_read':enc,'lines':lines})
check.joinpath('input-inventory.json').write_text(json.dumps(rows,ensure_ascii=False,indent=2)+'\n')
errors=[];notes=[]
for p in Path('artifacts').rglob('*.md'):
 s=p.read_text()
 if re.search(r'\{\{[^}]+\}\}',s):errors.append(f'placeholder: {p}')
 for target in re.findall(r'\]\(([^)]+)\)',s):
  if target.startswith(('http:','https:','mailto:')):continue
  file,sep,fragment=target.partition('#'); q=p.parent/file if file else p
  if not q.exists():errors.append(f'broken link {p}: {target}')
  elif fragment and q.suffix=='.md':
   anchors={re.sub(r'[^\w\- ]','',line.lstrip('# ').lower()).replace(' ','-') for line in q.read_text().splitlines() if line.startswith('#')}
   if fragment not in anchors:errors.append(f'broken anchor {p}: {target}')
html=Path('artifacts/design/AF-AFY10400/prototypes/SCR-01.html');s=html.read_text()
class Parser(HTMLParser):
 def __init__(self):super().__init__();self.attrs=[]
 def handle_starttag(self,tag,attrs):self.attrs.append((tag,dict(attrs)))
p=Parser();p.feed(s)
for tag,a in p.attrs:
 for key in ('src','href','action'):
  if key in a and re.match(r'(?:https?:)?//',a[key]):errors.append('remote resource '+a[key])
 if tag in ('iframe','object','embed'):errors.append('unsupported remote-capable element '+tag)
 if tag=='form' and 'action' in a:errors.append('form action present')
roots=[a for tag,a in p.attrs if a.get('data-scope-id')]
assert len(roots)==1 and roots[0]['data-scope-id']=='AF-AFY10400'
assert roots[0]['data-screen-id']=='SCR-01' and roots[0]['data-state-id']=='ST-01'
product_code=s.split('<script>',1)[1].split('</script>',1)[0]
check.joinpath('prototype-script.js').write_text(product_code)
if re.search(r'\b(?:fetch|XMLHttpRequest|WebSocket|sendBeacon)\s*\(',product_code):errors.append('network API in prototype')
spec=Path('artifacts/design/AF-AFY10400/specification.md').read_text()
for a in [a for _,a in p.attrs]:
 for key in ('data-ui-id','data-flow-id','data-component-id'):
  if key in a and a[key] not in spec:errors.append(f'unmapped {key}={a[key]}')
for ident in re.findall(r"dataset\.(?:uiId|flowId)='([^']+)'",product_code):
 if ident not in spec:errors.append('unmapped dynamic ID '+ident)
if not all(r['matches_manifest'] for r in rows):errors.append('input/skill hash changed')
result={'manifest_files_checked':len(rows),'immutable_hash_matches':sum(r['matches_manifest'] for r in rows),'root_lines':next(r['lines'] for r in rows if r['path'].endswith('AFY10400.jsp')),'markdown_files_checked':len(list(Path('artifacts').rglob('*.md'))),'prototype_root':roots[0],'external_network_constructs_found':False,'errors':errors,'limitations':['HTMLParser checks structure/attributes, not browser validity or layout.','No API calls, JSP runtime, legacy pixel comparison, browser interaction, keyboard, console or network monitor executed.','Date helper strict encoding remains unknown.']}
check.joinpath('static-report.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
print(json.dumps(result,ensure_ascii=False,indent=2))
raise SystemExit(bool(errors))
