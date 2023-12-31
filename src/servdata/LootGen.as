package servdata 
{
	import locdata.Loot;
	import locdata.Room;

	import components.XmlBook;
	
	public class LootGen 
	{
		//случайные объекты 
		private static var rndArr:Array;
		public static var arr:Array;
				
		private static var is_loot:int = 0;		//был сгенерирован лут
		private static var room:Room;				//целевая локация
		private static var nx:Number;
		private static var ny:Number;
		private static var lootBroken:Boolean=false;

		public static function init():void
		{
			//var n:Number;
			arr = [];
			var n:Array = [];
			//arrWeapon=new Array();
			n['weapon'] 	= 0;
			arr['weapon'] 	= [];
			arr['magic'] 	= [];
			arr['uniq'] 	= [];
			arr['pers'] 	= [];
			for each (var weap:XML in XmlBook.getXML("weapons").weapon.(@tip > 0 && @tip < 4)) 
			{
				if (weap.com.length() == 0) continue;
				arr['weapon'].push({id: weap.@id, st: weap.com.@stage, chance: weap.com.@chance, worth: weap.com.@worth, lvl: weap.@lvl, r: (n['weapon'] += Number(weap.com.@chance))});
				if (weap.com.@uniq.length()) arr['uniq'].push({id: weap.@id + '^1', st: weap.com.@stage, chance: weap.com.@uniq, worth: weap.com.@worth, lvl: weap.@lvl, r: (n['uniq'] += Number(weap.com.@uniq))});
			}
			for each (weap in XmlBook.getXML("weapons").weapon.(@tip == 5)) 
			{
				arr['magic'].push({id: weap.@id, st: 0, chance: 0, worth: 0, lvl: 0, r: 0});
			}
			for each (var item:XML in XmlBook.getXML("items").item) 
			{
				if (item.@tip.length()) 
				{
					if (arr[item.@tip] == null) 
					{
						arr[item.@tip] = [];
						n[item.@tip] = 0;
					}
					arr[item.@tip].push({id: item.@id, st: item.@stage, chance: (item.@chance.length() ? item.@chance : 1), lvl: item.@lvl, r: (n[item.@tip] += Number(item.@chance.length() ? item.@chance : 1))});
					if (item.@tip == 'art' || item.@tip == 'impl' || item.sk.length()) arr['pers'].push(item.@id); // Items modifying character traits
				}
				if (item.@tip2.length()) 
				{
					if (arr[item.@tip2] == null) 
					{
						arr[item.@tip2] = [];
						n[item.@tip2] = 0;
					}
					arr[item.@tip2].push({id: item.@id, st: item.@stage, chance: (item.@chance2.length() ? item.@chance2 : item.@chance), lvl: item.@lvl, r: (n[item.@tip2] += Number(item.@chance2.length() ? item.@chance2 : item.@chance))});
				}
			}
			
			
			var a:Array = []; // проверка рандома
		}
		
		public static function getRandom(tip:String, maxlvl:Number = -100, worth:int = -100):String 
		{
			var a:Array, res:Array, n:Number = 0;
			a = arr[tip];
			if (a == null) return null;
			var gameStage:int = 0
			if (GameSession.currentSession.level) gameStage = GameSession.currentSession.level.gameStage;
			
			if (tip != Item.L_BOOK && (maxlvl > 0 || worth > 0 || gameStage > 0)) 
			{
				res = [];
				for each(var i:Object in a) 
				{
					if (
						(gameStage <= 0    || i.st    == null || i.st  <= gameStage) &&		//зависит от этапа сюжета
						(maxlvl    == -100 || i.lvl   == null || i.lvl <= maxlvl) &&			//максимальный уровень, зависит от сложности
						(worth 	   == -100 || i.worth == null || worth == i.worth)			//тип предмета, зависит от типа контейнера
					) 
					{
						res.push({id:i.id, r:(n += Number(i.chance))});
					}
				}
			} 
			else res = a;

			if (res.length == 0) return null;
			if (res.length == 1) return res[0].id;
			n = Math.random() * res[res.length - 1].r;
			for each(i in res) 
			{
				if (i.r > n) return i.id;
			}
			return null;
		}
		
		//создать рандомный, если id==null, или заданный лут
		//если запрос превышает лимит, не создавать лут, вернуть false
		private static function newLoot(rnd:Number, tip:String, id:String = null, kol:int = -1, imp:int = 0, cont:Interact = null):Boolean 
		{
			if (rnd < 1 && Math.random() > rnd) return false;
			var mn:Number = 1;
			if (lootBroken) mn = 0.4;
			if (tip == Item.L_WEAPON) 
			{
				//Рандомное оружие
				if (int(id) > 0) 
				{
					id = getRandom(tip, Math.max(1, room.weaponLevel + (Math.random() * 2 - 1)), int(id));
					if (id == null) mn *= 0.5;
				}
				if (id == null) 
				{
					id = getRandom(tip, Math.max(1, room.weaponLevel + (Math.random() * 2 - 1)));
					if (id == null) mn *= 0.5;
				}
				if (id == null) id = getRandom(tip);
			}
			//Рандомный лут, определить нужный id
			if (id == null || id == '') 
			{
				if (tip == Item.L_EXPL || tip == Item.L_UNIQ) 
				{
					id = getRandom(tip, Math.max(1, room.weaponLevel + (Math.random() * 2 - 1)));
				} 
				else 
				{
					id = getRandom(tip, Math.max(1, room.locDifLevel / 2 + (Math.random() * 2 - 1)));
				}
				if (id == null) id = getRandom(tip);
			}
			if (id == null)
			{
				trace('Ошибка при генерации лута тип:', tip);
				return false;
			}
			if (kol == -1 && tip == Item.L_UNIQ) kol = 1;
			var item:Item = new Item(tip, id, kol);
			if (tip == 'eda') item.tip = 'food';
			if (tip == 'co') 
			{
				item.tip = 'scheme';
				var wid:String = id.substr(2);
				item.objectName = Res.txt('pip', 'recipe') + ' «' + Res.txt('item', wid) + '»';
			}
			item.multHP = mn;
			item.imp = imp;
			item.cont = cont;
			if (item.id == 'money') item.kol *= GameSession.currentSession.pers.capsMult * GameSession.currentSession.pers.difCapsMult;	//множитель крышек
			if (item.id == 'bit')   item.kol *= GameSession.currentSession.pers.bitsMult * GameSession.currentSession.pers.difCapsMult;	//множитель крышек
			if (lootBroken && (item.id == 'money' || item.id == 'bit')) item.kol *= 0.5;
			if (lootBroken && (item.tip == Item.L_AMMO || item.tip == Item.L_EXPL) && Math.random() < 0.5) return false;
			//проверить лимиты
			if (imp == 0 && item.xml.@limit.length()) 
			{
				var lim:int = GameSession.currentSession.game.getLimit(item.xml.@limit);
				var itemLimit:Number = GameSession.currentSession.level.lootLimit;
				if (item.xml.@mlim.length()) itemLimit *= item.xml.@mlim;
				if (item.xml.@maxlim.length() && lim >= item.xml.@maxlim) 
				{
					if (!GameSession.currentSession.testLoot) trace('Достигнут максимум:', id, lim);
					return false;
				}
				if (lim >= itemLimit) 
				{
					if (!GameSession.currentSession.testLoot) trace('Превышен лимит:', id, lim, itemLimit);
					return false;
				}
				GameSession.currentSession.game.addLimit(item.xml.@limit, 1);
			}
			if (GameSession.currentSession.testLoot) GameSession.currentSession.invent.take(item);
			else new Loot(room, item, nx, ny, true);
			is_loot++;
			return true;
		}
		
		//Генерация лута по заданному ID
		public static function lootId(newRoom:Room, nnx:Number, nny:Number, id:String, kol:int = -1, imp:int = 0, cont:Interact = null, broken:Boolean = false):void
		{
			if (newRoom == null) return;
			lootBroken = broken;
			room = newRoom;
			nx = nnx;
			ny = nny;
			newLoot(1, '', id, kol, imp, cont);
		}
		
		//генерация лута из заданного типа контейнера, вернуть true если было что-то сгенерировано
		//dif - сложность замков, принимает значение от 0 до 49
		public static function lootCont(newRoom:Room, nnx:Number, nny:Number, cont:String, broken:Boolean = false, dif:Number = 0):Boolean 
		{
			if (newRoom == null) return false;
			lootBroken = broken;
			room = newRoom;
			nx = nnx; 
			ny = nny;
			is_loot = 0;
			var locdif:Number=Math.min(room.locDifLevel, 20);
			var kol:int = 1;
			if (cont == 'ammo') 
			{
				newLoot(0.7,  Item.L_AMMO);
				newLoot(0.25, Item.L_AMMO);
				newLoot(0.15, Item.L_AMMO);
				if (GameSession.currentSession.pers.freel) newLoot(0.7, Item.L_AMMO);
			} 
			else if (cont == 'metal') 
			{		//металлоискатель
				if (!newLoot(0.5, Item.L_ITEM, 'money', Math.random() * 30 * (locdif * 0.15 + 1) + 5)) newLoot(1, Item.L_AMMO);
			} 
			else if (cont == 'bomb') 
			{
				kol=3;
				for (var i:int = 0; i < kol; i++) newLoot(1, Item.L_EXPL, 'dinamit');
			} 
			else if (cont == 'expl') 
			{
				kol = Math.floor(Math.random() * 4 - 1);
				for (var j:int = 0; j <= kol; j++) newLoot(1, Item.L_EXPL);
				newLoot(0.5, Item.L_COMPE);
				if (GameSession.currentSession.pers.freel) newLoot(0.5, Item.L_EXPL);
			} 
			else if (cont == 'bigexpl') 
			{
				kol = Math.floor(Math.random() * 4 + 2);
				for (var k:int = 0; k <= kol; k++) newLoot(1, Item.L_EXPL);
				if (GameSession.currentSession.pers.freel) newLoot(0.5,Item.L_EXPL);
				newLoot(0.5, Item.L_COMPE);
			} 
			else if (cont == 'wbattle') 
			{
				if (!newLoot(0.04, Item.L_UNIQ)) 
				{
					if (Math.random() < Math.min(locdif / 5, 0.7)) newLoot(1, Item.L_WEAPON, '4', 1);
					else newLoot(1, Item.L_WEAPON,'3',1);
				}
				newLoot(0.8, Item.L_AMMO);
				if (GameSession.currentSession.pers.freel) newLoot(0.5, Item.L_AMMO);
				newLoot(0.1, Item.L_ITEM, 'stealth');
				if (GameSession.currentSession.pers.barahlo) newLoot(0.1, Item.L_COMPA, 'intel_comp');
			} 
			else if (cont == 'case') 
			{
				newLoot(0.9, Item.L_ITEM, 'money', Math.random() * 20 * (locdif * 0.11 + 1) + 5);
			} 
			else if (cont == 'wbig') 
			{
				if (!newLoot(0.08, Item.L_UNIQ)) 
				{
					if (Math.random() < 0.5) newLoot(1, Item.L_WEAPON, '5', 1);
					else newLoot(1, Item.L_WEAPON, '4', 1);
				}
				newLoot(0.5, Item.L_EXPL, '', Math.floor(Math.random() * 4));
				newLoot(0.5, Item.L_AMMO, '', Math.floor(Math.random() * 4));
				if (GameSession.currentSession.pers.freel) newLoot(0.5, Item.L_AMMO);
				if (GameSession.currentSession.pers.barahlo) newLoot(0.5, Item.L_COMPA, 'intel_comp');
			} 
			else if (cont == 'robocell') 
			{
				newLoot(1, Item.L_COMPM);
			} 
			else if (cont == 'instr') 
			{
				newLoot(0.1, Item.L_ITEM,'pin',Math.floor(Math.random()*5+1)); 
				if (!newLoot(0.35, Item.L_WEAPON,'2',1)) newLoot(0.5, Item.L_ITEM,'rep');
				newLoot(0.85, Item.L_COMPA);
				newLoot(0.7, Item.L_COMPW);
				newLoot(0.1, Item.L_COMPE);
				newLoot(0.5, Item.L_COMPM);
				newLoot(0.5, Item.L_PAINT);
				if (GameSession.currentSession.pers.barahlo) 
				{
					newLoot(0.85, Item.L_COMPA);
					newLoot(0.7, Item.L_COMPW);
					newLoot(0.1, Item.L_COMPE);
					newLoot(0.1, Item.L_COMPE);
					newLoot(0.5, Item.L_COMPA);
				}
			} 
			else if (cont == 'instr2') 
			{
				newLoot(0.1, Item.L_ITEM,'pin',Math.floor(Math.random()*5+1)); 
				if (!newLoot(0.35, Item.L_WEAPON,'2',1)) newLoot(0.5, Item.L_ITEM,'rep');
				newLoot(0.75, Item.L_COMPA);
				newLoot(0.4, Item.L_COMPW);
				newLoot(0.5, Item.L_COMPM);
				newLoot(0.2, Item.L_PAINT);
				if (GameSession.currentSession.pers.barahlo) 
				{
					newLoot(0.75, Item.L_COMPA);
					newLoot(0.4, Item.L_COMPW);
					newLoot(0.1, Item.L_COMPE);
					newLoot(0.5, Item.L_COMPA);
				}
			} 
			else if (cont == 'trash') 
			{
				if (room.level.levelTemplate.biom==0) newLoot(0.25, Item.L_FOOD, 'radcookie');
				if (Math.random() < 0.25) 
				{
					if (Math.random() < 0.6) room.createUnit('tarakan', nx, ny, true);
					else room.createUnit('rat', nx, ny, true);
				} 
				else 
				{
					kol=Math.floor(Math.random()*2);
					if (GameSession.currentSession.pers.barahlo) kol+=2;
					for (i = 0; i <= kol; i++) newLoot(1, Item.L_STUFF);
					newLoot(0.4, Item.L_ITEM,'money',Math.random()*10*(locdif*0.1+1)+5);
				}
			} 
			else if (cont == 'fridge') 
			{
				newLoot(0.5, Item.L_FOOD, 'sparklecola');
				newLoot(0.5, Item.L_FOOD, 'sars');
				newLoot(0.1, Item.L_FOOD, 'radcola');
				if (Math.random()<0.2) 
				{
					if (Math.random() < 0.4) room.createUnit('tarakan', nx, ny, true);
					else if (Math.random() < 0.5) room.createUnit('rat', nx, ny, true);
					else room.createUnit('bloat', nx, ny, true);
				} 
				else 
				{
					kol = Math.floor(Math.random() * 2);
					for (i = 0; i <= kol; i++) newLoot(1, Item.L_FOOD);
					newLoot(0.3, Item.L_COMPP, 'herbs', Math.floor(Math.random() * 6 + 1));
				}
			} 
			else if (cont == 'food') 
			{
				if (room.level.levelTemplate.biom==0) newLoot(0.25, Item.L_FOOD, 'radcookie');
				if (Math.random() < 0.25) 
				{
					if (Math.random() < 0.6) room.createUnit('tarakan', nx, ny, true);
					else room.createUnit('rat', nx, ny, true);
				} 
				else 
				{
					newLoot(0.8, Item.L_FOOD);
					newLoot(0.5, Item.L_STUFF);
					newLoot(0.2, Item.L_COMPP, 'herbs', Math.floor(Math.random() * 6 + 1));
					newLoot(0.05, 'co');
				}
			} 
			else if (cont == 'med') 
			{
				newLoot(0.05, Item.L_ITEM, 'pin', Math.floor(Math.random() * 2 + 1)); 
				kol = Math.floor(Math.random() * 3 - 1);
				for (i = 0; i <= kol; i++) newLoot(1, Item.L_MED);
				newLoot(0.25, Item.L_HIM);
				newLoot(0.03, Item.L_MED, 'firstaid');
				newLoot(0.05, Item.L_POT, 'potHP');
				newLoot(0.25, Item.L_ITEM, 'gel');
			} 
			else if (cont == 'med2') 
			{
				newLoot(0.75, Item.L_POT, 'potHP');
				kol = Math.floor(Math.random() * 3);
				for (i = 0; i <= kol; i++) newLoot(1, Item.L_MED);
				newLoot(1, Item.L_HIM);
				newLoot(0.5, Item.L_MED, 'firstaid');
				newLoot(0.5, Item.L_MED, 'doctor');
				newLoot(0.5, Item.L_MED, 'surgeon');
				newLoot(0.8, Item.L_ITEM, 'gel');
			} 
			else if (cont == 'table') 
			{
				newLoot(0.1, Item.L_ITEM,'pin',Math.floor(Math.random()*3+1)); 
				if (!newLoot(0.08, Item.L_BOOK)) newLoot(0.5, Item.L_ITEM,'money',Math.random()*50+5+3*locdif);
				newLoot(0.1, Item.L_FOOD);
				newLoot(0.13, Item.L_WEAPON,'3');
				newLoot(0.3, Item.L_AMMO);
				newLoot(0.1, Item.L_ITEM,'dart');
				newLoot(0.1, Item.L_ITEM,'app');
				newLoot(0.04, Item.L_SCHEME);
				newLoot(0.25, Item.L_FOOD);
				newLoot(0.08, 'co');
				newLoot(0.1, Item.L_MED, 'potm1')
			} 
			else if (cont == 'filecab') 
			{
				newLoot(0.1, Item.L_ITEM,'pin',Math.floor(Math.random()*3+1)); 
				newLoot(0.5, Item.L_ITEM,'money',Math.random()*20);
				newLoot(0.1, Item.L_ITEM,'app');
				newLoot(0.02, Item.L_SCHEME);
				newLoot(0.08, 'co');
			} 
			else if (cont == 'cup') 
			{
				newLoot(0.06, Item.L_ITEM,'pin',Math.floor(Math.random()*3+1)); 
				newLoot(0.3, Item.L_ITEM,'money',Math.random()*20);
				newLoot(0.25, Item.L_COMPA);
				newLoot(0.75, Item.L_STUFF);
				newLoot(0.2, Item.L_COMPA, 'kombu_comp');
				newLoot(0.2, Item.L_COMPA, 'antirad_comp');
				newLoot(0.2, Item.L_COMPA, 'antihim_comp');
			} 
			else if (cont == 'bloat') 
			{
				room.createUnit('bloat',nx,ny,true);
			} 
			else if (cont == 'book') 
			{
				if (!newLoot(0.3, Item.L_BOOK)) newLoot(1, Item.L_ITEM,'lbook');
				newLoot(0.1, Item.L_ITEM,'gem'+Math.floor(Math.random()*3+1));
				newLoot(0.25, Item.L_SCHEME);
				newLoot(0.3, 'co');
				if (newRoom.itemsTip == 'bibl') newLoot(0.5, Item.L_ITEM, 'book_cm');
			} 
			else if (cont == 'term' || cont == 'info') 
			{
				if (newRoom.level.levelTemplate.id=='minst') newLoot(1,Item.L_ITEM,'datast');
				else if (!newLoot(0.25, Item.L_ITEM,'disc')) newLoot(1,Item.L_ITEM,'data');
				newLoot(0.5, Item.L_COMPM);
			} 
			else if (cont == 'cryo') 
			{
				kol = Math.floor(Math.random() * 3);
				for (var l:int = 0; l <= kol; l++) newLoot(1, Item.L_ITEM, 'pcryo');
				newLoot(0.5, Item.L_ITEM, 'gel');
			} 
			else if (cont == 'chest') 
			{
				newLoot(0.1, Item.L_ITEM,'pin',Math.floor(Math.random() * 5 + 1)); 
				newLoot(0.2, Item.L_WEAPON,'3', 2);
				newLoot(0.2, Item.L_ITEM,'bit',Math.random() * 50 + 7 * locdif + 2);
				newLoot(0.3, Item.L_ITEM,'gem'+Math.floor(Math.random()*3+1));
				newLoot(0.25, Item.L_COMPA);
				newLoot(0.03, Item.L_BOOK);
				newLoot(0.5, Item.L_AMMO);
				newLoot(0.03, Item.L_SCHEME);
				if (is_loot > 5) replic('full');
				if (is_loot < 2) replic('empty');
			} 
			else if (cont == 'safe') 
			{
				if (GameSession.currentSession.level.rnd && newRoom.prob == null && Math.random() < 0.05) 
				{
					for (i = 0; i < 4; i++) room.createUnit('bloat', nx, ny, true);
				} 
				else 
				{
					newLoot(dif / 100, Item.L_UNIQ);
					newLoot(0.1 + dif / 100, Item.L_ITEM,'sphera');
					newLoot(0.2 + dif / 200, Item.L_ITEM,'stealth');
					newLoot(0.25 + dif / 100, Item.L_ITEM,'gem'+Math.floor(Math.random()*3+1));
					newLoot(0.2, Item.L_MED);
					newLoot(0.25, Item.L_ITEM, 'retr');
					newLoot(0.1, Item.L_ITEM, 'runa');
					newLoot(0.1, Item.L_ITEM, 'reboot');
					newLoot(0.2 + dif / 100, Item.L_BOOK);
					newLoot(0.1 + dif / 100, Item.L_COMPP);
					newLoot(1, Item.L_ITEM, 'bit', Math.random() * (dif + 10) * 8 + 2 + 4 * locdif);
					newLoot(0.1 + dif / 300, Item.L_SCHEME);
					newLoot(0.25, Item.L_POT, 'potMP');
					newLoot(0.1, Item.L_POT, 'potHP');
					if (!newLoot(0.4, Item.L_MED, 'potm2')) newLoot(0.3, Item.L_MED, 'potm3')
					if (is_loot == 0) newLoot(1, Item.L_ITEM,'gem' + Math.floor(Math.random() * 3 + 1));
					if (is_loot > 6) replic('full');
					if (is_loot < 2) replic('empty');
				}
			} 
			else if (cont == 'specweap') 
			{
				kol = Math.floor(Math.random() * 4);
				var vars:Array = [];
				if (GameSession.currentSession.invent.weapons['lsword']==null || GameSession.currentSession.invent.weapons['lsword'].variant==0) vars.push('lsword^1');
				if (GameSession.currentSession.invent.weapons['antidrak']==null || GameSession.currentSession.invent.weapons['antidrak'].variant==0) vars.push('antidrak^1');
				if (GameSession.currentSession.invent.weapons['quick']==null || GameSession.currentSession.invent.weapons['quick'].variant==0) vars.push('quick^1');
				if (GameSession.currentSession.invent.weapons['mlau']==null || GameSession.currentSession.invent.weapons['mlau'].variant==0) vars.push('mlau^1');
				if (vars.length) newLoot(1, Item.L_WEAPON, vars[Math.floor(Math.random()*vars.length)]);
				else newLoot(1, Item.L_UNIQ);
			} 
			else if (cont == 'specalc') 
			{
				newLoot(1, Item.L_SPEC,'alc7');
				newLoot(1, Item.L_ITEM,'gem' + Math.floor(Math.random() * 3 + 1));
			} 
			else if (cont == 'speclp') 
			{
				newLoot(1, Item.L_SPEC,'lp_item');
				newLoot(1, Item.L_ITEM,'gem' + Math.floor(Math.random() * 3 + 1));
			}
			return is_loot > 0;
		}
		
		// TODO: Move these, holy christ
		//генерация лута, выпадающего из врагов, вернуть true если было что-то сгенерировано
		public static function lootDrop(newRoom:Room, nnx:Number, nny:Number, cont:String, hero:int=0):Boolean 
		{
			if (newRoom==null) return false;
			lootBroken=false;
			room=newRoom;
			nx = nnx;
			ny = nny;
			is_loot=0;
			//монстры
			switch (cont)
			{
				case 'scorp':
					newLoot(1, Item.L_COMPA, 'chitin_comp');
					newLoot(0.25, Item.L_COMPP, 'gland');
					newLoot(0.1, Item.L_FOOD, 'meat');
				break;

				case 'slime':
					newLoot(0.75, Item.L_ITEM, 'acidslime');
				break;

				case 'pinkslime':
					newLoot(0.75, Item.L_ITEM, 'pinkslime');
				break;

				case 'raider':
					newLoot(0.25, 'eda');
					newLoot(0.25, Item.L_AMMO);
					newLoot(0.12, Item.L_EXPL);
				break;

				case 'alicorn1':
				case 'alicorn2':
				case 'alicorn3':
					newLoot(1, Item.L_COMPP, 'mdust');
					newLoot(0.1, Item.L_POT, 'potMP');
					if (!newLoot(0.3, Item.L_MED, 'potm1')) newLoot(0.2, Item.L_MED, 'potm2');
				break;

				case 'ranger1':
				case 'ranger2':
				case 'ranger3':
					newLoot(1, Item.L_ITEM, 'frag',Math.floor(Math.random()*3+1));
					newLoot(0.5, Item.L_ITEM, 'scrap',Math.floor(Math.random()*3+1));
					newLoot(1, Item.L_COMPA, 'power_comp');
					newLoot(0.25, Item.L_AMMO);
				break;

				case 'encl2':
				case 'encl3':
				case 'encl4':
					newLoot(0.5, Item.L_ITEM, 'frag',Math.floor(Math.random()*3+1));
					if (!newLoot(0.3, Item.L_AMMO, 'batt')) newLoot(0.5, Item.L_AMMO,'crystal');
					newLoot(0.3, Item.L_COMPA, 'power_comp');
				break;

				case 'hellhound1':
					if (hero > 0) newLoot(1, Item.L_COMPW, 'kogt');
				break;

				case 'zombie':
					newLoot(0.35, Item.L_COMPP, 'ghoulblood');
					newLoot(0.15, Item.L_COMPP, 'radslime');
					newLoot(0.5, Item.L_COMPA, 'skin_comp');
				break;

				case 'zombie4':
					newLoot(0.8, Item.L_COMPP, 'ghoulblood');
					newLoot(1, Item.L_COMPP, 'radslime');
				break;

				case 'zombie5':
					newLoot(1, Item.L_COMPP, 'ghoulblood');
					newLoot(0.3, Item.L_COMPP, 'metal_comp');
				break;

				case 'zombie6':
					newLoot(1, Item.L_COMPP, 'ghoulblood');
					newLoot(0.3, Item.L_COMPA, 'battle_comp');
					newLoot(0.8, Item.L_COMPP, 'acidslime');
				break;

				case 'zombie7':
					newLoot(0.6, Item.L_COMPP, 'ghoulblood');
					newLoot(0.2, Item.L_COMPP, 'pinkslime');
					if (hero>0) newLoot(0.6, Item.L_COMPM, 'darkfrag');
				break;

				case 'zombie8':
					newLoot(0.6, Item.L_COMPP, 'ghoulblood');
					newLoot(1, Item.L_COMPP, 'pinkslime');
					if (hero>0) newLoot(0.8, Item.L_COMPM, 'darkfrag');
				break;

				case 'zombie9':
					newLoot(0.6, Item.L_COMPP, 'ghoulblood');
					newLoot(1, Item.L_COMPP, 'whorn');
					if (hero>0) newLoot(1, Item.L_COMPM, 'darkfrag');
				break;

				case 'bloodwing':
					newLoot(0.2, Item.L_COMPP, 'wingmembrane');
					newLoot(0.16, Item.L_COMPP, 'vampfang');
					newLoot(0.25, Item.L_FOOD, 'meat');
				break;

				case 'bloodwing2':
					newLoot(0.3, Item.L_COMPP, 'wingmembrane');
					newLoot(0.2, Item.L_COMPP, 'vampfang');
					newLoot(0.4, Item.L_COMPP, 'pinkslime');
				break;

				case 'bloat0':
					newLoot(0.2, Item.L_COMPP, 'bloatwing');
					newLoot(0.1, Item.L_COMPP, 'bloateye');
				break;

				case 'bloat1':
					newLoot(0.2, Item.L_COMPP, 'bloatwing');
					newLoot(0.1, Item.L_COMPP, 'bloateye');
					newLoot(0.2, Item.L_COMPP, 'acidslime');
				break;

				case 'bloat2':
					newLoot(0.2, Item.L_COMPP, 'bloatwing');
					newLoot(0.1, Item.L_COMPP, 'bloateye');
					newLoot(0.1, Item.L_COMPP, 'gland');
				break;

				case 'bloat3':
					newLoot(0.3, Item.L_COMPP, 'bloatwing');
					newLoot(0.2, Item.L_COMPP, 'bloateye');
					newLoot(0.1, Item.L_COMPP, 'molefat');
				break;

				case 'bloat4':
					newLoot(0.4, Item.L_COMPP, 'bloatwing');
					newLoot(0.3, Item.L_COMPP, 'bloateye');
				break;

				case 'rat':
					newLoot(0.35, Item.L_COMPP, 'ratliver');
					newLoot(0.25, Item.L_COMPP, 'rattail');
					newLoot(0.1, Item.L_FOOD, 'meat');
				break;

				case 'molerat':
					newLoot(0.5, Item.L_COMPP, 'ratliver');
					newLoot(1, Item.L_COMPP, 'molefat');
					newLoot(0.25, Item.L_FOOD, 'meat');
				break;

				case 'fish1':
					newLoot(0.5, Item.L_COMPP, 'fishfat');
				break;

				case 'fish2':
					newLoot(1, Item.L_COMPP, 'fishfat');
				break;

				case 'ant1':
					newLoot(0.15, Item.L_COMPA, 'chitin_comp');
					newLoot(0.1, Item.L_FOOD, 'meat');
				break;

				case 'ant2':
					newLoot(0.3, Item.L_COMPA, 'chitin_comp');
					newLoot(0.1, Item.L_FOOD, 'meat');
				break;

				case 'ant3':
					newLoot(0.2, Item.L_COMPA, 'chitin_comp');
					newLoot(1, Item.L_COMPP, 'firegland');
					newLoot(0.1, Item.L_FOOD, 'meat');
				break;

				case 'necros':
					newLoot(0.5, Item.L_ITEM, 'dsoul');
				break;

				case 'ebloat':
					newLoot(1, Item.L_COMPP, 'essence');
				break;

				case 'turret':
					newLoot(0.5, Item.L_ITEM, 'scrap');
					newLoot(0.35, Item.L_COMPW, 'frag');
					if (!newLoot(0.2, Item.L_AMMO, 'batt')) newLoot(0.2, Item.L_AMMO,'energ');
				break;

				case 'turret1':
					newLoot(0.5, Item.L_ITEM, 'scrap');
					newLoot(0.5, Item.L_ITEM, 'scrap');
					newLoot(0.85, Item.L_COMPW, 'frag');
					newLoot(0.52, Item.L_COMPA, 'magus_comp');
					if (!newLoot(0.4, Item.L_AMMO, 'batt')) newLoot(0.8, Item.L_AMMO,'energ');
				break;

				case 'robobrain':
					newLoot(0.25, Item.L_ITEM, 'scrap');
					newLoot(0.15, Item.L_COMPW, 'frag');
					newLoot(0.5, Item.L_COMPM);
					newLoot(0.5, Item.L_AMMO, 'batt');
					newLoot(0.4, Item.L_COMPA, 'metal_comp');
					if (hero>0) newLoot(1, Item.L_COMPM, 'impgen');
				break;

				case 'protect':
					newLoot(0.3, Item.L_ITEM, 'scrap');
					newLoot(0.25, Item.L_COMPW, 'frag');
					newLoot(0.6, Item.L_COMPM);
					newLoot(0.9, Item.L_AMMO, 'batt');
					newLoot(0.4, Item.L_COMPA, 'metal_comp');
					if (hero>0) newLoot(1, Item.L_COMPM, 'uscan');
				break;

				case 'gutsy':
					newLoot(0.45, Item.L_ITEM, 'scrap');
					newLoot(0.5, Item.L_COMPW, 'frag');
					newLoot(0.7, Item.L_COMPM);
					newLoot(0.85, Item.L_COMPA, 'battle_comp');
					if (!newLoot(0.4, Item.L_AMMO, 'fuel')) newLoot(0.75, Item.L_AMMO, 'energ');
					if (hero>0) newLoot(1, Item.L_COMPM, 'tlaser');
				break;

				case 'eqd':
					newLoot(0.45, Item.L_ITEM, 'scrap');
					newLoot(0.5, Item.L_COMPW, 'frag');
					newLoot(0.8, Item.L_COMPM);
					newLoot(0.85, Item.L_COMPA, 'magus_comp');
					newLoot(1, Item.L_AMMO, 'energ');
					newLoot(0.5, Item.L_ITEM, 'data');
					if (hero>0) newLoot(1, Item.L_COMPM, 'pcrystal');
				break;

				case 'sentinel':
					newLoot(0.85, Item.L_ITEM, 'scrap');
					newLoot(0.5, Item.L_COMPW, 'frag');
					newLoot(1, Item.L_COMPM);
					if (!newLoot(0.4, Item.L_AMMO, 'p5')) newLoot(1, Item.L_AMMO, 'crystal');
					newLoot(0.85, Item.L_AMMO, 'rocket');
					newLoot(0.5, Item.L_COMPW);
					newLoot(1, Item.L_COMPM, 'motiv');
				break;

				case 'vortex':
				case 'spritebot':
				case 'roller':
					newLoot(0.2, Item.L_ITEM, 'scrap');
				break;

			}
			return is_loot > 0;
		}
		
		public static function replic(s:String):void 
		{
			if (isrnd()) GameSession.currentSession.gg.replic(s);
		}	
		
		protected static function isrnd(n:Number = 0.5):Boolean 
		{
			return Math.random() < n;
		}	
	}	
}