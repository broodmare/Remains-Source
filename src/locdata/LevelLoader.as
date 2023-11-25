package locdata 
{
	
	// Class for loading terrain maps from a file or retrieving them from variables
	// Contained within the 'world' object
	import flash.net.URLLoader; 
	import flash.net.URLRequest; 
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	import components.Settings;
	import components.XmlBook;
	
	public class LevelLoader 
	{

		public var id:String;
		
		public var roomsFile:String;
		public var request:URLRequest;
		public var loader_rooms:URLLoader; 
		
		
		public var loaded:Boolean 	= false; //I don't think these are used.
		public var errLoad:Boolean 	= false; //I don't think these are used.
		
		public var allroom:XML;
		
		

		public function LevelLoader(nid:String) 
		{
			var roomsURL:String = Settings.levelPath + roomsFile + ".xml";

			id = nid;
			roomsFile = XmlBook.getXML("levels").level.(@id == id).@file;
			// Source of room templates
			
			request = new URLRequest(roomsURL); 
			loader_rooms = new URLLoader(request);


			loader_rooms.addEventListener(Event.COMPLETE, onCompleteLoadRooms); 
			loader_rooms.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler); 

		}

		public function onCompleteLoadRooms(event:Event):void  
		{
			loaded = true;
			World.world.load_log += 'roomsFile ' + roomsFile + ' loaded.\n';
			allroom = new XML(loader_rooms.data);
			World.world.levelsLoaded++
			World.world.roomsLoadOk();
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void 
		{
			trace('LevelLoader.as/onCompleteLoadRooms() - Rooms failed to load, IO Error.');
			World.world.load_log += 'IOerror ' + roomsFile + '\n';
        }
		
	}
	
}
