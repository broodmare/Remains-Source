package systems
{
	import flash.net.URLLoader; 
	import flash.net.URLRequest; 
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;

    public class XMLLoader extends EventDispatcher 
    {

        // TextLoader properties

		
		public var xmlData:XML;
		private var fileURL:String;

		private var loaderURL:URLRequest;
		private var loader:URLLoader;

		private var callerID:String;

		public static const XML_LOADED:String = "xml_Loaded";


		public function XMLLoader()
		{

		}


		public function load(url:String, caller:String):void
		{

			callerID = caller;	//What function instantiated the loader.
			fileURL = url;		//What file is being loaded.
			
			//trace('XMLLoader.as/load() - Function: "' + callerID + '" is requesting to load file: "' + fileURL + '."');

			loaderURL = new URLRequest(fileURL);
			loader = new URLLoader();
			
			loader.addEventListener(Event.COMPLETE, loaderFinished);
			loader.addEventListener(IOErrorEvent.IO_ERROR, loaderFinished);

			loader.load(loaderURL);
			
		}


		private function loaderFinished(event:Event):void
		{
			event.target.removeEventListener(Event.COMPLETE, loaderFinished);
			event.target.removeEventListener(IOErrorEvent.IO_ERROR, loaderFinished);


			switch (event.type) 
			{
				case Event.COMPLETE:

					xmlData = new XML(loader.data);

					//trace('XMLLoader.as/loaderFinished() - File: "' + fileURL + '" requested by "' + callerID + '" is done loading. Firing event to notify the caller.')
					dispatchEvent(new Event(XMLLoader.XML_LOADED));
					break;
				
				case IOErrorEvent.IO_ERROR:

					trace('XMLLoader.as/loaderFinished() - File: "' + fileURL + '" requested by "' + callerID + '" failed to load! IO_ERROR.');
					break;
			}
		}

	}
}