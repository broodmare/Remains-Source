package interdata 
{
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	import fl.controls.ScrollBar;
	import fl.events.ScrollEvent;
	
	import unitdata.Invent;
	import unitdata.Unit;
	import unitdata.Effect;
	import unitdata.Armor;
	import unitdata.UnitPlayer;
	import weapondata.Weapon;
	import servdata.Item;
	import servdata.Vendor;
	import unitdata.Pers;
	
	import components.Settings;
	import components.XmlBook;
	
	import stubs.visPipHelp;
	import stubs.visSetKey;
	import stubs.visPipRItem;

	public class PipBuck 
	{
		public var light:Boolean		= false;	//простая версия
		var vis:MovieClip;
		var vissetkey:MovieClip;
		var vishelp:MovieClip;
		public var active:Boolean 		= false;
		public var gamePause:Boolean 	= false;
		var noAct2:Boolean 				= false;
		public var ArmorId:String;
		public var hideMane:int 		= 0;
		var visX 						= 1200;
		var visY 						= 800;
		var page:int 					= 1;
		var kolPages:int 				= 5;
		
		var pages:Array;
		public var currentPage:PipPage; //The currently active (displayed) page of the pipbuck
		
		var inv:Invent;
		var gg:UnitPlayer;
		var money:int 				= 0;
		
		public var helpText:String 	= '';
		public var massText:String 	= '';
		
		var showHidden:Boolean 		= false;
		public var reqKey:Boolean 	= false;		// Request for key assignment
		
		public var arrWeapon:Array;
		public var arrArmor:Array;
		
		// Variables set depending on which object or NPC invoked the interface
		public var vendor:Vendor;					// Associated vendor
		public var npcInter:String 		= '';		// Type of interaction of the associated NPC
		public var npcId:String 		= '';		// ID of the associated NPC
		public var workTip:String 		= 'work';	// Type of associated crafting station
		public var travel:Boolean 		= false;	// Able to use transitions between locations
		
		public var isSaveConf:Boolean  	= false;
		
		public var pipVol:Number		= 0.25;
		
		var kolRItems:int 				= 15;

		public var ritems:Array;

		public function PipBuck(vpip:MovieClip) 
		{
			light 			 = true;
			vis 			 = vpip;
			vis.visible 	 = false;
			vis.skin.visible = false;
			vis.fon.visible  = false;
			
			for (var i:int = 0; i <= kolPages; i++) //buttons
			{
				
				var item:MovieClip = vis.getChildByName('but' + i) as MovieClip;
				item.id.visible 	= false;
				item.visible 		= false;
				item.mouseChildren 	= false;
			}

			vis.but0.visible = true;
			vis.but0.addEventListener(MouseEvent.CLICK, pipClose);

			vis.but0.text.text = Res.txt('pip', 'mainclose');

			pages =
			[
				null,
				new PipPageStat(this, 'stat'),
				new PipPageInv(this,  'inv'),
				new PipPageInfo(this, 'info'),
				new PipPageVend(this, 'vend'),
				new PipPageOpt(this,  'opt'),
				new PipPageMed(this,  'med'),
				new PipPageWork(this, 'work'),
				new PipPageApp(this,  'app'),
				new PipPageVault(this,'vault')
			];

			page = kolPages;
			currentPage = pages[page];

			vishelp = new visPipHelp();
			vishelp.x = 168;
			vishelp.y = 138;
			vis.addChild(vishelp);

			vissetkey = new visSetKey();
			vissetkey.visible = false;
			vissetkey.x = 600;
			vissetkey.y = 400;
			vis.addChild(vissetkey);

			vishelp.visible = false;
			PipPage.setStyle(vishelp.txt);

			vis.butHelp.addEventListener(MouseEvent.MOUSE_OVER, helpShow);
			vis.butHelp.addEventListener(MouseEvent.MOUSE_OUT,  helpUnshow);
			vis.butMass.addEventListener(MouseEvent.MOUSE_OVER, massShow);
			vis.butMass.addEventListener(MouseEvent.MOUSE_OUT,  massUnshow);

			PipPage.setStyle(vis.toptext.txt);
			
			vis.pr.visible = false;

			ritems = [];
			for (var j:int = 0; j < kolRItems; j++) 
			{
				item = new visPipRItem();
				ritems[j] = item;
				vis.pr.addChild(item);
				item.x = 5;
				item.y = 40 + j * 30;
				PipPage.setStyle(item.txt);
				item.trol.gotoAndStop(j + 1);
				//item.nazv.visible = false; (This was breaking loading the main menu, but present in original code.)
				item.visible = false;
			}
		}
		
		public function updateLang():void
		{
			vis.but0.text.text = Res.txt('pip', 'mainclose');

			for each(var p in pages) //Run the language update function in every pipbuck page.
			{
				if (p is PipPage) p.updateLang();
			}

			currentPage.setStatus();
		}
		
		public function toNormalMode():void
		{
			light 			 = false;
			vis.skin.visible = true;
			vis.fon.visible  = true;
			for (var i:int = 1; i <= kolPages; i++) 
			{
				var item:MovieClip = vis.getChildByName('but' + i) as MovieClip;
				item.addEventListener(MouseEvent.CLICK,pageClick);
				item.text.text = Res.txt('pip', 'main' + i);
				item.id.text = i;
				item.visible = true;
			}
			vis.but0.text.text = Res.txt('pip', 'main0');
			page = 1;
			allItems();
		}
		
		public function pageClick(event:MouseEvent):void
		{
			if (GameSession.currentSession.ctr.setkeyOn) return;
			if (GameSession.currentSession.gg && GameSession.currentSession.gg.pipOff) return;
			page = int(event.currentTarget.id.text);
			setPage();
			setButtons();
			snd(2);
		}
		public function pipClose(event:MouseEvent):void
		{
			if (GameSession.currentSession.ctr.setkeyOn) return;
			onoff(-1);
		}
		public function setButtons():void
		{
			for (var i:int = 0; i <= kolPages; i++) 
			{
				var item:MovieClip = vis.getChildByName('but' + i) as MovieClip;

				if (page == i) item.gotoAndStop(2);
				else item.gotoAndStop(1);

				if (i == 4 && (page == 6 || page == 7 || page == 8 || page == 9)) item.gotoAndStop(2);
			}
		}
		
		public function snd(n:int):void
		{
			Snd.ps('pip' + n, -1000, -1000, 0, pipVol);
		}
		
		//0 - сменить вкл на выкл
		//11 - принудительно включить
		//Показать/скрыть
		public function onoff(turn:int = 0, p2:int = 0):void
		{
			reqKey = false;

			if (active && turn == 11) return;
			else if (turn == 0) 
			{
				active =! active;
				if (page >= 4 && !light) page = 1;
				snd(3);
			} 
			else if (turn > 0) 
			{
				if (turn < 10) page = turn;
				else if (page >= 4) page = 1;
				active = true;
			} 
			else 
			{
				if (active) snd(3);
				active = false;
			}

			if (!light && GameSession.currentSession.room && GameSession.currentSession.room.base) travel = true;
			vis.but4.visible = false;
			if (turn == 4 || (turn >= 6 && turn <= 9)) 
			{
				vis.but4.id.text 	= turn;
				vis.but4.text.text 	= Res.txt('pip', 'main' + turn);
				vis.but4.visible 	= true;
			}
			vis.visible = active;

			if (active) 
			{
				GameSession.currentSession.cur();
				showHidden = false;
				if (vendor) vendor.reset();
				GameSession.currentSession.ctr.clearAll();
				if (GameSession.currentSession.stand) GameSession.currentSession.stand.onoff(-1);
				setPage(p2);

				if (!light) 
				{
					GameSession.currentSession.gui.offCelObj();
					if (GameSession.currentSession.gui.t_mess>  30) GameSession.currentSession.gui.t_mess = 30;
				}
				if (GameSession.currentSession.gui) 
				{
					GameSession.currentSession.gui.dial.alpha   = 0;
					GameSession.currentSession.gui.inform.alpha = 0;
				}
				if (GameSession.currentSession.gg && GameSession.currentSession.gg.rat > 0 || GameSession.currentSession.catPause) 
				{
					noAct2 	  = gamePause;
					gamePause = true;
				}
				GameSession.currentSession.gc();
			} 
			else 
			{
				if (isSaveConf) 
				{
					GameSession.currentSession.saveConfig();
					isSaveConf = false;
				}
				vendor 	= null;
				npcId 	= '';
				GameSession.currentSession.ctr.clearAll();
				GameSession.currentSession.appearanceWindow.detach();
				if (GameSession.currentSession.gui) 
				{
					GameSession.currentSession.gui.dial.alpha 	 = 1;
					GameSession.currentSession.gui.inform.alpha = 1;
				}
				if (GameSession.currentSession.gg && GameSession.currentSession.gg.rat > 0) 
				{
					gamePause = noAct2;
				}
			}

			if (!light) 
			{
				GameSession.currentSession.gui.setEffects();
				vis.pr.visible = true;
			}
			setButtons();
			if (!light && GameSession.currentSession.room && !GameSession.currentSession.room.base) travel = false;
			supply(GameSession.currentSession && GameSession.currentSession.gg && GameSession.currentSession.gg.pipOff ? -1 : 1);
			GameSession.currentSession.ctr.keyPressed = false;
		}
		
		//коррекция размеров
		public function resizeScreen(nx:int, ny:int):void
		{
			if (nx >= 1200 && ny >= 800) 
			{
				if (nx > 1320) 
				{
					vis.x = (nx - visX) / 2 - 60;
					vis.y = (ny - visY) / 2;
				} 
				else 
				{
					vis.x = 0;
					vis.y = 0;
				}
				vis.scaleX = 1;
				vis.scaleY = 1;
			} 
			else 
			{
				vis.x = 0;
				vis.y = 0;

				if (nx / 1200 < ny / 800) 
				{
					vis.scaleX = nx / 1200;
					vis.scaleY = nx / 1200;
				} 
				else 
				{
					vis.scaleX = ny / 800;
					vis.scaleY = ny / 800;
				}
			}
		}
		
		//питание
		public function supply(turn:int=-1):void
		{
			if (turn < 0) 
			{
				currentPage.vis.visible = false;
				vis.toptext.visible 	= false;
				vis.pipError.visible 	= true;
				vis.pipError.objectName.text = Res.txt('pip', 'piperror');
				var s:String = Res.txt('pip', 'piperror', 1);
				vis.pipError.info.text = s.replace(/[\b\r\t]/g, '');
			} 
			else 
			{
				vis.pipError.visible = false;
			}
		}
		
		//режим показа
		public function setPage(p2:int = 0):void
		{
			if (!light) 
			{
				gg = GameSession.currentSession.gg;
				inv = GameSession.currentSession.invent;
				money = inv.money.kol;
				if (vendor) 
				{
					vendor.multPrice = GameSession.currentSession.pers.barterMult;
				}
			}
			for (var i in pages) 
			{
				if (pages[i] is PipPage) pages[i].vis.visible = false;
			}
			currentPage = pages[page];
			if (currentPage is PipPage) 
			{
				if (p2 > 0) currentPage.subCategory = p2;
				currentPage.setStatus();
			}
			if (!light) setRPanel();
			vishelp.visible = false;
		}
		
		public function assignKey(num:int):void
		{
			if (!active) return;
			if (currentPage is PipPageInv) (currentPage as PipPageInv).assignKey(num);
		}
		
		public function helpShow(event:MouseEvent):void
		{
			vishelp.txt.htmlText = helpText;
			vishelp.visible = true;
		}

		public function helpUnshow(event:MouseEvent):void
		{
			vishelp.visible = false;
		}

		public function massShow(event:MouseEvent):void
		{
			vishelp.txt.htmlText = massText;
			vishelp.visible = true;
		}

		public function massUnshow(event:MouseEvent):void
		{
			vishelp.visible = false;
		}
		
		public function allItems():void
		{
			// Creating arrays for the pipbuck to hold all armor sets and weapons.
			arrWeapon = [];
			arrArmor  = [];
			var owner:Unit = new Unit(); // Placeholder empty unit.

			var w:Weapon;
			var a:Armor;

			// Retreiving weapon and armor XML files from XmlBook.
			var weaponsXML:XML = XmlBook.getXML("weapons");
			var armorsXML:XML  = XmlBook.getXML("armors");

			for each (var weap in weaponsXML.weapon.(@tip > 0)) //Iterating through weapons and placing them in the weaponArray
			{
				try
				{
					w = Weapon.create(owner, weap.@id, 0);
					arrWeapon[weap.@id] = w;
					if (weap.char.length() > 1) 
					{
						w = Weapon.create(owner, weap.@id, 1);
						arrWeapon[weap.@id + '^' + 1] = w;
					}
				}
				catch(err:Error)
				{
					trace('PipBuck.as/allItems() - Error creating weapon: "' + weap.@id + '".');
				}
			}

			for each (var armor in armorsXML.armor) //Iterating through armor sets and placing them in the armorArray
			{
				try
				{
					a = new Armor(armor.@id);
					arrArmor[armor.@id] = a;
				}
				catch(err:Error)
				{
					trace('PipBuck.as/allItems() - Error creating armor: "' + armor.@id + '".');
				}
			}
		}
		
		public function setRPanel():void
		{
			if (light || !active) return;
			var gg:UnitPlayer = GameSession.currentSession.gg;
			var pers:Pers 	  = GameSession.currentSession.pers;
			ritem1(0, gg.hp, gg.maxhp);
			ritem1(1, pers.headHP,  pers.inMaxHP,   !GameSession.currentSession.game.triggers['nomed']);
			ritem1(2, pers.torsHP,  pers.inMaxHP,   !GameSession.currentSession.game.triggers['nomed']);
			ritem1(3, pers.legsHP,  pers.inMaxHP,   !GameSession.currentSession.game.triggers['nomed']);
			ritem1(4, pers.bloodHP, pers.inMaxHP,   !GameSession.currentSession.game.triggers['nomed']);
			ritem1(5, pers.manaHP,  pers.inMaxMana, !GameSession.currentSession.game.triggers['nomed']);

			if (gg.pet) ritem1(6, gg.pet.hp,gg.pet.maxhp);
			else ritem1(6, 0 ,0, false);

			if (gg.currentWeapon && gg.currentWeapon.tip <= 3) ritem2(7,gg.currentWeapon.hp,gg.currentWeapon.maxhp); 
			else ritem1(7, 0, 0, false);

			if (gg.currentArmor) ritem2(8, gg.currentArmor.hp, gg.currentArmor.maxhp); 
			else ritem1(8, 0, 0, false);

			ritems[9].txt.htmlText = "<span class = 'yel'>" + gg.invent.money.kol + "</span>"
			ritem3(10,inv.massW,pers.maxmW,    Settings.hardInv);
			ritem3(11,inv.massM,pers.maxmM,    Settings.hardInv);
			ritem3(12,inv.mass[1], pers.maxm1, Settings.hardInv);
			ritem3(13,inv.mass[2], pers.maxm2, Settings.hardInv);
			ritem3(14,inv.mass[3], pers.maxm3, Settings.hardInv);
		}
		
		public function ritem1(n:int, hp:Number, maxhp:Number, usl = true):void
		{
			ritems[n].visible = usl;

			if (usl) ritems[n].txt.htmlText="<span class = '" + med(hp, maxhp) + "'>" + Math.round(hp) + "</span>" + ' / ' + Math.round(maxhp);
			else ritems[n].txt.htmlText = '';

		}

		public function ritem2(n:int, hp:Number, maxhp:Number, usl = true):void
		{
			ritems[n].visible = usl;

			if (usl) ritems[n].txt.htmlText = "<span class = '" + med(hp, maxhp) + "'>" + Math.round(hp / maxhp*100) + "%</span>";
			else ritems[n].txt.htmlText = '';
		}

		public function ritem3(n:int, hp:Number, maxhp:Number, usl = true):void
		{
			ritems[n].visible = usl;

			if (usl) ritems[n].txt.htmlText="<span class='mass'><span class = '"+((hp>maxhp)?'red':'')+"'>"+Math.round(hp)+"</span>"+' / '+Math.round(maxhp)+"</span>";
			else ritems[n].txt.htmlText = '';
		}
		
		public function med(hp:Number, maxhp:Number):String
		{
			if (hp < maxhp * 0.25) return 'red';
			else if (hp < maxhp * 0.5) return 'or';
			return '';
		}
		
		public function setArmor(aid:String):void
		{
			ArmorId = aid;

			// Retrieve the entire XML file for armors
			var armorsXML:XML = XmlBook.getXML("armors");

			// Navigate to the correct XMLList of armor elements and filter by ID
			var armorXMLList:XMLList = armorsXML.armor.(@id == aid);

			if (armorXMLList.length() > 0) hideMane = armorXMLList[0].@hide;
			else hideMane = 0;
		}
		
		public function step():void
		{
			if (currentPage) currentPage.step();
		}
	}
}