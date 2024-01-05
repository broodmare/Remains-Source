package interdata 
{
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.StyleSheet;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;

	import fl.controls.ScrollBar;
	import fl.events.ScrollEvent;

	import unitdata.Invent;
	import unitdata.Pers;
	import unitdata.Unit;
	import unitdata.Armor;
	import unitdata.UnitPlayer;
	import locdata.Quest;
	import weapondata.Weapon;
	import servdata.Item;
	import servdata.LootGen;
	import locdata.LevelTemplate;
	import unitdata.UnitPet;
	
	import components.Settings;
	import components.XmlBook;

	import stubs.visPipInv;
	
	public class PipPage 
	{


		var vis:MovieClip;

		var arr:Array;
		var statArr:Array;
		var statHead:MovieClip;
		var pageClass:Class;
		var itemClass:Class;

		var maxrows:int = 18;
		var selItem:MovieClip;
		
		var pip:PipBuck;
		var inv:Invent;
		var gg:UnitPlayer;
		
		var isLC:Boolean = false;
		var isRC:Boolean = false; //реакция на клик
		
		var signs:Array = [0, 0, 0, 0, 0, 0];
		
		var page2:int = 1;
		var scrl:int = 0;
		
		var infIco:MovieClip;
		var itemFilter:GlowFilter 		= new GlowFilter(0x00FF88, 1, 3, 3, 3, 1);
		var itemTrans:ColorTransform 	= new ColorTransform(1, 1, 1);
		
		var pp:String; //pipPage
		
		var kolCats:int=6;
		var cat:Array=[0, 0, 0, 0, 0, 0, 0];
		var curTip = '';
		var tips:Array = [[]];
		
		//setStatItems - update all elements without reloading the page
		//setStatus - fully refresh the page"

		public function PipPage(npip:PipBuck, npp:String) 
		{
			
			pip = npip;
			
			pp = npp;
			if (pageClass == null) pageClass = visPipInv;
			vis = new pageClass();
			vis.x = 165;
			vis.y = 72;
			vis.visible = false;
			if (vis.pers) vis.pers.visible 	 = false
			if (vis.skill) vis.skill.visible = false;
			if (vis.item) vis.item.visible 	 = false
			pip.vis.addChild(vis);
			
			vis.scBar.addEventListener(ScrollEvent.SCROLL, statScroll);
			vis.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel1);
			statArr = [];
			var item:MovieClip;

			for (var i:int = -1; i < maxrows; i++) 
			{
				item = new itemClass(); 
				item.x = 30;
				item.y = 100 + i * 30;
				if (item.nazv) setStyle(item.nazv);
				vis.addChild(item);
				if (item.ramka) item.ramka.visible = false;
				if (i < 0) 
				{
					item.back.visible = false;
					statHead = item;
				} 
				else 
				{
					if (isLC) item.addEventListener(MouseEvent.CLICK,itemClick);
					if (isRC) item.addEventListener(MouseEvent.RIGHT_CLICK,itemRightClick);
					item.addEventListener(MouseEvent.MOUSE_OVER,statInfo);
					statArr.push(item);
				}
			}

			for (var j:int  = 1; j <= 5; j++)
			{
				item = vis.getChildByName('but' + j) as MovieClip;
				item.addEventListener(MouseEvent.CLICK, page2Click);
				item.text.text = Res.txt('pip', pp + j);
				item.id.text = j;
				item.id.visible = false;
			}

			vis.butOk.visible = false;
			vis.butDef.visible = false;
			if (vis.cats) vis.cats.visible = false;
			
			setStyle(vis.info);
			setStyle(vis.bottext);
		}
		
		//Text color definitions
		public static function setStyle(tt:TextField):void
		{
			var style:StyleSheet = new StyleSheet(); 
			var styleObj:Object = {};

			styleObj.color = "#00FF99"; 
			style.setStyle(".r0", styleObj); 	//по умолчанию зелёный
			
			styleObj.color = "#FF3333"; 
			style.setStyle(".red", styleObj);	//красный

			styleObj.color = "#FFFF33"; 
			style.setStyle(".yellow", styleObj);	//жёлтый

			styleObj.color = "#FF9900"; 
			style.setStyle(".or", styleObj);	//оранжевый

			styleObj.color = "#FC7FED"; 
			style.setStyle(".pink", styleObj);	//розовый

			styleObj.color = "#00FFFF"; 
			style.setStyle(".blue", styleObj);	//голубой

			styleObj.color = "#99CCFF"; 
			style.setStyle(".lightBlue", styleObj);	//серо-голубой

			styleObj.color = "#007E4B"; 
			style.setStyle(".dark", styleObj);	//7 - тёмно-зелёный

			styleObj.color = "#8AFFD0"; 
			style.setStyle(".light", styleObj);	//7 - светло-зелёный

			styleObj.color = "#33FF33"; 
			style.setStyle(".green", styleObj);	//зелёный

			styleObj.color = "#B466FF"; 
			style.setStyle(".purp", styleObj);	//фиолет

			tt.styleSheet = style;
		}

		//Print colored text
		public static function textAsColor(color:String, text:String):String
		{
			return "<span class = " + "'" + color + "'" + ">" + text + "</span>";
		}
		public static function numberAsColor(color:String, number:Number):String
		{
			return "<span class = " + "'" + color + "'" + ">" + number.toString() + "</span>";
		}
		
		public function updateLang():void
		{
			trace('PipPage.as/updateLang() - PipPage: "' + pp + '" updating button langauge.');
			for (var i:int = 1; i <= 5; i++) 
			{
				var item = vis.getChildByName('but' + i) as MovieClip;
				item.text.text = Res.txt('pip', pp + i);
			}
		}

		public function page2Click(event:MouseEvent):void
		{
			if (GameSession.currentSession.ctr.setkeyOn) return;
			page2 = int(event.currentTarget.id.text);
			setStatus();
			pip.snd(2);
		}
		
		public function setButtons():void
		{
			for (var i:int = 1; i <= 5; i++) 
			{
				var item:MovieClip = vis.getChildByName('but' + i) as MovieClip;

				if (page2 == i) item.gotoAndStop(2);
				else if (signs[i] > 0) item.gotoAndStop(signs[i] + 2);
				else item.gotoAndStop(1);
			}
		}
		
		public function setStatus(flop:Boolean = true):void
		{

			if (pip.reqKey != null) pip.reqKey = false;
			if (statHead.id != null) statHead.id.text = '';
			if (vis.visible != null) vis.visible = true;
			if (vis.info != null) vis.info.text = '';
			if (vis.nazv != null) vis.nazv.text = '';
			if (vis.bottext != null) vis.bottext.text = '';
			if (vis.emptytext != null) vis.emptytext.text = '';

			arr = [];

			if (flop) scrl = 0; // Reset scroll
			if (vis.scText) vis.scText.visible = false;
			
			gg = pip.gg;
			inv = pip.inv;

			pip.vis.toptext.visible = false;
			pip.vis.butHelp.visible = false;
			pip.vis.butMass.visible = false;
			pip.vishelp.visible 	= false;

			setSubPages();

			setStatItems(flop ? 0 : -1);

			var sc:ScrollBar = vis.scBar;

			if (arr.length > maxrows) 
			{
				sc.visible 			 = true;
				sc.minScrollPosition = 0
				sc.maxScrollPosition = arr.length - maxrows;
				sc.scrollPosition 	 = scrl;
			} 
			else 
			{
				sc.visible = false;
			}

			setSigns(); // Turn off all button highlights

			setButtons();
		}
		
		
		public function setSubPages():void // Preparation of pages
		{

		}
		
		public function setSigns():void // Which buttons are highlighted.
		{
			signs = [0, 0, 0, 0, 0, 0];
		}
		
		// Display of a single element
		public function setStatItem(item:MovieClip, obj:Object):void
		{

		}
		
		// Information about the element
		public function statInfo(event:MouseEvent):void
		{

		}
		
		public function itemClick(event:MouseEvent):void
		{

		}

		public function itemRightClick(event:MouseEvent):void
		{

		}
		
		// Show all elements
		public function setStatItems(n:int = -1):void
		{
			if (n >= 0) scrl = n;
			for (var i:int = 0; i < statArr.length; i++) 
			{
				if (i + scrl >= arr.length) 
				{
					statArr[i].visible = false;
				} 
				else 
				{
					statArr[i].visible = true;
					setStatItem(statArr[i], arr[i + scrl]);
				}
			}
		}
		
		public function setIco(tip:int = 0, id:String = ''):void
		{
			if (infIco && vis.ico.contains(infIco)) vis.ico.removeChild(infIco);
			vis.pers.visible = vis.skill.visible = false;
			vis.item.gotoAndStop(1);
			vis.info.y = vis.ico.y;
			if (tip == 1) //оружие
			{
				var w:Weapon=pip.arrWeapon[id];
				if (w.tip == 5) 
				{
					tip = 3;
					if (id.charAt(id.length - 2) == '^') id = id.substr(0, id.length - 2);
				} 
				else 
				{
					var vWeapon:Class = w.vWeapon;
					var nodeList:XMLList = XmlBook.getXML("weapons").weapon.(@id == id); //Create an XMLList of all nodes matching the given ID

					var node:XML = nodeList[0]; // Access the first (and presumably only) XML node in the list.
					if (node.vis.length() > 0 && node.vis[0].@vico.length() > 0) 
					{
						vWeapon = Res.getClass(node.vis[0].@vico, null);
					}

					if (vWeapon == null) 
					{
						vWeapon = Res.getClass('vis' + id, null);
					}
					if (vWeapon != null) 
					{
						infIco = new vWeapon();
						infIco.stop();
						if (infIco.lez) infIco.lez.stop();
						var r:Number = 1;
						if (node.length() && node.vis.length()) 
						{
							if (node.vis.@icomult.length()) 
							{
								r = infIco.scaleX = infIco.scaleY = node.vis.@icomult;
							}
						}
						infIco.x = -infIco.getRect(infIco).left * r + 140 - infIco.width / 2;
						infIco.y = -infIco.getRect(infIco).top;
						vis.ico.addChild(infIco);
						vis.info.y = vis.ico.y + vis.ico.height + 10;
						infIco.transform.colorTransform = itemTrans;
						infIco.filters = [itemFilter];
					}
				}
			}
			if (tip == 2) //бронька
			{
				pip.setArmor(id);
				vis.pers.gotoAndStop(2);
				vis.pers.gotoAndStop(1);
				vis.pers.head.morda.magic.visible = false;
				vis.pers.visible = true;
				vis.info.y = vis.pers.y + 25;
			}
			if (tip == 3) 
			{
				vis.item.visible = true;
				try 
				{
					vis.item.gotoAndStop(id);
					vis.info.y = vis.item.y+vis.item.height + 25;
				} 
				catch(err) 
				{
					vis.item.gotoAndStop(1);
					vis.item.visible = false;
					vis.info.y = vis.ico.y;
				}
			}
			if (tip == 5) //перки 
			{
				vis.skill.visible = true;
				try 
				{
					vis.skill.gotoAndStop(id);
					vis.info.y = vis.ico.y + 220;
				} 
				catch(err) 
				{
					vis.skill.visible = false;
					vis.info.y = vis.ico.y;
				}
			}
		}

		//добавить в текстовую строку значения
		public static function addVar(s:String, xml:XML):String 
		{
			for (var i:int = 1; i <= 5; i++) 
			{
				if (xml.attribute('s' + i).length())  s = s.replace('#' + i, "<span class='yel'>" + xml.attribute('s' + i) + "</span>");
			}
			return s;
		}
		
		public static function effStr(tip:String, id:String, dlvl:int = 0):String 
		{
			var s:String;
			if (tip == 'item') s = Res.txt('item', id, 1)
			else s = Res.txt('eff', id, 1);
			if (id.substr(-3) == '_ad') id=id.substr(0, id.length - 3);

			var dp = XmlBook.getXML(tip).skill.(@id == id);
			if (dp.length() == 0) return s;
			dp = dp[0];

			//определение текущего уровня
			var lvl = 1;
			var pers:Pers = GameSession.currentSession.pers;
			if (tip == 'perks')
			{
				lvl = pers.perks[id];
				if (lvl == null) lvl = 0;
			} 
			else if (tip == 'skills') 
			{
				lvl=pers.getSkLevel(pers.skills[id]);
			} 
			else if (dp.@him == '2') 
			{
				var ad = pers.addictions[id];
				if (ad >= pers.ad2) lvl = 2;
				if (ad >= pers.ad3) lvl = 3;
			} 
			else if (dp.@him == '1') lvl = pers.himLevel;

			lvl += dlvl;
			
			if (lvl > 1 && dp.textvar[lvl - 1]) s = addVar(s, dp.textvar[lvl-1]); //вставка в текст числовых значений
			else if (dp.textvar.length()) s = addVar(s, dp.textvar[0]);


			if (dp.eff.length() && lvl > 0) //добавление особых эффектов
			{
				s += '<br>';
				for each(var eff in dp.eff) 
				{
					s += '<br>' + (eff.@id.length() ? Res.txt('pip', eff.@id):Res.txt('pip', 'refeff')) + ': ' + textAsColor('yellow', eff.attribute('n' + lvl));
				}
			}
			
			if (Settings.hardInv && dp.sk.length()) // добавление эффектов веса
			{
				s += '<br>';
				for each(var sk in dp.sk) 
				{
					if (sk.@tip == 'm') 
					{
						var add = textAsColor('lightBlue', '+1');
						if (sk.@vd > 0) add = textAsColor('lightBlue', '+') + numberAsColor('lightBlue', sk.@vd) + ' ' + Res.txt('pip', 'perlevel');
						if (sk.@v1 > 0) add = textAsColor('lightBlue', '+') + numberAsColor('lightBlue', sk.@v1);
						s += '<br>' + Res.txt('pip', 'add_' + sk.@id)+' ' + add;
					}
				}
			}
			
			if (dp.req.length()) // добавление требований
			{
				s += '<br><br>' + Res.txt('pip', 'requir');
				lvl--;
				for each(var req in dp.req) 
				{
					var reqlevel:int = 1;
					if (req.@lvl.length()) reqlevel = req.@lvl;
					if (lvl > 0 && req.@dlvl.length()) reqlevel += lvl * req.@dlvl;
					var s1:String = '<br>';
					var ok:Boolean = true;
					if (req.@id == 'level') 
					{
						s1 += Res.txt('pip', 'level');
						if (pers.level<reqlevel) ok = false;
					} 
					else if (req.@id == 'guns') 
					{
						s1 += Res.txt('eff', 'smallguns') + ' ' + Res.txt('pip', 'or') + ' ' + Res.txt('eff', 'energy');
						if (pers.getSkLevel(pers.skills['smallguns']) < reqlevel && pers.getSkLevel(pers.skills['energy']) < reqlevel) ok = false;
					}
					else 
					{
						s1 += Res.txt('eff', req.@id);
						if (pers.getSkLevel(pers.skills[req.@id]) < reqlevel) ok = false;
					}
					s1 += ': ' + reqlevel;

					if (ok)	s += textAsColor('yellow', s1);
					else 	s += textAsColor('red', s1);
				}
			}
			return s;
		}
		
		
		public static function infoStr(tip:String, id:String):String 
		{
			var s:String = '';
			var pip:PipBuck = GameSession.currentSession.pip;
			var gg:UnitPlayer = GameSession.currentSession.gg;
			var inv:Invent=GameSession.currentSession.invent;
			if (tip == Item.L_ARMOR && inv.armors[id] == null && pip.arrArmor[id] == null) tip = Item.L_ITEM;
			if (tip == Item.L_WEAPON && inv.weapons[id] && inv.weapons[id].spell) tip = Item.L_ITEM;
			if (tip == Item.L_WEAPON || tip == Item.L_EXPL) 
			{
				var w:Weapon = pip.arrWeapon[id];
				if (w == null) return '';
				w.setPers(gg,gg.pers);
				var skillConf:int = 1;
				var razn:Number = w.lvl - gg.pers.getWeapLevel(w.skill);
				if (razn == 1) skillConf = 0.75;
				if (razn >= 2) skillConf = 0.5;
				w.skillConf = skillConf;
				s += Res.txt('pip', 'weapontip') + ': ' + textAsColor('yellow', Res.txt('pip', 'weapontip' + w.skill));
				if (w.lvl > 0) 
				{
					s += '\n' + Res.txt('pip', 'lvl') + ': ' + numberAsColor('yellow', w.lvl);
					s += '\n' + Res.txt('pip', 'islvl') + ': ' + numberAsColor('yellow', gg.pers.getWeapLevel(w.skill));
					if (razn > 0) s += "<span class = 'red'>";

					if (w.lvlNoUse && razn > 0 || razn > 2) s += ' (' + Res.txt('pip', 'weapnouse') + ')</span>';
					else if (razn > 0)
					{
						if (razn == 2) 
						{
							s += ' (-40% ';
						} 
						else if (razn == 1) 
						{
							s += ' (-20% ';
						}
						if (w.tip == 1) s += Res.txt('pip', 'rapid')
						else if (w.tip == 4) s += Res.txt('pip', 'distance');
						else s += Res.txt('pip', 'precision');

						s += ")</span>";
					}
				}
				if (w.perslvl > 0) 
				{
					s += '\n' + Res.txt('pip', 'perslvl') + ': ' + numberAsColor('yellow', w.perslvl);
					s += '\n' + Res.txt('pip', 'isperslvl') + ': ' + numberAsColor('yellow', gg.pers.level);
					if (gg.pers.level < w.perslvl) s += textAsColor('red', ' (' + Res.txt('pip', 'weapnouse') + ')');
				}
				s += '\n' + Res.txt('pip', 'damage') + ': ';
				var wdam:Number = w.damage, wdamexpl:Number = w.damageExpl;
				if (w.damage > 0) 
				{
					s += numberAsColor('yellow', Math.round(w.damage * 10) / 10);
					wdam = w.resultDamage(w.damage,gg.pers.weaponSkills[w.skill]);
					if (wdam != w.damage) 
					{
						s += ' (' + numberAsColor('yellow', Math.round(wdam * 10) / 10) + ')';
					}
				}
				if (w.damage > 0 && w.damageExpl > 0) s += ' + ';
				if (w.damageExpl > 0) 
				{
					s += numberAsColor('yellow', Math.round(w.damageExpl * w.damMult * 10) / 10);
					wdamexpl = w.resultDamage(w.damageExpl, gg.pers.weaponSkills[w.skill]);
					if (wdamexpl!=w.damageExpl) 
					{
						s += ' (' + numberAsColor('yellow', Math.round(wdamexpl * 10) / 10) + ')';
					}
					s += ' ' + Res.txt('pip', 'expldam');
				}
				if (w.kol > 1) s += ' [x' + w.kol + ']';
				if (w.explKol > 1) s+= ' [x' + w.explKol + ']';
				var wrapid:Number = w.resultRapid(w.rapid);
				if (w.tip != 4) 
				{
					s += '\n'+Res.txt('pip', 'aps') + ': ' + textAsColor('yellow', Number(Settings.fps / wrapid).toFixed(1));
					s += '\n'+Res.txt('pip', 'dps') + ': ' + textAsColor('yellow', Number((wdam + wdamexpl) * w.kol * Settings.fps / wrapid).toFixed(1));
					if (w.holder) s += ' (' + textAsColor('yellow', Number((wdam + wdamexpl) * w.kol * Settings.fps / (wrapid + w.reload * w.reloadMult / w.holder * w.rashod)).toFixed(1)) + ')';
				}
				s += '\n' + Res.txt('pip', 'critch') + ': ' + textAsColor('yellow', Math.round((w.critCh + w.critchAdd + gg.critCh) * 100) + '%');
				s += '\n' + Res.txt('pip', 'tipdam') + ': ' + textAsColor('blue', Res.txt('pip', 'tipdam' + w.tipDamage));
				if (w.tip < 4 && w.holder > 0) s += '\n' + Res.txt('pip', 'inv5') + ': ' + textAsColor('yellow', Res.txt('item', w.ammo));
				if (w.tip < 4 && w.holder > 0) s += '\n' + Res.txt('pip', 'holder') + ': ' + numberAsColor('yellow', w.holder);
				if (w.rashod> 1 ) s += ' (' + numberAsColor('yellow', w.rashod) + ' ' + Res.txt('pip', 'rashod') + ')';
				if (w.tip == 5) s += '\n' + Res.txt('pip', 'dmana') + ': ' + numberAsColor('yellow', Math.round(w.mana));
				if (w.precision > 0) s +='\n' + Res.txt('pip', 'prec') + ': ' + numberAsColor('yellow', Math.round(w.precision * w.precMult / 40));
				if (w.pier+w.pierAdd > 0) s +='\n' + Res.txt('pip', 'pier') + ': ' + numberAsColor('yellow', Math.round(w.pier + w.pierAdd));
				if (!w.noSats)
				{
					s+='\n'+Res.txt('pip', 'ap')+': ';
					if (razn>0) s+="<span class = 'red'>";
					else s+="<span class = 'yel'>";
					s+=Math.round(w.satsCons*w.consMult/skillConf*gg.pers.satsMult);
					s+="</span>";
					if (w.satsQue>1) s+=' (x' + numberAsColor('yellow', w.satsQue) + ')';
				}
				if (w.destroy >= 100) 
				{
					s += '\n' + Res.txt('pip', 'destroy');
				}
				if (w.opt && w.opt.perk) 
				{
					s += '\n' + Res.txt('pip', 'refperk') + ': ' + textAsColor('pink', Res.txt('eff', w.opt.perk));
				}
				var sinf:String = Res.txt('weapon', id, 1);
				if (sinf == '') sinf = Res.txt('weapon', w.id, 1);
				if (Settings.hardInv && w.tip < 4) s += '\n' + Res.txt('pip', 'mass2') + ": <span class = 'mass'>" + w.mass + "</span>";
				if (Settings.hardInv && w.tip == 4) s += '\n\n' + Res.txt('pip', 'mass') + ": <span class = 'mass'>" + inv.items[id].xml.@m + "</span> (" + Res.txt('pip', 'vault' + inv.items[id].invCat) + ')';
				s += '\n\n' + sinf;
			} 
			else if (tip == Item.L_ARMOR) 
			{
				var a:Armor = inv.armors[id];
				if (a == null) a = pip.arrArmor[id];

				//TODO: I think I uncolored the % symbols.
				if (a.armor_qual > 0) s += Res.txt('pip', 'aqual')+': ' + numberAsColor('yellow', Math.round(a.armor_qual * 100)) + '%';
				if (a.armor > 0) s += '\n' + Res.txt('pip', 'armor')+': ' + numberAsColor('yellow', Math.round(a.armor));
				if (a.marmor > 0) s += '\n' + Res.txt('pip', 'marmor')+': ' + numberAsColor('yellow', Math.round(a.marmor));
				if (a.dexter != 0) s += '\n' + Res.txt('pip', 'dexter')+': ' + numberAsColor('yellow', Math.round(a.dexter * 100)) + '%';
				if (a.sneak != 0) s += '\n' + Res.txt('pip', 'sneak')+': ' + numberAsColor('yellow', Math.round(a.sneak * 100)) + '%';
				if (a.meleeMult != 1) s += '\n' + Res.txt('pip', 'meleedamage') + ': +' + numberAsColor('yellow', Math.round((a.meleeMult - 1) * 100)) + '%';
				if (a.gunsMult != 1) s += '\n' + Res.txt('pip', 'gunsdamage') + ': +' + numberAsColor('yellow', Math.round((a.gunsMult-1) * 100)) + '%';
				if (a.magicMult != 1) s += '\n' + Res.txt('pip', 'spelldamage') + ': +' + numberAsColor('yellow', Math.round((a.magicMult-1) * 100)) + '%';
				if (a.crit!=0) s += '\n' + Res.txt('pip', 'critch')+': +' + numberAsColor('yellow', Math.round(a.crit * 100)) + '%';
				if (a.radVul<1) s += '\n' + Res.txt('pip', 'radx')+': ' + numberAsColor('yellow', Math.round((1 - a.radVul) * 100)) + '%';

				// Print armor resistances as a percentage in yellow text if the resistance is not 0.
				var resistanceTypesArray:Array = 
				[
					{key: 'D_BUL', label: 'bullet'}, {key: 'D_EXPL', label: 'expl'}, {key: 'D_PHIS', label: 'phis'}, {key: 'D_BLADE', label: 'blade'},  {key: 'D_FANG', label: 'fang'}, 
					{key: 'D_FIRE', label: 'fire'}, {key: 'D_LASER', label: 'laser'}, {key: 'D_PLASMA', label: 'plasma'},  {key: 'D_SPARK', label: 'spark'}, {key: 'D_CRIO', label: 'crio'}, 
					{key: 'D_VENOM', label: 'venom'}, {key: 'D_ACID', label: 'acid'},  {key: 'D_NECRO', label: 'necro'}
				];
				for each (var resistanceType:Object in resistanceTypesArray)
				{
					var resistanceValue:int = Unit[resistanceType.key];
					var resistanceLabel:String = resistanceType.label;

					if (a.resist[resistanceValue] != 0 && a.resist[resistanceValue] != null) 
					{
						s += '\n' + Res.txt('pip', resistanceLabel) + ': ' + numberAsColor('yellow', Math.round(a.resist[resistanceValue] * 100)) + '%';
					}
				}

				s += '\n\n' + Res.txt('armor', id, 1); // Armor description.
			} 
			else if (tip == Item.L_AMMO) 
			{
				var ammo:XML = inv.items[id].xml;

				if (XmlBook.getXML("weapons").weapon.(@id == id).length()) 
				{
					s = Res.txt('weapon', id, 1);
				} 
				else if (ammo.@base.length()) 
				{
					s = Res.txt('item', ammo.@base, 1);
					if (ammo.@mod > 0) 
					{
						s += '\n\n' + Res.txt('pip', 'ammomod_' + ammo.@mod, 1);
					}
				} 
				else 
				{
					s = Res.txt('item', id, 1);
				}

				s += '\n';
				if (ammo.@damage.length()) s+='\n'+Res.txt('pip', 'damage')+': x' + textAsColor('yellow', ammo.@damage);
				if (ammo.@pier.length()) s+='\n'+Res.txt('pip', 'pier')+': ' + textAsColor('yellow', ammo.@pier);
				if (ammo.@armor.length()) s+='\n'+Res.txt('pip', 'tarmor')+': x' + textAsColor('yellow', ammo.@armor);
				if (ammo.@prec.length()) s+='\n'+Res.txt('pip', 'prec')+': x' + textAsColor('yellow', ammo.@prec);
				if (ammo.@det>0) s+='\n'+Res.txt('pip', 'det');
				if (Settings.hardInv && ammo.@m>0) s+='\n\n'+Res.txt('pip', 'mass')+": <span class = 'mass'>"+ammo.@m+"</span> ("+Res.txt('pip', 'vault'+inv.items[id].invCat)+')';
				if (ammo.@sell > 0) s += '\n' + Res.txt('pip', 'sell') + ": " + textAsColor('yellow', ammo.@sell);
			} 
			else 
			{
				var hhp:Number = 0;
				s = Res.txt('items', id, 1) + '\n';
				var pot:XML = inv.items[id].xml;
				tip = pot.@tip;
				if (tip == 'instr' || tip == 'impl'|| tip == 'art') 
				{
					s = effStr('items', id) + '\n';
				}
				if (tip == 'med' || tip == 'food'|| tip == 'pot' || tip == 'him') 
				{
					if (pot.@hhp.length() || pot.@hhplong.length())
					s += '\n'+Res.txt('pip', 'healhp') + ': ' + numberAsColor('yellow', Math.round(pot.@hhp * GameSession.currentSession.pers.healMult));
					if (pot.@hhplong.length()) 	s += '+' + numberAsColor('yellow', Math.round(pot.@hhplong * GameSession.currentSession.pers.healMult));
					if (pot.@hrad.length()) 	s += '\n' + Res.txt('pip', 'healrad') 	 + ': ' + numberAsColor('yellow', Math.round(pot.@hrad * GameSession.currentSession.pers.healMult));
					if (pot.@hcut.length()) 	s += '\n' + Res.txt('pip', 'healcut') 	 + ': ' + numberAsColor('yellow', Math.round(pot.@hcut));
					if (pot.@hpoison.length()) 	s += '\n' + Res.txt('pip', 'healpoison') + ': ' + numberAsColor('yellow', Math.round(pot.@hpoison));
					if (pot.@horgan.length()) 	s += '\n' + Res.txt('pip', 'healorgan')  + ': ' + numberAsColor('yellow', Math.round(pot.@horgan));
					if (pot.@horgans.length()) 	s += '\n' + Res.txt('pip', 'healorgans') + ': ' + numberAsColor('yellow', Math.round(pot.@horgans));
					if (pot.@hblood.length()) 	s += '\n' + Res.txt('pip', 'healblood')  + ': ' + numberAsColor('yellow', Math.round(pot.@hblood));
					if (pot.@hmana.length()) 	s += '\n' + Res.txt('pip', 'healmana') 	 + ': ' + numberAsColor('yellow', Math.round(pot.@hmana * GameSession.currentSession.pers.healManaMult));
					if (pot.@alc.length()) 		s += '\n' + Res.txt('pip', 'alcohol') 	 + ': ' + numberAsColor('yellow', Math.round(pot.@alc));
					if (pot.@rad.length()) 		s += '\n' + Res.txt('pip', 'rad') 		 + ': ' + numberAsColor('yellow', Math.round(pot.@rad));
					if (pot.@effect.length()) 	s += '\n' + Res.txt('pip', 'refeff') + ': '+effStr('eff',pot.@effect);
					if (pot.@perk.length()) 	s += '\n' + textAsColor('pink', Res.txt('eff',pot.@perk))+': '+Res.txt('pip', 'level')+' '+(GameSession.currentSession.pers.perks[pot.@perk]>0?GameSession.currentSession.pers.perks[pot.@perk]:'0');
					if (pot.@maxperk.length()) 	s += '/' + pot.@maxperk;
				}
				if (tip=='book') 
				{
					if (GameSession.currentSession.pers.skills[id]!=null) s+='\n'+Res.txt('pip', 'skillup')+': ' + textAsColor('pink', Res.txt('eff',id));
				}
				if (tip=='spell') 
				{
					s += '\n' + Res.txt('pip', 'dmana2') + ': ' + textAsColor('yellow', pot.@mana)+' (' + numberAsColor('yellow', Math.round(pot.@mana * GameSession.currentSession.pers.allDManaMult)) + ')';
					s += '\n' + Res.txt('pip',   'culd') + ': ' + textAsColor('yellow', pot.@culd + Res.txt('gui', 'sec'))+' (' + numberAsColor('yellow', Math.round(pot.@culd*GameSession.currentSession.pers.spellDown)) + Res.txt('gui', 'sec') + ')';
					s += '\n' + Res.txt('pip',    'is1') + ': ' + textAsColor('pink', (pot.@tele > 0) ? Res.txt('eff', 'tele') : Res.txt('eff', 'magic'));
				}
				if (id=='rep') 
				{
					if (pot.@hp.length()) hhp=pot.@hp*gg.pers.repairMult;
					if (hhp>0) s+='\n'+Res.txt('pip', 'effect')+': ' + numberAsColor('yellow', Math.round(hhp));
				}
				if (pot.@pet_info.length()) 
				{
					var pet:UnitPet=gg.pets[pot.@pet_info];
					if (pet) 
					{
						s+='\n'+Res.txt('pip', 'hp')+': ' + numberAsColor('yellow', Math.round(pet.hp)) + '/' + numberAsColor('yellow', Math.round(pet.maxhp));
						s+='\n'+Res.txt('pip', 'skin')+': ' + numberAsColor('yellow', Math.round(pet.skin));
						if (pet.allVulnerMult<1) s+='\n'+Res.txt('pip', 'allresist') + ': ' + numberAsColor('yellow', Math.round((1 - pet.allVulnerMult) * 100)) + '%';
						s+='\n'+Res.txt('pip', 'damage')+': ' + numberAsColor('yellow', Math.round(pet.dam));
					}
				}
				if (tip=='paint') s=Res.txt('pip','paint',1);
				if (Settings.hardInv && pot.@m>0) s+='\n\n'+Res.txt('pip', 'mass')+": <span class = 'mass'>"+pot.@m+"</span> ("+Res.txt('pip', 'vault'+inv.items[id].invCat)+')';
				if (pot.@sell>0) s+='\n'+Res.txt('pip', 'sell')+": " + textAsColor('yellow', pot.@sell);
			}
			return s;
		}
		
		public function infoItem(tip:String, id:String, objectName:String, craft:int=0):void
		{
			vis.nazv.text = objectName;
			var s:String = '';
			if (id.substr(0, 2) == 's_') 
			{
				id = id.substr(2);
				craft = 1;
				if (XmlBook.getXML("weapons").weapon.(@id == id).length()) tip = Item.L_WEAPON;
				else if (XmlBook.getXML("armors").armor.(@id == id).length()) tip = Item.L_ARMOR;
				else tip = Item.L_ITEM;
			}

			if (tip == Item.L_WEAPON || tip == Item.L_EXPL) 
			{
				if (craft > 0) setIco();
				else setIco(1,id);
				s = infoStr(tip, id);
				if (craft==1) s += craftInfo(id);
				if (craft==2) s += craftInfo(id.substr(0, id.length - 2));
			} 
			else if (tip==Item.L_ARMOR) 
			{
				var a:Armor=inv.armors[id];
				if (a == null) a = pip.arrArmor[id];
				
				if (craft > 0) setIco();
				else if (a.tip == 3) setIco(3, id);
				else setIco(2, id);

				s = infoStr(tip, id);
				if (craft==2) 
				{
					var cid:String=a.idComp;
					var kolcomp:int=a.needComp();
					s+="\n\n<span class = 'or'>"+Res.txt('item',cid)+ " - "+kolcomp+" <span ";
					if (!GameSession.currentSession.room.base && kolcomp>inv.items[cid].kol || GameSession.currentSession.room.base && kolcomp>inv.items[cid].kol+inv.items[cid].vault) s+="class='red'"
					s+="> ("+inv.items[cid].kol;
					if (GameSession.currentSession.room.base && inv.items[cid].vault>0) s+=' +'+inv.items[cid].vault;
					s+=")</span></span>";
				}
				if (craft==1) s+=craftInfo(id);
			} 
			else if (tip == Item.L_AMMO) 
			{
				var ammo = inv.items[id].xml;
				if (ammo.@base.length()) 
				{
					vis.nazv.text = Res.txt('item',ammo.@base);
					if (ammo.@mod>0) 
					{
						vis.nazv.text += '\n' + Res.txt('pip', 'ammomod_' + ammo.@mod);
					} 
					else 
					{
						vis.nazv.text += '\n' + Res.txt('pip', 'ammomod_0');
					}
				}
				setIco();
				s = infoStr(tip, id);
			} 
			else 
			{
				if (craft>0) setIco();
				else setIco(3,id);
				s=infoStr(tip, id);
				if (craft==1) s+=craftInfo(id);
			}

			vis.info.htmlText=s;
			vis.info.height=680-vis.info.y;
			vis.info.scaleX=vis.info.scaleY=1;
			if (vis.scText) vis.scText.visible=false;
			if (vis.info.height<vis.info.textHeight && vis.scText) 
			{
				vis.scText.maxScrollPosition=vis.info.maxScrollV;
				vis.scText.visible=true;
			}
		}
		
		public function craftInfo(id:String):String 
		{
			var s:String='\n';
			var sch = XmlBook.getXML("items").item.(@id == 's_' + id);
			if (sch.length()) sch=sch[0];
			else return '';
			var kol:int=1;
			if (sch.@kol.length()) kol=sch.@kol;
			if (sch.@perk=='potmaster' && gg.pers.potmaster) kol*=2;
			if (kol>1) s+=Res.txt('pip', 'crekol')+": "+kol+"\n";
			if (sch.@skill.length() && sch.@lvl.length()) {
				s+="\n"+Res.txt('pip', 'needskill')+": <span class = '";
				if (gg.pers.getSkillLevel(sch.@skill)<sch.@lvl) s+="red";
				else s+="pink";
				s+="'>"+Res.txt('eff',sch.@skill)+" - "+sch.@lvl+"</span>\n";
			}
			for each(var c in sch.craft) 
			{
				s+="\n<span class = 'or'>"+Res.txt('item',c.@id)+ " - "+c.@kol+" <span ";
				if (!GameSession.currentSession.room.base && c.@kol>inv.items[c.@id].kol
				  || GameSession.currentSession.room.base && c.@kol>inv.items[c.@id].kol+inv.items[c.@id].vault) s+="class='red'";
				s+=">("+inv.items[c.@id].kol;
				if (GameSession.currentSession.room.base && inv.items[c.@id].vault>0) s+=' +'+inv.items[c.@id].vault;
				s+=")</span></span>";
			}
			return s;
		}
		
		public function infoQuest(id:String):String 
		{
				var q:Quest=GameSession.currentSession.game.quests[id];
				if (q==null) return '';
				vis.nazv.text=q.objectName;
				var s:String=q.info;
				if (q.empl) s+='<br><br>'+Res.txt('unit',q.empl);
				s+='\n';
				var n:int=1;
				for each(var st:Quest in q.subs) 
				{
					if (st.invis && st.state<2) continue;
					s+="\n";
					if (st.state==2) s+="<span class = 'dark'>";
					s += textAsColor('yellow', n + '.') + " "
					if (st.hidden && st.state < 2 && st.est <= 0) s += '?????';
					else s+=st.objectName;
					if (st.collect && st.colTip==0) 
					{
						if (st.give) 
						{
							s += ' (' + textAsColor('yellow', st.gived + '/' + st.kol) + ')';
							if (st.est > 0 && st.state < 2) s += ' (' + textAsColor('yellow', '+' + st.est) + ')';
						} 
						else s += ' (' + textAsColor('yellow', st.est + '/' + st.kol) + ')';
					}
					if (st.nn) s += ' (' + Res.txt('pip', 'nn') + ')';
					if (st.state==2) s += "</span>";
					n++;
				}
				return s;
		}
		
		public function factor(id:String):String 
		{
			var lines:Array = [];
			var s1:String;
			var ok:Boolean = false;
			
			var xml = XmlBook.getXML("parameters").param.(@v == id);
			var xmlTip:String = xml.@tip;
			
			if (GameSession.currentSession.pers.factor[id] is Array) 
			{
				if (xmlTip == '4') lines.push('- ' + Res.txt('pip', 'begvulner') + ': ' + textAsColor('yellow', '100%'));
				
				for each (var obj in GameSession.currentSession.pers.factor[id]) 
				{
					var line:String = '- ';
					
					if (obj.id == 'beg') 
					{
						if (xml.@nobeg > 0) continue;
						
						line += handleBeg(obj, xmlTip);
					} 
					else 
					{
						if ((obj.ref == 'add' && obj.val == 0) || (obj.ref == 'mult' && obj.val == 1)) continue;
						
						ok = true;
						line += handleOther(obj, xmlTip);
					}
					
					lines.push(line);
				}
				
				if (obj && (xmlTip == '3' || xmlTip == '4')) 
				{
					lines.push('- ' + Res.txt('pip', 'result') + ': 100% - ' + textAsColor('yellow', Res.numb(obj.res * 100) + '%') + ' = ' + textAsColor('yellow', Res.numb((1 - obj.res) * 100) + '%'));
				}
			}
			
			if (ok) 
			{
				lines.unshift(Res.txt('pip', 'factor') + ':');
				return lines.join('\n');
			}
			
			return '';
		}

		private function handleBeg(obj:Object, xmlTip:String):String 
		{
			var s:String = '';
			if (xmlTip == '0') 
			{
				if (obj.res != 0) s = Res.txt('pip', 'begval') + ': ' + textAsColor('yellow', Res.numb(obj.res));
			} 
			else if (xmlTip == '3') 
			{
				s = Res.txt('pip', 'begvulner') + ': ' + textAsColor('yellow', Res.numb(obj.res * 100) + '%');
			} 
			else 
			{
				s = Res.txt('pip', 'begval') + ': ' + textAsColor('yellow', Res.numb(obj.res * 100) + '%');
			}
			return s;
		}

		private function handleOther(obj:Object, xmlTip:String):String 
		{
			var s1:String, s:String = '';
			if (obj.tip != null) s1 = Res.txt(obj.tip, obj.id);
			else if (Res.istxt('eff', obj.id)) s1 = Res.txt('eff', obj.id);
			else if (Res.istxt('item', obj.id)) s1 = Res.txt('item', obj.id);
			else if (Res.istxt('armor', obj.id)) s1 = Res.txt('armor', obj.id);
			else s1 = '???';
			
			if (s1.substr(0, 6) == '*eff_f') s1 = Res.txt('eff', 'food');
			s += s1 + ': ';
			
			if (obj.ref == 'add') 
			{
				s += handleAdd(obj, xmlTip);
			} 
			else if (obj.ref == 'mult') 
			{
				s += handleMult(obj, xmlTip);
			} 
			else if (obj.ref == 'min') 
			{
				s += handleMin(obj, xmlTip);
			} 
			else 
			{
				s += handleElse(obj, xmlTip);
			}
			return s;
		}

		private function handleAdd(obj:Object, xmlTip:String):String 
		{
			var s:String = (obj.val > 0 ? '+' : '-') + ' ' + numberAsColor('yellow', Math.abs(obj.val));
			if (xmlTip != '0') 
			{
				s = (obj.val > 0 ? '+' : '-') + ' ' + textAsColor('yellow', Res.numb(Math.abs(obj.val * 100)) + '%');
				s += ' = ' + textAsColor('yellow', Res.numb(obj.res * 100) + '%');
			}
			return s;
		}

		private function handleMult(obj:Object, xmlTip:String):String 
		{
			var s:String = 'x ' + textAsColor('yellow', obj.val);
			if (xmlTip == '0') 
			{
				s += ' = ' + textAsColor('yellow', Res.numb(obj.res));
			} 
			else if (xmlTip == '3' || xmlTip == '4') 
			{
				s += 'x (1 ' + (obj.val < 1 ? '-' : '+') + ' ' + numberAsColor('yellow', Math.abs(Math.round(100 - obj.val * 100)) * 0.01) + ')';
				s += ' = ' + textAsColor('yellow', Res.numb(obj.res * 100) + '%');
			} 
			else 
			{
				s += ' = ' + textAsColor('yellow', Res.numb(obj.res * 100) + '%');
			}
			return s;
		}

		private function handleMin(obj:Object, xmlTip:String):String 
		{
			var s:String = '- ' + textAsColor('yellow', Res.numb(Math.abs(obj.val * 100)) + '%');
			s += ' = ' + textAsColor('yellow', Res.numb((obj.res) * 100) + '%');
			return s;
		}

		private function handleElse(obj:Object, xmlTip:String):String 
		{
			var s:String = (xmlTip == '0') ? textAsColor('yellow', obj.val) : textAsColor('yellow', Res.numb(obj.val * 100) + '%');
			return s;
		}
				
				public function setTopText(s:String=''):void
				{
					if (s == '') 
					{
						pip.vis.toptext.visible=false;
					} 
					else 
					{
						pip.vis.toptext.visible=true;
						var ins:String=Res.txt('pip',s,0,true);
						var myPattern:RegExp = /@/g; 
						pip.vis.toptext.txt.htmlText=ins.replace(myPattern,'\n');
					}
				}
				
		//проверка квеста на доступность
		public function checkQuest(task:XML):Boolean 
		{
			//проверка на доступ к местности
			if (task.@level.length()) 
			{
				var level:LevelTemplate=GameSession.currentSession.game.levelArray[task.@level];
				if (level==null) return false;
				if (!level.access && !level.visited && GameSession.currentSession.pers.level<level.dif) return false;
			}
			//проверка триггера
			if (task.@trigger.length()) 
			{
				if (GameSession.currentSession.game.triggers[task.@trigger]!=1) return false;
			}
			//проверка скилла
			if (task.@skill.length() && task.@skilln.length()) 
			{
				if (GameSession.currentSession.pers.skills[task.@skill]<task.@skilln) return false;
			}
			return true;
		}
		
		public function initCats():void
		{
			for (var i:int = 0; i<=kolCats; i++) 
			{
				vis.cats['cat'+i].addEventListener(MouseEvent.CLICK,selCatEvent);
			}
			selCat();
		}
		
		//установить кнопки категорий
		public function setCats():void
		{
			var arr = tips[page2];
			if (arr == null) 
			{
				vis.cats.visible = false;
				return;
			}
			vis.cats.visible=true;
			var ntip;
			for (var i=0; i<=kolCats; i++) 
			{
				ntip=arr[i];
				if (ntip==null) vis.cats['cat'+i].visible=false;
				else 
				{
					if (ntip is Array) ntip=ntip[0];
					vis.cats['cat'+i].visible=true;
					try 
					{
						vis.cats['cat'+i].ico.gotoAndStop(ntip);
					} 
					catch (err) 
					{
						vis.cats['cat'+i].ico.gotoAndStop(1);
					}
				}
			}
			selCat(cat[page2]);
		}

		//выбор подкатегории инвентаря
		public function selCatEvent(event:MouseEvent):void
		{
			var n:int = int(event.currentTarget.name.substr(3));
			cat[page2] = n;
			setStatus();
		}
		
		public function selCat(n:int=0):void
		{
			for (var i:int = 0; i<= kolCats; i++) 
			{
				vis.cats['cat'+i].fon.gotoAndStop(1);
			}
			vis.cats['cat'+n].fon.gotoAndStop(2);
			try 
			{
				curTip=tips[page2][n];
			} 
			catch (err) 
			{
				curTip = '';
			}
			if (curTip == null) curTip = '';
		}
		
		//проверить соответствии категории
		public function checkCat(tip:String):Boolean 
		{
			if (curTip == '' || curTip == null || curTip == tip) return true;
			if (curTip is Array) 
			{
				for each (var t in curTip) if (t == tip) return true;
			}
			return false;
		}
		
		public function statScroll(event:ScrollEvent):void
		{
			setStatItems(event.position);
		}

		public function onMouseWheel1(event:MouseEvent):void 
		{
			if (GameSession.currentSession.ctr.setkeyOn) return;
			if (vis.scText && vis.scText.visible && vis.mouseX>vis.info.x) return;

			scroll(event.delta);
			if (!vis.scBar.visible) return;
			if (event.delta < 0) (event.currentTarget as MovieClip).scBar.scrollPosition++;
			if (event.delta > 0) (event.currentTarget as MovieClip).scBar.scrollPosition--;
			event.stopPropagation();
		}

		public function scroll(dn:int=0):void
		{

		}
		
		public function step():void
		{

		}
	}
}