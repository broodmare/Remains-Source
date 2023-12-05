package interdata 
{
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	import stubs.visPipQuestItem;
	
	public class PipPageApp extends PipPage
	{
		

		public function PipPageApp(npip:PipBuck, npp:String)
		{
			itemClass = visPipQuestItem;
			super(npip,npp);
			vis.but1.visible=vis.but2.visible=vis.but3.visible=vis.but4.visible=vis.but5.visible=false;
			trace('PipPageApp.as/PipPageApp() - Created PipPageApp page.');
		}
		
		//принять настройки внешности
		public function funVidOk():void
		{
			GameSession.currentSession.gg.refreshVis();
			pip.onoff(-1);
		}
		//принять настройки внешности
		public function funVidCancel():void
		{
			pip.onoff(-1);
		}

		//set public
		public override function setSubPages():void
		{
			trace('PipPageApp.as/setSubPages() - updating subPages.');

			vis.bottext.visible = false;
			vis.butOk.visible 	= false;
			statHead.visible 	= false;

			setTopText();
			if (page2 == 1) 
			{
				pip.ArmorId = '';
				GameSession.currentSession.appearanceWindow.attach(vis, funVidOk, funVidCancel);
				GameSession.currentSession.appearanceWindow.window.y = 400;
				GameSession.currentSession.appearanceWindow.window.x = 444;
				GameSession.currentSession.appearanceWindow.window.fon.visible = false;
			}
			
			trace('PipPageApp.as/setSubPages() - Finished updating subPages.');

		}
		
		
	}
	
}
