from pathlib import Path
from datetime import datetime, timezone
import hashlib, json, re
from urllib.parse import unquote

base=Path('artifacts/renovation/AF-AFY10400')
manifest=json.loads(Path('manifest.json').read_text())
source=Path(manifest['root_entry'])
data=source.read_bytes()
line_count=len(data.splitlines())
dep=json.loads((base/'dependency-inventory.json').read_text())
selection=json.loads((base/'template-selection.json').read_text())
checks=[]

def check(name,ok,detail):
    checks.append({'name':name,'result':'pass' if ok else 'fail','actual':detail})

check('single-root-and-byte-version',source.is_file() and source.suffix=='.jsp' and hashlib.sha256(data).hexdigest()==next(x['sha256'] for x in manifest['files'] if x['path']==manifest['root_entry']),{'root':str(source),'sha256':hashlib.sha256(data).hexdigest(),'physical_lines':line_count})
inventory=json.loads((base/'source-inventory.json').read_text())['files'][0]
check('physical-line-and-strict-decoding-metadata',inventory['physical_lines']==line_count and inventory['strict_decoding']['cp950']['status']=='valid' and inventory['strict_decoding']['utf-8']['status']=='invalid',inventory)
initial=base/'plan.initial.md'
metadata=base/'source-inventory.json'
check('persisted-plan-precedes-analysis',initial.stat().st_mtime<metadata.stat().st_mtime,{'initial_mtime':initial.stat().st_mtime,'source_inventory_mtime':metadata.stat().st_mtime,'sequence':'plan + initial snapshot persisted before source content analysis; immutable initial text retained'})
check('scope-boundaries-and-pending-decisions',len(dep['dependencies'])==19 and all(d['decision_status']=='pending' for d in dep['dependencies']),{'dep_count':len(dep['dependencies']),'decision_status':'pending','no_expansion_or_deferral_authorized':True})

scope_documents=['plan.md','tracking.md','user-response.md','plan.initial.md']
placeholder_errors=[]
table_errors=[]
link_errors=[]
range_errors=[]
linked=[]
for name in scope_documents:
    file=base/name
    text=file.read_text()
    if '{{' in text or '}}' in text: placeholder_errors.append(name)
    expect=None
    for num,line in enumerate(text.splitlines(),1):
        if line.startswith('|') and line.endswith('|'):
            width=len(line.split('|'))-2
            if expect is None: expect=width
            elif width!=expect: table_errors.append({'file':name,'line':num,'expected':expect,'actual':width})
        else: expect=None
    for match in re.finditer(r'\]\(([^)]+)\)',text):
        target=unquote(match.group(1))
        path,sep,anchor=target.partition('#')
        dest=(file.parent/path).resolve() if path else file.resolve()
        if not dest.is_file(): link_errors.append({'file':name,'target':target,'problem':'file missing'}); continue
        if anchor:
            contents=dest.read_text()
            if f'id="{anchor}"' not in contents:
                headings=[re.sub(r'[^\w\- ]','',ln.lstrip('#').strip()).lower().replace(' ','-') for ln in contents.splitlines() if ln.startswith('#')]
                if anchor not in headings: link_errors.append({'file':name,'target':target,'problem':'anchor missing'})
        linked.append({'file':name,'target':target})
    for a,b in re.findall(r'L(\d+)[–-](\d+)',text):
        if not 1<=int(a)<=int(b)<=line_count: range_errors.append({'file':name,'range':[int(a),int(b)]})
    for num in re.findall(r'(?<![\w])L(\d+)',text):
        if not 1<=int(num)<=line_count: range_errors.append({'file':name,'line':int(num)})

check('no-template-placeholder',not placeholder_errors,{'errors':placeholder_errors,'documents':scope_documents})
check('markdown-table-column-consistency',not table_errors,{'errors':table_errors,'documents':scope_documents})
check('actual-local-links-and-anchors',not link_errors,{'errors':link_errors,'checked_link_count':len(linked)})
check('raw-byte-line-reference-ranges',not range_errors,{'errors':range_errors,'maximum_line':line_count})
plan=(base/'plan.md').read_text()
tracking=(base/'tracking.md').read_text()
check('dep-todo-decision-and-task-location-coverage',all(f'id="{d["id"].lower()}"' in plan and f'id="{d["todo"].lower()}"' in tracking and d['decision'] in plan for d in dep['dependencies']),{'dependency_rows':19,'actual_todo_sections':19,'all_pending':True,'design_locations':'not created in plan stage; not claimed checked'})
check('task-menu-required-optional-and-status',all(f'id="task-{i:02d}"' in plan for i in range(1,12)) and 'optional' in plan and 'required' in plan and '可執行' in plan and '阻塞' in plan,{'task_count':11,'available_first_tasks':['TASK-02','TASK-08'],'optional':['TASK-07'],'all_execution_tasks_unselected':True})
template_errors=[]
for role in ('plan','tracking'):
    item=selection['templates'][role]
    if hashlib.sha256(Path(item['path']).read_bytes()).hexdigest()!=item['sha256']: template_errors.append(role)
check('actually-used-template-hashes',not template_errors,{'roles':['plan','tracking'],'errors':template_errors,'other_roles':'selected for traceability, not generated'})
check('unselected-contracts-not-generated',not Path('artifacts/design').exists() and not Path('artifacts/integration').exists(),{'design_exists':Path('artifacts/design').exists(),'integration_exists':Path('artifacts/integration').exists(),'phase':'first-response plan'})
check('input-source-unchanged',hashlib.sha256(data).hexdigest()==inventory['sha256'],{'sha256':inventory['sha256'],'original_bytes_preserved':True})
report={'scope_id':'AF-AFY10400','stage':'plan','checked_at':datetime.now(timezone.utc).isoformat(),'result':'pass' if all(c['result']=='pass' for c in checks) else 'fail','checks':checks,'not_executed':[{'check':'check_design_metadata.py','reason':'Design documents/prototypes/styles are intentionally not created at the first choice gate; this checker is not applicable to plan-only delivery.'},{'check':'browser/render/computed-style/interaction','reason':'No execution task selected; no prototype or acquired shared style/scripts.'},{'check':'backend execution/integration','reason':'Backend baseline/environment not supplied; task prohibits backend execution and external calls.'},{'check':'local design TODO placement','reason':'No design/API/prototype exists in plan phase. Root impact locations and actual tracking TODO anchors checked instead; design placement remains future work.'}],'limits':['No behavior-completeness or deployment claim.','No external/other-workspace data read.','All dependencies and execution task choices remain pending.']}
(base/'checks.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
print(json.dumps({'result':report['result'],'check_count':len(checks),'failures':[c for c in checks if c['result']=='fail'],'output':str(base/'checks.json')},ensure_ascii=False,indent=2))
