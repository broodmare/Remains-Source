package src.loc 
{
	import src.*;
	import src.serv.Script;
	import src.graph.Emitter;
	import src.unit.Unit;
	
	// Active Area
	
	public class Area extends Obj
	{
		
		public var enabled:Boolean = true;
		public var tip:String = 'gg';	//1 - GG is activated
		
		// Sizes in blocks
		var bx:int=0, by:int=0, rx:int=2, ry:int=2;
		
		var active:Boolean = false;		// Area is active (activator is in it)
		var preactive:Boolean = false;	// Area was active in the previous cycle
		
		public var over:Function;
		public var out:Function;
		public var run:Function;
		
		public var scrOver:Script;
		public var scrOut:Script;
		
		public var mess:String;			// Message
		public var messDown:Boolean;	// Show message below
		
		public var activator:Unit;
		public var allact:String;		// Action for the entire room
		public var allid:String;		// ID for the specified action
		public var lift:Number=1;		// Gravity change
		public var onPort:Boolean = false;// Teleportation
		public var portX:int = -1;
		public var portY:int = -1;
		public var noRad:Boolean = false;
		
		public var emit:Emitter;
		public var dens:Number = 1;
		public var frec:Number = 1;
		public var t_frec:Number = 0;
		public var trig:Boolean;	// Disable and set trigger on first activation

		public function Area(nloc:Location, xml:XML=null, loadObj:Object=null, mirror:Boolean=false) 
		{
			loc = nloc;
			if (xml) 
			{
				bx = xml.@x;
				by = xml.@y;
				if (xml.@w.length()) 
				{
					rx = xml.@w;
				}
				if (mirror) 
				{
					bx=loc.spaceX - bx - rx;
				}
				scX = rx * World.tilePixelWidth;
				X = bx * World.tilePixelWidth;
				X1 = bx * World.tilePixelWidth;
				Y = by * World.tilePixelHeight + World.tilePixelHeight;
				Y2 = by * World.tilePixelHeight + World.tilePixelHeight;
				X2 = X1 + scX;
				if (xml.@h.length()) 
				{
					ry=xml.@h;
				}
				scY = ry * World.tilePixelHeight;
				Y1 = Y2 - scY;

				// Visual
				if (xml.@vis.length()) 
				{
					vis=Res.getVis('vis'+xml.@vis,visArea);
				} 

				if (World.w.showArea) //If the world.showArea toggle is true;
				{
					vis = new visArea(); 
				}
				if (xml.@tip.length()) tip = xml.@tip;
				if (xml.@mess.length()) mess = xml.@mess;
				if (xml.@down.length()) messDown = true;
				if (xml.@off.length()) enabled=xml.@off <= 0;
				if (xml.@allact.length()) allact = xml.@allact;
				if (xml.@allid.length()) allid = xml.@allid;
				if (xml.@trig.length()) trig = true;

				// Attached Scripts
				if (xml.scr.length()) 
				{
					for each (var xscr in xml.scr) 
					{
						var scr:Script=new Script(xscr,loc.land,this);
						if (scr.eve==null || scr.eve=='over') scrOver=scr;
						if (scr.eve=='out') scrOut=scr;
					}
				}
				if (xml.@scr.length()) scrOver=World.w.game.getScript(xml.@scr,this);
				if (xml.@scrout.length()) scrOut=World.w.game.getScript(xml.@scrout,this);

				// Change Walls
				if (xml.@tilehp.length() || xml.@tileop.length() || xml.@tilethre.length())  //If the tile has a HP value, tileop, or tilethre property?
				{
					for (var i = bx; i < bx + rx; i++) 
					{
						for (var j = by - ry + 1; j <= by; j++) 
						{
							var tile:Tile = loc.getTile(i, j);

							if (xml.@tilehp.length()) 
							{
								tile.hp = xml.@tilehp;
								tile.indestruct = false;
								if (tile.hp <= 1)
								{
									tile.fake = true;
								}
								if (tile.damageThreshold > tile.hp) 
								{
									tile.damageThreshold = tile.hp;
								}
							}

							if (xml.@damageThreshold.length()) 
							{
								tile.indestruct = false;
								tile.damageThreshold = xml.@damageThreshold;
							}

							if (xml.@tileop.length()) 
							{
								if (tile.phis == 0) 
								{
									tile.opac = xml.@tileop;
								}
							}
						}
					}
				}
				if (xml.@grav.length()) lift = xml.@grav;
				if (xml.@norad.length()) noRad = true;

				// Particle Emitter
				if (xml.@emit.length()) 
				{
					emit=Emitter.arr[xml.@emit];
				}
				if (xml.@dens.length()) 
				{
					dens=xml.@dens;
				}
				frec = dens * rx * ry / 100;

				// Teleport
				if (xml.@port.length()) 
				{
					var s:String=xml.@port;
					var arr:Array=s.split(':');
					if (arr.length>=2) 
					{
						onPort=true;
						portX=arr[0];
						portY=arr[1];
					}
				}
			}
			if (loadObj) 
			{
				enabled=loadObj.enabled;
			}
			if (enabled && lift!=1) setLift();
			if (vis)
			{
				if (vis.totalFrames <= 1) 
				{
					vis.cacheAsBitmap=true;
				}
				vis.x = X;
				vis.y = Y;
				vis.scaleX = scX / 100;
				vis.scaleY = scY / 100;
				vis.alpha = enabled? 1:0.1;
				vis.blendMode='screen';
			}
		}
		
		public override function save():Object 
		{
			var obj:Object=new Object();
			obj.enabled=enabled;
			return obj;
		}
		
		public override function command(com:String, val:String=null) 
		{
			if (com=='onoff') enabled=!enabled;
			if (com=='off') enabled=false;
			if (com=='on') enabled=true;
			if (lift!=1) setLift();
			if (vis) vis.alpha=enabled?1:0.1;
			if (com=='dam') damTiles(int(val));
		}
		
		public override function step() 
		{
			if (!enabled || !loc.locationActive || tip=='') return;
			if (emit)
			{
				t_frec += frec;
				if (t_frec > 1) 
				{
					var kol:int = Math.floor(t_frec);
					t_frec -= kol;
					emit.cast(loc,(X1 + X2) / 2,(Y1 + Y2) / 2, {rx:scX, ry:scY, kol:kol});
				}
			}

			activator=null;

			if (tip == 'gg') 
			{
				active = areaTest(loc.gg);
				if (active && noRad) loc.gg.noRad = true;
				activator = loc.gg;
			}
			else 
			{
				active = false;
				for each(var un:Unit in loc.units) 
				{
					if (!un.disabled && un.sost<3 && un.areaTestTip==tip && areaTest(un)) 
					{
						active = true;
						activator = un;
						break;
					}
				}
			}
			if (active && mess) World.w.gui.messText(mess, '', messDown);
			if (active && run) run();
			if (active && !preactive && allact) loc.allAct(this,allact,allid);
			if (active && !preactive && over) over();
			if (active && !preactive && onPort) teleport(activator);
			if (!active && preactive && out) out();
			if (active && !preactive && scrOver) 
			{
				if (trig && uid) 
				{
					if (World.w.game.triggers[uid] != 1) 
					{
						World.w.game.triggers[uid] = 1;
						scrOver.start();
					}
				} 
				else scrOver.start();
			}
			if (!active && preactive && scrOut) scrOut.start();
			preactive=active;
		}
		
		public function setSize(x1:Number, y1:Number, x2:Number, y2:Number) 
		{
			X = x1;
			X1 = x1;
			Y1 = y1;
			X2 = x2;
			Y2 = y2;
			Y2 = y2;
			scX = X2 - X1;
			scY = Y2 - Y1;
		}
		
		public function setLift() 
		{
			for (var i=bx; i<bx+rx; i++) 
			{
				for (var j = by - ry + 1; j <= by; j++) 
				{
					loc.getTile(i, j).grav = enabled? lift:1;
				}
			}
		}
		
		public function damTiles(destroy:int,tipDam:int=11) 
		{
			for (var i = bx; i < bx + rx; i++) 
			{
				for (var j = by - ry + 1; j <= by; j++) 
				{
					loc.hitTile(loc.getTile(i, j), destroy, (i + 0.5) * Tile.tilePixelWidth, (j + 0.5) * Tile.tilePixelHeight, tipDam);
				}
			}
		}
		
		public function teleport(un:Unit) 
		{
			if (un == null) return;
			if (!loc.collisionUnit((portX+1) * World.tilePixelWidth, (portY + 1) * World.tilePixelHeight - 1, un.scX, un.scY)) 
			{
				un.teleport((portX + 1) * World.tilePixelWidth, (portY + 1) * World.tilePixelHeight - 1);
			}
		}
	}
	
}
