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
					if (GameSession.currentSession.ctr.keyPressed2) 
					{
						dial_n = 10000;
					} 
					else if (!GameSession.currentSession.ctr.keyPressed) return;
					if (dial_n < 0) 
					{
						GameSession.currentSession.gui.dialText();
						wait = false;
					}
					else 
					{
						dial_n++;
						if (GameSession.currentSession.gui.dialText(actObj.val, dial_n, actObj.opt1 > 0, true)) 
						{
							GameSession.currentSession.ctr.active = false;
							GameSession.currentSession.ctr.keyPressed = false;
							GameSession.currentSession.gg.levit = 0;
							return;
						} 
						else 
						{
							GameSession.currentSession.gui.dialText();
							GameSession.currentSession.gg.controlOn();
							wait = false;
						}
					}
					GameSession.currentSession.ctr.keyPressed  = false;
					GameSession.currentSession.ctr.keyPressed2 = false;
				}
				ncom++;
				if (ncom >= acts.length) 
				{
					running = false;
					GameSession.currentSession.gui.dialText();
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
			if (GameSession.currentSession.gui.vis.dial.visible) GameSession.currentSession.gui.dialText();
			GameSession.currentSession.ctr.keyPressed 	= false;
			GameSession.currentSession.ctr.keyPressed2 = false;
			wait = false;
			dial_n = -1;
			if (obj.targ) 
			{
				var target:Obj;
				if (obj.targ == 'this') target = owner;
				else if (level) target = level.uidObjs[obj.targ];
				else target = GameSession.currentSession.level.uidObjs[obj.targ];

				if (target) target.command(obj.act, obj.val);
			} 
			else 
			{
				if (obj.act == 'control off') GameSession.currentSession.gg.controlOff();
				if (obj.act == 'control on') GameSession.currentSession.gg.controlOn();
				if (obj.act == 'mess') GameSession.currentSession.gui.messText(obj.val, '', obj.opt1 > 0, obj.opt2 > 0);
				if (obj.act == 'dial') 
				{
					if (!(obj.t > 0)) wait = true;
					GameSession.currentSession.ctr.active = false;
					GameSession.currentSession.gui.dialText(obj.val, obj.n, obj.opt1 > 0, wait);
				}
				if (obj.act == 'dialog') 
				{
					if (Settings.dialOn) 
					{
						GameSession.currentSession.gg.controlOff();
						wait = true;
						dial_n = 0;
						GameSession.currentSession.ctr.active = false;
						GameSession.currentSession.gui.dialText(actObj.val, dial_n, actObj.opt1 > 0, true);
						GameSession.currentSession.ctr.keyStates.keyJump = false;
						GameSession.currentSession.gg.levit = 0;
					}
				}
				if (obj.act == 'inform') 
				{
					GameSession.currentSession.gg.controlOff();
					wait = true;
					dial_n = 0;
					GameSession.currentSession.ctr.active = false;
					GameSession.currentSession.gui.dialText(<r mod = {actObj.opt2} push = {(actObj.opt1 > 0) ? '1':'0'}> {actObj.val}</r>, 0, false, true);
				}
				if (obj.act == 'landlevel') 
				{
					if (Settings.dialOn && GameSession.currentSession.game.levelArray[actObj.val]) 
					{
						GameSession.currentSession.gg.controlOff();
						wait=true;
						GameSession.currentSession.ctr.active=false;
						var str:String = Res.txt('map', actObj.val) + "\n" + Res.txt('pip', 'recLevel') + ': ['+GameSession.currentSession.game.levelArray[actObj.val].dif + "]\n" + Res.txt('pip', 'isperslvl') + ': [' + GameSession.currentSession.pers.level + ']';
						if (GameSession.currentSession.game.levelArray[actObj.val].dif > GameSession.currentSession.pers.level) 
						{
							str += '\n\n' + Res.txt('pip', 'wrLevel');
						}
						GameSession.currentSession.gui.dialText(<r mod='1'>{str}</r>, 0, false, true);
					}
				}
				if (obj.act == 'allact') 
				{
					GameSession.currentSession.room.allAct(null, obj.val, obj.n);
				}
				if (obj.act == 'take') 
				{
					if (obj.n < 0) 
					{
						if (GameSession.currentSession.invent.items[obj.val]) 
						{
							GameSession.currentSession.gui.infoText('withdraw', GameSession.currentSession.invent.items[obj.val].objectName, -obj.n);
							GameSession.currentSession.invent.minusItem(obj.val, -obj.n);
							GameSession.currentSession.pers.setParameters();
						}
					} 
					else 
					{
						var item:Item = new Item(null, obj.val, obj.n);
						GameSession.currentSession.invent.take(item);
					}
				}
				if (obj.act == 'armor') 
				{
					GameSession.currentSession.gg.changeArmor(obj.val, true);
				}
				if (obj.act == 'xp') GameSession.currentSession.pers.expa(obj.val,GameSession.currentSession.gg.X,GameSession.currentSession.gg.Y);
				if (obj.act == 'perk') GameSession.currentSession.pers.addPerk(obj.val);
				if (obj.act == 'eff') GameSession.currentSession.gg.addEffect(obj.val,obj.opt1,obj.opt2);
				if (obj.act == 'remeff') GameSession.currentSession.gg.remEffect(obj.val);
				if (obj.act == 'music') 
				{
					if (obj.n>0) Snd.playMusic(obj.val, obj.n);
					else Snd.playMusic(obj.val);
				}
				if (obj.act == 'music_rep') 
				{
					if (GameSession.currentSession.pers.rep>=GameSession.currentSession.pers.repGood) Snd.playMusic(obj.val);
				}
				if (obj.act == 'anim') GameSession.currentSession.gg.anim(obj.val,actObj.opt1>0);
				if (obj.act == 'turn') 
				{
					if (obj.val>0) GameSession.currentSession.gg.storona=1;
					else GameSession.currentSession.gg.storona=-1;
					GameSession.currentSession.gg.dx+=GameSession.currentSession.gg.storona*3;
				}
				if (obj.act == 'black') 
				{
					GameSession.currentSession.cam.dblack=0;
					if (obj.val>0)GameSession.currentSession.vblack.visible=true;
					GameSession.currentSession.vblack.alpha=obj.val;
				}
				if (obj.act == 'dblack') GameSession.currentSession.cam.dblack=obj.val;
				if (obj.act == 'gui off') 
				{
					GameSession.currentSession.gui.hpBarOnOff(false);
				}
				if (obj.act == 'gui on') 
				{
					GameSession.currentSession.gui.hpBarOnOff(true);
				}
				if (obj.act == 'refill') 
				{
					GameSession.currentSession.level.refill();
				}
				if (obj.act == 'upland') 
				{
					GameSession.currentSession.game.upLandLevel();
				}
				if (obj.act == 'locon') 
				{
					GameSession.currentSession.room.allon();
				}
				if (obj.act == 'locoff') 
				{
					GameSession.currentSession.room.alloff();
				}
				if (obj.act == 'quest') 
				{
					GameSession.currentSession.game.addQuest(obj.val);
				}
				if (obj.act == 'showstage')
				{
					GameSession.currentSession.game.showQuest(obj.val, obj.n);
				}
				if (obj.act == 'show') 
				{
					GameSession.currentSession.cam.showOn=false;
				}
				if (obj.act == 'stage') 
				{
					GameSession.currentSession.game.closeQuest(obj.val, obj.n);
				}
				if (obj.act == 'trigger') 
				{
					if (obj.n != null) GameSession.currentSession.game.setTrigger(obj.val, obj.n);
					else GameSession.currentSession.game.setTrigger(obj.val);
				}
				if (obj.act == 'goto') 
				{	//перейти в комнату
					var distr:Array = obj.val.split(' ');
					if (distr.length == 2) level.gotoXY(distr[0], distr[1]);
				}
				if (obj.act == 'gotoLevel') //перейти в местность
				{	
					if (obj.n == 2) GameSession.currentSession.game.gotoLevel(obj.val, null, true);
					else if (obj.n == 1) GameSession.currentSession.game.gotoLevel(obj.val, obj.opt1 + ':' + obj.opt2);
					else GameSession.currentSession.game.gotoLevel(obj.val);
				}
				if (obj.act == 'openland') //открыть местность на карте
				{	
					if (GameSession.currentSession.game.levelArray[obj.val]) 
					{
						GameSession.currentSession.game.levelArray[obj.val].access = true;
					} 
					else 
					{
						trace('error level ', obj.val)
					}
				}
				if (obj.act == 'passed') //местность пройдена
				{		
					GameSession.currentSession.level.levelTemplate.passed = true;
				}
				if (obj.act == 'actprob') 
				{
					if (GameSession.currentSession.room.prob) GameSession.currentSession.room.prob.activateProb();
				}
				if (obj.act == 'alarm') 
				{
					GameSession.currentSession.room.signal();
				}
				if (obj.act == 'trus') 
				{
					if (owner && owner.room) owner.room.trus = Number(obj.val);
					else GameSession.currentSession.room.trus = Number(obj.val);
				}
				if (obj.act == 'checkall') 
				{
					for each (var un:Unit in GameSession.currentSession.room.units) 
					{
						un.command('check');
					}
				}
				if (obj.act == 'robots') 
				{
					GameSession.currentSession.room.robocellActivate();
				}
				if (obj.act == 'weapch') 
				{
					GameSession.currentSession.gg.changeWeapon(obj.val);
				}
				if (obj.act == 'alicorn') 
				{
					if (obj.val <= 0) GameSession.currentSession.gg.alicornOff();
					else GameSession.currentSession.gg.alicornOn();
				}
				if (obj.act == 'wave') 
				{
					if (GameSession.currentSession.room.prob) GameSession.currentSession.room.prob.beginWave();
				}
				if (obj.act == 'pip') 
				{
					GameSession.currentSession.pip.onoff(obj.val, obj.n);
				}
				if (obj.act == 'speceffect') 
				{
					GameSession.currentSession.grafon.specEffect(obj.n);
				}
				if (obj.act == 'scene') 
				{
					if (obj.val) 
					{
						GameSession.currentSession.showScene(obj.val, obj.n);
					}
					else 
					{
						GameSession.currentSession.unshowScene();
					}
				}
				if (obj.act == 'endgame') 
				{
					GameSession.currentSession.endgame();
				}
				if (obj.act == 'gameover') 
				{
					GameSession.currentSession.endgame(1);
				}
				if (obj.act == 'wait') 
				{
					wait = true;
					dial_n = 0;
					GameSession.currentSession.ctr.active = false;
				}
			}
		}
	}
	
}
