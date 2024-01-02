package  locdata
{
	import flash.display.Sprite;
	import flash.display.MovieClip;
	
	
	public class Tile 
	{
		public static var tilePixelWidth:int  = 40;
		public static var tilePixelHeight:int = 40;
		
		public var X:int;
		public var Y:int;
		
		public var indestruct:Boolean = false;  //Indestrutable
		public var phis:int = 0;				//Physics enable
		public var shelf:Boolean = false;		//Can the tile be stood on?
		public var hp:int = 1000;				//Tile Hitpoints
		public var damageThreshold:int = 0;		//Damage below this amount is ignored.
		public var phX1:Number;					//???
		public var phX2:Number;					//???
		public var phY1:Number;					//???
		public var phY2:Number;					//???
		
		public var zForm:int  = 0;				//???
		public var diagon:int = 0;				//is this tile a diagonal block?
		public var stair:int  = 0;				//is this tile a stair?
		public var water:int  = 0;				//is this tile water?
		
		public var fake:Boolean = false;
		public var t_ghost:int  = 0;
		
		public var recalc:Boolean = false;
		
		public var vid:int = 0;
		public var vid2:int = 0; 
		public var tileTexture:String = '';
		public var tileRearTexture:String = '';
		public var zad:String = '';
		public var tileHasRearTexture:Boolean = false;
		public var vRear:Boolean  = false;
		public var v2Rear:Boolean = false;
		
		public var visi:Number = 0;
		public var t_visi:Number = 0;
		public var opac:Number = 0;	// Opacity of the block
		
		// Material
		// 0 - Unknown
		// 1 - Metal
		// 2 - Stone
		// 3 - Wood
		// 4 - Brick
		// 5 - Glass
		// 6 - Earth
		// 7 - Force Field
		// 10 - Flesh
		public var tileMaterial:int = 0;
		
		public var grav:Number = 1;
		public var lurk:int = 0;
		public var kontur:int = 0;
		public var konturRot:int=  0;
		public var floor:int = 0;
		public var place:Boolean = true;	// Objects can be placed inside this tile.
		
		public var kont1:int = 0;
		public var kont2:int = 0;
		public var kont3:int = 0;
		public var kont4:int = 0;

		public var pont1:int = 0;
		public var pont2:int = 0;
		public var pont3:int = 0;
		public var pont4:int = 0;
		
		public var door:Box;
		public var trap:Obj;
		
		public function Tile(nx:int, ny:int) //Initialization
		{ 
			X = nx;
			Y = ny;
			phX1 = X * Tile.tilePixelWidth;
			phX2 = (X + 1) * Tile.tilePixelWidth;
			phY1 = Y * Tile.tilePixelHeight;
			phY2 = (Y + 1)*Tile.tilePixelHeight;
		}
		

		//Block type
		public function inForm(f:Form):void
		{
			var form:Form = f;

			if (form == null) return; //If there's no form, return.

			if (form.formLayer == 2)  //if this is a backwall, set it's rear texture as it's normal texure.
			{
				try 
				{
					tileRearTexture = form.formTextureID;
				}
				catch (err)
				{
					trace('Tile.as/inForm() - Backwall failed applying texture. Backwall:', form, ' Texture: ', form.formTextureID)
				}
			} 
			else // For Tiles...
			{
				try 
				{
					tileTexture = form.formTextureID;		  //Set the form texture 
					if (form.formHasRearTexture) tileHasRearTexture = true; //If this form has a rear texture, set tileHasRearTexture to true.
					if (form.formRearTextureID) zad = form.formRearTextureID;
				}
				catch (err)
				{
					trace('Tile.as/inForm() - Tile failed applying texture. Tile:', form, ' Texture: ', tileTexture)
				}
			}

			if (form.vid > 0) 
			{
				if (vid == 0)	
				{
					vid = form.vid;
					if (form.formHasRearTexture) vRear = true;
				} 
				else 
				{
					vid2 = form.vid;
					if (form.formHasRearTexture) v2Rear = true;
				}
			}

			if (form.formMaterial) tileMaterial = form.formMaterial;
			
			if (form.hp) hp = form.hp;
			if (form.damageThreshold) damageThreshold = form.damageThreshold;
			if (form.indestruct) indestruct = true;
			
			if (form.lurk) lurk = form.lurk; 
			if (form.phis) phis = form.phis;
			if (form.shelf) shelf = true; 
			if (form.diagon) diagon = form.diagon;
			if (form.stair) stair = form.stair;
			if (phis > 0 ) opac = 1; // If the tile has physics, it's opaque.
		}
		
		public function parseLevelXML(s:String, mirror:Boolean = false):void  
		{
			phis 	= 0;
			vid 	= 0;
			vid2 	= 0;
			diagon 	= 0;
			stair 	= 0;
			water 	= 0;
			tileTexture 	= '';
			tileRearTexture = '';
			zad 			= '';
			shelf 			= false;
			indestruct 		= false;

			setZForm(0);

			var fr:int = s.charCodeAt(0);

			if (fr > 64 && fr != 95) 
			{
				inForm(Form.tileForms[s.charAt(0)]);
			}
			if (s.length > 1) 
			{
				for (var i:int = 1; i < s.length; i++) 
				{
					fr = s.charCodeAt(i);
					var tileSymbol:String = s.charAt(i);
					if (tileSymbol == '*') //water
					{
						water = 1;
					} 
					else if (tileSymbol==',') //???
					{
						setZForm(1);
					} 
					else if (tileSymbol==';') //???
					{
						setZForm(2);
					} 
					else if (tileSymbol==':') //???
					{
						setZForm(3);
					} 
					else // All other tiles.
					{
						if (mirror && Form.otherForms[tileSymbol].idMirror) 
						{
							inForm(Form.otherForms[Form.otherForms[tileSymbol].idMirror]);
						}
						else inForm(Form.otherForms[tileSymbol]);
					}
				}
			}

			if (zForm == 0 && zad != '') 
			{
				tileRearTexture = zad;
			}
		}
		
		//If it has physics, turn them off.
		public function hole():Boolean 
		{
			if (phis > 0) 
			{
				phis = 0;
				return true;
			}
			phis = 0;
			return false;
		}
		
		public function updVisi():Number 
		{
			visi += 0.1;
			if (visi > t_visi) visi = t_visi;
			return visi;
		}

		public function setZForm(n:int):void  
		{
			if (n < 0) n = 0;
			if (n > 3) n = 3;
			zForm = n;
			phY1 = (Y + zForm / 4) * Tile.tilePixelHeight;
			if (n > 0) opac = 0;
		}

		public function mainFrame(s:String = 'A'):void // 'A' is a failsafe.
		{
			var frontTexture:String = s;
			phis 	= 1;
			vid 	= 0;
			vid2 	= 0;
			diagon 	= 0;
			stair 	= 0;
			tileMaterial 	= Form.tileForms[frontTexture].formMaterial;
			tileTexture = frontTexture;
			tileRearTexture = Form.tileForms[frontTexture].tileRearTexture;
			indestruct = true;
			hp = 10000;
			opac = 1;
		}

		public function getMaxY(rx:Number):Number 
		{
			if (diagon == 0) return phY1;
			else if (diagon > 0) 
			{
				if (rx < phX1) return phY2;
				else if (rx > phX2) return phY1;
				else return phY2 - (phY2 - phY1) * ((rx - phX1) / (phX2 - phX1));
			} 
			else 
			{
				if (rx < phX1) 
				{
					return phY1;
				}
				else if (rx > phX2) 
				{
					return phY2;
				}
				else 
				{
					return phY2 - (phY2 - phY1) * ((phX2 - rx) / (phX2 - phX1));
				}
			}
		}
		
		// Deal damage to the block, return true if damage was dealt
		public function udar(hit:int):Boolean 
		{
			if (indestruct || damageThreshold > hit) return false;
			hp -= hit;
			return true;
		}
		
		// Destroy the block
		public function die():void
		{
			if (phis != 3) tileTexture = '';
			phis = 0;
			opac = 0;
			vid = 0;
			vid2 = 0;
			t_ghost = 0;
			if (trap) trap.die();	// Destroy associated traps
		}
	}
}
