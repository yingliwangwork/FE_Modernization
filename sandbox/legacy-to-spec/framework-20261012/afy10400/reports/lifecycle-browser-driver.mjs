import fs from 'node:fs/promises';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
const {chromium}=await import(pathToFileURL('/Users/cfh00911058/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright-core/index.mjs'));
const dir=path.resolve(process.argv[2]);
const prototype=path.join(dir,'artifacts/design/AF-AFY10400/prototypes/SCR-01.html');
const report={kind:'source-lifecycle-browser-check',checks:[],errors:[],networkAttempts:[],limits:['Synthetic keypress checks the source listener condition, not native Escape compatibility.','A focus-call observer verifies an attempt; it does not prove the operating system changed focus.','No legacy server or backend is executed.']};
report.runtimeHashes={};
for(const sub of ['prototypes','styles']){const folder=path.join(dir,'artifacts/design/AF-AFY10400',sub);for(const name of await fs.readdir(folder)){if(!/\.(html|js|css)$/.test(name))continue;const file=path.join(folder,name);report.runtimeHashes[path.relative(dir,file)]=createHash('sha256').update(await fs.readFile(file)).digest('hex');}}
const browser=await chromium.launch({headless:true});
try {
 const ctx=await browser.newContext({viewport:{width:1280,height:900},serviceWorkers:'block'});
 await ctx.route(/^https?:/,async route=>{report.networkAttempts.push(route.request().url());await route.abort();});
 async function newPage(){const p=await ctx.newPage();p.on('pageerror',e=>report.errors.push(e.message));return p;}
 let page=await newPage();
 await page.addInitScript(()=>{window.__focusAttempts=0;window.focus=()=>{window.__focusAttempts++;};});
 await page.goto(pathToFileURL(prototype).href);
 const focus={id:'cover-window-focus-attempt',source:'CSRUtil.js:321-326 active control type contains button',status:'PASS'};
 try {await page.locator('#exportBtn').click();focus.observed=await page.evaluate(()=>({activeType:document.activeElement.type,attempts:window.__focusAttempts}));assert(focus.observed.attempts>0,'Source-defined window focus attempt was omitted');}catch(e){focus.status='FAIL';focus.detail=e.message;} report.checks.push(focus);await page.close();
 page=await newPage();await page.goto(pathToFileURL(prototype).href);
 const drag={id:'detached-message-first-key-guard',source:'CSRUtil.js:1545-1555,1613-1625 detached message returns before stopping key',status:'PASS'};
 try {
  await page.locator('#custom-msg').fill('合成訊息');await page.locator('#show-custom').click();
  const box=await page.locator('#message-title').boundingBox();assert(box);
  const x=box.x+box.width/2,y=box.y+box.height/2;
  await page.mouse.move(x,y);await page.mouse.down();await page.mouse.move(x+50,y+30,{steps:3});
  assert.equal(await page.locator('#message').count(),0);
  drag.observed=await page.evaluate(()=>{let propagated=0;const observe=()=>{propagated++;};window.addEventListener('keypress',observe);const ev=new KeyboardEvent('keypress',{bubbles:true,cancelable:true,key:'Escape',keyCode:27});const accepted=document.dispatchEvent(ev);window.removeEventListener('keypress',observe);return{accepted,defaultPrevented:ev.defaultPrevented,propagated};});
  await page.mouse.up();assert(await page.locator('#message').isVisible());
  assert.equal(drag.observed.defaultPrevented,false,'Detached message must not cancel the first closing key');assert.equal(drag.observed.propagated,1,'Detached message must preserve key propagation');
 }catch(e){drag.status='FAIL';drag.detail=e.message;}report.checks.push(drag);
 report.status=report.checks.every(c=>c.status==='PASS')&&!report.errors.length&&!report.networkAttempts.length?'PASS':'FAIL';
}finally{await browser.close();await fs.mkdir(path.join(dir,'reports'),{recursive:true});await fs.writeFile(path.join(dir,'reports/lifecycle-browser.json'),JSON.stringify(report,null,2)+'\n');}
console.log(JSON.stringify(report));if(report.status!=='PASS')process.exitCode=1;
