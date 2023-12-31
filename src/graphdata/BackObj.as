package graphdata
{
	import flash.display.MovieClip;
	import flash.utils.*;

	import locdata.Room;
	
	import components.Settings;
	import components.XmlBook;
	
	public class BackObj 
	{
		public var id:String;
		public var X:Number;
		public var Y:Number;
		public var scX:Number = 1;
		public var scY:Number = 1;
		public var vis:MovieClip; 	// Texture of the background object.
		public var erase:MovieClip;	// Parts to erase from the background object texture.
		public var light:MovieClip; // Texture to overlay on the background object (Light Glow).
		public var frame:int = 1;
		public var frameOn:int = 0;
		public var frameOff:int = 0;
		public var blend:String = 'normal';
		public var alpha:Number = 1;
		public var layer:int = 0;
		public var er:Boolean = false;	// Erasure

		public function BackObj(newRoom:Room, nid:String, nx:Number, ny:Number, xml:XML = null)
		{
			id = nid;
			X = nx;
			Y = ny;

			var node:XML = XmlBook.getXML("backgroundObjects").back.(@id == id)[0];
			var wid:int = node.@x2 * Settings.tilePixelWidth;

			if (xml && xml.@w.length()) wid = xml.@w * Settings.tilePixelWidth
			if (!(wid > 0)) wid = Settings.tilePixelWidth;
			if (newRoom && newRoom.mirror) 
			{
				if (node.@mirr == '2' && Math.random() < 0.5) 
				{
					X = newRoom.roomPixelWidth - X;
					scX = -1;
				} 
				else if (node.@mirr == '1') 
				{
					X = newRoom.roomPixelWidth - X;
					scX = -1;
				} 
				else 
				{
					X = newRoom.roomPixelWidth - X - wid;
				}
			} 
			else if (node.@mirr == '2' && Math.random() < 0.5) 
			{
				X = nx + wid;
				scX = -1;
			}
			
			//TODO: This is called 3 times for every background object even if it doesn't have an erase or light textures.
			vis 	= GameSession.currentSession.grafon.getObj('back_' + (node.@tid.length() ? node.@tid:id) + '_t', Grafon.bgObjectCount); 	// Texture
			erase 	= GameSession.currentSession.grafon.getObj('back_' + (node.@tid.length() ? node.@tid:id) + '_e', Grafon.bgObjectCount); 	// Erase parts of texture?
			light 	= GameSession.currentSession.grafon.getObj('back_' + (node.@tid.length() ? node.@tid:id) + '_l', Grafon.bgObjectCount); 	// Light

			if (node.@fr.length()) frame = node.@fr;
			else if (newRoom.lightOn > 0 && node.@lon.length()) frame = node.@lon;
			else if (newRoom.lightOn < 0 && node.@loff.length()) frame = node.@loff;
			else if (vis) frame = Math.floor(Math.random() * vis.totalFrames + 1);
			else frame = 1;

			if (node.@s.length()) layer = node.@s;
			if (node.@blend.length()) blend = node.@blend;
			if (node.@alpha.length()) alpha = node.@alpha;
			if (node.@er.length()) er = true;
			if (xml) 
			{
				if (xml.@w.length()) scX = xml.@w;
				if (xml.@h.length()) scY = xml.@h;
				if (xml.@a.length()) alpha = xml.@a;
				if (xml.@fr.length()) frame = xml.@fr;
				if (xml.@lon.length && xml.@lon > 1 && node.@lon.length()) frame = node.@lon;
				if (xml.@lon.length && xml.@lon < 1 && node.@loff.length()) frame = node.@loff;
			}
			if (frame > 0) 
			{
				if (vis) vis.gotoAndStop(frame);
				if (erase) erase.gotoAndStop(frame);
				if (light) light.gotoAndStop(frame);
			}
			if (node.@loff.length()) frameOff = node.@loff;
			if (node.@lon.length()) frameOn = node.@lon;
		}
		
		public function onoff(n:int):void
		{
			if (n > 0 && frameOn) frame = frameOn;
			if (n < 0 && frameOff) frame = frameOff;
			if (frame > 0) 
			{
				if (vis) vis.gotoAndStop(frame);
				if (erase) erase.gotoAndStop(frame);
				if (light) light.gotoAndStop(frame);
			}
		}

	}
	
}
