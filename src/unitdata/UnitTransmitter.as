package unitdata 
{
	
	import weapondata.Weapon;
	import graphdata.Emitter;
	import locdata.Room;
	
	import components.Settings;
	
	import stubs.visualTransmitter;
	
	public class UnitTransmitter extends Unit
	{
		
		var cDam:Number;
		var dist:Number=1000, distdam:Number=400;
		var upKoef:Number=0;
		var prevKoef:Number=0;
		var cep:int=-1;

		public function UnitTransmitter(cid:String=null, ndif:Number=100, xml:XML=null, loadObj:Object=null) {
			super(cid, ndif, xml, loadObj);
			id='transmitter';
			vis=new visualTransmitter();
			vis.osn.gotoAndStop(1);
			getXmlParam();
			storona=1;
			if (cid=='box') cep=0;
			doop=true;		//не отслеживает цели
			aiState=1;
		}
		//поместить созданный юнит в локацию
		public override function putLoc(newRoom:Room, nx:Number, ny:Number)
		{
			if (cep<0 && newRoom.getAbsTile(nx, ny+10).phis==0) {
				if (newRoom.getAbsTile(nx, ny-50).phis) {
					cep=1;
					ny-=10;
					vis.osn.gotoAndStop(2);
					vis.osn.rotation=90;
					fixed=true;
				} else if (newRoom.getAbsTile(nx-40, ny-10).phis) {
					cep=2;
					nx-=(40-scX)/2-1;
					vis.osn.gotoAndStop(2);
					fixed=true;
				} else if (newRoom.getAbsTile(nx+40, ny-10).phis) {
					cep=3;
					nx+=(40-scX)/2-1;
					vis.osn.gotoAndStop(2);
					vis.osn.scaleX=-1;
					fixed=true;
				}
			}
			super.putLoc(newRoom, nx, ny);
		}

		public override function expl()
		{
			newPart('metal',4);
			//if (shum) shum.stop();
			//shum=null;
		}
		public override function setVisPos()
		{
			if (vis) {
				vis.x=X,vis.y=Y;
			}
		}
		
		public override function locout():void
		{
			super.locout();
			//if (shum) shum.stop();
			//shum=null;
			upKoef=0;
		}
		
		//состояния
		//0 - ничего не делает
		//1 - излучает
		
		public override function control()
		{
			if (sost>=3) return;
			if (Settings.enemyAct<=0) {
				return;
			}
			aiTCh++;
			if (aiState==1 && oduplenie<=0 && aiTCh%3==1 && room==World.world.gg.room) {
				upKoef+=0.05;
				if (rasst2<dist*dist) {
					rasst=Math.sqrt(rasst2);
					var rkoef=(dist-rasst)/dist;
					if (rkoef<0.5) rkoef*=2;
					else rkoef=1;
					if (rkoef>upKoef) rkoef=upKoef;
					if (room.roomActive) {
						Snd.pshum(sndRun,rkoef);
					}
					if (aiTCh%15==1) Emitter.emit('necronoise',room,X,Y-10,{alpha:rkoef});
					if (!World.world.gg.invulner && aiTCh%30==1) {
						if (rasst<distdam) {
							rkoef=(distdam-rasst)/distdam;
							if (rkoef<0.5) rkoef*=2;
							else rkoef=1;
							World.world.gg.damage(dam*rkoef,tipDamage,null,false);
						}
					}
				}
			} else {
			}
		}
	}
	
}
