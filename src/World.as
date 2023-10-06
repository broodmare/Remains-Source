package
{
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;

	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.events.IOErrorEvent;
	import flash.system.Capabilities;
	import flash.utils.Timer;
	import flash.net.SharedObject;
    import flash.ui.Mouse;
	import flash.desktop.Clipboard;	
	import flash.utils.getTimer;
	import flash.system.System;
	import flash.external.ExternalInterface;

	import locdata.*;
	import roomdata.RoomContainer;
	import graphdata.Grafon;
	import graphdata.Part;
	import graphdata.Emitter;
	import interdata.*;
	import servdata.LootGen;
	import unitdata.Unit;
	import unitdata.UnitPlayer;
	import unitdata.Invent;
	import unitdata.Pers;
	import weapondata.Weapon;

	import components.Settings;
	import systems.Languages;

	public class World 
	{

		public static var world:World;
		
		public var urle:String;						//URL from which the game was launched


		//Visual components
		public var mainDisplay:Sprite;				//Main game sprite
		public var swfStage:Stage;					//Sprite container
		public var loadingScreen:MovieClip;			//Loading image
		public var skybox:MovieClip;				//Static background
		public var mainCanvas:Sprite;				//Active area
		public var vscene:MovieClip;				//Scene
		public var vblack:MovieClip;				//Darkness
		public var vpip:MovieClip;					//Pipbuck
		public var vsats:MovieClip;					//HUD interface
		public var vgui:MovieClip;					//GUI (HUD)
		public var vstand:MovieClip;				//Stand
		public var verror:MovieClip;				//Error window
		public var vconsol:MovieClip;				//Console scroll
	

		//All main components
		public var mainMenu:MainMenu;
		public var cam:Camera;						//Camera
		public var ctr:Ctr;							//Controls
		public var consol:Consol;					//Console
		public var game:Game;						//Game
		public var gg:UnitPlayer;					//Player unit
		public var pers:Pers;						//Character
		public var invent:Invent;					//Inventory
		public var gui:GUI;							//GUI
		public var grafon:Grafon;					//Graphics
		public var pip:PipBuck;						//Pipbuck
		public var stand:Stand;						//Stand
		public var sats:Sats;						//SATS
		public var app:Appear;						//Character appearance settings
		

		//Room components
		public var level:Level;						//Current level
		public var room:Room;						//Current room
		public var roomContainer:RoomContainer;		//Holds all level data.
		

		//Working variables
		public var onConsol:Boolean = false;		//Console active
		public var onPause:Boolean = false;			//Game on pause
		public var allStat:int = 0; 				//Overall status 0 - game has not started
		public var celX:Number;						//Cursor coordinates in room coordinate system
		public var celY:Number;
		public var t_battle:int = 0;				//Is there a battle happening or not
		public var t_die:int = 0;					//Player character has died
		public var t_exit:int = 0;					//Exit from room
		public var gr_stage:int = 0;				//Room rendering stage
		public var checkLoot:Boolean = false;		//Recalculate auto-loot
		public var calcMass:Boolean = false;		//Recalculate mass
		public var calcMassW:Boolean = false;		//Recalculate weapon mass
		public var lastCom:String = null;
		public var armorWork:String = '';			//Temporary display of armor
		public var mmArmor:Boolean = false;			//Armor in main menu
		public var catPause:Boolean = false;		//Pause for scene display
		public var testLoot:Boolean = false;		//Loot and experience testing
		public var summxp:int = 0;
		public var ccur:String;
		public var currentMusic:String = '';
		


		//Loading, saves, config
		public var configObj:SharedObject;
		public var saveObj:SharedObject;
		public var saveArr:Array;
		public var saveCount:int = 10;
		public var savePath:String = null;
		public var t_save:int = 0;
		public var loaddata:Object;					//data loaded from file
		public var nadv:int = 0, koladv:int = 10;	//advice number
		public var load_log:String = '';			//This is the text that apepars onscreen during boot.
		

		//Maps
		public var levelPath:String;
		public var landData:Array;
		public var kolLands:int = 0;
		public var kolLandsLoaded:int = 0;
		public var allLandsLoaded:Boolean = false;


		//Other
		public var comLoad:int 		= -1;				//load command
		public var clickReq:int 	= 0;				//button click request, if set to 1, 2 will only be set after click
		public var ng_wait:int 		= 0;				//new game wait
		public var loadScreen:int 	= -1;				//loading screen
		public var autoSaveN:int 	= 0;				//autosave slot number
		public var log:String 		= '';
		public var fc:int 			= 0;


		public var d1:int, d2:int;
		public var landError:Boolean = false;
		public var textProgressLoad:Number;





		public function World(nmain:Sprite) 
		{
			trace ('World.as/World() - starting loading stage 1...');
			World.world = this;
		

			mainDisplay = nmain;

			swfStage 				= mainDisplay.stage;
			swfStage.tabChildren 	= false;
			swfStage.addEventListener(Event.DEACTIVATE, onDeactivate);

			Tile.tilePixelWidth 	= Settings.tilePixelWidth;
			Tile.tilePixelHeight 	= Settings.tilePixelHeight;
			
			
			LootGen.init();
			Form.setForms();
			Emitter.init();
			

			//Creating graphic elements
			loadingScreen = new visualWait();
			loadingScreen.cacheAsBitmap = Settings.bitmapCachingOption;
			
			//Appearance configurator
			app = new Appear();
			
			mainCanvas 	= new Sprite();
			vgui 		= new visualGUI();
			skybox 		= new MovieClip();
			vpip 		= new visPipBuck();
			vstand 		= new visualStand();
			vsats 		= new MovieClip();
			vscene 		= new visualScene();
			vblack 		= new visBlack();
			vblack.cacheAsBitmap =  Settings.bitmapCachingOption;
			vconsol 	= new visConsol();
			verror 		= new visError();

			setLoadScreen();
			vgui.visible=vpip.visible=vconsol.visible=skybox.visible=mainCanvas.visible=vsats.visible=loadingScreen.visible=vblack.visible=verror.visible=vscene.visible = false;
			vscene.stop();

			mainDisplay.addChild(loadingScreen);
			mainDisplay.addChild(skybox);
			mainDisplay.addChild(mainCanvas);
			mainDisplay.addChild(vscene);
			mainDisplay.addChild(vblack);
			mainDisplay.addChild(vpip);
			mainDisplay.addChild(vsats);
			mainDisplay.addChild(vgui);
			mainDisplay.addChild(vstand);
			mainDisplay.addChild(verror);
			mainDisplay.addChild(vconsol);

			//ERROR LOG STUFF
			verror.butCopy.addEventListener(flash.events.MouseEvent.CLICK, function () {Clipboard.generalClipboard.clear();Clipboard.generalClipboard.setData(flash.desktop.ClipboardFormats.TEXT_FORMAT, verror.txt.text);});
			verror.butClose.addEventListener(flash.events.MouseEvent.CLICK, function () {verror.visible = false;});
			verror.butForever.addEventListener(flash.events.MouseEvent.CLICK, function () {Settings.errorShow = false; verror.visible = false;});
			
			vstand.visible = false;
			trace('World.as/World() - Creating new Grafon object.');
			grafon = new Grafon(mainCanvas);
			cam = new Camera(this);

			
			load_log += 'Stage 1 Ok\n';
			trace('World.as/World() - STAGE 1 COMPLETE.');

			//FPS counter
			d1 = d2 = getTimer();
			
			//config, immediately loads sound settings
			configObj = SharedObject.getLocal('config', savePath);
			if (configObj.data.snd) Snd.load(configObj.data.snd);

		}

//=============================================================================================================
//			Technical Part
//=============================================================================================================
		
		public function init2()
		{
			trace('World.as/init2() - Starting loading stage 2...');

			if (consol) return;
			if (configObj) lastCom = configObj.data.lastCom;

			consol = new Consol(vconsol, lastCom);

			//saves and config
			saveArr = new Array();
			for (var i = 0; i <= saveCount; i++) 
			{
				saveArr[i] = SharedObject.getLocal('PFEgame' + i, savePath);
			}
			saveObj = saveArr[0];

			if (configObj.data.dialon 	!= null) Settings.dialOn = configObj.data.dialon;
			if (configObj.data.zoom100 	!= null) Settings.zoom100 = configObj.data.zoom100;
			if (Settings.zoom100) 
			{
				cam.isZoom = 0; 
			}
			else cam.isZoom = 2;
			if (configObj.data.mat 		!= null) Settings.matFilter = configObj.data.mat;
			if (configObj.data.help 	!= null) Settings.helpMess = configObj.data.help;
			if (configObj.data.hit 		!= null) Settings.showHit = configObj.data.hit;
			if (configObj.data.sysCur 	!= null) Settings.sysCur = configObj.data.sysCur;
			if (configObj.data.hintTele != null) Settings.hintTele = configObj.data.hintTele;
			if (configObj.data.showFavs != null) Settings.showFavs = configObj.data.showFavs;
			if (configObj.data.quakeCam != null) Settings.quakeCam = configObj.data.quakeCam;
			if (configObj.data.errorShowOpt != null) Settings.errorShowOpt = configObj.data.errorShowOpt;
			if (configObj.data.app) 
			{
				app.load(configObj.data.app);
				app.setTransforms();
			}
			try 
			{
				koladv = Res.d.advice[0].a.length();
			} 
			catch (err) 
			{
				trace('World.as/init2() - Error during init2().' + err.message);
			}

			if (configObj.data.nadv) 
			{
				nadv = configObj.data.nadv;
				configObj.data.nadv++;
				if (configObj.data.nadv>=koladv) configObj.data.nadv = 0;
			} 
			else 
			{
				configObj.data.nadv = 1;
			}

			if (configObj.data.chit > 0) 		Settings.chitOn 		= true;
			if (configObj.data.vsWeaponNew > 0) Settings.vsWeaponNew 	= false;
			if (configObj.data.vsWeaponRep > 0) Settings.vsWeaponRep 	= false;
			if (configObj.data.vsAmmoAll > 0) 	Settings.vsAmmoAll 		= false;	
			if (configObj.data.vsAmmoTek > 0) 	Settings.vsAmmoTek 		= false;	
			if (configObj.data.vsExplAll > 0) 	Settings.vsExplAll  	= false;	
			if (configObj.data.vsMedAll > 0) 	Settings.vsMedAll 		= false;
			if (configObj.data.vsHimAll > 0) 	Settings.vsHimAll 		= false;
			if (configObj.data.vsEqipAll > 0) 	Settings.vsEqipAll 		= false;
			if (configObj.data.vsStuffAll > 0) 	Settings.vsStuffAll 	= false;
			if (configObj.data.vsVal > 0) 		Settings.vsVal 			= false;
			if (configObj.data.vsBook > 0) 		Settings.vsBook 		= false;
			if (configObj.data.vsFood > 0) 		Settings.vsFood 		= false;
			if (configObj.data.vsComp > 0) 		Settings.vsComp 		= false;
			if (configObj.data.vsIngr > 0) 		Settings.vsIngr 		= false;
			
			//trace(configObj.data.vsWeaponNew,vsWeaponNew);
			ctr = new Ctr(configObj.data.ctr);
			pip = new PipBuck(vpip);
			if (!Settings.sysCur) Mouse.cursor = 'arrow';
			
			//loading room maps
			landData = new Array();
			for each(var xl in GameData.d.level) 
			{
				if (!Settings.testMode && xl.@test > 0) continue;
				var ll:LandLoader = new LandLoader(xl.@id);
				if (!(xl.@test > 0)) kolLands++;
				landData[xl.@id] = ll;
			}
			
			load_log += 'Stage 2 Ok\n';
			Snd.loadMusic();
		}

		public function roomsLoadOk()
		{
			if (!Settings.roomsLoad) 
			{
				allLandsLoaded = true;
				return;
			}
			kolLandsLoaded++;
			if (kolLands == kolLandsLoaded) allLandsLoaded = true;
		}

		//Pause and calling the pipbuck if focus is lost
		public function onDeactivate(event:Event):void  
		{
			if (allStat == 1) 
			{
				pip.onoff(11);
			}
			if (allStat> 0 && !Settings.alicorn) saveGame();
		}
		
		//Pause and call pipbuck if window size is changed
		public function resizeScreen()
		{
			if (allStat > 0) 
			{
				cam.setLoc(room);
			} 
			if (gui) gui.resizeScreen(swfStage.stageWidth,swfStage.stageHeight);
			pip.resizeScreen(swfStage.stageWidth,swfStage.stageHeight);
			grafon.setSkyboxSize(swfStage.stageWidth,swfStage.stageHeight);
			if (stand) stand.resizeScreen(swfStage.stageWidth,swfStage.stageHeight);
			vblack.width = swfStage.stageWidth;
			vblack.height = swfStage.stageHeight;
			if (loadScreen<0) 
			{
				loadingScreen.x=swfStage.stageWidth/2;
				loadingScreen.y=swfStage.stageHeight/2;
			}
			if (allStat == 1 && !Settings.testMode) pip.onoff(11);
		}
		
		//Console call
		public function consolOnOff()
		{
			onConsol =! onConsol; //Toggles the state of onConsole
			consol.vis.visible = onConsol; //Toggles the visibility of consol depending on the state of onConsol
			if (onConsol) swfStage.focus = consol.vis.input;
		}
		
		
//=============================================================================================================
//			Game
//=============================================================================================================
		
		var newGame:Boolean;
		var data:Object;
		var opt:Object;
		var newName:String;

		//Start a new game or load a save. Pass the slot number or -1 for a new game
		//Stage 0 - create HUD, SATS, and pipuck
		//Initialize game
		public function startNewGame(nload:int = -1, nnewName:String = 'LP', nopt:Object = null)
		{
			if (Settings.testMode && !Settings.chitOn) 
			{
				loadingScreen.progres.text='error';
				return;
			}
			try
			{
				allStat = -1;
				opt = nopt;
				newName = nnewName;
				game = new Game();
				if (!Settings.roomsLoad) allLandsLoaded = true;
				newGame = nload<0;
				if (newGame) 
				{
					if (opt && opt.autoSaveN) 
					{
						autoSaveN=opt.autoSaveN;
						saveObj=saveArr[autoSaveN];
						nload=autoSaveN;
					} 
					else nload = 0;
					saveObj.clear();
				}
				
				// create GUI
				gui = new GUI(vgui);
				gui.resizeScreen(swfStage.stageWidth,swfStage.stageHeight);
				// switch PipBuck to normal mode
				pip.toNormalMode();
				pip.resizeScreen(swfStage.stageWidth,swfStage.stageHeight);
				// create SATS interface
				sats = new Sats(vsats);
				
				// create game
				if (nload == 99) 
				{
					data = loaddata;	// loaded from file
				} 
				else 
				{
					data=saveArr[nload].data; // loaded from slot
				}

				if (newGame)	
				{
					game.init(null, opt); 
				}
				else 
				{
					game.init(data.game);
				}
				ng_wait = 1;
			} 
			catch (err) 
			{
				showError(err);
			}
		}
		
		// stage 1 - create character and inventory
		public function newGame1()
		{
			try 
			{
				if (!newGame) app.load(data.app);
				if (data.hardInv == true) Settings.hardInv = true; else Settings.hardInv = false;
				if (opt && opt.hardinv) Settings.hardInv = true;

				// create character
				pers = new Pers(data.pers, opt);
				if (newGame) pers.persName=newName;

				// create player character
				gg = new UnitPlayer();
				gg.ctr = ctr;
				gg.sats = sats;
				sats.gg = gg;
				gui.gg = gg;

				// create inventory
				invent = new Invent(gg, data.invent, opt);
				stand = new Stand(vstand,invent);
				gg.attach();

				// auto save slot number
				if (!newGame && data.n != null) 
				{
					autoSaveN = data.n;
				}
				Unit.txtMiss = Res.guiText('miss');
				
				waitLoadClick();
				ng_wait = 2;
			} 
			catch (err) 
			{
				showError(err);
			}
		}
		
		// Stage 2 - create a terrain and enter it
		public function newGame2()
		{
			try 
			{
				
				//visual part
				resizeScreen();
				offLoadScreen();
				vgui.visible=skybox.visible=mainCanvas.visible = true;
				vblack.alpha=1;
				cam.dblack=-10;
				pip.onoff(-1);

				//enter the current room
				game.enterToCurLand();//!!!!
				game.beginGame();
				
				Snd.off= false;
				gui.setAll();
				allStat=1;
				ng_wait=0;
			} 
			catch (err) 
			{
				showError(err);
			}
		}
		
		public function loadGame(nload:int = 0)
		{
			try 
			{
				comLoad = -1;
				if (room) room.unloadRoom();
				level = null;
				room = null;
				try {cur('arrow');} 
				catch(err)
				{

				}

				//loading object
				var data:Object;

				if (nload == 99) 
				{
					data = loaddata;
				} 
				else 
				{
					data = saveArr[nload].data;
				}

				//create game
				Snd.off = true;
				cam.showOn = false;
				if (data.hardInv==true) Settings.hardInv=true; else Settings.hardInv= false;
				game = new Game();
				game.init(data.game);
				app.load(data.app);

				//create character
				pers = new Pers(data.pers);

				//create player unit
				gg = new UnitPlayer();
				gg.ctr = ctr;
				gg.sats = sats;
				sats.gg = gg;
				gui.gg = gg;

				// create an inventory
				invent = new Invent(gg, data.invent);
				if (stand) stand.inv = invent;
				else stand = new Stand(vstand,invent);
				gg.attach();

				// auto-save cell number
				if (data.n != null) autoSaveN=data.n;
				
				offLoadScreen();
				vgui.visible=skybox.visible=mainCanvas.visible=true;
				vblack.alpha=1;
				cam.dblack=-10;
				pip.onoff(-1);
				gui.allOn();
				t_die=0;
				t_battle=0;

				//enter the current room
				game.enterToCurLand();//!!!!
				game.beginGame();
				log = '';
				Snd.off= false;
				gui.setAll();
				allStat=1;
			} 
			catch (err) 
			{
				showError(err);
			}
		}
		
		// Call when entering a specific level
		public function activateLevel(l:Level)
		{
			try 
			{
				level = l;
				grafon.drawSkybox(skybox,level.template.skybox);
			} 
			catch (err) 
			{
				showError(err);
			}
		}
		
		// Call when entering a specific area
		// There is a graphical bug here
		public function ativateLoc(newRoom:Room)
		{
			try 
			{
				if (room != null) //If a room exists, unload it.
				{
					room.unloadRoom();
				}

				room = newRoom; //Set the desired area as the current area
				grafon.drawLoc(room); //Draw the current area
				cam.setLoc(room);
				grafon.setSkyboxSize(swfStage.stageWidth, swfStage.stageHeight);
				gui.setAll();
				currentMusic = room.sndMusic;
				Snd.playMusic(currentMusic);
				gui.hpBarBoss();
				if (t_die <= 0) World.world.gg.controlOn();
				gui.dialText();
				pers.invMassParam();
				gc();
			} 
			catch (err) 
			{
				showError(err);
			}
		}
		
		public function redrawLoc()
		{
			try 
			{
				grafon.drawLoc(room);
				cam.setLoc(room);
				gui.setAll();
			} 
			catch (err) 
			{
				showError(err);
			}
		}
		
		public function exitLand(fast:Boolean= false)
		{
			if (t_exit > 0) return;
			gg.controlOff();
			pip.gamePause=true;
			if (fast) 
			{
				t_exit = 21;
			} 
			else 
			{
				t_exit = 100;
			}
		}
		
		
		function exitStep()
		{
			try 
			{
				t_exit--;

				if (t_exit == 99) cam.dblack = 1.5; // Fade to black for level change. (Canterlot, Factory, etc.)

				if (t_exit == 20) 
				{
					vblack.alpha = 0;
					cam.dblack = 0;
					setLoadScreen(getLoadScreen());
					Snd.off=true;
				}
				if (t_exit == 19) 
				{
					cur('arrow');
					game.enterToCurLand();
				}
				if (t_exit == 18 && clickReq> 0) waitLoadClick();
				if (t_exit == 16) 
				{
					Mouse.show();
					Snd.off = false;
					offLoadScreen();
					vgui.visible=skybox.visible=mainCanvas.visible = true;
					vblack.alpha=1;
					cam.dblack = -10;
					gg.controlOn();
					pip.gamePause = false;
				}
				if (t_exit == 1) 
				{
					gui.allOn();
				}
			} 
			catch (err) 
			{
				showError(err);
			}
		}
		
		function ggDieStep()
		{
			try 
			{
				t_die--;
				if (t_die == 200) cam.dblack = 2.2;
				if (t_die == 150) 
				{
					if (Settings.alicorn) 
					{
						game.runScript('gameover');
						t_die=0;
					} 
					else 
					{
						if (gg.sost == 3) 
						{
							game.curLevelID = game.baseId;
							game.enterToCurLand();
						} 
						else 
						{
							level.gotoCheckPoint();
						}
						cam.dblack = -4;
						gg.vis.visible = true;
					}
				}
				if (t_die == 100) gg.resurect();
				if (t_die == 1) 
				{
					gg.controlOn();
				}
			} 
			catch (err) 
			{
				showError(err);
			}
		}

		// Main loop
		public function step()
		{
			try 
			{
				if (verror.visible) return;

				
				ctr.step();	//Process controls
				Snd.step(); //Process sound

				if (ng_wait > 0) 
				{
					if (ng_wait == 1) 
					{
						newGame1();
					} 
					else if (ng_wait == 2) 
					{
						if (clickReq != 1) newGame2();
					}
					return;
				}

				if (!onConsol && !pip.active) swfStage.focus = swfStage;
				
				//Only if the game has started and not paused, game loops
				if (allStat == 1 && !onPause) 
				{
					//exit loop
					if (t_exit > 0) 
					{
						if (!(t_exit == 17 && clickReq == 1)) exitStep();
					}
					//particle count
					Emitter.kol2 = Emitter.kol1;
					Emitter.kol1 = 0;
					//trace(Emitter.kol2);

					//main loop !!!!
					if (t_exit != 17) level.step();

					//death loop
					if (t_die > 0) ggDieStep();

					//battle timer
					if (t_battle > 0) t_battle--;

					sats.step2();

					//if mass recalculation is needed
					if (calcMass) 
					{
						invent.calcMass();
						calcMass= false;
					}
					if (calcMassW) 
					{
						invent.calcWeaponMass();
						calcMassW= false;
					}

					//Increment ticks since last save, if over 5000, and not in either test or alicorn mode, save the game.
					t_save++;
					if (t_save>5000 && !Settings.testMode && !Settings.alicorn)
					{
						saveGame();
					}

					checkLoot = false;
				}
				//trace(clickReq,t_exit)
				
				if (comLoad >= 0) 
				{
					if (comLoad >= 100) 
					{
						if (autoSaveN > 0) saveGame();
						loadGame(comLoad - 100);
					} 
					else 
					{
						pip.onoff(-1);
						comLoad += 100;
						setLoadScreen();
					}
				}
				
				//If the game has started, and is also on pause
				if (allStat >= 1) 
				{
					cam.calc(gg);
					gui.step();
					pip.step();
					sats.step();
					
					if (ctr.keyPip) 
					{
						if (!sats.active) pip.onoff();
						ctr.keyPip = false;
					}
					if (ctr.keyInvent) 
					{
						if (!sats.active) pip.onoff(2);
						ctr.keyInvent = false;
					}
					if (ctr.keyStatus) 
					{
						if (!sats.active) pip.onoff(1,1);
						ctr.keyStatus = false;
					}
					if (ctr.keySkills) 
					{
						if (!sats.active) pip.onoff(1,2);
						ctr.keySkills = false;
					}
					if (ctr.keyMed) 
					{
						if (!sats.active) pip.onoff(1,5);
						ctr.keyMed = false;
					}
					if (ctr.keyMap) 
					{
						if (!sats.active) pip.onoff(3,1);
						ctr.keyMap = false;
					}
					if (ctr.keyQuest) 
					{
						if (!sats.active) pip.onoff(3,2);
						ctr.keyQuest = false;
					}
					if (ctr.keySats) 
					{
						if (gg.ggControl && !pip.active && gg && gg.pipOff<=0 && !catPause) sats.onoff();
						ctr.keySats = false;
					}

					allStat=(pip.active || sats.active || stand.active || gui.guiPause)?2:1;
					
					if (consol && consol.visoff) 
					{
						onConsol=consol.vis.visible=consol.visoff= false;
					}
				}
			} 
			catch (err) 
			{
				showError(err);
			}
		}

//=============================================================================================================
//			Global interaction functions
//=============================================================================================================
		public function cur(ncur:String = 'arrow')
		{
			if (Settings.sysCur) return;
			if (pip.active || stand.active || comLoad >= 0) ncur = 'arrow';
			else if (t_battle> 0) ncur ='combat';
			if (ncur != ccur) 
			{
				Mouse.cursor = ncur;
				Mouse.show();
				ccur=ncur;
			}
		}
		
		public function quake(x:Number, y:Number)
		{
			if (room.sky) return;
			if (Settings.quakeCam) 
			{
				cam.quakeX += x;
				cam.quakeY += y;

				if (cam.quakeX >  20) cam.quakeX =  20;
				if (cam.quakeX < -20) cam.quakeX = -20;
				if (cam.quakeY >  20) cam.quakeY =  20;
				if (cam.quakeY < -20) cam.quakeY = -20;
			}
		}
		
		public function possiblyOut():int 
		{
			if (t_battle > 0) return 2;
			if (room && room.t_alarm > 0) return 2;
			if (level.loc_t > 120) return 1;
			return 0;
		}
		
		public function showError(err:Error, dop:String = null)
		{
			if (!Settings.errorShow || !Settings.errorShowOpt) return;

			try 
			{
				verror.info.text 			= Res.pipText('error');
				verror.butClose.text.text 	= Res.pipText('err_close');
				verror.butForever.text.text = Res.pipText('err_dont_show');
				verror.butCopy.text.text 	= Res.pipText('err_copy_to_clipboard');
			} 
			catch (e) 
			{
				
			}

			verror.txt.text = err.message + '\n' + err.getStackTrace();
			verror.txt.text += '\n' + 'gr_stage: ' + gr_stage;
			if (dop != null) verror.txt.text += '\n' + dop;
			verror.visible=true;
		}
		
		public function gc()
		{
			System.pauseForGCIfCollectionImminent(0.25)	
		}
		
//=============================================================================================================
//			Loading Screen
//=============================================================================================================

		//set loading screen
		public function setLoadScreen(n:int = -1)
		{
			loadScreen = n;
			loadingScreen.story.lmb.stop();
			loadingScreen.story.lmb.visible = false;
			vgui.visible = false;
			skybox.visible = false;
			mainCanvas.visible = false;
			vscene.visible = false;
			loadingScreen.visible = true;
			catPause = false;
			loadingScreen.progres.text = Res.guiText('loading');

			if (n < 0) 
			{
				loadingScreen.x = swfStage.stageWidth / 2;
				loadingScreen.y = swfStage.stageHeight / 2;
				loadingScreen.skill.gotoAndStop(Math.floor(Math.random() * loadingScreen.skill.totalFrames+1));
				loadingScreen.skill.visible = loadingScreen.progres.visible = true;
				loadingScreen.story.visible = false;
				clickReq=0;
			} 
			else 
			{
				loadingScreen.x=loadingScreen.y = 0;
				loadingScreen.story.visible = true;
				loadingScreen.skill.visible = loadingScreen.progres.visible= false;

				if (n == 0) 
				{
					loadingScreen.story.txt.htmlText = '<i>' + Res.guiText('story') + '</i>';
				} 
				else 
				{
					loadingScreen.story.txt.htmlText = '<i>' + 'История' + n + '</i>';
				}

				clickReq = 1;
			}

			loadingScreen.cacheAsBitmap = false;
			loadingScreen.cacheAsBitmap = true;
		}
		
		// Determine which loading screen to display
		function getLoadScreen():int 
		{
			return -1;
			try 
			{
				var nscr = game.levelArray[game.curLevelID].loadScr;
				if (nscr >= 0 && (game.triggers['loadScr'] == null || game.triggers['loadScr'] < nscr))
				{
					game.triggers['loadScr'] = nscr;
					return nscr;
				}
			} 
			catch(err) 
			{

			}
			return -1;
		}
		
		// Enable waiting for a click
		function waitLoadClick()
		{
			loadingScreen.story.lmb.play();
			loadingScreen.story.lmb.visible = true;
		}
		
		// Remove the loading screen
		function offLoadScreen()
		{
			loadingScreen.visible = false;
			loadingScreen.story.visible = false;
			loadingScreen.skill.visible=loadingScreen.progres.visible = true;
			loadingScreen.story.lmb.stop();
			loadingScreen.story.lmb.visible = false;
			clickReq=0;
		}

		// Show the scene
		public function showScene(sc:String, n:int=0)
		{
			catPause = true;
			mainCanvas.visible = false;
			gui.allOff();
			gui.offCelObj();

			try 
			{
				vscene.gotoAndStop(sc);
			}  
			catch(err)
			{
				vscene.gotoAndStop(1);
			}

			try 
			{
				if (n > 0) 
				{
					vscene.sc.gotoAndPlay(n);
				} 
				else
				{
					vscene.sc.gotoAndPlay(1);
				}
			} 
			catch(err)
			{

			}

			vscene.visible = true;
		}
		
		// Remove the scene
		public function unshowScene()
		{
			catPause = false;
			mainCanvas.visible = true;
			gui.allOn();
			vscene.gotoAndStop(1);
			vscene.visible = false;
		}
		
		// Final credits or game over
		public function endgame(n:int = 0)
		{
			loadingScreen.visible=skybox.visible = false;
			var s:String;
			if (n == 1) 
			{
				showScene('gameover');
				s = Res.lpName(Res.guiText('end_bad'));
			} 
			else if (pers.rep>=pers.repGood) 
			{
				showScene('endgame');
				s = Res.lpName(Res.guiText('end_good'));
				Snd.playMusic('music_fall_2');
			} 
			else 
			{
				showScene('endgame');
				s=Res.lpName(Res.guiText('end_norm'));
			}
			try 
			{
				vscene.sc.txt.htmlText=s;
			} 
			catch(err)
			{

			}
		}

//=============================================================================================================
//			Saves and configuration
//=============================================================================================================
		public function saveToObj(data:Object)
		{
			var now:Date 	= new Date();
			data.game 		= game.save();
			data.pers 		= pers.save();
			data.invent 	= invent.save();
			data.app 		= app.save();
			data.date 		= now.time;
			data.n 			= autoSaveN;
			data.hardInv 	= Settings.hardInv;
			data.ver 		= mainMenu.version;
			data.est 		= 1;
		}
		
		public function saveGame(n:int = -1)
		{
			if (n == -2) 
			{
				n 			= autoSaveN;
				var save 	= saveArr[n];
				saveToObj(save.data);
				save.flush();
				trace('World.as/saveGame() - Конец');
				return;
			}
			if (t_save < 100 && n == -1 && !pers.hardcoreMode) return;
			if (pip.gamePause) return;
			if (n == -1) n = autoSaveN;
			var save = saveArr[n];
			if (save is SharedObject) 
			{
				saveToObj(save.data);
				var r = save.flush();
				trace('World.as/saveGame() - ' + r);
				if (n == 0) t_save = 0;
			}
		}
		
		public function getSave(n:int):Object 
		{
			if (saveArr[n] is SharedObject) return saveArr[n].data;
			else return null;
		}
		
		public function saveConfig()
		{
			try 
			{
				configObj.data.ctr = ctr.save();
				configObj.data.snd = Snd.save();
				configObj.data.language 	= Languages.currentLanguageName;
				configObj.data.chit 		= (Settings.chitOn?1:0);
				configObj.data.dialon 		= Settings.dialOn;
				configObj.data.zoom100 		= Settings.zoom100;
				configObj.data.help 		= Settings.helpMess;
				configObj.data.mat 			= Settings.matFilter;
				configObj.data.hit 			= Settings.showHit;
				configObj.data.sysCur 		= Settings.sysCur;
				configObj.data.hintTele 	= Settings.hintTele;
				configObj.data.showFavs 	= Settings.showFavs;
				configObj.data.quakeCam 	= Settings.quakeCam;
				configObj.data.errorShowOpt = Settings.errorShowOpt;
				configObj.data.app = app.save();
				if (lastCom != null) configObj.data.lastCom = lastCom;
					
				configObj.data.vsWeaponNew 	= Settings.vsWeaponNew?0:1;
				configObj.data.vsWeaponRep 	= Settings.vsWeaponRep?0:1;
				configObj.data.vsAmmoAll 	= Settings.vsAmmoAll?0:1;	
				configObj.data.vsAmmoTek 	= Settings.vsAmmoTek?0:1;	
				configObj.data.vsExplAll 	= Settings.vsExplAll?0:1;	
				configObj.data.vsMedAll 	= Settings.vsMedAll?0:1;
				configObj.data.vsHimAll 	= Settings.vsHimAll?0:1;
				configObj.data.vsEqipAll 	= Settings.vsEqipAll?0:1;
				configObj.data.vsStuffAll 	= Settings.vsStuffAll?0:1;
				configObj.data.vsVal 		= Settings.vsVal?0:1;
				configObj.data.vsBook 		= Settings.vsBook?0:1;
				configObj.data.vsFood 		= Settings.vsFood?0:1;
				configObj.data.vsComp 		= Settings.vsComp?0:1;
				configObj.data.vsIngr 		= Settings.vsIngr?0:1;
				configObj.flush();
			} 
			catch (err) 
			{
				showError(err);
			}
		}
		
		function weaponWrite() //Debug function?
		{
			var un:Unit = new Unit();
			var s:String = '';
			for each (var w in AllData.d.weapon.(@tip > 0)) 
			{
				var weap:Weapon = new Weapon(un, w.@id, 0);
				s += weap.write() + '\n';
				if (w.com.length && w.com.@uniq.length()) 
				{
					weap = new Weapon(un, w.@id, 1);
					s += weap.write() + '\n';
				}
			}
			trace('World.as/weaponWrite() - ' + s);
		}
	}
}
