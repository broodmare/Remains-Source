package weapondata 
{

	import flash.display.Graphics;
	
	import unitdata.Unit;
	import locdata.*;

	import components.Settings;
	
	public class Trasser 
	{
		
		public var room:Room;
		public var X:Number, Y:Number, dx:Number, dy:Number, begx:Number, begy:Number, begdx:Number, begdy:Number, ddx:Number=0, ddy:Number=0;
		public var is_skok:Boolean=false, vse:Boolean=false, stay:Boolean=false;
		public var liv:int=100;
		public var sled:Array;
		public var explRadius:Number=0;	// Explosion radius, if 0, then there is no explosion
		
		var brake:int = 2, skok:Number = 0.5, tormoz:Number = 0.7;

		public function Trasser() 
		{

		}
		
		public function trass(gr:Graphics):void
		{
			sled = new Array();
			X = begx;
			Y = begy;
			dx = begdx;
			dy = begdy;
			vse = false;
			stay = false;
			gr.clear();
			gr.lineStyle(5, 0x00FF99, 0.5);
			gr.moveTo(X, Y);
			
			for (var i:int = 0; i<liv; i++) 
			{
				dy += ddy;
				dx += ddx;
				if (stay) 
				{
					if (dx > 1) dx -= brake;
					else if (dx < -1) dx += brake;
					else dx = 0;
				}
				if (Math.abs(dx)<Settings.maxdelta && Math.abs(dy)<Settings.maxdelta)	run();
				else 
				{
					var div:Number = Math.floor(Math.max(Math.abs(dx),Math.abs(dy))/Settings.maxdelta)+1;
					for (var j:int=0; (j<div && !vse); j++) run(div);
				}
				gr.lineTo(X,Y);
				//trace(X,Y,dx,dy,ddx,ddy);
				sled.push({x:X, y:Y});
				if (vse) break;
			}
		}
		
		public function run(div:int=1):void
		{
			if (vse) return;
			var abstile:* = room.getAbsTile(X,Y);
			X+=dx/div;
			if (X<0 || X>=room.roomWidth*Tile.tilePixelWidth)
			{
				vse=true;
				return;
			}
			if (dx<0) 
			{
				if (abstile.phis ==1 && X <= abstile.phX2 && X >= abstile.phX1 && Y >= abstile.phY1 && Y <= abstile.phY2) 
				{
					if (!is_skok) vse=true;
					else 
					{
						X = abstile.phX2+1;
						dx = Math.abs(dx * skok);
					}
				}
			}
			//movement to the right
			if (dx>0) 
			{
				if (abstile.phis == 1 && X >= abstile.phX1 && X <= abstile.phX2 && Y >= abstile.phY1 && Y <= abstile.phY2) 
				{
					if (!is_skok) vse=true;
					else 
					{
						X = abstile.phX1-1;
						dx =- Math.abs(dx * skok);
					}
				}
			}
			if (vse) 
			{
				Y += dy / div;
				return;
			}
			//VERTICAL
			//upward movement
			if (dy < 0) 
			{
				Y += dy / div;
				if (abstile.phis == 1 && Y <= abstile.phY2 && Y >= abstile.phY1 && X >= abstile.phX1 && X <= abstile.phX2) 
				{
					if (!is_skok) vse=true;
					else 
					{
						Y = abstile.phY2+1;
						dy = Math.abs(dy*skok);
					}
				}
			}
			//movement down-up
			var newmy:Number=0;
			if (dy>0) 
			{
				Y+=dy/div;
				if (Y >= room.roomHeight*Tile.tilePixelHeight) 
				{
					vse=true;
					return;
				}
				if (abstile.phis==1 && Y>=abstile.phY1 && Y<=abstile.phY2 && X>=abstile.phX1 && X<=abstile.phX2) 
				{
					Y=abstile.phY1-1;
					if (!is_skok) vse=true;
					else 
					{
						if (dy>2) 
						{
							dy =- Math.abs(dy*skok);
							dx *= tormoz;
						} 
						else 
						{
							dy=0;
							stay=true;
						}
					}
				}
			}
		}
	}
}
