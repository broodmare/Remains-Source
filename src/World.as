package  src
{
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.net.URLLoader; 
	import flash.net.URLRequest; 
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
	
	import src.loc.*;
	import src.rooms.Rooms;
	import src.graph.Grafon;
	import src.graph.Part;
	import src.graph.Emitter;
	import src.inter.*;
	import src.serv.LootGen;
	import src.unit.Unit;
	import src.unit.UnitPlayer;
	import src.unit.Invent;
	import src.unit.Pers;
	import flash.external.ExternalInterface;
	import src.weapon.Weapon;

	
	public class World 
	{
		public static var w:World;
		
		public var playerMode:String;	//Flash player mode
		public var urle:String;			//URL from which the game was launched

		//Visual components
		public var main:Sprite;			//Main game sprite
		public var swfStage:Stage;	
		
		public var vwait:MovieClip;		//Loading image
		public var vfon:MovieClip;		//Static background
		public var visual:Sprite;		//Active area
		public var vscene:MovieClip;	//Scene
		public var vblack:MovieClip;	//Darkness
		public var vpip:MovieClip;		//Pipbuck
		public var vsats:MovieClip;		//HUD interface
		public var vgui:MovieClip;		//GUI (HUD)
		public var vstand:MovieClip;	//Stand
		public var verror:MovieClip;	//Error window
		public var vconsol:MovieClip;	//Console scroll
	
		//All main components
		public var mm:MainMenu;
		public var cam:Camera;			//Camera
		public var ctr:Ctr;				//Controls
		public var consol:Consol;		//Console
		public var game:Game;			//Game
		public var gg:UnitPlayer;		//Player unit
		public var pers:Pers;			//Character
		public var invent:Invent;		//Inventory
		public var gui:GUI;				//GUI
		public var grafon:Grafon;		//Graphics
		public var pip:PipBuck;			//Pipbuck
		public var stand:Stand;			//Stand
		public var sats:Sats;			//SATS
		public var app:Appear;			//Character appearance settings
		
		//Location components
		public var land:Land;		//Current terrain
		public var loc:Location;	//Current location
		public var rooms:Rooms;
		
		//Working variables
		public var onConsol:Boolean=false;	//Console active
		public var onPause:Boolean=false;	//Game on pause
		public var allStat:int=0; 			//Overall status 0 - game has not started
		public var celX:Number;				//Cursor coordinates in location coordinate system
		public var celY:Number;
		public var t_battle:int=0;			//Is there a battle happening or not
		public var t_die:int=0;				//Player character has died
		public var t_exit:int=0;			//Exit from location
		public var gr_stage:int=0;			//Location rendering stage
		public var checkLoot:Boolean=false;	//Recalculate auto-loot
		public var calcMass:Boolean=false;	//Recalculate mass
		public var calcMassW:Boolean=false;	//Recalculate weapon mass
		public var lastCom:String=null;
		public var armorWork:String='';		//Temporary display of armor
		public var mmArmor:Boolean=false;	//Armor in main menu
		public var catPause:Boolean=false;	//Pause for scene display
		
		public var testLoot:Boolean=false;	 //Loot and experience testing
		public var summxp:int=0;
		var ccur:String;
		
		public var currentMusic:String='';
		
		
		//Settings variables
		public var enemyAct:int=3;					//enemy activity, should be 3. If 0, enemies will not be active
		public var roomsLoad:int=1;  				//1-load from file
		var langLoad=1;  							//1-load from file
		public var addCheckSP:Boolean=false;		//add skill points when visiting checkpoints
		public var weaponsLevelsOff:Boolean=true;	//disable using weapons of incorrect level
		public var drawAllMap:Boolean=false;		//display the whole map without fog of war
		public var black:Boolean=true;				//display fog of war
		public var testMode:Boolean=false;			//Test mode
		public var chitOn:Boolean=false;
		public var chit:String='', chitX:String=null;	//current cheat
		public var showArea:Boolean=false;		//show active zones
		public var godMode:Boolean=false;		//invincibility 
		public var showAddInfo:Boolean=false;	//show additional information
		public var testBattle:Boolean=false;	//stamina will be consumed outside of battle
		public var testEff:Boolean=false;		//effects will be 10 times shorter
		public var testDam:Boolean=false;		//cancel damage range
		public var hardInv:Boolean=false;		//limited inventory
		public var alicorn:Boolean=false;
		public var maxParts:int=100;			//maximum particles
		
		public var zoom100:Boolean=false;		//zoom 100%
		public var dialOn:Boolean=true;			//show dialogues with NPCs
		public var showHit:int=2;				//show damage
		public var matFilter:Boolean=true;		//material filter
		public var helpMess:Boolean=true;		//tutorial messages
		
		public var shineObjs:Boolean=false;		//objects glow
		public var sysCur:Boolean=false;		//system cursor
		public var hintKeys:Boolean=true;		//keyboard hints
		public var hintTele:Boolean=true;		//teleport hints
		public var showFavs:Boolean=true;		//show additional info when cursor is on top of the screen
		public var errorShow:Boolean=true;
		public var errorShowOpt:Boolean=true;
		public var quakeCam:Boolean=true;		//camera shake
		
		public var vsWeaponNew:Boolean=true;	//automatically take new weapon if there is room
		public var vsWeaponRep:Boolean=true;	//automatically take weapon for repair
		public var vsAmmoAll:Boolean=true;		
		public var vsAmmoTek:Boolean=true;		
		public var vsExplAll:Boolean=true;		
		public var vsMedAll:Boolean=true;		
		public var vsHimAll:Boolean=true;		
		public var vsEqipAll:Boolean=true;		
		public var vsStuffAll:Boolean=true;		
		public var vsVal:Boolean=true;		
		public var vsBook:Boolean=true;		
		public var vsFood:Boolean=true;		
		public var vsComp:Boolean=true;		
		public var vsIngr:Boolean=true;		
		
		//Global constants
		public var actionDist=200*200;
		public static const tilePixelWidth=40;
		public static const tilePixelHeight=40;
		public static const cellsX:int=48;
		public static const cellsY:int=25;
		public static const fps=30;
		public static const ddy=1;
		public static const maxdy=20;
		public static const maxwaterdy=20;
		public static const maxdelta=9;
		public static const oduplenie=100;
		public static const battleNoOut=120;
		public static const unitXPMult:Number=2;
		public static const kolHK=12;			//number of hotkeys
		public static const kolQS=4;			//number of quick spells
			
		
		public static const boxDamage=0.2;		//box attack strength multiplier
		
		//Load texts
		public var lang:String='en';
		public var langDef:String='ru';
		public var languageList:Array;
		public var kolLangs:int=0;
		public var tl:TextLoader;
		public var tld:TextLoader;
		public var textLoaded:Boolean=false;
		public var textLoadErr:Boolean=false;
		var loader_lang:URLLoader; 
		var request_lang:URLRequest;
		public var langsXML:XML;
		public var textProgressLoad:Number=0;
		
		//Files
		public var soundPath:String;
		public var musicPath:String;
		public var textureURL:String;
		public var spriteURL:String;
		public var sprite1URL:String;
		public var musicKol:int=0;
		public var musicLoaded:int=0;
		
		
		//public var ressoundURL:String;
		public var langURL:String;
		
		//Loading, saves, config
		public var configObj:SharedObject;
		var saveObj:SharedObject;
		var saveArr:Array;
		public var saveKol:int=10;
		var savePath:String=null;
		var t_save:int=0;
		public var loaddata:Object;				//data loaded from file
		public var nadv:int=0, koladv:int=10;	//advice number
		public var load_log:String='';
		
		//Maps
		public var landPath:String;
		public var fileVersion:int=2;		//change this number to clear cache
		public var landData:Array;
		public var kolLands:int=0;
		public var kolLandsLoaded:int=0;
		public var allLandsLoaded:Boolean=false;
		
		public var comLoad:int=-1;		//load command
		public var clickReq:int=0;		//button click request, if set to 1, 2 will only be set after click
		public var ng_wait:int=0;		//new game wait
		public var loadScreen:int=-1;	//loading screen
		public var autoSaveN:int=0;		//autosave slot number
		public var log:String='';
		
		//fps counter
		public var tfc:Timer;	

		var fc:int=0;
		//var date:Date,
		var d1:int, d2:int;
		
		public var landError:Boolean=false;


		public function World(nmain:Sprite, paramObj:Object) 
		{
			World.w=this;

			// Technical part
			// Determine the player type and the address from which it is launched
			playerMode=Capabilities.playerType;
			
			//if (playerMode=='PlugIn') roomsLoad=0;
			/*if (playerMode=='PlugIn' && ExternalInterface.available) {
			   urle = ExternalInterface.call("window.location.href.toString");
			   if (urle=="http://foe.ucoz.org/test318/psrc.html") chitOn=true;
			}
			if (playerMode=='External') chitOn=true;
			chitOn=true;*/
			
			//files
			soundPath='';
			musicPath='Music/';
			textureURL='texture.swf';
			spriteURL='sprite.swf';
			sprite1URL='sprite1.swf';
			//ressoundURL='sound.swf';
			//textURL='D:/Dropbox/foe/text.xml';
			langURL='lang.xml';
			landPath='Rooms/';
			if (testMode) fileVersion=Math.random()*100000;
			if (playerMode=='PlugIn') 
			{
				musicPath='http://foe.ucoz.org/Sound/music/';
				//soundPath='http://foe.ucoz.org/Sound/';
				//musicPath='Sound/music/';
				soundPath='';
				langURL += '?u='+ Math.random().toFixed(5);
				//langURL+='?u='+fileVersion;
				textureURL += '?u='+fileVersion;
				spriteURL += '?u='+fileVersion;
				//ressoundURL+='?u='+fileVersion;
				//textURL='http://foe.ucoz.org/text.xml?u='+ Math.random().toFixed(5);
				//landPath='http://foe.ucoz.org/Rooms/';
				//graphURL='http://foe.ucoz.org/texture.swf'
				//ressoundURL='http://foe.ucoz.org/res.swf'
			}
			
			main = nmain;
			swfStage = main.stage;
			swfStage.tabChildren = false;
			swfStage.addEventListener(Event.DEACTIVATE, onDeactivate);
			Tile.tilePixelWidth = tilePixelWidth;
			Tile.tilePixelHeight = tilePixelHeight;
			
			//Data initialization
			loader_lang = new URLLoader(); 
			request_lang = new URLRequest(langURL); 
			loader_lang.load(request_lang); 
			loader_lang.addEventListener(Event.COMPLETE, onCompleteLoadLang);
			loader_lang.addEventListener(IOErrorEvent.IO_ERROR, onErrorLoadLang);
			


			//initTexts();
			
			LootGen.init();
			Form.setForms();
			Emitter.init();

			if (roomsLoad == 0) 
			{
				//=============================== Remove when loading from file
				//rooms=new Rooms();
			}
			
			//Creating graphic elements
			vwait = new visualWait();
			vwait.cacheAsBitmap = true;
			
			//Appearance configurator
			app=new Appear();
			
			visual=new Sprite();
			vgui=new visualGUI();
			vfon=new MovieClip();
			vpip=new visPipBuck();
			vstand=new visualStand();
			vsats=new MovieClip();
			vscene=new visualScene();
			vblack=new visBlack();
			vblack.cacheAsBitmap=true;
			vconsol=new visConsol();
			verror=new visError();
			setLoadScreen();
			vgui.visible=vpip.visible=vconsol.visible=vfon.visible=visual.visible=vsats.visible=vwait.visible=vblack.visible=verror.visible=vscene.visible=false;
			vscene.stop();
			main.addChild(vwait);
			main.addChild(vfon);
			main.addChild(visual);
			main.addChild(vscene);
			main.addChild(vblack);
			main.addChild(vpip);
			main.addChild(vsats);
			main.addChild(vgui);
			main.addChild(vstand);
			main.addChild(verror);
			main.addChild(vconsol);
			verror.butCopy.addEventListener(flash.events.MouseEvent.CLICK, function () {Clipboard.generalClipboard.clear();Clipboard.generalClipboard.setData(flash.desktop.ClipboardFormats.TEXT_FORMAT, verror.txt.text);});
			verror.butClose.addEventListener(flash.events.MouseEvent.CLICK, function () {verror.visible=false;});
			verror.butForever.addEventListener(flash.events.MouseEvent.CLICK, function () {errorShow=false; verror.visible=false;});
			vstand.visible=false;
			grafon=new Grafon(visual);
			cam=new Camera(this);
			load_log+='Stage 1 Ok\n';
			//FPS counter
			d1=d2=getTimer();
			
			//config, immediately loads sound settings
			configObj=SharedObject.getLocal('config',savePath);
			if (configObj.data.snd) Snd.load(configObj.data.snd);
			
			/*var nq:int=0;
			for each(var q in GameData.d.quest) {
				if (q.@rep>0) nq+=int(q.@rep);	
			}
			trace('rep',nq);*/
		}

//=============================================================================================================
//			Technical Part
//=============================================================================================================
		
		// The loading of the language list from xml was completed successfully
		function onCompleteLoadLang(event:Event):void  
		{
			try 
			{
				langsXML = new XML(loader_lang.data);
				initLangs(false)
			} 
			catch(err) 
			{
				trace('Error in language file');
				load_log+='Language file error: '+langURL+'\n';
				initLangs(true);
			}

			loader_lang.removeEventListener(Event.COMPLETE, onCompleteLoadLang);
			loader_lang.removeEventListener(IOErrorEvent.IO_ERROR, onErrorLoadLang);
			load_log+='Language file loading: '+langURL+' Ok\n';
		}
		
		//error loading language list from xml
		function onErrorLoadLang(event:IOErrorEvent):void 
		{
			initLangs(true);
			loader_lang.removeEventListener(Event.COMPLETE, onCompleteLoadLang);
			loader_lang.removeEventListener(IOErrorEvent.IO_ERROR, onErrorLoadLang);
			load_log+='Load lang error '+langURL+'\n';
			trace('Cannot load the list of languages');
        }
		
		//create language list, initiate language loading
		function initLangs(err:Boolean=false) 
		{
			if (err) langsXML = <all>
				<lang id='ru' file='text_ru.xml'>Русский</lang>
				<lang id='en' file='text_en.xml'>English</lang>
			</all>;	

			lang = Capabilities.language;
			
			if (configObj.data.language != null) lang = configObj.data.language;
			if (langsXML && langsXML.@default.length()) langDef=langsXML.@default;

			languageList = new Array();
			for each (var xmlFile:XML in langsXML.lang) 
			{
				if (xmlFile.@off.length()==0 || !xmlFile.@off>0) 
				{
					var obj={file:xmlFile.@file, nazv:xmlFile[0]};
					languageList[xmlFile.@id]=obj;
					kolLangs++;
				}
			}
			if (languageList[lang] == null) lang = langDef;
			tld = new TextLoader(languageList[langDef].file, true);
			if (lang != langDef) 
			{
				tl = new TextLoader(languageList[lang].file);
			} 
			else 
			{
				tl = tld;
			}
		}
		
		//language loading completed
		public function textsLoadOk() 
		{
			if (tl.loaded) 
			{
				textLoaded=true;
				Res.d = tl.d;
			}
			if (tl.errLoad) 
			{
				lang=langDef;
				if (tld.loaded) 
				{
					textLoaded=true;
					Res.d=tld.d;
				}
				textLoadErr=true;
			}
		}
		
		//select new language
		public function defuxLang(nid:String) 
		{
			lang=nid;
			textLoadErr=false;
			if (nid!=langDef) 
			{
				textLoaded=false;
				tl=new TextLoader(languageList[nid].file);
			} 
			else
			{
				Res.d=Res.e;
				pip.updateLang();
			}
			saveConfig();
		}
		
		function init2() 
		{
			if (consol) return;
			if (configObj) lastCom=configObj.data.lastCom;
			consol=new Consol(vconsol, lastCom);
			//saves and config
			saveArr=new Array();
			for (var i=0; i<=saveKol; i++) 
			{
				saveArr[i]=SharedObject.getLocal('PFEgame'+i,savePath);
			}
			saveObj = saveArr[0];
			/*if (configObj.data.lang) {
				curLang=configObj.data.lang;
				setLang();
			}*/
			if (configObj.data.dialon!=null) dialOn=configObj.data.dialon;
			if (configObj.data.zoom100!=null) zoom100=configObj.data.zoom100;
			if (zoom100) cam.isZoom=0; else cam.isZoom=2;
			if (configObj.data.mat!=null) matFilter=configObj.data.mat;
			if (configObj.data.help!=null) helpMess=configObj.data.help;
			if (configObj.data.hit!=null) showHit=configObj.data.hit;
			if (configObj.data.sysCur!=null) sysCur=configObj.data.sysCur;
			if (configObj.data.hintTele!=null) hintTele=configObj.data.hintTele;
			if (configObj.data.showFavs!=null) showFavs=configObj.data.showFavs;
			if (configObj.data.quakeCam!=null) quakeCam=configObj.data.quakeCam;
			if (configObj.data.errorShowOpt!=null) errorShowOpt=configObj.data.errorShowOpt;
			if (configObj.data.app) {
				app.load(configObj.data.app);// .loadObj=configObj.data.app;
				app.setTransforms();
			}
			try 
			{
				koladv=Res.d.advice[0].a.length();
			} 
			catch (err) {}

			if (configObj.data.nadv) 
			{
				nadv=configObj.data.nadv;
				configObj.data.nadv++;
				if (configObj.data.nadv>=koladv) configObj.data.nadv=0;
			} 
			else 
			{
				configObj.data.nadv=1;
			}

			if (configObj.data.chit>0) chitOn=true;
			
			if (configObj.data.vsWeaponNew>0) vsWeaponNew=false;
			if (configObj.data.vsWeaponRep>0) vsWeaponRep=false;
			if (configObj.data.vsAmmoAll>0) vsAmmoAll=false;	
			if (configObj.data.vsAmmoTek>0) vsAmmoTek=false;	
			if (configObj.data.vsExplAll>0) vsExplAll=false;	
			if (configObj.data.vsMedAll>0) vsMedAll=false;
			if (configObj.data.vsHimAll>0) vsHimAll=false;
			if (configObj.data.vsEqipAll>0) vsEqipAll=false;
			if (configObj.data.vsStuffAll>0) vsStuffAll=false;
			if (configObj.data.vsVal>0) vsVal=false;
			if (configObj.data.vsBook>0) vsBook=false;
			if (configObj.data.vsFood>0) vsFood=false;
			if (configObj.data.vsComp>0) vsComp=false;
			if (configObj.data.vsIngr>0) vsIngr=false;
			
			//trace(configObj.data.vsWeaponNew,vsWeaponNew);
			ctr = new Ctr(configObj.data.ctr);
			pip = new PipBuck(vpip);
			if (!sysCur) Mouse.cursor='arrow';
			
			//loading location maps
			landData = new Array();
			for each(var xl in GameData.d.land) 
			{
				if (!testMode && xl.@test>0) continue;
				var ll:LandLoader=new LandLoader(xl.@id);
				if (!(xl.@test>0)) kolLands++;
				landData[xl.@id]=ll;
			}
			
			//
			load_log+='Stage 2 Ok\n';
			Snd.loadMusic();
			
			//for (var i=0; i<100; i++) trace(Res.repText('raider', 'neutral'));
			//weaponWrite();
			//mm.main.stage.quality='low';
		}

		public function roomsLoadOk() 
		{
			if (!roomsLoad) 
			{
				allLandsLoaded=true;
				return;
			}
			kolLandsLoaded++;
			if (kolLands==kolLandsLoaded) allLandsLoaded=true;
		}

		//Pause and calling the pipbuck if focus is lost
		public function onDeactivate(event:Event):void  
		{
			if (allStat==1) 
			{
				pip.onoff(11);
				if (playerMode=='PlugIn') ctr.active=false;
			}
			if (allStat>0 && !alicorn) saveGame();
		}
		
		//Pause and call pipbuck if window size is changed
		public function resizeScreen() 
		{
			if (allStat>0) 
			{
				cam.setLoc(loc);
			} 
			if (gui) gui.resizeScreen(swfStage.stageWidth,swfStage.stageHeight);
			pip.resizeScreen(swfStage.stageWidth,swfStage.stageHeight);
			grafon.setFonSize(swfStage.stageWidth,swfStage.stageHeight);
			if (stand) stand.resizeScreen(swfStage.stageWidth,swfStage.stageHeight);
			vblack.width=swfStage.stageWidth;
			vblack.height=swfStage.stageHeight;
			if (loadScreen<0) 
			{
				vwait.x=swfStage.stageWidth/2;
				vwait.y=swfStage.stageHeight/2;
			}
			if (allStat==1 && !testMode) pip.onoff(11);
		}
		
		//Console call
		public function consolOnOff() 
		{
			onConsol=!onConsol;
			consol.vis.visible=onConsol;
			if (onConsol) swfStage.focus=consol.vis.input;
		}
		
		
//=============================================================================================================
//			Game
//=============================================================================================================
		
		var ng:Boolean;
		var data:Object;
		var opt:Object;
		var newName:String;

		//Start a new game or load a save. Pass the slot number or -1 for a new game
		//Stage 0 - create HUD, SATS, and pipuck
		//Initialize game
		public function newGame(nload:int=-1, nnewName:String='LP', nopt:Object=null) 
		{
			if (testMode && !chitOn) 
			{
				vwait.progres.text='error';
				return;
			}
			try 
			{
				time___metr();
				allStat=-1;
				opt=nopt;
				newName=nnewName;
				game=new Game();
				if (!roomsLoad) allLandsLoaded=true;
				ng=nload<0;
				if (ng) 
				{
					if (opt && opt.autoSaveN) 
					{
						autoSaveN=opt.autoSaveN;
						saveObj=saveArr[autoSaveN];
						nload=autoSaveN;
					} 
					else nload=0;
					saveObj.clear();
				}
				// create GUI
				gui=new GUI(vgui);
				gui.resizeScreen(swfStage.stageWidth,swfStage.stageHeight);
				// switch PipBuck to normal mode
				pip.toNormalMode();
				pip.resizeScreen(swfStage.stageWidth,swfStage.stageHeight);
				// create SATS interface
				sats=new Sats(vsats);
				time___metr('Интерфейс');
				
				// create game
				if (nload==99) 
				{
					data=loaddata;	// loaded from file
				} 
				else 
				{
					data=saveArr[nload].data; // loaded from slot
				}

				if (ng)	game.init(null,opt); 
				else game.init(data.game);

				ng_wait=1;
				time___metr('Game init');
				
			} 
			catch (err) {showError(err);}
		}
		
		// stage 1 - create character and inventory
		public function newGame1() 
		{
			try 
			{
				if (!ng) app.load(data.app);
				if (data.hardInv==true) hardInv=true; else hardInv=false;
				if (opt && opt.hardinv) hardInv=true;
				// create character
				pers = new Pers(data.pers, opt);
				if (ng) pers.persName=newName;
				// create player character
				gg = new UnitPlayer();
				gg.ctr=ctr;
				gg.sats=sats;
				sats.gg=gg;
				gui.gg=gg;
				// create inventory
				invent=new Invent(gg, data.invent, opt);
				stand=new Stand(vstand,invent);
				gg.attach();
				time___metr('Персонаж'); //'Character'
				// auto save slot number
				if (!ng) if (data.n!=null) autoSaveN=data.n;
				Unit.txtMiss=Res.guiText('miss');
				
				waitLoadClick();
				ng_wait=2;
				time___metr('Местность'); //'Terrain'
			} 
			catch (err) {showError(err);}
		}
		
		// Stage 2 - create a terrain and enter it
		public function newGame2() 
		{
			try 
			{
				
				//visual part
				resizeScreen();
				offLoadScreen();
				vgui.visible=vfon.visible=visual.visible=true;
				vblack.alpha=1;
				cam.dblack=-10;
				pip.onoff(-1);
				//enter the current location
				game.enterToCurLand();//!!!!
				game.beginGame();
				
				Snd.off=false;
				gui.setAll();
				if (World.w.playerMode=='PlugIn') ctr.active=false;
				allStat=1;
				ng_wait=0;
			} 
			catch (err) {showError(err);}
		}
		
		public function loadGame(nload:int=0) 
		{
			try 
			{
				time___metr();
				comLoad=-1;
				if (loc) loc.out();
				land=null;
				loc=null;
				try {cur('arrow');} catch(err){}
				//loading object
				var data:Object;
				if (nload==99) {
					data=loaddata;
				} else {
					data=saveArr[nload].data;
				}
				//create game
				Snd.off=true;
				cam.showOn=false;
				if (data.hardInv==true) hardInv=true; else hardInv=false;
				game=new Game();
				game.init(data.game);
				app.load(data.app);
				//create character
				pers=new Pers(data.pers);
				//create player unit
				gg=new UnitPlayer();
				gg.ctr=ctr;
				gg.sats=sats;
				sats.gg=gg;
				gui.gg=gg;
				// create an inventory
				invent=new Invent(gg, data.invent);
				if (stand) stand.inv=invent;
				else stand=new Stand(vstand,invent);
				gg.attach();
				// auto-save cell number
				if (data.n!=null) autoSaveN=data.n;
				
				offLoadScreen();
				vgui.visible=vfon.visible=visual.visible=true;
				vblack.alpha=1;
				cam.dblack=-10;
				pip.onoff(-1);
				gui.allOn();
				t_die=0;
				t_battle=0;
				time___metr('Персонаж'); //'Character'
				//enter the current location
				game.enterToCurLand();//!!!!
				game.beginGame();
				log='';
				Snd.off=false;
				gui.setAll();
				if (World.w.playerMode=='PlugIn') ctr.active=false;
				allStat=1;
			} 
			catch (err) {showError(err);}
		}
		
		// Call when entering a specific location
		public function ativateLand(nland:Land) 
		{
		try 
		{
			land=nland;
			grafon.drawFon(vfon,land.act.fon);
			//grafon.setFonSize(swfStage.stageWidth,swfStage.stageHeight);
			//vblack.alpha=1;
			//cam.dblack=-10;
		} 
		catch (err) {showError(err);}
		}
		
		// Call when entering a specific area
		// There is a graphical bug here
		public function ativateLoc(nloc:Location) 
		{
		try 
		{
			if (loc) loc.out(); //Unload current area
			loc=nloc; //Set the desired area as the current area
			//MAYBE TRY ZEROING OUT EVERYTHING IN GRAFON?
			grafon.drawLoc(loc); //Draw the current area
			cam.setLoc(loc);
			grafon.setFonSize(swfStage.stageWidth,swfStage.stageHeight);
			gui.setAll();
			currentMusic=loc.sndMusic;
			Snd.playMusic(currentMusic);
			gui.hpBarBoss();
			if (t_die<=0) World.w.gg.controlOn();
			gui.dialText();
			pers.invMassParam();
			gc();
		} 
		catch (err) {showError(err);}
		}
		
		public function redrawLoc() 
		{
			try 
			{
				grafon.drawLoc(loc);
				cam.setLoc(loc);
				gui.setAll();
			} catch (err) {showError(err);}
		}
		

		//MIGHT HAVE TO DO WITH BUG
		public function exitLand(fast:Boolean=false) {
			if (t_exit>0) return;
			gg.controlOff();
			pip.noAct=true;
			if (fast) 
			{
				t_exit=21; // is the game running out of rendering time because it's cut short for quicker transitions??
			} 
			else 
			{
				t_exit=100;
			}
		}
		
		
		function exitStep() 
		{
			try 
			{
				t_exit--;
				if (t_exit==99) cam.dblack=1.5;
				if (t_exit==20) 
				{
					vblack.alpha=0;
					cam.dblack=0;
					setLoadScreen(getLoadScreen());
					Snd.off=true;
				}
				if (t_exit==19) 
				{
					cur('arrow');
					game.enterToCurLand();
				}
				if (t_exit==18 && clickReq>0) waitLoadClick();
				if (t_exit==16) 
				{
					Mouse.show();
					Snd.off=false;
					offLoadScreen();
					vgui.visible=vfon.visible=visual.visible=true;
					vblack.alpha=1;
					cam.dblack=-10;
					gg.controlOn();
					pip.noAct=false;
				}
				if (t_exit==1) 
				{
					gui.allOn();
				}
			} 
			catch (err) {showError(err);}
		}
		
		// Player death
		/*public function ggDie() {
			gg.controlOff();
			gui.unshowSelector();
			if (pers.hardcore) {
				pers.dead=true;
				saveGame();
			} else {
				t_die=300;
			}
		}*/
		
		function ggDieStep() {
		try {
			t_die--;
			if (t_die==200) cam.dblack=2.2;
			if (t_die==150) {
				if (alicorn) {
					game.runScript('gameover');
					t_die=0;
				} else {
					if (gg.sost==3) {
						game.curLandId=game.baseId;
						game.enterToCurLand();
					} else {
						land.gotoCheckPoint();
					}
					cam.dblack=-4;
					gg.vis.visible=true;
				}
			}
			if (t_die==100) gg.resurect();
			if (t_die==1) {
				gg.controlOn();
			}
		} catch (err) {showError(err);}
		}
		
		/*public function onTfc(event:TimerEvent):void {
			step();
			//fc++;
			//vgui.vfc.text=swfStage.focus;
		}*/
		
		// Main loop
		public function step() 
		{
			try 
			{
				if (verror.visible) return;
				//Controls
				ctr.step();				
				Snd.step();
				if (ng_wait>0) 
				{
					if (ng_wait==1) 
					{
						newGame1();
					} else if (ng_wait==2) 
					{
						if (clickReq!=1) newGame2();
					}
					return;
				}
				if (!onConsol && !pip.active) swfStage.focus=swfStage;
				
				//Only if the game has started and not paused, game loops
				if (allStat==1 && !onPause) 
				{
					//exit loop
					if (t_exit>0) 
					{
						if (!(t_exit==17 && clickReq==1)) exitStep();
					}
					//particle count
					Emitter.kol2=Emitter.kol1;
					Emitter.kol1=0;
					//trace(Emitter.kol2);

					//main loop !!!!
					if (t_exit!=17) land.step();

					//death loop
					if (t_die>0) ggDieStep();

					//battle timer
					if (t_battle>0) t_battle--;

					sats.step2();

					//if mass recalculation is needed
					if (calcMass) 
					{
						invent.calcMass();
						calcMass=false;
					}
					if (calcMassW) 
					{
						invent.calcWeaponMass();
						calcMassW=false;
					}
					//save
					t_save++;
					if (t_save>5000 && !testMode && !alicorn) 
					{
						saveGame();
					}
					checkLoot=false;
				}
				//trace(clickReq,t_exit)
				
				if (comLoad>=0) 
				{
					if (comLoad>=100) 
					{
						if (autoSaveN>0) saveGame();
						loadGame(comLoad-100);
					} 
					else 
					{
						pip.onoff(-1);
						comLoad+=100;
						setLoadScreen();
					}
				}
				
				//If the game has started, and is also on pause
				if (allStat>=1) 
				{
					cam.calc(gg);
					gui.step();
					pip.step();
					sats.step();
					if (ctr.keyPip) 
					{
						if (!sats.active) pip.onoff();
						ctr.keyPip=false;
					}
					if (ctr.keyInvent) 
					{
						if (!sats.active) pip.onoff(2);
						ctr.keyInvent=false;
					}
					if (ctr.keyStatus) 
					{
						if (!sats.active) pip.onoff(1,1);
						ctr.keyStatus=false;
					}
					if (ctr.keySkills) 
					{
						if (!sats.active) pip.onoff(1,2);
						ctr.keySkills=false;
					}
					if (ctr.keyMed) 
					{
						if (!sats.active) pip.onoff(1,5);
						ctr.keyMed=false;
					}
					if (ctr.keyMap) 
					{
						if (!sats.active) pip.onoff(3,1);
						ctr.keyMap=false;
					}
					if (ctr.keyQuest) 
					{
						if (!sats.active) pip.onoff(3,2);
						ctr.keyQuest=false;
					}
					if (ctr.keySats) 
					{
						if (gg.ggControl && !pip.active && gg && gg.pipOff<=0 && !catPause) sats.onoff();
						ctr.keySats=false;
					}
					allStat=(pip.active || sats.active || stand.active || gui.guiPause)?2:1;
					
					if (consol && consol.visoff) 
					{
						onConsol=consol.vis.visible=consol.visoff=false;
					}
				}
				//var d1a=d1;  FPS
				/*d1=getTimer();
				fc++;
				if (fc==30) {
					fc=0;
					vgui.vfc.text=d1-d2;
					d2=d1;
				}*/
			} catch (err) {showError(err);}
		}

//=============================================================================================================
//			Global interaction functions
//=============================================================================================================
		public function cur(ncur:String='arrow') 
		{
			if (sysCur) return;
			if (pip.active || stand.active || comLoad>=0) ncur='arrow';
			else if (t_battle>0) ncur='combat';
			if (ncur!=ccur) 
			{
				Mouse.cursor = ncur;
				Mouse.show();
				ccur=ncur;
			}
		}
		
		public function quake(x:Number, y:Number) 
		{
			if (loc.sky) return;
			if (quakeCam) 
			{
				cam.quakeX+=x;
				cam.quakeY+=y;
				if (cam.quakeX>20) cam.quakeX=20;
				if (cam.quakeX<-20) cam.quakeX=-20;
				if (cam.quakeY>20) cam.quakeY=20;
				if (cam.quakeY<-20) cam.quakeY=-20;
			}
		}
		
		public function possiblyOut():int 
		{
			if (t_battle>0) return 2;
			if (loc && loc.t_alarm>0) return 2;
			if (land.loc_t>120) return 1;
			return 0;
		}
		
		public function showError(err:Error, dop:String=null) 
		{
			if (!errorShow || !errorShowOpt) return;

			try 
			{
				verror.info.text=Res.pipText('error');
				verror.butClose.text.text=Res.pipText('err_close');
				verror.butForever.text.text=Res.pipText('err_dont_show');
				verror.butCopy.text.text=Res.pipText('err_copy_to_clipboard');
			} catch (e) {}

			verror.txt.text=err.message+'\n'+err.getStackTrace();
			verror.txt.text+='\n'+'gr_stage: '+gr_stage;
			if (dop!=null) verror.txt.text+='\n'+dop;
			verror.visible=true;
		}
		
		//measurement of action time
		public function time___metr(s=null) 
		{
			d2=getTimer();
			if (s!=null) trace(d2-d1,s);
			d1=d2;
		}
		
		public function gc() 
		{
			System.pauseForGCIfCollectionImminent(0.25)	
		}
		
//=============================================================================================================
//			Loading Screen
//=============================================================================================================
		//set loading screen
		public function setLoadScreen(n:int=-1) 
		{
			loadScreen=n;
			vwait.story.lmb.stop();
			vwait.story.lmb.visible=false;
			vgui.visible=vfon.visible=visual.visible=vscene.visible=false;
			vwait.visible=true;
			catPause=false;
			vwait.progres.text=Res.guiText('loading');

			if (n<0) 
			{
				vwait.x=swfStage.stageWidth/2;
				vwait.y=swfStage.stageHeight/2;
				vwait.skill.gotoAndStop(Math.floor(Math.random()*vwait.skill.totalFrames+1));
				vwait.skill.visible=vwait.progres.visible=true;
				vwait.story.visible=false;
				clickReq=0;
			} 
			else 
			{
				vwait.x=vwait.y=0;
				vwait.story.visible=true;
				vwait.skill.visible=vwait.progres.visible=false;

				if (n==0) 
				{
					vwait.story.txt.htmlText='<i>'+Res.guiText('story')+'</i>';
				} 
				else 
				{
					vwait.story.txt.htmlText='<i>'+'История'+n+'</i>';
				}

				clickReq=1;
			}

			vwait.cacheAsBitmap=false;
			vwait.cacheAsBitmap=true;
		}
		
		// Determine which loading screen to display
		function getLoadScreen():int 
		{
			return -1;
			try 
			{
				var nscr=game.lands[game.curLandId].loadScr;
				if (nscr>=0 && (game.triggers['loadScr']==null || game.triggers['loadScr']<nscr))
				 {
					game.triggers['loadScr']=nscr;
					return nscr;
				}
			} catch(err) {}
			return -1;
		}
		
		// Enable waiting for a click
		function waitLoadClick() 
		{
			vwait.story.lmb.play();
			vwait.story.lmb.visible=true;
		}
		
		// Remove the loading screen
		function offLoadScreen() 
		{
			vwait.visible=false;
			vwait.story.visible=false;
			vwait.skill.visible=vwait.progres.visible=true;
			vwait.story.lmb.stop();
			vwait.story.lmb.visible=false;
			clickReq=0;
		}
		// Show the scene
		public function showScene(sc:String, n:int=0) 
		{
			catPause=true;
			visual.visible=false;
			gui.allOff();
			gui.offCelObj();

			try 
			{
				vscene.gotoAndStop(sc);
			}  catch(err){vscene.gotoAndStop(1);}

			try 
			{
				if (n>0) 
				{
					vscene.sc.gotoAndPlay(n);
				} 
				else
				{
					vscene.sc.gotoAndPlay(1);
				}
			} catch(err){}

			vscene.visible=true;
		}
		
		// Remove the scene
		public function unshowScene() 
		{
			catPause=false;
			visual.visible=true;
			gui.allOn();
			vscene.gotoAndStop(1);
			vscene.visible=false;
		}
		
		// Final credits or game over
		public function endgame(n:int=0) 
		{
			vwait.visible=vfon.visible=false;
			var s:String;
			if (n==1) 
			{
				showScene('gameover');
				s=Res.lpName(Res.guiText('end_bad'));
			} 
			else if (pers.rep>=pers.repGood) 
			{
				showScene('endgame');
				s=Res.lpName(Res.guiText('end_good'));
				Snd.playMusic('music_fall_2');
			} 
			else 
			{
				showScene('endgame');
				s=Res.lpName(Res.guiText('end_norm'));
				//Snd.playMusic('music_fall_2');
			}
			try 
			{
				vscene.sc.txt.htmlText=s;
			} catch(err){}
		}
//=============================================================================================================
//			Saves and configuration
//=============================================================================================================
		public function saveToObj(data:Object) 
		{
			var now:Date = new Date();
			data.game=game.save();
			data.pers=pers.save();
			data.invent=invent.save();
			data.app=app.save();
			data.date=now.time;
			data.n=autoSaveN;
			data.hardInv=hardInv;
			data.ver=mm.version;
			data.est=1;
		}
		
		public function saveGame(n:int=-1) 
		{
			if (n==-2) 
			{
				n=autoSaveN;
				var save=saveArr[n];
				saveToObj(save.data);
				save.flush();
				trace('Конец');
				return;
			}
			if (t_save<100 && n==-1 && !pers.hardcore) return;
			if (pip.noAct) return;
			if (n==-1) n=autoSaveN;
			var save=saveArr[n];
			if (save is SharedObject) {
				saveToObj(save.data);
				var r=save.flush();
				trace(r);
				if (n==0) t_save=0;
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
			configObj.data.ctr=ctr.save();
			configObj.data.snd=Snd.save();
			configObj.data.language=lang;
			configObj.data.chit=(chitOn?1:0);
			configObj.data.dialon=dialOn;
			configObj.data.zoom100=zoom100;
			configObj.data.help=helpMess;
			configObj.data.mat=matFilter;
			configObj.data.hit=showHit;
			configObj.data.sysCur=sysCur;
			configObj.data.hintTele=hintTele;
			configObj.data.showFavs=showFavs;
			configObj.data.quakeCam=quakeCam;
			configObj.data.errorShowOpt=errorShowOpt;
			configObj.data.app=app.save();
			if (lastCom!=null) configObj.data.lastCom=lastCom;
				
			configObj.data.vsWeaponNew=vsWeaponNew?0:1;
			configObj.data.vsWeaponRep=vsWeaponRep?0:1;
			configObj.data.vsAmmoAll=vsAmmoAll?0:1;	
			configObj.data.vsAmmoTek=vsAmmoTek?0:1;	
			configObj.data.vsExplAll=vsExplAll?0:1;	
			configObj.data.vsMedAll=vsMedAll?0:1;
			configObj.data.vsHimAll=vsHimAll?0:1;
			configObj.data.vsEqipAll=vsEqipAll?0:1;
			configObj.data.vsStuffAll=vsStuffAll?0:1;
			configObj.data.vsVal=vsVal?0:1;
			configObj.data.vsBook=vsBook?0:1;
			configObj.data.vsFood=vsFood?0:1;
			configObj.data.vsComp=vsComp?0:1;
			configObj.data.vsIngr=vsIngr?0:1;
			configObj.flush();
			} catch (err) {showError(err);}
		}
		
		function weaponWrite() 
		{
			var un:Unit = new Unit();
			var s:String='';
			for each (var w in AllData.d.weapon.(@tip>0)) 
			{
				var weap:Weapon=new Weapon(un,w.@id,0);
				s+=weap.write()+'\n';
				if (w.com.length() && w.com.@uniq.length()) 
				{
					weap=new Weapon(un,w.@id,1);
					s+=weap.write()+'\n';
				}
			}
			trace(s);
		}
				
		
	}
	
}
