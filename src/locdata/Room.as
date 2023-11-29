package locdata 
{
	import flash.geom.ColorTransform;
	import flash.display.MovieClip;
	import flash.display.BitmapData;

	import unitdata.Unit;
	import unitdata.UnitPlayer;
	import unitdata.UnitPhoenix;
	import unitdata.UnitTransmitter;
	import graphdata.*;
	import weapondata.Bullet;
	import servdata.LootGen;
	import servdata.Item;
	import unitdata.UnitTurret;
	
	import components.Settings;
	import components.XmlBook;
	
	import stubs.signPost;
	
	public class Room 
	{
		
		public var level:Level;
		
		public var id:String;					// Room ID
		public var roomTemplate:RoomTemplate;	// Linked room template
		public var prob:Probation;				// Linked trial
		
		//Dimensions and Position
		public var roomWidth:int;			// Size of the room in tiles.
		public var roomHeight:int;			// Size of the room in tiles.
		public var roomPixelWidth:int;		// Size of the room in pixels.
		public var roomPixelHeight:int;		// Size of the room in pixels.
		public var roomCoordinateX:int = 0;	
		public var roomCoordinateY:int = 0;
		public var roomCoordinateZ:int = 0;
		public var levelProb:String = '';
		public var bindRoom:Room;	// Bound by coordinate z ???
		public var base:Boolean = false;	// Base camp
		public var train:Boolean = false;	// Training ground
		public var black:Boolean = true;	// Fog of war
		
		
		// Objects
		public var grafon:Grafon;
		public var roomTileArray:Array;		// Room tile array
		public var otstoy:Tile;			// Empty tile
		public var units:Array;			// Array of Units
		public var ups:Array;			// Spawn random units
		public var objs:Array;			// Array of active objects
		public var bonuses:Array;		// Array of Bonuses
		public var areas:Array;			// Array of Areas
		public var activeObjects:Array;	// Array of Active objects (displayed on the map)
		public var saves:Array;			// Array of Objects subject to saving
		public var backobjs:Array;		// Array of Background objects
		public var grenades:Array;		// Array of Active grenades
		public var gg:UnitPlayer;
		public var celObj:Obj;
		public var celDist:Number =- 1;	// Target object and distance to it
		public var unitCoord;			// Object for unit coordination
		
		// Entrances and Visits
		public var spawnPoints:Array;	// Spawn points
		public var enspawn:Array;		// Enemy spawn points
		public var doors:Array;			// Passages to other locations
		public var signposts:Array, sign_vis:Boolean=true;		// Exit indicators
		public var nAct:int=0;			// Last visit
		public var roomActive:Boolean = false;		// Currently active
		public var visited:Boolean=false;		// Visited
		
		// Service
		public var cp:CheckPoint;
		public var pass_r:Array, pass_d:Array;		// Passages to other locations
		//public var unitsT:Array;			// Units
		public var objsT:Array;				// Active objects
		public var recalcTiles:Array;		// Recalculate water
		public var firstObj:Pt, nextObj:Pt, lastObj:Pt;	// Execution chain
		public var isRebuild:Boolean=false, isRecalc:Boolean=false, isRelight:Boolean=false, relight_t:int;
		public var warning:int=0;			// Dangers like thrown grenades exist
		public var t_gwall:int=0;	// Transparent walls exist
		public var lDist1:int = 300, lDist2:int = 1000;	// Fog of war reveal distance
		public var quake:int = 0;
		public var broom:Boolean=false;		// All loot will be automatically picked up
		public var isCheck:Boolean=false;	// Checkpoint, exit point, or trial door was created
		
		// Options
		public var noHolesPlace:Boolean = true;	// Remove containers near passages
		public var ramka:int = 0;					// Frame made of blocks around the perimeter: 1 - entire perimeter, 2 - sides only, 3 - bottom only, 4 - bottom and sides
		public var bezdna:Boolean = false;		// Falling leads downward
		public var mirror:Boolean = false;		// Mirror room
		public var sky:Boolean = false;
		public var zoom:Number = 1;
		
		// Settings
		public var gas:int = 0;					// Special texture
		public var maxdy:Number = 20;
		public var rad:Number = 0;				// Air radioactivity
		public var wrad:Number = 1;				// Water radioactivity
		public var wdam:Number = 0;				// Water damage
		public var wtipdam:int = 7;
		public var tipWater:int = 0;				// Water appearance
		public var opacWater:Number = 0;			// Water opacity
		public var waterLevel:int = 100;			// Water level
		public var backwall:String = '';			// Background wall
		public var backform:int = 0;				// Background wall shape: 0 - filled, 1 - side parts, 2 - bottom part
		public var transparentBackground:Boolean = false;		// Transparent background
		public var cTransform:ColorTransform;
		public var cTransformFon:ColorTransform;
		public var color:String;
		public var colorfon:String;
		public var sndMusic:String = 'music_0';
		public var postMusic:Boolean = false;		// Music does not switch to combat
		public var homeStable:Boolean = false;	
		public var homeAtk:Boolean = false;	
		public var visMult:Number = 1;
		public var noMap:Boolean = false;			// Map is unavailable
		public var darkness:int = 0;				// Background darkening
		public var lightOn:int = 0;				// If greater than 0 - light is on, less - off
		public var retDark:Boolean = false;		// Fog of war will be restored
		public var levitOn:Boolean = true;		// Levitation is allowed
		public var portOn:Boolean = true;			// Teleportation is allowed
		public var petOn:Boolean = true;			// Pet is allowed
		public var destroyOn:Boolean = true;		// Wall destruction is allowed
		public var itemsTip:String;				// Special loot type
		public var electroDam:Number = 0;
		public var trus:Number = 0;				// Constant shaking
		
		// Enemies
		public var tipEnemy:int = -1;				// Type of random enemies
		public var kolEn:Array = [0,6,4,6,4,6]; // Number of random small enemies: 0, small crawling, normal, flying, ceiling, trap
		var tipEn:Array=['','enl1','enl2','enf1','enc1','lov'];
		public var tipSpawn:String = 'enl2';
		public var kolEnSpawn:int = 0;		// Normal enemies may spawn
		public var tileSpawn:Number = 0;		// Spawn when breaking blocks
		public var kolEnHid:int = 3;			// Hidden normal enemies
		public var kol_phoenix:int = 0;
		
		public var detecting:Boolean = false;
		public var t_alarm:int = 0;			// Alarm counter
		public var t_alarmsp:int = 0;			// Enemy spawn counter
		
		// Bonuses and Experience
		public var kolXp:int = 0;
		public var maxXp:int = 0;
		public var unXp:int = 100;
		public var summXp:int = 0;
		
		// Difficulty Level
		public var locDifLevel:Number = 0;
		public var biom:int = 0;
		public var locksLevel:Number = 0;		// Locks level 0-25
		public var mechLevel:Number = 0;		// Mines and mechanisms level 0-7
		public var weaponLevel:Number = 0;	// Level of randomly dropped weapons
		public var enemyLevel:int = 0;		// Enemy level
		public var earMult:Number = 1; 		// Mob hearing multiplier
		
		
		
		
		
		
		
		
//**************************************************************************************************************************
//
//				Creation
//
//**************************************************************************************************************************


// ------------------------------------------------------------------------------------------------
// First stage - create and build according to the map from xml

		public function Room(l:Level, nroom:XML, rnd:Boolean, opt:Object=null) 
		{
			level = l;
			roomWidth = Settings.roomTileWidth;
			roomHeight = Settings.roomTileHeight;
			roomPixelWidth = roomWidth * Settings.tilePixelWidth;
			roomPixelHeight = roomHeight * Settings.tilePixelHeight;
			otstoy=new Tile(-1,-1);

			units 			= new Array();
			ups 			= new Array();
			objs 			= new Array();
			activeObjects 	= new Array();
			areas 			= new Array();
			saves 			= new Array();
			enspawn 		= new Array();
			backobjs 		= new Array();
			roomTileArray 	= new Array();
			signposts 		= new Array();
			recalcTiles 	= new Array();
			spawnPoints 	= new Array();
			grenades 		= new Array();
			bonuses 		= new Array();
			maxdy 			= Settings.maxdy;

			if (rnd) ramka=1;
			if (opt) 
			{
				if (opt.prob) ramka = 0;
				if (opt.mirror) mirror = true;
				if (opt.water != null) waterLevel = opt.water;
				if (opt.ramka != null) ramka = opt.ramka;
				if (ramka == 5) backform = 1;
				if (ramka == 6) backform = 2;
				if (opt.backform) backform = opt.backform;
				if (opt.transparentBackground) transparentBackground = opt.transparentBackground;
				if (opt.home) homeStable = true;
				if (opt.atk) homeAtk = true;
			}
			for (var i = 0; i < kolEn.length; i++) ups[i] = new Array();
			noHolesPlace = rnd;
			
			buildLoc(nroom);
		}

		// Add the player character to the units array
		public function addPlayer(un:UnitPlayer) 
		{
			gg = un;
			units.push(un);
			units.push(un.defpet);
		}
		
		// Build according to the xml map
		public function buildLoc(nroom:XML) 
		{
			// Create an array of tiles
			for (var i = 0; i < roomWidth; i++) 
			{
				roomTileArray[i] = new Array();
				for (var j = 0; j < roomHeight; j++) 
				{
					roomTileArray[i][j] = new Tile(i,j);
				}
			}

			// Options
			backwall 	= level.template.backwall;
			sndMusic  	= level.template.sndMusic;
			postMusic 	= level.template.postMusic;
			rad 		= level.template.rad;
			wrad 		= level.template.wrad;
			wdam 		= level.template.wdam;
			wtipdam 	= level.template.wtipdam;
			tipWater 	= level.template.tipWater;
			color 		= level.template.color;
			visMult 	= level.template.visMult;
			opacWater 	= level.template.opacWater;
			darkness 	= level.template.darkness;
			if (nroom.options.length()) 
			{
				if (nroom.options.@backwall.length()) backwall=nroom.options.@backwall;
				if (nroom.options.@backform.length()) backform=nroom.options.@backform;
				if (nroom.options.@transparentBackground.length()) transparentBackground=true;
				if (nroom.options.@music.length()) sndMusic=nroom.options.@music;
				if (nroom.options.@rad.length()) rad=nroom.options.@rad;
				if (nroom.options.@wrad.length()) wrad=nroom.options.@wrad;
				if (nroom.options.@wtip.length()) tipWater=nroom.options.@wtip;
				if (nroom.options.@wopac.length()) opacWater=nroom.options.@wopac;
				if (nroom.options.@wdam.length()) wdam=nroom.options.@wdam;
				if (nroom.options.@wtipdam.length()) wtipdam=nroom.options.@wtipdam;
				if (nroom.options.@bezdna.length()) bezdna=true;
				if (nroom.options.@wlevel.length()) waterLevel=nroom.options.@wlevel;
				if (nroom.options.@base.length()) base=true;
				if (nroom.options.@noblack.length()) black=false;
				if (nroom.options.@train.length()) train=true;
				if (nroom.options.@color.length()) color=nroom.options.@color;
				if (nroom.options.@colorfon.length()) colorfon=nroom.options.@colorfon;
				if (nroom.options.@vis.length()) visMult=nroom.options.@vis;
				if (nroom.options.@nomap.length()) noMap=true;
				if (nroom.options.@entip.length()) tipEnemy=nroom.options.@entip;
				if (nroom.options.@lon.length()) lightOn=nroom.options.@lon;
				if (nroom.options.@dark.length()) darkness=nroom.options.@dark;
				if (nroom.options.@retdark.length()) retDark=true;
				if (nroom.options.@levitoff.length()) levitOn=false;
				if (nroom.options.@portoff.length()) portOn=false;
				if (nroom.options.@desoff.length()) destroyOn=false;
				if (nroom.options.@petoff.length()) petOn=false;
				if (nroom.options.@spawn.length()) tipSpawn=nroom.options.@spawn;
				if (nroom.options.@kolspawn.length()) kolEnSpawn=nroom.options.@kolspawn;
				if (nroom.options.@tilespawn.length()) tileSpawn=nroom.options.@tilespawn;
				if (nroom.options.@items.length()) itemsTip=nroom.options.@items;
				if (nroom.options.@maxdy.length()) maxdy=nroom.options.@maxdy;
				if (nroom.options.@sky.length())  sky=true;
				if (nroom.options.@zoom.length()) zoom=nroom.options.@zoom;
				if (nroom.options.@trus.length()) trus=nroom.options.@trus;
				if (!black) 
				{
					for (i = 0; i < roomWidth; i++) 
					{
						for (j  =0; j < roomHeight; j++) 
						{
							(roomTileArray[i][j] as Tile).visi = 1;
						}
					}
				}
			}
			if (homeStable) 
			{
				color = 'yellow';
				lightOn = 1;
				base = true;
			}
			if (homeAtk) 
			{
				color = 'fire';
				lightOn = 1;
			}

			// Create a room. (I think this part works correctly.)
			for (j = 0; j < roomHeight; j++) //Build the room from XML Data.
			{ 
				var js:String = ''; //XML data as string
				js = nroom.a[j];
				var arri:Array = js.split('.'); //Demarcates the room into tiles.
				for (i = 0; i < roomWidth; i++) 
				{
					var jis:String;
					if (mirror) 
					{
						jis = arri[roomWidth - i - 1];
					} 
					else 
					{
						jis = arri[i];
					}
					if (jis == null) jis='';
					roomTileArray[i][j].parseLevelXML(jis, mirror);
					if (roomTileArray[i][j].stair != 0) // Shelf on top of the ladder
					{  
						if (j > 0 && roomTileArray[i][j].phis == 0 && !roomTileArray[i][j].shelf && roomTileArray[i][j].stair != roomTileArray[i][j - 1].stair) 
						{
							roomTileArray[i][j].shelf = true;
							roomTileArray[i][j].vid++;
						}
					}
					// Water line
					if (j >= waterLevel) roomTileArray[i][j].water = 1;
					// Frame
					if (i == 0 || i == roomWidth - 1 || j == 0 || j == roomHeight - 1) 
					{
						if (ramka == 1
							|| (ramka == 2 || ramka == 4) && (i == 0 || i == roomWidth - 1)
							|| (ramka == 3 || ramka == 4) && (j == roomHeight - 1)
							|| ramka == 5 && (i <= 10 || i >= 37)
							|| ramka == 6 && j >= 16
							|| ramka == 7 && (i <= 10 || i >= 37) && j >= 16
							|| ramka == 8 && (i == roomWidth-1)
						) roomTileArray[i][j].phis = 1;
						else if (roomTileArray[i][j].phis >= 1) roomTileArray[i][j].indestruct = true;
					}
				}
			}
			
			// Possible passages to other locations
			if (nroom.doors.length() > 0) 
			{
				var s:String=nroom.doors[0];
				doors=s.split('.');
				if (mirror) {
					var d;
					d = doors[6];
					doors[6] = doors[10];
					doors[10] = d;
					d = doors[7];
					doors[7] = doors[9];
					doors[9] = d;
					d = doors[17];
					doors[17] = doors[21];
					doors[21] = d;
					d = doors[18];
					doors[18] = doors[20];
					doors[20] = d;
					for (i = 0; i <= 5; i++) 
					{
						d = doors[i];
						doors[i] = doors[i + 11];
						doors[i + 11] = d;
					}
				}
			} 
			else 
			{
				doors = new Array();
				for (i = 0; i < 22; i++) doors[i] = 2;
			}
			
			// Visibility
			lDist1 *= visMult;
			lDist2 *= visMult;
			if (isNaN(lDist1)) 
			{
				lDist1 = 300;
				lDist2 = 1000;
			}
			// Color filter
			cTransform = colorFilter(color);
			if (colorfon) cTransformFon=colorFilter(colorfon);
			
			// Object spawnpoints
			objsT = new Array();
			for each(var obj:XML in nroom.obj) 
			{
				var xmll:XML = XmlBook.getXML("objects").obj.(@id == obj.@id)[0];
				var size:int = xmll.@size;
				if (size <= 0) size = 1;
				var nx:int = obj.@x;
				var ny:int = obj.@y;
				if (mirror) nx = roomWidth - nx - size;
				if (xmll.@tip == 'spawnpoint') spawnPoints.push({x:nx, y:ny});
				else if (xmll.@tip == 'enspawn') addEnSpawn(nx, ny, xmll);
				else if (xmll.@tip == 'up') 
				{
					var n:int = xmll.@tipn;
					ups[n].push({x:nx, y:ny, xml:obj});
				} 
				else objsT.push({id:obj.@id, tip:xmll.@tip, rem:xmll.@rem, x:nx, y:ny, xml:obj})
			}
			
			// Background objects
			for each(obj in nroom.back) 
			{
				backobjs.push(new BackObj(this, obj.@id,obj.@x * Tile.tilePixelWidth, obj.@y*Tile.tilePixelHeight, obj));
			}

			if (zoom > 1) 
			{
				roomPixelWidth  *= zoom;
				roomPixelHeight *= zoom;
			}
		}
		
		// Color filter
		public function colorFilter(filter:String=''):ColorTransform 
		{
			
			var colorT = new ColorTransform();
			var red:Number;
			var green:Number;
			var blue:Number;
			
			var lookup:Object = 
			{
				'green': function():void
				{
            		red = 0.8;
					green = 1.16;
					blue = 0.8;
        		},
				'red': function():void
				{
            		red = 1.1;
					green = 0.9;
					blue = 0.7;
        		},
				'fire': function():void
				{
            		red = 1.1;
					green = 0.7;
					blue = 0.5;
        		},
				'lab': function():void
				{
            		red = 0.9;
					green = 1.1;
					blue = 0.7;
        		},
				'black': function():void
				{
            		red = 0.5;
					green = 0.7;
					blue = 0.6;
        		},
				'blue': function():void
				{
            		red = 0.8;
					green = 0.8;
					blue = 1.16;
        		},
				'sky': function():void
				{
            		red = 0.85;
					green = 1.12;
					blue = 1.12;
        		},
				'yellow': function():void
				{
            		red = 1.25;
					green = 1.2;
					blue = 0.9;
        		},
				'purple': function():void
				{
            		red = 1.08;
					green = 0.8;
					blue = 1.12;
        		},
				'pink': function():void
				{
            		red = 1.1;
					green = 0.9;
					blue = 1;
        		},
				'blood': function():void
				{
            		red = 1.08;
					green = 0.6;
					blue = 1.08;
        		},
				'blood2': function():void
				{
            		red = 1;
					green = 0.1;
					blue = 0.1;
        		},
				'dark': function():void
				{
            		red = 0;
					green = 0;
					blue = 0;
        		},
				'mf': function():void
				{
            		red = 0.5;
					green = 0.5;
					blue = 1.08;
        		}
			}

			if (lookup.hasOwnProperty(filter)) 
			{
        		lookup[filter]();
				colorT.redMultiplier 	= red;
				colorT.greenMultiplier 	= green;
				colorT.blueMultiplier 	= blue;
    		}

			return colorT;
		}
		
// ------------------------------------------------------------------------------------------------
// Second stage - determine passages, create a frame, and create objects based on difficulty and passages

		// Add a transition with number n
		public function setDoor(n:int, fak:int = 2):void
		{
			var q:int;
			if (fak < 2) return;
			var dyr:Boolean = false;
			if (n > 21) return;
			else if (n >= 17) 
			{
				q=(n-17)*9+4;
				dyr=roomTileArray[q+1][0].hole() || dyr;
				dyr=roomTileArray[q+2][0].hole() || dyr;
				roomTileArray[q+1][1].hole();
				roomTileArray[q+2][1].hole();
				setNoObj(q+1,0,0,2);
				setNoObj(q+2,0,0,2);
				if (fak>2) 
				{
					dyr=roomTileArray[q][0].hole() || dyr;
					dyr=roomTileArray[q+3][0].hole() || dyr;
					roomTileArray[q][1].hole();
					roomTileArray[q+3][1].hole();
					setNoObj(q,0,0,2);
					setNoObj(q+3,0,0,2);
				}
				if (dyr) addSignPost(q+2,0,-90);
			} 
			else if (n>=11) 
			{
				q=(n-11)*4+3;
				dyr=roomTileArray[0][q].hole() || dyr;
				dyr=roomTileArray[0][q-1].hole() || dyr;
				roomTileArray[1][q].hole();
				roomTileArray[1][q-1].hole();
				setNoObj(0,q,5,0);
				setNoObj(0,q-1,5,0);
				if (fak>2) 
				{
					dyr=roomTileArray[0][q-2].hole() || dyr;
					roomTileArray[1][q-2].hole();
				} 
				if (dyr) addSignPost(0,q,180);
				addEnSpawn(Tile.tilePixelWidth, (q+1)*Tile.tilePixelHeight-1);
			} 
			else if (n>=6) 
			{
				q=(n-6)*9+4;
				dyr=roomTileArray[q+1][roomHeight-1].hole() || dyr;
				dyr=roomTileArray[q+2][roomHeight-1].hole() || dyr;
				roomTileArray[q+1][roomHeight-2].hole();
				roomTileArray[q+2][roomHeight-2].hole();
				setNoObj(q+1,roomHeight-1,0,-2);
				setNoObj(q+2,roomHeight-1,0,-2);
				if (fak>2) 
				{
					dyr=roomTileArray[q][roomHeight-1].hole() || dyr;
					dyr=roomTileArray[q+3][roomHeight-1].hole() || dyr;
					roomTileArray[q][roomHeight-2].hole();
					roomTileArray[q+3][roomHeight-2].hole();
					setNoObj(q,roomHeight-1,0,-2);
					setNoObj(q+3,roomHeight-1,0,-2);
				} 
				if (dyr) addSignPost(q+2,roomHeight,90);
			} 
			else if (n>=0) 
			{
				q=(n)*4+3;
				dyr=roomTileArray[roomWidth-1][q].hole() || dyr;
				dyr=roomTileArray[roomWidth-1][q-1].hole() || dyr;
				roomTileArray[roomWidth-2][q].hole();
				roomTileArray[roomWidth-2][q-1].hole();
				setNoObj(roomWidth-1,q,-5,0);
				setNoObj(roomWidth-1,q-1,-5,0);
				if (fak>2) 
				{
					dyr=roomTileArray[roomWidth-1][q-2].hole() || dyr;
					roomTileArray[roomWidth-2][q-2].hole();
				} 
				if (dyr) addSignPost(roomWidth,q,0);
				addEnSpawn((roomWidth-1)*Tile.tilePixelWidth, (q+1)*Tile.tilePixelHeight-1);
			} 
			else return;
		}
		
		// Add transition indicators to neighboring locations
		private function addSignPost(nx:int,ny:int,r:int):void
		{
			var sign:MovieClip;
			sign = new signPost();
			sign.x=nx*Tile.tilePixelWidth;
			sign.y=ny*Tile.tilePixelHeight;
			sign.rotation=r;
			signposts.push(sign);
		}
		
		// Add enemy spawn points
		private function addEnSpawn(nx:Number, ny:Number, xmll:XML=null):void
		{
			var obj:Object=new Object();
			if (xmll) 
			{
				var size:int=xmll.@size;
				if (size<=0) size=1;
				obj.x=(nx+0.5*size)*Tile.tilePixelWidth;
				obj.y=(ny+1)*Tile.tilePixelHeight-1;
			} 
			else 
			{
				obj.x = nx;
				obj.y = ny;
			}
			enspawn.push(obj);
		}
		
		// Add places where there should be no containers (near passages)
		private function setNoObj(nx:int, ny:int, dx:int, dy:int):void
		{
			var i:int;
			if (dx>0) for (i=nx; i<=nx+dx; i++) roomTileArray[i][ny].place=false;
			if (dx<0) for (i=nx+dx; i<=nx; i++) roomTileArray[i][ny].place=false;
			if (dy>0) for (i=ny; i<=ny+dy; i++) roomTileArray[nx][i].place=false;
			if (dy<0) for (i=ny+dy; i<=ny; i++) roomTileArray[nx][i].place=false;
		}
		
		
		// Main frame, call after creating passages
		public function mainFrame():void
		{
			var border:String='A';
			if (level && level.template) border=level.template.border;
			for (var j=0; j<roomWidth; j++) 
			{
				if (roomTileArray[j][0].phis>=1) roomTileArray[j][0].mainFrame(border);
				if (roomTileArray[j][roomHeight-1].phis>=1) roomTileArray[j][roomHeight-1].mainFrame(border);
			}
			for (j=0; j<roomHeight; j++) 
			{
				if (roomTileArray[0][j].phis>=1) roomTileArray[0][j].mainFrame(border);
				if (roomTileArray[roomWidth-1][j].phis>=1) roomTileArray[roomWidth-1][j].mainFrame(border);
			}
		}
		
		// Create active objects in their spawn locations, except for places near passages, call after creating passages
		public function setObjects():void
		{
			for each (var obj in objsT) 
			{
				if (noHolesPlace && obj.rem>0 && !roomTileArray[obj.x][obj.y].place) continue;	/// Do not place boxes near passages
				if (obj.tip=='unit') createUnit(obj.id,obj.x,obj.y, false, obj.xml);
				else createObj(obj.id, obj.tip, obj.x,obj.y, obj.xml);
			}
			objsT=null;
			setRandomUnits();
			if (level.rnd && World.world.pers.modMetal>0 && Math.random()<World.world.pers.modMetal) putRandomLoot();
		}
		
		// Set the number of random enemies
		public function setKolEn(en:int, min:int, max:int, spl:int=0):void
		{
			if (en==-1) 
			{
				kolEnSpawn=min+Math.floor(Math.random()*(max-min+1));
			} 
			else 
			{
				kolEn[en]=min+Math.floor(Math.random()*(max-min+1));
				if (spl>0 && Math.random()<0.2) kolEn[en]+=spl;
			}
		}
		
		// Create random enemies in their spawn points
		public function setRandomUnits():void
		{
			for (var i=1; i<kolEn.length; i++) 
			{
				if (kolEn[i]>0 && ups[i].length) 
				{
					// Remove points near passages
					if (noHolesPlace) 
					{
						for (var j=0; j<ups[i].length; j++) 
						{
							if (!roomTileArray[ups[i][j].x][ups[i][j].y].place) 
							{
								ups[i].splice(j,1);
								j--;
							}
						}
					}
					if (ups[i].length > 0) 
					{
						for (j=0; j<kolEn[i]; j++) 
						{
							var n=Math.floor(Math.random()*ups[i].length);
							createUnit(tipEn[i],ups[i][n].x,ups[i][n].y, false, ups[i][n].xml);
							if (ups[i].length <= 1) 
							{
								ups[i]=[];
								break;
							} 
							else ups[i].splice(n,1);
						}
					}
				}
			}
			// Add hidden enemies
			if (kolEnHid>0 && ups[2].length > 0) 
			{
				for (j=0; j<kolEnHid; j++) 
				{
					n=Math.floor(Math.random()*ups[2].length );
					createHidden(ups[2][n].x,ups[2][n].y);
					if (ups[2].length <= 1) break;
					else ups[2].splice(n,1);
				}
			}
		}
		
		// Create random loot
		public function putRandomLoot():void
		{
			var nx:int=Math.floor(Math.random()*(roomWidth-2)+1);
			var ny:int=Math.floor(Math.random()*(roomHeight-2)+1);
			if (roomTileArray[nx][ny].phis==0) 
			{
				LootGen.lootCont(this,(nx+0.5)*Tile.tilePixelWidth,(ny+0.8)*Tile.tilePixelHeight,'metal');
			}
		}
		
		// Create a unit, nx, ny - coordinates in blocks if abs=false, and in pixels if abs=true
		// emerg>0 - smooth appearance over X ticks
		public function createUnit(tip:String,nx:int,ny:int,abs:Boolean=false,xml:XML=null,cid:String=null, emerg:int=0):Unit 
		{
			if (tip=='mines') 
			{
				createUnit('mine',nx,ny);
				createUnit('mine',nx+2,ny);
				createUnit('mine',nx+4,ny);
				return null;
			}

			if (level.rnd && tip=='transm') 
			{
				if ((xml==null || xml.@on.length()==0) && Math.random()<0.5) return null;
			}

			if (xml && xml.@trigger.length() && World.world.game.triggers[xml.@trigger]=='1') return null;

			var loadObj:Object=null;

			if (xml && xml.@code.length() && World.world.game.objs.hasOwnProperty(xml.@code)) loadObj=World.world.game.objs[xml.@code];

			//не генерировать юнита, который сдох
			if (loadObj && loadObj.dead>0 && loadObj.loot!=2)
			{
				return null;
			}
			var un:Unit;
			var scid:String;
			var hero:int=0;
			var inWater:Boolean=false;

			if ((biom==1 || biom==5) && abs==false) 
			{
				inWater=getTile(nx,ny).water>0;
			}
			var s:String=randomUnit(tip,inWater); //определить, является ли юнит случайным, если да, то сгенерировать его id
			//если тип был случайным и удалось сгенерировать его id

			if (s!='') 
			{
				if (cid) scid=cid;
				else scid=randomCid(s);
				if (s=='slmine') s='slime';
				un=Unit.create(s,locDifLevel,xml,loadObj,scid);
			}

			//если юнит не был случайным, или не получилось сгенерировать по id=s, попробовать сгенерировать по id=tip
			if ((s=='' && !homeStable) || un==null) 
			{
				if (cid) scid=cid;
				else scid=randomCid(tip);
				un=Unit.create(tip,locDifLevel,xml,loadObj,scid);
			}

			if (un!=null) 
			{
				var enl=enemyLevel;
				if (level.rnd && levelProb=='') {//геройский юнит
					if (Math.random()<Math.min(0.05,locDifLevel/100+0.02)) hero=Math.floor(Math.random()*4+1);	
				}
				if (hero==0 && un.boss==false) enl=Math.round(enl*(1.1-Math.random()*0.4));
				un.setLevel(enl);
				un.setHero(hero);
				if (abs) 
				{
					un.putLoc(this,nx,ny);
				} 
				else 
				{
					var size=Math.floor((un.scX-1)/40)+1;
					un.putLoc(this,(nx+0.5*size)*Tile.tilePixelWidth,(ny+1)*Tile.tilePixelHeight-1);
				}
				if (roomActive) 
				{
					un.xp=0;
				} else 
				{
					summXp+=un.xp;
				}
				addObj(un);
				units.push(un);
				if (homeStable) 
				{
					un.fraction=Unit.F_PLAYER;
					un.warn=0;
				}
				if (homeAtk) 
				{
					if (un is UnitTurret) (un as UnitTurret).hack(2);
					else if (Math.random()<0.5) backobjs.push(new BackObj(this, 'blood1', nx*Tile.tilePixelWidth,(ny-Math.random()*4)*Tile.tilePixelHeight));
					
				}
				if (xml && xml.@code.length()) saves.push(un);
				//Добавление объектов, имеющих uid в массив
				if (xml && xml.@uid.length()) 
				{
					un.uid=xml.@uid;
					level.uidObjs[un.uid]=un;
				}
				if (emerg>0) un.emergence(emerg);
				un.step();
			}
			return un;
		}
		
		//создать феникса, сидящего на ящике
		public function createPhoenix(box:Box):Boolean 
		{
			if (box.wall || !box.shelf) return false;
			if (collisionUnit(box.X,box.Y1-1,38,38)) return false;
			var un:Unit=new UnitPhoenix();
			un.putLoc(this,box.X,box.Y1-1);
			addObj(un);
			units.push(un);
			kol_phoenix++;
			level.kol_phoenix++;
			//trace('Феникс',roomCoordinateX, roomCoordinateY);
			return true;
		}
		//создать передатчик на ящике
		public function createTransmitter(box:Box):Boolean 
		{
			if (box.wall || !box.shelf) return false;
			if (level.rnd && Math.random()<0.5) return false;
			if (collisionUnit(box.X,box.Y1-1,30,20)) return false;
			var un:Unit=new UnitTransmitter('box');
			un.setLevel(enemyLevel);
			un.putLoc(this,box.X,box.Y1-1);
			addObj(un);
			units.push(un);
			return true;
		}
		
		//создать предмет, стоящий на ящике
		public function createSur(box:Box, nsur:String=null):void
		{
			if (nsur==null) 
			{
				if (Math.random()>0.25) return;
				if (biom==0) nsur='fan';
				if (biom==2) nsur='lamp';
				if (biom==3) nsur='kofe';
				if (nsur==null) return;
			}
			var item:Item=new Item(null, nsur, 1);
			var l:Loot=new Loot(this,item,box.X,box.Y-box.scY-3,false,false,false);
			if (base) 
			{
				l.inter.active=false;
				l.levitPoss=false;
			}
		}
		
		//создать скрытый юнит или дополнительный объект
		public function createHidden(nx:int,ny:int):void
		{
			if (biom==10 || biom==11) return;
			if (tipEnemy==0) createUnit('zombie',nx,ny, false, <unit dig='2'/>);
			else if (tipEnemy==2) createObj('robocell','box',nx,ny);
			else if (tipEnemy==1 || tipEnemy==3) createObj('alarm','box',nx,ny);
			else if (tipEnemy==6) createUnit('lov',nx,ny);
		}
		
		//облака газа
		public function createClouds(lvl:int, ncloud:String=null):void
		{
			if (ncloud==null) 
			{
				if (biom==1) 
				{
					ncloud='tcloud1';
					if (lvl>=2) return;
				}
				if (biom==5) 
				{
					ncloud='pcloud1';
				}
			}
			if (ncloud!=null) 
			{
				var kol:int=1;
				if (biom==1) kol=Math.random()*5;
				if (biom==5) 
				{
					if (lvl==0) kol=Math.random()*2;
					else kol=Math.random()*3;
				}
				for (var i=0; i<kol; i++) 
				{
					var nx:int=Math.floor(Math.random()*(roomWidth-4)+2);
					var ny:int=Math.floor(Math.random()*(roomHeight-4)+2);
					if (cp) 
					{
						var dnx=cp.X-(nx*Settings.tilePixelWidth+20);
						var dny=cp.Y-(ny*Settings.tilePixelHeight+40);
						if (dnx*dnx+dny*dny<80*80) continue;
					}
					if (biom==1 && lvl==1 && ny>15) ny=15;
					if (biom==5 && lvl==0) ny=Math.floor(Math.random()*15+9);
					createObj(ncloud,'box',nx,ny);
				}
			}
		}
		
		//определение id случайного юнита
		public function randomUnit(tip:String, inWater:Boolean=false):String 
		{
			var s:String='';
			switch (tip) 
			{
				case 'enl2':
					if (biom==10) s='stabpon';
					else if (tipEnemy==0) s='zombie';
					else if (tipEnemy==2) 
					{
						if (biom==2 && locDifLevel>=12 && Math.random()<Math.min(locDifLevel/100,0.15)) s='eqd';
						else if (locDifLevel>=5 && Math.random()<0.1) s='landturret';
						else if (locDifLevel>=6 && Math.random()<Math.min(locDifLevel/40,0.3)) s='gutsy';
						else if (locDifLevel>=2 && Math.random()<Math.min(locDifLevel/10,0.5)) s='protect';
						else s='robot';
					} 
					else if (tipEnemy==3) s='slaver';
					else if (tipEnemy==4) s='merc';
					else if (tipEnemy==5) s='alicorn';
					else if (tipEnemy==6) s='zebra';
					else if (tipEnemy==7) 
					{
						if (Math.random()<0.4) 
						{
							if (Math.random()<0.5) s='gutsy';
							else s='protect';
						} 
						else s='ranger';
					} 
					else if (tipEnemy==8) 
					{
						if (Math.random()<0.75) s='zombie';
						else s='necros'
					} 
					else if (tipEnemy==9) 
					{
						if (Math.random()<0.1) s='hellhound';
						else if (Math.random()<0.07) s='landturret';
						else s='encl';
					} 
					else if (tipEnemy==10) s='hellhound';
					else if (tipEnemy==11) 
					{
						if (Math.random()<0.3) s='hellhound';
						else s='encl';
					} 
					else s='raider';
				break;
				case 'enl1':
					if (biom==10 || biom==11) return '';
					if ((biom==1 || biom==5) && inWater) 
					{
						s='fish';
					} 
					else if (biom==5) 
					{
						if (Math.random()<0.3) s='scorp3';
						else s='slime';
					} 
					else if (biom==6) 
					{
						s='roller';
					} 
					else if (tipEnemy==2 && locDifLevel>=4 || tipEnemy==7 || tipEnemy==9 || tipEnemy==10) 
					{
						if ((roomCoordinateX+roomCoordinateY)%2==0) s='roller';
						else s='msp';
					} 
					else if (tipEnemy==0 || tipEnemy==5 || tipEnemy==6) 
					{
						if (locDifLevel>=2 && Math.random()<Math.min(locDifLevel/30,0.5)) 
						{
							s='scorp';
						} 
						else if ((roomCoordinateX+roomCoordinateY)%2==0) s='slime';
						else s='ant';
						if (biom==1 && Math.random()<0.25) s='rat';
					} 
					else if (locDifLevel>=2 && Math.random()<Math.min(locDifLevel/30,0.5)) s='molerat';
					else if (Math.random()<0.6) s='tarakan';
					else s='rat';
				break;
				case 'enc1':
					if (biom==10) 
					{
						s='turret';
					} 
					else if ((biom==1 || biom==5) && inWater) 
					{
						s='fish';
					} 
					else if (biom==5) 
					{
						if ((roomCoordinateX+roomCoordinateY)%2==0) s='bloodwing';
						else s='slime';
					} 
					else if (biom==6 || biom==4) 
					{
						s='cturret';
					} 
					else if (tipEnemy==0 || tipEnemy==5 || tipEnemy==6) 
					{
						if (biom==1 && Math.random()<0.6) s='slime';
						else s='bloodwing';
					} 
					else s='turret';
				break;
				case 'enf1':
					if (biom==10) return '';
					if ((biom==1 || biom==5) && inWater) 
					{
						s='fish';
					} 
					else if (biom==5) 
					{
						s='bloat';
					} 
					else if (tipEnemy==0 || tipEnemy==5) s='bloat';
					else if ((tipEnemy==1 || tipEnemy==3 || tipEnemy==4 || tipEnemy==6) && locDifLevel>=3) s='vortex';
					else if (tipEnemy==2 && locDifLevel>=3) s='spritebot';
					else if (tipEnemy==11 || tipEnemy==7 || tipEnemy==9 || tipEnemy==10 || tipEnemy==2 && locDifLevel>10 && Math.random()<Math.min(locDifLevel/40,0.5)) s='dron';
				break;
				case 'lov':
					if (biom==10 || biom==11) return '';
					if (biom==5) 
					{
						s='slmine';
					} else if (tipEnemy==0) 
					{
						if ((roomCoordinateX+roomCoordinateY)%2==0) s='slmine';
						else s='trap';
					} 
					else if ((tipEnemy==1 || tipEnemy==3 || tipEnemy==4 || tipEnemy==6)&&(roomCoordinateX+roomCoordinateY)%2==0) 
					{
						if (locDifLevel>=10 && Math.random()<0.5) s='trridge';
						else if (Math.random()<0.5) s='trplate';
						else s='trcans';
					} 
					else if ((biom==2 && tipEnemy==2 || tipEnemy==7 || tipEnemy==9) &&(roomCoordinateX+roomCoordinateY)%2==0) 
					{
						s='trlaser';
					} 
					else s='mine';
				break;
			}
			return s;
		}
		
		//определение сid случайного юнита
		public function randomCid(stringType:String):String
		{

			var randNum:Number = Math.random();
			var lookup:Object = 
			{
				'raider': function():int
				{
            		if (locDifLevel >= 5) return Math.floor(randNum * 9 + 1);
            		if (locDifLevel >= 2) return Math.floor(randNum * 5 + 1);
            		return Math.floor(randNum * 2 + 1);
        		},
				'slaver': function():int
				{
					if (locDifLevel >= 18) return Math.floor(randNum * 6 + 1);
					if (locDifLevel >= 15) return Math.floor(randNum * 5 + 1);
					return Math.floor(randNum * 4 + 1);
				},
				'zebra': function():int
				{
					if (locDifLevel >= 25 && randNum < 0.1) return 5; 
					if (locDifLevel >= 15) return Math.floor(randNum * 4 + 1);
					return Math.floor(randNum * 2 + 1);
				},
				'ranger': function():int
				{
					if (level.template.conf == 7) return Math.floor(randNum * 3 + 1);
					if (roomCoordinateY == 0) return 1;
					return Math.floor(randNum * 2 + 1);
				},		
				'merc': function():int
				{
					if (locDifLevel>=19) return Math.floor(randNum * 5 + 1);
					if (locDifLevel>=15 && Math.random()>0.5) return Math.floor(randNum * 4 + 1);
					return Math.floor(randNum * 2 + 1);
				},
				'encl': function():int
				{
					return Math.floor(randNum * 4 + 1);
				},
				'protect': function():int
				{
					if (tipEnemy == 7) return 1;
					return null
				},
				'gutsy': function():int
				{
					if (tipEnemy == 7) return 1;
					return null
				},
				'dron': function():int
				{
					if (tipEnemy == 9)
					{
						var i = Math.floor(randNum * 4 + 1);
						if (i > 3) return 3;
						return i;

					}
					return Math.floor(randNum * 2 + 1);
				},
				'roller': function():int
				{
					if (biom == 6) return 2;
					return 1
				},
				'zombie': function():int
				{
					if (biom == 5)
					{
						if (locDifLevel >= 20 && randNum < 0.1) return 9;
						return Math.floor(randNum * 4 + 5);
					}
					if (biom >= 1 && locDifLevel>=8) return Math.floor(randNum * 7);
					if (locDifLevel >= 5) return Math.floor(randNum * 5);
					if (locDifLevel >= 2) return Math.floor(randNum * 4);
					return 0;
				},
				'alicorn': function():int
				{
					return Math.floor(randNum * 3 + 1);
				},
				'hellhound': function():int
				{
					return 1;
				},
				'bloat': function():int
				{
					if (biom == 5) return Math.floor(randNum * 3 + 4);
					if (locDifLevel >= 10) return Math.floor(randNum * 5);
					if (locDifLevel >= 4) return Math.floor(randNum * 4);
					if (locDifLevel >= 2) return Math.floor(randNum * 3);
					return 0;
				},
				'ant': function():int
				{
					if (biom >= 1 && locDifLevel >= 6) return Math.floor(randNum * 3 + 1);
					if (locDifLevel>=3) return Math.floor(randNum * 2 + 1);
					return 1;
				},
				'fish': function():int
				{
					if (biom == 5) return 3;
					return Math.floor(randNum * 2 + 1);
				},
				'slime': function():int
				{
					if (biom == 5) return 2;
					return 0;
				},
				'slmine': function():int
				{
					if (biom == 5) return 12;
					return 10;
				},
				'bloodwing': function():int
				{
					if (biom == 5) return 2;
					return 1;
				},
				'scorp': function():String
				{
					var i;
					if (locDifLevel >= 5) i = Math.floor(randNum * 2 + 1);
					else i = 1;
					return 'scorp' + i;
				},
				'mine': function():String
				{
					if (biom == 4) return 'plamine'
					if (biom==2 && randNum < Math.min(locDifLevel / 20, 0.4)) return 'plamine';
					if (randNum < Math.min(locDifLevel / 20, 0.75)) return 'mine';
					return 'hmine';
				}
			}
			// Check if the 'stringType' exists in the lookup table
			if (lookup.hasOwnProperty(stringType))
			{
				if (stringType == 'scorp' || stringType == 'mine')
				{
					var s:String;
					s = lookup[stringType]();  // Special cases, return strings.
					return s;
				}
			 	else 
				{
					var i:Number = 0; // Normal cases, initialize as INT and return.
					i = lookup[stringType]();
					return i.toString();
    			}
			} 
			else 
			{
				return null;  // 'stringType' not found
			}
		}
		
		//создать активный объект, nx,ny-координаты в блоках
		public function createObj(id:String,tip:String,nx:int,ny:int,xml:XML=null):Obj 
		{
			var obj:Obj;
			var size:int = XmlBook.getXML("objects").obj.(@id == id).@size;
			if (size<=0) size=1;
			var loadObj:Object=null;
			if (xml && xml.@code.length() && World.world.game.objs.hasOwnProperty(xml.@code)) loadObj=World.world.game.objs[xml.@code];
			if (tip=='box' || tip=='door') 
			{
				obj=new Box(this, id, (nx+0.5*size)*Tile.tilePixelWidth, (ny+1)*Tile.tilePixelHeight-1, xml, loadObj);
				objs.push(obj);
				if ((obj is Box) && (obj as Box).un) units.push((obj as Box).un);
				//создать феникса
				if (xml && xml.@ph=='1' && !World.world.game.triggers['pet_phoenix']) createPhoenix((obj as Box));
				if (xml && xml.@transm=='1') createTransmitter((obj as Box));
				if (level.rnd && level.template.biom==0 && !World.world.game.triggers['pet_phoenix'] && kol_phoenix==0 && level.kol_phoenix<3 && Math.random()<0.02) 
				{
					createPhoenix(obj as Box);
				}
				if ((obj is Box) && (obj as Box).sur && level.rnd) createSur(obj as Box);
				if (!level.rnd && xml && xml.@sur.length()) createSur(obj as Box, xml.@sur);
				if ((obj is Box) && (obj as Box).electroDam>electroDam && !obj.inter.open) electroDam=(obj as Box).electroDam;
			} 
			else if (tip=='trap') 
			{
				obj=new Trap(this, id,(nx+0.5*size)*Tile.tilePixelWidth, (ny+1)*Tile.tilePixelHeight-1);
			} 
			else if (tip=='checkpoint') 
			{
				obj=new CheckPoint(this, id,(nx+0.5*size)*Tile.tilePixelWidth, (ny+1)*Tile.tilePixelHeight-1, xml, loadObj);
				//установить на контрольных точках телепорты на базу
				if (World.world.game.globalDif<=1 || level.rnd && World.world.game.globalDif==2 && Math.random()<0.33) (obj as CheckPoint).teleOn=true;
				activeObjects.push(obj);
			} 
			else if (tip=='area') 
			{
				obj=new Area(this, xml, loadObj, mirror);
				areas.push(obj);
			} 
			else if (tip=='bonus') 
			{
				obj=new Bonus(this, id,(nx+0.5)*Tile.tilePixelWidth, (ny+0.5)*Tile.tilePixelHeight, xml, loadObj);
				bonuses.push(obj);
			}
			if (xml && xml.@code.length()) // Assignment of checkpoint objects to the currentCP property of the level.template when specific conditions are met.
			{ 
				saves.push(obj);
				obj.code=xml.@code;
				if (tip=='checkpoint' && !level.rnd) //сохранённая контрольная точка
				{	
					if (World.world.pers.currentCPCode!=null && obj.code==World.world.pers.currentCPCode || World.world.pers.prevCPCode!=null && obj.code==World.world.pers.prevCPCode || level.template.lastCpCode==obj.code) {
						level.currentCP=obj as CheckPoint;
					}
				}
			}
			//Добавление объектов, имеющих uid в массив
			if (xml && xml.@uid.length()) 
			{
				obj.uid=xml.@uid;
				level.uidObjs[obj.uid]=obj;
			}
			if (xml && xml.@objectName.length()) 
			{
				obj.objectName=xml.@objectName;
			}
			//Добавление id испытаний
			if (levelProb=='' && xml && xml.@prob.length() && xml.@prob!='') level.probIds.push(xml.@prob);
			addObj(obj);
			return obj;
		}
		
		//создание чекпоинта в случайной точке появления
		public function createCheck(act:Boolean=false):void
		{
			if (spawnPoints.length > 0) 
			{
				var sp=spawnPoints[Math.floor(Math.random()*spawnPoints.length)];
				var id='checkpoint';
				if (!act && level.rnd && Math.random()<0.5) 
				{
					id+=Math.floor(Math.random()*5+1);
				}
				cp=createObj(id,'checkpoint',sp.x,sp.y) as CheckPoint;
				if (level.template.landStage==0 && act) cp.teleOn=true;
				if (act) cp.activate(true);
				isCheck=true;
			}
		}
		//создание выхода в случайной точке появления
		public function createExit(s:String=''):void
		{
			if (spawnPoints.length > 0) 
			{
				var sp=spawnPoints[Math.floor(Math.random()*spawnPoints.length)];
				createObj('exit','box',sp.x,sp.y,<obj name='exit' prob={level.template.exitProb+s} time='20' inter='8' sign='1'/>);
				isCheck=true;
			}
		}
		//создание двери испытаний в случайной точке появления
		public function createDoorProb(nid:String, nprob:String):Boolean 
		{
			if (spawnPoints.length > 0) 
			{
				var sp=spawnPoints[Math.floor(Math.random()*spawnPoints.length)];
				createObj(nid,'box',sp.x,sp.y,<obj prob={nprob} objectName={Res.txt('m',nprob)} time='20' inter='8'/>);
				isCheck=true;
				return true;
			}
			return false;
		}
		
		// Creates the golden horseshoes I think...
		public function createXpBonuses(kol:int=5):void
		{
			if (homeStable || homeAtk) return;
			var nx:int, ny:int, x1:int, x2:int, y1:int, y2:int;
			var mesto:int=4;
			var n:int=5;
			maxXp=kol;
			for (var i=1; i<=100; i++) 
			{
				x1 = 2;
				y1 = 2;
				x2 = roomWidth - 2;
				y2 = roomHeight - 2;
				if (mesto==4) 
				{
					x2 = roomWidth / 2;
					y2 = roomHeight / 2;
				} 
				else if (mesto==3) 
				{
					x1=roomWidth/2;
					y2=roomHeight/2;
				} 
				else if (mesto==2) 
				{
					x2=roomWidth/2;
					y1=roomHeight/2;
				} 
				else if (mesto==1) 
				{
					x1=roomWidth/2;
					y1=roomHeight/2;
				}
				nx=Math.floor(x1+Math.random()*(x2-x1));
				ny=Math.floor(y1+Math.random()*(y2-y1));
				if (getTile(nx,ny).phis==0 && (getTile(nx-1,ny).phis==0 || getTile(nx+1,ny).phis==0)) 
				{
					createObj('xp','bonus',nx,ny);
					kolXp++;
					if (mesto>0) mesto--;
					if (kolXp>=kol) return;
				} 
				else 
				{
					n--;
					if (n<=0) 
					{
						n=5;
						if (mesto>0) mesto--;
					}
				}
			}
		}
		
		public function preStep():void
		{
			for (var i:int = 0; i < 30; i++) stepInvis();
		}
		
//**************************************************************************************************************************
//
//				Activation
//
//**************************************************************************************************************************
		
		// Activate when the player character enters the room
		public function reactivate(n:int=0):void
		{
			var obj:Pt=firstObj;
			while (obj) 
			{
				nextObj=obj.nobj;
				obj.setNull(n-nAct>2 || n==0 || prob &&!prob.closed);
				obj=nextObj;
			}

			resetUnits();
			if (n>0) nAct = n;
			showSign(false);
			roomActive = true;    //Set the room to active.
			visited = true; 
			warning = 0;
			if (prob) prob.over();
			Snd.resetShum();
		}
		
		public function resetUnits():void
		{
			units=units.filter(isAct);
		}
		
		private function isAct(element:*, index:int, arr:Array):Boolean 
		{
			if (element == null) return false;
			if (element is unitdata.UnitPet) return true;
            return (element.sost < 4);
        }
		
		// Deactivate the room  This doesn't do anything.
		//This function is actually overwritten later??? wtf?

		public function unloadRoom():void
		{
			roomActive = false; // Set the Room as inactive.

			for each (var un:Unit in units) 
			{
				un.locout(); // Unload all units.
			}

			if (prob) 
			{
				prob.out();   // unload trial with it's built in unloader TODO: replace!
			}
		}
		
//**************************************************************************************************************************
//
//				Processing Chain
//
//**************************************************************************************************************************
		// Add any object to the processing chain
		public function addObj(obj:Pt):void
		{
			if (obj.in_chain) return;
			if (!firstObj) firstObj = obj;
			else 
			{
				lastObj.nobj = obj;
				obj.pobj = lastObj;
			}
			obj.nobj = null;
			lastObj = obj;
			obj.in_chain = true;
			if (roomActive) obj.addVisual();
		}
		
		// Remove an object from the processing chain
		public function remObj(obj:Pt):void
		{
			if (!obj.in_chain) return;

			if (obj.nobj) 
			{
				obj.nobj.pobj = obj.pobj;
			} 
			else 
			{
				lastObj = obj.pobj;
			}

			if (obj.pobj) 
			{
				obj.pobj.nobj = obj.nobj;
			} 
			else 
			{
				firstObj = obj.nobj;
			}
			obj.in_chain = false;
			obj.nobj=obj.pobj = null;
			obj.remVisual();
		}
		
//**************************************************************************************************************************
//
//				Working with Tile Space
//
//**************************************************************************************************************************

		// Checks if a tile is in bounds of Space, if so returns otstoy (an empty tile).
		// Otherwise, it attempts to retrieve the tile from the roomTileArray using the provided coordinates and returns it.

		//input coordinates and return the tile at that room.
		public function getTile(nx:int, ny:int):Tile 
		{
			if (nx < 0 || nx >= roomWidth || ny < 0 || ny >= roomHeight) return otstoy;
			return roomTileArray[nx][ny] as Tile;
		}

		public function getAbsTile(nx:int, ny:int):Tile 
		{
			if (nx < 0 || nx >= roomWidth * Tile.tilePixelWidth || ny < 0 || ny >= roomHeight * Tile.tilePixelHeight) return otstoy;
			
			var xIndex:int = nx / Tile.tilePixelWidth | 0;
			var yIndex:int = ny / Tile.tilePixelHeight | 0;
			
			return roomTileArray[xIndex][yIndex] as Tile;
		}

		public function collisionUnit(X:Number, Y:Number, scX:Number = 0, scY:Number = 0):Boolean 
		{
			var X1:Number = X - scX / 2, X2:Number = X + scX / 2, Y1:Number = Y - scY;
			
			var startX:int	 = X1 / Tile.tilePixelWidth | 0;
			var endX:int 	= X2 / Tile.tilePixelWidth | 0;
			var startY:int 	= Y1 / Tile.tilePixelHeight | 0;
			var endY:int 	= Y / Tile.tilePixelHeight | 0;
			
			for (var i:int = startX; i <= endX; i++) 
			{
				for (var j:int = startY; j <= endY; j++) 
				{
					if (i < 0 || i >= roomWidth || j < 0 || j >= roomHeight) continue;
					if (roomTileArray[i][j].phis > 0) return true;
				}
			}
			return false;
		}

		public function isLine(nx:Number, ny:Number, cx:Number, cy:Number, obj:Obj=null):Boolean 
		{
			var ndx:Number = cx - nx;
			var ndy:Number = cy - ny;
			var div:int = Math.floor(Math.max(Math.abs(ndx), Math.abs(ndy)) / Settings.maxdelta) + 1;
			
			for (var i:int = 1; i < div; i++) 
			{
				var tempX:Number = nx + ndx * i / div;
				var tempY:Number = ny + ndy * i / div;
				
				var t:Tile = World.world.room.getAbsTile(tempX | 0, tempY | 0);
				
				if (t.phis == 1 && tempX >= t.phX1 && tempX <= t.phX2 && tempY >= t.phY1 && tempY <= t.phY2) 
				{
					if (obj == null || t.door != obj) return false;
				}
			}
			return true;
		}
	
		// Tile contours
		public function tileKontur(tx:int, ty:int, tile:Tile):void
		{
			var a0:Boolean,a1:Boolean,a2:Boolean,a3:Boolean,a4:Boolean,a5:Boolean,a6:Boolean,a7:Boolean;
			if (tile.phis==1) {
				a0 = uslKontur(tx - 1, ty - 1);
				a1 = uslKontur(tx, ty - 1);
				a2 = uslKontur(tx + 1, ty - 1);
				a3 = uslKontur(tx + 1, ty);
				a4 = uslKontur(tx + 1, ty + 1);
				a5 = uslKontur(tx,  ty + 1);
				a6 = uslKontur(tx - 1, ty + 1);
				a7 = uslKontur(tx - 1, ty);
				tile.kont1 = insKontur(a1, a7, a0);
				tile.kont2 = insKontur(a1, a3, a2);
				tile.kont3 = insKontur(a5, a7, a6);
				tile.kont4 = insKontur(a5, a3, a4);
				if (b != '') 
				{
					if (!a1) a1=uslPontur(tx, ty-1);
					if (!a3) a3=uslPontur(tx+1,ty);
					if (!a5) a5=uslPontur(tx, ty+1);
					if (!a7) a7=uslPontur(tx-1,ty);
					tile.pont1=insKontur(a1,a7,a0);
					tile.pont2=insKontur(a1,a3,a2);
					tile.pont3=insKontur(a5,a7,a6);
					tile.pont4=insKontur(a5,a3,a4);
				}
			} 
			else 
			{
				var b:String = tile.tileRearTexture;
				var vse:Boolean = (backwall == 'sky');
				a0 = uslBontur(tx-1,ty-1, b, vse);
				a1 = uslBontur(tx,  ty-1, b, vse);
				a2 = uslBontur(tx+1,ty-1, b, vse);
				a3 = uslBontur(tx+1,ty, b, vse);
				a4 = uslBontur(tx+1,ty+1, b, vse);
				a5 = uslBontur(tx,  ty+1,b, vse);
				a6 = uslBontur(tx-1,ty+1,b, vse);
				a7 = uslBontur(tx-1,ty,b, vse);
				tile.pont1 = insKontur(a1, a7, a0);
				tile.pont2 = insKontur(a1, a3, a2);
				tile.pont3 = insKontur(a5, a7, a6);
				tile.pont4 = insKontur(a5, a3, a4);
			}
		}
		
		private function insKontur(a:Boolean, b:Boolean, c:Boolean):int 
		{
			if (a && b) return c?0:1;
			else if (!a && b) return 2;
			else if (a && !b) return 3;
			else return 4;
		}
		
		// Front contours
		private function uslKontur(nx:int,ny:int):Boolean 
		{
			if (nx<0 || nx>=roomWidth || ny<0 || ny>=roomHeight) return true;
			return (roomTileArray[nx][ny].phis == 1 || roomTileArray[nx][ny].door != null);
		}

		// Back contours with a wall
		private function uslPontur(nx:int,ny:int):Boolean 
		{
			if (nx < 0 || nx >= roomWidth || ny<0 || ny >= roomHeight) return true;
			return (roomTileArray[nx][ny].back!='' || roomTileArray[nx][ny].shelf >0 );
		}

		// Back contours without a wall
		private function uslBontur(nx:int,ny:int,b:String='',vse:Boolean=false):Boolean 
		{
			if (nx<0 || nx >= roomWidth || ny < 0 || ny >= roomHeight) return true;
			return (roomTileArray[nx][ny].back == b || vse && roomTileArray[nx][ny].back != '' || roomTileArray[nx][ny].phis == 1 || roomTileArray[nx][ny].shelf > 0);
		}
		
		// Tile damage
		public function hitTile(t:Tile, hit:int, nx:int,ny:int, tip:int=9) 
		{
			// Damage from falling
			if (tip == 100 && hit <= 50 && (t.damageThreshold > 0 || t.indestruct)) return;
			if (tip == 100) tip = 4;
			// Room walls are not destructible
			if (!destroyOn && t.hp>500) 
			{
				if (roomActive && t.phis == 1) grafon.dyrka(nx, ny, tip, t.tileMaterial, true, hit / t.hp);
				return;
			}
			// Has damage been dealt to the tile?
			if (t.udar(hit))  // Hit the tile, passes if damage was dealt
			{	
				if (t.hp<=0)  // If the tile is destroyed
				{	
					if (t.phis>=1) // Change the room configuration
					{
						isRebuild = true;				 
						if (t.Y < waterLevel)  // Recalculate water
						{		
							recalcTiles.push(t);
							isRecalc = true;
						}
					}
					if (t.door) // If it's a door
					{				
						t.door.die(tip);
					} 
					else if (t.phis >= 1) // If it's a regular solid block
					{		
						t.die();
						try 
						{
							if (tileSpawn>0 && Math.random() < tileSpawn) enemySpawn(true,true);
						} 
						catch(err) 
						{

						}
						if (roomActive) grafon.tileDie(t, tip);
					}
				} 
				else if (t.phis >= 1)  // If it's not destroyed but damage was dealt
				{	
					if (roomActive) grafon.dyrka(nx, ny, tip, t.tileMaterial, false, hit / t.hp);
				}
			} 
			else if (t.phis >= 1) // If there was no damage
			{		
				if (roomActive) grafon.dyrka(nx, ny, tip, t.tileMaterial, true, hit / t.hp);
			}
		}
		
		// Destroy a tile
		public function dieTile(t:Tile):void
		{
			if (t.indestruct) return;
			if (t.phis==1) 
			{
				if (t.door) // If it's a door
				{				
					t.door.die(4);
				} 				
				isRebuild=true;		// Change the room configuration		
				if (t.Y < waterLevel) // Recalculate water
				{		
					recalcTiles.push(t);
					isRecalc = true;
				}
			}
			if (t.phis >= 1) 
			{
				t.die();
				if (roomActive) grafon.tileDie(t, 4);
			}
		}
		
		
		// Called on any change in the roomTileArray
		private function rebuild():void
		{
			recalcWater();
			isRebuild = false;
		}
		
		// Water physics   
		private function recalcWater():void
		{
			//trace(recalcTiles.length);
			var rec:Array = recalcTiles;
			recalcTiles = new Array();
			isRecalc = false;
			var t:Tile, tl:Tile, tr:Tile, tt:Tile, tb:Tile;
			for (var i in rec) 
			{
				t = rec[i];
				if (t.Y >= waterLevel) continue;
				if (t.phis != 1) 
				{
					tl = getTile(t.X - 1, t.Y);
					tr = getTile(t.X + 1, t.Y);
					tt = getTile(t.X, t.Y - 1);
					tb = getTile(t.X, t.Y + 1);
					if ((tb.phis==1 || tb.water==1) && (tr.phis==1 || tr.water==1) && (tl.phis==1 || tl.water==1) && (tl.water==1 || tr.water==1 || tt.water==1)) {
						t.water=1;
						if (roomActive) grafon.drawWater(t);
					} else {
						if (tl.water>0 && t.phis!=1) 
						{
							tl.water=0;
							recalcTiles.push(tl);
							if (roomActive) grafon.drawWater(tl);
							isRecalc=true;
						}
						if (tr.water>0 && t.phis!=1) 
						{
							tr.water=0;
							recalcTiles.push(tr);
							if (roomActive) grafon.drawWater(tr);
							isRecalc=true;
						}
						if (tt.water>0 && t.phis!=1) 
						{
							tt.water=0;
							recalcTiles.push(tt);
							if (roomActive) grafon.drawWater(tt);
							isRecalc=true;
						}
					}
					t.recalc=false;
				}
			}
			var obj:Pt=firstObj;
			while (obj) {
				if (obj is Obj) (obj as Obj).checkStay();
				obj=obj.nobj;
			}

			//for each(var box in objs) if (box is Box) box.checkStay();
		}
		
		// Check for the possibility of placing a ghost wall, returns true if nothing obstructs
		public function testTile(t:Tile):Boolean 
		{
			if (t.phis > 0 || t.stair != 0 || t.water != 0 || t.door) return false;
			for each (var cel in units) 
			{
				if (cel == null || (cel as Unit).sost == 4) continue;
				if (cel.transT) continue;
				if (!(cel.X1 >= (t.X + 1) * Tile.tilePixelWidth || cel.X2 <= t.X * Tile.tilePixelWidth || cel.Y1 >= (t.Y + 1) * Tile.tilePixelHeight || cel.Y2 <= t.Y * Tile.tilePixelHeight)) 
				{
					return false;
				}
			}

			return true;
		}
		
		// Draw the map on the PipBuck
		public function drawMap(m:BitmapData):void
		{
			var vid:Number = 1;
			for (var i = 0; i < roomWidth; i++)
			 {
				for (var j = 0; j < roomHeight; j++) 
				{
					var color:uint = 0x003323;
					var t:Tile = roomTileArray[i][j];
					if (t.water) color = 0x0066FF;
					if (t.shelf || t.diagon != 0) color = 0x7B482F;
					if (t.stair != 0) color = 0x666666;
					if (t.phis == 1) 
					{
						if (t.indestruct) color = 0xFFFFFF;
						else if (t.door) color = 0x639104;
						else if (t.hp<100) color = 0x01995A; 
						else color = 0x00FF99;
					}
					if (t.phis == 2) color = 0x01995A; 
					if (!Settings.drawAllMap) 
					{
						vid = roomTileArray[i][j].visi;
						if (i < roomWidth - 1) 
						{
							if (roomTileArray[i + 1][j].visi > vid) vid = roomTileArray[i + 1][j].visi;
							if (j<roomHeight-1) 
							{
								if (roomTileArray[i + 1][j + 1].visi > vid) vid = roomTileArray[i + 1][j + 1].visi;
							}
						}
						if (j<roomHeight-1) 
						{
							if (roomTileArray[i][j + 1].visi > vid) vid = roomTileArray[i][j + 1].visi;
						}
					}
					color += Math.floor(vid * 255) * 0x1000000;
					m.setPixel32((roomCoordinateX - level.minLocX) * Settings.roomTileWidth + i,(roomCoordinateY - level.minLocY) * Settings.roomTileHeight + j, color);
				}
			}
			for each (var obj:Obj in objs) 
			{
				if (obj.inter && obj.inter.cont!='' && obj.inter.active) 
				{
					drawMapObj(m, obj, 0xFFCC00);
				}
				if (obj.inter && obj.inter.prob!='' && obj.inter.prob != null) 
				{
					drawMapObj(m, obj, 0xFF0077);
				}
			}
			for each (obj in activeObjects) 
			{
				if (obj is CheckPoint) 
				{
					drawMapObj(m, obj, 0xFF00FF);
				}
			}
			for each (obj in units) 
			{
				if ((obj as Unit).npc)
				{
					drawMapObj(m, obj, 0x5500FF);
				}
			}
		}
		
		public function drawMapObj(m, obj:Obj, color:uint):void
		{
			for (var i = (roomCoordinateX - level.minLocX) 		* Settings.roomTileWidth + Math.floor(obj.X1 / Settings.tilePixelWidth + 0.5); i <= (roomCoordinateX - level.minLocX) * Settings.roomTileWidth + Math.floor(obj.X2 / Settings.tilePixelWidth - 0.5); i++) 
			{
				for (var j = (roomCoordinateY - level.minLocY) 	* Settings.roomTileHeight + Math.floor(obj.Y1 / Settings.tilePixelHeight + 0.4); j <= (roomCoordinateY - level.minLocY) * Settings.roomTileHeight + Math.floor(obj.Y2 / Settings.tilePixelHeight - 0.5); j++) 
				{
					m.setPixel(i, j, color);
				}
			}
		}
		
//**************************************************************************************************************************
//
//				Usage
//
//**************************************************************************************************************************
		// Command to all objects
		public function allAct(emit:Obj, allact:String, allid:String=''):void
		{
			var obj:Obj;
			for each (obj in objs) 
			{
				if (obj != emit && obj.inter && (allid == '' || allid == null || obj.inter.allid == allid)) obj.command(allact, '13');
			}
			for each (obj in areas) 
			{
				if (obj != emit && allid == '' || allid == null || (obj as Area).allid == allid) obj.command(allact);
			}
			for each (obj in units) 
			{
				if (obj != emit && obj.inter && (allid == '' || allid == null || obj.inter.allid == allid)) obj.command(allact);
			}
		}
		
		// Wake up everyone around
		public function budilo(nx:Number, ny:Number, rad:Number = 1000, owner:Unit = null):void
		{
			var r2:Number = rad * rad * earMult * earMult;
			for each(var un in units) 
			{
				if (un && un != owner && un.sost == 1 && !un.unres) 
				{
					var dx = un.X - nx;
					var dy = un.Y - ny;
					var delta = rad / 2;
					if (delta > 400) delta = 400;
					if (dx*dx+dy*dy<r2*un.ear*un.ear) un.alarma(nx+(Math.random()-0.5)*delta,ny+(Math.random()-0.5)*delta);
				}
			}
		}
		
		public function electroCheck():void
		{
			electroDam=0;
			for each (var obj in objs) 
			{
				if ((obj is Box) && (obj as Box).electroDam>electroDam && !obj.inter.open) electroDam=(obj as Box).electroDam;
			}
		}
		
		// Activate all robot cells
		public function robocellActivate():void
		{
			for each(var un in objs) 
			{
				if (un.inter && un.inter.allact=='robocell') un.inter.genRobot();
			}
		}
		
		// Activate the alarm
		public function signal(n:int=300):void
		{
			t_alarm=n;
			t_alarmsp=Math.floor(n*Math.random()*0.25+0.25);
			if (prob && prob.alarmScript) prob.alarmScript.start(); 
		}
		// Turn on everything
		public function allon():void
		{
			color='yellow';
			cTransform=colorFilter(color);
			lightOn=1;
			darkness=-20;
			gg.inLoc(this);
			for each(var obj in units) 
			{
				obj.cTransform=cTransform;
			}
			for each(var obj in objs) 
			{
				obj.cTransform=cTransform;
				if (obj.inter) {
					if (obj.inter.lockTip=='4') obj.inter.setAct('open',0);
					obj.inter.active=true;
					obj.inter.update();
				}
			}
			for each(var obj in backobjs)
			 {
				obj.onoff(1);
			}
			World.world.redrawLoc();
		}
		// Turn off everything
		public function alloff():void
		{
			color='black';
			cTransform=colorFilter(color);
			lightOn=-1;
			darkness=20;
			gg.inLoc(this);
			for each(var obj in units) 
			{
				obj.cTransform=cTransform;
			}
			for each(var obj in objs) 
			{
				obj.cTransform=cTransform;
			}
			for each(var obj in backobjs) 
			{
				obj.onoff(-1);
			}
			World.world.redrawLoc();
		}
		
		// Spawn an enemy at the spawn point
		public function enemySpawn(one:Boolean=false, getGG:Boolean=false, tipSp:String=null):void
		{
			if (kolEnSpawn<=0 || enspawn==null || enspawn.length == 0) return;
			kolEnSpawn--;
			if (!one) t_alarmsp=Math.floor(Math.random()*30);
			var sp:Object=enspawn[Math.floor(Math.random()*enspawn.length)];
			var un:Unit=createUnit((tipSp==null)?tipSpawn:tipSp,sp.x,sp.y,true,null,null,30);
			if (getGG) 
			{
				un.alarma(gg.X, gg.Y);
			} 
			else 
			{
				un.alarma();
			}
		}
		
		// Spawn an enemy from a wave
		public function waveSpawn(w:XML, n:int=0, spart:String=null):Unit 
		{
			if (w==null) return null;
			if (enspawn.length == 0) return null;
			var sp:Object=enspawn[n];
			if (sp==null) sp=enspawn[Math.floor(Math.random()*enspawn.length)];
			var un:Unit=createUnit(w.@id,sp.x,sp.y,true,w,w.@cid,30);
			if (spart!=null) Emitter.emit(spart,this,sp.x,sp.y);
			if (un) 
			{
				un.trup=false;
				un.isRes=false;
				un.fraction=1;
				un.wave=1;
				un.alarma();
				return un;
			}
			return null;
		}
		
		// Cause an earthquake
		public function earthQuake(n:int):void
		{
			if (quake<n) 
			{
				quake=n;
				World.world.quake(n,n/4);
			}
		}
		
		public function createHealBonus(nx:Number, ny:Number) 
		{
			if (World.world.pers.bonusHeal <= 0) return;
			var obj:Bonus = new Bonus(this, 'heal', nx, ny);
			obj.liv = 300;
			obj.val = World.world.pers.bonusHeal * World.world.pers.bonusHealMult;
			if (roomActive) obj.addVisual();
			addObj(obj);
		}
		
		// Process ghost walls
		public function gwalls():void
		{
			var est = false;
			var t:Tile;
			for (var i = 0; i < roomWidth; i++) 
			{
				for (var j = 0; j < roomHeight; j++) 
				{
					t = roomTileArray[i][j];
					if (t.phis == 3) 
					{
						if (roomActive) 
						{
							t.t_ghost--;
							est = true;
							if (t.t_ghost <= 0) dieTile(t);
						} 
						else 
						{
							t.t_ghost = 0;
							dieTile(t);
						}
					}
				}
			}
			if (est) t_gwall = Settings.fps + 1;
		}
		
		public function lightAll():void
		{
			for each (var cel in objs) 
			{
				if (cel.light) 
				{
					lighting(cel.X - 10, cel.Y - cel.scY / 2);
					lighting(cel.X, cel.Y - cel.scY / 2);
					lighting(cel.X + 10, cel.Y - cel.scY / 2);
				}
			}
		}
		
		public function lighting(nx:int = -10000, ny:int = -10000, dist1:int = -1, dist2:int = -1):void
		{
			if (roomActive == false) 
			{
				return;
			}
			if (dist1 < 0) dist1 = lDist1;
			if (dist2 < 0) dist2 = lDist2;
			if (nx == -10000) 
			{
				nx = gg.X+gg.storona * 12;
				ny = gg.Y1 + gg.stayY * 0.247;
			}
			var n1:Number, n2:Number;
			relight_t = 10;
			for (var i = 1; i < roomWidth; i++) 
			{
				for (var j = 1; j < roomHeight; j++) 
				{
					n1 = roomTileArray[i][j].visi;
					if (!retDark && n1 >= 1) continue;
					var dx:int = i * Tile.tilePixelWidth - nx;
					var dy:int = j * Tile.tilePixelHeight - ny;
					var rasst = dx * dx + dy * dy;
					if (rasst >= dist2 * dist2) 
					{
						if (retDark && roomTileArray[i][j].t_visi>0) 
						{
							roomTileArray[i][j].t_visi-=0.025;
							if (roomTileArray[i][j].t_visi<0) roomTileArray[i][j].t_visi=0;
							grafon.lightBmp.setPixel32(i,j+1,Math.floor((1-roomTileArray[i][j].updVisi())*255)*0x1000000);
						}
						continue;
					}
					var rasst1=Math.sqrt(rasst);
					if (rasst1<=dist1) n2=1;
					else n2=(dist2-rasst1)/(dist2-dist1);
					//видимость по линии
					if (rasst<=dist2*dist2) 
					{
						var dex:Number,dey:Number,maxe:int;
						if (Math.abs(dx)==Math.abs(dy)) dy++;
						if (Math.abs(dx)>=Math.abs(dy)) //двигаемся по х
						{
							if (dx>0) 
							{
								dex=Tile.tilePixelWidth;
								dey=dy/dx*Tile.tilePixelHeight;
							} 
							else 
							{
								dex=-Tile.tilePixelWidth;
								dey=-dy/dx*Tile.tilePixelHeight;
							}
							maxe=dx/dex;
						} 
						else 
						{
							if (dy>0) 
							{
								dey=Tile.tilePixelHeight;
								dex=dx/dy*Tile.tilePixelWidth;
							} 
							else 
							{
								dey=-Tile.tilePixelHeight;
								dex=-dx/dy*Tile.tilePixelWidth;
							}
							maxe=dy/dey;
						}
						for (var e=1; e<=maxe; e++) 
						{
							var t:Tile=getAbsTile(nx+e*dex, ny+e*dey);
							var opac:Number=t.opac;
							if (opacWater>0 && t.water>0 && opacWater>opac) opac=opacWater;
							if (opac>0) 
							{
								n2-=opac;
								if (n2<=0) 
								{
									n2=0;
									break;
								}
							}
						}
					}
					if (n2>1) n2=1;
					if (n2>n1+0.01) 
					{
						roomTileArray[i][j].t_visi=n2;
						grafon.lightBmp.setPixel32(i,j+1,Math.floor((1-roomTileArray[i][j].updVisi())*255)*0x1000000);
					} 
					else if (retDark && n2<n1-0.01) 
					{
						roomTileArray[i][j].t_visi-=0.025;
						if (roomTileArray[i][j].t_visi<n2) roomTileArray[i][j].t_visi=n2;
						grafon.lightBmp.setPixel32(i,j+1,Math.floor((1-roomTileArray[i][j].updVisi())*255)*0x1000000);
					}
				}
			}
		}
		
		public function lighting2():void
		{
			if (!roomActive) return;
			relight_t--;
			for (var i:int = 1; i < roomWidth; i++) 
			{
				for (var j:int = 1; j < roomHeight; j++) 
				{
					if (roomTileArray[i][j].visi!=roomTileArray[i][j].t_visi) 
					{
						grafon.lightBmp.setPixel32(i,j+1,Math.floor((1-roomTileArray[i][j].updVisi())*255)*0x1000000);
					}
				}
			}
		}
		
		//дать опыт
		public function takeXP(dxp:int, nx:Number=-1, ny:Number=-1, un:Boolean=false):void
		{
			if (un) 
			{
				if (dxp>summXp) 
				{
					dxp=summXp;
					summXp=0;
				} 
				else 
				{
					summXp-=dxp;
				}
				level.summXp+=dxp;
			}
			if (dxp>0) World.world.pers.expa(dxp,nx,ny);
		}
		
		
		//обработка за кадром
		public function stepInvis():void
		{
			//for each (var un:Unit in units) if (!un.player) un.step();
			//for each (var obj:Obj in objs) obj.step();
			var numb=0;
			var obj:Pt=firstObj;
			if (warning>0) warning--;
			while (obj) 
			{
				nextObj=obj.nobj;
				try 
				{
					obj.step();
				} catch(err) 
				{
					World.world.showError(err, obj.err());
				}
				obj=nextObj;
				numb++;
				if (numb>10000) 
				{
					trace('alarma');
					break;
				}
			}
			if (isRebuild) rebuild();
			if (isRecalc) recalcWater();
			if (t_gwall==1) gwalls();
			if (t_gwall>0) t_gwall--;
		}
		
		public function step():void
		{
			gg.step(); 
			if (prob) prob.step();
			// Iterate through a chain of objects
			var numb=0;
			var obj:Pt=firstObj;
			if (warning>0) warning--;
			while (obj) 
			{
				nextObj=obj.nobj;
				try 
				{
					obj.step();
					// Determine the object under the cursor
					if ((obj is Obj) && (obj as Obj).onCursor>0 && obj!=gg && (celObj==null || (obj as Obj).onCursor>=celObj.onCursor)) celObj=(obj as Obj);
				} 
				catch(err) 
				{
					World.world.showError(err, obj.err());
				}
				obj=nextObj;
				// Check for infinite loop prevention
				numb++;
				if (numb > 10000) 
				{
					trace('alarma');
					break;
				}
			}
			if (unitCoord && unitCoord.step) unitCoord.step();
			if (celObj && celObj.onCursor<=0) celObj=null;
			if (black) 
			{
				if (gg.dx+gg.osndx>0.5 || gg.dy+gg.osndy>0.5 || gg.dx+gg.osndx<-0.5 || gg.dy+gg.osndy<-0.5 || isRelight || isRebuild) lighting();
				else if (relight_t>0) lighting2();
			}
			isRelight=false;
			getDist();
			// If needed, rebuild the room
			if (isRebuild) rebuild();
			if (isRecalc) recalcWater();
			if (t_gwall==1) gwalls();
			if (t_gwall>0) t_gwall--;
			// Show/hide transition markers based on player position
			if (sign_vis && World.world.possiblyOut() ||  !sign_vis && !World.world.possiblyOut()) showSign(!sign_vis);
			// Handle game alarms and enemy spawns
			if (t_alarm>0) 
			{
				t_alarm--;
			}
			if (t_alarmsp>0) 
			{
				t_alarmsp--;
				if (t_alarmsp==0) enemySpawn();
			}
			// Handle screen shaking (earthquake effect)
			if (quake>0) quake--;
			if (trus>0) World.world.quake(trus/2,trus);
		}
		
		// Kill all enemies and open all containers
		public function getAll():int 
		{
			World.world.summxp=0;
			World.world.pers.expa(unXp*9);
			for each (var un:Unit in units) 
			{
				if (un.fraction!=Unit.F_PLAYER && un.xp>0) un.damage(100000,Unit.D_INSIDE);
			}
			for each (var box:Box in objs) 
			{
				if (box.inter && box.inter.cont) box.inter.loot();
			}
			return World.world.summxp;
		}
		
		public function openAllPrize():void
		{
			for each (var box:Box in objs) 
			{
				if (box.inter && box.inter.cont && box.inter.prize) box.inter.loot();
			}
		}
		
		
		//дистанция между гг и активным объектом
		private function getDist():void
		{
			if (getTile(Math.round(World.world.celX/Tile.tilePixelWidth),Math.round(World.world.celY/Tile.tilePixelHeight)).visi<0.1) celObj=null;
			if (celObj) 
			{
				celDist = (gg.X - celObj.X) * (gg.X - celObj.X) + (gg.Y - celObj.Y) * (gg.Y - celObj.Y);
			} 
			else celDist = -1;
		}
		
		
		//показать/скрыть указатели перехода
		private function showSign(n:Boolean):void
		{
			for each (var s in signposts) s.visible = n;
			sign_vis = n;
		}
		
		public function newGrenade(g:Bullet):void
		{
			if (grenades[0] == null) grenades[0] = g;
			else 
			{
				for (var i = 1; i < 10; i++) 
				{
					if (grenades[i] == null) grenades[i] = g;
				}
			}
		}
		public function remGrenade(g:Bullet):void
		{
			if (grenades[0] == g) grenades[0] = null;
			else 
			{
				for (var i = 1; i < 10; i++) 
				{
					if (grenades[i] == g) grenades[i] = null;
				}
			}
		}
		
		// Save all objects
		public function saveObjs(arr:Array):void
		{
			for each (var obj:Obj in saves) 
			{
				if (obj.code) arr[obj.code] = obj.save();
			}
		}
		
	}
	
}
