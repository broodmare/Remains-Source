package servdata 
{
    import locdata.Quest;
    import components.XmlBook;
    import components.Settings;

    public class QuestHelper
    {
        private static var quests:Array = GameSession.currentSession.game.quests;

        public static function addQuest(id:String, loadObj:Object=null, noVis:Boolean = false, snd:Boolean = true, showDial:Boolean = true):Quest 
		{
			if (quests[id]) // Check if the quest exists
			{
				
				if (quests[id].state == 0) // If it is not active, make it active
				{
					quests[id].state = 1;
					GameSession.currentSession.gui.infoText('addTask',quests[id].objectName);
					Snd.ps('quest');
					quests[id].isClosed(); // Check stages, if all are completed, close it immediately
					quests[id].deposit();
					if (quests[id].state == 2) GameSession.currentSession.gui.infoText('doneTask',quests[id].objectName);
				}
				return quests[id];
			}
			var xlq:XMLList = XmlBook.getXML("quests").quest.(@id == id);
			if (xlq.length() == 0) 
			{
				trace ('Quest not found', id);
				return null;
			}
			var xq:XML = xlq[0];
			var q:Quest = new Quest(xq, loadObj);
			quests[q.id] = q;
			if (noVis && !q.auto) q.state = 0;
			if (loadObj == null && q.state > 0) 
			{
				GameSession.currentSession.gui.infoText('addTask', q.objectName);
				quests[id].deposit();
				if (snd) Snd.ps('quest');
			}
			if (loadObj == null && showDial && q.begDial && Settings.dialOn && GameSession.currentSession.room.prob == null) 
			{
				GameSession.currentSession.pip.onoff(-1);
				GameSession.currentSession.gui.dialog(q.begDial);
			}
			return q;
		}
		
		public static function showQuest(id:String, sid:String):void
		{
			var q:Quest = quests[id];
			if (q == null) 
			{
				q = addQuest(id, null, true);
			}
			if (q == null || q.state == 2) 
			{
				return;
			}
			q.showSub(sid);

			for each (var q1 in q.subs) 
			{
				if (q1.id == sid) 
				{
					GameSession.currentSession.gui.infoText('addTask2', q1.objectName);
					Snd.ps('quest');
					break;
				}
			}
		}
		
		public static function closeQuest(id:String, sid:String = null):void
		{
			var q:Quest = quests[id];
			
			if (q == null) q = addQuest(id, null, true); // If the quest stage is completed, but the quest is not taken, add it as inactive

			if (q == null || q.state == 2) return;

			if (sid == null || sid == '' || int(sid) < 0) q.close();
			else q.closeSub(sid);
		}
		
		public static function checkQuests(cid:String):String 
		{
			var res2, res:String;
			for each(var q:Quest in quests) 
			{
				if (q.state == 1 && q.isCheck) 
				{
					res = q.check(cid);
					if (res != null) res2 = res;
				}
			}
			return res2;
		}

		public static function incQuests(cid:String, kol:int = 1):void
		{
			for each(var q:Quest in quests) 
			{
				if (q.state == 1 && q.isCheck) 
				{
					q.inc(cid, kol);
					q.check(cid);
				}
			}
		}
    } 
}