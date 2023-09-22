package src {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageScaleMode;
	import flash.display.StageDisplayState;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import src.inter.PipBuck;
	import src.inter.Appear;
	import src.graph.Displ;
	import flash.display.SimpleButton;
	import flash.text.TextFormat;
	import flash.text.StyleSheet;
	import flash.net.FileReference;
	import flash.net.FileFilter;
	//import flash.net.URLLoader; 
	//import flash.net.URLRequest; 
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import src.inter.PipPageOpt;
	
	public class MainMenu 
	{

		var version:String='1.0.3a (woons)';
		var mainMenu:MovieClip; // Create MovieClip object for MainMenu
		public var main:Sprite;
		var world:World;
		public var active:Boolean=true;
		public var loaded:Boolean=false;
		var newGameMode:int = 2;
		var newGameDif:int = 2;
		var loadCell:int = -1;
		var loadReg:int = 0;	// loading mode, 0 - loading, 1 - slot selection for autosave
		var command:int = 0; //What should the main menu be doing?
		var com:String='';
		var mmp:MovieClip; // Create MovieClip object for PipBuck
		var pip:PipBuck;
		var displ:Displ;
		var animOn:Boolean=true;
		var langReload:Boolean=false;
		
		var kolDifs:int = 5;
		var kolOpts:int = 6;
		
		var butsLang:Array;
		
		var stn:int = 0;
		
		public var style:StyleSheet = new StyleSheet(); 
		var styleObj:Object = new Object(); 
		
		var format:TextFormat = new TextFormat();
		
		var file:FileReference = new FileReference();
		var ffil:Array;
		var arr:Array=new Array();
		
		var mainTimer:Timer;
			
		public function MainMenu(nmain:Sprite) 
		{
			main = nmain;
			mainMenu = new visMainMenu();   //Linkage defined in pfe.fla
			mainMenu.dialLoad.visible = false;
			mainMenu.dialNew.visible = false;
			mainMenu.dialAbout.visible = false;
			main.stage.addEventListener(Event.RESIZE, resizeDisplay); 
			main.stage.addEventListener(Event.ENTER_FRAME, mainStep);
			
			//mainTimer = new Timer(30);
			//mainTimer.addEventListener(TimerEvent.TIMER, mainStep);
			//mainTimer.start();
			
			showButtons(false);
			mainMenuOn();
			
			var paramObj:Object = LoaderInfo(main.root.loaderInfo).parameters;
			world = new World(main);
			world.mainMenu = this;
			
			mainMenu.testtest.visible=world.testMode;
			mainMenu.info.visible=false;
			//mainMenu.testtest.htmlText='555 <a href="https://tabun.everypony.ru/">gre</a> 777';
			Snd.initSnd();
			setMenuSize();
			displ=new Displ(mainMenu.pipka, mainMenu.groza);
			mainMenu.groza.visible=false;
			format.font = "_sans";
            format.color = 0xFFFFFF;
            format.size = 28;
			
			styleObj.fontWeight = "bold"; 
			styleObj.color = "#FFFF00"; 
			style.setStyle(".yel", styleObj); 	//выделение важного
			
			styleObj.fontWeight = "normal"; 
			styleObj.color = "#00FF99";
			styleObj.fontSize= "12";
			style.setStyle(".music", styleObj); 	//мелкий шрифт
			
			styleObj.fontWeight = "normal"; 
			styleObj.color = "#66FF66";
			styleObj.fontSize=undefined;
			style.setStyle("a", styleObj); 	//ссыль
			styleObj.textDecoration= "underline";
			style.setStyle("a:hover", styleObj);
			
			//mainMenu.testtest.styleSheet=style;
			mainMenu.info.txt.styleSheet=style;
			mainMenu.link.l1.styleSheet=style;
			mainMenu.link.l2.styleSheet=style;
			//mainMenu.link.l1.htmlText="<a href='http://foe.ucoz.org/main.html'>foe.ucoz.org</a>";
			//mainMenu.link.l1.useHandCursor=true;
		}

		public function mainMenuOn() 
		{
			active=true;
			//mainMenu.butRus.addEventListener(MouseEvent.CLICK, funRus);
			//mainMenu.butEng.addEventListener(MouseEvent.CLICK, funEng);
			mainMenu.butNewGame.addEventListener(MouseEvent.MOUSE_OVER, funOver);
			mainMenu.butNewGame.addEventListener(MouseEvent.MOUSE_OUT, funOut);
			mainMenu.butLoadGame.addEventListener(MouseEvent.MOUSE_OVER, funOver);
			mainMenu.butLoadGame.addEventListener(MouseEvent.MOUSE_OUT, funOut);
			mainMenu.butContGame.addEventListener(MouseEvent.MOUSE_OVER, funOver);
			mainMenu.butContGame.addEventListener(MouseEvent.MOUSE_OUT, funOut);
			mainMenu.butOpt.addEventListener(MouseEvent.MOUSE_OVER, funOver);
			mainMenu.butOpt.addEventListener(MouseEvent.MOUSE_OUT, funOut);
			mainMenu.butAbout.addEventListener(MouseEvent.MOUSE_OVER, funOver);
			mainMenu.butAbout.addEventListener(MouseEvent.MOUSE_OUT, funOut);
			mainMenu.butOpt.addEventListener(MouseEvent.CLICK, funOpt);
			mainMenu.butNewGame.addEventListener(MouseEvent.CLICK, funNewGame);
			mainMenu.butLoadGame.addEventListener(MouseEvent.CLICK, funLoadGame);
			mainMenu.butContGame.addEventListener(MouseEvent.CLICK, funContGame);
			mainMenu.butAbout.addEventListener(MouseEvent.CLICK, funAbout);
			mainMenu.adv.addEventListener(MouseEvent.CLICK, funAdv);
			mainMenu.adv.addEventListener(MouseEvent.RIGHT_CLICK, funAdvR);
			if (!main.contains(mainMenu)) main.addChild(mainMenu);
			file.addEventListener(Event.SELECT, selectHandler);
			file.addEventListener(Event.COMPLETE, completeHandler);
		}
		public function mainMenuOff() 
		{
			active=false;
			//mainMenu.butRus.removeEventListener(MouseEvent.CLICK, funRus);
			//mainMenu.butEng.removeEventListener(MouseEvent.CLICK, funEng);
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
			for each(var m in butsLang) 
			{
				if (m) m.removeEventListener(MouseEvent.CLICK, funLang);
			}
			if (main.contains(mainMenu)) main.removeChild(mainMenu);
			world.vwait.visible=true;
			world.vwait.progres.text=Res.guiText('loading');
		}

		public function funNewGame(event:MouseEvent) 
		{
			world.mmArmor=false;
			mainLoadOff();
			mainNewOn();
		}

		public function funLoadGame(event:MouseEvent) 
		{
			world.mmArmor=true;
			mainNewOff();
			loadReg=0;
			mainLoadOn();
		}

		//продолжить игру
		public function funContGame(event:MouseEvent) 
		{
			var n:int = 0;
			var maxDate:Number = 0;
			for (var i = 0; i <= world.saveKol; i++) 
			{
				var save:Object=World.w.getSave(i);
				if (save && save.est && save.date > maxDate) 
				{
					n = i;
					maxDate = save.date;
				}
			}

			save=World.w.getSave(n);

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
		public function funOver(event:MouseEvent) 
		{
			(event.currentTarget as MovieClip).fon.scaleX=1;
			(event.currentTarget as MovieClip).fon.alpha=1.5;
		}

		public function funOut(event:MouseEvent) 
		{
			(event.currentTarget as MovieClip).fon.scaleX=0.7;
			(event.currentTarget as MovieClip).fon.alpha=1;
		}
		
		public function setLangButtons() 
		{
			butsLang=new Array();
			if (world.kolLangs>1) {
				var i=world.kolLangs;
				for each(var l in world.langsXML.lang) 
				{
					i--;
					var m:MovieClip=new butLang();
					butsLang[i]=m;
					m.lang.text=l[0];
					m.y=-i*40;
					m.n.text=l.@id;
					m.n.visible=false;
					m.addEventListener(MouseEvent.CLICK, funLang);
					mainMenu.lang.addChild(m);
				}
			}
			//mainMenumm.butRus.lang.text= 'ѠҨҼ✶☆☢☣';
			
		}
		
		//надписи
		public function setMainLang() 
		{
			//mainMenu.butContGame.txt.defaultTextFormat=format;
			setMainButton(mainMenu.butContGame,Res.guiText('contgame'));
			setMainButton(mainMenu.butNewGame,Res.guiText('newgame'));
			setMainButton(mainMenu.butLoadGame,Res.guiText('loadgame'));
			setMainButton(mainMenu.butOpt,Res.guiText('options'));
			setMainButton(mainMenu.butAbout,Res.guiText('about'));
			mainMenu.dialNew.title.text=Res.guiText('newgame');
			mainMenu.dialLoad.title.text=Res.guiText('loadgame');
			mainMenu.dialLoad.title2.text=Res.guiText('select_slot');
			mainMenu.version.htmlText='<b>'+Res.guiText('version')+' '+version+'</b>';
			mainMenu.dialLoad.butCancel.text.text=mainMenu.dialNew.butCancel.text.text=Res.guiText('cancel');
			mainMenu.dialLoad.butFile.text.text=Res.pipText('loadfile');
			mainMenu.dialLoad.warn.text=mainMenu.dialNew.warn.text=Res.guiText('loadwarn');
			mainMenu.dialNew.infoName.text=Res.guiText('inputname');
			mainMenu.dialNew.hardOpt.text=Res.guiText('hardopt');
			mainMenu.dialNew.butOk.text.text='OK';
			mainMenu.dialNew.inputName.text=Res.txt('u','littlepip');
			mainMenu.dialNew.maxChars=32;
			for (var i=0; i<kolDifs; i++) 
			{
				mainMenu.dialNew['dif'+i].mode.text=Res.guiText('dif'+i);
				mainMenu.dialNew['dif'+i].modeinfo.text=Res.formatText(Res.txt('g','dif'+i,1));
			}
			for (var i=1; i<=kolOpts; i++) 
			{
				mainMenu.dialNew['infoOpt'+i].text=Res.guiText('opt'+i);
			}
			mainMenu.dialNew.butVid.mode.text=Res.guiText('butvid');
			if (world.app) world.app.setLang();
			mainMenu.adv.text=Res.advText(world.nadv);
			mainMenu.adv.y=main.stage.stageHeight-mainMenu.adv.textHeight-40;
			//mainMenu.butRus.visible=(Res.lang==1);
			//mainMenu.butEng.visible=(Res.lang==0);
			mainMenu.info.txt.htmlText=Res.txt('g','inform')+'<br>'+Res.txt('g','inform',1);
			mainMenu.info.visible=(mainMenu.info.txt.text.length>0);
			setScrollInfo();
		}
		
		function setMainButton(but:MovieClip, txt:String) 
		{
			but.txt.text=txt;
			but.glow.text=txt;
			but.txt.visible=(but.glow.textWidth<1)
		}
		
		public function setMenuSize()
		{
			mainMenu.adv.y=main.stage.stageHeight-mainMenu.adv.textHeight-40;
			mainMenu.version.y=main.stage.stageHeight-58;
			mainMenu.link.y=main.stage.stageHeight-125;
			var ny=main.stage.stageHeight-400;
			if (ny<280) ny=280;
			mainMenu.dialLoad.x=mainMenu.dialNew.x=world.app.vis.x=main.stage.stageWidth/2;
			mainMenu.dialLoad.y=mainMenu.dialNew.y=world.app.vis.y=ny;
			mainMenu.lang.x=main.stage.stageWidth-30;
			mainMenu.lang.y=main.stage.stageHeight-50;
			mainMenu.info.txt.height=mainMenu.info.scroll.height=mainMenu.link.y-mainMenu.info.y-20;
			setScrollInfo();
		}
		
		function setScrollInfo() 
		{
			if (mainMenu.info.txt.height<mainMenu.info.txt.textHeight) {
				mainMenu.info.scroll.maxScrollPosition=mainMenu.info.txt.maxScrollV;
				mainMenu.info.scroll.visible=true;
			} else mainMenu.info.scroll.visible=false;
		}
		
		public function resizeDisplay(event:Event) {
			world.resizeScreen();
			if (active) setMenuSize();
		}

		//загрузка игры
		public function mainLoadOn() 
		{
			mainMenu.dialLoad.visible=true;
			mainMenu.dialLoad.title2.visible=(loadReg==1);
			mainMenu.dialLoad.title.visible=(loadReg==0);
			mainMenu.dialLoad.slot0.visible=(loadReg==0);
			mainMenu.dialLoad.info.text='';
			mainMenu.dialLoad.nazv.text='';
			mainMenu.dialLoad.pers.visible=false;
			arr=new Array();
			for (var i=0; i<=world.saveKol; i++) 
			{
				var slot:MovieClip=mainMenu.dialLoad['slot'+i];
				var save:Object=World.w.getSave(i);
				var obj:Object=src.inter.PipPageOpt.saveObj(save,i);
				arr.push(obj);
				slot.id.text=i;
				slot.id.visible=false;
				if (save!=null && save.est!=null) 
				{
					slot.nazv.text=(i==0)?Res.pipText('autoslot'):(Res.pipText('saveslot')+' '+i);
					slot.ggName.text=(save.pers.persName==null)?'-------':save.pers.persName;
					if (save.pers.level!=null) slot.ggName.text+=' ('+save.pers.level+')';
					if (save.pers.dead) slot.nazv.text+=' [†]';
					else if (save.pers.hardcore) slot.nazv.text+=' {!}';
					slot.date.text=(save.date==null)?'-------':Res.getDate(save.date);
					slot.land.text=(save.date==null)?'':Res.txt('m',save.game.land).substr(0,18);
				} 
				else 
				{
					slot.nazv.text=Res.pipText('freeslot');
					slot.ggName.text=slot.land.text=slot.date.text='';
				}
				slot.addEventListener(MouseEvent.CLICK, funLoadSlot);
				slot.addEventListener(MouseEvent.MOUSE_OVER, funOverSlot);
			}
			mainMenu.dialLoad.butCancel.addEventListener(MouseEvent.CLICK, funLoadCancel);
			mainMenu.dialLoad.butFile.addEventListener(MouseEvent.CLICK, funLoadFile);
			animOn=false;
		}
		
		public function mainLoadOff() 
		{
			mainMenu.dialLoad.visible=false;
			if (mainMenu.dialLoad.butCancel.hasEventListener(MouseEvent.CLICK)) 
			{
				mainMenu.dialLoad.butCancel.removeEventListener(MouseEvent.CLICK, funLoadCancel);
				mainMenu.dialLoad.butFile.removeEventListener(MouseEvent.CLICK, funLoadFile);
			}
			for (var i=0; i<=world.saveKol; i++) {
				var slot:MovieClip=mainMenu.dialLoad['slot'+i];
				if (slot.hasEventListener(MouseEvent.CLICK)) {
					slot.removeEventListener(MouseEvent.CLICK, funLoadSlot);
					slot.removeEventListener(MouseEvent.MOUSE_OVER, funOverSlot);
				}
			}
			animOn=true;
		}
		
		public function funLoadCancel(event:MouseEvent) 
		{
			mainLoadOff();
		}
		//выбрать слот
		public function funLoadSlot(event:MouseEvent) 
		{
			loadCell=event.currentTarget.id.text;
			if (loadReg==1 && loadCell==0) return;
			if (loadReg==0 && event.currentTarget.ggName.text=='') return;
			mainLoadOff();
			mainMenuOff();
			command = 3;
			if (loadReg==1) com='new';
			else com='load';
		}
		public function funOverSlot(event:MouseEvent) 
		{
			src.inter.PipPageOpt.showSaveInfo(arr[event.currentTarget.id.text],mainMenu.dialLoad);
		}
		
		public function funLoadFile(event:MouseEvent) 
		{
			ffil=[new FileFilter(Res.pipText('gamesaves')+" (*.sav)", "*.sav")];
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
				var obj:Object=file.data.readObject();
				if (obj && obj.est==1) 
				{
					loadCell=99;
					world.loaddata=obj;
					mainLoadOff();
					mainMenuOff();
					command=3;
					com='load';
					return;
				}
			} catch(err) {}
			trace('Error load');
       }		
		
		//new game
		public function mainNewOn() 
		{
			mainMenu.dialNew.visible=true;
			mainMenu.dialNew.butCancel.addEventListener(MouseEvent.CLICK, funNewCancel);
			mainMenu.dialNew.butOk.addEventListener(MouseEvent.CLICK, funNewOk);
			mainMenu.dialNew.butVid.addEventListener(MouseEvent.CLICK, funNewVid);
			for (var i=0; i<kolDifs; i++) 
			{
				mainMenu.dialNew['dif'+i].addEventListener(MouseEvent.CLICK, funNewDif);
				mainMenu.dialNew['dif'+i].addEventListener(MouseEvent.MOUSE_OVER, infoMode);
			}
			for (var i=1; i<=kolOpts; i++) 
			{
				mainMenu.dialNew['infoOpt'+i].addEventListener(MouseEvent.MOUSE_OVER, infoOpt);
				mainMenu.dialNew['checkOpt'+i].addEventListener(MouseEvent.MOUSE_OVER, infoOpt);
			}
			updNewMode();
			mainMenu.dialNew.pers.gotoAndStop(2);
			mainMenu.dialNew.pers.gotoAndStop(1);
			animOn=false;
		}

		public function mainNewOff() 
		{
			mainMenu.dialNew.visible=false;
			if (mainMenu.dialNew.butCancel.hasEventListener(MouseEvent.CLICK)) mainMenu.dialNew.butCancel.removeEventListener(MouseEvent.CLICK, funNewCancel);
			if (mainMenu.dialNew.butOk.hasEventListener(MouseEvent.CLICK)) mainMenu.dialNew.butOk.removeEventListener(MouseEvent.CLICK, funNewOk);
			if (mainMenu.dialNew.butOk.hasEventListener(MouseEvent.CLICK)) 
			{
				mainMenu.dialNew.butVid.removeEventListener(MouseEvent.CLICK, funNewVid);
				for (var i=0; i<kolDifs; i++) 
				{
					mainMenu.dialNew['dif'+i].removeEventListener(MouseEvent.CLICK, funNewDif);
					mainMenu.dialNew['dif'+i].removeEventListener(MouseEvent.MOUSE_OVER, infoMode);
				}
			}
			animOn=true;
		}

		public function funAdv(event:MouseEvent) 
		{
			world.nadv++;
			if (world.nadv>=world.koladv) world.nadv=0;
			mainMenu.adv.text=Res.advText(world.nadv);
			mainMenu.adv.y=main.stage.stageHeight-mainMenu.adv.textHeight-40;
		}

		public function funAdvR(event:MouseEvent) 
		{
			world.nadv--;
			if (world.nadv<0) world.nadv=world.koladv-1;
			mainMenu.adv.text=Res.advText(world.nadv);
			mainMenu.adv.y=main.stage.stageHeight-mainMenu.adv.textHeight-40;
		}

		public function funNewCancel(event:MouseEvent) 
		{
			mainNewOff();
		}

		//click OK in the new game window
		public function funNewOk(event:MouseEvent) 
		{
			mainNewOff();
			if (mainMenu.dialNew.checkOpt2.selected) 
			{	//show slot selection window
				loadReg=1;
				mainLoadOn();
			} 
			else 
			{
				mainMenuOff();
				loadCell=-1;
				command=3;
				com='new';
			}
		}
		//enable appearance settings
		public function funNewVid(event:MouseEvent) 
		{
			setMenuSize();
			mainMenu.dialNew.visible=false;
			world.app.attach(mainMenu,funVidOk,funVidOk);
		}
		//accept appearance settings
		public function funVidOk() 
		{
			mainMenu.dialNew.visible=true;
			world.app.detach();
			mainMenu.dialNew.pers.gotoAndStop(2);
			mainMenu.dialNew.pers.gotoAndStop(1);
		}

		public function funNewDif(event:MouseEvent) 
		{
			if (event.currentTarget==mainMenu.dialNew.dif0) newGameDif=0;
			if (event.currentTarget==mainMenu.dialNew.dif1) newGameDif=1;
			if (event.currentTarget==mainMenu.dialNew.dif2) newGameDif=2;
			if (event.currentTarget==mainMenu.dialNew.dif3) newGameDif=3;
			if (event.currentTarget==mainMenu.dialNew.dif4) newGameDif=4;
			updNewMode();
		}
		function updNewMode() 
		{
			mainMenu.dialNew.dif0.fon.gotoAndStop(1);
			mainMenu.dialNew.dif1.fon.gotoAndStop(1);
			mainMenu.dialNew.dif2.fon.gotoAndStop(1);
			mainMenu.dialNew.dif3.fon.gotoAndStop(1);
			mainMenu.dialNew.dif4.fon.gotoAndStop(1);
			if (newGameDif==0) mainMenu.dialNew.dif0.fon.gotoAndStop(2);
			if (newGameDif==1) mainMenu.dialNew.dif1.fon.gotoAndStop(2);
			if (newGameDif==2) mainMenu.dialNew.dif2.fon.gotoAndStop(2);
			if (newGameDif==3) mainMenu.dialNew.dif3.fon.gotoAndStop(2);
			if (newGameDif==4) mainMenu.dialNew.dif4.fon.gotoAndStop(2);
		}
		function infoMode(event:MouseEvent) 
		{
			mainMenu.dialNew.modeinfo.htmlText=event.currentTarget.modeinfo.text;
		}
		function infoOpt(event:MouseEvent) 
		{
			var n=int(event.currentTarget.name.substr(event.currentTarget.name.length-1));
			mainMenu.dialNew.modeinfo.htmlText=Res.formatText(Res.txt('g','opt'+n,1));
		}
		
		public function funOpt(event:MouseEvent) 
		{
			mainNewOff();
			mainLoadOff();
			world.pip.onoff();
		}
		public function funLang(event:MouseEvent) 
		{
			mainMenu.loading.text='';
			var nid=event.currentTarget.n.text;
			if (nid==world.lang) return;
			world.defuxLang(nid);
			if (nid==world.langDef) 
			{
				setMainLang();
			} 
			else 
			{
				langReload=true;
				showButtons(false);
				mainMenu.loading.text='Loading';
			}
		}
		
		function showButtons(n:Boolean) 
		{
			mainMenu.lang.visible=mainMenu.butNewGame.visible=mainMenu.butLoadGame.visible=mainMenu.butContGame.visible=mainMenu.butOpt.visible=mainMenu.butAbout.visible=n;
		}
		
		//creators
		public function funAbout(event:MouseEvent) {
			mainMenu.dialAbout.title.text=Res.guiText('about');
			var s:String=Res.formatText(Res.txt('g','about',1));
			s+='<br><br>'+Res.guiText('usedmusic')+'<br>';
			s+="<br><span class='music'>"+Res.formatText(Res.d.gui.(@id=='usedmusic').info[0])+"</span>"
			s+="<br><br><a href='https://creativecommons.org/licenses/by-nc/4.0/legalcode'>Music CC-BY License</a>";
			//s=s.replace(/\[/g,"<span class='imp'>");
			//s=s.replace(/\]/g,"</span>");
			mainMenu.dialAbout.txt.styleSheet=style;
			mainMenu.dialAbout.txt.htmlText=s;
			mainMenu.dialAbout.visible=true;
			mainMenu.dialAbout.butCancel.addEventListener(MouseEvent.CLICK, funAboutOk);
			mainMenu.dialAbout.scroll.maxScrollPosition=mainMenu.dialAbout.txt.maxScrollV;
		}
		public function funAboutOk(event:MouseEvent) {
			mainMenu.dialAbout.visible=false;
			mainMenu.dialAbout.butCancel.removeEventListener(MouseEvent.CLICK, funAboutOk);
		}
		
		function step() {
			if (langReload) {
				if (world.textLoaded) 
				{
					langReload=false;
					showButtons(true);
					if (world.textLoadErr) mainMenu.loading.text='Language loading error';
					else mainMenu.loading.text='';
					world.pip.updateLang();
					setMainLang();
				}
				return;
			}
			if (loaded) 
			{
				if (animOn && !world.pip.active) displ.anim();
				if (world.allLandsLoaded && world.textLoaded) 
				{
					if (world.musicKol>world.musicLoaded) mainMenu.loading.text='Music loading '+world.musicLoaded+'/'+world.musicKol;
					else mainMenu.loading.text='';
				}
				return;
			}
			if (world.grafon.resIsLoad) 
			{
				stn++;
				mainMenu.loading.text='Loading '+(Math.floor(stn/30))+'\n';
				//+Math.round(world.textProgressLoad*100)+'%\n';
				if (world.textLoaded) world.init2();
				if (world.allLandsLoaded && world.textLoaded) {
					setLangButtons();
					setMainLang();
					loaded=true;
					showButtons(true);
					return;
				}
				mainMenu.loading.text+=world.load_log;
			} 
			else 
			{
				mainMenu.loading.text='Loading '+Math.round(world.grafon.progressLoad*100)+'%';
			}
		}
		
		public function log(s:String) {
			mainMenu.loading.text+=s+'; ';
		}

		public function mainStep(event:Event):void {
			if (active) step();
			else if (command > 0) 
			{
				command--;
				if (command == 1 && !mainMenu.dialNew.checkOpt1.selected && com == 'new') 
				{
					world.setLoadScreen(0);
				}
				//start the game!!!!
				if (command == 0) 
				{
					var opt:Object;
					if (com == 'new') 
					{
						//propusk - option 1 - skip training
						//hardcore - option 2
						//fastxp - option 3, 40% less experience needed
						//rndpump - option 4, random pumping
						//hardskills - give 3 sp per level
						//autoSaveN - autosave cell
						opt={dif:newGameDif,
							propusk:mainMenu.dialNew.checkOpt1.selected,
							hardcore:mainMenu.dialNew.checkOpt2.selected,
							fastxp:mainMenu.dialNew.checkOpt3.selected,
							rndpump:mainMenu.dialNew.checkOpt4.selected,
							hardskills:mainMenu.dialNew.checkOpt5.selected,
							hardinv:mainMenu.dialNew.checkOpt6.selected};
						if (opt.hardcore) opt.autoSaveN=loadCell;
						loadCell=-1;
					}
					world.newGame(loadCell,mainMenu.dialNew.inputName.text,opt);
				}
			} 
			else world.step();
		}
		
				
	}
	
}
