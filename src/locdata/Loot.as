package locdata 
{
	
	import flash.geom.ColorTransform;
	import flash.utils.*;
	import flash.display.MovieClip;

	import graphdata.Emitter;
	import servdata.Item;
	import servdata.Interact;
	
	public class Loot extends Obj
	{
		
		public var item:Item;
		
		
		const osnRad=50, actRad=250;
		public var vClass:Class;
		public var osnova:Box=null;
		public var vsos:Boolean=false;
		public var isPlav:Boolean=false;
		public var takeR:int=osnRad;		//радиус взятия
		
		private var isTake:Boolean=false;	//взят
		var actTake:Boolean=false;			//была нажата E
		public var auto:Boolean=false;		//берётся автоматически
		public var auto2:Boolean=false;		//берётся автоматически в соответствии с настройками автовзятия
		public var krit:Boolean=false;		//критически важный
		private var dery:int=0;
		private var ttake:int=30;
		private var tvsos:int=0;
		public var sndFall:String='fall_item';

		public function Loot(nloc:Location, nitem:Item, nx:Number, ny:Number, jump:Boolean=false, nkrit:Boolean=false, nauto:Boolean=true) 
		{
			location=nloc;
			item=nitem;
			if (location.cTransform) cTransform=location.cTransform;
			sloy=2, prior=3;
			X=nx, Y=ny;
			krit=nkrit;
			if (nx<Tile.tilePixelWidth) nx=Tile.tilePixelWidth;
			if (nx>(location.spaceX-1)*Tile.tilePixelWidth) nx=(location.spaceX-1)*Tile.tilePixelWidth;
			if (ny>(location.spaceY-1)*Tile.tilePixelHeight) ny=(location.spaceY-1)*Tile.tilePixelHeight;
			massa=0.1;
			nazv=item.nazv;
			scX=30, scY=20;
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
					var infIco=new vClass();
					infIco.stop();
					infIco.x=-infIco.getRect(infIco).left-infIco.width/2;
					infIco.y=-infIco.height-infIco.getRect(infIco).top+10;
					vis=new MovieClip();
					vis.addChild(infIco);
					dery=10;
				}
				if (item.variant>0) shine();
				if (item.xml.snd.@fall.length()) sndFall=item.xml.snd.@fall;
			} 
			else if (item.tip==Item.L_EXPL) 
			{
				vClass=Res.getClass('vis'+item.id,null,visualAmmo);
				var infIco=new vClass();
				infIco.stop();
				infIco.x=-infIco.getRect(infIco).left-infIco.width/2;
				infIco.y=-infIco.height-infIco.getRect(infIco).top;
				vis=new MovieClip();
				vis.addChild(infIco);
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
					//var item.tip:String;
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
					nazv='"'+nazv+'"';
					sndFall='fall_paper';
				}
				if (item.xml.@fall.length()) sndFall=item.xml.@fall;
			} 
			if (vClass) 
			{
				vis.x=X;
				vis.y=Y;
				vis.cacheAsBitmap=true;
				scX=vis.width, scY=vis.height;
			}
			if (jump) 
			{
				dx=Math.random()*10-5;
				dy=Math.random()*5-10;
			}
			if (!location.locationActive) sndFall='';
			auto=nauto;
				inter=new Interact(this);
				inter.active=true;
				inter.action=100;
				inter.userAction='take';
				inter.actFun=toTake;
				inter.update();
				levitPoss=true;
			location.addObj(this);
			auto2=item.checkAuto();
		}
		
		public override function addVisual() 
		{
			super.addVisual();
			if (vis && cTransform) 
			{
				if (item.tip!='art') vis.transform.colorTransform=cTransform;
			}
		}
		
		function shine() 
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
		public function take(prinud:Boolean=false) 
		{
			if ((ttake>0 || World.w.gg.location!=location || World.w.gg.rat>0) && !prinud) return;
			var rx=World.w.gg.X-X, ry=World.w.gg.Y-World.w.gg.scY/2-Y;
			//взять
			if (prinud || (World.w.gg.isTake>=1 || actTake) && rx<20 && rx>-20 && ry<20 &&ry>-20) 
			{
				if (World.w.hardInv && !actTake) 
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
				location.remObj(this);
				if (!isTake) World.w.invent.take(item);
				isTake=true;
				onCursor=0;
				return;
			}

			//притяжение
			if ((World.w.gg.isTake>=20 || actTake) && rx<takeR && rx>-takeR && ry<takeR &&ry>-takeR && tvsos<45) 
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
		
		public override function step() 
		{
			if (location.broom && (auto2 || krit)) 
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
				if (!levit && !vsos && dy<World.maxdy) dy+=World.ddy;
				else if (levit && !isPlav) 
				{
					dy*=0.8; dx*=0.8;
				}
				if (isPlav) 
				{
					dy*=0.7; dx*=0.7;
				}
				if (Math.abs(dx)<World.maxdelta && Math.abs(dy)<World.maxdelta)	run();
				else 
				{
					var div=Math.floor(Math.max(Math.abs(dx),Math.abs(dy))/World.maxdelta)+1;
					for (var i=0; (i<div && !stay && !isTake); i++) run(div);
				}
				checkWater();
				if (vis) 
				{
					vis.x=X;
					vis.y=Y-dery;
				}
			}
			if (inter) inter.step();
			onCursor=(X-scX/2<World.w.celX && X+scX/2>World.w.celX && Y-scY<World.w.celY && Y>World.w.celY)?prior:0;
			if (World.w.checkLoot) auto2=item.checkAuto();
			if (auto && auto2 || actTake) take();
		}
		
		public function run(div:int=1) 
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
				if (X+scX/2>=location.spaceX*Tile.tilePixelWidth) 
				{
					X=location.spaceX*Tile.tilePixelWidth-1-scX/2;
					dx=-Math.abs(dx);
				}
				//движение влево
				if (dx<0) 
				{
					t=location.getAbsTile(X,Y);
					if (t.phis==1 && X<=t.phX2 && X>=t.phX1 && Y>=t.phY1 && Y<=t.phY2) 
					{
						X=t.phX2+1;
						dx=Math.abs(dx);
					}
				}
				//движение вправо
				if (dx>0) 
				{
					t=location.getAbsTile(X,Y);
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
				t=location.getAbsTile(X,Y);
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
				if (Y+dy/div>=location.spaceY*Tile.tilePixelHeight) 
				{
					if (auto2) take(true);
					dx=0;
					return;
				}
				t=location.getAbsTile(X,Y+dy/div);
				if (t.phis==1 && Y+dy/div>=t.phY1 && Y<=t.phY2 && X>=t.phX1 && X<=t.phX2 || t.shelf && !levit && !vsos && Y+dy/div>=t.phY1 && Y<=t.phY1 && X>=t.phX1 && X<=t.phX2) 
				{
					newmy=t.phY1;
				}
				if (newmy==0 && !levit && !vsos) newmy=checkShelf(dy/div);
				if (!location.locationActive && Y>=(location.spaceY-1)*Tile.tilePixelHeight) newmy=(location.spaceY-1)*Tile.tilePixelHeight;
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

		public override function checkStay() 
		{
			if (osnova) return true;
			var t:Tile=location.getAbsTile(X,Y+1);
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
			for (var i in location.objs) 
			{
				var b:Box=location.objs[i] as Box;
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
			var pla=isPlav;
			isPlav=false;
			try 
			{
				if ((location.space[Math.floor(X/Tile.tilePixelWidth)][Math.floor(Y/Tile.tilePixelHeight)] as Tile).water>0) 
				{
					isPlav=true;
				}
			} 
			catch (err)
			{
				
			}
			if (pla!=isPlav && dy>5) 
			{
				Emitter.emit('kap',location,X,Y,{dy:-Math.abs(dy)*(Math.random()*0.3+0.3), kol:5});
				Snd.ps('fall_item_water',X,Y,0, dy/10);
			}
			return isPlav;
		}
	}
}
