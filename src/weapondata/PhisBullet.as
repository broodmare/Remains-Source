package weapondata 
{
	
	import unitdata.Unit;
	import unitdata.UnitPlayer;
	import graphdata.Emitter;
	import locdata.Tile;
	import locdata.Box;
	
	import components.Settings;
	
	public class PhisBullet extends Bullet 
	{
		
		var brake = 2;
		var dr:Number = 0;
		var lip:Boolean = false;
		var prilip:Boolean = false;
		var bumc:Boolean = false;
		
		var skok:Number = 0.5;
		var tormoz:Number = 0.7;
		var isSensor:Boolean = false;
		
		public var sndHit:String='';

		public function PhisBullet(own:Unit, nx:Number, ny:Number, visClass:Class=null) 
		{
			super(own,nx,ny,visClass);
			ddy=Settings.ddy;
			massa=0.1;
			warn=1;
			levitPoss=true;
			inWater=0;
			scX=scY=30;
			if (vis) vis.visible=true;
		}
		public override function step()
		{
			if (levit) 
			{
				dy *= 0.8; 
				dx *= 0.8;
			} 
			else dy += ddy;
			if (stay) 
			{
				if (dx > 1) dx -= brake;
				else if (dx < -1) dx += brake;
				else dx = 0;
				dr = dx;
			}
			if (inWater)
			{
				dy *= 0.8; 
				dx *= 0.8;
			}
			if (!babah && !prilip) 
			{
				if (Math.abs(dx)<Settings.maxdelta && Math.abs(dy)<Settings.maxdelta)	run();
				else 
				{
					var div:Number =Math.floor(Math.max(Math.abs(dx),Math.abs(dy))/Settings.maxdelta)+1;
					for (var i:int = 0; (i<div && !babah); i++) run(div);
				}
			}
			checkWater();
			if (vis) 
			{
				vis.rotation+=dr;
				vis.x=X;
				vis.y=Y;
			}
			if (isSensor || room.sky) sensor();
			if (expl_t>0) expl_t--;
			else liv--;
			if (liv==3) 
			{
				if ((World.world.gg as UnitPlayer).teleObj==this) (World.world.gg as UnitPlayer).dropTeleObj();
				explosion();
				liv=1;
			}
			if (expl_t>0 && expl_t%explPeriod==1) explRun();
			if (liv<=0) 
			{ 
				onCursor=0;
				vse=true;
			}
			if (explRadius>0) room.warning=10;	// Command for AI to watch out for grenades
			if (vse) 
			{
				room.remObj(this);
				room.remGrenade(this);
			}

			//trace(liv,expl_t);
			onCursor=(liv>5 && X-scX/2<World.world.celX && X+scX/2>World.world.celX && Y-scY/2<World.world.celY && Y+scY/2>World.world.celY)?3:0;
		}
		
		private function sensor():Boolean 
		{
			for each (var un:Unit in room.units) 
			{
				if (!un.disabled && un.fraction!=owner.fraction && X>=un.X1 && X<=un.X2 && Y>=un.Y1 && Y<=un.Y2 && un.sost<3) 
				{
					explosion();
					onCursor=0;
					vse=true;
					return true;
				}
			}
			return false;
		}
		
		// Check for liquid
		public function checkWater():int 
		{
			var pla=inWater;
			inWater=0;
			try 
			{
				if ((room.roomTileArray[Math.floor(X/Tile.tilePixelWidth)][Math.floor(Y/Tile.tilePixelHeight)] as Tile).water>0) 
				{
					inWater=1;
				}
			} 
			catch (err) {}

			if (pla!=inWater && dy>5) 
			{
				Emitter.emit('kap',room,X,Y,{dy:-Math.abs(dy)*(Math.random()*0.3+0.3), kol:5});
				Snd.ps('fall_item_water',X,Y,0, dy/10);
			}
			return inWater;
		}
		
		public override function popadalo(res:int=0)
		{
			if (res<0) return;			// Did not hit
			dx=dy=0;
			if (explRadius) 
			{
				explosion();
				if (vis) vis.visible=false;
			} 
			if (liv>1) liv=1;
			babah=true;
		}
		



//################################


		public override function run(div:int = 1)
		{
			var celobj:* = room.celObj;
			var abstile:* = room.getAbsTile(X,Y) 
			X += dx/div;


			if (lip) 
			{
				if (celobj && (celobj is Box) && (celobj as Box).explcrack && owner && owner.player && X >= celobj.X1 && X<=celobj.X2 && Y >= celobj.Y1 && Y <= celobj.Y2) 
				{
					targetObj = celobj;
					prilip = true;
					return;
				}
			}
			if (room.sky) 
			{
				Y+=dy/div;
				if (X<0 || X>=room.roomPixelWidth || Y<0 || Y>=room.roomPixelHeight) 
				{
					vse=true;
					return;
				}
			} 
			else 
			{
				if (X<0 || X >= room.roomWidth * Tile.tilePixelWidth) 
				{
					vse=true;
					return;
				}
				if (dx<0) 
				{
					if (abstile.phis==1 && X<=abstile.phX2 && X>=abstile.phX1 && Y>=abstile.phY1 && Y<=abstile.phY2) 
					{
						if (sndHit!='') Snd.ps(sndHit,X,Y,0,Math.abs(dx/10));
						if (bumc) 
						{
							popadalo();
						}
						X = abstile.phX2 + 1;
						dx = Math.abs(dx * skok);
						if (lip) prilip = true;
					}
				}
				// Move right
				if (dx>0) 
				{
					if (abstile.phis==1 && X>=abstile.phX1 && X<=abstile.phX2 && Y>=abstile.phY1 && Y<=abstile.phY2) 
					{
						if (sndHit!='') Snd.ps(sndHit,X,Y,0,Math.abs(dx/10));
						if (bumc) 
						{
							popadalo();
						}
						X = abstile.phX1 - 1;
						dx=-Math.abs(dx*skok);
						if (lip) prilip=true;
					}
				}
				// VERTICAL
				// Move up
				if (dy<0) 
				{
					stay=false;
					Y+=dy/div;
					if (abstile.phis==1 && Y<=abstile.phY2 && Y>=abstile.phY1 && X>=abstile.phX1 && X<=abstile.phX2) 
					{
						if (sndHit!='') Snd.ps(sndHit,X,Y,0,Math.abs(dy/10));
						if (bumc) 
						{
							popadalo();
						}
						Y = abstile.phY2 + 1;
						dy=Math.abs(dy*skok);
						if (lip) prilip=true;
					}
				}
				// Move down
				var newmy:Number=0;
				if (dy>0) 
				{
					stay=false;
					Y+=dy/div;
					if (Y>=room.roomHeight*Tile.tilePixelHeight) 
					{
						vse=true;
						return;
					}
					if (abstile.phis==1 && Y>=abstile.phY1 && Y<=abstile.phY2 && X>=abstile.phX1 && X<=abstile.phX2) 
					{
						if (bumc) 
						{
							if (sndHit!='') Snd.ps(sndHit,X,Y,0,Math.abs(dy/10));
							popadalo();
						}
						Y = abstile.phY1-1;
						if (lip) prilip = true;
						if (dy>2) 
						{
							dy=-Math.abs(dy*skok);
							dx*=tormoz;
							if (sndHit!='') Snd.ps(sndHit,X,Y,0,Math.abs(dy/10));
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
