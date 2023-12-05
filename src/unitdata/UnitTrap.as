package unitdata 
{
	
	import servdata.Interact;

	import stubs.vismtrap;
	
	public class UnitTrap extends Unit
	{
		
		var rearm:Boolean=false;

		public function UnitTrap(cid:String=null, ndif:Number=100, xml:XML=null, loadObj:Object=null) 
		{
			if (cid==null) {
				id='mtrap';
			}
			mat=1;
			prior=2;
			vis=Res.getVis('vis'+id,vismtrap);
			vis.gotoAndStop(1);
			setVis(false);
			getXmlParam();
			visibility=300;
			showNumbs=false;
			doop=true;
			if (loadObj && loadObj.rearm) {
				rearm=true;
				fraction=F_PLAYER;
				warn=0;
			}
			aiState=1;
			undodge=1;
			inter = new Interact(this);
			inter.active=true;
			inter.action=100;
			inter.userAction='disarm';
			inter.actFun=disarm;
			inter.t_action=30;
			inter.needSkill='repair';
			inter.needSkillLvl=1;
			inter.update();
		}

		public override function expl():void
		{
			newPart('metal',3);
		}

		public function setVis(v:Boolean):void
		{
			isVis=v;
			levitPoss=v;
			vis.visible=v;
			vis.alpha=v?1:0.1;
		}
		
		public function disarm():void
		{
			if (aiState==1) {
				klac();
			} else if (aiState==2) {
				rearm=true;
				aiState=1;
				vis.gotoAndPlay(5);
				sound('trap_reload');
				fraction=F_PLAYER;
				warn=0;
				inter.t_action=30;
				inter.needSkillLvl=1;
				inter.userAction='disarm';
				inter.update();
			}
		}

		public override function save():Object
		{
			var obj:Object=super.save();
			if (rearm) {
				if (obj==null) obj = {};
				obj.rearm=true;
			}
			return obj;
		}	
		
		public function klac():void
		{
			aiState=2;
			sound('trap_a');
			vis.gotoAndPlay(1);
			inter.needSkillLvl=3;
			inter.t_action=60;
			inter.userAction='rearm';
			inter.update();
		}
		
		var aiN:int=Math.floor(Math.random()*5);
		
		public override function control():void
		{
			aiN++;
			if (sost>1) return;
			if (aiState==1 && !levit) { //взведена, поиск целей
				if (aiN%5==0) {
					for each (var un:Unit in room.units) {
						if (un==null || un.activateTrap<=1 || !isMeet(un) || un.sost==3 || un.fraction==fraction || un.fraction==0) continue;
						if (attKorp(un)) {
							klac();
							damage(35,D_INSIDE);
							setVis(true);
						}
					}
				}
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
