package unitdata 
{
	import flash.display.MovieClip;
	
	import stubs.visualPonPon;
	import stubs.visualStabPon;
	import stubs.visualZebPon;
	
	public class UnitPonPon extends Unit
	{
		
		var tr:int=1;
		var act:Boolean=true;
		var novoi:Boolean=false;
		var verVis:Number=0.4;
		var privet:Boolean=false;
		
		public function UnitPonPon(cid:String=null, ndif:Number=100, xml:XML=null, loadObj:Object=null) 
		{
			super(cid, ndif, xml, loadObj);
			id='ponpon';
			//if (questId==null) questId=id;
			npc=true;
			getXmlParam();
			if (loadObj && loadObj.tr) 
			{			//из загружаемого объекта
				tr=loadObj.tr;
			} 
			else if (xml && xml.@tr.length()) 
			{	//из настроек карты
				tr=xml.@tr;
			} 
			else 
			{
				if (cid=='zebra') tr=Math.floor(Math.random()*5+1);
				if (cid=='stab') tr=Math.floor(Math.random()*33+1);
				else tr=Math.floor(Math.random()*15+13);
			}

			if (cid=='zebra') 
			{
				if (tr>=4) msex=true;
				vis=new visualZebPon();
				//id_replic='';
				if (!uniqName) objectName=Res.txt('unit','zebpon');
				verVis=1;
			} 
			else if (cid=='stab') 
			{
				vis=new visualStabPon();
				if (!uniqName) objectName=Res.txt('unit','stabpon');
				verVis=1;
				id_replic='stabpon';
				if (tr>=17 && tr<=27) msex=true;
				if (tr>=28) id_replic='child';
				privet=true;
			} 
			else 
			{
				vis=new visualPonPon();
				if (tr>=9 && tr<=11 || tr>=22) msex=true;
				else msex=false;
				if (tr==12) novoi=true;
			}

			if (xml && xml.@rep.length()) 
			{
				id_replic=xml.@rep;
				privet=false;
			}
			vis.osn.pon.gotoAndStop(tr);
			invulner=true;
			t_replic=Math.random()*1500;
			
		}
		
		public override function setNull(f:Boolean=false):void
		{
			if (f) act=Math.random()<verVis;
			super.setNull(f);
			vis.visible=act;
			isVis=act;
		}
		
		public override function save():Object
		{
			var obj:Object=super.save();
			if (obj==null) obj = {};
			obj.tr=tr;
			return obj;
		}	
	
		public override function animate():void
		{
		}
		
		public override function command(com:String, val:String=null):void
		{
			super.command(com,val);
			if (com=='tell' && act) 
			{
				t_replic=0;
				replic(val);			
			}
		}
		
		public override function control():void
		{
			if (novoi || !act) return;
			t_replic--;
			if (room!=World.world.room) return;
			if (privet && t_replic%60==3) 
			{
				var nx = World.world.gg.X-X;
				var ny = World.world.gg.Y-Y;
				if (Math.abs(nx)<200 && Math.abs(ny)<60) 
				{
					t_replic=0;
					replic('hi');
					t_replic=Math.random()*1500+1000;
					privet=false;
				}
			}
			if (t_replic<=0) {
				replic('neutral');
				t_replic=Math.random()*1500+1000;
			}
		}
		
	
	}
}
