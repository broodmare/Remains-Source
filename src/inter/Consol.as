package src.inter {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import src.*;
	import src.unit.Unit;
	
	public class Consol {
		public var vis:MovieClip;
		public var ist:Array;
		public var istN:int=0;
		
		var help:XML = <chit>
			<a>all - add everything</a>
			<a>all weapon - add all weapons</a>
			<a>all armor - add all armor</a>
			<a>all item - 1000 of each item</a>
			<a>all ammo - 10000 of each ammo</a>
			<a>min - add the necessary minimum</a>
			<a>god - toggle invincibility</a>
			<a>jump - change jump mode</a>
			<a>xp X - add X experience</a>
			<a>lvl X - set character level to X</a>
			<a>sp X - add X skill points</a>
			<a>pp X - add X perk points</a>
			<a>money X - set the amount of caps to X</a>
			<a>weapon ID - get weapon ID</a>
			<a>armor ID - get armor ID</a>
			<a>item ID X - set the quantity of item ID to X</a>
			<a>ammo ID X - set the quantity of ammo ID to X</a>
			<a>skill ID n - set skill ID to n (0-20)</a>
			<a>perk ID - get perk ID</a>
			<a>eff ID - get effect ID</a>
			<a>res - reset all effects</a>
			<a>testeff - all effects will be 10 times shorter</a>
			<a>testdam - cancel damage spread</a>
			<a>hardinv - toggle restricted inventory</a>
			<a>repair - repair weapons</a>
			<a>crack X - damage weapons by X%</a>
			<a>break X - damage armor by X%</a>
			<a>lim X - set the special loot limit to X%</a>
			<a>heal - full healing</a>
			<a>mana X - set mana to X</a>
			<a>die - die</a>
			<a>check - return to the checkpoint</a>
			<a>goto X Y - move to location with coordinates X Y</a>
			<a>clear - reset some variables</a>
			<a>map - show the entire map</a>
			<a>black - hide/show fog of war</a>
			<a>enemy - toggle AI</a>
			<a>fly - can enable flight with the ~ key</a>
			<a>port - teleport with the ~ key</a>
			<a>emit X - summon particle X with the ~ key</a>
			<a>refill - restock items at traders</a>
			<a>getroom - clear the room</a>
			<a>getloc - clear the location</a>
			<a>dif X - change difficulty (0-4)</a>
			<a>st X Y - set trigger X to value Y</a>
			<a>trigger X - get the value of trigger X</a>
			<a>triggers - get trigger values</a>
		</chit>;

		public function Consol(vcons:MovieClip, prev:String=null) {
			vis=vcons;
			ist=new Array();
			if (prev!=null) ist.push(prev);
			vis.visible=false;
			vis.input.addEventListener(KeyboardEvent.KEY_DOWN,onKeyboardDownEvent);
			vis.butEnter.addEventListener(MouseEvent.CLICK,onButEnter);
			vis.butClose.addEventListener(MouseEvent.CLICK,onButClose);
			for each(var i in help.a) vis.help.text+=i+'\n';
			for each(i in Res.d.weapon) vis.list1.text+=i.@id+' \t'+i.n[0]+'\n';
			for each(i in Res.d.item) vis.list2.text+=i.@id+' \t'+i.n[0]+'\n';
			for each(i in Res.d.ammo) vis.list2.text+=i.@id+' \t'+i.n[0]+'\n';
			vis.help.visible=vis.list1.visible=vis.list2.visible=false;
		}
		
		public function onKeyboardDownEvent(event:KeyboardEvent):void {
			if (event.keyCode==Keyboard.ENTER) {
				analis();
			}
			if (event.keyCode==Keyboard.END || event.keyCode==Keyboard.ESCAPE) {
				World.w.consolOnOff();
			}
			if (event.keyCode==Keyboard.UP) {
				if (istN>0) istN--;
				if (istN<ist.length) vis.input.text=ist[istN];
			}
			if (event.keyCode==Keyboard.DOWN) {
				if (istN<ist.length) istN++;
				if (istN<ist.length) vis.input.text=ist[istN];
			}
			event.stopPropagation();
		}
		
		public function onButEnter(event:MouseEvent):void {
			analis();
			event.stopPropagation();
		}
		public function onButClose(event:MouseEvent):void {
			World.w.consolOnOff();
			event.stopPropagation();
		}
		
		public var visoff=false;
		
		function off() {
			visoff=true;
		}
		
		function analis() {
			var str:String=vis.input.text;
			ist.push(str);
			World.w.lastCom=str;
			World.w.saveConfig();
			istN=ist.length;
			vis.input.text='';
			var s:Array=str.split(' ');
			//try {
				if (s[0]=='clear') {
					try {
						World.w.cam.dblack=0;
						World.w.gg.controlOn();
						World.w.gg.vis.visible=true;
						World.w.vblack.alpha=0;
						World.w.vblack.visible=false;
						World.w.t_exit=World.w.t_die=0;
						World.w.vgui.visible=World.w.vfon.visible=World.w.visual.visible=true;
						Snd.off=false;
						World.w.pip.noAct=false;

					} catch (err) {
					}
				}
				if (s[0]=='redraw') {
					World.w.redrawLoc();
				}
				if (s[0]=='hud') {
					World.w.gui.vis.visible=!World.w.gui.vis.visible;
				}
				if (s[0]=='die') {
					World.w.gg.damage(10000,Unit.D_INSIDE);
				}
				if (s[0]=='hardreset' && World.w.pers.dead) {
					World.w.pers.dead=false;
					World.w.t_die=210;
					World.w.gg.anim('die',true);
					off();
				}
				if (s[0]=='hardinv') {
					World.w.hardInv=!World.w.hardInv;
				}
				if (s[0]=='res_watcher') {	//исправление бага с наблюдателем
					World.w.game.triggers['observer']=1;
				}
				if (s[0]=='mqt') {
					World.w.chitOn=!World.w.chitOn;
					World.w.saveConfig();
					return;
				}
				if (!World.w.chitOn) {
					off();
					return;
				}
				if (str=='?') {
					vis.help.visible=vis.list1.visible=vis.list2.visible=!vis.help.visible;
					return;
				}
				if (s[0]=='hardcore') {
					World.w.pers.hardcore=!World.w.pers.hardcore;
				}
				if (s[0]=='testmode') {
					World.w.testMode=!World.w.testMode;
				}
				if (s[0]=='dif') {
					World.w.game.globalDif=s[1];
					if (World.w.game.globalDif<0) World.w.game.globalDif=0;
					if (World.w.game.globalDif>4) World.w.game.globalDif=4;
					World.w.pers.setGlobalDif(World.w.game.globalDif);
					World.w.pers.setParameters();
				}
				if (s[0]=='all') {
					if (s.length==1) {
						World.w.invent.addAll();
						World.w.pers.addSkillPoint(10);
					}
					else if (s[1]=='weapon') World.w.invent.addAllWeapon();
					else if (s[1]=='ammo') World.w.invent.addAllAmmo();
					else if (s[1]=='item') World.w.invent.addAllItem();
					else if (s[1]=='armor') World.w.invent.addAllArmor();
					off();
				}
				if (s[0]=='min') {
					World.w.invent.addMin();
					off();
				}
				if (s[0]=='god') {
					World.w.godMode=!World.w.godMode;
				}
				if (s[0]=='lvl' || s[0]=='level') {
					World.w.pers.setForcLevel(s[1]);
				}
				if (s[0]=='xp') {
					World.w.pers.expa(s[1]);
				}
				if (s[0]=='sp') {
					if (s.length==1) World.w.pers.addSkillPoint();
					else World.w.pers.addSkillPoint(int(s[1]));
				}
				if (s[0]=='pp') {
					if (s.length==1) World.w.pers.perkPoint++;
					else  World.w.pers.perkPoint+=int(s[1]);
				}
				if (s[0]=='weapon') {
					if (s.length==2) World.w.invent.addWeapon(s[1]);
					else if (s.length>2) World.w.invent.updWeapon(s[1],1)
				}
				if (s[0]=='remw') {
					if (s.length==2) World.w.invent.remWeapon(s[1]);
				}
				if (s[0]=='armor') {
					if (s.length==2) World.w.invent.addArmor(s[1]);
				}
				if (s[0]=='money') {
					if (s.length==2) World.w.invent.items['money'].kol=int(s[1]);
				}
				if (s[0]=='item') {
					if (World.w.invent.items[s[1]]==null) return;
					if (s.length==3) World.w.invent.items[s[1]].kol=int(s[2]);
					else if (s.length==2) World.w.invent.items[s[1]].kol++;
					World.w.game.checkQuests(s[1]);
					World.w.pers.setParameters();
				}
				if (s[0]=='ammo') {
					if (s.length==3) World.w.invent.items[s[1]].kol=int(s[2]);
				}
				if (s[0]=='perk') {
					if (s.length==2) World.w.pers.addPerk(s[1]);
				}
				if (s[0]=='skill') {
					if (s.length==3) World.w.pers.setSkill(s[1], s[2]);
				}
				if (s[0]=='eff') {
					if (s.length==2) World.w.gg.addEffect(s[1]);
				}
				if (s[0]=='res') {
					if (World.w.gg.effects.length>0) {
						for each (var eff in World.w.gg.effects) eff.unsetEff();
					}
				}
				if (s[0]=='repair') {
					World.w.gg.currentWeapon.repair(1000000);
				}
				if (s[0]=='refill') {
					World.w.game.refillVendors();
				}
				if (s[0]=='rep') {
					if (s.length==2) World.w.pers.rep=int(s[1]);
				}
				if (s[0]=='crack') {
					if (s.length==2 && World.w.gg.currentWeapon) World.w.gg.currentWeapon.hp=Math.round(World.w.gg.currentWeapon.maxhp*Number(s[1])/100);
				}
				if (s[0]=='break') {
					if (s.length==2 && World.w.gg.currentArmor) World.w.gg.currentArmor.hp=Math.round(World.w.gg.currentArmor.maxhp*Number(s[1])/100);
				}
				if (s[0]=='heal') {
					World.w.gg.heal(10000);
				}
				if (s[0]=='rad') {
					World.w.gg.rad=s[1];
					World.w.gui.setAll();
				}
				if (s[0]=='mana') {
					World.w.pers.manaHP=int(s[1]);
					World.w.pers.setParameters();
				}
				if (s[0]=='check') {
					World.w.land.gotoCheckPoint();
				}
				if (s[0]=='goto') {
					if (s.length==3) World.w.land.gotoXY(s[1],s[2]);
				}
				if (s[0]=='map') {
					World.w.drawAllMap=!World.w.drawAllMap;
				}
				if (s[0]=='black') {
					World.w.black=!World.w.black;
					World.w.grafon.visLight.visible=World.w.black && World.w.loc.black;
				}
				if (s[0]=='battle') {
					World.w.testBattle=!World.w.testBattle;
				}
				if (s[0]=='testeff') {
					World.w.testEff=!World.w.testEff;
				}
				if (s[0]=='testdam') {
					World.w.testDam=!World.w.testDam;
				}
				if (s[0]=='enemy') {
					if (World.w.enemyAct==3) World.w.enemyAct=0;
					else World.w.enemyAct=3;
				}
				if (s[0]=='lim') {
					if (s.length==2) World.w.land.lootLimit=Number(s[1]);
				}
				if (s[0]=='fly' || s[0]=='port' || s[0]=='emit') {
					World.w.chit=s[0];
					World.w.chitX=s[1];
				}
				if (s[0]=='getroom') {
					World.w.testLoot=true;
					trace('получено опыта', World.w.loc.getAll());
					World.w.testLoot=false;
				}
				if (s[0]=='err') {
					World.w.landError=!World.w.landError;
				}
				if (s[0]=='getloc') {
					World.w.testLoot=true;
					trace('получено опыта', World.w.land.getAll());
					World.w.testLoot=false;
					//World.w.game.gotoNextLevel();			
				}
				if (s[0]=='alicorn') {
					if (World.w.alicorn) World.w.gg.alicornOff();
					else World.w.gg.alicornOn();
				}
				if (s[0]=='st') {
					if (s.length==3) World.w.game.triggers[s[1]]=s[2];
				}
				if (s[0]=='trigger') {
					if (s.length==2) World.w.gui.infoText('trigger',s[1],World.w.game.triggers[s[1]]);
				}
				if (s[0]=='triggers') {
					if (s.length>1) World.w.gui.infoText('trigger',s[1],World.w.game.triggers[s[1]]);
					else {
						for (var i in World.w.game.triggers)  World.w.gui.infoText('trigger',i,World.w.game.triggers[i]);
					}
				}
				
			//}
			World.w.gui.setAll();
		}

	}
	
}
