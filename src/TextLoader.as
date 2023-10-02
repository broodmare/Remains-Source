package
{
	
	//A class that performs the loading of text files
	import flash.net.URLLoader; 
	import flash.net.URLRequest; 
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	
	public class TextLoader 
	{

		public var id:String;
		public var n:int=0;
		var def:Boolean=false;
		
		public var textFile:String;
		var loader_text:URLLoader; 
		var request:URLRequest;
		public var progressLoad:Number=0;
		
		public var loaded:Boolean=false;
		public var errLoad:Boolean=false;
		
		public var d:XML;
		
		public function TextLoader(nfile:String, ndef:Boolean=false) 
		{
			def=ndef;
			textFile=nfile;
			loader_text = new URLLoader(); 
			request = new URLRequest(textFile); 
			loader_text.load(request); 
			loader_text.addEventListener(Event.COMPLETE, onCompleteLoadText);
			loader_text.addEventListener(IOErrorEvent.IO_ERROR, onErrorLoadText);
			loader_text.addEventListener(ProgressEvent.PROGRESS, funProgress);
		}

		function onCompleteLoadText(event:Event):void  
		{
			loaded=true;
			World.world.load_log+='Text '+textFile+' loaded\n';
			try {
				d = new XML(loader_text.data);
				if (def) Res.e = d;
				loaded=true;
			} 
			catch(err) 
			{
				World.world.load_log+='Text file error '+textFile+'\n';
				errLoad=true;
			}
			World.world.textsLoadOk();
			loader_text.removeEventListener(Event.COMPLETE, onCompleteLoadText);
			loader_text.removeEventListener(IOErrorEvent.IO_ERROR, onErrorLoadText);
		}
		
		private function onErrorLoadText(event:IOErrorEvent):void 
		{
			errLoad=true;
			World.world.load_log+='File not found '+textFile+'\n';
			World.world.textsLoadOk();
			loader_text.removeEventListener(Event.COMPLETE, onCompleteLoadText);
			loader_text.removeEventListener(IOErrorEvent.IO_ERROR, onErrorLoadText);
			loader_text.removeEventListener(ProgressEvent.PROGRESS, funProgress);
        }
		
		function funProgress(event:ProgressEvent):void 
		{
			progressLoad=event.bytesLoaded/event.bytesTotal;
			World.world.textProgressLoad=progressLoad;
        }
		
	}
	
}
