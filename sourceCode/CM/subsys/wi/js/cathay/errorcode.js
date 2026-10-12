function MajorErrorReason(rcode){
	switch(rcode){
		case 0x76000001:
			return "未輸入金鑰";
		case 0x76000002:
			return "未輸入憑證";
		case 0x76000003:
			return "未輸入待簽訊息";
		case 0x76000004:
			return "未輸入密文";
		case 0x76000005:
			return "未輸入函式庫檔案路徑";
		case 0x76000006:
			return "未插入IC卡";
		case 0x76000007:
			return "未登入";
		case 0x76000008:
			return "型態錯誤";
		case 0x76000009:
			return "檔案錯誤";
		case 0x7600000A:
			return "檔案過大";
		case 0x7600000B:
			return "JSON格式錯誤";
		case 0x7600000C:
			return "參數錯誤";
		case 0x7600000D:
			return "執行檔錯誤或逾時";
		case 0x7600000E:
			return "不支援的方法";
		case 0x7600000F:
			return "禁止存取的網域";
		case 0x76000998:
			return "未輸入PIN碼";
		case 0x76000999:
			return "使用者已取消動作";
		case 0x76100001:
			return "無法載入IC卡函式庫檔案";
		case 0x76100002:
			return "結束IC卡函式庫失敗";
		case 0x76100003:
			return "無可用讀卡機";
		case 0x76100004:
			return "取得讀卡機資訊失敗";
		case 0x76100005:
			return "取得session失敗";
		case 0x76100006:
			return "IC卡登入失敗";
		case 0x76100007:
			return "IC卡登出失敗";
		case 0x76100008:
			return "IC卡取得金鑰失敗";
		case 0x76100009:
			return "IC卡取得憑證失敗";
		case 0x7610000A:
			return "取得函式庫資訊失敗";
		case 0x7610000B:
			return "IC卡卡片資訊失敗";
		case 0x7610000C:
			return "找不到指定憑證";
		case 0x7610000D:
			return "找不到指定金鑰";
		case 0x76200001:
			return "pfx初始失敗";
		case 0x76200006:
			return "pfx登入失敗";
		case 0x76200007:
			return "pfx登出失敗";
		case 0x76200008:
			return "不支援的CA";
		case 0x76300001:
			return "簽章初始錯誤";
		case 0x76300002:
			return "簽章型別錯誤";
		case 0x76300003:
			return "簽章內容錯誤";
		case 0x76300004:
			return "簽章執行錯誤";
		case 0x76300005:
			return "簽章憑證錯誤";
		case 0x76300006:
			return "簽章DER錯誤";
		case 0x76300007:
			return "簽章結束錯誤";
		case 0x76300008:
			return "簽章驗證錯誤";
		case 0x76300009:
			return "簽章BIO錯誤";
		case 0x76400001:
			return "解密DER錯誤";
		case 0x76400002:
			return "解密型態錯誤";
		case 0x76400003:
			return "解密錯誤";
		case 0x76500001:
			return "憑證尚未生效";
		case 0x76500002:
			return "憑證已逾期";
		case 0x76600001:
			return "Base64編碼錯誤";
		case 0x76600002:
			return "Base64解碼錯誤";
		case 0x76700001:
			return "伺服金鑰解密錯誤";
		case 0x76700002:
			return "未登錄伺服金鑰";
		case 0x76700003:
			return "伺服金鑰加密錯誤";
		case 0x76210001:
			return "身分證字號或外僑號碼比對錯誤";
		case 0x76210002:
			return "未支援的憑證型別";
		case 0x76210003:
			return "非元大寶來憑證";
		case 0x76210004:
			return "非中華電信通用憑證管理中心發行之憑證";
		case -536870893: //0xE0000013
			return "金鑰不相符";
		case -536870894: //0xE0000012
			return "使用者取消";
		case -536870896: //0xE0000010
			return "建立金鑰容器失敗，可能是因為權限不足";
		case -536870897: //0xE000000F
			return "找不到任一家CA發的該類別用戶憑證，但中華電信該憑證類別中有找到其他用戶";
		case -536870898: //0xE000000E
			return "開啟物件(p7b)失敗";
		case -536870899: //0xE000000D
			return "HEX字串格式錯誤";
		case -536870900: //0xE000000C
			return "HEX字串長度錯誤";
		case -536870901: //0xE000000B
			return "寬位元字串轉多位元字串轉換失敗";
		case -536870902: //0xE000000A
			return "開啟CertStore失敗";
		case -536870903: //0xE0000009
			return "匯出檔案失敗";
		case -536870904: //0xE0000008
			return "匯入檔案失敗";
		case -536870905: //0xE0000007
			return "必須輸入檔案路徑";
		case -536870906: //0xE0000006
			return "找不到任一家CA發的該類別用戶憑證";
		case -536870907: //0xE0000005
			return "找不到中華電信該類別用戶憑證，但找得到其他CA發的該類別用戶憑證";
		case -536870908: //0xE0000004
			return "未支援的參加單位代碼";
		case -536870909: //0xE0000003
			return "金鑰的雜湊值不一致";
		case -536870910: //0xE0000002
			return "程式配置記憶體失敗";
		case -536870911: //0xE0000001
			return "找不到由中華電信所核發且合乎搜尋條件的憑證";
		default:
			return rcode ? rcode.toString(16) : rcode;
	}
}
function MinorErrorReason(rcode){
	switch(rcode){
		case 0x06:
			return "函式失敗";
		case 0xA0:
			return "PIN碼錯誤";
		case 0xA2:
			return "PIN碼長度錯誤";
		case 0xA4:
			return "已鎖卡";
		case 0x150:
			return "記憶體緩衝不足";
		case -2147483647:
			return "PIN碼錯誤，剩餘一次機會";
		case -2147483646:
			return "PIN碼錯誤，剩餘兩次機會";
		default:
			return rcode ? rcode.toString(16) : rcode;
	}
}
function VAErrorReason(rcode){
	switch(rcode){
		case 501:
			return '產生驗證模組錯誤'
		case 502:
			return '設定系統參數錯誤'
		case 503:
			return '沒有對應的驗證原則'
		case 1011:
			return '發行者憑證(CA)禁用'
		case 1012:
			return '解析憑證錯誤'
		case 1013:
			return '憑證驗證錯誤'
		case 1014:
			return '沒有設定憑證相關資訊(CAINFO)'
		case 1021:
			return '憑證過期'
		case 1022:
			return '憑證尚未有效'
		case 1030:
			return '憑證已經註銷，註銷原因未明'
		case 1031:
			return '憑證已經註銷，註銷原因為憑證金鑰遭破解'
		case 1032:
			return '憑證已經註銷，註銷原因為CA憑證金鑰遭破解'
		case 1033:
			return '憑證已經註銷，註銷原因為用戶身分變更'
		case 1034:
			return '憑證已經註銷，註銷原因為憑證已被另一張憑證取代(憑證內容變更時使用)'
		case 1035:
			return '憑證已經註銷，註銷原因為用戶不再需要使用憑證'
		case 1036:
			return '憑證已經註銷，註銷原因為憑證被暫禁'
		case 1039:
			return '憑證已經註銷，註銷原因為憑證授權的主體已經被撤銷'
		case 1040:
			return '憑證已經註銷，註銷原因為憑證金鑰遭破解(僅用於屬性憑證)'
		case 1041:
			return '搜尋可用的CRL資訊發生錯誤'
		case 1042:
			return '資料庫中不存在CRL發佈點資訊'
		case 1043:
			return '資料庫中儲存的CRL發佈點資訊設定為不使用狀態'
		case 1044:
			return '資料庫中儲存的CRL已過期'
		case 1045:
			return 'CRL未被下載'
		case 1051:
			return 'OCSP請求格式錯誤'
		case 1052:
			return 'OCSP內部處理發生錯誤'
		case 1053:
			return 'OCSP稍後重試'
		case 1055:
			return 'OCSP請求必須要簽章'
		case 1056:
			return 'OCSP尚未授權使用'
		case 1057:
			return 'OCSP回應解析發生錯誤'
		case 1058:
			return 'OCSP回應驗證發生錯誤'
		case 1059:
			return 'OCSP回應格式不符合'
		case 1060:
			return 'OCSP中的認證值不符'
		case 1061:
			return 'OCSP使用的金鑰用途錯誤'
		case 1062:
			return '憑證狀態不明'
		case 1063:
			return '找不到OCSP使用的憑證'
		case 1064:
			return '沒有指定OCSP的URL'
		case 1070:
			return '憑證的DN為NULL'
		case 1071:
			return '要求的DN為NULL'
		case 1072:
			return '憑證沒有包含必要的DN'
		case 1081:
			return '憑證使用非預期的金鑰用途'
		case 1082:
			return '解析憑證的延伸金鑰用途欄位發生錯誤'
		case 1083:
			return '憑證不存在需要的延伸金鑰用途'
		case 1091:
			return '憑證使用非預期的憑證政策'
		case 1100:
			return '憑證指定的OID物件不存在'
		case 1101:
			return '憑證找不到主體目錄屬性的OID'
		case 1102:
			return '憑證的主體目錄屬性不符合'
		case 1111:
			return '找不到憑證的主體別名'
		case 1121:
			return '找不到APPID資訊'
		case 1122:
			return '找不到使用者帳號'
		case 1123:
			return '使用者的密碼不正確'
		case 1124:
			return '沒有指定APPID參數'
		case 1125:
			return '沒有指定使用者帳號參數'
		case 1126:
			return '沒有指定使用者密碼參數'
		case 1130:
			return '未給定參數ClientCert (HSM對應之工商憑證)'
		case 1131:
			return '未給定參數KEYFILE (PFX位置，僅在非HSM->PFX會用到)'
		case 1132:
			return '未給定參數PASSWORD (HSM密碼錯誤)'
		case 1133:
			return '未給定參數IP (ICS Verify Server IP–ex: 61.60.9.50)'
		case 1134:
			return '未給定參數PORT (ICS Verify Server Port–ex: 443)'
		case 1135:
			return '未給定參數GCAURL (ICS Verify Server 用到的參數–ex: /cgi-bin/CheckSNPID/CheckSNPID)'
		case 1136:
			return '未給定參數SIGNTYPE (HSM簽章algorithm–ex: SHA1withRSA)'
		case 1137:
			return '未給定參數PID (欲驗證之身分證字號–ex: A123456789)'
		case 1138:
			return '初始化參數錯誤 (例如從HSM取出PrivateKey handle的值為null)'
		case 1139:
			return 'ICS驗證失敗'
		case 1140:
			return '驗證ICS發生其他錯誤'
		case 1141:
			return '未給定參數HSM key label'
		case 1142:
			return '從SafeNet HSM load private key失敗'
		case 1143:
			return '未給定參數HSM slot'
		case 1144:
			return 'HSM slot值非integer'
		case 1145:
			return 'Add SafeNet HSM Provider失敗'
		case 1146:
			return 'SafeNet HSM密碼解密失敗'
		case 1147:
			return '剖析Group/CertType(在SDA)失敗'
		case 1148:
			return '驗證PublicCA證券憑證失敗'
		case 2001:
			return '驗簽章失敗 (非簽章格式資料或是簽章錯誤)'
		case 2002:
			return '驗章核心功能發生不預期錯誤(如BouncyCastle library版本錯誤)，需搭配回傳message，才知為何錯誤。'
		case 2003:
			return '驗證憑證結果回傳NULL值'
		case 2004:
			return '剖析JSON格式錯誤'
		case 2005:
			return 'appID、type有值(非空白或NULL值)，且非integer格式'
		case 2006:
			return '只單驗Certificate的時候(如驗PKCS#7模式，即不會發生此exception)，傳入的byte array非certificate der code格式'
		case 2007:
			return '簽章時(signing time)的憑證已經過期'
		case 2008:
			return '寫Transaction Log進入database時，發生錯誤(請查詢資料庫是否異常)'
		case 2009:
			return 'Client端不具合法IP (可登入managers設定, 若設定*表示any)'
		case 2010:
			return '從http request中，抓取client端IP失敗'
		case 2099:
			return '其他未定義之驗章異常發生'
		case 3011:
			return '找不到APPINFO資訊'
		case 3012:
			return '找不到RULEINFO資訊'
		case 3013:
			return '找不到VALIDATORINFO資訊'
		case 3014:
			return '找不到CRLDOWNLOADINFO資訊'
		case 3015:
			return '找不到CAINFO資訊'
		case 3016:
			return '找不到CRLINFO資訊'
		case 3017:
			return '找不到SYSTEMINFO資訊'
		case 3018:
			return '找不到TRANSACTIONINFO資訊'
		case 3019:
			return '找不到USERINFO資訊'
		case 3021:
			return '找不到APPINFO服務'
		case 3022:
			return '找不到RULEINFO服務'
		case 3023:
			return '找不到VALIDATORINFO服務'
		case 3024:
			return '找不到CRLDOWNLOADINFO服務'
		case 3025:
			return '找不到CAINFO服務'
		case 3026:
			return '找不到CRLINFO服務'
		case 3027:
			return '找不到SYSTEMINFO服務'
		case 3028:
			return '找不到TRANSACTIONINFO服務'
		case 3029:
			return '找不到USERINFO服務'
		case 5011:
			return 'CRL解析或驗證發生錯誤'
		case 5012:
			return 'CRL下載IO錯誤(例如無法連線)'
		case 5013:
			return 'CA憑證解析發生錯誤'
		case 5014:
			return 'CRL檔案路徑(URI)錯誤'
		case 5015:
			return '已禁止CRL下載'
		case 5999:
			return 'CRL下載其他錯誤'
		case 7001:
			return 'Xml格式錯誤(剖析失敗)'
		case 7002:
			return '不存在Xml Signature Block'
		case 7003:
			return 'unmarshal the XMLSignature失敗(unmarshal:將Xml內容轉成java XMLSignature格式)'
		case 7004:
			return '執行core validate Xml signature(驗證Xml簽章+驗證refence digest)發生exception'
		case 7005:
			return 'core validate Xml signature (Xml簽章+驗證refence digest)失敗 (正常情況不會回此exception)'
		case 7006:
			return '執行validate xml signature發生exception'
		case 7007:
			return 'validate xml signature失敗'
		case 7008:
			return '執行validate Xml reference digest發生exception'
		case 7009:
			return 'Validate Xml reference digest失敗'
		case 7010:
			return '註冊IDs時，發生錯誤。'
		case 7011:
			return '對input 做Base64 decode失敗'
		case 7255:
			return '其他未定義之Xml Signature驗章異常發生'
		case 8001:
			return '找不到指定的CRL內容'
		case 8002:
			return 'CRL已逾期'
		case 8003:
			return 'CRL已停止下載'
		case 8004:
			return 'CRL下載發生錯誤'
		case 8005:
			return 'CRL從未下載'
		case 8006:
			return 'CRLCenter未初始化'
		default:
			return rcode ? rcode.toString(16) : rcode;
	}
}

	