package graphdata
{
	
	import flash.net.URLRequest;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	
	public class GrLoader 
	{
		
		public var id:int;
		public var loader:Loader;
		public var progressLoad:Number=0;
		public var isLoad:Boolean=false;
		public var resource:*;
		var gr:Grafon;
		

		public static var instanceCount:int=0;  //How many instances of the graphics loader (this class) exist.  Used to determine when all graphics are loaded.
		public static var completedInstances:int=0; //How many instances are loaded.  Used to determine when all graphics are loaded.

		public function GrLoader(nid:int, url:String, ngr:Grafon) {
			instanceCount++; //Increment the number of instances of that exist.

			gr = ngr; //Assign the graphics loader a local name.
			id = nid; //Assign the graphics loader an ID.

			loader = new Loader();

			var urlReq:URLRequest = new URLRequest(url); 										//What file to load.
			loader.load(urlReq); 																//Load the file.
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, funProgress); 	//Add event listeners to check loading progress.
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, funLoaded); 			 	//Add event listeners to check if file loading is complete.
			
		}
		

		//What to do when the file is loaded.
		function funLoaded(event:Event):void 
		{

			resource = event.target.content;
			isLoad=true; 		// Indicate the file is fully loaded.  CHECK IF THIS IS EVEN USED.
			progressLoad = 1; 	// Set the progress to 100%.
			completedInstances++; 		// Increase the global number of loaded instances.

			gr.checkLoaded(id); 
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, funLoaded); 			//Remove the event listeners.
			loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, funProgress);  //Remove the event listeners.
 		}

		//Determine the progress of the file loading.
		function funProgress(event:ProgressEvent):void 
		{
			progressLoad = event.bytesLoaded/event.bytesTotal; //Progress is the number of bytes loaded divided by the total number of bytes.
			gr.allProgress();
        }

	}
	
}
