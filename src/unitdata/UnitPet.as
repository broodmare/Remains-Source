package unitdata 
{
	
	import weapondata.Weapon;
	import graphdata.Emitter;
	import locdata.Tile;
	import locdata.Box;
	
	import components.Settings;
	
	import stubs.visualMoon;

	public class UnitPet extends Unit{
		
		var spd:Object;
		var flyX:Number=0, flyY:Number=0, flyDX:Number=0, flyDY:Number=0, flyR:Number, flyBox:Box;	//точка, в которую надо лететь
		var iskr:Emitter;
		var gg:UnitPlayer;
		public var active:Boolean=false;
		var rasstGG:Number=200;		//дистанция до ГГ, больше которой включается следование
		var rasstUnmat:Number=400;		//дистанция до ГГ, больше которой включается нематериальность
		var rasstVisEn:Number=800;	//максимальная дистанция атаки
		var rasstWeap:Number=200;	//дистанция атаки
		var rasstOut:Number=100;	//дистанция отлёта
		var tempUnmat:Boolean=false;
		
		var optEnW:Boolean=true;	//энергетическое оружие
		var optSit:Boolean=true;	//садиться на ящики
		var optAutores:Boolean=true;	//автовозрождение
		var optUncall:Boolean=false;	//отзыв при смерти
		var optTurn:Boolean=true;	//поворачиваться

		public function UnitPet(cid:String=null, ndif:Number=100, xml:XML=null, loadObj:Object=null) 
		{
			super(cid, ndif, xml, loadObj);
			id='phoenix';
			if (cid!=null) id=cid;
			getXmlParam();
			fraction=Unit.F_PLAYER;
			//fraction=1;
			if (id=='moon') {
				vis=new visualMoon();
				vis.osn.stop();
			} else {
				initBlit();
				animState='fly';
			}
			aiState=1;
			walkSpeed=maxSpeed;
			runSpeed=maxSpeed*2;
			isFly=true;
			isSats=false;
			spd= {};
			elast=0.2;
			plaKap=true;
			mater=false;
			activateTrap=0;
			currentWeapon=getXmlWeapon(ndif);
			if (currentWeapon) childObjs=new Array(currentWeapon);
			if (id=='phoenix') {
				optAutores=true;
				rasstWeap=200;
			}
			if (id=='owl') {
				optAutores=false;
				rasstWeap=400;
				vulner[D_NECRO]=0.2;
			}
			if (id=='moon') {
				knocked=0;
				optAutores=false;
				optSit=false;
				optUncall=true;
				rasstWeap=400;
				optTurn=false;
				storona=1;
				vulner[D_NECRO]=0.5;
			}
			transT=true;
			sost=4;
		}

		public override function expl():void
		{
			if (id=='phoenix')	newPart('green_spark',25);
			if (id=='owl')	newPart('orange_spark',25);
			if (id=='moon')	newPart('blue_spark',25);
		}
		
		public override function step():void
		{
			if (GameSession.currentSession.room.petOn) super.step();
		}
		
		public override function forces():void
		{
			if (isFly) {
				if (dx*dx+dy*dy>maxSpeed*maxSpeed)
				{
					dx*=0.8;
					dy*=0.8;
				}
				if (isPlav) 
				{
					dy*=0.9;
					dx*=0.9;
					if (mater) dy+=Settings.ddy*ddyPlav;
				}
			} 
			else super.forces();
		}
		
		//лечение 0-предметами, 1-радиацией
		public override function heal(hl:Number, tip:int=0, ismess:Boolean=true):void
		{
			if (tip==1 && (id!='phoenix' || sost>=3)) return;
			hp+=hl;
			if (hp>maxhp) hp=maxhp;
			if (hl>0) visDetails();
			if ((tip==0 || hl>=10) && active && ismess) {
				numbEmit.castSpell(room,X,Y-scY/2,{txt:'+'+Math.round(hl), frame:4, rx:10, ry:10});
			}
		}
		
		public override function setNull(f:Boolean=false):void
		{
			super.setNull(f);
			aiState=1;
			getFlyPoint();
			if (optTurn) storona=(celX>X)?1:-1;
		}
		
		//настройка силы спутника
		public override function setLevel(nlevel:int=1):void
		{
			level = nlevel-1;
			var koef=hp/maxhp;
			if (id=='phoenix') 
			{
				maxhp=gg.pers.petHP*(1+level*0.12);
				dam=gg.pers.petDam*(1+level*0.1);
				currentWeapon.damage=gg.pers.petDam*(1+level*0.1);
				skin=gg.pers.petSkin;
				allVulnerMult=gg.pers.petVulner;
			} else if (id=='owl') 
			{
				maxhp=gg.pers.owlHP*(1+level*0.1);
				dam=gg.pers.owlDam*(1+level*0.1);
				currentWeapon.damage=gg.pers.owlDam*(1+level*0.1);
				skin=gg.pers.owlSkin;
				allVulnerMult=gg.pers.owlVulner;
			} else if (id=='moon') 
			{
				maxhp=gg.pers.moonHP*(1+level*0.1)*gg.spellPower;
				dam=gg.pers.moonDam*(1+level*0.1)*gg.spellPower;
			}
			//currentWeapon.damage=1;
			hp=koef*maxhp;
		}
		
		public override function setWeaponPos(tip:int=0):void
		{
			if (id=='phoenix') {
				weaponX=X+15*storona;
				weaponY=Y-20;
			} else {
				weaponX=X+11*storona;
				weaponY=Y-18;
			}
			magicX=weaponX;
			magicY=weaponY;
		}
		
		public override function animate():void
		{
			if (oduplenie>30) vis.alpha=0;
			else if (oduplenie>0) vis.alpha=1-oduplenie/30;
			else vis.alpha=1;
			if (id=='moon') {
				if (aiState==4 || aiState==5 || aiState==2) {
					vis.osn.gotoAndStop(2);
					vis.osn.rotation+=30;
				} else {
					vis.osn.gotoAndStop(1);
					vis.osn.rotation+=3; 
				}
			} else {
				if (aiState==0) animState='stay';
				else animState='fly';
				if (animState!=animState2) {
					anims[animState].restart();
					animState2=animState;
				}
				if (!anims[animState].st) {
					blit(anims[animState].id,Math.floor(anims[animState].f));
				}
				anims[animState].step();
			}
			if (hpbar) hpbar.alpha=vis.alpha;
		}
		public override function visDetails():void
		{
			super.visDetails();
			GameSession.currentSession.gui.setPet();
		}
		
		//найти точку следования
		public function getFlyPoint():void
		{
			var rx:Number=-120;
			var ry:Number=-80;
			flyBox=null;
			//var nx:Number, ny:Number;
			flyX=gg.X+gg.storona*rx;
			flyY=gg.Y+ry;
			if (flyX<60) flyX=60;
			if (flyX>room.roomPixelWidth-60) flyX=room.roomPixelWidth-60;
			if (flyY<80) flyY=80;
			if (flyY>room.roomPixelHeight-40) flyY=room.roomPixelHeight-40;
			if (optSit) {
				for each (var b:Box in room.objs) {
					if (b.wall==0 && b.stay && !b.invis && b.X1<flyX && b.X2>flyX && flyY-b.Y1<80 &&  flyY-b.Y1>-40) {
						flyY=b.Y1;
						flyX=b.X;
						flyBox=b;
						break;
					}
				}
			}
			if (!room.collisionUnit(flyX,flyY,scX,scY)) return;
			flyX=Math.floor(flyX/40)*40+20;
			flyY=Math.floor(flyY/40)*40+39;
			if (room.getAbsTile(flyX,flyY).phis==0) return;
			flyX+=40*gg.storona;
			flyY+=40;
			if (room.getAbsTile(flyX,flyY).phis==0) return;
			flyY+=40;
			if (room.getAbsTile(flyX,flyY).phis==0) return;
			flyX+=40*gg.storona;
			if (room.getAbsTile(flyX,flyY).phis==0) return;
			flyX=gg.X;
			flyY=gg.Y-1;
		}
		
		public function visCelUnit(un:Unit):Boolean 
		{
			return room.isLine(X,Y-30,un.X,un.Y-un.scY/2);
		}
		
		public override function findCel(over:Boolean=false):Boolean
		{
			celUnit=null;
			if (gg.invulner) return null;
			for each (var un:Unit in room.units) {
				if (un.disabled || un.sost>=3 || un.fraction==fraction || un.doop || un.invis || un.invulner || un.noAgro || un.trigDis) continue;
				if (un is UnitTurret && un.aiState<=1) continue;
				var tx=un.X-X;
				var ty=un.Y-Y;
				if (tx*tx+ty*ty>rasstVisEn*rasstVisEn) continue;	//если расстояние больше расстояния атаки, игнорировать
				if (optEnW && un.isPlav) continue;	//если враг под водой, игнорировать 
				if (currentWeapon && currentWeapon.damage*un.vulner[currentWeapon.tipDamage]<(optEnW?un.marmor:un.armor)+un.skin+1-currentWeapon.pier) continue;	//если оружие не наносит урона, игнорировать
				if (visCelUnit(un)) {
					setCel(un);
					return true;
				}
			}
			
			return false;
		}
		
		//приказ двигаться
		public function moveTo(nx:Number, ny:Number, unmat:Boolean=false):void
		{
			if (sost==4 || oduplenie>0) return;
			tempUnmat=unmat;
			flyBox=null;
			if (!room.base && room.getAbsTile(nx,ny).visi<0.5) 
			{
				//не лететь в неразведанное место
				return;
			}
			flyX=nx;
			flyY=ny+20;
			aiState=3;
			if (optTurn) storona=(flyX>X)?1:-1;
			aiTCh=100;
		}
		
		//приказ атаковать
		public function atk(un:Unit):void
		{
			tempUnmat=false;
			if (visCelUnit(un)) 
			{
				setCel(un);
				flyBox=null;
				aiState=2;
			}
		}
		
		public function call():void 
		{
			active=true;
			if (hp<=0 && !optAutores) return;
			if (sost==4 && optAutores) resurrect();
			oduplenie=60;
			vis.alpha=0;
			vis.visible=true;
			aiState=1;
			sost=1;
			addVisual();
			flyX=gg.X;
			flyY=gg.Y-20;
			setLevel(gg.pers.level);
			if (room && room.units) room.units[1] = this;
			//damage(40,Unit.D_INSIDE);
		}
		
		//отзыв
		public function recall():void
		{
			active=false;
			sost=4;
			if (vis.visible) expl();
			vis.visible=false;
			remVisual();
		}
		
		public override function die(sposob:int = 0):void
		{
			if (sost>=3) return;
			if (optAutores)	GameSession.currentSession.gui.infoText('petDie', objectName, GameSession.currentSession.pers.petRes);
			else GameSession.currentSession.gui.infoText('petDie2', objectName);
			if (optUncall) {
				recall();
				gg.pet=null;
				gg.childObjs[2]=null;
				gg.currentPet='';
				return;
			}
			if (hpbar) hpbar.visible=false;
			vis.visible=false;
			hp=0;
			poison=stun=cut=0;
			sost=4;
			expl();
			if (optAutores)	gg.noPet = GameSession.currentSession.pers.petRes * 30;
			GameSession.currentSession.gui.setPet();
		}
		
		public function resurrect():void
		{
			GameSession.currentSession.gui.infoText('petRes', objectName);
			if (hpbar) hpbar.visible=false;
			hp=Math.min(100,maxhp/2);
			setLevel(gg.pers.level);
			visDetails();
			X=gg.X;
			Y=gg.Y-20;
			oduplenie=60;
			vis.alpha=0;
			cut=poison=stun=0;
			vis.visible=true;
			sost=1;
			aiState=1;
			GameSession.currentSession.gui.setPet();
		}
		
		public function repair(hl:Number):Boolean 
		{
			if (hp<0) hp=0;
			if (hp>=maxhp) return false;
			heal(hl,0,false);
			if (sost==4) 
			{
				sost=1;
				if (gg.currentPet==id) 
				{
					GameSession.currentSession.gui.infoText('petRes', objectName);
					setLevel(gg.pers.level);
					visDetails();
					X=gg.X;
					Y=gg.Y-20;
					oduplenie=60;
					vis.alpha=0;
					cut=poison=stun=0;
					vis.visible=true;
					aiState=1;
					GameSession.currentSession.gui.setPet();
				}
			}
			return true;
		}
		
		//состояния
		//0 - сидит на месте
		//1 - следует
		//2 - атакует
		//3 - движется в указанное место
		//4 - атакует корпусом
		//5 - после атаки корпусом
		
		public override function control():void
		{
			if (sost>=3 || !active) return;
			if (stun) {
				return;
			}
			if ((rasst2<rasstUnmat*rasstUnmat) || celUnit) {
				if (!mater && aiTCh%10==1 && !collisionAll()) mater=true;
			} else {
				mater=false;
			}
			if (tempUnmat) mater=false;
			if (aiTCh>0) aiTCh--;		//счётчик смены состояний
			else {						//смена состояний
				tempUnmat=false;
				if (aiState==0 || aiState==1) {	//выбрать точку следования
					if (rasst2>rasstGG*rasstGG || isPlav) {
						aiState=1;
						getFlyPoint();
						if (optTurn) storona=(flyX>X)?1:-1;
					} else {
						if (optTurn) storona=(flyX>gg.X)?-1:1;
					}
				} else if (aiState==2) {
					if (rasst2>rasstGG*rasstGG*9) getFlyPoint();
					if (celUnit==null) setCel(null, celX+Math.random()*300-150, celY+Math.random()*120-60);
				} else if (aiState==4 || aiState==5) {
					aiState=2;
				} else if (aiState==3) {
					if (GameSession.currentSession.t_battle<=0) aiState=1;
					else aiState=2;
				}
				if (gg.dx>2 || gg.dx<-2) aiTCh=Math.floor(Math.random()*20)+10;
				else aiTCh=Math.floor(Math.random()*100)+30;
			}
			//движение
			if (isFly) {
				flyDX=flyX-X;
				flyDY=flyY-Y;
				var flyR=Math.sqrt(flyDX*flyDX+flyDY*flyDY);
				if (aiState==0) {
					dy=dx=0;
					spd.x=spd.y=0;
					if (flyBox && !flyBox.stay) {
						aiState=1;
						flyBox=null;
					}
				} if (aiState==2) {
					if (optTurn) storona=(celX>X)?1:-1;
					if (flyR>rasstWeap*0.9 || !mater) {
						spd.x=flyDX;
						spd.y=flyDY;
						norma(spd,Math.min(accel*2,accel*flyR/200));
					} else if (flyR<rasstOut) {	//улетать от цели
						spd.x=-flyDX;
						spd.y=-flyDY/2-3;
						//norma(spd,accel*3*(rasstWeap*0.5-flyR)/rasstWeap);
						norma(spd,accel);
					} else {
						dy*=0.85;
						dx*=0.85;
						spd.x=spd.y=0;
					}
					if (turnX!=0) {
						dy+=Math.random()*8-4;
						turnX=0;
					}
					if (turnY!=0) {
						dx+=Math.random()*8-4;
						turnY=0;
					}
				} else if (aiState==5) {
					spd.x*=0.95;
					spd.y*=0.95;
					dx*=0.9;
					dy*=0.9;
				} else if (aiState==4) {
				} else {
					if (flyR<20 && flyBox && mater) {	//сесть на предмет
						spd.x=spd.y=0;
						dx=flyX-X;
						dy=flyY-Y;
						aiState=0;
					} else if (flyR<100 && mater) {
						dy*=0.95;
						dx*=0.95;
						spd.x=spd.y=0;
					} else {
						spd.x=flyDX;
						spd.y=flyDY;
						norma(spd,Math.min(accel*2,accel*flyR/200));
					}
				}
				dx+=spd.x;
				dy+=spd.y;
			}
			if (celUnit && celUnit.fraction==fraction) celUnit=null;
			//поиск цели
			if (aiState<=1 && aiTCh%30==1 && oduplenie<=0) {
				if (findCel() || GameSession.currentSession.t_battle>0) {
					aiState=2;
				}
			} if ((aiState==2 || aiState==5) && aiTCh%15==1) {
				if (celUnit && !celUnit.disabled && celUnit.sost<3 && visCelUnit(celUnit)) {	//цель установлена и видна
					
				} else if (findCel()) {		//найти новую цель
					
				} else {					//успокоиться
					if (GameSession.currentSession.t_battle<=0) aiState=1;
				}
			} else if (aiState==3) {
				//достиг точки назначения
				if (flyR<20) {
					if (GameSession.currentSession.t_battle<=0) aiState=1;
					else aiState=2;
				}
			}
			if (aiState==2 && flyR<rasstWeap && currentWeapon==null && celUnit) {
				aiState=4;
				aiTCh=15;
				spd.x=celUnit.X-X;
				spd.y=celUnit.Y-celUnit.scY/2-Y+scY/2;
				norma(spd,runSpeed);
			}
			if (aiState==4) {
				if (celUnit) {
					if (attKorp(celUnit)) {
						spd.x*=0.5;
						spd.y*=0.5;
						aiState=5;
						aiTCh=15;
						damage(dam*0.02,Unit.D_INSIDE);
					}
				} else aiState=2;
			}
			
			if (aiState<=1) maxSpeed=walkSpeed;
			else maxSpeed=runSpeed;
	
			//атака
			if (aiState==2 && celUnit && !isPlav) {
				celX=celUnit.X;
				celY=celUnit.Y-celUnit.scY/2;
				flyX=celUnit.X;
				flyY=celUnit.Y-80;
				if (flyR<=rasstWeap && currentWeapon) currentWeapon.attack();
			}
		}
	}
	
}
