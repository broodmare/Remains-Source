﻿package interdata 
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	import unitdata.Unit;
	import unitdata.Effect;
	import unitdata.Pers;
	
	import components.Settings;
	import components.XmlBook;
	
	import stubs.visPipStatItem;
	
	//	sub-category cheat-sheet
	//	1 - Main
	//	2 - Skills
	//	3 - Perks
	//	4 - Effects
	//	5 - Health

	public class PipPageStat extends PipPage //This category is called "Status" in-game.
	{
		
		var pers:Pers;
		var skills:Array;
		var maxSkLvl:int 		= 20;
		var skillPoint:int 		= 0;
		var perkPoint:int 		= 0;
		var selectedPerk:String = '';
		var infoItemId:String 	= '';
		var n_food:String;
		var drunk:int 			= 0;

		public function PipPageStat(npip:PipBuck, npp:String) 
		{
			isLC = true;
			isRC = true;
			itemClass = visPipStatItem;
			skills = [];
			super(npip,npp);
			vis.butOk.addEventListener(MouseEvent.CLICK,  transOk);
			vis.butDef.addEventListener(MouseEvent.CLICK, gotoDef);
			n_food = Res.txt('eff', 'food');
		}
		
		//подготовка страниц
		public override function setSubPages():void
		{
			setIco();
			pers = GameSession.currentSession.pers;
			maxSkLvl = Pers.maxSkLvl;
			statHead.progress.visible = false;
			statHead.hpbar.visible=statHead.cat.visible = false;
			statHead.numb.x = 335;
			vis.butOk.visible = false;
			vis.butDef.visible = false;
			drunk = 0;
			if (subCategory == 1) 
			{
				statHead.nazv.text = '';
				statHead.numb.text = '';
				arr.push({objectName:Res.txt('pip', 'name'), lvl:gg.pers.persName});
				arr.push({objectName:Res.txt('pip', 'level'), lvl:gg.pers.level});
				arr.push({objectName:Res.txt('pip', 'expa'), lvl:gg.pers.xpCur+' ('+(gg.pers.xpNext-gg.pers.xpCur)+')'});
				arr.push({id:'diff', objectName:Res.txt('pip', 'diff'), lvl:Res.txt('gui', 'dif'+GameSession.currentSession.game.globalDif)});
				arr.push({id:'reput', objectName:Res.txt('pip', 'reput'), lvl:(gg.pers.rep+' ('+gg.pers.repTex()+')')});
				var arm:String = '';
				
				for (var i = 0; i < XmlBook.getXML("parameters").param.length(); i++) 
				{
    				var xml = XmlBook.getXML("parameters").param[i];
					if (xml.@show>0) 
					{
						if (xml.@show=='2' && gg.armor==0 && gg.marmor==0) continue;
						if (xml.@show=='3' && (!GameSession.currentSession.game.triggers['story_canter']>0)) continue;
						var objectName=Res.txt('pip', xml.@id);
						if (xml.@v!='') objectName='-  '+objectName;
						else 
						{
							arr.push({id:xml.@id, objectName:objectName, lvl:''});
							continue;
						}
						var param;

						if (xml.@tip == '4') param=gg.vulner[xml.@v];
						else if (gg.hasOwnProperty(xml.@v)) param = gg[xml.@v];
						else if (gg.pers.hasOwnProperty(xml.@v)) param = gg.pers[xml.@v];
						else 
						{
							trace('нет переменной', xml.@v);
							continue;
						}

						if (xml.@tip == '0') 
						{
							if (param>0) arr.push({id:xml.@id, objectName:objectName, lvl:Res.numb(param)});
						}
						if (xml.@tip == '1') 
						{
							if (param!=1 || GameSession.currentSession.pers.factor[xml.@v] && GameSession.currentSession.pers.factor[xml.@v].length > 1) arr.push({id:xml.@id, objectName:objectName, lvl:((param>=1?'+':'')+Res.numb((param-1)*100)+'%')});
						}
						if (xml.@tip == '2') 
						{
							arr.push({id:xml.@id, objectName:objectName, lvl:(Res.numb(param*100)+'%')});
						}
						if (xml.@tip=='3' || xml.@tip=='4') 
						{
							if (param!=1) arr.push({id:xml.@id, objectName:objectName, lvl:((param<1?'+':'')+Res.numb((1-param)*100)+'%')});
						}
					}
				}
			} 
			else if (subCategory == 5) 
			{
				if (GameSession.currentSession.game.triggers['nomed']>0) 
				{
					vis.emptytext.text=Res.txt('pip', 'emptymed');
					statHead.visible=false;
					return;
				}
				else 
				{
					vis.emptytext.text='';
					statHead.visible=true;
				}
				gg.pers.checkHP();
				setTopText('usemed1');
				statHead.nazv.text=statHead.numb.text='';
				arr.push({id:'hp', objectName:Res.txt('pip', 'hp'), lvl:Math.round(gg.hp)+'/'+Math.round(gg.maxhp), bar:(gg.hp/gg.maxhp)});
				arr.push({id:'organism', objectName:Res.txt('pip', 'organism')+':', lvl:''});
				arr.push({id:'statHead'+gg.pers.headSt,objectName:'   '+Res.txt('pip', 'head'), lvl:Math.round(gg.pers.headHP)+'/'+Math.round(gg.pers.inMaxHP), bar:(gg.pers.headHP/gg.pers.inMaxHP)});
				arr.push({id:'statTors'+gg.pers.torsSt,objectName:'   '+Res.txt('pip', 'tors'), lvl:Math.round(gg.pers.torsHP)+'/'+Math.round(gg.pers.inMaxHP), bar:(gg.pers.torsHP/gg.pers.inMaxHP)});
				arr.push({id:'statLegs'+gg.pers.legsSt,objectName:'   '+Res.txt('pip', 'legs'), lvl:Math.round(gg.pers.legsHP)+'/'+Math.round(gg.pers.inMaxHP), bar:(gg.pers.legsHP/gg.pers.inMaxHP)});
				arr.push({id:'statBlood'+gg.pers.bloodSt,objectName:'   '+Res.txt('pip', 'blood'), lvl:Math.round(gg.pers.bloodHP)+'/'+Math.round(gg.pers.inMaxHP), bar:(gg.pers.bloodHP/gg.pers.inMaxHP)});
				arr.push({id:'statMana'+gg.pers.manaSt,objectName:'   '+Res.txt('pip', 'mana'), lvl:Math.round(gg.pers.manaHP)+'/'+Math.round(gg.pers.inMaxMana), bar:(gg.pers.manaHP/gg.pers.inMaxMana)});
				arr.push({id:'rad', objectName:Res.txt('pip', 'rad'), lvl:Math.round(gg.rad)});
				arr.push({id:'radx', objectName:Res.txt('pip', 'radx'), lvl:Math.round((1-gg.radX)*100)+'%'});
				arr.push({id:'cut', objectName:Res.txt('pip', 'cut'), lvl:Math.round(gg.cut*10)/10});
				arr.push({id:'resbleeding', objectName:Res.txt('pip', 'resbleeding'), lvl:Math.round((1-gg.vulner[Unit.D_BLEED])*100)+'%'});
				arr.push({id:'poison', objectName:Res.txt('pip', 'poison'), lvl:Math.round(gg.poison*10)/10});
				arr.push({id:'respoison', objectName:Res.txt('pip', 'respoison'), lvl:Math.round((1-gg.vulner[Unit.D_POISON])*100)+'%'});
				if (gg.pets['phoenix'] && GameSession.currentSession.game.triggers['pet_phoenix']) {
					arr.push({id:'phoenix', objectName:gg.pets['phoenix'].objectName, lvl:Math.round(gg.pets['phoenix'].hp)+'/'+Math.round(gg.pets['phoenix'].maxhp)});
				}
				for (var i in pers.addictions) 
				{
					if (pers.addictions[i]>0) 
					{
						var str:String='';
						if (pers.addictions[i]>=pers.ad3) str=Res.txt('pip', 'ad3');
						else if (pers.addictions[i]>=pers.ad2) str=Res.txt('pip', 'ad2');
						else if (pers.addictions[i]>=pers.ad1) str=Res.txt('pip', 'ad1');
						else str=Res.txt('pip', 'ad0');
						arr.push({id:i, objectName:Res.txt('eff',i+'_ad'), lvl:Math.round(pers.addictions[i])+'% ('+str+')', cat:'ad'});
					}
				}
			} 
			else if (subCategory == 2) 
			{	
				setTopText('infoskills');
				skillPoint=pers.skillPoint;
				statHead.nazv.text=Res.txt('pip', 'is1');
				statHead.numb.text=Res.txt('pip', 'is2');
				for each(var sk in pers.skill_ids) 
				{
					if (pers.level<Pers.postPersLevel && sk.post>0) continue;
					var numb=pers.skills[sk.id];
					var n:Object={id:sk.id, objectName:Res.txt('eff',sk.id), lvl:numb, minlvl:numb, post:sk.post};
					arr.push(n);
					skills[sk.id]=n;
				}
				vis.butOk.text.text=Res.txt('pip', 'accept');
			} 
			else if (subCategory == 3) 
			{
				perkPoint=pers.perkPoint;
				statHead.nazv.text=Res.txt('pip', 'is5');
				statHead.numb.text=Res.txt('pip', 'is2');
				for (var pid in pers.perks) 
				{
					var maxlvl=1;
					var xperk = XmlBook.getXML("perks").perk.(@id == pid);
					if (xperk.length() && xperk.@lvl.length()) maxlvl=xperk.@lvl;
					var numb=pers.perks[pid];
					var n:Object={id:pid, objectName:Res.txt('eff',pid), lvl:numb, maxlvl:maxlvl, sort:(xperk.@tip=='0'?2:1)};
					arr.push(n);
				}
				if (perkPoint) 
				{
					vis.butOk.text.text=Res.txt('pip', 'choose');
					vis.butOk.visible=true;
				}
				if (arr.length == 0)
				{
					vis.emptytext.text=Res.txt('pip', 'emptyperk');
					statHead.visible=false;
				} 
				else 
				{
					vis.emptytext.text='';
					statHead.visible=true;
					arr.sortOn(['sort','objectName']);
				}
			} 
			else if (subCategory == 4) 
			{
				statHead.nazv.text=Res.txt('pip', 'is3');
				statHead.numb.text=Res.txt('pip', 'is4');
				statHead.numb.x=500;
				for (var sk in gg.effects) 
				{
					var ef=gg.effects[sk];
					var n={id:ef.id, objectName:Res.txt('eff',ef.id), lvl:'∞'};
					if (ef.ad) 
					{
						var str=Res.txt('eff',ef.id+'_ad');
						if (str!='') 
						{
							n.objectName=str+' ('+Res.txt('pip', 'ad'+ef.lvl)+')';
							n.id+='_ad';
						}
					}
					if (ef.id=='drunk') 
					{
						n.objectName=Res.txt('pip', 'drunk'+ef.lvl);
						drunk=ef.lvl;
					}
					if (!ef.forever) n.lvl=Math.round(ef.t/30);
					if (ef.tip==3) 
					{
						n.name=n_food;
					}
					arr.push(n);
				}
				if (arr.length == 0) 
				{
					vis.emptytext.text=Res.txt('pip', 'emptyeff');
					statHead.visible=false;
				} 
				else 
				{
					vis.emptytext.text='';
					statHead.visible=true;
				}
			} 
			else if (subCategory == 6) 
			{
				perkPoint=pers.perkPoint;
				statHead.nazv.text=Res.txt('pip', 'is5');
				statHead.numb.text=Res.txt('pip', 'is2');
				for each (var dp:XML in XmlBook.getXML("perks").perk) 
				{
					if (dp.@tip == 1) 
					{
						var res:int = pers.perkPoss(dp.@id, dp);
						if (res < 0) continue;
						var numb = pers.perks[dp.@id];
						if (numb == null) numb = 0;
						var maxlvl = 1;
						if (dp.@lvl.length()) maxlvl = dp.@lvl;
						var n:Object = {id:dp.@id, objectName:Res.txt('eff', dp.@id), lvl:(numb+1), maxlvl:maxlvl, ok:(res>0), sort:(1-res)};
						arr.push(n);
					}
				}
				arr.sortOn(['sort','objectName']);
				vis.butOk.text.text=Res.txt('pip', 'accept');
				vis.butDef.text.text=Res.txt('gui', 'cancel');
				vis.butDef.visible=true;
			}
			showBottext();
		}
		
		public override function setSigns():void
		{
			super.setSigns();
			if (pers.skillPoint>0) signs[2]=1;
			if (pers.perkPoint>0) signs[3]=1;
			if (gg.pers.headHP/gg.pers.inMaxHP<0.25 || gg.pers.torsHP/gg.pers.inMaxHP<0.25 || gg.pers.legsHP/gg.pers.inMaxHP<0.25 || gg.pers.bloodHP/gg.pers.inMaxHP<0.25) signs[5]=3;
			else if (gg.pers.headHP/gg.pers.inMaxHP<0.5 || gg.pers.torsHP/gg.pers.inMaxHP<0.5 || gg.pers.legsHP/gg.pers.inMaxHP<0.5 || gg.pers.bloodHP/gg.pers.inMaxHP<0.5) signs[5]=2;
		}
		
		//показ одного элемента
		public override function setStatItem(item:MovieClip, obj:Object):void
		{
			if (obj.id!=null) item.id.text=obj.id; else item.id.text='';
			if (obj.cat!=null) item.cat.text=obj.cat; else item.cat.text='';
			item.id.visible = false;
			item.cat.visible = false;
			item.progress.visible = false;
			item.hpbar.visible = false;
			item.numb.x = 335;
			item.nazv.text = obj.objectName;
			item.numb.text = obj.lvl;
			if (obj.maxlvl && obj.maxlvl > 1 && obj.maxlvl < 1000) item.numb.text += '/' + obj.maxlvl;
			item.alpha = 1;
			if (subCategory == 4) item.numb.x = 500;
			if (subCategory == 2) 
			{
				if (obj.post > 0) 
				{
					var sklvl = pers.getPostSkLevel(obj.lvl);
					var nextN = 100;
					if (sklvl < pers.postSkTab.length) nextN = pers.postSkTab[sklvl];
					item.numb.text = obj.lvl + '  (+' + (nextN - obj.lvl) + ')\t         ' + Res.txt('pip', 'level') + ': ' + sklvl;
					item.numb.x = 215;
				} 
				else 
				{
					item.numb.text = pers.getSkLevel(obj.lvl);
					for (var i:int = 1; i <= maxSkLvl; i++) 
					{
						if (i <= obj.minlvl) item.progress['p' + i].gotoAndStop(2);
						else if (i <= obj.lvl) item.progress['p' + i].gotoAndStop(3);
						else item.progress['p' + i].gotoAndStop(1);
					}
					item.progress.visible = true;
					item.numb.x = 525;
				}
			}
			if (subCategory == 6) 
			{
				if (!obj.ok) item.alpha=0.4;
			}
			if (obj.bar!=null) 
			{
				item.hpbar.visible=true;
				item.hpbar.bar.scaleX=Math.max(0,obj.bar);
			}
		}
		
		//информация об элементе
		public override function statInfo(event:MouseEvent):void
		{
			var id:String = event.currentTarget.id.text;
			var objectName:String = event.currentTarget.nazv.text;
			if (subCategory == 2 || subCategory == 3 || subCategory == 6) setIco(5,id);
			else setIco();
			if (id!='') 
			{
				if (subCategory == 1) 
				{
					infoItemId = id;
					if (id == 'diff') 
					{
						vis.nazv.text=Res.txt('pip',id);
						vis.info.htmlText=Res.txt('gui','dif'+GameSession.currentSession.game.globalDif,1);
					} 
					else 
					{
						vis.nazv.text=Res.txt('pip', id);
						vis.info.htmlText=Res.txt('pip',id,1);
					}
					vis.info.htmlText+='<br><br>';
					var xml = XmlBook.getXML("parameters").param.(@id == id);
					if (xml.length() && xml.@f>0) vis.info.htmlText+=factor(xml.@v);
				} 
				else if (subCategory == 5) 
				{
					infoItemId=id;
					showBottext();
					var lvl;

					if (event.currentTarget.cat.text == 'ad') 
					{
						vis.nazv.text = Res.txt('eff',id+'_ad');
						lvl=0;
						lvl=int(event.currentTarget.numb.text);
						if (lvl>0) lvl--;
						vis.info.htmlText = effStr('effects', id + '_ad',lvl); //Done via XmlBook lookup, not Res.txt
					} 
					else if (id == 'phoenix') 
					{
						vis.nazv.text=objectName;
						vis.info.htmlText = Res.txt('unit','phoenix',1);
					} 
					else 
					{
						vis.nazv.text=Res.txt('pip', id);
						vis.info.htmlText=Res.txt('pip',id,1);
					}

					vis.info.htmlText += '<br><br>';

					if (id.indexOf('statHead') == 0) 
					{
						var lvl:int = getSeverityLevel(id, 'statHead', 3);
						if (lvl > 0) vis.info.htmlText += effStr('perks', 'trauma_head', lvl);
					}
					if (id.indexOf('statTors') == 0) 
					{
						lvl = getSeverityLevel(id, 'statTors', 3);
						if (lvl > 0) vis.info.htmlText += effStr('perks', 'trauma_tors', lvl);
					}
					if (id.indexOf('statLegs') == 0) 
					{
						lvl = getSeverityLevel(id, 'statLegs', 3);
						if (lvl > 0) vis.info.htmlText += effStr('perks', 'trauma_legs', lvl);
					}
					if (id.indexOf('statBlood') == 0) 
					{
						lvl = getSeverityLevel(id, 'statBlood', 3);
						if (lvl > 0) vis.info.htmlText += effStr('perks', 'trauma_blood', lvl);
					}
					if (id.indexOf('statMana') == 0) 
					{
						lvl = getSeverityLevel(id, 'statMana', 2);
						if (lvl > 0) vis.info.htmlText += effStr('perks', 'trauma_mana', lvl);
					}

					if (id=='hp') vis.info.htmlText+=factor('maxhp');
					if (id=='radx') vis.info.htmlText+=factor('radX');
					if (id=='resbleeding') vis.info.htmlText+=factor('13');
					if (id=='respoison') vis.info.htmlText+=factor('12');
				} 
				else 
				{
					vis.nazv.text=objectName;
					if (subCategory==4) 
					{
						if (id=='drunk') 
						{
							vis.info.htmlText = effStr('effects',id,drunk-1);
						} 
						else if (objectName == n_food) vis.info.htmlText = Res.txt('eff','food',1)+'<br><br>'+effStr('effects',id);
						else vis.info.htmlText = effStr('effects',id);
					} 
					else if (subCategory == 2) 
					{
						if (Settings.alicorn && Res.istxt('eff',id+'_al')) 
						{
							vis.info.htmlText = Res.rainbow(Res.txt('eff',id+'_al'));
							vis.info.htmlText += '<br><br>' + effStr('skills', id + '_al');
						} 
						else 
						{
							vis.info.htmlText=effStr('skills',id);
						}
					} 
					else if (subCategory == 6) 
					{
						vis.info.htmlText=effStr('perks',id, 1);
					} 
					else if (subCategory == 3) 
					{
						vis.info.htmlText=effStr('perks',id);
					}
				}
			} 
			else 
			{
				vis.nazv.text=vis.info.htmlText='';
			}

			// Get the severity level of a status by reading the number at the end of a given string. eg. 'statHead2' -> 2.
			function getSeverityLevel(id:String, baseString:String, maxLevel:int):int 
			{
				if (id.indexOf(baseString) == 0)
				{
					var lvl:int = parseInt(id.substr(baseString.length, 1));
					return Math.min(lvl, maxLevel);
				}
				return 0;
			}
		}

		public function selSkill(id:String):void
		{
			if (pers.skillIsPost(id) && skills[id].lvl < Pers.maxPostSkLvl || skills[id].lvl < maxSkLvl) 
			{
				if (skillPoint>0) 
				{
					skills[id].lvl++;
					skillPoint--;
					vis.butOk.visible=true;
				}
				else 
				{
					GameSession.currentSession.gui.infoText('noSkillPoint');
				}
			}
		}

		public function unselSkill(id:String):void
		{
			if (skills[id].lvl>skills[id].minlvl) 
			{
				skills[id].lvl--;
				skillPoint++;
			}
		}
		
		public function showBottext():void
		{
			vis.bottext.text='';
			if (subCategory == 1) vis.bottext.htmlText = Res.txt('pip',      'tgame') + ': ' + GameSession.currentSession.game.gameTime();
			if (subCategory == 2) vis.bottext.htmlText = Res.txt('pip', 'skillpoint') + ': ' + numberAsColor('pink', skillPoint);
			if (subCategory == 3) vis.bottext.htmlText = Res.txt('pip',  'perkpoint') + ': ' + numberAsColor('pink', perkPoint);
			if (subCategory == 6) 
			{
				if (selectedPerk == '') vis.bottext.htmlText=Res.txt('pip', 'chooseperk');
				else vis.bottext.htmlText = textAsColor('pink', Res.txt('eff',selectedPerk));
			}

			if (subCategory == 5 && infoItemId != '') 
			{
				var ci:String = '';
				var simplifiedID:String = getSimplifiedItemId(infoItemId)

				switch (simplifiedID)
				{
					case 'hp':
						vis.bottext.htmlText = Res.txt('pip', 'healpotions') + ': ' + textAsColor('yellow', inv.items['pot1'].kol + inv.items['pot2'].kol + inv.items['pot3'].kol);
						break;

					case 'rad':
						ci = 'antiradin';
						break;

					case 'cut':
						ci = 'pot0';
						break;

					case 'poison':
						ci = 'antidote';
						break;

					case 'statBlood':
						ci = 'bloodpak';
						break;

					case 'statMana':
						vis.bottext.htmlText = Res.txt('item','potm1') + ': ' + textAsColor('yellow', inv.items['potm1'].kol + inv.items['potm2'].kol + inv.items['potm3'].kol);
						break;

					case 'phoenix':
						ci = 'radcookie';
						break;

					case 'post_':
						ci = 'detoxin';
						break;

					case 'statHead':
						ci = gg.invent.getMed(1);
						if (ci == '') vis.bottext.text = '';
						break;

					case 'statTors':
						ci = gg.invent.getMed(2);
						if (ci == '') vis.bottext.text = '';
						break;

					case 'statLegs':
						ci = gg.invent.getMed(3);
						if (ci == '') vis.bottext.text = '';
						break;

				}

				if (ci != '') vis.bottext.htmlText = Res.txt('item', ci) + ': ' + textAsColor('yellow', inv.items[ci].kol);
			}
		}		
		
		public override function itemClick(event:MouseEvent):void
		{
			if (pip.gamePause) 
			{
				GameSession.currentSession.gui.infoText('gamePause');
				return;
			}

			if (subCategory == 2) 
			{
				var id=event.currentTarget.id.text;
				if (event.ctrlKey) unselSkill(id);
				else selSkill(id);
				setStatItem(event.currentTarget as MovieClip, skills[id]);
				pip.snd(1);
			}

			if (subCategory == 6) 
			{
				if (event.currentTarget.alpha >= 1) 
				{
					vis.butOk.visible = true;
					selectedPerk = event.currentTarget.id.text;
				}
				pip.snd(1);
			}

			if (subCategory == 5 && infoItemId != '') //Clicking on status problems to heal them using the appropriate item.
			{
				infoItemId = event.currentTarget.id.text;
				var need:String;
				var simplifiedID:String = getSimplifiedItemId(infoItemId)

				switch (simplifiedID)
				{
					case 'hp':
						inv.usePotion();
						break;

					case 'rad':
						inv.usePotion('antiradin');
						break;

					case 'cut':
						inv.usePotion('pot0');
						break;

					case 'poison':
						inv.usePotion('antidote');
						break;

					case 'statBlood':
						inv.usePotion('bloodpak');
						break;

					case 'statMana':
						inv.usePotion('mana');
						break;

					case 'phoenix':
						inv.usePotion('radcookie');
						break;

					case 'post_':
						inv.usePotion('detoxin');
						break;

					case 'statHead':
						need = gg.invent.getMed(1);
						if (need != '') inv.usePotion(need, 1);
						break;

					case 'statTors':
						need = gg.invent.getMed(2);
						if (need != '') inv.usePotion(need, 2);
						break;

					case 'statLegs':
						need = gg.invent.getMed(3);
						if (need != '') inv.usePotion(need, 3);
						break;

				}

				setStatus();
				pip.snd(1);
				pip.setRPanel();
			}
			showBottext();
		}

		// Helper function for switch-cases. These strings have nubmers at the end, eg. 'statBlood2' to represent intensity levels.
		// This removes the trailing number if applicable so the switch-case can do an instant comparison to check for matches.
		private function getSimplifiedItemId(infoItemId:String):String  
		{
			if (infoItemId.indexOf('statBlood') == 0) return 'statBlood';
			if (infoItemId.indexOf('statMana')  == 0) return 'statMana';
			if (infoItemId.indexOf('statHead')  == 0) return 'statHead';
			if (infoItemId.indexOf('statTors')  == 0) return 'statTors';
			if (infoItemId.indexOf('statLegs')  == 0) return 'statLegs';
			if (infoItemId.indexOf('detoxin')   == 0) return 'detoxin';

			return infoItemId;
		}

		public override function itemRightClick(event:MouseEvent):void
		{
			if (pip.gamePause) 
			{
				GameSession.currentSession.gui.infoText('gamePause');
				return;
			}

			if (subCategory == 2) 
			{
				var id = event.currentTarget.id.text;
				unselSkill(id);
				setStatItem(event.currentTarget as MovieClip, skills[id]);
				pip.snd(1);
			}

			showBottext();
		}

		public function transOk(event:MouseEvent):void
		{
			if (pip.gamePause) 
			{
				GameSession.currentSession.gui.infoText('gamePause');
				return;
			}
			if (subCategory == 2) 
			{
				var n = 0;
				for (var i in skills) 
				{
					n += skills[i].lvl-skills[i].minlvl;
				}
				if (n<=pers.skillPoint) 
				{
					for (i in skills) 
					{
						pers.addSkill(skills[i].id, skills[i].lvl-skills[i].minlvl, true);
					}
					pers.setParameters();
					GameSession.currentSession.gui.setAll();
				}
				pip.snd(3);
				GameSession.currentSession.saveGame();
			} 
			else if (subCategory == 3) 
			{
				subCategory = 6;
				pip.snd(2);
				selectedPerk = '';
			} 
			else if (subCategory == 6) 
			{
				if (selectedPerk != '' && pers.perkPoint > 0) pers.addPerk(selectedPerk, true);
				subCategory = 3;
				pip.snd(3);
				pip.setRPanel();
				GameSession.currentSession.saveGame();
			}
			setStatus();
		}
		
		public function gotoDef(event:MouseEvent):void
		{
			if (subCategory == 6) 
			{
				subCategory = 3;
				setStatus();
				pip.snd(2);
			}
		}
	}	
}