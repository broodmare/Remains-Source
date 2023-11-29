package graphdata
{
	
	import flash.filters.GlowFilter;

	import locdata.Room;
	import servdata.BlitAnim;
	
	import components.Settings;
	import components.XmlBook;

	public class Emitter 
	{
		
		public static var arr:Array;
		public static var kols:Array = [0, 0, 0, 0, 0, 0];
		
		public static var kol1:int = 0;
		public static var kol2:int = 0;
		
		

		
		/*
				Particles
				vis - visual class
				ctrans='1' - room's color settings are applied
				move='1' - particle moves
				alph='1' - particle becomes transparent towards the end of its life
				
				minliv, rliv - lifetime
				minv, rv - initial speed in a random direction
				rdx, rdy - random speed in the x, y direction
				dx, dy - specified speed in the x, y direction
				rr - random rotational speed
				rot='1' - random initial rotation angle
				grav - gravity susceptibility
		*/
		public var id:String;
		
		public var vis:String;
		public var visClass:Class;
		public var layer:int = 3;
		
		public var imp:int = 0;	//1 - is important
		
		public var blit:String;
		public var blitx:int = 0;
		public var blity:int = 0;
		public var blitf:int = -1;
		public var blitd:Number = 1;
		
		public var ctrans:Boolean = false;
		public var alph:Boolean = false;
		public var prealph:Boolean = false;
		public var anim:int = 0;
		public var blend:String = 'normal';
		public var rsc:Number = 0;
		public var scale:Number = 1;
		public var frame:int = 0;
		public var dframe:int = 0;
		public var otklad:int = 0;
		public var filter:String;
		
		public var move:Boolean = false;
		public var minliv:int = 20, rliv:int = 0;
		public var minv:Number = 0, rv:Number = 0;
		public var rx:Number = 0, ry:Number = 0;
		public var rdx:Number = 0, rdy:Number = 0, rdr:Number = 0;
		public var dx:Number = 0, dy:Number = 0;
		public var rot:int = 0;
		public var brake:Number = 1;
		public var grav:Number = 0, rgrav:Number = 0;
		
		public var water:int = 0;
		public var maxkol:int = 0;
		public var camscale:Boolean = false;
		
		public static var fils:Array = new Array();
		fils['bur']  = [new GlowFilter(0xFF7700, 1, 8, 8, 1, 1)];
		fils['plav'] = [new GlowFilter(0x00FF00, 1, 8, 8, 1, 1)];

		public function Emitter(xml:XML) 
		{
			for (var i:String in xml.attributes()) 
			{
				var att:String = xml.attributes()[i].name();
				if (this.hasOwnProperty(att)) 
				{
					if (this[att] is Boolean) this[att] = true;
					else this[att] = xml.attributes()[i];
					//trace(att,this[att]);
				}
			}
			if (vis) visClass = Res.getClass(vis);
		}
		
		// The emitter creates a particle
		// The param can contain properties:
		//kol - number of particles
		//rx,ry - random deviation from nx, ny
		//alpha, scale
		//dx,dy,dr - initial velocity
		//frame - specified frame
		//txt - text used in text particles
		//celx+cely - orientation
		


		public static function init():void
		{
			arr = new Array();
			var particlesXML:XML = XmlBook.getXML("particles");
			for each (var xml:XML in particlesXML.part) 
			{
				var em:Emitter = new Emitter(xml);
				arr[em.id] = em;
			}
		}
		
		// The specified emitter creates a particle
		public static function emit(nid:String, room:Room, nx:Number, ny:Number, param:Object = null):void
		{
			var em:Emitter = arr[nid];
			if (em) em.castSpell(room, nx, ny, param);
			else trace ('Нет частицы ' + nid);
		}



		public function castSpell(room:Room, nx:Number, ny:Number, param:Object = null):Part 
		{
			if (room == null || !room.roomActive) return null;
			if (kol2 > Settings.maxParts && imp == 0) return null;
			var kol:int = 1;
			if (param && param.kol) kol = param.kol;
			if (kol > 50) kol = 50;
			frame  = 0;
			dframe = 0;
			var p:Part;
			for (var i:int = 1; i<=kol; i++) 
			{
				if (maxkol > 0 && kols[maxkol] >= 12) return p;
				p = new Part();
				p.room = room;
				p.layer = layer;
				p.X = nx;
				p.Y = ny;
				if (rx) p.X += (Math.random() - 0.5) * rx;
				if (ry) p.Y += (Math.random() - 0.5) * ry;
				
				if (maxkol > 0) 
				{
					p.maxkol = maxkol;
					kols[maxkol]++;
				}
				
				p.vClass = visClass;
				
				if (minv + rv > 0) 
				{
					var rot2:Number;
					var vel:Number;
					rot2 = Math.random() * Math.PI * 2;
					vel = Math.random() * rv + minv;
					p.dx = Math.sin(rot2) * vel;
					p.dy = Math.cos(rot2) * vel;
				}
				if (rdx) p.dx += (Math.random() - 0.5) * rdx;
				if (rdy) p.dy += (Math.random() - 0.5) * rdy;
				p.dx += dx;
				p.dy += dy;
				if (rdr) p.dr = (Math.random() - 0.5) * rdr;
				if (rot) p.r = Math.random() * 360;
				if (param) 
				{
					if (param.rx) p.X += (Math.random() - 0.5) * param.rx;
					if (param.ry) p.Y += (Math.random() - 0.5) * param.ry;
					if (param.dx) p.dx += param.dx;
					if (param.dy) p.dy += param.dy;
					if (param.dr) p.dr += param.dr;
					if (param.md != null) 
					{
						p.dx *= param.md;
						p.dy *= param.md;
					}
					if (param.frame) frame = param.frame;
					if (param.dframe) dframe = param.dframe;
					if (param.otklad) otklad = param.otklad;
				}
				p.ddy = Settings.ddy * grav;
				p.brake = brake;
				if (rgrav) p.ddy += Settings.ddy * rgrav * Math.random();
				p.liv = p.mliv = Math.floor(Math.random() * rliv)+minliv;
				p.isAlph = alph;
				p.isPreAlph = prealph;
				p.isAnim = anim;
				p.isMove = (p.dx != 0 || p.dy != 0 || p.ddy != 0);
				p.water = water;
				if (blitx) p.blitX = blitx;
				if (blity) p.blitY = blity;
				if (blitd) p.blitDelta = blitd;
				if (blitf > 0) 
				{
					p.blitMFrame = blitf;
					p.blitFrame = Math.floor(Math.random() * blitf);
				}
				
				if (otklad > 0) 
				{
					p.otklad = Math.floor(Math.random() * otklad + 1);
				}
				if (vis) p.initVis(frame + ((dframe == 0) ? 0:Math.floor(Math.random() * dframe + 1)));
				if (blit) p.initBlit(blit)
				
				if (p.vis) 
				{
					if (param && param.alpha) p.vis.alpha = param.alpha;
					if (param && param.scale) 
					{
						p.vis.scaleX = param.scale;
						p.vis.scaleY = param.scale;
					}
					if (param && param.rotation) p.vis.rotation = param.rotation;
					p.vis.blendMode = blend;
					if (scale != 1) 
					{
						p.vis.scaleX = scale;
						p.vis.scaleY = scale;
					}
					if (rsc != 0) 
					{
						p.vis.scaleX = scale - rsc + Math.random() * rsc;
						p.vis.scaleY = scale - rsc + Math.random() * rsc;
					}
					if (ctrans) p.vis.transform.colorTransform = room.cTransform;
					if (filter && Emitter.fils[filter]) p.vis.filters = Emitter.fils[filter];
					if (param && param.celx != null && param.cely != null && p.vis.len) 
					{
						var gx:Number = param.celx - p.X;
						var gy:Number = param.cely - p.Y;
						var gr:Number = Math.sqrt(gx * gx + gy * gy);
						var gu:Number = Math.atan2(gy, gx) * 180 / Math.PI;
						p.vis.len.scaleX = gr / p.vis.len.width;
						p.vis.len.rotation = gu;
						if (p.vis.fl) 
						{
							p.vis.fl.x = gx;
							p.vis.fl.y = gy;
						}
					}
					if (param && param.mirr) p.vis.scaleX = -p.vis.scaleX;
					room.addObj(p);
					if (prealph) p.vis.alpha = 0;
					if (id == 'numb' && param.txt) p.vis.numb.text = param.txt;
					if ((id == 'replic' || id == 'replic2') && param.txt) 
					{
						p.vis.text.text.text=param.txt;
					}
					if ((id == 'gui' || id == 'take') && param.txt) 
					{
						p.vis.text.text.styleSheet = World.world.gui.style;
						p.vis.text.text.htmlText = param.txt;
					}
					if (camscale) 
					{
						p.vis.scaleX = 1 / World.world.cam.scaleV;
						p.vis.scaleY = 1 / World.world.cam.scaleV;
						if (param && param.scale) 
						{
							p.vis.scaleX *= param.scale;
							p.vis.scaleY *= param.scale;
						}
					}
				}
			}
			return p;
		}
		
	}
	
}
