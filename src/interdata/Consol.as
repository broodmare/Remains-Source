package interdata 
{
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	import unitdata.Unit;
	
	import components.Settings;
	
	public class Consol 
	{
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
			<a>goto X Y - move to room with coordinates X Y</a>
			<a>clear - reset some variables</a>
			<a>map - show the entire map</a>
			<a>black - hide/show fog of war</a>
			<a>enemy - toggle AI</a>
			<a>fly - can enable flight with the ~ key</a>
			<a>port - teleport with the ~ key</a>
			<a>emit X - summon particle X with the ~ key</a>
			<a>refill - restock items at traders</a>
			<a>getroom - clear the room</a>
			<a>getloc - clear the room</a>
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
				World.world.consolOnOff();
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
			World.world.consolOnOff();
			event.stopPropagation();
		}
		
		public var visoff=false;
		
		function off() 
		{
			visoff=true;
		}
		
		function analis() 
		{
			var str:String=vis.input.text;
			ist.push(str);
			World.world.lastCom=str;
			World.world.saveConfig();
			istN=ist.length;
			vis.input.text='';
			var s:Array=str.split(' ');
			//try {
				if (s[0]=='clear') {
					try {
						World.world.cam.dblack=0;
						World.world.gg.controlOn();
						World.world.gg.vis.visible=true;
						World.world.vblack.alpha=0;
						World.world.vblack.visible=false;
						World.world.t_exit=World.world.t_die=0;
						World.world.vgui.visible=World.world.skybox.visible=World.world.mainCanvas.visible=true;
						Snd.off=false;
						World.world.pip.gamePause=false;

					} catch (err) {
					}
				}
				if (s[0]=='redraw') {
					World.world.redrawLoc();
				}
				if (s[0]=='hud') {
					World.world.gui.vis.visible=!World.world.gui.vis.visible;
				}
				if (s[0]=='die') {
					World.world.gg.damage(10000,Unit.D_INSIDE);
				}
				if (s[0]=='hardreset' && World.world.pers.dead) {
					World.world.pers.dead=false;
					World.world.t_die=210;
					World.world.gg.anim('die',true);
					off();
				}
				if (s[0]=='hardinv') {
					Settings.hardInv=!Settings.hardInv;
				}
				if (s[0]=='res_watcher') {	//исправление бага с наблюдателем
					World.world.game.triggers['observer']=1;
				}
				if (s[0]=='mqt') {
					Settings.chitOn=!Settings.chitOn;
					World.world.saveConfig();
					return;
				}
				if (!Settings.chitOn) {
					off();
					return;
				}
				if (str=='?') {
					vis.help.visible=vis.list1.visible=vis.list2.visible=!vis.help.visible;
					return;
				}
				if (s[0]=='hardcoreMode') //Toggle Hardcore mode.
				{
					World.world.pers.hardcoreMode =! World.world.pers.hardcoreMode;
				}
				if (s[0]=='testmode') //Toggle debug testing mode.
				{
					Settings.testMode =! Settings.testMode;
				}
				if (s[0]=='dif') {
					World.world.game.globalDif=s[1];
					if (World.world.game.globalDif<0) World.world.game.globalDif=0;
					if (World.world.game.globalDif>4) World.world.game.globalDif=4;
					World.world.pers.setGlobalDif(World.world.game.globalDif);
					World.world.pers.setParameters();
				}
				if (s[0]=='all') {
					if (s.length==1) {
						World.world.invent.addAll();
						World.world.pers.addSkillPoint(10);
					}
					else if (s[1]=='weapon') World.world.invent.addAllWeapon();
					else if (s[1]=='ammo') World.world.invent.addAllAmmo();
					else if (s[1]=='item') World.world.invent.addAllItem();
					else if (s[1]=='armor') World.world.invent.addAllArmor();
					off();
				}
				if (s[0]=='min') {
					World.world.invent.addMin();
					off();
				}
				if (s[0]=='god') {
					Settings.godMode=!Settings.godMode;
				}
				if (s[0]=='lvl' || s[0]=='level') {
					World.world.pers.setForcLevel(s[1]);
				}
				if (s[0]=='xp') {
					World.world.pers.expa(s[1]);
				}
				if (s[0]=='sp') {
					if (s.length==1) World.world.pers.addSkillPoint();
					else World.world.pers.addSkillPoint(int(s[1]));
				}
				if (s[0]=='pp') {
					if (s.length==1) World.world.pers.perkPoint++;
					else  World.world.pers.perkPoint+=int(s[1]);
				}
				if (s[0]=='weapon') {
					if (s.length==2) World.world.invent.addWeapon(s[1]);
					else if (s.length>2) World.world.invent.updWeapon(s[1],1)
				}
				if (s[0]=='remw') {
					if (s.length==2) World.world.invent.remWeapon(s[1]);
				}
				if (s[0]=='armor') {
					if (s.length==2) World.world.invent.addArmor(s[1]);
				}
				if (s[0]=='money') {
					if (s.length==2) World.world.invent.items['money'].kol=int(s[1]);
				}
				if (s[0]=='item') {
					if (World.world.invent.items[s[1]]==null) return;
					if (s.length==3) World.world.invent.items[s[1]].kol=int(s[2]);
					else if (s.length==2) World.world.invent.items[s[1]].kol++;
					World.world.game.checkQuests(s[1]);
					World.world.pers.setParameters();
				}
				if (s[0]=='ammo') {
					if (s.length==3) World.world.invent.items[s[1]].kol=int(s[2]);
				}
				if (s[0]=='perk') {
					if (s.length==2) World.world.pers.addPerk(s[1]);
				}
				if (s[0]=='skill') {
					if (s.length==3) World.world.pers.setSkill(s[1], s[2]);
				}
				if (s[0]=='eff') {
					if (s.length==2) World.world.gg.addEffect(s[1]);
				}
				if (s[0]=='res') {
					if (World.world.gg.effects.length>0) {
						for each (var eff in World.world.gg.effects) eff.unsetEff();
					}
				}
				if (s[0]=='repair') {
					World.world.gg.currentWeapon.repair(1000000);
				}
				if (s[0]=='refill') {
					World.world.game.refillVendors();
				}
				if (s[0]=='rep') {
					if (s.length==2) World.world.pers.rep=int(s[1]);
				}
				if (s[0]=='crack') {
					if (s.length==2 && World.world.gg.currentWeapon) World.world.gg.currentWeapon.hp=Math.round(World.world.gg.currentWeapon.maxhp*Number(s[1])/100);
				}
				if (s[0]=='break') {
					if (s.length==2 && World.world.gg.currentArmor) World.world.gg.currentArmor.hp=Math.round(World.world.gg.currentArmor.maxhp*Number(s[1])/100);
				}
				if (s[0]=='heal') {
					World.world.gg.heal(10000);
				}
				if (s[0]=='rad') {
					World.world.gg.rad=s[1];
					World.world.gui.setAll();
				}
				if (s[0]=='mana') {
					World.world.pers.manaHP=int(s[1]);
					World.world.pers.setParameters();
				}
				if (s[0]=='check') {
					World.world.level.gotoCheckPoint();
				}
				if (s[0]=='goto') {
					if (s.length==3) World.world.level.gotoXY(s[1],s[2]);
				}
				if (s[0]=='map') {
					Settings.drawAllMap=!Settings.drawAllMap;
				}
				if (s[0]=='black') {
					Settings.black=!Settings.black;
					World.world.grafon.layerLighting.visible=Settings.black && World.world.room.black;
				}
				if (s[0]=='battle') {
					Settings.testBattle=!Settings.testBattle;
				}
				if (s[0]=='testeff') {
					Settings.testEff=!Settings.testEff;
				}
				if (s[0]=='testdam') {
					Settings.testDam=!Settings.testDam;
				}
				if (s[0]=='enemy') {
					if (Settings.enemyAct==3) Settings.enemyAct=0;
					else Settings.enemyAct=3;
				}
				if (s[0]=='lim') {
					if (s.length==2) World.world.level.lootLimit=Number(s[1]);
				}
				if (s[0]=='fly' || s[0]=='port' || s[0]=='emit') {
					Settings.chit=s[0];
					Settings.chitX=s[1];
				}
				if (s[0]=='getroom') {
					World.world.testLoot=true;
					trace('получено опыта', World.world.room.getAll());
					World.world.testLoot=false;
				}
				if (s[0]=='err') {
					World.world.landError=!World.world.landError;
				}
				if (s[0]=='getloc') {
					World.world.testLoot=true;
					trace('получено опыта', World.world.level.getAll());
					World.world.testLoot=false;
					//World.world.game.gotoNextLevel();			
				}
				if (s[0]=='alicorn') {
					if (Settings.alicorn) World.world.gg.alicornOff();
					else World.world.gg.alicornOn();
				}
				if (s[0]=='st') {
					if (s.length==3) World.world.game.triggers[s[1]]=s[2];
				}
				if (s[0]=='trigger') {
					if (s.length==2) World.world.gui.infoText('trigger',s[1],World.world.game.triggers[s[1]]);
				}
				if (s[0]=='triggers') {
					if (s.length>1) World.world.gui.infoText('trigger',s[1],World.world.game.triggers[s[1]]);
					else {
						for (var i in World.world.game.triggers)  World.world.gui.infoText('trigger',i,World.world.game.triggers[i]);
					}
				}
				
			//}
			World.world.gui.setAll();
		}

	}
	
}
