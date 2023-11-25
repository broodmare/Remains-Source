package unitdata 
{
	import components.Settings;
	
	import stubs.visualAntEmitter;
	import stubs.visualBloatEmitter;

	public class UnitBloatEmitter  extends Unit{
		
		var emitId:String='bloat';

		public function UnitBloatEmitter(cid:String=null, ndif:Number=100, xml:XML=null, loadObj:Object=null) {
			super(cid, ndif, xml, loadObj);
			if (cid!=null) id=cid;
			else id='ebloat';
			if (id=='eant') {
				vis=new visualAntEmitter();
				emitId='ant';
			} else vis=new visualBloatEmitter();
			vis.stop();
			getXmlParam();
		}
		
		public override function setVisPos():void
		{
			vis.x=X,vis.y=Y;
		}
		
		public override function setNull(f:Boolean=false):void
		{
			if (sost==1) {
				if (f) {
					//сбросить эффекты
					if (effects.length > 0) 
					{
						for each (var eff in effects) eff.unsetEff();
						effects=new Array();
					}
					oduplenie=Math.round(Settings.oduplenie*(Math.random()*0.2+0.9));
					disabled=false;		//включить
				}
			}
		}
		
		function emit(d:Boolean=false) {
			var un:Unit;
			var emitTr:String='0';
			if (emitId=='bloat') {
				if (room.locDifLevel>3) emitTr=room.randomCid(emitId);
				un=room.createUnit(emitId,X,Y,true,null,emitTr);
			}
			if (emitId=='ant') {
				emitTr=room.randomCid(emitId);
				un=room.createUnit(emitId,X,Y-40,true,null,emitTr);
			}
			if (un && d) {
				kolChild++;
				un.mother=this;
			}
		}
		
		var emit_t:int=0;
		
		public override function expl()
		{
			super.expl();
			if (emitId=='ant') newPart('schep',16,2);
			else newPart('shmatok',16,2);
		}
		
		public override function dropLoot()
		{
			super.dropLoot();
			for (var i=0; i<5; i++) emit();
		}
		
		public override function control():void
		{
			if (Settings.enemyAct<=0) {
				return;
			}
			//поиск цели
			if (aiTCh>0) aiTCh--;
			if (Settings.enemyAct>1 && aiTCh==0) {
				aiTCh=10;
				if (findCel()) {
					aiState=2;
				} else {
					aiState=1;		
				}
			}
			if (emit_t>0) emit_t--;
			else {
				if (aiState==2 && kolChild<5) {
					emit(true);
					emit_t=100;
				}
			}
			//атака
			if (Settings.enemyAct>=3 && celUnit) {
				attKorp(celUnit);
			}
		}
	}
	
}
