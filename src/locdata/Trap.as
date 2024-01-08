package locdata 
{
	import flash.display.MovieClip;
	
	import unitdata.Unit;
	
	import components.Settings;
	import components.XmlBook;
	
	import stubs.vistrapspikes;
	
	public class Trap extends Obj
	{

		public var id:String;
		public var vis2:MovieClip;
		
		public var dam:Number=0;
		public var tipDamage:int=0;
		
		public var spDam:int=1;		//способ нанесения урона
		public var spBind:int=1;	//способ прикрепления
		public var floor:Boolean = false;
		
		public var anim:Boolean = false;

		public function Trap(newRoom:Room, nid:String, nx:int=0, ny:int=0) 
		{
			room=newRoom;
			layer=0;
			prior=1;
			id=nid;
			X = nx;
			Y = ny;
			var vClass:Class  = Res.getClass('vistrap' + id, null, vistrapspikes);
			var vClass2:Class = Res.getClass('vistrap' + id + '2', null, null);
			vis  = new vClass();
			vis2 = new vClass2();
			var n1:int = Math.floor(Math.random() * vis.totalFrames) + 1;
			var n2:int = Math.floor(Math.random() * vis.totalFrames) + 1;
			levitPoss = false;
			vis.gotoAndStop(n1);
			vis2.gotoAndStop(n2);
			getXmlParam()
			if (!anim) vis.cacheAsBitmap=true;
			if (vis2 && !anim) vis2.cacheAsBitmap = true;
			X1 = X - scX / 2;
			X2 = X + scX / 2;
			if (floor) 
			{
				Y1 = Y - scY; 
				Y2 = Y;
			} 
			else 
			{
				Y1 = Y - Settings.tilePixelHeight;
				Y2 = Y1 + scY;
			}
			vis.x = X;
			vis.y = Y;
			vis2.x = X;
			vis2.y = Y;
			cTransform = room.cTransform;
			bindTile();
		}
		
		public function getXmlParam():void
		{
			var node:XML = XmlBook.getXML("objects").obj.(@id == id)[0];
			
			objectName = Res.txt('unit', id);
			if (node.@sX > 0) scX = node.@sX; 
			else scX = node.@size * Settings.tilePixelWidth;

			if (node.@sY > 0) scY = node.@sY; 
			else scY = node.@wid*Settings.tilePixelHeight;

			dam = node.@damage;
			if (node.@tipdam.length()) tipDamage=node.@tipdam;
			if (node.@anim.length()) anim=true;
			if (node.@floor.length()) floor=true;
			if (node.@att.length()) spDam=node.@att;
			if (node.@bind.length()) spBind=node.@bind;
		}
		
		public override function addVisual():void
		{
			if (vis) 
			{
				GameSession.currentSession.grafon.canvasLayerArray[layer].addChild(vis);
				if (cTransform) 
				{
					vis.transform.colorTransform=cTransform;
				}
			}
			if (vis2) 
			{
				GameSession.currentSession.grafon.canvasLayerArray[3].addChild(vis2);
				if (cTransform) 
				{
					vis2.transform.colorTransform=cTransform;
				}
			}
		}
		public override function remVisual():void
		{
			super.remVisual();
			if (vis2 && vis2.parent) vis2.parent.removeChild(vis2);
		}
		
		public override function step():void
		{
			if(!room.roomActive) return;
			for each (var un:Unit in room.units) 
			{
				if (!un.activateTrap || un.sost==4) continue;
				attKorp(un);
			}
		}
		
		public function bindTile():void
		{
			if (spBind==1) 	//прикрепление к полу
			{
				room.getAbsTile(X,Y+10).trap=this;
			}
			if (spBind==2) 	//прикрепление к потолку
			{
				room.getAbsTile(X,Y-50).trap=this;
			}
		}
		
		public override function die(sposob:int=0):void
		{
			room.remObj(this);
		}
		
		public function attKorp(cel:Unit):Boolean 
		{
			if (cel==null || cel.neujaz) return false;
			if (spDam==1 && !cel.isFly && cel.dy>8 && cel.X<=X2 && cel.X>=X1 && cel.Y<=Y2 && cel.Y>=Y1) 	//шипы
			{
				cel.damage(cel.massa*cel.dy/20*dam*(1+room.locDifLevel*0.1), tipDamage);
				cel.neujaz=cel.neujazMax;
			}
			if (spDam==2 && !cel.isFly && (cel.dy+cel.osndy<0) && cel.X<=X2 && cel.X>=X1 && cel.Y1<=Y2 && cel.Y1>=Y1) 	//шипы
			{	
				cel.damage(cel.massa*dam*(1+room.locDifLevel*0.1), tipDamage);
				cel.neujaz=cel.neujazMax;
			}
			return true;
		}
	}
}