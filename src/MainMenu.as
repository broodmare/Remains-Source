package
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageScaleMode;
	import flash.display.StageDisplayState;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.SimpleButton;
	import flash.text.TextFormat;
	import flash.text.StyleSheet;
	import flash.net.FileReference;
	import flash.net.FileFilter;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.events.TimerEvent;

	import interdata.PipPageOpt;
	import interdata.PipBuck;
	import interdata.Appear;
	import graphdata.Displ;
	

	import systems.Languages;
	import components.Settings;
	import components.XmlBook;

	import stubs.*;

	public class MainMenu 
	{
		
		public var mainMenu; 			// Create a container for the main menu sprite
		public var main:Sprite;
		public var world:World;
		public var active:Boolean 		= true;
		public var loaded:Boolean 		= false;	// If ALL resources (language, levels, grafon) are done loading.
		public var newGameDif:int 		= 2;
		public var loadCell:int 		= -1;
		public var loadReg:int 			= 0;	// loading mode, 0 - loading, 1 - slot selection for autosave
		public var command:int 			= 0; 	//What should the main menu be doing?
		public var com:String 			= '';
		public var pip:PipBuck;
		public var displ:Displ;
		public var animOn:Boolean			= true;
		public var langReload:Boolean		= false;
		private var langButtonsLoaded:Boolean = false;

		public var kolDifs:int 				= 5;
		public var kolOpts:int 				= 6;
		
		public var languageButtons:Array;

		public var style:StyleSheet 		= new StyleSheet(); 
		public var styleObj:Object 			= {};
		public var format:TextFormat 		= new TextFormat();
		public var file:FileReference 		= new FileReference();
		public var ffil:Array;
		public var arr:Array				= [];
		
		public var mainMenuLoaded:Boolean = false;

		public function MainMenu(nmain:Sprite)
		{
			trace('MainMenu.as/MainMenu() - Main Menu Starting, Calling Settings.as/settingsSetup().');
			Settings.settingsSetup();

			trace('MainMenu.as/MainMenu() - Calling XmlBook.as/xmlBookSetup().');
			XmlBook.xmlBookSetup();

			main = nmain;
			mainMenu = new visMainMenu(); //Linkage

			mainMenu.dialLoad.visible 		= false;
			mainMenu.dialNew.visible 		= false;
			mainMenu.dialAbout.visible 		= false;

			main.stage.addEventListener(Event.RESIZE, resizeDisplay);
			main.stage.addEventListener(Event.ENTER_FRAME, mainStep);
			
			trace('MainMenu.as/MainMenu() - Turning off buttons.');
			showMainButtons(false);
			
			trace('MainMenu.as/MainMenu() - Calling mainMenuOn()...');
			mainMenuOn();

			trace('MainMenu.as/MainMenu() - Creating new world and passing the "main" sprite.');
			world = new World(main);

			world.mainMenu = this;
			mainMenu.info.visible = false;
			

			trace('MainMenu.as/MainMenu() - Calling Sound/initSound...');
			Snd.initSnd();


		}

		public function continueLoading():void
		{

			trace('MainMenu.as/continueLoading() - Calling MainMenu/SetMenuSize...');
			setMenuSize(); //NEEDS world.app.

			trace('MainMenu.as/continueLoading() - Applying Formating...');
			displ = new Displ(mainMenu.pipka, mainMenu.groza);
			mainMenu.groza.visible = false;
			format.font = "_sans";
            format.color = 0xFFFFFF;
            format.size = 28;
			
			styleObj.fontWeight = "bold"; 
			styleObj.color		= "#FFFF00"; 
			style.setStyle(".yel", styleObj); 	//выделение важного
			
			styleObj.fontWeight = "normal"; 
			styleObj.color 		= "#00FF99";
			styleObj.fontSize	= "12";
			style.setStyle(".music", styleObj); 	//мелкий шрифт
			
			styleObj.fontWeight = "normal"; 
			styleObj.color 		= "#66FF66";
			styleObj.fontSize 	= undefined;
			style.setStyle("a", styleObj); 	//ссыль
			styleObj.textDecoration = "underline";
			style.setStyle("a:hover", styleObj);
			
			mainMenu.info.txt.styleSheet 	= style;
			mainMenu.link.l1.styleSheet 	= style;
			mainMenu.link.l2.styleSheet 	= style;

			trace('MainMenu.as/continueLoading() - Main menu setup finished..');
			
		}

		public function mainMenuOn():void
		{
			trace('MainMenu.as/mainMenuOn() - setting mainMenu.active to true.');
			active = true;

			mainMenuListenerToggle(true);
			if (!main.contains(mainMenu))
			{
				main.addChild(mainMenu);
			}
			file.addEventListener(Event.SELECT, selectHandler);
			file.addEventListener(Event.COMPLETE, completeHandler);
		}
		
		public function mainMenuOff():void
		{
			trace('MainMenu.as/mainMenuOff() - mainMenu disabled.');
			active = false;


			mainMenuListenerToggle(false);

			for each(var m:* in languageButtons) 
			{
				if (m) m.removeEventListener(MouseEvent.CLICK, languageButtonPress);
			}
			if (main.contains(mainMenu)) main.removeChild(mainMenu);
			world.loadingScreen.visible = true;
			world.loadingScreen.progres.text = Res.txt('gui', 'loading');
		}

		public function mainMenuListenerToggle(enabled:Boolean):void
		{
			var mainFivebuttons:Array = [mainMenu.butContGame, mainMenu.butLoadGame, mainMenu.butNewGame, mainMenu.butOpt, mainMenu.butAbout];
			var toggle:Function;
			
			for each (var mainFiveButton:Object in mainFivebuttons) 
			{
				toggle = enabled ? mainFiveButton.addEventListener : mainFiveButton.removeEventListener;
				toggle(MouseEvent.MOUSE_OVER, funOver);
				toggle(MouseEvent.MOUSE_OUT, funOut);
				toggle(MouseEvent.CLICK, mainMenuButtonPress);
    		}

			toggle = enabled ? mainMenu.adv.addEventListener : mainMenu.adv.removeEventListener;
			toggle(MouseEvent.CLICK, funAdv);
			toggle(MouseEvent.RIGHT_CLICK, funAdvR);

			toggle = enabled ? file.addEventListener : file.removeEventListener;
			toggle(Event.SELECT, selectHandler);
			toggle(Event.COMPLETE, completeHandler);
		}


		private function mainMenuButtonPress(event:MouseEvent):void
		{
			trace('MainMenu.as/mainMenuButtonPress() - "' + event.currentTarget.name + '" pressed.');
			switch(event.currentTarget.name)
			{
        		case "butContGame":
					trace('MainMenu.as/mainMenuButtonPress() - Opening Continue Game window.');
					var n:int = 0;
					var maxDate:Number = 0;
					for (var i:int = 0; i <= world.saveCount; i++) 
					{
						var save:Object = World.world.getSave(i);
						if (save && save.est && save.date > maxDate) 
						{
							n = i;
							maxDate = save.date;
						}
					}

					save = World.world.getSave(n);

					if (save && save.est) 
					{
						mainMenuOff();
						loadCell = n;
						command  = 3;
					} 
					else 
					{
						mainNewOn();
						mainLoadOff();
					}
           			break;

        		case "butLoadGame":
					trace('MainMenu.as/mainMenuButtonPress() - Opening Load Game window.');
					world.mmArmor = true;
					mainNewOff();
					loadReg = 0;
					mainLoadOn();
					break;
				case "butNewGame":
					trace('MainMenu.as/mainMenuButtonPress() - Opening New Game window.');
					world.mmArmor = false;
					mainLoadOff();
					mainNewOn();
					break;
				case "butOpt":
					trace('MainMenu.as/mainMenuButtonPress() - Opening Options window.');
					mainNewOff();
					mainLoadOff();
					world.pip.onoff();
					break;
				case "butAbout":
					trace('MainMenu.as/mainMenuButtonPress() - Executing funAbout().');
					mainMenu.dialAbout.title.text = Res.txt('gui', 'about');
					var s:String = Res.formatText(Res.txt('gui','about', 1));
					s += '<br><br>' + Res.txt('gui', 'usedmusic') + '<br>';
					s += "<br><span class='music'>" + Res.formatText(Res.localizationFile.gui.(@id == 'usedmusic').info[0]) + "</span>"
					s += "<br><br><a href='https://creativecommons.org/licenses/by-nc/4.0/legalcode'>Music CC-BY License</a>";
					mainMenu.dialAbout.txt.styleSheet 	= style;
					mainMenu.dialAbout.txt.htmlText 	= s;
					mainMenu.dialAbout.visible 			= true;
					mainMenu.dialAbout.butCancel.addEventListener(MouseEvent.CLICK, funAboutOk);
					mainMenu.dialAbout.scroll.maxScrollPosition = mainMenu.dialAbout.txt.maxScrollV;
					break;
				default:
           			trace("MainMenu.as/mainMenuButtonPress() - Unknown button pressed");
            		break;
			}

		}

		public function funOver(event:MouseEvent):void //Mouseover
		{
			(event.currentTarget as MovieClip).fon.scaleX = 1;
			(event.currentTarget as MovieClip).fon.alpha  = 1.5;
		}

		public function funOut(event:MouseEvent):void //Mouseover stopped
		{
			(event.currentTarget as MovieClip).fon.scaleX = 0.7;
			(event.currentTarget as MovieClip).fon.alpha  = 1;
		}
		
		public function setLangButtons():void
		{
			trace('MainMenu.as/setLangButtons() - Creating language buttons.');
			languageButtons = [];

			try
			{
				for each(var language:XML in Languages.languageListDictionary)
				{
					if(language.lang.@id != "" && language.lang.text() != "")
					{
						Languages.languageCount++;
						var button = new butLang();

						var languageId:String = language.lang.@id;
						var languageName:String = language.lang.text();

						trace('MainMenu.as/setLangButtons() - languageId: "' + languageId + '" languageName : "' + languageName + '"');

						// Set the button properties
						button.languageButtonTextField.text = languageName;
						button.y = -Languages.languageCount * 40;
						button.n.text = languageId;
						button.n.visible = false;
						button.addEventListener(MouseEvent.CLICK, languageButtonPress);
						mainMenu.lang.addChild(button)
					}
					else // Check languageListDictionary length and output error about a blank entry.
					{
						var dictionaryLength:int = 0;
						for (var key:* in Languages.languageListDictionary)
						{
							dictionaryLength++;
						}
						trace('MainMenu.as/setLangButtons() - Skipping blank language in languageListDictionary. languageListDictionary length: "' + dictionaryLength + '".');
					}
				}
			}
			catch(err:Error)
			{
				trace('MainMenu.as/setLangButtons() - ERROR: Failed to create language buttons. Error: "' + err.message + '."');
			}

			trace('MainMenu.as/setLangButtons() - Created: "' + Languages.languageCount + '" language buttons.');

			if (Languages.languageCount > -1 ) //-1 is the starting value.
			{
				langButtonsLoaded = true;
			}
		}
		
		//Language
		public function updateMainMenuLanguage():void
		{
			trace('MainMenu.as/updateMainMenuLanguage() - Updating language on mainMenu buttons.');

			setMainButton(mainMenu.butContGame, Res.txt('gui', 'contgame'));
			setMainButton(mainMenu.butNewGame, 	Res.txt('gui', 'newgame'));
			setMainButton(mainMenu.butLoadGame, Res.txt('gui', 'loadgame'));
			setMainButton(mainMenu.butOpt, 		Res.txt('gui', 'options'));
			setMainButton(mainMenu.butAbout, 	Res.txt('gui', 'about'));

			mainMenu.dialNew.title.text 			= Res.txt('gui', 'newgame');
			mainMenu.dialLoad.title.text 			= Res.txt('gui', 'loadgame');
			mainMenu.dialLoad.title2.text 			= Res.txt('gui', 'select_slot');
			mainMenu.version.htmlText 				= '<b>' + Res.txt('gui', 'version') + ' ' + Settings.version + '</b>';
			mainMenu.dialLoad.butCancel.text.text 	= Res.txt('gui', 'cancel');
			mainMenu.dialNew.butCancel.text.text 	= Res.txt('gui', 'cancel');
			mainMenu.dialLoad.butFile.text.text 	= Res.txt('pip', 'loadfile');
			mainMenu.dialLoad.warn.text 			= Res.txt('gui', 'loadwarn');
			mainMenu.dialNew.warn.text 				= Res.txt('gui', 'loadwarn');
			mainMenu.dialNew.infoName.text 			= Res.txt('gui', 'inputname');
			mainMenu.dialNew.hardOpt.text 			= Res.txt('gui', 'hardopt');
			mainMenu.dialNew.butOk.text.text 		= 'OK';
			mainMenu.dialNew.inputName.text 		= Res.txt('unit','littlepip');
			mainMenu.dialNew.maxChars = 32;

			for (var i:int = 0; i < kolDifs; i++) 
			{
				mainMenu.dialNew['dif' + i].mode.text 		= Res.txt('gui', 'dif' + i);
				mainMenu.dialNew['dif' + i].modeinfo.text 	= Res.formatText(Res.txt('gui', 'dif' + i, 1));
			}

			for (var j:int = 1; j <= kolOpts; j++) 
			{
				mainMenu.dialNew['infoOpt' + j].text = Res.txt('gui', 'opt' + j);
			}
			
			mainMenu.dialNew.butVid.mode.text = Res.txt('gui', 'butvid');

			world.app.setLang();

			mainMenu.adv.text 			= Res.advText(world.nadv);
			mainMenu.adv.y 				= main.stage.stageHeight - mainMenu.adv.textHeight - 40;


			mainMenu.info.txt.htmlText 	= Res.txt('gui', 'inform') + '<br>' + Res.txt('gui', 'inform', 1);
			mainMenu.info.visible 		= (mainMenu.info.txt.text.length > 0);


			setScrollInfo();

			trace('MainMenu.as/updateMainMenuLanguage() - Finished updating mainMenu language.');
		}
		
		public function setMainButton(but:MovieClip, txt:String):void
		{
			but.txt.text 	= txt;
			but.glow.text 	= txt;
			but.txt.visible = (but.glow.textWidth < 1)
		}
		
		public function setMenuSize():void
		{
			mainMenu.adv.y 		= main.stage.stageHeight - mainMenu.adv.textHeight - 40;
			mainMenu.version.y 	= main.stage.stageHeight - 58;
			mainMenu.link.y 	= main.stage.stageHeight - 125;
			var ny:int			= main.stage.stageHeight - 400;
			if (ny < 280) ny = 280;
			mainMenu.dialLoad.x = main.stage.stageWidth / 2;
			mainMenu.dialNew.x 	= main.stage.stageWidth / 2;
			
			world.app.vis.x 	= main.stage.stageWidth / 2;
			mainMenu.dialLoad.y = ny;
			mainMenu.dialNew.y 	= ny;
			world.app.vis.y 	= ny;

			mainMenu.lang.x 	= main.stage.stageWidth  - 30;
			mainMenu.lang.y 	= main.stage.stageHeight - 50;

			mainMenu.info.txt.height 	= mainMenu.link.y - mainMenu.info.y - 20; 
			mainMenu.info.scroll.height = mainMenu.link.y - mainMenu.info.y - 20;

			setScrollInfo();

		}
		
		public function setScrollInfo():void
		{
			if (mainMenu.info.txt.height < mainMenu.info.txt.textHeight) 
			{
				mainMenu.info.scroll.maxScrollPosition = mainMenu.info.txt.maxScrollV;
				mainMenu.info.scroll.visible = true;
			} 
			else mainMenu.info.scroll.visible = false;
		}
		
		public function resizeDisplay(event:Event):void
		{
			world.resizeScreen();
			if (active) setMenuSize();
		}

		//Main menu loading
		public function mainLoadOn():void
		{
			trace('MainMenu.as/mainLoadOn() - Executing mainLoadOn().');
			mainMenu.dialLoad.visible 			= true;
			mainMenu.dialLoad.title2.visible 	= (loadReg == 1);
			mainMenu.dialLoad.title.visible 	= (loadReg == 0);
			mainMenu.dialLoad.slot0.visible 	= (loadReg == 0);
			mainMenu.dialLoad.info.text 		= '';
			mainMenu.dialLoad.objectName.text 	= '';
			mainMenu.dialLoad.pers.visible 		= false;

			arr = [];

			for (var i:int = 0; i <= world.saveCount; i++) 
			{
				var slot:MovieClip = mainMenu.dialLoad['slot' + i];
				var save:Object = World.world.getSave(i);
				var obj:Object = interdata.PipPageOpt.saveObj(save, i);
				arr.push(obj);
				slot.id.text 	= i;
				slot.id.visible = false;
				if (save != null && save.est != null) 
				{
					slot.objectName.text = (i == 0)?Res.txt('pip', 'autoslot'):(Res.txt('pip', 'saveslot') + ' ' + i);
					slot.ggName.text = (save.pers.persName == null) ? '-------':save.pers.persName;
					if (save.pers.level != null) slot.ggName.text += ' ('+save.pers.level+')';
					if (save.pers.dead) slot.objectName.text += ' [†]';
					else if (save.pers.hardcore) slot.objectName.text += ' {!}';
					slot.date.text = (save.date == null)  ? '-------':Res.getDate(save.date);
					slot.level.text = (save.date == null) ? '':Res.txt('map', save.game.level).substr(0, 18);
				} 
				else 
				{
					slot.objectName.text = Res.txt('pip', 'freeslot');
					slot.ggName.text 	= '';
					slot.level.text 	= '';
					slot.date.text 		= '';
				}
				slot.addEventListener(MouseEvent.CLICK, 	 funLoadSlot);
				slot.addEventListener(MouseEvent.MOUSE_OVER, funOverSlot);
			}

			mainMenu.dialLoad.butCancel.addEventListener(MouseEvent.CLICK, 	funLoadCancel);
			mainMenu.dialLoad.butFile.addEventListener(MouseEvent.CLICK, 	funLoadFile);
			animOn = false;
		}
		
		public function mainLoadOff():void
		{
			trace('MainMenu.as/mainLoadOff() - Executing mainLoadOff().');
			mainMenu.dialLoad.visible = false;
			if (mainMenu.dialLoad.butCancel.hasEventListener(MouseEvent.CLICK)) 
			{
				mainMenu.dialLoad.butCancel.removeEventListener(MouseEvent.CLICK, funLoadCancel);
				mainMenu.dialLoad.butFile.removeEventListener(MouseEvent.CLICK, funLoadFile);
			}
			for (var i:int = 0; i <= world.saveCount; i++) 
			{
				var slot:MovieClip = mainMenu.dialLoad['slot' + i];
				if (slot.hasEventListener(MouseEvent.CLICK)) 
				{
					slot.removeEventListener(MouseEvent.CLICK, funLoadSlot);
					slot.removeEventListener(MouseEvent.MOUSE_OVER, funOverSlot);
				}
			}
			animOn = true;
		}
		
		public function funLoadCancel(event:MouseEvent):void
		{
			mainLoadOff();
		}

		//select slot
		public function funLoadSlot(event:MouseEvent):void
		{
			loadCell = event.currentTarget.id.text;
			if (loadReg == 1 && loadCell == 0) return;
			if (loadReg == 0 && event.currentTarget.ggName.text == '') return;
			mainLoadOff();
			mainMenuOff();
			command = 3;
			if (loadReg == 1) com = 'new';
			else com = 'load';
		}

		public function funOverSlot(event:MouseEvent):void
		{
			interdata.PipPageOpt.showSaveInfo(arr[event.currentTarget.id.text],mainMenu.dialLoad);
		}
		
		public function funLoadFile(event:MouseEvent):void
		{
			ffil = [new FileFilter(Res.txt('pip', 'gamesaves') + " (*.sav)", "*.sav")];
			file.browse(ffil);
		}
		
		private function selectHandler(event:Event):void 
		{
            file.load();
        }		
		private function completeHandler(event:Event):void
		{
			try 
			{
				var obj:Object = file.data.readObject();
				if (obj && obj.est == 1) 
				{
					loadCell = 99;
					world.loaddata = obj;
					mainLoadOff();
					mainMenuOff();
					command = 3;
					com = 'load';
				}
			} 
			catch(err:Error) 
			{
				trace('MainMenu.as/completeHandler() - Error load');
			}
			
       }		
		
		//new game
		public function mainNewOn():void
		{
			trace('MainMenu.as/mainNewOn() - Executing mainNewOn().');
			mainMenu.dialNew.visible = true;
			mainMenu.dialNew.butCancel.addEventListener(MouseEvent.CLICK, funNewCancel);
			mainMenu.dialNew.butOk.addEventListener(MouseEvent.CLICK, funNewOk);
			mainMenu.dialNew.butVid.addEventListener(MouseEvent.CLICK, funNewVid);
			for (var i:int = 0; i <kolDifs; i++) 
			{
				mainMenu.dialNew['dif' + i].addEventListener(MouseEvent.CLICK, funNewDif);
				mainMenu.dialNew['dif' + i].addEventListener(MouseEvent.MOUSE_OVER, infoMode);
			}
			for (var j:int = 1; j <= kolOpts; j++) 
			{
				mainMenu.dialNew['infoOpt' + j].addEventListener(MouseEvent.MOUSE_OVER, infoOpt);
				mainMenu.dialNew['checkOpt' + j].addEventListener(MouseEvent.MOUSE_OVER, infoOpt);
			}
			updNewMode();
			mainMenu.dialNew.pers.gotoAndStop(2);
			mainMenu.dialNew.pers.gotoAndStop(1);
			animOn = false;
		}

		public function mainNewOff():void
		{
			trace('MainMenu.as/mainNewOff() - Executing mainNewOff().');
			mainMenu.dialNew.visible = false;
			if (mainMenu.dialNew.butCancel.hasEventListener(MouseEvent.CLICK)) mainMenu.dialNew.butCancel.removeEventListener(MouseEvent.CLICK, funNewCancel);
			if (mainMenu.dialNew.butOk.hasEventListener(MouseEvent.CLICK)) mainMenu.dialNew.butOk.removeEventListener(MouseEvent.CLICK, funNewOk);
			if (mainMenu.dialNew.butOk.hasEventListener(MouseEvent.CLICK)) 
			{
				mainMenu.dialNew.butVid.removeEventListener(MouseEvent.CLICK, funNewVid);
				for (var i:int = 0; i < kolDifs; i++) 
				{
					mainMenu.dialNew['dif' + i].removeEventListener(MouseEvent.CLICK, funNewDif);
					mainMenu.dialNew['dif' + i].removeEventListener(MouseEvent.MOUSE_OVER, infoMode);
				}
			}
			animOn = true;
		}

		public function funAdv(event:MouseEvent):void
		{
			trace('MainMenu.as/funAdv() - Executing funAdv().');

			world.nadv++;
			if (world.nadv>=world.koladv) world.nadv = 0;
			mainMenu.adv.text = Res.advText(world.nadv);
			mainMenu.adv.y = main.stage.stageHeight-mainMenu.adv.textHeight -40;
		}

		public function funAdvR(event:MouseEvent):void
		{
			trace('MainMenu.as/funAdvR() - Executing funAdvR().');

			world.nadv--;
			if (world.nadv < 0) world.nadv = world.koladv - 1;
			mainMenu.adv.text = Res.advText(world.nadv);
			mainMenu.adv.y = main.stage.stageHeight - mainMenu.adv.textHeight - 40;
		}

		public function funNewCancel(event:MouseEvent):void
		{
			mainNewOff();
		}

		public function funNewOk(event:MouseEvent):void //click OK in the new game window
		{
			trace('MainMenu.as/funNewOk() - Executing funNewOk().');

			mainNewOff();
			if (mainMenu.dialNew.checkOpt2.selected) //show slot selection window
			{	
				loadReg = 1;
				mainLoadOn();
			} 
			else 
			{
				mainMenuOff();
				loadCell = -1;
				command  = 3;
				com 	 = 'new';
			}
		}
		
		public function funNewVid(event:MouseEvent):void //enable appearance settings
		{
			trace('MainMenu.as/funNewVid() - Opening appearance menu.');

			setMenuSize();
			mainMenu.dialNew.visible = false;
			world.app.attach(mainMenu, funVidOk, funVidOk);
		}
		
		public function funVidOk():void //accept appearance settings
		{
			trace('MainMenu.as/funNewVid() - Appearance settings accepted.');

			mainMenu.dialNew.visible = true;
			world.app.detach();
			mainMenu.dialNew.pers.gotoAndStop(2);
			mainMenu.dialNew.pers.gotoAndStop(1);
		}

		public function funNewDif(event:MouseEvent):void
		{
			trace('MainMenu.as/funNewDif() - Selecting game difficulty.');

			if (event.currentTarget == mainMenu.dialNew.dif0) newGameDif = 0;
			if (event.currentTarget == mainMenu.dialNew.dif1) newGameDif = 1;
			if (event.currentTarget == mainMenu.dialNew.dif2) newGameDif = 2;
			if (event.currentTarget == mainMenu.dialNew.dif3) newGameDif = 3;
			if (event.currentTarget == mainMenu.dialNew.dif4) newGameDif = 4;
			updNewMode();
		}

		public function updNewMode():void
		{
			trace('MainMenu.as/updNewMode() - Updating game difficulty.');

			mainMenu.dialNew.dif0.fon.gotoAndStop(1);
			mainMenu.dialNew.dif1.fon.gotoAndStop(1);
			mainMenu.dialNew.dif2.fon.gotoAndStop(1);
			mainMenu.dialNew.dif3.fon.gotoAndStop(1);
			mainMenu.dialNew.dif4.fon.gotoAndStop(1);
			if (newGameDif == 0) mainMenu.dialNew.dif0.fon.gotoAndStop(2);
			if (newGameDif == 1) mainMenu.dialNew.dif1.fon.gotoAndStop(2);
			if (newGameDif == 2) mainMenu.dialNew.dif2.fon.gotoAndStop(2);
			if (newGameDif == 3) mainMenu.dialNew.dif3.fon.gotoAndStop(2);
			if (newGameDif == 4) mainMenu.dialNew.dif4.fon.gotoAndStop(2);
		}

		public function infoMode(event:MouseEvent):void
		{
			mainMenu.dialNew.modeinfo.htmlText = event.currentTarget.modeinfo.text;
		}

		public function infoOpt(event:MouseEvent):void
		{
			var n:int = int(event.currentTarget.name.substr(event.currentTarget.name.length - 1));
			mainMenu.dialNew.modeinfo.htmlText = Res.formatText(Res.txt('gui', 'opt' + n, 1));
		}
		
		public function languageButtonPress(event:MouseEvent):void //What to do when a langauge button is pressed.
		{
			trace('MainMenu.as/languageButtonPress() - Language : "' + event.currentTarget.n.text + '" pressed. Current Language: "' + Languages.languageName + '."');

			mainMenu.loading.text = '';
			var newLanguage:String = event.currentTarget.n.text;
			if (newLanguage == Languages.languageName) 
			{
				trace('MainMenu.as/languageButtonPress() - New langauge is the same as old language, returning.');
				return;
			}

			trace('MainMenu.as/languageButtonPress() - Calling Languages/changeLanguage().');
			Languages.changeLanguage(newLanguage);

			trace('MainMenu.as/languageButtonPress() - Setting langReload to true and turning off buttons.');
			langReload = true;
			showMainButtons(false);
			mainMenu.loading.text = 'Loading';
			
		}
		
		public function showMainButtons(bool:Boolean):void
		{
			mainMenu.butNewGame.visible  = bool;
			mainMenu.butLoadGame.visible = bool;
			mainMenu.butContGame.visible = bool;
			mainMenu.butOpt.visible      = bool;
			mainMenu.butAbout.visible    = bool;

			trace('MainMenu.as/showMainButtons() - Turned main buttons ' + (bool ? 'on' : 'off') + '.');
		}

		public function funAboutOk(event:MouseEvent):void
		{
			mainMenu.dialAbout.visible = false;
			mainMenu.dialAbout.butCancel.removeEventListener(MouseEvent.CLICK, funAboutOk);
		}
		
		public function step():void
		{

			//trace('MainMenu.as/step()');
			if (langReload) 
			{	
				trace('MainMenu.as/step() - mainMenu.langReload is true, reloading language.');

				langReload = false;
				showMainButtons(true);

				world.pip.updateLang();
				updateMainMenuLanguage();

			}
			
			//TODO: This is probably better as a switch-case
			if (loaded) 
			{
				if (animOn && !world.pip.active) displ.anim();

				if (world.allLevelsLoaded && Languages.textLoaded)
				{
					if (Settings.musicTracksFound > Settings.musicTracksLoaded) 
					{
						trace('MainMenu.as/step() - Waiting on music to load, updating loading display.');
						try
						{
							mainMenu.loading.text = 'Music loading ' + Settings.musicTracksLoaded + '/' + Settings.musicTracksFound;
						}
						catch (error:Error)
						{
							trace('MainMenu.as/step() - updating mainMenu loading text failed.');
						}
						
					}
				}
				else
				{
					mainMenu.loading.text = '';
				}
			}

			if (!world.constructorFinished && Languages.textLoaded)
			{
				trace('MainMenu.as/step() - Language data finished loading, continuing world construction.');
				world.constructorFinished = true;
				world.continueLoadingWorld();
			}

			if (world.constructorFinished && !mainMenuLoaded)
			{
				trace('MainMenu.as/step() - world finished loading. Starting main menu loading stage 2.');
				mainMenuLoaded = true;
				continueLoading();
			}

			if (world.grafon != null)
			{
				if (world.grafon.resourcesLoaded) 
				{
					mainMenu.loading.text = 'Loading...\n';
					//trace('MainMenu.as/step() - Resources loaded. Languages.textloaded = "' + Languages.textLoaded + '" world.init2Done: "' + world.init2Done + '" world.allLevelsLoaded: ' + world.allLevelsLoaded + '"');
					
					if (Languages.textLoaded && !world.init2Done)
					{
						trace('MainMenu.as/step() - Languages.textLoaded are true, calling world.init2().');
						world.init2Done = true
						world.init2();
						return;
					}

					if (Languages.textLoaded && world.allLevelsLoaded)
					{
						//trace('MainMenu.as/step() - Languages.textLoaded and world.allLevelsLoaded are true, Checking if language buttons are loaded.');
						if (!langButtonsLoaded)
						{
							trace('MainMenu.as/step() - No language buttons found, creating new Menu buttons array.');
							setLangButtons();
							updateMainMenuLanguage(); //I put this in here as a quick hacky fix.
						}
						if (!loaded)
						{
							showMainButtons(true);
						}
						loaded = true; // ALL loading is finished.
					}

				}
				else 
				{
					trace('MainMenu.as/step() - world.grafon.resourcesLoaded is false, waiting on resources to load...');
					mainMenu.loading.text = 'Loading ' + Math.round(world.grafon.progressLoad * 100) + '%';
				}
			}

		}
		
		public function log(s:String):void
		{
			mainMenu.loading.text += s + '; ';
		}

		public function mainStep(event:Event):void  // Runs when entering the frame.
		{
			if (active) 
			{
				step();
			}
			else if (command > 0) 
			{
				command--;
				if (command == 1 && !mainMenu.dialNew.checkOpt1.selected && com == 'new') 
				{
					world.setLoadScreen(0);
				}
				
				if (command == 0) //start the game!!!!
				{
					trace('MainMenu.as/mainStep() - Starting the game.');
					
					var opt:Object;
					if (com == 'new') 
					{	
						opt =
						{
							dif:newGameDif,
							skipTraining:mainMenu.dialNew.checkOpt1.selected,	//skipTraining - option 1 - skip training
							hardcore:mainMenu.dialNew.checkOpt2.selected,		//hardcoreMode - option 2
							fastxp:mainMenu.dialNew.checkOpt3.selected,			//fastxp - option 3, 40% less experience needed
							rndpump:mainMenu.dialNew.checkOpt4.selected, 		//randomizeLevelUpSkills - option 4, randomize what skillpoints are assigned to when leveling up.
							hardskills:mainMenu.dialNew.checkOpt5.selected, 	//hardskills - give 3 sp per level (instead of?)
							hardinv:mainMenu.dialNew.checkOpt6.selected 		//limitedInventory
						};
						if (opt.hardcore) opt.autoSaveN = loadCell; 			//autoSaveN - autosave cell
						loadCell = -1;
					}
					world.startNewGame(loadCell, mainMenu.dialNew.inputName.text, opt);
				}
			} 
			
			else 
			{
				//trace('MainMenu.as/mainStep() - mainMenu is not active and (mainMenu.command < 1). Calling world/step().');
				world.step();
			}
		}
	}
}
