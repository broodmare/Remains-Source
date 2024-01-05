package interdata 
{
	
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.StageDisplayState;
	import flash.net.FileReference;
	import flash.net.FileFilter;
	import flash.net.URLLoader; 
	import flash.net.URLRequest; 
	import flash.utils.ByteArray;

	import fl.controls.ScrollBar;
	import fl.events.ScrollEvent;
	import fl.controls.CheckBox;
	
	import components.Settings;
	
	import stubs.visPipOptItem;
	import stubs.logText;

	public class PipPageOpt extends PipPage
	{
		
		var setkeyAction:String;
		var setkeyCell:int = 1;
		var setkeyKey;
		var nSave:int = -1;
		var info:TextField;
		var hit1:Boolean;
		var hit2:Boolean;
		
		var file:FileReference = new FileReference();
		var ffil:Array;
		
		public function PipPageOpt(npip:PipBuck, npp:String) 
		{
			isLC = true;
			itemClass = visPipOptItem;
			super(npip, npp);

			vis.butOk.addEventListener(MouseEvent.CLICK, transOk);
			vis.butDef.addEventListener(MouseEvent.CLICK, gotoDef);
			file.addEventListener(Event.SELECT, selectHandler);
			file.addEventListener(Event.COMPLETE, completeHandler);

			pip.vis.butHelp.visible = false;
			var log:logText = new logText();
			info = log.text;
			log.x = 20;
			log.y = 85;
			vis.addChild(log);
			trace('PipPageOpt.as/PipPageOpt() - Created PipPageOpt page.');
		}

		//set public
		//подготовка страниц
		public override function setSubPages():void
		{
			info.visible 		= false;
			statHead.visible 	= false;
			vis.butOk.visible 	= false;
			vis.butDef.visible	= false;
			vis.pers.visible	= false;
			vis.info.y			= 160;
			nSave				= -1;

			if (page2 == 3)
			{
				try
				{
					if (statHead == null)
					{
						trace('PipPageOpt.as/setSubPages() - statHead is null.');
					}

					statHead.nazv.text = ''; 
					statHead.numb.text = '';

					if (arr == null)
					{
						trace('PipPageOpt.as/setSubPages() - arr is null.');
					}
					arr.push({id:'fullscreen'});
					arr.push({id:'zoom100', 	check:Settings.zoom100});
					arr.push({id:'quake', 		check:Settings.quakeCam});
					arr.push({id:'opt1_1', 		numb:Math.round(Snd.globalVol * 100)});
					arr.push({id:'opt1_2', 		numb:Math.round(Snd.musicVol  * 100)});
					arr.push({id:'opt1_3', 		numb:Math.round(Snd.stepVol   * 100)});
					arr.push({id:'help_mess', 	check:Settings.helpMess});
					arr.push({id:'dial_on', 	check:Settings.dialOn});
					arr.push({id:'show_hit1', 	check:Settings.showHit > 0});
					arr.push({id:'show_hit2', 	check:Settings.showHit == 2});
					arr.push({id:'hint_tele', 	check:Settings.hintTele});
					arr.push({id:'sys_cur', 	check:Settings.systemCursor});
					arr.push({id:'show_favs', 	check:Settings.showFavs});
					arr.push({id:'mat_filter', 	check:Settings.matFilter});
					arr.push({id:'err_show', 	check:Settings.errorShowOpt});
					arr.push({id:'autotake'});
				}
				catch (err:Error)
				{
					trace('PipPageOpt.as/setSubPages() - Failed updating page 2. Page 2: "' + page2 + '". Error: "' + err.message + '".');
				}

			}

			if (page2 == 6) 
			{
				try
				{
					if (arr == null)
					{
						trace('PipPageOpt.as/setSubPages() - arr is null.');
					}
					arr.push({id:'vsWeaponNew', check:Settings.vsWeaponNew});
					arr.push({id:'vsWeaponRep', check:Settings.vsWeaponRep});
					arr.push({id:'vsAmmoAll', 	check:Settings.vsAmmoAll});
					arr.push({id:'vsAmmoTek', 	check:Settings.vsAmmoTek});
					arr.push({id:'vsExplAll', 	check:Settings.vsExplAll});
					arr.push({id:'vsMedAll', 	check:Settings.vsMedAll});
					arr.push({id:'vsHimAll', 	check:Settings.vsHimAll});
					arr.push({id:'vsEqipAll', 	check:Settings.vsEqipAll});
					arr.push({id:'vsStuffAll', 	check:Settings.vsStuffAll});
					arr.push({id:'vsVal', 		check:Settings.vsVal});
					arr.push({id:'vsBook', 		check:Settings.vsBook});
					arr.push({id:'vsFood', 		check:Settings.vsFood});
					arr.push({id:'vsComp', 		check:Settings.vsComp});
					arr.push({id:'vsIngr', 		check:Settings.vsIngr});
					trace('PipPageOpt.as/setSubPages() - Sucessfully updated page 2.');
				}
				catch (err:Error)
				{
					trace('PipPageOpt.as/setSubPages() - Failed updating page 2. Page 2: "' + page2 + '"');
				}

			}

			if (page2 == 4) 
			{
				try
				{
					if (arr == null)
					{
						trace('PipPageOpt.as/setSubPages() - arr is null.');
					}
					setTopText('infokeys');
					for each (var key:Object in GameSession.currentSession.ctr.keyObj) 
					{
						var obj:Object = {id:key.id, objectName:Res.txt('key', key.id), a1:key.a1, a2:key.a2};
						arr.push(obj);
					}
					vis.butOk.text.text  = Res.txt('pip', 'accept');
					vis.butDef.visible 	 = true;
					vis.butDef.text.text = Res.txt('pip', 'default');
					trace('PipPageOpt.as/setSubPages() - Sucessfully updated page 2.');
				}
				catch (err:Error)
				{
					trace('PipPageOpt.as/setSubPages() - Failed updating page 2. Page 2: "' + page2 + '"');
				}

			}

			if (page2 == 5) 
			{
				try
				{
					if (pip.light) return;
					info.visible 	= true;
					info.styleSheet = GameSession.currentSession.gui.style;
					info.htmlText 	= GameSession.currentSession.log;
					info.scrollV 	= info.maxScrollV;
					trace('PipPageOpt.as/setSubPages() - Sucessfully updated page 2.');
				}
				catch (err)
				{
					trace('PipPageOpt.as/setSubPages() - Failed updating page 2. Page 2: "' + page2 + '"');
				}
			}

			if (page2 == 1 || page2 == 2) 
			{
				try
				{
					if (arr == null)
					{
						trace('PipPageOpt.as/setSubPages() - arr is null.');
					}
					if (pip.light) return;
					vis.butDef.visible = true;
					GameSession.currentSession.appearanceWindow.saveOst();
					if (page2 == 1) 
					{
						setTopText('infoload');
						vis.butOk.text.text = Res.txt('pip', 'opt1');
						vis.butDef.text.text = Res.txt('pip', 'loadfile');
					} 
					else 
					{
						setTopText('infosave');
						if (GameSession.currentSession.pers.hardcoreMode) 
						{
							nSave = GameSession.currentSession.autoSaveN;
							vis.butOk.visible = true;
						}
						vis.butOk.text.text = Res.txt('pip', 'opt2');
						if (gg.pers.hardcoreMode) vis.butDef.visible = false;
						vis.butDef.text.text = Res.txt('pip', 'savefile');
					}
					for (var i:int = 0; i <= GameSession.currentSession.saveCount; i++) 
					{
						var save:Object = GameSession.currentSession.getSave(i);
						var obj1:Object = saveObj(save,i);
						arr.push(obj1);
					}
					if (page2 == 2 && GameSession.currentSession.pers.hardcoreMode) 
					{
						showSaveInfo(arr[nSave], vis);
					}
					pip.vis.butHelp.visible=true;
					pip.helpText = Res.txt('pip','helpSave', 0, true);
					trace('PipPageOpt.as/setSubPages() - Sucessfully updated page 2.');
				}
				catch (err:Error)
				{
					trace('PipPageOpt.as/setSubPages() - Failed updating page 2. Page 2: "' + page2 + '"');
				}

			}
		}
		
		public static function saveObj(save:Object, n):Object 
		{
			var obj:Object={id:n};
			if (save == null || save.est == null) 
			{
				obj.objectName = Res.txt('pip', 'freeslot');
				obj.gg = '';
				obj.date = '';
			} 
			else 
			{
				obj.objectName = (n == 0) ? Res.txt('pip', 'autoslot'):(Res.txt('pip', 'saveslot')+' '+n);
				obj.gg 		= (save.pers.persName==null)?'-------':save.pers.persName;
				obj.level 	= Res.txt('map',save.game.level);
				obj.level 	= (save.pers.level==null)?'':save.pers.level;
				obj.date 	= (save.date==null)?'-------':Res.getDate(save.date);
				obj.dif 	= Res.txt('gui', 'dif'+save.game.dif);
				obj.app 	= save.app;
				obj.armor 	= save.invent.cArmorId;
				if (save.pers.dead) obj.hard = 2;
				else if (save.pers.hardcoreMode) obj.hard = 1;
				if (save.hardInv) obj.hardInv = 1;
				if (save.pers.rndpump) obj.rndpump = 1;
				obj.time = Res.gameTime(save.game.t_save);
				obj.ver = save.ver;
			}

			trace('PipPageOpt.as/setSubPages() - Finished updating subPages.');
			return obj;
		}		
		
		//показ одного элемента
		public override function setStatItem(item:MovieClip, obj:Object):void
		{
			if (obj.id!=null) item.id.text=obj.id;
			else item.id.text='';
			item.id.visible=false;
			item.scr.visible=false;
			item.check.visible=false;
			item.key1.visible=item.key2.visible=false;
			item.ramka.visible=false;
			item.level.text = '';
			
			if (page2==3 || page2==6) 
			{
				item.nazv.text = Res.txt('pip', obj.id);
				item.ggName.text = '';
				if (obj.numb != null) 
				{
					item.numb.text = obj.numb;
					var scr:ScrollBar = item.scr;
					scr.visible = true;
					scr.minScrollPosition =   0;
					scr.maxScrollPosition = 100;
					scr.scrollPosition = obj.numb;
					if (!scr.hasEventListener(ScrollEvent.SCROLL)) scr.addEventListener(ScrollEvent.SCROLL,optScroll);
				} 
				else 
				{
					item.numb.text='';
				}
				if (obj.check!=null) 
				{
					item.check.visible=true;
					var ch:CheckBox = item.check;
					ch.selected=obj.check;
					if (!ch.hasEventListener(Event.CHANGE)) ch.addEventListener(Event.CHANGE,optCheck);
				}
			}
			if (page2==4) 
			{
				item.key1.visible=item.key2.visible=true;
				item.numb.text=item.ggName.text='';
				item.nazv.text=obj.objectName;
				setVisKey(obj.a1,item.key1);
				setVisKey(obj.a2,item.key2);
			}
			if (page2==1 || page2==2) 
			{
				item.nazv.text=obj.objectName;
				item.numb.text=obj.date;
				item.ggName.text=obj.gg;
				if (obj.level) item.ggName.text+=((obj.level!='')?(' ('+obj.level+')'):'');
				if (obj.level) item.level.text=obj.level.substr(0,18);
				if (obj.hard==1) item.nazv.text+=' {!}';
				if (obj.hard==2) item.nazv.text+=' [†]';
				if (nSave==obj.id) item.ramka.visible=true;
			}
		}
		
		//установить визуальное отображение клавиши
		public function setVisKey(n,vis):void
		{
			vis.txt.text='';
			vis.gotoAndStop(1);
			if (n==null) return;
			try {
				vis.txt.text=GameSession.currentSession.ctr.keyNames[n];
			} 
			catch(err:Error) 
			{
				vis.gotoAndStop(n);
			}

		}
		
		//показать окно назначения клавиши
		public function showSetKey():void
		{
			pip.vissetkey.visible=true;
			pip.vissetkey.txt.htmlText=Res.txt('gui', 'setkeyinfo')+'\n\n<b>'+Res.txt('key',setkeyAction)+'</b>\n'+setkeyCell;
			GameSession.currentSession.ctr.requestKey(unshowSetKey);
		}
		
		public function unshowSetKey():void
		{
			var newkey=GameSession.currentSession.ctr.setkeyRequest;
			pip.vissetkey.visible=false;
			if (newkey!=-1) 
			{
				for (var i in arr) 
				{
					if (newkey!=null) 
					{
						if (arr[i].a1==newkey) arr[i].a1=null;
						if (arr[i].a2==newkey) arr[i].a2=null;
					}
					if (arr[i].id==setkeyAction)
					{
						if (setkeyCell == 1) arr[i].a1 = newkey;
						if (setkeyCell == 2) arr[i].a2 = newkey;
					}
				}
				setStatItems();
				vis.butOk.visible = true;
			}
		}
		
		public override function setStatus(flop:Boolean=true):void
		{
			if (pip.light) 
			{
				vis.but5.visible = vis.but1.visible = vis.but2.visible = false;
				if (page2==1 || page2==2) page2=3;
			}
			else 
			{
				vis.but5.visible = vis.but1.visible = vis.but2.visible = true;
			}
			super.setStatus(flop);
		}
		public override function updateLang():void
		{
			vis.butOk.text.text=Res.txt('pip', 'accept');
			vis.butDef.text.text=Res.txt('pip', 'default');
			super.updateLang();
		}
		
		public function optScroll(event:ScrollEvent):void
		{
			event.currentTarget.parent.numb.text = Math.round(event.position);
			var id = event.currentTarget.parent.id.text;
			if (id == 'opt1_1') 
			{
				Snd.globalVol = Number((event.position / 100).toFixed(2));
				Snd.soundEnabled = Snd.globalVol > 0;
				Snd.ps('mine_bip', 1000, 0);
			}
			if (id == 'opt1_2') 
			{
				Snd.musicVol = Number((event.position / 100).toFixed(2));
				Snd.musicEnabled = Snd.musicVol > 0;
				Snd.updateMusicVol();
			}
			if (id == 'opt1_3') 
			{
				Snd.stepVol = Number((event.position / 100).toFixed(2));
			}
			pip.isSaveConf = true;
		}

		public function optCheck(event:Event):void
		{
			var id = event.currentTarget.parent.id.text;
			var sel:Boolean = (event.target as CheckBox).selected;
			if (id == 'dial_on') Settings.dialOn = sel;
			if (id == 'mat_filter') Settings.matFilter = sel;
			if (id == 'help_mess') Settings.helpMess = sel;
			hit1 = Settings.showHit > 0;
			hit2 = Settings.showHit == 2;
			if (id == 'show_hit1') hit1 = sel;
			if (id == 'show_hit2') hit2 = sel;
			Settings.showHit = hit1 ? (hit2 ? 2:1):0;
			if (id == 'sys_cur') Settings.systemCursor = sel
			if (id == 'hint_tele') Settings.hintTele = sel;
			if (id == 'show_favs') Settings.showFavs = sel;
			if (id == 'quake') Settings.quakeCam = sel;
			if (id == 'err_show') Settings.errorShowOpt = sel;
			if (id == 'zoom100') 
			{
				Settings.zoom100=sel;
				if (!pip.light) 
				{
					if (sel) GameSession.currentSession.cam.setZoom(0);
					else GameSession.currentSession.cam.setZoom(2);
				} 
				else 
				{
					if (sel) GameSession.currentSession.cam.isZoom=0;
					else GameSession.currentSession.cam.isZoom=2;
				}
			}
			if (page2 == 6) 
			{
				GameSession.currentSession[id] = sel;
				GameSession.currentSession.checkLoot = true;
			}
			pip.isSaveConf=true;
		}
		
		//set public
		public override function itemClick(event:MouseEvent):void
		{
			if (GameSession.currentSession.ctr.setkeyOn) return;
			if (page2 == 3) 
			{
				if (event.currentTarget.id.text=='fullscreen') 
				{
					GameSession.currentSession.swfStage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
				}
				if (event.currentTarget.id.text=='autotake') 
				{
					page2 = 6;
					setStatus();
				}
			} 
			else if (page2 == 4) 
			{
				if (event.target.parent.name=='key1' || event.target.name=='key1') setkeyCell=1;
				else if (event.target.parent.name=='key2' || event.target.name=='key2') setkeyCell=2;
				else return;
				if (setkeyCell==1 && event.currentTarget.key1.txt.text=='TAB') return;
				setkeyAction=event.currentTarget.id.text;
				showSetKey();
			} 
			else if (page2 == 1 || page2 == 2) 
			{
				if (pip.gamePause && page2 == 2) 
				{
					GameSession.currentSession.gui.infoText('gamePause');
					return;
				}
				if (page2 == 2 && gg.pers.hardcoreMode) return;
				var numb:int = event.currentTarget.id.text;
				if (page2 == 1 && event.currentTarget.numb.text == '') return;
				nSave = numb;
				setStatItems();
				showSaveInfo(arr[numb], vis);
				vis.butOk.visible = true;
			}
		}
		
		//set public
		//применить настройки
		public function transOk(event:MouseEvent):void
		{
			if (page2==4) 
			{
				for (var i in arr) 
				{
					var obj=GameSession.currentSession.ctr.keyIds[arr[i].id];
					obj.a1=arr[i].a1;
					obj.a2=arr[i].a2;
				}
				vis.butOk.visible=false;
				GameSession.currentSession.ctr.updateKeys();
				GameSession.currentSession.saveConfig();
			} 
			else if (page2==1) 
			{
				GameSession.currentSession.comLoad=nSave;
			} 
			else if (page2==2) 
			{
				if (pip.gamePause) 
				{
					GameSession.currentSession.gui.infoText('gamePause');
					return;
				}
					try 
					{
						GameSession.currentSession.saveGame(nSave);
						GameSession.currentSession.gui.infoText('SaveGame');
						nSave=-1;
						vis.butOk.visible=false;
						setStatus();
					}
					catch (err:Error) 
					{
						GameSession.currentSession.gui.infoText('noSaveGame');
					}
			}
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
					GameSession.currentSession.comLoad=99;
					GameSession.currentSession.loaddata=obj;
					return;
				}
			} 
			catch(err) 
			{
				
			}
			GameSession.currentSession.gui.infoText('noLoadGame');
			trace('Error load');
       }		
		
		public function gotoDef(event:MouseEvent):void
		{
			if (page2==4) 
			{
				GameSession.currentSession.ctr.gotoDef();
				GameSession.currentSession.ctr.updateKeys();
				GameSession.currentSession.saveConfig();
				setStatus();
			} 
			else if (page2==1) 
			{
				ffil=[new FileFilter(Res.txt('pip', 'gamesaves')+" (*.sav)", "*.sav")];
				file.browse(ffil);
			} 
			else if (page2==2) 
			{
				if (pip.gamePause) 
				{
					GameSession.currentSession.gui.infoText('gamePause');
					return;
				}
				//сохранить в файл
				var obj:Object={};
				GameSession.currentSession.saveToObj(obj);
				var ba:ByteArray=new ByteArray();
				ba.writeObject(obj);
				var sfile = new FileReference();
				try 
				{
					sfile.save(ba,gg.pers.persName+'('+gg.pers.level+').sav');
				} 
				catch(err) 
				{
					sfile.save(ba,'Name('+gg.pers.level+').sav');
				}
			}
		}
		
		public static function showSaveInfo(obj:Object, vis:MovieClip):void
		{
			vis.info.htmlText='';
			if (obj && obj.gg!='') 
			{
				vis.nazv.text = obj.gg;
				GameSession.currentSession.appearanceWindow.load(obj.app);
				GameSession.currentSession.pip.setArmor(obj.armor);
				vis.pers.gotoAndStop(2);
				vis.pers.gotoAndStop(1);
				vis.pers.head.morda.magic.visible=false;
				vis.pers.visible=true;
				vis.info.y=vis.pers.y+25;
				vis.info.htmlText+=Res.txt('pip', 'level')+': ' + textAsColor('yellow', obj.level)+'\n';
				vis.info.htmlText+=obj.level+'\n';
				vis.info.htmlText+='\n';
				vis.info.htmlText+=Res.txt('pip', 'diff')+': ' + textAsColor('yellow', obj.dif)+'\n';
				if (obj.hard==1) vis.info.htmlText+=Res.txt('gui', 'opt2')+'\n';
				if (obj.hard==2) vis.info.htmlText+=textAsColor('red', Res.txt('pip', 'dead'))+'\n';
				if (obj.hardInv==1) vis.info.htmlText+=Res.txt('gui', 'opt6')+'\n';
				if (obj.rndpump==1) vis.info.htmlText+=Res.txt('gui', 'opt4')+'\n';
				if (obj.ver) vis.info.htmlText+=Res.txt('gui', 'version')+': ' + textAsColor('yellow', obj.ver)+'\n';
				vis.info.htmlText += Res.txt('pip', 'tgame') + ': ' + textAsColor('yellow', obj.time) + '\n';
				vis.info.htmlText += Res.txt('pip', 'saved') + ': ' + textAsColor('yellow', obj.date) + '\n';
			} 
			else 
			{
				vis.nazv.text = '';
				vis.pers.visible = false;
			}
		}
		
		//информация об элементе
		public override function statInfo(event:MouseEvent):void
		{
			if (page2==3 || page2==6) 
			{
				vis.info.htmlText=Res.txt('pip',event.currentTarget.id.text,1);
			} 
			else if (page2==1 || page2==2) 
			{
				if (nSave<0) showSaveInfo(arr[event.currentTarget.id.text],vis);
			} 
			else vis.info.text='';
		}
	}
	
}
