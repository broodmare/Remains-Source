package graphdata
{

	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.display.MovieClip;

	
	public class Part  extends Pt
	{
		public var vClass:Class;
		
		public var isMove:Boolean = false;
		public var isAnim:int = 0;
		public var isAlph:Boolean = false;
		public var isPreAlph:Boolean = false;

		public var dr:Number=0;
		public var r:Number=0;
		public var ddy:Number=0;

		public var liv:int = 20;
		public var mliv:int = 20;
		public var brake:Number = 1;
		public var otklad:int = 0;


		public var blitData:BitmapData;
		public var blitX:int = 120;
		public var blitY:int = 120;
		public var blitRect:Rectangle;
		public var blitPoint:Point;
		public var visData:BitmapData;
		public var visBmp:Bitmap;
		public var blitFrame:Number = 0;
		public var blitDelta:Number = 1;
		public var blitMFrame:int = -1;
		
		public var water:int = 0;
		public var maxkol:int = 0;
		
		public function Part() 
		{
			
		}
		
		public override function setNull(f:Boolean=false):void
		{
			if (visData) 
			{
				visData.dispose();
			}

			room.remObj(this);
			
			if (maxkol > 0) 
			{
				Emitter.kols[maxkol]--;
			}
			
		}
		
		public function initBlit(blitId:String):void //Create a bitmap
		{
			blitData = World.world.grafon.getSpriteList(blitId, 1);
			blitRect = new Rectangle(0, 0, blitX, blitY);
			blitPoint = new Point(0,0);
			vis = new MovieClip();
			visData = new BitmapData(blitX, blitY, true, 0);
			visBmp = new Bitmap(visData);
			vis.addChild(visBmp);
			visBmp.x = -blitX / 2;
			visBmp.y = -blitY / 2;
			vis.x = X;
			vis.y = Y;
			vis.rotation = r;

			if (isAnim == 0) 
			{
				var n:int = Math.floor(Math.random() * blitData.width / blitX);
				blit(n);
			}
		}
		
		public function blit(blframe:int):void
		{
			blitRect.x = blframe * blitX;
			blitRect.y = 0;
			visData.copyPixels(blitData, blitRect, blitPoint);
		}
		
		public function initVis(frame:int = 0):void
		{
			if (vClass) vis = new vClass();
			else return;
			if (frame == 0) vis.gotoAndStop(Math.floor(Math.random() * vis.totalFrames + 1));
			else vis.gotoAndStop(frame);
			if (isAnim == 0) vis.cacheAsBitmap = true;
			else if (isAnim == 2) vis.gotoAndPlay(Math.floor(Math.random() * vis.totalFrames) + 1);
			else vis.gotoAndPlay(frame + 1);
			vis.x = X;
			vis.y = Y;
			vis.rotation = r;
		}
		
		public override function step():void
		{

			if (otklad > 0) 
			{
				vis.visible = false;
				vis.stop();
				otklad--;
				return;
			} 

			else if (!vis.visible)
			{
				vis.visible = true;
				if (isAnim > 0) vis.play();
			}

			if (isMove) 
			{
				X += dx;
				Y += dy;
				dy += ddy;
				r += dr;
				vis.x = X;
				vis.y = Y;
				vis.rotation = r;
				dx *= brake;
				dy *= brake;
			}
			
			if (isAlph && liv < 9) 
			{
				vis.alpha = liv / 10;
			}
			else if (isPreAlph && (mliv - liv < 9)) 
			{
				vis.alpha = (mliv - liv) / 10;
			}

			else if (isAlph || isPreAlph) 
			{
				vis.alpha = 1;
			}

			if (isAnim && blitData && blitFrame * blitX < blitData.width) 
			{
				blit(Math.floor(blitFrame));
				blitFrame += blitDelta;
				if (blitMFrame > 0 && blitFrame >= blitMFrame) blitFrame = 0;
			}

			if (water > 0) 
			{
				var voda = room.getAbsTile(X, Y).water;
				if (water == 2 && voda == 0 || water == 1 && voda > 0) liv = 1;
			}

			liv--;

			if (liv <= 0) 
			{
				setNull();
			}

			Emitter.kol1++;
		}

	}
	
}
