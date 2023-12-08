package graphdata
{
	
	import flash.net.URLRequest;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	
	public class GrLoader 
	{
		
		public var loaderID:int;
		public var loader:Loader;
		public var progressLoad:Number;
		public var isLoad:Boolean;
		public var grafon:Grafon;
		public var resource:*;
		public static var instanceCount:int		 = 0;  	//How many instances of the graphics loader (this class) exist. Used to determine when all graphics are loaded.
		public static var completedInstances:int = 0; 	//How many instances are loaded. Used to determine when all graphics are loaded.
		private var resourceURL:String;


		public function GrLoader(ID:int, url:String, gr:Grafon) 
		{
			
			instanceCount++; 		//Increment the number of instances of that exist.
			resourceURL = url;
			progressLoad = 0;
			isLoad = false;
			grafon = gr; 			//Grafon pointer to call it's functions later.
			loaderID = ID; 			//Assign the graphics loader an ID.

			//trace('GrLoader.as/GrLoader() - New loader (' + loaderID + ') created. Instance count: "' + instanceCount + '." Content: "' + resourceURL + '."');
			loader = new Loader(); 	// Sets the loader a new Flash.Loader class.
			
			trace('GrLoader.as/GrLoader() - Attempting to load resources from url: "' + url + '"');
			var urlReq:URLRequest = new URLRequest(url);	//What file to load.
			loader.load(urlReq);	//Load the file.
																
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, funProgress); 	//Add event listeners to check loading progress.
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, funIOError)
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, funLoaded); 			 	//Add event listeners to check if file loading is complete.
			
		}
		

		//What to do when the file is loaded.
		public function funLoaded(event:Event):void 
		{
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, funLoaded);
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, funIOError);
			loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, funProgress);

			resource = event.target.content; // Set 'resource' as the loaded content.

			//trace('GrLoader.as/funLoaded() - Loader (' + loaderID + ') finished loading: "' + resourceURL + '."');

			isLoad = true; 				// Indicate the file is fully loaded.  CHECK IF THIS IS EVEN USED.
			progressLoad = 1; 			// Set the progress to 100%.
			completedInstances++; 		// Increase the global number of loaded instances.

			grafon.checkLoaded(); 

 		}

		public function funIOError(event:IOErrorEvent):void
		{
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, funLoaded);
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, funIOError);
			loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, funProgress);

			{
				trace('GrLoader.as/funIOError() - ERROR: IO error while loading graphics: "' + event.text);
			}
		}

		//Determine the progress of the file loading.
		public function funProgress(event:ProgressEvent):void 
		{
			progressLoad = event.bytesLoaded/event.bytesTotal; //Progress is the number of bytes loaded divided by the total number of bytes.
			grafon.allProgress();
        }

	}
}
