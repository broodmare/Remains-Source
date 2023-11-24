package locdata 
{
	
	public class Form 
	{
		
		public var formID:String;				// Tile ID
		public var formMirrorID:String; 		// ID of the tile's mirror version.
		public var formLayer:int = 0;		// 1 - Tile, 2 - Backwall
		
		public var formTextureID:String; 		// Texture for Tile or Backwall.
		public var formRearTextureID:String;	// Texture behind tile.
		public var vid:int;					// vid?
		public var formHasRearTexture:Boolean = false;	//Has a different texture for the backwall behind the texture for the sprite.
		public var formMaterial:int = 0;				// Form material
		
		public var hp:int = 0;				// Form HP
		public var damageThreshold:int=0;	// Damage below this amount is ignored.
		public var indestruct:Boolean=false;// The form is indestructable.
		
		public var phis:int = 0;			// Does this have physics?
		public var shelf:Boolean = false;	// Can you stand on this?
		public var diagon:int = 0;			// is this block a diagonal piece?
		public var stair:int = 0;			// is this a staircase?
		public var lurk:int = 0;			// Can you hide here?

		public function Form(node:XML = null) 
		{
			if (node != null) 
			{
				formID = node.@formID; // Tile ID (string).
				if (node.@m.length()) formMirrorID = node.@m; // Mirrored Tile ID if applicable (string).
				formLayer = node.@ed; //What layer this tile is on.
				if (node.@vid > 0) vid = node.@vid;
				else formTextureID = node.@id; // If vid does not exist, front = Tile ID.
				if (node.@back.length()) formRearTextureID=node.@back;
				if (node.@mat.length()) formMaterial=node.@mat;
				if (node.@rear.length()) formHasRearTexture=true;
				if (node.@lurk.length()) lurk=node.@lurk;
				
				if (node.@hp>0) hp=node.@hp;
				if (node.@damageThreshold > 0) damageThreshold = node.@damageThreshold;
				if (node.@indestruct>0) indestruct=true;
				
				if (node.@phis.length()) phis=node.@phis;
				if (node.@shelf.length()) shelf=true;
				if (node.@diagon.length()) diagon=node.@diagon;
				if (node.@stair.length()) stair=node.@stair;
			}
		}
		
		public static var tileForms:Array;
		public static var otherForms:Array;
		
		public static function setForms():void //Populates arrays of all Tiles and Backgrounds.
		{
			trace('Form.as/setForms() - SetForms() Executing...');
			tileForms = new Array();
			otherForms = new Array();
			if (AllData.d.mat == null)
			{
				trace('Form.as/setForms() - SetForms() AllData.d.mat does not exist!');
			}
			for each (var node in AllData.d.mat) 
			{
				if (node.@ed == 1) tileForms[node.@id] = new Form(node); // If interactive tile...
				else otherForms[node.@id] = new Form(node);				// Else (backwall)...
			}
			trace('Form.as/setForms() - SetForms() Finished.');
		}
	}
}
