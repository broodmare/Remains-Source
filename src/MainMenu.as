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

	public class MainMenu 
	{

		public var version:String='1.0.4 (woons)';
		public var mainMenu:MovieClip; 			// Create a container for the main menu sprite
		public var main:Sprite;
		public var world:World;
		public var active:Boolean 		= true;
		public var loaded:Boolean 		= false;
		public var newGameMode:int 		= 2;
		public var newGameDif:int 		= 2;
		public var loadCell:int 		= -1;
		public var loadReg:int 			= 0;	// loading mode, 0 - loading, 1 - slot selection for autosave
		public var command:int 			= 0; 	//What should the main menu be doing?
		public var com:String 			= '';
		public var mmp:MovieClip; 				// Create MovieClip object for PipBuck
		public var pip:PipBuck;
		public var displ:Displ;
		public var animOn:Boolean		= true;
		public var langReload:Boolean	= false;


		public var kolDifs:int = 5;
		public var kolOpts:int = 6;
		
		public var languageButtons:Array;
		public var stn:int = 0;
		public var style:StyleSheet 	= new StyleSheet(); 
		public var styleObj:Object 		= new Object(); 
		public var format:TextFormat 	= new TextFormat();
		public var file:FileReference 	= new FileReference();
		public var ffil:Array;
		public var arr:Array			= new Array();
		public var mainTimer:Timer;
		public var settings:Settings;	

		public function MainMenu(nmain:MovieClip) 
		{
			
			Settings.settingsSetup();
			
			main = nmain;

			mainMenu = new visMainMenu();   //Linkage defined in pfe.fla
			mainMenu.dialLoad.visible = false;
			mainMenu.dialNew.visible = false;
			mainMenu.dialAbout.visible = false;
			main.stage.addEventListener(Event.RESIZE, resizeDisplay); 
			main.stage.addEventListener(Event.ENTER_FRAME, mainStep);
			
			showButtons(false);
			mainMenuOn();
			
			var paramObj:Object = LoaderInfo(main.root.loaderInfo).parameters;

			trace('MainMenu.as/MainMenu() - Creating new world...');
			world = new World(main);
			world.mainMenu = this;
			
			mainMenu.info.visible = false;
			

			trace('MainMenu.as/MainMenu() - Calling Languages/languages...');
			Languages.languageStart();

			trace('MainMenu.as/MainMenu() - Calling Sound/initSound...');
			Snd.initSnd();


			
			setMenuSize();
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

		}

		public function mainMenuOn()
		{
			active = true;

			mainMenu.butNewGame.addEventListener	(MouseEvent.MOUSE_OVER, funOver);
			mainMenu.butNewGame.addEventListener	(MouseEvent.MOUSE_OUT,  funOut);
			mainMenu.butLoadGame.addEventListener	(MouseEvent.MOUSE_OVER, funOver);
			mainMenu.butLoadGame.addEventListener	(MouseEvent.MOUSE_OUT,  funOut);
			mainMenu.butContGame.addEventListener	(MouseEvent.MOUSE_OVER, funOver);
			mainMenu.butContGame.addEventListener	(MouseEvent.MOUSE_OUT,  funOut);
			mainMenu.butOpt.addEventListener		(MouseEvent.MOUSE_OVER, funOver);
			mainMenu.butOpt.addEventListener		(MouseEvent.MOUSE_OUT,  funOut);
			mainMenu.butAbout.addEventListener		(MouseEvent.MOUSE_OVER, funOver);
			mainMenu.butAbout.addEventListener		(MouseEvent.MOUSE_OUT,  funOut);
			mainMenu.butOpt.addEventListener		(MouseEvent.CLICK, 		funOpt);
			mainMenu.butNewGame.addEventListener	(MouseEvent.CLICK, 		funNewGame);
			mainMenu.butLoadGame.addEventListener	(MouseEvent.CLICK, 		funLoadGame);
			mainMenu.butContGame.addEventListener	(MouseEvent.CLICK, 		funContGame);
			mainMenu.butAbout.addEventListener		(MouseEvent.CLICK, 		funAbout);
			mainMenu.adv.addEventListener			(MouseEvent.CLICK, 		funAdv);
			mainMenu.adv.addEventListener			(MouseEvent.RIGHT_CLICK, funAdvR);

			if (!main.contains(mainMenu)) 			main.addChild(mainMenu);
			file.addEventListener					(Event.SELECT, selectHandler);
			file.addEventListener					(Event.COMPLETE, completeHandler);
		}
		
		public function mainMenuOff()
		{
			active = false;

			mainMenu.butNewGame.removeEventListener(MouseEvent.MOUSE_OVER, funOver);
			mainMenu.butNewGame.removeEventListener(MouseEvent.MOUSE_OUT, funOut);
			mainMenu.butLoadGame.removeEventListener(MouseEvent.MOUSE_OVER, funOver);
			mainMenu.butLoadGame.removeEventListener(MouseEvent.MOUSE_OUT, funOut);
			mainMenu.butContGame.removeEventListener(MouseEvent.MOUSE_OVER, funOver);
			mainMenu.butContGame.removeEventListener(MouseEvent.MOUSE_OUT, funOut);
			mainMenu.butOpt.removeEventListener(MouseEvent.MOUSE_OVER, funOver);
			mainMenu.butOpt.removeEventListener(MouseEvent.MOUSE_OUT, funOut);
			mainMenu.butAbout.removeEventListener(MouseEvent.MOUSE_OVER, funOver);
			mainMenu.butAbout.removeEventListener(MouseEvent.MOUSE_OUT, funOut);
			mainMenu.butOpt.removeEventListener(MouseEvent.CLICK, funOpt);
			mainMenu.butNewGame.removeEventListener(MouseEvent.CLICK, funNewGame);
			mainMenu.butLoadGame.removeEventListener(MouseEvent.CLICK, funLoadGame);
			mainMenu.butContGame.removeEventListener(MouseEvent.CLICK, funContGame);
			mainMenu.butAbout.removeEventListener(MouseEvent.CLICK, funAbout);
			mainMenu.adv.removeEventListener(MouseEvent.CLICK, funAdv);
			mainMenu.adv.removeEventListener(MouseEvent.RIGHT_CLICK, funAdvR);
			file.removeEventListener(Event.SELECT, selectHandler);
			file.removeEventListener(Event.COMPLETE, completeHandler);

			for each(var m in languageButtons) 
			{
				if (m) m.removeEventListener(MouseEvent.CLICK, funLang);
			}
			if (main.contains(mainMenu)) main.removeChild(mainMenu);
			world.loadingScreen.visible = true;
			world.loadingScreen.progres.text = Res.guiText('loading');
		}

		public function funNewGame(event:MouseEvent)
		{
			world.mmArmor = false;
			mainLoadOff();
			mainNewOn();
		}

		public function funLoadGame(event:MouseEvent)
		{
			world.mmArmor = true;
			mainNewOff();
			loadReg=0;
			mainLoadOn();
		}

		//продолжить игру
		public function funContGame(event:MouseEvent)
		{
			var n:int = 0;
			var maxDate:Number = 0;
			for (var i = 0; i <= world.saveCount; i++) 
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
				command = 3;
			} 
			else 
			{
				mainNewOn();
				mainLoadOff();
			}
		}

		public function funOver(event:MouseEvent) //Mouseover
		{
			(event.currentTarget as MovieClip).fon.scaleX = 1;
			(event.currentTarget as MovieClip).fon.alpha = 1.5;
		}

		public function funOut(event:MouseEvent) //Mouseover stopped
		{
			(event.currentTarget as MovieClip).fon.scaleX = 0.7;
			(event.currentTarget as MovieClip).fon.alpha = 1;
		}
		
		public function setLangButtons()
		{
			languageButtons = new Array();
			if (Languages.languageCount > 1) 
			{
				var i:int = Languages.languageCount;
				for each(var l in Languages.languageListXML.languageID) 
				{
					i--;
					var button:MovieClip = new butLang();
					languageButtons[i] = l;
					button.lang.text = l[0];
					button.y = -i * 40;
					button.n.text = l.@id;
					button.n.visible = false;
					button.addEventListener(MouseEvent.CLICK, funLang);
					mainMenu.lang.addChild(button);
				}
			}
			
		}
		
		//Language
		public function setMainLang()
		{
			//Hardcoded button text as a fallback.
			setMainButton(mainMenu.butContGame, Res.guiText	('contgame'));
			setMainButton(mainMenu.butNewGame, 	Res.guiText	('newgame'));
			setMainButton(mainMenu.butLoadGame, Res.guiText	('loadgame'));
			setMainButton(mainMenu.butOpt, 		Res.guiText	('options'));
			setMainButton(mainMenu.butAbout, 	Res.guiText	('about'));

			mainMenu.dialNew.title.text = Res.guiText('newgame');
			mainMenu.dialLoad.title.text = Res.guiText('loadgame');
			mainMenu.dialLoad.title2.text = Res.guiText('select_slot');
			mainMenu.version.htmlText = '<b>' + Res.guiText('version') + ' ' + version + '</b>';
			mainMenu.dialLoad.butCancel.text.text = mainMenu.dialNew.butCancel.text.text = Res.guiText('cancel');
			mainMenu.dialLoad.butFile.text.text = Res.pipText('loadfile');
			mainMenu.dialLoad.warn.text = mainMenu.dialNew.warn.text=Res.guiText('loadwarn');
			mainMenu.dialNew.infoName.text = Res.guiText('inputname');
			mainMenu.dialNew.hardOpt.text = Res.guiText('hardopt');
			mainMenu.dialNew.butOk.text.text = 'OK';
			mainMenu.dialNew.inputName.text = Res.txt('u','littlepip');
			mainMenu.dialNew.maxChars = 32;
			for (var i = 0; i < kolDifs; i++) 
			{
				mainMenu.dialNew['dif' + i].mode.text = Res.guiText('dif' + i);
				mainMenu.dialNew['dif' + i].modeinfo.text = Res.formatText(Res.txt('g', 'dif' + i, 1));
			}
			for (var i = 1; i <= kolOpts; i++) 
			{
				mainMenu.dialNew['infoOpt' + i].text = Res.guiText('opt' + i);
			}
			mainMenu.dialNew.butVid.mode.text = Res.guiText('butvid');
			if (world.app) world.app.setLang();
			mainMenu.adv.text = Res.advText(world.nadv);
			mainMenu.adv.y = main.stage.stageHeight - mainMenu.adv.textHeight - 40;
			mainMenu.info.txt.htmlText = Res.txt('g', 'inform') + '<br>' + Res.txt('g', 'inform', 1);
			mainMenu.info.visible = (mainMenu.info.txt.text.length>0);
			setScrollInfo();
		}
		
		public function setMainButton(but:MovieClip, txt:String)
		{
			but.txt.text = txt;
			but.glow.text = txt;
			but.txt.visible = (but.glow.textWidth<1)
		}
		
		public function setMenuSize() 
		{
			mainMenu.adv.y = main.stage.stageHeight - mainMenu.adv.textHeight - 40;
			mainMenu.version.y = main.stage.stageHeight - 58;
			mainMenu.link.y=main.stage.stageHeight - 125;
			var ny = main.stage.stageHeight - 400;
			if (ny < 280) ny = 280;
			mainMenu.dialLoad.x = mainMenu.dialNew.x = world.app.vis.x = main.stage.stageWidth / 2;
			mainMenu.dialLoad.y = mainMenu.dialNew.y = world.app.vis.y = ny;
			mainMenu.lang.x = main.stage.stageWidth - 30;
			mainMenu.lang.y = main.stage.stageHeight - 50;
			mainMenu.info.txt.height = mainMenu.info.scroll.height = mainMenu.link.y - mainMenu.info.y - 20;
			setScrollInfo();
		}
		
		public function setScrollInfo()
		{
			if (mainMenu.info.txt.height < mainMenu.info.txt.textHeight) 
			{
				mainMenu.info.scroll.maxScrollPosition = mainMenu.info.txt.maxScrollV;
				mainMenu.info.scroll.visible = true;
			} 
			else mainMenu.info.scroll.visible = false;
		}
		
		public function resizeDisplay(event:Event)
		{
			world.resizeScreen();
			if (active) setMenuSize();
		}

		//Main menu loading
		public function mainLoadOn()
		{
			mainMenu.dialLoad.visible = true;
			mainMenu.dialLoad.title2.visible = (loadReg == 1);
			mainMenu.dialLoad.title.visible = (loadReg == 0);
			mainMenu.dialLoad.slot0.visible = (loadReg == 0);
			mainMenu.dialLoad.info.text = '';
			mainMenu.dialLoad.nazv.text = '';
			mainMenu.dialLoad.pers.visible = false;
			arr = new Array();
			for (var i = 0; i <= world.saveCount; i++) 
			{
				var slot:MovieClip = mainMenu.dialLoad['slot' + i];
				var save:Object = World.world.getSave(i);
				var obj:Object = interdata.PipPageOpt.saveObj(save, i);
				arr.push(obj);
				slot.id.text = i;
				slot.id.visible = false;
				if (save != null && save.est != null) 
				{
					slot.nazv.text = (i == 0)?Res.pipText('autoslot'):(Res.pipText('saveslot') + ' ' + i);
					slot.ggName.text = (save.pers.persName == null)?'-------':save.pers.persName;
					if (save.pers.level != null) slot.ggName.text += ' ('+save.pers.level+')';
					if (save.pers.dead) slot.nazv.text += ' [†]';
					else if (save.pers.hardcore) slot.nazv.text += ' {!}';
					slot.date.text = (save.date == null)?'-------':Res.getDate(save.date);
					slot.level.text = (save.date == null)?'':Res.txt('m', save.game.level).substr(0, 18);
				} 
				else 
				{
					slot.nazv.text = Res.pipText('freeslot');
					slot.ggName.text = slot.level.text = slot.date.text = '';
				}
				slot.addEventListener(MouseEvent.CLICK, funLoadSlot);
				slot.addEventListener(MouseEvent.MOUSE_OVER, funOverSlot);
			}
			mainMenu.dialLoad.butCancel.addEventListener(MouseEvent.CLICK, funLoadCancel);
			mainMenu.dialLoad.butFile.addEventListener(MouseEvent.CLICK, funLoadFile);
			animOn = false;
		}
		
		public function mainLoadOff()
		{
			mainMenu.dialLoad.visible = false;
			if (mainMenu.dialLoad.butCancel.hasEventListener(MouseEvent.CLICK)) 
			{
				mainMenu.dialLoad.butCancel.removeEventListener(MouseEvent.CLICK, funLoadCancel);
				mainMenu.dialLoad.butFile.removeEventListener(MouseEvent.CLICK, funLoadFile);
			}
			for (var i = 0; i <= world.saveCount; i++) 
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
		
		public function funLoadCancel(event:MouseEvent)
		{
			mainLoadOff();
		}

		//select slot
		public function funLoadSlot(event:MouseEvent)
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
		public function funOverSlot(event:MouseEvent)
		{
			interdata.PipPageOpt.showSaveInfo(arr[event.currentTarget.id.text],mainMenu.dialLoad);
		}
		
		public function funLoadFile(event:MouseEvent)
		{
			ffil = [new FileFilter(Res.pipText('gamesaves') + " (*.sav)", "*.sav")];
			file.browse(ffil);
		}
		
		private function selectHandler(event:Event):void 
		{
            file.load();
        }		
		private function completeHandler(event:Event)
		{
			try 
			{
				var obj:Object=file.data.readObject();
				if (obj && obj.est == 1) 
				{
					loadCell = 99;
					world.loaddata = obj;
					mainLoadOff();
					mainMenuOff();
					command = 3;
					com = 'load';
					return;
				}
			} catch(err) 
			{

			}
			trace('MainMenu.as/completeHandler() - Error load');
       }		
		
		//new game
		public function mainNewOn()
		{
			mainMenu.dialNew.visible = true;
			mainMenu.dialNew.butCancel.addEventListener(MouseEvent.CLICK, funNewCancel);
			mainMenu.dialNew.butOk.addEventListener(MouseEvent.CLICK, funNewOk);
			mainMenu.dialNew.butVid.addEventListener(MouseEvent.CLICK, funNewVid);
			for (var i = 0; i <kolDifs; i++) 
			{
				mainMenu.dialNew['dif' + i].addEventListener(MouseEvent.CLICK, funNewDif);
				mainMenu.dialNew['dif' + i].addEventListener(MouseEvent.MOUSE_OVER, infoMode);
			}
			for (var i = 1; i <= kolOpts; i++) 
			{
				mainMenu.dialNew['infoOpt' + i].addEventListener(MouseEvent.MOUSE_OVER, infoOpt);
				mainMenu.dialNew['checkOpt' + i].addEventListener(MouseEvent.MOUSE_OVER, infoOpt);
			}
			updNewMode();
			mainMenu.dialNew.pers.gotoAndStop(2);
			mainMenu.dialNew.pers.gotoAndStop(1);
			animOn = false;
		}

		public function mainNewOff()
		{
			mainMenu.dialNew.visible = false;
			if (mainMenu.dialNew.butCancel.hasEventListener(MouseEvent.CLICK)) mainMenu.dialNew.butCancel.removeEventListener(MouseEvent.CLICK, funNewCancel);
			if (mainMenu.dialNew.butOk.hasEventListener(MouseEvent.CLICK)) mainMenu.dialNew.butOk.removeEventListener(MouseEvent.CLICK, funNewOk);
			if (mainMenu.dialNew.butOk.hasEventListener(MouseEvent.CLICK)) 
			{
				mainMenu.dialNew.butVid.removeEventListener(MouseEvent.CLICK, funNewVid);
				for (var i = 0; i < kolDifs; i++) 
				{
					mainMenu.dialNew['dif' + i].removeEventListener(MouseEvent.CLICK, funNewDif);
					mainMenu.dialNew['dif' + i].removeEventListener(MouseEvent.MOUSE_OVER, infoMode);
				}
			}
			animOn = true;
		}

		public function funAdv(event:MouseEvent) 
		{
			world.nadv++;
			if (world.nadv>=world.koladv) world.nadv = 0;
			mainMenu.adv.text = Res.advText(world.nadv);
			mainMenu.adv.y = main.stage.stageHeight-mainMenu.adv.textHeight -40;
		}

		public function funAdvR(event:MouseEvent) 
		{
			world.nadv--;
			if (world.nadv < 0) world.nadv = world.koladv - 1;
			mainMenu.adv.text = Res.advText(world.nadv);
			mainMenu.adv.y = main.stage.stageHeight - mainMenu.adv.textHeight - 40;
		}

		public function funNewCancel(event:MouseEvent) 
		{
			mainNewOff();
		}

		
		public function funNewOk(event:MouseEvent) //click OK in the new game window
		{
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
				command = 3;
				com = 'new';
			}
		}
		
		public function funNewVid(event:MouseEvent) //enable appearance settings
		{
			setMenuSize();
			mainMenu.dialNew.visible=false;
			world.app.attach(mainMenu,funVidOk,funVidOk);
		}
		
		public function funVidOk() //accept appearance settings
		{
			mainMenu.dialNew.visible = true;
			world.app.detach();
			mainMenu.dialNew.pers.gotoAndStop(2);
			mainMenu.dialNew.pers.gotoAndStop(1);
		}

		public function funNewDif(event:MouseEvent) 
		{
			if (event.currentTarget==mainMenu.dialNew.dif0) newGameDif = 0;
			if (event.currentTarget==mainMenu.dialNew.dif1) newGameDif = 1;
			if (event.currentTarget==mainMenu.dialNew.dif2) newGameDif = 2;
			if (event.currentTarget==mainMenu.dialNew.dif3) newGameDif = 3;
			if (event.currentTarget==mainMenu.dialNew.dif4) newGameDif = 4;
			updNewMode();
		}

		public function updNewMode() 
		{
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

		public function infoMode(event:MouseEvent) 
		{
			mainMenu.dialNew.modeinfo.htmlText = event.currentTarget.modeinfo.text;
		}

		public function infoOpt(event:MouseEvent) 
		{
			var n = int(event.currentTarget.name.substr(event.currentTarget.name.length - 1));
			mainMenu.dialNew.modeinfo.htmlText = Res.formatText(Res.txt('g', 'opt' + n, 1));
		}
		
		public function funOpt(event:MouseEvent) 
		{
			mainNewOff();
			mainLoadOff();
			world.pip.onoff();
		}

		public function funLang(event:MouseEvent)
		{
			mainMenu.loading.text = '';
			var nid = event.currentTarget.n.text;
			if (nid == Languages.currentLanguageData) return;
			Languages.defuxLang(nid);
			if (nid == Languages.currentLanguageData) 
			{
				setMainLang();
			} 
			else 
			{
				langReload = true;
				showButtons(false);
				mainMenu.loading.text = 'Loading';
			}
		}
		
		public function showButtons(n:Boolean) 
		{
			mainMenu.lang.visible = n;
			
			mainMenu.butNewGame.visible = n;
			mainMenu.butLoadGame.visible = n;
			mainMenu.butContGame.visible = n;
			mainMenu.butOpt.visible = n;
			mainMenu.butAbout.visible = n;
		}
		
		//creators
		public function funAbout(event:MouseEvent) 
		{
			mainMenu.dialAbout.title.text = Res.guiText('about');
			var s:String = Res.formatText(Res.txt('g','about',1));
			s += '<br><br>'+Res.guiText('usedmusic')+'<br>';
			s += "<br><span class='music'>"+Res.formatText(Res.d.gui.(@id=='usedmusic').info[0])+"</span>"
			s += "<br><br><a href='https://creativecommons.org/licenses/by-nc/4.0/legalcode'>Music CC-BY License</a>";
			mainMenu.dialAbout.txt.styleSheet = style;
			mainMenu.dialAbout.txt.htmlText = s;
			mainMenu.dialAbout.visible = true;
			mainMenu.dialAbout.butCancel.addEventListener(MouseEvent.CLICK, funAboutOk);
			mainMenu.dialAbout.scroll.maxScrollPosition=mainMenu.dialAbout.txt.maxScrollV;
		}
		public function funAboutOk(event:MouseEvent) 
		{
			mainMenu.dialAbout.visible = false;
			mainMenu.dialAbout.butCancel.removeEventListener(MouseEvent.CLICK, funAboutOk);
		}
		
		public function step()
		{
			trace('MainMenu.as/mainStep - main menu is STEPPING');
			if (langReload) 
			{	
				try
				{
					langReload = false;
					showButtons(true);
					if (Languages.textLoadFailed) mainMenu.loading.text = 'Language loading error';
					else mainMenu.loading.text = '';
					world.pip.updateLang();
					setMainLang();
					trace('MainMenu.as/step() - Language reloaded.');
				}
				catch (err)
				{
					trace('MainMenu.as/step() - Reloading language failed.\n', 'Reason: ' + err.message);
				}
				return;
			}
			if (loaded) 
			{
				if (animOn && !world.pip.active) displ.anim();
				if (world.allLandsLoaded && Languages.textLoaded)
				{
					if (Settings.musicKol > Settings.musicLoaded) mainMenu.loading.text = 'Music loading ' + Settings.musicLoaded + '/' + Settings.musicKol;
					else mainMenu.loading.text = '';
				}
				return;
			}
			if (world.grafon.resourcesLoaded) 
			{
				stn++;
				mainMenu.loading.text = 'Loading ' + (Math.floor(stn / 30))+'\n';
				if (Languages.textLoaded) world.init2(); // Call for init 2.
				if (world.allLandsLoaded && Languages.textLoaded) 
				{
					setLangButtons();
					setMainLang();
					loaded = true;
					showButtons(true);
					return;
				}
				mainMenu.loading.text += world.load_log;
			} 
			else 
			{
				mainMenu.loading.text = 'Loading ' + Math.round(world.grafon.progressLoad * 100) + '%';
			}
		}
		
		public function log(s:String) 
		{
			mainMenu.loading.text += s + '; ';
		}

		public function mainStep(event:Event):void  // Runs when entering the frame.
		{
			trace('MainMenu.as/mainStep - main menu is MAINSTEPPING');
			if (active) step();
			else if (command > 0) 
			{
				command--;
				if (command == 1 && !mainMenu.dialNew.checkOpt1.selected && com == 'new') 
				{
					world.setLoadScreen(0);
				}
				
				if (command == 0) //start the game!!!!
				{
					trace('MainMenu.as/mainStep() - Starting the game...');
					var opt:Object;
					if (com == 'new') 
					{
						//skipTraining - option 1 - skip training
						//hardcoreMode - option 2
						//fastxp - option 3, 40% less experience needed
						//randomizeLevelUpSkills - option 4, randomize what skillpoints are assigned to when leveling up.
						//hardskills - give 3 sp per level (instead of?)
						//autoSaveN - autosave cell
						//limitedInventory
						opt =
						{
							dif:newGameDif,
							skipTraining:mainMenu.dialNew.checkOpt1.selected,
							hardcore:mainMenu.dialNew.checkOpt2.selected,
							fastxp:mainMenu.dialNew.checkOpt3.selected,
							rndpump:mainMenu.dialNew.checkOpt4.selected,
							hardskills:mainMenu.dialNew.checkOpt5.selected,
							hardinv:mainMenu.dialNew.checkOpt6.selected
						};
						if (opt.hardcore) opt.autoSaveN = loadCell;
						loadCell = -1;
					}
					world.startNewGame(loadCell, mainMenu.dialNew.inputName.text, opt);
				}
			} 
			else world.step();
		}
		
	}
}
