package interdata 
{
	import flash.display.MovieClip;
	import flash.filters.GlowFilter;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.display.DisplayObject;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.events.MouseEvent;
	
	import unitdata.Unit;
	import weapondata.Weapon;
	import unitdata.UnitPlayer;
	
	import components.Settings;
	
	import stubs.satsRadius;
	import stubs.satsUnit;
	
	public class Sats 
	{
		
		public var vis:MovieClip;
		public var trasser:MovieClip;
		public var radius:MovieClip;
		public var active:Boolean=false;
		public var que:Array;
		public var weapon:Weapon;
		public var gg:UnitPlayer;
		public var skillConf:Number=1;			//модификатор, зависит от соответствия уровня скилла, 1 - норм, 0.75 - скилл на 1 уровень ниже, 0.5 - скилл на 2 уровня ниже
		public var units:Array;
		public var ct:ColorTransform= new ColorTransform(1,1,1,1,0,100,0,0);
		var fGlow:GlowFilter=new GlowFilter(0xFF0000,1,3,3,4,1);
		var fShad:GlowFilter=new GlowFilter(0x000000,1,3,3,3,1);
		
		public var od:Number=80;	//реальные од
		public var odv:Number=80;	//виртуальные од
		public var odd:Number=0.1;
		public var limOd:Number=200;
		
		public function Sats(nvis:MovieClip) 
		{
			vis=nvis;
			vis.visible=false;
			trasser=new MovieClip();
			radius=new satsRadius();
			vis.addChild(trasser);
			vis.addChild(radius);
			que = [];
			units = [];
		}

		//Показать/скрыть
		public function onoff(turn:int=0):void
		{
			if (turn==0) active=!active;
			else if (turn>0) active=true;
			else active=false;
			if (active) 
			{
				if (GameSession.currentSession.room.base || Settings.alicorn) 
				{
					active=false;
					return;
				}
				gg=GameSession.currentSession.gg;
				weapon=gg.currentWeapon;
				if (weapon==null) 
				{
					GameSession.currentSession.gui.infoText('noSats');
					active=false;
				} 
				else 
				{
					if (weapon.noSats) 
					{
						GameSession.currentSession.gui.infoText('noSats');
						active=false;
					} 
					else 
					{
						var st=weapon.status();
						if (st==4) 
						{
							GameSession.currentSession.gui.infoText('noAmmo','');
							active=false;
						}
						if (st==5) 
						{
							GameSession.currentSession.gui.infoText('brokenWeapon','');
							active=false;
						}
						if (st==6) 
						{
							GameSession.currentSession.gui.infoText('noMana','');
							active=false;
						}
					}
				}
			}
			if (active) 
			{
				if (weapon.tip > 1) 
				{
					trasser.visible = true;
					trass();
				} 
				else 
				{
					trasser.visible = false;
					radius.visible 	= true;
					radius.x = gg.X + gg.pers.meleeS * gg.storona;
					radius.y = gg.Y - gg.scY / 2;
					radius.scaleX = gg.pers.meleeR / 100;
					radius.scaleY = gg.pers.meleeR / 100;
				}

				skillConf = 1;
				if (Settings.weaponsLevelsOff) 
				{
					var razn = weapon.lvl-gg.pers.getWeapLevel(weapon.skill);
					if (razn == 1) skillConf = 0.8;
					else if (razn==2) skillConf=0.6;
					else if (razn>2) 
					{
						skillConf=0;
						GameSession.currentSession.gui.infoText('weaponSkillLevel');
						active=false;
						return;
					}
				}
				if (que.length > 0) clearAll();
				GameSession.currentSession.grafon.drawSats();
				GameSession.currentSession.grafon.onSats(true);
				getUnits();
				GameSession.currentSession.gui.offCelObj();
				odv=od;
				GameSession.currentSession.gui.setOd();
				GameSession.currentSession.swfStage.addEventListener(MouseEvent.MOUSE_MOVE,mMove);
				GameSession.currentSession.gui.setTopText('infosats');
			} 
			else 
			{
				GameSession.currentSession.grafon.onSats(false);
				offUnits();
				GameSession.currentSession.swfStage.removeEventListener(MouseEvent.MOUSE_MOVE,mMove);
				GameSession.currentSession.ctr.clearAll();
				GameSession.currentSession.gui.setTopText('');
			}
			vis.visible = active;
			GameSession.currentSession.gui.setSats(active);
		}
		
		//когда на паузе
		public function step():void
		{
			if (active) 
			{
				if (GameSession.currentSession.ctr.keyStates.keyAttack) 
				{
					setCel();
					GameSession.currentSession.ctr.keyStates.keyAttack = false;
				}
				if (GameSession.currentSession.ctr.keyStates.keyTele) 
				{
					unsetCel();
					GameSession.currentSession.ctr.keyStates.keyTele = false;
				}
				if (GameSession.currentSession.ctr.keyStates.keyAction) 
				{
					onoff(-1);
					GameSession.currentSession.ctr.keyStates.keyAction = false;
				}
			}
		}
		
		//когда не на паузе
		public function step2():void
		{
			if (que.length > 0 && GameSession.currentSession.ctr.keyStates.keyAttack) clearAll();
			if (que.length > 0 && weapon.satsCons*weapon.consMult*weapon.consMult/skillConf*gg.pers.satsMult/weapon.satsQue>od) 
			{
				GameSession.currentSession.gui.infoText('noOd');
				clearAll();
			}
			if (que.length == 0 && od<gg.pers.maxOd) 
			{
				od+=odd;
				odv=od;
				GameSession.currentSession.gui.setOd();
			}
		}
		
		public function clearAll():void
		{
			var n=que.length;
			for (var i=0; i<n; i++) 
			{
				var cel:SatsCel=que.shift();
				cel.remove();
			}
			odv=od;
			GameSession.currentSession.gui.setOd();
			//trace('cl all');
		}
		
		public function setCel():void
		{
			if (weapon.satsCons*weapon.consMult/skillConf*gg.pers.satsMult>odv) 
			{
				GameSession.currentSession.gui.infoText('noOd');
				return;
			}
			var cel:SatsCel;
			if (units.length) 
			{
				for each (var obj in units) 
				{
					//trace (obj.du.filters);
					if (obj.du.filters.length > 0) 
					{
						cel=new SatsCel(obj,0,0,weapon.satsCons*weapon.consMult/skillConf*gg.pers.satsMult,weapon.satsQue);
						break;
					}
				}
			}
			if (cel==null) cel=new SatsCel(null, GameSession.currentSession.celX,GameSession.currentSession.celY,weapon.satsCons*weapon.consMult/skillConf*gg.pers.satsMult,weapon.satsQue);
			weapon.ready=false;
			odv-=weapon.satsCons*weapon.consMult/skillConf*gg.pers.satsMult;
			GameSession.currentSession.gui.setOd();
			que.push(cel);
		}
		public function unsetCel(q:Boolean=false):void
		{
			if (que.length == 0) 
			{
				onoff(-1);
				return;
			}
			var cel:SatsCel;
			if (q) cel=que.shift();
			else cel=que.pop();
			if (cel.un) cel.un.n--;
			cel.remove();
			odv+=weapon.satsCons*weapon.consMult/skillConf*gg.pers.satsMult;
			if (que.length == 0) 
			{
				onoff(-1);
				odv=od;
			}
			GameSession.currentSession.gui.setOd();
		}
		
		public function getReady():Boolean 
		{
			if (que.length > 0 && (que[0].un==null || que[0].begined || que[0].un.u.sost<3)) return true;
			else return false;
		}
		
		//действие выполнено
		public function act():void
		{
			od-=que[0].cons;
			GameSession.currentSession.gui.setOd();
			if (que[0].kol>1 && weapon.status()<=1)
			{
				que[0].kol--;
				que[0].begined=true;
			} 
			else 
			{
				var cel:SatsCel=que.shift();
				cel.remove();
			}
		}
		
		public function getPrec(un:Unit):Number 
		{
			var prec:Number=1;
			var sk=gg.pers.weaponSkills[weapon.skill];
			var dx=weapon.X-un.X;
			var dy=weapon.Y-un.Y;
			var rasst=Math.sqrt(dx*dx+dy*dy);
			if (weapon.precision>0) 
			{
				prec=weapon.resultPrec(1,sk)/rasst/(un.dexter+0.1)*skillConf;
			}
			if (weapon.antiprec>0 && rasst<weapon.antiprec) 
			{
				prec=(rasst/weapon.antiprec*0.75+0.25)/(un.dexter+0.1)*skillConf;
			}
			if (weapon.deviation>0 || gg.mazil>0) 
			{
				var ug1=Math.atan2(un.scY,rasst)*180/Math.PI;
				var ug2=(weapon.deviation/(sk+0.01)+gg.mazil);
				if (ug2>ug1) prec=prec*ug1/ug2;
				//trace (ug1,ug2);
			}
			if (prec>0.95) prec=0.95;
			if (prec>skillConf) prec=skillConf;
			return prec;
		}
		
		public function drawUnit(un:Unit):MovieClip 
		{
			var satsBmp:BitmapData=new BitmapData(un.vis.width,un.vis.height,true,0);
			var m:Matrix=new Matrix();
			var rect:Rectangle=un.vis.getBounds(un.vis);
			m.tx = -rect.left;
			m.ty = -rect.top;
			var hpoff:Boolean=false;
			if (un.hpbar && un.hpbar.visible) hpoff=true;
			if (hpoff) un.hpbar.visible=false;
			satsBmp.draw(un.vis,m,ct);
			if (hpoff) un.hpbar.visible=true;
			
			var mc:MovieClip=new MovieClip();
			mc.scaleX = un.vis.scaleX;
			mc.scaleY = un.vis.scaleY;
			mc.rotation = un.vis.rotation;
			var bm:Bitmap=new Bitmap(satsBmp);
			mc.addChild(bm);
			bm.x = rect.left;
			bm.y = rect.top;
			
			mc.addEventListener(MouseEvent.MOUSE_OVER,mOver);
			mc.addEventListener(MouseEvent.MOUSE_OUT,mOut);
			return mc;
		}
		
		public function mOver(event:MouseEvent):void 
		{
			if (active && !weapon.noPerc) (event.currentTarget as MovieClip).filters=[fGlow];
			try {
				var su:TextField=(event.currentTarget.parent as MovieClip).getChildAt(1)['info'];
				su.visible=true;
			} catch(err){}
		}
		public function mOut(event:MouseEvent):void 
		{
			if (active && !weapon.noPerc) (event.currentTarget as MovieClip).filters=[];
			try {
				var su:TextField=(event.currentTarget.parent as MovieClip).getChildAt(1)['info'];
				su.visible=false;
			} catch(err){}
		}
		
		public function offUnits():void
		{
			if (units && units.length) 
			{
				for each (var obj in units) 
				{
					try 
					{
						vis.removeChild(obj.v);
						obj.v.removeEventListener(MouseEvent.MOUSE_OVER,mOver);
						obj.v.removeEventListener(MouseEvent.MOUSE_OUT,mOut);
					} 
					catch (err) 
					{
						
					}
				}
			}
			units = [];
			for each (obj in que)
			{
				obj.vis.visible = false;
			}
		}
		
		public function getUnits():void
		{
			for each (var un:Unit in GameSession.currentSession.room.units) 
			{
				if (!gg.isMeet(un) || !un.isSats || un.sost>=3 || un.invis) continue;
				if (weapon.satsMelee) 
				{
					if (gg.look(un,false,0,gg.pers.meleeR*1.2+100)<=0) continue;
				} 
				else 
				{

				}
				if (gg.look(un)<=0 || !un.getTileVisi()) continue;
				var mc:MovieClip=new MovieClip();
				mc.x = un.vis.x;
				mc.y = un.vis.y;
				vis.addChild(mc);
				var du:MovieClip=drawUnit(un);
				var su:MovieClip=new satsUnit();
				su.filters=[fShad];
				su.scaleX=su.scaleY=1/GameSession.currentSession.cam.scaleV;
				var txt:TextField=su.txt;
				var info:TextField=su.info;
				txt.y=3;
				txt.autoSize=TextFieldAutoSize.CENTER;
				if (!weapon.noPerc) var prec:Number=getPrec(un);
				txt.text=un.objectName;
				txt.selectable=false;
				if (!weapon.noPerc) txt.text+='\n'+Math.round(prec*100)+'%';
				
				info.autoSize=TextFieldAutoSize.CENTER;
				info.selectable=false;				
				info.visible=false;
				info.text='';
				
				//расширенная информация о враге
				if (GameSession.currentSession.pers && GameSession.currentSession.pers.modAnalis) 
				{
					info.text+='\n'+Res.txt('pip', 'level')+': '+(un.level+1);
					info.text+='\n'+Res.txt('pip', 'hp')+': '+Math.ceil(un.hp)+'/'+Math.ceil(un.maxhp);
					if (un.skin>0) info.text+='\n'+Res.txt('pip', 'skin')+': '+Math.ceil(un.skin);
					if (un.armor_qual>0 && un.armor>0) info.text+='\n'+Res.txt('pip', 'armor')+': '+Math.ceil(un.armor+un.skin)+' ('+Math.round(un.armor_qual*100)+'%)';
					if (un.armor_qual>0 && un.marmor>0) info.text+='\n'+Res.txt('pip', 'marmor')+': '+Math.ceil(un.marmor+un.skin)+' ('+Math.round(un.armor_qual*100)+'%)';
					if (mc.y<150) info.y=50;
					else info.y=-un.scY-info.textHeight-20;
				}
				su.name='su';
				mc.addChild(du);
				mc.addChild(su);
				units.push({u:un, v:mc, du:du, p:prec, n:0});
			}
		}
		
		public function mMove(event:MouseEvent):void 
		{
			trass();
		}
		
		public function trass():void
		{
			if (weapon.noTrass) return;
			weapon.setTrass(trasser.graphics);
			if (weapon.explRadius) 
			{
				radius.visible=true;
				radius.scaleX=radius.scaleY=weapon.explRadius/100;
				radius.cacheAsBitmap=true;
				radius.x=weapon.trasser.X;
				radius.y=weapon.trasser.Y;
			} 
			else 
			{
				radius.visible=false;
			}
		}
	}
	
}
