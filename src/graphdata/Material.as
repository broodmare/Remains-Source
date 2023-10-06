package graphdata
{
	
	import flash.utils.*;
	import flash.filters.BevelFilter;
	import flash.filters.GlowFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.BitmapFilter; //CHECK IF USED
	import flash.display.BitmapData;

	import systems.TileFilter;
	
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

		public var isBackwall:Boolean = false; //Is the material as a Backwall?
		public var slit:Boolean = false; 
		
		



		//Material class setup.
		public function Material(material:XML) //input a material when constructing this...
		{
			var tempMaterial:XML = material;
			
			try 
			{
				materialSetup(tempMaterial);
			}
			catch(err)
			{
				trace('Filter: ', tempMaterial.filter.@f, ' for tile: ', tempMaterial.id, '\n', tempMaterial, '\n');
			}
		}



		private function materialSetup(material:XML):void
		{
			var tempMaterial:XML = material;

			id = tempMaterial.@id; //id of the material is the id of the material in the XML file.
			texture = World.world.grafon.getObj(tempMaterial.main.@tex,Grafon.materialCount);

			//If the material has an alternate texture, set alttexture as alternate texture ID.?
			if (tempMaterial.main.@alt.length)
			{
				alttexture = World.world.grafon.getObj(tempMaterial.main.@alt,Grafon.materialCount);
			}

			border = World.world.grafon.getObj(tempMaterial.border.@tex,Grafon.materialCount);
			floor = World.world.grafon.getObj(tempMaterial.floor.@tex,Grafon.materialCount);

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
				borderMask = getDefinitionByName(tempMaterial.border.@mask) as Class;
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
			
			if (tempMaterial.filter.length) //If the material has a filter, apply it.
			{	
				try
				{
					appliedFilters = TileFilter.getFilter(tempMaterial.filter.@f);
				}
				catch (err)
				{

					trace('Failed to set appliedFilters property, ', tempMaterial.filter.@f);

				}
			}
			
			if (tempMaterial.@rear > 0 || tempMaterial.@ed == '2') // If the material's 'rear' property is greater than 0, or if ed = 2? It should be drawin on the decorative background layer.
			{
				isBackwall = true;
			}
			
			if (tempMaterial.@slit > 0) //If the material is a slit, set to true.
			{
				slit = true;
			}
		}
	}
}
