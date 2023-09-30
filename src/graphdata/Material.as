package graphdata
{
	
	import flash.utils.*;
	import flash.filters.BevelFilter;
	import flash.filters.GlowFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.BitmapFilter;
	import flash.display.BitmapData;
	
	public class Material 
	{

		public var id:String;
		public var used:Boolean = false;
		public var texture:BitmapData;
		public var alttexture:BitmapData;
		public var border:BitmapData;
		public var floor:BitmapData;

		public var textureMask:Class;
		public var borderMask:Class;
		public var floorMask:Class;

		public var appliedFilters:Array; //What goes in here?

		public var rear:Boolean = false; //Is the material as a rear wall?
		public var slit:Boolean = false; 
		public var filterArray:Array;

		//Creating an array of filters. 
		//Changes to the names of these need to be updated in AllData.XML as well.
		



		//Material class setup.
		public function Material(material:XML) //input a material when constructing this...
		{
			var tempMaterial:XML = material;


			try 
			{
				arraySetup()
			}
			catch(err)
			{
				trace('error setting up filter array.')
			}

			try 
			{
				materialSetup(tempMaterial)
			}
			catch(err)
			{
				trace('error setting up material', tempMaterial.@id)
			}
		}



		public function materialSetup(material:XML):void
		{
			var tempMaterial:XML = material;

			id = tempMaterial.@id; //id of the material is the id of the material in the XML file.
			texture = World.w.grafon.getObj(tempMaterial.main.@tex,Grafon.numbMat);

			//If the material has an alternate texture, set alttexture as alternate texture ID.?
			if (tempMaterial.main.@alt.length())
			{
				alttexture = World.w.grafon.getObj(tempMaterial.main.@alt,Grafon.numbMat);
			}

			border = World.w.grafon.getObj(tempMaterial.border.@tex,Grafon.numbMat);
			floor = World.w.grafon.getObj(tempMaterial.floor.@tex,Grafon.numbMat);

			if (tempMaterial.main.@mask.length()) //If a material has a mask property...
			{
				try //try setting the texturemask variable of the instantiated material as that mask.
				{
					textureMask = getDefinitionByName(tempMaterial.main.@mask) as Class;
				} 
				catch (err:ReferenceError) 
				{
					textureMask = null;
					trace('Applying texture mask failed', id)
				}
			} 

			try 
			{
				borderMask=getDefinitionByName(tempMaterial.border.@mask) as Class;
			} 
			catch (err:ReferenceError) 
			{
				borderMask = null;
			}

			try 
			{
				floorMask=getDefinitionByName(tempMaterial.floor.@mask) as Class;
			} 
			catch (err:ReferenceError) 
			{
				floorMask = null;
			}
			
			if (tempMaterial.filter.length()) //If the material has a filter, apply it.
			{
				appliedFilters = filterArray[tempMaterial.filter.@f];
			}
			
			if (tempMaterial.@rear > 0 || tempMaterial.@ed == '2') // If the material's 'rear' property is greater than 0, or if ed = 2? It should be drawin in the rear.
			{
				rear = true;
			}
			
			if (tempMaterial.@slit > 0) //If the material is a slit, set to true.
			{
				slit = true;
			}
		}


		public function arraySetup():void
		{

			filterArray = new Array();

			filterArray['potek']		=[new BevelFilter(10,270,0,0,0,0.5,1,10,1,3),new GlowFilter(0,2,2,2,2,1,true)];
			filterArray['shad']			=[new DropShadowFilter(5,90,0,1,12,12,1,3)];
			filterArray['cont']			=[new GlowFilter(0,1,15,15,1,3,true)];
			filterArray['cont_metal']	=[new GlowFilter(0,1,2,2,2,1,true), new GlowFilter(0,1,15,15,1,3,true)];
			filterArray['cont_th']		=[new GlowFilter(0,1,5,5,1,3,true),new GlowFilter(0,2,2,2,2,1,true)];
			filterArray['plitka']		=[new BevelFilter(2,70,0xFFFFFF,0.5,0,0.5,2,2,1,1),new GlowFilter(0,0.5,5,5,1,3,false)];
			filterArray['dyrka']		=[new DropShadowFilter(10,70,0,2,10,10,1,3,true),new BevelFilter(2,250,0xFFFFFF,0.7,0,0.7,3,3,1,1)];
			filterArray['cloud']		=[new DropShadowFilter(5,90,0x375774,1,5,7,1,3,true),new BevelFilter(2,250,0xFFFFFF,0.7,0,0.7,3,3,1,1)];

		}
	}
}
