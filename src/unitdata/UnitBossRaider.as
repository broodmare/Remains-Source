package unitdata 
{

	import flash.filters.GlowFilter;
	import flash.display.MovieClip;
	
	import weapondata.*;
	import locdata.Tile;
	import servdata.BlitAnim;
	import servdata.LootGen;
	import graphdata.Emitter;
	
	import components.Settings;
	
	import stubs.visualRaiderBoss;
	import stubs.visualRaiderBoss2;

	public class UnitBossRaider extends UnitPon
	{
		
		public var tr:int=1;
		var weap:String;
		public var scrAlarmOn:Boolean=true;
		public var controlOn:Boolean=true;
		public var kol_emit=8;
		public var called:int=0;

		public function UnitBossRaider(cid:String=null, ndif:Number=100, xml:XML=null, loadObj:Object=null)
		{
			super(cid, ndif, xml, loadObj);
			id='bossraider';
			if (xml && xml.@tr.length()) 
			{	//из настроек карты
				tr=xml.@tr;
			}
			//взять параметры из xml
			if (tr==2) vis=new visualRaiderBoss2();
			else vis=new visualRaiderBoss();
			vis.osn.gotoAndStop(1);
			getXmlParam();
			walkSpeed=maxSpeed;
			plavSpeed=maxSpeed;
			runSpeed=maxSpeed*6;
			plavdy=accel;
			porog=45;
			boss=true;
			aiTCh=80;
			
			//дать оружие
			if (tr==1) 
			{
				currentWeapon=Weapon.create(this,'carbine');
				aiDist=2000;
			}
			if (tr==2) 
			{
				currentWeapon=Weapon.create(this,'flamer');
				aiDist=500;
			}
			if (currentWeapon) weap=currentWeapon.id;
			else weap='';
			if (currentWeapon) childObjs=new Array(currentWeapon);
			if (currentWeapon && currentWeapon.uniq) 
			{
				currentWeapon.updVariant(1);
			}
			
			aiNapr=storona;
		}
		

		public override function save():Object
		{
			var obj:Object=super.save();
			if (obj==null) obj = {};
			obj.tr=tr;
			obj.weap=weap;
			return obj;
		}
		
		public override function setLevel(nlevel:int=0):void
		{
			super.setLevel(nlevel);
			var wMult=(1+level*0.08);
			var dMult=1;
			if (GameSession.currentSession.game.globalDif==3) dMult=1.2;
			if (GameSession.currentSession.game.globalDif==4) dMult=1.5;
			hp=maxhp=hp*dMult;
			dam*=dMult;
			if (currentWeapon) {
				currentWeapon.damage*=dMult;
			} 
		}
		
		public override function animate():void
		{
			if (sost==3) { //сдох
				if (animState!='die') {
					vis.osn.gotoAndStop('die');
					animState='die';
				}
			} else if (aiState==4 || aiState==6) 
			{
				if (animState!='bac') {
					vis.osn.gotoAndStop('bac');
					animState='bac';
				}
			} 
			else if (stay) 
			{
				if (dx<1 && dx>-1) 
				{
					if (animState!='stay') 
					{
						vis.osn.gotoAndStop('stay');
						animState='stay';
					}
				} 
				else if (aiState==1) 
				{
					if (animState!='run') 
					{
						vis.osn.gotoAndStop('run');
						animState='run';
					}
				} 
				else 
				{
					if (animState!='trot') 
					{
						vis.osn.gotoAndStop('trot');
						animState='trot';
					}
				}
			} 
			else 
			{
				if (animState!='jump') 
				{
					vis.osn.gotoAndStop('jump');
					animState='jump';
					var cframe=Math.round(16+dy);
					if (cframe>32) cframe=32;
					if (cframe<1) cframe=1;
					vis.osn.body.gotoAndStop(cframe);
				}
			} 
		}
		
		public override function setWeaponPos(tip:int=0):void
		{
			weaponX=X;
			weaponY=Y-scY*0.58;
		}
		
		public override function dropLoot():void
		{
			super.dropLoot();
			if (currentWeapon) {
				if (currentWeapon.vis) currentWeapon.vis.visible=false;
				var cid:String=currentWeapon.id;
				if (currentWeapon.variant>0) cid+='^'+currentWeapon.variant;
				LootGen.lootId(room,currentWeapon.X,currentWeapon.Y,cid,0);
			}
			if (attackerType==3) 
			{
				for (var i:int = 0; i < 3; i++) 
				{
					setCel(null,X+Math.random()*30-15,Y-Math.random()*15);
					currentWeapon.attack();
				}
			}
		}
		
		public override function damage(dam:Number, tip:int, bul:Bullet=null, tt:Boolean=false):Number
		{
			var td:Number=super.damage(dam, tip, bul,tt);
			if (tr==2 && GameSession.currentSession.game.globalDif>1) {
				var tc:int=Math.floor((maxhp-hp)/maxhp*4);
				if (tc>called) {
					room.enemySpawn(true,true);
					called++;
				}
			}
			return td;
		}

		public function emit():void
		{
			var un:Unit=room.createUnit('vortex',X,Y-scY/2,true);
			un.fraction=fraction;
			un.oduplenie=0;
			emit_t=500;
			kol_emit--;
		}
		
		public override function setNull(f:Boolean=false):void
		{
			super.setNull(f);
			//вернуть в исходную точку
			if (begX>0 && begY>0) setPos(begX, begY);
			dx=dy=0;
			setWeaponPos();
			aiState=aiSpok=0;
		}
		
		public function jump(v:Number=1) {
			aiJump=Math.floor(30+Math.random()*50);
			if (stay || isLaz) {		//прыжок
				dy=-jumpdy*v;
				isLaz=0;
			}
			if (stay) {
				if (aiNapr==-1) dx*=0.8;
				else dx+=storona*accel*2;
			}
		}
		

		var aiLaz:int=0, aiJump:int=0;	
		var aiAttack:int=0, attackerType:int=0;	//0-без оружия, 1-хол.оруж., 2-пальба
		var aiAttackT:int=0, aiAttackOch:int=12;	//стрельба очередью
		var aiDist:int; 
		var aiVKurse:Boolean=false;
		var celUnit2:Unit, t_chCel:int=0;
		var emit_t:int=0;
		
		//aiState
		//0 - стоит на месте
		//1 - атакует корпусом
		//2 - стоит и стреляет
		//3 - лупит по земле
		
		public override function control():void
		{
			var t:Tile;
			//если сдох, то не двигаться
			if (sost==3) return;
			if (stun) {
				aiState=0; aiTCh=3; walk=0;
			}
			
			t_replic--;
			var jmp:Number=0;
			//return;
			
			if (room.gg.invulner) return;
			if (Settings.enemyAct<=0) {
				celY=Y-scY;
				celX=X+scX*storona*2;
				return;
			}
			
			if (aiLaz>0) aiLaz--;
			if (aiJump>0) aiJump--;
			//таймер смены состояний
			if (aiTCh>0) aiTCh--;
			else {
				aiState++;
				if (aiState>5) aiState=1;
				if (aiState==2 || aiState==4 || aiState==5) aiTCh=30;
				else aiTCh=Math.floor(Math.random()*100)+150;
			}
			//поиск цели
			//trace(aiState)
			if (aiTCh%10==1) {
				if (room.gg.pet && room.gg.pet.sost==1 && isrnd(0.4)) setCel(room.gg.pet);
				else setCel(room.gg);
			}
			//направление
			celDX=celX-X;
			if (stay) celDY=celY-Y+scY;
			if (celDY>40) aiVNapr=1;		//вниз
			else if(celDY<-40) aiVNapr=-1;	//прыжок
			else aiVNapr=0;
			porog=10;
			throu=(celDY>160);
			if (celDY>70) porog=0;
			if (isLaz==0) storona=aiNapr;

			
			//скорость
			maxSpeed=walkSpeed;
			if (aiState==1) {
				maxSpeed=runSpeed;
			}
			destroy=0;
			//поведение при различных состояниях
			if (aiState==0) {
				if (dx>0.5) storona=1; 
				if (dx<-0.5) storona=-1;
				walk=0;
			} else if (aiState==1 || (aiState==2 || aiState==3) && Math.abs(celDX)>aiDist) 
			{
				destroy = 50;

				if (aiTCh%15 == 1 && aiState != 6) 
				{
					if (isrnd(0.5)) 
					{
						if (celDX>100) aiNapr=storona=1;
						if (celDX<-100) aiNapr=storona=-1;
					}
				}

				if (levit) 
				{
					if (aiNapr == -1) 
					{
						if (dx>-maxSpeed) dx-=levitaccel;
					} 
					else 
					{
						if (dx<maxSpeed) dx+=levitaccel;
					}
				} 
				else if (stay || isPlav) 
				{
					if (aiNapr == -1) 
					{
						if (dx > -maxSpeed) dx -= accel;
						walk = -1;
					} 
					else 
					{
						if (dx < maxSpeed) dx += accel;
						walk = 1;
					}
				} 
				else 
				{
					if (aiNapr == -1) 
					{
						if (dx>-maxSpeed) dx-=accel/4;
					} 
					else if (aiNapr==1)
					{
						if (dx<maxSpeed) dx+=accel/4;
					}
				}
				if (stay && isrnd(0.5) && aiVNapr<=0 && (shX1>0.5 && aiNapr<0 || shX2>0.5 && aiNapr>0)) jmp=0.5;
				if (stay && Y-begY>=40) jmp=1;
				if (stay && tr==2 && celDY<-100) jmp=1;
				if (turnX!=0) 
				{
					if (celDX*aiNapr<0) 
					{				//повернуться, если цель сзади
						aiNapr=storona=turnX;
						aiTTurn=Math.floor(Math.random()*20)+5;
					} 
					else 
					{							//попытаться перепрыгнуть, если цель спереди
						aiTTurn--;
						if (aiTTurn<0) 
						{
							aiNapr=storona=turnX;
							aiTTurn=Math.floor(Math.random()*20)+5;
						}
					}
					turnX=turnY=0;
				}
				if (jmp>0 && aiJump<=0) {
					storona=aiNapr;
					jump(jmp);
					jmp=0;
				}
			} 
			else if (aiState==3 || aiState==2) 
			{
				walk=0;
				aiNapr=storona=(celX>X)?1:-1;
				if (celDX*celDX+celDY*celDY<200*200) 
				{
					aiState=1;
				}
			}
			
			attack();

		}
		
		public function attack():void
		{
			if (aiState==1 && celUnit) 
			{	//атака холодным оружием без левитации или корпусом
				attKorp(celUnit,(Math.abs(dx-celUnit.dx)>8)?1:0.5);
			} 
			else if (aiState==3) 
			{							//пальба
				mazil=10;		//стоя на месте стрельба точнее
				if (aiAttackOch>0) 
				{										//стрельба очередями
					if (aiAttackT<=0) aiAttackT=Math.round((Math.random()*0.4+0.8)*aiAttackOch);
					if (aiAttackT>aiAttackOch*0.25) currentWeapon.attack();
					aiAttackT--;
				}
				//currentWeapon.attack();
				if ((celDX*celDX+celDY*celDY<100*100) && isrnd(0.1)) attKorp(celUnit,0.5);
				} else if (aiState==4) {		//тряска
					if (aiTCh==5) quake();
				} else if (aiState==5) {		//тряска
					if (aiTCh==5 && kol_emit && tr==1) emit();
				if (celUnit && isrnd(0.02)) {
					currentWeapon.attack();
					if (currentWeapon is WThrow && (currentWeapon as WThrow).kolAmmo<=0) attackerType=0;
				}
				if ((celDX*celDX+celDY*celDY<100*100) && isrnd(0.1)) attKorp(celUnit,(Math.abs(dx)>8)?1:0.5);
			}
		}
		
		public function quake():void
		{
			room.earthQuake(40);
			Emitter.emit('quake', room, X + Math.random() * 40 - 20, Y);
		}
		
		public override function command(com:String, val:String=null):void
		{
			if (com == 'off') 
			{
				walk = 0;
				controlOn = false;
			} 
			else if (com == 'on') 
			{
				controlOn = true;
			}
		}
		
	}
}
