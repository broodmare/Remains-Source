package unitdata
{
	
	import weapondata.Weapon;
	import weapondata.Bullet;
	
	import stubs.visualTTurret;
	
	public class UnitThunderTurret extends Unit
	{
		
		public var head:UnitThunderHead;
		var bindX:Number=0, bindY:Number=0;
		public var tr:int;
		
		var attTurN:int=15;
		var t_wait:int=0;

		public function UnitThunderTurret(cid:String=null, ndif:Number=100, xml:XML=null, loadObj:Object=null) 
		{
			super(cid, ndif, xml, loadObj);
			id='ttur';
			tr=int(cid);
			getXmlParam();
			vis=new visualTTurret();
			vis.osn.scaleX=vis.osn.scaleY=3;
			vis.osn.pole.visible=false;
			mater=false;
			mat=1;
			fixed=true;
			objectName='';
			friendlyExpl=0;
			currentWeapon=new Weapon(this,'ttweap'+tr);
			childObjs=new Array(currentWeapon);
			t_wait=Math.round(Math.random()*100);
		}
		
		public function mega():void
		{
			vis.osn.pole.visible=true;
			invulner=true;
			hp=maxhp=maxhp*10;
		}
		
		public override function run(div:int=1):void
		{
			if (head) 
			{
				X=head.X+bindX;
				Y=head.Y+bindY;
			}
			Y1=Y-scY;
			Y2=Y;
			X1=X-scX/2;
			X2=X+scX/2;
			setVisPos();
		}
		
		public override function control():void
		{
			if (head==null || room==null) return;
			if (sost>1 || head.sost>1) return;
			if (head.isAtt && X>200 && Y>200 && X<room.roomPixelWidth-200 && Y<room.roomPixelHeight-200) {
				if (t_wait>0) {
					t_wait--;
					return;
				}
				currentWeapon.reloadMult=1/head.reloadDiv;
					//setCel(null, GameSession.currentSession.gg.X+Math.random()*500-250, GameSession.currentSession.gg.Y+Math.random()*400-200);
				setCel(GameSession.currentSession.gg);
				storona=(celDX>0)?1:-1;
				//if (head.attTur<=0) 
					currentWeapon.attack();
				if (isShoot) {
					head.attTur=attTurN;
					isShoot=false;
				}
			}
		}
		
		public override function setLevel(nlevel:int=0):void
		{
			if (GameSession.currentSession.game.globalDif==3) 
			{
				hp=maxhp=hp*1.5;
			}
			if (GameSession.currentSession.game.globalDif==4) 
			{
				hp=maxhp=hp*2;
			}
		}
		
		public override function expl():void
		{
			head.dieTurret();
			newPart('metal',4);
			newPart('expl');
		}
		public override function animate():void
		{
			if (sost>1) return;
			try 
			{

			} 
			catch(err) 
			{

			}
		}

		public override function setVisPos():void
		{
			if (vis) {
				vis.x=X;
				vis.y=Y;
				currentWeapon.vis.x=X;
				currentWeapon.vis.y=Y-scY/2;
			}
		}
		public override function makeNoise(n:int, hlup:Boolean=false):void
		{

		}
		public override function setHpbarPos():void
		{
			hpbar.y=Y-140;
			hpbar.x=X;
			if (room && room.zoom!=1) hpbar.scaleX=hpbar.scaleY=room.zoom;
		}
	}
	
}
