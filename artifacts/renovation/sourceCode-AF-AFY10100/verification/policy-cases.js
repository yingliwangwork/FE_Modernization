async(page)=>{
 const records=[];const check=async(id,actual,ok)=>{records.push({id,actual,result:ok?'PASS':'FAIL'});await page.evaluate(v=>window.__afyPolicyResults=v,records);if(!ok)throw new Error('Failed '+id);};
 await page.goto('http://127.0.0.1:8765/prototypes/SCR-01.html?policy=Y');
 await page.clock.install();
 await page.evaluate(()=>{window.__prevented=[];window.addEventListener('keydown',e=>{if(e.ctrlKey)window.__prevented.push({code:e.keyCode,prevented:e.defaultPrevented});},true);});
 page.once('dialog',async d=>{await d.accept();});await page.keyboard.press('Control+A');
 await check('AC-22/CtrlA',await page.evaluate(()=>window.__prevented),await page.evaluate(()=>window.__prevented.some(x=>x.code===65&&x.prevented)));
 await page.evaluate(()=>{document.getElementById('review-output').textContent='';const a=document.getElementById('review-output');a.textContent='A';const range=document.createRange();range.selectNodeContents(a);window.getSelection().removeAllRanges();window.getSelection().addRange(range);document.body.dispatchEvent(new Event('copy',{bubbles:true,cancelable:true}));});
 let first=JSON.parse(await page.locator('#review-output').textContent());await check('AC-23/A',first,first.boundary==='BOUND-08'&&first.encodedCopyContent==='A');
 await page.clock.fastForward(30000);
 await page.evaluate(()=>{const a=document.getElementById('review-output');a.textContent='B';const range=document.createRange();range.selectNodeContents(a);window.getSelection().removeAllRanges();window.getSelection().addRange(range);document.body.dispatchEvent(new Event('copy',{bubbles:true,cancelable:true}));});
 let second=JSON.parse(await page.locator('#review-output').textContent());await check('AC-23/B',second,second.encodedCopyContent==='B');
 await page.clock.fastForward(29000);
 await page.evaluate(()=>{const a=document.getElementById('review-output');a.textContent='B';const range=document.createRange();range.selectNodeContents(a);window.getSelection().removeAllRanges();window.getSelection().addRange(range);document.body.dispatchEvent(new Event('copy',{bubbles:true,cancelable:true}));});
 await check('AC-23/B-before-old-timer',await page.locator('#review-output').textContent(),await page.locator('#review-output').textContent()==='B');
 await page.clock.fastForward(2000);
 await page.evaluate(()=>{const a=document.getElementById('review-output');a.textContent='B';const range=document.createRange();range.selectNodeContents(a);window.getSelection().removeAllRanges();window.getSelection().addRange(range);document.body.dispatchEvent(new Event('copy',{bubbles:true,cancelable:true}));});
 let third=JSON.parse(await page.locator('#review-output').textContent());await check('AC-23/B-after-old-timer',third,third.boundary==='BOUND-08'&&third.encodedCopyContent==='B');
 await page.emulateMedia({media:'print'});let printing=await page.evaluate(()=>({bodyChild:getComputedStyle(document.getElementById('product')).display,after:getComputedStyle(document.body,'::after').content}));await check('AC-22/print',printing,printing.bodyChild==='none'&&printing.after.includes('依據資安政策，不開放列印功能'));await page.emulateMedia({media:'screen'});
 await page.goto('http://127.0.0.1:8765/prototypes/SCR-01.html?subsystem=DS');let message='';page.once('dialog',async dialog=>{message=dialog.message();await dialog.accept();});await page.locator('#btn_async').click();await check('AC-17/DS',message,message.includes('檢核錯誤如下:')&&message.includes('身份證字號/統一編號：不得為空值'));
 await page.goto('http://127.0.0.1:8765/prototypes/SCR-01.html');await page.evaluate(v=>window.__afyPolicyResults=v,records);return records;
}