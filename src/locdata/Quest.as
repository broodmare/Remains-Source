package locdata 
{
	import servdata.Item;

	import components.Settings;
	import systems.Languages;
	
	public class Quest 
	{
		
		public var id:String;
		public var xml:XML;
		public var objectName:String;
		public var info:String;
		public var empl:String;
		
		public var main:Boolean = false;	//главный квест
		public var sub:Boolean 	= false;	//этап квеста
		public var nsub:int 	= 0;		//номер этапа
		public var subs:Array;				//массив этапов 
		public var subsId:Array;			//массив этапов по id
		public var par:Quest;				//главный квест по отношению к подквесту
		public var auto:Boolean = true;		//квест автматически берётся если закрыт один из этапов, установить в false чтобы квест добавлялся как скрытый

		public var isCheck:Boolean = false;
		public var nn:Boolean = false;		//не обязательно
		public var collect:String;			//собрать предметы
		public var colTip:int = 0;			//тип коллекционного предмета. 0-обычный, 1-оружие
		public var isDel:Boolean = false;	//изъять предмет после закрытия квеста
		public var give:String;				//кому отдать
		public var est:int = 0;
		public var kol:int = 1;
		public var canBeUse:Boolean = false;//подквест закроется если количество будет достигнуто, и больше уже не откроется
		public var gived:int = 0;			//сколько было отдано
		public var pay:int = 0;				//плата за каждый принесённый предмет
		public var prevRes:String='';		//предыдущий реузльтат проверки
		
		public var hidden:Boolean = false;	//описание скрыто
		public var invis:Boolean = false;	//пункт квеста не отображается
		public var result:Boolean = false;	//открывается, если выполнены все предыдущие пункты
		
		public var report:String;
		
		public var begDial:String;
		public var endDial:String;
		public var endScript:String;
		
		public var state:int 	= 0;		//состояние 0 - не активен, 1 - активен, 2 - выполнен
		public var sp:int 		= 0;		//награда в скилл-поинтах
		public var xp:int 		= 0;		//награда в опыте
		public var rep:int 		= 0;		//награда в репутации

		public var trigger:String;			//установить триггер, когда квест будет выполнен
		public var triggerSet:String;		//значение устанавливаемого триггера
		
		public var sort:int=0;

		public function Quest(nxml:XML, loadObj:Object=null, npar:Quest=null, nnsub:int=0) 
		{
			xml=nxml;
			id=xml.@id;
			var pid:String;
			if (npar==null)	
			{
				pid=id;
			} 
			else 
			{
				par=npar;
				sub=true;
				pid=par.id+id;
			}
			state=1;
			nsub=nnsub;
			if (loadObj) 
			{
				state=loadObj.state;
				est=loadObj.est;
				if (loadObj.gived) gived=loadObj.gived;
			}
			
			if (xml.@empl.length()) empl = xml.@empl;
			if (xml.@begdial.length()) begDial = xml.@begdial;
			if (xml.@enddial.length()) endDial = xml.@enddial;
			if (xml.@endscr.length()) endScript = xml.@endscr;
			if (xml.@nn.length()) nn = true;
			
			if (xml.@collect.length()) 
			{
				collect = xml.@collect;
				isCheck = true;
				if (par) par.isCheck = true;
				if (xml.@del.length()) isDel = true;
				if (xml.@coltip.length()) colTip = xml.@coltip;
			}
			if (xml.@give.length()) 
			{
				give=xml.@give;
			}
			if (xml.@pay.length()) 
			{
				pay=xml.@pay;
			}
			if (xml.@kol.length()) kol = xml.@kol;
			if (xml.@report.length()) report = xml.@report;
			if (xml.@us.length()) canBeUse = true;
			if (xml.@hidden.length()) hidden = true;
			if (xml.@invis.length()) invis = true;
			if (xml.@result.length()) 
			{
				result = true;
				if (par) par.result = true;
			}
			
			if (xml.@sp.length()) sp = xml.@sp;
			if (xml.@xp.length()) xp = xml.@xp;
			if (xml.@rep.length()) rep = xml.@rep;
			if (xml.@trigger.length()) 
			{
				trigger = xml.@trigger;
				if (xml.@triggerset.length()) triggerSet=xml.@triggerset;
				else triggerSet = '1';
				if (state == 2 && GameSession.currentSession.game.triggers[trigger] == null) GameSession.currentSession.game.triggers[trigger]=triggerSet;
			}
			if (loadObj && loadObj.invis != undefined) 
			{
				invis=loadObj.invis;
			}
			//TODO: Don't access languages' stuff directly like this.
			var node = Languages.currentLanguageData.txt.(@id == pid);
			if (node.length()) 
			{
				node = node[0]
				objectName = node.n[0];
				if (objectName == null) objectName = '[' + id + ']';
			} 
			else 
			{
				objectName = '[' + id + ']';
			}
			if (!sub) 
			{
				if (node && node.info.length())	
				{
					info = node.info[0];
				}
				else 
				{
					info = '---';
				}

				main = xml.@main.length() > 0;
				subs = [];
				subsId = [];
				nnsub = 1;

				for each(var sxml:XML in xml.q) 
				{
					var sl:Object;
					if (loadObj) sl = loadObj.subs[sxml.@id];
					var q:Quest = new Quest(sxml, sl, this, nnsub);
					subsId[q.id] = q;
					subs.push(q);
					nnsub++;
				}
			}
		}
		
		public function save():Object 
		{
			var obj:Object={id:id, state:state, est:est, gived:gived, invis:invis};
			if (!sub) 
			{
				obj.subs=[];
				for each(var q:Quest in subs) 
				{
					obj.subs[q.id]=q.save();
				}
			}
			return obj;
		}
		
		//проверить, если cid совпадает с collect, увеличить est
		public function inc(cid:String, kol:int=1):void
		{
			if (cid == collect) est += kol;
			if (!sub) 
			{
				for each (var q:Quest in subs) 
				{
					q.inc(cid, kol);
				}
			}
		}
		
		//выдать начальные предметы
		public function deposit():void
		{
			if (xml.deposit.length()) 
			{
				for each(var rew in xml.deposit) 
				{
					if (rew.@id.length()) 
					{
						var item:Item;
						if (rew.@kol.length()) item = new Item('', rew.@id, rew.@kol);
						else item = new Item('', rew.@id);
						GameSession.currentSession.invent.take(item,2);
					}
					if (rew.@trigger.length()) 
					{
						if (rew.@set.length()) GameSession.currentSession.game.triggers[rew.@trigger] = rew.@set.toString();
						else GameSession.currentSession.game.triggers[rew.@trigger] = 1;
					}
				}
			}
		}
		
		//проверка на соответствие условию, если всё соотвествует, то закрыть
		//вернуть выводимый результат
		public function check(cid:String=null):String 
		{
			var res:String;
			if (sub) 
			{
				if (collect && colTip==0 && gived<kol) 
				{
					if (GameSession.currentSession.invent.items[collect]) est=GameSession.currentSession.invent.items[collect].kol+gived;
					if (est>kol) est=kol;
					if (give==null) {
						if (est>=kol) 
						{
							state=2;
							if (par.result) par.isResult();
						} 
						else if (canBeUse) 
						{
							if (state<2) state=1;
							else est=kol;
						} 
						else state=1;
					} 
					else 
					{
						
					}
					if (cid!=null && collect==cid) res=objectName+' '+est+'/'+kol;
					if (GameSession.currentSession.invent.items[collect]) est=GameSession.currentSession.invent.items[collect].kol;
				}
				if (collect && colTip==1) 
				{
					if (GameSession.currentSession.invent.weapons[collect]!=null && GameSession.currentSession.invent.weapons[collect].respect!=3) 
					{
						state=2;
						if (par.result) par.isResult();
					}
					if (cid!=null && collect==cid) res=objectName;
				}
			} 
			else 
			{
				if (state==2) return null;
				var cl:Boolean=true;
				var res2:String;
				for each (var q:Quest in subs) 
				{
					res2=q.check(cid);
					if (res2!=null) res=res2;
					if (q.state<2 && !q.nn) cl=false;
				}
				if (cl) close();
			}
			//trace(res,prevRes)
			if (res==prevRes || res==null) 
			{
				return null;
			}
			prevRes=res;
			return res;
		}
		
		//проверить на возможность отдать предметы
		public function chGive(npc:String, us:Boolean=false):Boolean
		{
			if (sub) 
			{
				if (give==null) return false;
				if (collect) 
				{
					if (GameSession.currentSession.invent.items[collect]) est=GameSession.currentSession.invent.items[collect].kol;
					if (est>0 && (kol-gived)>0) 
					{
						if (est>kol-gived) est=kol-gived;
						if (us) 
						{
							GameSession.currentSession.invent.minusItem(collect,est);
							gived+=est;
							if (pay>0) 
							{
								GameSession.currentSession.invent.money.kol+=est*pay;
								GameSession.currentSession.gui.infoText('reward',Res.txt('item','money'),est*pay);
							}
							GameSession.currentSession.gui.infoText('withdraw',GameSession.currentSession.invent.items[collect].objectName, est);
							est=0;
							if (gived>=kol) close();
						}
						return true;
					}
				}
				return false;
			} 
			else 
			{
				var ok = false;
				for each (var q:Quest in subs) 
				{
					if (q.chGive(npc,us)) ok = true;
				}
				check(null);
				return ok;
			}
		}
		
		public function chReport(npc:String, us:Boolean=false):Boolean 
		{
			if (!sub) 
			{
				var cl:Boolean=true;
				var rep:Quest;
				for each (var q:Quest in subs) 
				{
					if (q.report && q.report==npc) 
					{
						rep=q;
					} 
					else if (q.state<2 && !q.nn) cl=false;
				}
				if (cl && rep) 
				{
					if (!us) return true;
					rep.close();
					check(null);
					return true;
				}
			}
			return false;
		}
		
		//проверить все этапы, если все закрыты, то закрыть основной
		public function isClosed():void
		{
			var cl:Boolean=true;
			for each (var q:Quest in subs) 
			{
				if (q.state<2) cl=false;
			}
			if (cl) close();
		}
		
		public function isResult():void
		{
			for (var i:int = 0; i<subs.length; i++) 
			{
				if (subs[i].result) 
				{
					var cl:Boolean=true;
					for (var j = i - 1; j >= 0; j--) 
					{
						if (subs[j].state<2) cl=false;
					}
					if (cl) subs[i].invis=false;
					//trace(subs[i].objectName, cl);
				}
			}
		}
		
		//закрыть этап
		public function closeSub(sid:String):void
		{
			if (state==2 || sid==null || sid=='' || subsId[sid]==null) return;
			subsId[sid].close();
			if (result) isResult();
			if (state==1) isClosed();
		}
		
		//показать скрытый этап
		public function showSub(sid:String):void
		{
			if (sid==null || sid=='' || subsId[sid]==null) return;
			subsId[sid].invis=false;
		}
		
		//закрыть квест
		public function close():void
		{
			if (state==2) return;
			state=2;
			//изъять квестовые вещи
			if (!sub) 
			{
				for each (var q:Quest in subs) 
				{
					if (q.isDel) 
					{
						if (q.colTip==0) 
						{
							GameSession.currentSession.invent.minusItem(q.collect, q.kol);
							try 
							{
								GameSession.currentSession.gui.infoText('withdraw',GameSession.currentSession.invent.items[q.collect].objectName, q.kol);
							} catch (err) {}
						} 
						else if (q.colTip==1) 
						{
							try 
							{
								GameSession.currentSession.gui.infoText('withdraw',GameSession.currentSession.invent.weapons[q.collect].objectName, 1);
							} 
							catch (err) 
							{

							}
							GameSession.currentSession.invent.remWeapon(q.collect);
						}
					}
				}
			}
			//выдать награды
			if (sp) GameSession.currentSession.pers.addSkillPoint(sp);
			if (xp) GameSession.currentSession.pers.expa(xp);
			if (rep) GameSession.currentSession.pers.rep+=rep;
			if (trigger) GameSession.currentSession.game.triggers[trigger]=triggerSet;
			if (xml.reward.length()) 
			{
				for each(var rew in xml.reward) 
				{
					if (rew.@id.length()) 
					{
						var item:Item;
						if (rew.@kol.length()) item=new Item('', rew.@id, rew.@kol);
						else item=new Item('', rew.@id);
						GameSession.currentSession.invent.take(item,2);
					}
					if (rew.@trigger.length()) 
					{
						if (rew.@set.length()) GameSession.currentSession.game.triggers[rew.@trigger]=rew.@set.toString();
						else GameSession.currentSession.game.triggers[rew.@trigger]=1;
					}
				}
			}
			//сообщение и звук
			if (!sub) 
			{
				GameSession.currentSession.gui.infoText('doneTask',objectName);
				Snd.ps('quest_ok');
			} 
			else 
			{
				GameSession.currentSession.gui.infoText('doneStage',objectName);
			}
			//завершающий диалог
			if (endDial && Settings.dialOn) 
			{
				GameSession.currentSession.pip.onoff(-1);
				GameSession.currentSession.gui.dialog(endDial);
			}
			//завершающий скрипт
			if (endScript!=null) 
			{
				GameSession.currentSession.game.runScript(endScript);
			}
		}

	}
	
}
