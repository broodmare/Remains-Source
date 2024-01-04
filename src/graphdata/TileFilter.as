package graphdata
{
	import flash.utils.*;
	import flash.filters.BevelFilter;
	import flash.filters.GlowFilter;
	import flash.filters.DropShadowFilter;

    public class TileFilter
    {
        private static var tileFilter:Object;
        private static var initialized:Boolean = false;

        public function TileFilter()
        {
            if (!initialized)
            {
                tileFilterSetup();
                initialized = true;
            }
        }
        
        public static function getFilter(filterName:String):Array 
        {
            if (!initialized)
            {
                trace('TileFilter.as/getFilter() - getFilter() Called before tileFilter list exists, creating...');
                tileFilterSetup();
                initialized = true;
            }
            var result:Array = [];
            try
            {
                result = tileFilter[filterName];
                
            }
            catch (err)
            {
                trace('TileFilter.as/TileFilter() - Could not return tileFiler: "' + filterName + '." Error:' + err.message);
            }
            return result;
        }
        
        private static function tileFilterSetup():void
		{
            trace('TileFilter.as/tileFilterSetup() - tileFilter list object is being created and intialized.');
            tileFilter = {};

            //Changes to the names of these need to be updated in AllData.XML as well.
            tileFilter['potek']		    = [new BevelFilter(10,270,0,0,0,0.5,1,10,1,3), new GlowFilter(0,2,2,2,2,1,true)];
            tileFilter['shad']			= [new DropShadowFilter(5,90,0,1,12,12,1,3)];
            tileFilter['cont']			= [new GlowFilter(0,1,15,15,1,3,true)];
            tileFilter['cont_metal']	= [new GlowFilter(0,1,2,2,2,1,true), new GlowFilter(0,1,15,15,1,3,true)];
            tileFilter['cont_th']		= [new GlowFilter(0,1,5,5,1,3,true), new GlowFilter(0,2,2,2,2,1,true)];
            tileFilter['plitka']		= [new BevelFilter(2,70,0xFFFFFF,0.5,0,0.5,2,2,1,1), new GlowFilter(0,0.5,5,5,1,3,false)];
            tileFilter['dyrka']		    = [new DropShadowFilter(10,70,0,2,10,10,1,3,true), new BevelFilter(2,250,0xFFFFFF,0.7,0,0.7,3,3,1,1)];
            tileFilter['cloud']		    = [new DropShadowFilter(5,90,0x375774,1,5,7,1,3,true), new BevelFilter(2,250,0xFFFFFF,0.7,0,0.7,3,3,1,1)];

		}
    }
}