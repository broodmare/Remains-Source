package unitdata 
{
	
	import weapondata.Bullet;
	import graphdata.Emitter;
	import locdata.Tile;
	
	import components.Settings;
	
	public class UnitNecros extends Unit{
		
		var spd:Object;
		var br:Number=0;

		public function UnitNecros(cid:String=null, ndif:Number=100, xml:XML=null, loadObj:Object=null) {
			super(cid, ndif, xml, loadObj);
			id='necros';
			getXmlParam();
			walkSpeed=maxSpeed;
			runSpeed=maxSpeed*2;
			initBlit();
			isFly=true;
			spd={x:0, y:0};
			destroy=20;
			knocked=0;
			undodge=1;
			doop=true;		//не отслеживает цели
			collisionTip=0;
			transp=true;
			mater=false;
			ctrans=false;
			grav=0;
			vulner[D_NECRO]=0;
		}

		public override function forces():void
		{
			if (isFly) {
				if (dx*dx+dy*dy>maxSpeed*maxSpeed || rasst2<100*100) {
					dx*=0.8;
					dy*=0.8;
				}
				if (aiState!=1) {
					dx*=0.8;
					dy*=0.8;
				}
			} else super.forces();
		}
		
		public override function expl()
		{
			newPart('black',24);
			isFly=true;
		}
		
		public override function animate():void
		{
			vis.scaleX=1;
			blit(anims[animState].id,Math.floor(anims[animState].f));
			anims['stay'].step();
		}
		
		//состояния
		//0 - ничего не делает
		//1 - летит к цели
		
		public override function control():void
		{
			if (sost>=3) return;
			if (Settings.enemyAct<=0) {
				return;
			}
			if (aiTCh>0) aiTCh--;		//счётчик смены состояний
			else {						//смена состояний
				if (aiSpok==0) {	//перейти в пассивный режим
					aiState=0;
				} else if (aiSpok>=maxSpok) {	//агрессивный
					aiState=1;
				} else {
					aiState=2;
				}
				aiTCh=Math.floor(Math.random()*100)+100;
				if (aiState==0) {		//выбрать случайную цель в пассивном режиме
					if (aiTip!='stay' && isrnd()) {
						celX=X+(Math.random()*300+400)*(isrnd()?1:-1);
						if (celX<0) celX=200;
						if (celX>room.roomPixelWidth) celX=room.roomPixelWidth-200;
						celY=Y+Math.random()*200-100;
						if (celY<0) celX=200;
						if (celY>room.roomPixelHeight) celY=room.roomPixelHeight-200;
					} else {
						celX=X, celY=Y-scY/2;
					}
				}
			}
			//поиск цели
			if (Settings.enemyAct>1 && aiTCh%10==1) {
				if (findCel()) {
					aiSpok=maxSpok+10;
					aiState=1;
					storona=(celX>X)?1:-1;
				} else {
					if (aiSpok>0) aiSpok--;
				}
				spd.x=celX-X;
				spd.y=celY-(Y-scY/2);
				norma(spd,aiState==0?accel/2:accel);
			}
			dx+=spd.x;
			dy+=spd.y;
			
			if (aiState==0) maxSpeed=walkSpeed;
			else maxSpeed=runSpeed;
	
			//атака
			if (Settings.enemyAct>=3 && aiState==1 && celUnit && celUnit.sost==1) {
				attKorp(celUnit,1);
			}
		}
	}
	
}
