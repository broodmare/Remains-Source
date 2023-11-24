package unitdata 
{
	
	import servdata.Interact;
	import graphdata.Emitter;
	
	import stubs.vismwall;
	
	public class UnitMWall extends Unit
	{
		
		var rearm:Boolean=false;

		public function UnitMWall(cid:String=null, ndif:Number=100, xml:XML=null, loadObj:Object=null) {
			if (cid==null) {
				id='mwall';
			} else id=cid
			mat=7;
			vis=Res.getVis('vis'+id,vismwall);
			//vis.gotoAndStop(1);
			getXmlParam();
			vulner[D_NECRO]=begvulner[D_NECRO]=1;
			objectName='';
			this.levitPoss=false;
			showNumbs=false;
			doop=true;
			transT=true;
		}

		public override function expl()
		{
			Emitter.emit('pole',room,X,Y-scY/2,{kol:12,rx:scX, ry:scY});
		}
		
		public override function addVisual():void
		{
			if (disabled) return;
			if (vis && room && room.roomActive) World.world.grafon.canvasLayerArray[layer].addChild(vis);
		}
		
		public override function visDetails()
		{
		
		}
		
		public override function control()
		{
			hp-=0.2;
			if (hp<50) vis.alpha=hp/50;
			if (hp<=0) exterminate();
		}
		
		public override function setNull(f:Boolean=false):void
		{
			exterminate();
		}		
		
		public override function die(sposob:int=0):void
		{
			expl();
			exterminate();
		}
		
	}
	
}
