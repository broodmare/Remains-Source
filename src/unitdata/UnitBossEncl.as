package unitdata 
{
	import flash.filters.GlowFilter;
	import flash.display.MovieClip;
	
	import weapondata.*;
	import locdata.Room;
	import servdata.BlitAnim;
	import servdata.LootGen;
	import graphdata.Emitter;
	
	import components.Settings;
	
	public class UnitBossEncl extends UnitPon
	{
		
		public var tr:int=1;
		var weap:String;
		public var scrAlarmOn:Boolean=true;
		public var controlOn:Boolean=true;
		public var kol_emit=8;
		public var called:int=0;
		public var coord:Object;

		public function UnitBossEncl(cid:String=null, ndif:Number=100, xml:XML=null, loadObj:Object=null) 
		{
			super(cid, ndif, xml, loadObj);
			id='bossencl';
			if (xml && xml.@tr.length()) {	//из настроек карты
				tr=xml.@tr;
			}
			//взять параметры из xml
			getXmlParam();
			//boss=true;
			aiTCh=30;
			aiVNapr=1;
			if (tr==1) {
				currentWeapon=Weapon.create(this,'lmg');
				armor=20;
				vulner[D_BUL]=vulner[D_PHIS]=vulner[D_BLADE]=0.7;
			}
			if (tr==2) {
				currentWeapon=Weapon.create(this,'quick');
				marmor=20;
				//currentWeapon.damage;
				vulner[D_LASER]=vulner[D_PLASMA]=vulner[D_SPARK]=0.7;
				blitId='sprEnclboss2';
			}
			if (tr==3) {
				currentWeapon=Weapon.create(this,'mlau');
				currentWeapon.speed=12;
				currentWeapon.accel=0.6;
				currentWeapon.reload=30;
				currentWeapon.damageExpl*=0.6;
				armor=marmor=10;
				vulner[D_EXPL]=vulner[D_FIRE]=vulner[D_CRIO]=0.7;
				blitId='sprEnclboss3';
			}
			initBlit();
			animState='fly';
			if (currentWeapon) weap=currentWeapon.id;
			else weap='';
			if (currentWeapon) childObjs=new Array(currentWeapon);
			if (currentWeapon && currentWeapon.uniq) {
				currentWeapon.updVariant(1);
			}
			isFly=true;
			aiNapr=storona;
		}
		
		public override function die(sposob:int=0):void
		{
			super.die(3);
			coord['liv'+tr]=false;
		}
		
		public override function putLoc(newRoom:Room, nx:Number, ny:Number):void
		{
			super.putLoc(newRoom,nx,ny);
			if (newRoom.unitCoord==null) 
			{
				newRoom.unitCoord=new Coord(newRoom);
			}
			coord=newRoom.unitCoord;
			coord['liv'+tr]=true;
		}

		public override function setLevel(nlevel:int=0):void
		{
			super.setLevel(nlevel);
			var wMult=(1+level*0.08);
			var dMult=1;
			if (World.world.game.globalDif==3) dMult=1.2;
			if (World.world.game.globalDif==4) dMult=1.5;
			hp=maxhp=hp*dMult;
			dam*=dMult;
			if (currentWeapon) {
				currentWeapon.damage*=dMult;
			} 
		}
		
		public override function animate():void
		{
			var cframe:int;
			var revers:Boolean=false;
			if (isFly) {
				animState='fly';
			} else {
				animState='stay';
			}
			if (animState!=animState2) {
				anims[animState].restart();
				animState2=animState;
			}
			if (!anims[animState].st) {
				if (revers) blit(anims[animState].id,anims[animState].maxf-anims[animState].f-1);
				else blit(anims[animState].id,anims[animState].f);
			}
			anims[animState].step();
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
		
		var minY:int=250;
		var maxY:int=850;
		var minX:int=1000;
		var maxX:int=1600;
		var sinX:Number=Math.random()*10;
		var sinDX:Number=Math.random()*0.1+0.02;
		
		var emit_t:int=0;
		
		//aiState
		//0 - стоит на месте
		//1 - летает и атакует
		//2 - меняет оружие
		
		public override function control():void
		{
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
			
			//таймер смены состояний
			if (aiTCh>0) aiTCh--;
			else {
					aiState=1;
					aiTCh=Math.floor(Math.random()*60+150);
			}
			//поиск цели
			//trace(aiState)
			if (aiTCh%40==1) {
				if (room.gg.pet && room.gg.pet.sost==1 && isrnd(0.4)) setCel(room.gg.pet);
				else setCel(room.gg);
			}
			//направление
			storona=(celDX>0)?1:-1;

			
			destroy=0;
			//поведение при различных состояниях
			if (aiState==0) {
			} else {
				sinX+=sinDX;
				if (Y<minY && dy<maxSpeed) {
					dy+=accel;
					aiVNapr=1;
				}
				if (Y>maxY && dy>-maxSpeed) {
					dy-=accel;
					aiVNapr=-1;
				}
				if (Y>=minY && Y<=maxY) {
					if (aiVNapr==1 && dy<maxSpeed) dy+=accel;
					if (aiVNapr==-1 && dy>-maxSpeed) dy-=accel;
				}
				if (X<minX && dx<maxSpeed) {
					dx+=accel;
				}
				if (X>maxX && dx>-maxSpeed) {
					dx-=accel;
				}
				if (X>=minX && X<=maxX) {
					dx+=Math.sin(sinX)*accel/2;
				}
			} 
			if (aiState==1) {
				attack();
			}

		}
		
		public function attack():void
		{
			if (celUnit) 
			{	//атака холодным оружием без левитации или корпусом
				attKorp(celUnit);
				if (coord.tr==tr && coord.t1>45) currentWeapon.attack();
			}
		}
		
		public override function command(com:String, val:String=null):void
		{
			if (com=='off') 
			{
				walk=0;
				controlOn=false;
			} 
			else if (com=='on') 
			{
				controlOn=true;
			}
		}
		
	}
}
