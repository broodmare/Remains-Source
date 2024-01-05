package locdata 
{
	import flash.display.BitmapData;

	import servdata.Script;
	import unitdata.UnitPlayer;
	import unitdata.Pers;
	
	import components.Settings;
	import components.XmlBook;
	
	public class Level 
	{
		public var levelTemplate:LevelTemplate;		//Which template the level was created with
		
		public var rnd:Boolean = false;			//true if the terrain has random generation
		public var room:Room;					//current room
		private var prevloc:Room;				//previously visited room
		public var roomArray:Array;				//three-dimensional map of all locations
		public var probs:Array;					//trial locations
		public var listLocs:Array;				//linear array of locations
		public var locX:int = 0;
		public var locY:int = 0;
		public var locZ:int = 0;				//coordinates of the active room
		public var retLocX:int = 0;				//room coordinates for returning to the main layer
		public var retLocY:int = 0;				//room coordinates for returning to the main layer
		public var retLocZ:int = 0;				//room coordinates for returning to the main layer
		public var retX:Number = 0;				//player coordinates for returning to the main layer
		public var retY:Number = 0;				//player coordinates for returning to the main layer
		public var prob:String = '';			//trial layer, ''-main layer
		public var minLocX:int = 0;
		public var minLocY:int = 0;
		public var minLocZ:int = 0;				//Level size
		public var maxLocX:int = 4;
		public var maxLocY:int = 6;
		public var maxLocZ:int = 2;				//Level size
		
		public var loc_t:int = 0;				//timer
		static var locN:int = 0;				//transition counter
		
		public var gg:UnitPlayer;
		public var ggX:Number=0;				//X coordinate of the player in the level
		public var ggY:Number=0;				//Y coordinate of the player in the level
		public var currentCP:CheckPoint;
		public var art_t:int=200;				// ???
		
		public var map:BitmapData;				//Level map
		
		public var levelDifficultyLevel:Number = 0;		//overall difficulty, depends on player level or map settings
		public var gameStage:int = 0;			//game story stage, affects loot drops, if 0, then no restrictions
		public var lootLimit:Number = 0;		//limit of special item drops
		public var allXp:int = 0;
		public var summXp:int = 0;
		public var isRefill:Boolean = false;	//goods have been replenished
		
		var allRoom:Array;						//array of all rooms taken from xml
		var rndRoom:Array;						//array used for random generation

		public var kolAll:Array;				//number of each type of object
		
		public var uidObjs:Array;				//all objects with uid
		public var scripts:Array;				//array of scripts with execution time
		public var itemScripts:Array;			//array of scripts linked to item pickups
		
		public var kol_phoenix:int = 0;
		public var aliAlarm:Boolean = false;	//alarm among alicorns
		
		public var probIds:Array;				//available trial rooms
		var impProb:int = -1;					//important trial room


		
		public function Level(ngg:UnitPlayer, lt:LevelTemplate, lvl:int) //lvl - character level - 1
		{
			trace('Level.as/Level() - Initializing level.')
			gg = ngg;
			levelTemplate = lt;
			rnd = levelTemplate.rnd;

			uidObjs  = [];
			scripts  = [];
			kolAll 	 = [];
			listLocs = [];
			probIds  = [];
			probs 	 = [];
			
			prepareRooms();

			if (rnd) 
			{
				levelDifficultyLevel = lvl;	//difficulty is determined by the given parameter
				if (levelDifficultyLevel < levelTemplate.dif) levelDifficultyLevel = levelTemplate.dif;	//if the difficulty is less than the minimum, set it to the minimum
				maxLocX = levelTemplate.mLocX;	//dimensions are taken from the level settings
				maxLocY = levelTemplate.mLocY;
				buildRandomLevel();
			} 
			else 
			{
				levelDifficultyLevel = levelTemplate.dif;	//difficulty is taken from the level settings
				if (levelTemplate.autoLevel) levelDifficultyLevel = lvl;
				maxLocX = 1;	//dimensions are determined according to the map
				maxLocY = 1;	//dimensions are determined according to the map
				buildSpecifLevel();
			}

			lootLimit = lvl + 3;
			gameStage = levelTemplate.gameStage;	//story stage is taken from the level settings
			itemScripts = []; //attached scripts

			for each(var xl in levelTemplate.levelData.scr) 
			{
				if (xl.@eve == 'take' && xl.@item.length()) 
				{
					var scr:Script = new Script(xl, this);
					itemScripts[xl.@item] = scr;
				}
			}
			createMap();
		}
		
//==============================================================================================================================		
//				*** Creation  ***
//==============================================================================================================================		
		
		//Convert from XML to array
		public function prepareRooms():void
		{
			trace('Level.as/prepareRooms() - Loading all rooms from the level template into the allRoom array.');
			allRoom = [];
			var roomsFound:int = 0;

			for each(var roomNode in levelTemplate.allroom.room) 
			{
				allRoom.push(new RoomTemplate(roomNode));
				roomsFound++;
			}

			trace('Level.as/prepareRooms() - Rooms added to allRoom: "' + roomsFound + '".');
		}
		
		public function buildRandomLevel():void
		{
			roomArray = [];
			
			if (levelTemplate.conf == 0 && levelTemplate.landStage <= 0) maxLocY = 3;
			var loc1:Room;
			var loc2:Room;
			var opt:Object = {};

			for (var i:int = minLocX; i < maxLocX; i++) 
			{
				roomArray[i] = [];
				for (var j:int = minLocY; j<maxLocY; j++) 
				{
					opt.mirror = (Math.random() < 0.5);
					opt.water = null;
					opt.ramka = null;
					opt.backform = 0;
					opt.transparentBackground = false;
					
					if (levelTemplate.conf == 2) //Flooded rooms
					{
						if (j == 1) opt.water = 17;
						if (j > 1) opt.water = 0;
					}
					if (levelTemplate.conf==5) 
					{
						if (j == 2) opt.water = 21;
						if (j > 2) opt.water = 0;
					}
					
					if (levelTemplate.conf == 3) //buildings
					{
						
					}

					roomArray[i][j] = [];
					
					if (levelTemplate.conf == 0 && j == 0 && !levelTemplate.visited) //initial rooms
					{ 
						opt.mirror = false;
						loc1 = newTipLoc('beg' + i, i, j, opt);	
					} 
					else if ((levelTemplate.conf == 2 || levelTemplate.conf == 1 || levelTemplate.conf == 5) && j == 0 && i == 0 && !levelTemplate.visited) //initial rooms
					{ 
						opt.mirror = false;
						if (levelTemplate.conf == 5) 
						{
							opt.ramka = 3;
							opt.backform = 3;
							opt.transparentBackground = true;
						}
						loc1 = newTipLoc('beg0', i, j, opt);	
					} 
					else if (levelTemplate.conf == 3) //Manehattan
					{ 
						opt.transparentBackground = true;
						if (i == 2) 
						{
							if (j == 0) 
							{
								opt.ramka = 7;
								loc1 = newTipLoc('passroof', i, j, opt);
							} 
							else 
							{
								opt.ramka = 5;
								loc1 = newRandomLoc(levelTemplate.landStage, i, j, opt, 'pass');
							}
							loc1.bezdna = true;
						} 
						else if (j == 0) 
						{
							opt.ramka = 6;
							loc1 = newRandomLoc(levelTemplate.landStage, i, j, opt, 'roof');
						} 
						else 
						{
							loc1=newRandomLoc(levelTemplate.landStage,i,j,opt);
							if (i > 2 && loc1.backwall == 'tWindows') loc1.backwall = 'tWindows2';
						}
					} 
					else if (levelTemplate.conf == 4) //military base
					{ 
						if (i == 0) 
						{
							if (j == 0) 
							{
								if (!(GameSession.currentSession.game.triggers['mbase_visited'] > 0)) 
								{
									opt.mirror = false;
									opt.ramka = 8;
									loc1 = newTipLoc('beg0', i, j, opt);
								} 
								else 
								{
									loc1=newRandomLoc(0, i, j, opt);
								}
							} 
							else loc1 = newRandomLoc(0, i, j, opt, 'vert');
						} 
						else if (i == maxLocX - 1) 
						{
							if (j == maxLocY - 1)
							{
								opt.mirror = false;
								loc1=newTipLoc('end', i, j, opt);
							} 
							else loc1 = newRandomLoc(0, i, j, opt, 'vert');
						} 
						else loc1 = newRandomLoc(0, i, j, opt);
					} 
					else if (levelTemplate.conf == 7) //bunker
					{ 
						if (i == 0) 
						{
							if (j == 0) 
							{
								opt.mirror = false;
								loc1=newTipLoc('beg1', i, j, opt);
							} 
							else loc1 = newRandomLoc(1, i, j, opt, 'vert');
						} 
						else if (i == maxLocX - 1) 
						{
							if (j == maxLocY - 1) 
							{
								opt.mirror = false;
								loc1 = newTipLoc('end1', i, j, opt);
							} 
							else loc1=  newRandomLoc(1, i, j, opt, 'vert');
						} 
						else loc1=newRandomLoc(1,i,j,opt);
					} 
					else if (levelTemplate.conf == 5) //canterlot
					{ 
						if (j == 0) 
						{
							opt.ramka = 3;
							opt.backform = 3;
							opt.transparentBackground = true;
							loc1=newRandomLoc(levelTemplate.landStage, i, j, opt, 'surf');
							loc1.visMult = 2;
						} 
						else 
						{
							loc1=newRandomLoc(levelTemplate.landStage,i,j,opt);
						}
						loc1.gas=1;
					} 
					else if (levelTemplate.conf == 10) //stable
					{ 
						opt.home = true;
						if (i == levelTemplate.begLocX && j == levelTemplate.begLocY) 
						{
							opt.mirror = false;
							loc1 = newTipLoc('beg0', i, j, opt);
						} 
						else if (i == 1 && j == 1) 
						{
							opt.mirror = false;
							loc1 = newTipLoc('roof', i, j, opt);
						} 
						else 
						{
							loc1=newRandomLoc(10, i, j, opt);
						}
					} 
					else if (levelTemplate.conf == 11) // attacked stable
					{ 
						opt.atk = true;
						if (i == 5 && j == 0)
						{
							opt.mirror = false;
							loc1=newTipLoc('pass', i, j, opt);
						} 
						else 
						{
							loc1 = newRandomLoc(levelTemplate.landStage, i, j, opt);
						}
					} 
					else 
					{
						loc1 = newRandomLoc(levelTemplate.landStage, i, j, opt);
					}
					// add a room on the second level
					roomArray[i][j][0] = loc1;
					if (loc1.roomTemplate.back != null) 
					{	
						loc2 = null;
						for each(var roomTemplate:RoomTemplate in allRoom) 
						{
							if (roomTemplate.id == loc1.roomTemplate.back) 
							{
								loc2 = newRoom(roomTemplate,i,j,1,opt);
								loc2.tipEnemy = loc1.tipEnemy;
								roomArray[i][j][1] = loc2;
								loc2.noMap = true;
								break;
							}
						}
					}
				}
			}
			
			for (i = minLocX; i < maxLocX; i++) //determine possible passages
			{
				for (j = minLocY; j < maxLocY; j++) 
				{
					loc1 = roomArray[i][j][0];
					loc1.pass_r = [];
					loc1.pass_d = [];
					if (i < maxLocX - 1) 
					{
						loc2 = roomArray[i + 1][j][0];
						for (var e:int = 0; e <= 5; e++) 
						{
							var hole:int = Math.min(loc1.doors[e], loc2.doors[e + 11]);
							if (hole >= 2) 
							{
								loc1.pass_r.push({n:e, fak:hole});
							}
						}
					}
					if (j < maxLocY - 1) 
					{
						loc2 = roomArray[i][j + 1][0];
						for (e = 6; e <= 11; e++) 
						{
							hole = Math.min(loc1.doors[e], loc2.doors[e + 11]);
							if (hole >= 2) 
							{
								loc1.pass_d.push({n:e, fak:hole});
							}
						}
					}
				}
			}
			
			for (i = minLocX; i < maxLocX; i++) //carry out passes, choosing random from the possible ones
			{
				for (j = minLocY; j < maxLocY; j++) 
				{
					loc1=roomArray[i][j][0];
					if (i < maxLocX - 1) 
					{
						if (loc1.pass_r.length) 
						{
							loc2 = roomArray[i + 1][j][0];
							for (e = 0; e <= 2; e++) 
							{
								var n:Number = Math.floor(Math.random()*loc1.pass_r.length);
								loc1.setDoor(loc1.pass_r[n].n,loc1.pass_r[n].fak);
								loc2.setDoor(loc1.pass_r[n].n+11,loc1.pass_r[n].fak);
							}
						}
					}
					if (j<maxLocY-1) 
					{
						if (loc1.pass_d.length) 
						{
							loc2=roomArray[i][j+1][0];
							n=Math.floor(Math.random()*loc1.pass_d.length);
							loc1.setDoor(loc1.pass_d[n].n,loc1.pass_d[n].fak);
							loc2.setDoor(loc1.pass_d[n].n+11,loc1.pass_d[n].fak);
						}
					}
					loc1.mainFrame();
				}
			}
			
			if (levelTemplate.conf == 2) newRandomProb(roomArray[3][0][0], levelTemplate.landStage, true); //sewer camp
			
			if (levelTemplate.conf == 3 && levelTemplate.landStage >= 1) newRandomProb(roomArray[1][4][0], levelTemplate.landStage, true); //Manehattan camp
			
			for (j = maxLocY - 1; j >= minLocY; j--) //arrange objects
			{
				for (i = minLocX; i < maxLocX; i++) 
				{
					var isBonuses:Boolean = true;
					roomArray[i][j][0].setObjects();
					//Create checkpoints

					//Create exit points
					if (levelTemplate.conf == 0 || levelTemplate.conf == 1) //factory and stable configuration
					{	
						if ((i + j)%2 == 0) 
						{
							if (j == maxLocY - 1) 
							{
								if (levelTemplate.conf == 0 && levelTemplate.landStage >= 2 || levelTemplate.conf == 1 && levelTemplate.landStage >= 1) 
								{
									roomArray[i][j][0].createExit('1');		//Exit points on the lower level
								} 
								else 
								{
									roomArray[i][j][0].createExit();			//Exit points on the lower level
								}
							} 
							else roomArray[i][j][0].createCheck(i == levelTemplate.begLocX && j == levelTemplate.begLocY);	//checkpoints  
						} 
						else 
						{
							if (j == maxLocY - 1) newRandomProb(roomArray[i][j][0], levelTemplate.landStage, true);
							else if (Math.random() < 0.3) newRandomProb(roomArray[i][j][0], levelTemplate.landStage, false);
						}
					}
					//sewer and Canterlot configuration
					if (levelTemplate.conf==2 || levelTemplate.conf==5) 	//exit points on the right edge
					{
						if (i != 0 || j != 0) roomArray[i][j][0].createClouds(j);
						if (levelTemplate.conf == 2 && i == maxLocX - 1) roomArray[i][j][0].createExit();
						if (levelTemplate.conf == 5 && i == maxLocX - 1 && j == 0)
						{
							if (levelTemplate.landStage >= 1) roomArray[i][j][0].createExit('1');
							else roomArray[i][j][0].createExit();
						} 
						else if ((i + j)%2 == 0) 
						{
							if (levelTemplate.conf == 2 && j < 2 && i < maxLocX - 1 || levelTemplate.conf == 5 && (i == 0 || j > 0)) roomArray[i][j][0].createCheck(i == levelTemplate.begLocX && j == levelTemplate.begLocY);
						}
						if (levelTemplate.conf == 2 && j > 1) roomArray[i][j][0].petOn = false;
						if ((j > 1 && i < maxLocX - 1) || (levelTemplate.conf == 2 && i < maxLocX - 1 && Math.random() < 0.25)) 
						{
							if ((i + j)%2 == 1) newRandomProb(roomArray[i][j][0], levelTemplate.landStage, false);
						}
					}
					
					if (levelTemplate.conf == 3 && i != 2) //Manehattan configuration
					{
						if ((i + j)%2 == 0) //Exit points on the upper level
						{
							if (j == 0)
							{
								if (levelTemplate.landStage >= 1) roomArray[i][j][0].createExit('1');
								else roomArray[i][j][0].createExit();
							} 
							else roomArray[i][j][0].createCheck(i == levelTemplate.begLocX && j == levelTemplate.begLocY); 
						} 
						else 
						{
							if (j == 0) newRandomProb(roomArray[i][j][0], levelTemplate.landStage, true);
							else if (j != 4 && Math.random() < 0.25) newRandomProb(roomArray[i][j][0], levelTemplate.landStage, false);
						}	
					}
					
					if (levelTemplate.conf == 4) // military base configuration
					{
						if (i == levelTemplate.begLocX && j == levelTemplate.begLocY || i == 3) 
						{
							roomArray[i][j][0].createCheck(i == levelTemplate.begLocX && j == levelTemplate.begLocY);
							if (i == levelTemplate.begLocX && j == levelTemplate.begLocY) isBonuses = false;
						}
					}
					
					if (levelTemplate.conf == 7) //bunker configuration
					{
						if (i == levelTemplate.begLocX && j == levelTemplate.begLocY) 
						{
							roomArray[i][j][0].createCheck(true);
							isBonuses = false;
						}
					}
					
					if (levelTemplate.conf == 6) //enclave base configuration
					{
						opt.transparentBackground = true;
						if (j == 0) 
						{
							if (i == 0 || i == 2) 
							{
								if (levelTemplate.landStage >= 1) roomArray[i][j][0].createExit('1');
								else roomArray[i][j][0].createExit();
							}
							if (i == 1) newRandomProb(roomArray[i][j][0], levelTemplate.landStage, true);
						} 
						else if (i == levelTemplate.begLocX && j == levelTemplate.begLocY || i == ((7 - j)%3)) 
						{
							roomArray[i][j][0].createCheck(i == levelTemplate.begLocX && j == levelTemplate.begLocY);
						} 
						else if (Math.random() < 0.25) newRandomProb(roomArray[i][j][0], levelTemplate.landStage, false);
					}
					
					if (levelTemplate.conf == 10 || levelTemplate.conf == 11) //stable configuration
					{
						if (i == levelTemplate.begLocX && j == levelTemplate.begLocY) 
						{
							roomArray[i][j][0].createCheck(true);
						}
					}
					roomArray[i][j][0].preStep();
					if (roomArray[i][j][1]) 
					{
						roomArray[i][j][1].mainFrame();
						roomArray[i][j][1].setObjects();
						roomArray[i][j][1].preStep();
					}
					if (isBonuses) roomArray[i][j][0].createXpBonuses(5);
					allXp += roomArray[i][j][0].summXp;
				}
			}
			buildProbs();
		}
		
		public function buildSpecifLevel():void
		{
			var i:int;
			var j:int;
			var e:int;
			var loc1:Room;
			var loc2:Room;

			for each(var roomTemplate:RoomTemplate in allRoom) // Determine the actual sizes (of what, the room? the level?)
			{
				if (roomTemplate.roomCoordinateX < minLocX) minLocX = roomTemplate.roomCoordinateX;
				if (roomTemplate.roomCoordinateY < minLocY) minLocY = roomTemplate.roomCoordinateY;
				if (roomTemplate.roomCoordinateX + 1 > maxLocX) maxLocX = roomTemplate.roomCoordinateX + 1;
				if (roomTemplate.roomCoordinateY + 1 > maxLocY) maxLocY = roomTemplate.roomCoordinateY + 1;
			}

			roomArray = [];
			for (i = minLocX; i < maxLocX; i++) 
			{
				roomArray[i] = [];
				for (j = minLocY; j < maxLocY; j++) roomArray[i][j] = [];
			}

			for each(roomTemplate in allRoom) //populate array with rooms from the allRoom.
			{
				loc1 = newRoom(roomTemplate, roomTemplate.roomCoordinateX, roomTemplate.roomCoordinateY, roomTemplate.roomCoordinateZ);
				roomArray[roomTemplate.roomCoordinateX][roomTemplate.roomCoordinateY][roomTemplate.roomCoordinateZ] = loc1;
			}

			for (i = minLocX; i < maxLocX; i++) //place objects
			{
				for (j = minLocY; j < maxLocY; j++) 
				{
					for (e = minLocZ; e<maxLocZ; e++) 
					{
						if (roomArray[i][j][e] == null) continue;
						roomArray[i][j][e].setObjects();
						roomArray[i][j][e].preStep();
					}
				}
			}

			buildProbs();
		}
		
		//add trial rooms whose ids were used in the area (doors with prob={id} were involved)
		//process all added
		public function buildProbs():void
		{
			for each (var s in probIds)	buildProb(s);
			for each (var room in listLocs) 
			{
				room.setObjects();
				room.preStep();
				if (room.prob) room.prob.prepare();
			}
		}
		
		
		public function buildProb(nprob:String):Boolean //create a test layer, return false if the layer already exists
		{
			if (probs[nprob] != null) return false;
			//create a single room

			var arrr:XML = GameSession.currentSession.game.probs['prob'].allroom;
			for each(var xml in arrr.roomTemplate) 
			{
				if (xml.@name == nprob) 
				{
					var roomTemplate:RoomTemplate = new RoomTemplate(xml);
					var room:Room = newRoom(roomTemplate, 0, 0, 0, {prob:nprob});
					room.levelProb = nprob;
					room.noMap = true;
					var xmll:XMLList = XmlBook.getXML("levels").level.prob.(@id == nprob);
					if (xmll.length()) room.prob = new Probation(xmll[0],room);
					if (room.spawnPoints.length) //add an exit door
					{
						room.createObj('doorout','box',room.spawnPoints[0].x,room.spawnPoints[0].y,<obj prob='' uid='begin'/>);
					}
					probs[nprob] = [[[room]]];
					listLocs.push(room);
					break;
				}
			}
			return true;
		}

		// Create a door and a random test room behind it, return false if none were found
		public function newRandomProb(newRoom:Room, maxlevel:int = 100, imp:Boolean = false):Boolean 
		{
			rndRoom = [];
			var impProb;
			for each(var xml in levelTemplate.levelData.prob) 
			{
				if (probs[xml.@id] == null && GameSession.currentSession.game.triggers['prob_' + xml.@id] == null && (xml.@levelTemplate.length == 0 || xml.@levelTemplate <= maxlevel)) 
				{
					rndRoom.push(xml.@id);
					if (xml.@imp.length()) impProb = xml.@id;
				}
			}
			if (rndRoom.length == 0) return false;

			var pid:String, did:String = 'doorprob';

			if (imp && impProb) pid = impProb;
			else if (rndRoom.length == 1) pid = rndRoom[0];
			else pid = rndRoom[Math.floor(Math.random() * rndRoom.length)];

			if (levelTemplate.levelData.prob.(@id == pid).@tip == '2') did = 'doorboss';
			
			if (!newRoom.createDoorProb(did,pid)) return false;
			buildProb(pid);
			return true;
		}
		
		// create a new room of the specified type, at the given coordinates
		public function newTipLoc(ntip:String, roomCoordinateX:int, roomCoordinateY:int, opt:Object=null):Room 
		{
			rndRoom = [];
			for each(var roomTemplate in allRoom) 
			{
				if (roomTemplate.tip == ntip) rndRoom.push(roomTemplate); 
			}
			if (rndRoom.length > 0) 
			{
				roomTemplate = rndRoom[Math.floor(Math.random() * rndRoom.length)];
			} 
			else 
			{
				roomTemplate = allRoom[Math.floor(Math.random() * allRoom.length)];
			}
			roomTemplate.kol--;
			return newRoom(roomTemplate, roomCoordinateX, roomCoordinateY, 0, opt);
		}
		
		//create a new random room in the given coordinates
		public function newRandomLoc(maxlevel:int, roomCoordinateX:int, roomCoordinateY:int, opt:Object = null, ntip:String = null):Room 
		{
			rndRoom = [];
			var r1:RoomTemplate, r2:RoomTemplate;
			if (roomCoordinateX > minLocX) r1 = roomArray[roomCoordinateX - 1][roomCoordinateY][0].roomTemplate;
			if (roomCoordinateY > minLocY) r2 = roomArray[roomCoordinateX][roomCoordinateY - 1][0].roomTemplate;
			
			for each(var roomTemplate in allRoom) //array of all rooms that meet the conditions
			{
				if (roomTemplate.lvl <= maxlevel && roomTemplate.kol > 0 && roomTemplate != r1 && roomTemplate != r2 && (ntip == null && roomTemplate.rnd || roomTemplate.tip == ntip)) 
				{
					var rndKol = roomTemplate.kol * roomTemplate.kol;
					if (rndKol == 4 && roomTemplate.lvl == 0 && maxlevel > 1) 
					{
						rndKol = 2;
					}
					for (var i:int = 0; i < rndKol; i++) 
					{
						rndRoom.push(roomTemplate);
					}
				}
			}
			if (rndRoom.length > 0) 
			{
				roomTemplate = rndRoom[Math.floor(Math.random() * rndRoom.length)];
			} 
			else 
			{
				for each(roomTemplate in allRoom) //array of all rooms suitable for random selection
				{
					if (roomTemplate.rnd) 
					{
						rndRoom.push(roomTemplate);
					}
				}
				roomTemplate = rndRoom[Math.floor(Math.random()*rndRoom.length)];
			}
			roomTemplate.kol--;
			if (levelTemplate.conf == 4) roomTemplate.kol = 0;	//rooms on a military base are used only once
			return newRoom(roomTemplate, roomCoordinateX, roomCoordinateY, 0, opt);
		}
		
		//create a new room based on the given Room template, at the specified coordinates
		public function newRoom(roomTemplate:RoomTemplate, roomCoordinateX:int, roomCoordinateY:int, roomCoordinateZ:int=0, opt:Object=null):Room 
		{
			var room:Room = new Room(this, roomTemplate.xml, rnd, opt);
			room.biom = levelTemplate.biom;
			room.roomTemplate = roomTemplate;
			room.roomCoordinateX = roomCoordinateX;
			room.roomCoordinateY = roomCoordinateY;
			room.roomCoordinateZ = roomCoordinateZ;
			room.id = 'room' + roomCoordinateX + '_' + roomCoordinateY;
			if (roomCoordinateZ > 0) room.id += '_' + roomCoordinateZ;
			room.unXp=levelTemplate.xp;
			
			
			var deep:Number = 0; // Set the difficulty level gradient
			if (rnd) 
			{
				if (levelTemplate.conf == 0) deep = roomCoordinateY / 2;	
				if (levelTemplate.conf == 1) deep = roomCoordinateY;
				if (levelTemplate.conf == 2) deep = roomCoordinateY * 2.5;
			}
			setLocDif(room, deep);
			
			room.addPlayer(gg);
			return room;
		}
		
		// Setting the difficulty level of the room based on the character's level and difficulty gradient
		public function setLocDif(room:Room, deep:Number):void
		{
			var ml:Number = levelDifficultyLevel + deep;
			room.locDifLevel = ml;
			room.locksLevel = ml * 0.7;	// level of locks
			room.mechLevel = ml / 4;		// level of mines and mechanisms
			room.weaponLevel = 1 + ml / 4;	// level of encountered weapons
			room.enemyLevel = ml;		// level of enemies

			// influence of difficulty settings
			if (GameSession.currentSession.game.globalDif < 2) room.earMult *= 0.5;
			if (GameSession.currentSession.game.globalDif > 2) room.enemyLevel += (GameSession.currentSession.game.globalDif - 2) * 2;	// level of enemies based on difficulty
			// type of enemies
			if (levelTemplate.biom == 0 && Math.random() < 0.25) room.tipEnemy = 1;
			if (room.tipEnemy < 0) room.tipEnemy = Math.floor(Math.random() * 3);
			if (levelTemplate.biom == 1) room.tipEnemy = 0;
			if (levelTemplate.biom == 2 && room.tipEnemy == 1 && Math.random() < ml / 20) room.tipEnemy = 3;	// slave traders
			if (levelTemplate.biom == 3) 
			{
				room.tipEnemy = Math.floor(Math.random() * 3) + 3; // 4-mercenaries, 5-unicorns
			}
			if (ml > 12 && (levelTemplate.biom == 0 || levelTemplate.biom == 2 || levelTemplate.biom == 3) && Math.random() < 0.1) room.tipEnemy = 6;	// zebras
			if (levelTemplate.biom == 4) room.tipEnemy = 7;	// steel+robots
			if (levelTemplate.biom == 5) 
			{
				if (Math.random() < 0.3) room.tipEnemy = 5;
				else room.tipEnemy = 8;	// pink
			}
			if (levelTemplate.biom == 6) 
			{
				if (Math.random() > 0.3) room.tipEnemy = 9;	// enclave
				else room.tipEnemy = 10;// greyhounds
			}
			if (levelTemplate.biom == 11) room.tipEnemy = 11; // enclave and greyhounds
			// number of enemies
			// type, minimum, maximum, random increase
			if (ml < 4) 
			{
				room.setUnitSpawnLimits(1, 3, 5, 2);
				room.setUnitSpawnLimits(2, 2, 4, 0);
				room.setUnitSpawnLimits(3, 3, 4, 2);
				room.setUnitSpawnLimits(4, 1, 2, 0);
				room.setUnitSpawnLimits(5, 1, 4, 2);
				if (room.tipEnemy == 6) room.setUnitSpawnLimits(2, 1, 3, 0);
				if (room.kolEnSpawn == 0) 
				{
					if (room.tipEnemy != 5) room.setUnitSpawnLimits(-1, 1, 2);
				}
				room.kolEnHid = 0;
			} 
			else if (ml < 10) 
			{
				room.setUnitSpawnLimits(1, 3, 6, 2);
				if (Math.random() < 0.15) room.setUnitSpawnLimits(2, 1, 1, 0);
				else if (room.tipEnemy == 6) room.setUnitSpawnLimits(2, 2, 3, 0);
				else room.setUnitSpawnLimits(2, 2, 5, 0);
				room.setUnitSpawnLimits(3, 3, 5, 2);
				room.setUnitSpawnLimits(4, 2, 3, 1);
				room.setUnitSpawnLimits(5, 2, 4, 2);
				if (room.kolEnSpawn == 0) 
				{
					if (room.tipEnemy != 5) room.setUnitSpawnLimits(-1, 2, 3);
				}
				room.kolEnHid = Math.floor(Math.random() * 3);
			} 
			else 
			{
				room.setUnitSpawnLimits(1, 4, 6, 2);
				if (Math.random() < 0.15) room.setUnitSpawnLimits(2, 1, 2, 0);
				else if (room.tipEnemy == 6) room.setUnitSpawnLimits(2, 3, 4, 0);
				else room.setUnitSpawnLimits(2, 3, 6, 0);
				room.setUnitSpawnLimits(3, 4, 7, 2);
				room.setUnitSpawnLimits(4, 2, 4, 1);
				room.setUnitSpawnLimits(5, 3, 6, 2);
				if (room.kolEnSpawn == 0) 
				{
					if (room.tipEnemy != 5) room.setUnitSpawnLimits(-1, 2, 4);
					else if (Math.random() > 0.4) room.setUnitSpawnLimits(-1, 1, 3);
				}
				room.kolEnHid = Math.floor(Math.random() * 4);
			}
			if (room.tipEnemy == 5 || room.tipEnemy == 10) 
			{
				room.setUnitSpawnLimits(2, 1, 3, 1);
			}
			if (levelTemplate.biom == 11) 
			{
					room.setUnitSpawnLimits(2, 5, 8, 0);
			}
		}
		
		public function createMap():void
		{
			map = new BitmapData(Settings.roomTileWidth * (maxLocX - minLocX), Settings.roomTileHeight * (maxLocY - minLocY), true, 0);
		}
		
//==============================================================================================================================		
//				*** Functions ***
//==============================================================================================================================		
		
		
		public function enterLevel(first:Boolean = false, coord:String = null):void
		{
			trace('Level.as/enterLevel - Entering level.');

			GameSession.currentSession.grafon.changeSkybox(); // Render Skybox

			levelTemplate.visited = true;
			locZ = 0;
			prob = '';

			if (coord != null) 
			{
				var narr:Array = coord.split(':');
				locX = narr.length >= 1 ? narr[0] : 0;
				locY = narr.length >= 2 ? narr[1] : 0;
			} 
			else if (currentCP && !first) 
			{
				GameSession.currentSession.pers.currentCP = currentCP;
				gotoCheckPoint();
				currentCP.activate();
				return; // Avoid calling activateRoom and setGGToSpawnPoint.
			} 
			else 
			{
				locX = levelTemplate.begLocX;
				locY = levelTemplate.begLocY;
			}

			activateRoom();
			setGGToSpawnPoint();
		}
		
		public function saveObjs(arr:Array):void
		{
			if (rnd) return;
			for (var i:int = minLocX; i < maxLocX; i++) 
			{
				for (var j:int = minLocY; j < maxLocY; j++) 
				{
					for (var e = minLocZ; e < maxLocZ; e++) 
					{
						if (roomArray[i][j][e] == null) continue;
						roomArray[i][j][e].saveObjs(arr);
					}
				}
			}
		}
		
		public function setGGToSpawnPoint():void //Move the character to the spawn point
		{
			trace('Level.as/setGGToSpawnPoint() - Moving player to spawnpoint in room: "' + room.id + '".');

			var roomCoordinateX:int = 3;
			var roomCoordinateY:int = 3;

			trace('Level.as/setGGToSpawnPoint() - Spawnpoints: "' + room.spawnPoints.length + '".');
			if (room.spawnPoints.length > 0)
			{
				var n = Math.floor(Math.random() * room.spawnPoints.length);
				roomCoordinateX = room.spawnPoints[n].x;
				roomCoordinateY = room.spawnPoints[n].y;
			}
			else trace('Level.as/setGGToSpawnPoint() - ERROR: No valid spawnpoints found in Room: "' + room.id + '"!')

			gg.setLocPos((roomCoordinateX + 1) * Tile.tilePixelWidth, (roomCoordinateY + 1) * Tile.tilePixelHeight - 1);
			gg.dx = 3;

			room.lighting(gg.X, gg.Y - 75);

		}
		
		//TODO: Why is this returning a bool?
		public function activateRoom():Boolean //Activate the room with the current coordinates
		{
			trace('Level.as/activateRoom() - Activating room.');
			var newRoom:Room;

			if (prob != '' && probs[prob] == null)
			{
				trace('Level.as/activateRoom() - ERROR: Room does not have a valid trial! Stopping room activation.');
				return false;
			}

			if (prob != '')
			{
				if (probs != null) newRoom = probs[prob][locX][locY][locZ];
				else trace('Level.as/activateRoom() - Error: Failed to set up new room, probs is null.')
			}
			else
			{
				if (roomArray != null) newRoom = roomArray[locX][locY][locZ];
				else trace('Level.as/activateRoom() - Error: Failed to set up new room, roomArray is null.')
			}

			if (newRoom != null)
			{
				if (room == newRoom)
				{
					trace('Level.as/activateRoom() - room == newRoom returning false early.');
					return false;
				}
			}
			
			locN++; //increment transition timer by 1. (Default is 0)
			prevloc = room; //Set prevloc variable as the current room.
			room = newRoom; //Set the current room as the room being loaded.

			gg.inLoc(room);
			room.reactivate(locN);
			GameSession.currentSession.transitionToRoom(room);

			if (room.sky) 
			{
				gg.isFly = true;
				gg.stay = false;
				GameSession.currentSession.cam.setZoom(2);
			}

			room.lightAll();
			return true;
		}
		
		public function gotoXY(roomCoordinateX:int,roomCoordinateY:int):void //Go to room x,y
		{
			if (roomCoordinateX  < minLocX) roomCoordinateX = minLocX;
			if (roomCoordinateX >= maxLocX) roomCoordinateX = maxLocX - 1;
			if (roomCoordinateY  < minLocY) roomCoordinateY = minLocY;
			if (roomCoordinateY >= maxLocY) roomCoordinateY = maxLocY - 1;
			locX = roomCoordinateX;
			locY = roomCoordinateY;
			locZ = 0;
			activateRoom();
			setGGToSpawnPoint();
		}
		
		
		//Transition between locations
		public function gotoLoc(napr:int, portX:Number=-1, portY:Number=-1):Object 
		{
			var X:Number = gg.X;
			var Y:Number = gg.Y;
			var scX:Number = gg.scX;
			var scY:Number = gg.scY;
			var newX:int = locX;
			var newY:int = locY;
			var newZ:int = locZ;

			switch(napr)
			{
				case 1:
					newX--;
					break;
				case 2:
					newX++;
					break;
				case 3:
					newY++;
					break;
				case 4:
					newY--;
					break;
				case 5:
					newZ = 1 - newZ;
					break;
				default:
					return null;
			}

			if (prob == '' && (roomArray[newX] == null || roomArray[newX][newY] == null || roomArray[newX][newY][newZ] == null)) 
			{
				if (napr == 3) return {die:true};
				return null;
			}

			if (prob != '' && (probs[prob][newX] == null || probs[prob][newX][newY] == null || probs[prob][newX][newY][newZ] == null)) 
			{
				if (napr == 3) return {die:true};
				return null;
			}

			var newRoom:Room = roomArray[newX][newY][newZ];
			var outP:Object = {};

			switch(napr)
			{
				case 1:
					outP.x = newRoom.roomPixelWidth - scX / 2 - 9;
					outP.y = Y - 1;
					break;
				case 2:
					outP.x = scX / 2 + 9;
					outP.y = Y - 1;
					break;
				case 3:
					outP.x = X;
					outP.y = scY + 10;
					break;
				case 4:
					outP.x = X;
					outP.y = newRoom.roomPixelHeight - 10;
					break;
				case 5:
					outP.x = portX;
					outP.y = portY;
					break;
			}

			if (newRoom.collisionUnit(outP.x, outP.y, scX - 4, scY)) return null;
			
			loc_t = 150;
			locX = newX;
			locY = newY;
			locZ = newZ;
			activateRoom();
			gg.setLocPos(outP.x, outP.y);
			return outP;
		}
		
		// Go to the test layer nprob, or return to the main layer if the parameter is not specified
		public function gotoProb(nprob:String = '', nretX:Number = -1, nretY:Number = -1):void
		{
			if (nprob == '') 
			{
				prob = '';
				locX = retLocX;
				locY = retLocY;
				locZ = retLocZ;

				activateRoom();

				if (retX == 0 && retY == 0) setGGToSpawnPoint();
				else gg.setLocPos(retX, retY);
			}
			else 
			{
				retLocX = locX;
				retLocY = locY;
				retLocZ = locZ;

				if (nretX < 0 || nretY < 0) 
				{
					retX = gg.X;
					retY = gg.Y;
				} 
				else 
				{
					retX = nretX;
					retY = nretY;
				}

				prob = nprob;
				locX = 0;
				locY = 0;
				locZ = 0;

				if (activateRoom()) setGGToSpawnPoint();
				else 
				{
					prob = '';
					locX = retLocX;
					locY = retLocY;
					locZ = retLocZ;
				}
			}
		}
		
		public function gotoCheckPoint():void
		{
			var cp:CheckPoint = GameSession.currentSession.pers.currentCP;

			if (cp == null) 
			{
				gg.setNull();
				return;
			}

			if (cp.room.level != this && currentCP)	
			{
				cp = currentCP;
				GameSession.currentSession.pers.currentCP = currentCP;
				currentCP.activate();
			}

			if (cp.room.level != this) 
			{
				locX = levelTemplate.begLocX;
				locY = levelTemplate.begLocY;
				locZ = 0;
				prob = '';
				if (!activateRoom()) room.reactivate();
				setGGToSpawnPoint();
			} 
			else 
			{
				locX = cp.room.roomCoordinateX;
				locY = cp.room.roomCoordinateY;
				locZ = cp.room.roomCoordinateZ;
				prob = cp.room.levelProb;
				if (!activateRoom()) room.reactivate();
				gg.setLocPos(cp.X, cp.Y);
			}

			gg.dx = 3;
		}
		
		public function refill():void
		{
			if (isRefill) return;

			if (summXp * 10 > allXp || !rnd) 
			{
				GameSession.currentSession.game.refillVendors();
				isRefill = true;
			} 
			else trace('Experience obtained: ', summXp, allXp);
		}
		
		public function artBabah():void
		{
			Snd.ps('artfire');
			GameSession.currentSession.quake(10, 3);
		}
		
		public function artStep():void
		{
			art_t--;
			if (art_t <= 0) 
			{
				art_t = Math.floor(Math.random() * 1000 + 20);
				if (levelTemplate.artFire != null && GameSession.currentSession.game.triggers[levelTemplate.artFire] != 1) artBabah();
			}
		}
		
		public function drawMap():BitmapData 
		{
			map.fillRect(map.rect, 0x00000000);
			for (var i:int = minLocX; i < maxLocX; i++) 
			{
				for (var j:int = minLocY; j < maxLocY; j++) 
				{
					if (roomArray[i][j][0] != null && (Settings.drawAllMap || roomArray[i][j][0].visited)) roomArray[i][j][0].drawMap(map);
				}
			}
			ggX = (room.roomCoordinateX - minLocX) * Settings.roomTileWidth * Settings.tilePixelWidth + gg.X;
			ggY = (room.roomCoordinateY - minLocY) * Settings.roomTileHeight * Settings.tilePixelHeight + gg.Y - gg.scY / 2;
			return map;
		}
		
		public function getAll():int //Kill all enemies and open all containers
		{
			var summ:int = 0;
			for (var i:int = minLocX; i < maxLocX; i++) 
			{
				for (var j:int = minLocY; j < maxLocY; j++) 
				{
					for (var e:int = minLocZ; e < maxLocZ; e++) 
					{
						if (roomArray[i][j][e] == null) continue;
						summ += roomArray[i][j][e].getAll();
					}
				}
			}
			return summ;
		}
		
		public function step():void
		{
			if (!GameSession.currentSession.catPause) 
			{
				room.step();
				if (loc_t > 0) 
				{
					loc_t--;
					if (prevloc && room != prevloc) prevloc.stepInvis();
				}
				artStep();
			}
			if (scripts.length) 
			{
				for each (var scr:Script in scripts) 
				{
					if (scr.running) scr.step();
				}
			}
		}
	}
}
