package locdata 
{
	
	// Room template class
	
	public class RoomTemplate
	{
		
		public var xml:XML;
		public var id:String;
		public var tip:String;
		
		public var roomCoordinateX:int = 0;
		public var roomCoordinateY:int = 0;
		public var roomCoordinateZ:int = 0;
		
		public var lvl:int = 0;
		public var back:String;
		
		public var kol = 2;
		public var rnd:Boolean = true;	// Can be used as a random one
		
		public static var nornd:Array = ["beg0","back","roof","pass","passroof","roofpass","vert","surf"];

		public function RoomTemplate(nxml:XML) 
		{
			xml = nxml;
			id = xml.@name;
			if (xml.@x.length()) roomCoordinateX = xml.@x;
			if (xml.@y.length()) roomCoordinateY = xml.@y;
			if (xml.@z.length()) roomCoordinateZ = xml.@z;
			if (xml.options.length()) 
			{
				if (xml.options.@tip.length()) tip = xml.options.@tip;
				if (xml.options.@level.length()) lvl = xml.options.@level;
				if (xml.options.@back.length()) back = xml.options.@back;
				if (tip == "uniq") kol = 1;
				if (xml.options.@uniq.length()) kol = 1;
				for each (var st in nornd) 
				{
					if (tip == st) 
					{
						rnd = false;
						break;
					}
				}
				if (xml.options.@nornd.length()) rnd = false;
			}
		}

	}
	
}
