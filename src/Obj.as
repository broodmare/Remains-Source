package
{
	
	// Base class for objects interacting with the player or the world
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	
	import graphdata.Emitter;
	import graphdata.Part;
	import locdata.Room;
	import servdata.Interact;
	import weapondata.Bullet;
	import unitdata.UnitPlayer;
	import interdata.Appear;
	
	import components.Settings;
	
	public class Obj extends Pt
	{
		public var code:String;		//individual code
		public var uid:String;		//unique identifier used for script access to the object
		
		public var prior:Number 	= 1;
		public var scX:Number 		= 10;
		public var scY:Number 		= 10;
		public var storona:int 		= 1;	//dimensions
		public var rasst2:Number 	= 0;	//distance to the player square
		public var massa:Number 	= 1;
		public var levit:int 		= 0;
		public var levitPoss:Boolean = true;	//ability to move using levitation
		public var fracLevit:int 	= 0; //was levitated
		public var radioactiv:Number = 0;	//radioactivity
		public var radrad:Number 	= 250;	//radioactivity radius
		public var radtip:int 		= 0;		//0 - radiation, 1 - poison, 2 - pink cloud, 3 - death
		public var warn:int 		= 0;			//tooltip color
		public var objectName:String = '';
		
		public var inter:Interact;
		public var dist2:Number 	= 0;	//distance to the player square
		public var X1:Number;
		public var X2:Number;
		public var Y1:Number;
		public var Y2:Number;
		
		public var onCursor:Number = 0;
		
		public static var nullTransfom:ColorTransform = new ColorTransform();
		public var cTransform:ColorTransform = nullTransfom;
		
		public function Obj() 
		{

		}
		
		public override function remVisual():void
		{
			super.remVisual(); 
			onCursor = 0;
		}
		public function setVisState(s:String):void
		{

		}
		
		public function die(sposob:int = 0):void
		{

		}
		
		public function checkStay():Boolean
		{
			return false;
		}
		
		public function getRasst2(obj:Obj=null):Number 
		{
			if (obj==null) obj=World.world.gg;
			var nx:Number = obj.X-X;
			var ny:Number = obj.Y-obj.scY/2-Y+scY/2;
			if (obj==World.world.gg) ny=obj.Y-obj.scY*0.75-Y+scY/2;
			rasst2=nx*nx+ny*ny;
			if (isNaN(rasst2)) rasst2=-1;
			return rasst2;
		}
		
		public function save():Object 
		{
			return null;
		}
		
		//script command
		public function command(com:String, val:String=null):void
		{
			if (com == 'show') 
			{
				World.world.cam.showOn = true;
				World.world.cam.showX = X;
				World.world.cam.showY = Y;
			}
		}
		
		//affecting the main character
		public function ggModum():void
		{
			if (room == World.world.gg.room && radioactiv && rasst2 >= 0 && rasst2 < radrad * radrad) 
			{
				World.world.gg.raddamage((radrad - Math.sqrt(rasst2)) / radrad, radioactiv, radtip);
			}
		}
		
		public override function err():String 
		{
			if (room) room.remObj(this);
			return 'Error obj ' + objectName;
		}
		
		public function norma(p:Object,mr:Number):void
		{
			if (p.x * p.x + p.y * p.y > mr * mr) 
			{
				var nr:Number = Math.sqrt(p.x * p.x + p.y * p.y);
				p.x *= mr / nr;
				p.y *= mr / nr;
				//trace(p.x, p.y);
			}
		}
		
		//Forced Movement
		public function bindMove(nx:Number, ny:Number, ox:Number=-1, oy:Number=-1):void
		{
			X=nx, Y=ny;
			X1=X-scX/2, X2=X+scX/2, Y1=Y-scY, Y2=Y;
		}
		
		//copying the state into another object
		public function copy(un:Obj):void
		{
			un.X=X, un.Y = Y, un.scX = scX, un.scY = scY;
			un.Y1 = Y1, un.Y2 = Y2, un.X1 = X1, un.X2 = X2;
			un.storona = storona;
		}
		
		//checking if the bullet hit, applying damage if it did, returns -1 if it missed
		public function udarBullet(bul:Bullet, sposob:int = 0):int 
		{
			return -1;
		}
		
		//checking intersection with another object
		public function areaTest(obj:Obj):Boolean 
		{
			if (obj == null || obj.X1 >= X2 || obj.X2 <= X1 || obj.Y1 >= Y2 || obj.Y2 <= Y1) return false;
			else return true;
		}
		
		public function locout():void
		{


		}
		
		public static function setArmor(m:MovieClip):void
		{
			var aid:String='';
			if (World.world) 
			{
				if (World.world.pip && World.world.pip.active || World.world.mmArmor && World.world.allStat == 0) aid = World.world.pip.ArmorId;
				else if (World.world.armorWork != '') aid = World.world.armorWork;
				else if (Settings.alicorn) aid = 'ali';
				else aid = Appear.ggArmorId;
			}
			if (aid=='') 
			{
				m.gotoAndStop(1);
				return;
			}
			try 
			{
				m.gotoAndStop(aid);
			} 
			catch (err) 
			{
				m.gotoAndStop(1);
			}
		}
		
		public static function setMorda(m:MovieClip, c:int):void
		{
			if (World.world && World.world.gg) m.gotoAndStop(World.world.gg.mordaN);
			else m.gotoAndStop(1);
		}
		
		public static function setColor(m:MovieClip, c:int):void
		{
			if (Appear.transp) 
			{
				m.visible=false;
				return;
			}
			if (c == 0) m.transform.colorTransform=Appear.trFur;
			if (c == 1) m.transform.colorTransform=Appear.trHair;
			if (c == 2) 
			{
				if (Appear.visHair1) 
				{
					m.visible = true;
					m.transform.colorTransform = Appear.trHair1;
				} else m.visible = false;
			}
			if (c == 3) m.transform.colorTransform = Appear.trEye;
			if (c == 4) m.transform.colorTransform = Appear.trMagic;
		}
		
		public static function setVisible(m:MovieClip):void
		{
			var h:int = 0;
			if (World.world && World.world.pip && World.world.pip.active) h = World.world.pip.hideMane;
			else h = Appear.hideMane;
			m.visible=(h == 0);
		}
		
		public static function setEye(m:MovieClip):void
		{
			m.gotoAndStop(Appear.fEye);
		}
		public static function setHair(m:MovieClip):void
		{
			m.gotoAndStop(Appear.fHair);
		}

	}
	
}
