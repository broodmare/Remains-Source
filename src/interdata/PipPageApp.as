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
			World.world.gg.refreshVis();
			pip.onoff(-1);
		}
		//принять настройки внешности
		public function funVidCancel():void
		{
			pip.onoff(-1);
		}

		override function setSubPages():void
		{
			trace('PipPageApp.as/setSubPages() - updating subPages.');

			vis.bottext.visible = false;
			vis.butOk.visible 	= false;
			statHead.visible 	= false;

			setTopText();
			if (page2 == 1) 
			{
				pip.ArmorId = '';
				World.world.app.attach(vis, funVidOk, funVidCancel);
				World.world.app.vis.y = 400;
				World.world.app.vis.x = 444;
				World.world.app.vis.fon.visible = false;
			}
			
			trace('PipPageApp.as/setSubPages() - Finished updating subPages.');

		}
		
		
	}
	
}
