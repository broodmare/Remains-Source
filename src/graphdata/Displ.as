package graphdata
{
	
	import flash.display.MovieClip;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.BitmapDataChannel;
    import flash.display.GradientType;
    import flash.display.SpreadMethod;
    import flash.filters.BitmapFilter;
    import flash.filters.DisplacementMapFilter;
    import flash.filters.DisplacementMapFilterMode;
    import flash.geom.Matrix;
    import flash.geom.Point;
	
	// This class is responsible for the main menu animation
	
	import stubs.displVolna;
	import stubs.visWav;
	import stubs.visSerost;

	public class Displ 
	{
		//Setting all variables as public.
		public var mm:MovieClip;
		public var gr:MovieClip;
		
		public var displFilter1:DisplacementMapFilter;
		public var displFilter2:DisplacementMapFilter;

		public var displBmpd:BitmapData;
		public var displStamp:MovieClip;
		public var displPoint:Point = new Point(0, 0);
		public var displMatrix:Matrix = new Matrix();
		public var displX:Number = 10;
		public var displY:Number = 15;
		public var disp_t:int = 0;
		
		public var wavKol:int = 10;
		public var wavArr:Array = [];
		public var disX:int = 200;
		public var disY:int = 250;
		public var spd:Number = 1;
		
		public var t_anim:int = 0;
		public var t_klip:int = 60;
		public var t_lightning:int = 120;
		public var p_x:Number;
		public var p_y:Number;
		
		public function Displ(nmm:MovieClip, ngr:MovieClip=null) 
		{
			mm = nmm;
			gr = ngr;
			displBmpd = new BitmapData(240, 300, false, 0x7F7F7F);
			displStamp = new displVolna();
			displMatrix.tx = mm.target.x - mm.displ1.x;
			displMatrix.ty = mm.target.y - mm.displ1.y;
			displFilter1 = new DisplacementMapFilter(displBmpd,displPoint,BitmapDataChannel.RED,BitmapDataChannel.RED,displX,displY,DisplacementMapFilterMode.COLOR);
			displFilter2 = new DisplacementMapFilter(displBmpd,displPoint,BitmapDataChannel.RED,BitmapDataChannel.RED,0,5,DisplacementMapFilterMode.COLOR);
			for (var i:int = 0; i < wavKol; i++) 
			{
				var v:MovieClip = new visWav();
				v.x = Math.random() * disX * 2 - disX;
				v.y = Math.random() * disY * 2 - disY;
				v.scaleX = Math.random() + 2;
				v.scaleY = 3;
				displStamp.addChild(v);
				wavArr[i] = v;
			}
			v = new visSerost();
			displStamp.addChild(v);
			p_x = mm.pistol.x;
			p_y = mm.pistol.y;
			if (gr) 
			{
				gr.tuchi.cacheAsBitmap = true;
				gr.maska.cacheAsBitmap = true;
				gr.tuchi.blendMode = 'screen';
				gr.tuchi.mask = gr.maska;
			}
		}
		
		public function anim():void
		{
			t_anim++;
			t_klip--;
			if (t_klip <= 0) 
			{
				mm.eye.play();
				t_klip = Math.floor(Math.random() * 110 + 60);
			}
			for (var i:int = 0; i < wavKol; i++) 
			{
				var v:MovieClip = wavArr[i];
				v.x -= (spd + i / 2);
				v.y += (spd + i / 2) * 0.3;
				if (v.x < -disX * 2) 
				{
					v.x = disX;
					v.scaleX = Math.random() + 2;
					v.scaleY = 3;
					v.alpha = Math.random() * 0.5 + 0.5;
				}
				if (v.y > disY) v.y = -disY;
			}
			displBmpd.draw(displStamp,displMatrix);
			mm.displ1.filters = [displFilter1];
			mm.displ2.filters = [displFilter2];
			mm.pistol.x = p_x+Math.sin(t_anim / 100) * 2;
			mm.pistol.y = p_y-(Math.cos(t_anim / 100) - 1) * 8;
			mm.pistol.magic.krug.rotation = t_anim;
			mm.pistol.magic2.krug.rotation = 90 + t_anim * 0.67;
			mm.horn.magic.krug.rotation = 90 + t_anim * 0.67;
			if (gr) 
			{
				t_lightning--;
				if (t_lightning == 0) 
				{
					gr.x = Math.random() * 1800;
					gr.y = Math.random() * 350;
					gr.scaleX = 1 - gr.y / 800;
					gr.scaleY = 1 - gr.y / 800;
					gr.moln.moln.rotation = Math.random() * 360;
					gr.moln.moln.gotoAndStop(Math.floor(Math.random() * gr.moln.moln.totalFrames + 1));
					gr.alpha = 1;
					gr.visible = true;
					gr.tuchi.x = -200 - Math.random() * 400
					gr.tuchi.y = -200 - Math.random() * 300
				} 
				else if (t_lightning < 0) 
				{
					gr.alpha = Math.min(1, Math.random() * 0.5 + t_lightning / 12 + 0.7);
					if (t_lightning<-6 && Math.random() < 0.1) t_lightning = -100;
				}
				if (t_lightning < -30) 
				{
					t_lightning = Math.floor(Math.random() * 200 + 100);
					gr.visible = false;
				}
			}
		}
		
		
	}
	
}
