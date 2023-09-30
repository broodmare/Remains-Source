package
{
	
	// Base class for all objects.
	
	import flash.display.MovieClip;

	import locdata.Location;
	
	public class Pt
	{

		public var location:Location;
		public var nobj:Pt, pobj:Pt;
		public var in_chain:Boolean=false;
		
		public var stay:Boolean=false;
		public var X:Number;
		public var Y:Number;
		public var sloy:int=0;
		
		//Movement
		public var dx:Number=0, dy:Number=0;
		public var vis:MovieClip;
		
		public function Pt() 
		{
			// constructor code
		}

		public function addVisual() 
		{
			if (vis && location && location.locationActive) 
			{
				World.w.grafon.visObjs[sloy].addChild(vis);
			}
		}
		
		public function remVisual() 
		{
			if (vis && vis.parent) vis.parent.removeChild(vis);
		}

		public function setNull(f:Boolean=false) 
		{

		}
		
		public function err():String 
		{
			if (location) location.remObj(this);
			return null;
		}
		
		public function step() 
		{

		}
		
	}
	
}
