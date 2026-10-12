import fs from 'node:fs/promises';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
const {marked} = await import(pathToFileURL('/Users/cfh00911058/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/marked/lib/marked.esm.js'));
const root=process.cwd();
const source=path.join(root,'docs/legacy-to-spec-manual.md');
const target=path.join(root,'docs/legacy-to-spec-manual.html');
const md=await fs.readFile(source,'utf8');
const escape=value=>value.replaceAll('&','&amp;').replaceAll('<','&lt;').replaceAll('>','&gt;').replaceAll('"','&quot;');
const chapters=[];
let body=marked.parse(md,{gfm:true});
body=body.replace(/<h2>(.*?)<\/h2>/g,(_,title)=>{
 const text=title.replace(/<[^>]*>/g,'');
 const id=text.toLowerCase().replace(/[^\p{L}\p{N}_\- ]/gu,'').replaceAll(' ','-');
 if (/^\d+\./.test(text)) chapters.push({title:text,id});
 return '<h2 id="'+escape(id)+'">'+title+'</h2>';
});
body=body.replace(/<h2 id="目錄">目錄<\/h2>\s*(<ul>[\s\S]*?<\/ul>)/,(_,list)=>'<details class="inline-toc" id="目錄"><summary>查看全部章節</summary>'+list+'</details>');
let codeCount=0;
body=body.replace(/<pre><code(.*?)>([\s\S]*?)<\/code><\/pre>/g,(_,attrs,code)=>{
 codeCount++;
 const language=(attrs.match(/language-([a-z]+)/)?.[1]||'text').toUpperCase();
 return '<div class="code-box"><div class="code-bar"><span>'+language+'</span><button type="button" class="copy-button" aria-label="複製範例 '+codeCount+'">複製</button></div><pre><code'+attrs+'>'+code+'</code></pre></div>';
});
body=body.replace(/<table>/g,'<div class="table-wrap" role="region" aria-label="資料對照表" tabindex="0"><table>').replace(/<\/table>/g,'</table></div>');
const nav=chapters.map(row=>'<a href="#'+escape(row.id)+'">'+escape(row.title)+'</a>').join('\n');
const html=`<!doctype html>
<html lang="zh-Hant">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="description" content="Legacy to Spec skill 操作手冊：單一 JSP 翻新、依賴決策、樣式雙份交付、客製化、驗證與續作。">
<title>Legacy to Spec · 操作手冊</title>
<style>
:root{color-scheme:light;--ink:#18352c;--muted:#5a6c64;--accent:#167657;--line:#dbe4de;--paper:#fff;--canvas:#f3f6f3;--sidebar:#17392e}
*{box-sizing:border-box}html{scroll-behavior:smooth;scroll-padding-top:24px}body{margin:0;background:var(--canvas);color:var(--ink);font:16px/1.8 -apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif}a{color:#116c50;text-underline-offset:3px}a:hover{text-decoration-thickness:2px}a:focus-visible,button:focus-visible,summary:focus-visible,[tabindex]:focus-visible{outline:3px solid #dfac43;outline-offset:4px}button{font:inherit;cursor:pointer}.skip-link{position:fixed;left:16px;top:12px;z-index:3;padding:10px 18px;background:#fff;transform:translateY(-170%)}.skip-link:focus{transform:translateY(0)}
.layout{display:grid;grid-template-columns:278px minmax(0,1fr);min-height:100vh}.sidebar{position:sticky;top:0;height:100vh;overflow-y:auto;background:var(--sidebar);color:#e6f1eb;padding:32px 23px}.brand{margin:0;font-size:20px;font-weight:720;line-height:1.35}.brand small{display:block;font-size:12px;letter-spacing:.14em;color:#b5d0c1;margin-bottom:9px}.side-note{font-size:13px;line-height:1.7;color:#bdd1c5;margin:18px 0 27px}.sidebar summary{font-size:14px;font-weight:600;cursor:pointer;list-style:none}.sidebar summary::-webkit-details-marker{display:none}.toc-wrap nav{display:grid;gap:4px;margin-top:12px}.toc-wrap a{color:#d0e3d7;text-decoration:none;line-height:1.65;font-size:14px;padding:9px 11px;border-radius:6px;border-left:3px solid transparent}.toc-wrap a:hover,.toc-wrap a[aria-current]{background:#285342;color:#fff;border-left-color:#9cd6b8}.side-foot{font-size:12px;color:#bdd1c5;margin-top:32px;padding-top:18px;border-top:1px solid #476154}.side-foot a{color:#e1efdf}
main{min-width:0;width:100%;max-width:1190px;margin:0 auto;padding:38px clamp(22px,4vw,64px) 70px}.top-bar{display:flex;gap:12px;align-items:center;justify-content:space-between;margin-bottom:22px}.eyebrow{font-size:12px;letter-spacing:.12em;color:var(--muted);font-weight:650;margin:0}.tools{display:flex;gap:9px;align-items:center;flex-wrap:wrap}.tools a,.tools button{border:1px solid var(--line);border-radius:6px;background:#fff;padding:7px 12px;text-decoration:none;color:var(--ink);font-size:13px;line-height:1.5}.flow{display:grid;grid-template-columns:repeat(6,minmax(0,1fr));gap:7px;padding:0;margin:0 0 28px;list-style:none}.flow li{padding:12px 9px;border:1px solid var(--line);background:#e8f0e9;border-radius:7px;line-height:1.5;font-size:12px}.flow span{display:block;color:var(--muted);font-size:10px;letter-spacing:.1em;margin-bottom:4px}.article{padding:30px clamp(22px,3vw,38px) 40px;background:var(--paper);border:1px solid var(--line);border-radius:12px;box-shadow:0 6px 24px #18352c06}.article h1{font-size:clamp(27px,3.3vw,40px);line-height:1.3;letter-spacing:-.035em;margin:0 0 16px}.article h1+p{color:var(--muted);font-size:17px}.article h2{font-size:25px;line-height:1.5;margin:48px 0 18px;padding-top:30px;border-top:1px solid var(--line);scroll-margin-top:24px}.inline-toc{margin:25px 0;padding:12px 16px;background:#f3f7f1;border:1px solid var(--line);border-radius:7px}.inline-toc summary{cursor:pointer;font-size:14px;font-weight:600}.inline-toc ul{columns:2}.article h3{font-size:18px;margin:28px 0 12px;line-height:1.6}.article p{margin:13px 0}.article ul,.article ol{padding-left:25px;margin:14px 0}.article li{padding-left:3px;margin:5px 0}.article strong{font-weight:700}.article :not(pre)>code{font-size:.88em;border:1px solid #e3eae5;border-radius:4px;background:#f2f5f1;padding:2px 5px;overflow-wrap:anywhere;font-family:ui-monospace,SFMono-Regular,Consolas,monospace}.table-wrap{max-width:100%;overflow-x:auto;margin:18px 0;border:1px solid var(--line);border-radius:8px}.table-wrap:focus-visible{outline-offset:2px}table{border-collapse:collapse;width:100%;min-width:560px;font-size:14px;line-height:1.75}th,td{text-align:left;vertical-align:top;border-bottom:1px solid var(--line);padding:12px 14px}th{background:#eef4ee;font-weight:650;color:#21493b}tr:last-child td{border-bottom:0}tbody tr:nth-child(even){background:#fafcf9}.code-box{margin:18px 0;border:1px solid #d6e0d8;border-radius:8px;overflow:hidden;background:#162f27;color:#e4f1e5}.code-bar{display:flex;justify-content:space-between;align-items:center;padding:7px 12px;border-bottom:1px solid #3b5347;background:#1e3c30;font-size:11px;letter-spacing:.08em}.copy-button{font-size:12px;letter-spacing:0;border:1px solid #607c69;border-radius:4px;color:#e8f3e8;background:#2b4c3c;padding:3px 10px}.copy-button:hover{background:#3b604b}pre{margin:0;padding:17px;max-width:100%;overflow-x:auto;font-size:13px;line-height:1.8}pre code{font-family:ui-monospace,SFMono-Regular,Consolas,monospace;white-space:pre-wrap;overflow-wrap:anywhere;tab-size:2}.article input[type=checkbox]{accent-color:var(--accent);margin-right:6px}.article ul:has(input[type=checkbox]){list-style:none;padding-left:2px}.page-foot{font-size:12px;color:var(--muted);margin-top:22px}.status{position:fixed;right:20px;bottom:20px;max-width:calc(100vw - 40px);font-size:13px;background:#183d2e;color:#fff;padding:11px 16px;border-radius:6px;box-shadow:0 3px 10px #0002}.status:empty{display:none}
@media(min-width:901px){.sidebar summary{pointer-events:none}}
@media(max-width:900px){.layout{display:block}.sidebar{position:static;height:auto;overflow:visible;padding:20px 24px}.brand{font-size:18px}.brand small{font-size:11px;display:inline;margin-right:12px}.side-note,.side-foot{display:none}.sidebar summary{padding:12px 0 0}.sidebar summary:after{content:" ＋";float:right}.toc-wrap[open] summary:after{content:" −"}.toc-wrap nav{grid-template-columns:repeat(2,minmax(0,1fr));gap:5px}.toc-wrap a{font-size:13px}.top-bar{margin-bottom:18px}main{padding:24px 16px 45px}.article{padding:24px 18px}.article h2{font-size:22px;margin-top:36px}.flow{grid-template-columns:repeat(3,minmax(0,1fr));gap:6px}.flow li{padding:10px}.tools a,.tools button{padding:6px 9px;font-size:12px}.eyebrow{font-size:10px}.inline-toc ul{columns:1}.table-wrap table{min-width:540px}pre{font-size:12px;padding:13px}}
@media(max-width:440px){.top-bar{align-items:flex-start;gap:8px}.eyebrow{max-width:120px}.tools{justify-content:flex-end}.toc-wrap nav{grid-template-columns:1fr}.article h1{font-size:27px}.article h1+p{font-size:16px}}
@media(prefers-reduced-motion:reduce){html{scroll-behavior:auto}}
@media print{@page{size:A4;margin:15mm}html{scroll-behavior:auto}body{background:#fff;color:#000;font-size:10pt;line-height:1.6}.layout{display:block}.sidebar,.top-bar,.flow,.copy-button,.status,.skip-link,.page-foot,.inline-toc{display:none!important}main{padding:0;max-width:none}.article{border:0;border-radius:0;box-shadow:none;padding:0}.article h1{font-size:23pt}.article h2{font-size:16pt;padding-top:18px;margin-top:26px;break-after:avoid}.article h3{font-size:12pt;break-after:avoid}.table-wrap{overflow:visible;max-width:none;break-inside:auto}table{min-width:0!important;font-size:9pt}th,td{padding:7px;overflow-wrap:anywhere}thead{display:table-header-group}tr{break-inside:avoid}.code-box{background:#fafafa;color:#000;break-inside:auto}.code-bar{background:#eee;color:#000;border-color:#ccc}pre{font-size:8.5pt}a{color:#000}a[href^="http"]:after{content:" (" attr(href) ")";font-size:8pt}.article :not(pre)>code{background:#f7f7f7}}
</style>
</head>
<body>
<a class="skip-link" href="#main-content">跳到手冊內容</a>
<div class="layout">
<aside class="sidebar" aria-label="手冊導覽">
<p class="brand"><small>LEGACY TO SPEC</small>使用與維護</p>
<p class="side-note">一個入口、一組可追溯契約。從計劃到驗證，逐步處理已知與缺口。</p>
<details class="toc-wrap" open><summary>章節目錄</summary><nav aria-label="章節">${nav}</nav></details>
<p class="side-foot">更新 2026-10-12<br><a href="../.agent/skills/legacy-to-spec/SKILL.md">檢視 skill 原則</a> · <a href="../README.md">專案說明</a></p>
</aside>
<main id="main-content" tabindex="-1">
<div class="top-bar"><p class="eyebrow">操作手冊 · 離線閱讀</p><div class="tools"><a href="legacy-to-spec-manual.md">Markdown 版</a><button id="print-manual" type="button">列印手冊</button></div></div>
<ol class="flow" aria-label="翻新六階段"><li><span>01</span>建立計劃</li><li><span>02</span>盤點依賴</li><li><span>03</span>選擇任務</li><li><span>04</span>建立契約</li><li><span>05</span>視覺成果</li><li><span>06</span>驗證追蹤</li></ol>
<article class="article">${body}</article>
<p class="page-foot">正文由 Markdown 版本生成。章節與複製功能在本機執行，沒有外部資源請求。</p>
</main>
</div>
<div id="copy-status" class="status" role="status" aria-live="polite"></div>
<script>
(() => {
 const contents=document.querySelector('.toc-wrap');
 const mobile=window.matchMedia('(max-width: 900px)');
 function layoutChanged(){contents.open=!mobile.matches;}
 layoutChanged();mobile.addEventListener('change',layoutChanged);
 document.getElementById('print-manual').addEventListener('click',()=>window.print());
 const status=document.getElementById('copy-status');
 let resetStatus;
 function say(text){status.textContent=text;clearTimeout(resetStatus);resetStatus=setTimeout(()=>{status.textContent='';},4500);}
 function fallbackCopy(text){
  const previous=document.activeElement;
  const field=document.createElement('textarea');field.value=text;field.setAttribute('readonly','');field.style.position='fixed';field.style.left='-9999px';document.body.appendChild(field);
  field.select();let copied=false;
  try{copied=document.execCommand('copy');}finally{field.remove();if(previous instanceof HTMLElement)previous.focus();}
  return copied;
 }
 document.querySelectorAll('.copy-button').forEach(button=>{
  button.addEventListener('click',async()=>{
   const text=button.closest('.code-box').querySelector('code').textContent.replace(/\\n$/,'');
   let copied=false;
   if(navigator.clipboard?.writeText){try{await navigator.clipboard.writeText(text);copied=true;}catch{}}
   if(!copied){try{copied=fallbackCopy(text);}catch{}}
   if(copied){button.textContent='已複製';say('已複製。請先改填指令中的輸入與路徑。');setTimeout(()=>{button.textContent='複製';},1800);}
   else{say('此瀏覽器未允許複製，請選取範例文字手動複製。');}
  });
 });
 const links=[...document.querySelectorAll('nav a')];
 const observer=new IntersectionObserver(entries=>{
  const visible=entries.filter(entry=>entry.isIntersecting).sort((a,b)=>a.boundingClientRect.top-b.boundingClientRect.top);
  if(!visible.length)return;
  const href='#'+visible[0].target.id;
  links.forEach(link=>{if(link.getAttribute('href')===href)link.setAttribute('aria-current','location');else link.removeAttribute('aria-current');});
 },{rootMargin:'-8% 0px -65% 0px'});
 document.querySelectorAll('article h2[id]').forEach(heading=>observer.observe(heading));
})();
</script>
</body>
</html>
`;
await fs.writeFile(target,html);
console.log(JSON.stringify({target,chapters:chapters.length,codeBlocks:codeCount,bytes:Buffer.byteLength(html)}));
