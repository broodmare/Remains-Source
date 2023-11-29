package servdata 
{
	import flash.media.SoundChannel;
	import flash.sampler.StackFrame;

	import locdata.*;
	import unitdata.Unit;
	import weapondata.Bullet;
	import unitdata.UnitPlayer;
	import graphdata.Emitter;
	
	import components.Settings;
	
	public class Interact 
	{
		
		//public var id:String;
		
		public var inited:Boolean = false;
		public var owner:Obj;
		public var room:Room;
		public var X:Number, Y:Number;
		
		public var active:Boolean=true;	// object is active
		// action displayed in GUI
		public var action:int=0;		// action that can be performed on it //1 - open  2 - use  3 - disarm
		public var userAction:String;	// specified action (id)
		
		public var xml:XML;				// individual parameter taken from the map
			
		public var cont:String;			// loot container
		public var door:int=0;			// door
		public var knop:int=0;			// button
		public var expl:int=0;			// bomb
		
		public var lock:int = 0;			// locked (lock difficulty)
		public var lockTip:int = 1;		// lock type 1 - normal (lockpick), 2 - electronic (hacker), 3 - booby-trapped, 4 - disable (repair), 5 - fix (repair), 0 - cannot be lockpicked
		public var lockLevel:int = 0;		// lock level (skill level requirements)
		public var lockAtt:int = -100;	// attempts
		public var lockHP:Number = 10;	// lock's HP
		public var noRuna:Boolean = false;// cannot use rune or lockpick
		public var low:Number = 0;		// probability of halving lock difficulty
		public var mine:int = 0;			// booby-trapped
		public var mineTip:int = 3;		// 3 - bomb, 6 - alarm
		public var damage:Number = 0;		// explosion damage
		public var destroy:Number = 0;	// destruction from explosion
		public var explRadius:Number = 260;	// explosion radius
		public var damdis:Number = 50;		// shock damage
		public var at_once:int = 0;		// 1 - apply the main action immediately after lockpicking or disarming, 2 - make it inactive after that
		public var lockKey:String;		// lock key
		public var cons:String;			// decrease the number of keys after successful use: 0 - do not decrease, 1 - use the key immediately, 2 - use only if the lock cannot be opened by other means
		public var allDif:Number = -1;		// overall lock and bomb difficulty
		public var xp:int = 0;			// experience for unlocking
		
		public var allact:String;		// specified action for the entire room
		public var allid:String;		// ID for the specified action
		public var needSkill:String;
		public var needSkillLvl:int = 0;
		public var is_hack:Boolean = false;	// controlled by access terminal
		public var open:Boolean = false;	// opened
		public var prob:String = null;		// transition to a trial
		public var noBase:Boolean = false;	// base rules do not apply here
		public var prize:Boolean = false;	// trial prize container
		
		public var is_act:Boolean = false;
		public var is_ready:Boolean = true;
		public var t_action:int = 0;
		public var unlock:int = 0;		// lockpicking ability
		public var master:int = 0;		// lockpicking mastery
		
		public var stateText = '';
		public var actionText = '';
		public var sndAct = '';
		
		public var successUnlock:Function;
		public var fiascoUnlock:Function;
		public var successRemine:Function;
		public var fiascoRemine:Function;
		public var actFun:Function;
		
		public var area:Area;	// Attached area
		
		public var sign:int = 0;	// Pointer
		public var t_sign:int = 0;
		
		public var isMove:Boolean=false;		// There is movement
		public var begX:Number=0, begY:Number=0, endX:Number=0, endY:Number=0, endX2:Number=0;	// Coordinates of the starting and ending points
		public var t_move:Number=0, dt_move:Number=1;		// Timer
		public var tStay:int=10, tMove:int=100;		// Time to stay and time to move
		public var moveSt:int=0;					// Movement mode 0 - stand, 1 - from start to end, 2 - from end to start, 3 - from one end to the other, 4 - continuous
		public var moveP:Boolean=false;					// If true, there is movement at this moment, if false, it stands
		public var moveCh:SoundChannel;
		
		public var lootBroken:Boolean=false;
		
		public var autoClose:int=0;
		public var t_autoClose:int=0;
		public var t_budilo:int=0;
		
		public var scrAct:Script, scrOpen:Script, scrClose:Script, scrTouch:Script;
		
		// Changes to states that are saved
		public var saveMine:int = 0;			// 101 - mine disarmed or exploded
		public var saveLock:int = 0;			// 101 - unlocked, 102 - jammed
		public var saveLoot:int = 0;	// 1 - loot obtained, 2 - loot obtained, critical loot exists
		public var saveOpen:int = 0;			// 1 - opened
		public var saveExpl:int = 0;
		
		public const maxLockLvl:int = 24;
		public const maxMechLvl:int = 7;
		
		public static var chanceUnlock:Array=[0.9, 0.75, 0.5, 0.3, 0.15, 0.05, 0.01];
		public static var chanceUnlock2:Array=[0.95, 0.8, 0.55, 0.35, 0.2, 0.08, 0.03];
		
		// node - template, xml - individual parameter taken from the map
		public function Interact(own:Obj, node:XML = null, nxml:XML = null, loadObj:Object = null) 
		{
			owner=own;
			room=owner.room;
			X=own.X, Y=own.Y;
			xml=nxml;
			var rnd:Boolean = true;
			if (xml && xml.@set.length()) rnd=false;	// if the set property is specified as '1', there won't be random parameters
			// lock type
			if (node && node.@locktip.length()) lockTip=node.@locktip;
			if (xml && xml.@locktip.length()) lockTip=xml.@locktip;
			if (node)  // content
			{
				if (node.@cont.length()) cont=node.@cont;
				// lock
				if (node.@lock.length()) 
				{
					var lk:Number=Number(node.@lock);
					if (rnd)  // random lock
					{		
						if (node.@lockch.length()==0 || Math.random()<Number(node.@lockch)) 
						{
							if (lockTip==1 || lockTip==2) {
								lock=Math.floor(lk+(0.3+Math.random())*room.locksLevel);
							} 
							else 
							{
								lock=Math.floor(lk+Math.random()*room.mechLevel);
							}
						}
						if (Math.random()<lk-Math.floor(lk)) lock+=1;
					} 
					else  // specified lock
					{		
						lock=Math.floor(lk);
					}
				}
				if (node.@low.length()) low=node.@low;
				saveLock=lock;
				// lock HP
				if (node.@lockhp.length()) lockHP=node.@lockhp;
				// mined
				if (node.@mine.length()) 
				{
					if (rnd) 
					{
						if (node.@minech.length()) 
						{
							if (Math.random()<Number(node.@minech))	mine=Math.floor(Math.random()*(Number(node.@mine)+Math.random()*room.mechLevel+1));
						} 
						else mine=Math.floor(Number(node.@mine)+Math.random()*room.mechLevel);
						if (mine>=2 && Math.random()<0.25) mine--;
					} 
					else 
					{
						mine=node.@mine;
					}
					if (node.@minetip.length()) mineTip=node.@minetip;
					else if (node.@inter!='3' && Math.random()<0.4) mineTip=6;
				}
				saveMine=mine;
				// can be hacked
				if (node.@hack>0) is_hack=true;
				// common action
				if (node.@allact.length()) allact=node.@allact;
				// action
				action=node.@inter;
				if (node.@xp.length()) xp=node.@xp;
				if (node.@once.length()) at_once=node.@once;
				if (node.@door.length()) door=node.@door;
				if (node.@knop.length()) knop=node.@knop;
				if (node.@time.length()) t_action=node.@time;
				if (node.@expl.length()) expl=node.@expl;
				if (node.@autoclose.length()) autoClose=node.@autoclose;
			}
			if (xml) 
			{
				if (xml.@off.length()) active=false;
				if (xml.@open.length()) 
				{
					setAct('open',1);
					update();
				}
				if (xml.@cont.length()) cont=xml.@cont;
				if (xml.@lock.length()) 
				{
					lock=xml.@lock;
					saveLock=lock;
					low=0;
					if (xml.@lock=='0') mine=saveMine=0;
				}
				if (xml.@locklevel.length()) lockLevel=xml.@locklevel;
				if (xml.@key.length()) lockKey=xml.@key;
				if (xml.@cons.length()) cons=xml.@cons;
				if (xml.@lockhp.length()) lockHP=xml.@lockhp;
				if (xml.@lockatt.length()) lockAtt=xml.@lockatt;
				if (xml.@mine.length()) 
				{
					mine=xml.@mine;
					saveMine=mine;
				}
				if (xml.@minetip.length()) mineTip=xml.@minetip;
				if (xml.@autoclose.length()) autoClose=xml.@autoclose;
				if (xml.@hack.length()) is_hack=xml.@hack>0;
				if (xml.@allact.length()) allact=xml.@allact;
				if (xml.@allid.length()) allid=xml.@allid;
				if (xml.@prob.length()) prob=xml.@prob;
				if (xml.@inter.length()) action=xml.@inter;
				if (xml.@time.length()) t_action=xml.@time;
				if (xml.@knop.length()) knop=xml.@knop;
				if (xml.@damage.length()) damage=xml.@damage;
				if (xml.@prize.length()) prize=true;
				if (xml.@nobase.length()) noBase=true;
				if (xml.@noruna.length()) noRuna=true;
				if (xml.@sign.length()) sign=xml.@sign;
				
				if (xml.move.length()) 
				{
					isMove=true;
					begX=X, begY=Y;
					if (xml.move.@dx.length()) 
					{
						if (room && room.mirror) endX=X-xml.move.@dx*Settings.tilePixelWidth;
						else endX=X+xml.move.@dx*Settings.tilePixelWidth;
					} else endX=endX2=X;
					if (xml.move.@dy.length()) endY=Y+xml.move.@dy*Settings.tilePixelHeight;
					else endY=Y;
					if (xml.move.@tstay.length()) tStay=xml.move.@tstay;
					if (xml.move.@tmove.length()) tMove=xml.move.@tmove;
					if (xml.move.@on.length()) moveSt=4;
				}
			}
			if (room && room.base && cont!=null && !noBase) 
			{
				cont=null;
				lock=mine=saveMine=saveLock=0;
				action=0;
				active=false;
			}
			if (room && (room.homeStable) && !noBase) 
			{
				lock=mine=saveMine=saveLock=0;
			}
			if (room && (room.homeAtk) && !noBase) 
			{
				lock=mine=saveMine=saveLock=0;
				if (cont && own is Box) {
					setAct('loot',1);
				}
			}
			if (loadObj) load(loadObj);
			var difSet:Boolean=(allDif>=0);
			if (lock<100) 
			{
				if (lockTip==1 || lockTip==2) 
				{
					if (low>0 && Math.random()<low) lock=Math.ceil(lock*0.5);
					if (lock>maxLockLvl) lock=maxLockLvl;
					if (lock>0 && low<=0 && own && own.room && own.room.level.rnd && own.room.prob==null && Math.random()<0.2) lock+=Math.floor(Math.random()*2)+2;
					//определить уровень замка
					if (lock>2 && lockLevel==0) 
					{
						lockLevel=Math.round(Math.random()*(lock-2)/3.2);
						if (lockLevel>5) lockLevel=5;
					}
					if (!difSet) allDif=lock+lockLevel*2;
				} 
				else 
				{
					if (lock>maxMechLvl) lock=maxMechLvl;
					if (!difSet) allDif=lock*3;
				}
			}
			if (mine>maxMechLvl) mine=maxMechLvl;
			if (mine>0) 
			{
				if (mineTip==6) 
				{
					fiascoRemine=alarm;
				} 
				else 
				{
					damage=mine*50*(0.8+Math.random()*0.4)*(1+room.locDifLevel*0.1);
					fiascoRemine=explosion;
				}
				if (!difSet) allDif+=mine*2;
			}
			if (room) 
			{
				damdis=30+room.mechLevel*20;
			}
			if (expl>0) 
			{
				if (node.@damage.length()) damage=node.@damage;
				if (node.@destroy.length()) destroy=node.@destroy;
				if (node.@radius.length()) explRadius=node.@radius;
			}
			if (allact=='robocell') 
			{
				fiascoUnlock=robocellFail;
			}
			if (allact=='alarm') 
			{
				fiascoRemine=alarm2;
				if (owner) 
				{
					area=new Area(room);
					owner.copy(area);
					area.tip='raider';
					area.over=alarm2;
				}
			}
			if (prize) 
			{
				mine=0;
				lockTip=0;
				lock=1;
			}
			update();
			owner.prior+=1;
			inited=true;
		}
		
		public function save(obj:Object):void
		{
			obj.lock=saveLock;
			obj.lockLevel=lockLevel;
			obj.mine=saveMine;
			obj.loot=saveLoot;
			obj.open=saveOpen;
			obj.expl=saveExpl;
			obj.dif=allDif;
			obj.sign=sign;
		}
		
		public function step():void
		{
			if (is_act) act();
			else is_ready=true;
			is_act=false;
			if (isMove) move();
			if (area) area.step();
			if (t_autoClose>0) 
			{
				t_autoClose--;
				if (t_autoClose==1) command('close');
			}
			if (t_budilo>0) 
			{
				if (t_budilo%30==0) 
				{
					room.budilo(owner.X,owner.Y,1500);
					Emitter.emit('laser2',room,owner.X,owner.Y-owner.scY+20);
					Snd.ps('alarm',X,Y);
				}
				t_budilo--;
			}
			if (sign>0) 
			{
				if (t_sign<=0) 
				{
					t_sign=30;
					if (Settings.helpMess) Emitter.emit('sign'+sign,room,owner.X,owner.Y-owner.scY/2);
				}
				t_sign--;
			}
		}
		
		public function update():void
		{
			if (userAction && userAction!='') 
			{
				 actionText=Res.txt('g', userAction);
			} 
			else 
			{
				if (active && action>0) 
				{
					if (action==1) actionText=Res.txt('g', !open?'open':'close');
					if (action==2) actionText=Res.txt('g', 'use'); 
					if (action==3) actionText=Res.txt('g', 'remine'); 
					if (action==4) actionText=Res.txt('g', 'press'); 
					if (action==5) actionText=Res.txt('g', 'shutoff'); 
					if (action==8) actionText=Res.txt('g', 'comein'); 
					if (action==9) actionText=Res.txt('g', 'exit'); 
					if (action==10) actionText=Res.txt('g', 'beginm'); 
					if (action==11) actionText=Res.txt('g', 'return'); 
					if (action==12) actionText=Res.txt('g', 'see'); 
				} 
				else actionText='';
			}
			
			if (mine>0) 
			{
				if (mineTip==6) 
				{
					stateText="<span class = 'r2'>"+Res.txt('g', 'signal')+"</span>";
					actionText=Res.txt('g', 'shutoff');
				} 
				else 
				{
					if (owner is Box) stateText="<span class = 'warn'>"+Res.txt('g', 'mined')+"</span>";
					actionText=Res.txt('g', 'remine');
				}
				sndAct='rem_act';
			} 
			else if (lock>0) 
			{
				if (lockTip==0)	
				{
					stateText="<span class = 'r2'>"+Res.txt('g', 'lock')+"</span>";
					actionText='';
					sndAct='lock_act';
				}
				if (lockTip==1)	
				{
					if (lock>=100) stateText="<span class = 'r3'>"+Res.txt('g', 'zhopa')+"</span>";
					else stateText="<span class = 'r2'>"+Res.txt('g', 'lock')+"</span>";
					actionText=Res.txt('g', 'unlock');
					sndAct='lock_act';
				}
				if (lockTip==2)	
				{
					if (lock>=100)stateText="<span class = 'r3'>"+Res.txt('g', 'block')+"</span>";
					else stateText="<span class = 'r2'>"+Res.txt('g', 'termlock')+"</span>";
					actionText=Res.txt('g', 'termunlock'); 
					sndAct='term_act';
				}
				if (lockTip==4)	
				{
					actionText=Res.txt('g', 'shutoff');
					sndAct='rem_act';
				}
				if (lockTip==5)	
				{
					actionText=Res.txt('g', 'fixup');
					sndAct='rem_act';
				}
			} 
			else if (cont=='empty') 
			{
				stateText="<span class = 'r0'>"+Res.txt('g', 'empty')+"</span>";
			} 
			else 
			{
				stateText='';
			}
		}
		
		// Set the state
		public function setAct(a:String, n:int=0):void
		{
			if (a=='mine') 
			{
				if (n<100) 
				{
					mine=n;
					saveMine=mine;
				}
				if (n==101) 
				{
					mine=0;
					saveMine=101;
					owner.warn=0;
				}
			}
			if (a=='lock') 
			{
				if (n<100) 
				{
					lock=n;
					saveLock=lock;
				}
				if (n==101) 
				{
					saveLock=101;
					lock=0;
					stateText='';
				}
				if (n==102) 
				{
					saveLock=102;
					lock=100;
					if (lockTip==1) stateText="<span class = 'r3'>"+Res.txt('g', 'zhopa')+"</span>";
					if (lockTip==2) stateText="<span class = 'r3'>"+Res.txt('g', 'block')+"</span>";
					if (lockTip==5) stateText="<span class = 'r3'>"+Res.txt('g', 'broken')+"</span>";
				}
			}
			if (a=='loot') 
			{
				if (n>0) 
				{
					saveLoot=n;
					active=false;
					cont='empty';
					actionText='';
					owner.setVisState('open');
				}
			}
			if (a=='open') 
			{
				if (autoClose==0) saveOpen=n;
				open=(n==1);
				if (door) setDoor();
				if (knop) 
				{
					if (open) owner.setVisState('open');
					else owner.setVisState('close');
				}
				if (open) 
				{
					lock=mine=0;
					update();
				}
				if (open && (allact=='robocell' || allact=='alarm')) 
				{
					allact='';
					active=false;
					owner.setVisState('open');
				}
				if (room && room.prob && room.roomActive) room.prob.check();
			}
			if (a=='expl') 
			{
				saveExpl=n;
			}
		}
		
		// Perform an action
		public function act():void
		{
			var verZhopa:int = 0, verFail:int = 0;
			if (action==0) return;
			if (scrTouch) 
			{
				scrTouch.start();
				scrTouch=null;
				return;
			}
			if (needSkill && needSkillLvl>unlock) 
			{
				World.world.gui.infoText('needSkill', Res.txt('e',needSkill), needSkillLvl,false);	// Skill required
			} 
			else if (mine>0) 
			{
					verZhopa=0, verFail=0;
					if (mine>unlock) verZhopa=(mine-unlock+1)*0.15;
					verFail=(mine-unlock+2)*0.2;
					if (Math.random()<verZhopa)  // Critical failure
					{	
						setAct('mine',101);
						if (mineTip==6) World.world.gui.infoText('signalZhopa');	// Alarm triggered
						else World.world.gui.infoText('remineZhopa');	// Bomb triggered
						if (fiascoRemine!=null) fiascoRemine();
						if (at_once>0) 
						{
							actOsn();
						}
						replic('zhopa');
						update();
					} else if (Math.random()<verFail)  // Failure	
					{ 
						if (mineTip==6) World.world.gui.infoText('signalFail',null,null,false);	// Alarm not disarmed
						else World.world.gui.infoText('remineFail',null,null,false);	// Bomb not disarmed
						replic('fail');
					} 
					else // Success
					{						
						setAct('mine',101);
						if (mineTip==6) World.world.gui.infoText('signalOff');	// Alarm disarmed
						else  World.world.gui.infoText('remine');	// Bomb disarmed
						if (successRemine!=null) successRemine();
						if (at_once>0) 
						{
							actOsn();
						}
						replic('success');
						update();
					}
					World.world.gui.bulb(X,Y);
					// trace('disarm', unlock, 'failure', verFail,'жопа',verZhopa);
				unlock=0;
				is_ready=false;
			} 
			else if (lock>0 && lockKey && World.world.invent.items[lockKey].kol>0) 
			{
				setAct('lock',101);
				if (lockTip==1) World.world.gui.infoText('unLockKey');
				if (lockTip==2) World.world.gui.infoText('unTermLock');
				if (lockTip==4) World.world.gui.infoText('unRepLock');
				if (lockTip==5) World.world.gui.infoText('unFixPart');
				update();
				if (successUnlock!=null) successUnlock();
				//if (lockKeyMinus) 
			} 
			else if (lock>=100) 
			{

			} 
			else if (lock>0) 
			{
				if (unlock>-99) 
				{
					var lockDam1:Number=0, lockDam2:Number=2;
					verFail=0;
					if (lockTip==1 || lockTip==5) 
					{
						verFail=1-this.getChance(lock-unlock);
						if (master<lockLevel) verFail=1;
						if (lock-unlock==1) 
						{
							lockDam1=1;
							lockDam2=3;
						} else if (lock-unlock>1)
						{
							lockDam1=2;
							lockDam2=4;
						}
					} 
					else if (lockTip==2) 
					{
						verFail=1-this.getChance(lock-unlock);
						if (master<lockLevel) verFail=1;
					} 
					else if (lockTip==4) 
					{
						if (lock-unlock<0) verFail=0.1;
						else if (lock-unlock==0) verFail=0.25;
						else if (lock-unlock==1) verFail=0.6;
						else if (lock-unlock==2) verFail=0.85;
						else verFail=1;
						lockDam1=2;
						lockDam2=4;
					}
					//trace(lock,unlock,lockDam1,lockDam2);
					//trace(lock,unlock,verFail);
					var lockDam:Number=lockDam1;
					if (Math.random()<verFail)  //неудача	
					{
						if (lockTip==1) 
						{
							var pinCrack:Boolean=false;
							if (World.world.invent.pin.kol>0) 
							{
								if (World.world.pers.pinBreak>=1 || Math.random()<World.world.pers.pinBreak) 
								{
									World.world.invent.minusItem('pin');
									pinCrack=true;
								}
							} 
							else lockDam1+=2;
							lockDam=(lockDam1+Math.random()*lockDam2)*World.world.pers.lockAtt;
							lockHP-=lockDam;
							//trace(lockDam,lockHP);
							if (lockHP<=0) 
							{		//Замок заклинило
								setAct('lock',102);
								World.world.gui.infoText('unLockZhopa');
								if (fiascoUnlock!=null) fiascoUnlock();
								replic('zhopa');
							} 
							else if (pinCrack) 
							{
								World.world.gui.infoText('unLockFailP', null,null,false);	//замок не открыт, заколка сломана
								replic('fail');
							} 
							else if (lockHP>100) 
							{
								World.world.gui.infoText('unLockFailA', null,null,false);	//замок не открыт, попробуйте ещё
							} 
							else 
							{
								World.world.gui.infoText('unLockFail',null,null,false);	//замок не открыт
								replic('fail');
							}
						} 
						else if (lockTip==2) 
						{
							if (lockAtt==-100) lockAtt=World.world.pers.hackAtt;
							lockAtt--;
							if (lockAtt>10) World.world.gui.infoText('unTermLockFail2',null,null,false);	//терминал не взломан
							else if (lockAtt>1) 
							{
								World.world.gui.infoText('unTermLockFail',lockAtt,null,false);	//терминал не взломан
								replic('fail');
							} 
							else if (lockAtt==1) 
							{
								World.world.gui.infoText('unTermLockFail1',null,null,false);	//терминал не взломан
								replic('fail');
							} else 
							{					//терминал блокирован
								setAct('lock',102);
								replic('zhopa');
								World.world.gui.infoText('unLockBlock');
								if (fiascoUnlock!=null) fiascoUnlock();
							}
						} 
						else if (lockTip==4) 
						{		//отключение с помощью навыка ремонт
							lockDam = (lockDam1+Math.random()*lockDam2);
							lockHP -= lockDam;
							//trace(lockDam,lockHP);
							if (lockHP <= 0) 
							{		//Удар током
								//setAct('lock',102);
								discharge();
								World.world.gui.infoText('unRepZhopa',null,null,false);
								replic('zhopa');
								if (fiascoUnlock!=null) fiascoUnlock();
							} 
							else 
							{
								World.world.gui.infoText('unRepFail',null,null,false);	//замок не открыт
								replic('fail');
							}
						} 
						else if (lockTip==5) //ремонт механизма
						{		
							lockDam=(lockDam1 + Math.random() * lockDam2);
							lockHP-=lockDam;
							//trace(lockDam,lockHP);
							if (lockHP <= 0) //Замок заклинило
							{		
								setAct('lock', 102);
								World.world.gui.infoText('unFixZhopa');
								replic('zhopa');
								if (fiascoUnlock!=null) fiascoUnlock();
							} 
							else
							{
								World.world.gui.infoText('unFixFail',null,null,false);	//замок не открыт
								replic('fail');
							}
						}
					} 
					else 	//успех	//замок открыт
					{					
						setAct('lock',101);
						if (lockTip==1) 
						{
							World.world.gui.infoText('unLock');
							if (Math.random()<0.8) replic('success');
							else replic('unlock');
						}
						if (lockTip==2) 
						{
							World.world.gui.infoText('unTermLock');
							if (Math.random()<0.8) replic('success');
							else replic('hack');
						}
						if (lockTip==4) 
						{
							World.world.gui.infoText('unRepLock');
							replic('success');
						}
						if (lockTip==5) 
						{
							World.world.gui.infoText('unFixLock');
							replic('success');
						}
						if (successUnlock!=null) successUnlock();
						if (at_once>0) 
						{
							actOsn();
						}
						update();
					}
					World.world.gui.bulb(owner.X,owner.Y);
				} 
				else 
				{
					World.world.gui.infoText('noPoss',null,null,false);
					World.world.gui.bulb(owner.X,owner.Y);
				}
				unlock=0;
				is_ready=false;
			} 
			else if (is_ready) 
			{
				actOsn();
			}
			is_ready=false;
		}
		
		public function getChance(dif:int):Number 
		{
			if (dif<-2) return 1;
			if (dif>4) return 0;
			if (World.world.pers.upChance>0) return chanceUnlock2[dif+2];
			return chanceUnlock[dif+2]
		}
		
		// Perform the main action
		public function actOsn():void
		{
			if (cons) 
			{
				if (World.world.invent.items[cons] && World.world.invent.items[cons].kol>0)	
				{
					World.world.invent.minusItem(cons);
					World.world.gui.infoText('usedCons', Res.txt('i',cons));
					if (cons=='empbomb') Emitter.emit('impexpl',room,owner.X, owner.Y-owner.scY/2);
				} 
				else 
				{
					World.world.gui.infoText('needCons', Res.txt('i',cons),null,false);
					return;
				}
			}
			if (actFun) 
			{
				actFun();
			}
			if (cont!=null)
			{
				loot();
			}
			sign=0;
			if (expl) owner.die();
			if ((door>0 || knop>0)&& action>0) 
			{
				open=!open;
				setAct('open',(open?1:0));
				if (open && scrOpen) scrOpen.start();
				if (!open && scrClose) scrClose.start();
				if (open) t_autoClose=autoClose;
				if (door>0 && World.world.pers.noiseDoorOpen) World.world.gg.makeNoise(World.world.pers.noiseDoorOpen, true);
			}
			if (allact || prob!=null) 
			{
				allAct();
			}
			
			if (room && room.prob) room.prob.check();
			if (scrAct) scrAct.start();
			update();
		}
		
		// Break the container
		public function dieCont():void
		{
			lootBroken=true;
			if (cont!=null) 
			{
				loot();
			}
			if (mine) 
			{
				setAct('mine',101);
				World.world.gui.infoText('remineZhopa');	// The bomb has triggered
				if (fiascoRemine!=null) fiascoRemine();
			}
			open=true;
			setAct('open',1);
			if (scrOpen) scrOpen.start();
			update();
		}
		
		public function load(obj:Object):void
		{
			if (obj==null) return;
			if (obj.lock!=null) 
			{
				setAct('lock',obj.lock);
			}
			if (obj.lockLevel!=null) 
			{
				lockLevel=obj.lockLevel;
			}
			if (obj.dif!=null) 
			{
				allDif=obj.dif;
			}
			if (obj.mine!=null) 
			{
				setAct('mine',obj.mine);
			}
			if (obj.loot!=null) 
			{
				if (obj.loot==2) 
				{
					loot(true);	// Generate critical loot if the state is 2
				}
				setAct('loot',obj.loot);
			}
			if (obj.open!=null) 
			{
				setAct('open',obj.open);
			}
			if (obj.expl!=null) 
			{
				setAct('expl',obj.expl);
			}
			if (obj.sign!=null) 
			{
				sign=obj.sign;
			}
		}

		public function setDoor():void
		{
			if (inited && !open && (owner as Box).attDoor()) 
			{
				open=true;
				if (t_autoClose<=0) World.world.gui.infoText('noClose',null,null,false);
				return;
			}
			(owner as Box).setDoor(open);
		}
		
		// Unsuccessful attempt at defusing - explosion
		public function explosion():void
		{
			if (saveExpl) return;
			var un:Unit=new Unit();
			un.room=room;
			var bul:Bullet=new Bullet(un,owner.X,owner.Y,null,false);
			bul.iExpl(damage,destroy,explRadius);
			setAct('expl',1);
			if (expl) 
			{
				owner.die();
			}
		}
		
		// Unsuccessful attempt at hacking a force field - electric shock
		public function discharge():void
		{
			World.world.gg.electroDamage(damdis*(Math.random()*0.4+0.8),owner.X,owner.Y-owner.scY/2);
			//damage(,Unit.D_SPARK);
			//Emitter.emit('moln',room,owner.X,owner.Y-owner.scY/2,{celx:World.world.gg.X, cely:(World.world.gg.Y-World.world.gg.scY/2)});
			//Snd.ps('electro',X,Y);
			damdis+=50;
			if (damdis>500) damdis=500;
		}
		
		// Unsuccessful attempt to disable the alarm - alarm
		public function alarm():void
		{
			if (saveExpl) return;
			t_budilo=240;
			setAct('expl',1);
			room.signal();
			room.robocellActivate();
		}
		
		// Unsuccessful attempt to disable the alarm button
		public function alarm2():void
		{
			if (allact!='alarm') return;
			t_budilo=240;
			room.signal();
			area=null;
			active=false;
			allact='';
			update();
			owner.setVisState('active');
		}
		
		// Unsuccessful attempt to hack the robot cell - alarm
		public function robocellFail():void
		{
			room.robocellActivate();
		}
		
		// Create a robot
		public function genRobot():void
		{
			if (allact!='robocell') return;
			room.createUnit('robot',X,Y,true,null,null,30);
			allact='';
			update();
			owner.setVisState('active');
		}
		
		public function needRuna(gg:UnitPlayer):int 
		{
			if (mineTip==6 && mine>0) return 1;
			if (noRuna || lock==0) return 0;
			if (gg.invent==null || mine>0) return 0;
			var pick:int = gg.pers.getLockTip(lockTip);
			var master:int = gg.pers.getLockMaster(lockTip)
			if (lockTip==1 && gg.invent.items['runa'].kol>0 && (lock-pick>1 || lockLevel>master)) return 1;
			if (lockTip==2 && gg.invent.items['reboot'].kol>0 && (lock-pick>1 || lockLevel>master)) return 1;
			return 0;
		}

		public function useRuna(gg:UnitPlayer):void
		{
			if (mineTip==6 && mine>0) 
			{
				if (fiascoRemine!=null) fiascoRemine();
				setAct('mine',101);
				if (at_once>0) 
				{
					actOsn();
				}
				update();
				return;
			}
			if (gg.invent==null) return;
			if (lockTip==1 && lock>0 && gg.invent.items['runa'].kol>0) 
			{
				command('unlock');
				gg.invent.minusItem('runa');
				World.world.gui.infoText('useRuna');
				World.world.gui.bulb(owner.X,owner.Y);
			}
			if (lockTip==2 && lock>0 && gg.invent.items['reboot'].kol>0) 
			{
				command('unlock');
				gg.invent.minusItem('reboot');
				World.world.gui.infoText('useReboot');
				World.world.gui.bulb(owner.X,owner.Y);
			}
		}
		
		public function off():void
		{
				stateText='';
				active=false;
				lock=0;
		}
		
		public function allAct():void
		{
			if (prob!=null) 
			{
				if (World.world.possiblyOut()==2) 
				{
					World.world.gui.infoText('noOutLoc',null,null,false);
					return;
				}
				room.level.gotoProb(prob, owner.X, owner.Y);
			} 
			else if (allact=='probreturn') 
			{
				if (room.levelProb!='') 
				{
					if (World.world.possiblyOut()==2) 
					{
						World.world.gui.infoText('noOutLoc',null,null,false);
						return;
					}
					room.level.gotoProb('', owner.X, owner.Y);
				}
			} 
			else if (allact=='hack_robot') 
			{
				World.world.gui.infoText('term1Act');
				World.world.gui.bulb(X,Y);
				for each (var un:Unit in owner.room.units) un.hack(World.world.pers.security);				
			} 
			else if (allact=='hack_lock') 
			{
				World.world.gui.infoText('term2Act');
				World.world.gui.bulb(X,Y);
				for each (var obj:Obj in owner.room.objs) 
				{
					if (obj.inter) obj.inter.command('hack');
				}
			} 
			else if (allact=='prob_help') 
			{
				if (room.prob) room.prob.showHelp();
			} 
			else if (allact=='electro_check') 
			{
				room.electroCheck();
				if (room.electroDam<=0) World.world.gui.infoText('electroOff',null,null,true);
				else World.world.gui.infoText('electroOn',null,null,true);
			} 
			else if (allact=='comein') 
			{
				World.world.gg.outLoc(5,X,Y);
			} 
			else if (allact=='bind') 
			{
				World.world.gg.bindChain(X,Y-20);
			} 
			else if (allact=='work' || allact=='lab' || allact=='stove') 
			{
				World.world.pip.workTip=allact;
				World.world.pip.onoff(7);
			} 
			else if (allact=='app') 
			{
				World.world.pip.onoff(8);
			} 
			else if (allact=='map') 
			{
				World.world.pip.travel=true;
				World.world.pip.onoff(3,3);
				World.world.pip.travel=true;
			} 
			else if (allact=='stand') 
			{
				World.world.stand.onoff(1);
			} 
			else if (allact=='exit') 
			{
				World.world.game.gotoNextLevel();
			} 
			else if (allact=='robocell') 
			{
				World.world.gui.infoText('robocellOff');
				setAct('open',1);
			} 
			else if (allact=='alarm') 
			{
				World.world.gui.infoText('alarmOff');
				setAct('open',1);
			} 
			else if (allact=='vault') 
			{
				World.world.pip.onoff(9);
			} else owner.room.allAct(owner,allact,allid);
		}
		
		// Start of prolonged action on the object
		public function beginAct():void
		{
			if (allact=='comein') 
			{
				owner.setVisState('comein');
			}
		}
		
		public function shine():void
		{
			Emitter.emit('unlock',room,owner.X,owner.Y-owner.scY/2,{kol:10, rx:owner.scX, ry:owner.scY, dframe:6});
		}
		
		public function signal(n:String):void
		{
			Emitter.emit(n,room,owner.X,owner.Y-owner.scY/2,{kol:6, rx:owner.scX/2, ry:owner.scY*0.8});
		}
		
		
		public function command(com:String, val:String=null):void
		{
			if (com=='hack' && is_hack) 
			{
				active=true;
				setAct('mine',101);
				setAct('lock',101);
				if (at_once>0) actOsn();
				update();
				shine();
			}
			if (com=='unlock') 
			{
				active=true;
				setAct('mine',101);
				setAct('lock',101);
				update();
				shine();
			}
			if (com=='open') 
			{
				open=true;
				setAct('open',1);
				t_autoClose=autoClose;
				if (allact && val!='13')	allAct();
			}
			if (com=='close') 
			{
				open=false;
				setAct('open',0);
				if (open) t_autoClose=150;
				if (allact && val!='13')	allAct();
			}
			if (com=='dam') 
			{
				if (expl) explosion();
				else if (knop && action==0) 
				{
					setAct('open',1);
					if (room.prob) room.prob.check();
				} 
				else actOsn();
			}
			if (com=='swap') 
			{
				open=!open;
				setAct('open',(open?1:0));
			}
			if (com=='sign') 
			{
				sign=int(val);
			}
			if (com=='off') 
			{
				active=false;
			}
			if (isMove)
			 {
				if (com=='stop') 
				{
					moveSt=0;
				}
				if (com=='move') 
				{
					moveSt=4;
				}
				if (com=='pop') 
				{
					if (moveSt==0) moveSt=4;
					else moveSt=0;
				}
				if (com=='move1') // Move from the beginning to the end
				{	
					moveTo(1);
				}
				if (com=='move2') // Move from the end to the beginning
				{	
					moveTo(2);
				}
				if (com=='move3') // Move from one end to the other
				{	
					moveTo(3);
				}
			}
			if (com=='red') 
			{
				signal('red');
			}
			if (com=='green') 
			{
				signal('green');
			}
		}
		
		public function move():void
		{
			if (isMove && moveSt>0) 
			{
				var f:Number=0;
				var pp:Boolean = moveP;
				if (dt_move<1) dt_move+=0.1;
				if (t_move>=0 && t_move<tStay) // standing at the beginning
				{	
					moveP=false;
					f=0;
					if (moveSt==2 || moveSt==3) moveSt=0;
				} 
				if (t_move>=tStay && t_move<tStay+tMove)  // moving from the beginning to the end
				{
					moveP=true;
					f=(t_move-tStay)/tMove;
				} 
				else if (t_move>=tStay+tMove && t_move<tStay+tMove+tStay) // standing at the end
				{ 
					moveP=false;
					f=1;
					if (moveSt==1 || moveSt==3) moveSt=0;
				} 
				else if (t_move>=tStay+tMove+tStay && t_move<(tStay+tMove)*2)  // moving from the end to the beginning
				{
					moveP=true;
					f=((tStay+tMove)*2-t_move)/tMove;
				} 
				else 
				{
					moveP=false;
					f=0;
				}
				if (pp!=moveP) 
				{
					if (moveP) sound('move');
					else sound('stop');
				}
				var nx:Number=begX+(endX-begX)*f;
				var ny:Number=begY+(endY-begY)*f;
				owner.bindMove(nx,ny);
				X=nx, Y=ny;
				t_move+=dt_move;
				if (t_move>=(tStay+tMove)*2) t_move=0;
			}
		}
		
		public function moveTo(n:int):void
		{
			moveSt=n;
			if (n==1) 
			{
				if (t_move>=0 && t_move<tStay) // standing at the beginning
				{ 
					t_move=tStay;
				}
				if (t_move>=tStay+tMove && t_move<tStay+tMove+tStay) // standing at the end
				{ 
					moveSt=0;
				}
			}
			if (n==2) 
			{
				if (t_move>=0 && t_move<tStay)  // standing at the beginning
				{
					moveSt=0;
				}
				if (t_move>=tStay+tMove && t_move<tStay+tMove+tStay) // standing at the end
				{ 
					t_move=tStay+tMove+tStay;
				}
			}
			if (n==3)
			{
				if (t_move>=0 && t_move<tStay)  // standing at the beginning
				{
					t_move=tStay;
				}
				if (t_move>=tStay+tMove && t_move<tStay+tMove+tStay) // standing at the end
				{ 
					t_move=tStay+tMove+tStay;
				}
			}
		}
		
		public function sound(s:String=null):void
		{
			if (s=='move') 
			{
				moveCh=Snd.ps('move',X,Y,0);
			} 
			else if (s=='stop') 
			{
				if (moveCh) moveCh.stop();
				moveCh=Snd.ps('move',X,Y,5500);
			} 
			else if (sndAct!='') Snd.actionCh=Snd.ps(sndAct,X,Y);
			
		}
		
		//set public
		public function replic(s:String):void
		{
			if (Math.random() < 0.25) World.world.gg.replic(s);
		}	
		
		// Confirm the receipt of a critical item
		public function receipt():void
		{
			saveLoot = 1;
		}
		
		public function loot(impOnly:Boolean=false):void
		{
			if (room==null || cont=='empty') return;
			X=owner.X, Y=owner.Y-owner.scY/2;
			var kol:int, imp:int;
			var is_loot:Boolean = false;
			var imp_loot:int = 1;
			if (xml && xml.item.length()) 
			{
				for each(var item:XML in xml.item) 
				{
					if (impOnly && item.@imp.length()==0) continue;
					if (item.@kol.length()) kol=item.@kol;
					else kol=1;
					if (item.@imp.length()) 
					{
						imp=2;
						imp_loot=2;
					} 
					else imp=1;
					LootGen.lootId(room,X,Y,item.@id,kol,imp,this,lootBroken);
					is_loot=true;
				}
			}
			if (impOnly) return;
			if (cont!='' && cont!='empty') 
			{
				if (owner is Unit) 
				{
					is_loot=LootGen.lootDrop(room,X,Y,cont,(owner as Unit).hero) || is_loot;
				} 
				else 
				{
					is_loot=LootGen.lootCont(room,X,Y,cont,lootBroken,prize?allDif:50) || is_loot;
					// Give experience points
					if (!lootBroken && allDif>0 && xp>0) 
					{
						room.takeXP(Math.round(xp*(allDif+1)),X,Y);
					}
				}
			}
			if (!is_loot && (owner is Box) && !World.world.testLoot) World.world.gui.infoText('itsEmpty');
			setAct('loot',imp_loot);
		}
	}
	
}
