package
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.events.Event;
    import flash.ui.ContextMenu;
    import flash.ui.ContextMenuItem;
    import flash.ui.ContextMenuBuiltInItems;
    import flash.events.ContextMenuEvent;
	import flash.display.LoaderInfo;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.system.Security;
	
	import stubs.loadingWidget;
	
	public class Main extends flash.display.MovieClip
	{
		
		public var mainMenu:MainMenu;

		public function Main() 
		{
			trace('Main.as/Main() - Entering Main()...');

			stage.scaleMode = "noScale";
			stage.align 	= StageAlign.TOP_LEFT;
			stage.color 	= 0;

			var myMenu:ContextMenu = new ContextMenu();
			myMenu.hideBuiltInItems();
			myMenu.builtInItems.quality = true;
			contextMenu = myMenu;
			myMenu.customItems.push(new ContextMenuItem("Hello!", false, true, false));

			stop();

			addEventListener(Event.ENTER_FRAME, onEnterFrameLoader);
		}
		
		public function onEnterFrameLoader(event:Event):void
		{
			var bLoaded:uint = loaderInfo.bytesLoaded;
			var bTotal:uint = loaderInfo.bytesTotal;
			//if (loadingWidget.alpha < 1) 
			//{
				//loadingWidget.alpha += 0.05;
			//}
			//loadingWidget.progres.text = 'Loading ' + Math.round(bLoaded / bTotal * 100) + '%';


			if (bLoaded >= bTotal)
			{
				//loadingWidget.visible = false;
				removeEventListener(Event.ENTER_FRAME, onEnterFrameLoader);
				nextFrame();

				trace('Main.as/onEnterFrameLoader() - Creating new mainMenu...');
				mainMenu = new MainMenu(this);
				
			}
		}

	}
}
