package locdata 
{
	
	// Class for loading terrain maps from a file or retrieving them from variables
	// Contained within the 'world' object
	import flash.net.URLLoader; 
	import flash.net.URLRequest; 
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	public class LandLoader 
	{

		public var id:String;
		
		public var roomsFile:String;
		var loader_rooms:URLLoader; 
		var request:URLRequest;
		
		public var test:Boolean=false;
		public var loaded:Boolean=false;
		public var errLoad:Boolean=false;
		
		public var allroom:XML;
		
		public function LandLoader(nid:String) 
		{
			id=nid;
			roomsFile=GameData.d.land.(@id==id).@file;
			test=GameData.d.land.(@id==id).@test>0;
			// Source of location templates
			if (World.world.roomsLoad) 
			{
				loader_rooms = new URLLoader();
				var roomsURL=World.world.landPath+roomsFile+".xml";
				request = new URLRequest(roomsURL); 
				try 
				{
					loader_rooms.load(request); 
				} 
				catch(err) 
				{
					errLoad=true;
					trace('no load '+roomsFile);
					World.world.load_log+='Load error '+roomsFile+'\n';
				}
				loader_rooms.addEventListener(Event.COMPLETE, onCompleteLoadRooms); 
				loader_rooms.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler); 
			} 
			else 
			{
				allroom=World.world.rooms.rooms[roomsFile];
				loaded=true;
				World.world.load_log+='Land '+roomsFile+' loaded\n';
				if (!test) World.world.roomsLoadOk();
			}
		}

		function onCompleteLoadRooms(event:Event):void  
		{
			loaded=true;
			World.world.load_log+='Land '+roomsFile+' loaded\n';
			allroom = new XML(loader_rooms.data);
			if (!test) World.world.roomsLoadOk();
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void 
		{
			World.world.load_log+='IOerror '+roomsFile+'\n';
        }
		
	}
	
}
