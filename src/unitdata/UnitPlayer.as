package unitdata 
{
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.ColorTransform;
	import flash.display.MovieClip;
	import flash.filters.DropShadowFilter;
	
	import locdata.*;
	import weapondata.*;
	import interdata.*;
	import servdata.Interact;
	import graphdata.Emitter;
	import flash.filters.BlurFilter;
	
	import components.Settings;
	
	import stubs.visualPlayer;
	import stubs.reloadBar;
	
	public class UnitPlayer extends UnitPon
	{
		
		public var ctr:Ctr;
		//движение
		public var maxjumpp:int,jumpNumb:int=0;
		public var jumpp:int=0, downp:int=0;
		public var dash:int=22, dash_t:int=0, dash_maxt:int=30, kdash_t:int=0, dash_dy:int=-2;
		public var osnSpeed:Number;
		var t_fly:Number=0;
		public var noReanim:Boolean=false;
		public var pinok:Number=0;	//сбивание с лестниц
		public var noStairs:Boolean=false;	//запред движения по лестницам
		public var dstam:Number=5;	//расход выносливости
		
		//телекинез
		public var levitOn:int=0;
		public var teleObj:Obj, teleSqrtMassa:Number, teleSpeed:Number=8, teleAccel:Number=1, maxTeleDist:int=200;
		public var levitup:Boolean=false;
		
		//действия
		public var ggControl:Boolean=true;	//Управление ГГ включено
		public var actionObj:Interact;
		public var t_action:int=0, mt_action:int=20;
		public var work:String='', t_work:int=0;
		private var actionReady:Boolean=true;
		private var t_stay:int=3;
		private var t_walk:int=3;
		private var t_run:int=0;
		public var runForever:int=0;
		public var h2o:Number=1000;
		public var stam:Number=1000;
		public var possRun:Boolean=true;
		public var zaput:int=0;	//перепутанное управление
		public var aJump:int=0;	//был ли прыжок, и какой именно
		var weapUp:Boolean=false;
		var inBattle:Boolean=false;
		public var noRad:Boolean=true;
		public var dodgePlus:Number=0;
		public var isStayDam:int=0;	//получать урон от стояния на полу
		
		//двойной прыжок
		public var dJump:Boolean=false;		//второй прыжок активен
		public var dJump2:Boolean=false;		//второй прыжок активен
		public var djumpdy:Number=5;		//сила
		public var maxdjumpp:int=10;		//продолжительность
		
		//оковы
		public var isFetter:int=0;
		public var fetX:Number=0;
		public var fetY:Number=0;
		var dfx:Number=0;
		var dfy:Number=0;
		var rfetter:Number=0;
		//
		public var t_raddam:int=0;
		public var t_nogas:int=0;	//не действовать газом
		var ddam1:Number=0;
		var ddam2:Number=0;
		var ddam3:Number=0;
		
		//магия
		public var currentSpell:Spell;
		var t_dclick:int=0;		//двойной клик
		public var t_port:int=0;
		public var t_culd:int=0;
		private var teleReady:Boolean=true;
		public var t_cryst:int=0, cryst:Boolean=false;
		
		//видимость
		public var sneak:Number=0;			//скрытность
		public var obs:Number=0;
		public var maxObs:Number=20;
		var minusObs:Number=0.1;	//скорость уменьшения видимости
		var isObs:int=0;
		public var showObsInd:Boolean=true;	//показывать индикатор скрытности
		
		//нычки
		var t_up:int=0;
		var lurked:Boolean=false;
		var lurkTip:int=1;
		var lurkX:Number=0;
		var lurkBox:Box;
		
		//инвентарь и оружие
		public var sats:Sats;
		public var invent:Invent;
		public var isTake:int=0;
		public var changeWeaponTime1:int=30, changeWeaponTime2:int=20, changeWeaponTime3:int=10;
		var t_reload:int=0;		//удерживание кнопки перезарядки
		public var punchWeapon:Weapon;
		public var throwWeapon:Weapon;
		public var magicWeapon:Weapon;
		public var paintWeapon:Weapon;
		public var newWeapon:Weapon;
		public var currentArmor:Armor;
		public var prevArmor:String='';
		public var armorEffect:Effect;
		public var currentAmul:Armor;
		public var atkPoss:int=1;			//возможность атаковать  в принципе (запрещает зелье тени)
		public var attackForever:int=0;		//неконтролируемая атака
		public var autoAttack:int=0;
		public var atkWeapon:int=0;		//какое оружие атакует в данный момент 1-осн, 2-метательное, 3-магия
		
		public var eyeMind:int=0;	//взгляд некроманта
		
		//отключение пипбака
		public var pipOff:int=0;
		
		public var rad:Number=0, drad:Number=0, drad2:Number=0, radX:Number=1, healhp:Number=0;
		
		//персонаж
		public var pers:Pers;
		
		//сопровождение
		public var pet:UnitPet;
		public var defpet:UnitPet;
		public var pets:Array;
		public var currentPet:String='';
		public var retPet:String='';
		public var noPet:int=0, noPet2:int=0;
		var k_pet:int=0;
		
		//визуальная часть
		public var levitFilter1:GlowFilter;
		public var levitFilter2:GlowFilter;
		protected var dieFilter:GlowFilter;
		protected var shadowFilter:DropShadowFilter;
		protected var invulnerFilter1:GlowFilter, invulnerFilter2:GlowFilter;
		var dashFilter:BlurFilter;
		var stealthFilter:BlurFilter;
		protected var dieTransform:ColorTransform = new ColorTransform();
		protected var teleTransform:ColorTransform = new ColorTransform();
		public var shineTransform:ColorTransform = new ColorTransform(); 
		public var t_levitfilter:int=-1;
		var freeAnim:int=0;
		var prev_levit;
		var f_levit:Boolean=false, f_die:Boolean=false, f_dash:Boolean=false, f_stealth:Boolean=false, f_inv:Boolean=false;
		public var f_shad:Boolean=false;
		var aMagic:int=50, aMC:int=50; //интенсивность магии установленная и текущая
		var headR:Number=0, headRO:Number=0, headRA:Number=0, t_head:int=100;	//поворот головы
		var hair:MovieClip, tail:MovieClip, hairY:Number=-1000;
		var hairDY:Number=0, hairR:Number=0;
		var prev_replic:String;
		var prev_dx:Number=0;
		
		public var rat:int=0, ratX:int=30, ratY:int=17;	//форма крысы
		public var mordaN:int=1;
		
		public var reloadbar:MovieClip;
		var showRadius:Boolean=false;
		var klip:int=300;
		public var visSel:Boolean=false; //селектор оружия
		public var animOff:Boolean=false;
		
		function testFunction()
		{

			if (Settings.chitOn) 
			{
				Settings.godMode=true;
				Settings.chit='port';
				Settings.drawAllMap=true;
				Settings.black=false;
				Settings.showAddInfo=true;
				World.world.grafon.layerLighting.visible=false;
			}
		}
		
		public function UnitPlayer(cid:String=null, ndif:Number=100, xml:XML=null, loadObj:Object=null) 
		{
			player=true; id='littlepip';
			vis=new visualPlayer();
			vis.osn.body.pip2.visible=false;
			vis.osn.stop();
			vis.inh.visible=vis.cryst.visible=vis.fetter.visible=vis.rat.visible=false;
			reloadbar=new reloadBar();
			reloadbar.visible=false;
			vis.addChild(reloadbar);
			if (vis.shit) vis.shit.visible=false;
			if (vis.svet) vis.svet.visible=false;
			storona=1;
			id_replic='pip';
			
			getXmlParam();
			walkSpeed=osnSpeed=maxSpeed;
			plavSpeed=walkSpeed*0.75;
			sitSpeed=walkSpeed*0.5;
			lazSpeed=walkSpeed*0.75;
			runSpeed=walkSpeed*2;
			
			critCh=0.05;
			
			brake=2;
			maxjumpp=8, plavdy=accel*0.5, levidy=accel*0.25;
			if (Settings.alicorn) levidy=accel*0.5;
			hp=maxhp;
			reloadbar.y=-scY-10;
			
			weaponKrep=0;	//0 - левитация оружия, 1 - держать
			
			teleColor=World.world.app.cMagic;
			//levitFilter=new GradientGlowFilter(0,0,[teleColor,teleColor,teleColor],[0,1,0],[0,100,255],6,6,1,3,"outer");
			levitFilter1=new GlowFilter(teleColor,0,6,6,2,3);
			teleFilter=new GlowFilter(teleColor,1,6,6,1,3);
			dieFilter=new GlowFilter(0xCC00FF,0,6,6,2,3);
			dashFilter=new BlurFilter(5,0,3);
			stealthFilter=new BlurFilter(3,3);
			shadowFilter=new DropShadowFilter(0,90,0,0.5,3,3,1,3,false,false,true);
			teleTransform.redMultiplier=Appear.trMagic.redMultiplier*0.5+1;
			teleTransform.greenMultiplier=Appear.trMagic.greenMultiplier*0.5+1;
			teleTransform.blueMultiplier=Appear.trMagic.blueMultiplier*0.5+1;
			shineTransform.greenMultiplier=1.5;
			shineTransform.blueMultiplier=1.2;
			invulnerFilter1=new GlowFilter(0xFF5555,1,2,2,3,3);
			invulnerFilter2=new GlowFilter(0xFF0000,1,7,7,1,3);
			doop=true;
			transT=true;
			fraction=F_PLAYER;
			//destroy=20;
		}
		
		public function attach() {
			invent = World.world.invent;
			invent.gg=this;
			invent.owner=this;
			invent.addAllSpells();
			pers=World.world.pers;
			pers.gg=this;
			
			hp=maxhp=pers.begHP;
			if (invent.cArmorId!='' && invent.cArmorId!=null && !Settings.alicorn) changeArmor(invent.cArmorId,true);
			else pers.setParameters();
			if (invent.cAmulId!='' && invent.cAmulId!=null) changeArmor(invent.cAmulId,true);
			if (!pers.dead && invent.cWeaponId!='' && invent.cWeaponId!=null) changeWeapon(invent.cWeaponId);
			if (invent.cSpellId!='' && invent.cSpellId!=null) changeSpell(invent.cSpellId, false);
			prevArmor=invent.prevArmor;
			punchWeapon=new WKick(this,'punch');
			paintWeapon=new WPaint(this,'paint');
			childObjs=new Array(currentWeapon,punchWeapon);
			if (invent.fav[29]) 
			{
				throwWeapon=invent.weapons[invent.fav[29]];
				throwWeapon.setNull();
				throwWeapon.setPers(this,pers);
			}
			if (invent.fav[30]) 
			{
				magicWeapon=invent.weapons[invent.fav[30]];
				magicWeapon.setNull();
				magicWeapon.setPers(this,pers);
			}
			
			//спутники
			pets = new Array();
			pet=new UnitPet('phoenix');
			pet.gg=this;
			pet.setLevel(pers.level);
			pets['phoenix']=pet;
			defpet=pet;
			
			pet=new UnitPet('owl');
			pet.gg=this;
			pet.setLevel(pers.level);
			pets['owl']=pet;
			pet.hp=pet.maxhp*pers.owlhpProc;
			if (pers.owlhpProc<=0) pet.sost=4;
			
			pet=new UnitPet('moon');
			pet.gg=this;
			pet.setLevel(pers.level);
			pets['moon']=pet;
			
			pet=null;
			neujazMax=pers.neujazMax;
			
			if (pers.dead) {
				hp=0;
				controlOff();
				anim('die',true);
			} 
			else 
			{
				currentPet=pers.currentPet;
				if (currentPet!='' && currentPet!=null && currentPet!='moon') {
					pet=pets[currentPet];
					childObjs[2]=pet;
					pet.call();
				}
				if (currentPet=='moon') currentPet='';
				invent.nextItem(1);
				weaponLevit();
			}
			World.world.calcMassW=World.world.calcMass=true;
			setAddictions();
			if (Settings.alicorn) alicornOn(false);
			else pers.setParameters();
		}
		
		public override function setNull(f:Boolean=false):void
		{
			Y1=Y-scY, Y2=Y, X1=X-scX/2, X2=X+scX/2;
			setWeaponPos();
			if (currentWeapon) currentWeapon.setNull();
			dropTeleObj();
			actionObj=null;
			isLaz=0;
			//t_work=0;
			levit=0;
			f_stealth=stealthMult<1;
			f_die=f_levit=f_dash=f_inv=false;
			setFilters();
			vis.osn.alpha=1;
			vis.osn.transform.colorTransform=new ColorTransform();
		}
		
		public function setSpeeds() {
			walkSpeed=osnSpeed*pers.allSpeedMult;
			if (walkSpeed>pers.maxSpeed) walkSpeed=pers.maxSpeed;
			runSpeed=walkSpeed*pers.runSpeedMult;
			if (runSpeed>pers.maxSpeed) runSpeed=pers.maxSpeed;
			plavSpeed=walkSpeed*0.75;
			sitSpeed=walkSpeed*0.5;
			lazSpeed=walkSpeed*0.75;
		}
		

//**************************************************************************************************************************
//
//				Движение, перемещение в другую локацию
//
//**************************************************************************************************************************
		//выход из локации (попытка, возвращает true если выход успешный)
		public override function outLoc(napr:int, portX:Number=-1, portY:Number=-1):Boolean 
		{
			//не давать выйти
			if (teleObj || actionObj || t_work>0 || isFetter>0 || room.sky) return false;
			
			//не давать выйти, пока гг под атакой
			var po:int=World.world.possiblyOut();
			if (po>0 && !(napr==3 && room.bezdna) && rat==0) 
			{
				if (napr==3 && !room.bezdna) {
					dy=-jumpdy;
					dx=maxSpeed*storona;
				}
				if (po==2) World.world.gui.infoText('noOutLoc',null,null,false);
				return false;
			}
			
			var laz=isLaz, lev=levit;
			var outP:Object=World.world.level.gotoLoc(napr, portX, portY);
			if (outP!=null) 
			{
				if (outP.die) {						//смерть от падения в бездну (переход на кт)
					//damage(10000,Unit.D_INSIDE);
					die(-1);
					vis.visible=false;
					return false;
				}
				//if (napr!=5) teleport(outP.x,outP.y);
				if (napr==3 || napr==4) {
					if (laz!=0) {
						checkStairs();
						if (!isLaz) checkStairs(1,-Tile.tilePixelWidth*laz);
						if (!isLaz) checkStairs(1,Tile.tilePixelWidth*laz);
					}
				} 
				if (napr==4) {
					if (!isLaz && !isFly && lev==0) {
						dy=-jumpdy;
						dx=maxSpeed*storona;
					} else if (isFly || lev==1) {
						dy=-jumpdy;
					}
				}
				if (napr==5) dx=3*storona;
				if (sats.que.length > 0) sats.clearAll();
				if (levit==1 && !ctr.keyStates.keyJump) levit=0;
				return true;
			} else {
				return false;
			}
			return false;
			
		}
		
		//Enter the room
		public function inLoc(newRoom:Room)
		{
			if (pet) 
			{
				if (!newRoom.petOn && room.petOn) 
				{
					World.world.gui.infoText('noPetFollow');
					pet.vis.alpha=0;
					if (pet.hpbar) pet.hpbar.alpha=pet.vis.alpha;
				} 
				else 
				{
					pet.room=newRoom;
				}
				newRoom.units[1]=pet;
				pet.vis.visible=(newRoom.petOn && pet.sost<3);
			} 
			else 
			{
				newRoom.units[1] = defpet;
			}
			room = newRoom;
			if (currentWeapon) currentWeapon.room = room;
			if (throwWeapon) 
			{
				throwWeapon.room = room;
			}
			if (magicWeapon) 
			{
				magicWeapon.room = room;
			}
			cTransform = room.cTransform;
			t_nogas = 90;
			vis.transform.colorTransform = cTransform;
			if (currentWeapon && currentWeapon.tip != 5) currentWeapon.vis.transform.colorTransform = cTransform;
			if (effects.length > 0) 
			{
				for each (var eff in effects) eff.visEff();
			}
			if (!room.levitOn && isFly) isFly = false;
			if (room.electroDam > 0) 
			{
				World.world.gui.infoText('electroOn',null,null,true);
				isStayDam=45;
			}
			vis.svet.visible = room.sky;
		}
		
		public override function addVisual():void
		{
			super.addVisual();
			if (throwWeapon) {
				throwWeapon.addVisual2();
			}
			if (magicWeapon) {
				magicWeapon.addVisual2();
			}
		}

		
		//Set position on entering the room
		public function setLocPos(nx:Number,ny:Number)
		{
			X=nx, Y=ny;
			setNull();
			if (pet) 
			{
				pet.X = X;
				pet.Y = Y - 30;
				if (isSit) pet.Y = Y;
				pet.setNull();
				pet.oduplenie = 60;
			}
		}
		
//**************************************************************************************************************************
//
//				Actions
//
//**************************************************************************************************************************

		public override function forces():void
		{
			grav=1;
			if (kdash_t>0) {
				if (kdash_t==1) {
					dx*=0.3;
					dy*=0.3;
				}
			} else if (isLaz!=0) {
				dy=0;
				dx*=0.8;
			} else if (levit) {
				dy*=0.8;
				dx*=0.8;
			} else if (isFly) {
				if (ctr.keyStates.keyRun) {
					dy*=0.96;
					dx*=0.96;
				} else if (t_throw<=0){
					dy*=0.9;
					dx*=0.9;
				}
				t_fly+=0.1;
				if (room.electroDam>0) {
					dy+=Math.sin(t_fly)*0.7;
					dx+=storona*Math.cos(t_fly)*0.5;
				} else {
					dy+=Math.sin(t_fly)/5;
				}
			} else {
				var brake1=brake;
				if (inWater && !isPlav) dx*=0.5;
				if (isPlav) {
					dy+=Settings.ddy*ddyPlav;
					dy*=0.8;
				} else {
					var t:Tile=room.getAbsTile(X,Y-scY/4);
					if (t.grav>0 && dy<room.maxdy*t.grav || t.grav<0 && dy>room.maxdy*t.grav) {
						if (dash_t>dash_maxt-11) dy+=Settings.ddy*t.grav*0.1;
						else dy+=Settings.ddy*t.grav;
					}
					if (t.grav>0) grav=t.grav; else grav=0;
					if (t.grav<0) dx*=0.8;
				}
				//торможение
				if (isSit) brake1=0.4*brake;
				if (!stay) {
					brake1=0.1*brake;
				}
				//if (stay) {
					if (walk<0) {
						if (dx<-maxSpeed) dx+=brake1;
					} else if (walk>0) {
						if (dx>maxSpeed) dx-=brake1;
					} else {
						if (dx>-brake1 && dx<brake1) dx=0;
						else if (dx>0) dx-=brake1;
						else if (dx<0) dx+=brake1;
					}
				if (stay) {
					dx*=tormoz;
					if (room.quake && massa<=2) {
						var pun:Number=(1+(2-massa)/2)*room.quake;
						if (pun>10) pun=10;
						dy=-pun*Math.random();
						dx+=pun*(Math.random()*2-1);
					}
				}
			}
			osndx=osndy=0;
			if (stayOsn) {
				if (stayOsn.cdx>10 || stayOsn.cdx<-10 || stayOsn.cdy>10 || stayOsn.cdy<-10) {
					stay=false;
				} else {
					osndx=stayOsn.cdx;
					osndy=stayOsn.cdy;
				}
			}
			stayOsn=null;
			//оковы
			if (isFetter>0) {
				isLaz=0;
				dfx=fetX-X;
				dfy=fetY-Y+30;
				rfetter=Math.sqrt(dfx*dfx+dfy*dfy);
				if (rfetter>isFetter*2) {
					fetX=X;
					fetY=Y;
					dfx=dfy=rfetter=0;
				} 
				if (rfetter>isFetter*0.95) {
					if (rfetter>isFetter) {
						dx+=dfx/20;
						dy+=dfy/20;
					} else {
						dx+=dfx/20*(rfetter/isFetter*20-19);
						dy+=dfy/20*(rfetter/isFetter*20-19);
					}
				}
			} else {
				rfetter=0;
			}
		}
		
		public override function actions():void
		{
			super.actions();
			
			//взаимодействие с объектами
			/*for each(var obj:Obj in room.objs) {
				if (obj.radioactiv) {
					if (obj.rasst2<obj.radioactiv*obj.radioactiv) {
						drad+=(obj.radioactiv-Math.sqrt(obj.rasst2))/200;
					}
				}
			}*/
			
			inBattle=World.world.t_battle>0 || Settings.testBattle;
			
			//захват лута
			if (isTake>0) isTake--;
			//радиация
			if (noRad) {
				noRad=false;
			} else {
				drad+=room.rad;
				if (inWater) drad+=room.wrad;
			}
			if (drad2>0) {
				drad+=drad2;
				drad2-=0.1;
			}
			if (drad>0) {
				if (radX>0 && !invulner && !Settings.godMode) {
					rad+=drad/30*radX;
					if (pers.radChild>0 && rad>maxhp*(1-pers.radChild)) rad=maxhp*(1-pers.radChild);
					if (hp>maxhp-rad) {
						hp=maxhp-rad;
						if (hp<=0) die();
					}
					World.world.gui.setHp();
				}
				var ver:Number=Math.min(0.5, drad/10);
				if (drad>0.1 && isrnd (ver)) sound('geiger');
				if (pet) pet.heal(drad/15,1);
				drad=0;
			} else if (drad==0){
				World.world.gui.setHp();
				drad=-0.0001;
			}
			//лечение
			if (healhp>0) {
				healhp-=pers.healMult/5*pers.metaMult;
				hp+=pers.healMult/5*pers.metaMult;
				if (hp>maxhp-rad) hp=maxhp-rad;
				World.world.gui.setHp();
			}
			if (pers.regenFew>0 && hp<Math.min(maxhp*pers.regenMax,maxhp-rad) && hp>0) {
				hp+=pers.regenFew;
				World.world.gui.setHp();
			}
			if (Settings.alicorn && sost==1) {
				if (hp<maxhp) {
					hp+=pers.alicornHeal;
					if (hp>maxhp) hp=maxhp;
					World.world.gui.setHp();
				}
				if (pers.manaHP<pers.inMaxMana) {
					pers.manaHP+=pers.alicornManaHeal;
					if (pers.manaHP>pers.inMaxMana) pers.manaHP=pers.inMaxMana;
					World.world.gui.setMana();
				}				
			}
			//различные действия
			if (t_work>0) t_work--;
			else work='';
			if (work=='change' && t_work==changeWeaponTime2) {
				changeWeaponNow(1);
			}
			if (work=='change' && t_work==changeWeaponTime3) {
				changeWeaponNow(2);
			}
			//перейти на нижний слой
			if (work=='lurk' && t_work==10) {
				if (layer==2) {
					if (lurkTip==1) chLayer(0);
					else chLayer(1);
				}
				if (lurkBox && lurkBox.layer==1 && layer==1) {
					lurkBox.vis.parent.setChildIndex(lurkBox.vis,lurkBox.vis.parent.numChildren-1);
				}
			}
			if (work=='unlurk' && t_work==5) {
				if (layer==1 || layer==0) chLayer(2);
			}
			if (work=='lurk') {
				if (lurkX-X>3) dx=4;
				if (lurkX-X<-3) dx=-4;
			}
			//нычки
			if (lurked) {
				if (!stay) lurked=false;
				if (lurkBox && lurkBox.wall==0 && !lurkBox.stay) lurked=false; 
				if (work!='lurk' && (X-lurkX>10 || X-lurkX<-10)) lurked=false; 
			}
			if (!lurked && work!='unlurk' && (layer==1 || layer==0)) chLayer(2);
			
			//рывок
			f_dash=(dash_t>dash_maxt-20);
			if (dash_t>0) dash_t--;
			if (kdash_t>0) {
				kdash_t--;
				stay=false;
			}
			f_stealth=(stealthMult<1);
			
			//действие над активными объектами
			if (actionObj) {
				if (actionObj.active==0) {
					actionObj=null;
				} else if (t_action>0) {
					t_action--;
				} else {
					ctr.keyStates.keyAction=false;
					actionObj.is_act=true;
					actionObj=null;
				}
			}
			if (Snd.actionCh!=null && actionObj==null) {
				Snd.actionCh.stop();
				//sndCh.soundTransform.volume=0;
				Snd.actionCh=null;
			}

			//видимость
			/*visibility=1500*pers.visiMult;
			if (dx<2 && dx>-2 && dy<2 && dy>-2) visibility*=(0.5+pers.visiMult*0.5);*/
			visibility=2000;
			if (dx<2 && dx>-2 && dy<2 && dy>-2) visibility=1500;
			if (dx>10 || dx<-10 || dy>10 || dy<-10) {
				if (demask<200*pers.visiMult) demask=200*pers.visiMult;
			}
			if (obs>0 && isObs<=0) obs-=minusObs; 
			if (isObs>=0) isObs--;
			if (levit>0 && demask<200) demask=200;
			dexterPlus=0;
			detecting=80;
			if (isSit) dexterPlus=pers.sitDexterPlus;
			if (lurked) {
				detecting=0;
				dexterPlus=pers.lurkDexterPlus;
				visibility*=0.5;
			}
			if (stealthMult<0.5) detecting=0;

			//trace(detecting)

			//--------------------- оружие ------------------------
			//если выстрел был выполнен
			if (currentWeapon && currentWeapon.is_shoot) {
				if (sats.que.length > 0) {
					sats.act();
					World.world.gui.setWeapon();
				}
				currentWeapon.is_shoot=false;
			}
			if (currentWeapon && currentWeapon.tip!=5 && currentWeapon.vis && currentWeapon.vis.visible) aMagic=50;
			else aMagic=0;
			//если есть активные цели
			if (sats.que.length > 0) {
				if (currentWeapon==null || currentWeapon.noSats || currentWeapon.status()>3) {	//если оружие не готово
					sats.clearAll();	//очистить очередь
				} else if (sats.getReady()) {	//если цель ещё не убита
					sats.que[0].run();			//установить цель
					celX=sats.que[0].X;
					celY=sats.que[0].Y;
					currentWeapon.attack(true);	//стрелять по готовности
				} else {			
					sats.unsetCel(true);	//иначе отменить цель
				}
			} else if (attackForever) {
				if (isrnd(0.05)) {
					//celX=World.world.celX+Math.random()*600-300;
					//celY=World.world.celY+Math.random()*600-300;
					celX=Math.random()*room.roomPixelWidth;
					celY=Math.random()*room.roomPixelHeight;
				}
			} else {
				celX=World.world.celX;
				celY=World.world.celY;
			}
			//модификатор точности precMult, только если стрельба не через зпс
			precMult=pers.allPrecMult, mazil=pers.mazilAdd;
			if (sats.que.length == 0 && !lurked) {
				if (pers.runPenalty>0 && (dx>10 || dx<-10 || dy>10 || dy<-10))  precMult*=(1-pers.runPenalty);
				if (!stay) precMult*=(1-pers.jumpPenalty);
				//if (isLaz) precMult*=0.8;
				if (stay && dx<1 && dx>-1)  precMult*=(1+pers.stayBonus);
				if (currentWeapon && (currentWeapon.storona!=storona)) precMult*=(1-pers.backPenalty);
			}
			//trace('---',precMult)
			
			if (throwWeapon && currentWeapon!=throwWeapon) {
				throwWeapon.actions();
				if (throwWeapon.tip==5) throwWeapon.animate();
			}
			if (magicWeapon && currentWeapon!=magicWeapon) {
				magicWeapon.actions();
				if (magicWeapon.tip==5) magicWeapon.animate();
			}
			atkWeapon=0;
			if (currentWeapon && !currentWeapon.attackPos()) atkWeapon=1;
			if (throwWeapon && currentWeapon!=throwWeapon && !throwWeapon.attackPos()) atkWeapon=2;
			if (magicWeapon && currentWeapon!=magicWeapon && !magicWeapon.attackPos()) atkWeapon=3;
			
			//телекинез
			var derp=15;
			if (teleObj) {
				aMagic=50;
				if (teleObj.massa>=1) aMagic=100;
				if (demask<200) demask=200;
				if (isTake<10) isTake=40;
				if (teleObj.X<celX-derp && teleObj.dx<teleSpeed) teleObj.dx+=teleAccel;
				if (teleObj.X>celX+derp && teleObj.dx>-teleSpeed) teleObj.dx-=teleAccel;
				if (teleObj.Y-teleObj.scY/2<celY-derp && teleObj.dy<teleSpeed) teleObj.dy+=teleAccel;
				if (teleObj.Y-teleObj.scY/2>celY+derp && teleObj.dy>-teleSpeed) teleObj.dy-=teleAccel;
				if (teleObj is Unit) {
					if ((teleObj as Unit).levit_max>0 && (teleObj as Unit).levit_r>(teleObj as Unit).levit_max*pers.unitLevitMult) {
						teleObj.levitPoss=false;
						dropTeleObj();
					}
				}
			}
			if (teleObj) {
				if (room.celDist>pers.teleDist*1.2 || mana<=0 || !teleObj.levitPoss) {
					dropTeleObj();
				} else if (teleObj is Unit && (teleObj as Unit).sost==1) {
					/*if (Math.abs(teleObj.X-celX)>maxTeleDist || Math.abs(teleObj.Y-celY)>maxTeleDist) {
						dropTeleObj();
					}*/
				}
				//trace(teleObj.dx,teleObj.dy)
			}
			if (levit==1) aMagic=100;
			if (sost>1) aMagic=0;
			//двойной клик
			if (t_dclick>0) t_dclick--;
			//кулдаун заклинания
			if (t_culd>0) t_culd--;
			if (shithp>0) shithp-=0.05;
			//мана
			if (teleObj || levit==1 || cryst) {
				dmana=0;
				if (teleObj) {			
					dmana-=teleSqrtMassa*pers.teleMult;
				} 
				if (levit==1) {
					if (levitup) dmana-=(pers.levitDManaUp*grav+pers.levitDMana);
					else dmana-=pers.levitDMana;
				}
				dmana*=pers.allDManaMult;
				if (pers.teleMana>0) {
					if (levit==1) pers.manaDamage(-dmana*pers.teleMana*pers.teleManaMult);
					else pers.manaDamage(-dmana/3*pers.teleMana*pers.teleManaMult);
				}
			} else if (Settings.alicorn && isFly && ctr.keyStates.keyRun && (ctr.keyStates.keyLeft || ctr.keyStates.keyRight || ctr.keyStates.keyBeUp)) {
				dmana=-pers.alicornRunMana;
				if (!room.sky) Emitter.emit('magrun',room,X,Y-scY/2,{dx:(dx*0.5+Math.random()*4-2), dy:(dy*0.5+Math.random()*4-2)});
			} else {
				if (dmana<pers.recManaMin*pers.shtrManaRes) dmana=pers.recManaMin*pers.shtrManaRes;
				dmana+=pers.recMana*pers.shtrManaRes;
			}
			mana+=dmana;
			if (mana>maxmana) mana=maxmana;
			if (pers.manaHP<pers.manaMin) {
				pers.manaHP+=pers.manaHPRes;
				World.world.gui.setMana();
			}
			//воздух
			if (isPlav) {
				isFly=false;
				if (h2o>0) {
					h2o-=pers.h2oPlav;
					if (sost==1 && isrnd(0.1)) Emitter.emit('bubble',room,X+storona*23,Y-58);
				} else {
					damage(maxhp/500,D_INSIDE,null,true);
					if (sost==1 && isrnd())Emitter.emit('bubble',room,X+storona*23,Y-58);
				}
			} else if (h2o<1000) {
				h2o+=10;
				if (h2o>1000) h2o=1000;
			}
			//запас сил
			if (isRun && walk && stay && !isSit && (dx!=0)) {
				if (stam>0) {
					if (inBattle) stam-=pers.stamRun*dstam;
				} else possRun=false;
			} else if (stam<1000) {
				stam+=pers.stamRes;
				if (stam>200) possRun=true;
				if (stam>1000) stam=1000;
			}
			//рывок
			if (dash_t>dash_maxt-10 || kdash_t>0) dodge=1+dodgePlus;
			else dodge=dodgePlus;
			//броня
			if (currentArmor && currentArmor.maxmana>0) {
				if (currentArmor.abilActive) {
					if (currentArmor.mana>0) {
						currentArmor.mana-=currentArmor.dmana_use;
					} else {
						if (armorEffect) {
							armorEffect.unsetEff(true,false,true);
						}
						currentArmor.abilActive=false;
					}
				} else {
					if (currentArmor.mana<currentArmor.maxmana) {
						currentArmor.mana+=currentArmor.dmana_res;
					}
				}
			}
			//кристальный щит
			if (t_cryst>0) {
				if (t_cryst==4) vis.cryst.gotoAndPlay(10);
				t_cryst--;
				if (!cryst) {
					vis.cryst.gotoAndPlay(1);
					vis.cryst.visible=true;
				}
				cryst=true;
			} else {
				if (cryst) vis.cryst.visible=false;
				cryst=false;
			}
			stun=0;
			//поворот оружия
			weaponR=-(celY-Y)/10;
			if (weaponR>85) weaponR=85;
			if (weaponR<-85) weaponR=-85;
			//свечение магии
			if (aMC<aMagic) aMC+=5;
			if (aMC>aMagic) aMC-=5;
			//спутник
			if (noPet>0) {
				noPet--;
				World.world.gui.setPet();
			}
			if (noPet2>0) noPet2--;
			if (pet && pet.sost==4 && noPet<=0 && pet.optAutores) pet.resurrect();
			//удары ап стену
			//if (stay) damWall=0;
			//откл. пипбака
			if (pipOff==1) World.world.gui.allOn();
			if (pipOff>0) pipOff--;
			//неконтролируемая атака
			if (attackForever) {
				if (isrnd(0.1)) {
					autoAttack=1-autoAttack;
				}
			} else {
				autoAttack=0;
			}
			//удары врагов
			if (pinok>0) {
				if (stay || isLaz!=0) pinok--;
				else pinok-=3;
			}
			//урон на расстоянии
			t_raddam++;
			if (t_nogas>0) t_nogas--;
			if (t_raddam>30) {
				t_raddam=0;
				if (ddam1>0) {
					damage(ddam1/30,Unit.D_VENOM,null,true);
					ddam1=0;
				}
				if (ddam2>0) {
					damage(ddam2/30,Unit.D_PINK,null,true);
					ddam2=0;
				}
				if (ddam3>0) {
					damage(ddam3/30,Unit.D_NECRO,null,true);
					ddam3=0;
				}
			}
			//урон от блоков
			if (isStayDam>0) {
				isStayDam--;
				//vis.alpha=0.4;
			} //else vis.alpha=1;
			if (room.electroDam>0 && isStayDam==0) {
				if (stay && stayMat==1 || isLaz || inWater || tykMat==1) {
					isStayDam=20;
					if (tykMat==1) {
						if (turnX!=0) Emitter.emit('moln',room,X,Y-scY/2,{celx:(X+45*storona), cely:Y-10});
						else if (turnY==1) Emitter.emit('moln',room,X,Y-scY/2,{celx:X, cely:Y-70});
						else if (turnY==-1) Emitter.emit('moln',room,X,Y-scY/2,{celx:X, cely:Y+20});
					} else if (isLaz) {
						Emitter.emit('moln',room,X,Y-scY/2,{celx:(X+20*storona), cely:Y-10});
					} else if (stay) {
						Emitter.emit('moln',room,X,Y-scY/2,{celx:(X-25*shX2+Math.random()*25*(shX1+shX2)), cely:(Y+20)});
					}
					electroDamage();
				}
			}
			if (room.electroDam>0) showElectroBlock();
			if (room.sky) isFly=true;
			turnY=turnX=0;
			tykMat=0;
			//заклинания
			for each (var sp:Spell in invent.spells) sp.step();
			t_replic--;
		}
		
		//расход магии при ударах по левитируемому ящику
		public function otbrosTele(knock:Number):void
		{
			mana -= pers.teleMult * knock * 5;
		}
		
		//активировать заклинание телепорта
		public function actPort():void
		{
			if (!room.portOn) return;
			if (mana<pers.portMana*pers.allDManaMult && mana<maxmana*0.99) {
				World.world.gui.infoText('overMana',null,null,false);
				World.world.gui.bulb(X,Y-20);
			} else {
				var nx=Math.round(World.world.celX/Settings.tilePixelWidth)*Settings.tilePixelWidth
				var ny=Math.round(World.world.celY/Settings.tilePixelHeight+1)*Settings.tilePixelHeight-1;
				if (checkPort()) {
					teleport(nx, ny, 1);
					sound('teleport');
					manaSpell(pers.portMagic,pers.portMana);
					if (room.electroDam) {
						electroDamage(room.electroDam);
						addEffect('burning',40);
						newPart('iskr',40);
					}
					t_culd=Math.floor(pers.spellDown*pers.portDown);
					dx=dy=0;
				}
			}
		}
		
		public function alicornPort():void
		{
			if (mana<pers.alicornPortMana && mana<maxmana*0.99) {
				World.world.gui.infoText('overMana',null,null,false);
				World.world.gui.bulb(X,Y-20);
				return;
			}
			if (!room.sky) {
				var t:Tile=room.getAbsTile(World.world.celX,World.world.celY);
				if (t.visi<0.8) return;
			}
			var tx=Math.round(World.world.celX/Settings.tilePixelWidth)*Settings.tilePixelWidth
			var ty=Math.round(World.world.celY/Settings.tilePixelHeight+1)*Settings.tilePixelHeight-1;
			if (room.sky || !room.collisionUnit(tx,ty,stayX,stayY))	{
				teleport(tx, ty, 1);
				if (teleObj) dropTeleObj();
				mana-=pers.alicornPortMana;
				dmana=0;
			}
		}
		
		//проверить возможность телепорта
		public function checkPort():Boolean
		{
			if (mana<pers.portMana*pers.allDManaMult) return false;
			if (room.sky) return true;
			var nx=Math.round(World.world.celX/Settings.tilePixelWidth)*Settings.tilePixelWidth
			var ny=Math.round(World.world.celY/Settings.tilePixelHeight+1)*Settings.tilePixelHeight-1;
			var t:Tile=room.getAbsTile(World.world.celX,World.world.celY);
			//if (!room.collisionUnit(tx,ty,stayX,stayY))	teleport(tx, ty);
			if (t.visi>=0.8 && !room.collisionUnit(nx, ny,stayX,stayY)) return true;
			//if (t.visi>=0.8 && !collisionAll(nx-X, ny-Y)) return true;
			return false;
		}
		
		//снять нужное количество маны, установить время перезарядки
		public function manaSpell(dmag:Number, dm:Number):void
		{
			//if (culd>0) t_culd=Math.floor(pers.spellDown*culd);
			mana-=dmag*pers.allDManaMult;
			pers.manaDamage(dm*pers.allDManaMult);
			dmana=0;
			if (teleObj) dropTeleObj();
		}
		
		public function castSpell(sid:String=null):void
		{
			
		}
		
		public function spellDisact():void
		{
			ctr.keyStates.keyDef = false;
		}
		
		public function bindChain(nx:Number, ny:Number):void
		{
			addEffect('fetter',0,10,false);
			fetX=nx, fetY=ny;
		}
		
		//включить или выключить левитацию объекта при нажатой клавише левитации
		public function actTele():void
		{
			//двойной клик
			if (t_dclick>0) {
			}
			if (t_dclick==0) t_dclick=15;
			if (teleObj) {
				dropTeleObj();
				return;
			}
			//найти ближайший подходящий объект, если курсор не указывает прямо на цель
			if (mana<200) return;
			if (room.celObj==null) {
				var dist=(X-World.world.celX)*(X-World.world.celX)+(Y-scY/2-World.world.celY)*(Y-scY/2-World.world.celY);
				if (dist>pers.teleDist) return;
				if (!room.isLine(X,Y-scY*0.75, World.world.celX, World.world.celY)) return;
				var pt:Pt=room.firstObj;
				var mindist=50*50;
				while (pt) {
					if ((pt is Obj) && (pt as Obj).levitPoss && (pt as Obj).massa<=pers.maxTeleMassa) {
						dist=(World.world.celX-pt.X)*(World.world.celX-pt.X)+(World.world.celY-pt.Y+(pt as Obj).scY/2)*(World.world.celY-pt.Y+(pt as Obj).scY/2);
						if (dist<mindist) {
							room.celObj=(pt as Obj);
							mindist=dist;
						}
					}
					pt=pt.nobj;
				}
				if (room.celObj) {
					room.celObj.onCursor=1;
					room.celDist=0;
				}
			}
			if (room.celObj && room.celObj.levitPoss && room.celObj.onCursor && room.celDist<=pers.teleDist && room.celObj.massa<=pers.maxTeleMassa){
				if ((pers.telemaster==0 || !room.portOn) && !room.isLine(X,Y-scY*0.75,room.celObj.X, room.celObj.Y-room.celObj.scY/2)) {
					World.world.gui.infoText('noVisible',null,null,false);
					return;
				}
				if (room.electroDam && (room.celObj is Box) && (room.celObj as Box).mat==1) {
					electroDamage(room.electroDam,room.celObj.X,room.celObj.Y-room.celObj.scY/2);
					return;
				}
				teleObj=room.celObj;
				if (teleObj==null) return;
				if (teleObj.massa>pers.telePorog) teleSqrtMassa=Math.sqrt(teleObj.massa);
				else teleSqrtMassa=0;
				if (teleObj.vis) {
					teleObj.vis.filters=[teleFilter];
					teleObj.vis.transform.colorTransform=teleTransform;
					teleObj.vis.parent.setChildIndex(teleObj.vis,teleObj.vis.parent.numChildren-1);
				}
				if (teleObj is Unit) (teleObj as Unit).alarma(X,Y);
				teleObj.levit=1;
				if (teleObj.inter) teleObj.inter.sign=0;
				teleObj.fracLevit=fraction;
				teleObj.stay=false;
				ctr.keyStates.keyTele=false;
			}
		}
		
		//бросок телекинезом
		public function throwTele():void
		{
			if (teleObj) {
				if (pers.spellsPoss<=0) {
					dropTeleObj();
					return;
				}
				var p:Object={x:(teleObj.X-X), y:(teleObj.Y-teleObj.scY/2-Y+scY/2-10)}
				var dm=0
				if (pers.throwForce>0) dm=teleObj.massa*pers.throwDmagic*pers.allDManaMult;
				if (dm<=mana) {
					norma(p,pers.throwForce);
					mana-=dm;
					pers.manaDamage(dm*pers.throwDmanaMult);
				} else {
					norma(p,pers.throwForce*mana/dm);
					pers.manaDamage(mana*pers.throwDmanaMult);
					mana=0;
				}
				if (teleObj is Box) {
					(teleObj as Box).isThrow=true;
					(teleObj as Box).t_throw=2;
				}
				if (teleObj is Unit) {
					(teleObj as Unit).t_throw=45;
				}
				World.world.gui.setMana();
				teleObj.dx+=p.x;
				teleObj.dy+=p.y;
				if (pers.throwForce>0) {
					Emitter.emit('throw',room,teleObj.X,teleObj.Y-teleObj.scY/2,{rotation:Math.atan2(teleObj.dy,teleObj.dx)*180/Math.PI});
					Snd.ps('dash',teleObj.X,teleObj.Y);
				}
				//Emitter.emit('magrun',room,teleObj.X,teleObj.Y-teleObj.scY/2,{dx:teleObj.dx, dy:teleObj.dx});
				dropTeleObj();
			}
		}
		
		public function throwForceRelat():Number
		{
			if (teleObj) {
				var dm:Number=teleObj.massa*pers.throwDmagic*pers.allDManaMult;
				if (dm>mana) return mana/dm;
				else return 1;
			}
			return 0;
		}
		
		//уронить левитируемый объект
		public function dropTeleObj():void
		{
			if (teleObj) {
				if (teleObj.vis) {
					teleObj.vis.filters=[];
					if (teleObj.cTransform) teleObj.vis.transform.colorTransform=teleObj.cTransform;
				}
				teleObj.levit=0;
				teleObj=null;
				World.world.gui.setMana();
			}
		}
		
		
		//действие с активным объектом при удерживаемой клавише действия
		public function actAction():void
		{
			if (actionObj) 
			{

				if ((X-actionObj.X)*(X-actionObj.X)+(Y-actionObj.Y)*(Y-actionObj.Y)>Settings.actionDist) 
				{
					actionObj = null;
				}
			} 
			else if (actionReady && room.celObj && room.celObj.onCursor && room.celDist<=Settings.actionDist)
			{
				actionReady=false;
				if ((pers.telemaster==0 || !room.portOn || (room.celObj is Loot) || (room.celObj.inter && room.celObj.inter.allact=='comein')) && !room.isLine(X, Y - scY * 0.75, room.celObj.X, room.celObj.Y - room.celObj.scY / 2, room.celObj)) 
				{
					World.world.gui.infoText('noVisible',null,null,false);
					return;
				}
				if (room.electroDam && (room.celObj is Box) && (room.celObj as Box).mat == 1) 
				{
					electroDamage(room.electroDam, room.celObj.X, room.celObj.Y - room.celObj.scY / 2);
					return;
				}
				if (room.celObj.inter &&  room.celObj.inter.active &&  room.celObj.inter.action>0) 
				{
					if (room.celObj.inter.needSkill) 
					{
						room.celObj.inter.unlock=pers.getSkillLevel(room.celObj.inter.needSkill);
					} 
					if (room.celObj.inter.mine>0) //ловушка или бабах
					{
						room.celObj.inter.unlock=pers.getLockTip(room.celObj.inter.mineTip);
						t_action = room.celObj.inter.t_action+pers.getLockPickTime(room.celObj.inter.mine, 3);
						actionObj = room.celObj.inter;
					} 
					else if (room.celObj.inter.lock > 0 && room.celObj.inter.lockKey && invent.items[room.celObj.inter.lockKey].kol > 0) 	//открыть ключом
					{
						room.celObj.inter.unlock=1;
						t_action=20;
						actionObj=room.celObj.inter;
					} 
					else if (room.celObj.inter.lock>=100) 	//заклинило
					{
						return;
					} 
					else if (room.celObj.inter.lock>0) 	//взлом
					{
						if (room.celObj.inter.lockTip==0) return;
						//if (pers.possLockPick<=0) return;
						room.celObj.inter.unlock=pers.getLockTip(room.celObj.inter.lockTip);
						room.celObj.inter.master=pers.getLockMaster(room.celObj.inter.lockTip);
						t_action=room.celObj.inter.t_action+pers.getLockPickTime(room.celObj.inter.lock, room.celObj.inter.lockTip);
						actionObj=room.celObj.inter;
					} 
					else if (room.celObj.inter.t_action) 	//открывается какое-то время
					{		
						t_action=room.celObj.inter.t_action;
						actionObj=room.celObj.inter;
						actionObj.beginAct();
					} 
					else 		//открыть сразу
					{						
						room.celObj.inter.is_act=true;
					}
					mt_action=t_action;
					if (mt_action<=0) mt_action=1;
					if (actionObj) actionObj.sound();
				}
			}
		}
		
		public function crackAction():void
		{
			if (actionReady && room.celObj && room.celObj.onCursor && room.celDist<=Settings.actionDist)
			{
				if (room.celObj.inter &&  room.celObj.inter.needRuna(this)) 
				{
					room.celObj.inter.useRuna(this);
				}
			}
		}

		public function chit():void
		{
			if (Settings.chit=='fly') isFly=!isFly;
			if (Settings.chit=='port') {
				var tx=Math.round(World.world.celX/Settings.tilePixelWidth)*Settings.tilePixelWidth
				var ty=Math.round(World.world.celY/Settings.tilePixelHeight+1)*Settings.tilePixelHeight-1;
				if (!room.collisionUnit(tx,ty,stayX,stayY))	teleport(tx, ty);
			}
			if (Settings.chit=='emit') {
				Emitter.emit(Settings.chitX,room,World.world.celX, World.world.celY);
			}
		}
		
		//включить неуязвимость, отключить управление
		public function controlOff():void
		{
			ctr.clearAll();
			ggControl=false;
			dropTeleObj();
			actionObj=null;
			invulner=true;
			isRun=false;
			walk=0;
			if (currentWeapon) currentWeapon.vis.visible=false;
			World.world.pip.gamePause=true;
		}
		
		//вернуть обычный режим
		public function controlOn():void
		{
			if (pers.dead) return;
			invulner=false;
			ggControl=true;
			if (currentWeapon) currentWeapon.vis.visible=true;
			World.world.pip.gamePause=false;
		}
		
		public override function sit(turn:Boolean):void
		{
			if (rat) return;
			super.sit(turn);
		}
		
		public override function control():void
		{
			if (!ggControl) 
			{
				return;
			}
			var keyLeft:Boolean=zaput?ctr.keyStates.keyRight:ctr.keyStates.keyLeft;
			var keyRight:Boolean=zaput?ctr.keyStates.keyLeft:ctr.keyStates.keyRight;
			if (work=='lurk' || work=='unlurk' || work=='res') return;
			if (lurked) {
				if (ctr.keyStates.keyBeUp || ctr.keyStates.keySit || ctr.keyStates.keyJump) {
					unlurk();
					ctr.clearAll();
					return;
				}
				if (keyLeft || keyRight) {
					if (lurkTip==1 || lurkTip==3) {
						if (keyLeft) storona=-1;
						if (keyRight) storona=1;
					}
					return;
				}
			}
			//--------------------- различные действия ---------------------------
			//действие
			if (ctr.keyStates.keyAction && rat==0) 
			{
				if (!teleObj) {
					if (sats.que.length > 0) sats.clearAll();
					actAction();
				} else {
					throwTele();
					ctr.keyStates.keyAction=false;
				}
			} 
			else 
			{
				actionReady=true;
				actionObj=null;
			}
			if (ctr.keyStates.keyCrack && !ctr.keyStates.keyAction && !room.base && rat==0) 
			{
				ctr.keyStates.keyCrack=false;
				crackAction();
			}
			//телекинез
			if (ctr.keyStates.keyTele && !ctr.keyStates.keyAction && !room.base && rat==0) 
			{
				if (!teleReady) 
				{
					if (sats.que.length > 0) sats.clearAll();
					if (visSel) World.world.gui.unshowSelector(0);
					else actTele();
					teleReady=true;
				}
				if (t_culd<=0 && pers.portPoss && pers.spellsPoss && !Settings.alicorn) t_port++;
			} else {
				if (teleReady) {
					if (t_port>=pers.portTime && pers.portPoss && pers.spellsPoss && room.portOn) {
						actPort();
					}
					teleReady=false;
				}
				t_port=0;
			}
			//полёт
			if (ctr.keyStates.keyFly) {
				chit();
				ctr.keyStates.keyFly=false
			}
			//тестовая функция
			if (ctr.keyStates.keyTest1) {
				testFunction();
				ctr.keyStates.keyTest1=false;
			}
			//взрывчатка
			if (ctr.keyStates.keyGrenad && !room.base && !ctr.keyStates.keyAttack && attackForever<=0 && atkPoss && (atkWeapon==0 || atkWeapon==2)) {
				if (sats.que.length > 0) sats.clearAll();
				if (throwWeapon) {
					throwWeapon.attack();
					spellDisact();
					if (throwWeapon.tip==4) ctr.keyStates.keyGrenad=false;
				} else ctr.keyStates.keyGrenad=false;
			}
			//магия
			if (ctr.keyStates.keyMagic && !room.base && !ctr.keyStates.keyAttack && attackForever<=0 && atkPoss && (atkWeapon==0 || atkWeapon==3)) {
				if (sats.que.length > 0) sats.clearAll();
				if (magicWeapon) {
					magicWeapon.attack();
					spellDisact();
					if (magicWeapon.tip==4) ctr.keyStates.keyMagic=false;
				} else ctr.keyStates.keyMagic=false;
			}
			//заклинание
			if (ctr.keyStates.keyDef && rat==0) { //&& !room.base
				if (sats.que.length > 0) sats.clearAll();
				if (Settings.alicorn) currentSpell=invent.spells['sp_mshit'];
				if (currentSpell) {
					if (!currentSpell.cast(World.world.celX, World.world.celY)) ctr.keyStates.keyDef=false;
					if (!currentSpell.prod) ctr.keyStates.keyDef=false;
				} else ctr.keyStates.keyDef=false;
			} //else if (currentSpell) currentSpell.active=false;
			for (var i=1; i<=Settings.kolQS; i++) {
				if (ctr['keySpell'+i]) {
					if (invent.fav[Settings.kolHK*2+i]!=null) {
						if (sats.que.length > 0) sats.clearAll();
						var sp:Spell=invent.spells[invent.fav[Settings.kolHK*2+i]];
						if (sp) {
							if (!sp.cast(World.world.celX, World.world.celY)) ctr['keySpell'+i]=false;
							if (!sp.prod) ctr['keySpell'+i]=false;
						} else ctr['keySpell'+i]=false;
					} else ctr['keySpell'+i]=false;
				}
			}
			//спутник
			if (ctr.keyStates.keyPet) { //&& !room.base
				k_pet++;
				if (k_pet>20) {
					if (pet) {
						pet.moveTo(X,Y-40,true);		//отзыв назад
					}
					k_pet=0;
					ctr.keyStates.keyPet=false;
				}
			} else {
				if (k_pet>0) {				//приказ
					if (pet) {
						if (room.celObj && room.celObj is Unit && (room.celObj as Unit).fraction!=fraction) pet.atk((room.celObj as Unit));
						else pet.moveTo(celX,celY);
					}
				}
				k_pet=0;
			}
			//атака
			if ((ctr.keyStates.keyAttack || autoAttack) && (!room.base || visSel) && atkPoss && (atkWeapon==0 || atkWeapon==1)) {
				if (visSel) {
					World.world.gui.unshowSelector(1);
					ctr.keyStates.keyAttack=false;
				} else if (ctr.keyStates.keyTele) {
					ctr.keyStates.keyTele=false;
					ctr.keyStates.keyAttack=false;
					t_port=0;
					spellDisact();
				} else if (currentWeapon && t_work<=0) {
					if (sats.que.length > 0) {
						sats.clearAll();
						ctr.keyStates.keyAttack=false;
					} else {
						weaponSkill=pers.weaponSkills[currentWeapon.skill];
						if (!currentWeapon.attack()) ctr.keyStates.keyAttack=false;
						World.world.gui.setWeapon();
						spellDisact();
					}
				}
			}
			//перезарядка
			if (ctr.keyStates.keyReload && currentWeapon && attackForever<=0) {
				//return;
				if (t_reload>=30) {
					currentWeapon.unloadWeapon();
					ctr.keyStates.keyReload=false;
				}
				if (currentWeapon.detonator()) ctr.keyStates.keyReload=false;
				t_reload++;
			} else {
				if (currentWeapon && t_reload>0 && t_reload<10) currentWeapon.initReload();
				t_reload=0;
			}
			//пинок
			if (ctr.keyStates.keyPunch && Settings.alicorn) {
				ctr.keyStates.keyPunch=false;
				alicornPort();
			}
			if (ctr.keyStates.keyPunch && !Settings.alicorn && stay && t_work==0 && !isSit && !keyLeft && !keyRight && !room.base && !lurked && attackForever<=0 && atkPoss) {
				(punchWeapon as WKick).kick=ctr.keyStates.keyRun;
				punchWeapon.attack();
				spellDisact();
				work='punch';
				t_work=13;
				ctr.keyStates.keyPunch=false;
			}
			if (ctr.keyStates.keyPunch && rat>0) {
				remEffect('potion_rat');
				ctr.keyStates.keyPunch=false;
			}
			if (rat==0) {
			//смена оружия
				if (t_work<=0 && attackForever<=0) {
					for (var i=1; i<=Settings.kolHK; i++) {
						if (ctr['keyWeapon'+i]) {
							ctr['keyWeapon'+i]=false;
							invent.useFav(i+(ctr.keyStates.keyRun?Settings.kolHK:0));
							if (visSel) World.world.gui.unshowSelector(0);
							if (currentSpell) currentSpell.active=false;
							ctr.keyStates.keyDef=ctr.keyStates.keyAttack=false;
						}
					}
				}
				if (ctr.keyStates.keyScrDown && !autoAttack) {
					World.world.gui.showSelector(1, ctr.keyStates.keyRun?1:0);
					ctr.keyStates.keyScrDown=ctr.keyStates.keyScrUp=false;
				}
				if (ctr.keyStates.keyScrUp && !autoAttack) {
					World.world.gui.showSelector(-1, ctr.keyStates.keyRun?1:0);
					ctr.keyStates.keyScrDown=ctr.keyStates.keyScrUp=false;
				}
				//вещи
				if (ctr.keyStates.keyItemNext) {
					invent.nextItem(1);
					ctr.keyStates.keyItemNext=ctr.keyStates.keyItemPrev=false;
				}
				if (ctr.keyStates.keyItemPrev) {
					invent.nextItem(-1);
					ctr.keyStates.keyItemNext=ctr.keyStates.keyItemPrev=false;
				}
				if (ctr.keyStates.keyItem) {
					invent.useItem();
					ctr.keyStates.keyItem=false;
				}
				if (ctr.keyStates.keyPot) {
					invent.usePotion();
					ctr.keyStates.keyPot=false;
				}
				if (ctr.keyStates.keyMana) {
					invent.usePotion('mana');
					ctr.keyStates.keyMana=false;
				}
				if (ctr.keyStates.keyArmor) {
					armorAbil();
					ctr.keyStates.keyArmor=false;
				}
			}
			
			//--------------------- движение ---------------------------
			//скорость
			var accel1=accel*pers.accelMult;
			maxSpeed=walkSpeed;
			if (stay && ctr.keyStates.keyAction && maxSpeed>3) {
				accel1=accel*0.4;
				maxSpeed=3;
			}
			if (room.sky) {
				maxSpeed*=3;
			}
			isRun=((possRun || stam>200) && ctr.keyStates.keyRun || runForever>0);
			if (h2o<=0) isRun=false;
			if (isRun && stay) maxSpeed=runSpeed;
			if (isSit && stay) maxSpeed=sitSpeed;
			if (diagon!=0) maxSpeed=walkSpeed*0.75;
			if (isPlav) maxSpeed=plavSpeed*pers.speedPlavMult;
			if (maxSpeed>walkSpeed && currentWeapon && currentWeapon.massa>=0.1 && pers.bigGunsSlow>0) maxSpeed*=(1-currentWeapon.massa*pers.bigGunsSlow);
			if (!stay) accel1=0.1*accel;
			if (isPlav) accel1=0.3*accel*pers.speedPlavMult;
			if (isFly) {
				maxSpeed*=1.3;
				if (Settings.alicorn && ctr.keyStates.keyRun && mana>20) {
					accel1=accel;
					maxSpeed=runSpeed*pers.alicornFlyMult;
					if (room.sky) maxSpeed*=2;
				} else accel1=0.5*accel; 
			}
			if (isLaz) accel1=1.4*accel; 
			if (levit) {
				maxSpeed=1000;
				accel1=0.3*accel; 
			}
			if (cryst) {
				maxSpeed=sitSpeed;
			}
			porog=0;
			porog_jump=0;//(dy>=0)?5:0;
			
			if ((isRun || ctr.keyStates.keyBeUp)&& jumpNumb==0) porog_jump=10;

			//ускорение
			//trace(diagonRot);
			if (!isLaz) {
				if (keyLeft && !keyRight) {
					storona=-1;
				}
				if (!keyLeft && keyRight) {
					storona=1;
				}
			}
			walk=0;
			if (keyLeft && !keyRight || runForever>0 && storona<0) {
				porog=20;
				isTake=40;
				if (storona>0 && stay) {
					storona=-1;
				} else if (dx>-maxSpeed && (!ctr.keyStates.keyRun || t_run>3)) {
					dx-=accel1;
					if (dx<-maxSpeed) dx=-maxSpeed;
				}
				walk=-1;
				t_run++;
			} else if (!keyLeft && keyRight || runForever>0 && storona>0) {
				porog=20;
				isTake=40;
				if (storona<0 && stay) {
					storona=1;
				} else if (dx<maxSpeed && (!ctr.keyStates.keyRun || t_run>3)) {
					dx+=accel1;
					if (dx>maxSpeed) dx=maxSpeed;
					
				}
				walk=1;
				t_run++;
			} else {
				t_run=0;
			}
			//Рывок в сторону
			if (ctr.keyStates.keyDubRight&&!zaput || ctr.keyStates.keyDubLeft&&zaput || ctr.keyStates.keyDash&&(storona==1)) {
				if (stay && !isSit && (ctr.keyStates.keyRun || ctr.keyStates.keyDash) && dash_t<=0 && stam>200 && pers.speedShtr<=0 && rat==0) {
					if (dx<dash) dx=dash;
					aJump=2;
					dy+=dash_dy;
					dash_t=dash_maxt;
					jumpNumb=2;
					dJump=false;
					//if (!room.levitOn) {
						stay=false;
						jumpp=0;
						ctr.keyStates.keyJump=false;
					//}
					if (inBattle) stam-=pers.stamRun*pers.stamDash*dstam;
				}
				ctr.keyStates.keyDubRight=ctr.keyStates.keyDubLeft=ctr.keyStates.keyDash=false;
			}
			if (ctr.keyStates.keyDubLeft&&!zaput || ctr.keyStates.keyDubRight&&zaput || ctr.keyStates.keyDash&&(storona==-1)) {
				if (stay && !isSit && (ctr.keyStates.keyRun || ctr.keyStates.keyDash) && dash_t<=0 && stam>200 && pers.speedShtr<=0 && rat==0) {
					if (dx>-dash) dx=-dash;
					aJump=2;
					dy+=dash_dy;
					dash_t=dash_maxt;
					jumpNumb=2;
					dJump=false;
					//if (!room.levitOn) {
						stay=false;
						jumpp=0;
						ctr.keyStates.keyJump=false;
					//}
					if (inBattle) stam-=pers.stamRun*pers.stamDash*dstam;
				}
				ctr.keyStates.keyDubLeft=ctr.keyStates.keyDubRight=ctr.keyStates.keyDash=false;
			}
			
			//прыг
			if (levit==1) levit=0;
			//throu=(ctr.keyStates.keyJump || isLaz)&&ctr.keyStates.keySit || isPlav;
			throu=(ctr.keyStates.keyJump || !stay)&&ctr.keyStates.keySit || isPlav || kdash_t>3 || pinok>70;
			if (stay && !ctr.keyStates.keyJump || isLaz) {
				jumpp=maxjumpp;//пока стоим, прыжок заряжен полностью
				dJump=false;
				if (isLaz && !keyLeft && !keyRight) jumpp=0;
				jumpNumb=0;
				if (dash_t<=0) aJump=0;
			} else if (!stay && !ctr.keyStates.keyJump && pers.isDJ && jumpNumb<=1 && room.levitOn) {
				jumpp=maxdjumpp;
				dJump=true;
			} else if (!ctr.keyStates.keyJump && jumpNumb==0) jumpNumb=1;
			if (throu && stayPhis==2) jumpp=0;
			if (!stay && ctr.keyStates.keyJump) jumpp--;
			if (!stay && !ctr.keyStates.keyJump && !(pers.isDJ && room.levitOn && jumpNumb<=1)) jumpp=0;
			if (isPlav && (jumpp<=2 || jumpNumb>1)) {
				jumpp=5;
				jumpNumb=1;
				dJump=false;
			}
			dJump2=false;
			if (ctr.keyStates.keyJump && dash_t<dash_maxt-15) {
				isTake=40;
				t_stay=0;
				if (!isJump) {
					if (inBattle && stam>-100) stam-=pers.stamRun*pers.stamJump*dstam;
					isJump=true;
					jumpNumb++;
				}
				if (stay && Settings.hardInv) invent.damageItems(0,false);
				if (isPlav) {
					dy-=plavdy*pers.speedPlavMult;
				} else if (jumpp>0) { //&& !isSit
					if (isSit) unsit();
					if (!isSit) {
						spellDisact();
						if (dJump && pers.ableFly && room.levitOn) {
							isFly=!isFly;
							if (room.sky) isFly=true;
							t_fly=0;
							ctr.keyStates.keyJump=false;
						} else if (dJump) {		//двойной прыжок
							dy=-djumpdy*pers.jumpMult;
							if (jumpp==maxdjumpp-1) {
								Emitter.emit('quake',room,X,Y);
								if (keyLeft) dx-=djumpdy*0.5;
								if (keyRight) dx+=djumpdy*0.5;
								if (dx>25) dx=25;
								if (dx<-25) dx=-25;
								jumpNumb=3;
							}
							dJump2=true;
							if (jumpp==1 && levitOn && room.levitOn && !isPlav) jumpNumb=3;
						} else {
							dy=-jumpdy*pers.jumpMult; //прыжок
						}
						aJump=1;
					}
				} else if (pers.ableFly && room.levitOn && rat==0) {
					if (isLaz) isLaz=0;
					isFly=!isFly;
					t_fly=0;
					ctr.keyStates.keyJump=false;
				} else if (levitOn && room.levitOn && jumpNumb>(pers.isDJ?2:1) && !isPlav) {	//самолевитация, при втором нажатии
					if (levit>1) levit--;
					else {
						levit=1;
						fracLevit=fraction;
					}
					isFly=false;
				}
				if (isLaz || stay) {	//прыжок с лестницы
					 if (!keyLeft && keyRight && dx<maxSpeed-accel1) dx+=accel1;
					 if (keyLeft && !keyRight && dx>-maxSpeed+accel1) dx-=accel1;
				}
				if (levit==1 && mana<=0) {
					levit=0;
					jumpNumb=2;
				}
			} else {
				isJump=false;
			}
			if (isPlav && ctr.keyStates.keyBeUp && !ctr.keyStates.keyJump) {
				dy-=plavdy*pers.speedPlavMult;
			}
			//самолевитация
			if (levit==1) {
				if (ctr.keyStates.keyBeUp) {
					dy-=levidy*0.7;
					levitup=true;
					t_up=10;
				} else levitup=false;
				if (ctr.keyStates.keySit) dy+=levidy;
			}
			if (isFly) {
				if (ctr.keyStates.keyBeUp) dy-=levidy;
				if (ctr.keyStates.keySit) dy+=levidy;
			}
			//плавание
			//присесть
			if (ctr.keyStates.keySit) {// !isSit &&!levit &&!isLaz &&!isPlav) {
				porog=0;
				if (stay && diagon==0 && runForever<=0 && !inWater && isFetter<=0 && !noStairs && rat==0) {
					if (checkStairs(2)) {	//проверить лестницу
						t_stay=0;
						dy=lazSpeed;
						throu=true;
					} else 	if (stayPhis==2 && checkStairs(2,-20*storona)) {	//проверить лестницу
							t_stay=0;
							dy=lazSpeed;
							throu=true;
					} else if (stayPhis==2 && checkStairs(2,20*storona)) {	//проверить лестницу
							t_stay=0;
							dy=lazSpeed;
							throu=true;
					} else if (stayPhis==1 && downp==1 || stayPhis==2 && downp==5){
						sit(true);
					}
				} else if (isLaz && !noStairs) {
					if (checkStairs(2)) {
						dy=lazSpeed*1.5;
					}
				} else if (isPlav) {
					dy+=plavdy*pers.speedPlavMult/2;
				}
				if (downp<6) downp++;
			} else {
				downp=0;
			}
			//встать
			if (isSit && ctr.keyStates.keyBeUp && !ctr.keyStates.keySit && rat==0) {
				t_up=10;
				unsit();
			}
			if (isSit && !stay && rat==0) {
				unsit();
			}
			//поднять оружие или спрятаться
			weapUp=false;
			if (stay && ctr.keyStates.keyBeUp && rat==0) {
				if (isSit) t_up=10;
				t_up++;
				if (t_up>10) weapUp=true;
			} else {
				if (t_up>0 && t_up<=7 && !keyLeft && !keyRight && rat==0) {
					lurk();	//спрятаться
				}
				if (!ctr.keyStates.keyBeUp) t_up=0;
			}
			//быстро спрыгнуть с балки
			if (ctr.keyStates.keyDubSit) {
				if (stay && stayPhis==2) {
					t_stay=0;
					throu=true;
					dy+=10;
				}
				ctr.keyStates.keyDubSit=false;
			}
			if (room.quake>5) throu=true;
			//лезть
			if (!isSit && !isFly && ctr.keyStates.keyBeUp && runForever<=0 && room.quake<=5 && !cryst && isFetter<=0 && !noStairs && pinok<30 && rat==0) {
				if (checkStairs()) {
					t_stay=0;
					dy=-lazSpeed;
					t_up=10;
				}
			}
			//перестать лезть
			if (runForever>0 || ctr.keyStates.keyJump && !ctr.keyStates.keyBeUp || room.quake>5) {
				isLaz=0;
			}
			isUp=ctr.keyStates.keyBeUp;
			if (rat==1) {
				isSit=false;
				scX=ratX;
				scY=ratY;
			}
		}
		
		
		//определить, видна ли ловушка
		public function lookInvis(ncel:Unit, visParam:Number=-1):Boolean {
			if (visParam==-1) visParam=pers.visiTrap;
			if (room!=ncel.room) return false;
			return look(ncel,false,visParam)>0;
		}
		
		
		//смотреть на целевую точку
		public function lineCel(rdx:int=0, rdy:int=0):int 
		{
			var res=0;
			var ndx=(celX+rdx-X);
			var ndy=(celY+rdy-Y+scY/2);
			var div=Math.floor(Math.max(Math.abs(ndx),Math.abs(ndy))/Settings.maxdelta)+1;
			for (var i=1; i<div; i++) {
				var nx=X+ndx*i/div;
				var ny=Y-scY/2+ndy*i/div;
				var t:Tile=World.world.room.getAbsTile(Math.floor(nx),Math.floor(ny));
				if (t.phis==1 && nx>=t.phX1 && nx<=t.phX2 && ny>=t.phY1 && ny<=t.phY2) {
					celX=nx;
					celY=ny;
					return 0
				}
			}
			return 1;
		}
		
		public function lurk():void
		{
			lurkTip=0;
			if (stay && !isSit && dx<5 && dx>-5 && stayPhis>=1 && work=='')	{
				lurkBox=null;
				for each (var b:Box in room.objs) {
					if (b.lurk>lurkTip && X>b.X1 && X<b.X2 && Y-10>b.Y1 && Y-10<b.Y2) {
						lurkTip=b.lurk;
						lurkBox=b;
					}
				}
				if (lurkBox) {
					lurkX=X;
					dx=0;
					t_work=20;
					work='lurk';
					lurked=true;
					if (lurkBox.lurk==2) {
						if (X>lurkBox.X) {
							storona=1;
							lurkX=lurkBox.X2-10;
						} else {
							storona=-1;
							lurkX=lurkBox.X1+10;
						}
					} else {
						lurkX=lurkBox.X;
					}
				} else if (room.getAbsTile(X-20,Y-10).lurk && room.getAbsTile(X+20,Y-10).lurk) {
					lurkTip=1;
					lurkX=Math.round(X/Tile.tilePixelWidth)*Tile.tilePixelWidth;
					dx=0;
					t_work=20;
					work='lurk';
					lurked=true;
				} else {
					//включить особые свойства брони
					armorAbil();
				}
			}
		}
		
		public function unlurk():void
		{
			if (lurked && stay) 
			{
				t_work = 10;
				work = 'unlurk';
			}
			lurked = false;
		}
		
		
		
//**************************************************************************************************************************
//
//				Эффекты и скиллы
//
//**************************************************************************************************************************
		// Установить зависимости
		public function setAddictions():void
		{
			for (var ad in pers.addictions) 
			{
				if (pers.addictions[ad]>=pers.ad1) 
				{
					var eff:Effect = addEffect(ad);
					if (pers.addictions[ad]>=pers.ad2) eff.lvl = 2;
					if (pers.addictions[ad]>=pers.ad3) eff.lvl = 3;
					eff.forever = true;
				}
			}
			if (World.world.game.triggers['curse']>0) addEffect('curse');
		}

		public function endAllEffect():void
		{
			if (effects.length > 0) 
			{
				for each (var eff in effects) eff.unsetEff();
				effects = new Array();
			}
		}
		
		public function clearAddictions():void
		{
			for (var ad in pers.addictions) 
			{
				pers.addictions[ad] = 0;
			}
		}

//**************************************************************************************************************************
//
//				Урон и лечение
//
//**************************************************************************************************************************

		//взгляд другого юнита, увеличивающий собственное значение видимости героя obs
		//оно увеличивается в зависимости от соотношения скрытности героя и наблюдательности врага
		//nlook - базовое значение, на которое увеличивается obs, зависит от расстояния до врага и параметров видимости
		//nobs - наблюдательность врага. если она не передаётся, то рассчёт соотношения скрытности героя и наблюдательности врага не производится
		public function observation(nlook:Number, nobs:Number = -1000):Boolean 
		{
			var nsneak = sneak - demask / 20;
			if (nsneak < 0) nsneak = 0;
			if (nobs > -1000) 
			{
				if (nobs > nsneak) 
				{
					nlook *= (1 + (nobs - nsneak) * 0.2);
				} 
				else if (nobs < nsneak) 
				{
					nlook /= (1 - (nobs - nsneak) * 0.3);
				}
			}
			nlook *= pers.visiMult * stealthMult;
			if (lurked) nlook -= pers.sneakLurk;
			if (isSit) nlook -= pers.sneakLurk / 5;
			if (nlook < 0) nlook = 0;
			obs += nlook;
			if (nlook > 0) isObs = 30;
			if (obs > maxObs * 2) obs = maxObs * 2;
			return obs >= maxObs;
		}

		public override function heal(hl:Number, tip:int=0, ismess:Boolean=true):void
		{
			if (hl==0) return;
			if (tip==0) {				//мгновенное лечение
				if (hl>maxhp-rad-hp) {
					hl=maxhp-rad-hp;
					hp=maxhp-rad;
				} else {
					hp+=hl;
				}
			} else if (tip==1) {	//лечение зельями
				healhp+=hl;
			} else if (tip==2) {	//лечение радиации
				rad-=hl;
				if (rad<0) rad=0;
			} else if (tip==3) {	//порезов
				cut-=hl;
				if (cut<0) cut=0;
			} else if (tip==4) {	//яда
				if (hl>0) {
					poison-=hl;
					if (poison<0) poison=0;
				} else {
					poison-=hl;
				}
			}
			if (ismess && (sost==1 || sost==2) && showNumbs && hl>0.5) numbEmit.cast(room,X,Y-scY/2,{txt:((tip==2)?'-':'+')+Math.round(hl), frame:((tip==2)?7:4), rx:20, ry:20});
			World.world.gui.setHp();
		}
		
		public override function udarUnit(un:Unit, mult:Number=1):Boolean
		{
			if (super.udarUnit(un, mult)) {
				if (un.radDamage) drad2=un.radDamage;
				return true;
			}
			return false;
		}
		
		//урон от радиации и прочий урон на расстоянии
		public function raddamage(koef:Number, dam:Number, tip:int=0):void
		{
			if (t_nogas>0) return;
			if (tip==0) {
				World.world.gg.drad+=dam*koef;
			} else if (this['ddam'+tip]!=null) {
				if (koef<0.25) koef=koef*4;
				else koef=1;
				this['ddam'+tip]+=dam*koef;
			}
		}
		
		public override function damage(dam:Number, tip:int, bul:Bullet=null, tt:Boolean=false):Number
		{
			if (bul && bul.weap && bul.weap.dopEffect=='psy') {
				if (isrnd(0.33)) addEffect('horror');
				else if (isrnd()) addEffect('vote');
				else  addEffect('disorient');
			}
			var dhp=hp;
			if (room.train || room.base) return 0;
			if (tip==Unit.D_EMP && dam>30 && pers.pipEmpVulner>0) {
				pipOff+=Math.round(dam*pers.pipEmpVulner);
				if (sats.que.length > 0) sats.clearAll();
				World.world.gui.allOff();
			}
			if (cryst && tip!=Unit.D_BLEED && tip!=Unit.D_POISON && tip!=Unit.D_INSIDE) {
				dam*=5/spellPower;
				mana-=dam;
				if (mana<=0) {
					cryst=false;
					spellDisact();
				}
				pers.manaDamage(dam*0.1);
				dmana=0;
				return 0;
			}
			if (currentArmor && !Settings.godMode) currentArmor.damage(dam*pers.armorVulner, tip);
			if (tip!=Unit.D_BLEED && tip!=Unit.D_POISON && tip!=Unit.D_INSIDE && tip!=Unit.D_PINK) {
				pinok+=dam/maxhp*200*knocked;
				//повреждение инвентаря
				if (!tt && Settings.hardInv && !Settings.alicorn) invent.damageItems(dam);
			}
			if (pinok>100) pinok=100;
			if (pinok>60 && levit==1) {
				levit=0;
				ctr.keyStates.keyJump=false;
			}
			if (pinok>60 && teleObj) dropTeleObj();
			if (pinok>30) isLaz=0;
			var pdam:Number=super.damage(dam, tip, bul, tt);
			if (dhp/maxhp>=0.2 && hp/maxhp<0.2) World.world.gui.critHP();
			if (pdam/maxhp>0.1 && isrnd(pdam/maxhp)) {
				replic('dam');
			}
			if (Settings.godMode) {
				hp=dhp;
			} else if (!Settings.alicorn) {
				pers.damage(pdam, tip);
				pers.bloodDamage(pdam, tip);
			}
			return pdam;
		}
		
		public function electroDamage(dam:Number=-1, nx=null, ny=null):void
		{
			if (dam<0) dam=room.electroDam;
			if (pinok>0) dam*=2;
			if (pers.potShad==0) {
				damage(dam,D_SPARK,null,true);
			} else {
				damage(dam,D_INSIDE,null,true);
				pinok=90;
			}
			Snd.ps('electro',X,Y);
			if (nx!=null && ny!=null) Emitter.emit('moln',room,X,Y-scY/2,{celx:nx, cely:ny});
		}
		
		public override function udarBox(un:Box):int
		{
			var res:int=super.udarBox(un);
			if (res==2 && room.electroDam && un.mat==1) electroDamage(room.electroDam, un.X, un.Y-un.scY/2);
			return res;
		}
		

		public override function die(sposob:int=0):void
		{
			//реанимация
			if (sost>1 || Settings.godMode && sposob>=0) return;
			if (sposob>=0) {
				if (pers.lastCh>0) {
					hp=1;
					heal(pers.lastCh*0.1,0,false);
					heal(pers.lastCh*0.9,1,false);
					remEffect('potion_chance');
					addEffect('post_chance');
					return;
				}
				if (pers.reanimHp>0 && !noReanim) {
					hp=0;
					heal(pers.reanimHp);
					addEffect('reanim');
					return;
				}
				if (sposob<10 && sost==1) pers.damage(0,0,true);
			}
			controlOff();
			World.world.gui.unshowSelector();
			if (sost<3) sost=2;
			if (sposob>=10) sost=3;
			isLaz=0;
			levit=0;
			isFly=false;
			t_port=0;
			healhp=shithp=0;
			if (work=='change') {
				changeWeaponNow(1);
				changeWeaponNow(2);
			}
			walk=0;
			t_work=205;
			work='die';
			if (pers.hardcoreMode && sposob>=0) {
				pers.dead=true;
				World.world.saveGame(-2);
				if (sposob==10) World.world.gui.messText('hardDie2', pers.persName, false, false, 10000);
				else World.world.gui.messText('hardDie', pers.persName, false, false, 10000);
				Snd.playMusic('harddie',1);
			} else {
				World.world.t_die=300;
			}
		}
		
		//восстановиться после смерти
		public function resurect():void
		{
			lurked=false;
			sost=1;
			sit(false);
			if (rad>maxhp-40) rad=maxhp-40;
			if (rad<0) rad=0;
			if (hp<=0) {
				hp=0;
				heal(Math.min(100,maxhp/2));
				cut=poison=0;
				pers.addPerk('dead');
			}
			if (pers.manaHP<50) pers.heal(Math.min(50,50-pers.manaHP),6);
			t_work=100;
			t_nogas=250;
			animOff=false;
			work='res';
			mana=h2o=stam=1000;
			drad2=0;
			possRun=true;
			if (pipOff>0) {
				World.world.gui.allOn();
				pipOff=0;
			}
			endAllEffect();
			setAddictions();
			pers.setParameters();
			if (pet && pet.sost==4) {
				noPet=0;
				if (pet.optAutores) pet.resurrect();
			}
			if (armorEffect) {
				armorEffect.unsetEff(true,false,true);
			}
			if (currentArmor) currentArmor.abilActive=false;
			vis.visible=true;
		}
		
//**************************************************************************************************************************
//
//				Оружие и броня
//
//**************************************************************************************************************************
		public override function setWeaponPos(tip:int=0):void
		{
			if (weaponKrep==0) {			//телекинез
				if (storona>0 && celX>X2 || storona<0 && celX<X1) weaponX=X+scX*1*storona;
				else weaponX=X;
				if (isLaz) weaponX=X;
				if (room.getAbsTile(weaponX,weaponY).phis==1 || room.getAbsTile(weaponX+storona*15,weaponY).phis==1) weaponX=X;
				if (tip==1) weaponY=Y-scY*0.4;
				else weaponY=Y-scY*0.7;
				if (stay && weapUp) {
					if (room.getTile(Math.floor(weaponX/Tile.tilePixelWidth),Math.floor((weaponY-40)/Tile.tilePixelHeight)).phis!=1) weaponY-=40;
				}
			} else super.setWeaponPos(tip);
			
			if (work=='change' && t_work>changeWeaponTime3 && tip!=5) {
					weaponX=X;
					weaponY=Y-scY*0.5;
			}
			try {
				var p:Point=new Point(vis.osn.body.head.morda.konec.x,vis.osn.body.head.morda.konec.y);
				p=vis.osn.body.head.morda.localToGlobal(p);
				p=vis.parent.globalToLocal(p);
				magicX=p.x;
				magicY=p.y;
				if (room.getAbsTile(magicX,magicY).phis==1) 
				{
					if (isSit) magicY=Y-35;
					else magicY=Y-75;
				}
			} catch (err) 
			{
				magicX=X;
				magicY=Y-scY/2;
			}
		}
		
		//TODO: Fix this, why is it returning a false?
		//Смена оружия по цифровой клавише или идентификатору
		public function changeWeapon(nid:String, moment:Boolean=false)
		{
			var nw;
			if (sats && sats.que.length > 0) sats.clearAll();
			if (nid == 'not') {
				nw = null;
			} 
			else if (nid == null || nid == '' || attackForever > 0 || atkPoss == 0) 
			{
				return false;
			} 
			else 
			{
				if (currentWeapon && nid==currentWeapon.id) 
				{
					nw=null;	
				} 
				else 
				{
					nw=invent.weapons[nid];
				}
			}
			if (nw is Weapon) 
			{
				if (nw.respect==1 || nw.alicorn && !Settings.alicorn) 
				{
					if (nw.tip==5) World.world.gui.infoText('disSpell',null,null,false);
					else World.world.gui.infoText('disWeapon',null,null,false);
					return;
				}
				if (nw.spell) 
				{
					if (nw.respect==0) nw.respect=2;
					invent.useItem(nid);
					return;
				}
				if (Settings.weaponsLevelsOff && nw.lvl>pers.getWeapLevel(nw.skill)) 
				{
					if (nw.lvlNoUse || nw.lvl-pers.getWeapLevel(nw.skill)>2) 
					{
						World.world.gui.infoText('weaponSkillLevel',null,null,false);
					}
				}
			}
			if (moment) 
			{
				newWeapon=nw;
				changeWeaponNow(1);
				changeWeaponNow(2);
			} 
			else 
			{
				work='change';
				t_work=changeWeaponTime1;
				newWeapon=nw;
			}
		}
		
		public function changePaintWeapon(npaint:String, ncolor:uint, nblend:String=null):void
		{
			(paintWeapon as WPaint).setPaint(npaint, ncolor, nblend);
			if (sats && sats.que.length > 0) sats.clearAll();
			newWeapon=paintWeapon;
			work='change';
			t_work=changeWeaponTime1;
		}
		
		//непосредственно замена оружия
		private function changeWeaponNow(st:int):void
		{
			//trace(st,currentWeapon,newWeapon);
			vision=1;
			if (st==1) {
				if (currentWeapon) {
					if (currentWeapon.tip!=5 || newWeapon && newWeapon.tip==5) currentWeapon.remVisual();
				}				
				currentWeapon=null;
				childObjs[0]=null;
			}
			if (st==2 && currentWeapon==null) {
				currentWeapon=newWeapon;
				childObjs[0]=currentWeapon;
				if (currentWeapon) {
					if (currentWeapon.respect==0) currentWeapon.respect=2;
					if (currentWeapon.tip==4 && invent.fav[29]==null) throwWeapon=currentWeapon;
					if (currentWeapon.tip==5 && invent.fav[30]==null) magicWeapon=currentWeapon;
					currentWeapon.addVisual();
					currentWeapon.setNull();
					currentWeapon.setPers(this,pers);
					weaponLevit();
				}
			}
			if (currentWeapon) vision=currentWeapon.visionMult;
			World.world.gui.setWeapon();
		}
		
		//вернуть нужное количество боеприпасов из инвентаря, или сколько есть
		//вернуть -1, если не хватает даже на 1 заряд
		public function getInvAmmo(ammoId:String, need:int=1, needmin:int=1, minus:Boolean=false):int 
		{
			if (invent==null) return -1;
			if (invent.items[ammoId].kol<needmin) return -1;
			var res:int=0;
			if (invent.items[ammoId].kol<need) {
				res=invent.items[ammoId].kol;
				if (minus) invent.items[ammoId].kol=0;
			} else {
				res=need;
				if (minus) invent.items[ammoId].kol-=need;
			}
			return res;
		}
		
		public function changeArmor (nid:String='', forced:Boolean=false):Boolean 
		{
			if (Settings.alicorn && nid!='' && !forced) {
				World.world.gui.infoText('alicornNot',null,null,false);
				return false;
			}
			if (World.world.t_battle>0 && nid!='off') {
				World.world.gui.infoText('noChArmor',null,null,false);
				return false;
			}
			var tipArmor=1;
			var clo=0;
			if (invent.armors[nid]) {
				tipArmor=invent.armors[nid].tip;
				clo=invent.armors[nid].clo;
			}
			if (Settings.hardInv && !forced && nid!='off' && !(room && room.base) && tipArmor==1) {
				if (clo==0 && nid!=prevArmor) {
					World.world.gui.infoText('noChArmor2',null,null,false);
					return false;
				}
			}
			if (nid=='off') {
				World.world.gui.infoText('brokenArmor');
				nid='';
			}
			if (tipArmor==1) {		//броня
				if (currentArmor) {
					currentArmor.active=false;
					if (armorEffect) armorEffect.unsetEff(true, false, true);
					armorEffect=null;
					currentArmor.abilActive=false;
				}
				if (nid=='' ||  currentArmor && currentArmor.id==invent.armors[nid].id) currentArmor=null;
				else if (invent.armors[nid]) {
					if (invent.armors[nid].hp>0) currentArmor=invent.armors[nid];
					else World.world.gui.infoText('brokenArmor');
				}
				if (currentArmor) {
					Appear.ggArmorId=currentArmor.id;
					Appear.hideMane=currentArmor.hideMane;
					currentArmor.owner=this;
					currentArmor.active=true;
					currentArmor.abilActive=false;
					currentArmor.mana=0;
					if (currentArmor.clo==0) prevArmor=currentArmor.id;
				} else {
					Appear.ggArmorId='';
					Appear.hideMane=0;
				}
				refreshVis();
				isFly=false;
			} else if (tipArmor==3) {	//амулет
				if (currentAmul) {
					currentAmul.active=false;
				}
				if (currentAmul && currentAmul.id==invent.armors[nid].id) currentAmul=null;
				else currentAmul=invent.armors[nid];
				if (currentAmul) {
					currentAmul.owner=this;
					currentAmul.active=true;
				}
			}
			pers.setParameters();
			return true;
		}
		
		public function changeSpell (nid:String='', inf:Boolean=true):void
		{
			//if (invent.spells[nid]==null) invent.addSpell(nid);
			if (currentSpell==invent.spells[nid]) currentSpell=null;
			else currentSpell=invent.spells[nid];
			if (inf && currentSpell) World.world.gui.infoText('usedSpell',currentSpell.objectName);
		}
		
		public override function setPunchWeaponPos(w:WPunch):void
		{
			w.X=X+scX/3*((celX>X)?1:-1);
			w.Y=Y-scY/2;
			w.rot=(celX>X)?0:Math.PI;
		}
		
		//особая функция брони
		public function armorAbil():void
		{
			if (currentArmor == null || currentArmor.abil == null) return;

			if (!currentArmor.abilActive) 
			{
				if (currentArmor.dmana_act < currentArmor.mana) 
				{
					currentArmor.mana -= currentArmor.dmana_act;
					armorEffect = addEffect(currentArmor.abil);
					currentArmor.abilActive = true;
				}
			} 
			else 
			{
				if (armorEffect) armorEffect.unsetEff(true, false, true);
				armorEffect = null;
				currentArmor.abilActive = false;
			}
		}
		
		//призыв и отзыв спутника, f=true - принудительно
		public function callPet(npet:String, f:Boolean = false):void
		{
			if (noPet > 0 && !f) 
			{
				World.world.gui.infoText('petNot', null, null, false);
				return;
			}

			if (noPet2 > 0 && !f || !atkPoss || Settings.alicorn) 
			{
				World.world.gui.infoText('petNot2', null, null, false);
				return;
			}

			if (npet == 'owl' && currentPet == 'owl' && pets[npet] && pets[npet].hp <= 0 && !f) 
			{
				World.world.gui.infoText('petNot3',null,null,false);
				return;
			}

			noPet2 = 150;

			if (pet) 
			{
				World.world.gui.infoText('petRecall', pet.objectName);
				pet.recall();
				pet = null;
				childObjs[2] = null;
			}

			retPet = '';

			if (currentPet == npet) 
			{
				currentPet = '';
			} 
			else 
			{
				if (!room.petOn) 
				{
					World.world.gui.infoText('noPetCall', null, null, false);
				} 
				else 
				{
					currentPet = npet;
					pet = pets[currentPet];
					childObjs[2] = pet;
					pet.X = X; 
					pet.Y = Y - 20;
					pet.room = room;
					pet.call();
					World.world.gui.infoText('petCall', pet.objectName);
				}
			}
			World.world.gui.setPet();
		}
		
		public function uncallPet(ret:Boolean=false):void
		{
			if (pet) {
				if (ret && currentPet!='moon') retPet=currentPet;
				World.world.gui.infoText('petRecall',pet.objectName);
				pet.recall();
				pet=null;
				childObjs[2]=null;
				currentPet='';
			}
			World.world.gui.setPet();
		}
		
		public function alicornOn(eff:Boolean=true):void
		{
			Settings.alicorn=true;
			if (armorEffect) {
				armorEffect.unsetEff(true,false,true);
			}
			changeArmor('',true);
			invent.addWeapon('a_melee');
			invent.addWeapon('a_fire');
			invent.addWeapon('a_energ');
			invent.addWeapon('a_expl');
			invent.addWeapon('a_magic');
			//changeWeapon('');
			uncallPet();
			clearAddictions();
			endAllEffect();
			pers.healAll();
			rad=cut=poison=0;
			pers.setParameters();
			if (eff) {
				newPart('redray',40);
				Snd.ps('al_armor',X,Y);
			}
			refreshVis();
		}
		
		public function alicornOff():void
		{
			Settings.alicorn=false;
			isFly=false;
			changeWeapon('not',true);
			pers.setParameters();
			refreshVis();
		}
		
		public function ratOn():void
		{
			unlurk();
			uncallPet(true);
			changeWeapon('not');
			isSit=false;
			isLaz=levit=0;
			isFly=false;
			dropTeleObj();
			actionObj=null;
			scX=ratX;
			scY=ratY;
			X1=X-scX/2, X2=X+scX/2,	Y1=Y-scY;
			vis.osn.visible=false;
			vis.rat.visible=true;
			newPart('black',30);
			rat=1;
		}
		public function ratOff():Boolean
		{
			scX=stayX, scY=stayY;
			X1=X-scX/2, X2=X+scX/2,	Y1=Y-scY;
			if (collisionAll()) {
				if (collisionAll(15)) {
					if (collisionAll(-15)) {
						scX=ratX;
						scY=ratY;
						X1=X-scX/2, X2=X+scX/2,	Y1=Y-scY;
						return false;
					} else {
						X-=15;
						X1=X-scX/2, X2=X+scX/2;
					}
				} else {
					X+=15;
					X1=X-scX/2, X2=X+scX/2;
				}
			}
			vis.osn.visible=true;
			vis.rat.visible=false;
			newPart('black',30);
			rat=0;
			return true;
		}
		
		
//**************************************************************************************************************************
//
//				Визаульная часть
//
//**************************************************************************************************************************
		
		public function anim(dey:String=null, ok:Boolean=false):void
		{
			if (dey==null || dey=='') {
				animOff=false;
				return;
			}
			vis.osn.gotoAndStop(dey);
			var f=vis.osn.body.totalFrames;
			if (ok) {
				animOff=true;
				vis.osn.body.gotoAndStop(f);
			} else {
				animOff=false;
				work=dey;
				t_work=f;
			}
			otherVisual();
		}
		
		function chLayer(n:int):void
		{
			if (layer==n) return;
			remVisual();
			layer=n;
			addVisual();
		}
		
		public function setFilters():void
		{
			var arr:Array;
			if (f_levit) {
				if (levit>=1 && fracLevit!=fraction && levitFilter2) arr=[levitFilter2];
				else if (levit==1 && fracLevit==fraction || dJump && levit<2) arr=[levitFilter1];
				else arr=[];
			}
			else arr=[];
			if (f_die) arr.push(dieFilter);
			if (f_shad) arr.push(shadowFilter);
			if (f_dash) arr.push(dashFilter); //trace('dash')
			if (f_stealth) arr.push(stealthFilter);
			if (f_stealth) vis.alpha=0.5; else vis.alpha=1;
			if (f_inv) arr.push(invulnerFilter1,invulnerFilter2);
			vis.osn.filters=arr;
		}
		
		public override function animate():void
		{
			if (animOff) return;
			vis.osn.y=0;
			vis.osn.rotation=0;
			if (t_work && work=='die') {
				reloadbar.visible=false;
				if (!Settings.alicorn) {
					if (animState!='die') {
						vis.osn.gotoAndStop('die');
						animState='die';
					}
					if (t_work<170 && t_work>120) {
						dieFilter.alpha=1-(t_work-120)/50;
						f_die=true;
						dieTransform.redOffset=(170-t_work)*2;
						dieTransform.blueOffset=(170-t_work)*3;
						vis.osn.transform.colorTransform=dieTransform;
						Emitter.emit('die_spark',room,X+Math.random()*120-60+20*storona,Y);
					} else if (t_work<120 && t_work>70) {
						vis.osn.alpha=(t_work-70)/50;
					}
				} else {
					if (animState!='die') {
						vis.osn.gotoAndStop('dieali');
						animState='die';
					}
					if (t_work<200 && t_work>140) {
						f_die=true;
						dieTransform.redOffset=(200-t_work)*4;
						dieTransform.blueOffset=(200-t_work);
						vis.osn.transform.colorTransform=dieTransform;
						newPart('redray');
					}
					if (t_work==140) {
						newPart('bloodblast');
						Snd.ps('bale_e');
						vis.osn.alpha=0;
					}
				}
				setFilters();
				otherVisual();
				return;
			}
			if (t_work && work=='lurk') {
				if (animState!='lurk') {
					vis.osn.gotoAndStop('lurk'+lurkTip);
					vis.osn.body.gotoAndPlay(1);
					animState='lurk';
				}
				setFilters();
				otherVisual();
				return;
			}
			if (t_work && work=='unlurk') {
				if (animState!='unlurk') {
					try {
						vis.osn.body.gotoAndPlay('un');
						animState='unlurk';
					} catch (err) {
					}
				}
				setFilters();
				otherVisual();
				return;
			}
			if (t_work && work=='res') {
				if (animState!='res') {
					vis.osn.gotoAndStop('res');
					animState='res';
				}
				otherVisual();
				return;
			}
			if (lurked) {
				vis.osn.body.head.morda.eye.gotoAndStop(1);
				otherVisual();
				return;
			}
			
			if (klip>0) klip--;
			else klip=Math.random()*200+50;
			
			if (stay) t_stay=5;
			else if (t_stay>0) t_stay--;
			

			var cframe:int;
			if (t_work && work=='punch') freeAnim=0;
			if (t_work && work=='punch' && animState!='punch') {
				//if (storona>0 && celX>X || storona<0 && celX<X) vis.osn.gotoAndStop('punch');
				if (!ctr.keyStates.keyRun) vis.osn.gotoAndStop('punch');
				else vis.osn.gotoAndStop('kick');
				animState='punch';
			}
			if (t_work==0 && animState=='punch') {
				animState='';
			}
			if (stay || t_stay>0) 
			{
				//Какие-то действия
				if  (diagon==0 && (dx<=1 && dx>=-1 && walk!=0 || dx<=4 && dx>=-4 && walk==0 || shX1>0.5 && isSit || shX2>0.5 && isSit)) 
				{
					t_walk=0;
					if (freeAnim==0 || isSit) 
					{
						freeAnim=0;
						if (vis.osn.currentFrameLabel!='stay') {
							if (vis.osn.currentFrameLabel=='jump' || vis.osn.currentFrameLabel=='levit') {
								vis.osn.gotoAndStop('stay');
								vis.osn.body.gotoAndPlay('jump');
							} else {
								vis.osn.gotoAndStop('stay');
							}
						}
						cframe=getStayFrame();
						//если сидим
						if (isSit) {
							if (animState=='jump') {
								if (animState!='downjump') {
									animState='downjump';
									vis.osn.body.gotoAndPlay('downjump');
								}
							}
							if (animState!='down' && animState!='downjump') {// && 
								if (animState=='polz' || cframe!=2) {
									vis.osn.body.gotoAndStop(cframe);
								} else if (animState!='roll') {
									vis.osn.body.gotoAndPlay('down');
								} else vis.osn.body.gotoAndStop('sit');
									animState='down';
							}
							//если стоим
						} else {
							if (animState=='down') {
								vis.osn.body.gotoAndPlay('up');
								animState='up';
							}
							if (animState!='up' || cframe!=1) {
								if (vis.osn.body.currentFrame<70) vis.osn.body.gotoAndStop(cframe);
								animState='';
							}
						}
						if (vis.osn.body.currentFrame!=cframe && !(vis.osn.body.currentFrame>=3 && vis.osn.body.currentFrame<=26 || vis.osn.body.currentFrame>70)) vis.osn.body.gotoAndStop(cframe);
						if (vis.osn.currentFrameLabel=='stay' && cframe==1) {
							if (isrnd(0.01)) {
								freeAnim=Math.floor(Math.random()*3)+1;
								vis.osn.gotoAndStop('free'+freeAnim);
								vis.osn.body.play();
							}
						}
						//trace(vis.body.currentFrame+' '+cframe);
					} 
					else 
					{
						if (vis.osn.body.currentFrame>=49) freeAnim=0;
					}
				} 
				else if (diagon!=0 && dx==0) 
				{
					freeAnim=0;
					t_walk=0;
					if (diagon*storona>0) 
					{
						if (animState!='diag_up') 
						{
							animState='diag_up';
							vis.osn.gotoAndStop('trot_up');
							vis.osn.body.gotoAndStop(1);
						}
					} 
					else 
					{
						if (animState!='diag_down') 
						{
							animState='diag_down';
							vis.osn.gotoAndStop('trot_down');
							vis.osn.body.gotoAndStop(1);
						}
					}
				} 
				else 
				{			//движение
					freeAnim=0;
					if (diagon!=0) {
						if (diagon*storona>0) {
							if (animState!='trot_up') {
								animState='trot_up';
								vis.osn.gotoAndStop('trot_up');
								vis.osn.body.play();
							}
						} else {
							if (animState!='trot_down') {
								animState='trot_down';
								vis.osn.gotoAndStop('trot_down');
								vis.osn.body.play();
							}
						}
						sndStep(t_walk,1);
						t_walk++;
					} 
					else 
					{
						if (isSit) 
						{
							if (animState=='roll' && vis.osn.body.currentFrame>=15) 
							{
								vis.osn.gotoAndStop('polz');
								animState='polz';
							}
							if (animState!='polz' && animState!='roll') {
								if (maxSpeed>walkSpeed*1.6 && dx*storona>0 && (runForever || ctr.keyStates.keyRun && (ctr.keyStates.keyLeft || ctr.keyStates.keyRight))) {
									vis.osn.gotoAndStop('roll');
									animState='roll';
								} else {
									vis.osn.gotoAndStop('polz');
									animState='polz';
								}
								vis.osn.body.play();
							}
						} else if (maxSpeed<5) {
							sndStep(t_walk,4);
							t_walk++;
							if (animState!='walk') {
								vis.osn.gotoAndStop('walk');
								vis.osn.body.play();
								animState='walk';
							}
						} else if (maxSpeed>walkSpeed*1.6 && dx*storona>0 && (runForever || ctr.keyStates.keyRun && (ctr.keyStates.keyLeft || ctr.keyStates.keyRight))) {
							sndStep(t_walk,2);
							t_walk++;
							if (animState!='run') {
								vis.osn.gotoAndStop('run');
								vis.osn.body.play();
								animState='run';
							}
						} else if (dx*storona>0) {
							sndStep(t_walk,1);
							t_walk++;
							if (animState!='trot') {
								vis.osn.gotoAndStop('trot');
								vis.osn.body.play();
								animState='trot';
							}
						}
					}
				}
 			//на лестнице
			} else if (isLaz) {
				freeAnim=0;
				if (animState!='laz') {
					vis.osn.gotoAndStop('laz');
					animState='laz';
				}
				if (dy==0) vis.osn.body.gotoAndStop(1);
				else {
					cframe=vis.osn.body.currentFrame;
					sndStep(cframe,3);
					if (dy<0) {
						if (cframe<=12) vis.osn.body.gotoAndStop(cframe+1);
						else vis.osn.body.gotoAndStop(2);
					} else {
						if (cframe>=3) vis.osn.body.gotoAndStop(cframe-1);
						else vis.osn.body.gotoAndStop(13);
					}
				}
			//плавание
			} else if (isPlav) {
				freeAnim=0;
				vis.osn.rotation=dy*1.5;
				if (animState!='plav') {
					animState='plav';
					vis.osn.gotoAndStop('plav');
				}
			//в воздухе
			} else {
				freeAnim=0;
				if (animState!='jump' && animState!='levit') {
					if (aJump>0) {
						vis.osn.gotoAndStop('jump');
						animState='jump';
					} else {
						vis.osn.gotoAndStop('pinok');
						animState='pinok';
					}
				}
				if (animState=='pinok' && isFly) {
					vis.osn.gotoAndStop('jump');
					animState='jump';
				}
				if (levit==1 && animState!='levit') {	//начать левитировать
					if (aJump>0 && vis.osn.body.currentFrame>=14 && vis.osn.body.currentFrame<=18) {
						animState='levit';
						vis.osn.gotoAndStop('levit');
					}
					if (aJump==0 && vis.osn.body.currentFrame>=10 && vis.osn.body.currentFrame<=22) {
						animState='levit';
						vis.osn.gotoAndStop('levit');
						vis.osn.body.gotoAndPlay(51);
					}
				}
				if (levit==0 && animState=='levit') {	//перестать левитировать
					vis.osn.gotoAndStop('levit');
					if (vis.osn.body.currentFrame<66) vis.osn.body.gotoAndPlay(67);
				}
				if (levit==1 && animState=='levit') {
					if (vis.osn.body.currentFrame>66) vis.osn.body.gotoAndPlay(17);
				} else if (animState!='levit') {
					if (aJump>0) {
						cframe=Math.round(16+dy);
						if (cframe>32) cframe=32;
						if (cframe<1) cframe=1;
					} else {
						if (dy>2 && dx>-6 && dx<6) {
							cframe=Math.round(31+dy);
							if (cframe<33) cframe=33;
							if (cframe>42) cframe=42;
						} else {
							cframe=Math.round(16+dx*storona);
							if (cframe>32) cframe=32;
							if (cframe<1) cframe=1;
						}
					}
					vis.osn.body.gotoAndStop(cframe);
				}
			}
			//поворот головы
			if (vis.osn.body.head.morda) {
				//trace(headR,headRA,headRO,t_head)
				var drot:int=3;
				if (lurked) headR=25;
				else if (headRO-weaponR<=1 && headRO-weaponR>=-1) {
					t_head--;
					drot=6;
					if (t_head<=0) {
						t_head=Math.floor(Math.random()*100+10);
						headR=Math.random()*70-25;
					}
				} else {
					headR=weaponR;
					t_head=100;
				}
				if (headRA-headR<=1 && headRA-headR>=-1) headRA=headR;
				else headRA+=(headR-headRA)/drot;
				if (isNaN(headRA)) headRA=0;
				if (headRA>55) headRA=55;
				if (headRA<-35) headRA=-35;
				vis.osn.body.head.morda.rotation=headRA;
				headRO=weaponR;
			}
			//самолевитация
			if (levit>0 && t_levitfilter<=20) t_levitfilter+=2;
			if (dJump2 && t_levitfilter<=20) t_levitfilter+=10;
			if (levit==0 && !dJump2 && t_levitfilter>=0) t_levitfilter--;
			if (t_levitfilter==0) {
				f_levit=false;
				setFilters();
			} else if (t_levitfilter>0 && t_levitfilter<=20) {
				levitFilter1.alpha=t_levitfilter/20;
				//levitFilter.strength=t_levitfilter/20;
				levitFilter1.blurX=levitFilter1.blurY=t_levitfilter/4+2;
				f_levit=true;
				setFilters();
			}
			if (dash_t>=dash_maxt-20) {
				dashFilter.blurX=Math.min(dash_t-dash_maxt+20,10)/2;
				setFilters();
			}
			else dashFilter.blurX=0;
			otherVisual();
			if ((shok>0 || runForever>0 || attackForever>0) && vis.osn.body.head.morda.eye.currentFrame==1) {
				vis.osn.body.head.morda.eye.gotoAndStop(2);
			}
			if (shok==0 && runForever<=0 && attackForever<=0 && vis.osn.body.head.morda.eye.currentFrame==2 || klip==1) {
				vis.osn.body.head.morda.eye.gotoAndStop(1);
			}
			if (klip==5 && vis.osn.body.head.morda.eye.currentFrame==1) {
				vis.osn.body.head.morda.eye.gotoAndStop(3);
			}
			if (vis.osn.body.head.morda.eye.eye && klip%10==3 && isrnd(0.2)) {
				vis.osn.body.head.morda.eye.eye.zrak.x+=Math.random()*8-4;
				if (vis.osn.body.head.morda.eye.eye.zrak.x<-20) vis.osn.body.head.morda.eye.eye.zrak.x=-20;
				if (vis.osn.body.head.morda.eye.eye.zrak.x>-11) vis.osn.body.head.morda.eye.eye.zrak.x=-11;
				vis.osn.body.head.morda.eye.eye.zrak.y+=Math.random()*4-2;
			}
			//if (currentWeapon) currentWeapon.animate();
			//trace(animState +'  ' + vis.body.currentFrame);
		}
		
		public function stopAnim():void
		{
			vis.osn.body.stop();
		}
		
		public function getStayFrame():int
		{
			if (shX2>=1 && shX2>=1) return isSit?2:1;  
			if (storona>0) {
				if (isSit) {
					if (shX2>0) return 49+Math.round(shX2*10);
					if (shX1>0) return 49+11+Math.round(shX1*10);
				} else {
					if (shX2>0.3) return 27+Math.round((shX2-0.3)*13);
					if (shX1>0.3) return 27+11+Math.round((shX1-0.3)*13);
				}
			} else {
				if (isSit) {
					if (shX1>0) return 49+Math.round(shX1*10);
					if (shX2>0) return 49+11+Math.round(shX2*10);
				} else {
					if (shX1>0.3) return 27+Math.round((shX1-0.3)*13);
					if (shX2>0.3) return 27+11+Math.round((shX2-0.3)*13);
				}
			}
			return isSit?2:1;
		}
		
		
		public function otherVisual():void
		{
			if (levit!=prev_levit) setFilters();
			prev_levit=levit;
			//trace(f_levit, levit)
			
			//перезарядка
			if (currentWeapon && currentWeapon.t_reload>1) {
				if (!reloadbar.visible) reloadbar.visible=true;
				reloadbar.gotoAndStop(Math.floor(currentWeapon.t_reload/(currentWeapon.reload*currentWeapon.reloadMult)*11)+1)
				World.world.gui.setHolder();
			} else {
				if (reloadbar.visible) reloadbar.visible=false;
			}
			//волосы
			hair=vis.osn.body.head.morda.hair;
			if (hair) {
				if (hairY!=-1000) {
					hairDY+=((Y/5+vis.osn.body.head.y*4-vis.osn.body.head.morda.rotation)-hairY)/4;
					hairR+=hairDY;
					hairDY-=hairR/4;
					hairDY*=0.8;
					if (hairR>8) hairR=8;
					if (hairR<-8) hairR=-8;
				}
				hairY=Y/5+vis.osn.body.head.y*4-vis.osn.body.head.morda.rotation;
				hair.rotation=hairR;
				tail=vis.osn.body.tail.h0;
				if (tail) tail.rotation=-hairR;
				tail=vis.osn.body.tail.h1;
				if (tail) tail.rotation=-hairR;
			}
			//пип
			if (vis.scaleX>0) {
				vis.osn.body.pip1.visible=true;
				vis.osn.body.pip2.visible=false;
				if (vis.osn.body.frleg3) {
					vis.osn.body.pip1.x=vis.osn.body.frleg3.x;
					vis.osn.body.pip1.y=vis.osn.body.frleg3.y;
					vis.osn.body.pip1.rotation=vis.osn.body.frleg3.rotation;
				}
			} else {
				vis.osn.body.pip2.visible=true;
				vis.osn.body.pip1.visible=false;
				if (vis.osn.body.flleg3) {
					vis.osn.body.pip2.x=vis.osn.body.flleg3.x;
					vis.osn.body.pip2.y=vis.osn.body.flleg3.y;
					vis.osn.body.pip2.rotation=vis.osn.body.flleg3.rotation;
				}
			}
			//магия
			vis.osn.body.head.morda.magic.alpha=aMC/100;
			vis.osn.body.head.morda.magic.visible=vis.osn.body.head.morda.magic.alpha>0;
			//крылья
			if (pers.ableFly) {
				if (vis.osn.body.rwing) vis.osn.body.rwing.visible=true;
				if (vis.osn.body.lwing) vis.osn.body.lwing.visible=true;
				if (Settings.alicorn || currentArmor && currentArmor.ableFly) {
					try {
						if (vis.osn.body.rwing.currentFrame!=11) vis.osn.body.rwing.gotoAndStop(11);
						if (vis.osn.body.lwing.currentFrame!=11) vis.osn.body.lwing.gotoAndStop(11);
						vis.osn.body.rwing.wing.wing2.rotation=50-Math.abs(dx)*1.6;
						vis.osn.body.lwing.wing.wing2.rotation=50-Math.abs(dx)*1.2;
						//vis.osn.body.rwing.wing..rotation=Math.abs(dy)*2;
					} catch (err) {}
				} else if (isFly && !stay && !isPlav && !isLaz) {
					if (vis.osn.body.rwing && vis.osn.body.rwing.currentFrame==1) vis.osn.body.rwing.gotoAndPlay(2);
					if (vis.osn.body.lwing && vis.osn.body.lwing.currentFrame==1) vis.osn.body.lwing.gotoAndPlay(2);
				} else {
					if (vis.osn.body.rwing) vis.osn.body.rwing.gotoAndStop(1);
					if (vis.osn.body.lwing) vis.osn.body.lwing.gotoAndStop(1);
				}
			} else {
				if (vis.osn.body.rwing) vis.osn.body.rwing.visible=false;
				if (vis.osn.body.lwing) vis.osn.body.lwing.visible=false;
			}
			//щит
			if (vis.shit && !vis.shit.visible && shithp>0) {
				vis.shit.visible=true;
				vis.shit.gotoAndPlay(1);
			}
			if (vis.shit && vis.shit.visible && shithp<=0) {
				vis.shit.visible=false;
				vis.shit.gotoAndStop(1);
			}
			if (isFetter>0) {
				dfx=fetX-X;
				dfy=fetY-Y+30;
				rfetter=Math.sqrt(dfx*dfx+dfy*dfy);
				vis.fetter.visible=true;
				vis.fetter.scaleX=rfetter/100;
				vis.fetter.rotation=Math.atan2(dfy,dfx*storona)/Math.PI*180;
			} else {
				vis.fetter.visible=false;
			}
		}
		
		public function refreshVis():void
		{
			var dez=vis.osn.currentFrameLabel;
			vis.osn.gotoAndStop('nope');
			vis.osn.gotoAndStop(dez);
			teleColor=World.world.app.cMagic;
			levitFilter1.color=teleColor;
			teleFilter.color=teleColor;
		}
		
		public override function visDetails():void
		{
			World.world.gui.setHp();
		}
		
		public function showElectroBlock() {
			var t:Tile=room.getAbsTile(X+Math.random()*320-160, Y-scY/2+Math.random()*320-160);
			if (t && t.tileMaterial==1 && t.hp>0) Emitter.emit('electro', room, (t.X+0.5)*Tile.tilePixelWidth, (t.Y+0.5)*Tile.tilePixelHeight);
		}
		
		public override function replic(s:String):void
		{
			if (sost!=1 || id_replic=='') return;
			if (t_replic>0) return;
			var s_replic:String;
			t_replic=75+Math.random()*30;
			s_replic=Res.repText(id_replic, s, false);
			if (s_replic==prev_replic) s_replic=Res.repText(id_replic, s, false);
			if (s_replic==prev_replic) return;
			prev_replic=s_replic;
			if (s_replic!='' && s_replic!=null) {
				Emitter.emit('replic2',room,X,Y-90,{txt:s_replic, ry:20});
			}
		}
		
		public override function sndStep(faza:int,tip:int=0):void
		{
			if (rat>0) return;
			super.sndStep(faza,tip);
		}
		protected override function sndFall():void
		{
			if (rat>0) return;
			super.sndFall();
		}
		
		
	}
	
}
