try {
	var hostname = location.hostname;
	if(hostname.indexOf('twww.cathaylife')!=-1 || hostname.indexOf('tcampaigns.cathaylife')!=-1 || hostname.indexOf('tcampaign.cathaylife')!=-1 || hostname.indexOf('tonline.cathaylife')!=-1 || hostname.indexOf('tmycrm.cathaylife')!=-1 || hostname.indexOf('tlinemsg.cathaylife')!=-1 || hostname.indexOf('tagent2.cathaylife')!=-1 || hostname.indexOf('tpatron.cathaylife')!=-1)
	{
		var jsFile = document.createElement("script");
		jsFile.setAttribute("type","text/javascript");
		jsFile.setAttribute("src", "https://twww.cathaylife.com.tw/website/PFWeb/js/common/CelebrusInsert_t.js");
		document.getElementsByTagName("body")[0].appendChild(jsFile);
	}else if(hostname.indexOf('swww.cathaylife')!=-1 || hostname.indexOf('scampaigns.cathaylife')!=-1 || hostname.indexOf('scampaign.cathaylife')!=-1 || hostname.indexOf('sonline.cathaylife.com.tw')!=-1  || hostname.indexOf('smycrm.cathaylife')!=-1 || hostname.indexOf('slinemsg.cathaylife')!=-1 || hostname.indexOf('sagent2.cathaylife')!=-1 || hostname.indexOf('spatron.cathaylife')!=-1)
	{	
		var jsFile = document.createElement("script");
		jsFile.setAttribute("type","text/javascript");
		jsFile.setAttribute("src", "https://swww.cathaylife.com.tw/website/PFWeb/js/common/CelebrusInsert_s.js");
		document.getElementsByTagName("body")[0].appendChild(jsFile);
	}else
	{
		var jsFile = document.createElement("script");
		jsFile.setAttribute("type","text/javascript");
		jsFile.setAttribute("src", "https://www.cathaylife.com.tw/website/PFWeb/js/common/CelebrusInsert_p.js");
		document.getElementsByTagName("body")[0].appendChild(jsFile);
	}
}catch(err) {
		
}