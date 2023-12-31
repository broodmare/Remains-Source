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
	import flash.utils.Timer;
	import flash.net.SharedObject;
    import flash.ui.Mouse;
	import flash.desktop.Clipboard;	
	import flash.utils.getTimer;
	import flash.system.System;
	import flash.external.ExternalInterface;

	import locdata.*;
	import locdata.LevelArray;

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
	import components.XmlBook;
	
	import systems.Languages;

	import stubs.*;
	
	public class GameSession
	{

		public static var currentSession:GameSession;

		//Visual components
		public var gameContainer:Sprite;			//Main game sprite
		public var swfStage:Stage;					//Sprite container
		public var skybox:MovieClip;				//Static background
		public var mainCanvas:Sprite;				//Active area

		//LINKAGES defined in .fla
		public var loadingScreen:MovieClip;			//Loading image
		public var vscene:MovieClip;				//Scene
		public var vblack:MovieClip;				//Darkness
		public var vpip:MovieClip;					//Pipbuck
		public var vsats:MovieClip;					//HUD interface
		public var vgui:MovieClip;					//GUI (HUD)
		public var vstand:MovieClip;				//Stand
		public var verror:MovieClip;				//Error window
		public var vconsol:MovieClip;				//Console scroll
	
		//All main components
		public var mainMenuWindow:MainMenu;
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
		public var appearanceWindow:Appear;			//Character appearance settings

		//Room components
		public var level:Level;						//Current level
		public var room:Room;						//Current room

		//Working variables
		public var onConsol:Boolean = false;		//Console active
		public var onPause:Boolean = false;			//Game on pause
		public var gameState:int = 0; 				//Overall status 0 - Game not started; 1 - Game active 2 - Game active, in menu.
		
		public var celX:Number;						//Cursor coordinates in room coordinate system
		public var celY:Number;
		public var t_battle:int = 0;				//Is there a battle happening or not
		public var t_die:int = 0;					//Player character has died
		public var t_exit:int = 0;					//Exit from room
		public var gr_stage:int = 0;				//Room rendering stage
		public var checkLoot:Boolean 	= false;	//Recalculate auto-loot
		public var calcMass:Boolean 	= false;	//Recalculate mass
		public var calcMassW:Boolean 	= false;	//Recalculate weapon mass
		public var lastCom:String 		= null;
		public var armorWork:String 	= '';		//Temporary display of armor
		public var mmArmor:Boolean 		= false;	//Armor in main menu
		public var catPause:Boolean 	= false;	//Pause for scene display
		public var testLoot:Boolean 	= false;	//Loot and experience testing
		public var summxp:int 			= 0;
		public var ccur:String;
		public var currentMusic:String = '';
		
		//Loading, saves, config
		public var configObj:SharedObject;
		public var saveObj:SharedObject;
		public var saveArr:Array = [];
		public var saveCount:int = 10;
		public var t_save:int = 0;
		public var loaddata:Object;					//data loaded from file
		public var nadv:int = 0;
		public var koladv:int = 10;					//advice number
		public var load_log:String = '';			//This is the text that apepars onscreen during boot.

		//Other
		public var comLoad:int 		= -1;			//load command
		public var clickReq:int 	= 0;			//button click request, if set to 1, 2 will only be set after click
		public var ng_wait:int 		= 0;			//new game wait
		public var loadScreen:int 	= -1;			//loading screen
		public var autoSaveN:int 	= 0;			//autosave slot number
		public var log:String 		= '';
		public var fc:int 			= 0;

		public var d1:int;
		public var d2:int;

		public var constructorFinished:Boolean = false; // Used by main menu to start constructor part 2 and not call it repeatedly.
		public var init2Done:Boolean = false;
		private var levelLoadTimer:int = 0; // Debug message slowdownerer. 

		public function GameSession(container:Sprite) 
		{
			trace('GameSession.as/GameSession() - Starting game session...');
			//TODO: This is dumb.
			GameSession.currentSession = this;

			gameContainer = container;
			swfStage 				= gameContainer.stage;
			swfStage.tabChildren 	= false;
			swfStage.addEventListener(Event.DEACTIVATE, onDeactivate);

			//config, immediately loads sound settings
			trace('GameSession.as/GameSession() - Creating configObj...');
			configObj = SharedObject.getLocal('config'); //Attempts to load a locally stored SharedObject called "config"

			if (configObj.data.snd)
			{
				trace('GameSession.as/GameSession() - Sound settings found in configObj. Calling Snd/load() and passing configObj.');
				Snd.load(configObj.data.snd);
			}

			trace('GameSession.as/GameSession() - Calling Languages/languageStart.');
			Languages.languageStart();
			
			trace('GameSession.as/GameSession() - Checking if language is loaded.');
			if (Languages.textLoaded)
			{
				trace('GameSession.as/GameSession() - Language data already done loading, continuing GameSession setup.');
				continueLoadingWorld()
			}
			else trace('GameSession.as/GameSession() - Language data still loading, waiting...');

			trace('GameSession.as/GameSession() - Stage 1 of GameSession setup finished.');
		}

		public function continueLoadingWorld():void
		{
			trace ('GameSession.as/continueLoadingWorld() - Continuing GameSession construction.');
			LootGen.init();
			Form.setForms();
			Emitter.init();
			
			loadingScreen 	 = new visualWait();// Loading screen
			appearanceWindow = new Appear(); 	// Appearance Editor window
			mainCanvas 		 = new Sprite();	// Rendered frames.
			vgui 			 = new visualGUI();	
			skybox 			 = new MovieClip();	//Skybox texture container.
			vpip 			 = new visPipBuck();
			vstand 			 = new visualStand();
			vsats 			 = new MovieClip();
			vscene 			 = new visualScene();
			vblack 			 = new visBlack();
			verror 			 = new visError(); 	// Error message pop-up.
			vconsol 		 = new visConsol(); // Cheat console
	
			loadingScreen.cacheAsBitmap = Settings.bitmapCachingOption;
			vblack.cacheAsBitmap 		= Settings.bitmapCachingOption;

			setLoadScreen();

			var mainMenuChildren:Array = 
			[
				"loadingScreen", "skybox", "mainCanvas", "vscene", "vblack",
				"vpip", "vsats", "vgui", "vstand", "verror",  "vconsol"
        	];
			for each (var child:String in mainMenuChildren) 
			{
				this[child].visible = false;
				if (child == "vscene") this[child].stop();
				gameContainer.addChild(this[child]);
			}

			//ERROR LOG STUFF
			verror.butCopy.addEventListener(flash.events.MouseEvent.CLICK, function():void {Clipboard.generalClipboard.clear();Clipboard.generalClipboard.setData(flash.desktop.ClipboardFormats.TEXT_FORMAT, verror.txt.text);});
			verror.butClose.addEventListener(flash.events.MouseEvent.CLICK, function():void {verror.visible = false;});
			verror.butForever.addEventListener(flash.events.MouseEvent.CLICK, function():void {Settings.errorShow = false; verror.visible = false;});

			grafon = new Grafon(mainCanvas);
			cam = new Camera(this);

			trace('GameSession.as/continueLoadingWorld() - GameSession constructor stage 2 finished.');
			
			d1 = d2 = getTimer(); //FPS counter
		}

//=============================================================================================================
//			Technical Part
//=============================================================================================================
		
		public function init2():void
		{
			trace('GameSession.as/init2() - init2() Executing...');
			
			if (consol) 
			{
				trace('GameSession.as/init2() - Consol enabled, returning.');
				return;
			}
			
			trace('GameSession.as/init2() - Calling configObjSetup().');
			configObjSetup();
			
			if (configObj) lastCom = configObj.data.lastCom; //Setting last command for console.
			
			trace('GameSession.as/init2() - Creating new Consol.');
			consol = new Consol(vconsol, lastCom);

			//saves and config
			trace('GameSession.as/init2() - Populating save array.');
			for (var i:int = 0; i <= saveCount; i++) 
			{
				saveArr[i] = SharedObject.getLocal('PFEgame' + i);
			}
    		saveObj = saveArr[0];
			
			trace('GameSession.as/init2() - Creating input controller.');
			ctr = new Ctr(configObj.data.ctr);

			trace('GameSession.as/init2() - Creating pipbuck.');
			pip = new PipBuck(vpip);
			
			trace('GameSession.as/init2() - Applying mouse settings.');
			if (!Settings.systemCursor) Mouse.cursor = 'arrow';

			//Removed loading levels here.

			trace('GameSession.as/init2() - Calling Sound/loadMusic.');
			Snd.loadMusic();

			init2Done = true;
			trace('GameSession.as/init2() - GameSession initialized.');
		}

		public function configObjSetup():void
		{

			trace('GameSession.as/configObjSetup() - Executing configObjSetup().');
			if (configObj.data.dialon 	!= null) Settings.dialOn = configObj.data.dialon;
			if (configObj.data.zoom100 	!= null) Settings.zoom100 = configObj.data.zoom100;

			if (Settings.zoom100) cam.isZoom = 0; 
			else cam.isZoom = 2;

			if (configObj.data.mat 			!= null) Settings.matFilter 	= configObj.data.mat;
			if (configObj.data.help 		!= null) Settings.helpMess 		= configObj.data.help;
			if (configObj.data.hit 			!= null) Settings.showHit 		= configObj.data.hit;
			if (configObj.data.systemCursor != null) Settings.systemCursor 	= configObj.data.systemCursor;
			if (configObj.data.hintTele 	!= null) Settings.hintTele 		= configObj.data.hintTele;
			if (configObj.data.showFavs 	!= null) Settings.showFavs 		= configObj.data.showFavs;
			if (configObj.data.quakeCam 	!= null) Settings.quakeCam 		= configObj.data.quakeCam;
			if (configObj.data.errorShowOpt != null) Settings.errorShowOpt 	= configObj.data.errorShowOpt;
			if (configObj.data.app) 
			{
				appearanceWindow.load(configObj.data.app);
				appearanceWindow.setTransforms();
			}
			
			//TODO: Don't access languages' stuff directly like this.
			trace('GameSession.as/configObjSetup() - Fetching number of advice snippets.');
			if (Languages.currentLanguageData == null || Languages.currentLanguageData == undefined) 
			{
   				trace('GameSession.as/configObjSetup() - Either Languages.currentLanguageData is null or <advice> element is missing');
				return;
			}
			koladv = Languages.currentLanguageData[0].a.length();
			trace('GameSession.as/configObjSetup() - Snippets found: "' + koladv + '."');

			trace('GameSession.as/configObjSetup() - Fetching last advice ID. ID: ' + configObj.data.nadv + '.');
			if (configObj.data.nadv) 
			{
				nadv = configObj.data.nadv;
				configObj.data.nadv++;
				if (configObj.data.nadv >= koladv) configObj.data.nadv = 0;
			} 
			else configObj.data.nadv = 1;

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

			trace('GameSession.as/configObjSetup() - Finished setup.');
		}

		public function onDeactivate(event:Event):void //Pause and calling the pipbuck if focus is lost 
		{
			if (gameState == 1) pip.onoff(11);
			if (gameState > 0 && !Settings.alicorn) saveGame();
		}
		
		public function resizeScreen():void //Pause and call pipbuck if window size is changed
		{
			if (gameState > 0) cam.setLoc(room);
			if (gui) gui.resizeScreen(swfStage.stageWidth, swfStage.stageHeight);
			pip.resizeScreen(swfStage.stageWidth, swfStage.stageHeight);
			grafon.setSkyboxSize(swfStage.stageWidth, swfStage.stageHeight);
			if (stand) stand.resizeScreen(swfStage.stageWidth, swfStage.stageHeight);
			vblack.width 	= swfStage.stageWidth;
			vblack.height 	= swfStage.stageHeight;
			if (loadScreen < 0) 
			{
				loadingScreen.x = swfStage.stageWidth  / 2;
				loadingScreen.y = swfStage.stageHeight / 2;
			}
			if (gameState == 1 && !Settings.testMode) pip.onoff(11);
		}
		
		public function consolOnOff():void //Toggle the console on or off.
		{
			onConsol =! onConsol;
			consol.vis.visible = onConsol;
			if (onConsol) swfStage.focus = consol.vis.input;
		}
		
		
//=============================================================================================================
//			Game
//=============================================================================================================
		
		//Setting these public
		public var newGame:Boolean;
		public var data:Object;
		public var opt:Object;
		public var newName:String;

		//Start a new game or load a save. Pass the slot number or -1 for a new game
		//Stage 0 - create HUD, SATS, and pipuck
		public function startNewGame(nload:int = -1, nnewName:String = 'LP', nopt:Object = null):void // Called by the main menu when initializing the game.
		{
			trace('GameSession.as/startNewGame() - Starting a new game.');
			//TODO: Remove testMode.
			if (Settings.testMode && !Settings.chitOn) 
			{
				trace('GameSession.as/startNewGame() - Tried starting new game with test mode on.');
				loadingScreen.progres.text = 'error';
				return;
			}

			gameState = -1;
			opt = nopt;
			newName = nnewName;

			trace('GameSession.as/startNewGame() - Creating new "Game()".');
			// TODO: Merge the two areas creating a Game object.
			game = new Game(); // GAME DATA IS INITIALIZED HERE
			newGame = nload < 0;
			if (newGame) 
			{
				if (opt && opt.autoSaveN) 
				{
					autoSaveN = opt.autoSaveN;
					saveObj = saveArr[autoSaveN];
					nload = autoSaveN;
				} 
				else nload = 0;
				saveObj.clear();
			}
						
			trace('GameSession.as/startNewGame() - Creating new GUI.');
			gui = new GUI(vgui); // create GUI
			gui.resizeScreen(swfStage.stageWidth, swfStage.stageHeight);
			
			trace('GameSession.as/startNewGame() - Calling pip.toNormalMode().');
			pip.toNormalMode(); // switch PipBuck to normal mode
			pip.resizeScreen(swfStage.stageWidth, swfStage.stageHeight);

			trace('GameSession.as/startNewGame() - Creating new SATS.');
			sats = new Sats(vsats); // create SATS interface
			
			trace('GameSession.as/startNewGame() - Loading data.'); // Load save data from file or slot.
			if (nload == 99) data = loaddata; // loaded from file
			else data = saveArr[nload].data; // loaded from slot

			// LEVELS NEED TO BE LOADED BY HERE.
			trace('GameSession.as/startNewGame() - Waiting on all levels to load.')
			ng_wait = 1; // Waiting on all levels to be loaded.
		}
			
		private function newGameStage1():void // Levels have been loaded, do other stuff...
		{
			if (newGame) // Start new game
			{
				trace('GameSession.as/startNewGame() - Calling "game.init()".');
				game.init(null, opt);
			}
			else 
			{
				trace('GameSession.as/startNewGame() - Calling "game.init()".');
				game.init(data.game);
			}

			ng_wait = 2;
		}

		private function newGameStage2():void // stage 1 - create character and inventory
		{
			trace('GameSession.as/newGame1() - Starting a new game.');
			if (!newGame) appearanceWindow.load(data.app);
			if (data.hardInv) Settings.hardInv = true; else Settings.hardInv = false;
			if (opt && opt.hardinv) Settings.hardInv = true;

			initializePlayer(true);
			
			if (!newGame && data.n != null) // auto save slot number 
			{
				autoSaveN = data.n;
			}
			Unit.txtMiss = Res.txt('gui', 'miss');

			trace('GameSession.as/newGame1() - Waiting on player input to finish starting a new game.');
			waitLoadClick();

			ng_wait = 3;
		}
		
		
		private function newGameStage3():void // Stage 2 - Initialize the level, then enter it
		{
			trace('GameSession.as/newGame2() - Beginning STAGE 2 of a starting a new game.');

			trace('GameSession.as/newGame2() - Visual part. 1/4');
			resizeScreen();
			hideLoadingScreen();
			vgui.visible = true;
			skybox.visible = true;
			mainCanvas.visible = true;
			vblack.alpha = 1;
			cam.dblack = -10;
			pip.onoff(-1);

			trace('GameSession.as/newGame2() - Initializing level and entering room. 2/4');
			game.initializeLevel(); //!!!!


			trace('GameSession.as/newGame2() - Sound and GUI stuff. 3/4');
			Snd.off = false;
			gui.setAll();
			gameState = 1;
			ng_wait = 0;
		
			trace('GameSession.as/newGame2() - STAGE 2 of starting a new game complete. 4/4');
		}
		
		private function initializePlayer(isNewPlayer:Boolean):void
		{
			trace('GameSession.as/playerInitialization() - Initializing player, SATS, and GUI.');

			if (isNewPlayer)
			{
				pers = new Pers(data.pers, opt); // Create new pers (Player container?)
				pers.persName = newName; // Change default name if necessary. 
				
			}
			else
			{
				pers = new Pers(data.pers);
			}

			gg = new UnitPlayer(); // Create new player unit.
			gg.ctr = ctr; // Add reference to controller to player unit.
			gg.sats = sats; // Add reference to sats to player unit.
			sats.gg = gg; // Add reference to player unit to SATS.
			gui.gg = gg; // Add reference to player unit to GUI.

			if (isNewPlayer)
			{
				invent = new Invent(gg, data.invent, opt); 	// Initialize player inventory.
				stand = new Stand(vstand, invent); 			// Initialize item stand.
			}
			else
			{
				invent = new Invent(gg, data.invent);
			}

			if (stand) stand.inv = invent;
			else stand = new Stand(vstand, invent);

			gg.attach(); // Attach inventory to player unit.
			
			trace('GameSession.as/playerInitialization() - Player initialized.');
		}

		public function loadGame(nload:int = 0):void
		{
			comLoad = -1;
			if (room) 
			{
				room.unloadRoom();
			}
			level = null;
			room = null;
			cur('arrow');

			var data:Object; //loading object

			if (nload == 99) data = loaddata;
			else data = saveArr[nload].data;

			Snd.off = true;
			cam.showOn = false;			
			Settings.hardInv = data.hardInv;

			// TODO: Merge the two areas creating a Game object.
			game = new Game();	// GAME DATA (Levels, game data) IS INITIALIZED HERE
			game.init(data.game);
			appearanceWindow.load(data.app);

			initializePlayer(false);

			if (data.n != null) autoSaveN = data.n; // auto-save cell number
			
			hideLoadingScreen();
			vgui.visible 		= true;
			skybox.visible 		= true;
			mainCanvas.visible 	= true;
			vblack.alpha		= 1;
			cam.dblack			= -10;
			pip.onoff(-1);
			gui.allOn();
			t_die		= 0;
			t_battle	= 0;

			trace('GameSession.as/loadGame() - Initializing level.');
			game.initializeLevel();

			log = '';
			Snd.off = false;
			gui.setAll();
			gameState = 1;

			trace('GameSession.as/loadGame() - Finished loading game.');
		}
		
		// TODO: There is a graphical bug here (original author comment, not mine)
		// Previously AtivateLoc [sic]
		public function transitionToRoom(newRoom:Room):void // Call when entering a specific area
		{
			trace('GameSession.as/transitionToRoom() - Transitioning to room: "' + newRoom.id + '".');

			if (room != null) room.unloadRoom(); //If a room exists, unload it.
			room = newRoom; //Set the current room as the one you want to load.

			grafon.drawLoc(room); //Call grafon to draw the room.

			cam.setLoc(room);
			grafon.setSkyboxSize(swfStage.stageWidth, swfStage.stageHeight);
			gui.setAll();

			currentMusic = room.sndMusic;
			Snd.playMusic(currentMusic);

			//TODO: This doesn't need to be called every time, esepecially not here.
			gui.hpBarBoss();

			if (t_die <= 0) GameSession.currentSession.gg.controlOn(); //Enable player controls
			gui.dialText();
			pers.invMassParam();

			gc(); // Pause the game for a moment if needed for garbage collection.
		}
		
		public function redrawLoc():void
		{
			trace('GameSession.as/redrawLoc() - REDRAWING ROOM');
			grafon.drawLoc(room);
			cam.setLoc(room);
			gui.setAll();
		}

		public function exitLevel(fast:Boolean = false):void
		{
			trace('GameSession.as/exitLevel() - exiting Level.');
			if (t_exit > 0) return;

			gg.controlOff();
			pip.gamePause = true;

			if (fast) t_exit = 21;
			else t_exit = 100;

		}
		
		public function exitStep():void
		{
			t_exit--;

			if (t_exit == 99) cam.dblack = 1.5; // Fade to black for level change. (Canterlot, Factory, etc.)

			if (t_exit == 20) 
			{
				vblack.alpha = 0;
				cam.dblack = 0;
				setLoadScreen(getLoadScreen());
				Snd.off = true;
			}
			if (t_exit == 19) 
			{
				cur('arrow');
				game.initializeLevel();
			}
			if (t_exit == 18 && clickReq > 0) waitLoadClick();
			if (t_exit == 16) 
			{
				Mouse.show();
				Snd.off = false;
				hideLoadingScreen();
				vgui.visible = true;
				skybox.visible = true;
				mainCanvas.visible = true;
				vblack.alpha = 1;
				cam.dblack = -10;
				gg.controlOn();
				pip.gamePause = false;
			}
			if (t_exit == 1) 
			{
				gui.allOn();
			}
		}
		
		public function ggDieStep():void
		{
			t_die--;
			if (t_die == 200) cam.dblack = 2.2;
			if (t_die == 150) 
			{
				if (Settings.alicorn) 
				{
					game.runScript('gameover');
					t_die = 0;
				} 
				else 
				{
					if (gg.sost == 3) 
					{
						game.curLevelID = game.baseId;
						game.initializeLevel();
					} 
					else level.gotoCheckPoint();

					cam.dblack = -4;
					gg.vis.visible = true;
				}
			}
			if (t_die == 100) gg.resurect();
			if (t_die == 1) gg.controlOn();
		}

		public function step():void
		{
			if (verror.visible) return; // Pause gameplay with an error message is showing.

			if (!Languages.textLoaded)
			{
				trace('GameSession.as/step() - Language data still loading, waiting.');
				return;
			}

			ctr.step();	//Process controls
			Snd.step(); //Process sound

			if (ng_wait > 0)
			{
				
				if (!LevelArray.allLevelsLoaded) 
				{
					levelLoadTimer++
					if (levelLoadTimer++ > 30) 
					{
						trace('GameSession.as/step() - Waiting on levels to finish loading.');
						levelLoadTimer = 0;
					}
					return;
				}
				switch (ng_wait)
				{
					case 1:
						newGameStage1();
						break;
					case 2:
						newGameStage2();
						break;
					case 3:
						if (clickReq != 1) newGameStage3();
						break;
				}
			}

			if (!onConsol && !pip.active) swfStage.focus = swfStage;
			
			if (gameState == 1 && !onPause) //GAME STATE 1: RUNNING, NOT PAUSED
			{
				if (t_exit > 0) //exit loop
				{
					if (!(t_exit == 17 && clickReq == 1)) exitStep();
				}
				
				Emitter.kol2 = Emitter.kol1; //particle count
				Emitter.kol1 = 0;

				if (t_exit != 17) level.step(); //main loop !!!!
				
				if (t_die > 0) ggDieStep(); //death loop
				
				if (t_battle > 0) t_battle--; //battle timer
				
				sats.step2();
				
				if (calcMass) //if mass recalculation is needed
				{
					invent.calcMass();
					calcMass = false;
				}
				if (calcMassW) 
				{
					invent.calcWeaponMass();
					calcMassW = false;
				}

				t_save++; //Increment ticks since last save, if over 5000, and not in either test or alicorn mode, save the game.
				if (t_save > 5000 && !Settings.testMode && !Settings.alicorn)
				{
					saveGame();
				}

				checkLoot = false;
			}
			
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
			
			if (gameState >= 1) //GAME STATE 2: RUNNING, IN MENU
			{
				cam.calc(gg);
				gui.step();
				pip.step();
				sats.step();
				
				if (ctr.keyStates.keyPip) 
				{
					if (!sats.active) pip.onoff();
					ctr.keyStates.keyPip = false;
				}
				if (ctr.keyStates.keyInvent) 
				{
					if (!sats.active) pip.onoff(2);
					ctr.keyStates.keyInvent = false;
				}
				if (ctr.keyStates.keyStatus) 
				{
					if (!sats.active) pip.onoff(1, 1);
					ctr.keyStates.keyStatus = false;
				}
				if (ctr.keyStates.keySkills) 
				{
					if (!sats.active) pip.onoff(1, 2);
					ctr.keyStates.keySkills = false;
				}
				if (ctr.keyStates.keyMed) 
				{
					if (!sats.active) pip.onoff(1, 5);
					ctr.keyStates.keyMed = false;
				}
				if (ctr.keyStates.keyMap) 
				{
					if (!sats.active) pip.onoff(3, 1);
					ctr.keyStates.keyMap = false;
				}
				if (ctr.keyStates.keyQuest) 
				{
					if (!sats.active) pip.onoff(3, 2);
					ctr.keyStates.keyQuest = false;
				}
				if (ctr.keyStates.keySats) 
				{
					if (gg.ggControl && !pip.active && gg && gg.pipOff <= 0 && !catPause) sats.onoff();
					ctr.keyStates.keySats = false;
				}

				gameState = (pip.active || sats.active || stand.active || gui.guiPause) ? 2:1; //If any of these are active, game state is set to 'in menu', otherwise game state is set to 'running'.
				
				if (consol && consol.visoff) 
				{
					onConsol = false;
					consol.vis.visible = false;
					consol.visoff = false;
				}
			}

		}

//=============================================================================================================
//			Global interaction functions
//=============================================================================================================
		public function cur(ncur:String = 'arrow'):void
		{
			if (Settings.systemCursor) return;
			if (pip.active || stand.active || comLoad >= 0) ncur = 'arrow';
			else if (t_battle> 0) ncur ='combat';
			if (ncur != ccur) 
			{
				Mouse.cursor = ncur;
				Mouse.show();
				ccur = ncur;
			}
		}
		
		public function quake(x:Number, y:Number):void
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
			if (t_battle > 0) 				return 2;
			if (room && room.t_alarm > 0) 	return 2;
			if (level.loc_t > 120) 			return 1;
			return 0;
		}
		
		//TODO: Pull out into own class.
		public function showError(error:Error, extraInfo:String = null):void
		{
			if (!Settings.errorShow || !Settings.errorShowOpt) return;

			try // Error pop-up window localization
			{
				verror.info.text 			= Res.txt('pip', 'error');
				verror.butClose.text.text 	= Res.txt('pip', 'err_close');
				verror.butForever.text.text = Res.txt('pip', 'err_dont_show');
				verror.butCopy.text.text 	= Res.txt('pip', 'err_copy_to_clipboard');
			}
			catch(error:Error)
			{
				trace('GameSession.as/showError - ERROR: Could not localize text for the error popup window! Error: "' + error.message + '".');
			}

			verror.txt.text = error.message + '\n' + error.getStackTrace(); // Stack trace.
			verror.txt.text += '\n' + 'gr_stage: ' + gr_stage;			// Graphics stage when the error occured. 
			if (extraInfo != null) verror.txt.text += '\n' + extraInfo; // Print any extra info given.
			verror.visible = true;
		}
		
		public function gc():void
		{
			System.pauseForGCIfCollectionImminent(0.25)	
		}
		
