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
		public var materialName:String;
		
		public var texture:BitmapData;
		public var alttexture:BitmapData;
		public var border:BitmapData;
		public var floor:BitmapData;

		public var textureMask:Class;	// Pulled from flash file.
		public var borderMask:Class;	// Pulled from flash file.
		public var floorMask:Class;		// Pulled from flash file.

		public var appliedFilters:Array;

		public var used:Boolean;
		public var isBackwall:Boolean; 
		public var slit:Boolean; 
		
		

		public function Material(materialXML:XML) //This constructor is passed a material XML element.
		{
			try
			{
				materialSetup(materialXML);
			}
			catch (err)
			{
				trace('Material.as/Material() - Error while creating material: "' + materialName + '."');
			}
			
		}



		private function materialSetup(materialXML:XML):void
		{
			var material:XML = materialXML;

			this.id = materialXML.@id; 
			this.materialName = materialXML.@name; 
			this.texture = GameSession.currentSession.grafon.getObj(material.main.@texture, Grafon.activeMaterials);

			if (material.main.@alt.length()) //If the materialXML has an alternate texture...
			{
				this.alttexture = GameSession.currentSession.grafon.getObj(material.main.@alt, Grafon.activeMaterials);
			}

			if (material.border.@texture.length())
			{
				this.border = GameSession.currentSession.grafon.getObj(material.border.@texture, Grafon.activeMaterials);
			}
			if (material.floor.@texture.length())
			{
				this.floor  = GameSession.currentSession.grafon.getObj(material.floor.@texture,  Grafon.activeMaterials);
			}
			if (material.main.@mask.length()) //If a materialXML has a mask property...
			{
				this.textureMask = getDefinitionByName(material.main.@mask) as Class;
			}

			if (material.border.@mask.length())
			{
				this.borderMask = getDefinitionByName(material.border.@mask) as Class;
			}
			
			if (material.floor.@mask.length())
			{
				this.floorMask  = getDefinitionByName(material.floor.@mask)  as Class;
			}

			if (material.filter.length()) //If the materialXML has a filter, apply it.
			{	
				this.appliedFilters = TileFilter.getFilter(material.filter.@filter);
			}
			
			if (material.@rear > 0 || material.@drawLayer == '2') // If the materialXML is a backwall, set to true.
			{
				this.isBackwall = true;
			}
			
			if (material.@slit > 0) //If the materialXML is a slit, set to true.
			{
				this.slit = true;
			}
			
		}
	}
}
