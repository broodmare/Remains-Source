package locdata 
{
	
	import flash.geom.ColorTransform;
	import flash.utils.*;
	import flash.display.MovieClip;

	import graphdata.Emitter;
	import servdata.Item;
	import servdata.Interact;
	
	import components.Settings;
	
	import stubs.visp10mm;
	import stubs.visualItem;
	import stubs.visualAmmo;
	import stubs.lootShine;

	public class Loot extends Obj
	{
		
		public var item:Item;
		
		
		//set public
		public const osnRad = 50;
		public const actRad = 250;


		public var vClass:Class;
		public var osnova:Box=null;
		public var vsos:Boolean=false;
		public var isPlav:Boolean=false;
		public var takeR:int=osnRad;		//радиус взятия
		
		private var isTake:Boolean=false;	//взят

		//set public 
		public var actTake:Boolean=false;			//была нажата E


		public var auto:Boolean=false;		//берётся автоматически
		public var auto2:Boolean=false;		//берётся автоматически в соответствии с настройками автовзятия
		public var krit:Boolean=false;		//критически важный
		private var dery:int=0;
		private var ttake:int=30;
		private var tvsos:int=0;
		public var sndFall:String='fall_item';

		public function Loot(newRoom:Room, nitem:Item, nx:Number, ny:Number, jump:Boolean=false, nkrit:Boolean=false, nauto:Boolean=true) 
		{
			room=newRoom;
			item=nitem;
			if (room.cTransform) cTransform=room.cTransform;
			layer = 2;
			prior = 3;
			X = nx;
			Y = ny;
			krit=nkrit;
			if (nx<Tile.tilePixelWidth) nx=Tile.tilePixelWidth;
			if (nx>(room.roomWidth-1)*Tile.tilePixelWidth) nx=(room.roomWidth-1)*Tile.tilePixelWidth;
			if (ny>(room.roomHeight-1)*Tile.tilePixelHeight) ny=(room.roomHeight-1)*Tile.tilePixelHeight;
			massa=0.1;
			objectName=item.objectName;
			scX = 30;
			scY = 20;
			if (item.tip==Item.L_WEAPON) 
			{
				if (item.xml.vis.length() && item.xml.vis.@loot.length()) 
				{
					vis=new visualItem();
					try 
					{
						vis.gotoAndStop(item.xml.vis.@loot);
					} 
					catch (err) {}
				} 
				else 
				{
					if (item.variant>0) vClass=Res.getClass('vis'+item.id+'_'+item.variant,'vis'+item.id,visp10mm);
					else vClass=Res.getClass('vis'+item.id,null,visp10mm);
					var infIco1 = new vClass();
					infIco1.stop();
					infIco1.x=-infIco1.getRect(infIco1).left-infIco1.width/2;
					infIco1.y=-infIco1.height-infIco1.getRect(infIco1).top+10;
					vis=new MovieClip();
					vis.addChild(infIco1);
					dery=10;
				}
				if (item.variant>0) shine();
				if (item.xml.snd.@fall.length()) sndFall=item.xml.snd.@fall;
			} 
			else if (item.tip==Item.L_EXPL) 
			{
				vClass=Res.getClass('vis'+item.id,null,visualAmmo);
				var infIco2 = new vClass();
				infIco2.stop();
				infIco2.x=-infIco2.getRect(infIco2).left-infIco2.width/2;
				infIco2.y=-infIco2.height-infIco2.getRect(infIco2).top;
				vis=new MovieClip();
				vis.addChild(infIco2);
				if (item.xml.@fall.length()) sndFall=item.xml.@fall;
			} 
			else if (item.tip==Item.L_AMMO) 
			{
				vClass=visualAmmo;
				vis=new vClass();
				try 
				{
					if (item.xml.@base.length()) vis.gotoAndStop(item.xml.@base);
					else vis.gotoAndStop(item.id);
				} 
				catch(err) 
				{
					vis.gotoAndStop(1);
				}
				if (item.xml.@fall.length()) sndFall=item.xml.@fall;
			} 
			else 
			{
				vClass=visualItem;
				vis=new vClass();
				try 
				{
					vis.gotoAndStop(item.id);
				} 
				catch(err) 
				{
					if (item.tip==Item.L_COMPA) vis.gotoAndStop('compa');
					else if (item.tip==Item.L_COMPW) vis.gotoAndStop('compw');
					else if (item.tip==Item.L_COMPE) vis.gotoAndStop('compe');
					else if (item.tip==Item.L_COMPP) vis.gotoAndStop('compp');
					else if (item.tip==Item.L_KEY) vis.gotoAndStop('key');
					else if (item.tip==Item.L_PAINT) vis.gotoAndStop('paint');
					else if (item.tip==Item.L_FOOD) vis.gotoAndStop('food');
					else vis.gotoAndStop(1);
				}
				if (item.tip==Item.L_SCHEME) 
				{
					sndFall='fall_paper';
					vis.gotoAndStop('scheme');
				}
				if (item.tip==Item.L_BOOK) 
				{
					objectName='"'+objectName+'"';
					sndFall='fall_paper';
				}
				if (item.xml.@fall.length()) sndFall=item.xml.@fall;
			} 
			if (vClass) 
			{
				vis.x=X;
				vis.y=Y;
				vis.cacheAsBitmap=true;
				scX = vis.width;
				scY = vis.height;
			}
			if (jump) 
			{
				dx=Math.random()*10-5;
				dy=Math.random()*5-10;
			}
			if (!room.roomActive) sndFall='';
			auto=nauto;
				inter=new Interact(this);
				inter.active=true;
				inter.action=100;
				inter.userAction='take';
				inter.actFun=toTake;
				inter.update();
				levitPoss=true;
			room.addObj(this);
			auto2=item.checkAuto();
		}
		
		public override function addVisual():void
		{
			super.addVisual();
			if (vis && cTransform) 
			{
				if (item.tip!='art') vis.transform.colorTransform=cTransform;
			}
		}
		
		public function shine():void
		{
			if (vis) 
			{
				var sh:MovieClip=new lootShine();
				sh.blendMode='hardlight';
				vis.addChild(sh);
			}
		}

		//при нажатии E
		public function toTake()
		{
			item.checkAuto(true);
			actTake=true;
			ttake=0;
			takeR=actRad;
		}

		//попробовать взять
		public function take(prinud:Boolean=false):void
		{
			if ((ttake>0 || World.world.gg.room!=room || World.world.gg.rat>0) && !prinud) return;
			var rx=World.world.gg.X-X, ry=World.world.gg.Y-World.world.gg.scY/2-Y;
			//взять
			if (prinud || (World.world.gg.isTake>=1 || actTake) && rx<20 && rx>-20 && ry<20 &&ry>-20) 
			{
				if (Settings.hardInv && !actTake) 
				{
					auto2=item.checkAuto();
					if (!auto2) 
					{
						vsos=actTake=false;
						tvsos=0;
						levitPoss=true;
						takeR=osnRad;
						return;
					}
				}
				levitPoss=false;
				room.remObj(this);
				if (!isTake) World.world.invent.take(item);
				isTake=true;
				onCursor=0;
				return;
			}

			//притяжение
			if ((World.world.gg.isTake>=20 || actTake) && rx<takeR && rx>-takeR && ry<takeR &&ry>-takeR && tvsos<45) 
			{
				levitPoss=false;
				stay=false;
				vsos=true;
				dx=rx/5;
				dy=ry/5;
				tvsos++;
			} 
			else 
			{
				vsos=actTake=false;
				tvsos=0;
				levitPoss=true;
				takeR=osnRad;
			}
		}
		
		public override function step():void
		{
			if (room.broom && (auto2 || krit)) 
			{
				take(true);
				return;
			}
			if (ttake>0) ttake--;
			if (stay && osnova && !osnova.stay) 
			{
				stay=false;
				osnova=null;
			}
			if (!stay) 
			{
				if (!levit && !vsos && dy<Settings.maxdy) dy+=Settings.ddy;
				else if (levit && !isPlav) 
				{
					dy*=0.8; dx*=0.8;
				}
				if (isPlav) 
				{
					dy*=0.7; dx*=0.7;
				}
				if (Math.abs(dx)<Settings.maxdelta && Math.abs(dy)<Settings.maxdelta)	run();
				else 
				{
					var div:int = Math.floor(Math.max(Math.abs(dx),Math.abs(dy))/Settings.maxdelta)+1;
					for (var i:int = 0; (i<div && !stay && !isTake); i++) run(div);
				}
				checkWater();
				if (vis) 
				{
					vis.x=X;
					vis.y=Y-dery;
				}
			}
			if (inter) inter.step();
			onCursor=(X-scX/2<World.world.celX && X+scX/2>World.world.celX && Y-scY<World.world.celY && Y>World.world.celY)?prior:0;
			if (World.world.checkLoot) auto2=item.checkAuto();
			if (auto && auto2 || actTake) take();
		}
		
		public function run(div:int=1):void
		{
			//движение
			var t:Tile;var i:int;
			
			
			//ГОРИЗОНТАЛЬ
				X+=dx/div;
				if (X-scX/2<0) 
				{
					X=scX/2;
					dx=Math.abs(dx);
				}
				if (X+scX/2>=room.roomWidth*Tile.tilePixelWidth) 
				{
					X=room.roomWidth*Tile.tilePixelWidth-1-scX/2;
					dx=-Math.abs(dx);
				}
				//движение влево
				if (dx<0) 
				{
					t=room.getAbsTile(X,Y);
					if (t.phis==1 && X<=t.phX2 && X>=t.phX1 && Y>=t.phY1 && Y<=t.phY2) 
					{
						X=t.phX2+1;
						dx=Math.abs(dx);
					}
				}
				//движение вправо
				if (dx>0) 
				{
					t=room.getAbsTile(X,Y);
					if (t.phis==1 && X>=t.phX1 && X<=t.phX2 && Y>=t.phY1 && Y<=t.phY2) 
					{
						X=t.phX1-1;
						dx=-Math.abs(dx);
					}
				}
			
			
			//ВЕРТИКАЛЬ
			//движение вверх
			if (dy<0) 
			{
				stay=false;
				Y+=dy/div;
				if (Y-scY<0) Y=scY;
				t=room.getAbsTile(X,Y);
				if (t.phis==1 && Y<=t.phY2 && Y>=t.phY1 && X>=t.phX1 && X<=t.phX2) 
				{
					Y=t.phY2+1;
					dy=0;
				}
			}
			//движение вниз
			var newmy:Number=0;
			if (dy>0) 
			{
				stay=false;
				if (Y+dy/div>=room.roomHeight*Tile.tilePixelHeight) 
				{
					if (auto2) take(true);
					dx=0;
					return;
				}
				t=room.getAbsTile(X,Y+dy/div);
				if (t.phis==1 && Y+dy/div>=t.phY1 && Y<=t.phY2 && X>=t.phX1 && X<=t.phX2 || t.shelf && !levit && !vsos && Y+dy/div>=t.phY1 && Y<=t.phY1 && X>=t.phX1 && X<=t.phX2) 
				{
					newmy=t.phY1;
				}
				if (newmy==0 && !levit && !vsos) newmy=checkShelf(dy/div);
				if (!room.roomActive && Y>=(room.roomHeight-1)*Tile.tilePixelHeight) newmy=(room.roomHeight-1)*Tile.tilePixelHeight;
				if (newmy) 
				{
					Y=newmy-1;
					if (!levit) 
					{
						if (dy>5 && sndFall) Snd.ps(sndFall,X,Y,0,dy/15);
						stay=true;
						dy=dx=0;
					}
				} 
				else 
				{
					Y+=dy/div;
				}
			}
		}

		public override function checkStay():Boolean
		{
			if (osnova) return true;
			var t:Tile=room.getAbsTile(X,Y+1);
			if ((t.phis==1 || t.shelf) && Y+1>t.phY1) 
			{
				return true;
			} 
			else 
			{
				stay=false;
				return false;
			}
		}

		public function checkShelf(dy):Number 
		{
			for (var i in room.objs) 
			{
				var b:Box=room.objs[i] as Box;
				if (!b.invis && b.stay && b.shelf && b.wall==0 && !(X<b.X1 || X>b.X2) && Y<=b.Y1 && Y+dy>b.Y1) 
				{
					osnova=b;
					return b.Y1;
				}
			}
			return 0;
		}

		//поиск жидкости
		public function checkWater():Boolean 
		{
			var pla:Boolean = isPlav;
			isPlav = false;
			try 
			{
				if ((room.roomTileArray[Math.floor(X/Tile.tilePixelWidth)][Math.floor(Y/Tile.tilePixelHeight)] as Tile).water>0) 
				{
					isPlav=true;
				}
			} 
			catch (err)
			{
				
			}
			if (pla!=isPlav && dy>5) 
			{
				Emitter.emit('kap',room,X,Y,{dy:-Math.abs(dy)*(Math.random()*0.3+0.3), kol:5});
				Snd.ps('fall_item_water',X,Y,0, dy/10);
			}
			return isPlav;
		}
	}
}