//=============================================================================================================
//			Loading Screen
//=============================================================================================================

		//set loading screen
		public function setLoadScreen(n:int = -1):void
		{
			trace('GameSession.as/setLoadScreen() - setLoadScreen() executing...');
			loadScreen = n;
			loadingScreen.story.lmb.stop();
			loadingScreen.story.lmb.visible = false;
			vgui.visible = false;
			skybox.visible = false;
			mainCanvas.visible = false;
			vscene.visible = false;
			loadingScreen.visible = true;
			catPause = false;
			trace('GameSession.as/setLoadScreen() - Calling Res/txt("g", "loading").');
			loadingScreen.progres.text = Res.txt('gui', 'loading');

			if (n < 0) 
			{
				loadingScreen.x = swfStage.stageWidth / 2;
				loadingScreen.y = swfStage.stageHeight / 2;
				loadingScreen.skill.gotoAndStop(Math.floor(Math.random() * loadingScreen.skill.totalFrames + 1));
				loadingScreen.skill.visible = loadingScreen.progres.visible = true;
				loadingScreen.story.visible = false;
				clickReq = 0;
			} 
			else 
			{
				loadingScreen.x = loadingScreen.y = 0;
				loadingScreen.story.visible = true;
				loadingScreen.skill.visible = loadingScreen.progres.visible = false;

				if (n == 0) loadingScreen.story.txt.htmlText = '<i>' + Res.txt('gui', 'story') + '</i>';
				else loadingScreen.story.txt.htmlText = '<i>' + 'История' + n + '</i>';

				clickReq = 1;
			}

			loadingScreen.cacheAsBitmap = false;
			loadingScreen.cacheAsBitmap = true;
		}
		
		public function getLoadScreen():int // Determine which loading screen to display.
		{
			var nscr:int = LevelArray.initializedLevelVariants[game.curLevelID].loadScr;

			if (nscr >= 0 && (game.triggers['loadScr'] == null || game.triggers['loadScr'] < nscr))
			{
				game.triggers['loadScr'] = nscr;
				return nscr;
			}

			return -1;
		}
		
		public function waitLoadClick():void // Enable waiting for a click
		{
			loadingScreen.story.lmb.play();
			loadingScreen.story.lmb.visible = true;
		}
		
		public function hideLoadingScreen():void // Remove the loading screen
		{
			loadingScreen.visible = false;
			loadingScreen.story.visible = false;
			loadingScreen.skill.visible = loadingScreen.progres.visible = true;
			loadingScreen.story.lmb.stop();
			loadingScreen.story.lmb.visible = false;
			clickReq = 0;
		}
		
		public function showScene(sc:String, n:int = 0):void // Show the scene
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
				trace('GameSession.as/showScene() - ERROR: Could not show Scene: "' + sc + '" using backup instead.');
				vscene.gotoAndStop(1);
			}

			if (n > 0) vscene.sc.gotoAndPlay(n);
			else 	   vscene.sc.gotoAndPlay(1);

			vscene.visible = true;
		}
		
		public function unshowScene():void // Remove the scene
		{
			catPause = false;
			mainCanvas.visible = true;
			gui.allOn();
			vscene.gotoAndStop(1);
			vscene.visible = false;
		}
		
		public function endgame(n:int = 0):void // Final credits or gameover
		{
			loadingScreen.visible = false;
			skybox.visible = false;
			var s:String;
			if (n == 1) 
			{
				showScene('gameover');
				s = Res.lpName(Res.txt('gui', 'end_bad'));
			} 
			else if (pers.rep >= pers.repGood) 
			{
				showScene('endgame');
				s = Res.lpName(Res.txt('gui', 'end_good'));
				Snd.playMusic('music_fall_2');
			} 
			else 
			{
				showScene('endgame');
				s = Res.lpName(Res.txt('gui', 'end_norm'));
			}

			vscene.sc.txt.htmlText = s;
		}

