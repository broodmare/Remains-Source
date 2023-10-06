package systems
{
	import flash.net.URLLoader; 
	import flash.net.URLRequest; 
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.system.Capabilities;

    public class XMLLoader
    {

        // TextLoader properties

		

		private var url:String;
		private var importedData:XML;

		private var loaderURL:URLRequest;
		private var loader:URLLoader;

		private var progress:Number;
		private var returnProgress:Function;
		private var returnData:Function;
		
		public function XMLLoader()
		{

		}


		public function load(fileURL:String, dataReturnCallback:Function, progressUpdateCallback:Function = null):void
		{
			trace('XMLLoader.as/load() - Received fileURL parameter: (' + fileURL + ')');
			
			url = fileURL;
			returnProgress = progressUpdateCallback; //What function to call when there's loading progress.
			returnData = dataReturnCallback;

			loaderURL = new URLRequest(url);
			loader = new URLLoader();
			
			addListeners();
			trace('XMLLoader.as/load() - Attempting to load ' + loaderURL.url);
			loader.load(loaderURL);

		}

		private function addListeners():void
		{
			loader.addEventListener(Event.COMPLETE, eventHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, eventHandler);
			loader.addEventListener(ProgressEvent.PROGRESS, eventHandler);
		}

		private function cleanup():void	//Nullify everything to save data and hopefully make this object available for GC.
		{
			loader.removeEventListener(Event.COMPLETE, eventHandler);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, eventHandler);
			loader.removeEventListener(ProgressEvent.PROGRESS, eventHandler);
			loader = null;
			loaderURL = null;
    		url = null;
			importedData = null;
			returnProgress = null;
			returnData = null;
		}


		private function eventHandler(event:Event):void 
		{
			switch (event.type) 
			{
				case Event.COMPLETE:

					importedData = new XML(loader.data);
					trace('XMLLoader.eventHandler/COMPLETE() - ' + loaderURL.url + 'Loaded, executing callback.');
					returnData(importedData);
					cleanup();
					break;
				
				case IOErrorEvent.IO_ERROR:

					trace('XMLLoader.eventHandler/IO_ERROR() - ' + loaderURL.url + 'Failed to load, IO Error.' + IOErrorEvent(event).text);
					cleanup();
					break;

				case ProgressEvent.PROGRESS:
				
					var progressEvent:ProgressEvent = event as ProgressEvent;
					if (returnProgress != null)
					{

						progress = progressEvent.bytesLoaded / progressEvent.bytesTotal;
						returnProgress(progress);
					}
					break;

				default:

					trace("XMLLoader.eventHandler() - Unhandled event type: " + event.type + '. ' + loaderURL);
					cleanup();
					break;
			}
		}
	}
}