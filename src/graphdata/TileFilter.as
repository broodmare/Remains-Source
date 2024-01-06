package graphdata
{
	import flash.utils.*;
	import flash.filters.BevelFilter;
	import flash.filters.GlowFilter;
	import flash.filters.DropShadowFilter;

    public class TileFilter //UTILITY CLASS
    {
        private static var tileFilter:Object = newTileFilter(); // Static constructor

        public function TileFilter()
        {

        }
        
        public static function getFilter(filterName:String):Array
        {
            var filter:Array = tileFilter[filterName];
            return filter;
        }
        
        private static function newTileFilter():Object
		{
            trace('TileFilter/newTileFilter() - TileFilter initialized.');
            var newFilterArray:Object = {};

            newFilterArray['potek']		    = [new BevelFilter(10,270,0,0,0,0.5,1,10,1,3), new GlowFilter(0,2,2,2,2,1,true)];
            newFilterArray['shad']			= [new DropShadowFilter(5,90,0,1,12,12,1,3)];
            newFilterArray['cont']			= [new GlowFilter(0,1,15,15,1,3,true)];
            newFilterArray['cont_metal']	= [new GlowFilter(0,1,2,2,2,1,true), new GlowFilter(0,1,15,15,1,3,true)];
            newFilterArray['cont_th']		= [new GlowFilter(0,1,5,5,1,3,true), new GlowFilter(0,2,2,2,2,1,true)];
            newFilterArray['plitka']		= [new BevelFilter(2,70,0xFFFFFF,0.5,0,0.5,2,2,1,1), new GlowFilter(0,0.5,5,5,1,3,false)];
            newFilterArray['dyrka']		    = [new DropShadowFilter(10,70,0,2,10,10,1,3,true), new BevelFilter(2,250,0xFFFFFF,0.7,0,0.7,3,3,1,1)];
            newFilterArray['cloud']		    = [new DropShadowFilter(5,90,0x375774,1,5,7,1,3,true), new BevelFilter(2,250,0xFFFFFF,0.7,0,0.7,3,3,1,1)];

            return newFilterArray;
		}
    }
}