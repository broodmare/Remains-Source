package unitdata 
{
	
	import servdata.Interact;
	import locdata.Room;
	
	import components.Settings;
	import components.XmlBook;
	
	import stubs.vismtrap;

	//различные ловушки, активирующиеся если войти в зону их действия - нажимные плиты, растяжки, лазерные датчики
	
	public class UnitTrigger extends Unit
	{
		
		var status:int=0;	//0 - взведён, 1 - активирован, 2 - отключён
		var trapT:int=0;	//тип области
		var ax1:Number, ax2:Number, ay1:Number, ay2:Number;
		var trapL:int=2;	//1 - нажимная плита, 2 - обычная
		var needSkill:String='repair';
		var isAct:Boolean=false;
		var one:Boolean=false;	//одноразовая
		var allid:String;
		var allact:String;
		var vNoise:int=1200;
		
		var res:String='';
		var damager:Unit;
		
		var sndAct:String;

		public function UnitTrigger(cid:String=null, ndif:Number=100, xml:XML=null, loadObj:Object=null) 
		{
			super(cid, ndif, xml, loadObj);
			if (cid==null) {
				id='triglaser';
			} else {
				id=cid;
			}
			mat=1;
			vis=Res.getVis('vis'+id,vismtrap);
			setVis(false);
			getXmlParam();
			visibility=300;
			showNumbs=levitPoss=isSats=false;
			doop=true;
			layer=0;
			noBox=true;
			if (loadObj && loadObj.status!=null) {
				//status=loadObj.status;
			}
			if (xml) {
				if (xml.@allid.length()) allid=xml.@allid;
				if (xml.@allact.length()) allact=xml.@allact;
				if (xml.@res.length()) res=xml.@res;
			}
			fixed=true;
			inter = new Interact(this);
			inter.active=true;
			inter.action=100;
			inter.userAction='disarm';
			inter.actFun=disarm;
			inter.t_action=30;
			inter.needSkill=needSkill;
			inter.needSkillLvl=1;
			setStatus();
		}
		
		public override function save():Object
		{
			var obj:Object=super.save();
			if (obj==null) obj = {};
			obj.status=status;
			return obj;
		}
		
		public override function getXmlParam(mid:String=null):void
		{
			super.getXmlParam();
			var node0:XML = XmlBook.getXML("units").unit.(@id == id)[0];
			if (node0.un.length()) {
				if (node0.un.@skill.length()) needSkill=node0.un.@skill;		//требуемый скилл
				if (node0.un.@res.length()) res=node0.un.@res;
				if (node0.un.@one.length()) one=true;		//одноразовая
				if (node0.un.@plate.length()) trapL=1;		//напольная
			}
			if (node0.snd.length()) {
				if (node0.snd.@act.length()) sndAct=node0.snd.@act;
			}
		}
		
		public override function putLoc(newRoom:Room, nx:Number, ny:Number):void
		{
			super.putLoc(newRoom,nx,ny);
			setArea();
			if (room.tipEnemy==2 && fraction==F_RAIDER) fraction=Unit.F_ROBOT;
			if (allid==null || allid=='') setDamager();
		}
		
		public override function setLevel(nlevel:int=0):void
		{
			level+=nlevel;
			var sk:int=Math.round(level*0.25*(Math.random()*0.7+0.3));
			if (sk<1) sk=1;
			if (sk>5) sk=5;
			inter.needSkillLvl=sk;
		}
		
		public function setDamager():void
		{
			if (res=='noise' || res=='') return;
			var i:int=1;
			var nx:Number=X;
			var ny:Number=Y;
			var nxml=<obj/>;
			var ok:Boolean=false;
			if (res=='damgren' && isrnd(0.25) && Y<room.roomPixelHeight-100 && room.getAbsTile(X,Y+60).phis==0) {
				ny=Y+2*Settings.tilePixelHeight;
				res='expl1';
				ok=true;
			} else for (var i=1; i<=10; i++) {
				if (res=='damgren' || res=='hturret2') {
					if (room.getAbsTile(X,Y-10-i*Settings.tilePixelHeight).phis) {
						if (i==1) break;
						ny=Y-(i-1)*Settings.tilePixelHeight;
						ok=true;
						break;
					}
					if (res=='hturret2') {
						if (room.getAbsTile(X-Settings.tilePixelWidth,Y-10-i*Settings.tilePixelHeight).phis) {
							ny=Y-(i-1)*Settings.tilePixelHeight;
							nx=X-Settings.tilePixelWidth;
							ok=true;
							break;
						}
						if (room.getAbsTile(X+Settings.tilePixelWidth,Y-10-i*Settings.tilePixelHeight).phis) {
							ny=Y-(i-1)*Settings.tilePixelHeight;
							nx=X+Settings.tilePixelWidth;
							ok=true;
							break;
						}
					}
				}
				if (res=='damshot') {
					if (i>1 && room.getAbsTile(X-i*Settings.tilePixelWidth,Y).phis) {
						nx=X-(i-1)*Settings.tilePixelWidth;
						nxml=<obj turn="1"/>;
						ok=true;
						break;
					}
					if (i>1 && room.getAbsTile(X+i*Settings.tilePixelWidth,Y).phis) {
						nx=X+(i-1)*Settings.tilePixelWidth;
						nxml=<obj turn="-1"/>;
						ok=true;
						break;
					}
				}
			}
			if (ok)	{
				damager=room.createUnit(res,nx,ny,true, nxml);
				if (damager) {
					damager.fraction=fraction;
				}
			} else if (res=='damgren' || res=='hturret2') {
				res='damshot';
				setDamager();
			} else {
				res='damshot';
				if (isrnd()) {
					nx=X+(3+Math.floor(Math.random()*8))*Settings.tilePixelWidth;
					nxml=<obj turn="-1"/>;
				} else {
					nx=X-(3+Math.floor(Math.random()*8))*Settings.tilePixelWidth;
					nxml=<obj turn="1"/>;
				}
				damager=room.createUnit(res,nx,ny,true, nxml);
				if (damager) {
					damager.fraction=fraction;
				}
			}
		}

		public function setStatus():void
		{
			if (status>0) {
				warn=0;
				inter.active=false;
			} else {
				warn=1;
				inter.active=true;
			}
			vis.gotoAndStop(status+1);
			inter.update();
		}
		
		public override function die(sposob:int=0):void
		{
			super.die(sposob);
			if (status==0) activate();
		}
		
		public function setVis(v:Boolean):void
		{
			isVis=v;
			vis.visible=v;
			vis.alpha=v?1:0.1;
		}
		
		public override function expl():void
		{
			newPart('metal',3);
		}
		
		//установить границы активации
		public function setArea():void
		{
			if (id=='trigridge' || id=='triglaser') {
				ax1=X-5
				ax2=X+5;
				ay1=Y-30;
				ay2=Y-20;
			}
			else if (id=='trigplate')
			{
				ax1=X1;
				ax2=X2;
				ay1=ay2=Y-1;
			}
			else
			{
				ax1=X1;
				ax2=X2;
				ay1=Y1;
				ay2=Y2;
			}
		}
		
		//проверить активацию
		public override function areaTest(obj:Obj):Boolean
		{
			if (obj==null || obj.X1>=ax2 || obj.X2<=ax1 || obj.Y1>=ay2 || obj.Y2<=ay1) return false;
			else return true;
		}
		
		//обезвредить
		public function disarm():void
		{
			status=2;
			setStatus();
			GameSession.currentSession.gui.infoText('trapDisarm')
		}
		
		//реактивировать
		public function rearm():void
		{
			status=0;
			setStatus();
		}
		
		//активировать
		public function activate():void
		{
			if (status != 0) return;
			setVis(true);
			status = 1;
			var act = false;
			if (allact == 'spawn') {
				room.enemySpawn(true,true);
				return;
			}
			if (allid != null && allid!='') {
				for each (var un:Unit in room.units) {
					if (un != this && (un is UnitDamager) && (un as UnitDamager).allid==allid) {
						(un as UnitDamager).activate();
						act=true;
					}
				}
				if (allact) room.allAct(this,allact,allid);
			}
			celX=X;
			celY=Y;
			if (res=='noise' || res=='hturret2') {
				budilo(vNoise);
				act=true;
				if (res=='hturret2' && damager) damager.command('alarma');
			}
			if (damager && damager.sost<2) {
				damager.command('dam');
				act=true;
			}
			if (sndAct) sound(sndAct);
			setStatus();
			if (act) GameSession.currentSession.gui.infoText('trapActivate')
		}
		
		var aiN:int=Math.floor(Math.random()*5);
		
		public override function control():void
		{
			if (sost>1 || status==2 || one && status==1) return;
			aiN++;
			if (aiN%5==0) {
				var act:Boolean=false;
				for each (var un:Unit in room.units) {
					if (un.activateTrap==0 || un.fraction==fraction || !isMeet(un)) continue;
					if (trapL<2 && (un.massa<0.5 || un.activateTrap<=1 || !un.stay)) continue;
					if (areaTest(un)) act=true;
				}
				if (!isAct && act) activate();
				if (isAct && !act && !one) rearm();
				isAct=act;
			}
			if (aiN%10==0 && !isVis) {
				isVis=GameSession.currentSession.gg.lookInvis(this);
				if (isVis) {
					setVis(true);
				}
			}
		}
	}
	
}
