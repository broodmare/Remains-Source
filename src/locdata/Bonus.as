package locdata 
{

	import servdata.Script;
	import graphdata.Emitter;
	import unitdata.Unit;
	
	//Бонусы, которые подбираются путём контакта с ними
	
	public class Bonus extends Obj
	{
		
		public var sost:int=1; 	//состояние 0-неактивен, 1-активен, 2-взят
		public var id:String='';
		public var val:Number=100;
		public var liv:int=1000000;

		public function Bonus(nloc:Location, nid:String, nx:int=0, ny:int=0, xml:XML=null, loadObj:Object=null) {
			location=nloc;
			id=nid;
			X=nx;
			Y=ny;
			setSize();
			if (loadObj) 
			{
				sost=loadObj.sost;
			}
			levitPoss=false;
			layer=3;
			if (sost==1) 
			{
				if (id=='heal') vis=new visualHealBonus();
				else vis=new visualBonus();
			}
			if (vis) 
			{
				vis.bonus.cacheAsBitmap=true;
				vis.x=X, vis.y=Y;
			}
		}
		
		function setSize() 
		{
			scX=scY=40;
			X1=X-scX/2;
			X2=X+scX/2;
			Y1=Y-scY/2;
			Y2=Y+scY/2;
		}
		
		public override function save():Object 
		{
			var obj:Object=new Object();
			obj.sost=sost;
			return obj;
		}
		
		public override function step() 
		{
			if (liv<1000000) 
			{
				liv--;
				if (!location.locationActive || liv==0) 
				{
					liv=0;
					sost=2;
					vis.gotoAndPlay(22);
				}
			}
			if (liv<-25) location.remObj(this);
			if (sost!=1 || !location.locationActive) return;
			if (areaTest(location.gg)) take();
		}
		
		public function take() 
		{
			sost=2;
			liv=0;
			vis.gotoAndPlay(2);
			if (id=='xp') 
			{
				location.kolXp--;
				if (location.kolXp==0 && location.maxXp>1)  //собрали все бонусы
				{	
					World.world.pers.expa(location.unXp*location.maxXp);
					if (!location.detecting && location.summXp>0) 
					{
						location.takeXP(location.summXp,World.world.gg.X, World.world.gg.Y-100,true);
						World.world.gui.infoText('sneakBonus');
					}
					Snd.ps('bonus2');
				} 
				else 
				{
					World.world.pers.expa(location.unXp);
					Snd.ps('bonus1');
				}
				
			}
			if (id=='heal') 
			{
				World.world.gg.heal(val);
				Snd.ps('bonus1');
			}
		}
		
	}
	
}
