package interdata 
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	import unitdata.Unit;
	import unitdata.Effect;
	import unitdata.Pers;
	import servdata.Item;
	
	public class PipPageMed extends PipPage{
		
		var pers:Pers;
		var infoItemId:String	= '';
		var priceHP:Number		= 0.5;
		var priceBlood:Number	= 0.5;
		var priceRad:Number		= 1;
		var priceOrgan:Number	= 0.5;
		var priceCut:Number		= 4;
		var pricePoison:Number	= 4;
		var priceMana:Number	= 1;
		var raz:int				= 200;
		var razMana:int			= 100;
		
		var plata:Item;

		public function PipPageMed(npip:PipBuck, npp:String) 
		{
			isLC = true;
			itemClass = visPipMedItem;
			super(npip,npp);
			vis.but3.visible = false;
			vis.but4.visible = false;
			vis.but5.visible = false;
		}

		//подготовка страниц
		public override function setSubPages():void
		{
			setIco();
			if (pip.npcInter == 'adoc') 
			{
				vis.but2.visible = false;
				plata = inv.gel;
			} 
			else if (pip.npcInter == 'vdoc') 
			{
				vis.but2.visible = false;
				plata = inv.good;
			} 
			else 
			{
				vis.but2.visible = true;
				plata = inv.money;
			}
			
			pers 		= GameSession.currentSession.pers;
			priceHP 	= pers.priceHP;
			priceBlood 	= pers.priceBlood;
			priceRad 	= pers.priceRad;
			priceOrgan 	= pers.priceOrgan;
			priceCut 	= pers.priceCut;
			pricePoison = pers.pricePoison;
			priceMana 	= pers.priceMana;
			
			statHead.hpbar.visible = false;
			statHead.nazv.text = '';
			statHead.numb.text = '';
			statHead.price.text = Res.txt('pip', 'medprice');
			vis.butOk.visible = vis.butDef.visible=false;

			if (page2 == 1) 
			{
				gg.pers.checkHP();
				setTopText('usemed2');
				var cena:Number;
				cena = (gg.maxhp - gg.hp - gg.rad) * priceHP;
				if (cena < 0) cena = 0;
				
				arr.push({id:'hp', objectName:Res.txt('pip', 'hp'), lvl:Math.round(gg.hp)+'/'+Math.round(gg.maxhp), bar:(gg.hp/gg.maxhp), price:cena});
				arr.push({id:'organism', objectName:Res.txt('pip', 'organism')+':', lvl:''});
				
				if (gg.pers.inMaxHP-gg.pers.headHP>raz) cena=raz*priceOrgan; else cena=(gg.pers.inMaxHP-gg.pers.headHP)*priceOrgan;
				arr.push({id:'statHead'+gg.pers.headSt,objectName:'   '+Res.txt('pip', 'head'), lvl:Math.round(gg.pers.headHP)+'/'+Math.round(gg.pers.inMaxHP), bar:(gg.pers.headHP/gg.pers.inMaxHP), price:cena});
				
				if (gg.pers.inMaxHP-gg.pers.torsHP>raz) cena=raz*priceOrgan; else cena=(gg.pers.inMaxHP-gg.pers.torsHP)*priceOrgan;
				arr.push({id:'statTors'+gg.pers.torsSt,objectName:'   '+Res.txt('pip', 'tors'), lvl:Math.round(gg.pers.torsHP)+'/'+Math.round(gg.pers.inMaxHP), bar:(gg.pers.torsHP/gg.pers.inMaxHP), price:cena});
				
				if (gg.pers.inMaxHP-gg.pers.legsHP>raz) cena=raz*priceOrgan; else cena=(gg.pers.inMaxHP-gg.pers.legsHP)*priceOrgan;
				arr.push({id:'statLegs'+gg.pers.legsSt,objectName:'   '+Res.txt('pip', 'legs'), lvl:Math.round(gg.pers.legsHP)+'/'+Math.round(gg.pers.inMaxHP), bar:(gg.pers.legsHP/gg.pers.inMaxHP), price:cena});
				
				if (gg.pers.inMaxHP-gg.pers.bloodHP>raz) cena=raz*priceBlood; else cena=(gg.pers.inMaxHP-gg.pers.bloodHP)*priceBlood;
				arr.push({id:'statBlood'+gg.pers.bloodSt,objectName:'   '+Res.txt('pip', 'blood'), lvl:Math.round(gg.pers.bloodHP)+'/'+Math.round(gg.pers.inMaxHP), bar:(gg.pers.bloodHP/gg.pers.inMaxHP), price:cena});
				
				if (gg.pers.inMaxMana-gg.pers.manaHP>razMana) cena=razMana*priceMana; else cena=(gg.pers.inMaxMana-gg.pers.manaHP)*priceMana;
				arr.push({id:'statMana'+gg.pers.manaSt,objectName:'   '+Res.txt('pip', 'mana'), lvl:Math.round(gg.pers.manaHP)+'/'+Math.round(gg.pers.inMaxMana), bar:(gg.pers.manaHP/gg.pers.inMaxMana), price:cena});
				
				cena=(gg.rad)*priceRad;
				arr.push({id:'rad', objectName:Res.txt('pip', 'rad'), lvl:Math.round(gg.rad), price:cena});
				cena=(gg.cut)*priceCut;
				arr.push({id:'cut', objectName:Res.txt('pip', 'cut'), lvl:Math.round(gg.cut*10)/10, price:cena});
				cena=(gg.poison)*pricePoison;
				arr.push({id:'poison', objectName:Res.txt('pip', 'poison'), lvl:Math.round(gg.poison*10)/10, price:cena});
			}
			showBottext();
		}
		
		//показ одного элемента
		public override function setStatItem(item:MovieClip, obj:Object):void
		{
			if (obj.id != null) item.id.text = obj.id;
			else item.id.text 		= '';
			item.id.visible 		= false;
			item.hpbar.visible 		= false;
			item.nazv.text 	= obj.objectName;
			item.numb.text 			= obj.lvl;

			if (obj.price != null) item.price.text = Math.round(obj.price);
			else item.price.text = '';

			if (obj.bar != null) 
			{
				item.hpbar.visible = true;
				item.hpbar.bar.scaleX = obj.bar;
			}
		}
		
		//информация об элементе
		public override function statInfo(event:MouseEvent):void
		{
				if (event.currentTarget.id.text != '') 
				{
					vis.nazv.text = Res.txt('pip', event.currentTarget.id.text);
					var s:String = Res.txt('pip', event.currentTarget.id.text, 1);
					vis.info.htmlText=s;
				} 
				else vis.nazv.text=vis.info.htmlText = '';
		}
		
		public override function page2Click(event:MouseEvent):void
		{
			if (GameSession.currentSession.ctr.setkeyOn) return;
			
			page2 = int(event.currentTarget.id.text);
			pip.snd(2);
			
			if (page2 == 2) 
			{
				page2 = 1;
				pip.onoff(4);
				pip.currentPage.page2 = 1;
				pip.currentPage.setStatus();
			} 
			else setStatus();
		}

		public function showBottext():void
		{
			if (pip.npcInter == 'adoc') vis.bottext.htmlText = Res.txt('item','gel')+': ' + numberAsColor('yellow', plata.kol);
			else if (pip.npcInter == 'vdoc') vis.bottext.htmlText = Res.txt('item','good')+': ' + numberAsColor('yellow', plata.kol);
			else vis.bottext.htmlText = Res.txt('pip', 'caps') + ': ' + numberAsColor('yellow', plata.kol);
		}

		public override function itemClick(event:MouseEvent):void
		{
			if (pip.gamePause) 
			{
				GameSession.currentSession.gui.infoText('gamePause');
				return;
			}

			var cena:Number;
			var need:String;
			var mon = plata.kol;

			infoItemId = getSimplifiedItemId(event.currentTarget.id.text);
			switch (infoItemId) 
			{
				case 'hp':
					cena = (gg.maxhp - gg.hp - gg.rad) * priceHP;
					if (cena > plata.kol) cena = plata.kol;
					gg.heal(cena / priceHP, 0, false);
					break;

				case 'rad':
					cena = (gg.rad) * priceRad;
					if (cena > plata.kol) cena = plata.kol;
					gg.heal(cena / priceRad, 2, false);
					break;

				case 'cut':
					cena = (gg.cut) * priceCut;
					if (cena > plata.kol) cena = plata.kol;
					gg.heal(cena / priceCut, 3, false);
					break;

				case 'poison':
					cena = (gg.poison) * pricePoison;
					if (cena > plata.kol) cena = plata.kol;
					gg.heal(cena / pricePoison, 4, false);
					break;

				case 'statBlood':
					if (gg.pers.inMaxHP - gg.pers.bloodHP > raz) cena = raz * priceBlood; 
					else cena = (gg.pers.inMaxHP - gg.pers.bloodHP) * priceBlood;

					if (cena > plata.kol) cena = plata.kol;

					if (healCheckPassed(gg.pers.bloodHP)) gg.pers.heal(49, 5);
					else gg.pers.heal(cena / priceBlood, 5);
					break;
				
				case 'statMana':
					if (gg.pers.inMaxMana - gg.pers.manaHP > razMana) cena = razMana * priceMana; 
					else cena = (gg.pers.inMaxMana - gg.pers.manaHP) * priceMana;

					if (cena > plata.kol) cena = plata.kol;

					gg.pers.heal(cena / priceMana, 6);
					break;

				case 'statHead':
					if (gg.pers.inMaxHP-gg.pers.headHP>raz) cena = raz * priceOrgan; 
					else cena = (gg.pers.inMaxHP - gg.pers.headHP) * priceOrgan;

					if (cena > plata.kol) cena = plata.kol;

					if (healCheckPassed(gg.pers.headHP)) gg.pers.heal(49, 1);
					else gg.pers.heal(cena / priceOrgan, 1);
					break;
				
				case 'statTors':
					if (gg.pers.inMaxHP - gg.pers.torsHP > raz) cena = raz * priceOrgan; 
					else cena = (gg.pers.inMaxHP - gg.pers.torsHP) * priceOrgan;

					if (cena > plata.kol) cena = plata.kol;

					if (healCheckPassed(gg.pers.torsHP)) gg.pers.heal(49, 2);
					else gg.pers.heal(cena / priceOrgan, 2);
					break;

				case 'statLegs':
					if (gg.pers.inMaxHP - gg.pers.legsHP > raz) cena = raz * priceOrgan; 
					else cena = (gg.pers.inMaxHP - gg.pers.legsHP) * priceOrgan;

					if (cena > plata.kol) cena = plata.kol;

					if (healCheckPassed(gg.pers.legsHP)) gg.pers.heal(49, 3);
					else gg.pers.heal(cena / priceOrgan, 3);
					break;
			}
			plata.kol -= Math.round(cena);

			if (plata.id == 'money' && plata.kol < mon && pip.vendor) pip.vendor.money += (mon - plata.kol);

			pip.snd(1);
			setStatus();
			showBottext();
			pip.setRPanel();
		}

		private function getSimplifiedItemId(infoItemId:String):String 
		{
			if (infoItemId.indexOf('statBlood') == 0) return 'statBlood';
			if (infoItemId.indexOf('statMana')  == 0) return 'statMana';
			if (infoItemId.indexOf('statHead')  == 0) return 'statHead';
			if (infoItemId.indexOf('statTors')  == 0) return 'statTors';
			if (infoItemId.indexOf('statLegs')  == 0) return 'statLegs';

			return infoItemId;
		}

		private function healCheckPassed(input:Number):Boolean // Helper function for itemClick, cuts down on code re-use.
		{
			if (input <= 2 && plata.kol <= 0 && gg.pers.level < 6) return true
			else return false;
		}
	}
}