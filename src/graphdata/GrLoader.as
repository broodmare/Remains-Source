package graphdata
{
	
	import flash.net.URLRequest;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	
	public class GrLoader 
	{
		
		public var loaderID:int;
		public var loader:Loader;
		public var progressLoad:Number;
		public var isLoad:Boolean;
		public var grafon:Grafon;
		public var resource:*;

		public static var instanceCount:int		 = 0;  	//How many instances of the graphics loader (this class) exist.  Used to determine when all graphics are loaded.
		public static var completedInstances:int = 0; 	//How many instances are loaded.  Used to determine when all graphics are loaded.

		public function GrLoader(ID:int, url:String, gr:Grafon) 
		{
			instanceCount++; 		//Increment the number of instances of that exist.

			progressLoad = 0;
			isLoad = false;
			grafon = gr; 			//Assign the graphics loader a local name.
			loaderID = ID; 	//Assign the graphics loader an ID.
			loader = new Loader(); 	// Sets the loader a new Flash.Loader class.


			var urlReq:URLRequest = new URLRequest(url); 										//What file to load.
			loader.load(urlReq); 																//Load the file.
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, funProgress); 	//Add event listeners to check loading progress.
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, funLoaded); 			 	//Add event listeners to check if file loading is complete.
			
		}
		

		//What to do when the file is loaded.
		public function funLoaded(event:Event):void 
		{

			resource = event.target.content; // Set 'resource' as the loaded content.
			
			if (resource == null)
			{
				trace('ressource:', resource, 'failed to load.')
			}

			isLoad = true; 				// Indicate the file is fully loaded.  CHECK IF THIS IS EVEN USED.
			progressLoad = 1; 			// Set the progress to 100%.
			completedInstances++; 		// Increase the global number of loaded instances.

			grafon.checkLoaded(); 
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, funLoaded); 			//Remove the event listeners.
			loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, funProgress);  //Remove the event listeners.
 		}

		//Determine the progress of the file loading.
		public function funProgress(event:ProgressEvent):void 
		{
			progressLoad = event.bytesLoaded/event.bytesTotal; //Progress is the number of bytes loaded divided by the total number of bytes.
			grafon.allProgress();
        }

	}
}
