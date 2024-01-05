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
		public var istN:int = 0;
		
		private var help:XML = <chit>
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

		public function Consol(vcons:MovieClip, prev:String = null) 
		{
			vis = vcons;
			ist = [];
			if (prev != null) ist.push(prev);
			vis.visible = false;
			vis.input.addEventListener(KeyboardEvent.KEY_DOWN,onKeyboardDownEvent);
			vis.butEnter.addEventListener(MouseEvent.CLICK,onButEnter);
			vis.butClose.addEventListener(MouseEvent.CLICK,onButClose);
			for each(var i in help.a) vis.help.text += i + '\n';
			for each(i in Res.localizationFile.weapon) vis.list1.text += i.@id + ' \t' + i.n[0] + '\n';
			for each(i in Res.localizationFile.item) vis.list2.text += i.@id + ' \t' + i.n[0] + '\n';
			for each(i in Res.localizationFile.ammo) vis.list2.text += i.@id + ' \t' + i.n[0] + '\n';
			vis.help.visible = vis.list1.visible = vis.list2.visible = false;
		}
		
		public function onKeyboardDownEvent(event:KeyboardEvent):void 
		{
			if (event.keyCode==Keyboard.ENTER) 
			{
				analis();
			}
			if (event.keyCode == Keyboard.END || event.keyCode == Keyboard.ESCAPE) 
			{
				GameSession.currentSession.consolOnOff();
			}
			if (event.keyCode == Keyboard.UP) 
			{
				if (istN > 0) istN--;
				if (istN < ist.length) vis.input.text = ist[istN];
			}
			if (event.keyCode == Keyboard.DOWN) 
			{
				if (istN<ist.length) istN++;
				if (istN<ist.length) vis.input.text=ist[istN];
			}
			event.stopPropagation();
		}
		
		public function onButEnter(event:MouseEvent):void
		{
			analis();
			event.stopPropagation();
		}
		public function onButClose(event:MouseEvent):void 
		{
			GameSession.currentSession.consolOnOff();
			event.stopPropagation();
		}
		
		public var visoff:Boolean = false;
		
		public function off():void
		{
			visoff = true;
		}
		
		public function analis():void
		{
			var str:String = vis.input.text;
			ist.push(str);
			GameSession.currentSession.lastCom = str;
			GameSession.currentSession.saveConfig();
			istN = ist.length;
			vis.input.text = '';
			var s:Array = str.split(' ');
				if (s[0]=='clear') 
				{
					GameSession.currentSession.cam.dblack = 0;
					GameSession.currentSession.gg.controlOn();
					GameSession.currentSession.gg.vis.visible = true;
					GameSession.currentSession.vblack.alpha = 0;
					GameSession.currentSession.vblack.visible = false;
					GameSession.currentSession.t_exit = GameSession.currentSession.t_die=0;
					GameSession.currentSession.vgui.visible = GameSession.currentSession.skybox.visible = GameSession.currentSession.mainCanvas.visible = true;
					Snd.off = false;
				}
				if (s[0]=='redraw') 
				{
					GameSession.currentSession.redrawLoc();
				}
				if (s[0]=='hud') 
				{
					GameSession.currentSession.gui.vis.visible=!GameSession.currentSession.gui.vis.visible;
				}
				if (s[0]=='die') 
				{
					GameSession.currentSession.gg.damage(10000,Unit.D_INSIDE);
				}
				if (s[0]=='hardreset' && GameSession.currentSession.pers.dead) 
				{
					GameSession.currentSession.pers.dead=false;
					GameSession.currentSession.t_die=210;
					GameSession.currentSession.gg.anim('die',true);
					off();
				}
				if (s[0]=='hardinv') 
				{
					Settings.hardInv=!Settings.hardInv;
				}
				if (s[0]=='res_watcher') 
				{	//исправление бага с наблюдателем
					GameSession.currentSession.game.triggers['observer']=1;
				}
				if (s[0]=='mqt') 
				{
					Settings.chitOn=!Settings.chitOn;
					GameSession.currentSession.saveConfig();
					return;
				}
				if (!Settings.chitOn) 
				{
					off();
					return;
				}
				if (str=='?')
				{
					vis.help.visible=vis.list1.visible=vis.list2.visible=!vis.help.visible;
					return;
				}
				if (s[0]=='hardcoreMode') //Toggle Hardcore mode.
				{
					GameSession.currentSession.pers.hardcoreMode =! GameSession.currentSession.pers.hardcoreMode;
				}
				if (s[0]=='testmode') //Toggle debug testing mode.
				{
					Settings.testMode =! Settings.testMode;
				}
				if (s[0]=='dif') 
				{
					GameSession.currentSession.game.globalDif=s[1];
					if (GameSession.currentSession.game.globalDif<0) GameSession.currentSession.game.globalDif=0;
					if (GameSession.currentSession.game.globalDif>4) GameSession.currentSession.game.globalDif=4;
					GameSession.currentSession.pers.setGlobalDif(GameSession.currentSession.game.globalDif);
					GameSession.currentSession.pers.setParameters();
				}
				if (s[0]=='all') 
				{
					if (s.length==1)
					{
						GameSession.currentSession.invent.addAll();
						GameSession.currentSession.pers.addSkillPoint(10);
					}
					else if (s[1]=='weapon') GameSession.currentSession.invent.addAllWeapon();
					else if (s[1]=='ammo') GameSession.currentSession.invent.addAllAmmo();
					else if (s[1]=='item') GameSession.currentSession.invent.addAllItem();
					else if (s[1]=='armor') GameSession.currentSession.invent.addAllArmor();
					off();
				}
				if (s[0]=='min') 
				{
					GameSession.currentSession.invent.addMin();
					off();
				}
				if (s[0]=='god') 
				{
					Settings.godMode=!Settings.godMode;
				}
				if (s[0]=='lvl' || s[0]=='level') 
				{
					GameSession.currentSession.pers.setForcLevel(s[1]);
				}
				if (s[0]=='xp') 
				{
					GameSession.currentSession.pers.expa(s[1]);
				}
				if (s[0]=='sp') 
				{
					if (s.length == 1) GameSession.currentSession.pers.addSkillPoint();
					else GameSession.currentSession.pers.addSkillPoint(int(s[1]));
				}
				if (s[0]=='pp') 
				{
					if (s.length == 1) GameSession.currentSession.pers.perkPoint++;
					else  GameSession.currentSession.pers.perkPoint+=int(s[1]);
				}
				if (s[0]=='weapon') 
				{
					if (s.length == 2) GameSession.currentSession.invent.addWeapon(s[1]);
					else if (s.length > 2) GameSession.currentSession.invent.updWeapon(s[1],1)
				}
				if (s[0]=='remw') 
				{
					if (s.length == 2) GameSession.currentSession.invent.remWeapon(s[1]);
				}
				if (s[0]=='armor') 
				{
					if (s.length == 2) GameSession.currentSession.invent.addArmor(s[1]);
				}
				if (s[0]=='money') 
				{
					if (s.length == 2) GameSession.currentSession.invent.items['money'].kol=int(s[1]);
				}
				if (s[0]=='item') 
				{
					if (GameSession.currentSession.invent.items[s[1]]==null) return;
					if (s.length == 3) GameSession.currentSession.invent.items[s[1]].kol=int(s[2]);
					else if (s.length == 2) GameSession.currentSession.invent.items[s[1]].kol++;
					GameSession.currentSession.game.checkQuests(s[1]);
					GameSession.currentSession.pers.setParameters();
				}
				if (s[0]=='ammo') 
				{
					if (s.length == 3) GameSession.currentSession.invent.items[s[1]].kol=int(s[2]);
				}
				if (s[0]=='perk') 
				{
					if (s.length == 2) GameSession.currentSession.pers.addPerk(s[1]);
				}
				if (s[0]=='skill') 
				{
					if (s.length == 3) GameSession.currentSession.pers.setSkill(s[1], s[2]);
				}
				if (s[0]=='eff') 
				{
					if (s.length == 2) GameSession.currentSession.gg.addEffect(s[1]);
				}
				if (s[0]=='res') 
				{
					if (GameSession.currentSession.gg.effects.length > 0) 
					{
						for each (var eff in GameSession.currentSession.gg.effects) eff.unsetEff();
					}
				}
				if (s[0]=='repair') 
				{
					GameSession.currentSession.gg.currentWeapon.repair(1000000);
				}
				if (s[0]=='refill') 
				{
					GameSession.currentSession.game.refillVendors();
				}
				if (s[0]=='rep') 
				{
					if (s.length == 2) GameSession.currentSession.pers.rep=int(s[1]);
				}
				if (s[0]=='crack') 
				{
					if (s.length == 2 && GameSession.currentSession.gg.currentWeapon) GameSession.currentSession.gg.currentWeapon.hp=Math.round(GameSession.currentSession.gg.currentWeapon.maxhp*Number(s[1])/100);
				}
				if (s[0]=='break') 
				{
					if (s.length == 2 && GameSession.currentSession.gg.currentArmor) GameSession.currentSession.gg.currentArmor.hp=Math.round(GameSession.currentSession.gg.currentArmor.maxhp*Number(s[1])/100);
				}
				if (s[0]=='heal') 
				{
					GameSession.currentSession.gg.heal(10000);
				}
				if (s[0]=='rad') 
				{
					GameSession.currentSession.gg.rad=s[1];
					GameSession.currentSession.gui.setAll();
				}
				if (s[0]=='mana') 
				{
					GameSession.currentSession.pers.manaHP=int(s[1]);
					GameSession.currentSession.pers.setParameters();
				}
				if (s[0]=='check') 
				{
					GameSession.currentSession.level.gotoCheckPoint();
				}
				if (s[0]=='goto') 
				{
					if (s.length == 3) GameSession.currentSession.level.gotoXY(s[1],s[2]);
				}
				if (s[0]=='map') 
				{
					Settings.drawAllMap=!Settings.drawAllMap;
				}
				if (s[0]=='black') 
				{
					Settings.black=!Settings.black;
					GameSession.currentSession.grafon.layerLighting.visible=Settings.black && GameSession.currentSession.room.black;
				}
				if (s[0]=='battle') 
				{
					Settings.testBattle=!Settings.testBattle;
				}
				if (s[0]=='testeff') 
				{
					Settings.testEff=!Settings.testEff;
				}
				if (s[0]=='testdam') 
				{
					Settings.testDam=!Settings.testDam;
				}
				if (s[0]=='enemy') 
				{
					if (Settings.enemyAct==3) Settings.enemyAct=0;
					else Settings.enemyAct=3;
				}
				if (s[0]=='lim') 
				{
					if (s.length == 2) GameSession.currentSession.level.lootLimit=Number(s[1]);
				}
				if (s[0]=='fly' || s[0]=='port' || s[0]=='emit') 
				{
					Settings.chit=s[0];
					Settings.chitX=s[1];
				}
				if (s[0]=='getroom') 
				{
					GameSession.currentSession.testLoot=true;
					trace('получено опыта', GameSession.currentSession.room.getAll());
					GameSession.currentSession.testLoot=false;
				}
				if (s[0]=='getloc') 
				{
					GameSession.currentSession.testLoot=true;
					trace('получено опыта', GameSession.currentSession.level.getAll());
					GameSession.currentSession.testLoot=false;		
				}
				if (s[0]=='alicorn') 
				{
					if (Settings.alicorn) GameSession.currentSession.gg.alicornOff();
					else GameSession.currentSession.gg.alicornOn();
				}
				if (s[0]=='st') 
				{
					if (s.length == 3) GameSession.currentSession.game.triggers[s[1]]=s[2];
				}
				if (s[0]=='trigger') 
				{
					if (s.length == 2) GameSession.currentSession.gui.infoText('trigger',s[1],GameSession.currentSession.game.triggers[s[1]]);
				}
				if (s[0]=='triggers') 
				{
					if (s.length > 1) GameSession.currentSession.gui.infoText('trigger',s[1],GameSession.currentSession.game.triggers[s[1]]);
					else 
					{
						for (var i in GameSession.currentSession.game.triggers)  GameSession.currentSession.gui.infoText('trigger',i,GameSession.currentSession.game.triggers[i]);
					}
				}
				
			GameSession.currentSession.gui.setAll();
		}

	}
	
}
