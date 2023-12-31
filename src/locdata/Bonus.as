package locdata 
{
	import stubs.visualBonus;
	import stubs.visualHealBonus;

	//Бонусы, которые подбираются путём контакта с ними
	
	public class Bonus extends Obj
	{
		public var sost:int = 1; 	//состояние 0-неактивен, 1-активен, 2-взят
		public var id:String = '';
		public var val:Number = 100;
		public var liv:int = 1000000;

		public function Bonus(newRoom:Room, nid:String, nx:int = 0, ny:int = 0, xml:XML = null, loadObj:Object = null)
		{
			room = newRoom;
			id = nid;
			X = nx;
			Y = ny;
			setSize();
			if (loadObj) 
			{
				sost = loadObj.sost;
			}
			levitPoss = false;
			layer = 3;
			if (sost == 1) 
			{
				if (id == 'heal') vis = new visualHealBonus();
				else vis = new visualBonus();
			}
			if (vis) 
			{
				vis.bonus.cacheAsBitmap = true;
				vis.x = X
				vis.y = Y;
			}
		}
		
		public function setSize():void
		{
			scX = 40;
			scY = 40;
			X1 = X - scX / 2;
			X2 = X + scX / 2;
			Y1 = Y - scY / 2;
			Y2 = Y + scY / 2;
		}
		
		public override function save():Object 
		{
			var obj:Object = {};
			obj.sost = sost;
			return obj;
		}
		
		public override function step():void
		{
			if (liv < 1000000) 
			{
				liv--;
				if (!room.roomActive || liv == 0) 
				{
					liv = 0;
					sost = 2;
					vis.gotoAndPlay(22);
				}
			}
			if (liv < -25) room.remObj(this);
			if (sost != 1 || !room.roomActive) return;
			if (areaTest(room.gg)) take();
		}
		
		public function take():void
		{
			sost = 2;
			liv = 0;
			vis.gotoAndPlay(2);
			if (id == 'xp') 
			{
				room.kolXp--;
				if (room.kolXp == 0 && room.maxXp > 1)  //собрали все бонусы
				{	
					GameSession.currentSession.pers.expa(room.unXp * room.maxXp);
					if (!room.detecting && room.summXp>0) 
					{
						room.takeXP(room.summXp, GameSession.currentSession.gg.X, GameSession.currentSession.gg.Y - 100, true);
						GameSession.currentSession.gui.infoText('sneakBonus');
					}
					Snd.ps('bonus2');
				} 
				else 
				{
					GameSession.currentSession.pers.expa(room.unXp);
					Snd.ps('bonus1');
				}
				
			}
			if (id == 'heal') 
			{
				GameSession.currentSession.gg.heal(val);
				Snd.ps('bonus1');
			}
		}
		
	}
	
}
