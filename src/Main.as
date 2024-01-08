package
{
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.events.Event;
    import flash.ui.ContextMenu;
    import flash.ui.ContextMenuItem;
	
	import stubs.LoadingWidget;
	
	public class Main extends MovieClip
	{

		public var mainMenu:MainMenu;

		//Symbol linkages defined in the '.fla' file.		
		public var loadingWidget:MovieClip;


		public function Main()
		{
			trace('Main.as/Main() - Entering Main()...');

			stage.scaleMode = "noScale";
			stage.align 	= StageAlign.TOP_LEFT;
			stage.color 	= 0;

			trace('Creating Loading Widget.');
			loadingWidget = new LoadingWidget();
			
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

			if (loadingWidget != null)
			{
				if (loadingWidget.alpha < 1 && loadingWidget ) 
				{
					loadingWidget.alpha += 0.05;
				}
				loadingWidget.progres.text = 'Loading ' + Math.round(bLoaded / bTotal * 100) + '%';
			}

			if (bLoaded >= bTotal)
			{
				loadingWidget.visible = false;
				removeEventListener(Event.ENTER_FRAME, onEnterFrameLoader);

				nextFrame();
				trace('Main.as/onEnterFrameLoader() - Creating new mainMenu.');
				
				mainMenu = new MainMenu(this);
			}
		}
	}
}