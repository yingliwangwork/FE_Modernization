function stat(){
var a = pageYOffset+window.innerHeight-document.getElementById('bar1').height-15;
document.getElementById('bar1').top = a;
setTimeout('stat()',2);
}
function fix(){
nome=navigator.appName;
if(nome=='Netscape'){
stat();
}
else{
var a=document.body.scrollTop-document.getElementById('bar1').offsetHeight+30;
document.getElementById('bar1').style.top = a;
}}