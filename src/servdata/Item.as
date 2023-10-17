package servdata 
{
	
	//Элемент инвентаря
	import unitdata.Invent;
	
	import components.Settings;
	
	public class Item 
	{

		public static const L_ITEM:String ='item', 
			L_ARMOR:String ='armor', L_WEAPON:String ='weapon', L_UNIQ:String ='uniq', L_SPELL:String ='spell', L_AMMO:String ='a', L_EXPL:String ='e',
			L_MED:String ='med', L_BOOK:String ='book', L_HIM:String ='him', L_POT:String ='pot', L_FOOD:String ='food', L_SCHEME:String ='scheme', L_PAINT:String ='paint',
			L_COMPA:String ='compa', L_COMPW:String ='compw', L_COMPE:String ='compe',  L_COMPM:String ='compm',  L_COMPP:String ='compp',
			L_SPEC:String ='spec', L_INSTR:String ='instr', L_STUFF:String ='stuff', L_ART:String ='art', L_IMPL:String ='impl', L_KEY:String ='key';

		public static var itemTip:Array = ['weapon', 'spell', 'a', 'e', 'med', 'book', 'him', 'scheme', 'compa', 'compw', 'compe', 'compm', 'compp', 'paint', 'art', 'impl', 'key']
		
		
		public var tip:String;
		public var wtip:String		= '';
		public var base:String		= '';
		public var id:String;
		public var objectName:String;
		public var mess:String;					//информационное окно, ставящее игру на паузу
		public var fc:int 			= -1;		//цвет всплывающего сообщения
		public var invis:Boolean 	= false;
		
		public var xml:XML;
		public var kol:int			= 0;		// Amount in inventory
		public var vault:int		= 0;		// Amount in storage
		public var invCat:int		= 3;		// Inventory section
		public var sost:Number		= 1;		// State of the loot
		public var multHP:Number 	= 1;		// HP multiplier
		public var variant:int 		= 0;
		public var mass:Number 		= 0;
		
		public var imp:int 			= 0; 		// 0 - randomly generated, 1 - specified, 2 - critical
		public var cont:Interact;				// Parent container
		
		public var nov:int 			= 0;		// New item
		public var dat:Number 		= 0;		// Time of acquisition
		public var bou:int 			= 0;		// Purchased
		public var shpun:int 		= 0;		// Flag indicating that the concealed weapon needs to be revealed
		public var lvl:int 			= 0;		// Character level from which the item becomes available
		public var barter:int 		= 0;		// Skill level from which the item becomes available
		public var trig:String;					// Trigger that must be set for the item to become available
		public var price:Number 	= 0;
		public var pmult:Number 	= 1;
		public var noref:Boolean 	= false;	// Do not replenish
		public var nocheap:Boolean 	= false;	// Do not reduce the price
		public var hardinv:Boolean 	= false;	// Only with limited inventory
		
		// nkol - number of items or the state of weapons/armor 0-1-2
		// if nkol = -1, the quantity is taken from xml
		public function Item(ntip:String, nid:String, nkol:int = -1, nvar:int = 0, nxml:XML = null) 
		{
			variant = nvar;
			if (nid != null && nid.charAt(nid.length - 2) == '^') 
			{
				variant = int(nid.charAt(nid.length - 1));
				id = nid.substr(0, nid.length - 2);
			} 
			else id = nid;
			//trace(id);

			tip = ntip;
			kol = nkol;
			if (tip == '' || tip == null) itemTip();
			if (tip == L_UNIQ) tip = L_WEAPON;

			if (nxml == null) 
			{
				var l:XMLList;

				if (tip == L_ARMOR) 
				{
					l = AllData.d.armor.(@id == id);
				} 
				else if (tip == L_WEAPON) 
				{
					l = AllData.d.weapon.(@id == id);
				} 
				else 
				{
					l = AllData.d.item.(@id == id);
				}

				if (l.length()) 
				{
					xml = l[0];
					wtip = xml.@tip;
				}
			} 
			else 
			{
				xml = nxml;
				wtip = xml.@tip;
			}

			if (tip == L_ARMOR || tip == L_WEAPON) 
			{
				kol = 1;
				if (tip == L_ARMOR && xml && xml.@tip == '3') 
				{
					sost = 1;
				} 
				else 
				{
					if (nkol == 0) sost = 0.05 + Math.random() * 0.15;
					if (nkol == 1) sost = 0.6 +  Math.random() * 0.25;
				}
			}

			if (kol < 0 && xml) 
			{
				if (xml.@kol.length()) kol = xml.@kol;
				else kol = 1;
			}

			if (tip == L_WEAPON || tip == L_EXPL) 
			{
				if (variant == 0)	objectName = Res.txt('w', id);
				else 
				{
					if (Res.istxt('w' , id + '^' + variant)) objectName = Res.txt('w', id + '^' + variant);
					else objectName = Res.txt('w', id) + ' - II';
				}
				if (tip == L_EXPL) wtip = 'w5';
				else wtip = 'w' + l.@skill;
			} 
			else if (tip == L_ARMOR) 
			{
				objectName = Res.txt('a', id);
				if (xml && xml.@tip.length()) 
				{
					wtip = 'armor' + xml.@tip;
				} 
				else wtip = 'armor1';
			} 
			else if (xml && xml.@base.length()) 
			{
				base = xml.@base;
				objectName = Res.txt('i', base);
				if (xml.@mod.length()) objectName += ' (' + Res.pipText('am_' + xml.@mod) + ')';
			} 
			else objectName = Res.txt('i', id);

			if (tip == L_ITEM && xml && xml.@tip.length()) tip = xml.@tip;
			if (tip == L_SCHEME && !Res.istxt('i', id)) 
			{
				var wid:String = id.substr(2);
				if (xml.@work == 'work') objectName = Res.pipText('scheme1') + ' «' + Res.txt('i', wid) + '»';
				else objectName = Res.pipText('recipe') + ' «' + Res.txt('i', wid) + '»';
			}
			if (tip == L_AMMO || tip == L_EXPL) invCat = 2;
			if (xml && xml.@us > 0 && tip != L_FOOD && tip != 'eda' && tip != L_BOOK) invCat = 1;

			if (tip == L_WEAPON && xml) 
			{
				if (xml.@tip != 4) mass = 1;
				if (xml.phis.length() && xml.phis.@m.length()) mass = xml.phis.@m;
			}

			if (xml) 
			{
				if (xml.@invcat.length()) invCat 	= xml.@invcat;
				if (xml.@invis.length()) invis 	= true;
				if (xml.@fc.length()) fc 			= xml.@fc;
				if (xml.@mess.length()) mess 		= xml.@mess;
				if (xml.@m.length()) mass 		= xml.@m;
			}
		}

		public function itemTip():void
		{
			var l:XMLList;
			l = AllData.d.item.(@id == id);
			if (l.length()) 
			{
				xml = l[0];
				if (xml.@tip.length()) tip = xml.@tip;
				else tip = L_ITEM;
			} 
			else 
			{
				l = AllData.d.weapon.(@id == id);
				if (l.length()) 
				{
					xml = l[0];
					tip = L_WEAPON;
				} 
				else 
				{
					l = AllData.d.armor.(@id == id);
					if (l.length()) 
					{
						xml = l[0];
						tip = L_ARMOR;
					} 
				}
			}
		}
		
		public function getPrice():void
		{
			if (xml) 
			{
				if (xml.com.length() && xml.com.@price.length()) 
				{
					price = xml.com[0].@price * sost * multHP * pmult;
					if (variant > 0) 
					{
						if (xml.com[1]) price = xml.com[1].@price * sost * multHP * pmult;
						else price *= 3;
					}
				} 
				else price = xml.@price * sost * multHP * pmult;
			}
		}
		
		public function getMultPrice():Number 
		{
			if (xml && xml.@price > 0 && xml.@sell > 0) 
			{
				return Number(xml.@sell) / Number(xml.@price);
			} 
			else return 0.1;
		}
		
		public function checkAuto(m:Boolean = false):Boolean 
		{
			var inv:Invent = World.world.invent;
			if (tip == L_WEAPON) 
			{
				var w = inv.weapons[id];
				if (w != null && (Settings.vsWeaponRep || m)) 
				{		// If auto-pickup for repair is enabled or forced call
					if (w.hp <= w.maxhp && (w.respect == 0 || w.respect == 2 || !Settings.hardInv)) 
					{	// Auto-pick if weapon exists, it is faulty and (it is selected or inventory is infinite)
						return true;
					} 
					else if (m && Settings.hardInv) 
					{	// If there was forced pickup with limited inventory, then activate the picked-up weapon
						shpun = 2;
					}
					return false; 
				}
				if (w == null && Settings.vsWeaponNew) // If auto-pickup for repair is enabled or forced call
				{
					if (Settings.hardInv) // If auto-pickup for new weapons is enabled and no weapon exists yet
					{		
						if (mass == 0) return true;
						if (xml.@tip <= 3) 
						{
							if (inv.massW <= World.world.pers.maxmW - mass) 
							{
								return true;
							} 
							else 
							{
								if (m) World.world.gui.infoText('fullWeap');
								return false;
							}
						}
						if (xml.@tip == 5) 
						{
							if (inv.massM <= World.world.pers.maxmM - mass) 
							{
								return true;
							} 
							else 
							{
								if (m) World.world.gui.infoText('fullMagic');
								return false;
							}
						}
						return false;
					}
					return true;
				}
				return false;
			}
			if (tip == L_SPELL) 
			{
				if (inv.massM >= World.world.pers.maxmM) World.world.gui.infoText('fullMagic');
				return true;
			}
			if (tip == L_ARMOR) return true;
			if (mass == 0) return true;
			if (Settings.hardInv) 
			{
				if (inv.mass[invCat] + mass * kol > World.world.pers['maxm' + invCat]) return false;
			}
			if (Settings.vsAmmoAll && tip == L_AMMO) return true;
			if (Settings.vsAmmoTek && xml && tip == L_AMMO) 
			{
				for each (w in inv.weapons) 
				{
					if (w.tip <= 3 && (w.respect == 0 || w.respect == 2) && w.ammoBase != '' && (w.ammoBase == xml.@id || w.ammoBase == xml.@base)) return true;
				}
			}
			if (Settings.vsExplAll && tip==L_EXPL) return true;
			if (Settings.vsMedAll && (tip==L_MED || tip==L_POT)) return true;
			if (Settings.vsHimAll && tip==L_HIM) return true;
			if (Settings.vsEqipAll && tip=='equip') return true;
			if (Settings.vsStuffAll && invCat==3) return true;
			if (Settings.vsVal && tip=='valuables') return true;
			if (Settings.vsBook && (tip=='book' || tip=='sphera')) return true;
			if (Settings.vsFood && (tip=='food' || tip=='eda')) return true;
			if (Settings.vsComp && (tip=='stuff' || tip=='compa' || tip=='compw' || tip=='compe' || tip=='compm')) return true;
			if (Settings.vsIngr && tip=='compp') return true;
			return false;
		}
		
		public function save():Object 
		{
			return {tip:tip, id:id, kol:kol, sost:sost, barter:barter, lvl:lvl, trig:trig, variant:variant};
		}
		
		public function trade():void
		{
			kol -= bou;
			bou = 0;
		}
		
	}
	
}
