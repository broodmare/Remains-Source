package locdata 
{
	
	import unitdata.UnitPlayer;
	import unitdata.Pers;
	import flash.display.BitmapData;
	import servdata.Script;
	
	public class Land 
	{
		
		public var act:LandAct;					//template based on which the terrain was created
		
		public var rnd:Boolean=false;			//true if the terrain has random generation
		public var location:Location;				//current location
		private var prevloc:Location;			//previously visited location
		public var locs:Array;					//three-dimensional map of all locations
		public var probs:Array;					//trial locations
		public var listLocs:Array;				//linear array of locations
		public var locX:int;
		public var locY:int;
		public var locZ:int = 0;				//coordinates of the active location
		public var retLocX:int = 0;
		public var retLocY:int = 0;
		public var retLocZ:int = 0;
		public var retX:Number = 0;
		public var retY:Number = 0;				//coordinates for returning to the main layer
		public var prob:String = '';			//trial layer, ''-main layer
		public var minLocX:int = 0;
		public var minLocY:int = 0;
		public var minLocZ:int = 0;				//terrain size
		public var maxLocX:int = 4;
		public var maxLocY:int = 6;
		public var maxLocZ:int = 2;				//terrain size
		
		public var loc_t:int = 0;				//timer
		static var locN:int = 0;				//transition counter
		
		public var gg:UnitPlayer;
		public var ggX:Number=0;				//X coordinate of the player in the land
		public var ggY:Number=0;				//Y coordinate of the player in the land
		public var currentCP:CheckPoint;
		public var art_t:int=200;
		
		public var map:BitmapData;				//terrain map
		
		public var landDifLevel:Number = 0;		//overall difficulty, depends on player level or map settings
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
		public var aliAlarm:Boolean = false;		//alarm among alicorns
		
		public var probIds:Array;				//available trial rooms
		var impProb:int = -1;						//important trial room


		//lvl - character level-1
		public function Land(ngg:UnitPlayer, nact:LandAct, lvl:int) 
		{
			gg = ngg;
			act = nact;
			rnd = act.rnd;
			uidObjs = new Array();
			scripts = new Array();
			kolAll = new Array();
			listLocs = new Array();
			probIds = new Array();
			probs = new Array();
			prepareRooms();
			if (rnd) 
			{
				landDifLevel=lvl;	//difficulty is determined by the given parameter
				if (landDifLevel<act.dif) landDifLevel=act.dif;	//if the difficulty is less than the minimum, set it to the minimum
				maxLocX=act.mLocX;	//dimensions are taken from the act settings
				maxLocY=act.mLocY;
				buildRandomLand();
			} 
			else 
			{
				landDifLevel = act.dif;	//difficulty is taken from the act settings
				if (act.autoLevel) landDifLevel = lvl;
				maxLocX = 1;	//dimensions are determined according to the map
				maxLocY = 1;	//dimensions are determined according to the map
				buildSpecifLand();
			}
			lootLimit = lvl + 3;
			gameStage = act.gameStage;	//story stage is taken from the act settings
			//attached scripts
			itemScripts = new Array();
			for each(var xl in act.xmlland.scr) 
			{
				if (xl.@eve == 'take' && xl.@item.length()) 
				{
					var scr:Script=new Script(xl,this);
					itemScripts[xl.@item] = scr;
				}
			}
			createMap();
		}
		
//==============================================================================================================================		
//				*** Creation  ***
//==============================================================================================================================		
		
		//Convert from XML to array
		public function prepareRooms() 
		{
			allRoom=new Array();
			for each(var xml in act.allroom.room) 
			{
				allRoom.push(new Room(xml));
			}
		}
		
		
		public function buildRandomLand() 
		{
			if (World.w.landError) 
			{
				locs=null;
				locs[0];
			}
			locs=new Array();
			if (act.conf==0 && act.landStage<=0) maxLocY=3;
			var loc1:Location, loc2:Location;
			var opt:Object=new Object();
			for (var i=minLocX; i<maxLocX; i++) 
			{
				locs[i]=new Array();
				for (var j=minLocY; j<maxLocY; j++) 
				{
					opt.mirror=(Math.random()<0.5);
					opt.water=null;
					opt.ramka=null;
					opt.backform=0;
					opt.transpFon=false;
					//Flooded rooms
					if (act.conf==2) 
					{
						if (j==1) opt.water=17;
						if (j>1) opt.water=0;
					}
					if (act.conf==5) 
					{
						if (j==2) opt.water=21;
						if (j>2) opt.water=0;
					}
					//buildings
					if (act.conf==3) 
					{
						
					}
					locs[i][j]=new Array();
					if (act.conf==0 && j==0 && !act.visited) 
					{ //initial rooms
						opt.mirror=false;
						loc1=newTipLoc('beg'+i,i,j,opt);	
					} 
					else if ((act.conf==2 || act.conf==1 || act.conf==5) && j==0 && i==0 && !act.visited) 
					{ //initial rooms
						opt.mirror=false;
						if (act.conf==5) 
						{
							opt.ramka=3;
							opt.backform=3;
							opt.transpFon=true;
						}
						loc1=newTipLoc('beg0',i,j,opt);	
					} 
					else if (act.conf==3) 
					{ //Manehattan
						opt.transpFon=true;
						if (i==2) {
							if (j==0) 
							{
								opt.ramka=7;
								loc1=newTipLoc('passroof',i,j,opt);
							} 
							else 
							{
								opt.ramka=5;
								loc1=newRandomLoc(act.landStage,i,j,opt,'pass');
							}
							loc1.bezdna=true;
						} 
						else if (j==0) 
						{
							opt.ramka=6;
							loc1=newRandomLoc(act.landStage,i,j,opt,'roof');
						} 
						else 
						{
							loc1=newRandomLoc(act.landStage,i,j,opt);
							if (i>2 && loc1.backwall=='tWindows') loc1.backwall='tWindows2';
						}
					} 
					else if (act.conf==4) 
					{ //military base
						if (i==0) 
						{
							if (j==0) 
							{
								if (!(World.w.game.triggers['mbase_visited']>0)) 
								{
									opt.mirror=false;
									opt.ramka=8;
									loc1=newTipLoc('beg0',i,j,opt);
								} 
								else 
								{
									loc1=newRandomLoc(0,i,j,opt);
								}
							} 
							else loc1=newRandomLoc(0,i,j,opt,'vert');
						} 
						else if (i==maxLocX-1) 
						{
							if (j==maxLocY-1)
							{
								opt.mirror=false;
								loc1=newTipLoc('end',i,j,opt);
							} 
							else loc1=newRandomLoc(0,i,j,opt,'vert');
						} 
						else loc1=newRandomLoc(0,i,j,opt);
					} 
					else if (act.conf==7) 
					{ //bunker
						if (i==0) 
						{
							if (j==0) 
							{
								opt.mirror=false;
								loc1=newTipLoc('beg1',i,j,opt);
							} 
							else loc1=newRandomLoc(1,i,j,opt,'vert');
						} 
						else if (i==maxLocX-1) 
						{
							if (j==maxLocY-1) 
							{
								opt.mirror=false;
								loc1=newTipLoc('end1',i,j,opt);
							} else loc1=newRandomLoc(1,i,j,opt,'vert');
						} 
						else loc1=newRandomLoc(1,i,j,opt);
					} 
					else if (act.conf==5) 
					{ //canterlot
						if (j==0) 
						{
							opt.ramka=3;
							opt.backform=3;
							opt.transpFon=true;
							loc1=newRandomLoc(act.landStage,i,j,opt,'surf');
							loc1.visMult=2;
						} 
						else 
						{
							loc1=newRandomLoc(act.landStage,i,j,opt);
						}
						loc1.gas=1;
					} 
					else if (act.conf==10) 
					{ //stable
						opt.home=true;
						if (i==act.begLocX && j==act.begLocY) 
						{
							opt.mirror=false;
							loc1=newTipLoc('beg0',i,j,opt);
						} 
						else if (i==1 && j==1) 
						{
							opt.mirror=false;
							loc1=newTipLoc('roof',i,j,opt);
						} 
						else 
						{
							loc1=newRandomLoc(10,i,j,opt);
						}
					} 
					else if (act.conf==11) 
					{ // attacked stable
						opt.atk=true;
						if (i==5 && j==0)
						{
							opt.mirror=false;
							loc1=newTipLoc('pass',i,j,opt);
						} 
						else 
						{
							loc1=newRandomLoc(act.landStage,i,j,opt);
						}
					} 
					else 
					{
						loc1=newRandomLoc(act.landStage,i,j,opt);
					}
					// add a room on the second level
					locs[i][j][0]=loc1;
					if (loc1.room.back!=null) 
					{	
						loc2=null;
						for each(var room:Room in allRoom) 
						{
							if (room.id==loc1.room.back) 
							{
								loc2=newLoc(room,i,j,1,opt);
								loc2.tipEnemy=loc1.tipEnemy;
								locs[i][j][1]=loc2;
								loc2.noMap=true;
								break;
							}
						}
					}
				}
			}
			//determine possible passages
			for (i = minLocX; i < maxLocX; i++) 
			{
				for (j=minLocY; j<maxLocY; j++) 
				{
					loc1=locs[i][j][0];
					loc1.pass_r = new Array();
					loc1.pass_d = new Array();
					if (i < maxLocX - 1) 
					{
						loc2 = locs[i + 1][j][0];
						for (var e = 0; e <= 5; e++) 
						{
							var hole:int = Math.min(loc1.doors[e], loc2.doors[e + 11]);
							if (hole >= 2) 
							{
								loc1.pass_r.push({n:e, fak:hole});
							}
						}
					}
					if (j<maxLocY - 1) 
					{
						loc2 = locs[i][j + 1][0];
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
			//carry out passes, choosing random from the possible ones
			for (i=minLocX; i<maxLocX; i++) 
			{
				for (j=minLocY; j<maxLocY; j++) 
				{
					loc1=locs[i][j][0];
					if (i<maxLocX - 1) 
					{
						if (loc1.pass_r.length) 
						{
							loc2=locs[i+1][j][0];
							for (e=0; e<=2; e++) 
							{
								var n=Math.floor(Math.random()*loc1.pass_r.length);
								loc1.setDoor(loc1.pass_r[n].n,loc1.pass_r[n].fak);
								loc2.setDoor(loc1.pass_r[n].n+11,loc1.pass_r[n].fak);
							}
						}
					}
					if (j<maxLocY-1) 
					{
						if (loc1.pass_d.length) 
						{
							loc2=locs[i][j+1][0];
							n=Math.floor(Math.random()*loc1.pass_d.length);
							loc1.setDoor(loc1.pass_d[n].n,loc1.pass_d[n].fak);
							loc2.setDoor(loc1.pass_d[n].n+11,loc1.pass_d[n].fak);
						}
					}
					loc1.mainFrame();
				}
			}
			//sewer camp
			if (act.conf==2) newRandomProb(locs[3][0][0], act.landStage, true);
			//Manehattan camp
			if (act.conf==3 && act.landStage>=1) newRandomProb(locs[1][4][0], act.landStage, true);
			//arrange objects
			for (j=maxLocY-1; j>=minLocY; j--) 
			{
				for (i=minLocX; i<maxLocX; i++) 
				{
					var isBonuses=true;
					locs[i][j][0].setObjects();
					//Create checkpoints

					//Create exit points
					//factory and stable configuration
					if (act.conf==0 || act.conf==1) 
					{	
						if ((i+j)%2==0) 
						{
							if (j==maxLocY-1) 
							{
								if (act.conf==0 && act.landStage>=2 || act.conf==1 && act.landStage>=1) 
								{
									locs[i][j][0].createExit('1');		//Exit points on the lower level
								} 
								else 
								{
									locs[i][j][0].createExit();			//Exit points on the lower level
								}
							} 
							else locs[i][j][0].createCheck(i==act.begLocX && j==act.begLocY);	//checkpoints  
						} 
						else 
						{
							if (j==maxLocY-1) newRandomProb(locs[i][j][0], act.landStage, true);
							else if (Math.random()<0.3) newRandomProb(locs[i][j][0], act.landStage, false);
						}
					}
					//sewer and Canterlot configuration
					if (act.conf==2 || act.conf==5) 	//exit points on the right edge
					{
						if (i!=0 || j!=0) locs[i][j][0].createClouds(j);
						if (act.conf==2 && i==maxLocX-1) locs[i][j][0].createExit();
						if (act.conf==5 && i==maxLocX-1 && j==0) {
							if (act.landStage>=1) locs[i][j][0].createExit('1');
							else locs[i][j][0].createExit();
						} 
						else if ((i+j)%2==0) 
						{
							if (act.conf==2 && j<2 && i<maxLocX-1 || act.conf==5 && (i==0 || j>0)) locs[i][j][0].createCheck(i==act.begLocX && j==act.begLocY);
						}
						if (act.conf==2 && j>1) locs[i][j][0].petOn=false;
						if ((j>1 && i<maxLocX-1) || (act.conf==2 && i<maxLocX-1 && Math.random()<0.25)) 
						{
							if ((i+j)%2==1) newRandomProb(locs[i][j][0], act.landStage, false);
						}
					}
					//Manehattan configuration
					if (act.conf==3 && i!=2) 	//Exit points on the upper level
					{
						if ((i+j)%2==0) 
						{
							if (j==0) 
							{
								if (act.landStage>=1) locs[i][j][0].createExit('1');
								else locs[i][j][0].createExit();
							} 
							else locs[i][j][0].createCheck(i==act.begLocX && j==act.begLocY); 
						} 
						else 
						{
							if (j==0) newRandomProb(locs[i][j][0], act.landStage, true);
							else if (j!=4 && Math.random()<0.25) newRandomProb(locs[i][j][0], act.landStage, false);
						}	
					}
					// military base configuration
					if (act.conf==4) 
					{
						if (i==act.begLocX && j==act.begLocY || i==3) 
						{
							locs[i][j][0].createCheck(i==act.begLocX && j==act.begLocY);
							if (i==act.begLocX && j==act.begLocY) isBonuses=false;
						}
					}
					//bunker configuration
					if (act.conf==7) 
					{
						if (i==act.begLocX && j==act.begLocY) 
						{
							locs[i][j][0].createCheck(true);
							isBonuses=false;
						}
					}
					//enclave base configuration
					if (act.conf==6) 
					{
						opt.transpFon=true;
						if (j==0) {
							if (i==0 || i==2) 
							{
								if (act.landStage>=1) locs[i][j][0].createExit('1');
								else locs[i][j][0].createExit();
							}
							if (i==1) newRandomProb(locs[i][j][0], act.landStage, true);
						} 
						else if (i==act.begLocX && j==act.begLocY || i==((7-j)%3)) 
						{
							locs[i][j][0].createCheck(i==act.begLocX && j==act.begLocY);
						} 
						else if (Math.random()<0.25) newRandomProb(locs[i][j][0], act.landStage, false);
					}
					
					//stable configuration
					if (act.conf==10 || act.conf==11) 
					{
						if (i==act.begLocX && j==act.begLocY) 
						{
							locs[i][j][0].createCheck(true);
						}
					}
					locs[i][j][0].preStep();
					if (locs[i][j][1]) 
					{
						locs[i][j][1].mainFrame();
						locs[i][j][1].setObjects();
						locs[i][j][1].preStep();
					}
					if (isBonuses) locs[i][j][0].createXpBonuses(5);
					allXp+=locs[i][j][0].summXp;
				}
			}
			buildProbs();
			//Number of objects
			//trace('safe', kolAll['safe']+kolAll['wallsafe']);
			//trace('bookcase', kolAll['bookcase']);
			//trace('table2', kolAll['chest']);
			//trace('table', kolAll['table']);
			//trace('Сложность местности ',landDifLevel)
		}
		
		public function buildSpecifLand() 
		{
			var i, j, e;
			var loc1:Location;
			var loc2:Location;

			// Determine the actual sizes (of what, the room? the land?)
			for each(var room:Room in allRoom) 
			{
				if (room.rx < minLocX) minLocX = room.rx;
				if (room.ry < minLocY) minLocY = room.ry;
				if (room.rx + 1 > maxLocX) maxLocX = room.rx + 1;
				if (room.ry + 1 > maxLocY) maxLocY = room.ry + 1;
			}

			//create array (for?)
			locs = new Array();
			for (i = minLocX; i < maxLocX; i++) 
			{
				locs[i] = new Array();
				for (j = minLocY; j < maxLocY; j++) locs[i][j] = new Array();
			}

			//populate array with rooms from the allRoom.
			for each(room in allRoom) 
			{
				loc1 = newLoc(room, room.rx, room.ry, room.rz);
				locs[room.rx][room.ry][room.rz] = loc1;
			}

			//place objects
			for (i = minLocX; i < maxLocX; i++) 
			{
				for (j = minLocY; j < maxLocY; j++) 
				{
					for (e = minLocZ; e<maxLocZ; e++) 
					{
						if (locs[i][j][e] == null) continue;
						locs[i][j][e].setObjects();
						locs[i][j][e].preStep();
					}
				}
			}
			buildProbs();
		}
		
		//add trial rooms whose ids were used in the area (doors with prob={id} were involved)
		//process all added
		public function buildProbs() 
		{
			for each (var s in probIds)	buildProb(s);
			for each (var location in listLocs) 
			{
				location.setObjects();
				location.preStep();
				if (location.prob) location.prob.prepare();
			}
		}
		
		//create a test layer, return false if the layer already exists
		public function buildProb(nprob:String):Boolean 
		{
			if (probs[nprob] != null) return false;
			//create a single room
			var arrr:XML=World.w.game.probs['prob'].allroom;
			for each(var xml in arrr.room) 
			{
				if (xml.@name==nprob) 
				{
					var room:Room = new Room(xml);
					var location:Location = newLoc(room,0,0,0,{prob:nprob});
					location.landProb = nprob;
					location.noMap = true;
					var xmll = GameData.d.land.prob.(@id == nprob);
					if (xmll.length()) location.prob = new Probation(xmll[0],location);
					//add an exit door
					if (location.spawnPoints.length) 
					{
						location.createObj('doorout','box',location.spawnPoints[0].x,location.spawnPoints[0].y,<obj prob='' uid='begin'/>);
					}
					probs[nprob] = [[[location]]];
					listLocs.push(location);
					break;
				}
			}
			return true;
		}
		
		// Create a door and a random test room behind it, return false if none were found
		public function newRandomProb(nloc:Location, maxlevel:int=100, imp:Boolean=false):Boolean 
		{
			rndRoom=new Array();
			var impProb;
			for each(var xml in act.xmlland.prob) 
			{
				if (probs[xml.@id]==null && World.w.game.triggers['prob_'+xml.@id]==null && (xml.@level.length==0 || xml.@level<=maxlevel)) 
				{
					rndRoom.push(xml.@id);
					if (xml.@imp.length()) impProb=xml.@id;
				}
			}
			if (rndRoom.length==0) return false;
			var pid:String, did:String='doorprob';
			if (imp && impProb) pid=impProb;
			else if (rndRoom.length==1) pid=rndRoom[0];
			else pid=rndRoom[Math.floor(Math.random()*rndRoom.length)];
			try 
			{
				if (act.xmlland.prob.(@id==pid).@tip=='2') did='doorboss';
			} 
			catch (err) {};
			if (!nloc.createDoorProb(did,pid)) return false;
			buildProb(pid);
			//trace(pid);
			return true;
		}
		
		
		// create a new location of the specified type, at the given coordinates
		public function newTipLoc(ntip:String, nx:int, ny:int, opt:Object=null):Location 
		{
			rndRoom=new Array();
			for each(var room in allRoom) 
			{
				if (room.tip==ntip) rndRoom.push(room); 
			}
			if (rndRoom.length>0) 
			{
				room=rndRoom[Math.floor(Math.random()*rndRoom.length)];
			} 
			else 
			{
				room=allRoom[Math.floor(Math.random()*allRoom.length)];
				trace('нет локации '+ntip);
			}
			room.kol--;
			return newLoc(room, nx, ny, 0, opt);
		}
		
		//create a new random location in the given coordinates
		public function newRandomLoc(maxlevel:int, nx:int, ny:int, opt:Object=null, ntip:String=null):Location 
		{
			rndRoom=new Array();
			var r1:Room, r2:Room;
			if (nx>minLocX) r1=locs[nx-1][ny][0].room;
			if (ny>minLocY) r2=locs[nx][ny-1][0].room;
			//array of all rooms that meet the conditions
			for each(var room in allRoom) 
			{
				if (room.lvl<=maxlevel && room.kol>0 && room!=r1 && room!=r2 && (ntip==null && room.rnd || room.tip==ntip)) 
				{
					var rndKol=room.kol*room.kol;
					if (rndKol==4 && room.lvl==0 && maxlevel>1) 
					{
						rndKol=2;
					}
					for (var i=0; i<rndKol; i++) 
					{
						rndRoom.push(room);
					}
				}
			}
			if (rndRoom.length>0) {
				room=rndRoom[Math.floor(Math.random()*rndRoom.length)];
			} 
			else 
			{
				//array of all rooms suitable for random selection
				for each(room in allRoom) 
				{
					if (room.rnd) 
					{
						rndRoom.push(room);
					}
				}
				room=rndRoom[Math.floor(Math.random()*rndRoom.length)];
			}
			room.kol--;
			if (act.conf==4) room.kol=0;	//rooms on a military base are used only once
			return newLoc(room, nx, ny, 0, opt);
		}
		
		
		//create a new location based on the given Room template, at the specified coordinates
		public function newLoc(room:Room, nx:int, ny:int, nz:int=0, opt:Object=null):Location 
		{
			var location:Location=new Location(this, room.xml, rnd, opt);
			location.biom=act.biom;
			location.room=room;
			location.landX=nx;
			location.landY=ny;
			location.landZ=nz;
			location.id='location'+nx+'_'+ny;
			if (nz>0) location.id+='_'+nz;
			location.unXp=act.xp;
			
			// Set the difficulty level gradient
			var deep:Number=0;
			if (rnd) 
			{
				if (act.conf==0) deep=ny/2;	
				if (act.conf==1) deep=ny;
				if (act.conf==2) deep=ny*2.5;
			}
			setLocDif(location,deep);
			
			location.addPlayer(gg);
			return location;
		}
		
		// Setting the difficulty level of the location based on the character's level and difficulty gradient
		function setLocDif(location:Location, deep:Number) 
		{
			var ml:Number=landDifLevel+deep;
			location.locDifLevel=ml;
			location.locksLevel=ml*0.7;	// level of locks
			location.mechLevel=ml/4;		// level of mines and mechanisms
			location.weaponLevel=1+ml/4;	// level of encountered weapons
			location.enemyLevel=ml;		// level of enemies

			// influence of difficulty settings
			if (World.w.game.globalDif<2) location.earMult*=0.5;
			if (World.w.game.globalDif>2) location.enemyLevel+=(World.w.game.globalDif-2)*2;	// level of enemies based on difficulty
			// type of enemies
			if (act.biom==0 && Math.random()<0.25) location.tipEnemy=1;
			if (location.tipEnemy<0) location.tipEnemy=Math.floor(Math.random()*3);
			if (act.biom==1) location.tipEnemy=0;
			if (act.biom==2 && location.tipEnemy==1 && Math.random()<ml/20) location.tipEnemy=3;	// slave traders
			if (act.biom==3) 
			{
				location.tipEnemy=Math.floor(Math.random()*3)+3;			 // 4-mercenaries, 5-unicorns
			}
			if (ml>12 && (act.biom==0 || act.biom==2 || act.biom==3) && Math.random()<0.1) location.tipEnemy=6;	// zebras
			if (act.biom==4) location.tipEnemy=7;	// steel+robots
			if (act.biom==5) 
			{
				if (Math.random()<0.3) location.tipEnemy=5;
				else location.tipEnemy=8;	// pink
			}
			if (act.biom==6)  // || act.biom==11
			{
				if (Math.random()>0.3) location.tipEnemy=9;	// enclave
				else location.tipEnemy=10;// greyhounds
			}
			if (act.biom==11) location.tipEnemy=11; // enclave and greyhounds
			// number of enemies
			// type, minimum, maximum, random increase
			if (ml<4) 
			{
				location.setKolEn(1,3,5,2);
				location.setKolEn(2,2,4,0);
				location.setKolEn(3,3,4,2);
				location.setKolEn(4,1,2,0);
				location.setKolEn(5,1,4,2);
				if (location.tipEnemy==6) location.setKolEn(2,1,3,0);
				if (location.kolEnSpawn==0) 
				{
					if (location.tipEnemy!=5) location.setKolEn(-1,1,2);
				}
				location.kolEnHid=0;
			} 
			else if (ml<10) 
			{
				location.setKolEn(1,3,6,2);
				if (Math.random()<0.15) location.setKolEn(2,1,1,0);
				else if (location.tipEnemy==6) location.setKolEn(2,2,3,0);
				else location.setKolEn(2,2,5,0);
				location.setKolEn(3,3,5,2);
				location.setKolEn(4,2,3,1);
				location.setKolEn(5,2,4,2);
				if (location.kolEnSpawn==0) 
				{
					if (location.tipEnemy!=5) location.setKolEn(-1,2,3);
				}
				location.kolEnHid=Math.floor(Math.random()*3);
			} 
			else 
			{
				location.setKolEn(1,4,6,2);
				if (Math.random()<0.15) location.setKolEn(2,1,2,0);
				else if (location.tipEnemy==6) location.setKolEn(2,3,4,0);
				else location.setKolEn(2,3,6,0);
				location.setKolEn(3,4,7,2);
				location.setKolEn(4,2,4,1);
				location.setKolEn(5,3,6,2);
				if (location.kolEnSpawn==0) 
				{
					if (location.tipEnemy!=5) location.setKolEn(-1,2,4);
					else if (Math.random()>0.4) location.setKolEn(-1,1,3);
				}
				location.kolEnHid=Math.floor(Math.random()*4);
			}
			if (location.tipEnemy==5 || location.tipEnemy==10) 
			{
				location.setKolEn(2,1,3,1);
			}
			if (act.biom==11) 
			{
					location.setKolEn(2,5,8,0);
			}
		}
		
		public function createMap() 
		{
			map=new BitmapData(World.cellsX*(maxLocX-minLocX), World.cellsY*(maxLocY-minLocY),true,0);
		}
		
//==============================================================================================================================		
//				*** Functions ***
//==============================================================================================================================		
		
		//enter the land
		public function enterLand(first:Boolean=false, coord:String=null) 
		{
			act.visited=true;
			
			if (coord!=null) 
			{
				var narr:Array=coord.split(':');
				if (narr.length>=1) locX=narr[0]; else locX=0;
				if (narr.length>=2) locY=narr[1]; else locY=0;
				locZ=0;
				prob='';
				ativateLoc();
				setGGToSpawnPoint();
			} 
			else if (currentCP && !first) 
			{
				World.w.pers.currentCP=currentCP;
				//trace('currentCP', currentCP);
				gotoCheckPoint();
				currentCP.activate();
			} 
			else 
			{
				locX=act.begLocX;
				locY=act.begLocY;
				locZ=0;
				prob='';
				ativateLoc();
				setGGToSpawnPoint();
			}
		}
		
		public function saveObjs(arr:Array) 
		{
			if (rnd) return;
			for (var i=minLocX; i<maxLocX; i++) 
			{
				for (var j=minLocY; j<maxLocY; j++) 
				{
					for (var e=minLocZ; e<maxLocZ; e++) 
					{
						if (locs[i][j][e]==null) continue;
						locs[i][j][e].saveObjs(arr);
					}
				}
			}
		}
		
		//Move the character to the spawn point
		public function setGGToSpawnPoint() 
		{
			var nx:int=3, ny:int=3;
			if (location.spawnPoints.length>0) 
			{
				var n=Math.floor(Math.random()*location.spawnPoints.length);
				nx=location.spawnPoints[n].x;
				ny=location.spawnPoints[n].y;
			}
			gg.setLocPos((nx+1)*Tile.tilePixelWidth, (ny+1)*Tile.tilePixelHeight-1);
			gg.dx=3;
			location.lighting(gg.X, gg.Y-75);
		}
		
		//Activate the location with the current coordinates
		public function ativateLoc():Boolean 
		{
			var nloc:Location;

			if (prob != '' && probs[prob] == null)  return false;
			try 
			{
				if (prob!='') nloc = probs[prob][locX][locY][locZ];	
				else nloc = locs[locX][locY][locZ];
			} 
			catch (err) 
			{
				trace('Location not found', act.id, locX, locY, locZ)
				nloc=locs[0][0][0];
			}
			
			if (location==nloc) return false;
			locN++; //increment transition timer by 1. (Default is 0)
			prevloc = location; //Set prevloc variable as the current location.
			location = nloc; //Set the current location as the location being loaded.
			gg.inLoc(location);
			location.reactivate(locN);
			World.w.ativateLoc(location);
			if (location.sky) 
			{
				gg.isFly=true;
				gg.stay=false;
				World.w.cam.setZoom(2);
			}
			location.lightAll();
			return true;
		}
		
		//Go to location x,y
		public function gotoXY(nx:int,ny:int) 
		{
			if (nx<minLocX) nx=minLocX;
			if (nx>=maxLocX) nx=maxLocX-1;
			if (ny<minLocY) ny=minLocY;
			if (ny>=maxLocY) ny=maxLocY-1;
			locX=nx;
			locY=ny;
			locZ=0;
			ativateLoc();
			setGGToSpawnPoint();
		}
		
		
		//Transition between locations
		public function gotoLoc(napr:int, portX:Number=-1, portY:Number=-1):Object 
		{
			var X:Number=gg.X, Y:Number=gg.Y, scX:Number=gg.scX, scY:Number=gg.scY;
			var newX:int=locX, newY:int=locY, newZ:int=locZ;
			if (napr==1) newX--;
			else if (napr==2) newX++;
			else if (napr==3) newY++;
			else if (napr==4) newY--;
			else if (napr==5) newZ=1-newZ;
			else return null;

			if (prob=='' && (locs[newX]==null || locs[newX][newY]==null || locs[newX][newY][newZ]==null)) 
			{
				if (napr==3) return {die:true};
				return null;
			}

			if (prob!='' && (probs[prob][newX]==null || probs[prob][newX][newY]==null || probs[prob][newX][newY][newZ]==null)) 
			{
				if (napr==3) return {die:true};
				return null;
			}

			var newLoc:Location = locs[newX][newY][newZ];
			var outP:Object=new Object();

			if (napr==1) 
			{
				outP.x=newLoc.limX-scX/2-9;
				outP.y=Y-1;
			} 
			else if (napr==2) 
			{
				outP.x=0+scX/2+9;
				outP.y=Y-1;
			} 
			else if (napr==3) 
			{
				outP.x=X;
				outP.y=0+scY+10;
			} 
			else if (napr==4) 
			{
				outP.x=X;
				outP.y=newLoc.limY-10;
			} 
			else if (napr==5) 
			{
				outP.x=portX;
				outP.y=portY;
			}

			if (newLoc.collisionUnit(outP.x,outP.y,scX-4,scY)) return null;
			
			loc_t=150;
			locX=newX, locY=newY, locZ=newZ;
			ativateLoc();
			gg.setLocPos(outP.x,outP.y);
			return outP;
		}
		
		// Go to the test layer nprob, or return to the main layer if the parameter is not specified
		public function gotoProb(nprob:String='', nretX:Number=-1, nretY:Number=-1) 
		{
			if (nprob=='') 
			{
				prob='';
				locX=retLocX;
				locY=retLocY;
				locZ=retLocZ;
				ativateLoc();
				if (retX==0 && retY==0) setGGToSpawnPoint();
				else gg.setLocPos(retX,retY);
			}
			else 
			{
				retLocX=locX, retLocY=locY, retLocZ=locZ;
				if (nretX<0 || nretY<0) 
				{
					retX=gg.X, retY=gg.Y;
				} 
				else 
				{
					retX=nretX, retY=nretY;
				}
				prob=nprob;
				locX=locY=locZ=0;
				if (ativateLoc()) 
				{
					setGGToSpawnPoint();
				} 
				else 
				{
					prob='';
					locX=retLocX;
					locY=retLocY;
					locZ=retLocZ;
				}
			}
		}
		
		public function gotoCheckPoint() 
		{
			var cp:CheckPoint=World.w.pers.currentCP;
			if (cp==null) 
			{
				gg.setNull();
				return;
			}
			if (cp.location.land!=this && currentCP)	
			{
				cp=currentCP;
				World.w.pers.currentCP=currentCP;
				currentCP.activate();
			}
			if (cp.location.land!=this) 
			{
				locX=act.begLocX;
				locY=act.begLocY;
				locZ=0;
				prob='';
				if (!ativateLoc()) location.reactivate();
				setGGToSpawnPoint();
			} 
			else 
			{
				locX=cp.location.landX;
				locY=cp.location.landY;
				locZ=cp.location.landZ;
				prob=cp.location.landProb;
				if (!ativateLoc()) location.reactivate();
				gg.setLocPos(cp.X,cp.Y);
			}
			gg.dx=3;
		}
		
		public function refill() 
		{
			if (isRefill) return;
			if (summXp*10>allXp || !rnd) 
			{
				World.w.game.refillVendors();
				isRefill=true;
			} 
			else 
			{
				trace('Experience obtained: ',summXp,allXp);
			}
		}
		
		public function artBabah() 
		{
			Snd.ps('artfire');
			World.w.quake(10,3);
		}
		
		public function artStep() 
		{
			art_t--;
			if (art_t<=0) 
			{
				art_t=Math.floor(Math.random()*1000+20);
				if (act.artFire!=null && World.w.game.triggers[act.artFire]!=1) 
				{
					artBabah();
				}
			}
		}
		
		public function drawMap():BitmapData 
		{
			map.fillRect(map.rect,0x00000000);
			for (var i=minLocX; i<maxLocX; i++) 
			{
				for (var j=minLocY; j<maxLocY; j++) 
				{
					if (locs[i][j][0]!=null && (World.w.drawAllMap || locs[i][j][0].visited)) locs[i][j][0].drawMap(map);
				}
			}
			ggX=(location.landX-minLocX)*World.cellsX*World.tilePixelWidth+gg.X;
			ggY=(location.landY-minLocY)*World.cellsY*World.tilePixelHeight+gg.Y-gg.scY/2;
			return map;
		}
		
		//Kill all enemies and open all containers
		public function getAll():int 
		{
			var summ:int=0;
			for (var i=minLocX; i<maxLocX; i++) 
			{
				for (var j=minLocY; j<maxLocY; j++) 
				{
					for (var e=minLocZ; e<maxLocZ; e++) 
					{
						if (locs[i][j][e]==null) continue;
						summ+=locs[i][j][e].getAll();
					}
				}
			}
			return summ;
		}
		
		public function step() 
		{
			if (!World.w.catPause) 
			{
				location.step();
				if (loc_t>0) 
				{
					loc_t--;
					if (prevloc && location!=prevloc) prevloc.stepInvis();
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