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

		
		
		public var roomsFile:String;	//TODO: Remove this.

		public var request:URLRequest;
		public var loader:URLLoader;


		public var id:String;	//ID of the level.
		public var allroom:XML;	//Stores the XML data containing all rooms in a level.
		
		

		public function LevelLoader(nid:String) 
		{
			id = nid;

			roomsFile = XmlBook.getXML("levels").level.(@id == id).@file;
			var roomsURL:String = Settings.levelPath + roomsFile + ".xml";

			request = new URLRequest(roomsURL); 
			loader = new URLLoader(request);


			loader.addEventListener(Event.COMPLETE, onCompleteLoadRooms); 
			loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler); 

		}

		public function onCompleteLoadRooms(event:Event):void  
		{
			event.target.removeEventListener(Event.COMPLETE, onCompleteLoadRooms);
			event.target.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);

			trace('LevelLoader.as/onCompleteLoadRooms() - roomsFile "' + roomsFile + '", loaded.');
			World.world.load_log += 'roomsFile ' + roomsFile + ' loaded.\n';
			allroom = new XML(loader.data);
			
			World.world.levelsLoaded++
			World.world.allLevelsLoadedCheck();
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void 
		{
			event.target.removeEventListener(Event.COMPLETE, onCompleteLoadRooms);
			event.target.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);

			trace('LevelLoader.as/ioErrorHandler() - Rooms failed to load, IO Error.');
			World.world.load_log += 'IOerror loading roomsFile.\n';
        }
		
	}
	
}
