package unitdata 
{
	
	import servdata.Interact;

	import stubs.visualTrain;
	import stubs.visualTrainArmor;

	public class UnitTrain extends Unit
	{
		
		var tr:int=0;
		
		public function UnitTrain(cid:String=null, ndif:Number=100, xml:XML=null, loadObj:Object=null) 
		{
			id='training';
			if (xml) {
				if (xml.@turn.length()) {
					if (xml.@turn>0) storona=1;
					if (xml.@turn<0) storona=-1;
				} else {
					storona=isrnd()?1:-1;
				}
				if (xml.@tr.length()) tr=xml.@tr;
				if (xml.@fix.length()) fixed=true;
			}
			getXmlParam();
			if (tr==1) {
				vis=new visualTrainArmor();
				skin=20;
			} else vis=new visualTrain();
			vis.gotoAndStop(1);
			doop=true;
			//dodge=0.2;
		}

		public override function control():void
		{
			hp=maxhp;
		}
		public override function setNull(f:Boolean=false):void
		{
			super.setNull(f);
			armor_hp=armor_maxhp;
		}
		public override function die(sposob:int=0):void
		{
			hp=maxhp;
		}
		public override function visDetails():void
		{
			if (hpbar) hpbar.visible=false;
		}
		public override function setLevel(nlevel:int=0):void
		{
			
		}
	}
	
}