//=============================================================================================================
//			Saves and configuration
//=============================================================================================================
		public function saveToObj(data:Object):void
		{
			var now:Date 	= new Date();
			data.game 		= game.save();
			data.pers 		= pers.save();
			data.invent 	= invent.save();
			data.app 		= appearanceWindow.save();
			data.date 		= now.time;
			data.n 			= autoSaveN;
			data.hardInv 	= Settings.hardInv;
			data.ver 		= Settings.version;
			data.est 		= 1;
		}
		
		public function saveGame(n:int = -1):void
		{
			if (n == -2) 
			{
				n = autoSaveN;
				var save = saveArr[n];
				saveToObj(save.data);
				save.flush();
				trace('GameSession.as/saveGame() - Конец');
				return;
			}
			if (t_save < 100 && n == -1 && !pers.hardcoreMode) return;
			if (pip.gamePause) return;
			if (n == -1) n = autoSaveN;

			save = saveArr[n];

			if (save is SharedObject) 
			{
				saveToObj(save.data);
				var r = save.flush();
				trace('GameSession.as/saveGame() - ' + r);
				if (n == 0) t_save = 0;
			}
		}
		
		public function getSave(n:int):Object 
		{
			if (saveArr[n] is SharedObject) return saveArr[n].data;
			else return null;
		}
		
		public function saveConfig():void
		{
			configObj.data.ctr = ctr.save();
			configObj.data.snd = Snd.save();
			configObj.data.language 	= Languages.languageName;
			configObj.data.chit 		= (Settings.chitOn ? 1:0);
			configObj.data.dialon 		= Settings.dialOn;
			configObj.data.zoom100 		= Settings.zoom100;
			configObj.data.help 		= Settings.helpMess;
			configObj.data.mat 			= Settings.matFilter;
			configObj.data.hit 			= Settings.showHit;
			configObj.data.systemCursor = Settings.systemCursor;
			configObj.data.hintTele 	= Settings.hintTele;
			configObj.data.showFavs 	= Settings.showFavs;
			configObj.data.quakeCam 	= Settings.quakeCam;
			configObj.data.errorShowOpt = Settings.errorShowOpt;
			configObj.data.app = appearanceWindow.save();

			if (lastCom != null) configObj.data.lastCom = lastCom;
				
			var configProperties:Array = 
			[
				"vsWeaponNew", "vsWeaponRep", "vsAmmoAll", "vsAmmoTek", "vsExplAll",
				"vsMedAll", "vsHimAll", "vsEqipAll", "vsStuffAll", "vsVal", 
				"vsBook", "vsFood", "vsComp", "vsIngr"
			];
			for each (var property:String in configProperties) 
			{
				configObj.data[property] = Settings[property] ? 0 : 1;
			}

			configObj.flush();
		}
	}
}