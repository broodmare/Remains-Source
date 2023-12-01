package servdata 
{

	import locdata.Level;
	import unitdata.Unit;
	
	import components.Settings;
	
	public class Script 
	{
		
		public var level:Level;
		public var owner:Obj;
		
		public var eve:String;	// Event that triggers the script
		public var acts:Array;
		public var actObj:Object;
		
		public var onTimer:Boolean = false;	// Are there commands with time delay
		public var running:Boolean = false;	// Script with time execution is running
		public var wait:Boolean = false;	// Waiting for button press
		public var ncom:int;
		public var tcom:int = 0;
		public var dial_n:int = -1;

		public function Script(xml:XML, newLevel:Level = null, nowner:Obj = null, tt:Boolean = false) 
		{
			level = newLevel;
			owner = nowner;
			acts = [];
			if (xml.@eve.length()) eve = xml.@eve;
			if (xml.@act.length()) analiz(xml);
			if (xml.s.length()) 
			{
				for each(var s:XML in xml.s) analiz(s);
			}
			if (tt) onTimer = true;
			if (level && onTimer) level.scripts.push(this);
		}
		
		//set public
		public function analiz(xml:XML):void
		{
			var act:String, targ:String, val:String, t:int = 0, n:String = '-1', opt1:int = 0, opt2:int = 0;
			if (xml.@act.length()) // Command
			{		
				act = xml.@act;
				if (act == 'dial' || act == 'dialog' || act == 'inform' || act == 'landlevel') onTimer = true;
			}
			if (xml.@targ.length()) targ = xml.@targ;		// Target
			if (xml.@val.length()) val = xml.@val;		// Value
			if (xml.@t.length()) // Delay in seconds
			{						
				t = Math.round(xml.@t * Settings.fps);
				if (t > 0) onTimer = true;
			}
			if (xml.@n.length()) n = xml.@n;		// Option
			if (xml.@opt1.length()) opt1 = xml.@opt1;		// Option
			if (xml.@opt2.length()) opt2 = xml.@opt2;		// Option
			if (act) acts.push({act:act, targ:targ, val:val, t:t, n:n, opt1:opt1, opt2:opt2});
		}
		
		// Script start
		public function start():void
		{
			if (acts.length <= 0) return;
			if (!onTimer) 
			{	// Execute everything at once
				for each(var obj:Object in acts) com(obj);
			} 
			else 
			{
				ncom = 0;
				com(acts[ncom]);
				tcom = acts[ncom].t;
				running = true;
			}
		}
		
		public function step():void
		{
			if (tcom > 0) tcom--;
			if (tcom <= 0) 
			{
				if (wait) 
				{
					if (World.world.ctr.keyPressed2) 
					{
						dial_n = 10000;
					} 
					else if (!World.world.ctr.keyPressed) return;
					if (dial_n < 0) 
					{
						World.world.gui.dialText();
						wait = false;
					}
					else 
					{
						dial_n++;
						if (World.world.gui.dialText(actObj.val, dial_n, actObj.opt1 > 0, true)) 
						{
							World.world.ctr.active = false;
							World.world.ctr.keyPressed = false;
							World.world.gg.levit = 0;
							return;
						} 
						else 
						{
							World.world.gui.dialText();
							World.world.gg.controlOn();
							wait = false;
						}
					}
					World.world.ctr.keyPressed  = false;
					World.world.ctr.keyPressed2 = false;
				}
				ncom++;
				if (ncom >= acts.length) 
				{
					running = false;
					World.world.gui.dialText();
				} 
				else 
				{
					com(acts[ncom]);
					tcom = acts[ncom].t;
				}
			}
		}
		
		// Command execution
		//set public
		public function com(obj:Object):void
		{
			if (obj == null) return;
			//trace('SCR', obj.targ, obj.act, obj.val);
			actObj = obj;
			if (World.world.gui.vis.dial.visible) World.world.gui.dialText();
			World.world.ctr.keyPressed 	= false;
			World.world.ctr.keyPressed2 = false;
			wait = false;
			dial_n = -1;
			if (obj.targ) 
			{
				var target:Obj;
				if (obj.targ == 'this') target = owner;
				else if (level) target = level.uidObjs[obj.targ];
				else target = World.world.level.uidObjs[obj.targ];

				if (target) target.command(obj.act, obj.val);
			} 
			else 
			{
				if (obj.act == 'control off') World.world.gg.controlOff();
				if (obj.act == 'control on') World.world.gg.controlOn();
				if (obj.act == 'mess') World.world.gui.messText(obj.val, '', obj.opt1 > 0, obj.opt2 > 0);
				if (obj.act == 'dial') 
				{
					if (!(obj.t > 0)) wait = true;
					World.world.ctr.active = false;
					World.world.gui.dialText(obj.val, obj.n, obj.opt1 > 0, wait);
				}
				if (obj.act == 'dialog') 
				{
					if (Settings.dialOn) 
					{
						World.world.gg.controlOff();
						wait = true;
						dial_n = 0;
						World.world.ctr.active = false;
						World.world.gui.dialText(actObj.val, dial_n, actObj.opt1 > 0, true);
						World.world.ctr.keyStates.keyJump = false;
						World.world.gg.levit = 0;
					}
				}
				if (obj.act == 'inform') 
				{
					World.world.gg.controlOff();
					wait = true;
					dial_n = 0;
					World.world.ctr.active = false;
					World.world.gui.dialText(<r mod = {actObj.opt2} push = {(actObj.opt1 > 0) ? '1':'0'}> {actObj.val}</r>, 0, false, true);
				}
				if (obj.act == 'landlevel') 
				{
					if (Settings.dialOn && World.world.game.levelArray[actObj.val]) 
					{
						World.world.gg.controlOff();
						wait=true;
						World.world.ctr.active=false;
						var str:String = Res.txt('map', actObj.val) + "\n" + Res.txt('pip', 'recLevel') + ': ['+World.world.game.levelArray[actObj.val].dif + "]\n" + Res.txt('pip', 'isperslvl') + ': [' + World.world.pers.level + ']';
						if (World.world.game.levelArray[actObj.val].dif > World.world.pers.level) 
						{
							str += '\n\n' + Res.txt('pip', 'wrLevel');
						}
						World.world.gui.dialText(<r mod='1'>{str}</r>, 0, false, true);
					}
				}
				if (obj.act == 'allact') 
				{
					World.world.room.allAct(null, obj.val, obj.n);
				}
				if (obj.act == 'take') 
				{
					if (obj.n < 0) 
					{
						if (World.world.invent.items[obj.val]) 
						{
							World.world.gui.infoText('withdraw', World.world.invent.items[obj.val].objectName, -obj.n);
							World.world.invent.minusItem(obj.val, -obj.n);
							World.world.pers.setParameters();
						}
					} 
					else 
					{
						var item:Item = new Item(null, obj.val, obj.n);
						World.world.invent.take(item);
					}
				}
				if (obj.act == 'armor') 
				{
					World.world.gg.changeArmor(obj.val, true);
				}
				if (obj.act == 'xp') World.world.pers.expa(obj.val,World.world.gg.X,World.world.gg.Y);
				if (obj.act == 'perk') World.world.pers.addPerk(obj.val);
				if (obj.act == 'eff') World.world.gg.addEffect(obj.val,obj.opt1,obj.opt2);
				if (obj.act == 'remeff') World.world.gg.remEffect(obj.val);
				if (obj.act == 'music') 
				{
					if (obj.n>0) Snd.playMusic(obj.val, obj.n);
					else Snd.playMusic(obj.val);
				}
				if (obj.act == 'music_rep') 
				{
					if (World.world.pers.rep>=World.world.pers.repGood) Snd.playMusic(obj.val);
				}
				if (obj.act == 'anim') World.world.gg.anim(obj.val,actObj.opt1>0);
				if (obj.act == 'turn') 
				{
					if (obj.val>0) World.world.gg.storona=1;
					else World.world.gg.storona=-1;
					World.world.gg.dx+=World.world.gg.storona*3;
				}
				if (obj.act == 'black') 
				{
					World.world.cam.dblack=0;
					if (obj.val>0)World.world.vblack.visible=true;
					World.world.vblack.alpha=obj.val;
				}
				if (obj.act == 'dblack') World.world.cam.dblack=obj.val;
				if (obj.act == 'gui off') 
				{
					World.world.gui.hpBarOnOff(false);
				}
				if (obj.act == 'gui on') 
				{
					World.world.gui.hpBarOnOff(true);
				}
				if (obj.act == 'refill') 
				{
					World.world.level.refill();
				}
				if (obj.act == 'upland') 
				{
					World.world.game.upLandLevel();
				}
				if (obj.act == 'locon') 
				{
					World.world.room.allon();
				}
				if (obj.act == 'locoff') 
				{
					World.world.room.alloff();
				}
				if (obj.act == 'quest') 
				{
					World.world.game.addQuest(obj.val);
				}
				if (obj.act == 'showstage')
				{
					World.world.game.showQuest(obj.val, obj.n);
				}
				if (obj.act == 'show') 
				{
					World.world.cam.showOn=false;
				}
				if (obj.act == 'stage') 
				{
					World.world.game.closeQuest(obj.val, obj.n);
				}
				if (obj.act == 'trigger') 
				{
					if (obj.n != null) World.world.game.setTrigger(obj.val, obj.n);
					else World.world.game.setTrigger(obj.val);
				}
				if (obj.act == 'goto') 
				{	//перейти в комнату
					var distr:Array = obj.val.split(' ');
					if (distr.length == 2) level.gotoXY(distr[0], distr[1]);
				}
				if (obj.act == 'gotoLevel') //перейти в местность
				{	
					if (obj.n == 2) World.world.game.gotoLevel(obj.val, null, true);
					else if (obj.n == 1) World.world.game.gotoLevel(obj.val, obj.opt1 + ':' + obj.opt2);
					else World.world.game.gotoLevel(obj.val);
				}
				if (obj.act == 'openland') //открыть местность на карте
				{	
					if (World.world.game.levelArray[obj.val]) 
					{
						World.world.game.levelArray[obj.val].access = true;
					} 
					else 
					{
						trace('error level ', obj.val)
					}
				}
				if (obj.act == 'passed') //местность пройдена
				{		
					World.world.level.levelTemplate.passed = true;
				}
				if (obj.act == 'actprob') 
				{
					if (World.world.room.prob) World.world.room.prob.activateProb();
				}
				if (obj.act == 'alarm') 
				{
					World.world.room.signal();
				}
				if (obj.act == 'trus') 
				{
					if (owner && owner.room) owner.room.trus = Number(obj.val);
					else World.world.room.trus = Number(obj.val);
				}
				if (obj.act == 'checkall') 
				{
					for each (var un:Unit in World.world.room.units) 
					{
						un.command('check');
					}
				}
				if (obj.act == 'robots') 
				{
					World.world.room.robocellActivate();
				}
				if (obj.act == 'weapch') 
				{
					World.world.gg.changeWeapon(obj.val);
				}
				if (obj.act == 'alicorn') 
				{
					if (obj.val <= 0) World.world.gg.alicornOff();
					else World.world.gg.alicornOn();
				}
				if (obj.act == 'wave') 
				{
					if (World.world.room.prob) World.world.room.prob.beginWave();
				}
				if (obj.act == 'pip') 
				{
					World.world.pip.onoff(obj.val, obj.n);
				}
				if (obj.act == 'speceffect') 
				{
					World.world.grafon.specEffect(obj.n);
				}
				if (obj.act == 'scene') 
				{
					if (obj.val) 
					{
						World.world.showScene(obj.val, obj.n);
					}
					else 
					{
						World.world.unshowScene();
					}
				}
				if (obj.act == 'endgame') 
				{
					World.world.endgame();
				}
				if (obj.act == 'gameover') 
				{
					World.world.endgame(1);
				}
				if (obj.act == 'wait') 
				{
					wait = true;
					dial_n = 0;
					World.world.ctr.active = false;
				}
			}
		}
	}
	
}
