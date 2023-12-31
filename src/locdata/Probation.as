package locdata 
{
	
	import locdata.Box;
	import unitdata.Unit;
	import servdata.Script;
	
	import components.Settings;
	
	//Класс представляет собой набор условий для испытания
	
	public class Probation 
	{
		
		public var xml:XML;
		public var room:Room;
		public var id:String;
		public var roomId:String;
		public var tip:int=0;
		
		public var objectName:String;
		public var info:String='';
		public var help:String='';
		
		// Options
		public var prizeActive:Boolean=false;	// Prize containers are initially open
		
		public var closed:Boolean=false;
		public var active:Boolean=false;
		public var isClose:Boolean=false;
		
		public var onWave:Boolean=false;
		public var nwave:int=0;		// Current wave number
		public var maxwave:int=0;	// Maximum wave number
		public var t_wave:int=0;	// Wave timer
		
		public var nspawn:int=0;	// Spawn point number
		public var kolEn:int=0;		// Total enemies in the wave
		public var killEn:int=0;	// Killed enemies in the wave

		public var dopOver:Function;
		public var dopOut:Function;
		
		public var alarmScript:Script;
		public var inScript:Script;
		public var outScript:Script;
		public var closeScript:Script;
		
		var beg_t:int=90;
		var next_t:int=300;

		public function Probation(nxml:XML, newRoom:Room) 
		{
			xml=nxml;
			room=newRoom;
			id=xml.@id;
			objectName=Res.txt('map',id);
			info='<b>'+objectName+'</b><br><br>'+Res.txt('map',id,1)+'<br>';
			if (Res.txt('map',id,3)!='') help="<span class = 'r3'>"+Res.txt('map',id,3)+"</span>";
			if (!room.levitOn) info+='<br>'+Res.txt('gui', 'restr_levit');
			if (!room.portOn) info+='<br>'+Res.txt('gui', 'restr_port');
			if (!room.destroyOn) info+='<br>'+Res.txt('gui', 'restr_des');
			if (xml.@prize.length()) prizeActive=true;
			if (xml.@tip.length()) tip=xml.@tip;
			if (xml.@close.length()) isClose=true;
			if (tip!=2) room.petOn=false;
			if (xml.scr.length()) 
			{
				for each(var xl in xml.scr) 
				{
					if (xl.@eve=='alarm') alarmScript=new Script(xl,room.level);
					if (xl.@eve=='out') outScript=new Script(xl,room.level);
					if (xl.@eve=='in') inScript=new Script(xl,room.level);
					if (xl.@eve=='close') closeScript=new Script(xl,room.level);
				}
			}			
			if (xml.wave.length()) maxwave=xml.wave.length();
		}
		
		//начальная подготовка (один раз)
		public function prepare():void
		{
			for each (var b:Box in room.objs) 
			{
				if (b.inter && (b.inter.prize && prizeActive)) 
				{
					b.inter.setAct('lock',0);
					b.inter.update();
				}
			}
		}
		
		//вызвать при открывании контейнеров и убийстве мобов
		//если условия выполнены, то закрыть испытание
		public function check():void
		{
			if (closed) return;
			if (checkAllCon()) 
			{
				closeProb();
			}
		}
		
		//проверить все условия закрытия
		public function checkAllCon():Boolean 
		{
			for each (var node in xml.con) 
			{
				if ((node.@tip=='box' || node.@tip.length()==0) && node.@uid.length())  //проверка боксов на открытость
				{
					for each (var b:Box in room.objs) 
					{
						if (b.uid==node.@uid && b.inter && (!b.inter.open && b.inter.cont!='empty')) return false;
					}
				} 
				else if (node.@tip=='unit') //проверка юнитов на смерть
				{
					for each (var un:Unit in room.units) 
					{
						if ((node.@uid.length() && un.uid==node.@uid || node.@qid.length() && un.questId==node.@qid) && un.sost<3) return false;
					}
				} 
				else if (node.@tip=='wave') //проверка волны
				{
					if (nwave<maxwave || killEn<kolEn) return false;
				}
			}
			return true;
		}
		
		//испытание пройдено
		public function closeProb():void
		{
			closed=true;
			active=false;
			if (GameSession.currentSession.game.triggers['prob_'+id]==null) GameSession.currentSession.game.triggers['prob_'+id]=1;
			else GameSession.currentSession.game.triggers['prob_'+id]++;
			GameSession.currentSession.gui.infoText('closeProb',objectName);
			Snd.ps('quest_ok');
			doorsOnOff(1);
			//окрыть коробки с призами
			if (!prizeActive) 
			{
				for each (var b:Box in room.objs) 
				{
					if (b.inter && b.inter.prize) 
					{
						b.inter.command('unlock');
					}
				}
			}
			if (closeScript) 
			{
				closeScript.start();
			}
		}
		
		//войти в комнату
		public function over() 
		{
			GameSession.currentSession.gui.messText('', objectName, GameSession.currentSession.gg.Y<300);
			if (!closed) defaultProb();
			if (inScript) 
			{
				inScript.start();
			}
			if (isClose) activateProb();
			room.broom=false;
		}
		//выйти из комнаты
		public function out() 
		{
			if (closed) 
			{
				room.openAllPrize();
				room.broom=true;
			} 
			else 
			{
				if (outScript) outScript.start();
				if (onWave) resetWave();
			}
		}
		
		public function showHelp():void
		{
			var isHelp = (help != '');
			GameSession.currentSession.gui.informText(info+(isHelp?('<br><br>'+Res.txt('gui', 'need_help')):''),isHelp);
		}
		
		//активировать испытание
		public function activateProb():void
		{
			if (closed || active || !room.roomActive) return;
			active=true;
			doorsOnOff(-1);
		}
		
		//вернуть испытание в исходное состояние
		public function defaultProb():void
		{
			active=false;
			doorsOnOff(0);
		}

		//-1 - отключить все выходы, 0 - отключить все выходы, кроме основного, 1-включить все выходы
		public function doorsOnOff(turn:int):void
		{
			for each (var b:Box in room.objs) 
			{
				if (b.id=='doorout') 
				{
					if (!b.vis.visible && turn==1 || b.vis.visible && turn==-1) 
					{
						b.inter.shine();
					}
					if (turn==-1 || turn==0 && b.uid!='begin') 
					{
						b.vis.visible=b.shad.visible=false;
						b.inter.active=false;
					}
					if (turn==1 || turn==0 && b.uid=='begin') 
					{
						b.vis.visible=b.shad.visible=true;
						b.inter.active=true;
					}
				}
			}
		}
		
		public function beginWave():void
		{
			if (onWave) return;
			doorsOnOff(-1);
			onWave=true;
			kolEn=killEn=0;
			nwave=0;
			t_wave=beg_t;
		}
		
		public function createWave():void
		{
			nspawn=0;
			var w:XML=xml.wave[nwave];
			if (w==null) return;
			for each (var un in w.obj) 
			{
				room.waveSpawn(un,nspawn);
				kolEn++;
				nspawn++;
			}
			if (w.@t.length()) t_wave=int(w.@t)*Settings.fps;
			nwave++;
		}
		
		//проверка выполняется при убийстве врага
		public function checkWave(inc:Boolean=false):void
		{
			if (inc) killEn++;
			if (killEn>=kolEn) 
			{
				checkAllCon();
				if (nwave<maxwave) t_wave=next_t;
				else t_wave=0;
			}
		}
		
		public function resetWave():void
		{
			onWave=false;
			for each (var un:Unit in room.units) 
			{
				if (un.wave) 
				{
					un.sost=4;
					un.disabled=true;
				}
			}
		}
		
		public function step():void
		{
			if (onWave) 
			{
				if (t_wave>0) t_wave--;
				if (t_wave==1 && nwave<maxwave) createWave();
				if (t_wave%30==1) GameSession.currentSession.gui.messText('',Math.floor(t_wave/30).toString());
			}
		}
	}
}
