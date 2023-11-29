package locdata 
{
	
	import unitdata.Pers;
	import servdata.Vendor;
	import servdata.Script;
	import servdata.NPC;
	
	import components.Settings;
	import components.XmlBook;

	//TODO - Calling entire script file multiple times, fix that later.
	public class Game 
	{
		
		public var levelArray:Array;
		public var probs:Array;
		public var vendors:Array;
		public var npcs:Array;
		public var curLevelID:String = '';
		public var curCoord:String = null;
		public var curLevel:LevelTemplate;
		public var triggers:Array;
		public var notes:Array;
		public var limits:Array;
		public var quests:Array;
		public var names:Array;
		
		// Game Time
		public var dBeg:Date;					// Start time of the game
		public var t_proshlo:Number;			// Current session time
		public var t_save:Number 		= 0;	// Saved time
		
		public var globalDif:int 		= 2;	// Global difficulty level
		public var baseId:String 		= '';	// Area to which the return occurs
		public var missionId:String 	= '';
		public var crea:Boolean 		= false;
		public var mReturn:Boolean 		= true;	// Can return to the base camp
		
		var objs:Array;
		

		public function Game() 
		{
			trace('Game.as/Game() - Running Game constructor.');
			levelArray  = [];
			probs 		= [];
			notes 		= [];
			vendors 	= [];
			npcs 		= [];
			triggers 	= [];
			limits 		= [];
			quests 		= [];
			names 		= [];
			
			for each (var xl in XmlBook.getXML("levels").level)
			{
				var level:LevelTemplate = new LevelTemplate(xl);
				if (World.world.allLevelsArray[xl.@id] && World.world.allLevelsArray[xl.@id].allroom) 
				{
					level.allroom = World.world.allLevelsArray[xl.@id].allroom;
					level.loaded = true;
				}
				if (level.prob == 0) levelArray[level.id] = level;
				else probs[level.id] = level;
			}
		}

		public function save():Object 
		{
			var obj:Object = {};

			obj.dif = globalDif;
			obj.level = curLevelID;
			World.world.level.saveObjs(objs);	//Save an array of objects with IDs
			
			obj.objs = [];
			for (var uid in objs) 
			{
				var obj1 = objs[uid];
				var nobj = {};
				for (var n in obj1) 
				{
					nobj[n] = obj1[n];
				}
				obj.objs[uid]=nobj;
			}
			
			obj.vendors = [];
			for (var i in vendors) 
			{
				var v = vendors[i].save();
				if (v != null) obj.vendors[i] = v;
			}

			obj.npcs = [];
			for (i in npcs) 
			{
				var npc=npcs[i].save();
				if (npc!=null) obj.npcs[i]=npc;
			}

			obj.triggers = [];
			for (i in triggers) 
			{
				obj.triggers[i]=triggers[i];
			}

			obj.notes = [];
			for (i in notes) 
			{
				obj.notes[i]=notes[i];
			}

			obj.quests = [];
			for (i in quests) 
			{
				var q:Object=quests[i].save();
				if (q!=null) obj.quests[i]=q;
			}

			obj.levelArray = [];
			for (var i in levelArray) 
			{
				var l = levelArray[i].save();
				if (l != null) obj.levelArray[i] = l;
			}

			var dNow:Date = new Date();
			t_proshlo = dNow.getTime() - dBeg.getTime();
			obj.t_save = t_save+t_proshlo;

			return obj;
		}
		
		public function init(loadObj:Object = null, opt:Object = null)
		{
			if (loadObj) 
			{
				if (loadObj.dif != null) globalDif = loadObj.dif;
				else globalDif = 2;
				if (loadObj.t_save) t_save=loadObj.t_save;
			} 
			else 
			{
				if (opt && opt.dif != null) globalDif = opt.dif;
				else globalDif = 2;
				triggers['noreturn'] = 1;
			}
			objs = [];
			if (loadObj && loadObj.objs) 
			{
				for (var uid in loadObj.objs) 
				{
					var obj = loadObj.objs[uid];
					var nobj = {};
					for (var n in obj) 
					{
						nobj[n] = obj[n];
					}
					objs[uid] = nobj;
				}
				
			}
			for each(var xl in XmlBook.getXML("vendors").vendor) 
			{
				var loadVendor = null;
				if (loadObj && loadObj.vendors && loadObj.vendors[xl.@id]) loadVendor = loadObj.vendors[xl.@id];
				var v:Vendor = new Vendor(0, xl, loadVendor);
				vendors[v.id] = v;
			}
			for each(var xl in XmlBook.getXML("npcs").npc) 
			{
				var loadNPC = null;
				if (loadObj && loadObj.npcs && loadObj.npcs[xl.@id]) loadNPC = loadObj.npcs[xl.@id];
				var npc:NPC = new NPC(xl, loadNPC);
				npcs[npc.id] = npc;
			}
			if (loadObj) 
			{
				for (var i in loadObj.triggers) 
				{
					triggers[i] = loadObj.triggers[i];
				}
				for (var i in loadObj.notes) 
				{
					notes[i] = loadObj.notes[i];
				}
				for (var i in loadObj.quests) 
				{
					addQuest(i, loadObj.quests[i]);
				}
				for (var i in loadObj.levelArray)  //!!!!!
				{
					if (levelArray[i]) levelArray[i].load(loadObj.levelArray[i]);
				}
				if (triggers['noreturn'] > 0) mReturn = false; else mReturn = true;
			}
			baseId = curLevelID = 'rbl';
			if (loadObj) 
			{
				curLevelID = loadObj.level;
				if (curLevelID != 'rbl') missionId = loadObj.level;
			} 
			else if (opt && opt.skipTraining) 	// Skip training
			{		
				triggers['dial_dialCalam2'] = 1;
			} 
			else 									// Do not skip training
			{									
				curLevelID = 'begin';
			}
			for each(var q in quests) 
			{
				if (q != null && q.state == 2 && q.xml.next.length()) 
				{
					for each (var nq in q.xml.next) addQuest(nq.@id);
				}
			}

			if (levelArray[curLevelID] == null || levelArray[curLevelID].rnd) curLevelID = 'rbl';
			addNote('helpControl');
			addNote('helpGl1');
			addNote('helpGl2');
			dBeg = new Date();
			if (loadObj == null) triggers['nomed'] = 1;
		}
		
		public function changeDif(ndif):Boolean
		{
			if (ndif == globalDif) return false;
			globalDif=ndif;
			if (globalDif < 0) globalDif = 0;
			if (globalDif > 4) globalDif = 4;
			World.world.pers.setGlobalDif(globalDif);
			World.world.pers.setParameters();
			return true;
		}
		
		public function enterCurrentLevel():void
		{
			Level.locN += 5;
			if (World.world.level && objs) World.world.level.saveObjs(objs);

			///Check if the game should transition to a random encounter
			Encounter();

			curLevel = levelArray[curLevelID];
			if (curLevel == null) curLevel = levelArray['rbl'];
			var first:Boolean = false;
			if (!curLevel.rnd && !curLevel.visited) first = true;

			if (curLevel.level == null || crea) 
			{
				var n:int = 0;
				if (triggers['firstroom'] > 0) 
				{
					n = 1;
					if (World.world.pers.level > 1) n = World.world.pers.level - 1;
				}
				curLevel.level = new Level(World.world.gg, curLevel, n);
			}
			if (!first) triggers['firstroom'] = 1;
			crea = false;
			World.world.activateLevel(curLevel.level);
			World.world.level.enterLevel(first, curCoord);
			curCoord = null;

			if (curLevel.id == 'rbl') 
			{
				triggers['noreturn'] 	= 0;
				triggers['nomed'] 		= 0;
				triggers['rbl_visited'] = 1;
			} 
			else 
			{
				if (curLevel.tip != 'base') 
				{
					missionId = curLevel.id;
					trace(curLevel.tip == 'base')
				}
			}
			World.world.gg.remEffect('potion_fly');
			World.world.gui.messText('', Res.txt('m', curLevel.id) + (curLevel.rnd?(' - ' + (curLevel.landStage + 1)):''), World.world.gg.Y < 300);
			if (!curLevel.rnd) curLevel.visited=true;
			mReturn = (triggers['noreturn'] <= 0);
			if (curLevel.upStage) 
			{
				curLevel.upStage = false;
			}
		}
		
		// Redirect to another room
		public function Encounter():void
		{
			trace('');

			switch(curLevelID)
			{
				case 'random_canter':
					if (!(triggers['encounter_way'] > 0)) curLevelID = 'way';
					break;

				case 'random_encl':
					if (!(triggers['encounter_post'] > 0)) curLevelID = 'post';
					break;

				case 'stable_pi':
					if (triggers['storm'] == 4) 
						curLevelID = 'stable_pi_atk';
					else if (triggers['storm'] == 5) 
						curLevelID = 'stable_pi_surf';
					break;

				default:
					trace('Game.as/Encounter() - curLevelID: "' + curLevelID + '" is not an encounter, returning.');
					break;
			}
}
		
		/*Transition to a new room
			gotoLevel(newLand:String)
			World.world.exitLevel();
			enterCurrentLevel();
			World.world.activateLevel(curLevel.level);
			World.world.level.enterLevel(first);
			activateRoom();
		*/
		
		public function gotoLevel(newLevel:String, coord:String = null, fast:Boolean = false)
		{
			trace('Game.as/gotoLevel() - Moving to a new level: "' + newLevel + '."');

			if (newLevel != baseId && !World.world.pers.dopusk()) 
			{
				World.world.gui.messText('nocont');
			} 
			else if (newLevel != baseId && World.world.pers.speedShtr >= 3) 
			{
				World.world.gui.messText('nocont2');
			} 
			else 
			{
				curLevelID = newLevel;
				curCoord = coord;
				World.world.exitLevel(fast);
			}
		}
		
		public function beginGame():void
		{

		}
		
		public function beginMission(nid:String = null):void
		{
			if (nid == curLevelID) return;
			if (nid && levelArray[nid]) 
			{
				if (levelArray[nid].tip != 'base') 
				{
					missionId = nid;
					crea = true;
				}
			}
			gotoLevel(nid);
		}
		
		public function gotoNextLevel():void
		{
			trace('Game.as/gotoNextLevel() - Moving to a next level: "' + missionId + '."');
			World.world.pers.prevCPCode 	= null;
			World.world.pers.currentCPCode 	= null;
			curLevel.level.currentCP 		= null;
			crea = true;
			curLevel.level.refill();
			gotoLevel(missionId);
		}
		
		public function upLandLevel():void
		{
			if (!curLevel.upStage) curLevel.landStage++;
			curLevel.upStage = true;
		}
		
		// Check the possibility of traveling through the map
		public function checkTravel(lid):Boolean 
		{
			// Check based on curLevelID
			if (this.curLevelID == 'grave') return false;

			// Use a switch statement for different values of triggers['fin']
			switch(triggers['fin'])
			{
				case 0:
					return true;
				case 1:
					return levelArray[lid].fin == 0 || levelArray[lid].fin == 1;
				case 2:
					return levelArray[lid].fin == 0 || levelArray[lid].fin == 2;
				case 3:
					return levelArray[lid].fin == 2;
				default:
					return true;
			}
		}
		
		public function refillVendors():void
		{
			for each(var vend:Vendor in vendors) vend.refill();
			for (var tr in triggers) 
			{
				if (triggers[tr] == 'wait') triggers[tr] = 1;
			}
			World.world.invent.good.kol = World.world.pers.goodHp;
			World.world.gui.infoText('refill');
		}
		
		public function addQuest(id:String, loadObj:Object=null, noVis:Boolean=false, snd:Boolean=true, showDial:Boolean=true):Quest 
		{
			// Check if the quest exists, if so...
			if (quests[id]) 
			{
				// If it is not active, make it active
				if (quests[id].state==0) 
				{
					quests[id].state=1;
					World.world.gui.infoText('addTask',quests[id].objectName);
					Snd.ps('quest');
					// Check stages, if all are completed, close it immediately
					quests[id].isClosed();
					quests[id].deposit();
					if (quests[id].state==2) World.world.gui.infoText('doneTask',quests[id].objectName);
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
				World.world.gui.infoText('addTask', q.objectName);
				quests[id].deposit();
				if (snd) Snd.ps('quest');
			}
			if (loadObj == null && showDial && q.begDial && Settings.dialOn && World.world.room.prob == null) 
			{
				World.world.pip.onoff(-1);
				World.world.gui.dialog(q.begDial);
			}
			return q;
		}
		
		public function showQuest(id:String, sid:String):void
		{
			var q:Quest = quests[id];
			if (q == null) 
			{
				q=addQuest(id, null, true);
			}
			if (q == null || q.state == 2) 
			{
				return;
			}
			q.showSub(sid);
			try 
			{
				for each (var q1 in q.subs) 
				{
					if (q1.id == sid) 
					{
						World.world.gui.infoText('addTask2', q1.objectName);
						Snd.ps('quest');
						break;
					}
				}
			} 
			catch(err) 
			{

			}
		}
		
		public function closeQuest(id:String, sid:String=null):void
		{
			var q:Quest=quests[id];
			// If the quest stage is completed, but the quest is not taken, add it as inactive
			if (q == null) 
			{
				q = addQuest(id, null, true);
			}
			if (q == null || q.state == 2) 
			{
				return;
			}
			if (sid == null || sid == '' || int(sid) < 0) 
			{
				q.close();
			} 
			else 
			{
				q.closeSub(sid);
			}
		}
		
		public function checkQuests(cid:String):String 
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

		public function incQuests(cid:String, kol:int = 1):void
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
		
		public function addNote(id:String):void
		{
			if (triggers['note_' + id]) return;
			triggers['note_' + id] = 1;
			notes.push(id);
		}
		
		public function setTrigger(id:String, n:int = 1):void
		{
			triggers[id] = n;
		}
		
		// Determine how many items were generated
		public function getLimit(id:String):int 
		{
			if (limits[id]) return limits[id];
			if (triggers[id]) 
			{
				limits[id] = triggers[id];
				return limits[id];
			}
			limits[id] = 0;
			return 0;
		}
		
		// Increase the limit by 1, stage=1 - during generation, stage=2 - when taken
		public function addLimit(id:String, etap:int):void
		{
			if (etap == 1) 
			{
				if (limits[id]) limits[id]++;
				else limits[id] = 1;
			}
			if (etap == 2) 
			{
				if (triggers[id]) triggers[id]++;
				else triggers[id] = 1;
			}
		}
		
		public function runScript(scr:String, own:Obj = null):Boolean 
		{
			// Retrieve the entire XML file for scripts
			var scriptsXML:XML = XmlBook.getXML("scripts");

			// Navigate to the correct XMLList of script elements and filter by ID
			var xmlList:XMLList = scriptsXML.scr.(@id == scr);

			if (xmlList.length()) 
			{
				var scriptXML:XML = xmlList[0];
				var runScr:Script = new Script(scriptXML, World.world.level, own);
				runScr.start();
				return true;
			}
			return false;
		}
		
		// Create a script from gamedata
		public function getScript(scr:String, own:Obj = null):Script 
		{

			// Retrieve the entire XML file for scripts
    		var scriptsXML:XML = XmlBook.getXML("scripts");

			// Navigate to the correct XMLList of script elements and filter by ID
    		var xmlList:XMLList = scriptsXML.scr.(@id == scr);

			//If a script is found by that name, do stuff, otherwise return null.
			if (xmlList.length()) 
			{
				var scriptXML:XML = xmlList[0];
				return new Script(scriptXML, (own == null) ? World.world.level : own.room.level, own);
			}
			return null;
		}
		
		// String representation of game time
		public function gameTime(n:Number=0):String 
		{
			if (n == 0) 
			{
				var dNow:Date = new Date();
				t_proshlo = dNow.getTime() - dBeg.getTime();
				n = t_save + t_proshlo;
			}
			return Res.gameTime(n);
		}
		
	}
	
}
