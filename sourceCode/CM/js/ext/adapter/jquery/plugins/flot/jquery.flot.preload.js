//block:
//Flot plugin for preprocessing data. Controlled through the option
//"axisKey" in either the global series options
/**
*  series: {
*    axisKey: {
*      x : String
*      y : String
*	   xmode : String
*	   label : String
*    }
*  }
*
* or in a specific series
*
*  $.plot($("#placeholder"), [{ data: [ ... ], axisKey:{ x , y , label }: { ... }}])
*
* @author adinKen
* @version 1.00
**/

(function ($) {
    var options = {
        series: { axisKey: null } // or { axisKey: { x : String , y : String , label : String , xmode : String}}
    };
    
    function init(plot) {
        function preload( plot , s , data ) {
			if (!s.axisKey)
                return data;
            	
			var label = s.axisKey.label ;
			  
			function dateTotime( value ){
				var date = value.split("-");    //YYYY-MM-DD
				var newDate = date[0] + "/" + date[1] + "/" + date[2]+" 8:00:00";
				return new Date(newDate).getTime();
			}
			
			var returnData = [];
			
			if( label ){
				var group = {};
				
				for(var i=0 ; i< data.length ; i++){
					var record = data[i];
					var x = record[s.axisKey.x];
					var y = record[s.axisKey.y];
					
					if( s.axisKey.xmode == "date" ){
						x = dateTotime(x);
					}
					
					if( group[record[label]] ){
						group[record[label]].data.push([x , y]);
						group[record[label]].records.push(record);
					}else{
						group[record[label]] = { label : record[label] , data : [[ x , y]] , records: [record] };	
					}	
				}
				
				for(var key in group ){	
					returnData.push( group[key] );
				}
				
				plot.data = returnData;
			}else{
				for(var i=0 ; i< data.length ; i++){
					var x = data[i][s.axisKey.x];
					var y = data[i][s.axisKey.y];
					
					if( s.axisKey.xmode == "date" ){
						x = dateTotime(x);
					}
					
					returnData.push( [ x , y ]);	
				}
				plot.data = returnData;
			}		
        }
        
        plot.hooks.preprocessRawData.push(preload);
    }
    
    $.plot.plugins.push({
        init: init,
        options: options,
        name: 'preload',
        version: '1.0'
    });
})(jQuery);
