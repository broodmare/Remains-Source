package unitdata 
{
	
	import flash.filters.GlowFilter;
	import flash.display.MovieClip;
	
	import weapondata.*;
	import locdata.Room;
	import servdata.LootGen;
	import graphdata.Emitter;
	
	import components.Settings;
	
	import stubs.visualUltraSentinel;
	import stubs.visShit;

	public class UnitBossUltra extends Unit{
		
		public var tr:int=1;
		var weap:String;
		public var scrAlarmOn:Boolean=true;
		public var controlOn:Boolean=true;
		public var kol_emit=3;
		var spd:Object;
		public var called:Boolean=false;
		var dopWeapon, gasWeapon, currentWeapon2:Weapon;
		var thWeapon:Weapon;
		var shitMaxHp:Number=500;
		var visshit:MovieClip;
		var usil:Boolean=false;

		public function UnitBossUltra(cid:String=null, ndif:Number=100, xml:XML=null, loadObj:Object=null)
		{
			super(cid, ndif, xml, loadObj);
			id='bossultra';
			tr=1;
			
			//взять параметры из xml
			vis=new visualUltraSentinel();
			vis.osn.gotoAndStop(1);
			visshit=new visShit();
			vis.addChild(visshit);
			visshit.gotoAndStop(1);
			visshit.visible=false;
			visshit.y=-70;
			visshit.scaleX=visshit.scaleY=1.7;
			
			getXmlParam();
			walkSpeed=maxSpeed;
			plavSpeed=maxSpeed;
			boss=true;
			isFly=true;
			aiTCh=80;
			
			shitArmor=15;
			
			//дать оружие
			currentWeapon=Weapon.create(this, 'robogatp');
			currentWeapon2=Weapon.create(this, 'robogatp2');
			currentWeapon2.vis.visible=false;
			dopWeapon=Weapon.create(this,'robomlau2');
			gasWeapon=Weapon.create(this,'robogas');
			thWeapon=Weapon.create(this,'roboplagr');
			thWeapon.findCel=false;
			(thWeapon as WThrow).kolAmmo=100000;
			childObjs=[currentWeapon, currentWeapon2, dopWeapon, gasWeapon, thWeapon];
			
			spd= {};
			aiNapr=storona;
			
			timerDie=150;
		}
		
		public override function dropLoot():void
		{
			newPart('baleblast');
			Snd.ps('bale_e');
			currentWeapon.vis.visible=false;
			super.dropLoot();
		}
		
		public override function setLevel(nlevel:int=0):void
		{
			super.setLevel(nlevel);
			var wMult=(1+level*0.07);
			var dMult=1;
			if (GameSession.currentSession.game.globalDif==3) dMult=1.2;
			if (GameSession.currentSession.game.globalDif==4) dMult=1.5;
			hp=maxhp=hp*dMult;
			shitMaxHp*=(1+level*0.12)*dMult;
			dam*=dMult;
			if (dopWeapon) {
				dopWeapon.damageExpl*=wMult*dMult;
				dopWeapon.damage*=wMult*dMult;
			}
			if (gasWeapon) {
				gasWeapon.damageExpl*=wMult*dMult;
				gasWeapon.damage*=wMult*dMult;
			}
			if (thWeapon) {
				thWeapon.damageExpl*=wMult*dMult;
				thWeapon.damage*=wMult*dMult;
			}
			if (currentWeapon) {
				currentWeapon.damage*=dMult;
				currentWeapon2.damage*=dMult;
			} 
		}
		
		public override function expl():void
		{
			newPart('metal', 22);
		}
		
		public override function putLoc(newRoom:Room, nx:Number, ny:Number):void
		{
			super.putLoc(newRoom,nx,ny);
			setCel(null,nx+200*storona, ny - 50);
		}
		
		public override function setNull(f:Boolean=false):void
		{
			if (sost==1) 
			{
				if (dopWeapon) dopWeapon.setNull();
			}
			super.setNull(f);
			aiState=aiSpok=0;
			if (hp>maxhp/2) 
			{
				usil=false;
				currentWeapon.vis.visible=true;
				currentWeapon2.vis.visible=false;
			}
		}

		public override function save():Object
		{
			var obj:Object=super.save();
			if (obj==null) obj = {};
			obj.tr=tr;
			obj.weap=weap;
			return obj;
		}	
		
		public override function animate():void
		{
			thWeapon.vis.visible=false;
			//щит
			if (visshit && !visshit.visible && shithp>0) 
			{
				visshit.visible=true;
				visshit.gotoAndPlay(1);
			}
			if (visshit && visshit.visible && shithp<=0) 
			{
				visshit.visible=false;
				visshit.gotoAndStop(1);
				Emitter.emit('pole',room,X,Y-50,{kol:12,rx:100, ry:100});
			}
			if (sost==2) 
			{
				if (isrnd(0.3-timerDie/500)) 
				{
					Emitter.emit('expl',room,X+Math.random()*120-60,Y-Math.random()*120);
					newPart('metal');
					Snd.ps('expl_e');
				}
			}
		}
		
		public override function setVisPos():void
		{
			if (vis) 
			{
				if (sost==2) 
				{
					vis.x = X + (Math.random() - 0.5) * (150 - timerDie) / 15;
					vis.y = Y + (Math.random() - 0.5) * (150 - timerDie) / 15;
				} 
				else 
				{
					vis.x = X;
					vis.y = Y;
				}
				vis.scaleX=storona;
			}
		}
		
		public override function setWeaponPos(tip:int = 0):void
		{
			weaponX = vis.x;
			weaponY = vis.y - 110;
		}
		
		public function emit():void
		{
			var un:Unit=room.createUnit('vortex',X,Y-scY/2,true);
			un.fraction=fraction;
			un.oduplenie=0;
			emit_t=500;
			kol_emit--;
		}
		

		var emit_t:int=0;
		
		var movePoints:Array=[{x:10,y:7},{x:37,y:7},{x:24,y:13},{x:7,y:18},{x:40,y:18}];
		var mp=3;
		var moveX:Number=0, moveY:Number=0;
		var attState:int=0;
		var t_turn:int=15;
		var t_shit:int=300
		//aiState
		//0 - стоит на месте
		//1 - движется
		//2 - готовится выполнить действие
		//3 - выполняет действие
		
		public override function control():void
		{

			//GameSession.currentSession.gui.vis.vfc.text=(celUnit==null)?'no':(celUnit.objectName+celDY);
			//если сдох, то не двигаться
			if (sost == 3) return;
			if (sost == 2) 
			{
				dx = 0;
				dy = 0;
				return;
			}
			
			t_replic--;
			var jmp:Number=0;
			//return;
			
			if (room.gg.invulner) return;
			if (Settings.enemyAct <= 0) 
			{
				celY = Y - scY;
				celX = X + scX * storona * 2;
				return;
			}
			if (t_shit>0) t_shit--;
			vulner[Unit.D_EMP]=(shithp>0)?0.2:1;	//под считом неуязвимость к emp
			//таймер смены состояний
			if (aiTCh>0) aiTCh--;
			else {
				aiState++;
				if (aiState>3) {
					if (attState==4) aiState=2;
					else aiState=1;
				}
				if (aiState==1) {	//выбор точки перемещения
					var nmp=Math.floor(Math.random()*5);
					if (nmp==mp) nmp++;
					if (nmp>=5) nmp=0;
					mp=nmp;
					moveX = movePoints[mp].x*40+20;
					moveY = movePoints[mp].y*40+40;
					aiTCh=60;
					castShit();
				} else if (aiState==2) {
					aiTCh=30;
					if (attState!=4 && isrnd(0.33)) attState=4;
					else attState=Math.floor(Math.random()*2);
					if (Y<17*40 && celY>16*40 && isrnd(0.33)) {
						attState=2;
						aiTCh=5;
					}
					if (attState==4) aiTCh=15;
					if (attState==0) setCel(room.gg);
				} else if (aiState==3) {
					replic('attack');
					if (attState==0) aiTCh=80;
					else if (attState==2) aiTCh=120;
					else if (attState==4) aiTCh=60;
					else aiTCh=Math.floor(Math.random()*100)+150;
				}
			}
			//поиск цели
			//trace(aiState)
			if ((aiState==1 || aiState>1 && attState==1) && aiTCh%10==1) {
				setCel(room.gg);
			}
			celDX=celX-X;
			celDY=celY-Y;
			var dist2:Number=celDX*celDX+celDY*celDY;
			var dist:Number=(moveX-X)*(moveX-X)+(moveY-Y)*(moveY-Y);
			//поведение при различных состояниях
			if (aiState==0) {
				if (dx>0.5) storona=1; 
				if (dx<-0.5) storona=-1;
				walk=0;
			} else if (aiState==1) {
				spd.x=moveX-X;
				spd.y=moveY-Y;
				
				norma(spd,Math.min(accel,accel*dist/10000));
				dx+=spd.x;
				dy+=spd.y;
				if (dist<1000) {
					dx *= 0.8;
					dy *= 0.8;
				}
			}
			else if (aiState >= 2)
			{
				dx*=0.7;
				dy*=0.7;
			}
			if (aiState==2 && aiTCh%5==1)
			{
				if (attState==0) Emitter.emit('laser',room,celX+Math.random()*100-50,celY-Math.random()*50);
				if (attState==1) Emitter.emit('plasma',room,celX+Math.random()*50-25,celY-Math.random()*20);
				if (attState==4) Emitter.emit('spark',room,celX+Math.random()*100-50,celY-Math.random()*50);
			}
			if (aiState>0 && !(aiState==3 && attState==2))
			{
				aiNapr=(celX>X)?1:-1;
				if (storona!=aiNapr)
				{
					t_turn--;
					if (t_turn <= 0)
					{
						storona = aiNapr;
						t_turn = 15;
					}
				}
				else t_turn = 15;
			}
			attack();
			
			if (!usil && hp<maxhp/2) {
				usil=true;
				shithp=shitMaxHp*4;
				t_shit=2000;
				currentWeapon.vis.visible=false;
				currentWeapon2.vis.visible=true;
			}
		}
		
		public function castShit():void
		{
			if (shithp<=0 && t_shit<=0 && (GameSession.currentSession.game.globalDif==4 || GameSession.currentSession.game.globalDif==3 && hp<maxhp/2)) {
				shithp=shitMaxHp;
				t_shit=1000;
			}
		}
		
		public function attack():void
		{
			if (sost!=1) return;
			if (aiState==1 && celUnit) {	//атака холодным оружием без левитации или корпусом
				attKorp(celUnit,1);
			} else if (aiState==3) {							//пальба
				if (attState==0) dopWeapon.attack();
				else if (attState==1) {
					if (usil) currentWeapon2.attack();
					else currentWeapon.attack();
				} else if (attState==4) gasWeapon.attack();
				else {
					thWeapon.forceRot+=0.1;
					thWeapon.attack();
				}
				if ((dist2<100*100) && isrnd(0.1)) attKorp(celUnit,0.5);
			}
		}
		
		public override function command(com:String, val:String=null):void
		{
			if (com=='off') {
				walk=0;
				controlOn=false;
			} else if (com=='on') {
				controlOn=true;
			}
		}
		
	}
}
