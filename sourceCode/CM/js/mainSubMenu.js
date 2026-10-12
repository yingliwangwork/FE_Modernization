/**
 * 連動式下拉選單
 *
 * @author sophiadeng
 * @version 1.0
 * @since 2005-09-29
 */

/**
 * 載入主選單內容，同時初始化次選單內容
 * @param master 主選單物件
 * @param detail 次選單物件
 * @param defaultValue 次選單預設值(可以不設)
 */
function loadMenu( master, detail, defaultValue ) {
    master.options.length = mainMenu.length;
    for( i = 0; i < mainMenu.length; i++ ) {
        master.options[ i ] = new Option( mainMenu[i][0], mainMenu[i][1] );  // Option( text , value );
    }
  
    if(defaultValue!=null && defaultValue.length!=0) {
  	    initSubMenu(master, detail, defaultValue) ;
    } else {
        master.selectedIndex = 0;
        changeMenu( master, detail );
    }
}

/**
 * 載入主選單內容，同時初始化次選單內容
 * @param master 主選單物件
 * @param detail 次選單物件
 * @param mainMenuName 主選單內容的變數名稱
 * @param subMenuName 次選單內容的變數名稱
 * @param defaultValue 次選單預設值(可以不設)
 */
function loadMenuByName( master, detail, mainMenuName, subMenuName, defaultValue ) {
    mainMenu = eval(mainMenuName);
    subMenu = eval(subMenuName);

    master.options.length = mainMenu.length;
    for( i = 0; i < mainMenu.length; i++ ) {
        master.options[ i ] = new Option( mainMenu[i][0], mainMenu[i][1] );  // Option( text , value );
    }
  
    if(defaultValue!=null && defaultValue.length!=0) {
  	    initSubMenuByName(master, detail, mainMenuName, subMenuName, defaultValue) ;
    } else {
        master.selectedIndex = 0;
        changeMenuByName( master, detail, mainMenuName, subMenuName );
    }
}





/**
 * 當主選單異動時，變更次選單內容
 * @param master 主選單物件
 * @param detail 次選單物件
 * @param defaultValue 次選單預設值(可以不設)
 */
function changeMenu( master, detail,defaultValue ) {
    detail.options.length = subMenu[ master.selectedIndex ].length;
    for( i = 0; i < subMenu[ master.selectedIndex ].length; i++ ) {
        detail.options[ i ] = new Option( subMenu[ master.selectedIndex ][ i ][0],
                                          subMenu[ master.selectedIndex ][ i ][1] );
    
        detail.options[ i ].selected=(defaultValue==subMenu[ master.selectedIndex ][i][1] ) ;
    }
}


/**
 * 當主選單異動時，變更次選單內容
 * @param master 主選單物件
 * @param detail 次選單物件
 * @param defaultValue 次選單預設值(可以不設)
 */
function changeMenuByName( master, detail, mainMenuName, subMenuName, defaultValue ) {

    mainMenu = eval(mainMenuName);
    subMenu = eval(subMenuName);
    
    detail.options.length = subMenu[ master.selectedIndex ].length;
    for( i = 0; i < subMenu[ master.selectedIndex ].length; i++ ) {
        detail.options[ i ] = new Option( subMenu[ master.selectedIndex ][ i ][0],
                                          subMenu[ master.selectedIndex ][ i ][1] );
    
        detail.options[ i ].selected=(defaultValue==subMenu[ master.selectedIndex ][i][1] ) ;
    }
}



/*
 * 依據預設值顯示主選單次選單
 * 若找不到符合預設值的選項,return false
 * @param master 主選單物件
 * @param detail 次選單物件
 * @param defaultValue 次選單預設值
 * 
 */
function initSubMenu(master, detail, defaultValue) {
    for(var i=0;i<subMenu.length;i++) {
    	for(var j=0;j<subMenu[i].length;j++) {
    	    if(subMenu[i][j][1]==defaultValue) {
    	        master.selectedIndex = i;
    	        changeMenu(master, detail, defaultValue);
    	        return true;
    	    }
    	}
    }
    return false;
}

/*
 * 依據預設值顯示主選單次選單
 * 若找不到符合預設值的選項,return false
 * @param master 主選單物件
 * @param detail 次選單物件
 * @param defaultValue 次選單預設值
 * 
 */
function initSubMenuByName(master, detail, mainMenuName, subMenuName, defaultValue) {

    mainMenu = eval(mainMenuName);
    subMenu = eval(subMenuName);

    for(var i=0;i<subMenu.length;i++) {
    	for(var j=0;j<subMenu[i].length;j++) {
    	    if(subMenu[i][j][1]==defaultValue) {
    	        master.selectedIndex = i;
    	        changeMenuByName(master, detail, mainMenuName, subMenuName, defaultValue);
    	        return true;
    	    }
    	}
    }
    return false;
}
