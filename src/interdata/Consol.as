package interdata 
{
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	import unitdata.Unit;
	import servdata.QuestHelper;
	
	import components.Settings;
	import systems.Languages;
	
	public class Consol 
	{
		public var vis:MovieClip;
		public var ist:Array;
		public var istN:int = 0;
		
		//TODO: Extract this.
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
			//TODO: Don't access languages' stuff directly like this.
			for each(i in Languages.currentLanguageData.weapon) vis.list1.text += i.@id + ' \t' + i.n[0] + '\n';
			for each(i in Languages.currentLanguageData.item) vis.list2.text += i.@id + ' \t' + i.n[0] + '\n';
			for each(i in Languages.currentLanguageData.ammo) vis.list2.text += i.@id + ' \t' + i.n[0] + '\n';
			vis.help.visible = vis.list1.visible = vis.list2.visible = false;
		}
		
		public function onKeyboardDownEvent(event:KeyboardEvent):void 
		{
			if (event.keyCode == Keyboard.ENTER) analis();
			if (event.keyCode == Keyboard.END || event.keyCode == Keyboard.ESCAPE) GameSession.currentSession.consolOnOff();

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
			var session = GameSession.currentSession;
			var str:String = vis.input.text;
			ist.push(str);
			GameSession.currentSession.lastCom = str;
			GameSession.currentSession.saveConfig();
			istN = ist.length;
			vis.input.text = '';
			var s:Array = str.split(' ');
			switch (s[0]) 
			{
				case 'clear':
					session.cam.dblack = 0;
					session.gg.controlOn();
					session.gg.vis.visible = true;
					session.vblack.alpha = 0;
					session.vblack.visible = false;
					session.t_exit = 0;
					session.t_die = 0;
					session.vgui.visible = true;
					session.skybox.visible = true;
					session.mainCanvas.visible = true;
					Snd.off = false;
					break;
				case 'redraw':
					session.redrawLoc();
					break;
				case 'hud':
					session.gui.vis.visible =! session.gui.vis.visible;
					break;
				case 'die':
					session.gg.damage(10000, Unit.D_INSIDE);
					break;
				case 'hardreset':
					if (session.pers.dead)
					{
						session.pers.dead = false;
						session.t_die = 210;
						session.gg.anim('die', true);
						off();
					}
					break;
				case 'hardinv':
					Settings.hardInv =! Settings.hardInv;
					break;
				case 'res_watcher':
					session.game.triggers['observer'] = 1; //исправление бага с наблюдателем
					break;
				case 'mqt':
					Settings.chitOn =! Settings.chitOn;
					session.saveConfig();
					break;
				case '?':
					vis.help.visible = vis.list1.visible = vis.list2.visible =! vis.help.visible;
					break;
				//TODO: Re-implement check that chitOn == true for commands below this point.
				case 'hardcoreMode':
					session.pers.hardcoreMode =! session.pers.hardcoreMode;
					break;
				case 'testmode':
					Settings.testMode =! Settings.testMode;
					break;
				case 'dif':
					session.game.globalDif = s[1];
					if (session.game.globalDif < 0) session.game.globalDif = 0;
					if (session.game.globalDif > 4) session.game.globalDif = 4;
					session.pers.setGlobalDif(session.game.globalDif);
					session.pers.setParameters();
					break;
				case 'all':
					if (s.length == 1)
					{
						session.invent.addAll();
						session.pers.addSkillPoint(10);
					}
					else if (s[1]=='weapon') session.invent.addAllWeapon();
					else if (s[1]=='ammo') session.invent.addAllAmmo();
					else if (s[1]=='item') session.invent.addAllItem();
					else if (s[1]=='armor') session.invent.addAllArmor();
					off();
					break;
				case 'min':
					session.invent.addMin();
					off();
					break;
				case 'god':
					Settings.godMode =! Settings.godMode;
					break;
				case 'level':
					session.pers.setForcLevel(s[1]);
					break;
				case 'xp':
					session.pers.expa(s[1]);
					break;
				case 'sp':
					if (s.length == 1) session.pers.addSkillPoint();
					else session.pers.addSkillPoint(int(s[1]));
					break;
				case 'pp':
					if (s.length == 1) session.pers.perkPoint++;
					else  session.pers.perkPoint+=int(s[1]);
					break;
				case 'weapon':
					if (s.length == 2) session.invent.addWeapon(s[1]);
					else if (s.length > 2) session.invent.updWeapon(s[1],1)
					break;
				case 'remw':
					if (s.length == 2) session.invent.remWeapon(s[1]);
					break;
				case 'armor':
					if (s.length == 2) session.invent.addArmor(s[1]);
					break;
				case 'money':
					if (s.length == 2) session.invent.items['money'].kol=int(s[1]);
					break;
				case 'item':
					if (session.invent.items[s[1]]==null) return;
					if (s.length == 3) session.invent.items[s[1]].kol=int(s[2]);
					else if (s.length == 2) session.invent.items[s[1]].kol++;
					QuestHelper.checkQuests(s[1]);
					session.pers.setParameters();
					break;
				case 'ammo':
					if (s.length == 3) session.invent.items[s[1]].kol=int(s[2]);
					break;
				case 'perk':
					if (s.length == 2) session.pers.addPerk(s[1]);
					break;
				case 'skill':
					if (s.length == 3) session.pers.setSkill(s[1], s[2]);
					break;
				case 'eff':
					if (s.length == 2) session.gg.addEffect(s[1]);
					break;
				case 'res':
					if (session.gg.effects.length > 0) 
					{
						for each (var eff in session.gg.effects) eff.unsetEff();
					}
					break;
				case 'repair':
					session.gg.currentWeapon.repair(1000000);
					break;
				case 'refill':
					session.game.refillVendors();
					break;
				case 'rep':
					if (s.length == 2) session.pers.rep=int(s[1]);
					break;
				case 'crack':
					if (s.length == 2 && session.gg.currentWeapon) session.gg.currentWeapon.hp=Math.round(session.gg.currentWeapon.maxhp*Number(s[1])/100);
					break;
				case 'break':
					if (s.length == 2 && session.gg.currentArmor) session.gg.currentArmor.hp=Math.round(session.gg.currentArmor.maxhp*Number(s[1])/100);
					break;
				case 'heal':
					session.gg.heal(10000);
					break;
				case 'rad':
					session.gg.rad=s[1];
					session.gui.setAll();
					break;
				case 'mana':
					session.pers.manaHP = int(s[1]);
					session.pers.setParameters();
					break;
				case 'check':
					session.level.gotoCheckPoint();
					break;
				case 'goto':
					if (s.length == 3) session.level.gotoXY(s[1], s[2]);
					break;
				case 'map':
					Settings.drawAllMap =! Settings.drawAllMap;
					break;
				case 'black':
					Settings.black =! Settings.black;
					session.grafon.layerLighting.visible = Settings.black && session.room.black;
					break;
				case 'battle':
					Settings.testBattle =! Settings.testBattle;
					break;
				case 'testeff':
					Settings.testEff =! Settings.testEff;
					break;
				case 'testdam':
					Settings.testDam =! Settings.testDam;
					break;
				case 'enemy':
					if (Settings.enemyAct == 3) Settings.enemyAct = 0;
					else Settings.enemyAct = 3;
					break;
				case 'lim':
					if (s.length == 2) session.level.lootLimit = Number(s[1]);
					break;
				case 'fly':
					Settings.chit  = s[0];
					Settings.chitX = s[1];
					break;
				case 'port':
					Settings.chit  = s[0];
					Settings.chitX = s[1];
					break;
				case 'emit':
					Settings.chit  = s[0];
					Settings.chitX = s[1];
					break;
				case 'getroom':
					session.testLoot = true;
					trace('получено опыта', session.room.getAll());
					session.testLoot = false;
					break;
				case 'getloc':
					session.testLoot = true;
					trace('получено опыта', session.level.getAll());
					session.testLoot = false;
					break;
				case 'alicorn':
					if (Settings.alicorn) session.gg.alicornOff();
					else session.gg.alicornOn();
					break;
				case 'st':
					if (s.length == 3) session.game.triggers[s[1]]=s[2];
					break;
				case 'trigger':
					if (s.length == 2) session.gui.infoText('trigger',s[1],session.game.triggers[s[1]]);
					break;
				case 'triggers':
					if (s.length > 1) session.gui.infoText('trigger',s[1],session.game.triggers[s[1]]);
					else 
					{
						for (var i in session.game.triggers)  session.gui.infoText('trigger',i,session.game.triggers[i]);
					}
					break;
				default:
					off();
					break;
			}
			session.gui.setAll();
		}
	}	
}