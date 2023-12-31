package unitdata 
{

	import fl.controls.progressBarClasses.IndeterminateBar;
	import flash.sampler.StackFrame;

	import weapondata.*;
	import servdata.Item;
	import servdata.LootGen;
	import servdata.Script;
	import servdata.QuestHelper;
	import locdata.Loot;
	
	import components.Settings;
	import components.XmlBook;
	
	public class Invent 
	{
		public var gg:UnitPlayer;
		public var owner:Unit;
		
		public var weapons:Array;
		public var fav:Array;		//массив избранного по номеру ячейки
		public var favIds:Array;	//массив избранного по id предмета
		public var cWeaponId:String='';
		
		public var armors:Array;
		public var cArmorId:String='';
		public var cAmulId:String='';
		public var prevArmor:String='';
		
		public var spells:Array;
		public var cSpellId:String='';
		
		public var items:Array;	//все вещи по id (Item)
		public var eqip:Array;	//все вещи, относящиеся к экипировке
		public var ammos:Array;	//количество патронов по базе
		public var money:Item, pin:Item, gel:Item, good:Item;
		public var itemsId:Array;
		public var cItem:int=-1, cItemMax:int;
		
		public var mass:Array=[0,0,0,0];
		public var massW:int=0;
		public var massM:int=0;
		
		public function Invent(own:Unit,loadObj:Object = null, opt:Object = null) 
		{
			owner = own;
			weapons = [];
			favIds 	= [];
			armors 	= [];
			spells 	= [];
			items 	= [];
			eqip 	= [];
			ammos 	= [];
			fav 	= [];
			
			itemsId = [];
			for each (var node in XmlBook.getXML("items").item) 
			{
				var item:Item = new Item(node.@tip, node.@id, 0, 0, node);
				items[node.@id] = item;
				if (node.@us >= 2) itemsId.push(node.@id);
				if (item.invCat == 1 && item.mass > 0 && node.@perk.length() == 0) eqip.push(node.@id);
				if (node.@base.length()) ammos[node.@base] = 0;
			}
			money = items['money'];
			pin = items['pin'];
			gel = items['gel'];
			good = items['good'];
			items[''] = new Item('', '', 0, 0, <item/>);
			if (loadObj == null) 
			{
				if (opt && opt.skipTraining) addMin();
				else addBegin();
			} 
			else addLoad(loadObj);
			cItemMax = itemsId.length;
		}
		
		public function nextItem(n:int=1):void
		{
			var ci = cItem + n;
			if (ci >= cItemMax) ci = 0;
			if (ci < 0) ci = cItemMax - 1;
			for (var i:int = 0; i < cItemMax; i++) 
			{
				if (items[itemsId[ci]].kol > 0) 
				{
					cItem = ci;
					break;
				}
				ci += n;
				if (ci >= cItemMax) ci = 0;
				if (ci < 0) ci = cItemMax - 1;
			}
			GameSession.currentSession.gui.setItems();
		}
		
		//выбрать подходящий мед. прибор
		public function getMed(n:int):String 	//$$$
		{
			var nhp:Number = 0;
			if (n == 1) 	 nhp = gg.pers.inMaxHP - gg.pers.headHP;
			else if (n == 2) nhp = gg.pers.inMaxHP - gg.pers.torsHP;
			else if (n == 3) nhp = gg.pers.inMaxHP - gg.pers.legsHP;
			else return '';
			var list = XmlBook.getXML("items").item;
			var minRazn:Number = 10000;
			var nci:String='';
			for each (var pot in list) 
			{
				if (pot.@heal=='organ' && items[pot.@id].kol > 0 && (pot.@minmed.length() == 0 || pot.@minmed <= gg.pers.medic)) 
				{
					var hhp = 0;
					if (pot.@horgan.length()) hhp = pot.@horgan;
					var razn = Math.abs(hhp - nhp + 25);
					if (razn < minRazn) 
					{
						minRazn = razn;
						nci = pot.@id;
					}
				}
			}
			return nci;
		}
		
		public function usePotion(ci:String=null, norgan:int=0):Boolean
		{
			var hhp:Number=0, hhplong:Number=0;
			var pot;
			var pet:UnitPet;
			var need1=gg.maxhp-gg.hp-gg.rad;	//нужда с учётом фактического здоровья
			var need2=need1-gg.healhp;			//нужда с учётом принятых зелий
			if (ci!=null && ci!='mana' && items[ci].kol<=0) return false;
			if (ci==null && need2<1)
			{
				GameSession.currentSession.gui.infoText('noHeal');
				if (gg.rad>1) GameSession.currentSession.gui.infoText('useAntirad');
				return false;
			}
			if (ci==null) 	//применить наиболее подходящее зелье
			{
				var list:XMLList = XmlBook.getXML("items").item;
				var minRazn:Number=10000;
				var nci:String='';
				for each (pot in list) {
					if (pot.@heal=='hp' && items[pot.@id].kol>0) 
					{
						hhp=0;
						if (pot.@hhp.length()) hhp+=pot.@hhp*gg.pers.healMult;
						if (pot.@hhplong.length()) hhp+=pot.@hhplong*gg.pers.healMult;
						var razn=Math.abs(hhp-need2);
						if (razn<minRazn) 
						{
							minRazn=razn;
							nci=pot.@id;
						}
					}
				}
				if (nci=='') 	//нет подходящего
				{
					GameSession.currentSession.gui.infoText('noSuitablePot');
					return false;
				} else ci=nci;
			}
			if (ci=='mana') 	//применить наиболее подходящее зелье маны
			{
				list = XmlBook.getXML("items").item;
				var minRazn:Number=10000;
				need1=gg.pers.inMaxMana-gg.pers.manaHP;
				if (need1<1) return false;
				var nci:String='';
				for each (pot in list) 
				{
					if (pot.@heal=='mana' && items[pot.@id].kol>0) 
					{
						hhp=0;
						if (pot.@hmana.length()) hhp=pot.@hmana;
						var razn=Math.abs(hhp-need1);
						if (razn<minRazn) 
						{
							minRazn=razn;
							nci=pot.@id;
						}
					}
				}
				if (nci=='') 	//нет подходящего
				{
					GameSession.currentSession.gui.infoText('noSuitablePot');
					return false;
				} 
				else ci=nci;
			}
			if (ci == 'potion_swim') 
			{
				gg.h2o = 1000;
			}
			pot = XmlBook.getXML("items").item.(@id == ci);
			if (pot.length() == 0) return false;
			
			if (Settings.alicorn) 
			{
				if (pot.@tip == 'pot' || pot.@tip == 'him' || pot.@tip == 'food') 
				{
					GameSession.currentSession.gui.infoText('alicornNot', null, null, false);
					return false;
				}
			}
			if (pot.@heal == 'rad' && gg.rad < 1) 
			{
				GameSession.currentSession.gui.infoText('noMedic',Res.txt('item',ci));
				return false;
			} 
			else if (pot.@heal=='poison' && gg.poison<0.1) 
			{
				GameSession.currentSession.gui.infoText('noMedic',Res.txt('item',ci));
				return false;
			} 
			else if (pot.@heal=='blood' && (gg.pers.inMaxHP-gg.pers.bloodHP<1)) 
			{
				GameSession.currentSession.gui.infoText('noMedic',Res.txt('item',ci));
				return false;
			} 
			else if (pot.@heal=='organ' && (gg.pers.inMaxHP-gg.pers.headHP<1) && (gg.pers.inMaxHP-gg.pers.torsHP<1) && (gg.pers.inMaxHP-gg.pers.legsHP<1)) 
			{
				GameSession.currentSession.gui.infoText('noHeal');
				return false;
			} 
			else if (pot.@heal=='mana' && (gg.pers.inMaxMana-gg.pers.manaHP<1)) 
			{
				GameSession.currentSession.gui.infoText('noMedic',Res.txt('item',ci));
				return false;
			} 
			else if (pot.@heal=='pet') 	//лечение феникса
			{
				pet=gg.pets[pot.@pet];
				if (pet==null || pet.maxhp-pet.hp<1) 
				{
					GameSession.currentSession.gui.infoText('noMedic',Res.txt('item',ci));
					return false;
				}
			}
			//проверить соответствие уровню навыка
			if (pot.@minmed.length() && pot.@minmed>gg.pers.medic) 
			{
				 GameSession.currentSession.gui.infoText('needSkill',Res.txt('eff','medic'),pot.@minmed);
				  return false;
			}
			if (pot.@heal=='detoxin') 
			{
				var limAddict:int=pot.@detox;
				for (var j:int = 0; j < 5; j++) 
				{
					for (var ad in GameSession.currentSession.pers.addictions) 
					{
						if (GameSession.currentSession.pers.addictions[ad]>0) 
						{
							var redAddict=Math.round(Math.random()*50+25);
							if (redAddict>GameSession.currentSession.pers.addictions[ad]) 
							{
								limAddict-=GameSession.currentSession.pers.addictions[ad];
								GameSession.currentSession.pers.addictions[ad]=0;
							} 
							else 
							{
								limAddict-=redAddict;
								GameSession.currentSession.pers.addictions[ad]-=redAddict;
							}
						}
						if (limAddict<=0) break;
					}
					if (limAddict<=0) break;
				}
				for each(var eff:Effect in owner.effects) 
				{
					if (eff.him==1 || eff.him==2) 
					{
						eff.unsetEff(false,true,false);
					}
				}
				gg.setAddictions();
				gg.pers.setParameters();
			}
			hhp=hhplong=0;
			if (pot.@hhp.length()) hhp=pot.@hhp*gg.pers.healMult;
			if (pot.@hhplong.length()) hhplong=pot.@hhplong*gg.pers.healMult;
			gg.heal(hhp,0,false);
			gg.heal(hhplong,1,false);
			if (hhp+hhplong>0) gg.numbEmit.castSpell(gg.room,gg.X,gg.Y-gg.scY/2,{txt:Math.round(hhp+hhplong), frame:4, rx:20, ry:20});
			
			if (pot.@hrad.length()) gg.heal(pot.@hrad*gg.pers.healMult,2);
			if (pot.@hpoison.length()) gg.heal(pot.@hpoison, 4, false);
			if (pot.@hcut.length()) gg.heal(pot.@hcut, 3, false);
			if (pot.@horgan.length()) gg.pers.heal(pot.@horgan,norgan);
			if (pot.@horgans.length()) gg.pers.heal(pot.@horgans,4);
			if (pot.@hblood.length()) gg.pers.heal(pot.@hblood,5);
			if (pot.@hmana.length()) gg.pers.heal(pot.@hmana, 6);
			if (pot.@hpurif.length()) {
				for each(var eff:Effect in owner.effects) 
				{
					if (eff.tip==4) 
					{
						eff.unsetEff(false,true,false);
					}
				}
				gg.remEffect('curse');
				GameSession.currentSession.game.triggers['curse']=0;
				gg.pers.setParameters();
			}
			if (pot.@hpet.length()) 
			{
				pet=gg.pets[pot.@pet];
				pet.heal(pot.@hpet, 0);
			}
			if (pot.@perk.length()) 
			{
				gg.pers.addPerk(pot.@perk);
			}
			if (pot.@effect.length()) 
			{
				var eff:Effect=gg.addEffect(pot.@effect);
				if (pot.@tip=='him') 
				{
					if (gg.pers.himLevel>0) 
					{
						eff.lvl=gg.pers.himLevel;
						gg.pers.setParameters();
					}
					eff.t*=gg.pers.himTimeMult;
				}
			}
			if (pot.@alc.length()) 
			{
				gg.addEffect('drunk',0,pot.@alc*10);
			}
			if (pot.@rad.length()) 
			{
				gg.drad2+=pot.@rad*1;
				trace(pot.@rad, gg.drad2)
			}
			if (pot.@ad.length()) 
			{
				var n1:int=pot.@admin;
				var n2:int=pot.@admax;
				var n:int=Math.round(Math.random()*(n2-n1)+n1)*gg.pers.himBadMult*gg.pers.himBadDif;
				if (gg.pers.addictions[pot.@ad]==null) gg.pers.addictions[pot.@ad]=0;
				var prev:int=gg.pers.addictions[pot.@ad];
				gg.pers.addictions[pot.@ad]+=n;
				if (gg.pers.addictions[pot.@ad]>gg.pers.admax) gg.pers.addictions[pot.@ad]=gg.pers.admax;
				if (prev<gg.pers.ad3 && prev+n>=gg.pers.ad3) GameSession.currentSession.gui.infoText('addiction3',Res.txt('item',ci));
				else if (prev<gg.pers.ad2 && prev+n>=gg.pers.ad2) GameSession.currentSession.gui.infoText('addiction2',Res.txt('item',ci));
				else if (prev<gg.pers.ad1 && prev+n>=gg.pers.ad1) GameSession.currentSession.gui.infoText('addiction1',Res.txt('item',ci));
			}
			if (pot.@tip=='food') 
			{
				if (pot.@ftip=='1') GameSession.currentSession.gui.infoText('usedfood2',Res.txt('item',ci));
				else GameSession.currentSession.gui.infoText('usedfood',Res.txt('item',ci));
			} 
			else if (pot.@heal=='organ') GameSession.currentSession.gui.infoText('usedheal',Res.txt('item',ci));
			else GameSession.currentSession.gui.infoText('heal',Res.txt('item',ci));
			if (pot.@inf>0) return true;
			minusItem(ci);
			return true;
		}
		
		public function useItem(ci:String=null):Boolean 
		{
			if (ci==null) 
			{
				if (cItem<0) return false;
				if (GameSession.currentSession.gui.t_item<=0) 
				{
					GameSession.currentSession.gui.setItems();
					return false;
				} 
				else 
				{
					ci=itemsId[cItem];
				}
			}
			if (ci=='mworkbench' || ci=='mworkexpl' || ci=='mworklab') 
			{
				if (GameSession.currentSession.t_battle>0) 
				{
					GameSession.currentSession.gui.infoText('noUseCombat',null,null,false);
					return false;
				}
				GameSession.currentSession.pip.workTip=ci;
				GameSession.currentSession.pip.onoff(7);
				return false;
			}
			if (items[ci].kol<=0) return false;
			var item=items[ci].xml;
			if (item==null) return false;
			var tip:String=item.@tip;
			if (item.@paint.length())  //краска
			{
				gg.changePaintWeapon(item.@id,item.@paint,item.@blend);
				GameSession.currentSession.gui.infoText('inUse',items[ci].objectName);
				return true;
			}
			if (item.@text.length())  //документ
			{
				if (GameSession.currentSession.t_battle>0) 
				{
					GameSession.currentSession.gui.infoText('noUseCombat',null,null,false);
					return false;
				}
				GameSession.currentSession.pip.onoff(-1);
				GameSession.currentSession.gui.dialog(item.@text);
				if (item.@perk.length()) 
				{
					gg.pers.addPerk(item.@perk);
				}
				return true;
			}
			if (ci=='rollup') 
			{
				if (!useRollup()) return false;
			} 
			else if (tip=='med' || tip=='him' || tip=='pot') 
			{
				return (usePotion(ci));
			} 
			else if (tip=='food') 
			{
				if (Settings.alicorn) 
				{
					GameSession.currentSession.gui.infoText('alicornNot',null,null,false);
					return false;
				}
				if (GameSession.currentSession.t_battle>0) 
				{
					GameSession.currentSession.gui.infoText('noUseCombat',null,null,false);
					return false;
				}
				return (usePotion(ci));
			} 
			else if (tip=='spell') 
			{
				if (Settings.alicorn) 
				{
					GameSession.currentSession.gui.infoText('alicornNot',null,null,false);
					return false;
				}
				gg.changeSpell(ci);
				return false;
			} 
			else if (tip=='book') 
			{
				if (GameSession.currentSession.t_battle>0) 
				{
					GameSession.currentSession.gui.infoText('noUseCombat',null,null,false);
					return false;
				}
				if (Settings.hardInv && !GameSession.currentSession.room.base) 
				{
					GameSession.currentSession.gui.infoText('noBase');
					return false;
				}
				if (item.@perk.length()) 
				{
					gg.pers.addPerk(item.@perk);
				} 
				else 
				{
					gg.pers.upSkill(ci);
				}
				items['lbook'].kol++;
			} 
			else if (ci=='sphera') 
			{
				if (GameSession.currentSession.t_battle>0) 
				{
					GameSession.currentSession.gui.infoText('noUseCombat',null,null,false);
					return false;
				}
				if (Settings.hardInv && !GameSession.currentSession.room.base) 
				{
					GameSession.currentSession.gui.infoText('noBase');
					return false;
				}
				gg.pers.addSkillPoint(1, true);
			} 
			else if (ci=='runa' || ci=='reboot') 
			{
				return false;
			} 
			else if (ci=='rep') 
			{
				if (!repWeapon(gg.currentWeapon)) return false;
			} 
			else if (ci=='stealth') 
			{
				if (Settings.alicorn) 
				{
					GameSession.currentSession.gui.infoText('alicornNot',null,null,false);
					return false;
				}
				gg.addEffect('stealth');
			} 
			else if (item.@pet.length()) 
			{
				if (Settings.alicorn) 
				{
					GameSession.currentSession.gui.infoText('alicornNot',null,null,false);
					return false;
				}
				gg.callPet(item.@pet);
				return true;
			} 
			else if (item.@chdif.length()) 	//карта судьбы
			{
				if (!GameSession.currentSession.game.changeDif(item.@chdif)) return false;
				GameSession.currentSession.gui.infoText('changeDif',Res.txt('gui', 'dif'+item.@chdif));
			} 
			else return false;
			minusItem(ci);
			if (ci==itemsId[cItem] && GameSession.currentSession.gui.t_item>0) GameSession.currentSession.gui.setItems();
			GameSession.currentSession.calcMass=true;
			return true;
		}
		
		//TODO: This checks multiple XML files instead of the correct one.
		public function useFav(n:int):void
		{
			var ci:String = fav[n];
			if (ci == null) return;

			var item:XMLList;

			item = XmlBook.getXML("weapons").weapon.(@id == ci);
			if (item.length()) 
			{
				gg.changeWeapon(ci);
				return;
			}

			item = XmlBook.getXML("armors").armor.(@id == ci);
			if (item.length()) 
			{
				gg.changeArmor(ci);
				return;
			}

			item = XmlBook.getXML("items").item.(@id == ci);
			if (item.length()) 
			{
				useItem(ci);
			}
		}
		
		public function addWeapon(id:String, hp:int = 0xFFFFFF, hold:int = 0, respect:int = 0, nvar:int = 0):Weapon 
		{
			if (id == null) return null;
			if (weapons[id]) 
			{
				weapons[id].repair(hp);
				return weapons[id];
			}

			var w:Weapon = Weapon.create(owner, id, nvar);

			if (w == null)
			{
				trace ('Invent.as/addWeapon() - ERROR while attempting to add weapon: "' + id + '". Weapon.create() failed, Weapon is null.')
				return null;
			} 

			if (w.tip == 5 || hp == 0xFFFFFF) w.hp = w.maxhp;
			else w.hp=hp;

			if (hold>0) w.hold=hold;
			if (w.tip==4 && respect==3) respect=0;

			w.respect=respect;
			weapons[id]=w;

			return w;
		}
		
		public function remWeapon(id:String):void
		{
			if (weapons[id]) 
			{
				if (weapons[id]==gg.currentWeapon) gg.changeWeapon(id,true);
				if (weapons[id].hold>0) 
				{
					items[weapons[id].ammo].kol+=weapons[id].hold;
					weapons[id].hold=0;
				}
				if (items['s_'+id] && items['s_'+id].kol>0) weapons[id].respect=3;
				else weapons[id]=null;
			}
		}
		
		public function updWeapon(id:String, nvar:int):void
		{
			if (weapons[id]==null) addWeapon(id);
			weapons[id].updVariant(nvar);
		}
		
		//показать/скрыть оружие
		public function respectWeapon(id:String):int 
		{
			var w:Weapon=weapons[id];
			if (w==null) return 2;
			if (w.respect==0 || w.respect==2) w.respect=1;
			else w.respect=2;
			if (gg.currentWeapon && gg.currentWeapon.respect==1) 
			{
				gg.changeWeapon(gg.currentWeapon.id);
			}
			if (w.respect==1 && gg.currentSpell && gg.currentSpell.id==w.id) 
			{
				gg.changeSpell('');
			}
			calcWeaponMass();
			return w.respect;
		}
		
		//ремонтировать оружие с помощью набора оружейника или деталей
		public function repWeapon(w:Weapon, koef:Number=1):Boolean 
		{
			if (w && w.tip>0 && w.tip<4 && w.rep_eff>0) 
			{
				if (w.hp<w.maxhp) 
				{
					var hhp=w.maxhp*gg.pers.repairMult*w.rep_eff*koef;
					w.repair(hhp);
					GameSession.currentSession.gui.infoText('repairWeapon',w.objectName,Math.round(w.hp/w.maxhp*100));
					GameSession.currentSession.gui.setWeapon();
				} 
				else 
				{
					GameSession.currentSession.gui.infoText('noRepair');
					return false;
				}
			} 
			else 
			{
				GameSession.currentSession.gui.infoText('noRepair2');
				return false;
			}
			return true;
		}
		
		public function repairWeapon(id:String, kol:int):void
		{
			if (kol==undefined || isNaN(kol)) return;
			var hpw=(weapons[id] as Weapon).hp;
			var rep=Math.round(kol*gg.pers.repairMult);
			if (hpw<kol) rep=Math.round(kol-hpw+hpw*gg.pers.repairMult);
			(weapons[id] as Weapon).repair(rep);
			if (gg.pers.barahlo) 
			{
				var n:Number=kol/(weapons[id] as Weapon).maxhp/(weapons[id] as Weapon).rep_eff;
				if ((weapons[id] as Weapon).rep_eff<=0) return;
				if (n<0.3) n=0.3;
				if (n<1 && n<Math.random()) return;
				n=Math.round(n);
				items['frag'].kol+=n;
				if(!GameSession.currentSession.testLoot) GameSession.currentSession.gui.infoText('take',Res.txt('item','frag')+((n>1)?(' ('+n+')'):''));
			}
		}
		public function favItem(id:String, cell:int):void
		{
			if (gg && (cell==29 || cell==30)) 
			{
				if (weapons[id]==null || (weapons[id].tip!=4 && weapons[id].tip!=5) || weapons[id].spell) 
				{
					GameSession.currentSession.gui.infoText('onlyExpl');
					return;
				}
				if (cell==29) 
				{
					if (gg.throwWeapon && id==gg.throwWeapon.id) gg.throwWeapon=null;
					else 
					{
						gg.throwWeapon=weapons[id];
						gg.throwWeapon.setNull();
						gg.throwWeapon.setPers(gg,gg.pers);
						gg.throwWeapon.addVisual();
						if (gg.throwWeapon.tip==4) gg.throwWeapon.remVisual();
					}
				}
				if (cell==30) 
				{
					if (gg.magicWeapon && id==gg.magicWeapon.id) gg.magicWeapon=null;
					else 
					{
						gg.magicWeapon=weapons[id];
						gg.magicWeapon.setNull();
						gg.magicWeapon.setPers(gg,gg.pers);
						gg.magicWeapon.addVisual();
						if (gg.magicWeapon.tip==4) gg.magicWeapon.remVisual();
					}
				}
			}
			if (cell<29 && cell>=25) 
			{
				var xml:XMLList = XmlBook.getXML("items").item.(@id == id);
				if (xml.length()==0 || xml.@tip!='spell') 
				{
					GameSession.currentSession.gui.infoText('onlySpell');
					return;
				}
			}
			var prevCell=favIds[id];
			var prevId=fav[cell];
			if (fav[prevCell]) fav[prevCell] = null;
			if (favIds[prevId]) favIds[prevId] = null;
			if (prevCell != cell)
			{
				fav[cell] = id;
				favIds[id] = cell;
			}
		}
		
		public function addArmor(id:String, hp:int=0xFFFFFF, nlvl:int = 0):Armor 
		{
			if (armors[id]) return null;
			var node:XMLList = XmlBook.getXML("armors").armor.(@id == id);
			if (!node) return null;
			var w:Armor = new Armor(id, nlvl);
			w.hp=hp;
			if (w.hp>w.maxhp) w.hp=w.maxhp;
			armors[id]=w;
			return w;
		}
		
		public function addSpell(id:String):Spell 
		{

			if (spells == null)
			{
				trace('Invent.as/addSpell() - ERROR: inventory spells is null.');
				return null;
			}
			if (id == null) 
			{
				trace('Invent.as/addSpell() - ERROR: spell ID is null.');
				return null;
			}
			if (spells[id]) 
			{
				return spells[id];
			}

			var sp:Spell = new Spell(owner, id);

			if (sp == null) 
			{
				trace('Invent.as/addSpell() - ERROR: New spell is null.');
				return null;
			}
			spells[id] = sp;

			var w:Weapon = addWeapon(id);
			if (w == null)
			{
				trace('Invent.as/addSpell() - ERROR: New weapon is null.');
				return null;
			}

			w.spell = true;
			w.objectName = sp.objectName;

			return sp;
		}
		
		public function addAllSpells():void
		{
			for each (var sp in XmlBook.getXML("items").item.(@tip == 'spell')) 
			{
				try
				{
					addSpell(sp.@id);
				}
				catch(err:Error)
				{
					trace('Invent.as/addAllSpells() - ERROR while adding spell: "' + sp.@id + '".');
				}
			}
		}
		
		// Add to the inventory, tr = 1 if the item was purchased, 2 if it was obtained as a reward
		public function take(l:Item, tr:int = 0):void
		{
			var kol:int=0;
			var color:int=-1;
			try 
			{
				if (l.tip==Item.L_WEAPON) 
				{
					var patron=l.xml.a[0];
					if (tr==0 && patron && patron!='recharg') 
					{
						var itemXML:XMLList = XmlBook.getXML("items").item.(@id == patron);
						kol = Math.floor(Math.random() * itemXML.@kol) + 1;
						items[patron].kol += kol;
					}
					var hp:int;
					if (l.variant>0 && l.xml.char[l.variant].@maxhp.length()) hp=Math.round(l.xml.char[l.variant].@maxhp*l.sost*l.multHP);
					else hp=Math.round(l.xml.char[0].@maxhp*l.sost*l.multHP);
					if (weapons[l.id])
					{
						if (weapons[l.id].variant<l.variant) 
						{
							if (tr==0 && !GameSession.currentSession.testLoot) GameSession.currentSession.gui.infoText('takeWeapon',l.objectName,Math.round(l.sost*l.multHP*100));
							updWeapon(l.id,l.variant);
						}
						if (weapons[l.id].tip!=5) 
						{
							repairWeapon(l.id, hp);
							if (!GameSession.currentSession.testLoot) GameSession.currentSession.gui.infoText('repairWeapon',weapons[l.id].objectName,Math.round(weapons[l.id].hp/weapons[l.id].maxhp*100));
						}
					} 
					else 
					{
						if (tr == 0 && !GameSession.currentSession.testLoot) GameSession.currentSession.gui.infoText('takeWeapon',l.objectName,Math.round(l.sost*l.multHP*100));
						addWeapon(l.id, hp, 0,0, l.variant);
						takeScript(l.id);
						if (owner.player && gg.currentWeapon==null) gg.changeWeapon(l.id);
					}
					if (l.shpun==2) weapons[l.id].respect=0;
					GameSession.currentSession.gui.setWeapon();
					GameSession.currentSession.calcMassW=true;
					color=5;
				} 
				else if (l.tip==Item.L_ARMOR) 
				{
					var hp:int=Math.round(l.xml.@hp*l.sost*l.multHP);
					addArmor(l.id, hp);
					color=3;
				} 
				else if (l.tip==Item.L_SPELL) 
				{
					plus(l,tr);
					GameSession.currentSession.calcMassW=true;
					color=5;
				} 
				else if (l.tip==Item.L_SCHEME) 
				{
					if (items[l.id].kol==0)	takeScript(l.id);
					plus(l,tr);
					if (tr <=1 && !GameSession.currentSession.testLoot) GameSession.currentSession.gui.infoText('take',l.objectName);
					if (l.xml && l.xml.@cat=='weapon' && weapons[l.id.substr(2)]==null) 
					{
						addWeapon(l.id.substr(2), 0xFFFFFF, 0,3);
					}
					if (l.xml && l.xml.@cat=='armor' && armors[l.id.substr(2)]==null) 
					{
						addArmor(l.id.substr(2), 0xFFFFFF, -1);
					}
					color=7;
				} 
				else if (l.tip==Item.L_EXPL) 
				{
					plus(l,tr);
					if (!weapons[l.id]) addWeapon(l.id);
					if (tr==0 && !GameSession.currentSession.testLoot) GameSession.currentSession.gui.infoText('take',l.objectName+((l.kol>1)?(' ('+l.kol+')'):''));
					color=3;
				} 
				else if (l.tip==Item.L_AMMO) 
				{
					plus(l,tr);
					if (tr==0 && !GameSession.currentSession.testLoot) GameSession.currentSession.gui.infoText('takeAmmo',l.objectName,l.kol);
					color=3;
				} 
				else if (l.tip==Item.L_MED) 
				{
					plus(l,tr);
					if (tr==0 && !GameSession.currentSession.testLoot) GameSession.currentSession.gui.infoText('takeMed',l.objectName);
					if (cItem<0) nextItem(1);
					else GameSession.currentSession.gui.setItems();
					color=1;
				} 
				else if (l.tip==Item.L_BOOK) 
				{
					if (items[l.id].kol==0)	takeScript(l.id);
					plus(l,tr);
					if (tr <= 1 && !GameSession.currentSession.testLoot) GameSession.currentSession.gui.infoText('takeBook',l.objectName);
					if (cItem<0) nextItem(1);
					else GameSession.currentSession.gui.setItems();
					color=4;
				} 
				else if (l.tip==Item.L_INSTR || l.tip==Item.L_ART || l.tip==Item.L_IMPL || l.xml && l.xml.sk.length()) 
				{
					if (items[l.id].kol==0)	takeScript(l.id);
					plus(l,tr);
					if (tr==0 && !GameSession.currentSession.testLoot) GameSession.currentSession.gui.infoText('take',l.objectName);
					gg.pers.setParameters();
					color=6;
				} 
				else 
				{
					if (items[l.id].kol==0)	takeScript(l.id);
					plus(l,tr);
					if (tr==0 && !GameSession.currentSession.testLoot) {
						if (l.id=='money') GameSession.currentSession.gui.infoText('takeMoney',l.kol);
						else GameSession.currentSession.gui.infoText('take',l.objectName+((l.kol>1)?(' ('+l.kol+')'):''));
					}
					if (cItem<0) nextItem(1);
					else GameSession.currentSession.gui.setItems();
					
					if (l.tip=='valuables') color=2;
					else if (l.tip==Item.L_HIM || l.tip==Item.L_POT) color=1;
					else if (l.tip==Item.L_KEY || l.tip==Item.L_SPEC) color=6;
					else if (l.tip=='equip') color=8;
					else color=0;
				}
				if (tr==2) 
				{
					if (l.kol>1) GameSession.currentSession.gui.infoText('reward',l.objectName,l.kol);
					else GameSession.currentSession.gui.infoText('reward2',l.objectName);
				}
				//если объект был сгенерирован случайно, обновить лимиты
				if (tr==0 && l.imp==0 && l.xml.@limit.length()) 
				{
					GameSession.currentSession.game.addLimit(l.xml.@limit,2);
				}
				//всплывающее сообщение
				if (!GameSession.currentSession.testLoot && (tr==0 || tr==2)) 
				{
					if (l.fc>=0) color=l.fc;
					GameSession.currentSession.gui.floatText(l.objectName+(l.kol>1?(' ('+l.kol+')'):''), gg.X, gg.Y, color);
				}
				//информационное окно для важных предметов
				if (Settings.helpMess || l.tip=='art') 
				{
					if (l.mess!=null && !(GameSession.currentSession.game.triggers['mess_'+l.mess]>0)) 
					{
						GameSession.currentSession.game.triggers['mess_'+l.mess]=1;
						GameSession.currentSession.gui.impMess(Res.txt('item',l.mess),Res.txt('item',l.mess,2),l.mess);
					}
				}
				//если объект критичный, подтвердить получение
				if (l.imp==2 && l.cont) l.cont.receipt();
				var res:String = QuestHelper.checkQuests(l.id);
				if (res!=null) 
				{
					GameSession.currentSession.gui.infoText('collect',res);
				}
			} catch (err) 
			{
				GameSession.currentSession.showError(err, 'Loot error. tip:' + l.tip + ' id:' + l.id);
			}
			if (Settings.hardInv) mass[l.invCat]+=l.mass*l.kol;
			GameSession.currentSession.calcMass=true;
		}
		
		public function plus(l:Item, tr:int = 0):void
		{
			if (l.id!='money') 
			{
				if (items[l.id].kol==0) items[l.id].nov=1;
				else if (items[l.id].nov==0) items[l.id].nov=2;
				items[l.id].dat=new Date().getTime();
			}
			if (tr==1) 
			{
				items[l.id].kol+=l.bou;
				l.trade();
			} 
			else items[l.id].kol+=l.kol;
			if (l.tip==Item.L_SCHEME || l.tip==Item.L_SPELL) items[l.id].kol=1;
		}
		
		//увеличить количество предметов
		public function plusItem(ci:String, n:int=1):void
		{
			if (items[ci] == null) 
			{
				trace('Ошибка увеличения количества', ci);
				return;
			}
			if (ci != 'money') 
			{
				if (items[ci].kol == 0) items[ci].nov = 1;
				else if (items[ci].nov == 0) items[ci].nov = 2;
				items[ci].dat = new Date().getTime();
			}
			items[ci].kol += n;
		}
		
		//уменьшить количество предметов
		public function minusItem(ci:String, n:int=1, snd:Boolean=true):void
		{
			if (items[ci]==null) 
			{
				trace('Ошибка уменьшения количества',ci);
				return;
			}
			if (items[ci].kol>=n) 
			{
				items[ci].kol-=n;
			} 
			else 
			{
				items[ci].vault-=(n-items[ci].kol);
				items[ci].kol=0;
				if (items[ci].vault<0) items[ci].vault=0;
			}
			if (items[ci].kol==0) nextItem(1);
			try {
				if (items[itemsId[cItem]] && items[itemsId[cItem]].kol==0) 
				{
					cItem=-1;
				}
			} catch(err) {}
			if (snd && items[ci].xml && items[ci].xml.@uses.length())	Snd.ps(items[ci].xml.@uses,owner.X,owner.Y);
		}
		
		public function checkKol(ci:String, n:int=1):Boolean 
		{
			if (GameSession.currentSession.room && GameSession.currentSession.room.base) 
			{
				if (items[ci].kol+items[ci].vault>=n) return true;
				else return false;
			} 
			else 
			{
				if (items[ci].kol>=n) return true;
				else return false;
			}
		}
		
		public function calcMass():void
		{
			mass[1]=mass[2]=mass[3]=0;
			for each (var item:Item in items) 
			{
				mass[item.invCat]+=item.mass*item.kol;
			}
			GameSession.currentSession.checkLoot=true;
			GameSession.currentSession.pers.invMassParam();
		}
		
		public function calcWeaponMass():void
		{
			massW=massM=0;
			for each (var w:Weapon in weapons) 
			{
				if (w==null) continue;
				if (w.tip>0 && w.tip<4 && (w.respect==0 || w.respect==2)) massW+=w.mass;
				if (w.tip==5 && (w.respect==0 || w.respect==2) && (!w.spell || items[w.id] && items[w.id].kol>0)) massM+=w.mass;
			}
			GameSession.currentSession.checkLoot=true;
			GameSession.currentSession.pers.invMassParam();
		}
		
		//уничтожение экипировки
		public function damageItems(dam:Number, destr:Boolean=true):void
		{
			if (!destr && !GameSession.currentSession.room.base && !Settings.alicorn) dam=5;
			if (mass[1]<=GameSession.currentSession.pers.maxm1 || dam<=0) return;
			var kol=dam*(mass[1]-GameSession.currentSession.pers.maxm1)/800;
			if (kol>=1 || Math.random()<kol) 
			{
				kol=Math.ceil(kol*Math.random());
				for (var i=1; i<20; i++) 
				{
					var nid=eqip[Math.floor(Math.random()*eqip.length)];
					if (items[nid].kol>0) 
					{
						if (destr) {

							minusItem(nid,kol,false);
							GameSession.currentSession.gui.infoText('itemDestr',items[nid].objectName, kol);
						} 
						else 
						{
							drop(nid,kol);
							GameSession.currentSession.gui.infoText('itemLose',items[nid].objectName, kol);
						}
						GameSession.currentSession.calcMass=true;
						return;
					}
				}
			}
		}
		
		
		//вернуть строковое представление занимаемого места
		public function retMass(n:int):String 
		{
			var txt:String;
			var cl:String='mass';
			var m:Number, maxm:Number;
			if (n>=1 && n<=3) 
			{
				txt='allmass'+n;
				m=mass[n];
				maxm=gg.pers['maxm'+n];
			} 
			else if (n==4) 
			{
				txt='allweap';
				m=massW;
				maxm=gg.pers.maxmW;
			} 
			else if (n==5) 
			{
				txt='allmagic';
				m=massM;
				maxm=gg.pers.maxmM;
			}
			if (m>maxm) cl='red';
			return Res.txt('pip', txt)+": <span class = '"+cl+"'>"+Res.numb(m)+'/'+Math.round(maxm)+"</span>";
		}
		
		//выкинуть вещи
		public function drop(nid:String, kol:int=1):void
		{
			if (GameSession.currentSession.room.base || Settings.alicorn) 
			{
				return;
			}
			if (kol>items[nid].kol) kol=items[nid].kol;
			if (kol<=0) return;
			var item:Item=new Item(null,nid,kol);
			var loot:Loot=new Loot(GameSession.currentSession.room,item,owner.X,owner.Y-owner.scY/2,true,false,false);
			minusItem(nid,kol,false);
		}
		
		//вызвать прикреплённый скрипт
		public function takeScript(id:String):void
		{
			if (GameSession.currentSession.level.itemScripts[id]) 
			{
				GameSession.currentSession.level.itemScripts[id].start();
			}
		}
		
		//рассчитать количество патронов по их базе
		public function getKolAmmos():void
		{
			for (var s in ammos) ammos[s]=0;
			for each (var ammo:Item in items) 
			{
				if (ammo.base!='') ammos[ammo.base]+=ammo.kol;
			}
		}
		
		//выкурить косяк
		public function useRollup():Boolean 
		{
			if (!GameSession.currentSession.room.base) 
			{
				GameSession.currentSession.gui.infoText('noBase');
				return false;
			} 
			else 
			{
				GameSession.currentSession.pip.onoff(-1);
				var xml1 = XmlBook.getXML("scripts").scr.(@id == 'smokeRollup');
				if (xml1.length()) 
				{
					xml1=xml1[0];
					var smokeScr:Script=new Script(xml1,GameSession.currentSession.room.level, gg);
					smokeScr.start();
					GameSession.currentSession.game.triggers['rollup']=1;
				}
				return true;
			}
		}
	
		public function addMin():void
		{
			addWeapon('r32');
			addWeapon('rech');
			addWeapon('mont');
			addWeapon('bat');
			cWeaponId='r32'
			
			addArmor('pip');
			cArmorId='pip';
			
			items['p32'].kol=16;
			items['money'].kol=50;
			items['pot0'].kol=1;
			items['pot1'].kol=1;
			
			items['screwdriver'].kol=1;
			
			favItem('mont',1);
			favItem('r32',2);
		}
		
		public function addBegin():void
		{
			addArmor('pip');
			cArmorId='pip';
		}
		
		public function addAllWeapon():void
		{
			var w:Weapon;
			//for each (w in LootGen.arr['weapon']) updWeapon(w.id,1);
			for each (w in LootGen.arr['weapon']) addWeapon(w.id);
			for each (w in LootGen.arr['e']) addWeapon(w.id);
			for each (w in LootGen.arr['magic']) addWeapon(w.id);
		}

		public function addAllAmmo():void
		{
			var w:Weapon;
			for each (w in LootGen.arr['a']) items[w.id].kol=10000;
			for each (w in LootGen.arr['e']) items[w.id].kol=10000;
		}

		public function addAllItem():void
		{
			var w:Weapon;
			for each (w in LootGen.arr['med']) items[w.id].kol = 1000;
			for each (w in LootGen.arr['compa']) items[w.id].kol = 1000;
			for each (w in LootGen.arr['him']) items[w.id].kol = 1000;
			for each (w in LootGen.arr['book']) items[w.id].kol = 10;
			for each (w in LootGen.arr['scheme']) take(new Item(Item.L_SCHEME, w.id));
			for each (w in LootGen.arr['spell']) take(new Item(Item.L_SPELL, w.id));
			for each (w in LootGen.arr['compw']) items[w.id].kol = 100;
			for each (w in LootGen.arr['compe']) items[w.id].kol = 100;
			for each (w in LootGen.arr['compm']) items[w.id].kol = 100;
			for each (w in LootGen.arr['compp']) items[w.id].kol = 1000;
			for each (w in LootGen.arr['stuff']) items[w.id].kol = 1000;
			for each (w in LootGen.arr['paint']) items[w.id].kol = 1;
			for each (w in LootGen.arr['pot']) items[w.id].kol = 100;
			for each (w in LootGen.arr['food']) items[w.id].kol = 100;
			items['stealth'].kol = 1000;
			items['potHP'].kol = 1000;
			items['rep'].kol = 1000;
			items['sphera'].kol = 100;
			items['screwdriver'].kol = 1;
		}

		public function addAllArmor():void
		{
			for each (var arm:XML in XmlBook.getXML("armors").armor)
			{
				addArmor(arm.@id);
			}
		}
		
		public function addAll():void
		{
			addAllWeapon();
			addAllAmmo();
			addAllItem();
			addAllArmor();
		}

		public function addLoad(obj:Object):void
		{
			if (obj==null) return;
			var w;
			for each(w in obj.weapons) 
			{
				//trace(w.id);
				var weap:Weapon = addWeapon(w.id,w.hp,w.hold,w.respect,w.variant);
				if (w.ammo) weap.setAmmo(w.ammo, items[w.ammo].xml);
			}
			for each(w in obj.armors) 
			{
				addArmor(w.id,w.hp,w.lvl);
			}
			for (w in obj.items) 
			{
				if (items[w]) items[w].kol=obj.items[w];
				if (isNaN(items[w].kol)) items[w].kol=0;
				if (obj.vault && obj.vault[w]>0) items[w].vault=obj.vault[w];
			}
			for (w in obj.fav) 
			{
				favItem(obj.fav[w], w);
			}
			cWeaponId = obj.cWeaponId;
			cArmorId = obj.cArmorId;
			cAmulId = obj.cAmulId;
			cSpellId = obj.cSpellId;
			prevArmor = obj.prevArmor;
			if (prevArmor == null) prevArmor = '';
		}

		public function save():Object 
		{
			var obj:Object = {};
			obj.weapons = [];
			obj.armors = [];
			obj.fav = [];
			obj.items = [];
			obj.vault = [];
			var w;
			for (w in weapons) 
			{
				if (weapons[w] is Weapon) obj.weapons[w]={id:weapons[w].id, hp:weapons[w].hp, hold:weapons[w].hold, ammo:weapons[w].ammo, respect:weapons[w].respect, variant:weapons[w].variant};
			}
			for (w in armors) 
			{
				if (armors[w] is Armor) obj.armors[w]={id:armors[w].id, hp:armors[w].hp, lvl:armors[w].lvl};
			}
			for (w in fav) 
			{
				obj.fav[w]=fav[w];
			}
			for (w in items) 
			{
				if (w!='') 
				{
					obj.items[w]=items[w].kol;
					if (items[w].vault>0) obj.vault[w]=items[w].vault;
				}
			}
			if (gg.currentWeapon) obj.cWeaponId=gg.currentWeapon.id; else obj.cWeaponId='';
			if (gg.currentArmor) obj.cArmorId=gg.currentArmor.id; else obj.cArmorId='';
			if (gg.currentAmul) obj.cAmulId=gg.currentAmul.id; else obj.cAmulId='';
			if (gg.currentSpell) obj.cSpellId=gg.currentSpell.id; else obj.cSpellId='';
			obj.prevArmor=gg.prevArmor;
			
			return obj;
		}
	}	
}