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

	import locdata.LevelArray;
	import interdata.PipPageOpt;
	import interdata.PipBuck;
	import graphdata.Displ;
	
	import systems.Languages;
	import components.Settings;
	import components.XmlBook;

	import stubs.*;

	public class MainMenu
	{
		
		public var gameWindow:Sprite;
		public var mainMenuWindow; 		//The MainMenu MovieClip from the '.fla' file, everything below goes in it.
		public var currentSession:GameSession;

		public var loadCell:int 		= -1;
		public var loadReg:int 			=  0;			// loading mode, 0 - loading, 1 - slot selection for autosave
		public var command:int 			=  0; 			//What should the main menu be doing?
		public var com:String 			= '';
		public var newGameDif:int =  2;					//New Game difficulty.

		public var mainMenuAnimation:Displ;

		public var difficultyOptionCount:int	= 5;	//Number of difficulty settings, eg. 'easy', that exist.
		public var playthroughOptionCount:int	= 6;	//Number of playthrough options, eg. 'permadeath', that exist

		public var languageButtons:Array = [];

		public var style:StyleSheet 		= new StyleSheet(); 
		public var styleObj:Object 			= {};
		public var format:TextFormat 		= new TextFormat();
		public var file:FileReference 		= new FileReference();
		public var ffil:Array;

		public var savefileArray:Array		= [];

		// MAIN MENU STATE VARIABLES
		public var mainMenuSecondaryLoadingDone:Boolean = false;
		public var readyToStart:Boolean = false;	// If ALL resources (language, levels, grafon) are done loading.
		public var mainMenuActive:Boolean = true;
		public var animOn:Boolean = true;
		public var langReload:Boolean = false;
		public var langButtonsLoaded:Boolean = false;

		// LOADING PROGRESS VARIABLES
		private var levelLoadingStarted:Boolean = false;

		//Difficulty option tickboxes in the new game window.
		private var difficultyOptionTickboxes:Array; 

		public function MainMenu(window)
		{
			mainMenuWindow = new visMainMenu();
			mainMenuWindow.newGameWindow.visible = false;
			mainMenuWindow.loadGameWindow.visible = false;
			mainMenuWindow.aboutWindow.visible = false;
			mainMenuWindow.info.visible = false;
			// Set up difficulty option tickboxes from the newgame window into array for easier code later.
			difficultyOptionTickboxes = [mainMenuWindow.newGameWindow.dif0, mainMenuWindow.newGameWindow.dif1, mainMenuWindow.newGameWindow.dif2, mainMenuWindow.newGameWindow.dif3, mainMenuWindow.newGameWindow.dif4];

			Settings.initialize(); //Load all game settings.
			XmlBook.xmlBookSetup(); //Load all XML data.
			mainMenuAnimation = new Displ(mainMenuWindow.mainMenuLittlepip, mainMenuWindow.lightningEffect); //Start main menu animation.

			gameWindow = window;
			gameWindow.stage.addEventListener(Event.RESIZE, resizeDisplay);
			gameWindow.stage.addEventListener(Event.ENTER_FRAME, mainStep);

			currentSession = new GameSession(gameWindow);
			currentSession.mainMenuWindow = this;

			mainMenuSetVisibility(true);
			mainMenuButtonsListenerToggle(true); // Attach all menu button listeners.
		}

		public function continueLoadingWhenGameSessionExists():void	//currentSession holds all the menu objects, hence the wait...
		{

			trace('MainMenu.as/continueLoadingWhenGameSessionExists() - Setting menu size and applying style');
			setMenuSize(); 

			mainMenuWindow.lightningEffect.visible = false;
			format.font = "_sans";
            format.color = 0xFFFFFF;
            format.size = 28;			
			styleObj.fontWeight = "bold"; 
			styleObj.color		= "#FFFF00"; 
			style.setStyle(".yel", styleObj);	//highlighting important
			styleObj.fontWeight = "normal"; 
			styleObj.color 		= "#00FF99";
			styleObj.fontSize	= "12";
			style.setStyle(".music", styleObj);	//Small font
			styleObj.fontWeight = "normal"; 
			styleObj.color 		= "#66FF66";
			styleObj.fontSize 	= undefined;
			style.setStyle("a", styleObj); 	// HTML link(?)
			styleObj.textDecoration = "underline";
			style.setStyle("a:hover", styleObj);
			mainMenuWindow.info.txt.styleSheet 	= style;
			mainMenuWindow.link.l1.styleSheet 	= style;
			mainMenuWindow.link.l2.styleSheet 	= style;
		}

		public function mainMenuSetVisibility(isVisible:Boolean):void
		{
			mainMenuActive = isVisible;
			switch(isVisible)
			{
				case true:
					if (!gameWindow.contains(mainMenuWindow)) gameWindow.addChild(mainMenuWindow);
					file.addEventListener(Event.SELECT, selectHandler);
					file.addEventListener(Event.COMPLETE, completeHandler);
					break;

				case false:
					for each(var m:* in languageButtons) 
					{
						if (m) m.removeEventListener(MouseEvent.CLICK, languageButtonPress);
					}
					if (gameWindow.contains(mainMenuWindow)) gameWindow.removeChild(mainMenuWindow);
					currentSession.loadingScreen.visible = true;
					currentSession.loadingScreen.progres.text = Res.txt('gui', 'loading');
					break;
			}
			trace('MainMenu.as/mainMenuSetVisibility() - mainMenu is now ' + (isVisible ? 'visible': 'hidden') + '.');
		}

		public function createMainMenuLanguageButtons():void
		{
			trace('MainMenu.as/createMainMenuLanguageButtons() - Creating language buttons.');
			for each(var language:XML in Languages.languageListDictionary)
			{
				if(language.lang.@id != "" && language.lang.text() != "")
				{
					Languages.languageCount++;
					var button = new LanguageSelectButton(); // .swf Linkage

					var languageId:String = language.lang.@id;
					var languageName:String = language.lang.text();

					button.txt.text = languageName; // Set the button properties
					button.y = -Languages.languageCount * 40;
					button.n.text = languageId;
					button.n.visible = false;
					button.addEventListener(MouseEvent.CLICK, languageButtonPress);

					if (mainMenuWindow.languageContainer == null)
					{
						trace('MainMenu.as/createMainMenuLanguageButtons() - languageContainer null!."');
					}
					mainMenuWindow.languageContainer.addChild(button)
				}
				else // Check languageListDictionary length and output error if there's a blank entry.
				{
					var dictionaryLength:int = 0;
					for (var key:* in Languages.languageListDictionary)
					{
						dictionaryLength++;
					}
					trace('MainMenu.as/createMainMenuLanguageButtons() - Skipping blank language in languageListDictionary. languageListDictionary length: "' + dictionaryLength + '".');
				}
				langButtonsLoaded = true;
			}
			trace('MainMenu.as/createMainMenuLanguageButtons() - Created: "' + Languages.languageCount + '" language buttons.');

			if (Languages.languageCount > -1 ) //-1 is the starting value.
			{
				mainMenuWindow.langButtonsLoaded = true;
			}
		}

		public function updateMainMenuLanguage():void
		{
			trace('MainMenu.as/updateMainMenuLanguage() - Updating mainMenu language.');
			updateMenuButtonLocalization();
			localizeMainMenuWindows()

			for (var i:int = 0; i < difficultyOptionCount; i++) //New Game difficulty options
			{
				mainMenuWindow.newGameWindow['dif' + i].mode.text 		= Res.txt('gui', 'dif' + i);
				mainMenuWindow.newGameWindow['dif' + i].modeinfo.text 	= Res.formatText(Res.txt('gui', 'dif' + i, 1));
			}
			
			for (var j:int = 1; j <= playthroughOptionCount; j++) //New Game playthrough options
			{
				mainMenuWindow.newGameWindow['infoOpt' + j].text = Res.txt('gui', 'opt' + j);
			}
			
			mainMenuWindow.newGameWindow.editAppearanceButton.mode.text = Res.txt('gui', 'editAppearanceButton');

			currentSession.appearanceWindow.setLang();

			mainMenuWindow.adviceSnippetBox.text = Res.advText(currentSession.nadv);
			mainMenuWindow.adviceSnippetBox.y = gameWindow.stage.stageHeight - mainMenuWindow.adviceSnippetBox.textHeight - 40;
			mainMenuWindow.info.txt.htmlText = Res.txt('gui', 'inform') + '<br>' + Res.txt('gui', 'inform', 1);
			mainMenuWindow.info.visible = (mainMenuWindow.info.txt.text.length > 0);

			setScrollInfo();
			trace('MainMenu.as/updateMainMenuLanguage() - Finished updating mainMenu language.');
		}
		
		public function setMenuSize():void
		{
			mainMenuWindow.adviceSnippetBox.y = gameWindow.stage.stageHeight - mainMenuWindow.adviceSnippetBox.textHeight - 40;
			mainMenuWindow.version.y = gameWindow.stage.stageHeight - 58;
			mainMenuWindow.link.y = gameWindow.stage.stageHeight - 125;
			var ny:int = gameWindow.stage.stageHeight - 400;
			if (ny < 280) ny = 280;
			mainMenuWindow.loadGameWindow.x = gameWindow.stage.stageWidth / 2;
			mainMenuWindow.newGameWindow.x 	= gameWindow.stage.stageWidth / 2;
			
			currentSession.appearanceWindow.window.x 	= gameWindow.stage.stageWidth / 2;
			mainMenuWindow.loadGameWindow.y = ny;
			mainMenuWindow.newGameWindow.y 	= ny;
			currentSession.appearanceWindow.window.y 	= ny;

			mainMenuWindow.languageContainer.x 	= gameWindow.stage.stageWidth  - 30;
			mainMenuWindow.languageContainer.y 	= gameWindow.stage.stageHeight - 50;

			mainMenuWindow.info.txt.height 	= mainMenuWindow.link.y - mainMenuWindow.info.y - 20; 
			mainMenuWindow.info.scroll.height = mainMenuWindow.link.y - mainMenuWindow.info.y - 20;

			setScrollInfo();
		}
		
		public function setScrollInfo():void
		{
			if (mainMenuWindow.info.txt.height < mainMenuWindow.info.txt.textHeight) 
			{
				mainMenuWindow.info.scroll.maxScrollPosition = mainMenuWindow.info.txt.maxScrollV;
				mainMenuWindow.info.scroll.visible = true;
			} 
			else mainMenuWindow.info.scroll.visible = false;
		}
		
		public function resizeDisplay(event:Event):void
		{
			currentSession.resizeScreen();
			if (mainMenuActive) setMenuSize();
		}

		
		public function openLoadGameWindow():void //Main menu loading
		{
			trace('MainMenu.as/openLoadGameWindow() - Executing openLoadGameWindow().');
			mainMenuWindow.loadGameWindow.visible 			= true;
			mainMenuWindow.loadGameWindow.title2.visible 	= (loadReg == 1);
			mainMenuWindow.loadGameWindow.title.visible 	= (loadReg == 0);
			mainMenuWindow.loadGameWindow.slot0.visible 	= (loadReg == 0);
			mainMenuWindow.loadGameWindow.info.text 		= '';
			mainMenuWindow.loadGameWindow.nazv.text 	= '';
			mainMenuWindow.loadGameWindow.pers.visible 		= false;

			savefileArray = [];

			for (var i:int = 0; i <= currentSession.saveCount; i++) 
			{
				var slot:MovieClip = mainMenuWindow.loadGameWindow['slot' + i];
				var save:Object = GameSession.currentSession.getSave(i);
				var obj:Object = interdata.PipPageOpt.saveObj(save, i);
				savefileArray.push(obj);
				slot.id.text 	= i;
				slot.id.visible = false;
				if (save != null && save.est != null) 
				{
					slot.nazv.text = (i == 0)?Res.txt('pip', 'autoslot'):(Res.txt('pip', 'saveslot') + ' ' + i);
					slot.ggName.text = (save.pers.persName == null) ? '-------':save.pers.persName;
					if (save.pers.level != null) slot.ggName.text += ' ('+save.pers.level+')';
					if (save.pers.dead) slot.nazv.text += ' [†]';
					else if (save.pers.hardcore) slot.nazv.text += ' {!}';
					slot.date.text = (save.date == null)  ? '-------':Res.getDate(save.date);
					slot.level.text = (save.date == null) ? '':Res.txt('map', save.game.level).substr(0, 18);
				} 
				else 
				{
					slot.nazv.text = Res.txt('pip', 'freeslot');
					slot.ggName.text 	= '';
					slot.level.text 	= '';
					slot.date.text 		= '';
				}
				slot.addEventListener(MouseEvent.CLICK, 	 funLoadSlot);
				slot.addEventListener(MouseEvent.MOUSE_OVER, funOverSlot);
			}

			mainMenuWindow.loadGameWindow.butCancel.addEventListener(MouseEvent.CLICK, 	clickedButtonCloseLoadGameWindow);
			mainMenuWindow.loadGameWindow.butFile.addEventListener(MouseEvent.CLICK, 	clickedButtonLoadGame);
			animOn = false;
		}
		
		public function closeLoadGameWindow():void
		{
			trace('MainMenu.as/closeLoadGameWindow() - Executing closeLoadGameWindow().');
			mainMenuWindow.loadGameWindow.visible = false;
			if (mainMenuWindow.loadGameWindow.butCancel.hasEventListener(MouseEvent.CLICK)) 
			{
				mainMenuWindow.loadGameWindow.butCancel.removeEventListener(MouseEvent.CLICK, clickedButtonCloseLoadGameWindow);
				mainMenuWindow.loadGameWindow.butFile.removeEventListener(MouseEvent.CLICK, clickedButtonLoadGame);
			}
			for (var i:int = 0; i <= currentSession.saveCount; i++) 
			{
				var slot:MovieClip = mainMenuWindow.loadGameWindow['slot' + i];
				if (slot.hasEventListener(MouseEvent.CLICK)) 
				{
					slot.removeEventListener(MouseEvent.CLICK, funLoadSlot);
					slot.removeEventListener(MouseEvent.MOUSE_OVER, funOverSlot);
				}
			}
			animOn = true;
		}

		public function funLoadSlot(event:MouseEvent):void //select slot
		{
			loadCell = event.currentTarget.id.text;
			if (loadReg == 1 && loadCell == 0) return;
			if (loadReg == 0 && event.currentTarget.ggName.text == '') return;
			closeLoadGameWindow();
			mainMenuSetVisibility(false);
			mainMenuButtonsListenerToggle(false);
			command = 3;
			if (loadReg == 1) com = 'new';
			else com = 'load';
		}

		public function funOverSlot(event:MouseEvent):void
		{
			interdata.PipPageOpt.showSaveInfo(savefileArray[event.currentTarget.id.text], mainMenuWindow.loadGameWindow);
		}
		
		public function openNewGameWindow():void //New Game Window
		{
			trace('MainMenu.as/openNewGameWindow() - Executing openNewGameWindow().');
			mainMenuWindow.newGameWindow.visible = true;
			mainMenuWindow.newGameWindow.butCancel.addEventListener(MouseEvent.CLICK, clickedButtonCloseNewGameWindow);
			mainMenuWindow.newGameWindow.butOk.addEventListener(MouseEvent.CLICK, clickedButtonStartNewGame);
			mainMenuWindow.newGameWindow.editAppearanceButton.addEventListener(MouseEvent.CLICK, openAppearanceEditorWindow);

			for (var i:int = 0; i <difficultyOptionCount; i++) 
			{
				mainMenuWindow.newGameWindow['dif' + i].addEventListener(MouseEvent.CLICK, funNewDif);
				mainMenuWindow.newGameWindow['dif' + i].addEventListener(MouseEvent.MOUSE_OVER, infoMode);
			}

			for (var j:int = 1; j <= playthroughOptionCount; j++) 
			{
				mainMenuWindow.newGameWindow['infoOpt' + j].addEventListener(MouseEvent.MOUSE_OVER, infoOpt);
				mainMenuWindow.newGameWindow['checkOpt' + j].addEventListener(MouseEvent.MOUSE_OVER, infoOpt);
			}

			initializeDifficultyOptionList();
			mainMenuWindow.newGameWindow.pers.gotoAndStop(2);
			mainMenuWindow.newGameWindow.pers.gotoAndStop(1);
			animOn = false;
		}

		public function closeNewGameWindow():void
		{
			trace('MainMenu.as/closeNewGameWindow() - Executing closeNewGameWindow().');
			mainMenuWindow.newGameWindow.visible = false;
			if (mainMenuWindow.newGameWindow.butCancel.hasEventListener(MouseEvent.CLICK)) mainMenuWindow.newGameWindow.butCancel.removeEventListener(MouseEvent.CLICK, clickedButtonCloseNewGameWindow);
			if (mainMenuWindow.newGameWindow.butOk.hasEventListener(MouseEvent.CLICK)) mainMenuWindow.newGameWindow.butOk.removeEventListener(MouseEvent.CLICK, clickedButtonStartNewGame);
			if (mainMenuWindow.newGameWindow.butOk.hasEventListener(MouseEvent.CLICK)) 
			{
				mainMenuWindow.newGameWindow.editAppearanceButton.removeEventListener(MouseEvent.CLICK, openAppearanceEditorWindow);
				for (var i:int = 0; i < difficultyOptionCount; i++) 
				{
					mainMenuWindow.newGameWindow['dif' + i].removeEventListener(MouseEvent.CLICK, funNewDif);
					mainMenuWindow.newGameWindow['dif' + i].removeEventListener(MouseEvent.MOUSE_OVER, infoMode);
				}
			}
			animOn = true;
		}

		public function openAppearanceEditorWindow(event:MouseEvent):void
		{
			trace('MainMenu.as/openAppearanceEditorWindow() - Opening appearance menu.');

			setMenuSize();
			mainMenuWindow.newGameWindow.visible = false;
			currentSession.appearanceWindow.attach(mainMenuWindow, closeAppearanceEditorWindow, closeAppearanceEditorWindow); //Why is this calling closeAppearanceEditorWindow twice?
		}
		
		public function closeAppearanceEditorWindow():void
		{
			trace('MainMenu.as/openAppearanceEditorWindow() - Appearance settings accepted.');

			mainMenuWindow.newGameWindow.visible = true;
			currentSession.appearanceWindow.detach();
			mainMenuWindow.newGameWindow.pers.gotoAndStop(2);
			mainMenuWindow.newGameWindow.pers.gotoAndStop(1);
		}

		public function funNewDif(event:MouseEvent):void
		{
			trace('MainMenu.as/funNewDif() - Selecting game difficulty.');

			for (var i:int = 0; i < 5; i++)
			{
				if (event.currentTarget == difficultyOptionTickboxes[i]) 
				{
					newGameDif = i;
					break;
				}

			}
			initializeDifficultyOptionList();
		}

		public function initializeDifficultyOptionList():void
		{
			for (var i:int = 0; i < 5; i++) // Set all difficulty checkboxes to empty.
			{
				difficultyOptionTickboxes[i].fon.gotoAndStop(1);

			}
			for (var j:int = 0; j < 5; j++) // If the new game difficulty matches the checkbox, change to a ticked checkbox.
			{
				if (newGameDif == j)
				{
					difficultyOptionTickboxes[j].fon.gotoAndStop(2);
					break;
				}
			}
		}

		public function infoMode(event:MouseEvent):void //???
		{
			mainMenuWindow.newGameWindow.modeinfo.htmlText = event.currentTarget.modeinfo.text;
		}

		public function infoOpt(event:MouseEvent):void //???
		{
			var n:int = int(event.currentTarget.name.substr(event.currentTarget.name.length - 1));
			mainMenuWindow.newGameWindow.modeinfo.htmlText = Res.formatText(Res.txt('gui', 'opt' + n, 1));
		}
		
		public function step():void
		{
			if (langReload) setMainMenuLanguage();
			if (XmlBook.bookSetup && !Snd.soundInitialized) Snd.initializeSound();

			if (readyToStart && currentSession.pip != null) // This is loading too fast and crashing, adding a check for pipbuck.
			{
				//trace('MainMenu.as/step() - Starting menu animation.');
				if (animOn && !currentSession.pip.active) mainMenuAnimation.anim();

				if (Languages.textLoaded)
				{
					if (Settings.musicTracksFound < Settings.musicTracksLoaded) 
					{
						mainMenuWindow.mainMenuLoadingLog.text = 'Music files readyToStart!';
					}
					else
					{
						mainMenuWindow.mainMenuLoadingLog.text = 'Music files: ' + Settings.musicTracksLoaded + '/' + Settings.musicTracksFound + ' loaded.';
					}
				}
				else mainMenuWindow.mainMenuLoadingLog.text = '';
			}

			if (!currentSession.constructorFinished && Languages.textLoaded)
			{
				trace('MainMenu.as/step() - Language data finished loading, continuing currentSession construction.');
				currentSession.constructorFinished = true;
				currentSession.continueLoadingWorld();
			}

			if (currentSession.constructorFinished && !mainMenuSecondaryLoadingDone)
			{
				trace('MainMenu.as/step() - currentSession finished loading. Starting main menu loading stage 2.');
				mainMenuSecondaryLoadingDone = true;
				continueLoadingWhenGameSessionExists();
			}

			if (currentSession.grafon != null)
			{
				if (currentSession.grafon.resourcesLoaded) 
				{
					mainMenuWindow.mainMenuLoadingLog.text = 'Loading...';
					
					
					if (Languages.textLoaded && !currentSession.init2Done)
					{
						trace('MainMenu.as/step() - Languages.textLoaded are true, calling currentSession.init2().');
						currentSession.init2Done = true
						currentSession.init2();
						return;
					}

					if (Languages.textLoaded)
					{
						if (!langButtonsLoaded)
						{
							trace('MainMenu.as/step() - No language buttons found, creating new Menu buttons array.');
							createMainMenuLanguageButtons();
						}
						if (!readyToStart)
						{
							updateMainMenuLanguage();
							showMainButtons(true);
						}
						readyToStart = true; // ALL loading is finished.
						mainMenuWindow.mainMenuLoadingLog.text = '';
					}

				}
				else 
				{
					//trace('MainMenu.as/step() - currentSession.grafon.resourcesLoaded is false, waiting on resources to load...');
					mainMenuWindow.mainMenuLoadingLog.text = 'Loading ' + Math.round(currentSession.grafon.progressLoad * 100) + '%';
				}
			}
		}
		
		private function setMainMenuLanguage():void
		{
			langReload = false;
			showMainButtons(false);
			currentSession.pip.updateLang();
			updateMainMenuLanguage();
		}

		public function log(s:String):void
		{
			mainMenuWindow.mainMenuLoadingLog.text += s + '; ';
		}

		public function mainStep(event:Event):void  // Runs when entering the frame.
		{
			if (mainMenuActive)
			{
				step();
			}
			else if (command > 0) 
			{
				command--;
				if (command == 1 && !mainMenuWindow.newGameWindow.checkOpt1.selected && com == 'new') 
				{
					currentSession.setLoadScreen(0);
				}
				
				if (command == 0) //start the game!!!!
				{
					trace('MainMenu.as/mainStep() - Starting the game.');
					
					if (!levelLoadingStarted)
					{
						trace('MainMenu.as/mainStep() - Loading all levels.');
						levelLoadingStarted = true;
						LevelArray.loadAllGameLevels(); // LEVELS ARE INITIALIZED HERE.
					}

					var opt:Object;
					if (com == 'new') 
					{	
						opt =
						{
							dif:newGameDif,
							skipTraining:mainMenuWindow.newGameWindow.checkOpt1.selected,	//skipTraining - option 1 - skip training
							hardcore:mainMenuWindow.newGameWindow.checkOpt2.selected,		//hardcoreMode - option 2
							fastxp:mainMenuWindow.newGameWindow.checkOpt3.selected,			//fastxp - option 3, 40% less experience needed
							rndpump:mainMenuWindow.newGameWindow.checkOpt4.selected, 		//randomizeLevelUpSkills - option 4, randomize what skillpoints are assigned to when leveling up.
							hardskills:mainMenuWindow.newGameWindow.checkOpt5.selected, 	//hardskills - give 3 sp per level (instead of?)
							hardinv:mainMenuWindow.newGameWindow.checkOpt6.selected 		//limitedInventory
						};
						if (opt.hardcore) opt.autoSaveN = loadCell; 						//autoSaveN - autosave cell
						loadCell = -1;
					}
					currentSession.startNewGame(loadCell, mainMenuWindow.newGameWindow.inputName.text, opt);
				}
			} 
			else currentSession.step();
		}

//########################################
//##
//##	WINDOWS AND BUTTONS
//##
//########################################


		private function localizeMainMenuWindows():void
		{
			mainMenuWindow.version.htmlText = '<b>' + Res.txt('gui', 'version') + ' ' + Settings.version + '</b>';
			//Load Game Window
			mainMenuWindow.loadGameWindow.title.text = Res.txt('gui', 'loadgame');
			mainMenuWindow.loadGameWindow.title2.text = Res.txt('gui', 'select_slot');
			mainMenuWindow.loadGameWindow.butCancel.text.text = Res.txt('gui', 'cancel');
			mainMenuWindow.loadGameWindow.butFile.text.text = Res.txt('pip', 'loadfile');
			mainMenuWindow.loadGameWindow.warn.text = Res.txt('gui', 'loadwarn');
			//New Game Window
			mainMenuWindow.newGameWindow.title.text = Res.txt('gui', 'newgame');
			mainMenuWindow.newGameWindow.warn.text = Res.txt('gui', 'loadwarn');
			mainMenuWindow.newGameWindow.infoName.text = Res.txt('gui', 'inputname');
			mainMenuWindow.newGameWindow.hardOpt.text = Res.txt('gui', 'hardopt');
			mainMenuWindow.newGameWindow.butOk.text.text = 'OK';
			mainMenuWindow.newGameWindow.inputName.text = Res.txt('unit','littlepip');
			mainMenuWindow.newGameWindow.butCancel.text.text = Res.txt('gui', 'cancel');
			mainMenuWindow.newGameWindow.maxChars = 32;
		}

		private function mainMenuButtonPress(event:MouseEvent):void
		{
			trace('MainMenu.as/mainMenuButtonPress() - "' + event.currentTarget.name + '" pressed.');
			switch(event.currentTarget.name)
			{
        		case "continueGameButton":
					trace('MainMenu.as/mainMenuButtonPress() - Opening Continue Game window.');
					var n:int = 0;
					var maxDate:Number = 0;
					for (var i:int = 0; i <= currentSession.saveCount; i++) 
					{
						var save:Object = currentSession.getSave(i);
						if (save && save.est && save.date > maxDate) 
						{
							n = i;
							maxDate = save.date;
						}
					}

					save = currentSession.getSave(n);

					if (save && save.est) 
					{
						mainMenuSetVisibility(false);
						loadCell = n;
						command  = 3;
					} 
					else 
					{
						openNewGameWindow();
						closeLoadGameWindow();
					}
           			break;

        		case "loadGameButton":
					trace('MainMenu.as/mainMenuButtonPress() - Opening Load Game window.');
					currentSession.mmArmor = true;
					closeNewGameWindow();
					loadReg = 0;
					openLoadGameWindow();
					break;
				case "newGameButton":
					trace('MainMenu.as/mainMenuButtonPress() - Opening New Game window.');
					currentSession.mmArmor = false;
					closeLoadGameWindow();
					openNewGameWindow();
					break;
				case "optionsButton":
					trace('MainMenu.as/mainMenuButtonPress() - Opening Options window.');
					closeNewGameWindow();
					closeLoadGameWindow();
					currentSession.pip.onoff();
					break;
				case "aboutButton":
					trace('MainMenu.as/mainMenuButtonPress() - Executing funAbout().');
					mainMenuWindow.aboutWindow.title.text = Res.txt('gui', 'about');
					var s:String = Res.formatText(Res.txt('gui','about', 1));
					s += '<br><br>' + Res.txt('gui', 'usedmusic') + '<br>';
					//TODO: Don't access languages' stuff directly like this.
					s += "<br><span class='music'>" + Res.formatText(Languages.currentLanguageData.gui.(@id == 'usedmusic').info[0]) + "</span>"
					s += "<br><br><a href='https://creativecommons.org/licenses/by-nc/4.0/legalcode'>Music CC-BY License</a>";
					mainMenuWindow.aboutWindow.txt.styleSheet 	= style;
					mainMenuWindow.aboutWindow.txt.htmlText 	= s;
					mainMenuWindow.aboutWindow.visible = true;
					mainMenuWindow.aboutWindow.butCancel.addEventListener(MouseEvent.CLICK, clickedButtonCloseAboutWindow);
					mainMenuWindow.aboutWindow.scroll.maxScrollPosition = mainMenuWindow.aboutWindow.txt.maxScrollV;
					break;
				default:
           			trace("MainMenu.as/mainMenuButtonPress() - Unknown button pressed");
            		break;
			}

		}

		public function showMainButtons(bool:Boolean):void
		{
			mainMenuWindow.newGameButton.visible = bool;
			mainMenuWindow.loadGameButton.visible = bool;
			mainMenuWindow.continueGameButton.visible = bool;
			mainMenuWindow.optionsButton.visible = bool;
			mainMenuWindow.aboutButton.visible = bool;
		}

		public function clickedButtonCloseAboutWindow(event:MouseEvent):void
		{
			mainMenuWindow.aboutWindow.visible = false;
			mainMenuWindow.aboutWindow.butCancel.removeEventListener(MouseEvent.CLICK, clickedButtonCloseAboutWindow);
		}

		public function mouseOverHighlight(event:MouseEvent):void //Mouseover
		{
			(event.currentTarget as MovieClip).fon.scaleX = 1;
			(event.currentTarget as MovieClip).fon.alpha  = 1.5;
		}

		public function mouseOverHighlightStop(event:MouseEvent):void //Mouseover stopped
		{
			(event.currentTarget as MovieClip).fon.scaleX = 0.7;
			(event.currentTarget as MovieClip).fon.alpha  = 1;
		}

		public function mainMenuButtonsListenerToggle(enabled:Boolean):void
		{
			var mainFivebuttons:Array = [mainMenuWindow.continueGameButton, mainMenuWindow.loadGameButton, mainMenuWindow.newGameButton, mainMenuWindow.optionsButton, mainMenuWindow.aboutButton];
			var toggle:Function;
			
			for each (var mainFiveButton:Object in mainFivebuttons) 
			{
				toggle = enabled ? mainFiveButton.addEventListener : mainFiveButton.removeEventListener;
				toggle(MouseEvent.MOUSE_OVER, mouseOverHighlight);
				toggle(MouseEvent.MOUSE_OUT, mouseOverHighlightStop);
				toggle(MouseEvent.CLICK, mainMenuButtonPress);
    		}

			toggle = enabled ? mainMenuWindow.adviceSnippetBox.addEventListener : mainMenuWindow.adviceSnippetBox.removeEventListener;
			toggle(MouseEvent.CLICK, showNextAdviceSnippet);
			toggle(MouseEvent.RIGHT_CLICK, showPreviousAdviceSnippet);

			toggle = enabled ? file.addEventListener : file.removeEventListener;
			toggle(Event.SELECT, selectHandler);
			toggle(Event.COMPLETE, completeHandler);
		}

		public function selectHandler(event:Event):void 
		{
            file.load();
        }

		public function completeHandler(event:Event):void
		{
			try 
			{
				var obj:Object = file.data.readObject();
				if (obj && obj.est == 1) 
				{
					loadCell = 99;
					currentSession.loaddata = obj;
					closeLoadGameWindow();
					mainMenuSetVisibility(false);
					command = 3;
					com = 'load';
				}
			} 
			catch(err:Error) 
			{
				trace('MainMenu.as/completeHandler() - Error load');
			}
       	}

		public function languageButtonPress(event:MouseEvent):void //What to do when a langauge button is pressed.
		{
			trace('MainMenu.as/languageButtonPress() - Language : "' + event.currentTarget.n.text + '" pressed. Current Language: "' + Languages.languageName + '."');

			mainMenuWindow.mainMenuLoadingLog.text = '';
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
			mainMenuWindow.mainMenuLoadingLog.text = 'Loading';
			
		}

		//Load Game Window
		public function clickedButtonLoadGame(event:MouseEvent):void
		{
			ffil = [new FileFilter(Res.txt('pip', 'gamesaves') + " (*.sav)", "*.sav")];
			file.browse(ffil);
		}
		public function clickedButtonCloseLoadGameWindow(event:MouseEvent):void
		{
			closeLoadGameWindow();
		}

		//New Game Window
		public function clickedButtonCloseNewGameWindow(event:MouseEvent):void
		{
			closeNewGameWindow();
		}
		public function clickedButtonStartNewGame(event:MouseEvent):void //click OK in the new game window
		{
			trace('MainMenu.as/clickedButtonStartNewGame() - Executing clickedButtonStartNewGame().');

			closeNewGameWindow();
			if (mainMenuWindow.newGameWindow.checkOpt2.selected) //show slot selection window
			{	
				loadReg = 1;
				openLoadGameWindow();
			} 
			else 
			{
				mainMenuSetVisibility(false);
				loadCell = -1;
				command  =  3;
				com 	 = 'new';
			}
		}

		// Main Menu hints
		public function showNextAdviceSnippet(event:MouseEvent):void
		{
			currentSession.nadv++;
			if (currentSession.nadv >= currentSession.koladv) currentSession.nadv = 0;
			mainMenuWindow.adviceSnippetBox.text = Res.advText(currentSession.nadv);
			mainMenuWindow.adviceSnippetBox.y = gameWindow.stage.stageHeight - mainMenuWindow.adviceSnippetBox.textHeight - 40;
		}
		public function showPreviousAdviceSnippet(event:MouseEvent):void
		{
			currentSession.nadv--;
			if (currentSession.nadv < 0) currentSession.nadv = currentSession.koladv - 1;
			mainMenuWindow.adviceSnippetBox.text = Res.advText(currentSession.nadv);
			mainMenuWindow.adviceSnippetBox.y = gameWindow.stage.stageHeight - mainMenuWindow.adviceSnippetBox.textHeight - 40;
		}
		public function updateMenuButtonLocalization():void
		{
			updateButtonText(mainMenuWindow.continueGameButton, Res.txt('gui', 'contgame'));
			updateButtonText(mainMenuWindow.newGameButton, Res.txt('gui', 'newgame'));
			updateButtonText(mainMenuWindow.loadGameButton, Res.txt('gui', 'loadgame'));
			updateButtonText(mainMenuWindow.optionsButton, Res.txt('gui', 'options'));
			updateButtonText(mainMenuWindow.aboutButton, Res.txt('gui', 'about'));

			showMainButtons(true);
		}

		//Button localization
		public function updateButtonText(menuButton:MovieClip, localizedText:String):void
		{
			menuButton.txt.text = localizedText;
			menuButton.glow.text = localizedText;
			menuButton.txt.visible = (menuButton.glow.textWidth < 1)
		}
	}
}