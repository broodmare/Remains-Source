package
{
	
	// Base class for all objects.
	
	import flash.display.MovieClip;

	import locdata.Room;
	
	public class Pt
	{

		public var room:Room;
		public var nobj:Pt, pobj:Pt;
		public var in_chain:Boolean = false;
		
		public var stay:Boolean = false;
		public var X:Number;
		public var Y:Number;
		public var layer:int = 0;
		
		//Movement
		public var dx:Number = 0;
		public var dy:Number = 0;
		public var vis:MovieClip;
		
		public function Pt() 
		{
			// constructor code
		}

		public function addVisual():void
		{
			if (vis && room && room.roomActive) 
			{
				World.world.grafon.canvasLayerArray[layer].addChild(vis);
			}
		}
		
		public function remVisual():void
		{
			if (vis && vis.parent) vis.parent.removeChild(vis);
		}

		public function setNull(f:Boolean = false):void
		{

		}
		
		public function err():String 
		{
			if (room) room.remObj(this);
			return null;
		}
		
		public function step():void
		{

		}
		
	}
	
}
